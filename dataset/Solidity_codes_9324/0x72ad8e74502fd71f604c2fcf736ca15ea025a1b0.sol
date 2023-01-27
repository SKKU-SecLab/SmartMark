
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

library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3Factory {
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);

    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    function setOwner(address _owner) external;

    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}// GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;


interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}// GPL-2.0-or-later
pragma solidity >=0.6.0;


library TransferHelper {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
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

}// GPL-3.0-only
pragma solidity 0.7.6;


interface IHypervisor {
    function deposit(
        uint256 deposit0,
        uint256 deposit1,
        address to
    ) external returns (uint256);

    function withdraw(
        uint256 shares,
        address to,
        address from
    ) external returns (uint256, uint256);

    function rebalance(
        int24 _baseLower,
        int24 _baseUpper,
        int24 _limitLower,
        int24 _limitUpper,
        address _feeRecipient,
        int256 swapQuantity
    ) external;

    function addBaseLiquidity(uint256 amount0, uint256 amount1) external;

    function addLimitLiquidity(uint256 amount0, uint256 amount1) external;

    function pullLiquidity(uint256 shares)
        external
        returns (
            uint256 base0,
            uint256 base1,
            uint256 limit0,
            uint256 limit1
        );

    function token0() external view returns (IERC20);

    function token1() external view returns (IERC20);

    function pool() external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function transfer(address, uint256) external returns (bool);

    function getTotalAmounts() external view returns (uint256 total0, uint256 total1);

    function pendingFees() external returns (uint256 fees0, uint256 fees1);

    function totalSupply() external view returns (uint256);

    function setMaxTotalSupply(uint256 _maxTotalSupply) external;

    function setDepositMax(uint256 _deposit0Max, uint256 _deposit1Max) external;

    function appendList(address[] memory listed) external;

    function toggleWhitelist() external;

    function transferOwnership(address newOwner) external;
}// Apache-2.0

pragma solidity 0.7.6;

interface IBabController {

    function createGarden(
        address _reserveAsset,
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        uint256 _seed,
        uint256[] calldata _gardenParams,
        uint256 _initialContribution,
        bool[] memory _publicGardenStrategistsStewards,
        uint256[] memory _profitSharing
    ) external payable returns (address);

    function removeGarden(address _garden) external;

    function addReserveAsset(address _reserveAsset) external;

    function removeReserveAsset(address _reserveAsset) external;

    function updateProtocolWantedAsset(address _wantedAsset, bool _wanted) external;

    function updateGardenAffiliateRate(address _garden, uint256 _affiliateRate) external;

    function addAffiliateReward(
        address _depositor,
        address _referrer,
        uint256 _reserveAmount
    ) external;

    function claimRewards() external;

    function editPriceOracle(address _priceOracle) external;

    function editMardukGate(address _mardukGate) external;

    function editGardenValuer(address _gardenValuer) external;

    function editTreasury(address _newTreasury) external;

    function editHeart(address _newHeart) external;

    function editRewardsDistributor(address _rewardsDistributor) external;

    function editGardenFactory(address _newGardenFactory) external;

    function editGardenNFT(address _newGardenNFT) external;

    function editStrategyNFT(address _newStrategyNFT) external;

    function editStrategyFactory(address _newStrategyFactory) external;

    function setOperation(uint8 _kind, address _operation) external;

    function setMasterSwapper(address _newMasterSwapper) external;

    function addKeeper(address _keeper) external;

    function addKeepers(address[] memory _keepers) external;

    function removeKeeper(address _keeper) external;

    function enableGardenTokensTransfers() external;

    function editLiquidityReserve(address _reserve, uint256 _minRiskyPairLiquidityEth) external;

    function patchIntegration(address _old, address _new) external;

    function gardenCreationIsOpen() external view returns (bool);

    function owner() external view returns (address);

    function EMERGENCY_OWNER() external view returns (address);

    function guardianGlobalPaused() external view returns (bool);

