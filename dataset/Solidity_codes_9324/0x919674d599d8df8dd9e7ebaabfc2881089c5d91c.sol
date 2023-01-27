
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

library SafeCast {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// Unlicense
pragma solidity >=0.8.4;

error PRBMath__MulDivFixedPointOverflow(uint256 prod1);

error PRBMath__MulDivOverflow(uint256 prod1, uint256 denominator);

error PRBMath__MulDivSignedInputTooSmall();

error PRBMath__MulDivSignedOverflow(uint256 rAbs);

error PRBMathSD59x18__AbsInputTooSmall();

error PRBMathSD59x18__CeilOverflow(int256 x);

error PRBMathSD59x18__DivInputTooSmall();

error PRBMathSD59x18__DivOverflow(uint256 rAbs);

error PRBMathSD59x18__ExpInputTooBig(int256 x);

error PRBMathSD59x18__Exp2InputTooBig(int256 x);

error PRBMathSD59x18__FloorUnderflow(int256 x);

error PRBMathSD59x18__FromIntOverflow(int256 x);

error PRBMathSD59x18__FromIntUnderflow(int256 x);

error PRBMathSD59x18__GmNegativeProduct(int256 x, int256 y);

error PRBMathSD59x18__GmOverflow(int256 x, int256 y);

error PRBMathSD59x18__LogInputTooSmall(int256 x);

error PRBMathSD59x18__MulInputTooSmall();

error PRBMathSD59x18__MulOverflow(uint256 rAbs);

error PRBMathSD59x18__PowuOverflow(uint256 rAbs);

error PRBMathSD59x18__SqrtNegativeInput(int256 x);

error PRBMathSD59x18__SqrtOverflow(int256 x);

error PRBMathUD60x18__AddOverflow(uint256 x, uint256 y);

error PRBMathUD60x18__CeilOverflow(uint256 x);

error PRBMathUD60x18__ExpInputTooBig(uint256 x);

error PRBMathUD60x18__Exp2InputTooBig(uint256 x);

error PRBMathUD60x18__FromUintOverflow(uint256 x);

error PRBMathUD60x18__GmOverflow(uint256 x, uint256 y);

error PRBMathUD60x18__LogInputTooSmall(uint256 x);

error PRBMathUD60x18__SqrtOverflow(uint256 x);

error PRBMathUD60x18__SubUnderflow(uint256 x, uint256 y);

library PRBMath {


    struct SD59x18 {
        int256 value;
    }

    struct UD60x18 {
        uint256 value;
    }


    uint256 internal constant SCALE = 1e18;

    uint256 internal constant SCALE_LPOTD = 262144;

    uint256 internal constant SCALE_INVERSE =
        78156646155174841979727994598816262306175212592076161876661_508869554232690281;


    function exp2(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = 0x800000000000000000000000000000000000000000000000;

            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }

            result *= SCALE;
            result >>= (191 - (x >> 64));
        }
    }

    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {

        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            msb += 1;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            unchecked {
                result = prod0 / denominator;
            }
            return result;
        }

        if (prod1 >= denominator) {
            revert PRBMath__MulDivOverflow(prod1, denominator);
        }


        uint256 remainder;
        assembly {
            remainder := mulmod(x, y, denominator)

            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        unchecked {
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, lpotdod)

                prod0 := div(prod0, lpotdod)

                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            prod0 |= prod1 * lpotdod;

            uint256 inverse = (3 * denominator) ^ 2;

            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            result = prod0 * inverse;
            return result;
        }
    }

    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {

        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 >= SCALE) {
            revert PRBMath__MulDivFixedPointOverflow(prod1);
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    function mulDivSigned(
        int256 x,
        int256 y,
        int256 denominator
    ) internal pure returns (int256 result) {

        if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
            revert PRBMath__MulDivSignedInputTooSmall();
        }

        uint256 ax;
        uint256 ay;
        uint256 ad;
        unchecked {
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);
            ad = denominator < 0 ? uint256(-denominator) : uint256(denominator);
        }

        uint256 rAbs = mulDiv(ax, ay, ad);
        if (rAbs > uint256(type(int256).max)) {
            revert PRBMath__MulDivSignedOverflow(rAbs);
        }

        uint256 sx;
        uint256 sy;
        uint256 sd;
        assembly {
            sx := sgt(x, sub(0, 1))
            sy := sgt(y, sub(0, 1))
            sd := sgt(denominator, sub(0, 1))
        }

        result = sx ^ sy ^ sd == 0 ? -int256(rAbs) : int256(rAbs);
    }

    function sqrt(uint256 x) internal pure returns (uint256 result) {

        if (x == 0) {
            return 0;
        }

        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
}// Unlicense
pragma solidity >=0.8.4;


