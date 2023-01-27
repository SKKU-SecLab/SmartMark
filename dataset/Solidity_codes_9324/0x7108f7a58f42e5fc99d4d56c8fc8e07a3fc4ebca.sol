pragma solidity >=0.7.5;

interface IFactory {


    event VaultCreation(
        address indexed strategyManager,
        address indexed uniswapPool,
        address indexed vaultAddress
    );

    event GovernanceChange(
        address indexed oldGovernance,
        address indexed newGovernance
    );

    function vaultManager(address _vault)
        external
        view
        returns (address _manager);


    function managerVault(address _manager)
        external
        view
        returns (address _vault);


    function createVault(
        address _uniswapPool,
        address _strategyManager,
        uint256 _protocolFee,
        uint256 _strategyFee,
        uint256 _maxCappedLimit
    ) external;


    function updateManager(address _newManager, address _vault) external;


    function router() external view returns (address _router);


    function governance() external view returns (address _governance);



    function pendingGovernance()
        external
        view
        returns (address _pendingGovernance);


    function setRouter(address _router) external;


    function setGovernance(address _governance) external;


    function acceptGovernance() external;

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

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IUniswapV3MintCallback {
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external;
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

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library TickMath {
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(MAX_TICK), 'T');

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

        if (tick > 0) ratio = type(uint256).max / ratio;

        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R');
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
}// MIT
pragma solidity >=0.4.0;

library FullMath {
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
            require(result < type(uint256).max);
            result++;
        }
    }
}// GPL-2.0-or-later
pragma solidity >=0.4.0;

library FixedPoint96 {
    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}// GPL-2.0-or-later
pragma solidity >=0.5.0;


library LiquidityAmounts {
    function toUint128(uint256 x) private pure returns (uint128 y) {
        require((y = uint128(x)) == x);
    }

    function getLiquidityForAmount0(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        uint256 intermediate = FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, FixedPoint96.Q96);
        return toUint128(FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
    }

    function getLiquidityForAmount1(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return toUint128(FullMath.mulDiv(amount1, FixedPoint96.Q96, sqrtRatioBX96 - sqrtRatioAX96));
    }

    function getLiquidityForAmounts(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            liquidity = getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            uint128 liquidity0 = getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
            uint128 liquidity1 = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);

            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        } else {
            liquidity = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
        }
    }

    function getAmount0ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            FullMath.mulDiv(
                uint256(liquidity) << FixedPoint96.RESOLUTION,
                sqrtRatioBX96 - sqrtRatioAX96,
                sqrtRatioBX96
            ) / sqrtRatioAX96;
    }

    function getAmount1ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            amount0 = getAmount0ForLiquidity(sqrtRatioX96, sqrtRatioBX96, liquidity);
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioX96, liquidity);
        } else {
            amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
        }
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library PositionKey {
    function compute(
        address owner,
        int24 tickLower,
        int24 tickUpper
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(owner, tickLower, tickUpper));
    }
}// MIT

pragma solidity >=0.7.5;


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}pragma solidity >=0.7.5;


interface IVault is IERC20 {

    event Deposit(
        address indexed sender,
        address indexed to,
        uint256 shares,
        uint256 amount0,
        uint256 amount1
    );

    event Withdraw(
        address indexed sender,
        address indexed to,
        uint256 shares,
        uint256 amount0,
        uint256 amount1
    );

    event CollectFees(
        uint256 feesToVault0,
        uint256 feesToVault1,
        uint256 feesToStrategy0,
        uint256 feesToStrategy1
    );

    function token0() external view returns (IERC20Metadata);

    function token1() external view returns (IERC20Metadata);

    function getBalance0() external view returns (uint256);

    function getBalance1() external view returns (uint256);

    function tickSpacing() external view returns (int24);

    function baseLower() external view returns (int24);

    function baseUpper() external view returns (int24);

    function limitLower() external view returns (int24);

    function limitUpper() external view returns (int24);