    function guardianPaused(address _address) external view returns (bool);

    function setPauseGuardian(address _guardian) external;

    function setGlobalPause(bool _state) external returns (bool);

    function setSomePause(address[] memory _address, bool _state) external returns (bool);

    function isPaused(address _contract) external view returns (bool);

    function priceOracle() external view returns (address);

    function gardenValuer() external view returns (address);

    function heart() external view returns (address);

    function gardenNFT() external view returns (address);

    function strategyNFT() external view returns (address);

    function rewardsDistributor() external view returns (address);

    function gardenFactory() external view returns (address);

    function treasury() external view returns (address);

    function ishtarGate() external view returns (address);

    function mardukGate() external view returns (address);

    function strategyFactory() external view returns (address);

    function masterSwapper() external view returns (address);

    function gardenTokensTransfersEnabled() external view returns (bool);

    function bablMiningProgramEnabled() external view returns (bool);

    function allowPublicGardens() external view returns (bool);

    function enabledOperations(uint256 _kind) external view returns (address);

    function getGardens() external view returns (address[] memory);

    function getReserveAssets() external view returns (address[] memory);

    function getOperations() external view returns (address[20] memory);

    function isGarden(address _garden) external view returns (bool);

    function protocolWantedAssets(address _wantedAsset) external view returns (bool);

    function gardenAffiliateRates(address _wantedAsset) external view returns (uint256);

    function affiliateRewards(address _user) external view returns (uint256);

    function patchedIntegrations(address _integration) external view returns (address);

    function isValidReserveAsset(address _reserveAsset) external view returns (bool);

    function isValidKeeper(address _keeper) external view returns (bool);

    function isSystemContract(address _contractAddress) external view returns (bool);

    function protocolPerformanceFee() external view returns (uint256);

    function protocolManagementFee() external view returns (uint256);

    function minLiquidityPerReserve(address _reserve) external view returns (uint256);
}// MIT

pragma solidity ^0.7.6;

abstract contract IGovernor {
    enum ProposalState {Pending, Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed}

    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );

    event ProposalCanceled(uint256 proposalId);

    event ProposalExecuted(uint256 proposalId);

    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);

    function name() public view virtual returns (string memory);

    function version() public view virtual returns (string memory);

    function proposals(uint256 _proposalId)
        public
        view
        virtual
        returns (
            uint256,
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            bool
        );

    function COUNTING_MODE() public pure virtual returns (string memory);

    function hashProposal(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata calldatas,
        bytes32 descriptionHash
    ) public pure virtual returns (uint256);

    function state(uint256 proposalId) public view virtual returns (ProposalState);

    function proposalSnapshot(uint256 proposalId) public view virtual returns (uint256);

    function proposalDeadline(uint256 proposalId) public view virtual returns (uint256);

    function votingDelay() public view virtual returns (uint256);

    function votingPeriod() public view virtual returns (uint256);

    function quorum(uint256 blockNumber) public view virtual returns (uint256);

    function getVotes(address account, uint256 blockNumber) public view virtual returns (uint256);

    function hasVoted(uint256 proposalId, address account) public view virtual returns (bool);

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual returns (uint256 proposalId);

    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable virtual returns (uint256 proposalId);

    function castVote(uint256 proposalId, uint8 support) public virtual returns (uint256 balance);

    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    ) public virtual returns (uint256 balance);

    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual returns (uint256 balance);
}// MIT

pragma solidity 0.7.6;

interface IERC1271 {
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}// Apache-2.0

pragma solidity 0.7.6;



interface IEmergencyGarden {

    function wrap() external;
}

interface IStrategyGarden {

    function finalizeStrategy(
        uint256 _profits,
        int256 _returns,
        uint256 _burningAmount
    ) external;

    function allocateCapitalToStrategy(uint256 _capital) external;

    function expireCandidateStrategy() external;

    function addStrategy(
        string memory _name,
        string memory _symbol,
        uint256[] calldata _stratParams,
        uint8[] calldata _opTypes,
        address[] calldata _opIntegrations,
        bytes calldata _opEncodedDatas
    ) external;

