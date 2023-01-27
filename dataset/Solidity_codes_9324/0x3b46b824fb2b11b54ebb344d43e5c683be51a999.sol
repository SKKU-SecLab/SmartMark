


pragma solidity 0.8.6;

contract Ownable
{


    mapping (address => bool) public isAuth;
    address tokenLinkAddress;

  string public constant NOT_CURRENT_OWNER = "018001";
  string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor()
  {
    owner = msg.sender;
    isAuth[owner] = true;
  }

  modifier onlyOwner()
  {

    require(msg.sender == owner, NOT_CURRENT_OWNER);
    _;
  }

  modifier onlyAuthorized()
  {

    require(isAuth[msg.sender] || msg.sender == owner, "Unauth");
    _;
  }
  function transferOwnership(
    address _newOwner
  )
    public
    onlyOwner
  {

    require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
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
    ownerToNFTokenCount[_from] -= 1;
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
    ownerToNFTokenCount[_to] += 1;
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

    delete idToApproval[_tokenId];
  }

}




interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}







contract NFTokenMetadata is
  NFToken,
  ERC721Metadata
{


  string internal nftName;

  string internal nftSymbol;

  mapping (uint256 => string) internal idToUri;

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
    virtual
    override
    view
    validNFToken(_tokenId)
    returns (string memory)
  {

    return idToUri[_tokenId];
  }

  function _burn(
    uint256 _tokenId
  )
    internal
    override
    virtual
  {

    super._burn(_tokenId);

    delete idToUri[_tokenId];
  }

  function _setTokenUri(
    uint256 _tokenId,
    string memory _uri
  )
    internal
    validNFToken(_tokenId)
  {

    idToUri[_tokenId] = _uri;
  }

}




library Strings {

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

contract KaibaNFT is NFTokenMetadata, Ownable {


  using Strings for uint256;

  uint256 _lastTokenId = 0;
  bool public mintEnabled;
  mapping(address => bool) is_auth;
  string public baseuri;
  mapping(address => bool) hasMinted;
  mapping(address => bool) isFree;
  address kaiba = 0xF2210f65235c2FB391aB8650520237E6378e5C5A;
  uint256 givingAway;
  IERC20 kaibatoken = IERC20(kaiba);

  modifier onlyAuth() {

      require(msg.sender==owner || is_auth[msg.sender], "Unauthorized");
      _;
  }

bool locked;

modifier safe() {

        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
  }

  constructor() {
    nftName = "Kaiba v2 Celebration NFT";
    nftSymbol = "THEPACK";
    baseuri = "https://interplanetarykitchen.mypinata.cloud/ipfs/QmRWHp6q55hP82DNiEZmDQrM2SMMy6jzcMKrixu4t2E1js";
    owner = msg.sender;
    is_auth[owner] = true;
    mintNFT();
  }

  function takeBalance () public onlyAuth {
        (bool sent,) =owner.call{value: (address(this).balance)}("");
        require(sent);
  }

  function setBaseuri(string calldata newUri) public onlyAuth {

      baseuri = newUri;
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

    return string(abi.encodePacked(baseuri));
  }

  function getOwner() external view returns (address) {

        return owner;
    }

  function decimals() external pure returns (uint8) {

        return 0;
    }

  function totalSupply() external view returns (uint256) {

        return _lastTokenId;
    }

  function setAuth(bool booly, address addy) public onlyAuth {

      is_auth[addy] = booly;
  }

  function enableMint(bool booly) public onlyAuth {

      mintEnabled = booly;
  }

  function setKaiba(address addy) public onlyAuth {

      kaiba = addy;
      kaibatoken = IERC20(kaiba);
  }

  function setFree(address addy) public onlyAuth {

      isFree[addy] = true;
  }

  function giveaway(uint256 qty) public onlyAuth {

      if(qty==0) {
          givingAway = 100000000;
      } else {
          givingAway = qty; 
      }
  }

function mintNFT() payable public safe {

    bool isGiveaway;
    if (givingAway > 0) {
        isGiveaway = true;
        givingAway -= 1;
    } else {
        isGiveaway = false;
    }
    if (!is_auth[msg.sender] && !isFree[msg.sender] && !isGiveaway) {
        require(mintEnabled, "Minting enabled");
        require(!hasMinted[msg.sender], "Minted already");
        require(kaibatoken.balanceOf(msg.sender) > 0, "Kaiba 2 not owned");
    }
    uint256 _tokenId = _lastTokenId;
    super._mint(msg.sender, _tokenId);
    _lastTokenId = _tokenId + 1;
    hasMinted[msg.sender] = true;
  }

}