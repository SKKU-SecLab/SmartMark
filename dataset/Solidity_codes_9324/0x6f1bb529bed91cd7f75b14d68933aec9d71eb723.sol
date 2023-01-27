pragma solidity 0.8.6;

interface IAnalyticMath {

    function pow(
        uint256 a,
        uint256 b,
        uint256 c,
        uint256 d
    ) external view returns (uint256, uint256);


    function caculateIntPowerSum(uint256 power, uint256 n)
        external
        pure
        returns (uint256);

}// SEE LICENSE IN LICENSE
pragma solidity 0.8.6;

uint256 constant MAX_VAL = type(uint256).max;

function safeAdd(uint256 x, uint256 y) pure returns (uint256) {
    return x + y;
}

function unsafeAdd(uint256 x, uint256 y) pure returns (uint256) { unchecked {
    return x + y;
}}

function unsafeSub(uint256 x, uint256 y) pure returns (uint256) { unchecked {
    return x - y;
}}

function unsafeMul(uint256 x, uint256 y) pure returns (uint256) { unchecked {
    return x * y;
}}

function mulModMax(uint256 x, uint256 y) pure returns (uint256) { unchecked {
    return mulmod(x, y, MAX_VAL);
}}

function mulMod(uint256 x, uint256 y, uint256 z) pure returns (uint256) { unchecked {
    return mulmod(x, y, z);
}}// SEE LICENSE IN LICENSE
pragma solidity 0.8.6;


library IntegralMath {

    function floorLog2(uint256 n) internal pure returns (uint8) { unchecked {

        uint8 res = 0;

        if (n < 256) {
            while (n > 1) {
                n >>= 1;
                res += 1;
            }
        }
        else {
            for (uint8 s = 128; s > 0; s >>= 1) {
                if (n >= 1 << s) {
                    n >>= s;
                    res |= s;
                }
            }
        }

        return res;
    }}

    function floorSqrt(uint256 n) internal pure returns (uint256) { unchecked {

        if (n > 0) {
            uint256 x = n / 2 + 1;
            uint256 y = (x + n / x) / 2;
            while (x > y) {
                x = y;
                y = (x + n / x) / 2;
            }
            return x;
        }
        return 0;
    }}

    function ceilSqrt(uint256 n) internal pure returns (uint256) { unchecked {

        uint256 x = floorSqrt(n);
        return x ** 2 == n ? x : x + 1;
    }}

    function floorCbrt(uint256 n) internal pure returns (uint256) { unchecked {

        uint256 x = 0;
        for (uint256 y = 1 << 255; y > 0; y >>= 3) {
            x <<= 1;
            uint256 z = 3 * x * (x + 1) + 1;
            if (n / y >= z) {
                n -= y * z;
                x += 1;
            }
        }
        return x;
    }}

    function ceilCbrt(uint256 n) internal pure returns (uint256) { unchecked {

        uint256 x = floorCbrt(n);
        return x ** 3 == n ? x : x + 1;
    }}

    function roundDiv(uint256 n, uint256 d) internal pure returns (uint256) { unchecked {

        return n / d + (n % d) / (d - d / 2);
    }}

    function mulDivF(uint256 x, uint256 y, uint256 z) internal pure returns (uint256) { unchecked {

        (uint256 xyh, uint256 xyl) = mul512(x, y);
        if (xyh == 0) { // `x * y < 2 ^ 256`
            return xyl / z;
        }
        if (xyh < z) { // `x * y / z < 2 ^ 256`
            uint256 m = mulMod(x, y, z);                    // `m = x * y % z`
            (uint256 nh, uint256 nl) = sub512(xyh, xyl, m); // `n = x * y - m` hence `n / z = floor(x * y / z)`
            if (nh == 0) { // `n < 2 ^ 256`
                return nl / z;
            }
            uint256 p = unsafeSub(0, z) & z; // `p` is the largest power of 2 which `z` is divisible by
            uint256 q = div512(nh, nl, p);   // `n` is divisible by `p` because `n` is divisible by `z` and `z` is divisible by `p`
            uint256 r = inv256(z / p);       // `z / p = 1 mod 2` hence `inverse(z / p) = 1 mod 2 ^ 256`
            return unsafeMul(q, r);          // `q * r = (n / p) * inverse(z / p) = n / z`
        }
        revert(); // `x * y / z >= 2 ^ 256`
    }}

    function mulDivC(uint256 x, uint256 y, uint256 z) internal pure returns (uint256) { unchecked {

        uint256 w = mulDivF(x, y, z);
        if (mulMod(x, y, z) > 0)
            return safeAdd(w, 1);
        return w;
    }}

    function mul512(uint256 x, uint256 y) private pure returns (uint256, uint256) { unchecked {

        uint256 p = mulModMax(x, y);
        uint256 q = unsafeMul(x, y);
        if (p >= q)
            return (p - q, q);
        return (unsafeSub(p, q) - 1, q);
    }}

    function sub512(uint256 xh, uint256 xl, uint256 y) private pure returns (uint256, uint256) { unchecked {

        if (xl >= y)
            return (xh, xl - y);
        return (xh - 1, unsafeSub(xl, y));
    }}

    function div512(uint256 xh, uint256 xl, uint256 pow2n) private pure returns (uint256) { unchecked {

        uint256 pow2nInv = unsafeAdd(unsafeSub(0, pow2n) / pow2n, 1); // `1 << (256 - n)`
        return unsafeMul(xh, pow2nInv) | (xl / pow2n); // `(xh << (256 - n)) | (xl >> n)`
    }}

    function inv256(uint256 d) private pure returns (uint256) { unchecked {

        uint256 x = 1;
        for (uint256 i = 0; i < 8; ++i)
            x = unsafeMul(x, unsafeSub(2, unsafeMul(x, d))); // `x = x * (2 - x * d) mod 2 ^ 256`
        return x;
    }}
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}//  MIT
pragma solidity 0.8.6;