    function payKeeper(address payable _keeper, uint256 _fee) external;

    function updateStrategyRewards(
        address _strategy,
        uint256 _newTotalBABLAmount,
        uint256 _newCapitalReturned,
        uint256 _newRewardsToSetAside
    ) external;
}

interface IAdminGarden {
    function initialize(
        address _reserveAsset,
        IBabController _controller,
        address _creator,
        string memory _name,
        string memory _symbol,
        uint256[] calldata _gardenParams,
        uint256 _initialContribution,
        bool[] memory _publicGardenStrategistsStewards
    ) external payable;

    function makeGardenPublic() external;

    function transferCreatorRights(address _newCreator, uint8 _index) external;

    function addExtraCreators(address[4] memory _newCreators) external;

    function setPublicRights(bool _publicStrategist, bool _publicStewards) external;

    function delegateVotes(address _token, address _address) external;

    function updateCreators(address _newCreator, address[4] memory _newCreators) external;

    function updateGardenParams(uint256[13] memory _newParams) external;

    function verifyGarden(uint256 _verifiedCategory) external;

    function resetHardlock(uint256 _hardlockStartsAt) external;
}

interface ICoreGarden {


    function privateGarden() external view returns (bool);

    function publicStrategists() external view returns (bool);

    function publicStewards() external view returns (bool);

    function controller() external view returns (IBabController);

    function creator() external view returns (address);

    function isGardenStrategy(address _strategy) external view returns (bool);

    function getContributor(address _contributor)
        external
        view
        returns (
            uint256 lastDepositAt,
            uint256 initialDepositAt,
            uint256 claimedAt,
            uint256 claimedBABL,
            uint256 claimedRewards,
            uint256 withdrawnSince,
            uint256 totalDeposits,
            uint256 nonce,
            uint256 lockedBalance
        );

    function reserveAsset() external view returns (address);

    function verifiedCategory() external view returns (uint256);

    function canMintNftAfter() external view returns (uint256);

    function customIntegrationsEnabled() external view returns (bool);

    function hardlockStartsAt() external view returns (uint256);

    function totalContributors() external view returns (uint256);

    function gardenInitializedAt() external view returns (uint256);

    function minContribution() external view returns (uint256);

    function depositHardlock() external view returns (uint256);

    function minLiquidityAsset() external view returns (uint256);

    function minStrategyDuration() external view returns (uint256);

    function maxStrategyDuration() external view returns (uint256);

    function reserveAssetRewardsSetAside() external view returns (uint256);

    function absoluteReturns() external view returns (int256);

    function totalStake() external view returns (uint256);

    function minVotesQuorum() external view returns (uint256);

    function minVoters() external view returns (uint256);

    function maxDepositLimit() external view returns (uint256);

    function strategyCooldownPeriod() external view returns (uint256);

    function getStrategies() external view returns (address[] memory);

    function extraCreators(uint256 index) external view returns (address);

    function getFinalizedStrategies() external view returns (address[] memory);

    function getVotingPower(address _contributor) external view returns (uint256);

    function strategyMapping(address _strategy) external view returns (bool);

    function keeperDebt() external view returns (uint256);

    function totalKeeperFees() external view returns (uint256);

    function lastPricePerShare() external view returns (uint256);

    function lastPricePerShareTS() external view returns (uint256);

    function pricePerShareDecayRate() external view returns (uint256);

    function pricePerShareDelta() external view returns (uint256);

    function userLock(address _contributor) external view returns (uint256);


    function deposit(
        uint256 _amountIn,
        uint256 _minAmountOut,
        address _to,
        address _referrer
    ) external payable;

    function depositBySig(
        uint256 _amountIn,
        uint256 _minAmountOut,
        uint256 _nonce,
        uint256 _maxFee,
        address _to,
        uint256 _pricePerShare,
        uint256 _fee,
        address _signer,
        address _referrer,
        bytes memory signature
    ) external;

