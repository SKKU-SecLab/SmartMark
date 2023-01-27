
pragma solidity 0.7.5;

interface IIntegralFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);
    event OwnerSet(address owner);

    function owner() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function createPair(
        address tokenA,
        address tokenB,
        address oracle,
        address trader
    ) external returns (address pair);


    function setOwner(address) external;


    function setMintFee(
        address tokenA,
        address tokenB,
        uint256 fee
    ) external;


    function setBurnFee(
        address tokenA,
        address tokenB,
        uint256 fee
    ) external;


    function setSwapFee(
        address tokenA,
        address tokenB,
        uint256 fee
    ) external;


    function setOracle(
        address tokenA,
        address tokenB,
        address oracle
    ) external;


    function setTrader(
        address tokenA,
        address tokenB,
        address trader
    ) external;


    function collect(
        address tokenA,
        address tokenB,
        address to
    ) external;


    function withdraw(
        address tokenA,
        address tokenB,
        uint256 amount,
        address to
    ) external;

}// GPL-3.0-or-later

pragma solidity 0.7.5;

interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

}// GPL-3.0-or-later

pragma solidity 0.7.5;


interface IIntegralERC20 is IERC20 {

    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

}// GPL-3.0-or-later

pragma solidity 0.7.5;

interface IReserves {

    event Sync(uint112 reserve0, uint112 reserve1);
    event Fees(uint256 fee0, uint256 fee1);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 lastTimestamp
        );


    function getReferences()
        external
        view
        returns (
            uint112 reference0,
            uint112 reference1,
            uint32 epoch
        );


    function getFees() external view returns (uint256 fee0, uint256 fee1);

}// GPL-3.0-or-later

pragma solidity 0.7.5;


interface IIntegralPair is IIntegralERC20, IReserves {

    event Mint(address indexed sender, address indexed to);
    event Burn(address indexed sender, address indexed to);
    event Swap(address indexed sender, address indexed to);
    event SetMintFee(uint256 fee);
    event SetBurnFee(uint256 fee);
    event SetSwapFee(uint256 fee);
    event SetOracle(address account);
    event SetTrader(address trader);
    event SetToken0AbsoluteLimit(uint256 limit);
    event SetToken1AbsoluteLimit(uint256 limit);
    event SetToken0RelativeLimit(uint256 limit);
    event SetToken1RelativeLimit(uint256 limit);
    event SetPriceDeviationLimit(uint256 limit);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function oracle() external view returns (address);


    function trader() external view returns (address);


    function mintFee() external view returns (uint256);


    function setMintFee(uint256 fee) external;


    function mint(address to) external returns (uint256 liquidity);


    function burnFee() external view returns (uint256);


    function setBurnFee(uint256 fee) external;


    function burn(address to) external returns (uint256 amount0, uint256 amount1);


    function swapFee() external view returns (uint256);


    function setSwapFee(uint256 fee) external;


    function setOracle(address account) external;


    function setTrader(address account) external;


    function token0AbsoluteLimit() external view returns (uint256);


    function setToken0AbsoluteLimit(uint256 limit) external;


    function token1AbsoluteLimit() external view returns (uint256);


    function setToken1AbsoluteLimit(uint256 limit) external;


    function token0RelativeLimit() external view returns (uint256);


    function setToken0RelativeLimit(uint256 limit) external;


    function token1RelativeLimit() external view returns (uint256);


    function setToken1RelativeLimit(uint256 limit) external;


    function priceDeviationLimit() external view returns (uint256);


    function setPriceDeviationLimit(uint256 limit) external;


    function collect(address to) external;


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to
    ) external;


    function sync() external;


    function initialize(
        address _token0,
        address _token1,
        address _oracle,
        address _trader
    ) external;


    function syncWithOracle() external;


    function fullSync() external;


    function getSpotPrice() external view returns (uint256 spotPrice);


    function getSwapAmount0In(uint256 amount1Out) external view returns (uint256 swapAmount0In);


    function getSwapAmount1In(uint256 amount0Out) external view returns (uint256 swapAmount1In);


    function getSwapAmount0Out(uint256 amount1In) external view returns (uint256 swapAmount0Out);


    function getSwapAmount1Out(uint256 amount0In) external view returns (uint256 swapAmount1Out);


    function getDepositAmount0In(uint256 amount0) external view returns (uint256 depositAmount0In);


    function getDepositAmount1In(uint256 amount1) external view returns (uint256 depositAmount1In);

}// GPL-3.0-or-later

pragma solidity 0.7.5;

interface IIntegralOracle {

    event OwnerSet(address owner);
    event UniswapPairSet(address uniswapPair);
    event PriceUpdateIntervalSet(uint32 interval);
    event ParametersSet(uint32 epoch, int256[] bidExponents, int256[] bidQs, int256[] askExponents, int256[] askQs);

    function owner() external view returns (address);


    function setOwner(address) external;


    function epoch() external view returns (uint32);


    function xDecimals() external view returns (uint8);


    function yDecimals() external view returns (uint8);


    function getParameters()
        external
        view
        returns (
            int256[] memory bidExponents,
            int256[] memory bidQs,
            int256[] memory askExponents,
            int256[] memory askQs
        );


    function setParameters(
        int256[] calldata bidExponents,
        int256[] calldata bidQs,
        int256[] calldata askExponents,
        int256[] calldata askQs
    ) external;


