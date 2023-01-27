

pragma solidity ^0.6.10;


library RealMath {

    
    int256 constant REAL_BITS = 128;
    
    int256 constant REAL_FBITS = 40;
    
    int256 constant REAL_IBITS = REAL_BITS - REAL_FBITS;
    
    int128 constant REAL_ONE = int128(1) << int128(REAL_FBITS);
    
    int128 constant REAL_HALF = REAL_ONE >> int128(1);
    
    int128 constant REAL_TWO = REAL_ONE << int128(1);
    
    int128 constant REAL_LN_TWO = 762123384786;
    
    int128 constant REAL_PI = 3454217652358;
    
    int128 constant REAL_HALF_PI = 1727108826179;
    
    int128 constant REAL_TWO_PI = 6908435304715;
    
    int128 constant SIGN_MASK = int128(1) << int128(127);
    

    function toReal(int88 ipart) public pure returns (int128) {

        return int128(ipart) * REAL_ONE;
    }
    
    function fromReal(int128 real_value) public pure returns (int88) {

        return int88(real_value / REAL_ONE);
    }
    
    function round(int128 real_value) public pure returns (int128) {

        int88 ipart = fromReal(real_value);
        if ((fractionalBits(real_value) & (uint40(1) << uint40(REAL_FBITS - 1))) > 0) {
            if (real_value < int128(0)) {
                ipart -= 1;
            } else {
                ipart += 1;
            }
        }
        return toReal(ipart);
    }
    
    function abs(int128 real_value) public pure returns (int128) {

        if (real_value > 0) {
            return real_value;
        } else {
            return -real_value;
        }
    }
    
    function fractionalBits(int128 real_value) public pure returns (uint40) {

        return uint40(abs(real_value) % REAL_ONE);
    }
    
    function fpart(int128 real_value) public pure returns (int128) {

        return abs(real_value) % REAL_ONE;
    }

    function fpartSigned(int128 real_value) public pure returns (int128) {

        int128 fractional = fpart(real_value);
        if (real_value < 0) {
            return -fractional;
        } else {
            return fractional;
        }
    }
    
    function ipart(int128 real_value) public pure returns (int128) {

        return real_value - fpartSigned(real_value);
    }
    
    function mul(int128 real_a, int128 real_b) public pure returns (int128) {

        return int128((int256(real_a) * int256(real_b)) >> REAL_FBITS);
    }
    
    function div(int128 real_numerator, int128 real_denominator) public pure returns (int128) {

        return int128((int256(real_numerator) * REAL_ONE) / int256(real_denominator));
    }
    
    function fraction(int88 numerator, int88 denominator) public pure returns (int128) {

        return div(toReal(numerator), toReal(denominator));
    }
    
    
    function ipow(int128 real_base, int88 exponent) public pure returns (int128) {

        if (exponent < 0) {
            revert();
        }
        
        int128 real_result = REAL_ONE;
        while (exponent != 0) {
            if ((exponent & 0x1) == 0x1) {
                real_result = mul(real_result, real_base);
            }
            exponent = exponent >> 1;
            real_base = mul(real_base, real_base);
        }
        
        return real_result;
    }
    
    function hibit(uint256 val) internal pure returns (uint256) {

        val |= (val >>  1);
        val |= (val >>  2);
        val |= (val >>  4);
        val |= (val >>  8);
        val |= (val >> 16);
        val |= (val >> 32);
        val |= (val >> 64);
        val |= (val >> 128);
        return val ^ (val >> 1);
    }
    
    function findbit(uint256 val) internal pure returns (uint8 index) {

        index = 0;
        
        if (val & 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA != 0) {
            index |= 1;
        }
        if (val & 0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC != 0) {
            index |= 2;
        }
        if (val & 0xF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0 != 0) {
            index |= 4;
        }
        if (val & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00 != 0) {
            index |= 8;
        }
        if (val & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000 != 0) {
            index |= 16;
        }
        if (val & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000 != 0) {
            index |= 32;
        }
        if (val & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000 != 0) {
            index |= 64;
        }
        if (val & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000 != 0) {
            index |= 128;
        }
    }
    
    function rescale(int128 real_arg) internal pure returns (int128 real_scaled, int88 shift) {

        if (real_arg <= 0) {
            revert();
        }
        
        int88 high_bit = findbit(hibit(uint256(real_arg)));
        
        shift = high_bit - int88(REAL_FBITS);
        
        if (shift < 0) {
            real_scaled = real_arg << int128(-shift);
        } else if (shift >= 0) {
            real_scaled = real_arg >> int128(shift);
        }
    }
    
    function lnLimited(int128 real_arg, int max_iterations) public pure returns (int128) {

        if (real_arg <= 0) {
            revert();
        }
        
        if (real_arg == REAL_ONE) {
            return 0;
        }
        
        int128 real_rescaled;
        int88 shift;
        (real_rescaled, shift) = rescale(real_arg);
        
        int128 real_series_arg = div(real_rescaled - REAL_ONE, real_rescaled + REAL_ONE);
        
        int128 real_series_result = 0;
        
        for (int88 n = 0; n < max_iterations; n++) {
            int128 real_term = div(ipow(real_series_arg, 2 * n + 1), toReal(2 * n + 1));
            real_series_result += real_term;
            if (real_term == 0) {
                break;
            }
        }
        
        real_series_result = mul(real_series_result, REAL_TWO);
        
        return mul(toReal(shift), REAL_LN_TWO) + real_series_result;
        
    }
    
    function ln(int128 real_arg) public pure returns (int128) {

        return lnLimited(real_arg, 100);
    }
    
    function expLimited(int128 real_arg, int max_iterations) public pure returns (int128) {

        int128 real_result = 0;
        
        int128 real_term = REAL_ONE;
        
        for (int88 n = 0; n < max_iterations; n++) {
            real_result += real_term;
            
            real_term = mul(real_term, div(real_arg, toReal(n + 1)));
            
            if (real_term == 0) {
                break;
            }
        }
        
        return real_result;
        
    }
    
    function exp(int128 real_arg) public pure returns (int128) {

        return expLimited(real_arg, 100);
    }
    
    function pow(int128 real_base, int128 real_exponent) public pure returns (int128) {

        if (real_exponent == 0) {
            return REAL_ONE;
        }
        
        if (real_base == 0) {
            if (real_exponent < 0) {
                revert();
            }
            return 0;
        }
        
        if (fpart(real_exponent) == 0) {
            
            if (real_exponent > 0) {
                return ipow(real_base, fromReal(real_exponent));
            } else {
                return div(REAL_ONE, ipow(real_base, fromReal(-real_exponent)));
            }
        }
        
        if (real_base < 0) {
            revert();
        }
        
        return exp(mul(real_exponent, ln(real_base)));
    }
    
    function sqrt(int128 real_arg) public pure returns (int128) {

        return pow(real_arg, REAL_HALF);
    }
    
    function sinLimited(int128 real_arg, int88 max_iterations) public pure returns (int128) {

        real_arg = real_arg % REAL_TWO_PI;
        
        int128 accumulator = REAL_ONE;
        
        for (int88 iteration = max_iterations - 1; iteration >= 0; iteration--) {
            accumulator = REAL_ONE - mul(div(mul(real_arg, real_arg), toReal((2 * iteration + 2) * (2 * iteration + 3))), accumulator);
        }
        
        return mul(real_arg, accumulator);
    }
    
    function sin(int128 real_arg) public pure returns (int128) {

        return sinLimited(real_arg, 15);
    }
    
    function cos(int128 real_arg) public pure returns (int128) {

        return sin(real_arg + REAL_HALF_PI);
    }
    
    function tan(int128 real_arg) public pure returns (int128) {

        return div(sin(real_arg), cos(real_arg));
    }
    
    function atanSmall(int128 real_arg) public pure returns (int128) {

        int128 real_arg_squared = mul(real_arg, real_arg);
        return mul(mul(mul(mul(mul(mul(
            - 12606780422,  real_arg_squared) // x^11
            + 57120178819,  real_arg_squared) // x^9
            - 127245381171, real_arg_squared) // x^7
            + 212464129393, real_arg_squared) // x^5
            - 365662383026, real_arg_squared) // x^3
            + 1099483040474, real_arg);       // x^1
    }
    
    function atan2(int128 real_y, int128 real_x) public pure returns (int128) {

        int128 atan_result;
        
        
        int128 real_abs_x = abs(real_x);
        int128 real_abs_y = abs(real_y);
        
        if (real_abs_x > real_abs_y) {
            atan_result = atanSmall(div(real_abs_y, real_abs_x));
        } else {
            atan_result = REAL_HALF_PI - atanSmall(div(real_abs_x, real_abs_y));
        }
        
        if (real_x < 0) {
            if (real_y < 0) {
                atan_result -= REAL_PI;
            } else {
                atan_result = REAL_PI - atan_result;
            }
        } else {
            if (real_y < 0) {
                atan_result = -atan_result;
            }
        }
        
        return atan_result;
    }
}


