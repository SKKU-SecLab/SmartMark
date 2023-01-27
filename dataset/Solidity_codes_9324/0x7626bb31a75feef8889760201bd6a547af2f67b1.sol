

pragma solidity ^0.8.9;


library BitMath {

    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {

        require(x > 0);

        unchecked {
            if (x >= 0x100000000000000000000000000000000) {
                x >>= 128;
                r += 128;
            }
            if (x >= 0x10000000000000000) {
                x >>= 64;
                r += 64;
            }
            if (x >= 0x100000000) {
                x >>= 32;
                r += 32;
            }
            if (x >= 0x10000) {
                x >>= 16;
                r += 16;
            }
            if (x >= 0x100) {
                x >>= 8;
                r += 8;
            }
            if (x >= 0x10) {
                x >>= 4;
                r += 4;
            }
            if (x >= 0x4) {
                x >>= 2;
                r += 2;
            }
            if (x >= 0x2) r += 1;
        }
    }

    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {

        require(x > 0);

        unchecked {
            r = 255;
            if (x & type(uint128).max > 0) {
                r -= 128;
            } else {
                x >>= 128;
            }
            if (x & type(uint64).max > 0) {
                r -= 64;
            } else {
                x >>= 64;
            }
            if (x & type(uint32).max > 0) {
                r -= 32;
            } else {
                x >>= 32;
            }
            if (x & type(uint16).max > 0) {
                r -= 16;
            } else {
                x >>= 16;
            }
            if (x & type(uint8).max > 0) {
                r -= 8;
            } else {
                x >>= 8;
            }
            if (x & 0xf > 0) {
                r -= 4;
            } else {
                x >>= 4;
            }
            if (x & 0x3 > 0) {
                r -= 2;
            } else {
                x >>= 2;
            }
            if (x & 0x1 > 0) r -= 1;
        }
    }
}


library FixedPoint128 {

    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
}


library FixedPoint96 {

    uint8 internal constant RESOLUTION = 96;
    uint256 internal constant Q96 = 0x1000000000000000000000000;
}


library FullMath {

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        unchecked {
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

            uint256 twos = (0 - denominator) & denominator;
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
    }

    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}


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


    function increaseObservationCardinalityNext(
        uint16 observationCardinalityNext
    ) external;

}


interface IUniswapV3PoolDerivedState {

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (
            int56[] memory tickCumulatives,
            uint160[] memory secondsPerLiquidityCumulativeX128s
        );


    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );

}


interface IUniswapV3PoolErrors {

    error LOK();
    error TLU();
    error TLM();
    error TUM();
    error AI();
    error M0();
    error M1();
    error AS();
    error IIA();
    error L();
    error F0();
    error F1();
}


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

    event SetFeeProtocol(
        uint8 feeProtocol0Old,
        uint8 feeProtocol1Old,
        uint8 feeProtocol0New,
        uint8 feeProtocol1New
    );

    event CollectProtocol(
        address indexed sender,
        address indexed recipient,
        uint128 amount0,
        uint128 amount1
    );
}


interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}


interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}


interface IUniswapV3PoolState {

    struct Slot0 {
        uint160 sqrtPriceX96;
        int24 tick;
        uint16 observationIndex;
        uint16 observationCardinality;
        uint16 observationCardinalityNext;
        uint8 feeProtocol;
        bool unlocked;
    }

    function slot0() external view returns (Slot0 memory);


    function feeGrowthGlobal0X128() external view returns (uint256);


    function feeGrowthGlobal1X128() external view returns (uint256);


    function protocolFees()
        external
        view
        returns (uint128 token0, uint128 token1);


    function liquidity() external view returns (uint128);


    struct TickInfo {
        uint128 liquidityGross;
        int128 liquidityNet;
        uint256 feeGrowthOutside0X128;
        uint256 feeGrowthOutside1X128;
        int56 tickCumulativeOutside;
        uint160 secondsPerLiquidityOutsideX128;
        uint32 secondsOutside;
        bool initialized;
    }

    function ticks(int24 tick) external view returns (TickInfo memory);


    struct PositionInfo {
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    function tickBitmap(int16 wordPosition) external view returns (uint256);


