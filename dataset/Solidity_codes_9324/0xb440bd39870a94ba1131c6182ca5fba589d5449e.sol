
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
}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IHotPotV3FundERC20 is IERC20{

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IHotPotV3FundEvents {

    event Deposit(address indexed owner, uint amount, uint share);

    event Withdraw(address indexed owner, uint amount, uint share);

    event SetDescriptor(bytes descriptor);

    event SetDeadline(uint deadline);

    event SetPath(address distToken, bytes path);

    event Init(uint poolIndex, uint positionIndex, uint amount);

    event Add(uint poolIndex, uint positionIndex, uint amount, bool collect);

    event Sub(uint poolIndex, uint positionIndex, uint proportionX128);

    event Move(uint poolIndex, uint subIndex, uint addIndex, uint proportionX128);
}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IHotPotV3FundState {

    function controller() external view returns (address);


    function manager() external view returns (address);


    function token() external view returns (address);


    function descriptor() external view returns (bytes memory);


    function lockPeriod() external view returns (uint);


    function baseLine() external view returns (uint);


    function managerFee() external view returns (uint);


    function depositDeadline() external view returns (uint);


    function lastDepositTime(address account) external view returns (uint);


    function totalInvestment() external view returns (uint);


    function investmentOf(address owner) external view returns (uint);


    function assetsOfPosition(uint poolIndex, uint positionIndex) external view returns(uint);


    function assetsOfPool(uint poolIndex) external view returns(uint);


    function totalAssets() external view returns (uint);


    function buyPath(address _token) external view returns (bytes memory);


    function sellPath(address _token) external view returns (bytes memory);


    function pools(uint index) external view returns(address);


    function positions(uint poolIndex, uint positionIndex) 
        external 
        view 
        returns(
            bool isEmpty,
            int24 tickLower,
            int24 tickUpper 
        );


    function poolsLength() external view returns(uint);


    function positionsLength(uint poolIndex) external view returns(uint);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IHotPotV3FundUserActions {

    function deposit(uint amount) external returns(uint share);


    function withdraw(uint share, uint amountMin, uint deadline) external returns(uint amount);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IHotPotV3FundManagerActions {

    function setDescriptor(bytes calldata _descriptor) external;


    function setDepositDeadline(uint deadline) external;


    function setPath(
        address distToken, 
        bytes calldata buy,
        bytes calldata sell
    ) external;


    function init(
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint amount,
        uint32 maxPIS
    ) external returns(uint128 liquidity);


    function add(
        uint poolIndex, 
        uint positionIndex, 
        uint amount, 
        bool collect,
        uint32 maxPIS
    ) external returns(uint128 liquidity);


    function sub(
        uint poolIndex, 
        uint positionIndex, 
        uint proportionX128,
        uint32 maxPIS
    ) external returns(uint amount);


    function move(
        uint poolIndex,
        uint subIndex, 
        uint addIndex, 
        uint proportionX128, //以前是按LP数量移除，现在改成按总比例移除，这样前端就不用管实际LP是多少了
        uint32 maxPIS
    ) external  returns(uint128 liquidity);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IHotPotV3Fund is 
    IHotPotV3FundERC20, 
    IHotPotV3FundEvents, 
    IHotPotV3FundState, 
    IHotPotV3FundUserActions, 
    IHotPotV3FundManagerActions
{    

}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IHotPot is IERC20{

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    function burn(uint value) external returns (bool) ;

    function burnFrom(address from, uint value) external returns (bool);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IManagerActions {

    function setDescriptor(address fund, bytes calldata _descriptor) external;


    function setDepositDeadline(address fund, uint deadline) external;


    function setPath(
        address fund, 
        address distToken, 
        bytes memory path
    ) external;


    function init(
        address fund,
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint amount,
        uint deadline
    ) external returns(uint128 liquidity);


    function add(
        address fund,
        uint poolIndex,
        uint positionIndex, 
        uint amount, 
        bool collect,
        uint deadline
    ) external returns(uint128 liquidity);


    function sub(
        address fund,
        uint poolIndex,
        uint positionIndex,
        uint proportionX128,
        uint deadline
    ) external returns(uint amount);


    function move(
        address fund,
        uint poolIndex,
        uint subIndex, 
        uint addIndex,
        uint proportionX128,
        uint deadline
    ) external returns(uint128 liquidity);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IGovernanceActions {

    function setGovernance(address account) external;


    function setVerifiedToken(address token, bool isVerified) external;


    function setHarvestPath(address token, bytes calldata path) external;


    function setMaxSqrtSlippage(uint32 sqrtSlippage) external;


    function setMaxPriceImpact(uint32 priceImpact) external;

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IControllerState {

    function uniV3Router() external view returns (address);


    function uniV3Factory() external view returns (address);


    function hotpot() external view returns (address);


    function governance() external view returns (address);


    function WETH9() external view returns (address);


    function verifiedToken(address token) external view returns (bool);


    function harvestPath(address token) external view returns (bytes memory);


    function maxSqrtSlippage() external view returns (uint32);


    function maxPriceImpact() external view returns (uint32);

}// GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IControllerEvents {

    event ChangeVerifiedToken(address indexed token, bool isVerified);

    event Harvest(address indexed token, uint amount, uint burned);

    event SetHarvestPath(address indexed token, bytes path);

    event SetGovernance(address indexed account);

    event SetMaxSqrtSlippage(uint sqrtSlippage);

    event SetMaxPriceImpact(uint priceImpact);
}// GPL-2.0-or-later
pragma solidity >=0.5.0;


interface IHotPotV3FundController is IManagerActions, IGovernanceActions, IControllerState, IControllerEvents {

    function harvest(address token, uint amount) external returns(uint burned);

}// GPL-2.0-or-later
pragma solidity >=0.7.5;

interface IMulticall {

    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

}// GPL-2.0-or-later
pragma solidity =0.7.6;


abstract contract Multicall is IMulticall {
    function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}// BUSL-1.1
pragma solidity =0.7.6;


contract HotPotV3FundController is IHotPotV3FundController, Multicall {

    using Path for bytes;

    address public override immutable uniV3Factory;
    address public override immutable uniV3Router;
    address public override immutable hotpot;
    address public override governance;
    address public override immutable WETH9;
    uint32 maxPIS = (100 << 16) + 9974;// MaxPriceImpact: 1%, MaxSwapSlippage: 0.5% = (1 - (sqrtSlippage/1e4)^2) * 100%

    mapping (address => bool) public override verifiedToken;
    mapping (address => bytes) public override harvestPath;

    modifier onlyManager(address fund){

        require(msg.sender == IHotPotV3Fund(fund).manager(), "OMC");
        _;
    }

    modifier onlyGovernance{

        require(msg.sender == governance, "OGC");
        _;
    }

    modifier checkDeadline(uint deadline) {

        require(block.timestamp <= deadline, 'CDL');
        _;
    }

    constructor(
        address _hotpot,
        address _governance,
        address _uniV3Router,
        address _uniV3Factory,
        address _weth9
    ) {
        hotpot = _hotpot;
        governance = _governance;
        uniV3Router = _uniV3Router;
        uniV3Factory = _uniV3Factory;
        WETH9 = _weth9;
    }

    function maxPriceImpact() external override view returns(uint32 priceImpact){

        return maxPIS >> 16;
    }

    function maxSqrtSlippage() external override view returns(uint32 sqrtSlippage){

        return maxPIS & 0xffff;
    }

    function setHarvestPath(address token, bytes calldata path) external override onlyGovernance {

        bytes memory _path = path;
        while (true) {
            (address tokenIn, address tokenOut, uint24 fee) = _path.decodeFirstPool();

            address pool = IUniswapV3Factory(uniV3Factory).getPool(tokenIn, tokenOut, fee);
            require(pool != address(0), "PIE");
            (,,,uint16 observationCardinality,,,) = IUniswapV3Pool(pool).slot0();
            require(observationCardinality >= 2, "OC");

            if (_path.hasMultiplePools()) {
                _path = _path.skipToken();
            } else {
                require(tokenIn == WETH9 && tokenOut == hotpot, "IOT");
                break;
            }
        }
        harvestPath[token] = path;
        emit SetHarvestPath(token, path);
    }

    function setMaxPriceImpact(uint32 priceImpact) external override onlyGovernance {

        require(priceImpact <= 1e4 ,"SPI");
        maxPIS = (priceImpact << 16) | (maxPIS & 0xffff);
        emit SetMaxPriceImpact(priceImpact);
    }

    function setMaxSqrtSlippage(uint32 sqrtSlippage) external override onlyGovernance {

        require(sqrtSlippage <= 1e4 ,"SSS");
        maxPIS = maxPIS & 0xffff0000 | sqrtSlippage;
        emit SetMaxSqrtSlippage(sqrtSlippage);
    }

    function harvest(address token, uint amount) external override returns(uint burned) {

        bytes memory path = harvestPath[token];
        PathPrice.verifySlippage(path, uniV3Factory, maxPIS & 0xffff);
        uint value = amount <= IERC20(token).balanceOf(address(this)) ? amount : IERC20(token).balanceOf(address(this));
        TransferHelper.safeApprove(token, uniV3Router, value);

        ISwapRouter.ExactInputParams memory args = ISwapRouter.ExactInputParams({
            path: path,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: value,
            amountOutMinimum: 0
        });
        burned = ISwapRouter(uniV3Router).exactInput(args);
        IHotPot(hotpot).burn(burned);
        emit Harvest(token, amount, burned);
    }

    function setGovernance(address account) external override onlyGovernance {

        require(account != address(0));
        governance = account;
        emit SetGovernance(account);
    }

    function setVerifiedToken(address token, bool isVerified) external override onlyGovernance {

        verifiedToken[token] = isVerified;
        emit ChangeVerifiedToken(token, isVerified);
    }

    function setDescriptor(address fund, bytes calldata _descriptor) external override onlyManager(fund) {

        return IHotPotV3Fund(fund).setDescriptor(_descriptor);
    }

    function setDepositDeadline(address fund, uint deadline) external override onlyManager(fund) {

        return IHotPotV3Fund(fund).setDepositDeadline(deadline);
    }

    function setPath(
        address fund,
        address distToken,
        bytes memory path
    ) external override onlyManager(fund){

        require(verifiedToken[distToken]);

        address fundToken = IHotPotV3Fund(fund).token();
        bytes memory _path = path;
        bytes memory _reverse;
        (address tokenIn, address tokenOut, uint24 fee) = path.decodeFirstPool();
        _reverse = abi.encodePacked(tokenOut, fee, tokenIn);
        bool isBuy;
        if(tokenIn == fundToken){
            isBuy = true;
        }
        else{
            require(tokenIn == distToken);
        }

        while (true) {
            require(verifiedToken[tokenIn], "VIT");
            require(verifiedToken[tokenOut], "VOT");
            address pool = IUniswapV3Factory(uniV3Factory).getPool(tokenIn, tokenOut, fee);
            require(pool != address(0), "PIE");
            (,,,uint16 observationCardinality,,,) = IUniswapV3Pool(pool).slot0();
            require(observationCardinality >= 2, "OC");

            if (path.hasMultiplePools()) {
                path = path.skipToken();
                (tokenIn, tokenOut, fee) = path.decodeFirstPool();
                _reverse = abi.encodePacked(tokenOut, fee, _reverse);
            } else {
                if(isBuy)
                    require(tokenOut == distToken, "OID");
                else
                    require(tokenOut == fundToken, "OIF");
                break;
            }
        }
        if(!isBuy) (_path, _reverse) = (_reverse, _path);
        IHotPotV3Fund(fund).setPath(distToken, _path, _reverse);
    }

    function init(
        address fund,
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint amount,
        uint deadline
    ) external override checkDeadline(deadline) onlyManager(fund) returns(uint128 liquidity){

        return IHotPotV3Fund(fund).init(token0, token1, fee, tickLower, tickUpper, amount, maxPIS);
    }

    function add(
        address fund,
        uint poolIndex,
        uint positionIndex,
        uint amount,
        bool collect,
        uint deadline
    ) external override checkDeadline(deadline) onlyManager(fund) returns(uint128 liquidity){

        return IHotPotV3Fund(fund).add(poolIndex, positionIndex, amount, collect, maxPIS);
    }

    function sub(
        address fund,
        uint poolIndex,
        uint positionIndex,
        uint proportionX128,
        uint deadline
    ) external override checkDeadline(deadline) onlyManager(fund) returns(uint amount){

        return IHotPotV3Fund(fund).sub(poolIndex, positionIndex, proportionX128, maxPIS);
    }

    function move(
        address fund,
        uint poolIndex,
        uint subIndex,
        uint addIndex,
        uint proportionX128,
        uint deadline
    ) external override checkDeadline(deadline) onlyManager(fund) returns(uint128 liquidity){

        return IHotPotV3Fund(fund).move(poolIndex, subIndex, addIndex, proportionX128, maxPIS);
    }
}