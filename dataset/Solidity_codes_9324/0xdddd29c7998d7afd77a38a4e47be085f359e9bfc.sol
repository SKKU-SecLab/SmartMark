


pragma solidity >=0.8.0;

library PRBMathCommon {

    uint256 internal constant SCALE = 1e18;

    uint256 internal constant SCALE_LPOTD = 262144;

    uint256 internal constant SCALE_INVERSE = 78156646155174841979727994598816262306175212592076161876661508869554232690281;

    function exp2(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = 0x80000000000000000000000000000000;

            if (x & 0x80000000000000000000000000000000 > 0) result = (result * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
            if (x & 0x40000000000000000000000000000000 > 0) result = (result * 0x1306FE0A31B7152DE8D5A46305C85EDED) >> 128;
            if (x & 0x20000000000000000000000000000000 > 0) result = (result * 0x1172B83C7D517ADCDF7C8C50EB14A7920) >> 128;
            if (x & 0x10000000000000000000000000000000 > 0) result = (result * 0x10B5586CF9890F6298B92B71842A98364) >> 128;
            if (x & 0x8000000000000000000000000000000 > 0) result = (result * 0x1059B0D31585743AE7C548EB68CA417FE) >> 128;
            if (x & 0x4000000000000000000000000000000 > 0) result = (result * 0x102C9A3E778060EE6F7CACA4F7A29BDE9) >> 128;
            if (x & 0x2000000000000000000000000000000 > 0) result = (result * 0x10163DA9FB33356D84A66AE336DCDFA40) >> 128;
            if (x & 0x1000000000000000000000000000000 > 0) result = (result * 0x100B1AFA5ABCBED6129AB13EC11DC9544) >> 128;
            if (x & 0x800000000000000000000000000000 > 0) result = (result * 0x10058C86DA1C09EA1FF19D294CF2F679C) >> 128;
            if (x & 0x400000000000000000000000000000 > 0) result = (result * 0x1002C605E2E8CEC506D21BFC89A23A011) >> 128;
            if (x & 0x200000000000000000000000000000 > 0) result = (result * 0x100162F3904051FA128BCA9C55C31E5E0) >> 128;
            if (x & 0x100000000000000000000000000000 > 0) result = (result * 0x1000B175EFFDC76BA38E31671CA939726) >> 128;
            if (x & 0x80000000000000000000000000000 > 0) result = (result * 0x100058BA01FB9F96D6CACD4B180917C3E) >> 128;
            if (x & 0x40000000000000000000000000000 > 0) result = (result * 0x10002C5CC37DA9491D0985C348C68E7B4) >> 128;
            if (x & 0x20000000000000000000000000000 > 0) result = (result * 0x1000162E525EE054754457D5995292027) >> 128;
            if (x & 0x10000000000000000000000000000 > 0) result = (result * 0x10000B17255775C040618BF4A4ADE83FD) >> 128;
            if (x & 0x8000000000000000000000000000 > 0) result = (result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAC) >> 128;
            if (x & 0x4000000000000000000000000000 > 0) result = (result * 0x100002C5C89D5EC6CA4D7C8ACC017B7CA) >> 128;
            if (x & 0x2000000000000000000000000000 > 0) result = (result * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
            if (x & 0x1000000000000000000000000000 > 0) result = (result * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
            if (x & 0x800000000000000000000000000 > 0) result = (result * 0x10000058B90CF1E6D97F9CA14DBCC1629) >> 128;
            if (x & 0x400000000000000000000000000 > 0) result = (result * 0x1000002C5C863B73F016468F6BAC5CA2C) >> 128;
            if (x & 0x200000000000000000000000000 > 0) result = (result * 0x100000162E430E5A18F6119E3C02282A6) >> 128;
            if (x & 0x100000000000000000000000000 > 0) result = (result * 0x1000000B1721835514B86E6D96EFD1BFF) >> 128;
            if (x & 0x80000000000000000000000000 > 0) result = (result * 0x100000058B90C0B48C6BE5DF846C5B2F0) >> 128;
            if (x & 0x40000000000000000000000000 > 0) result = (result * 0x10000002C5C8601CC6B9E94213C72737B) >> 128;
            if (x & 0x20000000000000000000000000 > 0) result = (result * 0x1000000162E42FFF037DF38AA2B219F07) >> 128;
            if (x & 0x10000000000000000000000000 > 0) result = (result * 0x10000000B17217FBA9C739AA5819F44FA) >> 128;
            if (x & 0x8000000000000000000000000 > 0) result = (result * 0x1000000058B90BFCDEE5ACD3C1CEDC824) >> 128;
            if (x & 0x4000000000000000000000000 > 0) result = (result * 0x100000002C5C85FE31F35A6A30DA1BE51) >> 128;
            if (x & 0x2000000000000000000000000 > 0) result = (result * 0x10000000162E42FF0999CE3541B9FFFD0) >> 128;
            if (x & 0x1000000000000000000000000 > 0) result = (result * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
            if (x & 0x800000000000000000000000 > 0) result = (result * 0x10000000058B90BFBF8479BD5A81B51AE) >> 128;
            if (x & 0x400000000000000000000000 > 0) result = (result * 0x1000000002C5C85FDF84BD62AE30A74CD) >> 128;
            if (x & 0x200000000000000000000000 > 0) result = (result * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
            if (x & 0x100000000000000000000000 > 0) result = (result * 0x1000000000B17217F7D5A7716BBA4A9AF) >> 128;
            if (x & 0x80000000000000000000000 > 0) result = (result * 0x100000000058B90BFBE9DDBAC5E109CCF) >> 128;
            if (x & 0x40000000000000000000000 > 0) result = (result * 0x10000000002C5C85FDF4B15DE6F17EB0E) >> 128;
            if (x & 0x20000000000000000000000 > 0) result = (result * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
            if (x & 0x10000000000000000000000 > 0) result = (result * 0x10000000000B17217F7D20CF927C8E94D) >> 128;
            if (x & 0x8000000000000000000000 > 0) result = (result * 0x1000000000058B90BFBE8F71CB4E4B33E) >> 128;
            if (x & 0x4000000000000000000000 > 0) result = (result * 0x100000000002C5C85FDF477B662B26946) >> 128;
            if (x & 0x2000000000000000000000 > 0) result = (result * 0x10000000000162E42FEFA3AE53369388D) >> 128;
            if (x & 0x1000000000000000000000 > 0) result = (result * 0x100000000000B17217F7D1D351A389D41) >> 128;
            if (x & 0x800000000000000000000 > 0) result = (result * 0x10000000000058B90BFBE8E8B2D3D4EDF) >> 128;
            if (x & 0x400000000000000000000 > 0) result = (result * 0x1000000000002C5C85FDF4741BEA6E77F) >> 128;
            if (x & 0x200000000000000000000 > 0) result = (result * 0x100000000000162E42FEFA39FE95583C3) >> 128;
            if (x & 0x100000000000000000000 > 0) result = (result * 0x1000000000000B17217F7D1CFB72B45E3) >> 128;
            if (x & 0x80000000000000000000 > 0) result = (result * 0x100000000000058B90BFBE8E7CC35C3F2) >> 128;
            if (x & 0x40000000000000000000 > 0) result = (result * 0x10000000000002C5C85FDF473E242EA39) >> 128;
            if (x & 0x20000000000000000000 > 0) result = (result * 0x1000000000000162E42FEFA39F02B772C) >> 128;
            if (x & 0x10000000000000000000 > 0) result = (result * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
            if (x & 0x8000000000000000000 > 0) result = (result * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
            if (x & 0x4000000000000000000 > 0) result = (result * 0x100000000000002C5C85FDF473DEA871F) >> 128;
            if (x & 0x2000000000000000000 > 0) result = (result * 0x10000000000000162E42FEFA39EF44D92) >> 128;
            if (x & 0x1000000000000000000 > 0) result = (result * 0x100000000000000B17217F7D1CF79E949) >> 128;
            if (x & 0x800000000000000000 > 0) result = (result * 0x10000000000000058B90BFBE8E7BCE545) >> 128;
            if (x & 0x400000000000000000 > 0) result = (result * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
            if (x & 0x200000000000000000 > 0) result = (result * 0x100000000000000162E42FEFA39EF366F) >> 128;
            if (x & 0x100000000000000000 > 0) result = (result * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
            if (x & 0x80000000000000000 > 0) result = (result * 0x100000000000000058B90BFBE8E7BCD6E) >> 128;
            if (x & 0x40000000000000000 > 0) result = (result * 0x10000000000000002C5C85FDF473DE6B3) >> 128;
            if (x & 0x20000000000000000 > 0) result = (result * 0x1000000000000000162E42FEFA39EF359) >> 128;
            if (x & 0x10000000000000000 > 0) result = (result * 0x10000000000000000B17217F7D1CF79AC) >> 128;

            result = result << ((x >> 128) + 1);

            result = PRBMathCommon.mulDiv(result, 1e18, 2**128);
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
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);


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

            inverse *= 2 - denominator * inverse; // inverse mod 2**8
            inverse *= 2 - denominator * inverse; // inverse mod 2**16
            inverse *= 2 - denominator * inverse; // inverse mod 2**32
            inverse *= 2 - denominator * inverse; // inverse mod 2**64
            inverse *= 2 - denominator * inverse; // inverse mod 2**128
            inverse *= 2 - denominator * inverse; // inverse mod 2**256

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

        require(SCALE > prod1);

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
}


pragma solidity >=0.8.0;


library PRBMathSD59x18 {

    int256 internal constant LOG2_E = 1442695040888963407;

    int256 internal constant HALF_SCALE = 5e17;

    int256 internal constant MAX_SD59x18 = 57896044618658097711785492504343953926634992332820282019728792003956564819967;

    int256 internal constant MAX_WHOLE_SD59x18 = 57896044618658097711785492504343953926634992332820282019728000000000000000000;

    int256 internal constant MIN_SD59x18 = -57896044618658097711785492504343953926634992332820282019728792003956564819968;

    int256 internal constant MIN_WHOLE_SD59x18 = -57896044618658097711785492504343953926634992332820282019728000000000000000000;

    int256 internal constant SCALE = 1e18;


    function abs(int256 x) internal pure returns (int256 result) {

        unchecked {
            require(x > MIN_SD59x18);
            result = x < 0 ? -x : x;
        }
    }

    function avg(int256 x, int256 y) internal pure returns (int256 result) {

        unchecked {
            result = (x >> 1) + (y >> 1) + (x & y & 1);
        }
    }

    function ceil(int256 x) internal pure returns (int256 result) {

        require(x <= MAX_WHOLE_SD59x18);
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

        require(x > type(int256).min);
        require(y > type(int256).min);

        uint256 ax;
        uint256 ay;
        unchecked {
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);
        }

        uint256 resultUnsigned = PRBMathCommon.mulDiv(ax, uint256(SCALE), ay);
        require(resultUnsigned <= uint256(type(int256).max));

        uint256 sx;
        uint256 sy;
        assembly {
            sx := sgt(x, sub(0, 1))
            sy := sgt(y, sub(0, 1))
        }

        result = sx ^ sy == 1 ? -int256(resultUnsigned) : int256(resultUnsigned);
    }

    function e() internal pure returns (int256 result) {

        result = 2718281828459045235;
    }

    function exp(int256 x) internal pure returns (int256 result) {

        if (x < -41446531673892822322) {
            return 0;
        }

        require(x < 88722839111672999628);

        unchecked {
            int256 doubleScaleProduct = x * LOG2_E;
            result = exp2((doubleScaleProduct + HALF_SCALE) / SCALE);
        }
    }

    function exp2(int256 x) internal pure returns (int256 result) {

        if (x < 0) {
            if (x < -59794705707972522261) {
                return 0;
            }

            unchecked { result = 1e36 / exp2(-x); }
            return result;
        } else {
            require(x < 128e18);

            unchecked {
                uint256 x128x128 = (uint256(x) << 128) / uint256(SCALE);

                result = int256(PRBMathCommon.exp2(x128x128));
            }
        }
    }

    function floor(int256 x) internal pure returns (int256 result) {

        require(x >= MIN_WHOLE_SD59x18);
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

        unchecked { result = x % SCALE; }
    }

    function gm(int256 x, int256 y) internal pure returns (int256 result) {

        if (x == 0) {
            return 0;
        }

        unchecked {
            int256 xy = x * y;
            require(xy / x == y);

            require(xy >= 0);

            result = int256(PRBMathCommon.sqrt(uint256(xy)));
        }
    }

    function inv(int256 x) internal pure returns (int256 result) {

        unchecked {
            result = 1e36 / x;
        }
    }

    function ln(int256 x) internal pure returns (int256 result) {

        unchecked { result = (log2(x) * SCALE) / LOG2_E; }
    }

    function log10(int256 x) internal pure returns (int256 result) {

        require(x > 0);

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
            unchecked { result = (log2(x) * SCALE) / 332192809488736234; }
        }
    }

    function log2(int256 x) internal pure returns (int256 result) {

        require(x > 0);
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

            uint256 n = PRBMathCommon.mostSignificantBit(uint256(x / SCALE));

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

        require(x > MIN_SD59x18);
        require(y > MIN_SD59x18);

        unchecked {
            uint256 ax;
            uint256 ay;
            ax = x < 0 ? uint256(-x) : uint256(x);
            ay = y < 0 ? uint256(-y) : uint256(y);

            uint256 resultUnsigned = PRBMathCommon.mulDivFixedPoint(ax, ay);
            require(resultUnsigned <= uint256(MAX_SD59x18));

            uint256 sx;
            uint256 sy;
            assembly {
                sx := sgt(x, sub(0, 1))
                sy := sgt(y, sub(0, 1))
            }
            result = sx ^ sy == 1 ? -int256(resultUnsigned) : int256(resultUnsigned);
        }
    }

    function pi() internal pure returns (int256 result) {

        result = 3141592653589793238;
    }

    function pow(int256 x, uint256 y) internal pure returns (int256 result) {

        uint256 absX = uint256(abs(x));

        uint256 absResult = y & 1 > 0 ? absX : uint256(SCALE);

        for (y >>= 1; y > 0; y >>= 1) {
            absX = PRBMathCommon.mulDivFixedPoint(absX, absX);

            if (y & 1 > 0) {
                absResult = PRBMathCommon.mulDivFixedPoint(absResult, absX);
            }
        }

        require(absResult <= uint256(MAX_SD59x18));

        bool isNegative = x < 0 && y & 1 == 1;
        result = isNegative ? -int256(absResult) : int256(absResult);
    }

    function scale() internal pure returns (int256 result) {

        result = SCALE;
    }

    function sqrt(int256 x) internal pure returns (int256 result) {

        require(x >= 0);
        require(x < 57896044618658097711785492504343953926634992332820282019729);
        unchecked {
            result = int256(PRBMathCommon.sqrt(uint256(x * SCALE)));
        }
    }
}



pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;




contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}




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
}




pragma solidity 0.8.13;




contract Staking is Ownable {

    struct Stake {

        string symbol;

        uint256 quantity;

        uint256 duration;

        int256 maxDuration;

        uint256 percent;

        uint256 aValue;

        uint256 date;
    }

    struct TokenDetails {
        address tokenAddress;

        int256 maxDuration;

        uint256 maxPercent;

        uint256 aValue;

        address poolAdmin;

        uint256 rewardPool;

        uint256 reservedPool;
    }

    int256 constant daysInMonth = 30;

    uint256 public constant secondsInMonth = uint256(daysInMonth) * 24 * 60 * 60;

    string[] public symbols;

    mapping(address => mapping (string /*symbol*/ => Stake[])) public stakes;

    mapping(address => string[]) public symbolsByAddress;

    mapping(string => TokenDetails) public tokenContracts;

    function allSymbols() public view returns (string[] memory) {
        return symbols;
    }

    function mySymbols(address who) public view returns (string[] memory) {
        return symbolsByAddress[who];
    }    

    function myStakes(address who, string memory symbol) public view returns (Stake[] memory) {
        return stakes[who][symbol];
    }

    event PoolSizeChanged(address indexed who, string symbol, uint256 oldQuantity, uint256 newQuantity);

    event TokensStaked(address indexed who, string symbol, uint256 quantity, int256 duration, int256 maxDuration, uint256 maxPercent, uint256 aValue, uint256 timestamp);

    event TokensClaimed(address indexed who, string symbol, uint256 totalTokens);


    function setTokenContract(address tokenAddress, string memory symbol, int256 maxDuration, uint256 maxPercent, uint256 aValue, address admin) public {
        require(!equals(symbol, ""), "Symbol must be set");
        require(maxPercent == 0 || maxPercent >= 10000000000000000, "Minimum percent is 0.01%");
        require(maxDuration <= 60, "Duration is limited to 5 years");

        Ownable own = Ownable(tokenAddress);
        require(own.owner() == _msgSender(), "You do not own this contract");

        TokenDetails memory existing = tokenContracts[symbol];
        if(existing.tokenAddress != address(0))
            require(existing.tokenAddress == tokenAddress, "Address already set for Symbol");
        else
            symbols.push(symbol);
        
        tokenContracts[symbol] = TokenDetails(tokenAddress, maxDuration, maxPercent, aValue, admin, existing.rewardPool, existing.reservedPool);
    }

    function createStake(string memory symbol, uint256 quantity, int256 duration) public {
        TokenDetails memory token = tokenContracts[symbol];
        require(token.tokenAddress != address(0x0), "Unknown symbol");
        require(token.maxPercent != 0, "New stakes are disabled");
        require(duration > 0, "Must stake for at least 1 month");
        require(duration <= int256(token.maxDuration), "Maximum staking time exceeded");
        ERC20 erc20 = ERC20(token.tokenAddress);
        require(quantity > 0, "Attempt to stake zero tokens");
        require(quantity <= erc20.balanceOf(_msgSender()), "Insufficient tokens");
        require(erc20.allowance(_msgSender(), address(this)) >= quantity, "Approval to staking contract insufficient");

        uint256 reward = uint256(calculateReturn(symbol, quantity, duration)) - quantity;
        require(reward <= token.rewardPool-token.reservedPool, "Insufficient reward pool");
        tokenContracts[symbol].reservedPool += reward;

        erc20.transferFrom(_msgSender(), address(this), quantity);
        uint256 timestamp = block.timestamp;
        Stake memory s = Stake(symbol, quantity, uint256(duration), token.maxDuration, token.maxPercent, token.aValue, timestamp);
        stakes[_msgSender()][symbol].push(s);

        string[] memory syms = symbolsByAddress[_msgSender()];
        for(uint256 i=0; i<syms.length; i++) {
            if(equals(syms[i], symbol))
                return;
        }
        symbolsByAddress[_msgSender()].push(symbol);
    }

    function calculateReturn(string memory symbol, uint256 tokens, int256 months) public view returns (int256) {

        TokenDetails memory token = tokenContracts[symbol];
        require(token.tokenAddress != address(0x0), "Unknown symbol");

        return calculateReturnParams(tokens, months, token.maxDuration, token.maxPercent, token.aValue);
    }

    function calculateReturnParams(uint256 tokens, int256 months, int256 maxMonths, uint256 percent, uint256 aValue) public pure returns (int256) {
        require(months >= 0, "Stake time cannot be negative.");

        if(months == 0)
            return int256(tokens);

        if(aValue > 0 && months == maxMonths)
            return PRBMathSD59x18.mul(int256(tokens), int256(1 ether + percent));

        int256 totalDays = PRBMathSD59x18.mul(int256(months * 1 ether), daysInMonth);
        int256 logTime = PRBMathSD59x18.ln(PRBMathSD59x18.div(totalDays, daysInMonth * maxMonths));
        int256 logTimeByA = PRBMathSD59x18.mul(int256(aValue), logTime);
        int256 expLogTimeByA = PRBMathSD59x18.exp(int256(logTimeByA));
        int256 totalPercent = int256(percent + 1 ether);
        int256 logPercent = PRBMathSD59x18.ln(totalPercent);
        int256 mainMul = PRBMathSD59x18.mul(logPercent, expLogTimeByA);
        int256 finalExp = PRBMathSD59x18.exp(mainMul);
        int256 total = PRBMathSD59x18.mul(int256(tokens), finalExp);

        return total;
    }

    function increaseRewardPool(string memory symbol, uint256 quantity) public {
        TokenDetails memory token = tokenContracts[symbol];
        require(token.tokenAddress != address(0x0), "Unknown symbol");
        require(_msgSender() == token.poolAdmin, "You are not pool admin");

        ERC20 erc20 = ERC20(token.tokenAddress);
        require(quantity <= erc20.balanceOf(_msgSender()), "Insufficient tokens");
        require(erc20.allowance(_msgSender(), address(this)) >= quantity, "Approval to staking contract insufficient");

        uint256 oldQuantity = token.rewardPool;

        erc20.transferFrom(_msgSender(), address(this), quantity);
        tokenContracts[symbol].rewardPool = tokenContracts[symbol].rewardPool + quantity;

        emit PoolSizeChanged(_msgSender(), symbol, oldQuantity, tokenContracts[symbol].rewardPool);
    }

    function withdrawAndClaimAll(string memory symbol) public {
        withdrawAndClaim(symbol, true);
    }

    function withdrawAndClaimVested(string memory symbol) public {
        withdrawAndClaim(symbol, false);
    }

    function withdrawAndClaim(string memory symbol, bool forced) private {
        TokenDetails memory token = tokenContracts[symbol];
        require(token.tokenAddress != address(0x0), "Unknown symbol");

        Stake[] memory stakesBySymbol = stakes[_msgSender()][symbol];
        if(stakesBySymbol.length == 0) {
            return;
        }

        uint256 totalTokens = 0;
        uint256 totalReward = 0;
        for(uint256 i = 0; i<stakesBySymbol.length; i++) {
            uint256 stakeTokens = getTokenCount(stakesBySymbol[i], forced);
            Stake memory s = stakesBySymbol[i];
            if(stakeTokens > 0) {
                if(!hasVested(s.date, s.duration)) {
                    int256 full = calculateReturnParams(s.quantity, int256(s.duration), s.maxDuration, s.percent, s.aValue);
                    tokenContracts[symbol].reservedPool -= (uint256(full) - s.quantity);
                }
                totalReward += stakeTokens - s.quantity;
                totalTokens += stakeTokens;
                stakes[_msgSender()][symbol][i] = Stake("", 0, 0, 0, 0, 0, 0);
            }
        }

        if(totalTokens > 0) {
            ERC20 erc20 = ERC20(token.tokenAddress);
            erc20.transfer(_msgSender(), totalTokens);
            tokenContracts[symbol].rewardPool -= totalReward;
            tokenContracts[symbol].reservedPool -= totalReward;
            emit TokensClaimed(_msgSender(), symbol, totalTokens);
        }
    }

    function hasVested(uint256 date, uint256 duration) public view returns (bool) {
        uint256 vestedDate = date + (duration * secondsInMonth);
        if(block.timestamp > vestedDate)
            return true;
        
        return false;
    }

    function rolloverVested(string memory symbol, uint256 quantity, uint256 duration) public {
        TokenDetails memory token = tokenContracts[symbol];
        require(token.tokenAddress != address(0x0), "Unknown symbol");
        require(duration > 0, "Must stake for at least 1 month");
        require(int256(duration) <= token.maxDuration, "Maximum staking time exceeded");
        ERC20 erc20 = ERC20(token.tokenAddress);
        require(quantity <= erc20.balanceOf(_msgSender()), "Insufficient tokens");
        require(erc20.allowance(_msgSender(), address(this)) >= quantity, "Approval to staking contract insufficient");

        Stake[] memory stakesBySymbol = stakes[_msgSender()][symbol];
        if(stakesBySymbol.length == 0) {
            return;
        }

        uint256 reuseStake = stakesBySymbol.length;
        uint256 totalTokens = quantity;
        uint256 totalReward = 0;

        for(uint256 i = 0; i<stakesBySymbol.length; i++) {
            uint256 stakeTokens = getTokenCount(stakesBySymbol[i], false);
            if(stakeTokens > 0) {
                totalReward += stakeTokens - stakesBySymbol[i].quantity;
                totalTokens += stakeTokens;

                if(reuseStake == stakesBySymbol.length)
                    reuseStake = i;
                else
                    stakes[_msgSender()][symbol][i] = Stake("", 0, 0, 0, 0, 0, 0);
            }
        }

        if(reuseStake == stakesBySymbol.length)
            return;

        uint256 newReward = uint256(calculateReturn(symbol, totalTokens, int256(duration))) - totalTokens;
        require(newReward <= token.rewardPool-token.reservedPool, "Insufficient reward pool");

        tokenContracts[symbol].rewardPool -= totalReward;
        tokenContracts[symbol].reservedPool -= totalReward;
        tokenContracts[symbol].reservedPool += newReward;

        stakes[_msgSender()][symbol][reuseStake].quantity = totalTokens;
        stakes[_msgSender()][symbol][reuseStake].duration = duration;
        stakes[_msgSender()][symbol][reuseStake].maxDuration = token.maxDuration;
        stakes[_msgSender()][symbol][reuseStake].percent = token.maxPercent;
        stakes[_msgSender()][symbol][reuseStake].aValue = token.aValue;
        stakes[_msgSender()][symbol][reuseStake].date = block.timestamp;
        
        emit TokensClaimed(_msgSender(), symbol, totalTokens);
    }

    function getTokenCount(Stake memory stake, bool forced) public view returns (uint256) {

        if(hasVested(stake.date, stake.duration)) {
            return uint256(calculateReturnParams(stake.quantity, int256(stake.duration), stake.maxDuration, stake.percent, stake.aValue));
        }
        else if(forced) {
            return stake.quantity;
        }
        else {
            return 0;
        }
    }

    function withdrawRewardPool(string memory symbol, uint256 quantity) public {
        TokenDetails memory token = tokenContracts[symbol];
        require(token.tokenAddress != address(0x0), "Unknown symbol");
        require(_msgSender() == token.poolAdmin, "You are not pool admin");

        uint256 maxWithdraw = token.rewardPool - token.reservedPool;

        ERC20 erc20 = ERC20(token.tokenAddress);
        require(quantity <= maxWithdraw, "Insufficient reward pool");

        uint256 oldQuantity = token.rewardPool;

        erc20.transfer(_msgSender(), quantity);
        tokenContracts[symbol].rewardPool = tokenContracts[symbol].rewardPool - quantity;

        emit PoolSizeChanged(_msgSender(), symbol, oldQuantity, tokenContracts[symbol].rewardPool);
    }

    function equals(string memory _a, string memory _b) public pure returns (bool) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);

        if(a.length != b.length)
            return false;
        
        for (uint256 i=0; i<a.length; i++) {
            if(a[i] != b[i])
                return false;
        }

        return true;
    }    
}