library RNG {

    using RealMath for *;

    struct RandNode {
        bytes32 _hash;
    }
    
    
    
    function derive(RandNode memory self, string memory entropy) internal pure returns (RandNode memory) {

        return RandNode(sha256(abi.encodePacked(self._hash, entropy)));
    }
    
    function derive(RandNode memory self, int256 entropy) internal pure returns (RandNode memory) {

        return RandNode(sha256(abi.encodePacked(self._hash, entropy)));
    }
    
    function derive(RandNode memory self, uint256 entropy) internal pure returns (RandNode memory) {

        return RandNode(sha256(abi.encodePacked(self._hash, entropy)));
    }

    function getHash(RandNode memory self) internal pure returns (bytes32) {

        return sha256(abi.encodePacked(self._hash));
    }
    
    function getBool(RandNode memory self) internal pure returns (bool) {

        return uint256(getHash(self)) & 0x1 > 0;
    }
    
    function getInt128(RandNode memory self) internal pure returns (int128) {

        return int128(int256(getHash(self)));
    }
    
    function getReal(RandNode memory self) internal pure returns (int128) {

        return getInt128(self).fpart();
    }
    
    function getIntBetween(RandNode memory self, int88 low, int88 high) internal pure returns (int88) {

        return RealMath.fromReal((getReal(self).mul(RealMath.toReal(high) - RealMath.toReal(low))) + RealMath.toReal(low));
    }
    
    function getRealBetween(RandNode memory self, int128 realLow, int128 realHigh) internal pure returns (int128) {

        return getReal(self).mul(realHigh - realLow) + realLow;
    }
    
    function d(RandNode memory self, int8 count, int8 size, int8 bonus) internal pure returns (int16) {

        if (count == 1) {
            return int16(getIntBetween(self, 1, size)) + bonus;
        } else {
            int16 sum = bonus;
            for(int8 i = 0; i < count; i++) {
                sum += d(derive(self, i), 1, size, 0);
            }
            return sum;
        }
    }
}


