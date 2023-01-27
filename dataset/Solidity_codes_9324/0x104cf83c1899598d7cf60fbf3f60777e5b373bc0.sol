
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

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
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
}// GPL-3.0-or-later

pragma solidity >=0.4.0;

library Babylonian {

    function sqrt(uint256 x) internal pure returns (uint256) {

        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }
}pragma solidity >=0.5.0;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}pragma solidity >=0.5.0;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

}pragma solidity >=0.6.2;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

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


contract Registry is IRegistry, AccessControl {

  using EnumerableSet for EnumerableSet.AddressSet;
  bool private _paused;
  bool public override tokenMinting;

  uint256 public constant override denominator = 10000;

  IWETH public immutable override weth;

  EnumerableSet.AddressSet private deadTokens;
  address payable public fallbackRecipient;

  mapping(address => string) public strategistNames;

  modifier onlyRole(bytes32 _role) {

    require(hasRole(_role, msg.sender), "Unauthorized: Invalid role");
    _;
  }

  constructor(
    address _governance,
    address payable _fallbackRecipient,
    address _weth
  ) {
    require(
      _fallbackRecipient != address(0) && _fallbackRecipient != address(this),
      "Invalid address"
    );
    _setupRole(DEFAULT_ADMIN_ROLE, _governance);
    _setupRole(OLib.GOVERNANCE_ROLE, _governance);
    _setRoleAdmin(OLib.VAULT_ROLE, OLib.DEPLOYER_ROLE);
    _setRoleAdmin(OLib.ROLLOVER_ROLE, OLib.DEPLOYER_ROLE);
    _setRoleAdmin(OLib.STRATEGY_ROLE, OLib.DEPLOYER_ROLE);
    fallbackRecipient = _fallbackRecipient;
    weth = IWETH(_weth);
  }

  function authorized(bytes32 _role, address _account)
    public
    view
    override
    returns (bool)
  {

    return hasRole(_role, _account);
  }

  function addStrategist(address _strategist, string calldata _name) external {

    grantRole(OLib.STRATEGIST_ROLE, _strategist);
    strategistNames[_strategist] = _name;
  }

  function enableTokens() external override onlyRole(OLib.GOVERNANCE_ROLE) {

    tokenMinting = true;
  }

  function disableTokens() external override onlyRole(OLib.GOVERNANCE_ROLE) {

    tokenMinting = false;
  }

  event Paused(address account);

  event Unpaused(address account);

  function paused() public view override returns (bool) {

    return _paused;
  }

  function pause() external override onlyRole(OLib.PANIC_ROLE) {

    _paused = true;
    emit Paused(msg.sender);
  }

  function unpause() external override onlyRole(OLib.GUARDIAN_ROLE) {

    _paused = false;
    emit Unpaused(msg.sender);
  }

  function tokensDeclaredDead(address[] calldata _tokens)
    external
    onlyRole(OLib.GUARDIAN_ROLE)
  {

    for (uint256 i = 0; i < _tokens.length; i++) {
      deadTokens.add(_tokens[i]);
    }
  }

  function recycleDeadTokens(uint256 _tranches)
    external
    override
    onlyRole(OLib.VAULT_ROLE)
  {

    uint256 toRecycle =
      deadTokens.length() >= _tranches ? _tranches : deadTokens.length();
    while (toRecycle > 0) {
      address last = deadTokens.at(deadTokens.length() - 1);
      try ITrancheToken(last).destroy(fallbackRecipient) {} catch {}
      deadTokens.remove(last);
      toRecycle -= 1;
    }
  }

  function setFallbackRecipient(address payable _target)
    external
    onlyRole(OLib.GOVERNANCE_ROLE)
  {

    fallbackRecipient = _target;
  }
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

}pragma solidity 0.8.3;

interface IUserTriggeredReward {

  function invest(uint256 _amount) external;


  function withdraw() external;

}// AGPL-3.0
pragma solidity 0.8.3;


