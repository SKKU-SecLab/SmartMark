
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

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolImmutables {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function fee() external view returns (uint24);

    function tickSpacing() external view returns (int24);

    function maxLiquidityPerTick() external view returns (uint128);
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolState {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    function feeGrowthGlobal0X128() external view returns (uint256);

    function feeGrowthGlobal1X128() external view returns (uint256);

    function protocolFees() external view returns (uint128 token0, uint128 token1);

    function liquidity() external view returns (uint128);

    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    function tickBitmap(int16 wordPosition) external view returns (uint256);

    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolDerivedState {
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolActions {
    function initialize(uint160 sqrtPriceX96) external;

    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolOwnerActions {
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3PoolEvents {
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}pragma solidity =0.6.6;

interface IERC223Recipient {
    function tokenReceived(
        address from,
        uint256 amount,
        bytes calldata data
    ) external;
}pragma solidity =0.6.6;

interface IERC677Recipient {
    function onTokenTransfer(
        address from,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}pragma solidity =0.6.6;

interface IERC1363Receiver {
    function onTransferReceived(
        address operator,
        address from,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);
}pragma solidity =0.6.6;

interface IOwnable {
    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;


interface IMiningPool is IOwnable, IERC165, IERC223Recipient, IERC677Recipient, IERC1363Receiver {
    function initialize(
        IERC20 _tokenToStake,
        IERC20 _tokenToReward,
        IUniswapV3Pool _referenceUniswapV3Pool,
        uint256 _totalAnnualRewards,
        uint256 _fixedPoolCapacityUSD,
        uint64 _lockPeriod,
        uint64 _rewardPeriod,
        uint64 _redeemWaitPeriod,
        bool _isTokenToStakeWETH
    ) external;

    function getTokenToStake() external view returns (address);

    function getTokenToReward() external view returns (address);

    function getReferenceUniswapV3Pool() external view returns (address);

    function getTotalAnnualRewards() external view returns (uint256);

    function getFixedPoolCapacityUSD() external view returns (uint256);

    function getFixedPoolUsageUSD() external view returns (uint256);

    function getLockPeriod() external view returns (uint64);

    function getRewardPeriod() external view returns (uint64);

    function getRedeemWaitPeriod() external view returns (uint64);

    function getPoolStake() external view returns (uint256);

    function getPoolStakeAt(uint64 timestamp) external view returns (Record memory);

    function getPoolRequestedToRedeem() external view returns (uint256);

    function getUserStake(address userAddr) external view returns (uint256);

    function getUserStakeAt(address userAddr, uint64 timestamp) external view returns (Record memory);

    function getUserStakeLocked(address userAddr) external view returns (uint256);

    function getUserStakeUnlocked(address userAddr) external view returns (uint256);

    function getUserStakeDetails(address userAddr) external view returns (StakeRecord[] memory);

    function getUserStakeRewards(address userAddr) external view returns (uint256);

    function getUserStakeRewardsDetails(address userAddr) external view returns (Record[] memory);

    function getUserRewardsAt(
        address userAddr,
        uint64 timestamp,
        int256 price,
        uint8 decimals
    ) external view returns (Record memory);

    function getUserRequestedToRedeem(address userAddr) external view returns (uint256);

    function getUserCanRedeemNow(address userAddr) external view returns (uint256);

    function getUserRedemptionDetails(address userAddr) external view returns (Record[] memory);

    function stakeToken(uint256 amount) external;

    function stakeETH() external payable;

    function claimStakeRewards() external;

    function requestRedemption(uint256 amount) external;

    function redeemToken() external;

    function redeemETH() external;

    function getAllUsers() external view returns (address[] memory);

    function setPriceConsultSeconds(uint32 _priceConsultSeconds) external;

    function getWithdrawers() external view returns (address[] memory);

    function grantWithdrawer(address withdrawerAddr) external;

    function revokeWithdrawer(address withdrawerAddr) external;

    function poolDeposit(uint256 amount) external;

    function poolDepositETH() external payable;

    function poolWithdraw(uint256 amount) external;

    function poolWithdrawETH(uint256 amount) external;

    function rescueERC20(
        address token,
        address to,
        uint256 amount
    ) external;

    event StakeRewards(address indexed userAddr, uint256 stakeAmount, uint256 stakeRewardsAmount, uint64 stakeTime, uint64 nodeID, bytes32 stakeHash);

    event FixedPoolStaking(address indexed userAddr, uint256 tokenAmount, uint256 equivUSD);

    event StakeToken(address indexed userAddr, uint256 amount);

    event ClaimStakeRewards(address indexed userAddr, uint256 amount);

    event RequestRedemption(address indexed userAddr, uint256 amount);

    event RedeemToken(address indexed userAddr, uint256 amount);

    struct Record {
        uint256 amount;
        uint64 timestamp;
    }

    struct StakeRecord {
        uint256 currentStakeAmount;
        uint256 initialStakeAmount;
        uint256 stakeRewardsAmount;
        uint64 timestamp;
    }
}pragma solidity =0.6.6;

interface IWETH {
    function deposit() external payable;

    function transfer(address recipient, uint256 amount) external returns (bool);

    function withdraw(uint256 amount) external;
}// MIT
pragma solidity >=0.4.0;

library FullMathV3 {
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);


        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        uint256 twos = -denominator & denominator;
        assembly {
            denominator := div(denominator, twos)
        }

        assembly {
            prod0 := div(prod0, twos)
        }
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        uint256 inv = (3 * denominator) ^ 2;
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        result = prod0 * inv;
        return result;
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < uint256(-1));
            result++;
        }
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library TickMath {
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(MAX_TICK), "T");

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = uint256(-1) / ratio;

        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, "R");
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0 <0.8.0;


library OracleLibrary {
    function consult(address pool, uint32 secondsAgo) internal view returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity) {
        require(secondsAgo != 0, "BP");

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) = IUniswapV3Pool(pool).observe(secondsAgos);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        uint160 secondsPerLiquidityCumulativesDelta = secondsPerLiquidityCumulativeX128s[1] - secondsPerLiquidityCumulativeX128s[0];

        arithmeticMeanTick = int24(tickCumulativesDelta / secondsAgo);
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)) arithmeticMeanTick--;

        uint192 secondsAgoX160 = uint192(secondsAgo) * uint160(-1);
        harmonicMeanLiquidity = uint128(secondsAgoX160 / (uint192(secondsPerLiquidityCumulativesDelta) << 32));
    }

    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        if (sqrtRatioX96 <= uint128(-1)) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken ? FullMathV3.mulDiv(ratioX192, baseAmount, 1 << 192) : FullMathV3.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMathV3.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken ? FullMathV3.mulDiv(ratioX128, baseAmount, 1 << 128) : FullMathV3.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }

    function getOldestObservationSecondsAgo(address pool) internal view returns (uint32 secondsAgo) {
        (, , uint16 observationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool).slot0();
        require(observationCardinality > 0, "NI");

        (uint32 observationTimestamp, , , bool initialized) = IUniswapV3Pool(pool).observations((observationIndex + 1) % observationCardinality);

        if (!initialized) {
            (observationTimestamp, , , ) = IUniswapV3Pool(pool).observations(0);
        }

        secondsAgo = uint32(block.timestamp) - observationTimestamp;
    }

    function getBlockStartingTickAndLiquidity(address pool) internal view returns (int24, uint128) {
        (, int24 tick, uint16 observationIndex, uint16 observationCardinality, , , ) = IUniswapV3Pool(pool).slot0();

        require(observationCardinality > 1, "NEO");

        (uint32 observationTimestamp, int56 tickCumulative, uint160 secondsPerLiquidityCumulativeX128, ) = IUniswapV3Pool(pool).observations(observationIndex);
        if (observationTimestamp != uint32(block.timestamp)) {
            return (tick, IUniswapV3Pool(pool).liquidity());
        }

        uint256 prevIndex = (uint256(observationIndex) + observationCardinality - 1) % observationCardinality;
        (uint32 prevObservationTimestamp, int56 prevTickCumulative, uint160 prevSecondsPerLiquidityCumulativeX128, bool prevInitialized) = IUniswapV3Pool(pool).observations(prevIndex);

        require(prevInitialized, "ONI");

        uint32 delta = observationTimestamp - prevObservationTimestamp;
        tick = int24((tickCumulative - prevTickCumulative) / delta);
        uint128 liquidity = uint128((uint192(delta) * uint160(-1)) / (uint192(secondsPerLiquidityCumulativeX128 - prevSecondsPerLiquidityCumulativeX128) << 32));
        return (tick, liquidity);
    }

    struct WeightedTickData {
        int24 tick;
        uint128 weight;
    }

    function getWeightedArithmeticMeanTick(WeightedTickData[] memory weightedTickData) internal pure returns (int24 weightedArithmeticMeanTick) {
        int256 numerator;

        uint256 denominator;

        for (uint256 i; i < weightedTickData.length; i++) {
            numerator += weightedTickData[i].tick * int256(weightedTickData[i].weight);
            denominator += weightedTickData[i].weight;
        }

        weightedArithmeticMeanTick = int24(numerator / int256(denominator));
        if (numerator < 0 && (numerator % int256(denominator) != 0)) weightedArithmeticMeanTick--;
    }
}pragma solidity =0.6.6;



