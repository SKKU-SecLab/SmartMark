
pragma solidity 0.8.0;


                                                                                 
  

abstract contract ECRecovery {

  function recover(bytes32 hash, bytes memory sig) public pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    if (sig.length != 65) {
      return (address(0));
    }

    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    if (v < 27) {
      v += 27;
    }

    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



 

 
 interface ERC721
{


  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );

  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external;


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;


  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;


  function approve(
    address _approved,
    uint256 _tokenId
  )
    external;


  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external;


  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256);


  function ownerOf(
    uint256 _tokenId
  )
    external
    view
    returns (address);


  function getApproved(
    uint256 _tokenId
  )
    external
    view
    returns (address);


  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    view
    returns (bool);


}
 
interface ERC721TokenReceiver
{


  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    returns(bytes4);


}


interface ERC165
{


  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    view
    returns (bool);

    
}


contract SupportsInterface is
  ERC165
{


  mapping(bytes4 => bool) internal supportedInterfaces;

  constructor()
  {
    supportedInterfaces[0x01ffc9a7] = true; // ERC165
  }

  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    override
    view
    returns (bool)
  {

    return supportedInterfaces[_interfaceID];
  }

}


library AddressUtils
{


  function isContract(
    address _addr
  )
    internal
    view
    returns (bool addressCheck)
  {


    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    assembly { codehash := extcodehash(_addr) } // solhint-disable-line
    addressCheck = (codehash != 0x0 && codehash != accountHash);
  }

}





 
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
 
 
 

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface MintableERC20  {

     function mint(address account, uint256 amount) external ;

     function burn(address account, uint256 amount) external ;

}


 


contract NFToken is
  ERC721,
  SupportsInterface
{

  using AddressUtils for address;

  string constant ZERO_ADDRESS = "003001";
  string constant NOT_VALID_NFT = "003002";
  string constant NOT_OWNER_OR_OPERATOR = "003003";
  string constant NOT_OWNER_APPROVED_OR_OPERATOR = "003004";
  string constant NOT_ABLE_TO_RECEIVE_NFT = "003005";
  string constant NFT_ALREADY_EXISTS = "003006";
  string constant NOT_OWNER = "003007";
  string constant IS_OWNER = "003008";

  bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

  mapping (uint256 => address) internal idToOwner;

  mapping (uint256 => address) internal idToApproval;

  mapping (address => uint256) private ownerToNFTokenCount;

  mapping (address => mapping (address => bool)) internal ownerToOperators;

  modifier canOperate(
    uint256 _tokenId
  )
  {

    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender],
      NOT_OWNER_OR_OPERATOR
    );
    _;
  }

  modifier canTransfer(
    uint256 _tokenId
  )
  {

    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender
      || idToApproval[_tokenId] == msg.sender
      || ownerToOperators[tokenOwner][msg.sender],
      NOT_OWNER_APPROVED_OR_OPERATOR
    );
    _;
  }

  modifier validNFToken(
    uint256 _tokenId
  )
  {

    require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);
    _;
  }

  constructor()
  {
    supportedInterfaces[0x80ac58cd] = true; // ERC721
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    override
  {

    _safeTransferFrom(_from, _to, _tokenId, _data);
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
  {

    _safeTransferFrom(_from, _to, _tokenId, "");
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {

    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from, NOT_OWNER);
    require(_to != address(0), ZERO_ADDRESS);

    _transfer(_to, _tokenId);
  }

  function approve(
    address _approved,
    uint256 _tokenId
  )
    external
    override
    canOperate(_tokenId)
    validNFToken(_tokenId)
  {

    address tokenOwner = idToOwner[_tokenId];
    require(_approved != tokenOwner, IS_OWNER);

    idToApproval[_tokenId] = _approved;
    emit Approval(tokenOwner, _approved, _tokenId);
  }

  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external
    override
  {

    ownerToOperators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function balanceOf(
    address _owner
  )
    external
    override
    view
    returns (uint256)
  {

    require(_owner != address(0), ZERO_ADDRESS);
    return _getOwnerNFTCount(_owner);
  }

  function ownerOf(
    uint256 _tokenId
  )
    external
    override
    view
    returns (address _owner)
  {

    _owner = idToOwner[_tokenId];
    require(_owner != address(0), NOT_VALID_NFT);
  }

  function getApproved(
    uint256 _tokenId
  )
    external
    override
    view
    validNFToken(_tokenId)
    returns (address)
  {

    return idToApproval[_tokenId];
  }

  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    override
    view
    returns (bool)
  {

    return ownerToOperators[_owner][_operator];
  }

  function _transfer(
    address _to,
    uint256 _tokenId
  )
    internal
  {

    address from = idToOwner[_tokenId];
    _clearApproval(_tokenId);

    _removeNFToken(from, _tokenId);
    _addNFToken(_to, _tokenId);

    emit Transfer(from, _to, _tokenId);
  }

  function _mint(
    address _to,
    uint256 _tokenId
  )
    internal
    virtual
  {

    require(_to != address(0), ZERO_ADDRESS);
    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);

    _addNFToken(_to, _tokenId);

    emit Transfer(address(0), _to, _tokenId);
  }

  function _burn(
    uint256 _tokenId
  )
    internal
    virtual
    validNFToken(_tokenId)
  {

    address tokenOwner = idToOwner[_tokenId];
    _clearApproval(_tokenId);
    _removeNFToken(tokenOwner, _tokenId);
    emit Transfer(tokenOwner, address(0), _tokenId);
  }

  function _removeNFToken(
    address _from,
    uint256 _tokenId
  )
    internal
    virtual
  {

    require(idToOwner[_tokenId] == _from, NOT_OWNER);
    ownerToNFTokenCount[_from] = ownerToNFTokenCount[_from] - 1;
    delete idToOwner[_tokenId];
  }

  function _addNFToken(
    address _to,
    uint256 _tokenId
  )
    internal
    virtual
  {

    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);

    idToOwner[_tokenId] = _to;
    ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to] + 1;
  }

  function _getOwnerNFTCount(
    address _owner
  )
    internal
    virtual
    view
    returns (uint256)
  {

    return ownerToNFTokenCount[_owner];
  }

  function _safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    private
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {

    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from, NOT_OWNER);
    require(_to != address(0), ZERO_ADDRESS);

    _transfer(_to, _tokenId);

    if (_to.isContract())
    {
      bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
      require(retval == MAGIC_ON_ERC721_RECEIVED, NOT_ABLE_TO_RECEIVE_NFT);
    }
  }

  function _clearApproval(
    uint256 _tokenId
  )
    private
  {

    if (idToApproval[_tokenId] != address(0))
    {
      delete idToApproval[_tokenId];
    }
  }

}


