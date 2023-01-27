
pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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

}//GPL-3.0-only
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


contract TokenListManager is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _erc20Id;
    Counters.Counter private _erc1155Id;

    mapping(address => uint256) public allowedErc20tokens;

    mapping(address => uint256) public allowedErc1155tokens;

    bytes32 public constant TOKEN_MANAGER_ROLE = keccak256("TOKEN_MANAGER_ROLE");

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setRegistryManager(address _manager) external {
        grantRole(TOKEN_MANAGER_ROLE, _manager);
    }

    function registerERC20Token(address _token) external isAdmin {
        require(_token != address(0), "token is the zero address");

        emit RegisterERC20Token(_token);
        _erc20Id.increment();
        allowedErc20tokens[_token] = _erc20Id.current();
    }

    function registerERC1155Token(address _token) external isAdmin {
        require(_token != address(0), "token is the zero address");
        emit RegisterERC1155Token(_token);
        _erc1155Id.increment();
        allowedErc1155tokens[_token] = _erc1155Id.current();
    }

    function unRegisterERC20Token(address _token) external isAdmin {
        require(_token != address(0), "token is the zero address");
        emit unRegisterERC20(_token);
        delete allowedErc20tokens[_token];
    }

    function unRegisterERC1155Token(address _token) external isAdmin {
        require(_token != address(0), "token is the zero address");
        emit unRegisterERC1155(_token);
        delete allowedErc1155tokens[_token];
    }

    modifier isAdmin() {
        require(hasRole(TOKEN_MANAGER_ROLE, _msgSender()), "must have dOTC Admin role");
        _;
    }

    event RegisterERC20Token(address indexed token);

    event RegisterERC1155Token(address indexed token);

    event unRegisterERC1155(address indexed token);

    event unRegisterERC20(address indexed token);
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

pragma solidity ^0.7.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}// MIT

pragma solidity ^0.7.0;


interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}// MIT

pragma solidity ^0.7.0;


interface IERC1155MetadataURI is IERC1155 {
    function uri(uint256 id) external view returns (string memory);
}// MIT

pragma solidity ^0.7.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}// MIT

pragma solidity ^0.7.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
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

pragma solidity ^0.7.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using SafeMath for uint256;
    using Address for address;

    mapping (uint256 => mapping(address => uint256)) private _balances;

    mapping (address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    constructor (string memory uri_) {
        _setURI(uri_);

        _registerInterface(_INTERFACE_ID_ERC1155);

        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    function uri(uint256) external view override returns (string memory) {
        return _uri;
    }

    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            require(accounts[i] != address(0), "ERC1155: batch balance query for the zero address");
            batchBalances[i] = _balances[ids[i]][accounts[i]];
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address account, uint256 id, uint256 amount) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal virtual
    { }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}//GPL-3.0-only
pragma solidity ^0.7.0;