library PRBMathSD59x18 {

    int256 internal constant LOG2_E = 1_442695040888963407;

    int256 internal constant HALF_SCALE = 5e17;

    int256 internal constant MAX_SD59x18 =
        57896044618658097711785492504343953926634992332820282019728_792003956564819967;

    int256 internal constant MAX_WHOLE_SD59x18 =
        57896044618658097711785492504343953926634992332820282019728_000000000000000000;

    int256 internal constant MIN_SD59x18 =
        -57896044618658097711785492504343953926634992332820282019728_792003956564819968;

    int256 internal constant MIN_WHOLE_SD59x18 =
        -57896044618658097711785492504343953926634992332820282019728_000000000000000000;

    int256 internal constant SCALE = 1e18;


    function abs(int256 x) internal pure returns (int256 result) {

        unchecked {
            if (x == MIN_SD59x18) {
                revert PRBMathSD59x18__AbsInputTooSmall();
            }
            result = x < 0 ? -x : x;
        }
    }

    function avg(int256 x, int256 y) internal pure returns (int256 result) {

        unchecked {
            int256 sum = (x >> 1) + (y >> 1);
            if (sum < 0) {
                assembly {
                    result := add(sum, and(or(x, y), 1))
                }
            } else {
                result = sum + (x & y & 1);
            }
        }
    }

    function ceil(int256 x) internal pure returns (int256 result) {

        if (x > MAX_WHOLE_SD59x18) {
            revert PRBMathSD59x18__CeilOverflow(x);
        }
        unchecked {
            int256 remainder = x % SCALE;
            if (remainder == 0) {
                result = x;
            } else {
                result = x - remainder;
                if (x > 0) {
                    result += SCALE;
                }
            }
        }
    }

    function div(int256 x, int256 y) internal pure returns (int256 result) {

        if (x == MIN_SD59x18 || y == MIN_SD59x18) {
            revert PRBMathSD59x18__DivInputTooSmall();
        }

        uint256 ax;
        uint256 ay;
        unchecked {
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);
        }

        uint256 rAbs = PRBMath.mulDiv(ax, uint256(SCALE), ay);
        if (rAbs > uint256(MAX_SD59x18)) {
            revert PRBMathSD59x18__DivOverflow(rAbs);
        }

        uint256 sx;
        uint256 sy;
        assembly {
            sx := sgt(x, sub(0, 1))
            sy := sgt(y, sub(0, 1))
        }

        result = sx ^ sy == 1 ? -int256(rAbs) : int256(rAbs);
    }

    function e() internal pure returns (int256 result) {

        result = 2_718281828459045235;
    }

    function exp(int256 x) internal pure returns (int256 result) {

        if (x < -41_446531673892822322) {
            return 0;
        }

        if (x >= 133_084258667509499441) {
            revert PRBMathSD59x18__ExpInputTooBig(x);
        }

        unchecked {
            int256 doubleScaleProduct = x * LOG2_E;
            result = exp2((doubleScaleProduct + HALF_SCALE) / SCALE);
        }
    }

    function exp2(int256 x) internal pure returns (int256 result) {

        if (x < 0) {
            if (x < -59_794705707972522261) {
                return 0;
            }

            unchecked {
                result = 1e36 / exp2(-x);
            }
        } else {
            if (x >= 192e18) {
                revert PRBMathSD59x18__Exp2InputTooBig(x);
            }

            unchecked {
                uint256 x192x64 = (uint256(x) << 64) / uint256(SCALE);

                result = int256(PRBMath.exp2(x192x64));
            }
        }
    }

    function floor(int256 x) internal pure returns (int256 result) {

        if (x < MIN_WHOLE_SD59x18) {
            revert PRBMathSD59x18__FloorUnderflow(x);
        }
        unchecked {
            int256 remainder = x % SCALE;
            if (remainder == 0) {
                result = x;
            } else {
                result = x - remainder;
                if (x < 0) {
                    result -= SCALE;
                }
            }
        }
    }

    function frac(int256 x) internal pure returns (int256 result) {

        unchecked {
            result = x % SCALE;
        }
    }

    function fromInt(int256 x) internal pure returns (int256 result) {

        unchecked {
            if (x < MIN_SD59x18 / SCALE) {
                revert PRBMathSD59x18__FromIntUnderflow(x);
            }
            if (x > MAX_SD59x18 / SCALE) {
                revert PRBMathSD59x18__FromIntOverflow(x);
            }
            result = x * SCALE;
        }
    }

    function gm(int256 x, int256 y) internal pure returns (int256 result) {

        if (x == 0) {
            return 0;
        }

        unchecked {
            int256 xy = x * y;
            if (xy / x != y) {
                revert PRBMathSD59x18__GmOverflow(x, y);
            }

            if (xy < 0) {
                revert PRBMathSD59x18__GmNegativeProduct(x, y);
            }

            result = int256(PRBMath.sqrt(uint256(xy)));
        }
    }

    function inv(int256 x) internal pure returns (int256 result) {

        unchecked {
            result = 1e36 / x;
        }
    }

    function ln(int256 x) internal pure returns (int256 result) {

        unchecked {
            result = (log2(x) * SCALE) / LOG2_E;
        }
    }

    function log10(int256 x) internal pure returns (int256 result) {

        if (x <= 0) {
            revert PRBMathSD59x18__LogInputTooSmall(x);
        }

        assembly {
            switch x
            case 1 { result := mul(SCALE, sub(0, 18)) }
            case 10 { result := mul(SCALE, sub(1, 18)) }
            case 100 { result := mul(SCALE, sub(2, 18)) }
            case 1000 { result := mul(SCALE, sub(3, 18)) }
            case 10000 { result := mul(SCALE, sub(4, 18)) }
            case 100000 { result := mul(SCALE, sub(5, 18)) }
            case 1000000 { result := mul(SCALE, sub(6, 18)) }
            case 10000000 { result := mul(SCALE, sub(7, 18)) }
            case 100000000 { result := mul(SCALE, sub(8, 18)) }
            case 1000000000 { result := mul(SCALE, sub(9, 18)) }
            case 10000000000 { result := mul(SCALE, sub(10, 18)) }
            case 100000000000 { result := mul(SCALE, sub(11, 18)) }
            case 1000000000000 { result := mul(SCALE, sub(12, 18)) }
            case 10000000000000 { result := mul(SCALE, sub(13, 18)) }
            case 100000000000000 { result := mul(SCALE, sub(14, 18)) }
            case 1000000000000000 { result := mul(SCALE, sub(15, 18)) }
            case 10000000000000000 { result := mul(SCALE, sub(16, 18)) }
            case 100000000000000000 { result := mul(SCALE, sub(17, 18)) }
            case 1000000000000000000 { result := 0 }
            case 10000000000000000000 { result := SCALE }
            case 100000000000000000000 { result := mul(SCALE, 2) }
            case 1000000000000000000000 { result := mul(SCALE, 3) }
            case 10000000000000000000000 { result := mul(SCALE, 4) }
            case 100000000000000000000000 { result := mul(SCALE, 5) }
            case 1000000000000000000000000 { result := mul(SCALE, 6) }
            case 10000000000000000000000000 { result := mul(SCALE, 7) }
            case 100000000000000000000000000 { result := mul(SCALE, 8) }
            case 1000000000000000000000000000 { result := mul(SCALE, 9) }
            case 10000000000000000000000000000 { result := mul(SCALE, 10) }
            case 100000000000000000000000000000 { result := mul(SCALE, 11) }
            case 1000000000000000000000000000000 { result := mul(SCALE, 12) }
            case 10000000000000000000000000000000 { result := mul(SCALE, 13) }
            case 100000000000000000000000000000000 { result := mul(SCALE, 14) }
            case 1000000000000000000000000000000000 { result := mul(SCALE, 15) }
            case 10000000000000000000000000000000000 { result := mul(SCALE, 16) }
            case 100000000000000000000000000000000000 { result := mul(SCALE, 17) }
            case 1000000000000000000000000000000000000 { result := mul(SCALE, 18) }
            case 10000000000000000000000000000000000000 { result := mul(SCALE, 19) }
            case 100000000000000000000000000000000000000 { result := mul(SCALE, 20) }
            case 1000000000000000000000000000000000000000 { result := mul(SCALE, 21) }
            case 10000000000000000000000000000000000000000 { result := mul(SCALE, 22) }
            case 100000000000000000000000000000000000000000 { result := mul(SCALE, 23) }
            case 1000000000000000000000000000000000000000000 { result := mul(SCALE, 24) }
            case 10000000000000000000000000000000000000000000 { result := mul(SCALE, 25) }
            case 100000000000000000000000000000000000000000000 { result := mul(SCALE, 26) }
            case 1000000000000000000000000000000000000000000000 { result := mul(SCALE, 27) }
            case 10000000000000000000000000000000000000000000000 { result := mul(SCALE, 28) }
            case 100000000000000000000000000000000000000000000000 { result := mul(SCALE, 29) }
            case 1000000000000000000000000000000000000000000000000 { result := mul(SCALE, 30) }
            case 10000000000000000000000000000000000000000000000000 { result := mul(SCALE, 31) }
            case 100000000000000000000000000000000000000000000000000 { result := mul(SCALE, 32) }
            case 1000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 33) }
            case 10000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 34) }
            case 100000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 35) }
            case 1000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 36) }
            case 10000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 37) }
            case 100000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 38) }
            case 1000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 39) }
            case 10000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 40) }
            case 100000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 41) }
            case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 42) }
            case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 43) }
            case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 44) }
            case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 45) }
            case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 46) }
            case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 47) }
            case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 48) }
            case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 49) }
            case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 50) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 51) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 52) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 53) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 54) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 55) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 56) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 57) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 58) }
            default {
                result := MAX_SD59x18
            }
        }

        if (result == MAX_SD59x18) {
            unchecked {
                result = (log2(x) * SCALE) / 3_321928094887362347;
            }
        }
    }

    function log2(int256 x) internal pure returns (int256 result) {

        if (x <= 0) {
            revert PRBMathSD59x18__LogInputTooSmall(x);
        }
        unchecked {
            int256 sign;
            if (x >= SCALE) {
                sign = 1;
            } else {
                sign = -1;
                assembly {
                    x := div(1000000000000000000000000000000000000, x)
                }
            }

            uint256 n = PRBMath.mostSignificantBit(uint256(x / SCALE));

            result = int256(n) * SCALE;

            int256 y = x >> n;

            if (y == SCALE) {
                return result * sign;
            }

            for (int256 delta = int256(HALF_SCALE); delta > 0; delta >>= 1) {
                y = (y * y) / SCALE;

                if (y >= 2 * SCALE) {
                    result += delta;

                    y >>= 1;
                }
            }
            result *= sign;
        }
    }

    function mul(int256 x, int256 y) internal pure returns (int256 result) {

        if (x == MIN_SD59x18 || y == MIN_SD59x18) {
            revert PRBMathSD59x18__MulInputTooSmall();
        }

        unchecked {
            uint256 ax;
            uint256 ay;
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);

            uint256 rAbs = PRBMath.mulDivFixedPoint(ax, ay);
            if (rAbs > uint256(MAX_SD59x18)) {
                revert PRBMathSD59x18__MulOverflow(rAbs);
            }

            uint256 sx;
            uint256 sy;
            assembly {
                sx := sgt(x, sub(0, 1))
                sy := sgt(y, sub(0, 1))
            }
            result = sx ^ sy == 1 ? -int256(rAbs) : int256(rAbs);
        }
    }

    function pi() internal pure returns (int256 result) {

        result = 3_141592653589793238;
    }

    function pow(int256 x, int256 y) internal pure returns (int256 result) {

        if (x == 0) {
            result = y == 0 ? SCALE : int256(0);
        } else {
            result = exp2(mul(log2(x), y));
        }
    }

    function powu(int256 x, uint256 y) internal pure returns (int256 result) {

        uint256 xAbs = uint256(abs(x));

        uint256 rAbs = y & 1 > 0 ? xAbs : uint256(SCALE);

        uint256 yAux = y;
        for (yAux >>= 1; yAux > 0; yAux >>= 1) {
            xAbs = PRBMath.mulDivFixedPoint(xAbs, xAbs);

            if (yAux & 1 > 0) {
                rAbs = PRBMath.mulDivFixedPoint(rAbs, xAbs);
            }
        }

        if (rAbs > uint256(MAX_SD59x18)) {
            revert PRBMathSD59x18__PowuOverflow(rAbs);
        }

        bool isNegative = x < 0 && y & 1 == 1;
        result = isNegative ? -int256(rAbs) : int256(rAbs);
    }

    function scale() internal pure returns (int256 result) {

        result = SCALE;
    }

    function sqrt(int256 x) internal pure returns (int256 result) {

        unchecked {
            if (x < 0) {
                revert PRBMathSD59x18__SqrtNegativeInput(x);
            }
            if (x > MAX_SD59x18 / SCALE) {
                revert PRBMathSD59x18__SqrtOverflow(x);
            }
            result = int256(PRBMath.sqrt(uint256(x * SCALE)));
        }
    }

    function toInt(int256 x) internal pure returns (int256 result) {

        unchecked {
            result = x / SCALE;
        }
    }
}// Unlicense
pragma solidity >=0.8.4;


