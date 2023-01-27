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

interface IUniswapV3SwapCallback {

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;

}// GPL-2.0-or-later
pragma solidity >=0.4.0;

library FixedPoint128 {

    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
}// GPL-2.0-or-later
pragma solidity >=0.4.0;

library FixedPoint96 {

    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
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
pragma solidity >=0.7.0;

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
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library SafeCast {

    function toUint160(uint256 y) internal pure returns (uint160 z) {

        require((z = uint160(y)) == y);
    }

    function toInt128(int256 y) internal pure returns (int128 z) {

        require((z = int128(y)) == y);
    }

    function toInt256(uint256 y) internal pure returns (int256 z) {

        require(y < 2**255);
        z = int256(y);
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library UnsafeMath {

    function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {

        assembly {
            z := add(div(x, y), gt(mod(x, y), 0))
        }
    }
}// BUSL-1.1
pragma solidity >=0.5.0;



library SqrtPriceMath {

    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    function getNextSqrtPriceFromAmount0RoundingUp(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {

        if (amount == 0) return sqrtPX96;
        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;

        if (add) {
            uint256 product;
            if ((product = amount * sqrtPX96) / amount == sqrtPX96) {
                uint256 denominator = numerator1 + product;
                if (denominator >= numerator1)
                    return uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator));
            }

            return uint160(UnsafeMath.divRoundingUp(numerator1, (numerator1 / sqrtPX96).add(amount)));
        } else {
            uint256 product;
            require((product = amount * sqrtPX96) / amount == sqrtPX96 && numerator1 > product);
            uint256 denominator = numerator1 - product;
            return FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator).toUint160();
        }
    }

    function getNextSqrtPriceFromAmount1RoundingDown(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {

        if (add) {
            uint256 quotient =
                (
                    amount <= type(uint160).max
                        ? (amount << FixedPoint96.RESOLUTION) / liquidity
                        : FullMath.mulDiv(amount, FixedPoint96.Q96, liquidity)
                );

            return uint256(sqrtPX96).add(quotient).toUint160();
        } else {
            uint256 quotient =
                (
                    amount <= type(uint160).max
                        ? UnsafeMath.divRoundingUp(amount << FixedPoint96.RESOLUTION, liquidity)
                        : FullMath.mulDivRoundingUp(amount, FixedPoint96.Q96, liquidity)
                );

            require(sqrtPX96 > quotient);
            return uint160(sqrtPX96 - quotient);
        }
    }

    function getNextSqrtPriceFromInput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountIn,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {

        require(sqrtPX96 > 0);
        require(liquidity > 0);

        return
            zeroForOne
                ? getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountIn, true)
                : getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountIn, true);
    }

    function getNextSqrtPriceFromOutput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountOut,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {

        require(sqrtPX96 > 0);
        require(liquidity > 0);

        return
            zeroForOne
                ? getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountOut, false)
                : getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountOut, false);
    }

    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount0) {

        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;
        uint256 numerator2 = sqrtRatioBX96 - sqrtRatioAX96;

        require(sqrtRatioAX96 > 0);

        return
            roundUp
                ? UnsafeMath.divRoundingUp(
                    FullMath.mulDivRoundingUp(numerator1, numerator2, sqrtRatioBX96),
                    sqrtRatioAX96
                )
                : FullMath.mulDiv(numerator1, numerator2, sqrtRatioBX96) / sqrtRatioAX96;
    }

    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount1) {

        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            roundUp
                ? FullMath.mulDivRoundingUp(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96)
                : FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) internal pure returns (int256 amount0) {

        return
            liquidity < 0
                ? -getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(-liquidity), false).toInt256()
                : getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(liquidity), true).toInt256();
    }

    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) internal pure returns (int256 amount1) {

        return
            liquidity < 0
                ? -getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(-liquidity), false).toInt256()
                : getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(liquidity), true).toInt256();
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
pragma solidity >=0.5.0 <0.8.0;

library BytesLib {

    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    ) internal pure returns (bytes memory) {

        require(_length + 31 >= _length, 'slice_overflow');
        require(_start + _length >= _start, 'slice_overflow');
        require(_bytes.length >= _start + _length, 'slice_outOfBounds');

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
                case 0 {
                    tempBytes := mload(0x40)

                    let lengthmod := and(_length, 31)

                    let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                    let end := add(mc, _length)

                    for {
                        let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                    } lt(mc, end) {
                        mc := add(mc, 0x20)
                        cc := add(cc, 0x20)
                    } {
                        mstore(mc, mload(cc))
                    }

                    mstore(tempBytes, _length)

                    mstore(0x40, and(add(mc, 31), not(31)))
                }
                default {
                    tempBytes := mload(0x40)
                    mstore(tempBytes, 0)

                    mstore(0x40, add(tempBytes, 0x20))
                }
        }

        return tempBytes;
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {

        require(_start + 20 >= _start, 'toAddress_overflow');
        require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {

        require(_start + 3 >= _start, 'toUint24_overflow');
        require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
        uint24 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }

        return tempUint;
    }
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
pragma solidity >=0.6.0;