interface ERC721Metadata
{


  function name()
    external
    view
    returns (string memory _name);


  function symbol()
    external
    view
    returns (string memory _symbol);


  function tokenURI(uint256 _tokenId)
    external
    view
    returns (string memory);

    
     
  function tokenArtist(uint256 _tokenId)
    external
    view
    returns (address artist);


}

 


abstract contract NFTokenMetadata is
  NFToken,
  ERC721Metadata
{

  string internal nftName;

  string internal nftSymbol;
 
 

  
  mapping (uint256 => uint256) public tokenIdToProjectId;

  mapping (uint256 => string) public projectIdToUri;
 
  mapping (uint256 => address) public projectIdToArtist;
  

  constructor()
  {
    supportedInterfaces[0x5b5e139f] = true; // ERC721Metadata
  }

  function name()
    external
    override
    view
    returns (string memory _name)
  {
    _name = nftName;
  }

  function symbol()
    external
    override
    view
    returns (string memory _symbol)
  {
    _symbol = nftSymbol;
  }

  function tokenURI(
    uint256 _tokenId
  )
    external
    override
    view
    validNFToken(_tokenId)
    returns (string memory)
  {
    uint256 projectId = tokenIdToProjectId[_tokenId];
    return projectIdToUri[projectId];
  }
 
 
 function tokenArtist(
    uint256 _tokenId
  )
    external
    override
    view
    validNFToken(_tokenId)
    returns (address artist)
  {
    uint256 projectId = tokenIdToProjectId[_tokenId];
    return projectIdToArtist[projectId]; 
  }
 
 

  function _burn(
    uint256 _tokenId
  )
    internal
    override
    virtual
  {
    super._burn(_tokenId);

     
  }
   
 
 
  
  function _setTokenProjectId(
    uint256 _tokenId,
    uint256 _projectId
  )
    internal
    validNFToken(_tokenId)
  {
    tokenIdToProjectId[_tokenId] = _projectId;
  }

  
   function _setProjectUri(
    uint256 _projectId,
    string memory _uri
  )
    internal
     
  { 
    
   
    projectIdToUri[_projectId] = _uri;
     
    
  }



 function _setProjectArtist(
    uint256 _projectId,
    address _artist
  )
    internal
    
  {
      
    
    projectIdToArtist[_projectId] = _artist;
    
    
    
  }

 


}

abstract contract ApproveAndCallFallBack {
       function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public virtual;
  }
  
  
  
