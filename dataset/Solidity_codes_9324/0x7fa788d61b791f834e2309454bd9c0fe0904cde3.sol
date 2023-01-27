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
pragma solidity >=0.7.5;

interface IQuoter {

    function quoteExactInput(bytes memory path, uint256 amountIn) external returns (uint256 amountOut);


    function quoteExactInputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountIn,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountOut);


    function quoteExactOutput(bytes memory path, uint256 amountOut) external returns (uint256 amountIn);


    function quoteExactOutputSingle(
        address tokenIn,
        address tokenOut,
        uint24 fee,
        uint256 amountOut,
        uint160 sqrtPriceLimitX96
    ) external returns (uint256 amountIn);

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

pragma solidity >=0.7.5;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// UNLICENSED
pragma solidity >=0.7.5;


interface IPeriphery {

    function vaultDeposit(uint256 amount0In, uint256 amount1In, uint256 slippage, address strategy) external;


    function vaultWithdraw(uint256 shares, address strategy, bool direction) external;

}pragma solidity >=0.7.5;

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
}// UNLICENSED
pragma solidity >=0.7.5;



contract Periphery is IPeriphery {

    using SafeMath for uint256;
    using LongMath for uint256;
    using SafeERC20 for IERC20Metadata;
    using SafeERC20 for IVault;

    ISwapRouter public immutable swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IQuoter public immutable quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    
    IFactory public factory;

    constructor(IFactory _factory) {
        factory = _factory;
    } 

    function vaultDeposit(uint256 amount0In, uint256 amount1In, uint256 slippage, address strategy) 
    external override {

        require(slippage <= 100*100, "100% slippage is not allowed");

        (IVault vault, IUniswapV3Pool pool, IERC20Metadata token0, IERC20Metadata token1) = _getVault(strategy);

        uint256 factor = 10 **
            (uint256(18).sub(token1.decimals()).add(token0.decimals()));

        (uint256 amountToSwap, bool direction) = _calculateAmountToSwap(vault, pool, factor, amount0In, amount1In);
        
        IERC20Metadata(direction ? token0 : token1)
            .safeTransferFrom(msg.sender, address(this), direction ? amount0In : amount1In);

        if(amountToSwap > 0) {
            uint256 amountOutQuotedWithSlippage = quoter.quoteExactInputSingle(
                address(direction ? token0 : token1), 
                address(direction ? token1 : token0), 
                pool.fee(), 
                amountToSwap, 
                0
            ).mul(100*100 - slippage).div(100*100);

            _swapTokens(
                direction, 
                address(token0), 
                address(token1), 
                pool.fee(), 
                amountToSwap, 
                amountOutQuotedWithSlippage 
            );
        }

        if(_tokenBalance(token0) > 0) {
            token0.approve(address(vault), _tokenBalance(token0));
        }
        if(_tokenBalance(token1) > 0) {
            token1.approve(address(vault), _tokenBalance(token1));
        }

        vault.deposit(
            _tokenBalance(direction ? token0 : token1), 
            _tokenBalance(direction ? token1 : token0), 
            0, 
            0, 
            msg.sender
        );

        _sendBalancesToUser(token0, token1, msg.sender);
    }

    function vaultWithdraw(uint256 shares, address strategy, bool direction) 
    external override minimumAmount(shares) {

        (IVault vault, IUniswapV3Pool pool, IERC20Metadata token0, IERC20Metadata token1) = _getVault(strategy);

        vault.safeTransferFrom(msg.sender, address(this), shares);
        (uint256 amount0, uint256 amount1) = vault.withdraw(shares, 0, 0, address(this));
        uint256 amountToSwap = direction ? amount0 : amount1;

        if(amountToSwap > 0) {
            _swapTokens(
                direction, 
                address(token0), 
                address(token1), 
                pool.fee(), 
                amountToSwap, 
                0
            );
        }
 
        _sendBalancesToUser(token0, token1, msg.sender);
    }

    function _tokenBalance(IERC20Metadata token) internal view returns (uint256) {

        return token.balanceOf(address(this));
    }

    function _getVault(address strategy) internal view 
        returns (IVault, IUniswapV3Pool, IERC20Metadata, IERC20Metadata) 
    {

        address vaultAddress = factory.managerVault(strategy);
        
        require(vaultAddress != address(0x0), "Not a valid strategy");

        IVault vault = IVault(vaultAddress);
        IUniswapV3Pool pool  = vault.pool();

        IERC20Metadata token0 = vault.token0();
        IERC20Metadata token1 = vault.token1();

        return (vault, pool, token0, token1);
    }

    function _calculateAmountToSwap(IVault vault, IUniswapV3Pool pool, uint256 factor, uint256 amount0In, uint256 amount1In) internal view returns (uint256 amountToSwap, bool isToken0Excess) {

        (uint256 token0InVault, uint256 token1InVault) = vault.getTotalAmounts();

        if(token0InVault == 0 && token1InVault == 0) {
            amountToSwap = 0;
            isToken0Excess = amount1In == 0 ? true : false;
        } else if(token0InVault == 0 || token1InVault == 0) {
            isToken0Excess = token0InVault==0;
            amountToSwap = isToken0Excess ? amount0In : amount1In;
        } else {
            uint256 ratio = token1InVault.mul(factor).div(token0InVault);
            (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
            uint256 price = uint256(sqrtPriceX96).mul(uint256(sqrtPriceX96)).mul(
                factor
            ) >> (96 * 2);

            uint256 token0Converted = ratio.mul(amount0In).div(factor);
            isToken0Excess = amount1In < token0Converted;

            uint256 excessAmount = isToken0Excess ? token0Converted.sub(amount1In).mul(factor).div(ratio) : amount1In.sub(token0Converted);
            amountToSwap = isToken0Excess
                ? excessAmount.mul(ratio).div(price.add(ratio))
                : excessAmount.mul(price).div(price.add(ratio));
        }
    }

    function _sendBalancesToUser(
        IERC20Metadata token0, 
        IERC20Metadata token1, 
        address recipient
    ) internal {

        if(_tokenBalance(token0) > 0) {
            token0.safeTransfer(recipient, _tokenBalance(token0));
        }
        if(_tokenBalance(token1) > 0) {
            token1.safeTransfer(recipient, _tokenBalance(token1));
        }
    }

    function _swapTokens(
        bool direction,
        address token0,
        address token1,
        uint24 fee,
        uint256 amountIn,
        uint256 amountOutMinimum
    ) internal {

        IERC20Metadata(direction ? token0 : token1).approve(address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: direction ? token0 : token1,
                tokenOut:  direction ? token1 : token0,
                fee: fee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: amountOutMinimum,
                sqrtPriceLimitX96: 0
            });
        swapRouter.exactInputSingle(params);
    }

    modifier minimumAmount(uint256 amountIn) {

        require(amountIn > 0, "amountIn not sufficient");
        _;
    }
}