contract PermissionItems is ERC1155, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor() ERC1155("") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setAdmin(address account) external {
        grantRole(MINTER_ROLE, account);
        grantRole(BURNER_ROLE, account);
    }

    function revokeAdmin(address account) external {
        revokeRole(MINTER_ROLE, account);
        revokeRole(BURNER_ROLE, account);
    }

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "PermissionItems: must have minter role to mint");

        super._mint(to, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external {
        require(hasRole(MINTER_ROLE, _msgSender()), "PermissionItems: must have minter role to mint");

        super._mintBatch(to, ids, amounts, data);
    }

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external {
        require(hasRole(BURNER_ROLE, _msgSender()), "PermissionItems: must have burner role to burn");
        super._burn(account, id, value);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external {
        require(hasRole(BURNER_ROLE, _msgSender()), "PermissionItems: must have burner role to burn");
        super._burnBatch(account, ids, values);
    }

    function setApprovalForAll(address, bool) public pure override {
        revert("disabled");
    }

    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public pure override {
        revert("disabled");
    }

    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public pure override {
        revert("disabled");
    }
}//GPL-3.0-only
pragma solidity ^0.7.0;

abstract contract PermissionManagerStorage {
    bytes32 public constant PERMISSIONS_ADMIN_ROLE = keccak256("PERMISSIONS_ADMIN_ROLE");

    address public permissionItems;

    uint256 public constant SUSPENDED_ID = 0;
    uint256 public constant TIER_1_ID = 1;
    uint256 public constant TIER_2_ID = 2;
    uint256 public constant REJECTED_ID = 3;
    uint256 public constant PROTOCOL_CONTRACT = 4;
}//GPL-3.0-only
pragma solidity ^0.7.0;



contract PermissionManager is Initializable, AccessControlUpgradeable, PermissionManagerStorage {
    struct UserProxy {
        address user;
        address proxy;
    }

    event PermissionItemsSet(address indexed newPermissions);

    function initialize(address _permissionItems, address _admin) public initializer {
        require(_permissionItems != address(0), "_permissionItems is the zero address");
        require(_admin != address(0), "_admin is the zero address");
        permissionItems = _permissionItems;

        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);

        emit PermissionItemsSet(permissionItems);
    }

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "must have default admin role");
        _;
    }

    modifier onlyPermissionsAdmin() {
        require(hasRole(PERMISSIONS_ADMIN_ROLE, _msgSender()), "must have permissions admin role");
        _;
    }

    function setPermissionsAdmin(address _permissionsAdmin) external onlyAdmin {
        require(_permissionsAdmin != address(0), "_permissionsAdmin is the zero address");
        grantRole(PERMISSIONS_ADMIN_ROLE, _permissionsAdmin);
    }

    function setPermissionItems(address _permissionItems) external onlyAdmin returns (bool) {
        require(_permissionItems != address(0), "_permissionItems is the zero address");
        emit PermissionItemsSet(_permissionItems);
        permissionItems = _permissionItems;
        return true;
    }

    function assingTier1(address[] memory _accounts) external onlyPermissionsAdmin {
        for (uint256 i = 0; i < _accounts.length; i++) {
            require(!hasTier1(_accounts[i]), "PermissionManager: Address already has Tier 1 assigned");
            PermissionItems(permissionItems).mint(_accounts[i], TIER_1_ID, 1, "");
        }
    }

    function assingTier2(UserProxy[] memory _usersProxies) external onlyPermissionsAdmin {
        for (uint256 i = 0; i < _usersProxies.length; i++) {
            UserProxy memory userProxy = _usersProxies[i];
            require(!hasTier2(userProxy.user), "PermissionManager: Address already has Tier 2 assigned");
            require(!hasTier2(userProxy.proxy), "PermissionManager: Proxy already has Tier 2 assigned");

            PermissionItems(permissionItems).mint(userProxy.user, TIER_2_ID, 1, "");
            PermissionItems(permissionItems).mint(userProxy.proxy, TIER_2_ID, 1, "");
        }
    }

    function suspendUser(UserProxy[] memory _usersProxies) external onlyPermissionsAdmin {
        for (uint256 i = 0; i < _usersProxies.length; i++) {
            UserProxy memory userProxy = _usersProxies[i];
            require(!isSuspended(userProxy.user), "PermissionManager: Address is already suspended");
            PermissionItems(permissionItems).mint(userProxy.user, SUSPENDED_ID, 1, "");

            if (userProxy.proxy != address(0)) {
                require(!isSuspended(userProxy.proxy), "PermissionManager: Proxy is already suspended");
                PermissionItems(permissionItems).mint(userProxy.proxy, SUSPENDED_ID, 1, "");
            }
        }
    }

    function rejectUser(UserProxy[] memory _usersProxies) external onlyPermissionsAdmin {
        for (uint256 i = 0; i < _usersProxies.length; i++) {
            UserProxy memory userProxy = _usersProxies[i];
            require(!isRejected(userProxy.user), "PermissionManager: Address is already rejected");
            PermissionItems(permissionItems).mint(userProxy.user, REJECTED_ID, 1, "");

            if (userProxy.proxy != address(0)) {
                require(!isRejected(userProxy.proxy), "PermissionManager: Proxy is already rejected");
                PermissionItems(permissionItems).mint(userProxy.proxy, REJECTED_ID, 1, "");
            }
        }
    }

    function revokeTier1(address[] memory _accounts) external onlyPermissionsAdmin {
        for (uint256 i = 0; i < _accounts.length; i++) {
            require(hasTier1(_accounts[i]), "PermissionManager: Address doesn't has Tier 1 assigned");
            PermissionItems(permissionItems).burn(_accounts[i], TIER_1_ID, 1);
        }
    }

    function revokeTier2(UserProxy[] memory _usersProxies) external onlyPermissionsAdmin {
        for (uint256 i = 0; i < _usersProxies.length; i++) {
            UserProxy memory userProxy = _usersProxies[i];
            require(hasTier2(userProxy.user), "PermissionManager: Address doesn't has Tier 2 assigned");
            require(hasTier2(userProxy.proxy), "PermissionManager: Proxy doesn't has Tier 2 assigned");

            PermissionItems(permissionItems).burn(userProxy.user, TIER_2_ID, 1);
            PermissionItems(permissionItems).burn(userProxy.proxy, TIER_2_ID, 1);
        }
    }

    function unsuspendUser(UserProxy[] memory _usersProxies) external onlyPermissionsAdmin {
        for (uint256 i = 0; i < _usersProxies.length; i++) {
            UserProxy memory userProxy = _usersProxies[i];
            require(isSuspended(userProxy.user), "PermissionManager: Address is not currently suspended");
            PermissionItems(permissionItems).burn(userProxy.user, SUSPENDED_ID, 1);

            if (userProxy.proxy != address(0)) {
                require(isSuspended(userProxy.proxy), "PermissionManager: Proxy is not currently suspended");
                PermissionItems(permissionItems).burn(userProxy.proxy, SUSPENDED_ID, 1);
            }
        }
    }

    function unrejectUser(UserProxy[] memory _usersProxies) external onlyPermissionsAdmin {
        for (uint256 i = 0; i < _usersProxies.length; i++) {
            UserProxy memory userProxy = _usersProxies[i];
            require(isRejected(userProxy.user), "PermissionManager: Address is not currently rejected");
            PermissionItems(permissionItems).burn(userProxy.user, REJECTED_ID, 1);

            if (userProxy.proxy != address(0)) {
                require(isRejected(userProxy.proxy), "PermissionManager: Proxy is not currently rejected");
                PermissionItems(permissionItems).burn(userProxy.proxy, REJECTED_ID, 1);
            }
        }
    }

    function assignItem(uint256 _itemId, address[] memory _accounts) external onlyPermissionsAdmin {
        for (uint256 i = 0; i < _accounts.length; i++) {
            require(!_hasItem(_accounts[i], _itemId), "PermissionManager: Account is assigned with item");
            PermissionItems(permissionItems).mint(_accounts[i], _itemId, 1, "");
        }
    }

    function removeItem(uint256 _itemId, address[] memory _accounts) external onlyPermissionsAdmin {
        for (uint256 i = 0; i < _accounts.length; i++) {
            require(_hasItem(_accounts[i], _itemId), "PermissionManager: Account is not assigned with item");
            PermissionItems(permissionItems).burn(_accounts[i], _itemId, 1);
        }
    }

    function _hasItem(address _user, uint256 itemId) internal view returns (bool) {
        return PermissionItems(permissionItems).balanceOf(_user, itemId) > 0;
    }

    function hasTier1(address _account) public view returns (bool) {
        return _hasItem(_account, TIER_1_ID);
    }

    function hasTier2(address _account) public view returns (bool) {
        return _hasItem(_account, TIER_2_ID);
    }

    function isSuspended(address _account) public view returns (bool) {
        return _hasItem(_account, SUSPENDED_ID);
    }

    function isRejected(address _account) public view returns (bool) {
        return _hasItem(_account, REJECTED_ID);
    }
}//GPL-3.0-only
pragma solidity ^0.7.0;

