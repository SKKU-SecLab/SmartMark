
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity ^0.6.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.6.0;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.6.0;


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
}// MIT

pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.6.2;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.6.2;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.6.2;


interface IERC721Enumerable is IERC721 {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.6.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);

}// MIT

pragma solidity ^0.6.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}// MIT

pragma solidity ^0.6.0;

library EnumerableMap {


    struct MapEntry {
        bytes32 _key;
        bytes32 _value;
    }

    struct Map {
        MapEntry[] _entries;

        mapping (bytes32 => uint256) _indexes;
    }

    function _set(Map storage map, bytes32 key, bytes32 value) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex == 0) { // Equivalent to !contains(map, key)
            map._entries.push(MapEntry({ _key: key, _value: value }));
            map._indexes[key] = map._entries.length;
            return true;
        } else {
            map._entries[keyIndex - 1]._value = value;
            return false;
        }
    }

    function _remove(Map storage map, bytes32 key) private returns (bool) {

        uint256 keyIndex = map._indexes[key];

        if (keyIndex != 0) { // Equivalent to contains(map, key)

            uint256 toDeleteIndex = keyIndex - 1;
            uint256 lastIndex = map._entries.length - 1;


            MapEntry storage lastEntry = map._entries[lastIndex];

            map._entries[toDeleteIndex] = lastEntry;
            map._indexes[lastEntry._key] = toDeleteIndex + 1; // All indexes are 1-based

            map._entries.pop();

            delete map._indexes[key];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Map storage map, bytes32 key) private view returns (bool) {

        return map._indexes[key] != 0;
    }

    function _length(Map storage map) private view returns (uint256) {

        return map._entries.length;
    }

    function _at(Map storage map, uint256 index) private view returns (bytes32, bytes32) {

        require(map._entries.length > index, "EnumerableMap: index out of bounds");

        MapEntry storage entry = map._entries[index];
        return (entry._key, entry._value);
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        return _get(map, key, "EnumerableMap: nonexistent key");
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToAddressMap {
        Map _inner;
    }

    function set(UintToAddressMap storage map, uint256 key, address value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(uint256(value)));
    }

    function remove(UintToAddressMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToAddressMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToAddressMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToAddressMap storage map, uint256 index) internal view returns (uint256, address) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), address(uint256(value)));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint256(_get(map._inner, bytes32(key), errorMessage)));
    }
}// MIT

pragma solidity ^0.6.0;

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
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}// MIT

pragma solidity ^0.6.0;


contract ERC721 is Context, ERC165, IERC721, IERC721Metadata, IERC721Enumerable {

    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Strings for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSet.UintSet) private _holderTokens;

    EnumerableMap.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");

        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_baseURI).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    function baseURI() public view returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        _holderTokens[owner].remove(tokenId);

        _tokenOwners.remove(tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal virtual {

        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _holderTokens[from].remove(tokenId);
        _holderTokens[to].add(tokenId);

        _tokenOwners.set(tokenId, to);

        emit Transfer(from, to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI_) internal virtual {

        _baseURI = baseURI_;
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {

        if (!to.isContract()) {
            return true;
        }
        bytes memory returndata = to.functionCall(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ), "ERC721: transfer to non ERC721Receiver implementer");
        bytes4 retval = abi.decode(returndata, (bytes4));
        return (retval == _ERC721_RECEIVED);
    }

    function _approve(address to, uint256 tokenId) private {

        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

}// MIT

pragma solidity ^0.6.0;


abstract contract ERC721Burnable is Context, ERC721 {
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }
}// MIT

pragma solidity ^0.6.0;


contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity ^0.6.0;


abstract contract ERC721Pausable is ERC721, Pausable {
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
}// MIT

pragma solidity ^0.6.0;


contract ERC721PresetMinterPauserAutoId is Context, AccessControl, ERC721Burnable, ERC721Pausable {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _tokenIdTracker;

    constructor(string memory name, string memory symbol, string memory baseURI) public ERC721(name, symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());

        _setBaseURI(baseURI);
    }

    function mint(address to) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

        _mint(to, _tokenIdTracker.current());
        _tokenIdTracker.increment();
    }

    function pause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to unpause");
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}// GPL-3.0
pragma solidity 0.6.12;