library PRBMathUD60x18 {

    uint256 internal constant HALF_SCALE = 5e17;

    uint256 internal constant LOG2_E = 1_442695040888963407;

    uint256 internal constant MAX_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457_584007913129639935;

    uint256 internal constant MAX_WHOLE_UD60x18 =
        115792089237316195423570985008687907853269984665640564039457_000000000000000000;

    uint256 internal constant SCALE = 1e18;

    function avg(uint256 x, uint256 y) internal pure returns (uint256 result) {

        unchecked {
            result = (x >> 1) + (y >> 1) + (x & y & 1);
        }
    }

    function ceil(uint256 x) internal pure returns (uint256 result) {

        if (x > MAX_WHOLE_UD60x18) {
            revert PRBMathUD60x18__CeilOverflow(x);
        }
        assembly {
            let remainder := mod(x, SCALE)

            let delta := sub(SCALE, remainder)

            result := add(x, mul(delta, gt(remainder, 0)))
        }
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 result) {

        result = PRBMath.mulDiv(x, SCALE, y);
    }

    function e() internal pure returns (uint256 result) {

        result = 2_718281828459045235;
    }

    function exp(uint256 x) internal pure returns (uint256 result) {

        if (x >= 133_084258667509499441) {
            revert PRBMathUD60x18__ExpInputTooBig(x);
        }

        unchecked {
            uint256 doubleScaleProduct = x * LOG2_E;
            result = exp2((doubleScaleProduct + HALF_SCALE) / SCALE);
        }
    }

    function exp2(uint256 x) internal pure returns (uint256 result) {

        if (x >= 192e18) {
            revert PRBMathUD60x18__Exp2InputTooBig(x);
        }

        unchecked {
            uint256 x192x64 = (x << 64) / SCALE;

            result = PRBMath.exp2(x192x64);
        }
    }

    function floor(uint256 x) internal pure returns (uint256 result) {

        assembly {
            let remainder := mod(x, SCALE)

            result := sub(x, mul(remainder, gt(remainder, 0)))
        }
    }

    function frac(uint256 x) internal pure returns (uint256 result) {

        assembly {
            result := mod(x, SCALE)
        }
    }

    function fromUint(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            if (x > MAX_UD60x18 / SCALE) {
                revert PRBMathUD60x18__FromUintOverflow(x);
            }
            result = x * SCALE;
        }
    }

    function gm(uint256 x, uint256 y) internal pure returns (uint256 result) {

        if (x == 0) {
            return 0;
        }

        unchecked {
            uint256 xy = x * y;
            if (xy / x != y) {
                revert PRBMathUD60x18__GmOverflow(x, y);
            }

            result = PRBMath.sqrt(xy);
        }
    }

    function inv(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = 1e36 / x;
        }
    }

    function ln(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = (log2(x) * SCALE) / LOG2_E;
        }
    }

    function log10(uint256 x) internal pure returns (uint256 result) {

        if (x < SCALE) {
            revert PRBMathUD60x18__LogInputTooSmall(x);
        }

        assembly {
            switch x
            case 1 { result := mul(SCALE, sub(0, 18)) }
            case 10 { result := mul(SCALE, sub(1, 18)) }
            case 100 { result := mul(SCALE, sub(2, 18)) }
            case 1000 { result := mul(SCALE, sub(3, 18)) }
            case 10000 { result := mul(SCALE, sub(4, 18)) }
            case 100000 { result := mul(SCALE, sub(5, 18)) }
            case 1000000 { result := mul(SCALE, sub(6, 18)) }
            case 10000000 { result := mul(SCALE, sub(7, 18)) }
            case 100000000 { result := mul(SCALE, sub(8, 18)) }
            case 1000000000 { result := mul(SCALE, sub(9, 18)) }
            case 10000000000 { result := mul(SCALE, sub(10, 18)) }
            case 100000000000 { result := mul(SCALE, sub(11, 18)) }
            case 1000000000000 { result := mul(SCALE, sub(12, 18)) }
            case 10000000000000 { result := mul(SCALE, sub(13, 18)) }
            case 100000000000000 { result := mul(SCALE, sub(14, 18)) }
            case 1000000000000000 { result := mul(SCALE, sub(15, 18)) }
            case 10000000000000000 { result := mul(SCALE, sub(16, 18)) }
            case 100000000000000000 { result := mul(SCALE, sub(17, 18)) }
            case 1000000000000000000 { result := 0 }
            case 10000000000000000000 { result := SCALE }
            case 100000000000000000000 { result := mul(SCALE, 2) }
            case 1000000000000000000000 { result := mul(SCALE, 3) }
            case 10000000000000000000000 { result := mul(SCALE, 4) }
            case 100000000000000000000000 { result := mul(SCALE, 5) }
            case 1000000000000000000000000 { result := mul(SCALE, 6) }
            case 10000000000000000000000000 { result := mul(SCALE, 7) }
            case 100000000000000000000000000 { result := mul(SCALE, 8) }
            case 1000000000000000000000000000 { result := mul(SCALE, 9) }
            case 10000000000000000000000000000 { result := mul(SCALE, 10) }
            case 100000000000000000000000000000 { result := mul(SCALE, 11) }
            case 1000000000000000000000000000000 { result := mul(SCALE, 12) }
            case 10000000000000000000000000000000 { result := mul(SCALE, 13) }
            case 100000000000000000000000000000000 { result := mul(SCALE, 14) }
            case 1000000000000000000000000000000000 { result := mul(SCALE, 15) }
            case 10000000000000000000000000000000000 { result := mul(SCALE, 16) }
            case 100000000000000000000000000000000000 { result := mul(SCALE, 17) }
            case 1000000000000000000000000000000000000 { result := mul(SCALE, 18) }
            case 10000000000000000000000000000000000000 { result := mul(SCALE, 19) }
            case 100000000000000000000000000000000000000 { result := mul(SCALE, 20) }
            case 1000000000000000000000000000000000000000 { result := mul(SCALE, 21) }
            case 10000000000000000000000000000000000000000 { result := mul(SCALE, 22) }
            case 100000000000000000000000000000000000000000 { result := mul(SCALE, 23) }
            case 1000000000000000000000000000000000000000000 { result := mul(SCALE, 24) }
            case 10000000000000000000000000000000000000000000 { result := mul(SCALE, 25) }
            case 100000000000000000000000000000000000000000000 { result := mul(SCALE, 26) }
            case 1000000000000000000000000000000000000000000000 { result := mul(SCALE, 27) }
            case 10000000000000000000000000000000000000000000000 { result := mul(SCALE, 28) }
            case 100000000000000000000000000000000000000000000000 { result := mul(SCALE, 29) }
            case 1000000000000000000000000000000000000000000000000 { result := mul(SCALE, 30) }
            case 10000000000000000000000000000000000000000000000000 { result := mul(SCALE, 31) }
            case 100000000000000000000000000000000000000000000000000 { result := mul(SCALE, 32) }
            case 1000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 33) }
            case 10000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 34) }
            case 100000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 35) }
            case 1000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 36) }
            case 10000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 37) }
            case 100000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 38) }
            case 1000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 39) }
            case 10000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 40) }
            case 100000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 41) }
            case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 42) }
            case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 43) }
            case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 44) }
            case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 45) }
            case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 46) }
            case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 47) }
            case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 48) }
            case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 49) }
            case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 50) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 51) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 52) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 53) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 54) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 55) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 56) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 57) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 58) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 59) }
            default {
                result := MAX_UD60x18
            }
        }

        if (result == MAX_UD60x18) {
            unchecked {
                result = (log2(x) * SCALE) / 3_321928094887362347;
            }
        }
    }

    function log2(uint256 x) internal pure returns (uint256 result) {

        if (x < SCALE) {
            revert PRBMathUD60x18__LogInputTooSmall(x);
        }
        unchecked {
            uint256 n = PRBMath.mostSignificantBit(x / SCALE);

            result = n * SCALE;

            uint256 y = x >> n;

            if (y == SCALE) {
                return result;
            }

            for (uint256 delta = HALF_SCALE; delta > 0; delta >>= 1) {
                y = (y * y) / SCALE;

                if (y >= 2 * SCALE) {
                    result += delta;

                    y >>= 1;
                }
            }
        }
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 result) {

        result = PRBMath.mulDivFixedPoint(x, y);
    }

    function pi() internal pure returns (uint256 result) {

        result = 3_141592653589793238;
    }

    function pow(uint256 x, uint256 y) internal pure returns (uint256 result) {

        if (x == 0) {
            result = y == 0 ? SCALE : uint256(0);
        } else {
            result = exp2(mul(log2(x), y));
        }
    }

    function powu(uint256 x, uint256 y) internal pure returns (uint256 result) {

        result = y & 1 > 0 ? x : SCALE;

        for (y >>= 1; y > 0; y >>= 1) {
            x = PRBMath.mulDivFixedPoint(x, x);

            if (y & 1 > 0) {
                result = PRBMath.mulDivFixedPoint(result, x);
            }
        }
    }

    function scale() internal pure returns (uint256 result) {

        result = SCALE;
    }

    function sqrt(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            if (x > MAX_UD60x18 / SCALE) {
                revert PRBMathUD60x18__SqrtOverflow(x);
            }
            result = PRBMath.sqrt(x * SCALE);
        }
    }

    function toUint(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = x / SCALE;
        }
    }
}// Apache-2.0

pragma solidity =0.8.9;

library Time {

    uint256 public constant SECONDS_IN_DAY_WAD = 86400e18;

    function blockTimestampScaled() internal view returns (uint256) {

        return PRBMathUD60x18.fromUint(block.timestamp);
    }

    function blockTimestampTruncated() internal view returns (uint32) {

        return timestampAsUint32(block.timestamp);
    }

    function timestampAsUint32(uint256 _timestamp)
        internal
        pure
        returns (uint32 timestamp)
    {

        require((timestamp = uint32(_timestamp)) == _timestamp, "TSOFLOW");
    }

    function isCloseToMaturityOrBeyondMaturity(uint256 termEndTimestampWad)
        internal
        view
        returns (bool vammInactive)
    {

        return
            Time.blockTimestampScaled() + SECONDS_IN_DAY_WAD >=
            termEndTimestampWad;
    }
}// Apache-2.0

pragma solidity =0.8.9;

library FixedAndVariableMath {

    using PRBMathSD59x18 for int256;
    using PRBMathUD60x18 for uint256;


    uint256 public constant SECONDS_IN_YEAR_IN_WAD = 31536000e18;
    uint256 public constant ONE_HUNDRED_IN_WAD = 100e18;

    function calculateSettlementCashflow(
        int256 fixedTokenBalance,
        int256 variableTokenBalance,
        uint256 termStartTimestampWad,
        uint256 termEndTimestampWad,
        uint256 variableFactorToMaturityWad
    ) internal view returns (int256 cashflow) {


        int256 fixedTokenBalanceWad = fixedTokenBalance.fromInt();
        int256 variableTokenBalanceWad = variableTokenBalance.fromInt();
        int256 fixedCashflowWad = fixedTokenBalanceWad.mul(
            int256(
                fixedFactor(true, termStartTimestampWad, termEndTimestampWad)
            )
        );

        int256 variableCashflowWad = variableTokenBalanceWad.mul(
            int256(variableFactorToMaturityWad)
        );

        int256 cashflowWad = fixedCashflowWad + variableCashflowWad;

        cashflow = cashflowWad.toInt();
    }

    function accrualFact(uint256 timeInSecondsAsWad)
        internal
        pure
        returns (uint256 timeInYearsWad)
    {

        timeInYearsWad = timeInSecondsAsWad.div(SECONDS_IN_YEAR_IN_WAD);
    }

    function fixedFactor(
        bool atMaturity,
        uint256 termStartTimestampWad,
        uint256 termEndTimestampWad
    ) internal view returns (uint256 fixedFactorValueWad) {

        require(termEndTimestampWad > termStartTimestampWad, "E<=S");

        uint256 currentTimestampWad = Time.blockTimestampScaled();

        require(currentTimestampWad >= termStartTimestampWad, "B.T<S");

        uint256 timeInSecondsWad;

        if (atMaturity || (currentTimestampWad >= termEndTimestampWad)) {
            timeInSecondsWad = termEndTimestampWad - termStartTimestampWad;
        } else {
            timeInSecondsWad = currentTimestampWad - termStartTimestampWad;
        }

        fixedFactorValueWad = accrualFact(timeInSecondsWad).div(
            ONE_HUNDRED_IN_WAD
        );
    }

    function calculateFixedTokenBalance(
        int256 amountFixedWad,
        int256 excessBalanceWad,
        uint256 termStartTimestampWad,
        uint256 termEndTimestampWad
    ) internal view returns (int256 fixedTokenBalanceWad) {

        require(termEndTimestampWad > termStartTimestampWad, "E<=S");

        return
            amountFixedWad -
            excessBalanceWad.div(
                int256(
                    fixedFactor(
                        true,
                        termStartTimestampWad,
                        termEndTimestampWad
                    )
                )
            );
    }

    function getExcessBalance(
        int256 amountFixedWad,
        int256 amountVariableWad,
        uint256 accruedVariableFactorWad,
        uint256 termStartTimestampWad,
        uint256 termEndTimestampWad
    ) internal view returns (int256) {


        return
            amountFixedWad.mul(
                int256(
                    fixedFactor(
                        false,
                        termStartTimestampWad,
                        termEndTimestampWad
                    )
                )
            ) + amountVariableWad.mul(int256(accruedVariableFactorWad));
    }

    function getFixedTokenBalance(
        int256 amountFixed,
        int256 amountVariable,
        uint256 accruedVariableFactorWad,
        uint256 termStartTimestampWad,
        uint256 termEndTimestampWad
    ) internal view returns (int256 fixedTokenBalance) {

        require(termEndTimestampWad > termStartTimestampWad, "E<=S");

        if (amountFixed == 0 && amountVariable == 0) return 0;

        int256 amountFixedWad = amountFixed.fromInt();
        int256 amountVariableWad = amountVariable.fromInt();

        int256 excessBalanceWad = getExcessBalance(
            amountFixedWad,
            amountVariableWad,
            accruedVariableFactorWad,
            termStartTimestampWad,
            termEndTimestampWad
        );

        int256 fixedTokenBalanceWad = calculateFixedTokenBalance(
            amountFixedWad,
            excessBalanceWad,
            termStartTimestampWad,
            termEndTimestampWad
        );

        fixedTokenBalance = fixedTokenBalanceWad.toInt();
    }
}// BUSL-1.1

pragma solidity =0.8.9;

library LiquidityMath {

    function addDelta(uint128 x, int128 y) internal pure returns (uint128 z) {

        if (y < 0) {
            uint128 yAbsolute;

            unchecked {
                yAbsolute = uint128(-y);
            }

            z = x - yAbsolute;
        } else {
            z = x + uint128(y);
        }
    }
}// BUSL-1.1