interface IdOTC {

    struct Offer {
        bool isNft;
        address maker;
        uint256 offerId;
        uint256[] nftIds; // list nft ids
        bool fullyTaken;
        uint256 amountIn; // offer amount
        uint256 offerFee;
        uint256 unitPrice;
        uint256 amountOut; // the amount to be receive by the maker
        address nftAddress;
        uint256 expiryTime;
        uint256 offerPrice;
        OfferType offerType; // can be PARTIAL or FULL
        uint256[] nftAmounts;
        address escrowAddress;
        address specialAddress; // makes the offer avaiable for one account.
        address tokenInAddress; // Token to exchange for another
        uint256 availableAmount; // available amount
        address tokenOutAddress; // Token to receive by the maker
    }

    struct Order {
        uint256 offerId;
        uint256 amountToSend; // the amount the taker sends to the maker
        address takerAddress;
        uint256 amountToReceive;
        uint256 minExpectedAmount; // the amount the taker is to recieve
    }

    enum OfferType { PARTIAL, FULL }

    function getOfferOwner(uint256 offerId) external view returns (address owner);

    function getOffer(uint256 offerId) external view returns (Offer memory offer);

    function getTaker(uint256 orderId) external view returns (address taker);

    function getTakerOrders(uint256 orderId) external view returns (Order memory order);
}// MIT

