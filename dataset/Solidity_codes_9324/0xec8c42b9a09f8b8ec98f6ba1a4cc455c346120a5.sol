

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


library SafeMath
{


  string constant OVERFLOW = "008001";
  string constant SUBTRAHEND_GREATER_THEN_MINUEND = "008002";
  string constant DIVISION_BY_ZERO = "008003";

  function mul(
    uint256 _factor1,
    uint256 _factor2
  )
    internal
    pure
    returns (uint256 product)
  {

    if (_factor1 == 0)
    {
      return 0;
    }

    product = _factor1 * _factor2;
    require(product / _factor1 == _factor2, OVERFLOW);
  }

  function div(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 quotient)
  {

    require(_divisor > 0, DIVISION_BY_ZERO);
    quotient = _dividend / _divisor;
  }

  function sub(
    uint256 _minuend,
    uint256 _subtrahend
  )
    internal
    pure
    returns (uint256 difference)
  {

    require(_subtrahend <= _minuend, SUBTRAHEND_GREATER_THEN_MINUEND);
    difference = _minuend - _subtrahend;
  }

  function add(
    uint256 _addend1,
    uint256 _addend2
  )
    internal
    pure
    returns (uint256 sum)
  {

    sum = _addend1 + _addend2;
    require(sum >= _addend1, OVERFLOW);
  }

  function mod(
    uint256 _dividend,
    uint256 _divisor
  )
    internal
    pure
    returns (uint256 remainder)
  {

    require(_divisor != 0, DIVISION_BY_ZERO);
    remainder = _dividend % _divisor;
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
    public
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


contract NFToken is
  ERC721,
  SupportsInterface
{

  using SafeMath for uint256;
  using AddressUtils for address;


  string constant ZERO_ADDRESS = "003001";
  string constant NOT_VALID_NFT = "003002";
  string constant NOT_OWNER_OR_OPERATOR = "003003";
  string constant NOT_OWNER_APPROWED_OR_OPERATOR = "003004";
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
    require(tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender], NOT_OWNER_OR_OPERATOR);
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
      NOT_OWNER_APPROWED_OR_OPERATOR
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
    public
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
    ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to].add(1);
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


}


contract NFTokenMetadata is
  NFToken,
  ERC721Metadata
{


  string internal nftName;

  string internal nftSymbol;

  mapping (uint256 => string) internal idToUri;

  constructor()
    public
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

    if (bytes(idToUri[_tokenId]).length != 0)
    {
      delete idToUri[_tokenId];
    }
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


interface ERC721Enumerable
{


  function totalSupply()
    external
    view
    returns (uint256);


  function tokenByIndex(
    uint256 _index
  )
    external
    view
    returns (uint256);


  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    external
    view
    returns (uint256);


}


contract NFTokenEnumerable is
  NFToken,
  ERC721Enumerable
{



  string constant INVALID_INDEX = "005007";

  uint256[] internal tokens;

  mapping(uint256 => uint256) internal idToIndex;

  mapping(address => uint256[]) internal ownerToIds;

  mapping(uint256 => uint256) internal idToOwnerIndex;

  constructor()
    public
  {
    supportedInterfaces[0x780e9d63] = true; // ERC721Enumerable
  }

  function totalSupply()
    external
    override
    view
    returns (uint256)
  {

    return tokens.length;
  }

  function tokenByIndex(
    uint256 _index
  )
    external
    override
    view
    returns (uint256)
  {

    require(_index < tokens.length, INVALID_INDEX);
    return tokens[_index];
  }

  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    external
    override
    view
    returns (uint256)
  {

    require(_index < ownerToIds[_owner].length, INVALID_INDEX);
    return ownerToIds[_owner][_index];
  }

  function _mint(
    address _to,
    uint256 _tokenId
  )
    internal
    override
    virtual
  {

    super._mint(_to, _tokenId);
    tokens.push(_tokenId);
    idToIndex[_tokenId] = tokens.length - 1;
  }

  function _burn(
    uint256 _tokenId
  )
    internal
    override
    virtual
  {

    super._burn(_tokenId);

    uint256 tokenIndex = idToIndex[_tokenId];
    uint256 lastTokenIndex = tokens.length - 1;
    uint256 lastToken = tokens[lastTokenIndex];

    tokens[tokenIndex] = lastToken;

    tokens.pop();
    idToIndex[lastToken] = tokenIndex;
    idToIndex[_tokenId] = 0;
  }

  function _removeNFToken(
    address _from,
    uint256 _tokenId
  )
    internal
    override
    virtual
  {

    require(idToOwner[_tokenId] == _from, NOT_OWNER);
    delete idToOwner[_tokenId];

    uint256 tokenToRemoveIndex = idToOwnerIndex[_tokenId];
    uint256 lastTokenIndex = ownerToIds[_from].length - 1;

    if (lastTokenIndex != tokenToRemoveIndex)
    {
      uint256 lastToken = ownerToIds[_from][lastTokenIndex];
      ownerToIds[_from][tokenToRemoveIndex] = lastToken;
      idToOwnerIndex[lastToken] = tokenToRemoveIndex;
    }

    ownerToIds[_from].pop();
  }

  function _addNFToken(
    address _to,
    uint256 _tokenId
  )
    internal
    override
    virtual
  {

    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);
    idToOwner[_tokenId] = _to;

    ownerToIds[_to].push(_tokenId);
    idToOwnerIndex[_tokenId] = ownerToIds[_to].length - 1;
  }

  function _getOwnerNFTCount(
    address _owner
  )
    internal
    override
    virtual
    view
    returns (uint256)
  {

    return ownerToIds[_owner].length;
  }
}