abstract contract BasePairLPStrategy is OndoRegistryClient, IStrategy {
  using SafeERC20 for IERC20;

  modifier onlyOrigin(uint256 _vaultId) {
    require(
      msg.sender == address(vaults[_vaultId].origin),
      "Unauthorized: Only Vault contract"
    );
    _;
  }

  event Invest(uint256 indexed vault, uint256 lpTokens);
  event Redeem(uint256 indexed vault);
  event Harvest(address indexed pool, uint256 lpTokens);

  mapping(uint256 => Vault) public override vaults;

  constructor(address _registry) OndoRegistryClient(_registry) {}

  function addLp(uint256 _vaultId, uint256 _amount)
    external
    virtual
    override
    whenNotPaused
    onlyOrigin(_vaultId)
  {
    Vault storage vault_ = vaults[_vaultId];
    vault_.shares += _amount;
  }

  function removeLp(
    uint256 _vaultId,
    uint256 _amount,
    address to
  ) external virtual override whenNotPaused onlyOrigin(_vaultId) {
    Vault storage vault_ = vaults[_vaultId];
    vault_.shares -= _amount;
    IERC20(vault_.pool).safeTransfer(to, _amount);
  }

  function getVaultInfo(uint256 _vaultId)
    external
    view
    override
    returns (IERC20, uint256)
  {
    Vault storage c = vaults[_vaultId];
    return (c.pool, c.shares);
  }

  function withdrawExcess(
    uint256 _vaultId,
    OLib.Tranche tranche,
    address to,
    uint256 amount
  ) external override onlyOrigin(_vaultId) {
    Vault storage _vault = vaults[_vaultId];
    if (tranche == OLib.Tranche.Senior) {
      uint256 excess = _vault.seniorExcess;
      require(amount <= excess, "Withdrawing too much");
      _vault.seniorExcess -= amount;
      _vault.senior.safeTransfer(to, amount);
    } else {
      uint256 excess = _vault.juniorExcess;
      require(amount <= excess, "Withdrawing too much");
      _vault.juniorExcess -= amount;
      _vault.junior.safeTransfer(to, amount);
    }
  }
}pragma solidity >=0.8.0;


library SushiSwapLibrary {

  using SafeMath for uint256;

  function sortTokens(address tokenA, address tokenB)
    internal
    pure
    returns (address token0, address token1)
  {

    require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
  }

  function pairFor(
    address factory,
    address tokenA,
    address tokenB
  ) internal pure returns (address pair) {

    (address token0, address token1) = sortTokens(tokenA, tokenB);
    pair = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex"ff",
              factory,
              keccak256(abi.encodePacked(token0, token1)),
              hex"e18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303" // init code hash
            )
          )
        )
      )
    );
  }

  function getReserves(
    address factory,
    address tokenA,
    address tokenB
  ) internal view returns (uint256 reserveA, uint256 reserveB) {

    (address token0, ) = sortTokens(tokenA, tokenB);
    (uint256 reserve0, uint256 reserve1, ) =
      IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();
    (reserveA, reserveB) = tokenA == token0
      ? (reserve0, reserve1)
      : (reserve1, reserve0);
  }

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) internal pure returns (uint256 amountB) {

    require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
    require(
      reserveA > 0 && reserveB > 0,
      "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
    );
    amountB = amountA.mul(reserveB) / reserveA;
  }

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) internal pure returns (uint256 amountOut) {

    require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
    require(
      reserveIn > 0 && reserveOut > 0,
      "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
    );
    uint256 amountInWithFee = amountIn.mul(997);
    uint256 numerator = amountInWithFee.mul(reserveOut);
    uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
    amountOut = numerator / denominator;
  }

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) internal pure returns (uint256 amountIn) {

    require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
    require(
      reserveIn > 0 && reserveOut > 0,
      "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
    );
    uint256 numerator = reserveIn.mul(amountOut).mul(1000);
    uint256 denominator = reserveOut.sub(amountOut).mul(997);
    amountIn = (numerator / denominator).add(1);
  }

  function getAmountsOut(
    address factory,
    uint256 amountIn,
    address[] memory path
  ) internal view returns (uint256[] memory amounts) {

    require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
    amounts = new uint256[](path.length);
    amounts[0] = amountIn;
    for (uint256 i; i < path.length - 1; i++) {
      (uint256 reserveIn, uint256 reserveOut) =
        getReserves(factory, path[i], path[i + 1]);
      amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
    }
  }

  function getAmountsIn(
    address factory,
    uint256 amountOut,
    address[] memory path
  ) internal view returns (uint256[] memory amounts) {

    require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
    amounts = new uint256[](path.length);
    amounts[amounts.length - 1] = amountOut;
    for (uint256 i = path.length - 1; i > 0; i--) {
      (uint256 reserveIn, uint256 reserveOut) =
        getReserves(factory, path[i - 1], path[i]);
      amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
    }
  }
}// MIT