pragma solidity ^0.7.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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
}//GPL-3.0-only
pragma solidity ^0.7.0;

interface IEscrow {
    function setMakerDeposit(uint256 _offerId) external;

    function setNFTDeposit(uint256 _offerId) external;

    function withdrawDeposit(uint256 offerId, uint256 orderId) external;

    function withdrawNftDeposit(uint256 _nftOfferId, uint256 _nftOrderId) external;

    function freezeEscrow(address _account) external returns (bool);

    function setdOTCAddress(address _token) external returns (bool);

    function freezeOneDeposit(uint256 offerId, address _account) external returns (bool);

    function unFreezeOneDeposit(uint256 offerId, address _account) external returns (bool);

    function unFreezeEscrow(address _account) external returns (bool status);

    function cancelDeposit(
        uint256 offerId,
        address token,
        address maker,
        uint256 _amountToSend
    ) external returns (bool status);

    function cancelNftDeposit(uint256 nftOfferId) external;

    function removeOffer(uint256 offerId, address _account) external returns (bool status);

    function setNFTDOTCAddress(address _token) external returns (bool status);
}//GPL-3.0-only
pragma solidity ^0.7.0;


contract AdminFunctions is AccessControl {
    address internal escrow;
    uint256 public feeAmount = 3 * 10**24;
    uint256 public constant BPSNUMBER = 10**27;
    uint256 public constant DECIMAL = 18;
    address internal feeAddress;
    address internal tokenListManagerAddress;
    address internal permissionAddress;
    bytes32 public constant dOTC_Admin_ROLE = keccak256("dOTC_ADMIN_ROLE");
    bytes32 public constant ESCROW_MANAGER_ROLE = keccak256("ESCROW_MANAGER_ROLE");
    bytes32 public constant PERMISSION_SETTER_ROLE = keccak256("PERMISSION_SETTER_ROLE");
    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");

    function setdOTCAdmin(address _dOTCAdmin) external {
        grantRole(dOTC_Admin_ROLE, _dOTCAdmin);
    }

    function setEscrowAddress(address _address) public returns (bool status) {
        require(hasRole(ESCROW_MANAGER_ROLE, _msgSender()), "Not allowed");
        escrow = _address;
        return true;
    }

    function setEscrowLinker() external returns (bool status) {
        require(hasRole(ESCROW_MANAGER_ROLE, _msgSender()), "Not allowed");
        if (IEscrow(escrow).setdOTCAddress(address(this))) {
            return true;
        }
        return false;
    }

    function freezeEscrow() external isAdmin returns (bool status) {
        if (IEscrow(escrow).freezeEscrow(msg.sender)) {
            return true;
        }
        return false;
    }

    function unFreezeEscrow() external isAdmin returns (bool status) {
        if (IEscrow(escrow).unFreezeEscrow(msg.sender)) {
            return true;
        }
        return false;
    }

    function setTokenListManagerAddress(address _contractAddress) external isAdmin returns (bool status) {
        tokenListManagerAddress = _contractAddress;
        return true;
    }

    function setPermissionAddress(address _permissionAddress) external isAdmin returns (bool status) {
        require(hasRole(PERMISSION_SETTER_ROLE, _msgSender()), "account not permmited");
        permissionAddress = _permissionAddress;
        return true;
    }

    function setFeeAddress(address _newFeeAddress) external isAdmin returns (bool status) {
        require(hasRole(FEE_MANAGER_ROLE, _msgSender()), "account not permmited");
        feeAddress = _newFeeAddress;
        return true;
    }

    function setFeeAmount(uint256 _feeAmount) external isAdmin returns (bool status) {
        require(hasRole(FEE_MANAGER_ROLE, _msgSender()), "account not permmited");
        feeAmount = _feeAmount;
        return true;
    }

    modifier isAdmin() {
        require(hasRole(dOTC_Admin_ROLE, _msgSender()), "must have dOTC Admin role");
        _;
    }
}//GPL-3.0-only
pragma solidity ^0.7.0;