    function withdraw(
        uint256 _amountIn,
        uint256 _minAmountOut,
        address payable _to,
        bool _withPenalty,
        address _unwindStrategy
    ) external;

    function withdrawBySig(
        uint256 _amountIn,
        uint256 _minAmountOut,
        uint256 _nonce,
        uint256 _maxFee,
        bool _withPenalty,
        address _unwindStrategy,
        uint256 _pricePerShare,
        uint256 _strategyNAV,
        uint256 _fee,
        address _signer,
        bytes memory signature
    ) external;

    function claimReturns(address[] calldata _finalizedStrategies) external;

    function claimAndStakeReturns(uint256 _minAmountOut, address[] calldata _finalizedStrategies) external;

    function claimRewardsBySig(
        uint256 _babl,
        uint256 _profits,
        uint256 _nonce,
        uint256 _maxFee,
        uint256 _fee,
        address signer,
        bytes memory signature
    ) external;

    function claimAndStakeRewardsBySig(
        uint256 _babl,
        uint256 _profits,
        uint256 _minAmountOut,
        uint256 _nonce,
        uint256 _nonceHeart,
        uint256 _maxFee,
        uint256 _pricePerShare,
        uint256 _fee,
        address _signer,
        bytes memory _signature
    ) external;

    function stakeBySig(
        uint256 _amountIn,
        uint256 _profits,
        uint256 _minAmountOut,
        uint256 _nonce,
        uint256 _nonceHeart,
        uint256 _maxFee,
        address _to,
        uint256 _pricePerShare,
        address _signer,
        bytes memory _signature
    ) external;

    function claimNFT() external;

    function updateUserLock(address _contributor, uint256 _userLock) external;
}

interface IERC20Metadata {
    function name() external view returns (string memory);
}

interface IGarden is ICoreGarden, IAdminGarden, IStrategyGarden, IEmergencyGarden, IERC20, IERC20Metadata, IERC1271 {
    struct Contributor {
        uint256 lastDepositAt;
        uint256 initialDepositAt;
        uint256 claimedAt;
        uint256 claimedBABL;
        uint256 claimedRewards;
        uint256 withdrawnSince;
        uint256 totalDeposits;
        uint256 nonce;
        uint256 lockedBalance;
    }
}// Apache-2.0

pragma solidity 0.7.6;

interface IHeart {

    function getVotedGardens() external view returns (address[] memory);

    function heartGarden() external view returns (IGarden);

    function getGardenWeights() external view returns (uint256[] memory);

    function minAmounts(address _reserve) external view returns (uint256);

    function assetToCToken(address _asset) external view returns (address);

    function bondAssets(address _asset) external view returns (uint256);

    function assetToLend() external view returns (address);

    function assetForPurchases() external view returns (address);

    function lastPumpAt() external view returns (uint256);

    function lastVotesAt() external view returns (uint256);

    function tradeSlippage() external view returns (uint256);

    function weeklyRewardAmount() external view returns (uint256);

    function bablRewardLeft() external view returns (uint256);

    function getFeeDistributionWeights() external view returns (uint256[] memory);

    function getTotalStats() external view returns (uint256[] memory);

    function votedGardens(uint256 _index) external view returns (address);

    function gardenWeights(uint256 _index) external view returns (uint256);

    function feeDistributionWeights(uint256 _index) external view returns (uint256);

    function totalStats(uint256 _index) external view returns (uint256);


    function pump(uint256 _bablMinAmountOut) external;

    function voteProposal(uint256 _proposalId, bool _isApprove) external;

    function resolveGardenVotesAndPump(
        address[] memory _gardens,
        uint256[] memory _weights,
        uint256 _bablMinAmountOut
    ) external;

    function resolveGardenVotes(address[] memory _gardens, uint256[] memory _weights) external;

    function updateMarkets() external;

    function setHeartGardenAddress(address _heartGarden) external;