pragma solidity =0.8.9;

library FixedPoint128 {

    uint256 internal constant Q128 = 0x100000000000000000000000000000000;
}// BUSL-1.1


pragma solidity =0.8.9;

library TickMath {


    int24 internal constant MIN_TICK = -69100;
    int24 internal constant MAX_TICK = -MIN_TICK;

    uint160 internal constant MIN_SQRT_RATIO = 2503036416286949174936592462;
    uint160 internal constant MAX_SQRT_RATIO = 2507794810551837817144115957740;

    function getSqrtRatioAtTick(int24 tick)
        internal
        pure
        returns (uint160 sqrtPriceX96)
    {

        uint256 absTick = tick < 0
            ? uint256(-int256(tick))
            : uint256(int256(tick));
        require(absTick <= uint256(int256(MAX_TICK)), "T");

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
        if (tick > 0) ratio = type(uint256).max / ratio;

        sqrtPriceX96 = uint160(
            (ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1)
        );
    }

    function getTickAtSqrtRatio(uint160 sqrtPriceX96)
        internal
        pure
        returns (int24 tick)
    {

        require(
            sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO,
            "R"
        );
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
}// BUSL-1.1

pragma solidity =0.8.9;

library SafeCastUni {

    function toUint160(uint256 y) internal pure returns (uint160 z) {

        require((z = uint160(y)) == y, "toUint160 oflo");
    }

    function toInt128(int256 y) internal pure returns (int128 z) {

        require((z = int128(y)) == y, "toInt128 oflo");
    }

    function toInt256(uint256 y) internal pure returns (int256 z) {

        require(y < 2**255, "toInt256 oflo");
        z = int256(y);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "toUint256 < 0");
        return uint256(value);
    }
}// MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {

	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {

		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {

		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}// UNLICENSED

pragma solidity =0.8.9;


library Printer {

    bool public constant PRINT = true;

    function printInt256(string memory reason, int256 number) internal view {

        if (!PRINT) return;

        if (number < 0) {
            console.log(reason, ": (-", uint256(-number), ") [FROM CONTRACT] ");
        } else {
            console.log(reason, ":", uint256(number), " [FROM CONTRACT] ");
        }
    }

    function printInt128(string memory reason, int128 number) internal view {

        if (!PRINT) return;

        if (number < 0) {
            console.log(reason, ": (-", uint128(-number), ") [FROM CONTRACT] ");
        } else {
            console.log(reason, ":", uint128(number), " [FROM CONTRACT] ");
        }
    }

    function printInt24(string memory reason, int24 number) internal view {

        if (!PRINT) return;

        if (number < 0) {
            console.log(reason, ": (-", uint24(-number), ") [FROM CONTRACT] ");
        } else {
            console.log(reason, ":", uint24(number), " [FROM CONTRACT] ");
        }
    }

    function printUint24(string memory reason, uint24 number) internal view {

        if (!PRINT) return;
        console.log(reason, ":", number, " [FROM CONTRACT] ");
    }

    function printUint32(string memory reason, uint32 number) internal view {

        if (!PRINT) return;
        console.log(reason, ":", number, " [FROM CONTRACT] ");
    }

    function printUint256(string memory reason, uint256 number) internal view {

        if (!PRINT) return;
        console.log(reason, ":", number, " [FROM CONTRACT] ");
    }

    function printUint128(string memory reason, uint128 number) internal view {

        if (!PRINT) return;
        console.log(reason, ":", number, " [FROM CONTRACT] ");
    }

    function printUint160(string memory reason, uint160 number) internal view {

        if (!PRINT) return;
        console.log(reason, ":", number, " [FROM CONTRACT] ");
    }

    function printAddress(string memory reason, address _address)
        internal
        view
    {

        if (!PRINT) return;
        console.log(reason, ":", _address, " [FROM CONTRACT] ");
    }

    function printBool(string memory reason, bool number) internal view {

        if (!PRINT) return;
        console.log(reason, number, " [FROM CONTRACT] ");
    }

    function printEmptyLine() internal view {

        if (!PRINT) return;
        console.log("");
    }
}// BUSL-1.1

pragma solidity =0.8.9;

library Tick {

    using SafeCastUni for int256;
    using SafeCastUni for uint256;

    int24 public constant MAXIMUM_TICK_SPACING = 16384;

    struct Info {
        uint128 liquidityGross;
        int128 liquidityNet;
        int256 fixedTokenGrowthOutsideX128;
        int256 variableTokenGrowthOutsideX128;
        uint256 feeGrowthOutsideX128;
        bool initialized;
    }

    function tickSpacingToMaxLiquidityPerTick(int24 tickSpacing)
        internal
        pure
        returns (uint128)
    {

        int24 minTick = TickMath.MIN_TICK - (TickMath.MIN_TICK % tickSpacing);
        int24 maxTick = -minTick;
        uint24 numTicks = uint24((maxTick - minTick) / tickSpacing) + 1;
        return type(uint128).max / numTicks;
    }

    function checkTicks(int24 tickLower, int24 tickUpper) internal pure {

        require(tickLower < tickUpper, "TLU");
        require(tickLower >= TickMath.MIN_TICK, "TLM");
        require(tickUpper <= TickMath.MAX_TICK, "TUM");
    }

    struct FeeGrowthInsideParams {
        int24 tickLower;
        int24 tickUpper;
        int24 tickCurrent;
        uint256 feeGrowthGlobalX128;
    }

    function _getGrowthInside(
        int24 _tickLower,
        int24 _tickUpper,
        int24 _tickCurrent,
        int256 _growthGlobalX128,
        int256 _lowerGrowthOutsideX128,
        int256 _upperGrowthOutsideX128
    ) private pure returns (int256) {

        int256 _growthBelowX128;

        if (_tickCurrent >= _tickLower) {
            _growthBelowX128 = _lowerGrowthOutsideX128;
        } else {
            _growthBelowX128 = _growthGlobalX128 - _lowerGrowthOutsideX128;
        }

        int256 _growthAboveX128;

        if (_tickCurrent < _tickUpper) {
            _growthAboveX128 = _upperGrowthOutsideX128;
        } else {
            _growthAboveX128 = _growthGlobalX128 - _upperGrowthOutsideX128;
        }

        int256 _growthInsideX128;

        _growthInsideX128 =
            _growthGlobalX128 -
            (_growthBelowX128 + _growthAboveX128);

        return _growthInsideX128;
    }

    function getFeeGrowthInside(
        mapping(int24 => Tick.Info) storage self,
        FeeGrowthInsideParams memory params
    ) internal view returns (uint256 feeGrowthInsideX128) {

        unchecked {
            Info storage lower = self[params.tickLower];
            Info storage upper = self[params.tickUpper];

            feeGrowthInsideX128 = uint256(
                _getGrowthInside(
                    params.tickLower,
                    params.tickUpper,
                    params.tickCurrent,
                    params.feeGrowthGlobalX128.toInt256(),
                    lower.feeGrowthOutsideX128.toInt256(),
                    upper.feeGrowthOutsideX128.toInt256()
                )
            );
        }
    }

    struct VariableTokenGrowthInsideParams {
        int24 tickLower;
        int24 tickUpper;
        int24 tickCurrent;
        int256 variableTokenGrowthGlobalX128;
    }

    function getVariableTokenGrowthInside(
        mapping(int24 => Tick.Info) storage self,
        VariableTokenGrowthInsideParams memory params
    ) internal view returns (int256 variableTokenGrowthInsideX128) {

        Info storage lower = self[params.tickLower];
        Info storage upper = self[params.tickUpper];

        variableTokenGrowthInsideX128 = _getGrowthInside(
            params.tickLower,
            params.tickUpper,
            params.tickCurrent,
            params.variableTokenGrowthGlobalX128,
            lower.variableTokenGrowthOutsideX128,
            upper.variableTokenGrowthOutsideX128
        );
    }

    struct FixedTokenGrowthInsideParams {
        int24 tickLower;
        int24 tickUpper;
        int24 tickCurrent;
        int256 fixedTokenGrowthGlobalX128;
    }

    function getFixedTokenGrowthInside(
        mapping(int24 => Tick.Info) storage self,
        FixedTokenGrowthInsideParams memory params
    ) internal view returns (int256 fixedTokenGrowthInsideX128) {

        Info storage lower = self[params.tickLower];
        Info storage upper = self[params.tickUpper];

        fixedTokenGrowthInsideX128 = _getGrowthInside(
            params.tickLower,
            params.tickUpper,
            params.tickCurrent,
            params.fixedTokenGrowthGlobalX128,
            lower.fixedTokenGrowthOutsideX128,
            upper.fixedTokenGrowthOutsideX128
        );
    }

    function update(
        mapping(int24 => Tick.Info) storage self,
        int24 tick,
        int24 tickCurrent,
        int128 liquidityDelta,
        int256 fixedTokenGrowthGlobalX128,
        int256 variableTokenGrowthGlobalX128,
        uint256 feeGrowthGlobalX128,
        bool upper,
        uint128 maxLiquidity
    ) internal returns (bool flipped) {

        Tick.Info storage info = self[tick];

        uint128 liquidityGrossBefore = info.liquidityGross;
        require(
            int128(info.liquidityGross) + liquidityDelta >= 0,
            "not enough liquidity to burn"
        );
        uint128 liquidityGrossAfter = LiquidityMath.addDelta(
            liquidityGrossBefore,
            liquidityDelta
        );

        require(liquidityGrossAfter <= maxLiquidity, "LO");

        flipped = (liquidityGrossAfter == 0) != (liquidityGrossBefore == 0);

        if (liquidityGrossBefore == 0) {
            if (tick <= tickCurrent) {
                info.feeGrowthOutsideX128 = feeGrowthGlobalX128;

                info.fixedTokenGrowthOutsideX128 = fixedTokenGrowthGlobalX128;

                info
                    .variableTokenGrowthOutsideX128 = variableTokenGrowthGlobalX128;
            }

            info.initialized = true;
        }


        info.liquidityGross = liquidityGrossAfter;

        info.liquidityNet = upper
            ? info.liquidityNet - liquidityDelta
            : info.liquidityNet + liquidityDelta;
    }

    function clear(mapping(int24 => Tick.Info) storage self, int24 tick)
        internal
    {

        delete self[tick];
    }

    function cross(
        mapping(int24 => Tick.Info) storage self,
        int24 tick,
        int256 fixedTokenGrowthGlobalX128,
        int256 variableTokenGrowthGlobalX128,
        uint256 feeGrowthGlobalX128
    ) internal returns (int128 liquidityNet) {

        Tick.Info storage info = self[tick];

        info.feeGrowthOutsideX128 =
            feeGrowthGlobalX128 -
            info.feeGrowthOutsideX128;

        info.fixedTokenGrowthOutsideX128 =
            fixedTokenGrowthGlobalX128 -
            info.fixedTokenGrowthOutsideX128;

        info.variableTokenGrowthOutsideX128 =
            variableTokenGrowthGlobalX128 -
            info.variableTokenGrowthOutsideX128;

        liquidityNet = info.liquidityNet;
    }
}// MIT


pragma solidity =0.8.9;

library FullMath {


    function mulDivSigned(
        int256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (int256 result) {

        if (a < 0) return -int256(mulDiv(uint256(-a), b, denominator));
        return int256(mulDiv(uint256(a), b, denominator));
    }

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product

        unchecked {
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            if (prod1 == 0) {
                require(denominator > 0, "Division by zero");
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            require(denominator > prod1, "overflow");


            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            uint256 twos = (type(uint256).max - denominator + 1) & denominator;
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

        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max, "overflow");
            result++;
        }
    }
}// BUSL-1.1

pragma solidity =0.8.9;


library Position {

    using Position for Info;

    struct Info {
        bool isSettled;
        uint128 _liquidity;
        int256 margin;
        int256 fixedTokenGrowthInsideLastX128;
        int256 variableTokenGrowthInsideLastX128;
        int256 fixedTokenBalance;
        int256 variableTokenBalance;
        uint256 feeGrowthInsideLastX128;
        uint256 rewardPerAmount;
        uint256 accumulatedFees;
    }

    function get(
        mapping(bytes32 => Info) storage self,
        address owner,
        int24 tickLower,
        int24 tickUpper
    ) internal view returns (Position.Info storage position) {

        Tick.checkTicks(tickLower, tickUpper);

        position = self[
            keccak256(abi.encodePacked(owner, tickLower, tickUpper))
        ];
    }

    function settlePosition(Info storage self) internal {

        require(!self.isSettled, "already settled");
        self.isSettled = true;
    }

    function updateMarginViaDelta(Info storage self, int256 marginDelta)
        internal
    {

        self.margin += marginDelta;
    }

    function updateBalancesViaDeltas(
        Info storage self,
        int256 fixedTokenBalanceDelta,
        int256 variableTokenBalanceDelta
    ) internal {

        if (fixedTokenBalanceDelta | variableTokenBalanceDelta != 0) {
            self.fixedTokenBalance += fixedTokenBalanceDelta;
            self.variableTokenBalance += variableTokenBalanceDelta;
        }
    }

    function calculateFeeDelta(Info storage self, uint256 feeGrowthInsideX128)
        internal
        pure
        returns (uint256 _feeDelta)
    {

        Info memory _self = self;

        unchecked {
            _feeDelta = FullMath.mulDiv(
                feeGrowthInsideX128 - _self.feeGrowthInsideLastX128,
                _self._liquidity,
                FixedPoint128.Q128
            );
        }
    }

    function calculateFixedAndVariableDelta(
        Info storage self,
        int256 fixedTokenGrowthInsideX128,
        int256 variableTokenGrowthInsideX128
    )
        internal
        pure
        returns (int256 _fixedTokenDelta, int256 _variableTokenDelta)
    {

        Info memory _self = self;

        int256 fixedTokenGrowthInsideDeltaX128 = fixedTokenGrowthInsideX128 -
            _self.fixedTokenGrowthInsideLastX128;

        _fixedTokenDelta = FullMath.mulDivSigned(
            fixedTokenGrowthInsideDeltaX128,
            _self._liquidity,
            FixedPoint128.Q128
        );

        int256 variableTokenGrowthInsideDeltaX128 = variableTokenGrowthInsideX128 -
                _self.variableTokenGrowthInsideLastX128;

        _variableTokenDelta = FullMath.mulDivSigned(
            variableTokenGrowthInsideDeltaX128,
            _self._liquidity,
            FixedPoint128.Q128
        );
    }

    function updateFixedAndVariableTokenGrowthInside(
        Info storage self,
        int256 fixedTokenGrowthInsideX128,
        int256 variableTokenGrowthInsideX128
    ) internal {

        self.fixedTokenGrowthInsideLastX128 = fixedTokenGrowthInsideX128;
        self.variableTokenGrowthInsideLastX128 = variableTokenGrowthInsideX128;
    }

    function updateFeeGrowthInside(
        Info storage self,
        uint256 feeGrowthInsideX128
    ) internal {

        self.feeGrowthInsideLastX128 = feeGrowthInsideX128;
    }

    function updateLiquidity(Info storage self, int128 liquidityDelta)
        internal
    {

        Info memory _self = self;

        if (liquidityDelta == 0) {
            require(_self._liquidity > 0, "NP"); // disallow pokes for 0 liquidity positions
        } else {
            self._liquidity = LiquidityMath.addDelta(
                _self._liquidity,
                liquidityDelta
            );
        }
    }
}// Apache-2.0

pragma solidity =0.8.9;

library TraderWithYieldBearingAssets {

    struct Info {
        uint256 marginInScaledYieldBearingTokens;
        int256 fixedTokenBalance;
        int256 variableTokenBalance;
        bool isSettled;
    }

    function updateMarginInScaledYieldBearingTokens(
        Info storage self,
        uint256 _marginInScaledYieldBearingTokens
    ) internal {

        self
            .marginInScaledYieldBearingTokens = _marginInScaledYieldBearingTokens;
    }

    function settleTrader(Info storage self) internal {

        require(!self.isSettled, "already settled");
        self.isSettled = true;
    }

    function updateBalancesViaDeltas(
        Info storage self,
        int256 fixedTokenBalanceDelta,
        int256 variableTokenBalanceDelta
    )
        internal
        returns (int256 _fixedTokenBalance, int256 _variableTokenBalance)
    {

        _fixedTokenBalance = self.fixedTokenBalance + fixedTokenBalanceDelta;
        _variableTokenBalance =
            self.variableTokenBalance +
            variableTokenBalanceDelta;

        self.fixedTokenBalance = _fixedTokenBalance;
        self.variableTokenBalance = _variableTokenBalance;
    }
}// BUSL-1.1

pragma solidity =0.8.9;

interface IERC20Minimal {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}// Apache-2.0

pragma solidity =0.8.9;

interface CustomErrors {

    error PositionNetZero();

    error DebugError(uint256 x, uint256 y);

    error MarginLessThanMinimum(int256 marginRequirement);

    error WithdrawalExceedsCurrentMargin();

    error PositionNotSettled();

    error MarginRequirementNotMet(
        int256 marginRequirement,
        int24 tick,
        int256 fixedTokenDelta,
        int256 variableTokenDelta,
        uint256 cumulativeFeeIncurred,
        int256 fixedTokenDeltaUnbalanced
    );

    error CannotLiquidate();

    error OnlyOwnerCanUpdatePosition();

    error OnlyVAMM();

    error OnlyFCM();

    error InvalidMarginDelta();

    error CannotSettleBeforeMaturity();

    error closeToOrBeyondMaturity();

    error NotEnoughFunds(uint256 requested, uint256 available);

    error ExpectedOppositeSigns(int256 amount0, int256 amount1);

    error ExpectedSqrtPriceZeroBeforeInit(uint160 sqrtPriceX96);

    error LiquidityDeltaMustBePositiveInMint(uint128 amount);

    error LiquidityDeltaMustBePositiveInBurn(uint128 amount);

    error IRSNotionalAmountSpecifiedMustBeNonZero();

    error CanOnlyTradeIfUnlocked(bool unlocked);

    error OnlyMarginEngine();

    error MarginRequirementNotMetFCM(int256 marginRequirement);

    error AavePoolGetReserveNormalizedIncomeReturnedZero();

    error CTokenExchangeRateReturnedZero();

    error OOO();
}// Apache-2.0


pragma solidity =0.8.9;


interface IRateOracle is CustomErrors {


    event MinSecondsSinceLastUpdate(uint256 _minSecondsSinceLastUpdate);
    event OracleBufferUpdate(
        uint256 blockTimestampScaled,
        address source,
        uint16 index,
        uint32 blockTimestamp,
        uint256 observedValue,
        uint16 cardinality,
        uint16 cardinalityNext
    );

    event RateCardinalityNext(
        uint16 observationCardinalityNextNew
    );


    function minSecondsSinceLastUpdate() external view returns (uint256);


    function underlying() external view returns (IERC20Minimal);


    function variableFactor(uint256 termStartTimestamp, uint256 termEndTimestamp) external returns(uint256 result);


    function variableFactorNoCache(uint256 termStartTimestamp, uint256 termEndTimestamp) external view returns(uint256 result);


    
    function getRateFromTo(uint256 from, uint256 to)
        external
        view
        returns (uint256);


    function getApyFromTo(uint256 from, uint256 to)
        external
        view
        returns (uint256 apyFromTo);



    function setMinSecondsSinceLastUpdate(uint256 _minSecondsSinceLastUpdate) external;


    function increaseObservationCardinalityNext(uint16 rateCardinalityNext) external;


    function writeOracleEntry() external;


    function UNDERLYING_YIELD_BEARING_PROTOCOL_ID() external view returns(uint8 yieldBearingProtocolID);

}// BUSL-1.1

pragma solidity =0.8.9;

interface IPositionStructs {

    struct ModifyPositionParams {
        address owner;
        int24 tickLower;
        int24 tickUpper;
        int128 liquidityDelta;
    }
}// BUSL-1.1

pragma solidity =0.8.9;

interface IVAMM is IPositionStructs, CustomErrors {

    function setPausability(bool state) external;


    event Swap(
        address sender,
        address indexed recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        int256 desiredNotional,
        uint160 sqrtPriceLimitX96,
        uint256 cumulativeFeeIncurred,
        int256 fixedTokenDelta,
        int256 variableTokenDelta,
        int256 fixedTokenDeltaUnbalanced
    );

    event VAMMInitialization(uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount
    );

    event Burn(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount
    );

    event FeeProtocol(uint8 feeProtocol);

    event Fee(uint256 feeWad);

    event IsAlpha(bool __isAlpha);

    event VAMMPriceChange(int24 tick);


    struct VAMMVars {
        uint160 sqrtPriceX96;
        int24 tick;
        uint8 feeProtocol;
    }

    struct SwapParams {
        address recipient;
        int256 amountSpecified;
        uint160 sqrtPriceLimitX96;
        int24 tickLower;
        int24 tickUpper;
    }

    struct SwapCache {
        uint128 liquidityStart;
        uint8 feeProtocol;
    }

    struct SwapState {
        int256 amountSpecifiedRemaining;
        int256 amountCalculated;
        uint160 sqrtPriceX96;
        int24 tick;
        int256 fixedTokenGrowthGlobalX128;
        int256 variableTokenGrowthGlobalX128;
        uint128 liquidity;
        uint256 feeGrowthGlobalX128;
        uint256 protocolFee;
        uint256 cumulativeFeeIncurred;
        int256 fixedTokenDeltaCumulative;
        int256 variableTokenDeltaCumulative;
        int256 fixedTokenDeltaUnbalancedCumulative;
    }

    struct StepComputations {
        uint160 sqrtPriceStartX96;
        int24 tickNext;
        bool initialized;
        uint160 sqrtPriceNextX96;
        uint256 amountIn;
        uint256 amountOut;
        uint256 feeAmount;
        uint256 feeProtocolDelta;
        int256 fixedTokenDeltaUnbalanced; // for LP
        int256 fixedTokenDelta; // for LP
        int256 variableTokenDelta; // for LP
    }

    function initialize(IMarginEngine __marginEngine, int24 __tickSpacing)
        external;



    function feeWad() external view returns (uint256);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);



    function vammVars() external view returns (VAMMVars memory);


    function isAlpha() external view returns (bool);


    function fixedTokenGrowthGlobalX128() external view returns (int256);


    function variableTokenGrowthGlobalX128() external view returns (int256);


    function feeGrowthGlobalX128() external view returns (uint256);


    function liquidity() external view returns (uint128);


    function protocolFees() external view returns (uint256);


    function marginEngine() external view returns (IMarginEngine);


    function factory() external view returns (IFactory);


    function setFeeProtocol(uint8 feeProtocol) external;


    function setIsAlpha(bool __isAlpha) external;


    function setFee(uint256 _fee) external;


    function updateProtocolFees(uint256 protocolFeesCollected) external;


    function initializeVAMM(uint160 sqrtPriceX96) external;


    function burn(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (int256 positionMarginRequirement);


    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (int256 positionMarginRequirement);


    function swap(SwapParams memory params)
        external
        returns (
            int256 fixedTokenDelta,
            int256 variableTokenDelta,
            uint256 cumulativeFeeIncurred,
            int256 fixedTokenDeltaUnbalanced,
            int256 marginRequirement
        );


    function ticks(int24 tick) external view returns (Tick.Info memory);


    function tickBitmap(int16 wordPosition) external view returns (uint256);


    function computeGrowthInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int256 fixedTokenGrowthInsideX128,
            int256 variableTokenGrowthInsideX128,
            uint256 feeGrowthInsideX128
        );

}// Apache-2.0