library Path {

    using BytesLib for bytes;

    uint256 private constant ADDR_SIZE = 20;
    uint256 private constant FEE_SIZE = 3;

    uint256 private constant NEXT_OFFSET = ADDR_SIZE + FEE_SIZE;
    uint256 private constant POP_OFFSET = NEXT_OFFSET + ADDR_SIZE;
    uint256 private constant MULTIPLE_POOLS_MIN_LENGTH = POP_OFFSET + NEXT_OFFSET;

    function hasMultiplePools(bytes memory path) internal pure returns (bool) {

        return path.length >= MULTIPLE_POOLS_MIN_LENGTH;
    }

    function decodeFirstPool(bytes memory path)
        internal
        pure
        returns (
            address tokenA,
            address tokenB,
            uint24 fee
        )
    {

        tokenA = path.toAddress(0);
        fee = path.toUint24(ADDR_SIZE);
        tokenB = path.toAddress(NEXT_OFFSET);
    }

    function getFirstPool(bytes memory path) internal pure returns (bytes memory) {

        return path.slice(0, POP_OFFSET);
    }

    function skipToken(bytes memory path) internal pure returns (bytes memory) {

        return path.slice(NEXT_OFFSET, path.length - NEXT_OFFSET);
    }
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

library PoolAddress {

    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;

    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {

        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {

        require(key.token0 < key.token1);
        pool = address(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        factory,
                        keccak256(abi.encode(key.token0, key.token1, key.fee)),
                        POOL_INIT_CODE_HASH
                    )
                )
            )
        );
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
}// GPL-2.0-or-later
pragma solidity >=0.4.0;

library FixedPoint64 {

    uint256 internal constant Q64 = 0x10000000000000000;
}// BUSL-1.1
pragma solidity >=0.7.5;


library PathPrice {

    using Path for bytes;

    function getSqrtPriceX96(
        bytes memory path, 
        address uniV3Factory
    ) internal view returns (uint sqrtPriceX96){

        require(path.length > 0, "IPL");

        sqrtPriceX96 = FixedPoint96.Q96;
        uint _nextSqrtPriceX96;
        uint32[] memory secondAges = new uint32[](2);
        secondAges[0] = 0;
        secondAges[1] = 1;
        while (true) {
            (address tokenIn, address tokenOut, uint24 fee) = path.decodeFirstPool();
            IUniswapV3Pool pool = IUniswapV3Pool(PoolAddress.computeAddress(uniV3Factory, PoolAddress.getPoolKey(tokenIn, tokenOut, fee)));

            (_nextSqrtPriceX96,,,,,,) = pool.slot0();
            sqrtPriceX96 = tokenIn > tokenOut
                ? FullMath.mulDiv(sqrtPriceX96, FixedPoint96.Q96, _nextSqrtPriceX96)
                : FullMath.mulDiv(sqrtPriceX96, _nextSqrtPriceX96, FixedPoint96.Q96);

            if (path.hasMultiplePools())
                path = path.skipToken();
            else 
                break; 
        }
    }

    function getSqrtPriceX96Last(
        bytes memory path, 
        address uniV3Factory
    ) internal view returns (uint sqrtPriceX96Last){

        require(path.length > 0, "IPL");

        sqrtPriceX96Last = FixedPoint96.Q96;
        uint _nextSqrtPriceX96;
        uint32[] memory secondAges = new uint32[](2);
        secondAges[0] = 0;
        secondAges[1] = 1;
        while (true) {
            (address tokenIn, address tokenOut, uint24 fee) = path.decodeFirstPool();
            IUniswapV3Pool pool = IUniswapV3Pool(PoolAddress.computeAddress(uniV3Factory, PoolAddress.getPoolKey(tokenIn, tokenOut, fee)));

            (int56[] memory tickCumulatives,) = pool.observe(secondAges);
            _nextSqrtPriceX96 = TickMath.getSqrtRatioAtTick(int24(tickCumulatives[0] - tickCumulatives[1]));
            sqrtPriceX96Last = tokenIn > tokenOut
                ? FullMath.mulDiv(sqrtPriceX96Last, FixedPoint96.Q96, _nextSqrtPriceX96)
                : FullMath.mulDiv(sqrtPriceX96Last, _nextSqrtPriceX96, FixedPoint96.Q96);

            if (path.hasMultiplePools())
                path = path.skipToken();
            else 
                break;
        }
    }

    function verifySlippage(
        bytes memory path, 
        address uniV3Factory, 
        uint32 maxSqrtSlippage
    ) internal view returns(uint) { 

        uint last = getSqrtPriceX96Last(path, uniV3Factory);
        uint current = getSqrtPriceX96(path, uniV3Factory);
        if(last > current) require(current > FullMath.mulDiv(maxSqrtSlippage, last, 1e4), "VS");
        return current;
    }
}// BUSL-1.1
pragma solidity >=0.7.5;