contract AnalyticMath is IAnalyticMath {

    using IntegralMath for *;
    using SafeMath for uint256;

    uint8 internal constant MIN_PRECISION = 32;
    uint8 internal constant MAX_PRECISION = 127;

    uint256 internal constant FIXED_1 = 1 << MAX_PRECISION;
    uint256 internal constant FIXED_2 = 2 << MAX_PRECISION;

    uint256 internal constant LN2_NUMERATOR   = 0x3f80fe03f80fe03f80fe03f80fe03f8;
    uint256 internal constant LN2_DENOMINATOR = 0x5b9de1d10bf4103d647b0955897ba80;

    uint256 internal constant OPT_LOG_MAX_VAL = 0x15bf0a8b1457695355fb8ac404e7a79e4;
    uint256 internal constant OPT_EXP_MAX_VAL = 0x800000000000000000000000000000000;

    uint256[MAX_PRECISION + 1] private maxExpArray;

    function init() public virtual {

        initMaxExpArray();
    }

    function pow(uint256 a, uint256 b, uint256 c, uint256 d) public view override returns (uint256, uint256) { unchecked {

        if (a >= b)
            return mulDivExp(mulDivLog(FIXED_1, a, b), c, d);
        (uint256 q, uint256 p) = mulDivExp(mulDivLog(FIXED_1, b, a), c, d);
        return (p, q);
    }}
    
    function caculateIntPowerSum(uint256 power, uint256 n) public pure override returns (uint256) {

        if (n == 0) return 0;
        if (n == 1) return 1;
        if (power == 1) {
            return n.mul(n).add(n).div(2);
        }
        if (power == 2) {
            return (n**3).mul(2).add((n**2).mul(3)).add(n).div(6);
        }
        if (power == 3) {
            return (n**4).add((n**3).mul(2)).add(n**2).div(4);
        }
        if (power == 4) {
            return (n**5).mul(6).add((n**4).mul(15)).add((n**3).mul(10)).sub(n).div(30);
        }
        if (power == 5) {
            return (n**6).mul(2).add((n**5).mul(6)).add((n**4).mul(5)).sub(n**2).div(12);
        }
        if (power == 6) {
            return (n**7).mul(6).add((n**6).mul(21)).add((n**5).mul(21)).sub((n**3).mul(7)).add(n).div(42);
        }
        if (power == 7) {
            return (n**8).mul(3).add((n**7).mul(12)).add((n**6).mul(14)).sub((n**4).mul(7)).add((n**2).mul(2)).div(24);
        }
        if (power == 8) {
            uint256 v = (n**9).mul(10).add((n**8).mul(45)).add((n**7).mul(60));
            return v.sub((n**5).mul(42)).add((n**3).mul(20)).sub(n.mul(3)).div(90);
        }
        if (power == 9) {
            uint256 v =  (n**10).mul(2).add((n**9).mul(10)).add((n**8).mul(15));
            return v.sub((n**6).mul(14)).add((n**4).mul(10)).sub((n**2).mul(3)).div(20);
        }
        if (power == 10) {
            uint256 v = (n**11).mul(6).add((n**10).mul(33)).add((n**9).mul(55)).sub((n**7).mul(66));
            return v.add((n**5).mul(66)).sub((n**3).mul(33)).add(n.mul(5)).div(66);
        }
    }

    function log(uint256 a, uint256 b) internal pure returns (uint256, uint256) { unchecked {

        require(a >= b, "log: a < b");
        return (mulDivLog(FIXED_1, a, b), FIXED_1);
    }}

    function exp(uint256 a, uint256 b) internal view returns (uint256, uint256) { unchecked {

        return mulDivExp(FIXED_1, a, b);
    }}

    function fixedLog(uint256 x) internal pure returns (uint256) { unchecked {

        if (x < OPT_LOG_MAX_VAL) {
            return optimalLog(x);
        }
        else {
            return generalLog(x);
        }
    }}

    function fixedExp(uint256 x) internal view returns (uint256, uint256) { unchecked {

        if (x < OPT_EXP_MAX_VAL) {
            return (optimalExp(x), 1 << MAX_PRECISION);
        }
        else {
            uint8 precision = findPosition(x);
            return (generalExp(x >> (MAX_PRECISION - precision), precision), 1 << precision);
        }
    }}

    function generalLog(uint256 x) internal pure returns (uint256) { unchecked {

        uint256 res = 0;

        if (x >= FIXED_2) {
            uint8 count = IntegralMath.floorLog2(x / FIXED_1);
            x >>= count; // now x < 2
            res = count * FIXED_1;
        }

        if (x > FIXED_1) {
            for (uint8 i = MAX_PRECISION; i > 0; --i) {
                x = (x * x) / FIXED_1; // now 1 < x < 4
                if (x >= FIXED_2) {
                    x >>= 1; // now 1 < x < 2
                    res += 1 << (i - 1);
                }
            }
        }

        return res * LN2_NUMERATOR / LN2_DENOMINATOR;
    }}

    function generalExp(uint256 x, uint8 precision) internal pure returns (uint256) { unchecked {

        uint256 xi = x;
        uint256 res = 0;

        xi = (xi * x) >> precision; res += xi * 0x3442c4e6074a82f1797f72ac0000000; // add x^02 * (33! / 02!)
        xi = (xi * x) >> precision; res += xi * 0x116b96f757c380fb287fd0e40000000; // add x^03 * (33! / 03!)
        xi = (xi * x) >> precision; res += xi * 0x045ae5bdd5f0e03eca1ff4390000000; // add x^04 * (33! / 04!)
        xi = (xi * x) >> precision; res += xi * 0x00defabf91302cd95b9ffda50000000; // add x^05 * (33! / 05!)
        xi = (xi * x) >> precision; res += xi * 0x002529ca9832b22439efff9b8000000; // add x^06 * (33! / 06!)
        xi = (xi * x) >> precision; res += xi * 0x00054f1cf12bd04e516b6da88000000; // add x^07 * (33! / 07!)
        xi = (xi * x) >> precision; res += xi * 0x0000a9e39e257a09ca2d6db51000000; // add x^08 * (33! / 08!)
        xi = (xi * x) >> precision; res += xi * 0x000012e066e7b839fa050c309000000; // add x^09 * (33! / 09!)
        xi = (xi * x) >> precision; res += xi * 0x000001e33d7d926c329a1ad1a800000; // add x^10 * (33! / 10!)
        xi = (xi * x) >> precision; res += xi * 0x0000002bee513bdb4a6b19b5f800000; // add x^11 * (33! / 11!)
        xi = (xi * x) >> precision; res += xi * 0x00000003a9316fa79b88eccf2a00000; // add x^12 * (33! / 12!)
        xi = (xi * x) >> precision; res += xi * 0x0000000048177ebe1fa812375200000; // add x^13 * (33! / 13!)
        xi = (xi * x) >> precision; res += xi * 0x0000000005263fe90242dcbacf00000; // add x^14 * (33! / 14!)
        xi = (xi * x) >> precision; res += xi * 0x000000000057e22099c030d94100000; // add x^15 * (33! / 15!)
        xi = (xi * x) >> precision; res += xi * 0x0000000000057e22099c030d9410000; // add x^16 * (33! / 16!)
        xi = (xi * x) >> precision; res += xi * 0x00000000000052b6b54569976310000; // add x^17 * (33! / 17!)
        xi = (xi * x) >> precision; res += xi * 0x00000000000004985f67696bf748000; // add x^18 * (33! / 18!)
        xi = (xi * x) >> precision; res += xi * 0x000000000000003dea12ea99e498000; // add x^19 * (33! / 19!)
        xi = (xi * x) >> precision; res += xi * 0x00000000000000031880f2214b6e000; // add x^20 * (33! / 20!)
        xi = (xi * x) >> precision; res += xi * 0x000000000000000025bcff56eb36000; // add x^21 * (33! / 21!)
        xi = (xi * x) >> precision; res += xi * 0x000000000000000001b722e10ab1000; // add x^22 * (33! / 22!)
        xi = (xi * x) >> precision; res += xi * 0x0000000000000000001317c70077000; // add x^23 * (33! / 23!)
        xi = (xi * x) >> precision; res += xi * 0x00000000000000000000cba84aafa00; // add x^24 * (33! / 24!)
        xi = (xi * x) >> precision; res += xi * 0x00000000000000000000082573a0a00; // add x^25 * (33! / 25!)
        xi = (xi * x) >> precision; res += xi * 0x00000000000000000000005035ad900; // add x^26 * (33! / 26!)
        xi = (xi * x) >> precision; res += xi * 0x000000000000000000000002f881b00; // add x^27 * (33! / 27!)
        xi = (xi * x) >> precision; res += xi * 0x0000000000000000000000001b29340; // add x^28 * (33! / 28!)
        xi = (xi * x) >> precision; res += xi * 0x00000000000000000000000000efc40; // add x^29 * (33! / 29!)
        xi = (xi * x) >> precision; res += xi * 0x0000000000000000000000000007fe0; // add x^30 * (33! / 30!)
        xi = (xi * x) >> precision; res += xi * 0x0000000000000000000000000000420; // add x^31 * (33! / 31!)
        xi = (xi * x) >> precision; res += xi * 0x0000000000000000000000000000021; // add x^32 * (33! / 32!)
        xi = (xi * x) >> precision; res += xi * 0x0000000000000000000000000000001; // add x^33 * (33! / 33!)

        return res / 0x688589cc0e9505e2f2fee5580000000 + x + (1 << precision); // divide by 33! and then add x^1 / 1! + x^0 / 0!
    }}

    function optimalLog(uint256 x) internal pure returns (uint256) { unchecked {

        uint256 res = 0;

        uint256 y;
        uint256 z;
        uint256 w;

        if (x >= 0xd3094c70f034de4b96ff7d5b6f99fcd9) {res += 0x40000000000000000000000000000000; x = x * FIXED_1 / 0xd3094c70f034de4b96ff7d5b6f99fcd9;} // add 1 / 2^1
        if (x >= 0xa45af1e1f40c333b3de1db4dd55f29a8) {res += 0x20000000000000000000000000000000; x = x * FIXED_1 / 0xa45af1e1f40c333b3de1db4dd55f29a8;} // add 1 / 2^2
        if (x >= 0x910b022db7ae67ce76b441c27035c6a2) {res += 0x10000000000000000000000000000000; x = x * FIXED_1 / 0x910b022db7ae67ce76b441c27035c6a2;} // add 1 / 2^3
        if (x >= 0x88415abbe9a76bead8d00cf112e4d4a9) {res += 0x08000000000000000000000000000000; x = x * FIXED_1 / 0x88415abbe9a76bead8d00cf112e4d4a9;} // add 1 / 2^4
        if (x >= 0x84102b00893f64c705e841d5d4064bd4) {res += 0x04000000000000000000000000000000; x = x * FIXED_1 / 0x84102b00893f64c705e841d5d4064bd4;} // add 1 / 2^5
        if (x >= 0x8204055aaef1c8bd5c3259f4822735a3) {res += 0x02000000000000000000000000000000; x = x * FIXED_1 / 0x8204055aaef1c8bd5c3259f4822735a3;} // add 1 / 2^6
        if (x >= 0x810100ab00222d861931c15e39b44e9a) {res += 0x01000000000000000000000000000000; x = x * FIXED_1 / 0x810100ab00222d861931c15e39b44e9a;} // add 1 / 2^7
        if (x >= 0x808040155aabbbe9451521693554f734) {res += 0x00800000000000000000000000000000; x = x * FIXED_1 / 0x808040155aabbbe9451521693554f734;} // add 1 / 2^8

        z = y = x - FIXED_1;
        w = y * y / FIXED_1;
        res += z * (0x100000000000000000000000000000000 - y) / 0x100000000000000000000000000000000; z = z * w / FIXED_1; // add y^01 / 01 - y^02 / 02
        res += z * (0x0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa - y) / 0x200000000000000000000000000000000; z = z * w / FIXED_1; // add y^03 / 03 - y^04 / 04
        res += z * (0x099999999999999999999999999999999 - y) / 0x300000000000000000000000000000000; z = z * w / FIXED_1; // add y^05 / 05 - y^06 / 06
        res += z * (0x092492492492492492492492492492492 - y) / 0x400000000000000000000000000000000; z = z * w / FIXED_1; // add y^07 / 07 - y^08 / 08
        res += z * (0x08e38e38e38e38e38e38e38e38e38e38e - y) / 0x500000000000000000000000000000000; z = z * w / FIXED_1; // add y^09 / 09 - y^10 / 10
        res += z * (0x08ba2e8ba2e8ba2e8ba2e8ba2e8ba2e8b - y) / 0x600000000000000000000000000000000; z = z * w / FIXED_1; // add y^11 / 11 - y^12 / 12
        res += z * (0x089d89d89d89d89d89d89d89d89d89d89 - y) / 0x700000000000000000000000000000000; z = z * w / FIXED_1; // add y^13 / 13 - y^14 / 14
        res += z * (0x088888888888888888888888888888888 - y) / 0x800000000000000000000000000000000;                      // add y^15 / 15 - y^16 / 16

        return res;
    }}

    function optimalExp(uint256 x) internal pure returns (uint256) { unchecked {

        uint256 res = 0;

        uint256 y;
        uint256 z;

        z = y = x % 0x10000000000000000000000000000000; // get the input modulo 2^(-3)
        z = z * y / FIXED_1; res += z * 0x10e1b3be415a0000; // add y^02 * (20! / 02!)
        z = z * y / FIXED_1; res += z * 0x05a0913f6b1e0000; // add y^03 * (20! / 03!)
        z = z * y / FIXED_1; res += z * 0x0168244fdac78000; // add y^04 * (20! / 04!)
        z = z * y / FIXED_1; res += z * 0x004807432bc18000; // add y^05 * (20! / 05!)
        z = z * y / FIXED_1; res += z * 0x000c0135dca04000; // add y^06 * (20! / 06!)
        z = z * y / FIXED_1; res += z * 0x0001b707b1cdc000; // add y^07 * (20! / 07!)
        z = z * y / FIXED_1; res += z * 0x000036e0f639b800; // add y^08 * (20! / 08!)
        z = z * y / FIXED_1; res += z * 0x00000618fee9f800; // add y^09 * (20! / 09!)
        z = z * y / FIXED_1; res += z * 0x0000009c197dcc00; // add y^10 * (20! / 10!)
        z = z * y / FIXED_1; res += z * 0x0000000e30dce400; // add y^11 * (20! / 11!)
        z = z * y / FIXED_1; res += z * 0x000000012ebd1300; // add y^12 * (20! / 12!)
        z = z * y / FIXED_1; res += z * 0x0000000017499f00; // add y^13 * (20! / 13!)
        z = z * y / FIXED_1; res += z * 0x0000000001a9d480; // add y^14 * (20! / 14!)
        z = z * y / FIXED_1; res += z * 0x00000000001c6380; // add y^15 * (20! / 15!)
        z = z * y / FIXED_1; res += z * 0x000000000001c638; // add y^16 * (20! / 16!)
        z = z * y / FIXED_1; res += z * 0x0000000000001ab8; // add y^17 * (20! / 17!)
        z = z * y / FIXED_1; res += z * 0x000000000000017c; // add y^18 * (20! / 18!)
        z = z * y / FIXED_1; res += z * 0x0000000000000014; // add y^19 * (20! / 19!)
        z = z * y / FIXED_1; res += z * 0x0000000000000001; // add y^20 * (20! / 20!)
        res = res / 0x21c3677c82b40000 + y + FIXED_1; // divide by 20! and then add y^1 / 1! + y^0 / 0!

        if ((x & 0x010000000000000000000000000000000) != 0) res = res * 0x1c3d6a24ed82218787d624d3e5eba95f9 / 0x18ebef9eac820ae8682b9793ac6d1e776; // multiply by e^2^(-3)
        if ((x & 0x020000000000000000000000000000000) != 0) res = res * 0x18ebef9eac820ae8682b9793ac6d1e778 / 0x1368b2fc6f9609fe7aceb46aa619baed4; // multiply by e^2^(-2)
        if ((x & 0x040000000000000000000000000000000) != 0) res = res * 0x1368b2fc6f9609fe7aceb46aa619baed5 / 0x0bc5ab1b16779be3575bd8f0520a9f21f; // multiply by e^2^(-1)
        if ((x & 0x080000000000000000000000000000000) != 0) res = res * 0x0bc5ab1b16779be3575bd8f0520a9f21e / 0x0454aaa8efe072e7f6ddbab84b40a55c9; // multiply by e^2^(+0)
        if ((x & 0x100000000000000000000000000000000) != 0) res = res * 0x0454aaa8efe072e7f6ddbab84b40a55c5 / 0x00960aadc109e7a3bf4578099615711ea; // multiply by e^2^(+1)
        if ((x & 0x200000000000000000000000000000000) != 0) res = res * 0x00960aadc109e7a3bf4578099615711d7 / 0x0002bf84208204f5977f9a8cf01fdce3d; // multiply by e^2^(+2)
        if ((x & 0x400000000000000000000000000000000) != 0) res = res * 0x0002bf84208204f5977f9a8cf01fdc307 / 0x0000003c6ab775dd0b95b4cbee7e65d11; // multiply by e^2^(+3)

        return res;
    }}

    function findPosition(uint256 x) internal view returns (uint8) { unchecked {

        uint8 lo = MIN_PRECISION;
        uint8 hi = MAX_PRECISION;

        while (lo + 1 < hi) {
            uint8 mid = (lo + hi) / 2;
            if (maxExpArray[mid] >= x)
                lo = mid;
            else
                hi = mid;
        }

        if (maxExpArray[hi] >= x)
            return hi;
        if (maxExpArray[lo] >= x)
            return lo;

        revert("findPosition: x > max");
    }}

    function initMaxExpArray() internal {

        maxExpArray[ 32] = 0x1c35fedd14ffffffffffffffffffffffff;
        maxExpArray[ 33] = 0x1b0ce43b323fffffffffffffffffffffff;
        maxExpArray[ 34] = 0x19f0028ec1ffffffffffffffffffffffff;
        maxExpArray[ 35] = 0x18ded91f0e7fffffffffffffffffffffff;
        maxExpArray[ 36] = 0x17d8ec7f0417ffffffffffffffffffffff;
        maxExpArray[ 37] = 0x16ddc6556cdbffffffffffffffffffffff;
        maxExpArray[ 38] = 0x15ecf52776a1ffffffffffffffffffffff;
        maxExpArray[ 39] = 0x15060c256cb2ffffffffffffffffffffff;
        maxExpArray[ 40] = 0x1428a2f98d72ffffffffffffffffffffff;
        maxExpArray[ 41] = 0x13545598e5c23fffffffffffffffffffff;
        maxExpArray[ 42] = 0x1288c4161ce1dfffffffffffffffffffff;
        maxExpArray[ 43] = 0x11c592761c666fffffffffffffffffffff;
        maxExpArray[ 44] = 0x110a688680a757ffffffffffffffffffff;
        maxExpArray[ 45] = 0x1056f1b5bedf77ffffffffffffffffffff;
        maxExpArray[ 46] = 0x0faadceceeff8bffffffffffffffffffff;
        maxExpArray[ 47] = 0x0f05dc6b27edadffffffffffffffffffff;
        maxExpArray[ 48] = 0x0e67a5a25da4107fffffffffffffffffff;
        maxExpArray[ 49] = 0x0dcff115b14eedffffffffffffffffffff;
        maxExpArray[ 50] = 0x0d3e7a392431239fffffffffffffffffff;
        maxExpArray[ 51] = 0x0cb2ff529eb71e4fffffffffffffffffff;
        maxExpArray[ 52] = 0x0c2d415c3db974afffffffffffffffffff;
        maxExpArray[ 53] = 0x0bad03e7d883f69bffffffffffffffffff;
        maxExpArray[ 54] = 0x0b320d03b2c343d5ffffffffffffffffff;
        maxExpArray[ 55] = 0x0abc25204e02828dffffffffffffffffff;
        maxExpArray[ 56] = 0x0a4b16f74ee4bb207fffffffffffffffff;
        maxExpArray[ 57] = 0x09deaf736ac1f569ffffffffffffffffff;
        maxExpArray[ 58] = 0x0976bd9952c7aa957fffffffffffffffff;
        maxExpArray[ 59] = 0x09131271922eaa606fffffffffffffffff;
        maxExpArray[ 60] = 0x08b380f3558668c46fffffffffffffffff;
        maxExpArray[ 61] = 0x0857ddf0117efa215bffffffffffffffff;
        maxExpArray[ 62] = 0x07ffffffffffffffffffffffffffffffff;
        maxExpArray[ 63] = 0x07abbf6f6abb9d087fffffffffffffffff;
        maxExpArray[ 64] = 0x075af62cbac95f7dfa7fffffffffffffff;
        maxExpArray[ 65] = 0x070d7fb7452e187ac13fffffffffffffff;
        maxExpArray[ 66] = 0x06c3390ecc8af379295fffffffffffffff;
        maxExpArray[ 67] = 0x067c00a3b07ffc01fd6fffffffffffffff;
        maxExpArray[ 68] = 0x0637b647c39cbb9d3d27ffffffffffffff;
        maxExpArray[ 69] = 0x05f63b1fc104dbd39587ffffffffffffff;
        maxExpArray[ 70] = 0x05b771955b36e12f7235ffffffffffffff;
        maxExpArray[ 71] = 0x057b3d49dda84556d6f6ffffffffffffff;
        maxExpArray[ 72] = 0x054183095b2c8ececf30ffffffffffffff;
        maxExpArray[ 73] = 0x050a28be635ca2b888f77fffffffffffff;
        maxExpArray[ 74] = 0x04d5156639708c9db33c3fffffffffffff;
        maxExpArray[ 75] = 0x04a23105873875bd52dfdfffffffffffff;
        maxExpArray[ 76] = 0x0471649d87199aa990756fffffffffffff;
        maxExpArray[ 77] = 0x04429a21a029d4c1457cfbffffffffffff;
        maxExpArray[ 78] = 0x0415bc6d6fb7dd71af2cb3ffffffffffff;
        maxExpArray[ 79] = 0x03eab73b3bbfe282243ce1ffffffffffff;
        maxExpArray[ 80] = 0x03c1771ac9fb6b4c18e229ffffffffffff;
        maxExpArray[ 81] = 0x0399e96897690418f785257fffffffffff;
        maxExpArray[ 82] = 0x0373fc456c53bb779bf0ea9fffffffffff;
        maxExpArray[ 83] = 0x034f9e8e490c48e67e6ab8bfffffffffff;
        maxExpArray[ 84] = 0x032cbfd4a7adc790560b3337ffffffffff;
        maxExpArray[ 85] = 0x030b50570f6e5d2acca94613ffffffffff;
        maxExpArray[ 86] = 0x02eb40f9f620fda6b56c2861ffffffffff;
        maxExpArray[ 87] = 0x02cc8340ecb0d0f520a6af58ffffffffff;
        maxExpArray[ 88] = 0x02af09481380a0a35cf1ba02ffffffffff;
        maxExpArray[ 89] = 0x0292c5bdd3b92ec810287b1b3fffffffff;
        maxExpArray[ 90] = 0x0277abdcdab07d5a77ac6d6b9fffffffff;
        maxExpArray[ 91] = 0x025daf6654b1eaa55fd64df5efffffffff;
        maxExpArray[ 92] = 0x0244c49c648baa98192dce88b7ffffffff;
        maxExpArray[ 93] = 0x022ce03cd5619a311b2471268bffffffff;
        maxExpArray[ 94] = 0x0215f77c045fbe885654a44a0fffffffff;
        maxExpArray[ 95] = 0x01ffffffffffffffffffffffffffffffff;
        maxExpArray[ 96] = 0x01eaefdbdaaee7421fc4d3ede5ffffffff;
        maxExpArray[ 97] = 0x01d6bd8b2eb257df7e8ca57b09bfffffff;
        maxExpArray[ 98] = 0x01c35fedd14b861eb0443f7f133fffffff;
        maxExpArray[ 99] = 0x01b0ce43b322bcde4a56e8ada5afffffff;
        maxExpArray[100] = 0x019f0028ec1fff007f5a195a39dfffffff;
        maxExpArray[101] = 0x018ded91f0e72ee74f49b15ba527ffffff;
        maxExpArray[102] = 0x017d8ec7f04136f4e5615fd41a63ffffff;
        maxExpArray[103] = 0x016ddc6556cdb84bdc8d12d22e6fffffff;
        maxExpArray[104] = 0x015ecf52776a1155b5bd8395814f7fffff;
        maxExpArray[105] = 0x015060c256cb23b3b3cc3754cf40ffffff;
        maxExpArray[106] = 0x01428a2f98d728ae223ddab715be3fffff;
        maxExpArray[107] = 0x013545598e5c23276ccf0ede68034fffff;
        maxExpArray[108] = 0x01288c4161ce1d6f54b7f61081194fffff;
        maxExpArray[109] = 0x011c592761c666aa641d5a01a40f17ffff;
        maxExpArray[110] = 0x0110a688680a7530515f3e6e6cfdcdffff;
        maxExpArray[111] = 0x01056f1b5bedf75c6bcb2ce8aed428ffff;
        maxExpArray[112] = 0x00faadceceeff8a0890f3875f008277fff;
        maxExpArray[113] = 0x00f05dc6b27edad306388a600f6ba0bfff;
        maxExpArray[114] = 0x00e67a5a25da41063de1495d5b18cdbfff;
        maxExpArray[115] = 0x00dcff115b14eedde6fc3aa5353f2e4fff;
        maxExpArray[116] = 0x00d3e7a3924312399f9aae2e0f868f8fff;
        maxExpArray[117] = 0x00cb2ff529eb71e41582cccd5a1ee26fff;
        maxExpArray[118] = 0x00c2d415c3db974ab32a51840c0b67edff;
        maxExpArray[119] = 0x00bad03e7d883f69ad5b0a186184e06bff;
        maxExpArray[120] = 0x00b320d03b2c343d4829abd6075f0cc5ff;
        maxExpArray[121] = 0x00abc25204e02828d73c6e80bcdb1a95bf;
        maxExpArray[122] = 0x00a4b16f74ee4bb2040a1ec6c15fbbf2df;
        maxExpArray[123] = 0x009deaf736ac1f569deb1b5ae3f36c130f;
        maxExpArray[124] = 0x00976bd9952c7aa957f5937d790ef65037;
        maxExpArray[125] = 0x009131271922eaa6064b73a22d0bd4f2bf;
        maxExpArray[126] = 0x008b380f3558668c46c91c49a2f8e967b9;
        maxExpArray[127] = 0x00857ddf0117efa215952912839f6473e6;
    }

    function mulDivLog(uint256 x, uint256 y, uint256 z) private pure returns (uint256) {

        return fixedLog(IntegralMath.mulDivF(x, y, z));
    }

    function mulDivExp(uint256 x, uint256 y, uint256 z) private view returns (uint256, uint256) {

        return fixedExp(IntegralMath.mulDivF(x, y, z));
    }
}