pragma solidity =0.8.9;


interface IFCM is CustomErrors {

    function setPausability(bool state) external;


    function getTraderWithYieldBearingAssets(address trader)
        external
        view
        returns (TraderWithYieldBearingAssets.Info memory traderInfo);


    function initiateFullyCollateralisedFixedTakerSwap(
        uint256 notional,
        uint160 sqrtPriceLimitX96
    ) external returns (int256 fixedTokenDelta, int256 variableTokenDelta, uint256 cumulativeFeeIncurred, int256 fixedTokenDeltaUnbalanced);


    function unwindFullyCollateralisedFixedTakerSwap(
        uint256 notionalToUnwind,
        uint160 sqrtPriceLimitX96
    ) external returns (int256 fixedTokenDelta, int256 variableTokenDelta, uint256 cumulativeFeeIncurred, int256 fixedTokenDeltaUnbalanced);


    function settleTrader() external returns (int256);


    function transferMarginToMarginEngineTrader(
        address account,
        uint256 marginDeltaInUnderlyingTokens
    ) external;


    function initialize(IVAMM __vamm, IMarginEngine __marginEngine)
        external;


    function marginEngine() external view returns (IMarginEngine);


    function vamm() external view returns (IVAMM);


    function rateOracle() external view returns (IRateOracle);