contract JoysLotteryMeta is Ownable {

    event LotteryMetaAdd(address indexed to, uint32 level,
        uint32 strengthMin, uint32 strengthMax,
        uint32 intelligenceMin, uint32 intelligenceMax,
        uint32 agilityMin, uint32 agilityMax,
        uint256 weight);

    event LotteryMetaUpdate(address indexed to, uint32 level,
        uint32 strengthMin, uint32 strengthMax,
        uint32 intelligenceMin, uint32 intelligenceMax,
        uint32 agilityMin, uint32 agilityMax,
        uint256 weight);

    struct MetaInfo {
        uint32 level;

        uint32 sMin;
        uint32 sMax;

        uint32 iMin;
        uint32 iMax;

        uint32 aMin;
        uint32 aMax;

        uint256 weight;
    }
    MetaInfo[] public metaInfo;
    mapping(uint32 => bool) public metaLevel;

    function addMeta (
        uint32 _level,
        uint32 _sMin,
        uint32 _sMax,
        uint32 _iMin,
        uint32 _iMax,
        uint32 _aMin,
        uint32 _aMax,
        uint256 _weight)
    onlyOwner public {
        require(_level > 0, "JoysLotteryMeta: The level starts at 1.");

        if (metaLevel[_level]) {
            return;
        }

        if(metaInfo.length > 0) {
            require(_level > metaInfo[metaInfo.length - 1].level, "JoysLotteryMeta: new level must bigger than old");
            require(_level == metaInfo[metaInfo.length - 1].level + 1, "JoysLotteryMeta: new level must bigger.");
        }

        metaInfo.push(MetaInfo({
            level: _level,
            sMin: _sMin,
            sMax: _sMax,
            iMin: _iMin,
            iMax: _iMax,
            aMin: _aMin,
            aMax: _aMax,
            weight: _weight
            }));
        metaLevel[_level] = true;

        emit LotteryMetaAdd(_msgSender(), _level, _sMin, _sMax, _iMin, _iMax, _aMin, _aMax, _weight);
    }

    function updateMeta (uint32 _level,
        uint32 _sMin,
        uint32 _sMax,
        uint32 _iMin,
        uint32 _iMax,
        uint32 _aMin,
        uint32 _aMax,
        uint256 _weight)
    onlyOwner public {
        require(_level > 0 && _level <= length(), "JoysLotteryMeta: invalid index.");

        for (uint32 idx = 0; idx < metaInfo.length; ++idx) {
            if (metaInfo[idx].level == _level) {
                metaInfo[idx] = MetaInfo({
                    level: _level,
                    sMin: _sMin,
                    sMax: _sMax,
                    iMin: _iMin,
                    iMax: _iMax,
                    aMin: _aMin,
                    aMax: _aMax,
                    weight: _weight
                    });
                break;
            }
        }

        emit LotteryMetaUpdate(_msgSender(), _level, _sMin, _sMax, _iMin, _iMax, _aMin, _aMax, _weight);
    }

    function length() public view returns (uint32) {
        return uint32(metaInfo.length);
    }

    function meta(uint256 _idx) public view returns (uint32, uint32, uint32, uint32, uint32, uint32, uint32, uint256){
        require(_idx < length(), "JoysLotteryMeta: invalid index.");
        MetaInfo storage m = metaInfo[_idx];
        return (m.level, m.sMin, m.sMax, m.iMin, m.iMax, m.aMin, m.aMax, m.weight);
    }
}

contract JoysHeroLotteryMeta is JoysLotteryMeta {
    constructor() public {
        addMeta(1, 500, 800, 400, 600, 500, 800, 10000);
        addMeta(2, 1500, 1800, 1000, 1200, 1500, 1800, 5000);
        addMeta(3, 4000, 6000, 4000, 6000, 2500, 3500, 2000);
        addMeta(4, 7000, 9000, 9000, 10000, 6000, 7000, 500);
        addMeta(5, 10000, 11000, 10000, 12000, 9000, 10000, 100);
        addMeta(6, 18000, 20000, 18000, 20000, 16000, 18000, 5);
    }
}