pragma solidity 0.8.3;


interface IRewarder {

  function onSushiReward(
    uint256 pid,
    address user,
    address recipient,
    uint256 sushiAmount,
    uint256 newLpAmount
  ) external;


  function pendingTokens(
    uint256 pid,
    address user,
    uint256 sushiAmount
  ) external view returns (IERC20[] memory, uint256[] memory);

}// MIT
pragma solidity >=0.8.0 <0.9.0;


interface IMasterChefV2 {

  struct UserInfo {
    uint256 amount; // How many LP tokens the user has provided.
    uint256 rewardDebt; // Reward debt. See explanation below.
  }

  struct PoolInfo {
    uint256 allocPoint; // How many allocation points assigned to this pool. SUSHI to distribute per block.
    uint256 lastRewardBlock; // Last block number that SUSHI distribution occurs.
    uint256 accSushiPerShare; // Accumulated SUSHI per share, times 1e12. See below.
  }

  function poolInfo(uint256 pid)
    external
    view
    returns (IMasterChefV2.PoolInfo memory);


  function lpToken(uint256 pid) external view returns (address);


  function poolLength() external view returns (uint256 pools);


  function totalAllocPoint() external view returns (uint256);


  function sushiPerBlock() external view returns (uint256);


  function deposit(
    uint256 _pid,
    uint256 _amount,
    address _to
  ) external;


  function withdraw(
    uint256 _pid,
    uint256 _amount,
    address _to
  ) external;


  function withdrawAndHarvest(
    uint256 _pid,
    uint256 _amount,
    address _to
  ) external;


  function harvest(uint256 _pid, address _to) external;


  function userInfo(uint256 _pid, address _user)
    external
    view
    returns (uint256 amount, uint256 rewardDebt);


  function owner() external view returns (address);


  function add(
    uint256 _allocPoint,
    IERC20 _lpToken,
    IRewarder _rewarder
  ) external;


  function set(
    uint256 _pid,
    uint256 _allocPoint,
    IRewarder _rewarder,
    bool _overwrite
  ) external;


  function emergencyWithdraw(uint256 pid, address to) external;

}// AGPL-3.0
pragma solidity 0.8.3;


