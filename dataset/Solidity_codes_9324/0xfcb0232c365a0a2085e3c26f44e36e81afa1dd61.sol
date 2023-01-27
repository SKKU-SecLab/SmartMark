


pragma solidity >0.4.13 >=0.4.23 >=0.5.0 <0.6.0 >=0.5.7 <0.6.0;


library ABDKMath64x64 {

    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function fromInt (int256 x) internal pure returns (int128) {
        require (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
        return int128 (x << 64);
    }

    function toInt (int128 x) internal pure returns (int64) {
        return int64 (x >> 64);
    }

    function fromUInt (uint256 x) internal pure returns (int128) {
        require (x <= 0x7FFFFFFFFFFFFFFF);
        return int128 (x << 64);
    }

    function toUInt (int128 x) internal pure returns (uint64) {
        require (x >= 0);
        return uint64 (x >> 64);
    }

    function from128x128 (int256 x) internal pure returns (int128) {
        int256 result = x >> 64;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }

    function to128x128 (int128 x) internal pure returns (int256) {
        return int256 (x) << 64;
    }

    function add (int128 x, int128 y) internal pure returns (int128) {
        int256 result = int256(x) + y;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }

    function sub (int128 x, int128 y) internal pure returns (int128) {
        int256 result = int256(x) - y;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }

    function mul (int128 x, int128 y) internal pure returns (int128) {
        int256 result = int256(x) * y >> 64;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }

    function muli (int128 x, int256 y) internal pure returns (int256) {
        if (x == MIN_64x64) {
            require (y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
            y <= 0x1000000000000000000000000000000000000000000000000);
            return -y << 63;
        } else {
            bool negativeResult = false;
            if (x < 0) {
                x = -x;
                negativeResult = true;
            }
            if (y < 0) {
                y = -y; // We rely on overflow behavior here
                negativeResult = !negativeResult;
            }
            uint256 absoluteResult = mulu (x, uint256 (y));
            if (negativeResult) {
                require (absoluteResult <=
                    0x8000000000000000000000000000000000000000000000000000000000000000);
                return -int256 (absoluteResult); // We rely on overflow behavior here
            } else {
                require (absoluteResult <=
                    0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int256 (absoluteResult);
            }
        }
    }

    function mulu (int128 x, uint256 y) internal pure returns (uint256) {
        if (y == 0) return 0;

        require (x >= 0);

        uint256 lo = (uint256 (x) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
        uint256 hi = uint256 (x) * (y >> 128);

        require (hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        hi <<= 64;

        require (hi <=
            0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
        return hi + lo;
    }

    function div (int128 x, int128 y) internal pure returns (int128) {
        require (y != 0);
        int256 result = (int256 (x) << 64) / y;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }

    function divi (int256 x, int256 y) internal pure returns (int128) {
        require (y != 0);

        bool negativeResult = false;
        if (x < 0) {
            x = -x; // We rely on overflow behavior here
            negativeResult = true;
        }
        if (y < 0) {
            y = -y; // We rely on overflow behavior here
            negativeResult = !negativeResult;
        }
        uint128 absoluteResult = divuu (uint256 (x), uint256 (y));
        if (negativeResult) {
            require (absoluteResult <= 0x80000000000000000000000000000000);
            return -int128 (absoluteResult); // We rely on overflow behavior here
        } else {
            require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int128 (absoluteResult); // We rely on overflow behavior here
        }
    }

    function divu (uint256 x, uint256 y) internal pure returns (int128) {
        require (y != 0);
        uint128 result = divuu (x, y);
        require (result <= uint128 (MAX_64x64));
        return int128 (result);
    }

    function neg (int128 x) internal pure returns (int128) {
        require (x != MIN_64x64);
        return -x;
    }

    function abs (int128 x) internal pure returns (int128) {
        require (x != MIN_64x64);
        return x < 0 ? -x : x;
    }

    function inv (int128 x) internal pure returns (int128) {
        require (x != 0);
        int256 result = int256 (0x100000000000000000000000000000000) / x;
        require (result >= MIN_64x64 && result <= MAX_64x64);
        return int128 (result);
    }

    function avg (int128 x, int128 y) internal pure returns (int128) {
        return int128 ((int256 (x) + int256 (y)) >> 1);
    }

    function gavg (int128 x, int128 y) internal pure returns (int128) {
        int256 m = int256 (x) * int256 (y);
        require (m >= 0);
        require (m <
            0x4000000000000000000000000000000000000000000000000000000000000000);
        return int128 (sqrtu (uint256 (m), uint256 (x) + uint256 (y) >> 1));
    }

    function pow (int128 x, uint256 y) internal pure returns (int128) {
        uint256 absoluteResult;
        bool negativeResult = false;
        if (x >= 0) {
            absoluteResult = powu (uint256 (x) << 63, y);
        } else {
            absoluteResult = powu (uint256 (uint128 (-x)) << 63, y);
            negativeResult = y & 1 > 0;
        }

        absoluteResult >>= 63;

        if (negativeResult) {
            require (absoluteResult <= 0x80000000000000000000000000000000);
            return -int128 (absoluteResult); // We rely on overflow behavior here
        } else {
            require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int128 (absoluteResult); // We rely on overflow behavior here
        }
    }

    function sqrt (int128 x) internal pure returns (int128) {
        require (x >= 0);
        return int128 (sqrtu (uint256 (x) << 64, 0x10000000000000000));
    }

    function log_2 (int128 x) internal pure returns (int128) {
        require (x > 0);

        int256 msb = 0;
        int256 xc = x;
        if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
        if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
        if (xc >= 0x10000) { xc >>= 16; msb += 16; }
        if (xc >= 0x100) { xc >>= 8; msb += 8; }
        if (xc >= 0x10) { xc >>= 4; msb += 4; }
        if (xc >= 0x4) { xc >>= 2; msb += 2; }
        if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

        int256 result = msb - 64 << 64;
        uint256 ux = uint256 (x) << 127 - msb;
        for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
            ux *= ux;
            uint256 b = ux >> 255;
            ux >>= 127 + b;
            result += bit * int256 (b);
        }

        return int128 (result);
    }

    function ln (int128 x) internal pure returns (int128) {
        require (x > 0);

        return int128 (
            uint256 (log_2 (x)) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128);
    }

    function exp_2 (int128 x) internal pure returns (int128) {
        require (x < 0x400000000000000000); // Overflow

        if (x < -0x400000000000000000) return 0; // Underflow

        uint256 result = 0x80000000000000000000000000000000;

        if (x & 0x8000000000000000 > 0)
            result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
        if (x & 0x4000000000000000 > 0)
            result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
        if (x & 0x2000000000000000 > 0)
            result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
        if (x & 0x1000000000000000 > 0)
            result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
        if (x & 0x800000000000000 > 0)
            result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
        if (x & 0x400000000000000 > 0)
            result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
        if (x & 0x200000000000000 > 0)
            result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
        if (x & 0x100000000000000 > 0)
            result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
        if (x & 0x80000000000000 > 0)
            result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
        if (x & 0x40000000000000 > 0)
            result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
        if (x & 0x20000000000000 > 0)
            result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
        if (x & 0x10000000000000 > 0)
            result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
        if (x & 0x8000000000000 > 0)
            result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
        if (x & 0x4000000000000 > 0)
            result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
        if (x & 0x2000000000000 > 0)
            result = result * 0x1000162E525EE054754457D5995292026 >> 128;
        if (x & 0x1000000000000 > 0)
            result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
        if (x & 0x800000000000 > 0)
            result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
        if (x & 0x400000000000 > 0)
            result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
        if (x & 0x200000000000 > 0)
            result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
        if (x & 0x100000000000 > 0)
            result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
        if (x & 0x80000000000 > 0)
            result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
        if (x & 0x40000000000 > 0)
            result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
        if (x & 0x20000000000 > 0)
            result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
        if (x & 0x10000000000 > 0)
            result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
        if (x & 0x8000000000 > 0)
            result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
        if (x & 0x4000000000 > 0)
            result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
        if (x & 0x2000000000 > 0)
            result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
        if (x & 0x1000000000 > 0)
            result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
        if (x & 0x800000000 > 0)
            result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
        if (x & 0x400000000 > 0)
            result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
        if (x & 0x200000000 > 0)
            result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
        if (x & 0x100000000 > 0)
            result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
        if (x & 0x80000000 > 0)
            result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
        if (x & 0x40000000 > 0)
            result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
        if (x & 0x20000000 > 0)
            result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
        if (x & 0x10000000 > 0)
            result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
        if (x & 0x8000000 > 0)
            result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
        if (x & 0x4000000 > 0)
            result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
        if (x & 0x2000000 > 0)
            result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
        if (x & 0x1000000 > 0)
            result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
        if (x & 0x800000 > 0)
            result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
        if (x & 0x400000 > 0)
            result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
        if (x & 0x200000 > 0)
            result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
        if (x & 0x100000 > 0)
            result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
        if (x & 0x80000 > 0)
            result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
        if (x & 0x40000 > 0)
            result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
        if (x & 0x20000 > 0)
            result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
        if (x & 0x10000 > 0)
            result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
        if (x & 0x8000 > 0)
            result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
        if (x & 0x4000 > 0)
            result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
        if (x & 0x2000 > 0)
            result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
        if (x & 0x1000 > 0)
            result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
        if (x & 0x800 > 0)
            result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
        if (x & 0x400 > 0)
            result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
        if (x & 0x200 > 0)
            result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
        if (x & 0x100 > 0)
            result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
        if (x & 0x80 > 0)
            result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
        if (x & 0x40 > 0)
            result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
        if (x & 0x20 > 0)
            result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
        if (x & 0x10 > 0)
            result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
        if (x & 0x8 > 0)
            result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
        if (x & 0x4 > 0)
            result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
        if (x & 0x2 > 0)
            result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
        if (x & 0x1 > 0)
            result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;

        result >>= 63 - (x >> 64);
        require (result <= uint256 (MAX_64x64));

        return int128 (result);
    }

    function exp (int128 x) internal pure returns (int128) {
        require (x < 0x400000000000000000); // Overflow

        if (x < -0x400000000000000000) return 0; // Underflow

        return exp_2 (
            int128 (int256 (x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
    }

    function divuu (uint256 x, uint256 y) private pure returns (uint128) {
        require (y != 0);

        uint256 result;

        if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
            result = (x << 64) / y;
        else {
            uint256 msb = 192;
            uint256 xc = x >> 192;
            if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
            if (xc >= 0x10000) { xc >>= 16; msb += 16; }
            if (xc >= 0x100) { xc >>= 8; msb += 8; }
            if (xc >= 0x10) { xc >>= 4; msb += 4; }
            if (xc >= 0x4) { xc >>= 2; msb += 2; }
            if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

            result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
            require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

            uint256 hi = result * (y >> 128);
            uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

            uint256 xh = x >> 192;
            uint256 xl = x << 64;

            if (xl < lo) xh -= 1;
            xl -= lo; // We rely on overflow behavior here
            lo = hi << 128;
            if (xl < lo) xh -= 1;
            xl -= lo; // We rely on overflow behavior here

            assert (xh == hi >> 128);

            result += xl / y;
        }

        require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return uint128 (result);
    }

    function powu (uint256 x, uint256 y) private pure returns (uint256) {
        if (y == 0) return 0x80000000000000000000000000000000;
        else if (x == 0) return 0;
        else {
            int256 msb = 0;
            uint256 xc = x;
            if (xc >= 0x100000000000000000000000000000000) { xc >>= 128; msb += 128; }
            if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
            if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
            if (xc >= 0x10000) { xc >>= 16; msb += 16; }
            if (xc >= 0x100) { xc >>= 8; msb += 8; }
            if (xc >= 0x10) { xc >>= 4; msb += 4; }
            if (xc >= 0x4) { xc >>= 2; msb += 2; }
            if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

            int256 xe = msb - 127;
            if (xe > 0) x >>= xe;
            else x <<= -xe;

            uint256 result = 0x80000000000000000000000000000000;
            int256 re = 0;

            while (y > 0) {
                if (y & 1 > 0) {
                    result = result * x;
                    y -= 1;
                    re += xe;
                    if (result >=
                        0x8000000000000000000000000000000000000000000000000000000000000000) {
                        result >>= 128;
                        re += 1;
                    } else result >>= 127;
                    if (re < -127) return 0; // Underflow
                    require (re < 128); // Overflow
                } else {
                    x = x * x;
                    y >>= 1;
                    xe <<= 1;
                    if (x >=
                        0x8000000000000000000000000000000000000000000000000000000000000000) {
                        x >>= 128;
                        xe += 1;
                    } else x >>= 127;
                    if (xe < -127) return 0; // Underflow
                    require (xe < 128); // Overflow
                }
            }

            if (re > 0) result <<= re;
            else if (re < 0) result >>= -re;

            return result;
        }
    }

    function sqrtu (uint256 x, uint256 r) private pure returns (uint128) {
        if (x == 0) return 0;
        else {
            require (r > 0);
            while (true) {
                uint256 rr = x / r;
                if (r == rr || r + 1 == rr) return uint128 (r);
                else if (r == rr + 1) return uint128 (rr);
                r = r + rr + 1 >> 1;
            }
        }
    }
}




interface IAssimilator {

    function intakeRaw (uint256 amount) external returns (int128);
    function intakeRawAndGetBalance (uint256 amount) external returns (int128, int128);
    function intakeNumeraire (int128 amount) external returns (uint256);
    function outputRaw (address dst, uint256 amount) external returns (int128);
    function outputRawAndGetBalance (address dst, uint256 amount) external returns (int128, int128);
    function outputNumeraire (address dst, int128 amount) external returns (uint256);
    function viewRawAmount (int128) external view returns (uint256);
    function viewNumeraireAmount (uint256) external view returns (int128);
    function viewNumeraireBalance (address) external view returns (int128);
    function viewNumeraireAmountAndBalance (address, uint256) external view returns (int128, int128);
}



library Assimilators {


    using ABDKMath64x64 for int128;
    IAssimilator constant iAsmltr = IAssimilator(address(0));

    function delegate(address _callee, bytes memory _data) internal returns (bytes memory) {


        (bool _success, bytes memory returnData_) = _callee.delegatecall(_data);

        assembly { if eq(_success, 0) { revert(add(returnData_, 0x20), returndatasize()) } }

        return returnData_;

    }

    function viewRawAmount (address _assim, int128 _amt) internal view returns (uint256 amount_) {

        amount_ = IAssimilator(_assim).viewRawAmount(_amt);

    }

    function viewNumeraireAmount (address _assim, uint256 _amt) internal view returns (int128 amt_) {

        amt_ = IAssimilator(_assim).viewNumeraireAmount(_amt);

    }

    function viewNumeraireAmountAndBalance (address _assim, uint256 _amt) internal view returns (int128 amt_, int128 bal_) {

        ( amt_, bal_ ) = IAssimilator(_assim).viewNumeraireAmountAndBalance(address(this), _amt);

    }

    function viewNumeraireBalance (address _assim) internal view returns (int128 bal_) {

        bal_ = IAssimilator(_assim).viewNumeraireBalance(address(this));

    }

    function intakeRaw (address _assim, uint256 _amt) internal returns (int128 amt_) {

        bytes memory data = abi.encodeWithSelector(iAsmltr.intakeRaw.selector, _amt);

        amt_ = abi.decode(delegate(_assim, data), (int128));

    }

    function intakeRawAndGetBalance (address _assim, uint256 _amt) internal returns (int128 amt_, int128 bal_) {

        bytes memory data = abi.encodeWithSelector(iAsmltr.intakeRawAndGetBalance.selector, _amt);

        ( amt_, bal_ ) = abi.decode(delegate(_assim, data), (int128,int128));

    }

    function intakeNumeraire (address _assim, int128 _amt) internal returns (uint256 amt_) {

        bytes memory data = abi.encodeWithSelector(iAsmltr.intakeNumeraire.selector, _amt);

        amt_ = abi.decode(delegate(_assim, data), (uint256));

    }

    function outputRaw (address _assim, address _dst, uint256 _amt) internal returns (int128 amt_ ) {

        bytes memory data = abi.encodeWithSelector(iAsmltr.outputRaw.selector, _dst, _amt);

        amt_ = abi.decode(delegate(_assim, data), (int128));

        amt_ = amt_.neg();

    }

    function outputRawAndGetBalance (address _assim, address _dst, uint256 _amt) internal returns (int128 amt_, int128 bal_) {

        bytes memory data = abi.encodeWithSelector(iAsmltr.outputRawAndGetBalance.selector, _dst, _amt);

        ( amt_, bal_ ) = abi.decode(delegate(_assim, data), (int128,int128));

        amt_ = amt_.neg();

    }

    function outputNumeraire (address _assim, address _dst, int128 _amt) internal returns (uint256 amt_) {

        bytes memory data = abi.encodeWithSelector(iAsmltr.outputNumeraire.selector, _dst, _amt.abs());

        amt_ = abi.decode(delegate(_assim, data), (uint256));

    }

}

library UnsafeMath64x64 {



    function us_mul (int128 x, int128 y) internal pure returns (int128) {
        int256 result = int256(x) * y >> 64;
        return int128 (result);
    }


    function us_div (int128 x, int128 y) internal pure returns (int128) {
        int256 result = (int256 (x) << 64) / y;
        return int128 (result);
    }

}

library PartitionedLiquidity {


    using ABDKMath64x64 for uint;
    using ABDKMath64x64 for int128;
    using UnsafeMath64x64 for int128;

    event PoolPartitioned(bool);

    event PartitionRedeemed(address indexed token, address indexed redeemer, uint value);

    int128 constant ONE = 0x10000000000000000;

    function partition (
        ComponentStorage.Component storage component,
        mapping (address => ComponentStorage.PartitionTicket) storage partitionTickets
    ) external {

        uint _length = component.assets.length;

        ComponentStorage.PartitionTicket storage totalSupplyTicket = partitionTickets[address(this)];

        totalSupplyTicket.initialized = true;

        for (uint i = 0; i < _length; i++) totalSupplyTicket.claims.push(component.totalSupply);

        emit PoolPartitioned(true);

    }

    function viewPartitionClaims (
        ComponentStorage.Component storage component,
        mapping (address => ComponentStorage.PartitionTicket) storage partitionTickets,
        address _addr
    ) external view returns (
        uint[] memory claims_
    ) {

        ComponentStorage.PartitionTicket storage ticket = partitionTickets[_addr];

        if (ticket.initialized) return ticket.claims;

        uint _length = component.assets.length;
        claims_ = new uint[](_length);
        uint _balance = component.balances[msg.sender];

        for (uint i = 0; i < _length; i++) claims_[i] = _balance;

        return claims_;

    }

    function partitionedWithdraw (
        ComponentStorage.Component storage component,
        mapping (address => ComponentStorage.PartitionTicket) storage partitionTickets,
        address[] calldata _derivatives,
        uint[] calldata _withdrawals
    ) external returns (
        uint[] memory
    ) {

        uint _length = component.assets.length;
        uint _balance = component.balances[msg.sender];

        ComponentStorage.PartitionTicket storage totalSuppliesTicket = partitionTickets[address(this)];
        ComponentStorage.PartitionTicket storage ticket = partitionTickets[msg.sender];

        if (!ticket.initialized) {

            for (uint i = 0; i < _length; i++) ticket.claims.push(_balance);
            ticket.initialized = true;

        }

        _length = _derivatives.length;

        uint[] memory withdrawals_ = new uint[](_length);

        for (uint i = 0; i < _length; i++) {

            ComponentStorage.Assimilator memory _assim = component.assimilators[_derivatives[i]];

            require(totalSuppliesTicket.claims[_assim.ix] >= _withdrawals[i], "Component/burn-exceeds-total-supply");

            require(ticket.claims[_assim.ix] >= _withdrawals[i], "Component/insufficient-balance");

            require(_assim.addr != address(0), "Component/unsupported-asset");

            int128 _reserveBalance = Assimilators.viewNumeraireBalance(_assim.addr);

            int128 _multiplier = _withdrawals[i].divu(1e18)
            .div(totalSuppliesTicket.claims[_assim.ix].divu(1e18));

            totalSuppliesTicket.claims[_assim.ix] = totalSuppliesTicket.claims[_assim.ix] - _withdrawals[i];

            ticket.claims[_assim.ix] = ticket.claims[_assim.ix] - _withdrawals[i];

            uint _withdrawal = Assimilators.outputNumeraire(
                _assim.addr,
                msg.sender,
                _reserveBalance.mul(_multiplier)
            );

            withdrawals_[i] = _withdrawal;

            emit PartitionRedeemed(_derivatives[i], msg.sender, withdrawals_[i]);

        }

        return withdrawals_;

    }

}

library ProportionalLiquidity {


    using ABDKMath64x64 for uint;
    using ABDKMath64x64 for int128;
    using UnsafeMath64x64 for int128;

    event Transfer(address indexed from, address indexed to, uint256 value);

    int128 constant ONE = 0x10000000000000000;
    int128 constant ONE_WEI = 0x12;

    function proportionalDeposit (
        ComponentStorage.Component storage component,
        uint256 _deposit
    ) external returns (
        uint256 components_,
        uint[] memory
    ) {

        int128 __deposit = _deposit.divu(1e18);

        uint _length = component.assets.length;

        uint[] memory deposits_ = new uint[](_length);

        ( int128 _oGLiq, int128[] memory _oBals ) = getGrossLiquidityAndBalances(component);

        if (_oGLiq == 0) {

            for (uint i = 0; i < _length; i++) {

                deposits_[i] = Assimilators.intakeNumeraire(component.assets[i].addr, __deposit.mul(component.weights[i]));

            }

        } else {

            int128 _multiplier = __deposit.div(_oGLiq);

            for (uint i = 0; i < _length; i++) {

                deposits_[i] = Assimilators.intakeNumeraire(component.assets[i].addr, _oBals[i].mul(_multiplier));

            }

        }

        int128 _totalComponents = component.totalSupply.divu(1e18);

        int128 _newComponents = _totalComponents > 0
        ? __deposit.div(_oGLiq).mul(_totalComponents)
        : __deposit;

        requireLiquidityInvariant(
            component,
            _totalComponents,
            _newComponents,
            _oGLiq,
            _oBals
        );

        mint(component, msg.sender, components_ = _newComponents.mulu(1e18));

        return (components_, deposits_);

    }


    function viewProportionalDeposit (
        ComponentStorage.Component storage component,
        uint256 _deposit
    ) external view returns (
        uint components_,
        uint[] memory
    ) {

        int128 __deposit = _deposit.divu(1e18);

        uint _length = component.assets.length;

        ( int128 _oGLiq, int128[] memory _oBals ) = getGrossLiquidityAndBalances(component);

        uint[] memory deposits_ = new uint[](_length);

        if (_oGLiq == 0) {

            for (uint i = 0; i < _length; i++) {

                deposits_[i] = Assimilators.viewRawAmount(
                    component.assets[i].addr,
                    __deposit.mul(component.weights[i])
                );

            }

        } else {

            int128 _multiplier = __deposit.div(_oGLiq);

            for (uint i = 0; i < _length; i++) {

                deposits_[i] = Assimilators.viewRawAmount(
                    component.assets[i].addr,
                    _oBals[i].mul(_multiplier)
                );

            }

        }

        int128 _totalComponents = component.totalSupply.divu(1e18);

        int128 _newComponents = _totalComponents > 0
        ? __deposit.div(_oGLiq).mul(_totalComponents)
        : __deposit;

        components_ = _newComponents.mulu(1e18);

        return (components_, deposits_ );

    }

    function proportionalWithdraw (
        ComponentStorage.Component storage component,
        uint256 _withdrawal
    ) external returns (
        uint[] memory
    ) {

        uint _length = component.assets.length;

        ( int128 _oGLiq, int128[] memory _oBals ) = getGrossLiquidityAndBalances(component);

        uint[] memory withdrawals_ = new uint[](_length);

        int128 _totalComponents = component.totalSupply.divu(1e18);
        int128 __withdrawal = _withdrawal.divu(1e18);

        int128 _multiplier = __withdrawal
        .mul(ONE - component.epsilon)
        .div(_totalComponents);

        for (uint i = 0; i < _length; i++) {

            withdrawals_[i] = Assimilators.outputNumeraire(
                component.assets[i].addr,
                msg.sender,
                _oBals[i].mul(_multiplier)
            );

        }

        requireLiquidityInvariant(
            component,
            _totalComponents,
            __withdrawal.neg(),
            _oGLiq,
            _oBals
        );

        burn(component, msg.sender, _withdrawal);

        return withdrawals_;

    }

    function viewProportionalWithdraw (
        ComponentStorage.Component storage component,
        uint256 _withdrawal
    ) external view returns (
        uint[] memory
    ) {

        uint _length = component.assets.length;

        ( , int128[] memory _oBals ) = getGrossLiquidityAndBalances(component);

        uint[] memory withdrawals_ = new uint[](_length);

        int128 _multiplier = _withdrawal.divu(1e18)
        .mul(ONE - component.epsilon)
        .div(component.totalSupply.divu(1e18));

        for (uint i = 0; i < _length; i++) {

            withdrawals_[i] = Assimilators.viewRawAmount(component.assets[i].addr, _oBals[i].mul(_multiplier));

        }

        return withdrawals_;

    }

    function getGrossLiquidityAndBalances (
        ComponentStorage.Component storage component
    ) internal view returns (
        int128 grossLiquidity_,
        int128[] memory
    ) {

        uint _length = component.assets.length;

        int128[] memory balances_ = new int128[](_length);

        for (uint i = 0; i < _length; i++) {

            int128 _bal = Assimilators.viewNumeraireBalance(component.assets[i].addr);

            balances_[i] = _bal;
            grossLiquidity_ += _bal;

        }

        return (grossLiquidity_, balances_);

    }

    function requireLiquidityInvariant (
        ComponentStorage.Component storage component,
        int128 _components,
        int128 _newComponents,
        int128 _oGLiq,
        int128[] memory _oBals
    ) private view {

        ( int128 _nGLiq, int128[] memory _nBals ) = getGrossLiquidityAndBalances(component);

        int128 _beta = component.beta;
        int128 _delta = component.delta;
        int128[] memory _weights = component.weights;

        int128 _omega = ComponentMath.calculateFee(_oGLiq, _oBals, _beta, _delta, _weights);

        int128 _psi = ComponentMath.calculateFee(_nGLiq, _nBals, _beta, _delta, _weights);

        ComponentMath.enforceLiquidityInvariant(_components, _newComponents, _oGLiq, _nGLiq, _omega, _psi);

    }

    function burn (ComponentStorage.Component storage component, address account, uint256 amount) private {

        component.balances[account] = burn_sub(component.balances[account], amount);

        component.totalSupply = burn_sub(component.totalSupply, amount);

        emit Transfer(msg.sender, address(0), amount);

    }

    function mint (ComponentStorage.Component storage component, address account, uint256 amount) private {

        component.totalSupply = mint_add(component.totalSupply, amount);

        component.balances[account] = mint_add(component.balances[account], amount);

        emit Transfer(address(0), msg.sender, amount);

    }

    function mint_add(uint x, uint y) private pure returns (uint z) {


        require((z = x + y) >= x, "Component/mint-overflow");

    }

    function burn_sub(uint x, uint y) private pure returns (uint z) {


        require((z = x - y) <= x, "Component/burn-underflow");

    }


}

library SelectiveLiquidity {


    using ABDKMath64x64 for int128;
    using UnsafeMath64x64 for int128;

    event Transfer(address indexed from, address indexed to, uint256 value);

    int128 constant ONE = 0x10000000000000000;

    function selectiveDeposit (
        ComponentStorage.Component storage component,
        address[] calldata _derivatives,
        uint[] calldata _amounts,
        uint _minComponents
    ) external returns (
        uint components_
    ) {

        (   int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals ) = getLiquidityDepositData(component, _derivatives, _amounts);

        int128 _components = ComponentMath.calculateLiquidityMembrane(component, _oGLiq, _nGLiq, _oBals, _nBals);

        components_ = _components.mulu(1e18);

        require(_minComponents < components_, "Component/under-minimum-components");

        mint(component, msg.sender, components_);

    }

    function viewSelectiveDeposit (
        ComponentStorage.Component storage component,
        address[] calldata _derivatives,
        uint[] calldata _amounts
    ) external view returns (
        uint components_
    ) {

        (   int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals ) = viewLiquidityDepositData(component, _derivatives, _amounts);

        int128 _components = ComponentMath.calculateLiquidityMembrane(component, _oGLiq, _nGLiq, _oBals, _nBals);

        components_ = _components.mulu(1e18);

    }

    function selectiveWithdraw (
        ComponentStorage.Component storage component,
        address[] calldata _derivatives,
        uint[] calldata _amounts,
        uint _maxComponents
    ) external returns (
        uint256 components_
    ) {

        (   int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals ) = getLiquidityWithdrawData(component, _derivatives, msg.sender, _amounts);

        int128 _components = ComponentMath.calculateLiquidityMembrane(component, _oGLiq, _nGLiq, _oBals, _nBals);

        _components = _components.neg().us_mul(ONE + component.epsilon);

        components_ = _components.mulu(1e18);

        require(components_ < _maxComponents, "Component/above-maximum-components");

        burn(component, msg.sender, components_);

    }

    function viewSelectiveWithdraw (
        ComponentStorage.Component storage component,
        address[] calldata _derivatives,
        uint[] calldata _amounts
    ) external view returns (
        uint components_
    ) {

        (   int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals ) = viewLiquidityWithdrawData(component, _derivatives, _amounts);

        int128 _components = ComponentMath.calculateLiquidityMembrane(component, _oGLiq, _nGLiq, _oBals, _nBals);

        _components = _components.neg().us_mul(ONE + component.epsilon);

        components_ = _components.mulu(1e18);

    }

    function getLiquidityDepositData (
        ComponentStorage.Component storage component,
        address[] memory _derivatives,
        uint[] memory _amounts
    ) private returns (
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.weights.length;
        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);

        for (uint i = 0; i < _derivatives.length; i++) {

            ComponentStorage.Assimilator memory _assim = component.assimilators[_derivatives[i]];

            require(_assim.addr != address(0), "Component/unsupported-derivative");

            if ( nBals_[_assim.ix] == 0 && 0 == oBals_[_assim.ix]) {

                ( int128 _amount, int128 _balance ) = Assimilators.intakeRawAndGetBalance(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = _balance;

                oBals_[_assim.ix] = _balance.sub(_amount);

            } else {

                int128 _amount = Assimilators.intakeRaw(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = nBals_[_assim.ix].add(_amount);

            }

        }

        return completeLiquidityData(component, oBals_, nBals_);

    }

    function getLiquidityWithdrawData (
        ComponentStorage.Component storage component,
        address[] memory _derivatives,
        address _rcpnt,
        uint[] memory _amounts
    ) private returns (
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.weights.length;
        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);

        for (uint i = 0; i < _derivatives.length; i++) {

            ComponentStorage.Assimilator memory _assim = component.assimilators[_derivatives[i]];

            require(_assim.addr != address(0), "Component/unsupported-derivative");

            if ( nBals_[_assim.ix] == 0 && 0 == oBals_[_assim.ix]) {

                ( int128 _amount, int128 _balance ) = Assimilators.outputRawAndGetBalance(_assim.addr, _rcpnt, _amounts[i]);

                nBals_[_assim.ix] = _balance;
                oBals_[_assim.ix] = _balance.sub(_amount);

            } else {

                int128 _amount = Assimilators.outputRaw(_assim.addr, _rcpnt, _amounts[i]);

                nBals_[_assim.ix] = nBals_[_assim.ix].add(_amount);

            }

        }

        return completeLiquidityData(component, oBals_, nBals_);

    }

    function viewLiquidityDepositData (
        ComponentStorage.Component storage component,
        address[] memory _derivatives,
        uint[] memory _amounts
    ) private view returns (
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.assets.length;
        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);

        for (uint i = 0; i < _derivatives.length; i++) {

            ComponentStorage.Assimilator memory _assim = component.assimilators[_derivatives[i]];

            require(_assim.addr != address(0), "Component/unsupported-derivative");

            if ( nBals_[_assim.ix] == 0 && 0 == oBals_[_assim.ix]) {

                ( int128 _amount, int128 _balance ) = Assimilators.viewNumeraireAmountAndBalance(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = _balance.add(_amount);

                oBals_[_assim.ix] = _balance;

            } else {

                int128 _amount = Assimilators.viewNumeraireAmount(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = nBals_[_assim.ix].add(_amount);

            }

        }

        return completeLiquidityData(component, oBals_, nBals_);

    }

    function viewLiquidityWithdrawData (
        ComponentStorage.Component storage component,
        address[] memory _derivatives,
        uint[] memory _amounts
    ) private view returns (
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.assets.length;
        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);

        for (uint i = 0; i < _derivatives.length; i++) {

            ComponentStorage.Assimilator memory _assim = component.assimilators[_derivatives[i]];

            require(_assim.addr != address(0), "Component/unsupported-derivative");

            if ( nBals_[_assim.ix] == 0 && 0 == oBals_[_assim.ix]) {

                ( int128 _amount, int128 _balance ) = Assimilators.viewNumeraireAmountAndBalance(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = _balance.sub(_amount);

                oBals_[_assim.ix] = _balance;

            } else {

                int128 _amount = Assimilators.viewNumeraireAmount(_assim.addr, _amounts[i]);

                nBals_[_assim.ix] = nBals_[_assim.ix].sub(_amount);

            }

        }

        return completeLiquidityData(component, oBals_, nBals_);

    }

    function completeLiquidityData (
        ComponentStorage.Component storage component,
        int128[] memory oBals_,
        int128[] memory nBals_
    ) private view returns (
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = oBals_.length;

        for (uint i = 0; i < _length; i++) {

            if (oBals_[i] == 0 && 0 == nBals_[i]) {

                nBals_[i] = oBals_[i] = Assimilators.viewNumeraireBalance(component.assets[i].addr);

            }

            oGLiq_ += oBals_[i];
            nGLiq_ += nBals_[i];

        }

        return ( oGLiq_, nGLiq_, oBals_, nBals_ );

    }

    function burn (ComponentStorage.Component storage component, address account, uint256 amount) private {

        component.balances[account] = burn_sub(component.balances[account], amount);

        component.totalSupply = burn_sub(component.totalSupply, amount);

        emit Transfer(msg.sender, address(0), amount);

    }

    function mint (ComponentStorage.Component storage component, address account, uint256 amount) private {

        component.totalSupply = mint_add(component.totalSupply, amount);

        component.balances[account] = mint_add(component.balances[account], amount);

        emit Transfer(address(0), msg.sender, amount);

    }

    function mint_add(uint x, uint y) private pure returns (uint z) {

        require((z = x + y) >= x, "Component/mint-overflow");
    }

    function burn_sub(uint x, uint y) private pure returns (uint z) {

        require((z = x - y) <= x, "Component/burn-underflow");
    }

}




library Components {


    using ABDKMath64x64 for int128;

    event Approval(address indexed _owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function add(uint x, uint y, string memory errorMessage) private pure returns (uint z) {

        require((z = x + y) >= x, errorMessage);
    }

    function sub(uint x, uint y, string memory errorMessage) private pure returns (uint z) {

        require((z = x - y) <= x, errorMessage);
    }

    function transfer(ComponentStorage.Component storage component, address recipient, uint256 amount) external returns (bool) {

        _transfer(component, msg.sender, recipient, amount);
        return true;
    }

    function approve(ComponentStorage.Component storage component, address spender, uint256 amount) external returns (bool) {

        _approve(component, msg.sender, spender, amount);
        return true;
    }

    function transferFrom(ComponentStorage.Component storage component, address sender, address recipient, uint256 amount) external returns (bool) {

        _transfer(component, sender, recipient, amount);
        _approve(component, sender, msg.sender, sub(component.allowances[sender][msg.sender], amount, "Component/insufficient-allowance"));
        return true;
    }

    function increaseAllowance(ComponentStorage.Component storage component, address spender, uint256 addedValue) external returns (bool) {

        _approve(component, msg.sender, spender, add(component.allowances[msg.sender][spender], addedValue, "Component/approval-overflow"));
        return true;
    }

    function decreaseAllowance(ComponentStorage.Component storage component, address spender, uint256 subtractedValue) external returns (bool) {

        _approve(component, msg.sender, spender, sub(component.allowances[msg.sender][spender], subtractedValue, "Component/allowance-decrease-underflow"));
        return true;
    }

    function _transfer(ComponentStorage.Component storage component, address sender, address recipient, uint256 amount) private {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        component.balances[sender] = sub(component.balances[sender], amount, "Component/insufficient-balance");
        component.balances[recipient] = add(component.balances[recipient], amount, "Component/transfer-overflow");
        emit Transfer(sender, recipient, amount);
    }


    function _approve(ComponentStorage.Component storage component, address _owner, address spender, uint256 amount) private {

        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        component.allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

}

library Swaps {


    using ABDKMath64x64 for int128;
    using UnsafeMath64x64 for int128;

    event Trade(address indexed trader, address indexed origin, address indexed target, uint256 originAmount, uint256 targetAmount);

    int128 constant ONE = 0x10000000000000000;

    function getOriginAndTarget (
        ComponentStorage.Component storage component,
        address _o,
        address _t
    ) private view returns (
        ComponentStorage.Assimilator memory,
        ComponentStorage.Assimilator memory
    ) {

        ComponentStorage.Assimilator memory o_ = component.assimilators[_o];
        ComponentStorage.Assimilator memory t_ = component.assimilators[_t];

        require(o_.addr != address(0), "Component/origin-not-supported");
        require(t_.addr != address(0), "Component/target-not-supported");

        return ( o_, t_ );

    }


    function originSwap (
        ComponentStorage.Component storage component,
        address _origin,
        address _target,
        uint256 _originAmount,
        address _recipient
    ) external returns (
        uint256 tAmt_
    ) {

        (   ComponentStorage.Assimilator memory _o,
        ComponentStorage.Assimilator memory _t  ) = getOriginAndTarget(component, _origin, _target);

        if (_o.ix == _t.ix) return Assimilators.outputNumeraire(_t.addr, _recipient, Assimilators.intakeRaw(_o.addr, _originAmount));

        (   int128 _amt,
        int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals ) = getOriginSwapData(component, _o.ix, _t.ix, _o.addr, _originAmount);

        _amt = ComponentMath.calculateTrade(component, _oGLiq, _nGLiq, _oBals, _nBals, _amt, _t.ix);

        settleProtocolShare(component, _t.addr, _amt);

        _amt = _amt.us_mul(ONE - component.epsilon);

        tAmt_ = Assimilators.outputNumeraire(_t.addr, _recipient, _amt);

        emit Trade(msg.sender, _origin, _target, _originAmount, tAmt_);

    }

    function viewOriginSwap (
        ComponentStorage.Component storage component,
        address _origin,
        address _target,
        uint256 _originAmount
    ) external view returns (
        uint256 tAmt_
    ) {

        (   ComponentStorage.Assimilator memory _o,
        ComponentStorage.Assimilator memory _t  ) = getOriginAndTarget(component, _origin, _target);

        if (_o.ix == _t.ix) return Assimilators.viewRawAmount(_t.addr, Assimilators.viewNumeraireAmount(_o.addr, _originAmount));

        (   int128 _amt,
        int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _nBals,
        int128[] memory _oBals ) = viewOriginSwapData(component, _o.ix, _t.ix, _originAmount, _o.addr);

        _amt = ComponentMath.calculateTrade(component, _oGLiq, _nGLiq, _oBals, _nBals, _amt, _t.ix);

        _amt = _amt.us_mul(ONE - component.epsilon);

        tAmt_ = Assimilators.viewRawAmount(_t.addr, _amt.abs());

    }

    function targetSwap (
        ComponentStorage.Component storage component,
        address _origin,
        address _target,
        uint256 _targetAmount,
        address _recipient
    ) external returns (
        uint256 oAmt_
    ) {

        (   ComponentStorage.Assimilator memory _o,
        ComponentStorage.Assimilator memory _t  ) = getOriginAndTarget(component, _origin, _target);

        if (_o.ix == _t.ix) return Assimilators.intakeNumeraire(_o.addr, Assimilators.outputRaw(_t.addr, _recipient, _targetAmount));

        (   int128 _amt,
        int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals) = getTargetSwapData(component, _t.ix, _o.ix, _t.addr, _recipient, _targetAmount);

        _amt = ComponentMath.calculateTrade(component, _oGLiq, _nGLiq, _oBals, _nBals, _amt, _o.ix);

        int128 _amtWFee = _amt.us_mul(ONE + component.epsilon);

        oAmt_ = Assimilators.intakeNumeraire(_o.addr, _amtWFee);

        settleProtocolShare(component, _o.addr, _amt);

        emit Trade(msg.sender, _origin, _target, oAmt_, _targetAmount);

    }

    function viewTargetSwap (
        ComponentStorage.Component storage component,
        address _origin,
        address _target,
        uint256 _targetAmount
    ) external view returns (
        uint256 oAmt_
    ) {

        (   ComponentStorage.Assimilator memory _o,
        ComponentStorage.Assimilator memory _t  ) = getOriginAndTarget(component, _origin, _target);

        if (_o.ix == _t.ix) return Assimilators.viewRawAmount(_o.addr, Assimilators.viewNumeraireAmount(_t.addr, _targetAmount));

        (   int128 _amt,
        int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _nBals,
        int128[] memory _oBals ) = viewTargetSwapData(component, _t.ix, _o.ix, _targetAmount, _t.addr);

        _amt = ComponentMath.calculateTrade(component, _oGLiq, _nGLiq, _oBals, _nBals, _amt, _o.ix);

        _amt = _amt.us_mul(ONE + component.epsilon);

        oAmt_ = Assimilators.viewRawAmount(_o.addr, _amt);

    }

    function getOriginSwapData (
        ComponentStorage.Component storage component,
        uint _inputIx,
        uint _outputIx,
        address _assim,
        uint _amt
    ) private returns (
        int128 amt_,
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.assets.length;

        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);
        ComponentStorage.Assimilator[] memory _reserves = component.assets;

        for (uint i = 0; i < _length; i++) {

            if (i != _inputIx) nBals_[i] = oBals_[i] = Assimilators.viewNumeraireBalance(_reserves[i].addr);
            else {

                int128 _bal;
                ( amt_, _bal ) = Assimilators.intakeRawAndGetBalance(_assim, _amt);

                oBals_[i] = _bal.sub(amt_);
                nBals_[i] = _bal;

            }

            oGLiq_ += oBals_[i];
            nGLiq_ += nBals_[i];

        }

        nGLiq_ = nGLiq_.sub(amt_);
        nBals_[_outputIx] = ABDKMath64x64.sub(nBals_[_outputIx], amt_);

        return ( amt_, oGLiq_, nGLiq_, oBals_, nBals_ );

    }

    function getTargetSwapData (
        ComponentStorage.Component storage component,
        uint _inputIx,
        uint _outputIx,
        address _assim,
        address _recipient,
        uint _amt
    ) private returns (
        int128 amt_,
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.assets.length;

        int128[] memory oBals_ = new int128[](_length);
        int128[] memory nBals_ = new int128[](_length);
        ComponentStorage.Assimilator[] memory _reserves = component.assets;

        for (uint i = 0; i < _length; i++) {

            if (i != _inputIx) nBals_[i] = oBals_[i] = Assimilators.viewNumeraireBalance(_reserves[i].addr);
            else {

                int128 _bal;
                ( amt_, _bal ) = Assimilators.outputRawAndGetBalance(_assim, _recipient, _amt);

                oBals_[i] = _bal.sub(amt_);
                nBals_[i] = _bal;

            }

            oGLiq_ += oBals_[i];
            nGLiq_ += nBals_[i];

        }

        nGLiq_ = nGLiq_.sub(amt_);
        nBals_[_outputIx] = ABDKMath64x64.sub(nBals_[_outputIx], amt_);

        return ( amt_, oGLiq_, nGLiq_, oBals_, nBals_ );

    }

    function viewOriginSwapData (
        ComponentStorage.Component storage component,
        uint _inputIx,
        uint _outputIx,
        uint _amt,
        address _assim
    ) private view returns (
        int128 amt_,
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.assets.length;
        int128[] memory nBals_ = new int128[](_length);
        int128[] memory oBals_ = new int128[](_length);

        for (uint i = 0; i < _length; i++) {

            if (i != _inputIx) nBals_[i] = oBals_[i] = Assimilators.viewNumeraireBalance(component.assets[i].addr);
            else {

                int128 _bal;
                ( amt_, _bal ) = Assimilators.viewNumeraireAmountAndBalance(_assim, _amt);

                oBals_[i] = _bal;
                nBals_[i] = _bal.add(amt_);

            }

            oGLiq_ += oBals_[i];
            nGLiq_ += nBals_[i];

        }

        nGLiq_ = nGLiq_.sub(amt_);
        nBals_[_outputIx] = ABDKMath64x64.sub(nBals_[_outputIx], amt_);

        return ( amt_, oGLiq_, nGLiq_, nBals_, oBals_ );

    }

    function viewTargetSwapData (
        ComponentStorage.Component storage component,
        uint _inputIx,
        uint _outputIx,
        uint _amt,
        address _assim
    ) private view returns (
        int128 amt_,
        int128 oGLiq_,
        int128 nGLiq_,
        int128[] memory,
        int128[] memory
    ) {

        uint _length = component.assets.length;
        int128[] memory nBals_ = new int128[](_length);
        int128[] memory oBals_ = new int128[](_length);

        for (uint i = 0; i < _length; i++) {

            if (i != _inputIx) nBals_[i] = oBals_[i] = Assimilators.viewNumeraireBalance(component.assets[i].addr);
            else {

                int128 _bal;
                ( amt_, _bal ) = Assimilators.viewNumeraireAmountAndBalance(_assim, _amt);
                amt_ = amt_.neg();

                oBals_[i] = _bal;
                nBals_[i] = _bal.add(amt_);

            }

            oGLiq_ += oBals_[i];
            nGLiq_ += nBals_[i];

        }

        nGLiq_ = nGLiq_.sub(amt_);
        nBals_[_outputIx] = ABDKMath64x64.sub(nBals_[_outputIx], amt_);


        return ( amt_, oGLiq_, nGLiq_, nBals_, oBals_ );

    }

    function settleProtocolShare(
        ComponentStorage.Component storage component,
        address _assim,
        int128 _amt
    ) internal {


        int128 _prtclShr = _amt.us_mul(component.epsilon.us_mul(component.sigma));

        if (_prtclShr.abs() > 0) {

            Assimilators.outputNumeraire(_assim, component.protocol, _prtclShr);

        }

    }

}




contract ComponentStorage {


    address public owner;

    string  public constant name = "Component LP Token";
    string  public constant symbol = "CMP-LP";
    uint8   public constant decimals = 18;

    Component public component;

    struct Component {
        int128 alpha;
        int128 beta;
        int128 delta;
        int128 epsilon;
        int128 lambda;
        int128 sigma;
        int128[] weights;
        uint totalSupply;
        address protocol;
        Assimilator[] assets;
        mapping (address => Assimilator) assimilators;
        mapping (address => uint) balances;
        mapping (address => mapping (address => uint)) allowances;
    }

    struct Assimilator {
        address addr;
        uint8 ix;
    }

    mapping (address => PartitionTicket) public partitionTickets;

    struct PartitionTicket {
        uint[] claims;
        bool initialized;
    }

    address[] public derivatives;
    address[] public numeraires;
    address[] public reserves;

    bool public partitioned = false;

    bool public frozen = false;

    bool internal notEntered = true;

}




library ComponentMath {


    int128 constant ONE = 0x10000000000000000;
    int128 constant MAX = 0x4000000000000000; // .25 in layman's terms
    int128 constant MAX_DIFF = -0x10C6F7A0B5EE;
    int128 constant ONE_WEI = 0x12;

    using ABDKMath64x64 for int128;
    using UnsafeMath64x64 for int128;
    using ABDKMath64x64 for uint256;

    function calculateFee (
        int128 _gLiq,
        int128[] memory _bals,
        int128 _beta,
        int128 _delta,
        int128[] memory _weights
    ) internal pure returns (int128 psi_) {

        uint _length = _bals.length;

        for (uint i = 0; i < _length; i++) {

            int128 _ideal = _gLiq.us_mul(_weights[i]);

            psi_ += calculateMicroFee(_bals[i], _ideal, _beta, _delta);

        }

    }

    function calculateMicroFee (
        int128 _bal,
        int128 _ideal,
        int128 _beta,
        int128 _delta
    ) private pure returns (int128 fee_) {

        if (_bal < _ideal) {

            int128 _threshold = _ideal.us_mul(ONE - _beta);

            if (_bal < _threshold) {

                int128 _feeMargin = _threshold - _bal;

                fee_ = _feeMargin.us_div(_ideal);
                fee_ = fee_.us_mul(_delta);

                if (fee_ > MAX) fee_ = MAX;

                fee_ = fee_.us_mul(_feeMargin);

            } else fee_ = 0;

        } else {

            int128 _threshold = _ideal.us_mul(ONE + _beta);

            if (_bal > _threshold) {

                int128 _feeMargin = _bal - _threshold;

                fee_ = _feeMargin.us_div(_ideal);
                fee_ = fee_.us_mul(_delta);

                if (fee_ > MAX) fee_ = MAX;

                fee_ = fee_.us_mul(_feeMargin);

            } else fee_ = 0;

        }

    }

    function calculateTrade (
        ComponentStorage.Component storage component,
        int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals,
        int128 _inputAmt,
        uint _outputIndex
    ) internal view returns (int128 outputAmt_) {

        outputAmt_ = - _inputAmt;

        int128 _lambda = component.lambda;
        int128 _beta = component.beta;
        int128 _delta = component.delta;
        int128[] memory _weights = component.weights;

        int128 _omega = calculateFee(_oGLiq, _oBals, _beta, _delta, _weights);
        int128 _psi;

        for (uint i = 0; i < 32; i++) {

            _psi = calculateFee(_nGLiq, _nBals, _beta, _delta, _weights);

            if (( outputAmt_ = _omega < _psi
            ? - ( _inputAmt + _omega - _psi )
            : - ( _inputAmt + _lambda.us_mul(_omega - _psi) )
            ) / 1e13 == outputAmt_ / 1e13 ) {

                _nGLiq = _oGLiq + _inputAmt + outputAmt_;

                _nBals[_outputIndex] = _oBals[_outputIndex] + outputAmt_;

                enforceHalts(component, _oGLiq, _nGLiq, _oBals, _nBals, _weights);

                enforceSwapInvariant(_oGLiq, _omega, _nGLiq, _psi);

                return outputAmt_;

            } else {

                _nGLiq = _oGLiq + _inputAmt + outputAmt_;

                _nBals[_outputIndex] = _oBals[_outputIndex].add(outputAmt_);

            }

        }

        revert("Component/swap-convergence-failed");

    }

    function enforceSwapInvariant (
        int128 _oGLiq,
        int128 _omega,
        int128 _nGLiq,
        int128 _psi
    ) private pure {

        int128 _nextUtil = _nGLiq - _psi;

        int128 _prevUtil = _oGLiq - _omega;

        int128 _diff = _nextUtil - _prevUtil;

        require(0 < _diff || _diff >= MAX_DIFF, "Component/swap-invariant-violation");

    }

    function calculateLiquidityMembrane (
        ComponentStorage.Component storage component,
        int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals
    ) internal view returns (int128 components_) {

        enforceHalts(component, _oGLiq, _nGLiq, _oBals, _nBals, component.weights);

        int128 _omega;
        int128 _psi;

        {

            int128 _beta = component.beta;
            int128 _delta = component.delta;
            int128[] memory _weights = component.weights;

            _omega = calculateFee(_oGLiq, _oBals, _beta, _delta, _weights);
            _psi = calculateFee(_nGLiq, _nBals, _beta, _delta, _weights);

        }

        int128 _feeDiff = _psi.sub(_omega);
        int128 _liqDiff = _nGLiq.sub(_oGLiq);
        int128 _oUtil = _oGLiq.sub(_omega);
        int128 _totalComponents = component.totalSupply.divu(1e18);
        int128 _componentMultiplier;

        if (_totalComponents == 0) {

            components_ = _nGLiq.sub(_psi);

        } else if (_feeDiff >= 0) {

            _componentMultiplier = _liqDiff.sub(_feeDiff).div(_oUtil);

        } else {

            _componentMultiplier = _liqDiff.sub(component.lambda.mul(_feeDiff));

            _componentMultiplier = _componentMultiplier.div(_oUtil);

        }

        if (_totalComponents != 0) {

            components_ = _totalComponents.us_mul(_componentMultiplier);

            enforceLiquidityInvariant(_totalComponents, components_, _oGLiq, _nGLiq, _omega, _psi);

        }

    }

    function enforceLiquidityInvariant (
        int128 _totalComponents,
        int128 _newComponents,
        int128 _oGLiq,
        int128 _nGLiq,
        int128 _omega,
        int128 _psi
    ) internal pure {

        if (_totalComponents == 0 || 0 == _totalComponents + _newComponents) return;

        int128 _prevUtilPerComponent = _oGLiq
        .sub(_omega)
        .div(_totalComponents);

        int128 _nextUtilPerComponent = _nGLiq
        .sub(_psi)
        .div(_totalComponents.add(_newComponents));

        int128 _diff = _nextUtilPerComponent - _prevUtilPerComponent;

        require(0 < _diff || _diff >= MAX_DIFF, "Component/liquidity-invariant-violation");

    }

    function enforceHalts (
        ComponentStorage.Component storage component,
        int128 _oGLiq,
        int128 _nGLiq,
        int128[] memory _oBals,
        int128[] memory _nBals,
        int128[] memory _weights
    ) private view {

        uint256 _length = _nBals.length;
        int128 _alpha = component.alpha;

        for (uint i = 0; i < _length; i++) {

            int128 _nIdeal = _nGLiq.us_mul(_weights[i]);

            if (_nBals[i] > _nIdeal) {

                int128 _upperAlpha = ONE + _alpha;

                int128 _nHalt = _nIdeal.us_mul(_upperAlpha);

                if (_nBals[i] > _nHalt){

                    int128 _oHalt = _oGLiq.us_mul(_weights[i]).us_mul(_upperAlpha);

                    if (_oBals[i] < _oHalt) revert("Component/upper-halt");
                    if (_nBals[i] - _nHalt > _oBals[i] - _oHalt) revert("Component/upper-halt");

                }

            } else {

                int128 _lowerAlpha = ONE - _alpha;

                int128 _nHalt = _nIdeal.us_mul(_lowerAlpha);

                if (_nBals[i] < _nHalt){

                    int128 _oHalt = _oGLiq.us_mul(_weights[i]).us_mul(_lowerAlpha);

                    if (_oBals[i] > _oHalt) revert("Component/lower-halt");
                    if (_nHalt - _nBals[i] > _oHalt - _oBals[i]) revert("Component/lower-halt");

                }
            }
        }
    }
}