abstract contract AccessControl {
    function allowQuery(address sender, address origin) virtual public view returns (bool);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ControlledAccess is Ownable {


    AccessControl accessControl;
    
    constructor(address originalAccessControl) internal {
        accessControl = AccessControl(originalAccessControl);
    }
    
    function changeAccessControl(address newAccessControl) public onlyOwner {

        accessControl = AccessControl(newAccessControl);
    }
    
    modifier onlyControlledAccess {

        if (!accessControl.allowQuery(msg.sender, tx.origin)) revert();
        _;
    }
    

}


library Macroverse {


    enum WorldClass {Asteroidal, Lunar, Terrestrial, Jovian, Cometary, Europan, Panthalassic, Neptunian, Ring, AsteroidBelt}

}


library MacroverseSystemGeneratorPart2 {

    using RNG for *;
    using RealMath for *;

    int128 constant REAL_PI = 3454217652358;

    int128 constant REAL_HALF_PI = REAL_PI >> 1;

    int256 constant REAL_FBITS = 40;
    
    int128 constant REAL_ONE = int128(1) << int128(REAL_FBITS);
    
    int128 constant REAL_HALF = REAL_ONE >> 1;
    
    int128 constant REAL_TWO = REAL_ONE << int128(1);

    int128 constant REAL_ZERO = 0;
    
    function convertOrbitShape(int128 realPeriapsis, int128 realApoapsis) public pure returns (int128 realSemimajor, int128 realEccentricity) {

        realSemimajor = RealMath.div(realApoapsis + realPeriapsis, RealMath.toReal(2));
        
        realEccentricity = RealMath.div(realApoapsis - realPeriapsis, realApoapsis + realPeriapsis);
    }
    
    
    function getWorldLan(bytes32 seed) public pure returns (int128) {

        RNG.RandNode memory node = RNG.RandNode(seed).derive("LAN");
        return node.getRealBetween(RealMath.toReal(0), RealMath.mul(RealMath.toReal(2), REAL_PI));
    }
    
    function getPlanetInclination(bytes32 seed, Macroverse.WorldClass class) public pure returns (int128) {

        RNG.RandNode memory node = RNG.RandNode(seed).derive("inclination");
    
        int88 minimum;
        int88 maximum;
        if (class == Macroverse.WorldClass.Lunar || class == Macroverse.WorldClass.Europan) {
            minimum = 0;
            maximum = 175;
        } else if (class == Macroverse.WorldClass.Terrestrial || class == Macroverse.WorldClass.Panthalassic) {
            minimum = 0;
            maximum = 87;
        } else if (class == Macroverse.WorldClass.Neptunian) {
            minimum = 0;
            maximum = 35;
        } else if (class == Macroverse.WorldClass.Jovian) {
            minimum = 0;
            maximum = 52;
        } else if (class == Macroverse.WorldClass.AsteroidBelt) {
            minimum = 0;
            maximum = 262;
        } else {
            revert();
        }
        
        int128 real_retrograde_offset = 0;
        if (node.derive("retrograde").d(1, 100, 0) < 3) {
            real_retrograde_offset = REAL_PI;
        }

        return real_retrograde_offset + RealMath.div(node.getRealBetween(RealMath.toReal(minimum), RealMath.toReal(maximum)), RealMath.toReal(1000));    
    }
    
    
    function getWorldAop(bytes32 seed) public pure returns (int128) {

        RNG.RandNode memory node = RNG.RandNode(seed).derive("AOP");
        return node.getRealBetween(RealMath.toReal(0), RealMath.mul(RealMath.toReal(2), REAL_PI));
    }
    
    function getWorldMeanAnomalyAtEpoch(bytes32 seed) public pure returns (int128) {

        RNG.RandNode memory node = RNG.RandNode(seed).derive("MAE");
        return node.getRealBetween(RealMath.toReal(0), RealMath.mul(RealMath.toReal(2), REAL_PI));
    }

    function isTidallyLocked(bytes32 seed, uint16 worldNumber) public pure returns (bool) {

        return RNG.RandNode(seed).derive("tidal_lock").getReal() < RealMath.fraction(1, int88(worldNumber + 1));
    }

    function getWorldYXAxisAngles(bytes32 seed) public pure returns (int128 realYRadians, int128 realXRadians) {

       
        realYRadians = RNG.RandNode(seed).derive("axisy").getRealBetween(-REAL_PI, REAL_PI);

        int16 tilt_die = RNG.RandNode(seed).derive("tilt").d(1, 6, 0);
        
        int128 real_tilt_limit = REAL_HALF;
        if (tilt_die >= 5) {
            real_tilt_limit = REAL_HALF_PI;
        }
    
        RNG.RandNode memory x_node = RNG.RandNode(seed).derive("axisx");
        realXRadians = x_node.getRealBetween(0, real_tilt_limit);

        if (tilt_die == 4 || tilt_die == 5) {
            realXRadians = REAL_PI - realXRadians;
        }

    }

    function getWorldSpinRate(bytes32 seed) public pure returns (int128) {

        return RNG.RandNode(seed).derive("spin").getRealBetween(REAL_ZERO, RealMath.toReal(8000)); 
    }

}