    function positions(bytes32 key) external view returns (PositionInfo memory);


    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );

}


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
}


library TickMath {

    error T();
    error R();

    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;

    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO =
        1461446703485210103287273052203988822378723970342;

    function getSqrtRatioAtTick(int24 tick)
        internal
        pure
        returns (uint160 sqrtPriceX96)
    {

        unchecked {
            uint256 absTick = tick < 0
                ? uint256(-int256(tick))
                : uint256(int256(tick));
            if (absTick > uint256(int256(MAX_TICK))) revert T();

            uint256 ratio = absTick & 0x1 != 0
                ? 0xfffcb933bd6fad37aa2d162d1a594001
                : 0x100000000000000000000000000000000;
            if (absTick & 0x2 != 0)
                ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
            if (absTick & 0x4 != 0)
                ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
            if (absTick & 0x8 != 0)
                ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
            if (absTick & 0x10 != 0)
                ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
            if (absTick & 0x20 != 0)
                ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
            if (absTick & 0x40 != 0)
                ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
            if (absTick & 0x80 != 0)
                ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
            if (absTick & 0x100 != 0)
                ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
            if (absTick & 0x200 != 0)
                ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
            if (absTick & 0x400 != 0)
                ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
            if (absTick & 0x800 != 0)
                ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
            if (absTick & 0x1000 != 0)
                ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
            if (absTick & 0x2000 != 0)
                ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
            if (absTick & 0x4000 != 0)
                ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
            if (absTick & 0x8000 != 0)
                ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
            if (absTick & 0x10000 != 0)
                ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
            if (absTick & 0x20000 != 0)
                ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
            if (absTick & 0x40000 != 0)
                ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
            if (absTick & 0x80000 != 0)
                ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

            if (tick > 0) ratio = type(uint256).max / ratio;

            sqrtPriceX96 = uint160(
                (ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1)
            );
        }
    }

    function getTickAtSqrtRatio(uint160 sqrtPriceX96)
        internal
        pure
        returns (int24 tick)
    {

        unchecked {
            if (
                !(sqrtPriceX96 >= MIN_SQRT_RATIO &&
                    sqrtPriceX96 < MAX_SQRT_RATIO)
            ) revert R();
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

            int24 tickLow = int24(
                (log_sqrt10001 - 3402992956809132418596140100660247210) >> 128
            );
            int24 tickHi = int24(
                (log_sqrt10001 + 291339464771989622907027621153398088495) >> 128
            );

            tick = tickLow == tickHi
                ? tickLow
                : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96
                ? tickHi
                : tickLow;
        }
    }
}


library UnsafeMath {

    function divRoundingUp(uint256 x, uint256 y)
        internal
        pure
        returns (uint256 z)
    {

        assembly {
            z := add(div(x, y), gt(mod(x, y), 0))
        }
    }
}


interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolErrors,
    IUniswapV3PoolEvents
{


}