contract Ownable
{


  string public constant NOT_CURRENT_OWNER = "018001";
  string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor()
    public
  {
    owner = msg.sender;
  }

  modifier onlyOwner()
  {

    require(msg.sender == owner, NOT_CURRENT_OWNER);
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


interface IMintable {

    function mintFor(
        address to,
        uint256 id,
        bytes calldata blueprint
    ) external;

}


library Bytes {

    function fromUint(uint256 value) internal pure returns (string memory) {

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
            buffer[index--] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }
        return string(buffer);
    }

    bytes constant alphabet = "0123456789abcdef";

    function indexOf(
        bytes memory _base,
        string memory _value,
        uint256 _offset
    ) internal pure returns (int256) {

        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length == 1);

        for (uint256 i = _offset; i < _base.length; i++) {
            if (_base[i] == _valueBytes[0]) {
                return int256(i);
            }
        }

        return -1;
    }

    function substring(
        bytes memory strBytes,
        uint256 startIndex,
        uint256 endIndex
    ) internal pure returns (string memory) {

        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function toUint(bytes memory b) internal pure returns (uint256) {

        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 val = uint256(uint8(b[i]));
            if (val >= 48 && val <= 57) {
                result = result * 10 + (val - 48);
            }
        }
        return result;
    }
}


library Minting {


    function split(bytes calldata blob)
        internal
        pure
        returns (uint256, bytes memory)
    {

        int256 index = Bytes.indexOf(blob, ":", 0);
        require(index >= 0, "Separator must exist");
        uint256 tokenID = Bytes.toUint(blob[1:uint256(index) - 1]);
        uint256 blueprintLength = blob.length - uint256(index) - 3;
        if (blueprintLength == 0) {
            return (tokenID, bytes(""));
        }
        bytes calldata blueprint = blob[uint256(index) + 2:blob.length - 1];
        return (tokenID, blueprint);
    }
}

abstract contract Mintable is Ownable, IMintable {
    address public imx;
    mapping(uint256 => bytes) public blueprints;

    event AssetMinted(address to, uint256 id, bytes blueprint);

    constructor(address _owner, address _imx) {
        imx = _imx;
        require(_owner != address(0), "Owner must not be empty");
        transferOwnership(_owner);
    }

    modifier onlyIMX() {
        require(msg.sender == imx, "Function can only be called by IMX");
        _;
    }

    function mintFor(
        address user,
        uint256 quantity,
        bytes calldata mintingBlob
    ) external override onlyIMX {
        require(quantity == 1, "Mintable: invalid quantity");
        (uint256 id, bytes memory blueprint) = Minting.split(mintingBlob);
        _mintFor(user, id, blueprint);
        blueprints[id] = blueprint;
        emit AssetMinted(user, id, blueprint);
    }

    function _mintFor(
        address to,
        uint256 id,
        bytes memory blueprint
    ) internal virtual;
}