contract JoysWeaponLotteryMeta is JoysLotteryMeta {
    constructor() public {
        addMeta(1, 500, 700, 600, 800, 600, 800, 10000);
        addMeta(2, 1800, 2000, 1600, 1800, 2000, 2200, 4000);
        addMeta(3, 3000, 4000, 2500, 3500, 3000, 4000, 2000);
        addMeta(4, 6000, 8000, 8000, 9000, 6000, 7000, 500);
        addMeta(5, 16000, 18000, 16000, 18000, 18000, 20000, 0);
        addMeta(6, 18000, 20000, 16000, 18000, 16000, 18000, 0);
    }
}// MIT

pragma solidity ^0.6.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}// MIT

pragma solidity ^0.6.0;


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// GPL-3.0
pragma solidity 0.6.12;




contract JoysToken is ERC20("JoysToken", "JOYS"), Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    mapping (address => address) internal _delegates;

    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    mapping (address => uint32) public numCheckpoints;

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping (address => uint) public nonces;

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    constructor() public {
        uint256 totalSupply = 300000000 * 1e18;
        _mint(_msgSender(), totalSupply);
    }

    function burn(uint256 _amount) public onlyOwner {
        _burn(_msgSender(), _amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        _moveDelegates(_delegates[from], _delegates[to], amount);
    }

    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "JOYS::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "JOYS::delegateBySig: invalid nonce");
        require(now <= expiry, "JOYS::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "JOYS::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying JOYS (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "JOYS::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal pure returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}// GPL-3.0
pragma solidity 0.6.12;


contract JoysNFT is ERC721PresetMinterPauserAutoId, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    struct Meta {
        uint32 level;

        uint32 sVal;

        uint32 iVal;

        uint32 aVal;
    }

    mapping (uint256 => Meta) public metaSet;

    Counters.Counter private tokenIdTracker;

    constructor (string memory name, string memory symbol) public
    ERC721PresetMinterPauserAutoId(name, symbol, "") {
    }

    function setBaseURI(string memory _baseURI) onlyOwner public {
        _setBaseURI(_baseURI);
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) onlyOwner public {
        _setRoleAdmin(role, adminRole);
    }

    function mint(address _to, uint32 _level, uint32 _sVal, uint32 _iVal, uint32 _aVal) public {
        require(hasRole(MINTER_ROLE, _msgSender()), "JoysNFT: must have minter role to mint");

        _mint(_to, tokenIdTracker.current());
        metaSet[tokenIdTracker.current()] = Meta(_level, _sVal, _iVal, _aVal);
        tokenIdTracker.increment();
    }

    function mint(address /*_to*/) public onlyOwner override(ERC721PresetMinterPauserAutoId) {
        require(false, "JoysNFT: not supported");
    }

    function info(uint256 tokenId) public view returns (uint32, uint32, uint32, uint32) {
        require(_exists(tokenId), "JoysNFT: URI query for nonexistent token");

        Meta storage m = metaSet[tokenId];
        return (m.level, m.sVal, m.iVal, m.aVal);
    }
}

contract JoysHero is JoysNFT {
    constructor() public JoysNFT("JoysHero NFT", "JoysHero") {
    }
}

contract JoysWeapon is JoysNFT {
    constructor() public JoysNFT("JoysWeapon NFT", "JoysWeapon") {
    }
}// GPL-3.0
pragma solidity 0.6.12;



contract JoysNFTMinning is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using Counters for Counters.Counter;

    struct UserInfo {
        uint256 point;              // The point of nft from the user has provided.
        uint256 heroId;             // Joys hero token id.
        uint256 weaponId;           // Joys weapon token id.
        bool withWeapon;            // Whether stake weapon.
        uint256 heroPoint;          // Joys hero point
        uint256 weaponPoint;        // Joys weapon point
        uint256 rewardDebt;         // Reward debt. See explanation below.
        uint256 blockNumber;        // The block when user deposit.

    }
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    mapping (address => uint256) public userReward;

    struct PoolInfo {
        uint256 point;              // Joys nft point
        bool withWeapon;            // Whether require weapon nft.
        uint256 allocPoint;         // How many allocation points assigned to this pool. Joys to distribute per block.
        uint256 lastRewardBlock;    // Last block number that Joys distribution occurs.
        uint256 accJoysPerShare;    // Accumulated Joys per share, times 1e12. See below.
    }
    PoolInfo[] public poolInfo;

    mapping (uint256 => uint256) public heroTracker;

    uint256 public totalAllocPoint = 0;

    JoysToken public joys;                  // address of joys token contract
    JoysNFT public joysHero;                // address of joys hero contract
    JoysNFT public joysWeapon;              // address of joys weapon contract

    uint256 public bonusBeginBlock;
    uint256 public bonusEndBlock;

    uint256 public constant BLOCK_PER_DAY = 6000;
    uint256 public constant MAX_REWARD_JOYS_PER_DAY = 20000;

    uint256 public constant BONUS_MULTIPLIER_8 = 20 * 10;
    uint256 public constant BONUS_MULTIPLIER_4 = 10 * 10;
    uint256 public constant BONUS_MULTIPLIER_2 = 5 * 10;
    uint256 public constant BONUS_MULTIPLIER_1 = 2.5 * 10;

    uint256 public constant MINED_DAYS = 48;

    uint256 public constant CONTINUE_DAYS_PER_STAGE = 12;

    uint256 public constant DEFAULT_HEROES = 100;

    struct PeriodInfo {
        uint256 begin;
        uint256 end;
        uint256 multiplier;     // times 10
        uint256 joysPerBlock;   // times 1e12
    }
    PeriodInfo[] public periodInfo;

    uint256 public lastMinersCount;

    event Deposit(address indexed user, uint256 indexed pid, uint256 heroId, bool withWeapon, uint256 weaponId);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 heroId, bool withWeapon, uint256 weaponId, uint256 _amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 heroId, bool withWeapon, uint256 weaponId);

    constructor(address _joys,
        address _joysHero,
        address _joysWeapon
    ) public {
        joys = JoysToken(_joys);
        joysHero = JoysNFT(_joysHero);
        joysWeapon = JoysNFT(_joysWeapon);

        lastMinersCount = DEFAULT_HEROES;

        bonusBeginBlock = block.number;
        bonusEndBlock = bonusBeginBlock.add(BLOCK_PER_DAY.mul(MINED_DAYS));

        uint256 multiplier = BONUS_MULTIPLIER_8;
        uint256 currentBlock = bonusBeginBlock;
        uint256 lastBlock = currentBlock;
        for (; currentBlock < bonusEndBlock; currentBlock = currentBlock.add(CONTINUE_DAYS_PER_STAGE.mul(BLOCK_PER_DAY))) {
            periodInfo.push(PeriodInfo({
                begin: lastBlock,
                end: currentBlock.add(CONTINUE_DAYS_PER_STAGE.mul(BLOCK_PER_DAY)),
                multiplier: multiplier,
                joysPerBlock: DEFAULT_HEROES.mul(multiplier).mul(1e11).div(BLOCK_PER_DAY)
                }));

            lastBlock = currentBlock.add(CONTINUE_DAYS_PER_STAGE.mul(BLOCK_PER_DAY));
            multiplier = multiplier.div(2);
        }

        add(30, false, false);
        add(30, false, false);
        add(40, true, true);
    }

    function periodInfoLength() external view returns (uint256) {
        return periodInfo.length;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function add(uint256 _allocPoint, bool _withWeapon, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > bonusBeginBlock? block.number : bonusBeginBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            point: 0,
            withWeapon: _withWeapon,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accJoysPerShare: 0
            }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function heroes(uint256 _pid) public view returns (uint256) {
        return heroTracker[_pid];
    }

    function totalHeroes() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 pid = 0; pid < poolInfo.length; ++pid) {
            sum = sum.add(heroes(pid));
        }
        return sum;
    }

    function withdrawPercent(uint256 _from, uint256 _to) public pure returns (uint256) {
        if (_to.sub(_from) <= BLOCK_PER_DAY.mul(3)) {
            return 90;
        }
        return 100;
    }

    function poolAllocPoint(uint256 _pid) public view returns (uint256){
        return poolInfo[_pid].allocPoint;
    }

    function getReward(uint256 _from, uint256 _to) public view returns (uint256) {
        uint256 totalReward;
        for (uint256 i = 0; i < periodInfo.length; ++i) {
            if (_to <= periodInfo[i].end) {
                if (i == 0) {
                    totalReward = totalReward.add(_to.sub(_from).mul(periodInfo[i].joysPerBlock));
                    break;
                } else {
                    uint256 dest = periodInfo[i].begin;
                    if (_from > periodInfo[i].begin) {
                        dest = _from;
                    }
                    totalReward = totalReward.add(_to.sub(dest).mul(periodInfo[i].joysPerBlock));
                    break;
                }
            } else if (_from >= periodInfo[i].end) {
                continue;
            } else {
                totalReward = totalReward.add(periodInfo[i].end.sub(_from).mul(periodInfo[i].joysPerBlock));
                _from = periodInfo[i].end;
            }
        }

        return totalReward.mul(1e6);
    }

    function getRate(uint256 _block) public view returns (uint256) {
        for (uint256 i = 0; i < periodInfo.length; ++i) {
            if (_block <= periodInfo[i].end) {
               return periodInfo[i].multiplier;
            }
        }
        return 0;
    }

    function pendingJoys(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accJoysPerShare = pool.accJoysPerShare;
        uint256 nftPoint = pool.point;
        if (block.number > pool.lastRewardBlock && nftPoint != 0) {
            uint256 reward = getReward(pool.lastRewardBlock, block.number);
            uint256 poolReward = reward.mul(pool.allocPoint).div(totalAllocPoint);
            accJoysPerShare = accJoysPerShare.add(poolReward.mul(1e12).div(nftPoint));
        }
        return user.point.mul(accJoysPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 nftPoint = pool.point;
        if (nftPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 reward = getReward(pool.lastRewardBlock, block.number);
        uint256 poolReward = reward.mul(pool.allocPoint).div(totalAllocPoint);
        pool.accJoysPerShare = pool.accJoysPerShare.add(poolReward.mul(1e12).div(nftPoint));
        pool.lastRewardBlock = block.number;
    }

    function updatePeriod() public {
        uint256 th = totalHeroes();
        if (th < lastMinersCount.add(DEFAULT_HEROES)) {
            return;
        }
        lastMinersCount = th;

        periodInfo.push(PeriodInfo({
            begin: block.number,
            end: 0,
            multiplier:0,
            joysPerBlock:0
            }));

        for (uint256 i = periodInfo.length - 1; i > 0; i--) {
            if (periodInfo[i-1].begin < block.number) {
                uint256 end = periodInfo[i-1].end;
                uint256 multiplier = periodInfo[i-1].multiplier;

                periodInfo[i-1].end = block.number;

                uint256 joysPerDay = lastMinersCount.mul(multiplier).div(10);
                if (joysPerDay > MAX_REWARD_JOYS_PER_DAY) {
                    joysPerDay = MAX_REWARD_JOYS_PER_DAY;
                }
                uint256 joysPerBlock = joysPerDay.mul(1e12).div(BLOCK_PER_DAY);
                periodInfo[i].end = end;
                periodInfo[i].multiplier = multiplier;
                periodInfo[i].joysPerBlock = joysPerBlock;
                break;
            }

            uint256 begin = periodInfo[i-1].begin;
            uint256 end = periodInfo[i-1].end;
            uint256 multiplier = periodInfo[i-1].multiplier;
            uint256 joysPerDay = lastMinersCount.mul(multiplier).div(10);
            if (joysPerDay > MAX_REWARD_JOYS_PER_DAY) {
                joysPerDay = MAX_REWARD_JOYS_PER_DAY;
            }
            uint256 joysPerBlock = joysPerDay.mul(1e12).div(BLOCK_PER_DAY);

            periodInfo[i-1] = periodInfo[i];

            periodInfo[i].begin = begin;
            periodInfo[i].end = end;
            periodInfo[i].multiplier = multiplier;
            periodInfo[i].joysPerBlock = joysPerBlock;
        }
    }

    function deposit(uint256 _pid, uint256 _heroId, bool _withWeapon, uint256 _weaponId) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.point <= 0, "JoysNFTMinning: Do the withdrawal operation first.");
        if (pool.withWeapon) {
          require(_withWeapon, "JoysNftMinning: Need weapon.");
        }

        heroTracker[_pid] = heroTracker[_pid].add(1);
        updatePool(_pid);
        updatePeriod();

        uint256 heroStrength;
        (, heroStrength, , ) = joysHero.info(_heroId);
        user.point = user.point.add(heroStrength);
        user.heroPoint = heroStrength;
        pool.point = pool.point.add(heroStrength);
        joysHero.transferFrom(_msgSender(), address(this), _heroId);

        if (_withWeapon) {
            uint256 weaponStrength;
            (, weaponStrength, , ) = joysWeapon.info(_weaponId);
            user.point = user.point.add(weaponStrength);
            user.weaponPoint = weaponStrength;
            pool.point = pool.point.add(weaponStrength);
            joysWeapon.transferFrom(_msgSender(), address(this), _weaponId);
        }

        user.heroId = _heroId;
        user.weaponId = _weaponId;
        user.withWeapon = _withWeapon;
        user.rewardDebt = user.point.mul(pool.accJoysPerShare).div(1e12);
        user.blockNumber = block.number;

        emit Deposit(_msgSender(), _pid, _heroId, _withWeapon, _weaponId);
    }

    function withdraw(uint256 _pid, bool _withNFT) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.point > 0, "JoysNftMinning: withdraw not good");

        updatePool(_pid);

        uint256 pending = user.point.mul(pool.accJoysPerShare).div(1e12).sub(user.rewardDebt);
        uint256 amount = 0;
        if (pending > 0) {
            amount = pending.mul(withdrawPercent(user.blockNumber, block.number)).div(100);
            safeJoysTransfer(_msgSender(), amount);
        }
        if (_withNFT && user.point > 0) {
            if(user.withWeapon) {
                pool.point = pool.point.sub(user.weaponPoint);
                joysWeapon.transferFrom(address(this), _msgSender(), user.weaponId);
            }
            pool.point = pool.point.sub(user.heroPoint);
            joysHero.transferFrom(address(this), _msgSender(), user.heroId);
            heroTracker[_pid] = heroTracker[_pid].sub(1);

            user.point = 0;
        }

        user.rewardDebt = user.point.mul(pool.accJoysPerShare).div(1e12);
        emit Withdraw(_msgSender(), _pid, user.heroId, user.withWeapon, user.weaponId, amount);

        userReward[_msgSender()] = userReward[_msgSender()].add(amount);
    }

    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];

        if (user.point > 0) {
            if(user.withWeapon) {
                pool.point = pool.point.sub(user.weaponPoint);
                joysWeapon.transferFrom(address(this), _msgSender(), user.weaponId);
            }
            pool.point = pool.point.sub(user.heroPoint);
            joysHero.transferFrom(address(this), _msgSender(), user.heroId);
            heroTracker[_pid] = heroTracker[_pid].sub(1);
        }
        emit EmergencyWithdraw(_msgSender(), _pid, user.heroId, user.withWeapon, user.weaponId);
        user.point = 0;
        user.rewardDebt = 0;
    }

    function safeJoysTransfer(address _to, uint256 _amount) internal {
        uint256 joysBal = joys.balanceOf(address(this));
        if (_amount > joysBal) {
            joys.transfer(_to, joysBal);
        } else {
            joys.transfer(_to, _amount);
        }
        return;
    }

    function recycleJoysToken(address _address) public onlyOwner {
        require(_address != address(0), "JoysLottery:Invalid address");
        require(joys.balanceOf(address(this)) > 0, "JoysLottery:no JOYS");
        joys.transfer(_address, joys.balanceOf(address(this)));
    }
}