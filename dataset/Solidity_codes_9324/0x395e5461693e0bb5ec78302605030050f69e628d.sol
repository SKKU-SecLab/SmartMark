

pragma solidity 0.5.0;

interface IBurnableEtherLegendsToken {        

    function burn(uint256 tokenId) external;

}


pragma solidity 0.5.0;

interface IMintableEtherLegendsToken {        

    function mintTokenOfType(address to, uint256 idOfTokenType) external;

}


pragma solidity 0.5.0;

interface ITokenDefinitionManager {        

    function getNumberOfTokenDefinitions() external view returns (uint256);

    function hasTokenDefinition(uint256 tokenTypeId) external view returns (bool);

    function getTokenTypeNameAtIndex(uint256 index) external view returns (string memory);

    function getTokenTypeName(uint256 tokenTypeId) external view returns (string memory);

    function getTokenTypeId(string calldata name) external view returns (uint256);

    function getCap(uint256 tokenTypeId) external view returns (uint256);

    function getAbbreviation(uint256 tokenTypeId) external view returns (string memory);

}


pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.5.0;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}


pragma solidity ^0.5.0;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}


pragma solidity ^0.5.0;


contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}


pragma solidity ^0.5.0;




contract IERC721Full is IERC721, IERC721Enumerable, IERC721Metadata {

}


pragma solidity 0.5.0;





contract IEtherLegendsToken is IERC721Full, IMintableEtherLegendsToken, IBurnableEtherLegendsToken, ITokenDefinitionManager {

    function totalSupplyOfType(uint256 tokenTypeId) external view returns (uint256);

    function getTypeIdOfToken(uint256 tokenId) external view returns (uint256);

}


pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


pragma solidity ^0.5.0;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}


pragma solidity ^0.5.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}


pragma solidity ^0.5.0;







contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}


pragma solidity 0.5.0;




contract ELERC721Metadata is ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return "";
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);
    }
}


pragma solidity ^0.5.0;




contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function _mint(address to, uint256 tokenId) internal {

        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

        return _ownedTokens[owner];
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        _ownedTokens[from].length--;

    }

    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}


pragma solidity 0.5.0;




contract ELERC721Full is ERC721, ERC721Enumerable, ELERC721Metadata {

    constructor (string memory name, string memory symbol) public ELERC721Metadata(name, symbol) {
    }
}


pragma solidity ^0.5.0;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity 0.5.0;