contract DOTCManager is IdOTC, AdminFunctions, ReentrancyGuard {
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _offerId;
    Counters.Counter private _takerOrdersId;

    mapping(uint256 => Order) internal takerOrders;
    mapping(uint256 => Offer) internal allOffers;
    mapping(address => Offer[]) internal offersFromAddress;
    mapping(address => Offer[]) internal takenOffersFromAddress;


    event CreatedOffer(
        uint256 indexed offerId,
        address indexed maker,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        OfferType offerType,
        address specialAddress,
        bool isComplete,
        uint256 expiryTime
    );
    event CreatedOrder(
        uint256 indexed offerId,
        uint256 indexed orderId,
        uint256 amountPaid,
        address indexed orderedBy,
        uint256 amountToReceive
    );
    event CompletedOffer(uint256 offerId);
    event CanceledOffer(uint256 indexed offerId, address canceledBy, uint256 amountToReceive);
    event freezeOffer(uint256 indexed offerId, address freezedBy);
    event unFreezeOffer(uint256 indexed offerId, address unFreezedBy);
    event AdminRemoveOffer(uint256 indexed offerId, address freezedBy);
    event TokenOfferUpdated(uint256 indexed offerId, uint256 newOffer);
    event UpdatedTokenOfferExpiry(uint256 indexed offerId, uint256 newExpiryTimestamp);
    event NftOfferUpdated(uint256 indexed offerId, uint256 newOffer);
    event UpdatedNftOfferExpiry(uint256 indexed offerId, uint256 newExpiryTimestamp);

    constructor(address _tokenListManagerAddress, address _permission) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        tokenListManagerAddress = _tokenListManagerAddress;
        permissionAddress = _permission;
    }

    function makeOffer(
        address _tokenInAddress,
        address _tokenOutAddress,
        uint256 _amountIn,
        uint256 _amountOut,
        uint256 _expiryTimestamp,
        uint8 _offerType,
        address _specialAddress
    )
        public
        allowedERC20Asset(_tokenInAddress)
        allowedERC20Asset(_tokenOutAddress)
        _accountIsTierTwo
        _accountSuspended
        nonReentrant
        returns (uint256 offerId)
    {
        require(IERC20(_tokenInAddress).balanceOf(msg.sender) >= (_amountIn), "Insufficient_balance");
        require(_expiryTimestamp > block.timestamp, "EXPIRATION_TIMESTAMP_HAS_PASSED");
        require(_tokenInAddress != _tokenOutAddress, "SAME_TOKEN");
        require(_offerType <= uint8(OfferType.FULL), "Out of range");
        require(_amountIn > 0, "ZERO_AMOUNTIN");
        require(_amountOut > 0, "ZERO_AMOUNTOUT");
        _offerId.increment();
        uint256 currentOfferId = _offerId.current();
        Offer memory _offer =
            setOffer(
                currentOfferId,
                _amountIn,
                _tokenInAddress,
                _tokenOutAddress,
                _amountOut,
                _expiryTimestamp,
                OfferType(_offerType),
                _specialAddress
            );
        offersFromAddress[msg.sender].push(_offer);
        allOffers[currentOfferId] = _offer;
        IEscrow(allOffers[currentOfferId].escrowAddress).setMakerDeposit(currentOfferId);
        safeTransfertokenIn(_tokenInAddress, _amountIn);
        emit CreatedOffer(
            currentOfferId,
            msg.sender,
            _tokenInAddress,
            _tokenOutAddress,
            _amountIn,
            _amountOut,
            OfferType(_offerType),
            _specialAddress,
            false,
            _offer.expiryTime
        );
        return currentOfferId;
    }

    function setOffer(
        uint256 _currentOfferId,
        uint256 _amountIn,
        address _tokenInAddress,
        address _tokenOutAddress,
        uint256 _amountOut,
        uint256 _expiryTimestamp,
        OfferType _offerType,
        address _specialAddress
    ) internal view returns (Offer memory offer) {
        uint256 sandaradAmountIn = standardiseNumber(_amountIn, _tokenInAddress);
        uint256 sandaradAmountOut = standardiseNumber(_amountOut, _tokenOutAddress);
        uint256[] memory emptyArray;
        Offer memory _offer =
            Offer({
                isNft: false,
                offerId: _currentOfferId,
                maker: msg.sender,
                tokenInAddress: _tokenInAddress,
                tokenOutAddress: _tokenOutAddress,
                amountIn: sandaradAmountIn,
                availableAmount: sandaradAmountIn,
                expiryTime: _expiryTimestamp,
                unitPrice: sandaradAmountOut.mul(10**DECIMAL).div(sandaradAmountIn),
                amountOut: sandaradAmountOut,
                fullyTaken: false,
                offerType: _offerType,
                specialAddress: address(_specialAddress),
                escrowAddress: escrow,
                offerFee: feeAmount,
                nftIds: emptyArray, // list nft ids
                nftAddress: address(0),
                offerPrice: 0,
                nftAmounts: emptyArray
            });
        return _offer;
    }

    function takeOffer(
        uint256 offerId,
        uint256 _amount,
        uint256 minExpectedAmount
    )
        public
        _accountIsTierTwo
        _accountSuspended
        isSpecial(offerId)
        isAvailable(offerId)
        can_buy(offerId)
        nonReentrant
        returns (uint256 takenOderId)
    {
        uint256 amountToReceiveByTaker = 0;
        uint256 standardAmount = standardiseNumber(_amount, allOffers[offerId].tokenOutAddress);
        require(_amount > 0, "ZERO_AMOUNT");
        require(standardAmount <= allOffers[offerId].amountOut, "AMOUNT_IS_TOO_BIG");
        require(IERC20(allOffers[offerId].tokenOutAddress).balanceOf(msg.sender) >= _amount, "Insufficient balance");

        if (allOffers[offerId].offerType == OfferType.FULL) {
            require(standardAmount == allOffers[offerId].amountOut, "FULL_REQUEST_REQUIRED");
            amountToReceiveByTaker = allOffers[offerId].amountIn;
            allOffers[offerId].amountOut = 0;
            allOffers[offerId].availableAmount = 0;
            allOffers[offerId].fullyTaken = true;
            emit CompletedOffer(offerId);
        } else {
            if (standardAmount == allOffers[offerId].amountOut) {
                amountToReceiveByTaker = allOffers[offerId].availableAmount;
                allOffers[offerId].amountOut = 0;
                allOffers[offerId].availableAmount = 0;
                allOffers[offerId].fullyTaken = true;
                emit CompletedOffer(offerId);
            } else {
                amountToReceiveByTaker = standardAmount.mul(10**DECIMAL).div(allOffers[offerId].unitPrice);
                allOffers[offerId].amountOut -= standardAmount;
                allOffers[offerId].availableAmount -= amountToReceiveByTaker;
            }
            if (allOffers[offerId].amountOut == 0 || allOffers[offerId].availableAmount == 0) {
                allOffers[offerId].fullyTaken = true;
                emit CompletedOffer(offerId);
            }
        }
        takenOffersFromAddress[msg.sender].push(allOffers[offerId]);
        _takerOrdersId.increment();
        uint256 orderId = _takerOrdersId.current();
        takerOrders[orderId] = Order(
            offerId,
            _amount,
            msg.sender,
            amountToReceiveByTaker,
            standardiseNumber(minExpectedAmount, allOffers[offerId].tokenInAddress)
        );
        uint256 amountFeeRatio = _amount.mul(allOffers[offerId].offerFee).div(BPSNUMBER);
        IEscrow(allOffers[offerId].escrowAddress).withdrawDeposit(offerId, orderId);
        payFee(allOffers[offerId].tokenOutAddress, amountFeeRatio);
        safeTransferAsset(
            allOffers[offerId].tokenOutAddress,
            allOffers[offerId].maker,
            msg.sender,
            (_amount.sub(amountFeeRatio))
        );
        uint256 realAmount = unstandardisedNumber(amountToReceiveByTaker, allOffers[offerId].tokenInAddress);
        emit CreatedOrder(offerId, orderId, _amount, msg.sender, realAmount);
        return orderId;
    }

    function cancelOffer(uint256 offerId) external can_cancel(offerId) nonReentrant returns (bool success) {
        Offer memory offer = allOffers[offerId];
        delete allOffers[offerId];
        uint256 _amountToSend = offer.availableAmount;
        uint256 realAmount = unstandardisedNumber(_amountToSend, offer.tokenInAddress);
        require(_amountToSend > 0, "CAN'T_CANCEL");
        require(
            IEscrow(offer.escrowAddress).cancelDeposit(offerId, offer.tokenInAddress, offer.maker, realAmount),
            "Escrow:CAN'T_CANCEL"
        );
        emit CanceledOffer(offerId, msg.sender, _amountToSend);
        return true;
    }

    function updateOffer(
        uint256 offerId,
        uint256 newOffer,
        uint256 _expiryTimestamp
    ) external returns (bool status) {
        require(newOffer > 0, "ZERO_NOT_ALLOWED");
        require(_expiryTimestamp > 0, "ZERO_NOT_ALLOWED");
        require(_expiryTimestamp > block.timestamp, "EXPIRATION_TIMESTAMP_HAS_PASSED");
        require(allOffers[offerId].maker == msg.sender, "NOT_OWNER");
        uint256 standardNewOfferOut = standardiseNumber(newOffer, allOffers[offerId].tokenOutAddress);
        if (standardNewOfferOut != allOffers[offerId].amountOut) {
            allOffers[offerId].amountOut = standardNewOfferOut;
            allOffers[offerId].unitPrice = standardiseNumber(newOffer, allOffers[offerId].tokenOutAddress)
                .mul(10**DECIMAL)
                .div(allOffers[offerId].availableAmount);
            emit TokenOfferUpdated(offerId, newOffer);
        }
        if (_expiryTimestamp != allOffers[offerId].expiryTime) {
            allOffers[offerId].expiryTime = _expiryTimestamp;
            emit UpdatedTokenOfferExpiry(offerId, _expiryTimestamp);
        }
        return true;
    }

    function getOfferOwner(uint256 offerId) external view override returns (address owner) {
        return allOffers[offerId].maker;
    }

    function getTaker(uint256 orderId) external view override returns (address taker) {
        return takerOrders[orderId].takerAddress;
    }

    function getOffer(uint256 offerId) external view override returns (Offer memory offer) {
        return allOffers[offerId];
    }

    function getTakerOrders(uint256 orderId) external view override returns (Order memory order) {
        return takerOrders[orderId];
    }

    function freezeXOffer(uint256 offerId) external isAdmin returns (bool hasfrozen) {
        if (IEscrow(escrow).freezeOneDeposit(offerId, msg.sender)) {
            emit freezeOffer(offerId, msg.sender);
            return true;
        }
        return false;
    }

    function adminRemoveOffer(uint256 offerId) external isAdmin returns (bool hasRemoved) {
        delete allOffers[offerId];
        if (IEscrow(escrow).removeOffer(offerId, msg.sender)) {
            emit AdminRemoveOffer(offerId, msg.sender);
            return true;
        }
        return false;
    }

    function unFreezeXOffer(uint256 offerId) external isAdmin returns (bool hasUnfrozen) {
        if (IEscrow(escrow).unFreezeOneDeposit(offerId, msg.sender)) {
            emit unFreezeOffer(offerId, msg.sender);
            return true;
        }
        return false;
    }

    function getOffersFromAddress(address account) external view returns (Offer[] memory) {
        return offersFromAddress[account];
    }

    function getTakenOffersFromAddress(address account) external view returns (Offer[] memory) {
        return takenOffersFromAddress[account];
    }

    function safeTransfertokenIn(address token, uint256 amount) internal {
        require(amount > 0, "Amount is 0");
        require(IERC20(token).transferFrom(msg.sender, escrow, amount), "Transfer failed");
    }

    function payFee(address token, uint256 amount) internal {
        require(amount > 0, "Amount is 0");
        require(IERC20(token).transferFrom(msg.sender, feeAddress, amount), "Transfer failed");
    }

    function safeTransferAsset(
        address erc20Token,
        address _to,
        address _from,
        uint256 _amount
    ) internal {
        require(IERC20(erc20Token).transferFrom(_from, _to, _amount), "Transfer failed");
    }

    function isActive(uint256 offerId) public view returns (bool active) {
        return allOffers[offerId].expiryTime > block.timestamp;
    }

    function isWrapperedERC20(address token) internal view returns (bool wrapped) {
        return TokenListManager(tokenListManagerAddress).allowedErc20tokens(token) != 0;
    }

    function standardiseNumber(uint256 amount, address _token) internal view returns (uint256) {
        uint8 decimal = ERC20(_token).decimals();
        return amount.mul(BPSNUMBER).div(10**decimal);
    }

    function unstandardisedNumber(uint256 _amount, address _token) internal view returns (uint256) {
        uint8 decimal = ERC20(_token).decimals();
        return _amount.mul(10**decimal).div(BPSNUMBER);
    }

    modifier allowedERC20Asset(address tokenAddress) {
        require(isWrapperedERC20(tokenAddress), "Asset not allowed");
        _;
    }

    modifier can_buy(uint256 offerId) {
        require(isActive(offerId), "IN_ACTIVE_OFFER");
        _;
    }

    modifier _accountIsTierTwo() {
        require(PermissionManager(permissionAddress).hasTier2(msg.sender), "NOT_ALLOWED_ON_THIS_PROTOCOL");
        _;
    }
    modifier _accountSuspended() {
        require(!PermissionManager(permissionAddress).isSuspended(msg.sender), "Account is suspended");
        _;
    }

    modifier can_cancel(uint256 id) {
        require(allOffers[id].maker == msg.sender, "CAN'T_CANCEL");
        _;
    }

    modifier isSpecial(uint256 offerId) {
        if (allOffers[offerId].specialAddress != address(0)) {
            require(allOffers[offerId].specialAddress == msg.sender, "CAN'T_TAKE_OFFER");
        }
        _;
    }

    modifier isAvailable(uint256 offerId) {
        require(allOffers[offerId].amountIn != 0, "Offer not found");
        _;
    }
}