library LiquidityAmounts {

    function toUint128(uint256 x) private pure returns (uint128 y) {

        require((y = uint128(x)) == x);
    }

    function getLiquidityForAmount0(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0
    ) internal pure returns (uint128 liquidity) {

        if (sqrtRatioAX96 > sqrtRatioBX96)
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        uint256 intermediate = FullMath.mulDiv(
            sqrtRatioAX96,
            sqrtRatioBX96,
            FixedPoint96.Q96
        );
        return
            toUint128(
                FullMath.mulDiv(
                    amount0,
                    intermediate,
                    sqrtRatioBX96 - sqrtRatioAX96
                )
            );
    }

    function getLiquidityForAmount1(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {

        if (sqrtRatioAX96 > sqrtRatioBX96)
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
        return
            toUint128(
                FullMath.mulDiv(
                    amount1,
                    FixedPoint96.Q96,
                    sqrtRatioBX96 - sqrtRatioAX96
                )
            );
    }

    function getLiquidityForAmounts(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {

        if (sqrtRatioAX96 > sqrtRatioBX96)
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            liquidity = getLiquidityForAmount0(
                sqrtRatioAX96,
                sqrtRatioBX96,
                amount0
            );
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            uint128 liquidity0 = getLiquidityForAmount0(
                sqrtRatioX96,
                sqrtRatioBX96,
                amount0
            );
            uint128 liquidity1 = getLiquidityForAmount1(
                sqrtRatioAX96,
                sqrtRatioX96,
                amount1
            );

            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        } else {
            liquidity = getLiquidityForAmount1(
                sqrtRatioAX96,
                sqrtRatioBX96,
                amount1
            );
        }
    }

    function getAmount0ForLiquidity(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0) {

        if (sqrtRatioAX96 > sqrtRatioBX96)
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

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

        if (sqrtRatioAX96 > sqrtRatioBX96)
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            FullMath.mulDiv(
                liquidity,
                sqrtRatioBX96 - sqrtRatioAX96,
                FixedPoint96.Q96
            );
    }

    function getAmountsForLiquidity(
        uint160 sqrtRatioX96,
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity
    ) internal pure returns (uint256 amount0, uint256 amount1) {

        if (sqrtRatioAX96 > sqrtRatioBX96)
            (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        if (sqrtRatioX96 <= sqrtRatioAX96) {
            amount0 = getAmount0ForLiquidity(
                sqrtRatioAX96,
                sqrtRatioBX96,
                liquidity
            );
        } else if (sqrtRatioX96 < sqrtRatioBX96) {
            amount0 = getAmount0ForLiquidity(
                sqrtRatioX96,
                sqrtRatioBX96,
                liquidity
            );
            amount1 = getAmount1ForLiquidity(
                sqrtRatioAX96,
                sqrtRatioX96,
                liquidity
            );
        } else {
            amount1 = getAmount1ForLiquidity(
                sqrtRatioAX96,
                sqrtRatioBX96,
                liquidity
            );
        }
    }
}


library SqrtPriceMath {

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
            unchecked {
                uint256 product;
                if ((product = amount * sqrtPX96) / amount == sqrtPX96) {
                    uint256 denominator = numerator1 + product;
                    if (denominator >= numerator1)
                        return
                            uint160(
                                FullMath.mulDivRoundingUp(
                                    numerator1,
                                    sqrtPX96,
                                    denominator
                                )
                            );
                }
            }
            return
                uint160(
                    UnsafeMath.divRoundingUp(
                        numerator1,
                        (numerator1 / sqrtPX96) + amount
                    )
                );
        } else {
            unchecked {
                uint256 product;
                require(
                    (product = amount * sqrtPX96) / amount == sqrtPX96 &&
                        numerator1 > product
                );
                uint256 denominator = numerator1 - product;
                return
                    FullMath
                        .mulDivRoundingUp(numerator1, sqrtPX96, denominator)
                        .toUint160();
            }
        }
    }

    function getNextSqrtPriceFromAmount1RoundingDown(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {

        if (add) {
            uint256 quotient = (
                amount <= type(uint160).max
                    ? (amount << FixedPoint96.RESOLUTION) / liquidity
                    : FullMath.mulDiv(amount, FixedPoint96.Q96, liquidity)
            );

            return (uint256(sqrtPX96) + quotient).toUint160();
        } else {
            uint256 quotient = (
                amount <= type(uint160).max
                    ? UnsafeMath.divRoundingUp(
                        amount << FixedPoint96.RESOLUTION,
                        liquidity
                    )
                    : FullMath.mulDivRoundingUp(
                        amount,
                        FixedPoint96.Q96,
                        liquidity
                    )
            );

            require(sqrtPX96 > quotient);
            unchecked {
                return uint160(sqrtPX96 - quotient);
            }
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
                ? getNextSqrtPriceFromAmount0RoundingUp(
                    sqrtPX96,
                    liquidity,
                    amountIn,
                    true
                )
                : getNextSqrtPriceFromAmount1RoundingDown(
                    sqrtPX96,
                    liquidity,
                    amountIn,
                    true
                );
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
                ? getNextSqrtPriceFromAmount1RoundingDown(
                    sqrtPX96,
                    liquidity,
                    amountOut,
                    false
                )
                : getNextSqrtPriceFromAmount0RoundingUp(
                    sqrtPX96,
                    liquidity,
                    amountOut,
                    false
                );
    }

    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount0) {

        unchecked {
            if (sqrtRatioAX96 > sqrtRatioBX96)
                (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

            uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;
            uint256 numerator2 = sqrtRatioBX96 - sqrtRatioAX96;

            require(sqrtRatioAX96 > 0);

            return
                roundUp
                    ? UnsafeMath.divRoundingUp(
                        FullMath.mulDivRoundingUp(
                            numerator1,
                            numerator2,
                            sqrtRatioBX96
                        ),
                        sqrtRatioAX96
                    )
                    : FullMath.mulDiv(numerator1, numerator2, sqrtRatioBX96) /
                        sqrtRatioAX96;
        }
    }

    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount1) {

        unchecked {
            if (sqrtRatioAX96 > sqrtRatioBX96)
                (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

            return
                roundUp
                    ? FullMath.mulDivRoundingUp(
                        liquidity,
                        sqrtRatioBX96 - sqrtRatioAX96,
                        FixedPoint96.Q96
                    )
                    : FullMath.mulDiv(
                        liquidity,
                        sqrtRatioBX96 - sqrtRatioAX96,
                        FixedPoint96.Q96
                    );
        }
    }

    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) internal pure returns (int256 amount0) {

        unchecked {
            return
                liquidity < 0
                    ? -getAmount0Delta(
                        sqrtRatioAX96,
                        sqrtRatioBX96,
                        uint128(-liquidity),
                        false
                    ).toInt256()
                    : getAmount0Delta(
                        sqrtRatioAX96,
                        sqrtRatioBX96,
                        uint128(liquidity),
                        true
                    ).toInt256();
        }
    }

    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) internal pure returns (int256 amount1) {

        unchecked {
            return
                liquidity < 0
                    ? -getAmount1Delta(
                        sqrtRatioAX96,
                        sqrtRatioBX96,
                        uint128(-liquidity),
                        false
                    ).toInt256()
                    : getAmount1Delta(
                        sqrtRatioAX96,
                        sqrtRatioBX96,
                        uint128(liquidity),
                        true
                    ).toInt256();
        }
    }
}