library Position {

    using LowGasSafeMath for uint;
    using SafeCast for int256;

    uint constant DIVISOR = 100 << 128;

    struct Info {
        bool isEmpty;
        int24 tickLower;
        int24 tickUpper;
    }

    function getAmountsForAmount0(
        uint160 sqrtPriceX96, 
        uint160 sqrtPriceL96,
        uint160 sqrtPriceU96,
        uint deltaX
    ) internal pure returns(uint amount0, uint amount1){

        if(sqrtPriceX96 <= sqrtPriceL96){
            amount0 = deltaX;
        }
        else if( sqrtPriceX96 < sqrtPriceU96){
            uint a = FullMath.mulDiv(sqrtPriceU96, sqrtPriceX96 - sqrtPriceL96, FixedPoint64.Q64);
            uint b = FullMath.mulDiv(sqrtPriceX96, sqrtPriceU96 - sqrtPriceX96, FixedPoint64.Q64);
            amount0 = FullMath.mulDiv(deltaX, b, a + b);
        }
        if(deltaX > amount0){
            amount1 = FullMath.mulDiv(
                deltaX.sub(amount0), 
                FullMath.mulDiv(sqrtPriceX96, sqrtPriceX96, FixedPoint64.Q64), 
                FixedPoint128.Q128
            );
        }
    }

    function getAmountOutMin(
        uint curSqrtPirceX96, 
        uint maxPriceImpact, 
        uint amountIn
    ) internal pure returns(uint amountOutMin){

        amountOutMin = FullMath.mulDiv(
            FullMath.mulDiv(amountIn, FullMath.mulDiv(curSqrtPirceX96, curSqrtPirceX96, FixedPoint64.Q64), FixedPoint128.Q128), 
            1e4 - maxPriceImpact, // maxPriceImpact最大1e4，不会溢出
            1e4);
    }

    struct SwapParams{
        uint amount;
        uint amount0;
        uint amount1;
        uint160 sqrtPriceX96;
        uint160 sqrtRatioAX96;
        uint160 sqrtRatioBX96;
        address token;
        address token0;
        address token1;
        uint24 fee;
        address uniV3Factory;
        address uniV3Router;
        uint32 maxSqrtSlippage;
        uint32 maxPriceImpact;
    }

    function computeSwapAmounts(
        SwapParams memory params,
        mapping(address => bytes) storage buyPath
    ) internal returns(uint amount0Max, uint amount1Max) {

        uint equalAmount0;
        bytes memory buy0Path;
        bytes memory buy1Path;
        uint buy0SqrtPriceX96;
        uint buy1SqrtPriceX96;
        uint amountIn;

        if(params.amount > 0){
            if(params.token == params.token0){
                buy1Path = buyPath[params.token1];
                buy1SqrtPriceX96 = PathPrice.verifySlippage(buy1Path, params.uniV3Factory, params.maxSqrtSlippage);
                equalAmount0 = params.amount0.add(params.amount);
            } else {
                buy0Path = buyPath[params.token0];
                buy0SqrtPriceX96 = PathPrice.verifySlippage(buy0Path, params.uniV3Factory, params.maxSqrtSlippage);
                if(params.token != params.token1) {
                    buy1Path = buyPath[params.token1];
                    buy1SqrtPriceX96 = PathPrice.verifySlippage(buy1Path, params.uniV3Factory, params.maxSqrtSlippage);
                }
                equalAmount0 = params.amount0.add((FullMath.mulDiv(
                    params.amount,
                    FullMath.mulDiv(buy0SqrtPriceX96, buy0SqrtPriceX96, FixedPoint64.Q64),
                    FixedPoint128.Q128
                )));
            }
        } 
        else  equalAmount0 = params.amount0;

        if(params.amount1 > 0){
            equalAmount0 = equalAmount0.add((FullMath.mulDiv(
                params.amount1,
                FixedPoint128.Q128,
                FullMath.mulDiv(params.sqrtPriceX96, params.sqrtPriceX96, FixedPoint64.Q64)
            )));
        }
        require(equalAmount0 > 0, "EIZ");

        (amount0Max, amount1Max) = getAmountsForAmount0(params.sqrtPriceX96, params.sqrtRatioAX96, params.sqrtRatioBX96, equalAmount0);

        if(amount0Max > params.amount0) {
            if(amount1Max > params.amount1){
                if(params.token0 == params.token){
                    amountIn = amount0Max - params.amount0;
                    if(amountIn > params.amount) amountIn = params.amount;
                    amount0Max = params.amount0.add(amountIn);
                } else {
                    amountIn = FullMath.mulDiv(
                        amount0Max - params.amount0,
                        FixedPoint128.Q128,
                        FullMath.mulDiv(buy0SqrtPriceX96, buy0SqrtPriceX96, FixedPoint64.Q64)
                    );
                    if(amountIn > params.amount) amountIn = params.amount;
                    if(amountIn > 0) {
                        uint amountOutMin = getAmountOutMin(buy0SqrtPriceX96, params.maxPriceImpact, amountIn);
                        amount0Max = params.amount0.add(ISwapRouter(params.uniV3Router).exactInput(ISwapRouter.ExactInputParams({
                            path: buy0Path,
                            recipient: address(this),
                            deadline: block.timestamp,
                            amountIn: amountIn,
                            amountOutMinimum: amountOutMin
                        })));
                    } else amount0Max = params.amount0;
                }
                if(params.token1 == params.token){
                    amount1Max = params.amount1.add(params.amount.sub(amountIn));
                } else {
                    if(amountIn < params.amount){
                        amountIn = params.amount.sub(amountIn);
                        uint amountOutMin = getAmountOutMin(buy1SqrtPriceX96, params.maxPriceImpact, amountIn);
                        amount1Max = params.amount1.add(ISwapRouter(params.uniV3Router).exactInput(ISwapRouter.ExactInputParams({
                            path: buy1Path,
                            recipient: address(this),
                            deadline: block.timestamp,
                            amountIn: amountIn,
                            amountOutMinimum: amountOutMin
                        })));
                    } 
                    else amount1Max = params.amount1;
                }
            }
            else {
                if (params.amount > 0){
                    if(params.token0 == params.token){
                        amount0Max = params.amount0.add(params.amount);
                    } else{
                        uint amountOutMin = getAmountOutMin(buy0SqrtPriceX96, params.maxPriceImpact, params.amount);
                        amount0Max = params.amount0.add(ISwapRouter(params.uniV3Router).exactInput(ISwapRouter.ExactInputParams({
                            path: buy0Path,
                            recipient: address(this),
                            deadline: block.timestamp,
                            amountIn: params.amount,
                            amountOutMinimum: amountOutMin
                        })));
                    }
                } else amount0Max = params.amount0;

                if(params.amount1 > amount1Max) {
                    amountIn = params.amount1.sub(amount1Max);
                    buy0Path = abi.encodePacked(params.token1, params.fee, params.token0);
                    buy0SqrtPriceX96 = FixedPoint96.Q96 * FixedPoint96.Q96 / params.sqrtPriceX96;// 不会出现溢出
                    uint lastSqrtPriceX96 = PathPrice.getSqrtPriceX96Last(buy0Path, params.uniV3Factory);
                    if(lastSqrtPriceX96 > buy0SqrtPriceX96) 
                        require(buy0SqrtPriceX96 > params.maxSqrtSlippage * lastSqrtPriceX96 / 1e4, "VS");// 不会出现溢出
                    uint amountOutMin = getAmountOutMin(buy0SqrtPriceX96, params.maxPriceImpact, amountIn);
                    amount0Max = amount0Max.add(ISwapRouter(params.uniV3Router).exactInput(ISwapRouter.ExactInputParams({
                        path: buy0Path,
                        recipient: address(this),
                        deadline: block.timestamp,
                        amountIn: amountIn,
                        amountOutMinimum: amountOutMin
                    })));
                }
            }
        }
        else {
            if(params.amount > 0){
                if(params.token1 == params.token){
                    amount1Max = params.amount1.add(params.amount);
                } else {
                    uint amountOutMin = getAmountOutMin(buy1SqrtPriceX96, params.maxPriceImpact, params.amount);
                    amount1Max = params.amount1.add(ISwapRouter(params.uniV3Router).exactInput(ISwapRouter.ExactInputParams({
                        path: buy1Path,
                        recipient: address(this),
                        deadline: block.timestamp,
                        amountIn: params.amount,
                        amountOutMinimum: amountOutMin
                    })));
                }
            } else amount1Max = params.amount1;

            if(params.amount0 > amount0Max){
                amountIn = params.amount0.sub(amount0Max);
                buy1Path = abi.encodePacked(params.token0, params.fee, params.token1);
                buy1SqrtPriceX96 = params.sqrtPriceX96;
                uint lastSqrtPriceX96 = PathPrice.getSqrtPriceX96Last(buy1Path, params.uniV3Factory);
                if(lastSqrtPriceX96 > buy1SqrtPriceX96) 
                    require(buy1SqrtPriceX96 > params.maxSqrtSlippage * lastSqrtPriceX96 / 1e4, "VS");// 不会出现溢出
                uint amountOutMin = getAmountOutMin(buy1SqrtPriceX96, params.maxPriceImpact, amountIn);
                amount1Max = amount1Max.add(ISwapRouter(params.uniV3Router).exactInput(ISwapRouter.ExactInputParams({
                    path: buy1Path,
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: amountIn,
                    amountOutMinimum: amountOutMin
                })));
            }
        }
    }

    struct AddParams {
        uint poolIndex;
        address pool;
        address token;
        uint amount;
        uint amount0Max;
        uint amount1Max;
        address uniV3Router;
        address uniV3Factory;
        uint32 maxSqrtSlippage;
        uint32 maxPriceImpact;
    }

    function addLiquidity(
        Info storage self,
        AddParams memory params,
        mapping(address => bytes) storage sellPath,
        mapping(address => bytes) storage buyPath
    ) public returns(uint128 liquidity) {

        (int24 tickLower, int24 tickUpper) = (self.tickLower, self.tickUpper);

        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(params.pool).slot0();

        SwapParams memory swapParams = SwapParams({
            amount: params.amount,
            amount0: params.amount0Max,
            amount1: params.amount1Max,
            sqrtPriceX96: sqrtPriceX96,
            sqrtRatioAX96: TickMath.getSqrtRatioAtTick(tickLower),
            sqrtRatioBX96: TickMath.getSqrtRatioAtTick(tickUpper),
            token: params.token,
            token0: IUniswapV3Pool(params.pool).token0(),
            token1: IUniswapV3Pool(params.pool).token1(),
            fee: IUniswapV3Pool(params.pool).fee(),
            uniV3Router: params.uniV3Router,
            uniV3Factory: params.uniV3Factory,
            maxSqrtSlippage: params.maxSqrtSlippage,
            maxPriceImpact: params.maxPriceImpact
        });
        (params.amount0Max,  params.amount1Max) = computeSwapAmounts(swapParams, buyPath);

        (sqrtPriceX96,,,,,,) = IUniswapV3Pool(params.pool).slot0();

        liquidity = LiquidityAmounts.getLiquidityForAmounts(sqrtPriceX96, swapParams.sqrtRatioAX96, swapParams.sqrtRatioBX96, params.amount0Max, params.amount1Max);

        require(liquidity > 0, "LIZ");
        (uint amount0, uint amount1) = IUniswapV3Pool(params.pool).mint(
            address(this),// LP recipient
            tickLower,
            tickUpper,
            liquidity,
            abi.encode(params.poolIndex)
        );

        if(amount0 < params.amount0Max){
            if(swapParams.token0 != params.token){
                ISwapRouter(params.uniV3Router).exactInput(ISwapRouter.ExactInputParams({
                    path: sellPath[swapParams.token0],
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: params.amount0Max - amount0,
                    amountOutMinimum: 0
                }));
            }
        }
        if(amount1 < params.amount1Max){
            if(swapParams.token1 != params.token){
                ISwapRouter(params.uniV3Router).exactInput(ISwapRouter.ExactInputParams({
                    path: sellPath[swapParams.token1],
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: params.amount1Max - amount1,
                    amountOutMinimum: 0
                }));
            }
        }

        if(self.isEmpty) self.isEmpty = false;
    }

    function burnAndCollect(
        Info storage self,
        address pool,
        uint proportionX128
    ) public returns(uint amount0, uint amount1) {

        require(proportionX128 <= DIVISOR, "PTL");

        if(self.isEmpty == true) return(amount0, amount1);

        int24 tickLower = self.tickLower;
        int24 tickUpper = self.tickUpper;

        IUniswapV3Pool _pool = IUniswapV3Pool(pool);
        if(proportionX128 > 0) {
            (uint sumLP, , , , ) = _pool.positions(PositionKey.compute(address(this), tickLower, tickUpper));
            uint subLP = FullMath.mulDiv(proportionX128, sumLP, DIVISOR);

            _pool.burn(tickLower, tickUpper, uint128(subLP));
            (amount0, amount1) = _pool.collect(address(this), tickLower,  tickUpper, type(uint128).max, type(uint128).max);

            if(sumLP == subLP) self.isEmpty = true;
        }
        else {
            _pool.burn(tickLower, tickUpper, 0);
            (amount0, amount1) = _pool.collect(address(this), tickLower,  tickUpper, type(uint128).max, type(uint128).max);
        }
    }

    struct SubParams {
        address pool;
        address token;
        uint proportionX128;
        address uniV3Router;
        address uniV3Factory;
        uint32 maxSqrtSlippage;
        uint32 maxPriceImpact;
    }

    function subLiquidity (
        Info storage self,
        SubParams memory params,
        mapping(address => bytes) storage sellPath
    ) public returns(uint amount) {
        address token0 = IUniswapV3Pool(params.pool).token0();
        address token1 = IUniswapV3Pool(params.pool).token1();
        uint sqrtPriceX96;
        uint sqrtPriceX96Last;
        uint amountOutMin;

        if(params.maxSqrtSlippage <= 1e4){
            (sqrtPriceX96,,,,,,) = IUniswapV3Pool(params.pool).slot0();
            uint32[] memory secondAges = new uint32[](2);
            secondAges[0] = 0;
            secondAges[1] = 1;
            (int56[] memory tickCumulatives,) = IUniswapV3Pool(params.pool).observe(secondAges);
            sqrtPriceX96Last = TickMath.getSqrtRatioAtTick(int24(tickCumulatives[0] - tickCumulatives[1]));
            if(sqrtPriceX96Last > sqrtPriceX96)
                require(sqrtPriceX96 > params.maxSqrtSlippage * sqrtPriceX96Last / 1e4, "VS");// 不会出现溢出
            
            sqrtPriceX96 = FixedPoint96.Q96 * FixedPoint96.Q96 / sqrtPriceX96; // 不会出现溢出
            sqrtPriceX96Last = FixedPoint96.Q96 * FixedPoint96.Q96 / sqrtPriceX96Last; 
            if(sqrtPriceX96Last > sqrtPriceX96)
                require(sqrtPriceX96 > params.maxSqrtSlippage * sqrtPriceX96Last / 1e4, "VS"); // 不会出现溢出
        }

        (uint amount0, uint amount1) = burnAndCollect(self, params.pool, params.proportionX128);

        if(token0 != params.token){
            if(amount0 > 0){
                bytes memory path = sellPath[token0];
                if(params.maxSqrtSlippage <= 1e4) {
                    sqrtPriceX96 = PathPrice.verifySlippage(path, params.uniV3Factory, params.maxSqrtSlippage);
                    amountOutMin = getAmountOutMin(sqrtPriceX96, params.maxPriceImpact, amount0);    
                }
                amount = ISwapRouter(params.uniV3Router).exactInput(ISwapRouter.ExactInputParams({
                    path: path,
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: amount0,
                    amountOutMinimum: amountOutMin
                }));
            }
        }

        if(token1 != params.token){
            if(amount1 > 0){
                bytes memory path = sellPath[token1];
                if(params.maxSqrtSlippage <= 1e4) {
                    sqrtPriceX96 = PathPrice.verifySlippage(path, params.uniV3Factory, params.maxSqrtSlippage);
                    amountOutMin = getAmountOutMin(sqrtPriceX96, params.maxPriceImpact, amount1);    
                }
                amount = amount.add(ISwapRouter(params.uniV3Router).exactInput(ISwapRouter.ExactInputParams({
                    path: path,
                    recipient: address(this),
                    deadline: block.timestamp,
                    amountIn: amount1,
                    amountOutMinimum: amountOutMin
                })));
            }
        }
    }

    struct AssetsParams {
        address token0;
        address token1;
        uint sqrt0;
        uint sqrt1;
        uint160 sqrtPriceX96;
        int24 tick;
        uint256 feeGrowthGlobal0X128;
        uint256 feeGrowthGlobal1X128;
    }

    function assetsOfPool(
        Info[] storage self,
        address pool,
        address token,
        mapping(address => bytes) storage sellPath,
        address uniV3Factory
    ) public view returns (uint amount, uint[] memory) {

        uint[] memory amounts = new uint[](self.length);
        AssetsParams memory params;
        params.token0 = IUniswapV3Pool(pool).token0();
        params.token1 = IUniswapV3Pool(pool).token1();
        if(params.token0 != token){
            bytes memory path = sellPath[params.token0];
            if(path.length == 0) return(amount, amounts);
            params.sqrt0 = PathPrice.getSqrtPriceX96Last(path, uniV3Factory);
        }
        if(params.token1 != token){
            bytes memory path = sellPath[params.token1];
            if(path.length == 0) return(amount, amounts);
            params.sqrt1 = PathPrice.getSqrtPriceX96Last(path, uniV3Factory);
        }

        (params.sqrtPriceX96, params.tick, , , , , ) = IUniswapV3Pool(pool).slot0();
        params.feeGrowthGlobal0X128 = IUniswapV3Pool(pool).feeGrowthGlobal0X128();
        params.feeGrowthGlobal1X128 = IUniswapV3Pool(pool).feeGrowthGlobal1X128();

        for(uint i=0; i < self.length; i++){
            Position.Info memory position = self[i];
            if(position.isEmpty) continue;
            bytes32 positionKey = keccak256(abi.encodePacked(address(this), position.tickLower, position.tickUpper));
            (uint256 _amount0, uint256 _amount1) =
                getAssetsOfSinglePosition(
                    AssetsOfSinglePosition({
                        pool: pool,
                        positionKey: positionKey,
                        tickLower: position.tickLower,
                        tickUpper: position.tickUpper,
                        tickCurrent: params.tick,
                        sqrtPriceX96: params.sqrtPriceX96,
                        feeGrowthGlobal0X128: params.feeGrowthGlobal0X128,
                        feeGrowthGlobal1X128: params.feeGrowthGlobal1X128
                    })
                );

            uint _amount;
            if(params.token0 != token){
                _amount = FullMath.mulDiv(
                    _amount0,
                    FullMath.mulDiv(params.sqrt0, params.sqrt0, FixedPoint64.Q64),
                    FixedPoint128.Q128);
            }
            else
                _amount = _amount0;

            if(params.token1 != token){
                _amount = _amount.add(FullMath.mulDiv(
                    _amount1,
                    FullMath.mulDiv(params.sqrt1, params.sqrt1, FixedPoint64.Q64),
                    FixedPoint128.Q128));
            }
            else
                _amount = _amount.add(_amount1);

            amounts[i] = _amount;
            amount = amount.add(_amount);
        }
        return(amount, amounts);
    }

    function assets(
        Info storage self,
        address pool,
        address token,
        mapping(address => bytes) storage sellPath,
        address uniV3Factory
    ) public view returns (uint amount) {

        if(self.isEmpty) return 0;

        (uint160 sqrtPriceX96, int24 tick, , , , , ) = IUniswapV3Pool(pool).slot0();

        bytes32 positionKey = keccak256(abi.encodePacked(address(this), self.tickLower, self.tickUpper));

        (uint256 amount0, uint256 amount1) =
            getAssetsOfSinglePosition(
                AssetsOfSinglePosition({
                    pool: pool,
                    positionKey: positionKey,
                    tickLower: self.tickLower,
                    tickUpper: self.tickUpper,
                    tickCurrent: tick,
                    sqrtPriceX96: sqrtPriceX96,
                    feeGrowthGlobal0X128: IUniswapV3Pool(pool).feeGrowthGlobal0X128(),
                    feeGrowthGlobal1X128: IUniswapV3Pool(pool).feeGrowthGlobal1X128()
                })
            );

        if(amount0 > 0){
            address token0 = IUniswapV3Pool(pool).token0();
            if(token0 != token){
                uint sqrt0 = PathPrice.getSqrtPriceX96Last(sellPath[token0], uniV3Factory);
                amount = FullMath.mulDiv(
                    amount0,
                    FullMath.mulDiv(sqrt0, sqrt0, FixedPoint64.Q64),
                    FixedPoint128.Q128);
            } else
                amount = amount0;
        }
        if(amount1 > 0){
            address token1 = IUniswapV3Pool(pool).token1();
            if(token1 != token){
                uint sqrt1 = PathPrice.getSqrtPriceX96Last(sellPath[token1], uniV3Factory);
                amount = amount.add(FullMath.mulDiv(
                    amount1,
                    FullMath.mulDiv(sqrt1, sqrt1, FixedPoint64.Q64),
                    FixedPoint128.Q128));
            } else
                amount = amount.add(amount1);
        }
    }

    struct AssetsOfSinglePosition {
        address pool;
        bytes32 positionKey;
        int24 tickLower;
        int24 tickUpper;
        int24 tickCurrent;
        uint160 sqrtPriceX96;
        uint256 feeGrowthGlobal0X128;
        uint256 feeGrowthGlobal1X128;
    }

    function getAssetsOfSinglePosition(AssetsOfSinglePosition memory params)
        internal
        view
        returns (uint256 amount0, uint256 amount1)
    {

        (
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = IUniswapV3Pool(params.pool).positions(params.positionKey);

        (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) =
            getFeeGrowthInside(
                FeeGrowthInsideParams({
                    pool: params.pool,
                    tickLower: params.tickLower,
                    tickUpper: params.tickUpper,
                    tickCurrent: params.tickCurrent,
                    feeGrowthGlobal0X128: params.feeGrowthGlobal0X128,
                    feeGrowthGlobal1X128: params.feeGrowthGlobal1X128
                })
            );

        amount0 =
            uint256(
                FullMath.mulDiv(
                    feeGrowthInside0X128 - feeGrowthInside0LastX128,
                    liquidity,
                    FixedPoint128.Q128
                )
            );
        amount1 =
            uint256(
                FullMath.mulDiv(
                    feeGrowthInside1X128 - feeGrowthInside1LastX128,
                    liquidity,
                    FixedPoint128.Q128
                )
            );

        amount0 = amount0.add(tokensOwed0);
        amount1 = amount1.add(tokensOwed1);

        if (params.tickCurrent < params.tickLower) {
            amount0 = amount0.add(uint256(
                -SqrtPriceMath.getAmount0Delta(
                    TickMath.getSqrtRatioAtTick(params.tickLower),
                    TickMath.getSqrtRatioAtTick(params.tickUpper),
                    -int256(liquidity).toInt128()
                )
            ));
        } else if (params.tickCurrent < params.tickUpper) {
            amount0 = amount0.add(uint256(
                -SqrtPriceMath.getAmount0Delta(
                    params.sqrtPriceX96,
                    TickMath.getSqrtRatioAtTick(params.tickUpper),
                    -int256(liquidity).toInt128()
                )
            ));
            amount1 = amount1.add(uint256(
                -SqrtPriceMath.getAmount1Delta(
                    TickMath.getSqrtRatioAtTick(params.tickLower),
                    params.sqrtPriceX96,
                    -int256(liquidity).toInt128()
                )
            ));
        } else {
            amount1 = amount1.add(uint256(
                -SqrtPriceMath.getAmount1Delta(
                    TickMath.getSqrtRatioAtTick(params.tickLower),
                    TickMath.getSqrtRatioAtTick(params.tickUpper),
                    -int256(liquidity).toInt128()
                )
            ));
        }
    }

    struct FeeGrowthInsideParams {
        address pool;
        int24 tickLower;
        int24 tickUpper;
        int24 tickCurrent;
        uint256 feeGrowthGlobal0X128;
        uint256 feeGrowthGlobal1X128;
    }

    function getFeeGrowthInside(FeeGrowthInsideParams memory params)
        internal
        view
        returns (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128)
    {

        IUniswapV3Pool _pool = IUniswapV3Pool (params.pool);
        uint256 lower_feeGrowthOutside0X128;
        uint256 lower_feeGrowthOutside1X128;
        ( , , lower_feeGrowthOutside0X128, lower_feeGrowthOutside1X128, , , ,)
            = _pool.ticks(params.tickLower);

        uint256 feeGrowthBelow0X128;
        uint256 feeGrowthBelow1X128;
        if (params.tickCurrent >= params.tickLower) {
            feeGrowthBelow0X128 = lower_feeGrowthOutside0X128;
            feeGrowthBelow1X128 = lower_feeGrowthOutside1X128;
        } else {
            feeGrowthBelow0X128 = params.feeGrowthGlobal0X128 - lower_feeGrowthOutside0X128;
            feeGrowthBelow1X128 = params.feeGrowthGlobal1X128 - lower_feeGrowthOutside1X128;
        }

        uint256 upper_feeGrowthOutside0X128;
        uint256 upper_feeGrowthOutside1X128;
        ( , , upper_feeGrowthOutside0X128, upper_feeGrowthOutside1X128, , , , ) =
            _pool.ticks(params.tickUpper);

        uint256 feeGrowthAbove0X128;
        uint256 feeGrowthAbove1X128;
        if (params.tickCurrent < params.tickUpper) {
            feeGrowthAbove0X128 = upper_feeGrowthOutside0X128;
            feeGrowthAbove1X128 = upper_feeGrowthOutside1X128;
        } else {
            feeGrowthAbove0X128 = params.feeGrowthGlobal0X128 - upper_feeGrowthOutside0X128;
            feeGrowthAbove1X128 = params.feeGrowthGlobal1X128 - upper_feeGrowthOutside1X128;
        }

        feeGrowthInside0X128 = params.feeGrowthGlobal0X128 - feeGrowthBelow0X128 - feeGrowthAbove0X128;
        feeGrowthInside1X128 = params.feeGrowthGlobal1X128 - feeGrowthBelow1X128 - feeGrowthAbove1X128;
    }
}