    event FullyCollateralisedSwap(
        address indexed trader,
        uint256 desiredNotional,
        uint160 sqrtPriceLimitX96,
        uint256 cumulativeFeeIncurred,
        int256 fixedTokenDelta,
        int256 variableTokenDelta,
        int256 fixedTokenDeltaUnbalanced
    );

    event FullyCollateralisedUnwind(
        address indexed trader,
        uint256 desiredNotional,
        uint160 sqrtPriceLimitX96,
        uint256 cumulativeFeeIncurred,
        int256 fixedTokenDelta,
        int256 variableTokenDelta,
        int256 fixedTokenDeltaUnbalanced
    );

    event fcmPositionSettlement(
        address indexed trader,
        int256 settlementCashflow
    );

    event FCMTraderUpdate(
        address indexed trader,
        uint256 marginInScaledYieldBearingTokens,
        int256 fixedTokenBalance,
        int256 variableTokenBalance
    );
}// Apache-2.0

pragma solidity =0.8.9;

interface IMarginEngine is IPositionStructs, CustomErrors {


    function setPausability(bool state) external;


    struct MarginCalculatorParameters {
        uint256 apyUpperMultiplierWad;
        uint256 apyLowerMultiplierWad;
        int256 sigmaSquaredWad;
        int256 alphaWad;
        int256 betaWad;
        int256 xiUpperWad;
        int256 xiLowerWad;
        int256 tMaxWad;
        uint256 devMulLeftUnwindLMWad;
        uint256 devMulRightUnwindLMWad;
        uint256 devMulLeftUnwindIMWad;
        uint256 devMulRightUnwindIMWad;
        uint256 fixedRateDeviationMinLeftUnwindLMWad;
        uint256 fixedRateDeviationMinRightUnwindLMWad;
        uint256 fixedRateDeviationMinLeftUnwindIMWad;
        uint256 fixedRateDeviationMinRightUnwindIMWad;
        uint256 gammaWad;
        uint256 minMarginToIncentiviseLiquidators;
    }

    event HistoricalApyWindowSetting(uint256 secondsAgo);
    event CacheMaxAgeSetting(uint256 cacheMaxAgeInSeconds);
    event RateOracle(uint256 cacheMaxAgeInSeconds);

    event ProtocolCollection(
        address sender,
        address indexed recipient,
        uint256 amount
    );
    event LiquidatorRewardSetting(uint256 liquidatorRewardWad);

    event VAMMSetting(IVAMM indexed vamm);

    event RateOracleSetting(IRateOracle indexed rateOracle);

    event FCMSetting(IFCM indexed fcm);

    event MarginCalculatorParametersSetting(
        MarginCalculatorParameters marginCalculatorParameters
    );

    event PositionMarginUpdate(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        int256 marginDelta
    );

    event HistoricalApy(uint256 value);

    event PositionSettlement(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        int256 settlementCashflow
    );

    event PositionLiquidation(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        address liquidator,
        int256 notionalUnwound,
        uint256 liquidatorReward
    );

    event PositionUpdate(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 _liquidity,
        int256 margin,
        int256 fixedTokenBalance,
        int256 variableTokenBalance,
        uint256 accumulatedFees
    );

    event IsAlpha(bool __isAlpha);


    function fcm() external view returns (IFCM);


    function factory() external view returns (IFactory);


    function underlyingToken() external view returns (IERC20Minimal);


    function rateOracle() external view returns (IRateOracle);


    function termStartTimestampWad() external view returns (uint256);


    function termEndTimestampWad() external view returns (uint256);


    function initialize(
        IERC20Minimal __underlyingToken,
        IRateOracle __rateOracle,
        uint256 __termStartTimestampWad,
        uint256 __termEndTimestampWad
    ) external;



    function liquidatorRewardWad() external view returns (uint256);


    function vamm() external view returns (IVAMM);


    function isAlpha() external view returns (bool);


    function getPosition(
        address _owner,
        int24 _tickLower,
        int24 _tickUpper
    ) external returns (Position.Info memory position);


    function lookbackWindowInSeconds() external view returns (uint256);



    function setLookbackWindowInSeconds(uint256 _secondsAgo) external;


    function setMarginCalculatorParameters(
        MarginCalculatorParameters memory _marginCalculatorParameters
    ) external;


    function setLiquidatorReward(uint256 _liquidatorRewardWad) external;


    function setIsAlpha(bool __isAlpha) external;


    function updatePositionMargin(
        address _owner,
        int24 _tickLower,
        int24 _tickUpper,
        int256 marginDelta
    ) external;


    function settlePosition(
        address _owner,
        int24 _tickLower,
        int24 _tickUpper
    ) external;


    function liquidatePosition(
        address _owner,
        int24 _tickLower,
        int24 _tickUpper
    ) external returns (uint256);


    function updatePositionPostVAMMInducedMintBurn(
        IPositionStructs.ModifyPositionParams memory _params
    ) external returns (int256 _positionMarginRequirement);


    function updatePositionPostVAMMInducedSwap(
        address _owner,
        int24 _tickLower,
        int24 _tickUpper,
        int256 _fixedTokenDelta,
        int256 _variableTokenDelta,
        uint256 _cumulativeFeeIncurred,
        int256 _fixedTokenDeltaUnbalanced
    ) external returns (int256 _positionMarginRequirement);


    function collectProtocol(address _recipient, uint256 _amount) external;


    function setVAMM(IVAMM _vAMM) external;


    function setRateOracle(IRateOracle __rateOracle) external;


    function setFCM(IFCM _newFCM) external;


    function transferMarginToFCMTrader(address _account, uint256 _marginDelta)
        external;


    function cacheMaxAgeInSeconds() external view returns (uint256);


    function setCacheMaxAgeInSeconds(uint256 _cacheMaxAgeInSeconds) external;


    function getHistoricalApy() external returns (uint256);


    function getHistoricalApyReadOnly() external view returns (uint256);


    function getPositionMarginRequirement(
        address _recipient,
        int24 _tickLower,
        int24 _tickUpper,
        bool _isLM
    ) external returns (uint256);

}// Apache-2.0

pragma solidity =0.8.9;


interface IPeriphery is CustomErrors {


    event MarginCap(IVAMM _vamm, int256 _lpMarginCapNew);


    struct MintOrBurnParams {
        IMarginEngine marginEngine;
        int24 tickLower;
        int24 tickUpper;
        uint256 notional;
        bool isMint;
        int256 marginDelta;
    }

    struct SwapPeripheryParams {
        IMarginEngine marginEngine;
        bool isFT;
        uint256 notional;
        uint160 sqrtPriceLimitX96;
        int24 tickLower;
        int24 tickUpper;
        uint256 marginDelta;
    }


    function getCurrentTick(IMarginEngine marginEngine)
        external
        view
        returns (int24 currentTick);


    function lpMarginCaps(IVAMM _vamm) external returns (int256);


    function lpMarginCumulatives(IVAMM _vamm) external returns (int256);



    function mintOrBurn(MintOrBurnParams memory params)
        external
        returns (int256 positionMarginRequirement);


    function swap(SwapPeripheryParams memory params)
        external
        returns (
            int256 _fixedTokenDelta,
            int256 _variableTokenDelta,
            uint256 _cumulativeFeeIncurred,
            int256 _fixedTokenDeltaUnbalanced,
            int256 _marginRequirement,
            int24 _tickAfter
        );


    function updatePositionMargin(
        IMarginEngine _marginEngine,
        int24 _tickLower,
        int24 _tickUpper,
        int256 _marginDelta,
        bool _fullyWithdraw
    ) external;