contract MiningPool is OwnableUpgradeable, AccessControlUpgradeable, ERC165Upgradeable, IMiningPool {
    using SafeMath for uint256;

    bytes32 private constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

    bytes4 private constant ERC1363RECEIVER_RETURN = bytes4(keccak256("onTransferReceived(address,address,uint256,bytes)"));
    uint8 private constant NOT_ENTERED = 1;
    uint8 private constant ENTERED = 2;

    uint8 private constant USDC_DECIMALS = 6;
    uint8 private constant MST_DECIMALS = 18;

    struct User {
        uint256 flexibleStake;
        uint64 stakeStart;
        uint64 stakeLast;
        uint64 stakeRewardsStart;
        uint64 stakeRewardsLast;
        uint64 redemptionStart;
        uint64 redemptionLast;
        bool isInList;
    }

    struct Node {
        uint256 amount;
        uint256 initialStakeAmount; // Used by fixed stake
        uint256 stakeRewardsAmount; // Used by fixed stake
        uint64 timestamp;
        uint64 next;
    }

    struct History {
        uint256 amount;
        uint64 timestamp;
    }

    mapping(address => User) private users;

    mapping(uint64 => Node) nodes;

    address[] userAddrList;

    History[] private poolHistory;

    mapping(address => History[]) private userHistory;

    IERC20 private tokenToStake;

    IERC20 private tokenToReward;

    IUniswapV3Pool private referenceUniswapV3Pool;

    uint256 private totalAnnualRewards;

    uint256 private fixedPoolCapacityUSD;

    uint256 private fixedPoolUsageUSD;

    uint64 private lockPeriod;

    uint64 private rewardPeriod;

    uint64 private redeemWaitPeriod;

    uint64 private nextNodeID;

    uint8 private directCalling;

    bool private isToken1;

    uint32 private priceConsultSeconds;

    uint256 private totalRequestedToRedeem;

    bool private isTokenToStakeWETH;

    function initialize(
        IERC20 _tokenToStake,
        IERC20 _tokenToReward,
        IUniswapV3Pool _referenceUniswapV3Pool,
        uint256 _totalAnnualRewards,
        uint256 _fixedPoolCapacityUSD,
        uint64 _lockPeriod,
        uint64 _rewardPeriod,
        uint64 _redeemWaitPeriod,
        bool _isTokenToStakeWETH
    ) external override initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __AccessControl_init_unchained();
        __ERC165_init_unchained();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        tokenToStake = _tokenToStake;
        tokenToReward = _tokenToReward;
        referenceUniswapV3Pool = _referenceUniswapV3Pool;
        totalAnnualRewards = _totalAnnualRewards;
        fixedPoolCapacityUSD = _fixedPoolCapacityUSD;
        fixedPoolUsageUSD = 0;
        lockPeriod = _lockPeriod;
        rewardPeriod = _rewardPeriod;
        redeemWaitPeriod = _redeemWaitPeriod;
        isTokenToStakeWETH = _isTokenToStakeWETH;
        nextNodeID = 1;
        directCalling = NOT_ENTERED;
        priceConsultSeconds = 1 hours;

        if (address(_referenceUniswapV3Pool) != address(0)) {
            address addr = address(_tokenToStake);
            if (addr == _referenceUniswapV3Pool.token0()) {
                isToken1 = false;
            } else if (addr == _referenceUniswapV3Pool.token1()) {
                isToken1 = true;
            } else {
                revert("Invalid UniswapV3Pool");
            }
        }

        poolHistory.push(History(0, 0));
        poolHistory.push(History(0, nextTimeSlot()));

        IMiningPool i;
        _registerInterface(i.tokenReceived.selector);
        _registerInterface(i.onTokenTransfer.selector);
        _registerInterface(i.onTransferReceived.selector);
    }

    function owner() public view override(OwnableUpgradeable, IOwnable) returns (address) {
        return OwnableUpgradeable.owner();
    }

    function renounceOwnership() public override(OwnableUpgradeable, IOwnable) {
        address _owner = owner();
        OwnableUpgradeable.renounceOwnership();
        revokeRole(DEFAULT_ADMIN_ROLE, _owner);
    }

    function transferOwnership(address newOwner) public override(OwnableUpgradeable, IOwnable) {
        address _owner = owner();
        require(_owner != newOwner, "Ownable: self ownership transfer");

        OwnableUpgradeable.transferOwnership(newOwner);
        grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        revokeRole(DEFAULT_ADMIN_ROLE, _owner);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165) returns (bool) {
        return ERC165Upgradeable.supportsInterface(interfaceId);
    }

    function tokenReceived(
        address from,
        uint256 amount,
        bytes calldata
    ) external override onlyAcceptableTokens {
        if (directCalling != ENTERED && msg.sender == address(tokenToStake)) {
            _stakeToken(from, amount);
        }
    }

    function onTokenTransfer(
        address from,
        uint256 amount,
        bytes calldata
    ) external override onlyAcceptableTokens returns (bool) {
        if (directCalling != ENTERED && msg.sender == address(tokenToStake)) {
            _stakeToken(from, amount);
        }

        return true;
    }

    function onTransferReceived(
        address,
        address from,
        uint256 value,
        bytes calldata
    ) external override onlyAcceptableTokens returns (bytes4) {
        if (directCalling != ENTERED && msg.sender == address(tokenToStake)) {
            _stakeToken(from, value);
        }

        return ERC1363RECEIVER_RETURN;
    }

    fallback() external payable {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }

    function _fallback() private {
        require(isTokenToStakeWETH, "Not WETH pool");

        if (directCalling != ENTERED) {
            uint256 amount = msg.value;
            IWETH(address(tokenToStake)).deposit{value: amount}();
            _stakeToken(msg.sender, amount);
        }
    }

    function getTokenToStake() external view override returns (address) {
        return address(tokenToStake);
    }

    function getTokenToReward() external view override returns (address) {
        return address(tokenToReward);
    }

    function getReferenceUniswapV3Pool() external view override returns (address) {
        return address(referenceUniswapV3Pool);
    }

    function getTotalAnnualRewards() external view override returns (uint256) {
        return totalAnnualRewards;
    }

    function getFixedPoolCapacityUSD() external view override returns (uint256) {
        return fixedPoolCapacityUSD;
    }

    function getFixedPoolUsageUSD() external view override returns (uint256) {
        return fixedPoolUsageUSD;
    }

    function getLockPeriod() external view override returns (uint64) {
        return lockPeriod;
    }

    function getRewardPeriod() external view override returns (uint64) {
        return rewardPeriod;
    }

    function getRedeemWaitPeriod() external view override returns (uint64) {
        return redeemWaitPeriod;
    }

    function getPoolStake() external view override returns (uint256) {
        return poolHistory[poolHistory.length - 1].amount;
    }

    function getPoolStakeAt(uint64 timestamp) public view override returns (Record memory) {
        uint64 timeSlot = timeSlotOf(timestamp);
        if (timeSlot > currentTimeSlot()) {
            return Record(0, 0);
        }

        uint256 index = poolHistory.length - 1;
        while (index > 0) {
            if (poolHistory[index].timestamp <= timeSlot) {
                return Record(poolHistory[index].amount, timeSlot);
            }

            index--;
        }

        return Record(0, timeSlot);
    }

    function getPoolRequestedToRedeem() external view override returns (uint256) {
        return totalRequestedToRedeem;
    }

    function getUserStake(address userAddr) external view override returns (uint256) {
        uint256 len = userHistory[userAddr].length;
        if (len == 0) {
            return 0;
        }

        return userHistory[userAddr][len - 1].amount;
    }

    function getUserStakeAt(address userAddr, uint64 timestamp) public view override returns (Record memory) {
        uint64 timeSlot = timeSlotOf(timestamp);
        if (timeSlot > currentTimeSlot()) {
            return Record(0, 0);
        }

        History[] storage user = userHistory[userAddr];
        if (user.length == 0) {
            return Record(0, timeSlot);
        }

        uint256 index = user.length - 1;
        while (index > 0) {
            if (user[index].timestamp <= timeSlot) {
                return Record(user[index].amount, timeSlot);
            }

            index--;
        }

        return Record(0, timeSlot);
    }

    function getUserStakeLocked(address userAddr) external view override returns (uint256) {
        return sumListLocked(users[userAddr].stakeStart, lockPeriod);
    }

    function getUserStakeUnlocked(address userAddr) external view override returns (uint256) {
        uint256 ret = sumListUnlocked(users[userAddr].stakeStart, lockPeriod);
        ret = ret.add(users[userAddr].flexibleStake);
        return ret;
    }

    function getUserStakeDetails(address userAddr) external view override returns (StakeRecord[] memory) {
        User memory user = users[userAddr];
        (uint64 nodeID, uint256 flexibleStake) = (user.stakeStart, user.flexibleStake);
        uint256 count = countList(nodeID);

        StakeRecord[] memory ret;
        uint256 offset;
        if (flexibleStake != 0) {
            ret = new StakeRecord[](count + 1);
            offset = 1;
            ret[0] = StakeRecord(flexibleStake, flexibleStake, 0, 0);
        } else {
            ret = new StakeRecord[](count);
            offset = 0;
        }

        for (uint256 i = 0; i < count; i++) {
            Node memory n = nodes[nodeID];
            ret[i + offset] = StakeRecord(n.amount, n.initialStakeAmount, n.stakeRewardsAmount, n.timestamp);
            nodeID = n.next;
        }

        return ret;
    }

    function getUserStakeRewards(address userAddr) external view override returns (uint256) {
        return sumList(users[userAddr].stakeRewardsStart);
    }

    function getUserStakeRewardsDetails(address userAddr) external view override returns (Record[] memory) {
        User memory user = users[userAddr];
        uint64 nodeID = user.stakeRewardsStart;
        uint256 count = countList(nodeID);

        Record[] memory ret = new Record[](count);

        copyFromList(nodeID, count, ret, 0);
        return ret;
    }

    function getUserRewardsAt(
        address userAddr,
        uint64 timestamp,
        int256 price,
        uint8 decimals
    ) external view override returns (Record memory) {
        uint64 timeSlot = timeSlotOf(timestamp);
        if (timeSlot > currentTimeSlot()) {
            return Record(0, 0);
        }

        Record memory pool = getPoolStakeAt(timestamp);
        Record memory user = getUserStakeAt(userAddr, timestamp);

        if (pool.amount == 0 || user.amount == 0) {
            return Record(0, timeSlot);
        }

        uint256 maxRewardsPerPeriod = totalAnnualRewards.mul(rewardPeriod).div(365 days);

        uint256 poolSize = pool.amount;
        if (address(referenceUniswapV3Pool) != address(0)) {
            uint256 tokenDecimals = uint256(ERC20(address(tokenToStake)).decimals());
            poolSize = poolSize.mul(uint256(price)).mul(10**uint256(USDC_DECIMALS)).div(10**(tokenDecimals.add(decimals)));
        }

        if (poolSize >= fixedPoolCapacityUSD) {
            return Record(user.amount.mul(maxRewardsPerPeriod).div(pool.amount), timeSlot);
        } else {
            return Record(user.amount.mul(maxRewardsPerPeriod).mul(poolSize).div(pool.amount.mul(fixedPoolCapacityUSD)), timeSlot);
        }
    }

    function getUserRequestedToRedeem(address userAddr) external view override returns (uint256) {
        return sumList(users[userAddr].redemptionStart);
    }

    function getUserCanRedeemNow(address userAddr) external view override returns (uint256) {
        return sumListUnlocked(users[userAddr].redemptionStart, redeemWaitPeriod);
    }

    function getUserRedemptionDetails(address userAddr) external view override returns (Record[] memory) {
        User memory user = users[userAddr];
        uint64 nodeID = user.redemptionStart;
        uint256 count = countList(nodeID);

        Record[] memory ret = new Record[](count);

        copyFromList(nodeID, count, ret, 0);
        return ret;
    }

    function stakeToken(uint256 amount) external override skipTransferCallback {
        SafeERC20.safeTransferFrom(tokenToStake, msg.sender, address(this), amount);
        _stakeToken(msg.sender, amount);
    }

    function stakeETH() external payable override {
        require(isTokenToStakeWETH, "Not WETH pool");

        uint256 amount = msg.value;
        IWETH(address(tokenToStake)).deposit{value: amount}();
        _stakeToken(msg.sender, amount);
    }

    function _stakeToken(address userAddr, uint256 amount) private {
        require(userAddr != address(0), "Invalid sender");
        require(amount > 0, "Invalid amount");

        User storage ptr = users[userAddr];
        User memory user = ptr;

        if (user.isInList == false) {
            ptr.isInList = true;
            userAddrList.push(userAddr);
        }

        uint256 remainAmount = amount;

        if (fixedPoolUsageUSD < fixedPoolCapacityUSD) {
            uint256 equivUSD = toEquivalentUSD(amount);
            uint256 tokenAmount = amount;

            if (fixedPoolUsageUSD.add(equivUSD) > fixedPoolCapacityUSD) {
                equivUSD = fixedPoolCapacityUSD.sub(fixedPoolUsageUSD);
                tokenAmount = toEquivalentToken(equivUSD);
            }

            addFixedStake(userAddr, tokenAmount, equivUSD);
            fixedPoolUsageUSD = fixedPoolUsageUSD.add(equivUSD);
            remainAmount = remainAmount.sub(tokenAmount);
        }

        if (remainAmount > 0) {
            ptr.flexibleStake = user.flexibleStake.add(remainAmount);
            emit StakeToken(userAddr, remainAmount);
        }

        updateHistory(userAddr, amount, true);
    }

    function claimStakeRewards() external override {
        User storage ptr = users[msg.sender];
        User memory user = ptr;
        uint256 amount = 0;
        uint64 nodeID = user.stakeRewardsStart;

        while (nodeID != 0) {
            Node memory node = nodes[nodeID];
            delete nodes[nodeID];
            amount = amount.add(node.amount);
            nodeID = node.next;
        }

        require(amount > 0, "No stake rewards can be claimed");

        ptr.stakeRewardsStart = 0;
        ptr.stakeRewardsLast = 0;

        SafeERC20.safeTransfer(tokenToReward, msg.sender, amount);
        emit ClaimStakeRewards(msg.sender, amount);
    }

    function requestRedemption(uint256 amount) external override {
        require(amount > 0, "Invalid amount");

        User storage ptr = users[msg.sender];
        User memory user = ptr;
        uint64 _lockPeriod = lockPeriod;
        uint256 remain = amount;
        uint64 nodeID;

        {
            nodeID = user.stakeStart;

            while (nodeID != 0) {
                Node memory node = nodes[nodeID];

                if ((node.timestamp + _lockPeriod) > block.timestamp) {
                    break;
                }

                if (node.amount > remain) {
                    nodes[nodeID].amount = node.amount.sub(remain);
                    remain = 0;
                    break;
                } else {
                    delete nodes[nodeID];
                    remain = remain.sub(node.amount);
                    nodeID = node.next;
                }
            }

            ptr.stakeStart = nodeID;
            if (nodeID == 0) {
                ptr.stakeLast = 0;
            }
        }

        require(remain <= user.flexibleStake, "Not enough unlocked tokens");
        ptr.flexibleStake = user.flexibleStake.sub(remain);

        {
            nodeID = newNode(amount);

            if (user.redemptionStart == 0) {
                ptr.redemptionStart = nodeID;
            } else {
                nodes[user.redemptionLast].next = nodeID;
            }

            ptr.redemptionLast = nodeID;
        }

        totalRequestedToRedeem = totalRequestedToRedeem.add(amount);
        updateHistory(msg.sender, amount, false);
        emit RequestRedemption(msg.sender, amount);
    }

    function redeemToken() external override {
        uint256 amount = _redeemToken();
        SafeERC20.safeTransfer(tokenToStake, msg.sender, amount);
    }

    function redeemETH() external override skipTransferCallback {
        require(isTokenToStakeWETH, "Not WETH pool");

        uint256 amount = _redeemToken();
        IWETH(address(tokenToStake)).withdraw(amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function _redeemToken() private returns (uint256 amount) {
        User storage ptr = users[msg.sender];
        User memory user = ptr;
        uint64 _redeemWaitPeriod = redeemWaitPeriod;
        amount = 0;

        {
            uint64 nodeID = user.redemptionStart;

            while (nodeID != 0) {
                Node memory node = nodes[nodeID];

                if ((node.timestamp + _redeemWaitPeriod) > block.timestamp) {
                    break;
                }

                delete nodes[nodeID];
                amount = amount.add(node.amount);
                nodeID = node.next;
            }

            require(amount > 0, "No token can be redeemed");

            ptr.redemptionStart = nodeID;
            if (nodeID == 0) {
                ptr.redemptionLast = 0;
            }
        }

        totalRequestedToRedeem = totalRequestedToRedeem.sub(amount);
        emit RedeemToken(msg.sender, amount);
    }

    function getAllUsers() external view override returns (address[] memory) {
        return userAddrList;
    }

    function setPriceConsultSeconds(uint32 _priceConsultSeconds) external override onlyOwner {
        priceConsultSeconds = _priceConsultSeconds;
    }

    function getWithdrawers() external view override returns (address[] memory) {
        return getMembers(WITHDRAWER_ROLE);
    }

    function grantWithdrawer(address withdrawerAddr) external override onlyOwner {
        grantRole(WITHDRAWER_ROLE, withdrawerAddr);
    }

    function revokeWithdrawer(address withdrawerAddr) external override onlyOwner {
        revokeRole(WITHDRAWER_ROLE, withdrawerAddr);
    }

    function poolDeposit(uint256 amount) external override skipTransferCallback {
        SafeERC20.safeTransferFrom(tokenToStake, msg.sender, address(this), amount);
    }

    function poolDepositETH() external payable override {
        require(isTokenToStakeWETH, "Not WETH pool");

        uint256 amount = msg.value;
        IWETH(address(tokenToStake)).deposit{value: amount}();
    }

    function poolWithdraw(uint256 amount) external override onlyWithdrawer {
        SafeERC20.safeTransfer(tokenToStake, msg.sender, amount);
    }

    function poolWithdrawETH(uint256 amount) external override onlyWithdrawer skipTransferCallback {
        require(isTokenToStakeWETH, "Not WETH pool");

        IWETH(address(tokenToStake)).withdraw(amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    function rescueERC20(
        address token,
        address to,
        uint256 amount
    ) external override onlyWithdrawer {
        SafeERC20.safeTransfer(IERC20(token), to, amount);
    }

    function getMembers(bytes32 role) private view returns (address[] memory) {
        uint256 count = getRoleMemberCount(role);
        address[] memory members = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            members[i] = getRoleMember(role, i);
        }
        return members;
    }

    uint256 private constant FOUR_DAYS = 4 days;

    function timeSlotOf(uint64 time) internal view returns (uint64) {
        uint256 _rewardPeriod = uint256(rewardPeriod);
        uint256 offset = _rewardPeriod == 7 days ? FOUR_DAYS : 0;
        uint256 _time = uint256(time);

        if (_time < FOUR_DAYS && _rewardPeriod == 7 days) {
            return 0;
        }

        return uint64(_time.sub(offset).div(_rewardPeriod).mul(_rewardPeriod).add(offset));
    }

    function currentTimeSlot() internal view returns (uint64) {
        uint256 _rewardPeriod = uint256(rewardPeriod);
        uint256 offset = _rewardPeriod == 7 days ? FOUR_DAYS : 0;
        return uint64(block.timestamp.sub(offset).div(_rewardPeriod).mul(_rewardPeriod).add(offset));
    }

    function nextTimeSlot() internal view returns (uint64) {
        uint256 _rewardPeriod = uint256(rewardPeriod);
        uint256 offset = _rewardPeriod == 7 days ? FOUR_DAYS : 0;
        return uint64(block.timestamp.sub(offset).div(_rewardPeriod).mul(_rewardPeriod).add(offset)) + rewardPeriod;
    }

    function countList(uint64 nodeStart) private view returns (uint256) {
        uint256 count;
        uint64 nodeID = nodeStart;

        while (nodeID != 0) {
            count++;
            nodeID = nodes[nodeID].next;
        }

        return count;
    }

    function sumList(uint64 nodeStart) private view returns (uint256) {
        uint256 amount = 0;
        uint64 nodeID = nodeStart;

        while (nodeID != 0) {
            Node memory node = nodes[nodeID];
            amount = amount.add(node.amount);
            nodeID = node.next;
        }

        return amount;
    }

    function sumListLocked(uint64 nodeStart, uint64 period) private view returns (uint256) {
        uint256 amount = 0;
        uint64 nodeID = nodeStart;

        while (nodeID != 0) {
            Node memory node = nodes[nodeID];

            if ((node.timestamp + period) > block.timestamp) {
                amount = amount.add(node.amount);
            }

            nodeID = node.next;
        }

        return amount;
    }

    function sumListUnlocked(uint64 nodeStart, uint64 period) private view returns (uint256) {
        uint256 amount = 0;
        uint64 nodeID = nodeStart;

        while (nodeID != 0) {
            Node memory node = nodes[nodeID];

            if ((node.timestamp + period) > block.timestamp) {
                break;
            }

            amount = amount.add(node.amount);
            nodeID = node.next;
        }

        return amount;
    }

    function copyFromList(
        uint64 nodeStart,
        uint256 count,
        Record[] memory array,
        uint256 indexStart
    ) private view {
        uint64 nodeID = nodeStart;
        for (uint256 i = 0; i < count; i++) {
            Node memory n = nodes[nodeID];
            array[i + indexStart] = Record(n.amount, n.timestamp);
            nodeID = n.next;
        }
    }

    function pseudoReferenceTokenAddr() private view returns (address) {
        return isToken1 ? address(0) : address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);
    }

    function toEquivalentUSD(uint256 tokenAmount) private view returns (uint256) {
        return toEquivalent(tokenAmount, address(tokenToStake), pseudoReferenceTokenAddr());
    }

    function toEquivalentToken(uint256 usdAmount) private view returns (uint256) {
        return toEquivalent(usdAmount, pseudoReferenceTokenAddr(), address(tokenToStake));
    }

    function toEquivalent(
        uint256 baseAmount,
        address baseToken,
        address quoteToken
    ) private view returns (uint256) {
        if (address(referenceUniswapV3Pool) == address(0)) {
            return baseAmount;
        }

        int24 tick;
        if (priceConsultSeconds == 0) {
            (, tick, , , , , ) = referenceUniswapV3Pool.slot0();
        } else {
            (tick, ) = OracleLibrary.consult(address(referenceUniswapV3Pool), priceConsultSeconds);
        }

        return OracleLibrary.getQuoteAtTick(tick, uint128(baseAmount), baseToken, quoteToken);
    }

    function newNode(uint256 amount) private returns (uint64) {
        uint64 nodeID = nextNodeID++;
        nodes[nodeID] = Node(amount, 0, 0, uint64(block.timestamp), 0);
        return nodeID;
    }

    function getStakeRewardsAmount(uint256 equivUSD) private pure returns (uint256) {
        return equivUSD * 10**uint256(MST_DECIMALS - USDC_DECIMALS);
    }

    function addFixedStake(
        address userAddr,
        uint256 amount,
        uint256 equivUSD
    ) private {
        User storage ptr = users[userAddr];
        User memory user = ptr;

        uint256 stakeRewardsAmount = getStakeRewardsAmount(equivUSD);
        uint64 nodeID = newNode(amount);
        uint64 stakeTime = uint64(block.timestamp);

        nodes[nodeID].initialStakeAmount = amount;

        nodes[nodeID].stakeRewardsAmount = stakeRewardsAmount;

        if (user.stakeStart == 0) {
            ptr.stakeStart = nodeID;
        } else {
            nodes[user.stakeLast].next = nodeID;
        }

        ptr.stakeLast = nodeID;

        emit StakeRewards(userAddr, amount, stakeRewardsAmount, stakeTime, nodeID, keccak256(abi.encodePacked(address(this), userAddr, stakeRewardsAmount, stakeTime, nodeID)));
        emit StakeToken(userAddr, amount);
        emit FixedPoolStaking(userAddr, amount, equivUSD);
    }

    function updateHistory(
        address userAddr,
        uint256 amount,
        bool isAddAmount
    ) private {
        uint64 _nextTimeSlot = nextTimeSlot();
        uint256 len;
        uint256 newAmount;

        {
            len = poolHistory.length;
            History memory history = poolHistory[len - 1];
            newAmount = isAddAmount ? history.amount.add(amount) : history.amount.sub(amount);

            if (history.timestamp == _nextTimeSlot) {
                poolHistory[len - 1].amount = newAmount;
            } else {
                poolHistory.push(History(newAmount, _nextTimeSlot));
            }
        }

        {
            History[] storage ptr = userHistory[userAddr];
            len = ptr.length;

            if (len == 0) {
                ptr.push(History(0, 0));
                ptr.push(History(amount, _nextTimeSlot));
                return;
            }

            History memory history = ptr[len - 1];
            newAmount = isAddAmount ? history.amount.add(amount) : history.amount.sub(amount);

            if (history.timestamp == _nextTimeSlot) {
                ptr[len - 1].amount = newAmount;
            } else {
                ptr.push(History(newAmount, _nextTimeSlot));
            }
        }
    }

    modifier onlyWithdrawer() {
        require(hasRole(WITHDRAWER_ROLE, msg.sender), "Withdrawer only");
        _;
    }

    modifier onlyAcceptableTokens() {
        require(msg.sender == address(tokenToStake) || msg.sender == address(tokenToReward), "Not acceptable token");
        _;
    }

    modifier skipTransferCallback() {
        directCalling = ENTERED;
        _;
        directCalling = NOT_ENTERED;
    }
}