    function updateFeeWeights(uint256[] calldata _feeWeights) external;

    function updateAssetToLend(address _assetToLend) external;

    function updateAssetToPurchase(address _purchaseAsset) external;

    function updateBond(address _assetToBond, uint256 _bondDiscount) external;

    function lendFusePool(address _assetToLend, uint256 _lendAmount) external;

    function borrowFusePool(address _assetToBorrow, uint256 _borrowAmount) external;

    function repayFusePool(address _borrowedAsset, uint256 _amountToRepay) external;

    function protectBABL(
        uint256 _bablPriceProtectionAt,
        uint256 _bablPrice,
        uint256 _pricePurchasingAsset,
        uint256 _slippage,
        address _hopToken
    ) external;

    function trade(
        address _fromAsset,
        address _toAsset,
        uint256 _fromAmount,
        uint256 _minAmount
    ) external;

    function sellWantedAssetToHeart(address _assetToSell, uint256 _amountToSell) external;

    function addReward(uint256 _bablAmount, uint256 _weeklyRate) external;

    function setMinTradeAmount(address _asset, uint256 _minAmount) external;

    function setTradeSlippage(uint256 _tradeSlippage) external;

    function bondAsset(
        address _assetToBond,
        uint256 _amountToBond,
        uint256 _minAmountOut,
        address _referrer,
        uint256 _userLock
    ) external;

    function bondAssetBySig(
        address _assetToBond,
        uint256 _amountToBond,
        uint256 _amountIn,
        uint256 _minAmountOut,
        uint256 _nonce,
        uint256 _maxFee,
        uint256 _priceInBABL,
        uint256 _pricePerShare,
        uint256[2] calldata _feeAndLock,
        address _contributor,
        address _referrer,
        bytes memory _signature
    ) external;
}// MIT

pragma solidity >=0.7.0 <0.9.0;


interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}// MIT

pragma solidity >=0.7.0 <0.9.0;

interface ICToken is IERC20 {
    function mint(uint256 mintAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function accrueInterest() external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function exchangeRateStored() external view returns (uint256);

    function getCash() external view returns (uint256);

    function borrowRatePerBlock() external view returns (uint256);

    function totalBorrows() external view returns (uint256);

    function underlying() external view returns (address);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function repayBorrowBehalf(address borrower, uint256 amount) external payable returns (uint256);

    function borrowBalanceCurrent(address account) external view returns (uint256);

    function supplyRatePerBlock() external returns (uint256);
}// MIT

pragma solidity >=0.7.0 <0.9.0;

interface ICEther {
    function mint() external payable;

    function borrow(uint256 borrowAmount) external returns (uint256);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function repayBorrow() external payable;

    function getCash() external view returns (uint256);

    function repayBorrowBehalf(address borrower) external payable;

    function borrowBalanceCurrent(address account) external returns (uint256);

    function borrowBalanceStored(address account) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);
}// MIT

pragma solidity >=0.7.0 <0.9.0;

interface IComptroller {
    function isComptroller() external view returns (bool);

    function markets(address _cToken) external view returns (bool, uint256);

    function getRewardsDistributors() external view returns (address[] memory);


    function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);

    function exitMarket(address cToken) external returns (uint256);

    function getAllMarkets() external view returns (address[] memory);

    function _borrowGuardianPaused() external view returns (bool);

    function borrowGuardianPaused(address _asset) external view returns (bool);

    function borrowCaps(address _asset) external view returns (uint256);

    function compAccrued(address holder) external view returns (uint256);


    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getAssetsIn(address account) external view returns (address[] memory);

    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);

    function mintVerify(
        address cToken,
        address minter,
        uint256 mintAmount,
        uint256 mintTokens
    ) external;

    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);

    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;

    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);

    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;

    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 borrowerIndex
    ) external;

    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount,
        uint256 seizeTokens
    ) external;

    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);

    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;

    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);

    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;


    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 repayAmount
    ) external view returns (uint256, uint256);
}// Apache-2.0