contract DigitalNFT is
  NFTokenMetadata,
  ECRecovery 
{

  uint public tokensMinted; //NFT minted count
  uint public _chain_id;
  uint public _fee_pct;
  
  
  address public _feeRecipient;  
    
  mapping(uint256 => uint256) public numberOfCopies; 
  
  mapping(bytes32 => bool) public projectUriBurned; 
  
  
   
  constructor(  uint256 chain_id, uint256 fee_pct, address fee_recipient ) 
  {
    require(fee_pct >= 0 && fee_pct <50);
      
    nftName = "Deploy.Art";
    nftSymbol = "D.ART";
    _chain_id=chain_id;
    _fee_pct=fee_pct;
    _feeRecipient = fee_recipient; 
  }
  
 
    
    struct MintPacket { 
        
        address artist;
        address keypassToken;
        string uri;
        uint256 maxCopies;
        uint256 expirationBlock;
        
        
        address currencyToken;
        uint256 currencyAmount;
        
        
    }
    
      
    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string contractName,string version,uint256 chainId,address verifyingContract)"
    );
    
    function getDomainTypehash() public pure returns (bytes32) {

        return EIP712DOMAIN_TYPEHASH;
    }
    
    function getEIP712DomainHash(string memory contractName, string memory version, uint256 chainId, address verifyingContract) public pure returns (bytes32) {

    
        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(contractName)),
            keccak256(bytes(version)),
            chainId,
            verifyingContract
        ));
    }
    
    bytes32 constant PACKET_TYPEHASH = keccak256(
    "MintPacket(address artist,address keypassToken,string uri,uint256 maxCopies,uint256 expirationBlock,address currencyToken,uint256 currencyAmount)"
    );
            
    function getPacketTypehash()  public pure returns (bytes32) {

        return PACKET_TYPEHASH;
    }
         
    
    function getPacketHash(address artist,address keypassToken,string memory uri, uint256 maxCopies, uint256 expirationBlock, address currencyToken, uint256 currencyAmount) public pure returns (bytes32) {

    return keccak256(abi.encode(
        PACKET_TYPEHASH,
        artist,
        keypassToken,
        keccak256(bytes(uri)),
        maxCopies, 
        expirationBlock,
        currencyToken,
        currencyAmount
    
        ));
    }



    function getTypedDataHash(address artist, address keypassToken, string memory uri,uint256 maxCopies, uint256 expirationBlock,address currencyToken, uint256 currencyAmount) public view returns (bytes32) {

        bytes32 digest = keccak256(abi.encodePacked(
        "\x19\x01",
        getEIP712DomainHash('DigitalNFT','1',_chain_id,address(this) ),
        getPacketHash(artist,keypassToken,uri,maxCopies,expirationBlock,currencyToken,currencyAmount)
        ));
        return digest;
    }
     



  function mint(address artist, address referral, address keypassToken, string memory uri, uint256 maxCopies, uint256 expirationBlock, address currencyToken, uint256 currencyAmount, bytes memory signature) external returns(bool) {  

  
  
    
    bytes32 sigHash = getTypedDataHash(artist,keypassToken, uri, maxCopies, expirationBlock, currencyToken, currencyAmount);
    address recoveredSignatureSigner = recover(sigHash,signature);
    require(artist == recoveredSignatureSigner, 'Invalid signature'); 
    
    require(expirationBlock == 0 || block.number < expirationBlock, 'Packet has expired.');
 
    if(keypassToken != address(0x0)){
        require( ERC721(keypassToken).balanceOf( msg.sender ) >= 1 ); 
    } 
    
    if(currencyToken != address(0x0)){ 
        _transferCurrencyForSale(msg.sender, artist, referral, currencyToken, currencyAmount );
    } 
    
    
    uint256 projectId = uint256( sigHash );
    
     
    super._mint(msg.sender,tokensMinted); 
    super._setTokenProjectId(tokensMinted,projectId );
    
    if(numberOfCopies[projectId] == 0){
      super._setProjectArtist(projectId, artist);
      super._setProjectUri(projectId, uri);
      
      require(projectUriBurned[keccak256(abi.encodePacked(artist,bytes(uri)))] == false, 'project uri already burned');
      projectUriBurned[keccak256(abi.encodePacked(artist,bytes(uri)))] = true;
    }
   
    
    require(numberOfCopies[projectId] < maxCopies, "exceeded max copies");
    numberOfCopies[projectId] = numberOfCopies[projectId]+1;
    
    
    tokensMinted = tokensMinted + 1;
    
   
    return true;
  }
  
  
   function _transferCurrencyForSale( address from, address to, address referral, address currencyToken, uint256 currencyAmount) internal returns (bool){

    
    uint256 feeAmount = (currencyAmount * _fee_pct) / 100;
    
    if(referral == address(0x0)){
        require( IERC20(currencyToken).transferFrom(from, to, currencyAmount - feeAmount  ), 'unable to pay' );
        require( IERC20(currencyToken).transferFrom(from, _feeRecipient, feeAmount ), 'unable to pay'  );
    }else{ 
        require( IERC20(currencyToken).transferFrom(from, to, currencyAmount - (2*feeAmount)  ), 'unable to pay' );
        require( IERC20(currencyToken).transferFrom(from, _feeRecipient, feeAmount ), 'unable to pay'  );  
        require( IERC20(currencyToken).transferFrom(from, referral, feeAmount ), 'unable to pay'  );  
    }

    return true;
  }
  
  function projectIdToMintedCopies(uint256 projectId) public view returns (uint256){

      return numberOfCopies[projectId];
  }
   
   
   

}