contract SushiStakingV2Strategy is BasePairLPStrategy {

  using SafeERC20 for IERC20;
  using OndoSaferERC20 for IERC20;

  string public constant name = "Ondo MasterChefV2 Staking Strategy v1.1";

  struct PoolData {
    uint256 pid;
    address[][2] pathsFromRewards;
    uint256 totalShares;
    uint256 totalLp;
    uint256 accRewardToken;
    IUserTriggeredReward extraRewardHandler;
    bool _isSet; // can't use pid because pid 0 is usdt/eth
  }

  struct Call {
    address target;
    bytes data;
  }

  mapping(address => PoolData) public pools;

  IUniswapV2Router02 public immutable sushiRouter;
  IERC20 public immutable sushiToken;
  IMasterChefV2 public immutable masterChef;
  address public immutable sushiFactory;

  uint256 public constant sharesToLpRatio = 10e15;

  event NewPair(address indexed pool, uint256 pid);

  constructor(
    address _registry,
    address _router,
    address _chef,
    address _factory,
    address _sushi
  ) BasePairLPStrategy(_registry) {
    require(_router != address(0), "Invalid address");
    require(_chef != address(0), "Invalid address");
    require(_factory != address(0), "Invalid address");
    require(_sushi != address(0), "Invalid address");
    registry = Registry(_registry);
    sushiRouter = IUniswapV2Router02(_router);
    sushiToken = IERC20(_sushi);
    masterChef = IMasterChefV2(_chef);
    sushiFactory = _factory;
  }

  function sharesFromLp(uint256 vaultId, uint256 lpTokens)
    public
    view
    override
    returns (
      uint256,
      uint256,
      IERC20
    )
  {

    Vault storage vault_ = vaults[vaultId];
    PoolData storage poolData = pools[address(vault_.pool)];
    return (
      (lpTokens * poolData.totalShares) / poolData.totalLp,
      vault_.shares,
      vault_.pool
    );
  }

  function lpFromShares(uint256 vaultId, uint256 shares)
    public
    view
    override
    returns (uint256, uint256)
  {

    Vault storage vault_ = vaults[vaultId];
    PoolData storage poolData = pools[address(vault_.pool)];
    return ((shares * poolData.totalLp) / poolData.totalShares, vault_.shares);
  }

  function addLp(uint256 _vaultId, uint256 _lpTokens)
    external
    virtual
    override
    whenNotPaused
    onlyOrigin(_vaultId)
  {

    Vault storage vault_ = vaults[_vaultId];
    PoolData storage poolData = pools[address(vault_.pool)];
    (uint256 userShares, , ) = sharesFromLp(_vaultId, _lpTokens);
    vault_.shares += userShares;
    poolData.totalShares += userShares;
    poolData.totalLp += _lpTokens;
    midTermDepositLp(vault_.pool, _lpTokens);
  }

  function removeLp(
    uint256 _vaultId,
    uint256 _shares,
    address to
  ) external override whenNotPaused onlyOrigin(_vaultId) {

    require(to != address(0), "No zero address");
    Vault storage vault_ = vaults[_vaultId];
    PoolData storage poolData = pools[address(vault_.pool)];
    (uint256 userLp, ) = lpFromShares(_vaultId, _shares);
    IERC20 rewardToken = IERC20(poolData.pathsFromRewards[1][0]);
    uint256 rewardTokenAmt = rewardToken.balanceOf(address(this));
    masterChef.withdraw(poolData.pid, userLp, address(this));
    rewardTokenAmt = rewardToken.balanceOf(address(this)) - rewardTokenAmt;
    if (address(poolData.extraRewardHandler) != address(0)) {
      rewardToken.safeTransfer(
        address(poolData.extraRewardHandler),
        rewardTokenAmt
      );
      poolData.extraRewardHandler.invest(rewardTokenAmt);
    } else {
      poolData.accRewardToken += rewardTokenAmt;
    }
    vault_.shares -= _shares;
    poolData.totalShares -= _shares;
    poolData.totalLp -= userLp;
    IERC20(vault_.pool).safeTransfer(to, userLp);
  }

  function midTermDepositLp(IERC20 pool, uint256 _lpTokens) internal {

    PoolData storage poolData = pools[address(pool)];
    IERC20 rewardToken = IERC20(poolData.pathsFromRewards[1][0]);
    uint256 rewardTokenAmt = rewardToken.balanceOf(address(this));
    pool.ondoSafeIncreaseAllowance(address(masterChef), _lpTokens);
    masterChef.deposit(pools[address(pool)].pid, _lpTokens, address(this));
    rewardTokenAmt = rewardToken.balanceOf(address(this)) - rewardTokenAmt;
    if (address(poolData.extraRewardHandler) != address(0)) {
      rewardToken.safeTransfer(
        address(poolData.extraRewardHandler),
        rewardTokenAmt
      );
      poolData.extraRewardHandler.invest(rewardTokenAmt);
    } else {
      poolData.accRewardToken += rewardTokenAmt;
    }
  }

  function addPool(
    address _pool,
    uint256 _pid,
    address[][2] memory _pathsFromRewards,
    address _extraRewardHandler
  ) external whenNotPaused isAuthorized(OLib.STRATEGIST_ROLE) {

    require(!pools[_pool]._isSet, "Pool already registered");
    require(_pool != address(0), "Cannot be zero address");

    address lpToken = masterChef.lpToken(_pid);
    require(lpToken == _pool, "LP Token does not match");
    require(
      _pathsFromRewards[0][0] == address(sushiToken) &&
        _pathsFromRewards[1][0] != address(sushiToken),
      "First path must be from SUSHI"
    );
    address token0 = IUniswapV2Pair(_pool).token0();
    address token1 = IUniswapV2Pair(_pool).token1();
    for (uint256 i = 0; i < 2; i++) {
      address rewardToken = _pathsFromRewards[i][0];
      if (rewardToken == token0 || rewardToken == token1) {
        require(_pathsFromRewards[i].length == 1, "Invalid path");
      } else {
        address endToken =
          _pathsFromRewards[i][_pathsFromRewards[i].length - 1];
        require(endToken == token0 || endToken == token1, "Invalid path");
      }
    }
    pools[_pool].pathsFromRewards = _pathsFromRewards;

    pools[_pool].pid = _pid;
    pools[_pool]._isSet = true;
    pools[_pool].extraRewardHandler = IUserTriggeredReward(_extraRewardHandler);

    emit NewPair(_pool, _pid);
  }

  function updateRewardPath(address _pool, address[] calldata _pathFromReward)
    external
    whenNotPaused
    isAuthorized(OLib.STRATEGIST_ROLE)
    returns (bool success)
  {

    require(pools[_pool]._isSet, "Pool ID not yet registered");
    address rewardToken = _pathFromReward[0];
    address endToken = _pathFromReward[_pathFromReward.length - 1];
    require(
      rewardToken != endToken || _pathFromReward.length == 1,
      "Invalid path"
    );
    address token0 = IUniswapV2Pair(_pool).token0();
    address token1 = IUniswapV2Pair(_pool).token1();
    PoolData storage poolData = pools[_pool];
    if (rewardToken == address(sushiToken)) {
      poolData.pathsFromRewards[0] = _pathFromReward;
      success = true;
    } else if (rewardToken == poolData.pathsFromRewards[1][0]) {
      poolData.pathsFromRewards[1] = _pathFromReward;
      success = true;
    } else {
      success = false;
    }
  }

  function _compound(IERC20 _pool, PoolData storage _poolData)
    internal
    returns (uint256 lpAmount)
  {

    uint256 sushiAmount = sushiToken.balanceOf(address(this));
    IERC20 rewardToken = IERC20(_poolData.pathsFromRewards[1][0]);
    uint256 rewardTokenAmount = rewardToken.balanceOf(address(this));
    masterChef.harvest(_poolData.pid, address(this));
    if (address(_poolData.extraRewardHandler) != address(0)) {
      _poolData.extraRewardHandler.withdraw();
    }
    sushiAmount = sushiToken.balanceOf(address(this)) - sushiAmount;
    rewardTokenAmount =
      rewardToken.balanceOf(address(this)) -
      rewardTokenAmount +
      _poolData.accRewardToken;
    _poolData.accRewardToken = 0;
    if (sushiAmount > 10000 && rewardTokenAmount > 10000) {
      IUniswapV2Pair pool = IUniswapV2Pair(address(_pool));
      uint256[] memory tokenAmountsArray = new uint256[](2);
      tokenAmountsArray[0] = sushiAmount;
      tokenAmountsArray[1] = rewardTokenAmount;
      for (uint256 i = 0; i < 2; i++) {
        if (
          tokenAmountsArray[i] > 0 && _poolData.pathsFromRewards[i].length > 1
        ) {
          tokenAmountsArray[i] = swapExactIn(
            tokenAmountsArray[i],
            0,
            _poolData.pathsFromRewards[i]
          );
        }
      }
      address tokenA =
        _poolData.pathsFromRewards[0][_poolData.pathsFromRewards[0].length - 1];
      address tokenB = IUniswapV2Pair(address(pool)).token0();
      if (tokenB == tokenA) tokenB = IUniswapV2Pair(address(pool)).token1();
      bool sameTarget =
        tokenA ==
          _poolData.pathsFromRewards[1][
            _poolData.pathsFromRewards[1].length - 1
          ];
      if (sameTarget) {
        tokenAmountsArray[0] = tokenAmountsArray[0] + tokenAmountsArray[1];
        (uint256 reserveA, ) =
          SushiSwapLibrary.getReserves(sushiFactory, tokenA, tokenB);
        tokenAmountsArray[1] = calculateSwapInAmount(
          reserveA,
          tokenAmountsArray[0]
        );
        tokenAmountsArray[0] -= tokenAmountsArray[1];
        tokenAmountsArray[1] = swapExactIn(
          tokenAmountsArray[1],
          0,
          getPath(tokenA, tokenB)
        );
        (, , lpAmount) = addLiquidity(
          tokenA,
          tokenB,
          tokenAmountsArray[0],
          tokenAmountsArray[1]
        );
      } else {
        uint256 amountInA;
        uint256 amountInB;
        (amountInA, amountInB, lpAmount) = addLiquidity(
          tokenA,
          tokenB,
          tokenAmountsArray[0],
          tokenAmountsArray[1]
        );
        tokenAmountsArray[0] -= amountInA;
        tokenAmountsArray[1] -= amountInB;
        require(
          tokenAmountsArray[0] == 0 || tokenAmountsArray[1] == 0,
          "Insufficient liquidity added on one side of first call"
        );
        (uint256 reserveA, uint256 reserveB) =
          SushiSwapLibrary.getReserves(sushiFactory, tokenA, tokenB);
        uint256 amountToSwap;
        if (tokenAmountsArray[0] < tokenAmountsArray[1]) {
          amountToSwap = calculateSwapInAmount(reserveB, tokenAmountsArray[1]);
          tokenAmountsArray[1] -= amountToSwap;
          tokenAmountsArray[0] += swapExactIn(
            amountToSwap,
            0,
            getPath(tokenB, tokenA)
          );
        } else if (tokenAmountsArray[0] > 0) {
          amountToSwap = calculateSwapInAmount(reserveA, tokenAmountsArray[0]);
          tokenAmountsArray[0] -= amountToSwap;
          tokenAmountsArray[1] += swapExactIn(
            amountToSwap,
            0,
            getPath(tokenA, tokenB)
          );
        }
        if (amountToSwap > 0) {
          (, , uint256 moreLp) =
            addLiquidity(
              tokenA,
              tokenB,
              tokenAmountsArray[0],
              tokenAmountsArray[1]
            );
          lpAmount += moreLp;
        }
      }
      _poolData.totalLp += lpAmount;
    }
    _pool.ondoSafeIncreaseAllowance(
      address(masterChef),
      _pool.balanceOf(address(this))
    );
    masterChef.deposit(
      _poolData.pid,
      _pool.balanceOf(address(this)),
      address(this)
    );
  }

  function depositIntoChef(uint256 vaultId, uint256 _amount) internal {

    Vault storage vault = vaults[vaultId];
    IERC20 pool = vault.pool;
    PoolData storage poolData = pools[address(pool)];
    _compound(pool, poolData);
    if (poolData.totalLp == 0 || poolData.totalShares == 0) {
      poolData.totalShares = _amount * sharesToLpRatio;
      poolData.totalLp = _amount;
      vault.shares = _amount * sharesToLpRatio;
    } else {
      uint256 shares = (_amount * poolData.totalShares) / poolData.totalLp;
      poolData.totalShares += shares;
      vault.shares += shares;
      poolData.totalLp += _amount;
    }
  }

  function withdrawFromChef(uint256 vaultId)
    internal
    returns (uint256 lpTokens)
  {

    Vault storage vault = vaults[vaultId];
    IERC20 pool = vault.pool;
    PoolData storage poolData = pools[address(pool)];
    lpTokens = vault.shares == poolData.totalShares
      ? poolData.totalLp
      : (poolData.totalLp * vault.shares) / poolData.totalShares;
    poolData.totalLp -= lpTokens;
    poolData.totalShares -= vault.shares;
    vault.shares = 0;
    masterChef.withdraw(poolData.pid, lpTokens, address(this));
    return lpTokens;
  }

  function harvest(address pool, uint256 minLp)
    external
    isAuthorized(OLib.STRATEGIST_ROLE)
    whenNotPaused
    returns (uint256)
  {

    PoolData storage poolData = pools[pool];
    uint256 lp = _compound(IERC20(pool), poolData);
    require(lp >= minLp, "Exceeds maximum slippage");
    emit Harvest(pool, lp);
    return lp;
  }

  function poolExists(IERC20 srAsset, IERC20 jrAsset)
    internal
    view
    returns (bool)
  {

    return
      IUniswapV2Factory(sushiFactory).getPair(
        address(srAsset),
        address(jrAsset)
      ) != address(0);
  }

  function addVault(
    uint256 _vaultId,
    IERC20 _senior,
    IERC20 _junior
  ) external override whenNotPaused nonReentrant isAuthorized(OLib.VAULT_ROLE) {

    require(
      address(vaults[_vaultId].origin) == address(0),
      "Vault already registered"
    );
    require(poolExists(_senior, _junior), "Pool doesn't exist");
    address pair =
      SushiSwapLibrary.pairFor(
        sushiFactory,
        address(_senior),
        address(_junior)
      );
    require(pools[pair]._isSet, "Pool not supported");
    vaults[_vaultId].origin = IPairVault(msg.sender);
    vaults[_vaultId].pool = IERC20(pair);
    vaults[_vaultId].senior = _senior;
    vaults[_vaultId].junior = _junior;
  }

  function swapExactIn(
    uint256 amtIn,
    uint256 minOut,
    address[] memory path
  ) internal returns (uint256) {

    IERC20(path[0]).ondoSafeIncreaseAllowance(address(sushiRouter), amtIn);
    return
      sushiRouter.swapExactTokensForTokens(
        amtIn,
        minOut,
        path,
        address(this),
        block.timestamp
      )[path.length - 1];
  }

  function swapExactOut(
    uint256 amtOut,
    uint256 maxIn,
    address[] memory path
  ) internal returns (uint256) {

    IERC20(path[0]).ondoSafeIncreaseAllowance(address(sushiRouter), maxIn);
    return
      sushiRouter.swapTokensForExactTokens(
        amtOut,
        maxIn,
        path,
        address(this),
        block.timestamp
      )[0];
  }

  function addLiquidity(
    address token0,
    address token1,
    uint256 amt0,
    uint256 amt1
  )
    internal
    returns (
      uint256 out0,
      uint256 out1,
      uint256 lp
    )
  {

    IERC20(token0).ondoSafeIncreaseAllowance(address(sushiRouter), amt0);
    IERC20(token1).ondoSafeIncreaseAllowance(address(sushiRouter), amt1);
    (out0, out1, lp) = sushiRouter.addLiquidity(
      token0,
      token1,
      amt0,
      amt1,
      0,
      0,
      address(this),
      block.timestamp
    );
  }

  function invest(
    uint256 _vaultId,
    uint256 _totalSenior,
    uint256 _totalJunior,
    uint256 _extraSenior,
    uint256 _extraJunior,
    uint256 _seniorMinIn,
    uint256 _juniorMinIn
  )
    external
    override
    nonReentrant
    whenNotPaused
    onlyOrigin(_vaultId)
    returns (uint256 seniorInvested, uint256 juniorInvested)
  {

    uint256 lpTokens;
    Vault storage vault_ = vaults[_vaultId];
    vault_.senior.ondoSafeIncreaseAllowance(address(sushiRouter), _totalSenior);
    vault_.junior.ondoSafeIncreaseAllowance(address(sushiRouter), _totalJunior);
    (seniorInvested, juniorInvested, lpTokens) = sushiRouter.addLiquidity(
      address(vault_.senior),
      address(vault_.junior),
      _totalSenior,
      _totalJunior,
      _seniorMinIn,
      _juniorMinIn,
      address(this),
      block.timestamp
    );
    vault_.seniorExcess = _totalSenior - seniorInvested + _extraSenior;
    vault_.juniorExcess = _totalJunior - juniorInvested + _extraJunior;
    depositIntoChef(_vaultId, lpTokens);
    emit Invest(_vaultId, lpTokens);
  }

  function getPath(address _token0, address _token1)
    internal
    pure
    returns (address[] memory path)
  {

    path = new address[](2);
    path[0] = _token0;
    path[1] = _token1;
  }

  function swapForSr(
    address _senior,
    address _junior,
    uint256 _seniorExpected,
    uint256 seniorReceived,
    uint256 juniorReceived
  ) internal returns (uint256, uint256) {

    uint256 seniorNeeded = _seniorExpected - seniorReceived;
    address[] memory jr2Sr = getPath(_junior, _senior);
    if (
      seniorNeeded >
      SushiSwapLibrary.getAmountsOut(sushiFactory, juniorReceived, jr2Sr)[1]
    ) {
      seniorReceived += swapExactIn(juniorReceived, 0, jr2Sr);
      return (seniorReceived, 0);
    } else {
      juniorReceived -= swapExactOut(seniorNeeded, juniorReceived, jr2Sr);
      return (_seniorExpected, juniorReceived);
    }
  }

  function redeem(
    uint256 _vaultId,
    uint256 _seniorExpected,
    uint256 _seniorMinReceived,
    uint256 _juniorMinReceived
  )
    external
    override
    nonReentrant
    whenNotPaused
    onlyOrigin(_vaultId)
    returns (uint256 seniorReceived, uint256 juniorReceived)
  {

    Vault storage vault_ = vaults[_vaultId];
    {
      uint256 lpTokens = withdrawFromChef(_vaultId);
      vault_.pool.ondoSafeIncreaseAllowance(address(sushiRouter), lpTokens);
      (seniorReceived, juniorReceived) = sushiRouter.removeLiquidity(
        address(vault_.senior),
        address(vault_.junior),
        lpTokens,
        0,
        0,
        address(this),
        block.timestamp
      );
    }
    if (seniorReceived < _seniorExpected) {
      (seniorReceived, juniorReceived) = swapForSr(
        address(vault_.senior),
        address(vault_.junior),
        _seniorExpected,
        seniorReceived,
        juniorReceived
      );
    } else {
      if (seniorReceived > _seniorExpected) {
        juniorReceived += swapExactIn(
          seniorReceived - _seniorExpected,
          0,
          getPath(address(vault_.senior), address(vault_.junior))
        );
      }
      seniorReceived = _seniorExpected;
    }
    require(
      _seniorMinReceived <= seniorReceived &&
        _juniorMinReceived <= juniorReceived,
      "Exceeds maximum slippage"
    );
    vault_.senior.ondoSafeIncreaseAllowance(
      msg.sender,
      seniorReceived + vault_.seniorExcess
    );
    vault_.junior.ondoSafeIncreaseAllowance(
      msg.sender,
      juniorReceived + vault_.juniorExcess
    );
    emit Redeem(_vaultId);
    return (seniorReceived, juniorReceived);
  }

  function calculateSwapInAmount(uint256 reserveIn, uint256 userIn)
    internal
    pure
    returns (uint256)
  {

    return
      (Babylonian.sqrt(reserveIn * (userIn * 3988000 + reserveIn * 3988009)) -
        reserveIn *
        1997) / 1994;
  }

  function multiexcall(Call[] calldata calls)
    external
    isAuthorized(OLib.GUARDIAN_ROLE)
    returns (bytes[] memory returnData)
  {

    returnData = new bytes[](calls.length);
    for (uint256 i = 0; i < calls.length; i++) {
      (bool success, bytes memory ret) = calls[i].target.call(calls[i].data);
      require(success, "Multicall aggregate: call failed");
      returnData[i] = ret;
    }
  }
}