pragma solidity 0.7.6;

interface ICurveMetaRegistry {

    function updatePoolsList() external;

    function updateCryptoRegistries() external;


    function isPool(address _poolAddress) external view returns (bool);

    function gaugeToPool(address _gaugeAddress) external view returns (address);

    function getGauge(address _pool) external view returns (address);

    function getCoinAddresses(address _pool, bool _getUnderlying) external view returns (address[8] memory);

    function getNCoins(address _pool) external view returns (uint256);

    function getLpToken(address _pool) external view returns (address);

    function getPoolFromLpToken(address _lpToken) external view returns (address);

    function getVirtualPriceFromLpToken(address _pool) external view returns (uint256);

    function isMeta(address _pool) external view returns (bool);

    function getUnderlyingAndRate(address _pool, uint256 _i) external view returns (address, uint256);

    function findBestPoolForCoins(address _fromToken, address _toToken) external view returns (address);

    function getCoinIndices(
        address _pool,
        address _fromToken,
        address _toToken
    )
        external
        view
        returns (
            uint256,
            uint256,
            bool
        );
}// Apache-2.0

pragma solidity 0.7.6;

interface IPickleJarRegistry {

    function updateJars(
        address[] calldata _jars,
        bool[] calldata _values,
        bool[] calldata _uniflags
    ) external;


    function jars(address _jarAddress) external view returns (bool);

    function noSwapParam(address _jarAddress) external view returns (bool);

    function isUniv3(address _jarAddress) external view returns (bool);

    function getJarStrategy(address _jarAddress) external view returns (address);

    function getJarGauge(address _jarAddress) external view returns (address);

    function getJarFromGauge(address _gauge) external view returns (address);

    function getAllJars() external view returns (address[] memory);

    function getAllGauges() external view returns (address[] memory);
}// MIT

pragma solidity ^0.7.6;

interface IBooster {
    function depositAll(uint256 _pid, bool _stake) external returns (bool);

    function poolInfo(uint256)
        external
        view
        returns (
            address,
            address,
            address,
            address,
            address,
            bool
        );

    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);

    function withdraw(uint256 _pid, uint256 _amount) external returns (bool);

    function withdrawAll(uint256 _pid) external returns (bool);

    function poolLength() external view returns (uint256);
}// Apache-2.0

pragma solidity 0.7.6;


interface IConvexRegistry {

    function updateCache() external;


    function getPid(address _asset) external view returns (bool, uint256);

    function convexPools(address _convexAddress) external view returns (bool);

    function booster() external view returns (IBooster);

    function getRewardPool(address _asset) external view returns (address reward);

    function getConvexInputToken(address _pool) external view returns (address inputToken);

    function getAllConvexPools() external view returns (address[] memory);
}// Apache-2.0

pragma solidity 0.7.6;

interface IYearnVaultRegistry {

    function updateVaults(address[] calldata _jars, bool[] calldata _values) external;


    function vaults(address _vaultAddress) external view returns (bool);

    function getAllVaults() external view returns (address[] memory);
}// Apache-2.0

pragma solidity 0.7.6;


interface ITokenIdentifier {

    function identifyTokens(address _tokenIn, address _tokenOut)
        external
        view
        returns (
            uint8,
            uint8,
            address,
            address
        );

    function convexPools(address _pool) external view returns (bool);

    function jars(address _jar) external view returns (uint8);

    function pickleGauges(address _gauge) external view returns (bool);

    function visors(address _visor) external view returns (bool);

    function vaults(address _vault) external view returns (bool);

    function aTokenToAsset(address _aToken) external view returns (address);

    function cTokenToAsset(address _cToken) external view returns (address);

    function jarRegistry() external view returns (IPickleJarRegistry);

    function vaultRegistry() external view returns (IYearnVaultRegistry);

    function curveMetaRegistry() external view returns (ICurveMetaRegistry);

    function convexRegistry() external view returns (IConvexRegistry);


    function updateVisor(address[] calldata _vaults, bool[] calldata _values) external;