    function setLPMarginCap(IVAMM _vamm, int256 _lpMarginCapNew) external;


    function settlePositionAndWithdrawMargin(
        IMarginEngine _marginEngine,
        address _owner,
        int24 _tickLower,
        int24 _tickUpper
    ) external;

}// Apache-2.0

pragma solidity =0.8.9;


interface IFactory is CustomErrors {

    event IrsInstance(
        IERC20Minimal indexed underlyingToken,
        IRateOracle indexed rateOracle,
        uint256 termStartTimestampWad,
        uint256 termEndTimestampWad,
        int24 tickSpacing,
        IMarginEngine marginEngine,
        IVAMM vamm,
        IFCM fcm,
        uint8 yieldBearingProtocolID,
        uint8 underlyingTokenDecimals
    );

    event MasterFCM(IFCM masterFCMAddress, uint8 yieldBearingProtocolID);

    event Approval(
        address indexed owner,
        address indexed intAddress,
        bool indexed isApproved
    );

    event PeripheryUpdate(IPeriphery periphery);


    function isApproved(address _owner, address intAddress)
        external
        view
        returns (bool);


    function masterVAMM() external view returns (IVAMM);


    function masterMarginEngine() external view returns (IMarginEngine);


    function periphery() external view returns (IPeriphery);



    function setApproval(address intAddress, bool allowIntegration) external;


    function setMasterFCM(IFCM masterFCM, uint8 yieldBearingProtocolID)
        external;


    function setMasterVAMM(IVAMM _masterVAMM) external;


    function setMasterMarginEngine(IMarginEngine _masterMarginEngine) external;


    function setPeriphery(IPeriphery _periphery) external;


    function deployIrsInstance(
        IERC20Minimal _underlyingToken,
        IRateOracle _rateOracle,
        uint256 _termStartTimestampWad,
        uint256 _termEndTimestampWad,
        int24 _tickSpacing
    )
        external
        returns (
            IMarginEngine marginEngineProxy,
            IVAMM vammProxy,
            IFCM fcmProxy
        );


    function masterFCMs(uint8 yieldBearingProtocolID)
        external
        view
        returns (IFCM masterFCM);

}// Apache-2.0

pragma solidity =0.8.9;

interface ICToken {


  function exchangeRateStored() external view returns (uint256);


  function exchangeRateCurrent() external returns (uint256);


  function redeemUnderlying(uint redeemAmount) external returns (uint);


  function underlying() external view returns (address);

}// Apache-2.0

pragma solidity =0.8.9;

interface ICompoundRateOracle is IRateOracle {


    function ctoken() external view returns (ICToken);


    function decimals() external view returns (uint8);


}// BUSL-1.1
pragma solidity =0.8.9;

library OracleBuffer {

    uint256 public constant MAX_BUFFER_LENGTH = 65535;

    struct Observation {
        uint32 blockTimestamp;
        uint216 observedValue;
        bool initialized;
    }

    function observation(uint32 blockTimestamp, uint256 observedValue)
        private
        pure
        returns (Observation memory)
    {

        require(observedValue <= type(uint216).max, ">216");
        return
            Observation({
                blockTimestamp: blockTimestamp,
                observedValue: uint216(observedValue),
                initialized: true
            });
    }

    function initialize(
        Observation[MAX_BUFFER_LENGTH] storage self,
        uint32[] memory times,
        uint256[] memory observedValues
    )
        internal
        returns (
            uint16 cardinality,
            uint16 cardinalityNext,
            uint16 rateIndex
        )
    {

        require(times.length < MAX_BUFFER_LENGTH, "MAXT");
        uint16 length = uint16(times.length);
        require(length == observedValues.length, "Lengths must match");
        require(length > 0, "0T");
        uint32 prevTime = 0;
        for (uint16 i = 0; i < length; i++) {
            require(prevTime < times[i], "input unordered");

            self[i] = observation(times[i], observedValues[i]);
            prevTime = times[i];
        }
        return (length, length, length - 1);
    }

    function write(
        Observation[MAX_BUFFER_LENGTH] storage self,
        uint16 index,
        uint32 blockTimestamp,
        uint256 observedValue,
        uint16 cardinality,
        uint16 cardinalityNext
    ) internal returns (uint16 indexUpdated, uint16 cardinalityUpdated) {

        Observation memory last = self[index];

        if (last.blockTimestamp == blockTimestamp) return (index, cardinality);

        if (cardinalityNext > cardinality && index == (cardinality - 1)) {
            cardinalityUpdated = cardinalityNext;
        } else {
            cardinalityUpdated = cardinality;
        }

        indexUpdated = (index + 1) % cardinalityUpdated;
        self[indexUpdated] = observation(blockTimestamp, observedValue);
    }

    function grow(
        Observation[MAX_BUFFER_LENGTH] storage self,
        uint16 current,
        uint16 next
    ) internal returns (uint16) {

        require(current > 0, "I");
        require(next < MAX_BUFFER_LENGTH, "buffer limit");
        if (next <= current) return current;
        for (uint16 i = current; i < next; i++) self[i].blockTimestamp = 1;
        return next;
    }

    function binarySearch(
        Observation[MAX_BUFFER_LENGTH] storage self,
        uint32 target,
        uint16 index,
        uint16 cardinality
    )
        internal
        view
        returns (Observation memory beforeOrAt, Observation memory atOrAfter)
    {

        uint256 l = (index + 1) % cardinality; // oldest observation
        uint256 r = l + cardinality - 1; // newest observation
        uint256 i;
        while (true) {
            i = (l + r) >> 1;

            beforeOrAt = self[i % cardinality];

            if (!beforeOrAt.initialized) {
                l = i + 1;
                continue;
            }

            atOrAfter = self[(i + 1) % cardinality];

            bool targetAtOrAfter = beforeOrAt.blockTimestamp <= target;

            if (targetAtOrAfter && target <= atOrAfter.blockTimestamp) break;

            if (!targetAtOrAfter) r = i - 1;
            else l = i + 1;
        }
    }

    function getSurroundingObservations(
        Observation[MAX_BUFFER_LENGTH] storage self,
        uint32 target,
        uint32 currentTime,
        uint256 currentValue,
        uint16 index,
        uint16 cardinality
    )
        internal
        view
        returns (Observation memory beforeOrAt, Observation memory atOrAfter)
    {

        beforeOrAt = self[index];

        if (beforeOrAt.blockTimestamp <= target) {
            if (beforeOrAt.blockTimestamp == target) {
                return (beforeOrAt, atOrAfter);
            } else {
                return (beforeOrAt, observation(currentTime, currentValue));
            }
        }

        beforeOrAt = self[(index + 1) % cardinality];
        if (!beforeOrAt.initialized) beforeOrAt = self[0];

        require(beforeOrAt.blockTimestamp <= target, "OLD");

        return binarySearch(self, target, index, cardinality);
    }
}// Apache-2.0

pragma solidity =0.8.9;

library WadRayMath {

    enum Mode {
        WAD_MODE,
        RAY_MODE
    }

    uint256 public constant WAD = 1e18;
    uint256 public constant RAY = 1e27;

    uint256 public constant HALF_WAD = WAD / 2;
    uint256 public constant HALF_RAY = RAY / 2;

    uint256 public constant WAD_RAY_RATIO = RAY / WAD;
    uint256 internal constant HALF_RATIO = WAD_RAY_RATIO / 2;

    function _mul(
        uint256 a,
        uint256 b,
        Mode m
    ) private pure returns (uint256) {

        if (a == 0 || b == 0) {
            return 0;
        }

        return
            (a * b + (m == Mode.RAY_MODE ? HALF_RAY : HALF_WAD)) /
            (m == Mode.RAY_MODE ? RAY : WAD);
    }

    function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {

        return _mul(a, b, Mode.WAD_MODE);
    }

    function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {

        return _mul(a, b, Mode.RAY_MODE);
    }

    function _div(
        uint256 a,
        uint256 b,
        Mode m
    ) private pure returns (uint256) {

        require(b != 0, "DIV0");
        uint256 halfB = b / 2;

        return (a * (m == Mode.RAY_MODE ? RAY : WAD) + halfB) / b;
    }

    function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return _div(a, b, Mode.WAD_MODE);
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return _div(a, b, Mode.RAY_MODE);
    }

    function wadToRay(uint256 a) internal pure returns (uint256) {

        uint256 result = a * WAD_RAY_RATIO;
        return result;
    }

    function rayToWad(uint256 a) internal pure returns (uint256) {

        uint256 result = a / WAD_RAY_RATIO;

        if (a % WAD_RAY_RATIO >= HALF_RATIO) {
            result += 1;
        }

        return result;
    }
}// Apache-2.0

pragma solidity =0.8.9;


