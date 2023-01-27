
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20PausableUpgradeable is Initializable, ERC20Upgradeable, PausableUpgradeable {
    function __ERC20Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC20Pausable_init_unchained();
    }

    function __ERC20Pausable_init_unchained() internal initializer {
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20BurnableUpgradeable is Initializable, ContextUpgradeable, ERC20Upgradeable {
    function __ERC20Burnable_init() internal initializer {
        __Context_init_unchained();
        __ERC20Burnable_init_unchained();
    }

    function __ERC20Burnable_init_unchained() internal initializer {
    }
    using SafeMathUpgradeable for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSetUpgradeable {


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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
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

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
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
    uint256[49] private __gap;
}// MIT
pragma solidity ^0.6.0;


contract F24 is ERC20PausableUpgradeable, ERC20BurnableUpgradeable, AccessControlUpgradeable {

  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  function initialize() public initializer {

      __Context_init_unchained();
      __ERC20_init_unchained("Fiat24 Coupon", "F24");
      __AccessControl_init_unchained();
      _setupDecimals(2);
      _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
      _setupRole(OPERATOR_ROLE, _msgSender());
  }

  function mint(address account, uint256 amount) public {

      require(hasRole(OPERATOR_ROLE, msg.sender), "Caller is not an operator");
      _mint(account, amount);
  }

  function burn(address account, uint256 amount) public {

      require(hasRole(OPERATOR_ROLE, msg.sender), "Caller is not an operator");
      _burn(account, amount);
  }

  function pause() public {

      require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
      _pause();
  }

  function unpause() public {

      require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin");
      _unpause();
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20Upgradeable, ERC20PausableUpgradeable) {

      super._beforeTokenTransfer(from, to, amount);
  }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

pragma solidity >=0.6.2 <0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableMapUpgradeable {


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

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
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

        return _set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
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
        return (uint256(key), address(uint160(uint256(value))));
    }

    function tryGet(UintToAddressMap storage map, uint256 key) internal view returns (bool, address) {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, address(uint160(uint256(value))));
    }

    function get(UintToAddressMap storage map, uint256 key) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key)))));
    }

    function get(UintToAddressMap storage map, uint256 key, string memory errorMessage) internal view returns (address) {

        return address(uint160(uint256(_get(map._inner, bytes32(key), errorMessage))));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library StringsUpgradeable {

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable, IERC721EnumerableUpgradeable {

    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.UintToAddressMap;
    using StringsUpgradeable for uint256;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (address => EnumerableSetUpgradeable.UintSet) private _holderTokens;

    EnumerableMapUpgradeable.UintToAddressMap private _tokenOwners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    string private _name;

    string private _symbol;

    mapping (uint256 => string) private _tokenURIs;

    string private _baseURI;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;

        _registerInterface(_INTERFACE_ID_ERC721);
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _holderTokens[owner].length();
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        return _tokenOwners.get(tokenId, "ERC721: owner query for nonexistent token");
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function baseURI() public view virtual returns (string memory) {

        return _baseURI;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {

        return _holderTokens[owner].at(index);
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _tokenOwners.length();
    }

    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {

        (uint256 tokenId, ) = _tokenOwners.at(index);
        return tokenId;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || ERC721Upgradeable.isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

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

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _tokenOwners.contains(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || ERC721Upgradeable.isApprovedForAll(owner, spender));
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

        address owner = ERC721Upgradeable.ownerOf(tokenId); // internal owner

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

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own"); // internal owner
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
            IERC721ReceiverUpgradeable(to).onERC721Received.selector,
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
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId); // internal owner
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }

    uint256[41] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC721PausableUpgradeable is Initializable, ERC721Upgradeable, PausableUpgradeable {
    function __ERC721Pausable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __Pausable_init_unchained();
        __ERC721Pausable_init_unchained();
    }

    function __ERC721Pausable_init_unchained() internal initializer {
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        require(!paused(), "ERC721Pausable: token transfer while paused");
    }
    uint256[50] private __gap;
}// MIT
pragma solidity >=0.6.0 <0.8.5;

library DigitsOfUint {

    using SafeMathUpgradeable for uint256;
    function numDigits(uint256 _number) internal pure returns (uint256) {

        uint256 number = _number;
        uint256 digits = 0;
        while (number != 0) {
            number = number.div(10);
            digits = digits.add(1);
        }
        return digits;
    }
    function hasFirstDigit(uint256 _accountId, uint _firstDigit) internal pure returns (bool) {

        uint256 number = _accountId;
        while (number >= 10) {
            number = number.div(10);
        }
        return number == _firstDigit;
    }


}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableUintToUintMapUpgradeable {


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

    function _tryGet(Map storage map, bytes32 key) private view returns (bool, bytes32) {

        uint256 keyIndex = map._indexes[key];
        if (keyIndex == 0) return (false, 0); // Equivalent to contains(map, key)
        return (true, map._entries[keyIndex - 1]._value); // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, "EnumerableMap: nonexistent key"); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }

    function _get(Map storage map, bytes32 key, string memory errorMessage) private view returns (bytes32) {

        uint256 keyIndex = map._indexes[key];
        require(keyIndex != 0, errorMessage); // Equivalent to contains(map, key)
        return map._entries[keyIndex - 1]._value; // All indexes are 1-based
    }


    struct UintToUintMap {
        Map _inner;
    }

    function set(UintToUintMap storage map, uint256 key, uint256 value) internal returns (bool) {

        return _set(map._inner, bytes32(key), bytes32(value));
    }

    function remove(UintToUintMap storage map, uint256 key) internal returns (bool) {

        return _remove(map._inner, bytes32(key));
    }

    function contains(UintToUintMap storage map, uint256 key) internal view returns (bool) {

        return _contains(map._inner, bytes32(key));
    }

    function length(UintToUintMap storage map) internal view returns (uint256) {

        return _length(map._inner);
    }

    function at(UintToUintMap storage map, uint256 index) internal view returns (uint256, uint256) {

        (bytes32 key, bytes32 value) = _at(map._inner, index);
        return (uint256(key), uint256(value));
    }

    function tryGet(UintToUintMap storage map, uint256 key) internal view returns (bool, uint256) {

        (bool success, bytes32 value) = _tryGet(map._inner, bytes32(key));
        return (success, uint256(value));
    }

    function get(UintToUintMap storage map, uint256 key) internal view returns (uint256) {

        return uint256(_get(map._inner, bytes32(key)));
    }

    function get(UintToUintMap storage map, uint256 key, string memory errorMessage) internal view returns (uint256) {

        return uint256(_get(map._inner, bytes32(key), errorMessage));
    }
}// MIT
pragma solidity ^0.6.0;


contract Fiat24PriceList is Initializable, AccessControlUpgradeable {

    using EnumerableUintToUintMapUpgradeable for EnumerableUintToUintMapUpgradeable.UintToUintMap;
    using DigitsOfUint for uint256;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    EnumerableUintToUintMapUpgradeable.UintToUintMap private _priceList;
    function initialize() public initializer {

        __AccessControl_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());
        _priceList.set(1,27993600);
        _priceList.set(2, 4665600);
        _priceList.set(3, 777600);
        _priceList.set(4, 129600);
        _priceList.set(5, 21600);
        _priceList.set(6, 3600);
        _priceList.set(7, 600);
        _priceList.set(8, 100);
    }

    function getPrice(uint256 accountNumber) external view returns(uint256) {

        if(!_priceList.contains(accountNumber.numDigits())) {
            return 0;
        } else {
            return _priceList.get(accountNumber.numDigits());
        }
    }

    function setPrice(uint256 digits, uint256 price) external {

        require(hasRole(OPERATOR_ROLE, msg.sender), "Caller is not an operator");
        _priceList.set(digits, price);
    }
}// MIT
pragma solidity ^0.6.0;


contract Fiat24Account is ERC721PausableUpgradeable, AccessControlUpgradeable {

    using DigitsOfUint for uint256;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    uint256 private constant DEFAULT_MERCHANT_RATE = 55;

    enum Status { Live, SoftBlocked, Invitee, Blocked, Closed, Na}
    string private constant BASE_URI_METADATA = 'https://api.defi.saphirstein.com/metadata?tokenid=';
    string private constant URI_STATUS_PARAM = '&status=';

    uint8 private constant MERCHANTDIGIT = 8;
    uint8 private constant INTERNALDIGIT = 9;
    uint8 private constant MAXDIGITSACCOUNTID = 8;

    mapping (address => uint256) private _tokenOwnersHistoric;


    mapping (uint256 => string) public nickNames;
    mapping (uint256 => bool) public isMerchant;
    mapping (uint256 => uint256) public merchantRate;
    mapping (uint256 => Status) public status;

    uint8 public minDigitForSale;

    function initialize(/*address _f24Address, address _fiat24PriceListAddress*/) public initializer {

        __Context_init_unchained();
        __ERC721_init_unchained("Fiat24 Account", "Fiat24");
        __AccessControl_init_unchained();
        minDigitForSale = 6;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(OPERATOR_ROLE, _msgSender());
    }

    function mint(address _to, uint256 _tokenId, bool _isMerchant, uint256 _merchantRate) public {

        require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
        require(_mintAllowed(_to, _tokenId), "mint not allowed");
        require(_tokenId.numDigits() <= MAXDIGITSACCOUNTID, "Number of digits of accountId > max. digits");
        _mint(_to, _tokenId);
        status[_tokenId] = Status.Invitee;
        isMerchant[_tokenId] = _isMerchant;
        if(_isMerchant) {
            nickNames[_tokenId] = string(abi.encodePacked("Merchant ", _tokenId.toString()));
            if(_merchantRate == 0) {
                merchantRate[_tokenId] = DEFAULT_MERCHANT_RATE;
            } else {
                merchantRate[_tokenId] = _merchantRate;
            }
        } else {
            nickNames[_tokenId] = string(abi.encodePacked("Tourist ", _tokenId.toString()));
        }
        _setTokenURI(_tokenId, string(abi.encodePacked(BASE_URI_METADATA,
                    _tokenId.toString(),
                    URI_STATUS_PARAM,
                    uint256(Status.Invitee).toString())));
    }


    function mintByClient(uint256 _tokenId) public {

        uint256 numDigits = _tokenId.numDigits();
        require(numDigits <= MAXDIGITSACCOUNTID, "Number of digits of accountId > max. digits");
        require(numDigits >= minDigitForSale, "Minimal digits limit of accountId broken");
        require(!_tokenId.hasFirstDigit(INTERNALDIGIT), "AccountId not allowed to mint");
        require(_mintAllowed(_msgSender(), _tokenId), "mint not allowed");
        bool merchantAccountId = _tokenId.hasFirstDigit(MERCHANTDIGIT);
        _mint(_msgSender(), _tokenId);
        status[_tokenId] = Status.Invitee;
        isMerchant[_tokenId] = merchantAccountId;
        if(merchantAccountId) {
            nickNames[_tokenId] = string(abi.encodePacked("Merchant ", _tokenId.toString()));
            merchantRate[_tokenId] = DEFAULT_MERCHANT_RATE;
        } else {
            nickNames[_tokenId] = string(abi.encodePacked("Tourist ", _tokenId.toString()));
        }
        _setTokenURI(_tokenId, string(abi.encodePacked(BASE_URI_METADATA,
                    _tokenId.toString(),
                    URI_STATUS_PARAM,
                    uint256(Status.Invitee).toString())));
    }

    function burn(uint256 tokenId) public {

        require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
        _burn(tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        super.transferFrom(from, to, tokenId);
        if(status[tokenId] != Status.Invitee) {
            _tokenOwnersHistoric[to] = tokenId;
        }
    }

    function getAccountOfAddress(address owner) public view returns(uint256) {

        return _tokenOwnersHistoric[owner];
    }

    function removeHistoricOwnership(address owner) public {

        require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
        delete _tokenOwnersHistoric[owner];
    }


    function changeClientStatus(uint256 tokenId, Status _status) public {

        require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
        if(_status == Status.Live && status[tokenId] == Status.Invitee) {
            _tokenOwnersHistoric[this.ownerOf(tokenId)] = tokenId;
            if(!this.isMerchant(tokenId)) {
                nickNames[tokenId] = string(abi.encodePacked("Account ", tokenId.toString()));
            }
        }
        status[tokenId] = _status;
        _setTokenURI(tokenId, string(abi.encodePacked(BASE_URI_METADATA, tokenId.toString(), URI_STATUS_PARAM, uint256(_status).toString())));
    }


    function setMinDigitForSale(uint8 minDigit) public {

        require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
        minDigitForSale = minDigit;
    }

    function setMerchantRate(uint256 tokenId, uint256 _merchantRate) public {

        require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
        merchantRate[tokenId] = _merchantRate;
    }

    function setNickname(uint256 tokenId, string memory nickname) public {

        require(_msgSender() == this.ownerOf(tokenId), "Not account owner");
        nickNames[tokenId] = nickname;
    }

    function pause() public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not an admin");
        _pause();
    }

    function unpause() public {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not an admin");
        _unpause();
    }

    function _mintAllowed(address to, uint256 tokenId) internal view returns(bool){

        return (this.balanceOf(to) < 1 && (_tokenOwnersHistoric[to] == 0 || _tokenOwnersHistoric[to] == tokenId));
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {

        require(!paused(), "Account transfers suspended");
        if(AddressUpgradeable.isContract(to) && (from != address(0))) {
            require(this.status(tokenId) == Status.Invitee, "Not allowed to transfer account");
        } else {
                if(from != address(0) && to != address(0)) {
                    require(balanceOf(to) < 1 && (_tokenOwnersHistoric[to] == 0 || _tokenOwnersHistoric[to] == tokenId), "Receiver has already account or account is blocked");
                    require(this.status(tokenId) == Status.Live || this.status(tokenId) == Status.Invitee, "Transfer not allowed in this status");
                }
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }
}// MIT
pragma solidity ^0.6.0;


contract Fiat24Token is ERC20PausableUpgradeable, AccessControlUpgradeable {

    using SafeMathUpgradeable for uint256;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    uint256 internal WalkinLimit;
    uint256 internal WithdrawCharge;
    uint256 private constant MINIMALCOMMISIONFEE = 10;
    Fiat24Account fiat24account;

    mapping (address => uint256) public walkinAccumulated;

    function __Fiat24Token_init_(address fiat24accountProxyAddress,
                               string memory name_,
                               string memory symbol_,
                               uint256 walkinLimit,
                               uint256 withdrawCharge) internal initializer {

      __Context_init_unchained();
      __AccessControl_init_unchained();
      __ERC20_init_unchained(name_, symbol_);
      _setupDecimals(2);
      _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
      _setupRole(OPERATOR_ROLE, _msgSender());
      fiat24account = Fiat24Account(fiat24accountProxyAddress);
      WithdrawCharge = withdrawCharge;
      WalkinLimit = walkinLimit;
  }

  function mint(uint256 amount) public {

      require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
      _mint(fiat24account.ownerOf(9101), amount);
  }

  function burn(uint256 amount) public {

      require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
      _burn(fiat24account.ownerOf(9104), amount);
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

    if(recipient == fiat24account.ownerOf(9102)) {
        _transfer(_msgSender(), recipient, amount.sub(WithdrawCharge, "Withdraw charge exceeds withdraw amount"));
        _transfer(_msgSender(), fiat24account.ownerOf(9202), WithdrawCharge);
    } else {
        if(fiat24account.balanceOf(recipient) > 0 && fiat24account.isMerchant(fiat24account.getAccountOfAddress(recipient))) {
            uint256 commissionFee = amount.mul(fiat24account.merchantRate(fiat24account.getAccountOfAddress(recipient))).div(10000);
            if(commissionFee >= MINIMALCOMMISIONFEE) {
                _transfer(_msgSender(), recipient, amount.sub(commissionFee, "Commission fee exceeds payment amount"));
                _transfer(_msgSender(), fiat24account.ownerOf(9201), commissionFee);
            } else {
                _transfer(_msgSender(), recipient, amount);
            }
        } else {
            _transfer(_msgSender(), recipient, amount);
        }
    }
    return true;
  }

  function transferByAccountId(uint256 recipientAccountId, uint256 amount) public returns(bool){

    return transfer(fiat24account.ownerOf(recipientAccountId), amount);
  }

  function balanceOfByAccountId(uint256 accountId) public view returns(uint256) {

    return balanceOf(fiat24account.ownerOf(accountId));
  }

  function tokenTransferAllowed(address from, address to, uint256 amount) public view returns(bool){

    require(!fiat24account.paused(), "All account transfers are paused");
    require(!paused(), "All account transfers of this currency are paused");
    if(from != address(0) && to != address(0)){
        if(balanceOf(from) < amount) {
            return false;
        }
        uint256 toAmount = amount + balanceOf(to);
        Fiat24Account.Status fromClientStatus;
        uint256 accountIdFrom = fiat24account.getAccountOfAddress(from);
        if(accountIdFrom != 0) {
            fromClientStatus = fiat24account.status(accountIdFrom);
        } else {
            fromClientStatus = Fiat24Account.Status.Invitee;
        }
        Fiat24Account.Status toClientStatus;
        uint256 accountIdTo = fiat24account.getAccountOfAddress(to);
        if(accountIdTo != 0) {
            toClientStatus = fiat24account.status(accountIdTo);
        } else {
            toClientStatus = Fiat24Account.Status.Invitee;
        }
        if((fromClientStatus == Fiat24Account.Status.Live) &&
           (toClientStatus == Fiat24Account.Status.Live || toClientStatus == Fiat24Account.Status.SoftBlocked ||
            (toClientStatus == Fiat24Account.Status.Invitee && toAmount <= WalkinLimit))) {
          return true;
        } else {
          return false;
        }




    }
  }

  function setWalkInLimit(uint256 walkinLimit) public {

    require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
    WalkinLimit = walkinLimit;
  }

  function setWithdrawCharge(uint256 withdrawCharge) public {

    require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
    WithdrawCharge = withdrawCharge;
  }

  function sendToSundry(address from, uint256 amount) public {

    require(hasRole(OPERATOR_ROLE, msg.sender), "Not an operator");
    _transfer(from, fiat24account.ownerOf(9103), amount);
  }

  function pause() public {

    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not an admin");
    _pause();
  }

  function unpause() public {

    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not an admin");
    _unpause();
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {

    require(!fiat24account.paused(), "Fiat24Token: all account transfers are paused");
    require(!paused(), "Fiat24Token: all account transfers of this currency are paused");
    if(from != address(0) && to != address(0) && to != fiat24account.ownerOf(9103)){
        require(tokenTransferAllowed(from, to, amount), "Fiat24Token: No FIAT24 account, accounts blocked or transfer limit exceeded");
    }
    super._beforeTokenTransfer(from, to, amount);
  }
}// MIT
pragma solidity ^0.6.0;


contract Fiat24CHF is Fiat24Token {


  function initialize(address fiat24AccountProxyAddress, uint256 walkinLimit, uint256 withdrawCharge) initializer public {

      __Fiat24Token_init_(fiat24AccountProxyAddress, "Fiat24 CHF", "CHF24", walkinLimit, withdrawCharge);
  }
  
}