    function refreshAAveReserves() external;

    function refreshCompoundTokens() external;

    function updateYearnVaults() external;

    function updatePickleJars() external;

    function updateConvexPools() external;

    function updateYearnVault(address[] calldata _vaults, bool[] calldata _values) external;

    function updateAavePair(address[] calldata _aaveTokens, address[] calldata _underlyings) external;

    function updateCompoundPair(address[] calldata _cTokens, address[] calldata _underlyings) external;
}// Apache-2.0

pragma solidity 0.7.6;


interface IPriceOracle {

    function getPrice(address _assetOne, address _assetTwo) external view returns (uint256);

    function getPriceNAV(address _assetOne, address _assetTwo) external view returns (uint256);

    function updateReserves(address[] memory list) external;

    function updateMaxTwapDeviation(int24 _maxTwapDeviation) external;

    function updateTokenIdentifier(ITokenIdentifier _tokenIdentifier) external;

    function getCompoundExchangeRate(address _asset, address _finalAsset) external view returns (uint256);

    function getCreamExchangeRate(address _asset, address _finalAsset) external view returns (uint256);
}// Apache-2.0

pragma solidity 0.7.6;

interface IBaseIntegration {
    function name() external view returns (string memory);
}// Apache-2.0

pragma solidity 0.7.6;


interface ITradeIntegration is IBaseIntegration {
    function trade(
        address _strategy,
        address _sendToken,
        uint256 _sendQuantity,
        address _receiveToken,
        uint256 _minReceiveQuantity
    ) external;

    function trade(
        address _strategy,
        address _sendToken,
        uint256 _sendQuantity,
        address _receiveToken,
        uint256 _minReceiveQuantity,
        address _hopToken
    ) external;
}// Apache-2.0

pragma solidity 0.7.6;


interface IMasterSwapper is ITradeIntegration {

    function isTradeIntegration(address _integration) external view returns (bool);
}// Apache-2.0

pragma solidity 0.7.6;


interface IVoteToken {
    function delegate(address delegatee) external;

    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bool prefix
    ) external;

    function getCurrentVotes(address account) external view returns (uint96);

    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint96);

    function getMyDelegatee() external view returns (address);

    function getDelegatee(address account) external view returns (address);

    function getCheckpoints(address account, uint32 id) external view returns (uint32 fromBlock, uint96 votes);

    function getNumberOfCheckpoints(address account) external view returns (uint32);
}

interface IVoteTokenWithERC20 is IVoteToken, IERC20 {}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SignedSafeMath {
    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}// GPL-2.0-or-later

pragma solidity 0.7.6;

library LowGasSafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'SafeMath: division by zero');
        return a / b;
    }
}// Apache-2.0


pragma solidity 0.7.6;