abstract contract BaseRateOracle is IRateOracle, Ownable {
    uint256 public constant ONE_IN_WAD = 1e18;

    using OracleBuffer for OracleBuffer.Observation[65535];

    mapping(uint32 => mapping(uint32 => uint256)) public settlementRateCache;
    struct OracleVars {
        uint16 rateIndex;
        uint16 rateCardinality;
        uint16 rateCardinalityNext;
    }

    IERC20Minimal public immutable override underlying;

    uint256 public override minSecondsSinceLastUpdate;

    OracleVars public oracleVars;

    OracleBuffer.Observation[65535] public observations;

    function setMinSecondsSinceLastUpdate(uint256 _minSecondsSinceLastUpdate)
        external
        override
        onlyOwner
    {
        if (minSecondsSinceLastUpdate != _minSecondsSinceLastUpdate) {
            minSecondsSinceLastUpdate = _minSecondsSinceLastUpdate;

            emit MinSecondsSinceLastUpdate(_minSecondsSinceLastUpdate);
        }
    }

    constructor(IERC20Minimal _underlying) {
        require(address(_underlying) != address(0), "underlying must exist");
        underlying = _underlying;
    }

    function interpolateRateValue(
        uint256 beforeOrAtRateValueRay,
        uint256 apyFromBeforeOrAtToAtOrAfterWad,
        uint256 timeDeltaBeforeOrAtToQueriedTimeWad
    ) public pure virtual returns (uint256 rateValueRay) {
        uint256 timeInYearsWad = FixedAndVariableMath.accrualFact(
            timeDeltaBeforeOrAtToQueriedTimeWad
        );
        uint256 apyPlusOne = apyFromBeforeOrAtToAtOrAfterWad + ONE_IN_WAD;
        uint256 factorInWad = PRBMathUD60x18.pow(apyPlusOne, timeInYearsWad);
        uint256 factorInRay = WadRayMath.wadToRay(factorInWad);
        rateValueRay = WadRayMath.rayMul(beforeOrAtRateValueRay, factorInRay);
    }

    function increaseObservationCardinalityNext(uint16 rateCardinalityNext)
        external
        override
    {
        uint16 rateCardinalityNextOld = oracleVars.rateCardinalityNext; // for the event

        uint16 rateCardinalityNextNew = observations.grow(
            rateCardinalityNextOld,
            rateCardinalityNext
        );

        oracleVars.rateCardinalityNext = rateCardinalityNextNew;

        if (rateCardinalityNextOld != rateCardinalityNextNew) {
            emit RateCardinalityNext(rateCardinalityNextNew);
        }
    }

    function computeApyFromRate(uint256 rateFromToWad, uint256 timeInYearsWad)
        internal
        pure
        returns (uint256 apyWad)
    {
        if (rateFromToWad == 0) {
            return 0;
        }

        uint256 exponentWad = PRBMathUD60x18.div(
            PRBMathUD60x18.fromUint(1),
            timeInYearsWad
        );
        uint256 apyPlusOneWad = PRBMathUD60x18.pow(
            (PRBMathUD60x18.fromUint(1) + rateFromToWad),
            exponentWad
        );
        apyWad = apyPlusOneWad - PRBMathUD60x18.fromUint(1);
    }

    function getRateFromTo(uint256 from, uint256 to)
        public
        view
        virtual
        override
        returns (uint256);

    function getApyFromTo(uint256 from, uint256 to)
        public
        view
        override
        returns (uint256 apyFromToWad)
    {
        require(from <= to, "Misordered dates");

        uint256 rateFromToWad = getRateFromTo(from, to);

        uint256 timeInSeconds = to - from;

        uint256 timeInSecondsWad = PRBMathUD60x18.fromUint(timeInSeconds);

        uint256 timeInYearsWad = FixedAndVariableMath.accrualFact(
            timeInSecondsWad
        );

        apyFromToWad = computeApyFromRate(rateFromToWad, timeInYearsWad);
    }

    function variableFactor(
        uint256 termStartTimestampInWeiSeconds,
        uint256 termEndTimestampInWeiSeconds
    ) public override(IRateOracle) returns (uint256 resultWad) {
        bool cacheable;

        (resultWad, cacheable) = _variableFactor(
            termStartTimestampInWeiSeconds,
            termEndTimestampInWeiSeconds
        );

        if (cacheable) {
            uint32 termStartTimestamp = Time.timestampAsUint32(
                PRBMathUD60x18.toUint(termStartTimestampInWeiSeconds)
            );
            uint32 termEndTimestamp = Time.timestampAsUint32(
                PRBMathUD60x18.toUint(termEndTimestampInWeiSeconds)
            );
            settlementRateCache[termStartTimestamp][
                termEndTimestamp
            ] = resultWad;
        }

        return resultWad;
    }

    function variableFactorNoCache(
        uint256 termStartTimestampInWeiSeconds,
        uint256 termEndTimestampInWeiSeconds
    ) public view override(IRateOracle) returns (uint256 resultWad) {
        (resultWad, ) = _variableFactor(
            termStartTimestampInWeiSeconds,
            termEndTimestampInWeiSeconds
        );
    }

    function _variableFactor(
        uint256 termStartTimestampInWeiSeconds,
        uint256 termEndTimestampInWeiSeconds
    ) private view returns (uint256 resultWad, bool cacheable) {
        uint32 termStartTimestamp = Time.timestampAsUint32(
            PRBMathUD60x18.toUint(termStartTimestampInWeiSeconds)
        );
        uint32 termEndTimestamp = Time.timestampAsUint32(
            PRBMathUD60x18.toUint(termEndTimestampInWeiSeconds)
        );

        require(termStartTimestamp > 0 && termEndTimestamp > 0, "UNITS");
        if (settlementRateCache[termStartTimestamp][termEndTimestamp] != 0) {
            resultWad = settlementRateCache[termStartTimestamp][
                termEndTimestamp
            ];
            cacheable = false;
        } else if (Time.blockTimestampTruncated() >= termEndTimestamp) {
            resultWad = getRateFromTo(termStartTimestamp, termEndTimestamp);
            cacheable = true;
        } else {
            resultWad = getRateFromTo(
                termStartTimestamp,
                Time.blockTimestampTruncated()
            );
            cacheable = false;
        }
    }

    function writeOracleEntry() external virtual override;
}// Apache-2.0

pragma solidity =0.8.9;


contract CompoundRateOracle is BaseRateOracle, ICompoundRateOracle {

    using OracleBuffer for OracleBuffer.Observation[65535];

    ICToken public immutable override ctoken;

    uint8 public immutable override decimals;

    uint256 private immutable scaleDownFactor;
    uint256 private immutable scaleUpFactor;

    uint8 public constant override UNDERLYING_YIELD_BEARING_PROTOCOL_ID = 2; // id of compound is 2

    uint8 constant DECIMALS_SCALING_THRESHOLD = 17;

    constructor(
        ICToken _ctoken,
        IERC20Minimal underlying,
        uint8 _decimals,
        uint32[] memory _times,
        uint256[] memory _results
    ) BaseRateOracle(underlying) {
        ctoken = _ctoken;
        require(
            ctoken.underlying() == address(underlying),
            "Tokens do not match"
        );
        decimals = _decimals;

        scaleDownFactor = decimals >= DECIMALS_SCALING_THRESHOLD
            ? 10**(decimals - DECIMALS_SCALING_THRESHOLD)
            : 0;
        scaleUpFactor = decimals < DECIMALS_SCALING_THRESHOLD
            ? 10**(DECIMALS_SCALING_THRESHOLD - decimals)
            : 0;

        require(_times.length < OracleBuffer.MAX_BUFFER_LENGTH / 2, "MAXT");
        uint16 length = uint16(_times.length);
        require(length == _results.length, "Lengths must match");

        uint32[] memory times = new uint32[](length + 1);
        uint256[] memory results = new uint256[](length + 1);
        for (uint256 i = 0; i < length; i++) {
            times[i] = _times[i];
            results[i] = _results[i];
        }
        times[length] = Time.blockTimestampTruncated();
        results[length] = exchangeRateInRay();
        (
            oracleVars.rateCardinality,
            oracleVars.rateCardinalityNext,
            oracleVars.rateIndex
        ) = observations.initialize(times, results);
    }

    function exchangeRateInRay() internal view returns (uint256 resultRay) {

        uint256 exchangeRateStored = ctoken.exchangeRateStored();
        if (exchangeRateStored == 0) {
            revert CustomErrors.CTokenExchangeRateReturnedZero();
        }

        if (decimals >= DECIMALS_SCALING_THRESHOLD) {
            resultRay = exchangeRateStored / scaleDownFactor;
        } else {
            resultRay = exchangeRateStored * scaleUpFactor;
        }

        return resultRay;
    }

    function writeRate(
        uint16 index,
        uint16 cardinality,
        uint16 cardinalityNext
    ) internal returns (uint16 indexUpdated, uint16 cardinalityUpdated) {

        OracleBuffer.Observation memory last = observations[index];
        uint32 blockTimestamp = Time.blockTimestampTruncated();

        if (blockTimestamp - minSecondsSinceLastUpdate < last.blockTimestamp)
            return (index, cardinality);

        uint256 resultRay = exchangeRateInRay();

        emit OracleBufferUpdate(
            Time.blockTimestampScaled(),
            address(this),
            index,
            blockTimestamp,
            resultRay,
            cardinality,
            cardinalityNext
        );

        return
            observations.write(
                index,
                blockTimestamp,
                resultRay,
                cardinality,
                cardinalityNext
            );
    }

    function getRateFromTo(
        uint256 _from,
        uint256 _to //  move docs to IRateOracle. Add additional parameter to use cache and implement cache.
    ) public view override(BaseRateOracle, IRateOracle) returns (uint256) {

        require(_from <= _to, "from > to");

        if (_from == _to) {
            return 0;
        }

        uint32 currentTime = Time.blockTimestampTruncated();
        uint32 from = Time.timestampAsUint32(_from);
        uint32 to = Time.timestampAsUint32(_to);

        uint256 rateFromRay = observeSingle(
            currentTime,
            from,
            oracleVars.rateIndex,
            oracleVars.rateCardinality
        );
        uint256 rateToRay = observeSingle(
            currentTime,
            to,
            oracleVars.rateIndex,
            oracleVars.rateCardinality
        );

        if (rateToRay > rateFromRay) {
            uint256 result = WadRayMath.rayToWad(
                WadRayMath.rayDiv(rateToRay, rateFromRay) - WadRayMath.RAY
            );
            return result;
        } else {
            return 0;
        }
    }

    function observeSingle(
        uint32 currentTime,
        uint32 queriedTime,
        uint16 index,
        uint16 cardinality
    ) internal view returns (uint256 rateValueRay) {

        if (currentTime < queriedTime) revert CustomErrors.OOO();

        if (currentTime == queriedTime) {
            OracleBuffer.Observation memory rate;
            rate = observations[index];
            if (rate.blockTimestamp != currentTime) {
                rateValueRay = exchangeRateInRay();
            } else {
                rateValueRay = rate.observedValue;
            }
            return rateValueRay;
        }

        uint256 currentValueRay = exchangeRateInRay();
        (
            OracleBuffer.Observation memory beforeOrAt,
            OracleBuffer.Observation memory atOrAfter
        ) = observations.getSurroundingObservations(
                queriedTime,
                currentTime,
                currentValueRay,
                index,
                cardinality
            );

        if (queriedTime == beforeOrAt.blockTimestamp) {
            rateValueRay = beforeOrAt.observedValue;
        } else if (queriedTime == atOrAfter.blockTimestamp) {
            rateValueRay = atOrAfter.observedValue;
        } else {

            uint256 rateFromBeforeOrAtToAtOrAfterWad;


            if (atOrAfter.observedValue > beforeOrAt.observedValue) {
                uint256 rateFromBeforeOrAtToAtOrAfterRay = WadRayMath.rayDiv(
                    atOrAfter.observedValue,
                    beforeOrAt.observedValue
                ) - WadRayMath.RAY;

                rateFromBeforeOrAtToAtOrAfterWad = WadRayMath.rayToWad(
                    rateFromBeforeOrAtToAtOrAfterRay
                );
            }

            uint256 timeInYearsWad = FixedAndVariableMath.accrualFact(
                (atOrAfter.blockTimestamp - beforeOrAt.blockTimestamp) *
                    WadRayMath.WAD
            );

            uint256 apyFromBeforeOrAtToAtOrAfterWad = computeApyFromRate(
                rateFromBeforeOrAtToAtOrAfterWad,
                timeInYearsWad
            );

            rateValueRay = interpolateRateValue(
                beforeOrAt.observedValue,
                apyFromBeforeOrAtToAtOrAfterWad,
                (queriedTime - beforeOrAt.blockTimestamp) * WadRayMath.WAD
            );
        }
    }

    function writeOracleEntry() external override(BaseRateOracle, IRateOracle) {

        (oracleVars.rateIndex, oracleVars.rateCardinality) = writeRate(
            oracleVars.rateIndex,
            oracleVars.rateCardinality,
            oracleVars.rateCardinalityNext
        );
    }
}