    function price() external view returns (int256);


    function priceUpdateInterval() external view returns (uint32);


    function updatePrice() external returns (uint32 _epoch);


    function setPriceUpdateInterval(uint32 interval) external;


    function price0CumulativeLast() external view returns (uint256);


    function blockTimestampLast() external view returns (uint32);


    function tradeX(
        uint256 xAfter,
        uint256 xBefore,
        uint256 yBefore
    ) external view returns (uint256 yAfter);


    function tradeY(
        uint256 yAfter,
        uint256 xBefore,
        uint256 yBefore
    ) external view returns (uint256 xAfter);


    function getSpotPrice(uint256 xCurrent, uint256 xBefore) external view returns (uint256 spotPrice);

}// GPL-3.0-or-later

pragma solidity 0.7.5;


library Math {

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x < y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x > y ? x : y;
    }

    function min32(uint32 x, uint32 y) internal pure returns (uint32 z) {

        z = x < y ? x : y;
    }

    function max32(uint32 x, uint32 y) internal pure returns (uint32 z) {

        z = x > y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}// GPL-3.0-or-later

pragma solidity 0.7.5;


library SafeMath {

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, 'SM_ADD_OVERFLOW');
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = sub(x, y, 'SM_SUB_UNDERFLOW');
    }

    function sub(
        uint256 x,
        uint256 y,
        string memory message
    ) internal pure returns (uint256 z) {

        require((z = x - y) <= x, message);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, 'SM_MUL_OVERFLOW');
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, 'SM_DIV_BY_ZERO');
        uint256 c = a / b;
        return c;
    }

    function ceil_div(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = div(a, b);
        if (c == mul(a, b)) {
            return c;
        } else {
            return add(c, 1);
        }
    }

    function safe32(uint256 n) internal pure returns (uint32) {

        require(n < 2**32, 'IS_EXCEEDS_32_BITS');
        return uint32(n);
    }

    function add96(uint96 a, uint96 b) internal pure returns (uint96 c) {

        c = a + b;
        require(c >= a, 'SM_ADD_OVERFLOW');
    }

    function sub96(uint96 a, uint96 b) internal pure returns (uint96) {

        require(b <= a, 'SM_SUB_UNDERFLOW');
        return a - b;
    }

    function mul96(uint96 x, uint96 y) internal pure returns (uint96 z) {

        require(y == 0 || (z = x * y) / y == x, 'SM_MUL_OVERFLOW');
    }

    function div96(uint96 a, uint96 b) internal pure returns (uint96) {

        require(b > 0, 'SM_DIV_BY_ZERO');
        uint96 c = a / b;
        return c;
    }

    function add32(uint32 a, uint32 b) internal pure returns (uint32 c) {

        c = a + b;
        require(c >= a, 'SM_ADD_OVERFLOW');
    }

    function sub32(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b <= a, 'SM_SUB_UNDERFLOW');
        return a - b;
    }

    function mul32(uint32 x, uint32 y) internal pure returns (uint32 z) {

        require(y == 0 || (z = x * y) / y == x, 'SM_MUL_OVERFLOW');
    }

    function div32(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b > 0, 'SM_DIV_BY_ZERO');
        uint32 c = a / b;
        return c;
    }
}// GPL-3.0-or-later

pragma solidity 0.7.5;


library FixedSafeMath {

    int256 private constant _INT256_MIN = -2**255;
    int256 internal constant ONE = 10**18;

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), 'FM_ADDITION_OVERFLOW');

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), 'FM_SUBTRACTION_OVERFLOW');

        return c;
    }

    function f18Mul(int256 a, int256 b) internal pure returns (int256) {

        return div(mul(a, b), ONE);
    }

    function f18Div(int256 a, int256 b) internal pure returns (int256) {

        return div(mul(a, ONE), b);
    }

    function f18Sqrt(int256 value) internal pure returns (int256) {

        require(value >= 0, 'FM_SQUARE_ROOT_OF_NEGATIVE');
        return int256(Math.sqrt(SafeMath.mul(uint256(value), uint256(ONE))));
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), 'FM_MULTIPLICATION_OVERFLOW');

        int256 c = a * b;
        require(c / a == b, 'FM_MULTIPLICATION_OVERFLOW');

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, 'FM_DIVISION_BY_ZERO');
        require(!(b == -1 && a == _INT256_MIN), 'FM_DIVISION_OVERFLOW');

        int256 c = a / b;

        return c;
    }
}// GPL-3.0-or-later

pragma solidity 0.7.5;


library Normalizer {

    using SafeMath for uint256;

    function normalize(uint256 amount, uint8 decimals) internal pure returns (uint256) {

        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.div(10**(decimals - 18));
        } else {
            return amount.mul(10**(18 - decimals));
        }
    }

    function denormalize(uint256 amount, uint8 decimals) internal pure returns (uint256) {

        if (decimals == 18) {
            return amount;
        } else if (decimals > 18) {
            return amount.mul(10**(decimals - 18));
        } else {
            return amount.div(10**(18 - decimals));
        }
    }
}// GPL-3.0-or-later

pragma solidity 0.7.5;

interface IIntegralOracleV3 {