library PreciseUnitMath {
    using LowGasSafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 internal constant PRECISE_UNIT = 10**18;
    int256 internal constant PRECISE_UNIT_INT = 10**18;

    uint256 internal constant MAX_UINT_256 = type(uint256).max;
    int256 internal constant MAX_INT_256 = type(int256).max;
    int256 internal constant MIN_INT_256 = type(int256).min;

    function decimals() internal pure returns (uint256) {
        return 18;
    }

    function preciseUnit() internal pure returns (uint256) {
        return PRECISE_UNIT;
    }

    function preciseUnitInt() internal pure returns (int256) {
        return PRECISE_UNIT_INT;
    }

    function maxUint256() internal pure returns (uint256) {
        return MAX_UINT_256;
    }

    function maxInt256() internal pure returns (int256) {
        return MAX_INT_256;
    }

    function minInt256() internal pure returns (int256) {
        return MIN_INT_256;
    }

    function preciseMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mul(b).div(PRECISE_UNIT);
    }

    function preciseMul(int256 a, int256 b) internal pure returns (int256) {
        return a.mul(b).div(PRECISE_UNIT_INT);
    }

    function preciseMulCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        return a.mul(b).sub(1).div(PRECISE_UNIT).add(1);
    }

    function preciseDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a.mul(PRECISE_UNIT).div(b);
    }

    function preciseDiv(int256 a, int256 b) internal pure returns (int256) {
        return a.mul(PRECISE_UNIT_INT).div(b);
    }

    function preciseDivCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'Cant divide by 0');

        return a > 0 ? a.mul(PRECISE_UNIT).sub(1).div(b).add(1) : 0;
    }

    function divDown(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0, 'Cant divide by 0');
        require(a != MIN_INT_256 || b != -1, 'Invalid input');

        int256 result = a.div(b);
        if (a ^ b < 0 && a % b != 0) {
            result -= 1;
        }

        return result;
    }

    function conservativePreciseMul(int256 a, int256 b) internal pure returns (int256) {
        return divDown(a.mul(b), PRECISE_UNIT_INT);
    }

    function conservativePreciseDiv(int256 a, int256 b) internal pure returns (int256) {
        return divDown(a.mul(PRECISE_UNIT_INT), b);
    }

    function safePower(uint256 a, uint256 pow) internal pure returns (uint256) {
        require(a > 0, 'Value must be positive');

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++) {
            uint256 previousResult = result;

            result = previousResult.mul(a);
        }

        return result;
    }
}// MIT

pragma solidity 0.7.6;


library UniversalERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000);
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function universalTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal returns (bool) {
        if (amount == 0) {
            return true;
        }

        if (isETH(token)) {
            address(uint160(to)).transfer(amount);
            return true;
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }

    function universalTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }

        if (isETH(token)) {
            require(from == msg.sender && msg.value >= amount, 'msg.value is zero');
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                msg.sender.transfer(msg.value.sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }

    function universalApprove(
        IERC20 token,
        address to,
        uint256 amount
    ) internal {
        if (!isETH(token)) {
            if (amount > 0 && token.allowance(address(this), to) > 0) {
                token.safeApprove(to, 0);
            }
            token.safeApprove(to, amount);
        }
    }

    function universalBalanceOf(IERC20 token, address who) internal view returns (uint256) {
        if (isETH(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }

    function universalDecimals(IERC20 token) internal view returns (uint256) {
        if (isETH(token)) {
            return 18;
        }

        (bool success, bytes memory data) = address(token).staticcall(abi.encodeWithSignature('decimals()'));

        return success ? abi.decode(data, (uint256)) : 18;
    }

    function isETH(IERC20 token) internal pure returns (bool) {
        return address(token) == address(ZERO_ADDRESS) || address(token) == address(ETH_ADDRESS);
    }
}// Apache-2.0

pragma solidity 0.7.6;



library SafeDecimalMath {
    using LowGasSafeMath for uint256;
    using UniversalERC20 for IERC20;

    uint8 internal constant decimals = 18;

    uint256 internal constant UNIT = 10**uint256(decimals);

    function unit() internal pure returns (uint256) {
        return UNIT;
    }

    function multiplyDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint256 x,
        uint256 y,
        uint256 precisionUnit
    ) private pure returns (uint256) {
        uint256 quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRound(uint256 x, uint256 y) internal pure returns (uint256) {
        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint256 x,
        uint256 y,
        uint256 precisionUnit
    ) private pure returns (uint256) {
        uint256 resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint256 x, uint256 y) internal pure returns (uint256) {
        return _divideDecimalRound(x, y, UNIT);
    }

    function normalizeAmountTokens(
        address _from,
        address _to,
        uint256 _amount
    ) internal view returns (uint256) {
        uint256 fromDecimals = IERC20(_from).universalDecimals();
        uint256 toDecimals = IERC20(_to).universalDecimals();

        if (fromDecimals == toDecimals) {
            return _amount;
        }
        if (toDecimals > fromDecimals) {
            return _amount.mul(10**(toDecimals - (fromDecimals)));
        }
        return _amount.div(10**(fromDecimals - (toDecimals)));
    }
}