library TickBitmapExtended {

    function position(int24 tick)
        private
        pure
        returns (int16 wordPos, uint8 bitPos)
    {

        wordPos = int16(tick >> 8);
        bitPos = uint8(uint24(tick % 256));
    }

    function nextInitializedTickWithinOneWord(
        function(int16) external view returns (uint256) self,
        int24 tick,
        int24 tickSpacing,
        bool lte
    ) internal view returns (int24 next, bool initialized) {

        int24 compressed = tick / tickSpacing;
        if (tick < 0 && tick % tickSpacing != 0) compressed--; // round towards negative infinity

        if (lte) {
            (int16 wordPos, uint8 bitPos) = position(compressed);
            uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint256 masked = self(wordPos) & mask;

            initialized = masked != 0;
            next = initialized
                ? (compressed -
                    int24(
                        uint24(bitPos - BitMath.mostSignificantBit(masked))
                    )) * tickSpacing
                : (compressed - int24(uint24(bitPos))) * tickSpacing;
        } else {
            (int16 wordPos, uint8 bitPos) = position(compressed + 1);
            uint256 mask = ~((1 << bitPos) - 1);
            uint256 masked = self(wordPos) & mask;

            initialized = masked != 0;
            next = initialized
                ? (compressed +
                    1 +
                    int24(
                        uint24(BitMath.leastSignificantBit(masked) - bitPos)
                    )) * tickSpacing
                : (compressed + 1 + int24(uint24(type(uint8).max - bitPos))) *
                    tickSpacing;
        }
    }
}


