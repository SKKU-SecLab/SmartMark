
pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return 18;
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(getRoleAdmin(role), _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address implementation, bytes32 salt, address deployer) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
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
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity ^0.8.0;


library Arrays {

    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {

        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
    }
}// MIT

pragma solidity ^0.8.0;

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
}// AGPL-3.0
pragma solidity 0.8.3;


interface IWETH is IERC20 {

  function deposit() external payable;


  function withdraw(uint256 wad) external;

}// AGPL-3.0
pragma solidity 0.8.3;


interface IRegistry is IAccessControl {

  function paused() external view returns (bool);


  function pause() external;


  function unpause() external;


  function tokenMinting() external view returns (bool);


  function denominator() external view returns (uint256);


  function weth() external view returns (IWETH);


  function authorized(bytes32 _role, address _account)
    external
    view
    returns (bool);


  function enableTokens() external;


  function disableTokens() external;


  function recycleDeadTokens(uint256 _tranches) external;

}// AGPL-3.0
pragma solidity 0.8.3;



library OLib {

  using Arrays for uint256[];
  using OLib for OLib.Investor;

  enum State {Inactive, Deposit, Live, Withdraw}

  enum Tranche {Senior, Junior}

  struct VaultParams {
    address seniorAsset;
    address juniorAsset;
    address strategist;
    address strategy;
    uint256 hurdleRate;
    uint256 startTime;
    uint256 enrollment;
    uint256 duration;
    string seniorName;
    string seniorSym;
    string juniorName;
    string juniorSym;
    uint256 seniorTrancheCap;
    uint256 seniorUserCap;
    uint256 juniorTrancheCap;
    uint256 juniorUserCap;
  }

  struct RolloverParams {
    VaultParams vault;
    address strategist;
    string seniorName;
    string seniorSym;
    string juniorName;
    string juniorSym;
  }

  bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");
  bytes32 public constant PANIC_ROLE = keccak256("PANIC_ROLE");
  bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
  bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
  bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
  bytes32 public constant STRATEGIST_ROLE = keccak256("STRATEGIST_ROLE");
  bytes32 public constant VAULT_ROLE = keccak256("VAULT_ROLE");
  bytes32 public constant ROLLOVER_ROLE = keccak256("ROLLOVER_ROLE");
  bytes32 public constant STRATEGY_ROLE = keccak256("STRATEGY_ROLE");


  struct Investor {
    uint256[] userSums;
    uint256[] prefixSums;
    bool claimed;
    bool withdrawn;
  }

  function getInvestedAndExcess(Investor storage investor, uint256 invested)
    internal
    view
    returns (uint256 userInvested, uint256 excess)
  {

    uint256[] storage prefixSums_ = investor.prefixSums;
    uint256 length = prefixSums_.length;
    if (length == 0) {
      return (userInvested, excess);
    }
    uint256 leastUpperBound = prefixSums_.findUpperBound(invested);
    if (length == leastUpperBound) {
      userInvested = investor.userSums[length - 1];
      return (userInvested, excess);
    }
    uint256 prefixSum = prefixSums_[leastUpperBound];
    if (prefixSum == invested) {
      userInvested = investor.userSums[leastUpperBound];
      excess = investor.userSums[length - 1] - userInvested;
    } else {
      userInvested = leastUpperBound > 0
        ? investor.userSums[leastUpperBound - 1]
        : 0;
      uint256 depositAmount = investor.userSums[leastUpperBound] - userInvested;
      if (prefixSum - depositAmount < invested) {
        userInvested += (depositAmount + invested - prefixSum);
        excess = investor.userSums[length - 1] - userInvested;
      } else {
        excess = investor.userSums[length - 1] - userInvested;
      }
    }
  }
}

library OndoSaferERC20 {

  using SafeERC20 for IERC20;

  function ondoSafeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {

    uint256 newAllowance = token.allowance(address(this), spender) + value;
    token.safeApprove(spender, 0);
    token.safeApprove(spender, newAllowance);
  }
}// AGPL-3.0
pragma solidity 0.8.3;


abstract contract OndoRegistryClientInitializable is
  Initializable,
  ReentrancyGuard,
  Pausable
{
  using SafeERC20 for IERC20;

  IRegistry public registry;
  uint256 public denominator;

  function __OndoRegistryClient__initialize(address _registry)
    internal
    initializer
  {
    require(_registry != address(0), "Invalid registry address");
    registry = IRegistry(_registry);
    denominator = registry.denominator();
  }

  modifier isAuthorized(bytes32 _role) {
    require(registry.authorized(_role, msg.sender), "Unauthorized");
    _;
  }

  function paused() public view virtual override returns (bool) {
    return registry.paused() || super.paused();
  }

  function pause() external virtual isAuthorized(OLib.PANIC_ROLE) {
    super._pause();
  }

  function unpause() external virtual isAuthorized(OLib.GUARDIAN_ROLE) {
    super._unpause();
  }

  function _rescueTokens(address[] calldata _tokens, uint256[] memory _amounts)
    internal
    virtual
  {
    for (uint256 i = 0; i < _tokens.length; i++) {
      uint256 amount = _amounts[i];
      if (amount == 0) {
        amount = IERC20(_tokens[i]).balanceOf(address(this));
      }
      IERC20(_tokens[i]).safeTransfer(msg.sender, amount);
    }
  }

  function rescueTokens(address[] calldata _tokens, uint256[] memory _amounts)
    public
    whenPaused
    isAuthorized(OLib.GUARDIAN_ROLE)
  {
    require(_tokens.length == _amounts.length, "Invalid array sizes");
    _rescueTokens(_tokens, _amounts);
  }
}// AGPL-3.0
pragma solidity 0.8.3;


