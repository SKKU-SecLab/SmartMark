pragma solidity >=0.4.24 <0.6.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}pragma solidity ^0.5.2;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}pragma solidity ^0.5.2;


contract IERC721 is Initializable, IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);


    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function transferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}pragma solidity ^0.5.2;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}pragma solidity ^0.5.2;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}pragma solidity ^0.5.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}pragma solidity ^0.5.2;


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
}pragma solidity ^0.5.2;


contract ERC165 is Initializable, IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function initialize() public initializer {

        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }

    uint256[50] private ______gap;
}pragma solidity ^0.5.2;


contract ERC721 is Initializable, ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    function initialize() public initializer {

        ERC165.initialize();

        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function _hasBeenInitialized() internal view returns (bool) {

        return supportsInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0));
        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0));
        require(!_exists(tokenId));

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from);
        require(to != address(0));

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

    uint256[50] private ______gap;
}pragma solidity ^0.5.2;


contract IERC721Enumerable is Initializable, IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}pragma solidity ^0.5.2;


contract ERC721Enumerable is Initializable, ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    function initialize() public initializer {

        require(ERC721._hasBeenInitialized());
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function _hasBeenInitialized() internal view returns (bool) {

        return supportsInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        require(index < balanceOf(owner));
        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

        require(index < totalSupply());
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

    uint256[50] private ______gap;
}pragma solidity ^0.5.2;


contract IERC721Metadata is Initializable, IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}pragma solidity ^0.5.2;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0));
        return role.bearer[account];
    }
}// agpl-3.0
pragma solidity ^0.5.0;


contract PoapRoles is Initializable {

    using Roles for Roles.Role;

    event AdminAdded(address indexed account);

    event AdminRemoved(address indexed account);
    
    event EventMinterAdded(uint256 indexed eventId, address indexed account);
    
    event EventMinterRemoved(uint256 indexed eventId, address indexed account);

    Roles.Role private _admins;
    mapping(uint256 => Roles.Role) private _minters;

    function initialize(address sender) public initializer {

        if (!isAdmin(sender)) {
            _addAdmin(sender);
        }
    }

    modifier onlyAdmin() {

        require(isAdmin(msg.sender), "Sender is not Admin");
        _;
    }

    modifier onlyEventMinter(uint256 eventId) {

        require(isEventMinter(eventId, msg.sender), "Sender is not Event Minter");
        _;
    }

    function isAdmin(address account) public view returns (bool) {

        return _admins.has(account);
    }

    function isEventMinter(uint256 eventId, address account) public view returns (bool) {

        return isAdmin(account) || _minters[eventId].has(account);
    }

    function addEventMinter(uint256 eventId, address account) public onlyEventMinter(eventId) {

        _addEventMinter(eventId, account);
    }

    function addAdmin(address account) public onlyAdmin {

        _addAdmin(account);
    }

    function renounceEventMinter(uint256 eventId) public {

        _removeEventMinter(eventId, msg.sender);
    }

    function renounceAdmin() public {

        _removeAdmin(msg.sender);
    }

    function removeEventMinter(uint256 eventId, address account) public onlyAdmin {

        _removeEventMinter(eventId, account);
    }

    function _addEventMinter(uint256 eventId, address account) internal {

        _minters[eventId].add(account);
        emit EventMinterAdded(eventId, account);
    }

    function _addAdmin(address account) internal {

        _admins.add(account);
        emit AdminAdded(account);
    }

    function _removeEventMinter(uint256 eventId, address account) internal {

        _minters[eventId].remove(account);
        emit EventMinterRemoved(eventId, account);
    }

    function _removeAdmin(address account) internal {

        _admins.remove(account);
        emit AdminRemoved(account);
    }

    uint256[50] private ______gap;
}// agpl-3.0
pragma solidity ^0.5.0;


contract PoapPausable is Initializable, PoapRoles {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function initialize() public initializer {

        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Contract is Paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Contract is not Paused");
        _;
    }

    function pause() public onlyAdmin whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyAdmin whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }

    uint256[50] private ______gap;
}// AGPL-3.0
pragma solidity ^0.5.2;


contract Poap is Initializable, ERC721, ERC721Enumerable, PoapRoles, PoapPausable {

   
    event EventToken(uint256 eventId, uint256 tokenId);

    string private _name;

    string private _symbol;

    string private _baseURI;

    uint256 private lastId;

    mapping(uint256 => uint256) private _tokenEvent;


    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenEvent(uint256 tokenId) public view returns (uint256) {

        return _tokenEvent[tokenId];
    }

    function tokenDetailsOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId, uint256 eventId) {

        tokenId = tokenOfOwnerByIndex(owner, index);
        eventId = tokenEvent(tokenId);
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        uint eventId = _tokenEvent[tokenId];
        return _strConcat(_baseURI, _uint2str(eventId), "/", _uint2str(tokenId), "");
    }

    function setBaseURI(string memory baseURI) public onlyAdmin whenNotPaused {

        _baseURI = baseURI;
    }

    function approve(address to, uint256 tokenId) public whenNotPaused {

        super.approve(to, tokenId);
    }

    function setApprovalForAll(address to, bool approved) public whenNotPaused {

        super.setApprovalForAll(to, approved);
    }

    function transferFrom(address from, address to, uint256 tokenId) public whenNotPaused {

        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public whenNotPaused {

        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public whenNotPaused {

        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function mintToken(uint256 eventId, address to)
    public whenNotPaused onlyEventMinter(eventId) returns (bool)
    {

        lastId += 1;
        return _mintToken(eventId, lastId, to);
    }

    function mintToken(uint256 eventId, uint256 tokenId, address to)
    public whenNotPaused onlyEventMinter(eventId) returns (bool)
    {

        return _mintToken(eventId, tokenId, to);
    }

    function mintEventToManyUsers(uint256 eventId, address[] memory to)
    public whenNotPaused onlyEventMinter(eventId) returns (bool)
    {

        for (uint256 i = 0; i < to.length; ++i) {
            _mintToken(eventId, lastId + 1 + i, to[i]);
        }
        lastId += to.length;
        return true;
    }

    function mintUserToManyEvents(uint256[] memory eventIds, address to)
    public whenNotPaused onlyAdmin() returns (bool)
    {

        for (uint256 i = 0; i < eventIds.length; ++i) {
            _mintToken(eventIds[i], lastId + 1 + i, to);
        }
        lastId += eventIds.length;
        return true;
    }

    function burn(uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId) || isAdmin(msg.sender), "Sender doesn't have permission");
        _burn(tokenId);
    }

    function initialize(string memory __name, string memory __symbol, string memory __baseURI, address[] memory admins)
    public initializer
    {

        ERC721.initialize();
        ERC721Enumerable.initialize();
        PoapRoles.initialize(msg.sender);
        PoapPausable.initialize();

        for (uint256 i = 0; i < admins.length; ++i) {
            _addAdmin(admins[i]);
        }

        _name = __name;
        _symbol = __symbol;
        _baseURI = __baseURI;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        delete _tokenEvent[tokenId];
    }

    function _mintToken(uint256 eventId, uint256 tokenId, address to) internal returns (bool) {

        _mint(to, tokenId);
        _tokenEvent[tokenId] = eventId;
        emit EventToken(eventId, tokenId);
        return true;
    }

    function _uint2str(uint _i) internal pure returns (string memory _uintAsString) {

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

    function _strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e)
    internal pure returns (string memory _concatenatedString)
    {

        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function removeAdmin(address account) public onlyAdmin {

        _removeAdmin(account);
    }
}