library SwapMath {

    function computeSwapStep(
        uint160 sqrtRatioCurrentX96,
        uint160 sqrtRatioTargetX96,
        uint128 liquidity,
        int256 amountRemaining,
        uint24 feePips
    )
        internal
        pure
        returns (
            uint160 sqrtRatioNextX96,
            uint256 amountIn,
            uint256 amountOut,
            uint256 feeAmount
        )
    {

        unchecked {
            bool zeroForOne = sqrtRatioCurrentX96 >= sqrtRatioTargetX96;
            bool exactIn = amountRemaining >= 0;

            if (exactIn) {
                uint256 amountRemainingLessFee = FullMath.mulDiv(
                    uint256(amountRemaining),
                    1e6 - feePips,
                    1e6
                );
                amountIn = zeroForOne
                    ? SqrtPriceMath.getAmount0Delta(
                        sqrtRatioTargetX96,
                        sqrtRatioCurrentX96,
                        liquidity,
                        true
                    )
                    : SqrtPriceMath.getAmount1Delta(
                        sqrtRatioCurrentX96,
                        sqrtRatioTargetX96,
                        liquidity,
                        true
                    );
                if (amountRemainingLessFee >= amountIn)
                    sqrtRatioNextX96 = sqrtRatioTargetX96;
                else
                    sqrtRatioNextX96 = SqrtPriceMath.getNextSqrtPriceFromInput(
                        sqrtRatioCurrentX96,
                        liquidity,
                        amountRemainingLessFee,
                        zeroForOne
                    );
            } else {
                amountOut = zeroForOne
                    ? SqrtPriceMath.getAmount1Delta(
                        sqrtRatioTargetX96,
                        sqrtRatioCurrentX96,
                        liquidity,
                        false
                    )
                    : SqrtPriceMath.getAmount0Delta(
                        sqrtRatioCurrentX96,
                        sqrtRatioTargetX96,
                        liquidity,
                        false
                    );
                if (uint256(-amountRemaining) >= amountOut)
                    sqrtRatioNextX96 = sqrtRatioTargetX96;
                else
                    sqrtRatioNextX96 = SqrtPriceMath.getNextSqrtPriceFromOutput(
                        sqrtRatioCurrentX96,
                        liquidity,
                        uint256(-amountRemaining),
                        zeroForOne
                    );
            }

            bool max = sqrtRatioTargetX96 == sqrtRatioNextX96;

            if (zeroForOne) {
                amountIn = max && exactIn
                    ? amountIn
                    : SqrtPriceMath.getAmount0Delta(
                        sqrtRatioNextX96,
                        sqrtRatioCurrentX96,
                        liquidity,
                        true
                    );
                amountOut = max && !exactIn
                    ? amountOut
                    : SqrtPriceMath.getAmount1Delta(
                        sqrtRatioNextX96,
                        sqrtRatioCurrentX96,
                        liquidity,
                        false
                    );
            } else {
                amountIn = max && exactIn
                    ? amountIn
                    : SqrtPriceMath.getAmount1Delta(
                        sqrtRatioCurrentX96,
                        sqrtRatioNextX96,
                        liquidity,
                        true
                    );
                amountOut = max && !exactIn
                    ? amountOut
                    : SqrtPriceMath.getAmount0Delta(
                        sqrtRatioCurrentX96,
                        sqrtRatioNextX96,
                        liquidity,
                        false
                    );
            }

            if (!exactIn && amountOut > uint256(-amountRemaining)) {
                amountOut = uint256(-amountRemaining);
            }

            if (exactIn && sqrtRatioNextX96 != sqrtRatioTargetX96) {
                feeAmount = uint256(amountRemaining) - amountIn;
            } else {
                feeAmount = FullMath.mulDivRoundingUp(
                    amountIn,
                    feePips,
                    1e6 - feePips
                );
            }
        }
    }
}