abstract contract OndoRegistryClient is OndoRegistryClientInitializable {
  constructor(address _registry) {
    __OndoRegistryClient__initialize(_registry);
  }
}// AGPL-3.0
pragma solidity 0.8.3;


interface ITrancheToken is IERC20Upgradeable {

  function mint(address _account, uint256 _amount) external;


  function burn(address _account, uint256 _amount) external;


  function destroy(address payable _receiver) external;

}// AGPL-3.0
pragma solidity 0.8.3;


contract TrancheToken is ERC20Upgradeable, ITrancheToken, OwnableUpgradeable {

  OndoRegistryClientInitializable public vault;
  uint256 public vaultId;

  modifier whenNotPaused {

    require(!vault.paused(), "Global pause in effect");
    _;
  }

  modifier onlyRegistry {

    require(
      address(vault.registry()) == msg.sender,
      "Invalid access: Only Registry can call"
    );
    _;
  }

  function initialize(
    uint256 _vaultId,
    string calldata _name,
    string calldata _symbol,
    address _vault
  ) external initializer {

    __Ownable_init();
    __ERC20_init(_name, _symbol);
    vault = OndoRegistryClientInitializable(_vault);
    vaultId = _vaultId;
  }

  function mint(address _account, uint256 _amount)
    external
    override
    whenNotPaused
    onlyOwner
  {

    _mint(_account, _amount);
  }

  function burn(address _account, uint256 _amount)
    external
    override
    whenNotPaused
    onlyOwner
  {

    _burn(_account, _amount);
  }

  function transfer(address _account, uint256 _amount)
    public
    override(ERC20Upgradeable, IERC20Upgradeable)
    whenNotPaused
    returns (bool)
  {

    return super.transfer(_account, _amount);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _amount
  )
    public
    override(ERC20Upgradeable, IERC20Upgradeable)
    whenNotPaused
    returns (bool)
  {

    return super.transferFrom(_from, _to, _amount);
  }

  function approve(address _account, uint256 _amount)
    public
    override(ERC20Upgradeable, IERC20Upgradeable)
    whenNotPaused
    returns (bool)
  {

    return super.approve(_account, _amount);
  }

  function destroy(address payable _receiver)
    external
    override
    whenNotPaused
    onlyRegistry
  {

    selfdestruct(_receiver);
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    override(ERC20Upgradeable)
    whenNotPaused
    returns (bool)
  {

    return super.increaseAllowance(spender, addedValue);
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    override(ERC20Upgradeable)
    whenNotPaused
    returns (bool)
  {

    return super.decreaseAllowance(spender, subtractedValue);
  }
}// AGPL-3.0
pragma solidity 0.8.3;


interface IPairVault {

  struct VaultView {
    uint256 id;
    Asset[] assets;
    IStrategy strategy; // Shared contract that interacts with AMMs
    address creator; // Account that calls createVault
    address strategist; // Has the right to call invest() and redeem(), and harvest() if strategy supports it
    address rollover;
    uint256 hurdleRate; // Return offered to senior tranche
    OLib.State state; // Current state of Vault
    uint256 startAt; // Time when the Vault is unpaused to begin accepting deposits
    uint256 investAt; // Time when investors can't move funds, strategist can invest
    uint256 redeemAt; // Time when strategist can redeem LP tokens, investors can withdraw
  }

  struct Asset {
    IERC20 token;
    ITrancheToken trancheToken;
    uint256 trancheCap;
    uint256 userCap;
    uint256 deposited;
    uint256 originalInvested;
    uint256 totalInvested; // not literal 1:1, originalInvested + proportional lp from mid-term
    uint256 received;
    uint256 rolloverDeposited;
  }

  function getState(uint256 _vaultId) external view returns (OLib.State);


  function createVault(OLib.VaultParams calldata _params)
    external
    returns (uint256 vaultId);


  function deposit(
    uint256 _vaultId,
    OLib.Tranche _tranche,
    uint256 _amount
  ) external;


  function depositETH(uint256 _vaultId, OLib.Tranche _tranche) external payable;


  function depositLp(uint256 _vaultId, uint256 _amount)
    external
    returns (uint256 seniorTokensOwed, uint256 juniorTokensOwed);


  function invest(
    uint256 _vaultId,
    uint256 _seniorMinOut,
    uint256 _juniorMinOut
  ) external returns (uint256, uint256);


  function redeem(
    uint256 _vaultId,
    uint256 _seniorMinOut,
    uint256 _juniorMinOut
  ) external returns (uint256, uint256);


  function withdraw(uint256 _vaultId, OLib.Tranche _tranche)
    external
    returns (uint256);


  function withdrawETH(uint256 _vaultId, OLib.Tranche _tranche)
    external
    returns (uint256);


  function withdrawLp(uint256 _vaultId, uint256 _amount)
    external
    returns (uint256, uint256);


  function claim(uint256 _vaultId, OLib.Tranche _tranche)
    external
    returns (uint256, uint256);


  function claimETH(uint256 _vaultId, OLib.Tranche _tranche)
    external
    returns (uint256, uint256);


  function depositFromRollover(
    uint256 _vaultId,
    uint256 _rolloverId,
    uint256 _seniorAmount,
    uint256 _juniorAmount
  ) external;


  function rolloverClaim(uint256 _vaultId, uint256 _rolloverId)
    external
    returns (uint256, uint256);


  function setRollover(
    uint256 _vaultId,
    address _rollover,
    uint256 _rolloverId
  ) external;


  function canDeposit(uint256 _vaultId) external view returns (bool);



  function getVaultById(uint256 _vaultId)
    external
    view
    returns (VaultView memory);


  function vaultInvestor(uint256 _vaultId, OLib.Tranche _tranche)
    external
    view
    returns (
      uint256 position,
      uint256 claimableBalance,
      uint256 withdrawableExcess,
      uint256 withdrawableBalance
    );


  function seniorExpected(uint256 _vaultId) external view returns (uint256);

}// AGPL-3.0
pragma solidity 0.8.3;


interface IStrategy {

  struct Vault {
    IPairVault origin; // who created this Vault
    IERC20 pool; // the DEX pool
    IERC20 senior; // senior asset in pool
    IERC20 junior; // junior asset in pool
    uint256 shares; // number of shares for ETF-style mid-duration entry/exit
    uint256 seniorExcess; // unused senior deposits
    uint256 juniorExcess; // unused junior deposits
  }

  function vaults(uint256 vaultId)
    external
    view
    returns (
      IPairVault origin,
      IERC20 pool,
      IERC20 senior,
      IERC20 junior,
      uint256 shares,
      uint256 seniorExcess,
      uint256 juniorExcess
    );


  function addVault(
    uint256 _vaultId,
    IERC20 _senior,
    IERC20 _junior
  ) external;


  function addLp(uint256 _vaultId, uint256 _lpTokens) external;


  function removeLp(
    uint256 _vaultId,
    uint256 _shares,
    address to
  ) external;


  function getVaultInfo(uint256 _vaultId)
    external
    view
    returns (IERC20, uint256);


  function invest(
    uint256 _vaultId,
    uint256 _totalSenior,
    uint256 _totalJunior,
    uint256 _extraSenior,
    uint256 _extraJunior,
    uint256 _seniorMinOut,
    uint256 _juniorMinOut
  ) external returns (uint256 seniorInvested, uint256 juniorInvested);


  function sharesFromLp(uint256 vaultId, uint256 lpTokens)
    external
    view
    returns (
      uint256 shares,
      uint256 vaultShares,
      IERC20 pool
    );


  function lpFromShares(uint256 vaultId, uint256 shares)
    external
    view
    returns (uint256 lpTokens, uint256 vaultShares);


  function redeem(
    uint256 _vaultId,
    uint256 _seniorExpected,
    uint256 _seniorMinOut,
    uint256 _juniorMinOut
  ) external returns (uint256, uint256);


  function withdrawExcess(
    uint256 _vaultId,
    OLib.Tranche tranche,
    address to,
    uint256 amount
  ) external;

}// AGPL-3.0
pragma solidity 0.8.3;


interface IFeeCollector {

  function processFee(
    uint256 vaultId,
    IERC20 token,
    uint256 feeSent
  ) external;

}// AGPL-3.0
pragma solidity 0.8.3;


contract AllPairVault is OndoRegistryClient, IPairVault {

  using OLib for OLib.Investor;
  using SafeERC20 for IERC20;
  using Address for address;
  using EnumerableSet for EnumerableSet.UintSet;

  struct Vault {
    mapping(OLib.Tranche => Asset) assets; // Assets corresponding to each tranche
    IStrategy strategy; // Shared contract that interacts with AMMs
    address creator; // Account that calls createVault
    address strategist; // Has the right to call invest() and redeem(), and harvest() if strategy supports it
    address rollover; // Manager of investment auto-rollover, if any
    uint256 rolloverId;
    uint256 hurdleRate; // Return offered to senior tranche
    OLib.State state; // Current state of Vault
    uint256 startAt; // Time when the Vault is unpaused to begin accepting deposits
    uint256 investAt; // Time when investors can't move funds, strategist can invest
    uint256 redeemAt; // Time when strategist can redeem LP tokens, investors can withdraw
    uint256 performanceFee; // Optional fee on junior tranche goes to strategist
  }

  mapping(address => mapping(address => OLib.Investor)) investors;

  address public immutable trancheTokenImpl;

  IFeeCollector public performanceFeeCollector;

  mapping(uint256 => Vault) private Vaults;

  mapping(address => uint256) public VaultsByTokens;

  EnumerableSet.UintSet private vaultIDs;

  modifier onlyStrategist(uint256 _vaultId) {

    require(msg.sender == Vaults[_vaultId].strategist, "Invalid caller");
    _;
  }

  modifier onlyRollover(uint256 _vaultId, uint256 _rolloverId) {

    Vault storage vault_ = Vaults[_vaultId];
    require(
      msg.sender == vault_.rollover && _rolloverId == vault_.rolloverId,
      "Invalid caller"
    );
    _;
  }

  modifier onlyRolloverOrStrategist(uint256 _vaultId) {

    Vault storage vault_ = Vaults[_vaultId];
    address rollover = vault_.rollover;
    require(
      (rollover == address(0) && msg.sender == vault_.strategist) ||
        (msg.sender == rollover),
      "Invalid caller"
    );
    _;
  }

  modifier atState(uint256 _vaultId, OLib.State _state) {

    require(getState(_vaultId) == _state, "Invalid operation");
    _;
  }

  function transition(uint256 _vaultId, OLib.State _nextState) private {

    Vault storage vault_ = Vaults[_vaultId];
    OLib.State curState = vault_.state;
    if (_nextState == OLib.State.Live) {
      require(curState == OLib.State.Deposit, "Invalid operation");
      require(vault_.investAt <= block.timestamp, "Not time yet");
    } else {
      require(
        curState == OLib.State.Live && _nextState == OLib.State.Withdraw,
        "Invalid operation"
      );
      require(vault_.redeemAt <= block.timestamp, "Not time yet");
    }
    vault_.state = _nextState;
  }

  function maybeOpenDeposit(uint256 _vaultId) private {

    Vault storage vault_ = Vaults[_vaultId];
    if (vault_.state == OLib.State.Inactive) {
      require(
        vault_.startAt > 0 && vault_.startAt <= block.timestamp,
        "Not time yet"
      );
      vault_.state = OLib.State.Deposit;
    } else if (vault_.state != OLib.State.Deposit) {
      revert("Invalid operation");
    }
  }


  function onlyETH(uint256 _vaultId, OLib.Tranche _tranche) private view {

    require(
      address((getVaultById(_vaultId)).assets[uint256(_tranche)].token) ==
        address(registry.weth()),
      "Not an ETH vault"
    );
  }

  event CreatedPair(
    uint256 indexed vaultId,
    IERC20 indexed seniorAsset,
    IERC20 indexed juniorAsset,
    ITrancheToken seniorToken,
    ITrancheToken juniorToken
  );

  event SetRollover(
    address indexed rollover,
    uint256 indexed rolloverId,
    uint256 indexed vaultId
  );

  event Deposited(
    address indexed depositor,
    uint256 indexed vaultId,
    uint256 indexed trancheId,
    uint256 amount
  );

  event Invested(
    uint256 indexed vaultId,
    uint256 seniorAmount,
    uint256 juniorAmount
  );

  event DepositedLP(
    address indexed depositor,
    uint256 indexed vaultId,
    uint256 amount,
    uint256 senior,
    uint256 junior
  );

  event RolloverDeposited(
    address indexed rollover,
    uint256 indexed rolloverId,
    uint256 indexed vaultId,
    uint256 seniorAmount,
    uint256 juniorAmount
  );

  event Claimed(
    address indexed depositor,
    uint256 indexed vaultId,
    uint256 indexed trancheId,
    uint256 shares,
    uint256 excess
  );

  event RolloverClaimed(
    address indexed rollover,
    uint256 indexed rolloverId,
    uint256 indexed vaultId,
    uint256 seniorAmount,
    uint256 juniorAmount
  );

  event Redeemed(
    uint256 indexed vaultId,
    uint256 seniorReceived,
    uint256 juniorReceived
  );

  event Withdrew(
    address indexed depositor,
    uint256 indexed vaultId,
    uint256 indexed trancheId,
    uint256 amount
  );

  event WithdrewLP(address indexed depositor, uint256 amount);



  constructor(address _registry, address _trancheTokenImpl)
    OndoRegistryClient(_registry)
  {
    require(_trancheTokenImpl != address(0), "Invalid target");
    trancheTokenImpl = _trancheTokenImpl;
  }

  function createVault(OLib.VaultParams calldata _params)
    external
    override
    whenNotPaused
    isAuthorized(OLib.CREATOR_ROLE)
    nonReentrant
    returns (uint256 vaultId)
  {

    require(
      registry.authorized(OLib.STRATEGY_ROLE, _params.strategy),
      "Invalid target"
    );
    require(
      registry.authorized(OLib.STRATEGIST_ROLE, _params.strategist),
      "Invalid target"
    );
    require(_params.startTime >= block.timestamp, "Invalid start time");
    require(
      _params.enrollment > 0 && _params.duration > 0,
      "No zero intervals"
    );
    require(_params.hurdleRate < 1e8, "Maximum hurdle is 10000%");
    require(denominator <= _params.hurdleRate, "Min hurdle is 100%");

    require(
      _params.seniorAsset != address(0) &&
        _params.seniorAsset != address(this) &&
        _params.juniorAsset != address(0) &&
        _params.juniorAsset != address(this),
      "Invalid target"
    );
    uint256 investAtTime = _params.startTime + _params.enrollment;
    uint256 redeemAtTime = investAtTime + _params.duration;
    TrancheToken seniorITrancheToken;
    TrancheToken juniorITrancheToken;
    {
      vaultId = uint256(
        keccak256(
          abi.encode(
            _params.seniorAsset,
            _params.juniorAsset,
            _params.strategy,
            _params.hurdleRate,
            _params.startTime,
            investAtTime,
            redeemAtTime
          )
        )
      );
      vaultIDs.add(vaultId);
      Vault storage vault_ = Vaults[vaultId];
      require(address(vault_.strategist) == address(0), "Duplicate");
      vault_.strategy = IStrategy(_params.strategy);
      vault_.creator = msg.sender;
      vault_.strategist = _params.strategist;
      vault_.hurdleRate = _params.hurdleRate;
      vault_.startAt = _params.startTime;
      vault_.investAt = investAtTime;
      vault_.redeemAt = redeemAtTime;

      registry.recycleDeadTokens(2);

      seniorITrancheToken = TrancheToken(
        Clones.cloneDeterministic(
          trancheTokenImpl,
          keccak256(abi.encodePacked(uint256(0), vaultId))
        )
      );
      juniorITrancheToken = TrancheToken(
        Clones.cloneDeterministic(
          trancheTokenImpl,
          keccak256(abi.encodePacked(uint256(1), vaultId))
        )
      );
      vault_.assets[OLib.Tranche.Senior].token = IERC20(_params.seniorAsset);
      vault_.assets[OLib.Tranche.Junior].token = IERC20(_params.juniorAsset);
      vault_.assets[OLib.Tranche.Senior].trancheToken = seniorITrancheToken;
      vault_.assets[OLib.Tranche.Junior].trancheToken = juniorITrancheToken;

      vault_.assets[OLib.Tranche.Senior].trancheCap = _params.seniorTrancheCap;
      vault_.assets[OLib.Tranche.Senior].userCap = _params.seniorUserCap;
      vault_.assets[OLib.Tranche.Junior].trancheCap = _params.juniorTrancheCap;
      vault_.assets[OLib.Tranche.Junior].userCap = _params.juniorUserCap;

      VaultsByTokens[address(seniorITrancheToken)] = vaultId;
      VaultsByTokens[address(juniorITrancheToken)] = vaultId;
      if (vault_.startAt == block.timestamp) {
        vault_.state = OLib.State.Deposit;
      }

      IStrategy(_params.strategy).addVault(
        vaultId,
        IERC20(_params.seniorAsset),
        IERC20(_params.juniorAsset)
      );

      seniorITrancheToken.initialize(
        vaultId,
        _params.seniorName,
        _params.seniorSym,
        address(this)
      );
      juniorITrancheToken.initialize(
        vaultId,
        _params.juniorName,
        _params.juniorSym,
        address(this)
      );
    }

    emit CreatedPair(
      vaultId,
      IERC20(_params.seniorAsset),
      IERC20(_params.juniorAsset),
      seniorITrancheToken,
      juniorITrancheToken
    );
  }

  function setRollover(
    uint256 _vaultId,
    address _rollover,
    uint256 _rolloverId
  ) external override isAuthorized(OLib.ROLLOVER_ROLE) {

    Vault storage vault_ = Vaults[_vaultId];
    if (vault_.rollover != address(0)) {
      require(
        msg.sender == vault_.rollover && _rolloverId == vault_.rolloverId,
        "Invalid caller"
      );
    }
    vault_.rollover = _rollover;
    vault_.rolloverId = _rolloverId;
    emit SetRollover(_rollover, _rolloverId, _vaultId);
  }

  function depositCapGuard(uint256 _allowedAmount, uint256 _amount)
    internal
    pure
  {

    require(
      _allowedAmount == 0 || _amount <= _allowedAmount,
      "Exceeds user cap"
    );
  }

  function _deposit(
    uint256 _vaultId,
    OLib.Tranche _tranche,
    uint256 _amount,
    address _payer
  ) internal whenNotPaused {

    maybeOpenDeposit(_vaultId);
    Vault storage vault_ = Vaults[_vaultId];
    vault_.assets[_tranche].token.safeTransferFrom(
      _payer,
      address(vault_.strategy),
      _amount
    );
    uint256 _total = vault_.assets[_tranche].deposited += _amount;
    OLib.Investor storage _investor =
      investors[address(vault_.assets[_tranche].trancheToken)][msg.sender];
    uint256 userSum =
      _investor.userSums.length > 0
        ? _investor.userSums[_investor.userSums.length - 1] + _amount
        : _amount;
    depositCapGuard(vault_.assets[_tranche].userCap, userSum);
    _investor.prefixSums.push(_total);
    _investor.userSums.push(userSum);
    emit Deposited(msg.sender, _vaultId, uint256(_tranche), _amount);
  }

  function deposit(
    uint256 _vaultId,
    OLib.Tranche _tranche,
    uint256 _amount
  ) external override nonReentrant {

    _deposit(_vaultId, _tranche, _amount, msg.sender);
  }

  function depositETH(uint256 _vaultId, OLib.Tranche _tranche)
    external
    payable
    override
    nonReentrant
  {

    onlyETH(_vaultId, _tranche);
    registry.weth().deposit{value: msg.value}();
    _deposit(_vaultId, _tranche, msg.value, address(this));
  }

  function depositFromRollover(
    uint256 _vaultId,
    uint256 _rolloverId,
    uint256 _seniorAmount,
    uint256 _juniorAmount
  )
    external
    override
    onlyRollover(_vaultId, _rolloverId)
    whenNotPaused
    nonReentrant
  {

    maybeOpenDeposit(_vaultId);
    Vault storage vault_ = Vaults[_vaultId];
    Asset storage senior_ = vault_.assets[OLib.Tranche.Senior];
    Asset storage junior_ = vault_.assets[OLib.Tranche.Junior];
    senior_.deposited += _seniorAmount;
    junior_.deposited += _juniorAmount;
    senior_.rolloverDeposited += _seniorAmount;
    junior_.rolloverDeposited += _juniorAmount;
    senior_.token.safeTransferFrom(
      msg.sender,
      address(vault_.strategy),
      _seniorAmount
    );
    junior_.token.safeTransferFrom(
      msg.sender,
      address(vault_.strategy),
      _juniorAmount
    );
    emit RolloverDeposited(
      msg.sender,
      _rolloverId,
      _vaultId,
      _seniorAmount,
      _juniorAmount
    );
  }

  function depositLp(uint256 _vaultId, uint256 _lpTokens)
    external
    override
    whenNotPaused
    nonReentrant
    atState(_vaultId, OLib.State.Live)
    returns (uint256 seniorTokensOwed, uint256 juniorTokensOwed)
  {

    require(registry.tokenMinting(), "Vault tokens inactive");
    Vault storage vault_ = Vaults[_vaultId];
    IERC20 pool;
    (seniorTokensOwed, juniorTokensOwed, pool) = getDepositLp(
      _vaultId,
      _lpTokens
    );

    depositCapGuard(
      vault_.assets[OLib.Tranche.Senior].userCap,
      seniorTokensOwed
    );
    depositCapGuard(
      vault_.assets[OLib.Tranche.Junior].userCap,
      juniorTokensOwed
    );

    vault_.assets[OLib.Tranche.Senior].totalInvested += seniorTokensOwed;
    vault_.assets[OLib.Tranche.Junior].totalInvested += juniorTokensOwed;
    vault_.assets[OLib.Tranche.Senior].trancheToken.mint(
      msg.sender,
      seniorTokensOwed
    );
    vault_.assets[OLib.Tranche.Junior].trancheToken.mint(
      msg.sender,
      juniorTokensOwed
    );

    pool.safeTransferFrom(msg.sender, address(vault_.strategy), _lpTokens);
    vault_.strategy.addLp(_vaultId, _lpTokens);
    emit DepositedLP(
      msg.sender,
      _vaultId,
      _lpTokens,
      seniorTokensOwed,
      juniorTokensOwed
    );
  }

  function getDepositLp(uint256 _vaultId, uint256 _lpTokens)
    public
    view
    atState(_vaultId, OLib.State.Live)
    returns (
      uint256 seniorTokensOwed,
      uint256 juniorTokensOwed,
      IERC20 pool
    )
  {

    Vault storage vault_ = Vaults[_vaultId];
    (uint256 shares, uint256 vaultShares, IERC20 ammPool) =
      vault_.strategy.sharesFromLp(_vaultId, _lpTokens);
    seniorTokensOwed =
      (vault_.assets[OLib.Tranche.Senior].totalInvested * shares) /
      vaultShares;
    juniorTokensOwed =
      (vault_.assets[OLib.Tranche.Junior].totalInvested * shares) /
      vaultShares;
    pool = ammPool;
  }

  function invest(
    uint256 _vaultId,
    uint256 _seniorMinIn,
    uint256 _juniorMinIn
  )
    external
    override
    whenNotPaused
    nonReentrant
    onlyRolloverOrStrategist(_vaultId)
    returns (uint256, uint256)
  {

    transition(_vaultId, OLib.State.Live);
    Vault storage vault_ = Vaults[_vaultId];
    investIntoStrategy(vault_, _vaultId, _seniorMinIn, _juniorMinIn);
    Asset storage senior_ = vault_.assets[OLib.Tranche.Senior];
    Asset storage junior_ = vault_.assets[OLib.Tranche.Junior];
    senior_.totalInvested = vault_.assets[OLib.Tranche.Senior].originalInvested;
    junior_.totalInvested = vault_.assets[OLib.Tranche.Junior].originalInvested;
    emit Invested(_vaultId, senior_.totalInvested, junior_.totalInvested);
    return (senior_.totalInvested, junior_.totalInvested);
  }

  function investIntoStrategy(
    Vault storage vault_,
    uint256 _vaultId,
    uint256 _seniorMinIn,
    uint256 _juniorMinIn
  ) private {

    uint256 seniorInvestableAmount =
      vault_.assets[OLib.Tranche.Senior].deposited;
    uint256 seniorCappedAmount = seniorInvestableAmount;
    if (vault_.assets[OLib.Tranche.Senior].trancheCap > 0) {
      seniorCappedAmount = min(
        seniorInvestableAmount,
        vault_.assets[OLib.Tranche.Senior].trancheCap
      );
    }
    uint256 juniorInvestableAmount =
      vault_.assets[OLib.Tranche.Junior].deposited;
    uint256 juniorCappedAmount = juniorInvestableAmount;
    if (vault_.assets[OLib.Tranche.Junior].trancheCap > 0) {
      juniorCappedAmount = min(
        juniorInvestableAmount,
        vault_.assets[OLib.Tranche.Junior].trancheCap
      );
    }

    (
      vault_.assets[OLib.Tranche.Senior].originalInvested,
      vault_.assets[OLib.Tranche.Junior].originalInvested
    ) = vault_.strategy.invest(
      _vaultId,
      seniorCappedAmount,
      juniorCappedAmount,
      seniorInvestableAmount - seniorCappedAmount,
      juniorInvestableAmount - juniorCappedAmount,
      _seniorMinIn,
      _juniorMinIn
    );
  }

  function _claim(
    uint256 _vaultId,
    OLib.Tranche _tranche,
    address _receiver
  )
    internal
    whenNotPaused
    atState(_vaultId, OLib.State.Live)
    returns (uint256 userInvested, uint256 excess)
  {

    Vault storage vault_ = Vaults[_vaultId];
    Asset storage _asset = vault_.assets[_tranche];
    ITrancheToken _trancheToken = _asset.trancheToken;
    OLib.Investor storage investor =
      investors[address(_trancheToken)][msg.sender];
    require(!investor.claimed, "Already claimed");
    IStrategy _strategy = vault_.strategy;
    (userInvested, excess) = investor.getInvestedAndExcess(
      _getNetOriginalInvested(_asset)
    );
    if (excess > 0)
      _strategy.withdrawExcess(_vaultId, _tranche, _receiver, excess);
    if (registry.tokenMinting()) {
      _trancheToken.mint(msg.sender, userInvested);
    }

    investor.claimed = true;
    emit Claimed(msg.sender, _vaultId, uint256(_tranche), userInvested, excess);
    return (userInvested, excess);
  }

  function claim(uint256 _vaultId, OLib.Tranche _tranche)
    external
    override
    nonReentrant
    returns (uint256, uint256)
  {

    return _claim(_vaultId, _tranche, msg.sender);
  }

  function claimETH(uint256 _vaultId, OLib.Tranche _tranche)
    external
    override
    nonReentrant
    returns (uint256 invested, uint256 excess)
  {

    onlyETH(_vaultId, _tranche);
    (invested, excess) = _claim(_vaultId, _tranche, address(this));
    registry.weth().withdraw(excess);
    safeTransferETH(msg.sender, excess);
  }

  function rolloverClaim(uint256 _vaultId, uint256 _rolloverId)
    external
    override
    whenNotPaused
    nonReentrant
    atState(_vaultId, OLib.State.Live)
    onlyRollover(_vaultId, _rolloverId)
    returns (uint256 srRollInv, uint256 jrRollInv)
  {

    Vault storage vault_ = Vaults[_vaultId];
    Asset storage senior_ = vault_.assets[OLib.Tranche.Senior];
    Asset storage junior_ = vault_.assets[OLib.Tranche.Junior];
    OLib.Investor storage investor =
      investors[address(senior_.trancheToken)][msg.sender];
    require(!investor.claimed, "Already claimed");
    srRollInv = _getRolloverInvested(senior_);
    jrRollInv = _getRolloverInvested(junior_);
    if (srRollInv > 0) {
      senior_.trancheToken.mint(msg.sender, srRollInv);
    }
    if (jrRollInv > 0) {
      junior_.trancheToken.mint(msg.sender, jrRollInv);
    }
    if (senior_.rolloverDeposited > srRollInv) {
      vault_.strategy.withdrawExcess(
        _vaultId,
        OLib.Tranche.Senior,
        msg.sender,
        senior_.rolloverDeposited - srRollInv
      );
    }
    if (junior_.rolloverDeposited > jrRollInv) {
      vault_.strategy.withdrawExcess(
        _vaultId,
        OLib.Tranche.Junior,
        msg.sender,
        junior_.rolloverDeposited - jrRollInv
      );
    }
    investor.claimed = true;
    emit RolloverClaimed(
      msg.sender,
      _rolloverId,
      _vaultId,
      srRollInv,
      jrRollInv
    );
    return (srRollInv, jrRollInv);
  }

  function redeem(
    uint256 _vaultId,
    uint256 _seniorMinReceived,
    uint256 _juniorMinReceived
  )
    external
    override
    whenNotPaused
    nonReentrant
    onlyRolloverOrStrategist(_vaultId)
    returns (uint256, uint256)
  {

    transition(_vaultId, OLib.State.Withdraw);
    Vault storage vault_ = Vaults[_vaultId];
    Asset storage senior_ = vault_.assets[OLib.Tranche.Senior];
    Asset storage junior_ = vault_.assets[OLib.Tranche.Junior];
    (senior_.received, junior_.received) = vault_.strategy.redeem(
      _vaultId,
      _getSeniorExpected(vault_, senior_),
      _seniorMinReceived,
      _juniorMinReceived
    );
    junior_.received -= takePerformanceFee(vault_, _vaultId);

    emit Redeemed(_vaultId, senior_.received, junior_.received);
    return (senior_.received, junior_.received);
  }

  function _withdraw(
    uint256 _vaultId,
    OLib.Tranche _tranche,
    address _receiver
  )
    internal
    whenNotPaused
    atState(_vaultId, OLib.State.Withdraw)
    returns (uint256 tokensToWithdraw)
  {

    Vault storage vault_ = Vaults[_vaultId];
    Asset storage asset_ = vault_.assets[_tranche];
    (, , , tokensToWithdraw) = vaultInvestor(_vaultId, _tranche);
    ITrancheToken token_ = asset_.trancheToken;
    if (registry.tokenMinting()) {
      uint256 bal = token_.balanceOf(msg.sender);
      if (bal > 0) {
        token_.burn(msg.sender, bal);
      }
    }
    asset_.token.safeTransferFrom(
      address(vault_.strategy),
      _receiver,
      tokensToWithdraw
    );
    investors[address(asset_.trancheToken)][msg.sender].withdrawn = true;
    emit Withdrew(msg.sender, _vaultId, uint256(_tranche), tokensToWithdraw);
    return tokensToWithdraw;
  }

  function withdraw(uint256 _vaultId, OLib.Tranche _tranche)
    external
    override
    nonReentrant
    returns (uint256)
  {

    return _withdraw(_vaultId, _tranche, msg.sender);
  }

  function withdrawETH(uint256 _vaultId, OLib.Tranche _tranche)
    external
    override
    nonReentrant
    returns (uint256 amount)
  {

    onlyETH(_vaultId, _tranche);
    amount = _withdraw(_vaultId, _tranche, address(this));
    registry.weth().withdraw(amount);
    safeTransferETH(msg.sender, amount);
  }

  receive() external payable {
    assert(msg.sender == address(registry.weth()));
  }

  function withdrawLp(uint256 _vaultId, uint256 _shares)
    external
    override
    whenNotPaused
    nonReentrant
    atState(_vaultId, OLib.State.Live)
    returns (uint256 seniorTokensNeeded, uint256 juniorTokensNeeded)
  {

    require(registry.tokenMinting(), "Vault tokens inactive");
    Vault storage vault_ = Vaults[_vaultId];
    (seniorTokensNeeded, juniorTokensNeeded) = getWithdrawLp(_vaultId, _shares);
    vault_.assets[OLib.Tranche.Senior].trancheToken.burn(
      msg.sender,
      seniorTokensNeeded
    );
    vault_.assets[OLib.Tranche.Junior].trancheToken.burn(
      msg.sender,
      juniorTokensNeeded
    );
    vault_.assets[OLib.Tranche.Senior].totalInvested -= seniorTokensNeeded;
    vault_.assets[OLib.Tranche.Junior].totalInvested -= juniorTokensNeeded;
    vault_.strategy.removeLp(_vaultId, _shares, msg.sender);
    emit WithdrewLP(msg.sender, _shares);
  }

  function getWithdrawLp(uint256 _vaultId, uint256 _shares)
    public
    view
    atState(_vaultId, OLib.State.Live)
    returns (uint256 seniorTokensNeeded, uint256 juniorTokensNeeded)
  {

    Vault storage vault_ = Vaults[_vaultId];
    (, uint256 totalShares) = vault_.strategy.getVaultInfo(_vaultId);
    seniorTokensNeeded =
      (vault_.assets[OLib.Tranche.Senior].totalInvested * _shares) /
      totalShares;
    juniorTokensNeeded =
      (vault_.assets[OLib.Tranche.Junior].totalInvested * _shares) /
      totalShares;
  }

  function getState(uint256 _vaultId)
    public
    view
    override
    returns (OLib.State)
  {

    Vault storage vault_ = Vaults[_vaultId];
    return vault_.state;
  }


  function takePerformanceFee(Vault storage vault, uint256 vaultId)
    internal
    returns (uint256 fee)
  {

    fee = 0;
    if (address(performanceFeeCollector) != address(0)) {
      Asset storage junior = vault.assets[OLib.Tranche.Junior];
      uint256 juniorHurdle =
        (junior.totalInvested * vault.hurdleRate) / denominator;

      if (junior.received > juniorHurdle) {
        fee =
          (vault.performanceFee * (junior.received - juniorHurdle)) /
          denominator;
        IERC20(junior.token).safeTransferFrom(
          address(vault.strategy),
          address(performanceFeeCollector),
          fee
        );
        performanceFeeCollector.processFee(vaultId, IERC20(junior.token), fee);
      }
    }
  }

  function safeTransferETH(address to, uint256 value) internal {

    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, "ETH transfer failed");
  }

  function _getSeniorExpected(Vault storage vault, Asset storage senior)
    internal
    view
    returns (uint256)
  {

    return (senior.totalInvested * vault.hurdleRate) / denominator;
  }

  function _getNetOriginalInvested(Asset storage asset)
    internal
    view
    returns (uint256)
  {

    uint256 o = asset.originalInvested;
    uint256 r = asset.rolloverDeposited;
    return o > r ? o - r : 0;
  }

  function _getRolloverInvested(Asset storage asset)
    internal
    view
    returns (uint256)
  {

    uint256 o = asset.originalInvested;
    uint256 r = asset.rolloverDeposited;
    return o > r ? r : o;
  }


  function setPerformanceFee(uint256 _vaultId, uint256 _performanceFee)
    external
    onlyStrategist(_vaultId)
    atState(_vaultId, OLib.State.Inactive)
  {

    require(_performanceFee <= denominator, "Too high");
    Vault storage vault_ = Vaults[_vaultId];
    vault_.performanceFee = _performanceFee;
  }

  function setPerformanceFeeCollector(address _collector)
    external
    isAuthorized(OLib.GOVERNANCE_ROLE)
  {

    performanceFeeCollector = IFeeCollector(_collector);
  }

  function canDeposit(uint256 _vaultId) external view override returns (bool) {

    Vault storage vault_ = Vaults[_vaultId];
    if (vault_.state == OLib.State.Inactive) {
      return vault_.startAt <= block.timestamp && vault_.startAt > 0;
    }
    return vault_.state == OLib.State.Deposit;
  }

  function getVaults(uint256 _from, uint256 _to)
    external
    view
    returns (VaultView[] memory vaults)
  {

    EnumerableSet.UintSet storage vaults_ = vaultIDs;
    uint256 len = vaults_.length();
    if (len == 0) {
      return new VaultView[](0);
    }
    if (len <= _to) {
      _to = len - 1;
    }
    vaults = new VaultView[](1 + _to - _from);
    for (uint256 i = _from; i <= _to; i++) {
      vaults[i - _from] = getVaultById(vaults_.at(i));
    }
    return vaults;
  }

  function getVaultByToken(address _trancheToken)
    external
    view
    returns (VaultView memory)
  {

    return getVaultById(VaultsByTokens[_trancheToken]);
  }

  function getVaultById(uint256 _vaultId)
    public
    view
    override
    returns (VaultView memory vault)
  {

    Vault storage svault_ = Vaults[_vaultId];
    mapping(OLib.Tranche => Asset) storage sassets_ = svault_.assets;
    Asset[] memory assets = new Asset[](2);
    assets[0] = sassets_[OLib.Tranche.Senior];
    assets[1] = sassets_[OLib.Tranche.Junior];
    vault = VaultView(
      _vaultId,
      assets,
      svault_.strategy,
      svault_.creator,
      svault_.strategist,
      svault_.rollover,
      svault_.hurdleRate,
      svault_.state,
      svault_.startAt,
      svault_.investAt,
      svault_.redeemAt
    );
  }

  function seniorExpected(uint256 _vaultId)
    external
    view
    override
    returns (uint256)
  {

    Vault storage vault_ = Vaults[_vaultId];
    Asset storage senior_ = vault_.assets[OLib.Tranche.Senior];
    return _getSeniorExpected(vault_, senior_);
  }

  function vaultInvestor(uint256 _vaultId, OLib.Tranche _tranche)
    public
    view
    override
    returns (
      uint256 position,
      uint256 claimableBalance,
      uint256 withdrawableExcess,
      uint256 withdrawableBalance
    )
  {

    Asset storage asset_ = Vaults[_vaultId].assets[_tranche];
    OLib.Investor storage investor_ =
      investors[address(asset_.trancheToken)][msg.sender];
    if (!investor_.withdrawn) {
      (position, withdrawableExcess) = investor_.getInvestedAndExcess(
        _getNetOriginalInvested(asset_)
      );
      if (!investor_.claimed) {
        claimableBalance = position;
        position += asset_.trancheToken.balanceOf(msg.sender);
      } else {
        withdrawableExcess = 0;
        if (registry.tokenMinting()) {
          position = asset_.trancheToken.balanceOf(msg.sender);
        }
      }
      if (Vaults[_vaultId].state == OLib.State.Withdraw) {
        claimableBalance = 0;
        withdrawableBalance =
          withdrawableExcess +
          (asset_.received * position) /
          asset_.totalInvested;
      }
    }
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;
  }

  function excall(address target, bytes calldata data)
    external
    isAuthorized(OLib.GUARDIAN_ROLE)
    returns (bytes memory returnData)
  {

    bool success;
    (success, returnData) = target.call(data);
    require(success, "CF");
  }
}