    event OwnerSet(address owner);
    event UniswapPairSet(address uniswapPair);
    event PriceUpdateIntervalSet(uint32 interval);
    event PriceBoundsSet(int256 minPrice, int256 maxPrice);
    event ParametersSet(uint32 epoch, int256[] bidExponents, int256[] bidQs, int256[] askExponents, int256[] askQs);

    function owner() external view returns (address);


    function setOwner(address) external;


    function epoch() external view returns (uint32);


    function xDecimals() external view returns (uint8);


    function yDecimals() external view returns (uint8);


    function getParameters()
        external
        view
        returns (
            int256[] memory bidExponents,
            int256[] memory bidQs,
            int256[] memory askExponents,
            int256[] memory askQs
        );


    function setParameters(
        int256[] calldata bidExponents,
        int256[] calldata bidQs,
        int256[] calldata askExponents,
        int256[] calldata askQs
    ) external;


    function price() external view returns (int256);


    function minPrice() external view returns (int256);


    function maxPrice() external view returns (int256);


    function priceUpdateInterval() external view returns (uint32);


    function updatePrice() external returns (uint32 _epoch);


    function setPriceUpdateInterval(uint32 interval) external;


    function setPriceBounds(int256 _minPrice, int256 _maxPrice) external;


    function blockTimestampLast() external view returns (uint256);


    function tradeX(
        uint256 xAfter,
        uint256 xBefore,
        uint256 yBefore
    ) external view returns (uint256 yAfter);


    function tradeY(
        uint256 yAfter,
        uint256 xBefore,
        uint256 yBefore
    ) external view returns (uint256 xAfter);


    function getSpotPrice(uint256 xCurrent, uint256 xBefore) external view returns (uint256 spotPrice);

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
pragma solidity >=0.5.0 <0.8.0;


library OracleLibrary {

    function consult(address pool, uint32 period) internal view returns (int24 timeWeightedAverageTick) {

        require(period != 0, 'BP');

        uint32[] memory secondAgos = new uint32[](2);
        secondAgos[0] = period;
        secondAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(secondAgos);
        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        timeWeightedAverageTick = int24(tickCumulativesDelta / period);

        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % period != 0)) timeWeightedAverageTick--;
    }

    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) internal pure returns (uint256 quoteAmount) {

        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }
}// GPL-3.0-or-later

pragma solidity 0.7.5;