    function pool() external view returns (IUniswapV3Pool);

    function factory() external view returns (IFactory);

    function router() external view returns (address);

    function strategy() external view returns (address);

    function getTotalAmounts() external view returns (uint256, uint256);

    function position(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            uint128,
            uint256,
            uint256,
            uint128,
            uint128
        );

    function getPositionAmounts(int24 tickLower, int24 tickUpper)
        external
        view
        returns (uint256 amount0, uint256 amount1);


    function poke(int24 tickLower, int24 tickUpper) external;

    function setBaseTicks(int24 _baseLower, int24 _baseUpper) external;

    function setLimitTicks(int24 _limitLower, int24 _limitUpper) external;

    function burnAndCollect(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity
    )
        external
        returns (
            uint256 burned0,
            uint256 burned1,
            uint256 feesToVault0,
            uint256 feesToVault1
        );

    function mintOptimalLiquidity(
        int24 _lowerTick,
        int24 _upperTick,
        uint256 amount0,
        uint256 amount1,
        bool swapEnabled
    ) external;

    function swapTokensFromPool(bool direction, uint256 amountInToSwap)
        external
        returns (uint256 amountOut);

    function compoundFee() external;

    function collectStrategy(
        uint256 amount0,
        uint256 amount1,
        address to
    ) external;


    function freezeStrategy(bool value) external;

    function freezeUser(bool value) external;

    function collectProtocol(
        uint256 amount0,
        uint256 amount1,
        address to
    ) external;

    function setMaxTotalSupply(uint256 _maxTotalSupply) external;

    function emergencyBurnAndCollect(address to) external;


    function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 amount0Min,
        uint256 amount1Min,
        address to
    )
        external
        returns (
            uint256 shares,
            uint256 amount0,
            uint256 amount1
        );

    function withdraw(
        uint256 shares,
        uint256 amount0Min,
        uint256 amount1Min,
        address to
    ) external returns (uint256 amount0, uint256 amount1);
}pragma solidity >=0.7.5;

library LongMath {    
    
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
}pragma solidity >=0.7.5;