contract ArtGalleryTokenImx is
    NFTokenEnumerable,
    NFTokenMetadata,
    Ownable,
    Mintable
{


    constructor(address _imx) public Mintable(msg.sender, _imx) {
        nftName = "ArtGallery";
        nftSymbol = "ArtGallery";
        publisher = msg.sender; //publisher == owner == contract deployer
        _own_address = address(this);
    }

    function __mint(
        address _to,
        uint256 _tokenId,
        string memory _uri
    ) internal {

        super._mint(_to, _tokenId);
        super._setTokenUri(_tokenId, _uri);
    }

    function _mintFor(
        address to,
        uint256 id,
        bytes memory blueprint
    ) internal override {

        string memory uri = string(blueprint);
        __mint(to, id, uri);
    }

    address public _own_address;

    address publisher = 0x0000000000000000000000000000000000000000;

    address bankContract = 0x0000000000000000000000000000000000000000;

    modifier bankOrPublisher() {

        require(
            (msg.sender == publisher) ||
                (msg.sender == bankContract && isContract(msg.sender)),
            "only bank or publisher can call this function"
        );
        _;
    }

    modifier onlyPublisher() {

        require(
            msg.sender == publisher,
            "only publisher can call this function"
        );
        _;
    }

    modifier onlyBankContract() {

        require(
            msg.sender == bankContract && isContract(msg.sender),
            "only bank can call this function"
        );
        _;
    }

    function isContract(address _addr) internal view returns (bool) {

        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }

        return (size > 0);
    }

    function setNFTName(string calldata new_name) external onlyOwner {

        nftName = new_name;
    }

    function setNFTSymbol(string calldata new_symbol) external onlyOwner {

        nftSymbol = new_symbol;
    }

    function transferPublishRight(address newPublisher) external onlyOwner {

        publisher = newPublisher;
    }

    function getPublisher() public view returns (address) {

        return publisher;
    }

    function transferBankRight(address newBankContract) external onlyOwner {

        bankContract = newBankContract;
    }

    function getBankContract() public view returns (address) {

        return bankContract;
    }

    function getContractBalance() public view returns (uint256) {

        return address(this).balance;
    }

    function mint(
        address _to,
        uint256 _tokenId,
        string calldata _uri
    ) external bankOrPublisher {

        __mint(_to, _tokenId, _uri);
    }

    function burn(uint256 _tokenId) external bankOrPublisher {

        super._burn(_tokenId);
    }

    function _mint(address _to, uint256 _tokenId)
        internal
        virtual
        override(NFToken, NFTokenEnumerable)
    {

        NFTokenEnumerable._mint(_to, _tokenId);
    }

    function _burn(uint256 _tokenId)
        internal
        virtual
        override(NFTokenMetadata, NFTokenEnumerable)
    {

        NFTokenEnumerable._burn(_tokenId);
        if (bytes(idToUri[_tokenId]).length != 0) {
            delete idToUri[_tokenId];
        }
    }

    function _removeNFToken(address _from, uint256 _tokenId)
        internal
        override(NFToken, NFTokenEnumerable)
    {

        NFTokenEnumerable._removeNFToken(_from, _tokenId);
    }

    function _addNFToken(address _to, uint256 _tokenId)
        internal
        override(NFToken, NFTokenEnumerable)
    {

        NFTokenEnumerable._addNFToken(_to, _tokenId);
    }

    function _getOwnerNFTCount(address _owner)
        internal
        view
        override(NFToken, NFTokenEnumerable)
        returns (uint256)
    {

        return NFTokenEnumerable._getOwnerNFTCount(_owner);
    }
}