library UniswapHelperViews {

    using SafeCast for uint256;
    using TickBitmapExtended for function(int16)
        external
        view
        returns (uint256);

    error ZeroAmount();
    error InvalidSqrtPriceLimit(uint160 sqrtPriceLimitX96);

    struct Cache {
        uint160 sqrtPriceX96Start;
        int24 tickStart;
        uint8 feeProtocol;
        uint128 liquidityStart;
        int24 tickSpacing;
        uint24 fee;
    }

    struct State {
        int256 amountSpecifiedRemaining;
        int256 amountCalculated;
        uint160 sqrtPriceX96;
        int24 tick;
        uint256 feeGrowthGlobalIncreaseX128;
        uint128 protocolFee;
        uint128 liquidity;
    }

    struct Step {
        uint160 sqrtPriceStartX96;
        int24 tickNext;
        bool initialized;
        uint160 sqrtPriceNextX96;
        uint256 amountIn;
        uint256 amountOut;
        uint256 feeAmount;
    }

    function simulateSwap(
        IUniswapV3Pool v3Pool,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        UniswapHelperViews.Cache memory cache
    )
        internal
        view
        returns (
            int256 amount0,
            int256 amount1,
            UniswapHelperViews.State memory state
        )
    {

        if (amountSpecified == 0) revert ZeroAmount();

        if (cache.sqrtPriceX96Start == 0) {
            IUniswapV3Pool.Slot0 memory slot0 = v3Pool.slot0();
            cache.sqrtPriceX96Start = slot0.sqrtPriceX96;
            cache.tickStart = slot0.tick;
            cache.feeProtocol = slot0.feeProtocol;
        }

        if (cache.liquidityStart == 0)
            cache.liquidityStart = v3Pool.liquidity();

        if (cache.tickSpacing == 0) {
            cache.fee = v3Pool.fee();
            cache.tickSpacing = v3Pool.tickSpacing();
        }

        if (
            zeroForOne
                ? sqrtPriceLimitX96 > cache.sqrtPriceX96Start ||
                    sqrtPriceLimitX96 < TickMath.MIN_SQRT_RATIO
                : sqrtPriceLimitX96 < cache.sqrtPriceX96Start ||
                    sqrtPriceLimitX96 > TickMath.MAX_SQRT_RATIO
        ) revert InvalidSqrtPriceLimit(sqrtPriceLimitX96);

        bool exactInput = amountSpecified > 0;

        state = UniswapHelperViews.State({
            amountSpecifiedRemaining: amountSpecified,
            amountCalculated: 0,
            sqrtPriceX96: cache.sqrtPriceX96Start,
            tick: cache.tickStart,
            feeGrowthGlobalIncreaseX128: 0,
            protocolFee: 0,
            liquidity: cache.liquidityStart
        });

        while (
            state.amountSpecifiedRemaining != 0 &&
            state.sqrtPriceX96 != sqrtPriceLimitX96
        ) {
            UniswapHelperViews.Step memory step;

            step.sqrtPriceStartX96 = state.sqrtPriceX96;

            (step.tickNext, step.initialized) = v3Pool
                .tickBitmap
                .nextInitializedTickWithinOneWord(
                    state.tick,
                    cache.tickSpacing,
                    zeroForOne
                );

            if (step.tickNext < TickMath.MIN_TICK) {
                step.tickNext = TickMath.MIN_TICK;
            } else if (step.tickNext > TickMath.MAX_TICK) {
                step.tickNext = TickMath.MAX_TICK;
            }

            step.sqrtPriceNextX96 = TickMath.getSqrtRatioAtTick(step.tickNext);

            (
                state.sqrtPriceX96,
                step.amountIn,
                step.amountOut,
                step.feeAmount
            ) = SwapMath.computeSwapStep(
                state.sqrtPriceX96,
                (
                    zeroForOne
                        ? step.sqrtPriceNextX96 < sqrtPriceLimitX96
                        : step.sqrtPriceNextX96 > sqrtPriceLimitX96
                )
                    ? sqrtPriceLimitX96
                    : step.sqrtPriceNextX96,
                state.liquidity,
                state.amountSpecifiedRemaining,
                cache.fee
            );

            if (exactInput) {
                state.amountSpecifiedRemaining -= (step.amountIn +
                    step.feeAmount).toInt256();
                state.amountCalculated =
                    state.amountCalculated -
                    step.amountOut.toInt256();
            } else {
                state.amountSpecifiedRemaining += step.amountOut.toInt256();
                state.amountCalculated =
                    state.amountCalculated +
                    (step.amountIn + step.feeAmount).toInt256();
            }

            if (state.liquidity > 0) {
                state.feeGrowthGlobalIncreaseX128 += FullMath.mulDiv(
                    step.feeAmount,
                    FixedPoint128.Q128,
                    state.liquidity
                );
            }


            if (state.sqrtPriceX96 == step.sqrtPriceNextX96) {
                if (step.initialized) {
                    IUniswapV3Pool.TickInfo memory tickInfo = v3Pool.ticks(
                        step.tickNext
                    );
                    int128 liquidityNet = tickInfo.liquidityNet;
                    if (zeroForOne) liquidityNet = -liquidityNet;
                    state.liquidity = liquidityNet < 0
                        ? state.liquidity - uint128(-liquidityNet)
                        : state.liquidity + uint128(liquidityNet);
                }

                state.tick = zeroForOne ? step.tickNext - 1 : step.tickNext;
            } else if (state.sqrtPriceX96 != step.sqrtPriceStartX96) {
                state.tick = TickMath.getTickAtSqrtRatio(state.sqrtPriceX96);
            }
        }

        (amount0, amount1) = zeroForOne == exactInput
            ? (
                amountSpecified - state.amountSpecifiedRemaining,
                state.amountCalculated
            )
            : (
                state.amountCalculated,
                amountSpecified - state.amountSpecifiedRemaining
            );
    }

    function simulateSwap(
        IUniswapV3Pool v3Pool,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96
    )
        public
        view
        returns (
            int256 amount0,
            int256 amount1,
            UniswapHelperViews.State memory state,
            UniswapHelperViews.Cache memory cache
        )
    {

        (amount0, amount1, state) = simulateSwap(
            v3Pool,
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            cache
        );
    }

    struct feesEarnedParams {
        uint128 liquidity;
        int24 tickCurrent;
        int24 tickLower;
        int24 tickUpper;
        uint256 feeGrowthGlobal0X128;
        uint256 feeGrowthGlobal1X128;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
    }

    function getFeesEarned(
        feesEarnedParams memory _feesEarnedParams,
        IUniswapV3Pool.TickInfo memory lower,
        IUniswapV3Pool.TickInfo memory upper
    ) internal pure returns (uint128 tokensOwed0, uint128 tokensOwed1) {

        uint256 feeGrowthBelow0X128;
        uint256 feeGrowthBelow1X128;
        if (_feesEarnedParams.tickCurrent >= _feesEarnedParams.tickLower) {
            feeGrowthBelow0X128 = lower.feeGrowthOutside0X128;
            feeGrowthBelow1X128 = lower.feeGrowthOutside1X128;
        } else {
            feeGrowthBelow0X128 =
                _feesEarnedParams.feeGrowthGlobal0X128 -
                lower.feeGrowthOutside0X128;
            feeGrowthBelow1X128 =
                _feesEarnedParams.feeGrowthGlobal1X128 -
                lower.feeGrowthOutside1X128;
        }

        uint256 feeGrowthAbove0X128;
        uint256 feeGrowthAbove1X128;
        if (_feesEarnedParams.tickCurrent < _feesEarnedParams.tickUpper) {
            feeGrowthAbove0X128 = upper.feeGrowthOutside0X128;
            feeGrowthAbove1X128 = upper.feeGrowthOutside1X128;
        } else {
            feeGrowthAbove0X128 =
                _feesEarnedParams.feeGrowthGlobal0X128 -
                upper.feeGrowthOutside0X128;
            feeGrowthAbove1X128 =
                _feesEarnedParams.feeGrowthGlobal1X128 -
                upper.feeGrowthOutside1X128;
        }

        uint256 feeGrowthInside0X128 = _feesEarnedParams.feeGrowthGlobal0X128 -
            feeGrowthBelow0X128 -
            feeGrowthAbove0X128;
        uint256 feeGrowthInside1X128 = _feesEarnedParams.feeGrowthGlobal1X128 -
            feeGrowthBelow1X128 -
            feeGrowthAbove1X128;

        tokensOwed0 = uint128(
            FullMath.mulDiv(
                feeGrowthInside0X128 -
                    _feesEarnedParams.feeGrowthInside0LastX128,
                _feesEarnedParams.liquidity,
                FixedPoint128.Q128
            )
        );
        tokensOwed1 = uint128(
            FullMath.mulDiv(
                feeGrowthInside1X128 -
                    _feesEarnedParams.feeGrowthInside1LastX128,
                _feesEarnedParams.liquidity,
                FixedPoint128.Q128
            )
        );
    }

}