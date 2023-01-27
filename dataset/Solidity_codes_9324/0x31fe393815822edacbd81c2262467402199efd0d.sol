
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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
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

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20Burnable is Context, ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "ERC20: burn amount exceeds allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;


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
}// MIT

pragma solidity 0.6.12;


interface ISwap {
  function getA() external view returns (uint256);

  function getToken(uint8 index) external view returns (IERC20);

  function getTokenIndex(address tokenAddress) external view returns (uint8);

  function getTokenBalance(uint8 index) external view returns (uint256);

  function getVirtualPrice() external view returns (uint256);

  function calculateSwap(
    uint8 tokenIndexFrom,
    uint8 tokenIndexTo,
    uint256 dx
  ) external view returns (uint256);

  function calculateTokenAmount(uint256[] calldata amounts, bool deposit)
    external
    view
    returns (uint256);

  function calculateRemoveLiquidity(uint256 amount)
    external
    view
    returns (uint256[] memory);

  function calculateRemoveLiquidityOneToken(
    uint256 tokenAmount,
    uint8 tokenIndex
  ) external view returns (uint256 availableTokenAmount);

  function initialize(
    IERC20[] memory pooledTokens,
    uint8[] memory decimals,
    string memory lpTokenName,
    string memory lpTokenSymbol,
    uint256 a,
    uint256 fee,
    uint256 adminFee,
    address lpTokenTargetAddress
  ) external;

  function swap(
    uint8 tokenIndexFrom,
    uint8 tokenIndexTo,
    uint256 dx,
    uint256 minDy,
    uint256 deadline
  ) external returns (uint256);

  function addLiquidity(
    uint256[] calldata amounts,
    uint256 minToMint,
    uint256 deadline
  ) external returns (uint256);

  function removeLiquidity(
    uint256 amount,
    uint256[] calldata minAmounts,
    uint256 deadline
  ) external returns (uint256[] memory);

  function removeLiquidityOneToken(
    uint256 tokenAmount,
    uint8 tokenIndex,
    uint256 minAmount,
    uint256 deadline
  ) external returns (uint256);

  function removeLiquidityImbalance(
    uint256[] calldata amounts,
    uint256 maxBurnAmount,
    uint256 deadline
  ) external returns (uint256);
}// MIT

pragma solidity >=0.4.0;

interface IWETH9 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    receive() external payable;

    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function totalSupply() external view returns (uint256);

    function approve(address guy, uint256 wad) external returns (bool);

    function transfer(address dst, uint256 wad) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);
}// MIT

pragma solidity 0.6.12;



interface IERC20Mintable is IERC20 {
  function mint(address to, uint256 amount) external;
}