contract Vault is
    IVault,
    IUniswapV3MintCallback,
    IUniswapV3SwapCallback,
    ERC20,
    ReentrancyGuard
{
    using SafeMath for uint256;
    using LongMath for uint256;
    using SafeERC20 for IERC20Metadata;

    IFactory public override factory;
    ISwapRouter public swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    IUniswapV3Pool public immutable override pool;
    IERC20Metadata public immutable override token0;
    IERC20Metadata public immutable override token1;

    bool public pauseStrategy;
    bool public pauseUser;

    uint256 public protocolFee;
    uint256 public strategyFee;
    uint256 public maxTotalSupply;

    uint256 public accruedProtocolFees0;
    uint256 public accruedStrategyFees0;
    uint256 public accruedProtocolFees1;
    uint256 public accruedStrategyFees1;

    int24 public immutable override tickSpacing;
    int24 public override baseLower;
    int24 public override baseUpper;
    int24 public override limitLower;
    int24 public override limitUpper;

    constructor(
        address _pool,
        uint256 _protocolFee,
        uint256 _strategyFee,
        uint256 _maxTotalSupply
    ) ERC20("Aastra Vault", "AASTRA-ETHPUT") {
        factory = IFactory(msg.sender);
        pool = IUniswapV3Pool(_pool);
        token0 = IERC20Metadata(IUniswapV3Pool(_pool).token0());
        token1 = IERC20Metadata(IUniswapV3Pool(_pool).token1());
        tickSpacing = IUniswapV3Pool(_pool).tickSpacing();

        protocolFee = _protocolFee;
        strategyFee = _strategyFee;

        if (_maxTotalSupply > 0) maxTotalSupply = _maxTotalSupply;
        else maxTotalSupply = type(uint256).max;
    }

    function governance() public view returns (address) {
        return factory.governance();
    }

    function strategy() public view override returns (address) {
        return factory.vaultManager(address(this));
    }

    function router() public view override returns (address) {
        return factory.router();
    }

    function deposit(
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 amount0Min,
        uint256 amount1Min,
        address to
    )
        external
        override
        nonReentrant
        onlyUser
        returns (
            uint256 shares,
            uint256 amount0,
            uint256 amount1
        )
    {
        require(
            amount0Desired > 0 || amount1Desired > 0,
            "amount0Desired or amount1Desired"
        );
        require(to != address(0) && to != address(this), "to");

        poke(baseLower, baseUpper);
        poke(limitLower, limitUpper);

        (shares, amount0, amount1) = _calcSharesAndAmounts(
            amount0Desired,
            amount1Desired
        );

        require(shares > 0, "shares");
        require(amount0 >= amount0Min, "amount0Min");
        require(amount1 >= amount1Min, "amount1Min");

        if (amount0 > 0)
            token0.safeTransferFrom(msg.sender, address(this), amount0);
        if (amount1 > 0)
            token1.safeTransferFrom(msg.sender, address(this), amount1);

        (uint256 baseAmount0, uint256 baseAmount1) = getPositionAmounts(
            baseLower,
            baseUpper
        );
        (uint256 limitAmount0, uint256 limitAmount1) = getPositionAmounts(
            limitLower,
            limitUpper
        );
        {
            (uint256 totalAmount0, uint256 totalAmount1) = getTotalAmounts();
            
            uint256 baseMintAmount0; 
            uint256 baseMintAmount1 ;
            uint256 limitMintAmount0;
            uint256 limitMintAmount1 ;
            
            if (totalAmount0>0){
                baseMintAmount0 = amount0.mul(baseAmount0).div(
                    totalAmount0
                );
                limitMintAmount0 = amount0.mul(limitAmount0).div(
                    totalAmount0
                );
            }
            if (totalAmount1>0){
                baseMintAmount1 = amount1.mul(baseAmount1).div(
                    totalAmount1
                );
                limitMintAmount1 = amount1.mul(limitAmount1).div(
                    totalAmount1
                );
            }
            if (baseMintAmount0 > 0 || baseMintAmount1 > 0) {
                uint128 baseLiquidity = _liquidityForAmounts(
                    baseLower,
                    baseUpper,
                    baseMintAmount0,
                    baseMintAmount1
                );
                mintLiquidity(baseLower, baseUpper, baseLiquidity);
            }

            if (limitMintAmount0 > 0 || limitMintAmount1 > 0) {
                uint128 limitLiquidity = _liquidityForAmounts(
                    limitLower,
                    limitUpper,
                    limitMintAmount0,
                    limitMintAmount1
                );
                mintLiquidity(limitLower, limitUpper, limitLiquidity);
            }
        }
        _mint(to, shares);
        emit Deposit(msg.sender, to, shares, amount0, amount1);
        require(totalSupply() <= maxTotalSupply, "maxTotalSupply");
    }

    function withdraw(
        uint256 shares,
        uint256 amount0Min,
        uint256 amount1Min,
        address to
    )
        external
        override
        nonReentrant
        onlyUser
        returns (uint256 amount0, uint256 amount1)
    {
        require(shares > 0, "shares");
        require(to != address(0) && to != address(this), "to");
        uint256 totalSupply = totalSupply();

        _burn(msg.sender, shares);

        uint256 unusedAmount0 = getBalance0().mul(shares).div(totalSupply);
        uint256 unusedAmount1 = getBalance1().mul(shares).div(totalSupply);

        (uint256 baseAmount0, uint256 baseAmount1) = burnLiquidityShare(
            baseLower,
            baseUpper,
            shares,
            totalSupply
        );

        (uint256 limitAmount0, uint256 limitAmount1) = burnLiquidityShare(
            limitLower,
            limitUpper,
            shares,
            totalSupply
        );

        amount0 = unusedAmount0.add(baseAmount0).add(limitAmount0);
        amount1 = unusedAmount1.add(baseAmount1).add(limitAmount1);
        require(amount0 >= amount0Min, "amount0Min");
        require(amount1 >= amount1Min, "amount1Min");
        if (amount0 > 0) token0.safeTransfer(to, amount0);
        if (amount1 > 0) token1.safeTransfer(to, amount1);

        emit Withdraw(msg.sender, to, shares, amount0, amount1);
    }

    function poke(int24 tickLower, int24 tickUpper) public override {
        (uint128 liquidity, , , , ) = position(tickLower, tickUpper);
        if (liquidity > 0) {
            pool.burn(tickLower, tickUpper, 0);
        }
    }

    function burnLiquidityShare(
        int24 tickLower,
        int24 tickUpper,
        uint256 shares,
        uint256 totalSupply
    ) internal returns (uint256 amount0, uint256 amount1) {
        (uint128 totalLiquidity, , , , ) = position(tickLower, tickUpper);
        uint256 liquidity = uint256(totalLiquidity).mul(shares).div(
            totalSupply
        );

        if (liquidity > 0) {
            (
                uint256 burned0,
                uint256 burned1,
                uint256 fees0,
                uint256 fees1
            ) = _burnAndCollect(tickLower, tickUpper, _toUint128(liquidity));

            amount0 = burned0.add(fees0.mul(shares).div(totalSupply));
            amount1 = burned1.add(fees1.mul(shares).div(totalSupply));
        }
    }

    function performOptimalSwap(
        uint256 actualAmount0,
        uint256 actualAmount1,
        uint256 amount0,
        uint256 amount1
    ) internal returns (uint256 token0AfterSwap, uint256 token1AfterSwap) {

        bool isToken0Excess;
        uint256 amountIn;
        uint256 amountOut;

        if (actualAmount1==0 || actualAmount0 == 0) {
            isToken0Excess = actualAmount0==0;
            amountIn = isToken0Excess? amount0: amount1;
        }
        else {
        uint256 factor = 10 **
            (uint256(18).sub(token1.decimals()).add(token0.decimals()));
        uint256 ratio = actualAmount1.mulDiv(factor, actualAmount0);
        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        uint256 price = uint256(sqrtPriceX96).mul(uint256(sqrtPriceX96)).mul(
            factor
        ) >> (96 * 2);

        uint256 token0Converted = ratio.mulDiv(amount0, factor);
        isToken0Excess = amount1 < token0Converted;

        uint256 excessAmount = isToken0Excess ? token0Converted.sub(amount1).mulDiv(factor, ratio) : amount1.sub(token0Converted);
        amountIn = isToken0Excess
            ? excessAmount.mulDiv(ratio, price.add(ratio))
            : excessAmount.mulDiv(price, price.add(ratio));
        }
        if (amountIn > 0) {
            amountOut = swapTokensFromPool(isToken0Excess, amountIn);
        }

        token0AfterSwap = isToken0Excess
            ? amount0.sub(amountIn)
            : amount0.add(amountOut);

        token1AfterSwap = isToken0Excess
            ? amount1.add(amountOut)
            : amount1.sub(amountIn);

        
    }

    function mintOptimalLiquidity(
        int24 _lowerTick,
        int24 _upperTick,
        uint256 amount0,
        uint256 amount1,
        bool swapEnabled
    ) public override onlyRouter {

        (uint256 actualAmount0, uint256 actualAmount1) = _amountsForLiquidity(
            _lowerTick,
            _upperTick,
            _liquidityForAmounts(_lowerTick, _upperTick,10**token0.decimals(),10**token1.decimals())
        );


        if (swapEnabled) {
            (uint256 token0AfterSwap, uint256 token1AfterSwap) = performOptimalSwap(
                actualAmount0,
                actualAmount1,
                amount0,
                amount1
            );

            mintLiquidity(
                _lowerTick,
                _upperTick,
                _liquidityForAmounts(
                    _lowerTick,
                    _upperTick,
                    token0AfterSwap,
                    token1AfterSwap
                )
            );


        } else {
            mintLiquidity(
                _lowerTick,
                _upperTick,
                _liquidityForAmounts(
                    _lowerTick,
                    _upperTick,
                    amount0,
                    amount1
                )
            );
        }

    }

    function mintLiquidity(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity
    ) internal {
        checkRange(tickLower, tickUpper);
        if (liquidity > 0) {
            pool.mint(address(this), tickLower, tickUpper, liquidity, "");
        }
    }

    function compoundFee() public override onlyRouter {

        collectFeeAndReinvest(baseLower, baseUpper);

        collectFeeAndReinvest(limitLower, limitUpper);
    }

    function collectFeeAndReinvest(int24 tickLower, int24 tickUpper) internal {
        poke(tickLower, tickUpper);

        (uint256 collect0, uint256 collect1) = pool.collect(
            address(this),
            tickLower,
            tickUpper,
            type(uint128).max,
            type(uint128).max
        );

        if (collect0 > 0 && collect1 > 0) {
            (uint256 fee0, uint256 fee1) = calculateFee(collect0, collect1);

            uint128 liquidity = _liquidityForAmounts(
                tickLower,
                tickUpper,
                fee0,
                fee1
            );
            mintLiquidity(tickLower, tickUpper, liquidity);
        }
    }

    function burnAndCollect(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity
    )
        public
        override
        onlyRouter
        returns (
            uint256 burned0,
            uint256 burned1,
            uint256 feesToVault0,
            uint256 feesToVault1
        )
    {
        return _burnAndCollect(tickLower, tickUpper, liquidity);
    }

    function _burnAndCollect(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity
    )
        internal
        returns (
            uint256 burned0,
            uint256 burned1,
            uint256 feesToVault0,
            uint256 feesToVault1
        )
    {
        checkRange(tickLower, tickUpper);
        
        poke(tickLower, tickUpper);
        (uint256 collectedFee0, uint256 collectedFee1) = pool.collect(
            address(this),
            tickLower,
            tickUpper,
            type(uint128).max,
            type(uint128).max
        );

        calculateFee(collectedFee0, collectedFee1);


        if (liquidity > 0) {
            (burned0, burned1) = pool.burn(tickLower, tickUpper, liquidity);
        

            (uint256 collect0, uint256 collect1) = pool.collect(
                address(this),
                tickLower,
                tickUpper,
                type(uint128).max,
                type(uint128).max
            );
        }

    }

    function calculateFee(uint256 feesToVault0, uint256 feesToVault1)
        internal
        returns (uint256, uint256)
    {
        uint256 feesToProtocol0;
        uint256 feesToProtocol1;
        uint256 feesToStrategy0;
        uint256 feesToStrategy1;

        {
            if (protocolFee > 0) {
                feesToProtocol0 = feesToVault0.mul(protocolFee).div(1e6);
                feesToProtocol1 = feesToVault1.mul(protocolFee).div(1e6);
                accruedProtocolFees0 = accruedProtocolFees0.add(
                    feesToProtocol0
                );
                accruedProtocolFees1 = accruedProtocolFees1.add(
                    feesToProtocol1
                );
            }

            if (strategyFee > 0) {
                feesToStrategy0 = feesToVault0.mul(strategyFee).div(1e6);
                feesToStrategy1 = feesToVault1.mul(strategyFee).div(1e6);
                accruedStrategyFees0 = accruedStrategyFees0.add(
                    feesToStrategy0
                );
                accruedStrategyFees1 = accruedStrategyFees1.add(
                    feesToStrategy1
                );
            }

            if (protocolFee > 0) {
                feesToVault0 = feesToVault0.sub(feesToProtocol0);
                feesToVault1 = feesToVault1.sub(feesToProtocol1);
            }
            if (strategyFee > 0) {
                feesToVault0 = feesToVault0.sub(feesToStrategy0);
                feesToVault1 = feesToVault1.sub(feesToStrategy1);
            }
        }

        emit CollectFees(
            feesToVault0,
            feesToVault1,
            feesToStrategy0,
            feesToStrategy1
        );

        return (feesToVault0, feesToVault1);
    }

    function swapTokensFromPool(bool direction, uint256 amountInToSwap)
        public
        override
        nonReentrant
        onlyRouter
        returns (uint256 amountOut)
    {
        address tokenInAddress = direction ? address(token0) : address(token1);
        address tokenOutAddress = direction ? address(token1) : address(token0);

        if (direction) {
            token0.approve(address(swapRouter), amountInToSwap);
        } else {
            token1.approve(address(swapRouter), amountInToSwap);
        }

        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenInAddress,
                tokenOut: tokenOutAddress,
                fee: pool.fee(),
                recipient: address(this),
                deadline: block.timestamp + 10,
                amountIn: amountInToSwap,
                amountOutMinimum: 1,
                sqrtPriceLimitX96: 0
            });
        amountOut = swapRouter.exactInputSingle(swapParams);
    }

    function collectProtocol(
        uint256 amount0,
        uint256 amount1,
        address to
    ) external override onlyGovernance {
        accruedProtocolFees0 = accruedProtocolFees0.sub(amount0);
        accruedProtocolFees1 = accruedProtocolFees1.sub(amount1);
        if (amount0 > 0) token0.safeTransfer(to, amount0);
        if (amount1 > 0) token1.safeTransfer(to, amount1);
    }

    function collectStrategy(
        uint256 amount0,
        uint256 amount1,
        address to
    ) external override onlyStrategy {
        accruedStrategyFees0 = accruedStrategyFees0.sub(amount0);
        accruedStrategyFees1 = accruedStrategyFees1.sub(amount1);
        if (amount0 > 0) token0.safeTransfer(to, amount0);
        if (amount1 > 0) token1.safeTransfer(to, amount1);
    }

    function setBaseTicks(int24 _baseLower, int24 _baseUpper)
        public
        override
        onlyRouter
    {
        (baseLower, baseUpper) = (_baseLower, _baseUpper);
    }

    function setLimitTicks(int24 _limitLower, int24 _limitUpper)
        public
        override
        onlyRouter
    {
        (limitLower, limitUpper) = (_limitLower, _limitUpper);
    }

    function setMaxTotalSupply(uint256 _maxTotalSupply)
        external
        override
        onlyGovernance
    {
        maxTotalSupply = _maxTotalSupply;
    }

    function emergencyBurnAndCollect(address to)
        external
        override
        onlyGovernance
    {

        if (baseLower < baseUpper) {
            (uint128 liquidityBase, , , , ) = position(baseLower, baseUpper);
            if (liquidityBase > 0) {
                pool.burn(baseLower, baseUpper, liquidityBase);
            }
            pool.collect(
                to,
                baseLower,
                baseUpper,
                type(uint128).max,
                type(uint128).max
            );
        }

        if (limitLower < limitUpper) {
            (uint128 liquidityLimit, , , , ) = position(limitLower, limitUpper);
            if (liquidityLimit > 0) {
                pool.burn(limitLower, limitUpper, liquidityLimit);
            }

            pool.collect(
                to,
                limitLower,
                limitUpper,
                type(uint128).max,
                type(uint128).max
            );
        }

        uint256 token0Balance = getBalance0();
        uint256 token1Balance = getBalance1();
        if (token0Balance > 0) token0.safeTransfer(to, getBalance0());
        if (token1Balance > 0) token1.safeTransfer(to, getBalance1());
    }

    function _calcSharesAndAmounts(
        uint256 amount0Desired,
        uint256 amount1Desired
    )
        internal
        view
        returns (
            uint256 shares,
            uint256 amount0,
            uint256 amount1
        )
    {
        uint256 totalSupply = totalSupply();
        (uint256 total0, uint256 total1) = getTotalAmounts();

        assert(totalSupply == 0 || total0 > 0 || total1 > 0);

        if (totalSupply == 0) {
            amount0 = amount0Desired;
            amount1 = amount1Desired;
            shares = Math.max(amount0, amount1);
        } else if (total0 == 0) {
            amount1 = amount1Desired;
            shares = amount1.mul(totalSupply).div(total1);
        } else if (total1 == 0) {
            amount0 = amount0Desired;
            shares = amount0.mul(totalSupply).div(total0);
        } else {
            uint256 cross = Math.min(
                amount0Desired.mul(total1),
                amount1Desired.mul(total0)
            );
            require(cross > 0, "cross");

            amount0 = cross.sub(1).div(total1).add(1);
            amount1 = cross.sub(1).div(total0).add(1);
            shares = cross.mul(totalSupply).div(total0).div(total1);
        }
    }

    function getTotalAmounts()
        public
        view
        override
        returns (uint256 total0, uint256 total1)
    {
        (uint256 baseAmount0, uint256 baseAmount1) = getPositionAmounts(
            baseLower,
            baseUpper
        );
        (uint256 limitAmount0, uint256 limitAmount1) = getPositionAmounts(
            limitLower,
            limitUpper
        );
        total0 = getBalance0().add(baseAmount0).add(limitAmount0);
        total1 = getBalance1().add(baseAmount1).add(limitAmount1);
    }

    function getPositionAmounts(int24 tickLower, int24 tickUpper)
        public
        view
        override
        returns (uint256 amount0, uint256 amount1)
    {
        (
            uint128 liquidity,
            ,
            ,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = position(tickLower, tickUpper);
        (amount0, amount1) = _amountsForLiquidity(
            tickLower,
            tickUpper,
            liquidity
        );

        uint256 oneMinusFee = uint256(1e6).sub(protocolFee).sub(strategyFee);
        amount0 = amount0.add(uint256(tokensOwed0).mul(oneMinusFee).div(1e6));
        amount1 = amount1.add(uint256(tokensOwed1).mul(oneMinusFee).div(1e6));
    }

    function getBalance0() public view override returns (uint256) {
        return
            token0.balanceOf(address(this)).sub(accruedProtocolFees0).sub(
                accruedStrategyFees0
            );
    }

    function getBalance1() public view override returns (uint256) {
        return
            token1.balanceOf(address(this)).sub(accruedProtocolFees1).sub(
                accruedStrategyFees1
            );
    }


    function freezeStrategy(bool value) external override onlyGovernance {
        pauseStrategy = value;
    }

    function freezeUser(bool value) external override onlyGovernance {
        pauseUser = value;
    }

    function _toUint128(uint256 x) internal pure returns (uint128) {
        assert(x <= type(uint128).max);
        return uint128(x);
    }

    modifier onlyGovernance() {
        require(msg.sender == governance(), "tx sender should be governance");
        _;
    }

    modifier onlyStrategy() {
        require(
            msg.sender == strategy() || msg.sender == router(),
            "tx sender should be either the strategy manager or router"
        );
        require(!pauseStrategy, "operations paused for strategy manager");
        _;
    }

    modifier onlyRouter() {
        require(msg.sender == router(), "tx sender should be router");
        require(!pauseStrategy, "operations paused for strategy manager");
        _;
    }

    modifier onlyUser() {
        require(!pauseUser, "operations paused for vault users");
        _;
    }

    function position(int24 tickLower, int24 tickUpper)
        public
        view
        override
        returns (
            uint128,
            uint256,
            uint256,
            uint128,
            uint128
        )
    {
        bytes32 positionKey = PositionKey.compute(
            address(this),
            tickLower,
            tickUpper
        );

        return pool.positions(positionKey);
    }

    function _liquidityForAmounts(
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1
    ) internal view returns (uint128) {
        (uint160 sqrtRatioX96, , , , , , ) = pool.slot0();
        return
            LiquidityAmounts.getLiquidityForAmounts(
                sqrtRatioX96,
                TickMath.getSqrtRatioAtTick(tickLower),
                TickMath.getSqrtRatioAtTick(tickUpper),
                amount0,
                amount1
            );
    }

    function _amountsForLiquidity(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity
    ) internal view returns (uint256, uint256) {
        (uint160 sqrtRatioX96, , , , , , ) = pool.slot0();
        return
            LiquidityAmounts.getAmountsForLiquidity(
                sqrtRatioX96,
                TickMath.getSqrtRatioAtTick(tickLower),
                TickMath.getSqrtRatioAtTick(tickUpper),
                liquidity
            );
    }

    function checkRange(int24 tickLower, int24 tickUpper) internal view {
        int24 _tickSpacing = tickSpacing;
        require(tickLower < tickUpper, "tickLower < tickUpper");
        require(tickLower >= TickMath.MIN_TICK, "tickLower too low");
        require(tickUpper <= TickMath.MAX_TICK, "tickUpper too high");
        require(tickLower % _tickSpacing == 0, "tickLower % tickSpacing");
        require(tickUpper % _tickSpacing == 0, "tickUpper % tickSpacing");
    }

    function uniswapV3MintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override {
        require(msg.sender == address(pool));
        if (amount0 > 0) token0.safeTransfer(msg.sender, amount0);
        if (amount1 > 0) token1.safeTransfer(msg.sender, amount1);
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) public override {
        require(msg.sender == address(pool));

        if (amount0Delta > 0)
            token0.safeTransfer(msg.sender, uint256(amount0Delta));
        if (amount1Delta > 0)
            token1.safeTransfer(msg.sender, uint256(amount1Delta));
    }
}pragma solidity >=0.7.5;