contract EtherLegendsToken is ELERC721Full, IEtherLegendsToken, Ownable {

  using Roles for Roles.Role;
  Roles.Role private _minters;

  mapping (uint256 => uint256) private _tokenTypeToSupply;
  mapping (uint256 => uint256) private _tokenIdToType;
  uint256 private _amountMinted;  

  uint256 private nextTokenTypeIndex;
  string[] public tokenTypeNames;
  mapping (uint256 => uint256) private tokenTypeIndexMap;
  mapping (string => uint256) private tokenTypeNameIdMap;    
  mapping (uint256 => string) private tokenTypeIdNameMap;
  mapping (uint256 => uint256) private tokenTypeToCap;
  mapping (uint256 => string) private tokenTypeToAbbreviation;

  string public baseTokenURI;

  constructor() public 
    ELERC721Full("Ether Legends", "EL")
    Ownable()
  {

  }  

  function isMinter(address account) public view returns (bool) {

    return _minters.has(account);
  }

  function addMinter(address account) external {

    _requireOnlyOwner();
    _minters.add(account);
  }

  function removeMinter(address account) external {

    _requireOnlyOwner();
    _minters.remove(account);
  }        

  function _totalSupplyOfType(uint256 tokenTypeId) internal view returns (uint256) {

    return _tokenTypeToSupply[tokenTypeId];
  }

  function totalSupplyOfType(uint256 tokenTypeId) external view returns (uint256) {

    return _totalSupplyOfType(tokenTypeId);
  }

  function getTypeIdOfToken(uint256 tokenId) external view returns (uint256) {

    return _tokenIdToType[tokenId];
  }

  function exists(uint256 tokenId) external view returns (bool) {

    return _exists(tokenId);
  }

  function mintTokenOfType(address to, uint256 idOfTokenType) external {

    _requireOnlyMinter();
    require(_totalSupplyOfType(idOfTokenType) < _getCap(idOfTokenType));
    _mint(to, _amountMinted++, idOfTokenType);
  }

  function _mint(address to, uint256 tokenId, uint256 idOfTokenType) internal {    

    _mint(to, tokenId);
    _tokenTypeToSupply[idOfTokenType]++;
    _tokenIdToType[tokenId] = idOfTokenType;
  }

  function burn(uint256 tokenId) external {  

    require(_isApprovedOrOwner(msg.sender, tokenId), "caller is not owner nor approved");
    _burn(tokenId);    
    _tokenTypeToSupply[_tokenIdToType[tokenId]]--;
    delete _tokenIdToType[tokenId];
  }  

  function _requireOnlyOwner() internal view {

    require(isOwner(), "Ownable: caller is not the owner");
  }

  function _requireOnlyMinter() internal view {

    require(isMinter(msg.sender), "caller does not have the Minter role");
  }


  function hasTokenDefinition(uint256 tokenTypeId) external view returns (bool) {

    return _hasTokenDefinition(tokenTypeId);
  }

  function getNumberOfTokenDefinitions() external view returns (uint256) {

    return tokenTypeNames.length;
  }          

  function getTokenTypeId(string calldata name) external view returns (uint256) {

    return _getTokenTypeId(name);
  }    

  function getTokenTypeNameAtIndex(uint256 index) external view returns (string memory) {

    require(index < tokenTypeNames.length, "Token Definition Index Out Of Range");
    return tokenTypeNames[index];
  }

  function getTokenTypeName(uint256 tokenTypeId) external view returns (string memory) {

    return _getTokenTypeName(tokenTypeId);
  }  

  function getCap(uint256 tokenTypeId) external view returns (uint256) {

    return _getCap(tokenTypeId);
  }  

  function getAbbreviation(uint256 tokenTypeId) external view returns (string memory) {

    return _getAbbreviation(tokenTypeId);
  }

  function addTokenDefinition(string calldata name, uint256 cap, string calldata abbreviation) external {

    _requireOnlyOwner();
    require(!_hasTokenDefinition(name), "token type already defined");
    require(bytes(abbreviation).length < 32, "abbreviation may not exceed 31 characters");

    nextTokenTypeIndex++;
    tokenTypeIndexMap[nextTokenTypeIndex] = tokenTypeNames.length;
    tokenTypeNameIdMap[name] = nextTokenTypeIndex;
    tokenTypeIdNameMap[nextTokenTypeIndex] = name;
    tokenTypeNames.push(name);
    tokenTypeToCap[nextTokenTypeIndex] = cap;
    tokenTypeToAbbreviation[nextTokenTypeIndex] = abbreviation;
  }    

  function removeTokenDefinition(string calldata name) external {

    _requireOnlyOwner();
    require(_hasTokenDefinition(name), "token type not defined");
    require(_totalSupplyOfType(_getTokenTypeId(name)) == 0, "tokens of this type exist");

    uint256 typeId = tokenTypeNameIdMap[name];      
    uint256 typeIndex = tokenTypeIndexMap[typeId];

    delete tokenTypeIndexMap[typeId];
    delete tokenTypeNameIdMap[name];
    delete tokenTypeIdNameMap[typeId];
    delete tokenTypeToCap[typeId];
    delete tokenTypeToAbbreviation[typeId];

    string memory tmp = _getTokenTypeNameAtIndex(typeIndex);      
    string memory priorLastTypeName = _getTokenTypeNameAtIndex(tokenTypeNames.length - 1);
    uint256 priorLastTypeId = tokenTypeNameIdMap[priorLastTypeName];      
    tokenTypeNames[typeIndex] = tokenTypeNames[tokenTypeNames.length - 1];
    tokenTypeNames[tokenTypeNames.length - 1] = tmp;
    tokenTypeIndexMap[priorLastTypeId] = typeIndex;
    delete tokenTypeNames[tokenTypeNames.length - 1];
    tokenTypeNames.length--;
  }

  function _hasTokenDefinition(string memory name) internal view returns (bool) {

    return tokenTypeNameIdMap[name] != 0;
  }

  function _hasTokenDefinition(uint256 tokenTypeId) internal view returns (bool) {

    return tokenTypeToCap[tokenTypeId] != 0;
  }

  function _getTokenTypeId(string memory name) internal view returns (uint256) {

    require(_hasTokenDefinition(name), "path not defined");
    return tokenTypeNameIdMap[name];
  }

  function _getTokenTypeName(uint256 tokenTypeId) internal view returns (string memory) {

    require(_hasTokenDefinition(tokenTypeId), "path not defined");
    return tokenTypeIdNameMap[tokenTypeId];
  }

  function _getCap(uint256 tokenTypeId) internal view returns (uint256) {

    require(_hasTokenDefinition(tokenTypeId), "token type not defined");
    return tokenTypeToCap[tokenTypeId];
  }  

  function _getAbbreviation(uint256 tokenTypeId) internal view returns (string memory) {

    require(_hasTokenDefinition(tokenTypeId), "token type not defined");
    return tokenTypeToAbbreviation[tokenTypeId];
  }  

  function _getTokenTypeNameAtIndex(uint256 typeIndex) internal view returns (string memory) {

    return tokenTypeNames[typeIndex];
  }


  function setBaseURI(string calldata uri) external {

    _requireOnlyOwner();
    baseTokenURI = uri;    
  }    

  function tokenURI(uint256 tokenId) external view returns (string memory) {

    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    return string(abi.encodePacked(baseTokenURI, _getAbbreviation(_tokenIdToType[tokenId]), '?tokenId=', uint2str(tokenId)));
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

    if (_i == 0) {
      return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
      bstr[k--] = byte(uint8(48 + _i % 10));
      _i /= 10;
    }
    return string(bstr);
  }
}