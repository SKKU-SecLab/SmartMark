
pragma solidity ^0.8.4;
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


}interface ERC165
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


  function _removeNFToken(
    address _from,
    uint256 _tokenId
  )
    internal
    virtual
  {

    require(idToOwner[_tokenId] == _from, NOT_OWNER);
    
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

 

contract NFTokenCollection is
  NFToken, 
  ERC721Metadata
{


    string internal nftName;
    string internal nftSymbol;
  
    uint256 public nftTokenIdLast = 0;

    address payable public owner;
    string public baseURI;
    
    mapping(address => bool) private whiteList;

    uint256 constant public MAX_SUPPLY = 10000;
    
    event newTokenMinted(
       uint newNFT
    );
    
  constructor()
  {
    supportedInterfaces[0x5b5e139f] = true; // ERC721Metadata
    supportedInterfaces[0x780e9d63] = true; // ERC721Enumarable
    nftName = "CATS SAGA CLUB";
    nftSymbol = "CATS-SAGA-CLUB";
    owner = payable(msg.sender);

    baseURI = "ipfs://QmUwhHW3XpbCHYkEsxr8RKJihD5qH5WZeYkvTpqFj5akzV/";

    whiteList[msg.sender]=true;

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

  function mint(
    address _to,
    uint256 _tokenId
  )
    internal
  {     

       _mint(_to, _tokenId);
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

    return string(abi.encodePacked(baseURI,uintToString(_tokenId)));
  }


 
  function uintToString(uint v) internal pure returns (string memory) {

    uint maxlength = 100;
    bytes memory reversed = new bytes(maxlength);
    uint i = 0;
    while (v != 0) {
        uint remainder = v % 10;
        v = v / 10;
        reversed[i++] = bytes1(uint8(48 + remainder));
    }
    bytes memory s = new bytes(i); // i + 1 is inefficient
    for (uint j = 0; j < i; j++) {
        s[j] = reversed[i - j - 1]; // to avoid the off-by-one error
    }
    string memory str = string(s);  // memory isn't implicitly convertible to storage
    return str;
}
  function includeToPrivateWhiteList(address[] memory _users) public  {

    require(msg.sender==owner,"Only approved staff can act here");
        for(uint8 i = 0; i < _users.length; i++) {
            whiteList[_users[i]] = true;
        }
    }
 

  function buyTokenNFT (uint256 _numTokens)  external payable returns (bool success){
        uint256 amount = msg.value;
         uint256 tokenPrice;
         require((nftTokenIdLast)+(_numTokens) <= MAX_SUPPLY,"Collection is not more available");
         require (_numTokens <= 10 ,"Max 10 Mints each transaction");

        if(whiteList[msg.sender]){
            tokenPrice = 0.02 ether;
        }else{
            tokenPrice = 0.03 ether;
        }
        
        require(amount >= tokenPrice * _numTokens,"Not enought amount to buy this NFT");

        owner.transfer(amount);

        for(uint i = 0; i < _numTokens; i++){
         nftTokenIdLast += 1;
        
         mint(msg.sender,nftTokenIdLast);
        }
         
        emit newTokenMinted(nftTokenIdLast);
        return true;
    }
    function setBaseURIpfs (string memory _baseUri)  external  returns (bool success){
        require(msg.sender==owner,"Only Admin can act this operation");
        baseURI = _baseUri;
        return true;
    }

    function mintTokenAdmin (uint256 _numTokens)  external returns (bool success){
        require(msg.sender==owner,"Only Admin can act this operation");
        require((nftTokenIdLast)+(_numTokens) <= MAX_SUPPLY,"Collection is not more available");
        for(uint i = 0; i < _numTokens; i++){
         nftTokenIdLast += 1;
        
         mint(msg.sender,nftTokenIdLast);
        }
          emit newTokenMinted(nftTokenIdLast);
         return true;
    }
    
    function totalSupply()public view  returns (uint256) {

      return nftTokenIdLast;
    }

 
}