contract Factory is IFactory {
    mapping(address => address) public override vaultManager;

    mapping(address => address) public override managerVault;

    address public override router;
    address public override governance;
    address public override pendingGovernance;

    constructor(address _governance) {
        governance = _governance;
    }

    function createVault(
        address _uniswapPool,
        address _strategyManager,
        uint256 _protocolFee,
        uint256 _strategyFee,
        uint256 _maxCappedLimit
    ) public override onlyGovernance {
        require(
            managerVault[_strategyManager] == address(0),
            "Factory : createVault :: Manager already has a vault"
        );

        Vault newVault = new Vault(
            _uniswapPool,
            _protocolFee,
            _strategyFee,
            _maxCappedLimit
        );

        vaultManager[address(newVault)] = _strategyManager;
        managerVault[_strategyManager] = address(newVault);

        emit VaultCreation(_strategyManager, _uniswapPool, address(newVault));
    }

    function updateManager(address _newManager, address _vault)
        public
        override
        onlyGovernance
    {
        require(
            vaultManager[_vault] != address(0),
            "Factory : updateManager :: Vault does not to exist"
        );
        address oldManager = vaultManager[_vault];
        require(
            managerVault[oldManager] == _vault,
            "Factory : updateManager :: previous manager of vault is corrupted"
        );

        managerVault[oldManager] = address(0);
        managerVault[_newManager] = _vault;
        vaultManager[_vault] = _newManager;

        assert(vaultManager[_vault] != oldManager);
        assert(managerVault[oldManager] == address(0));
    }

    function setRouter(address _router) public override onlyGovernance {
        require(
            _router != address(0),
            "Factory : setRouter :: address cannot be zero"
        );
        router = _router;
    }

    function setGovernance(address _governance)
        external
        override
        onlyGovernance
    {
        pendingGovernance = _governance;
    }

    function acceptGovernance() external override {
        require(
            msg.sender == pendingGovernance,
            "Factory : acceptGovernance :: you need to be pendingGovernance to accept governance"
        );
        emit GovernanceChange(governance, msg.sender);
        governance = msg.sender;
    }

    modifier onlyGovernance() {
        require(
            governance == msg.sender,
            "Factory : Only governance can send the tx"
        );
        _;
    }
}