contract IntegralOracleV3 is IIntegralOracleV3 {

    using FixedSafeMath for int256;
    using SafeMath for int256;
    using SafeMath for uint256;
    using Normalizer for uint256;

    address public override owner;
    address public uniswapPair;
    address public token0;
    address public token1;

    int256 public override price;
    int256 public override minPrice = 0;
    int256 public override maxPrice = type(int256).max;
    uint32 public override epoch;

    int256 private constant _ONE = 10**18;
    int256 private constant _TWO = 2 * 10**18;
    uint128 private immutable _ONE_IN_X;

    uint8 public override xDecimals;
    uint8 public override yDecimals;

    int256[] private bidExponents;
    int256[] private bidQs;
    int256[] private askExponents;
    int256[] private askQs;

    uint32 public override priceUpdateInterval = 2 minutes;
    uint256 public override blockTimestampLast;

    constructor(uint8 _xDecimals, uint8 _yDecimals) {
        require(_xDecimals <= 100 && _yDecimals <= 100, 'IO_DECIMALS_HIGHER_THAN_100');
        owner = msg.sender;
        xDecimals = _xDecimals;
        yDecimals = _yDecimals;
        _ONE_IN_X = uint128(10**xDecimals);
    }

    function isContract(address addr) private view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function setOwner(address _owner) external override {

        require(msg.sender == owner, 'IO_FORBIDDEN');
        owner = _owner;
        emit OwnerSet(owner);
    }

    function setUniswapPair(address _uniswapPair) external {

        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(_uniswapPair != address(0), 'IO_ADDRESS_ZERO');
        require(isContract(_uniswapPair), 'IO_UNISWAP_PAIR_MUST_BE_CONTRACT');
        IUniswapV3Pool uniswapV3Pool = IUniswapV3Pool(_uniswapPair);
        require(uniswapV3Pool.liquidity() != 0, 'IO_NO_UNISWAP_LIQUIDITY');

        uniswapPair = _uniswapPair;
        token0 = uniswapV3Pool.token0();
        token1 = uniswapV3Pool.token1();
        require(
            IERC20(token0).decimals() == xDecimals && IERC20(token1).decimals() == yDecimals,
            'IO_INVALID_DECIMALS'
        );
        _updatePrice();

        emit UniswapPairSet(uniswapPair);
    }

    function setPriceUpdateInterval(uint32 interval) external override {

        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(interval > 0, 'IO_INTERVAL_CANNOT_BE_ZERO');
        priceUpdateInterval = interval;
        emit PriceUpdateIntervalSet(interval);
    }

    function setPriceBounds(int256 _minPrice, int256 _maxPrice) external override {

        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(_minPrice <= _maxPrice, 'IO_INVALID_BOUNDS');
        minPrice = _minPrice;
        maxPrice = _maxPrice;
        emit PriceBoundsSet(minPrice, maxPrice);
    }

    function updatePrice() external override returns (uint32) {

        if (uniswapPair == address(0)) {
            return epoch;
        }

        uint256 timeElapsed = block.timestamp - blockTimestampLast;
        if (timeElapsed >= priceUpdateInterval) {
            _updatePrice();
            epoch += 1; // overflow is desired
        }

        return epoch;
    }

    function _updatePrice() internal {

        int24 tick = OracleLibrary.consult(uniswapPair, priceUpdateInterval);
        uint256 uniswapPrice = OracleLibrary.getQuoteAtTick(tick, _ONE_IN_X, token0, token1);
        price = normalizeAmount(yDecimals, uniswapPrice);
        require(price >= minPrice && price <= maxPrice, 'IO_PRICE_OUT_OF_BOUNDS');

        blockTimestampLast = block.timestamp;
    }

    function normalizeAmount(uint8 decimals, uint256 amount) internal pure returns (int256 result) {

        result = int256(amount.normalize(decimals));
        require(result >= 0, 'IO_INPUT_OVERFLOW');
    }

    function getParameters()
        external
        view
        override
        returns (
            int256[] memory _bidExponents,
            int256[] memory _bidQs,
            int256[] memory _askExponents,
            int256[] memory _askQs
        )
    {

        _bidExponents = bidExponents;
        _bidQs = bidQs;
        _askExponents = askExponents;
        _askQs = askQs;
    }

    function setParameters(
        int256[] calldata _bidExponents,
        int256[] calldata _bidQs,
        int256[] calldata _askExponents,
        int256[] calldata _askQs
    ) public override {

        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(_bidExponents.length == _bidQs.length, 'IO_LENGTH_MISMATCH');
        require(_askExponents.length == _askQs.length, 'IO_LENGTH_MISMATCH');

        bidExponents = _bidExponents;
        bidQs = _bidQs;
        askExponents = _askExponents;
        askQs = _askQs;

        epoch += 1; // overflow is desired
        emit ParametersSet(epoch, bidExponents, bidQs, askExponents, askQs);
    }


    function tradeX(
        uint256 xAfter,
        uint256 xBefore,
        uint256 yBefore
    ) public view override returns (uint256 yAfter) {

        int256 xAfterInt = normalizeAmount(xDecimals, xAfter);
        int256 xBeforeInt = normalizeAmount(xDecimals, xBefore);
        int256 yBeforeInt = normalizeAmount(yDecimals, yBefore);
        int256 yAfterInt = yBeforeInt.sub(integral(xAfterInt.sub(xBeforeInt)));
        require(yAfterInt >= 0, 'IO_NEGATIVE_Y_BALANCE');
        return uint256(yAfterInt).denormalize(yDecimals);
    }

    function tradeY(
        uint256 yAfter,
        uint256 xBefore,
        uint256 yBefore
    ) public view override returns (uint256 xAfter) {

        int256 yAfterInt = normalizeAmount(yDecimals, yAfter);
        int256 xBeforeInt = normalizeAmount(xDecimals, xBefore);
        int256 yBeforeInt = normalizeAmount(yDecimals, yBefore);
        int256 xAfterInt = xBeforeInt.add(integralInverted(yBeforeInt.sub(yAfterInt)));
        require(xAfterInt >= 0, 'IO_NEGATIVE_X_BALANCE');
        return uint256(xAfterInt).denormalize(xDecimals);
    }


    function integral(int256 q) private view returns (int256) {

        if (q > 0) {
            return integralBid(q);
        } else if (q < 0) {
            return integralAsk(q);
        } else {
            return 0;
        }
    }

    function integralBid(int256 q) private view returns (int256) {

        int256 C = 0;
        for (uint256 i = 1; i < bidExponents.length; i++) {
            int256 pPrevious = price.f18Mul(bidExponents[i - 1]);
            int256 pCurrent = price.f18Mul(bidExponents[i]);

            int256 qPrevious = bidQs[i - 1];
            int256 qCurrent = bidQs[i];

            if (q <= qCurrent) {
                int256 X = pPrevious.add(pCurrent).mul(qCurrent.sub(qPrevious)).add(
                    pCurrent.sub(pPrevious).mul(q.sub(qCurrent))
                );
                int256 Y = q.sub(qPrevious);
                int256 Z = qCurrent.sub(qPrevious);
                int256 A = X.mul(Y).div(Z).div(_TWO);
                return C.add(A);
            } else {
                int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function integralAsk(int256 q) private view returns (int256) {

        int256 C = 0;
        for (uint256 i = 1; i < askExponents.length; i++) {
            int256 pPrevious = price.f18Mul(askExponents[i - 1]);
            int256 pCurrent = price.f18Mul(askExponents[i]);

            int256 qPrevious = askQs[i - 1];
            int256 qCurrent = askQs[i];

            if (q >= qCurrent) {
                int256 X = pPrevious.add(pCurrent).mul(qCurrent.sub(qPrevious)).add(
                    pCurrent.sub(pPrevious).mul(q.sub(qCurrent))
                );
                int256 Y = q.sub(qPrevious);
                int256 Z = qCurrent.sub(qPrevious);
                int256 A = X.mul(Y).div(Z).div(_TWO);
                return C.add(A);
            } else {
                int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function integralInverted(int256 s) private view returns (int256) {

        if (s > 0) {
            return integralBidInverted(s);
        } else if (s < 0) {
            return integralAskInverted(s);
        } else {
            return 0;
        }
    }

    function integralBidInverted(int256 s) private view returns (int256) {

        int256 _s = s.add(1);
        int256 C = 0;
        for (uint256 i = 1; i < bidExponents.length; i++) {
            int256 pPrevious = price.f18Mul(bidExponents[i - 1]);
            int256 pCurrent = price.f18Mul(bidExponents[i]);
            int256 qPrevious = bidQs[i - 1];
            int256 qCurrent = bidQs[i];
            int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
            if (_s <= C.add(A)) {
                int256 c = C.sub(_s);
                int256 b = pPrevious;
                int256 a = pCurrent.sub(b);
                int256 d = qCurrent.sub(qPrevious);
                int256 h = f18SolveQuadratic(a, b, c, d);
                return qPrevious.add(h);
            } else {
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function integralAskInverted(int256 s) private view returns (int256) {

        int256 C = 0;
        for (uint256 i = 1; i < askExponents.length; i++) {
            int256 pPrevious = price.f18Mul(askExponents[i - 1]);
            int256 pCurrent = price.f18Mul(askExponents[i]);
            int256 qPrevious = askQs[i - 1];
            int256 qCurrent = askQs[i];
            int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
            if (s >= C.add(A)) {
                int256 a = pCurrent.sub(pPrevious);
                int256 d = qCurrent.sub(qPrevious);
                int256 b = pPrevious;
                int256 c = C.sub(s);
                int256 h = f18SolveQuadratic(a, b, c, d);
                return qPrevious.add(h).sub(1);
            } else {
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function f18SolveQuadratic(
        int256 A,
        int256 B,
        int256 C,
        int256 D
    ) private pure returns (int256) {

        int256 inside = B.mul(B).sub(_TWO.mul(A).mul(C).div(D));
        int256 sqroot = int256(Math.sqrt(uint256(inside)));
        int256 x = sqroot.sub(B).mul(D).div(A);
        for (uint256 i = 0; i < 16; i++) {
            int256 xPrev = x;
            int256 z = A.mul(x);
            x = z.mul(x).div(2).sub(C.mul(D).mul(_ONE)).div(z.add(B.mul(D)));
            if (x > xPrev) {
                if (x.sub(xPrev) <= int256(1)) {
                    return x;
                }
            } else {
                if (xPrev.sub(x) <= int256(1)) {
                    return x;
                }
            }
        }
        revert('IO_OVERFLOW');
    }


    function getSpotPrice(uint256 xCurrent, uint256 xBefore) public view override returns (uint256 spotPrice) {

        int256 xCurrentInt = normalizeAmount(xDecimals, xCurrent);
        int256 xBeforeInt = normalizeAmount(xDecimals, xBefore);
        int256 spotPriceInt = derivative(xCurrentInt.sub(xBeforeInt));
        require(spotPriceInt >= 0, 'IO_NEGATIVE_SPOT_PRICE');
        return uint256(spotPriceInt);
    }


    function derivative(int256 t) public view returns (int256) {

        if (t > 0) {
            return derivativeBid(t);
        } else if (t < 0) {
            return derivativeAsk(t);
        } else {
            return price;
        }
    }

    function derivativeBid(int256 t) public view returns (int256) {

        for (uint256 i = 1; i < bidExponents.length; i++) {
            int256 pPrevious = price.f18Mul(bidExponents[i - 1]);
            int256 pCurrent = price.f18Mul(bidExponents[i]);
            int256 qPrevious = bidQs[i - 1];
            int256 qCurrent = bidQs[i];
            if (t <= qCurrent) {
                return (pCurrent.sub(pPrevious)).f18Mul(t.sub(qCurrent)).f18Div(qCurrent.sub(qPrevious)).add(pCurrent);
            }
        }
        revert('IO_OVERFLOW');
    }

    function derivativeAsk(int256 t) public view returns (int256) {

        for (uint256 i = 1; i < askExponents.length; i++) {
            int256 pPrevious = price.f18Mul(askExponents[i - 1]);
            int256 pCurrent = price.f18Mul(askExponents[i]);
            int256 qPrevious = askQs[i - 1];
            int256 qCurrent = askQs[i];
            if (t >= qCurrent) {
                return (pCurrent.sub(pPrevious)).f18Mul(t.sub(qCurrent)).f18Div(qCurrent.sub(qPrevious)).add(pCurrent);
            }
        }
        revert('IO_OVERFLOW');
    }
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

}pragma solidity >=0.4.0;

library FixedPoint {

    struct uq112x112 {
        uint224 _x;
    }

    struct uq144x112 {
        uint _x;
    }

    uint8 private constant RESOLUTION = 112;

    function encode(uint112 x) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(x) << RESOLUTION);
    }

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {

        return uq144x112(uint256(x) << RESOLUTION);
    }

    function div(uq112x112 memory self, uint112 x) internal pure returns (uq112x112 memory) {

        require(x != 0, 'FixedPoint: DIV_BY_ZERO');
        return uq112x112(self._x / uint224(x));
    }

    function mul(uq112x112 memory self, uint y) internal pure returns (uq144x112 memory) {

        uint z;
        require(y == 0 || (z = uint(self._x) * y) / y == uint(self._x), "FixedPoint: MULTIPLICATION_OVERFLOW");
        return uq144x112(z);
    }

    function fraction(uint112 numerator, uint112 denominator) internal pure returns (uq112x112 memory) {

        require(denominator > 0, "FixedPoint: DIV_BY_ZERO");
        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);
    }

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);
    }

    function decode144(uq144x112 memory self) internal pure returns (uint144) {

        return uint144(self._x >> RESOLUTION);
    }
}pragma solidity >=0.5.0;


library UniswapV2OracleLibrary {

    using FixedPoint for *;

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2 ** 32);
    }

    function currentCumulativePrices(
        address pair
    ) internal view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {

        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();

        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative += uint(FixedPoint.fraction(reserve1, reserve0)._x) * timeElapsed;
            price1Cumulative += uint(FixedPoint.fraction(reserve0, reserve1)._x) * timeElapsed;
        }
    }
}// GPL-3.0-or-later

pragma solidity 0.7.5;


contract IntegralOracle is IIntegralOracle {

    using FixedSafeMath for int256;
    using SafeMath for int256;
    using SafeMath for uint256;
    using Normalizer for uint256;

    address public override owner;
    address public uniswapPair;

    int256 public override price;
    uint32 public override epoch;

    int256 private constant _ONE = 10**18;
    int256 private constant _TWO = 2 * 10**18;

    uint8 public override xDecimals;
    uint8 public override yDecimals;

    int256[] private bidExponents;
    int256[] private bidQs;
    int256[] private askExponents;
    int256[] private askQs;

    uint32 public override priceUpdateInterval = 5 minutes;
    uint256 public override price0CumulativeLast;
    uint32 public override blockTimestampLast;

    constructor(uint8 _xDecimals, uint8 _yDecimals) {
        require(_xDecimals <= 100 && _yDecimals <= 100, 'IO_DECIMALS_HIGHER_THAN_100');
        owner = msg.sender;
        xDecimals = _xDecimals;
        yDecimals = _yDecimals;
    }

    function isContract(address addr) private view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function setOwner(address _owner) external override {

        require(msg.sender == owner, 'IO_FORBIDDEN');
        owner = _owner;
        emit OwnerSet(owner);
    }

    function setUniswapPair(address _uniswapPair) external {

        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(_uniswapPair != address(0), 'IO_ADDRESS_ZERO');
        require(isContract(_uniswapPair), 'IO_UNISWAP_PAIR_MUST_BE_CONTRACT');
        uniswapPair = _uniswapPair;
        emit UniswapPairSet(uniswapPair);

        price0CumulativeLast = IUniswapV2Pair(uniswapPair).price0CumulativeLast();
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestamp) = IUniswapV2Pair(uniswapPair).getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'IO_NO_UNISWAP_RESERVES');
        blockTimestampLast = blockTimestamp;
        emit UniswapPairSet(uniswapPair);
    }

    function setPriceUpdateInterval(uint32 interval) public override {

        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(interval > 0, 'IO_INTERVAL_CANNOT_BE_ZERO');
        priceUpdateInterval = interval;
        emit PriceUpdateIntervalSet(interval);
    }

    function updatePrice() public override returns (uint32 _epoch) {

        if (uniswapPair == address(0)) {
            return epoch;
        }

        (uint256 price0Cumulative, , uint32 blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(
            uniswapPair
        );

        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed >= priceUpdateInterval) {
            FixedPoint.uq112x112 memory price0Average = FixedPoint.uq112x112(
                uint224((price0Cumulative - price0CumulativeLast) / timeElapsed)
            );
            uint256 multiplyBy = xDecimals > yDecimals ? 10**(xDecimals - yDecimals) : 1;
            uint256 divideBy = yDecimals > xDecimals ? 10**(yDecimals - xDecimals) : 1;
            price = int256(uint256(price0Average._x).mul(10**18).mul(multiplyBy).div(divideBy).div(2**112));
            price0CumulativeLast = price0Cumulative;
            blockTimestampLast = blockTimestamp;

            epoch += 1; // overflow is desired
        }

        return epoch;
    }

    function normalizeAmount(uint8 decimals, uint256 amount) internal pure returns (int256 result) {

        result = int256(amount.normalize(decimals));
        require(result >= 0, 'IO_INPUT_OVERFLOW');
    }

    function getParameters()
        external
        view
        override
        returns (
            int256[] memory _bidExponents,
            int256[] memory _bidQs,
            int256[] memory _askExponents,
            int256[] memory _askQs
        )
    {

        _bidExponents = bidExponents;
        _bidQs = bidQs;
        _askExponents = askExponents;
        _askQs = askQs;
    }

    function setParameters(
        int256[] calldata _bidExponents,
        int256[] calldata _bidQs,
        int256[] calldata _askExponents,
        int256[] calldata _askQs
    ) public override {

        require(msg.sender == owner, 'IO_FORBIDDEN');
        require(_bidExponents.length == _bidQs.length, 'IO_LENGTH_MISMATCH');
        require(_askExponents.length == _askQs.length, 'IO_LENGTH_MISMATCH');

        bidExponents = _bidExponents;
        bidQs = _bidQs;
        askExponents = _askExponents;
        askQs = _askQs;

        epoch += 1; // overflow is desired
        emit ParametersSet(epoch, bidExponents, bidQs, askExponents, askQs);
    }


    function tradeX(
        uint256 xAfter,
        uint256 xBefore,
        uint256 yBefore
    ) public view override returns (uint256 yAfter) {

        int256 xAfterInt = normalizeAmount(xDecimals, xAfter);
        int256 xBeforeInt = normalizeAmount(xDecimals, xBefore);
        int256 yBeforeInt = normalizeAmount(yDecimals, yBefore);
        int256 yAfterInt = yBeforeInt.sub(integral(xAfterInt.sub(xBeforeInt)));
        require(yAfterInt >= 0, 'IO_NEGATIVE_Y_BALANCE');
        return uint256(yAfterInt).denormalize(yDecimals);
    }

    function tradeY(
        uint256 yAfter,
        uint256 xBefore,
        uint256 yBefore
    ) public view override returns (uint256 xAfter) {

        int256 yAfterInt = normalizeAmount(yDecimals, yAfter);
        int256 xBeforeInt = normalizeAmount(xDecimals, xBefore);
        int256 yBeforeInt = normalizeAmount(yDecimals, yBefore);
        int256 xAfterInt = xBeforeInt.add(integralInverted(yBeforeInt.sub(yAfterInt)));
        require(xAfterInt >= 0, 'IO_NEGATIVE_X_BALANCE');
        return uint256(xAfterInt).denormalize(xDecimals);
    }


    function integral(int256 q) private view returns (int256) {

        if (q > 0) {
            return integralBid(q);
        } else if (q < 0) {
            return integralAsk(q);
        } else {
            return 0;
        }
    }

    function integralBid(int256 q) private view returns (int256) {

        int256 C = 0;
        for (uint256 i = 1; i < bidExponents.length; i++) {
            int256 pPrevious = price.f18Mul(bidExponents[i - 1]);
            int256 pCurrent = price.f18Mul(bidExponents[i]);

            int256 qPrevious = bidQs[i - 1];
            int256 qCurrent = bidQs[i];

            if (q <= qCurrent) {
                int256 X = pPrevious.add(pCurrent).mul(qCurrent.sub(qPrevious)).add(
                    pCurrent.sub(pPrevious).mul(q.sub(qCurrent))
                );
                int256 Y = q.sub(qPrevious);
                int256 Z = qCurrent.sub(qPrevious);
                int256 A = X.mul(Y).div(Z).div(_TWO);
                return C.add(A);
            } else {
                int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function integralAsk(int256 q) private view returns (int256) {

        int256 C = 0;
        for (uint256 i = 1; i < askExponents.length; i++) {
            int256 pPrevious = price.f18Mul(askExponents[i - 1]);
            int256 pCurrent = price.f18Mul(askExponents[i]);

            int256 qPrevious = askQs[i - 1];
            int256 qCurrent = askQs[i];

            if (q >= qCurrent) {
                int256 X = pPrevious.add(pCurrent).mul(qCurrent.sub(qPrevious)).add(
                    pCurrent.sub(pPrevious).mul(q.sub(qCurrent))
                );
                int256 Y = q.sub(qPrevious);
                int256 Z = qCurrent.sub(qPrevious);
                int256 A = X.mul(Y).div(Z).div(_TWO);
                return C.add(A);
            } else {
                int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function integralInverted(int256 s) private view returns (int256) {

        if (s > 0) {
            return integralBidInverted(s);
        } else if (s < 0) {
            return integralAskInverted(s);
        } else {
            return 0;
        }
    }

    function integralBidInverted(int256 s) private view returns (int256) {

        int256 _s = s.add(1);
        int256 C = 0;
        for (uint256 i = 1; i < bidExponents.length; i++) {
            int256 pPrevious = price.f18Mul(bidExponents[i - 1]);
            int256 pCurrent = price.f18Mul(bidExponents[i]);
            int256 qPrevious = bidQs[i - 1];
            int256 qCurrent = bidQs[i];
            int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
            if (_s <= C.add(A)) {
                int256 c = C.sub(_s);
                int256 b = pPrevious;
                int256 a = pCurrent.sub(b);
                int256 d = qCurrent.sub(qPrevious);
                int256 h = f18SolveQuadratic(a, b, c, d);
                return qPrevious.add(h);
            } else {
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function integralAskInverted(int256 s) private view returns (int256) {

        int256 C = 0;
        for (uint256 i = 1; i < askExponents.length; i++) {
            int256 pPrevious = price.f18Mul(askExponents[i - 1]);
            int256 pCurrent = price.f18Mul(askExponents[i]);
            int256 qPrevious = askQs[i - 1];
            int256 qCurrent = askQs[i];
            int256 A = pPrevious.add(pCurrent).f18Mul(qCurrent.sub(qPrevious)).div(2);
            if (s >= C.add(A)) {
                int256 a = pCurrent.sub(pPrevious);
                int256 d = qCurrent.sub(qPrevious);
                int256 b = pPrevious;
                int256 c = C.sub(s);
                int256 h = f18SolveQuadratic(a, b, c, d);
                return qPrevious.add(h).sub(1);
            } else {
                C = C.add(A);
            }
        }
        revert('IO_OVERFLOW');
    }

    function f18SolveQuadratic(
        int256 A,
        int256 B,
        int256 C,
        int256 D
    ) private pure returns (int256) {

        int256 inside = B.mul(B).sub(_TWO.mul(A).mul(C).div(D));
        int256 sqroot = int256(Math.sqrt(uint256(inside)));
        int256 x = sqroot.sub(B).mul(D).div(A);
        for (uint256 i = 0; i < 16; i++) {
            int256 xPrev = x;
            int256 z = A.mul(x);
            x = z.mul(x).div(2).sub(C.mul(D).mul(_ONE)).div(z.add(B.mul(D)));
            if (x > xPrev) {
                if (x.sub(xPrev) <= int256(1)) {
                    return x;
                }
            } else {
                if (xPrev.sub(x) <= int256(1)) {
                    return x;
                }
            }
        }
        revert('IO_OVERFLOW');
    }


    function getSpotPrice(uint256 xCurrent, uint256 xBefore) public view override returns (uint256 spotPrice) {

        int256 xCurrentInt = normalizeAmount(xDecimals, xCurrent);
        int256 xBeforeInt = normalizeAmount(xDecimals, xBefore);
        int256 spotPriceInt = derivative(xCurrentInt.sub(xBeforeInt));
        require(spotPriceInt >= 0, 'IO_NEGATIVE_SPOT_PRICE');
        return uint256(spotPriceInt);
    }


    function derivative(int256 t) public view returns (int256) {

        if (t > 0) {
            return derivativeBid(t);
        } else if (t < 0) {
            return derivativeAsk(t);
        } else {
            return price;
        }
    }

    function derivativeBid(int256 t) public view returns (int256) {

        for (uint256 i = 1; i < bidExponents.length; i++) {
            int256 pPrevious = price.f18Mul(bidExponents[i - 1]);
            int256 pCurrent = price.f18Mul(bidExponents[i]);
            int256 qPrevious = bidQs[i - 1];
            int256 qCurrent = bidQs[i];
            if (t <= qCurrent) {
                return (pCurrent.sub(pPrevious)).f18Mul(t.sub(qCurrent)).f18Div(qCurrent.sub(qPrevious)).add(pCurrent);
            }
        }
        revert('IO_OVERFLOW');
    }

    function derivativeAsk(int256 t) public view returns (int256) {

        for (uint256 i = 1; i < askExponents.length; i++) {
            int256 pPrevious = price.f18Mul(askExponents[i - 1]);
            int256 pCurrent = price.f18Mul(askExponents[i]);
            int256 qPrevious = askQs[i - 1];
            int256 qCurrent = askQs[i];
            if (t >= qCurrent) {
                return (pCurrent.sub(pPrevious)).f18Mul(t.sub(qCurrent)).f18Div(qCurrent.sub(qPrevious)).add(pCurrent);
            }
        }
        revert('IO_OVERFLOW');
    }
}// GPL-3.0-or-later

pragma solidity 0.7.5;



contract IntegralPriceReader {

    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;

    address public factory;
    address public owner;
    mapping(address => bool) public isOracleV3;

    event SetOracleV3(address oracle, bool isV3);
    event OwnerSet(address newOwner);

    constructor(address _factory) {
        factory = _factory;
        owner = msg.sender;
    }

    function setOwner(address _owner) external {

        require(msg.sender == owner, 'PR_FORBIDDEN');
        owner = _owner;
        emit OwnerSet(owner);
    }

    function setOracleV3(address oracle, bool isV3) external {

        require(msg.sender == owner, 'PR_FORBIDDEN');
        require(oracle != address(0), 'PR_INVALID_ORACLE');
        isOracleV3[oracle] = isV3;

        emit SetOracleV3(oracle, isV3);
    }

    function getOracle(address token0, address token1) public view returns (address oracle) {

        require(token0 != address(0) && token1 != address(0), 'PR_INVALID_TOKEN');
        address pair = IIntegralFactory(factory).getPair(token0, token1);
        require(pair != address(0), 'PR_PAIR_NOT_FOUND');
        oracle = IIntegralPair(pair).oracle();
    }

    function getPrice(address token0, address token1) external view returns (uint256 price) {

        address oracle = getOracle(token0, token1);
        if (isOracleV3[oracle]) {
            price = _getPriceV3(IntegralOracleV3(oracle));
        } else {
            price = _getPriceV2(IntegralOracle(oracle));
        }
    }

    function _getPriceV2(IntegralOracle oracle) internal view returns (uint256 price) {

        address uniswapPair = oracle.uniswapPair();
        require(uniswapPair != address(0), 'PR_INVALID_UN_PAIR');

        (uint256 multiplier, uint256 divider) = _getPriceMultipliers(oracle.xDecimals(), oracle.yDecimals());

        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(uniswapPair).getReserves();
        price = reserve1.mul(ONE).mul(multiplier).div(reserve0).div(divider);
    }

    function _getPriceV3(IntegralOracleV3 oracle) internal view returns (uint256 price) {

        address uniswapPair = oracle.uniswapPair();
        require(uniswapPair != address(0), 'PR_INVALID_UNV3_PAIR');

        (uint256 multiplier, uint256 divider) = _getPriceMultipliers(oracle.xDecimals(), oracle.yDecimals());
        (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(uniswapPair).slot0();
        price = (uint256(sqrtPriceX96)**2).mul(ONE).mul(multiplier).div(divider) >> 192;
    }

    function _getPriceMultipliers(uint8 xDecimals, uint8 yDecimals)
        internal
        pure
        returns (uint256 multiplier, uint256 divider)
    {

        if (xDecimals > yDecimals) {
            multiplier = 10**(xDecimals - yDecimals);
            divider = 1;
        } else {
            multiplier = 1;
            divider = 10**(yDecimals - xDecimals);
        }
    }
}