contract SynapseBridge is Initializable, AccessControlUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable {
  using SafeERC20 for IERC20;
  using SafeERC20 for IERC20Mintable;
  using SafeMath for uint256;

  bytes32 public constant NODEGROUP_ROLE = keccak256('NODEGROUP_ROLE');
  bytes32 public constant GOVERNANCE_ROLE = keccak256('GOVERNANCE_ROLE');

  mapping(address => uint256) private fees;

  uint256 public startBlockNumber;
  uint256 public constant bridgeVersion = 6;
  uint256 public chainGasAmount;
  address payable public WETH_ADDRESS;

  mapping(bytes32 => bool) private kappaMap;

  receive() external payable {}
  
  function initialize() external initializer {
    startBlockNumber = block.number;
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    __AccessControl_init();
  }

  function setChainGasAmount(uint256 amount) external {
    require(hasRole(GOVERNANCE_ROLE, msg.sender), "Not governance");
    chainGasAmount = amount;
  }

  function setWethAddress(address payable _wethAddress) external {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not admin");
    WETH_ADDRESS = _wethAddress;
  }

  function addKappas(bytes32[] calldata kappas) external {
    require(hasRole(GOVERNANCE_ROLE, msg.sender), "Not governance");
    for (uint256 i = 0; i < kappas.length; ++i) {
      kappaMap[kappas[i]] = true;
    }
  }

  event TokenDeposit(
    address indexed to,
    uint256 chainId,
    IERC20 token,
    uint256 amount
  );
  event TokenRedeem(address indexed to, uint256 chainId, IERC20 token, uint256 amount);
  event TokenWithdraw(address indexed to, IERC20 token, uint256 amount, uint256 fee, bytes32 indexed kappa);
  event TokenMint(
    address indexed to,
    IERC20Mintable token,
    uint256 amount,
    uint256 fee,
    bytes32 indexed kappa
  );
  event TokenDepositAndSwap(
    address indexed to,
    uint256 chainId,
    IERC20 token,
    uint256 amount,
    uint8 tokenIndexFrom,
    uint8 tokenIndexTo,
    uint256 minDy,
    uint256 deadline
  );
  event TokenMintAndSwap(
    address indexed to,
    IERC20Mintable token,
    uint256 amount,
    uint256 fee,
    uint8 tokenIndexFrom,
    uint8 tokenIndexTo,
    uint256 minDy,
    uint256 deadline,
    bool swapSuccess,
    bytes32 indexed kappa
  );
  event TokenRedeemAndSwap(
    address indexed to,
    uint256 chainId,
    IERC20 token,
    uint256 amount,
    uint8 tokenIndexFrom,
    uint8 tokenIndexTo,
    uint256 minDy,
    uint256 deadline
  );
  event TokenRedeemAndRemove(
    address indexed to,
    uint256 chainId,
    IERC20 token,
    uint256 amount,
    uint8 swapTokenIndex,
    uint256 swapMinAmount,
    uint256 swapDeadline
  );
  event TokenWithdrawAndRemove(
    address indexed to,
    IERC20 token,
    uint256 amount,
    uint256 fee,
    uint8 swapTokenIndex,
    uint256 swapMinAmount,
    uint256 swapDeadline,
    bool swapSuccess,
    bytes32 indexed kappa
  );

  event TokenRedeemV2(bytes32 indexed to, uint256 chainId, IERC20 token, uint256 amount);

  function getFeeBalance(address tokenAddress) external view returns (uint256) {
    return fees[tokenAddress];
  }

  function kappaExists(bytes32 kappa) external view returns (bool) {
    return kappaMap[kappa];
  }

  function withdrawFees(IERC20 token, address to) external whenNotPaused() {
    require(hasRole(GOVERNANCE_ROLE, msg.sender), "Not governance");
    require(to != address(0), "Address is 0x000");
    if (fees[address(token)] != 0) {
      token.safeTransfer(to, fees[address(token)]);
      fees[address(token)] = 0;
    }
  }

  function pause() external {
    require(hasRole(GOVERNANCE_ROLE, msg.sender), "Not governance");
    _pause();
  }

  function unpause() external {
    require(hasRole(GOVERNANCE_ROLE, msg.sender), "Not governance");
    _unpause();
  }


  function deposit(
    address to,
    uint256 chainId,
    IERC20 token,
    uint256 amount
  ) external nonReentrant() whenNotPaused() {
    emit TokenDeposit(to, chainId, token, amount);
    token.safeTransferFrom(msg.sender, address(this), amount);
  }

  function redeem(
    address to,
    uint256 chainId,
    ERC20Burnable token,
    uint256 amount
  ) external nonReentrant() whenNotPaused() {
    emit TokenRedeem(to, chainId, token, amount);
    token.burnFrom(msg.sender, amount);
  }

  function withdraw(
    address to,
    IERC20 token,
    uint256 amount,
    uint256 fee,
    bytes32 kappa
  ) external nonReentrant() whenNotPaused() {
    require(hasRole(NODEGROUP_ROLE, msg.sender), 'Caller is not a node group');
    require(amount > fee, 'Amount must be greater than fee');
    require(!kappaMap[kappa], 'Kappa is already present');
    kappaMap[kappa] = true;
    fees[address(token)] = fees[address(token)].add(fee);
    if (address(token) == WETH_ADDRESS && WETH_ADDRESS != address(0)) {
      IWETH9(WETH_ADDRESS).withdraw(amount.sub(fee));
      (bool success, ) = to.call{value: amount.sub(fee)}("");
      require(success, "ETH_TRANSFER_FAILED");
      emit TokenWithdraw(to, token, amount, fee, kappa);
    } else {
      emit TokenWithdraw(to, token, amount, fee, kappa);
      token.safeTransfer(to, amount.sub(fee));
    }
  }


  function mint(
    address payable to,
    IERC20Mintable token,
    uint256 amount,
    uint256 fee,
    bytes32 kappa
  ) external nonReentrant() whenNotPaused() {
    require(hasRole(NODEGROUP_ROLE, msg.sender), 'Caller is not a node group');
    require(amount > fee, 'Amount must be greater than fee');
    require(!kappaMap[kappa], 'Kappa is already present');
    kappaMap[kappa] = true;
    fees[address(token)] = fees[address(token)].add(fee);
    emit TokenMint(to, token, amount.sub(fee), fee, kappa);
    token.mint(address(this), amount);
    IERC20(token).safeTransfer(to, amount.sub(fee));
    if (chainGasAmount != 0 && address(this).balance > chainGasAmount) {
      to.call.value(chainGasAmount)("");
    }
  }

  function depositAndSwap(
    address to,
    uint256 chainId,
    IERC20 token,
    uint256 amount,
    uint8 tokenIndexFrom,
    uint8 tokenIndexTo,
    uint256 minDy,
    uint256 deadline
  ) external nonReentrant() whenNotPaused() {
     emit TokenDepositAndSwap(
      to,
      chainId,
      token,
      amount,
      tokenIndexFrom,
      tokenIndexTo,
      minDy,
      deadline
    );
    token.safeTransferFrom(msg.sender, address(this), amount);
  }

  function redeemAndSwap(
    address to,
    uint256 chainId,
    ERC20Burnable token,
    uint256 amount,
    uint8 tokenIndexFrom,
    uint8 tokenIndexTo,
    uint256 minDy,
    uint256 deadline
  ) external nonReentrant() whenNotPaused() {
    emit TokenRedeemAndSwap(
      to,
      chainId,
      token,
      amount,
      tokenIndexFrom,
      tokenIndexTo,
      minDy,
      deadline
    );
    token.burnFrom(msg.sender, amount);
  }

  function redeemAndRemove(
    address to,
    uint256 chainId,
    ERC20Burnable token,
    uint256 amount,
    uint8 swapTokenIndex,
    uint256 swapMinAmount,
    uint256 swapDeadline
  ) external nonReentrant() whenNotPaused() {
      emit TokenRedeemAndRemove(
      to,
      chainId,
      token,
      amount,
      swapTokenIndex,
      swapMinAmount,
      swapDeadline
    );
    token.burnFrom(msg.sender, amount);
  }

  function mintAndSwap(
    address payable to,
    IERC20Mintable token,
    uint256 amount,
    uint256 fee,
    ISwap pool,
    uint8 tokenIndexFrom,
    uint8 tokenIndexTo,
    uint256 minDy,
    uint256 deadline,
    bytes32 kappa
  ) external nonReentrant() whenNotPaused() {
    require(hasRole(NODEGROUP_ROLE, msg.sender), 'Caller is not a node group');
    require(amount > fee, 'Amount must be greater than fee');
    require(!kappaMap[kappa], 'Kappa is already present');
    kappaMap[kappa] = true;
    fees[address(token)] = fees[address(token)].add(fee);
    if (chainGasAmount != 0 && address(this).balance > chainGasAmount) {
      to.call.value(chainGasAmount)("");
    }
    uint256 expectedOutput = ISwap(pool).calculateSwap(
      tokenIndexFrom,
      tokenIndexTo,
      amount.sub(fee)
    );

    if (expectedOutput >= minDy) {
      token.mint(address(this), amount);
      token.safeIncreaseAllowance(address(pool), amount);
      try
        ISwap(pool).swap(
          tokenIndexFrom,
          tokenIndexTo,
          amount.sub(fee),
          minDy,
          deadline
        )
      returns (uint256 finalSwappedAmount) {
        IERC20 swappedTokenTo = ISwap(pool).getToken(tokenIndexTo);
        if (address(swappedTokenTo) == WETH_ADDRESS && WETH_ADDRESS != address(0)) {
          IWETH9(WETH_ADDRESS).withdraw(finalSwappedAmount);
          (bool success, ) = to.call{value: finalSwappedAmount}("");
          require(success, "ETH_TRANSFER_FAILED");
          emit TokenMintAndSwap(to, token, finalSwappedAmount, fee, tokenIndexFrom, tokenIndexTo, minDy, deadline, true, kappa);
        } else {
          swappedTokenTo.safeTransfer(to, finalSwappedAmount);
          emit TokenMintAndSwap(to, token, finalSwappedAmount, fee, tokenIndexFrom, tokenIndexTo, minDy, deadline, true, kappa);
        }
      } catch {
        IERC20(token).safeTransfer(to, amount.sub(fee));
        emit TokenMintAndSwap(to, token, amount.sub(fee), fee, tokenIndexFrom, tokenIndexTo, minDy, deadline, false, kappa);
      }
    } else {
      token.mint(address(this), amount);
      IERC20(token).safeTransfer(to, amount.sub(fee));
      emit TokenMintAndSwap(to, token, amount.sub(fee), fee, tokenIndexFrom, tokenIndexTo, minDy, deadline, false, kappa);
    }
  }

  function withdrawAndRemove(
    address to,
    IERC20 token,
    uint256 amount,
    uint256 fee,
    ISwap pool,
    uint8 swapTokenIndex,
    uint256 swapMinAmount,
    uint256 swapDeadline,
    bytes32 kappa
  ) external nonReentrant() whenNotPaused() {
    require(hasRole(NODEGROUP_ROLE, msg.sender), 'Caller is not a node group');
    require(amount > fee, 'Amount must be greater than fee');
    require(!kappaMap[kappa], 'Kappa is already present');
    kappaMap[kappa] = true;
    fees[address(token)] = fees[address(token)].add(fee);
    uint256 expectedOutput = ISwap(pool).calculateRemoveLiquidityOneToken(
      amount.sub(fee),
      swapTokenIndex
    );

    if (expectedOutput >= swapMinAmount) {
      token.safeIncreaseAllowance(address(pool), amount.sub(fee));
      try
        ISwap(pool).removeLiquidityOneToken(
          amount.sub(fee),
          swapTokenIndex,
          swapMinAmount,
          swapDeadline
        )
      returns (uint256 finalSwappedAmount) {
        IERC20 swappedTokenTo = ISwap(pool).getToken(swapTokenIndex);
        swappedTokenTo.safeTransfer(to, finalSwappedAmount);
        emit TokenWithdrawAndRemove(to, token, finalSwappedAmount, fee, swapTokenIndex, swapMinAmount, swapDeadline, true, kappa);
      } catch {
        IERC20(token).safeTransfer(to, amount.sub(fee));
        emit TokenWithdrawAndRemove(to, token, amount.sub(fee), fee, swapTokenIndex, swapMinAmount, swapDeadline, false, kappa);
      }
    } else {
      token.safeTransfer(to, amount.sub(fee));
      emit TokenWithdrawAndRemove(to, token, amount.sub(fee), fee, swapTokenIndex, swapMinAmount, swapDeadline, false, kappa);
    }
  }


  function redeemV2(
    bytes32 to,
    uint256 chainId,
    ERC20Burnable token,
    uint256 amount
  ) external nonReentrant() whenNotPaused() {
    emit TokenRedeemV2(to, chainId, token, amount);
    token.burnFrom(msg.sender, amount);
  }

}