
pragma solidity ^0.4.15;


library Math {


    enum EstimationMode { LowerBound, UpperBound, Midpoint }

    uint public constant ONE =  0x10000000000000000;
    uint public constant LN2 = 0xb17217f7d1cf79ac;
    uint public constant LOG2_E = 0x171547652b82fe177;

    function exp(int x)
        public
        constant
        returns (uint)
    {

        require(x <= 2454971259878909886679);
        if (x <= -818323753292969962227)
            return 0;

        var (lower, upper) = pow2Bounds(x * int(ONE) / int(LN2));
        return (upper - lower) / 2 + lower;
    }

    function pow2(int x, EstimationMode estimationMode)
        public
        constant
        returns (uint)
    {

        var (lower, upper) = pow2Bounds(x);
        if(estimationMode == EstimationMode.LowerBound) {
            return lower;
        }
        if(estimationMode == EstimationMode.UpperBound) {
            return upper;
        }
        if(estimationMode == EstimationMode.Midpoint) {
            return (upper - lower) / 2 + lower;
        }
        revert();
    }

    function pow2Bounds(int x)
        public
        constant
        returns (uint lower, uint upper)
    {

        require(x <= 3541774862152233910271);
        if (x < -1180591620717411303424)
            return (0, 1);

        int shift;
        int z;
        if (x >= 0) {
            shift = x / int(ONE);
            z = x % int(ONE);
        }
        else {
            shift = (x+1) / int(ONE) - 1;
            z = x - (int(ONE) * shift);
        }
        assert(z >= 0);
        int result = int(ONE) << 64;
        int zpow = z;
        result += 0xb17217f7d1cf79ab * zpow;
        zpow = zpow * z / int(ONE);
        result += 0xf5fdeffc162c7543 * zpow >> (66 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xe35846b82505fc59 * zpow >> (68 - 64);
        zpow = zpow * z / int(ONE);
        result += 0x9d955b7dd273b94e * zpow >> (70 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xaec3ff3c53398883 * zpow >> (73 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xa184897c363c3b7a * zpow >> (76 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xffe5fe2c45863435 * zpow >> (80 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xb160111d2e411fec * zpow >> (83 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xda929e9caf3e1ed2 * zpow >> (87 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xf267a8ac5c764fb7 * zpow >> (91 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xf465639a8dd92607 * zpow >> (95 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xe1deb287e14c2f15 * zpow >> (99 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xc0b0c98b3687cb14 * zpow >> (103 - 64);
        zpow = zpow * z / int(ONE);
        result += 0x98a4b26ac3c54b9f * zpow >> (107 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xe1b7421d82010f33 * zpow >> (112 - 64);
        zpow = zpow * z / int(ONE);
        result += 0x9c744d73cfc59c91 * zpow >> (116 - 64);
        zpow = zpow * z / int(ONE);
        result += 0xcc2225a0e12d3eab * zpow >> (121 - 64);
        zpow = zpow * z / int(ONE);
        zpow = 0xfb8bb5eda1b4aeb9 * zpow >> (126 - 64);
        result += zpow;
        zpow = int(8 * ONE);

        shift -= 64;
        if (shift >= 0) {
            if (result >> (256-shift) == 0) {
                lower = uint(result) << shift;
                zpow <<= shift; // todo: is this safe?
                if (safeToAdd(lower, uint(zpow)))
                    upper = lower + uint(zpow);
                else
                    upper = 2**256-1;
                return;
            }
            else
                return (2**256-1, 2**256-1);
        }
        zpow = (zpow >> (-shift)) + 1;
        lower = uint(result) >> (-shift);
        upper = lower + uint(zpow);
        return;
    }

    function ln(uint x)
        public
        constant
        returns (int)
    {

        var (lower, upper) = log2Bounds(x);
        return ((upper - lower) / 2 + lower) * int(ONE) / int(LOG2_E);
    }

    function log2(uint x, EstimationMode estimationMode)
        public
        constant
        returns (int)
    {

        var (lower, upper) = log2Bounds(x);
        if(estimationMode == EstimationMode.LowerBound) {
            return lower;
        }
        if(estimationMode == EstimationMode.UpperBound) {
            return upper;
        }
        if(estimationMode == EstimationMode.Midpoint) {
            return (upper - lower) / 2 + lower;
        }
        revert();
    }

    function log2Bounds(uint x)
        public
        constant
        returns (int lower, int upper)
    {

        require(x > 0);
        lower = floorLog2(x);

        uint y;
        if (lower < 0)
            y = x << uint(-lower);
        else
            y = x >> uint(lower);

        lower *= int(ONE);

        for (int m = 1; m <= 64; m++) {
            if(y == ONE) {
                break;
            }
            y = y * y / ONE;
            if(y >= 2 * ONE) {
                lower += int(ONE >> m);
                y /= 2;
            }
        }

        return (lower, lower + 4);
    }

    function floorLog2(uint x)
        public
        constant
        returns (int lo)
    {

        lo = -64;
        int hi = 193;
        int mid = (hi + lo) >> 1;
        while((lo + 1) < hi) {
            if (mid < 0 && x << uint(-mid) < ONE || mid >= 0 && x >> uint(mid) < ONE)
                hi = mid;
            else
                lo = mid;
            mid = (hi + lo) >> 1;
        }
    }

    function max(int[] nums)
        public
        constant
        returns (int max)
    {

        require(nums.length > 0);
        max = -2**255;
        for (uint i = 0; i < nums.length; i++)
            if (nums[i] > max)
                max = nums[i];
    }

    function safeToAdd(uint a, uint b)
        public
        constant
        returns (bool)
    {

        return a + b >= a;
    }

    function safeToSub(uint a, uint b)
        public
        constant
        returns (bool)
    {

        return a >= b;
    }

    function safeToMul(uint a, uint b)
        public
        constant
        returns (bool)
    {

        return b == 0 || a * b / b == a;
    }

    function add(uint a, uint b)
        public
        constant
        returns (uint)
    {

        require(safeToAdd(a, b));
        return a + b;
    }

    function sub(uint a, uint b)
        public
        constant
        returns (uint)
    {

        require(safeToSub(a, b));
        return a - b;
    }

    function mul(uint a, uint b)
        public
        constant
        returns (uint)
    {

        require(safeToMul(a, b));
        return a * b;
    }

    function safeToAdd(int a, int b)
        public
        constant
        returns (bool)
    {

        return (b >= 0 && a + b >= a) || (b < 0 && a + b < a);
    }

    function safeToSub(int a, int b)
        public
        constant
        returns (bool)
    {

        return (b >= 0 && a - b <= a) || (b < 0 && a - b > a);
    }

    function safeToMul(int a, int b)
        public
        constant
        returns (bool)
    {

        return (b == 0) || (a * b / b == a);
    }

    function add(int a, int b)
        public
        constant
        returns (int)
    {

        require(safeToAdd(a, b));
        return a + b;
    }

    function sub(int a, int b)
        public
        constant
        returns (int)
    {

        require(safeToSub(a, b));
        return a - b;
    }

    function mul(int a, int b)
        public
        constant
        returns (int)
    {

        require(safeToMul(a, b));
        return a * b;
    }
}