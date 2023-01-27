
pragma solidity 0.5.16;

interface IERC20Mintable {

    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);


    function mint(address _to, uint256 _value) external returns (bool);


    function balanceOf(address _account) external view returns (uint256);


    function totalSupply() external view returns (uint256);

}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library ABDKMath64x64 {

    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function fromInt(int256 x) internal pure returns (int128) {

        require(x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
        return int128(x << 64);
    }

    function toInt(int128 x) internal pure returns (int64) {

        return int64(x >> 64);
    }

    function fromUInt(uint256 x) internal pure returns (int128) {

        require(x <= 0x7FFFFFFFFFFFFFFF);
        return int128(x << 64);
    }

    function toUInt(int128 x) internal pure returns (uint64) {

        require(x >= 0);
        return uint64(x >> 64);
    }

    function from128x128(int256 x) internal pure returns (int128) {

        int256 result = x >> 64;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    function to128x128(int128 x) internal pure returns (int256) {

        return int256(x) << 64;
    }

    function add(int128 x, int128 y) internal pure returns (int128) {

        int256 result = int256(x) + y;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    function sub(int128 x, int128 y) internal pure returns (int128) {

        int256 result = int256(x) - y;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    function mul(int128 x, int128 y) internal pure returns (int128) {

        int256 result = (int256(x) * y) >> 64;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    function muli(int128 x, int256 y) internal pure returns (int256) {

        if (x == MIN_64x64) {
            require(
                y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
                    y <= 0x1000000000000000000000000000000000000000000000000
            );
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
            uint256 absoluteResult = mulu(x, uint256(y));
            if (negativeResult) {
                require(absoluteResult <= 0x8000000000000000000000000000000000000000000000000000000000000000);
                return -int256(absoluteResult); // We rely on overflow behavior here
            } else {
                require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                return int256(absoluteResult);
            }
        }
    }

    function mulu(int128 x, uint256 y) internal pure returns (uint256) {

        if (y == 0) return 0;

        require(x >= 0);

        uint256 lo = (uint256(x) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
        uint256 hi = uint256(x) * (y >> 128);

        require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        hi <<= 64;

        require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
        return hi + lo;
    }

    function div(int128 x, int128 y) internal pure returns (int128) {

        require(y != 0);
        int256 result = (int256(x) << 64) / y;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    function divi(int256 x, int256 y) internal pure returns (int128) {

        require(y != 0);

        bool negativeResult = false;
        if (x < 0) {
            x = -x; // We rely on overflow behavior here
            negativeResult = true;
        }
        if (y < 0) {
            y = -y; // We rely on overflow behavior here
            negativeResult = !negativeResult;
        }
        uint128 absoluteResult = divuu(uint256(x), uint256(y));
        if (negativeResult) {
            require(absoluteResult <= 0x80000000000000000000000000000000);
            return -int128(absoluteResult); // We rely on overflow behavior here
        } else {
            require(absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int128(absoluteResult); // We rely on overflow behavior here
        }
    }

    function divu(uint256 x, uint256 y) internal pure returns (int128) {

        require(y != 0);
        uint128 result = divuu(x, y);
        require(result <= uint128(MAX_64x64));
        return int128(result);
    }

    function neg(int128 x) internal pure returns (int128) {

        require(x != MIN_64x64);
        return -x;
    }

    function abs(int128 x) internal pure returns (int128) {

        require(x != MIN_64x64);
        return x < 0 ? -x : x;
    }

    function inv(int128 x) internal pure returns (int128) {

        require(x != 0);
        int256 result = int256(0x100000000000000000000000000000000) / x;
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    function avg(int128 x, int128 y) internal pure returns (int128) {

        return int128((int256(x) + int256(y)) >> 1);
    }

    function gavg(int128 x, int128 y) internal pure returns (int128) {

        int256 m = int256(x) * int256(y);
        require(m >= 0);
        require(m < 0x4000000000000000000000000000000000000000000000000000000000000000);
        return int128(sqrtu(uint256(m)));
    }

    function pow(int128 x, uint256 y) internal pure returns (int128) {

        bool negative = x < 0 && y & 1 == 1;

        uint256 absX = uint128(x < 0 ? -x : x);
        uint256 absResult;
        absResult = 0x100000000000000000000000000000000;

        if (absX <= 0x10000000000000000) {
            absX <<= 63;
            while (y != 0) {
                if (y & 0x1 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                if (y & 0x2 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                if (y & 0x4 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                if (y & 0x8 != 0) {
                    absResult = (absResult * absX) >> 127;
                }
                absX = (absX * absX) >> 127;

                y >>= 4;
            }

            absResult >>= 64;
        } else {
            uint256 absXShift = 63;
            if (absX < 0x1000000000000000000000000) {
                absX <<= 32;
                absXShift -= 32;
            }
            if (absX < 0x10000000000000000000000000000) {
                absX <<= 16;
                absXShift -= 16;
            }
            if (absX < 0x1000000000000000000000000000000) {
                absX <<= 8;
                absXShift -= 8;
            }
            if (absX < 0x10000000000000000000000000000000) {
                absX <<= 4;
                absXShift -= 4;
            }
            if (absX < 0x40000000000000000000000000000000) {
                absX <<= 2;
                absXShift -= 2;
            }
            if (absX < 0x80000000000000000000000000000000) {
                absX <<= 1;
                absXShift -= 1;
            }

            uint256 resultShift = 0;
            while (y != 0) {
                require(absXShift < 64);

                if (y & 0x1 != 0) {
                    absResult = (absResult * absX) >> 127;
                    resultShift += absXShift;
                    if (absResult > 0x100000000000000000000000000000000) {
                        absResult >>= 1;
                        resultShift += 1;
                    }
                }
                absX = (absX * absX) >> 127;
                absXShift <<= 1;
                if (absX >= 0x100000000000000000000000000000000) {
                    absX >>= 1;
                    absXShift += 1;
                }

                y >>= 1;
            }

            require(resultShift < 64);
            absResult >>= 64 - resultShift;
        }
        int256 result = negative ? -int256(absResult) : int256(absResult);
        require(result >= MIN_64x64 && result <= MAX_64x64);
        return int128(result);
    }

    function sqrt(int128 x) internal pure returns (int128) {

        require(x >= 0);
        return int128(sqrtu(uint256(x) << 64));
    }

    function log_2(int128 x) internal pure returns (int128) {

        require(x > 0);

        int256 msb = 0;
        int256 xc = x;
        if (xc >= 0x10000000000000000) {
            xc >>= 64;
            msb += 64;
        }
        if (xc >= 0x100000000) {
            xc >>= 32;
            msb += 32;
        }
        if (xc >= 0x10000) {
            xc >>= 16;
            msb += 16;
        }
        if (xc >= 0x100) {
            xc >>= 8;
            msb += 8;
        }
        if (xc >= 0x10) {
            xc >>= 4;
            msb += 4;
        }
        if (xc >= 0x4) {
            xc >>= 2;
            msb += 2;
        }
        if (xc >= 0x2) msb += 1; // No need to shift xc anymore

        int256 result = (msb - 64) << 64;
        uint256 ux = uint256(x) << uint256(127 - msb);
        for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
            ux *= ux;
            uint256 b = ux >> 255;
            ux >>= 127 + b;
            result += bit * int256(b);
        }

        return int128(result);
    }

    function ln(int128 x) internal pure returns (int128) {

        require(x > 0);

        return int128((uint256(log_2(x)) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF) >> 128);
    }

    function exp_2(int128 x) internal pure returns (int128) {

        require(x < 0x400000000000000000); // Overflow

        if (x < -0x400000000000000000) return 0; // Underflow

        uint256 result = 0x80000000000000000000000000000000;

        if (x & 0x8000000000000000 > 0) result = (result * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
        if (x & 0x4000000000000000 > 0) result = (result * 0x1306FE0A31B7152DE8D5A46305C85EDEC) >> 128;
        if (x & 0x2000000000000000 > 0) result = (result * 0x1172B83C7D517ADCDF7C8C50EB14A791F) >> 128;
        if (x & 0x1000000000000000 > 0) result = (result * 0x10B5586CF9890F6298B92B71842A98363) >> 128;
        if (x & 0x800000000000000 > 0) result = (result * 0x1059B0D31585743AE7C548EB68CA417FD) >> 128;
        if (x & 0x400000000000000 > 0) result = (result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8) >> 128;
        if (x & 0x200000000000000 > 0) result = (result * 0x10163DA9FB33356D84A66AE336DCDFA3F) >> 128;
        if (x & 0x100000000000000 > 0) result = (result * 0x100B1AFA5ABCBED6129AB13EC11DC9543) >> 128;
        if (x & 0x80000000000000 > 0) result = (result * 0x10058C86DA1C09EA1FF19D294CF2F679B) >> 128;
        if (x & 0x40000000000000 > 0) result = (result * 0x1002C605E2E8CEC506D21BFC89A23A00F) >> 128;
        if (x & 0x20000000000000 > 0) result = (result * 0x100162F3904051FA128BCA9C55C31E5DF) >> 128;
        if (x & 0x10000000000000 > 0) result = (result * 0x1000B175EFFDC76BA38E31671CA939725) >> 128;
        if (x & 0x8000000000000 > 0) result = (result * 0x100058BA01FB9F96D6CACD4B180917C3D) >> 128;
        if (x & 0x4000000000000 > 0) result = (result * 0x10002C5CC37DA9491D0985C348C68E7B3) >> 128;
        if (x & 0x2000000000000 > 0) result = (result * 0x1000162E525EE054754457D5995292026) >> 128;
        if (x & 0x1000000000000 > 0) result = (result * 0x10000B17255775C040618BF4A4ADE83FC) >> 128;
        if (x & 0x800000000000 > 0) result = (result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB) >> 128;
        if (x & 0x400000000000 > 0) result = (result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9) >> 128;
        if (x & 0x200000000000 > 0) result = (result * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
        if (x & 0x100000000000 > 0) result = (result * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
        if (x & 0x80000000000 > 0) result = (result * 0x10000058B90CF1E6D97F9CA14DBCC1628) >> 128;
        if (x & 0x40000000000 > 0) result = (result * 0x1000002C5C863B73F016468F6BAC5CA2B) >> 128;
        if (x & 0x20000000000 > 0) result = (result * 0x100000162E430E5A18F6119E3C02282A5) >> 128;
        if (x & 0x10000000000 > 0) result = (result * 0x1000000B1721835514B86E6D96EFD1BFE) >> 128;
        if (x & 0x8000000000 > 0) result = (result * 0x100000058B90C0B48C6BE5DF846C5B2EF) >> 128;
        if (x & 0x4000000000 > 0) result = (result * 0x10000002C5C8601CC6B9E94213C72737A) >> 128;
        if (x & 0x2000000000 > 0) result = (result * 0x1000000162E42FFF037DF38AA2B219F06) >> 128;
        if (x & 0x1000000000 > 0) result = (result * 0x10000000B17217FBA9C739AA5819F44F9) >> 128;
        if (x & 0x800000000 > 0) result = (result * 0x1000000058B90BFCDEE5ACD3C1CEDC823) >> 128;
        if (x & 0x400000000 > 0) result = (result * 0x100000002C5C85FE31F35A6A30DA1BE50) >> 128;
        if (x & 0x200000000 > 0) result = (result * 0x10000000162E42FF0999CE3541B9FFFCF) >> 128;
        if (x & 0x100000000 > 0) result = (result * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
        if (x & 0x80000000 > 0) result = (result * 0x10000000058B90BFBF8479BD5A81B51AD) >> 128;
        if (x & 0x40000000 > 0) result = (result * 0x1000000002C5C85FDF84BD62AE30A74CC) >> 128;
        if (x & 0x20000000 > 0) result = (result * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
        if (x & 0x10000000 > 0) result = (result * 0x1000000000B17217F7D5A7716BBA4A9AE) >> 128;
        if (x & 0x8000000 > 0) result = (result * 0x100000000058B90BFBE9DDBAC5E109CCE) >> 128;
        if (x & 0x4000000 > 0) result = (result * 0x10000000002C5C85FDF4B15DE6F17EB0D) >> 128;
        if (x & 0x2000000 > 0) result = (result * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
        if (x & 0x1000000 > 0) result = (result * 0x10000000000B17217F7D20CF927C8E94C) >> 128;
        if (x & 0x800000 > 0) result = (result * 0x1000000000058B90BFBE8F71CB4E4B33D) >> 128;
        if (x & 0x400000 > 0) result = (result * 0x100000000002C5C85FDF477B662B26945) >> 128;
        if (x & 0x200000 > 0) result = (result * 0x10000000000162E42FEFA3AE53369388C) >> 128;
        if (x & 0x100000 > 0) result = (result * 0x100000000000B17217F7D1D351A389D40) >> 128;
        if (x & 0x80000 > 0) result = (result * 0x10000000000058B90BFBE8E8B2D3D4EDE) >> 128;
        if (x & 0x40000 > 0) result = (result * 0x1000000000002C5C85FDF4741BEA6E77E) >> 128;
        if (x & 0x20000 > 0) result = (result * 0x100000000000162E42FEFA39FE95583C2) >> 128;
        if (x & 0x10000 > 0) result = (result * 0x1000000000000B17217F7D1CFB72B45E1) >> 128;
        if (x & 0x8000 > 0) result = (result * 0x100000000000058B90BFBE8E7CC35C3F0) >> 128;
        if (x & 0x4000 > 0) result = (result * 0x10000000000002C5C85FDF473E242EA38) >> 128;
        if (x & 0x2000 > 0) result = (result * 0x1000000000000162E42FEFA39F02B772C) >> 128;
        if (x & 0x1000 > 0) result = (result * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
        if (x & 0x800 > 0) result = (result * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
        if (x & 0x400 > 0) result = (result * 0x100000000000002C5C85FDF473DEA871F) >> 128;
        if (x & 0x200 > 0) result = (result * 0x10000000000000162E42FEFA39EF44D91) >> 128;
        if (x & 0x100 > 0) result = (result * 0x100000000000000B17217F7D1CF79E949) >> 128;
        if (x & 0x80 > 0) result = (result * 0x10000000000000058B90BFBE8E7BCE544) >> 128;
        if (x & 0x40 > 0) result = (result * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
        if (x & 0x20 > 0) result = (result * 0x100000000000000162E42FEFA39EF366F) >> 128;
        if (x & 0x10 > 0) result = (result * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
        if (x & 0x8 > 0) result = (result * 0x100000000000000058B90BFBE8E7BCD6D) >> 128;
        if (x & 0x4 > 0) result = (result * 0x10000000000000002C5C85FDF473DE6B2) >> 128;
        if (x & 0x2 > 0) result = (result * 0x1000000000000000162E42FEFA39EF358) >> 128;
        if (x & 0x1 > 0) result = (result * 0x10000000000000000B17217F7D1CF79AB) >> 128;

        result >>= uint256(63 - (x >> 64));
        require(result <= uint256(MAX_64x64));

        return int128(result);
    }

    function exp(int128 x) internal pure returns (int128) {

        require(x < 0x400000000000000000); // Overflow

        if (x < -0x400000000000000000) return 0; // Underflow

        return exp_2(int128((int256(x) * 0x171547652B82FE1777D0FFDA0D23A7D12) >> 128));
    }

    function divuu(uint256 x, uint256 y) private pure returns (uint128) {

        require(y != 0);

        uint256 result;

        if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) result = (x << 64) / y;
        else {
            uint256 msb = 192;
            uint256 xc = x >> 192;
            if (xc >= 0x100000000) {
                xc >>= 32;
                msb += 32;
            }
            if (xc >= 0x10000) {
                xc >>= 16;
                msb += 16;
            }
            if (xc >= 0x100) {
                xc >>= 8;
                msb += 8;
            }
            if (xc >= 0x10) {
                xc >>= 4;
                msb += 4;
            }
            if (xc >= 0x4) {
                xc >>= 2;
                msb += 2;
            }
            if (xc >= 0x2) msb += 1; // No need to shift xc anymore

            result = (x << (255 - msb)) / (((y - 1) >> (msb - 191)) + 1);
            require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

            uint256 hi = result * (y >> 128);
            uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

            uint256 xh = x >> 192;
            uint256 xl = x << 64;

            if (xl < lo) xh -= 1;
            xl -= lo; // We rely on overflow behavior here
            lo = hi << 128;
            if (xl < lo) xh -= 1;
            xl -= lo; // We rely on overflow behavior here

            assert(xh == hi >> 128);

            result += xl / y;
        }

        require(result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return uint128(result);
    }

    function sqrtu(uint256 x) private pure returns (uint128) {

        if (x == 0) return 0;
        else {
            uint256 xx = x;
            uint256 r = 1;
            if (xx >= 0x100000000000000000000000000000000) {
                xx >>= 128;
                r <<= 64;
            }
            if (xx >= 0x10000000000000000) {
                xx >>= 64;
                r <<= 32;
            }
            if (xx >= 0x100000000) {
                xx >>= 32;
                r <<= 16;
            }
            if (xx >= 0x10000) {
                xx >>= 16;
                r <<= 8;
            }
            if (xx >= 0x100) {
                xx >>= 8;
                r <<= 4;
            }
            if (xx >= 0x10) {
                xx >>= 4;
                r <<= 2;
            }
            if (xx >= 0x8) {
                r <<= 1;
            }
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1; // Seven iterations should be enough
            uint256 r1 = x / r;
            return uint128(r < r1 ? r : r1);
        }
    }
}

library ABDKMathQuad {

    bytes16 private constant POSITIVE_ZERO = 0x00000000000000000000000000000000;

    bytes16 private constant NEGATIVE_ZERO = 0x80000000000000000000000000000000;

    bytes16 private constant POSITIVE_INFINITY = 0x7FFF0000000000000000000000000000;

    bytes16 private constant NEGATIVE_INFINITY = 0xFFFF0000000000000000000000000000;

    bytes16 private constant NaN = 0x7FFF8000000000000000000000000000;

    function fromInt(int256 x) internal pure returns (bytes16) {

        if (x == 0) return bytes16(0);
        else {
            uint256 result = uint256(x > 0 ? x : -x);

            uint256 msb = msb(result);
            if (msb < 112) result <<= 112 - msb;
            else if (msb > 112) result >>= msb - 112;

            result = (result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | ((16383 + msb) << 112);
            if (x < 0) result |= 0x80000000000000000000000000000000;

            return bytes16(uint128(result));
        }
    }

    function toInt(bytes16 x) internal pure returns (int256) {

        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;

        require(exponent <= 16638); // Overflow
        if (exponent < 16383) return 0; // Underflow

        uint256 result = (uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | 0x10000000000000000000000000000;

        if (exponent < 16495) result >>= 16495 - exponent;
        else if (exponent > 16495) result <<= exponent - 16495;

        if (uint128(x) >= 0x80000000000000000000000000000000) {
            require(result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
            return -int256(result); // We rely on overflow behavior here
        } else {
            require(result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int256(result);
        }
    }

    function fromUInt(uint256 x) internal pure returns (bytes16) {

        if (x == 0) return bytes16(0);
        else {
            uint256 result = x;

            uint256 msb = msb(result);
            if (msb < 112) result <<= 112 - msb;
            else if (msb > 112) result >>= msb - 112;

            result = (result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | ((16383 + msb) << 112);

            return bytes16(uint128(result));
        }
    }

    function toUInt(bytes16 x) internal pure returns (uint256) {

        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;

        if (exponent < 16383) return 0; // Underflow

        require(uint128(x) < 0x80000000000000000000000000000000); // Negative

        require(exponent <= 16638); // Overflow
        uint256 result = (uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | 0x10000000000000000000000000000;

        if (exponent < 16495) result >>= 16495 - exponent;
        else if (exponent > 16495) result <<= exponent - 16495;

        return result;
    }

    function from128x128(int256 x) internal pure returns (bytes16) {

        if (x == 0) return bytes16(0);
        else {
            uint256 result = uint256(x > 0 ? x : -x);

            uint256 msb = msb(result);
            if (msb < 112) result <<= 112 - msb;
            else if (msb > 112) result >>= msb - 112;

            result = (result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | ((16255 + msb) << 112);
            if (x < 0) result |= 0x80000000000000000000000000000000;

            return bytes16(uint128(result));
        }
    }

    function to128x128(bytes16 x) internal pure returns (int256) {

        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;

        require(exponent <= 16510); // Overflow
        if (exponent < 16255) return 0; // Underflow

        uint256 result = (uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | 0x10000000000000000000000000000;

        if (exponent < 16367) result >>= 16367 - exponent;
        else if (exponent > 16367) result <<= exponent - 16367;

        if (uint128(x) >= 0x80000000000000000000000000000000) {
            require(result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
            return -int256(result); // We rely on overflow behavior here
        } else {
            require(result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int256(result);
        }
    }

    function from64x64(int128 x) internal pure returns (bytes16) {

        if (x == 0) return bytes16(0);
        else {
            uint256 result = uint128(x > 0 ? x : -x);

            uint256 msb = msb(result);
            if (msb < 112) result <<= 112 - msb;
            else if (msb > 112) result >>= msb - 112;

            result = (result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | ((16319 + msb) << 112);
            if (x < 0) result |= 0x80000000000000000000000000000000;

            return bytes16(uint128(result));
        }
    }

    function to64x64(bytes16 x) internal pure returns (int128) {

        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;

        require(exponent <= 16446); // Overflow
        if (exponent < 16319) return 0; // Underflow

        uint256 result = (uint256(uint128(x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF) | 0x10000000000000000000000000000;

        if (exponent < 16431) result >>= 16431 - exponent;
        else if (exponent > 16431) result <<= exponent - 16431;

        if (uint128(x) >= 0x80000000000000000000000000000000) {
            require(result <= 0x80000000000000000000000000000000);
            return -int128(result); // We rely on overflow behavior here
        } else {
            require(result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
            return int128(result);
        }
    }

    function fromOctuple(bytes32 x) internal pure returns (bytes16) {

        bool negative = x & 0x8000000000000000000000000000000000000000000000000000000000000000 > 0;

        uint256 exponent = (uint256(x) >> 236) & 0x7FFFF;
        uint256 significand = uint256(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        if (exponent == 0x7FFFF) {
            if (significand > 0) return NaN;
            else return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
        }

        if (exponent > 278526) return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
        else if (exponent < 245649) return negative ? NEGATIVE_ZERO : POSITIVE_ZERO;
        else if (exponent < 245761) {
            significand =
                (significand | 0x100000000000000000000000000000000000000000000000000000000000) >>
                (245885 - exponent);
            exponent = 0;
        } else {
            significand >>= 124;
            exponent -= 245760;
        }

        uint128 result = uint128(significand | (exponent << 112));
        if (negative) result |= 0x80000000000000000000000000000000;

        return bytes16(result);
    }

    function toOctuple(bytes16 x) internal pure returns (bytes32) {

        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;

        uint256 result = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        if (exponent == 0x7FFF)
            exponent = 0x7FFFF; // Infinity or NaN
        else if (exponent == 0) {
            if (result > 0) {
                uint256 msb = msb(result);
                result = (result << (236 - msb)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                exponent = 245649 + msb;
            }
        } else {
            result <<= 124;
            exponent += 245760;
        }

        result |= exponent << 236;
        if (uint128(x) >= 0x80000000000000000000000000000000)
            result |= 0x8000000000000000000000000000000000000000000000000000000000000000;

        return bytes32(result);
    }

    function fromDouble(bytes8 x) internal pure returns (bytes16) {

        uint256 exponent = (uint64(x) >> 52) & 0x7FF;

        uint256 result = uint64(x) & 0xFFFFFFFFFFFFF;

        if (exponent == 0x7FF)
            exponent = 0x7FFF; // Infinity or NaN
        else if (exponent == 0) {
            if (result > 0) {
                uint256 msb = msb(result);
                result = (result << (112 - msb)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                exponent = 15309 + msb;
            }
        } else {
            result <<= 60;
            exponent += 15360;
        }

        result |= exponent << 112;
        if (x & 0x8000000000000000 > 0) result |= 0x80000000000000000000000000000000;

        return bytes16(uint128(result));
    }

    function toDouble(bytes16 x) internal pure returns (bytes8) {

        bool negative = uint128(x) >= 0x80000000000000000000000000000000;

        uint256 exponent = (uint128(x) >> 112) & 0x7FFF;
        uint256 significand = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        if (exponent == 0x7FFF) {
            if (significand > 0) return 0x7FF8000000000000;
            else
                return
                    negative
                        ? bytes8(0xFFF0000000000000) // -Infinity
                        : bytes8(0x7FF0000000000000); // Infinity
        }

        if (exponent > 17406)
            return
                negative
                    ? bytes8(0xFFF0000000000000) // -Infinity
                    : bytes8(0x7FF0000000000000);
        else if (exponent < 15309)
            return
                negative
                    ? bytes8(0x8000000000000000) // -0
                    : bytes8(0x0000000000000000);
        else if (exponent < 15361) {
            significand = (significand | 0x10000000000000000000000000000) >> (15421 - exponent);
            exponent = 0;
        } else {
            significand >>= 60;
            exponent -= 15360;
        }

        uint64 result = uint64(significand | (exponent << 52));
        if (negative) result |= 0x8000000000000000;

        return bytes8(result);
    }

    function isNaN(bytes16 x) internal pure returns (bool) {

        return uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF > 0x7FFF0000000000000000000000000000;
    }

    function isInfinity(bytes16 x) internal pure returns (bool) {

        return uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0x7FFF0000000000000000000000000000;
    }

    function sign(bytes16 x) internal pure returns (int8) {

        uint128 absoluteX = uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        require(absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

        if (absoluteX == 0) return 0;
        else if (uint128(x) >= 0x80000000000000000000000000000000) return -1;
        else return 1;
    }

    function cmp(bytes16 x, bytes16 y) internal pure returns (int8) {

        uint128 absoluteX = uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        require(absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

        uint128 absoluteY = uint128(y) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        require(absoluteY <= 0x7FFF0000000000000000000000000000); // Not NaN

        require(x != y || absoluteX < 0x7FFF0000000000000000000000000000);

        if (x == y) return 0;
        else {
            bool negativeX = uint128(x) >= 0x80000000000000000000000000000000;
            bool negativeY = uint128(y) >= 0x80000000000000000000000000000000;

            if (negativeX) {
                if (negativeY) return absoluteX > absoluteY ? -1 : int8(1);
                else return -1;
            } else {
                if (negativeY) return 1;
                else return absoluteX > absoluteY ? int8(1) : -1;
            }
        }
    }

    function eq(bytes16 x, bytes16 y) internal pure returns (bool) {

        if (x == y) {
            return uint128(x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF < 0x7FFF0000000000000000000000000000;
        } else return false;
    }

    function add(bytes16 x, bytes16 y) internal pure returns (bytes16) {

        uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
        uint256 yExponent = (uint128(y) >> 112) & 0x7FFF;

        if (xExponent == 0x7FFF) {
            if (yExponent == 0x7FFF) {
                if (x == y) return x;
                else return NaN;
            } else return x;
        } else if (yExponent == 0x7FFF) return y;
        else {
            bool xSign = uint128(x) >= 0x80000000000000000000000000000000;
            uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (xExponent == 0) xExponent = 1;
            else xSignifier |= 0x10000000000000000000000000000;

            bool ySign = uint128(y) >= 0x80000000000000000000000000000000;
            uint256 ySignifier = uint128(y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (yExponent == 0) yExponent = 1;
            else ySignifier |= 0x10000000000000000000000000000;

            if (xSignifier == 0) return y == NEGATIVE_ZERO ? POSITIVE_ZERO : y;
            else if (ySignifier == 0) return x == NEGATIVE_ZERO ? POSITIVE_ZERO : x;
            else {
                int256 delta = int256(xExponent) - int256(yExponent);

                if (xSign == ySign) {
                    if (delta > 112) return x;
                    else if (delta > 0) ySignifier >>= uint256(delta);
                    else if (delta < -112) return y;
                    else if (delta < 0) {
                        xSignifier >>= uint256(-delta);
                        xExponent = yExponent;
                    }

                    xSignifier += ySignifier;

                    if (xSignifier >= 0x20000000000000000000000000000) {
                        xSignifier >>= 1;
                        xExponent += 1;
                    }

                    if (xExponent == 0x7FFF) return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
                    else {
                        if (xSignifier < 0x10000000000000000000000000000) xExponent = 0;
                        else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                        return
                            bytes16(
                                uint128(
                                    (xSign ? 0x80000000000000000000000000000000 : 0) | (xExponent << 112) | xSignifier
                                )
                            );
                    }
                } else {
                    if (delta > 0) {
                        xSignifier <<= 1;
                        xExponent -= 1;
                    } else if (delta < 0) {
                        ySignifier <<= 1;
                        xExponent = yExponent - 1;
                    }

                    if (delta > 112) ySignifier = 1;
                    else if (delta > 1) ySignifier = ((ySignifier - 1) >> uint256(delta - 1)) + 1;
                    else if (delta < -112) xSignifier = 1;
                    else if (delta < -1) xSignifier = ((xSignifier - 1) >> uint256(-delta - 1)) + 1;

                    if (xSignifier >= ySignifier) xSignifier -= ySignifier;
                    else {
                        xSignifier = ySignifier - xSignifier;
                        xSign = ySign;
                    }

                    if (xSignifier == 0) return POSITIVE_ZERO;

                    uint256 msb = msb(xSignifier);

                    if (msb == 113) {
                        xSignifier = (xSignifier >> 1) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                        xExponent += 1;
                    } else if (msb < 112) {
                        uint256 shift = 112 - msb;
                        if (xExponent > shift) {
                            xSignifier = (xSignifier << shift) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                            xExponent -= shift;
                        } else {
                            xSignifier <<= xExponent - 1;
                            xExponent = 0;
                        }
                    } else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                    if (xExponent == 0x7FFF) return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
                    else
                        return
                            bytes16(
                                uint128(
                                    (xSign ? 0x80000000000000000000000000000000 : 0) | (xExponent << 112) | xSignifier
                                )
                            );
                }
            }
        }
    }

    function sub(bytes16 x, bytes16 y) internal pure returns (bytes16) {

        return add(x, y ^ 0x80000000000000000000000000000000);
    }

    function mul(bytes16 x, bytes16 y) internal pure returns (bytes16) {

        uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
        uint256 yExponent = (uint128(y) >> 112) & 0x7FFF;

        if (xExponent == 0x7FFF) {
            if (yExponent == 0x7FFF) {
                if (x == y) return x ^ (y & 0x80000000000000000000000000000000);
                else if (x ^ y == 0x80000000000000000000000000000000) return x | y;
                else return NaN;
            } else {
                if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
                else return x ^ (y & 0x80000000000000000000000000000000);
            }
        } else if (yExponent == 0x7FFF) {
            if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
            else return y ^ (x & 0x80000000000000000000000000000000);
        } else {
            uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (xExponent == 0) xExponent = 1;
            else xSignifier |= 0x10000000000000000000000000000;

            uint256 ySignifier = uint128(y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (yExponent == 0) yExponent = 1;
            else ySignifier |= 0x10000000000000000000000000000;

            xSignifier *= ySignifier;
            if (xSignifier == 0)
                return (x ^ y) & 0x80000000000000000000000000000000 > 0 ? NEGATIVE_ZERO : POSITIVE_ZERO;

            xExponent += yExponent;

            uint256 msb = xSignifier >= 0x200000000000000000000000000000000000000000000000000000000
                ? 225
                : xSignifier >= 0x100000000000000000000000000000000000000000000000000000000
                ? 224
                : msb(xSignifier);

            if (xExponent + msb < 16496) {
                xExponent = 0;
                xSignifier = 0;
            } else if (xExponent + msb < 16608) {
                if (xExponent < 16496) xSignifier >>= 16496 - xExponent;
                else if (xExponent > 16496) xSignifier <<= xExponent - 16496;
                xExponent = 0;
            } else if (xExponent + msb > 49373) {
                xExponent = 0x7FFF;
                xSignifier = 0;
            } else {
                if (msb > 112) xSignifier >>= msb - 112;
                else if (msb < 112) xSignifier <<= 112 - msb;

                xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                xExponent = xExponent + msb - 16607;
            }

            return
                bytes16(
                    uint128(uint128((x ^ y) & 0x80000000000000000000000000000000) | (xExponent << 112) | xSignifier)
                );
        }
    }

    function div(bytes16 x, bytes16 y) internal pure returns (bytes16) {

        uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
        uint256 yExponent = (uint128(y) >> 112) & 0x7FFF;

        if (xExponent == 0x7FFF) {
            if (yExponent == 0x7FFF) return NaN;
            else return x ^ (y & 0x80000000000000000000000000000000);
        } else if (yExponent == 0x7FFF) {
            if (y & 0x0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF != 0) return NaN;
            else return POSITIVE_ZERO | ((x ^ y) & 0x80000000000000000000000000000000);
        } else if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) {
            if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
            else return POSITIVE_INFINITY | ((x ^ y) & 0x80000000000000000000000000000000);
        } else {
            uint256 ySignifier = uint128(y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (yExponent == 0) yExponent = 1;
            else ySignifier |= 0x10000000000000000000000000000;

            uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (xExponent == 0) {
                if (xSignifier != 0) {
                    uint256 shift = 226 - msb(xSignifier);

                    xSignifier <<= shift;

                    xExponent = 1;
                    yExponent += shift - 114;
                }
            } else {
                xSignifier = (xSignifier | 0x10000000000000000000000000000) << 114;
            }

            xSignifier = xSignifier / ySignifier;
            if (xSignifier == 0)
                return (x ^ y) & 0x80000000000000000000000000000000 > 0 ? NEGATIVE_ZERO : POSITIVE_ZERO;

            assert(xSignifier >= 0x1000000000000000000000000000);

            uint256 msb = xSignifier >= 0x80000000000000000000000000000
                ? msb(xSignifier)
                : xSignifier >= 0x40000000000000000000000000000
                ? 114
                : xSignifier >= 0x20000000000000000000000000000
                ? 113
                : 112;

            if (xExponent + msb > yExponent + 16497) {
                xExponent = 0x7FFF;
                xSignifier = 0;
            } else if (xExponent + msb + 16380 < yExponent) {
                xExponent = 0;
                xSignifier = 0;
            } else if (xExponent + msb + 16268 < yExponent) {
                if (xExponent + 16380 > yExponent) xSignifier <<= xExponent + 16380 - yExponent;
                else if (xExponent + 16380 < yExponent) xSignifier >>= yExponent - xExponent - 16380;

                xExponent = 0;
            } else {
                if (msb > 112) xSignifier >>= msb - 112;

                xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

                xExponent = xExponent + msb + 16269 - yExponent;
            }

            return
                bytes16(
                    uint128(uint128((x ^ y) & 0x80000000000000000000000000000000) | (xExponent << 112) | xSignifier)
                );
        }
    }

    function neg(bytes16 x) internal pure returns (bytes16) {

        return x ^ 0x80000000000000000000000000000000;
    }

    function abs(bytes16 x) internal pure returns (bytes16) {

        return x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    }

    function sqrt(bytes16 x) internal pure returns (bytes16) {

        if (uint128(x) > 0x80000000000000000000000000000000) return NaN;
        else {
            uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
            if (xExponent == 0x7FFF) return x;
            else {
                uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if (xExponent == 0) xExponent = 1;
                else xSignifier |= 0x10000000000000000000000000000;

                if (xSignifier == 0) return POSITIVE_ZERO;

                bool oddExponent = xExponent & 0x1 == 0;
                xExponent = (xExponent + 16383) >> 1;

                if (oddExponent) {
                    if (xSignifier >= 0x10000000000000000000000000000) xSignifier <<= 113;
                    else {
                        uint256 msb = msb(xSignifier);
                        uint256 shift = (226 - msb) & 0xFE;
                        xSignifier <<= shift;
                        xExponent -= (shift - 112) >> 1;
                    }
                } else {
                    if (xSignifier >= 0x10000000000000000000000000000) xSignifier <<= 112;
                    else {
                        uint256 msb = msb(xSignifier);
                        uint256 shift = (225 - msb) & 0xFE;
                        xSignifier <<= shift;
                        xExponent -= (shift - 112) >> 1;
                    }
                }

                uint256 r = 0x10000000000000000000000000000;
                r = (r + xSignifier / r) >> 1;
                r = (r + xSignifier / r) >> 1;
                r = (r + xSignifier / r) >> 1;
                r = (r + xSignifier / r) >> 1;
                r = (r + xSignifier / r) >> 1;
                r = (r + xSignifier / r) >> 1;
                r = (r + xSignifier / r) >> 1; // Seven iterations should be enough
                uint256 r1 = xSignifier / r;
                if (r1 < r) r = r1;

                return bytes16(uint128((xExponent << 112) | (r & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF)));
            }
        }
    }

    function log_2(bytes16 x) internal pure returns (bytes16) {

        if (uint128(x) > 0x80000000000000000000000000000000) return NaN;
        else if (x == 0x3FFF0000000000000000000000000000) return POSITIVE_ZERO;
        else {
            uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
            if (xExponent == 0x7FFF) return x;
            else {
                uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                if (xExponent == 0) xExponent = 1;
                else xSignifier |= 0x10000000000000000000000000000;

                if (xSignifier == 0) return NEGATIVE_INFINITY;

                bool resultNegative;
                uint256 resultExponent = 16495;
                uint256 resultSignifier;

                if (xExponent >= 0x3FFF) {
                    resultNegative = false;
                    resultSignifier = xExponent - 0x3FFF;
                    xSignifier <<= 15;
                } else {
                    resultNegative = true;
                    if (xSignifier >= 0x10000000000000000000000000000) {
                        resultSignifier = 0x3FFE - xExponent;
                        xSignifier <<= 15;
                    } else {
                        uint256 msb = msb(xSignifier);
                        resultSignifier = 16493 - msb;
                        xSignifier <<= 127 - msb;
                    }
                }

                if (xSignifier == 0x80000000000000000000000000000000) {
                    if (resultNegative) resultSignifier += 1;
                    uint256 shift = 112 - msb(resultSignifier);
                    resultSignifier <<= shift;
                    resultExponent -= shift;
                } else {
                    uint256 bb = resultNegative ? 1 : 0;
                    while (resultSignifier < 0x10000000000000000000000000000) {
                        resultSignifier <<= 1;
                        resultExponent -= 1;

                        xSignifier *= xSignifier;
                        uint256 b = xSignifier >> 255;
                        resultSignifier += b ^ bb;
                        xSignifier >>= 127 + b;
                    }
                }

                return
                    bytes16(
                        uint128(
                            (resultNegative ? 0x80000000000000000000000000000000 : 0) |
                                (resultExponent << 112) |
                                (resultSignifier & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
                        )
                    );
            }
        }
    }

    function ln(bytes16 x) internal pure returns (bytes16) {

        return mul(log_2(x), 0x3FFE62E42FEFA39EF35793C7673007E5);
    }

    function pow_2(bytes16 x) internal pure returns (bytes16) {

        bool xNegative = uint128(x) > 0x80000000000000000000000000000000;
        uint256 xExponent = (uint128(x) >> 112) & 0x7FFF;
        uint256 xSignifier = uint128(x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        if (xExponent == 0x7FFF && xSignifier != 0) return NaN;
        else if (xExponent > 16397) return xNegative ? POSITIVE_ZERO : POSITIVE_INFINITY;
        else if (xExponent < 16255) return 0x3FFF0000000000000000000000000000;
        else {
            if (xExponent == 0) xExponent = 1;
            else xSignifier |= 0x10000000000000000000000000000;

            if (xExponent > 16367) xSignifier <<= xExponent - 16367;
            else if (xExponent < 16367) xSignifier >>= 16367 - xExponent;

            if (xNegative && xSignifier > 0x406E00000000000000000000000000000000) return POSITIVE_ZERO;

            if (!xNegative && xSignifier > 0x3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) return POSITIVE_INFINITY;

            uint256 resultExponent = xSignifier >> 128;
            xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            if (xNegative && xSignifier != 0) {
                xSignifier = ~xSignifier;
                resultExponent += 1;
            }

            uint256 resultSignifier = 0x80000000000000000000000000000000;
            if (xSignifier & 0x80000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
            if (xSignifier & 0x40000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1306FE0A31B7152DE8D5A46305C85EDEC) >> 128;
            if (xSignifier & 0x20000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1172B83C7D517ADCDF7C8C50EB14A791F) >> 128;
            if (xSignifier & 0x10000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10B5586CF9890F6298B92B71842A98363) >> 128;
            if (xSignifier & 0x8000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1059B0D31585743AE7C548EB68CA417FD) >> 128;
            if (xSignifier & 0x4000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x102C9A3E778060EE6F7CACA4F7A29BDE8) >> 128;
            if (xSignifier & 0x2000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10163DA9FB33356D84A66AE336DCDFA3F) >> 128;
            if (xSignifier & 0x1000000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100B1AFA5ABCBED6129AB13EC11DC9543) >> 128;
            if (xSignifier & 0x800000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10058C86DA1C09EA1FF19D294CF2F679B) >> 128;
            if (xSignifier & 0x400000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1002C605E2E8CEC506D21BFC89A23A00F) >> 128;
            if (xSignifier & 0x200000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100162F3904051FA128BCA9C55C31E5DF) >> 128;
            if (xSignifier & 0x100000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000B175EFFDC76BA38E31671CA939725) >> 128;
            if (xSignifier & 0x80000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100058BA01FB9F96D6CACD4B180917C3D) >> 128;
            if (xSignifier & 0x40000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10002C5CC37DA9491D0985C348C68E7B3) >> 128;
            if (xSignifier & 0x20000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000162E525EE054754457D5995292026) >> 128;
            if (xSignifier & 0x10000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000B17255775C040618BF4A4ADE83FC) >> 128;
            if (xSignifier & 0x8000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB) >> 128;
            if (xSignifier & 0x4000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9) >> 128;
            if (xSignifier & 0x2000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
            if (xSignifier & 0x1000000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
            if (xSignifier & 0x800000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000058B90CF1E6D97F9CA14DBCC1628) >> 128;
            if (xSignifier & 0x400000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000002C5C863B73F016468F6BAC5CA2B) >> 128;
            if (xSignifier & 0x200000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000162E430E5A18F6119E3C02282A5) >> 128;
            if (xSignifier & 0x100000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000B1721835514B86E6D96EFD1BFE) >> 128;
            if (xSignifier & 0x80000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000058B90C0B48C6BE5DF846C5B2EF) >> 128;
            if (xSignifier & 0x40000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000002C5C8601CC6B9E94213C72737A) >> 128;
            if (xSignifier & 0x20000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000162E42FFF037DF38AA2B219F06) >> 128;
            if (xSignifier & 0x10000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000B17217FBA9C739AA5819F44F9) >> 128;
            if (xSignifier & 0x8000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000058B90BFCDEE5ACD3C1CEDC823) >> 128;
            if (xSignifier & 0x4000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000002C5C85FE31F35A6A30DA1BE50) >> 128;
            if (xSignifier & 0x2000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000162E42FF0999CE3541B9FFFCF) >> 128;
            if (xSignifier & 0x1000000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
            if (xSignifier & 0x800000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000058B90BFBF8479BD5A81B51AD) >> 128;
            if (xSignifier & 0x400000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000002C5C85FDF84BD62AE30A74CC) >> 128;
            if (xSignifier & 0x200000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
            if (xSignifier & 0x100000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000B17217F7D5A7716BBA4A9AE) >> 128;
            if (xSignifier & 0x80000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000058B90BFBE9DDBAC5E109CCE) >> 128;
            if (xSignifier & 0x40000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000002C5C85FDF4B15DE6F17EB0D) >> 128;
            if (xSignifier & 0x20000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
            if (xSignifier & 0x10000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000B17217F7D20CF927C8E94C) >> 128;
            if (xSignifier & 0x8000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000058B90BFBE8F71CB4E4B33D) >> 128;
            if (xSignifier & 0x4000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000002C5C85FDF477B662B26945) >> 128;
            if (xSignifier & 0x2000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000162E42FEFA3AE53369388C) >> 128;
            if (xSignifier & 0x1000000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000B17217F7D1D351A389D40) >> 128;
            if (xSignifier & 0x800000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000058B90BFBE8E8B2D3D4EDE) >> 128;
            if (xSignifier & 0x400000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000002C5C85FDF4741BEA6E77E) >> 128;
            if (xSignifier & 0x200000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000162E42FEFA39FE95583C2) >> 128;
            if (xSignifier & 0x100000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000B17217F7D1CFB72B45E1) >> 128;
            if (xSignifier & 0x80000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000058B90BFBE8E7CC35C3F0) >> 128;
            if (xSignifier & 0x40000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000002C5C85FDF473E242EA38) >> 128;
            if (xSignifier & 0x20000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000162E42FEFA39F02B772C) >> 128;
            if (xSignifier & 0x10000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
            if (xSignifier & 0x8000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
            if (xSignifier & 0x4000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000002C5C85FDF473DEA871F) >> 128;
            if (xSignifier & 0x2000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000162E42FEFA39EF44D91) >> 128;
            if (xSignifier & 0x1000000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000B17217F7D1CF79E949) >> 128;
            if (xSignifier & 0x800000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000058B90BFBE8E7BCE544) >> 128;
            if (xSignifier & 0x400000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
            if (xSignifier & 0x200000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000162E42FEFA39EF366F) >> 128;
            if (xSignifier & 0x100000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
            if (xSignifier & 0x80000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000058B90BFBE8E7BCD6D) >> 128;
            if (xSignifier & 0x40000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000002C5C85FDF473DE6B2) >> 128;
            if (xSignifier & 0x20000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000162E42FEFA39EF358) >> 128;
            if (xSignifier & 0x10000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000B17217F7D1CF79AB) >> 128;
            if (xSignifier & 0x8000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000058B90BFBE8E7BCD5) >> 128;
            if (xSignifier & 0x4000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000002C5C85FDF473DE6A) >> 128;
            if (xSignifier & 0x2000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000162E42FEFA39EF34) >> 128;
            if (xSignifier & 0x1000000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000B17217F7D1CF799) >> 128;
            if (xSignifier & 0x800000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000058B90BFBE8E7BCC) >> 128;
            if (xSignifier & 0x400000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000002C5C85FDF473DE5) >> 128;
            if (xSignifier & 0x200000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000162E42FEFA39EF2) >> 128;
            if (xSignifier & 0x100000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000B17217F7D1CF78) >> 128;
            if (xSignifier & 0x80000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000058B90BFBE8E7BB) >> 128;
            if (xSignifier & 0x40000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000002C5C85FDF473DD) >> 128;
            if (xSignifier & 0x20000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000162E42FEFA39EE) >> 128;
            if (xSignifier & 0x10000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000B17217F7D1CF6) >> 128;
            if (xSignifier & 0x8000000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000058B90BFBE8E7A) >> 128;
            if (xSignifier & 0x4000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000002C5C85FDF473C) >> 128;
            if (xSignifier & 0x2000000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000162E42FEFA39D) >> 128;
            if (xSignifier & 0x1000000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000B17217F7D1CE) >> 128;
            if (xSignifier & 0x800000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000058B90BFBE8E6) >> 128;
            if (xSignifier & 0x400000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000002C5C85FDF472) >> 128;
            if (xSignifier & 0x200000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000162E42FEFA38) >> 128;
            if (xSignifier & 0x100000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000B17217F7D1B) >> 128;
            if (xSignifier & 0x80000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000058B90BFBE8D) >> 128;
            if (xSignifier & 0x40000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000002C5C85FDF46) >> 128;
            if (xSignifier & 0x20000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000162E42FEFA2) >> 128;
            if (xSignifier & 0x10000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000B17217F7D0) >> 128;
            if (xSignifier & 0x8000000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000058B90BFBE7) >> 128;
            if (xSignifier & 0x4000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000002C5C85FDF3) >> 128;
            if (xSignifier & 0x2000000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000162E42FEF9) >> 128;
            if (xSignifier & 0x1000000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000B17217F7C) >> 128;
            if (xSignifier & 0x800000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000058B90BFBD) >> 128;
            if (xSignifier & 0x400000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000002C5C85FDE) >> 128;
            if (xSignifier & 0x200000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000162E42FEE) >> 128;
            if (xSignifier & 0x100000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000B17217F6) >> 128;
            if (xSignifier & 0x80000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000058B90BFA) >> 128;
            if (xSignifier & 0x40000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000002C5C85FC) >> 128;
            if (xSignifier & 0x20000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000162E42FD) >> 128;
            if (xSignifier & 0x10000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000B17217E) >> 128;
            if (xSignifier & 0x8000000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000058B90BE) >> 128;
            if (xSignifier & 0x4000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000002C5C85E) >> 128;
            if (xSignifier & 0x2000000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000162E42E) >> 128;
            if (xSignifier & 0x1000000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000B17216) >> 128;
            if (xSignifier & 0x800000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000058B90A) >> 128;
            if (xSignifier & 0x400000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000002C5C84) >> 128;
            if (xSignifier & 0x200000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000162E41) >> 128;
            if (xSignifier & 0x100000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000000B1720) >> 128;
            if (xSignifier & 0x80000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000058B8F) >> 128;
            if (xSignifier & 0x40000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000002C5C7) >> 128;
            if (xSignifier & 0x20000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000000162E3) >> 128;
            if (xSignifier & 0x10000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000000B171) >> 128;
            if (xSignifier & 0x8000 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000000058B8) >> 128;
            if (xSignifier & 0x4000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000002C5B) >> 128;
            if (xSignifier & 0x2000 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000000162D) >> 128;
            if (xSignifier & 0x1000 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000000B16) >> 128;
            if (xSignifier & 0x800 > 0)
                resultSignifier = (resultSignifier * 0x10000000000000000000000000000058A) >> 128;
            if (xSignifier & 0x400 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000000002C4) >> 128;
            if (xSignifier & 0x200 > 0)
                resultSignifier = (resultSignifier * 0x100000000000000000000000000000161) >> 128;
            if (xSignifier & 0x100 > 0)
                resultSignifier = (resultSignifier * 0x1000000000000000000000000000000B0) >> 128;
            if (xSignifier & 0x80 > 0) resultSignifier = (resultSignifier * 0x100000000000000000000000000000057) >> 128;
            if (xSignifier & 0x40 > 0) resultSignifier = (resultSignifier * 0x10000000000000000000000000000002B) >> 128;
            if (xSignifier & 0x20 > 0) resultSignifier = (resultSignifier * 0x100000000000000000000000000000015) >> 128;
            if (xSignifier & 0x10 > 0) resultSignifier = (resultSignifier * 0x10000000000000000000000000000000A) >> 128;
            if (xSignifier & 0x8 > 0) resultSignifier = (resultSignifier * 0x100000000000000000000000000000004) >> 128;
            if (xSignifier & 0x4 > 0) resultSignifier = (resultSignifier * 0x100000000000000000000000000000001) >> 128;

            if (!xNegative) {
                resultSignifier = (resultSignifier >> 15) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                resultExponent += 0x3FFF;
            } else if (resultExponent <= 0x3FFE) {
                resultSignifier = (resultSignifier >> 15) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
                resultExponent = 0x3FFF - resultExponent;
            } else {
                resultSignifier = resultSignifier >> (resultExponent - 16367);
                resultExponent = 0;
            }

            return bytes16(uint128((resultExponent << 112) | resultSignifier));
        }
    }

    function exp(bytes16 x) internal pure returns (bytes16) {

        return pow_2(mul(x, 0x3FFF71547652B82FE1777D0FFDA0D23A));
    }

    function msb(uint256 x) private pure returns (uint256) {

        require(x > 0);

        uint256 result = 0;

        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            result += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            result += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            result += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            result += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            result += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            result += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            result += 2;
        }
        if (x >= 0x2) result += 1; // No need to shift x anymore

        return result;
    }
}



contract Initializable {

    bool private initialized;

    bool private initializing;

    modifier initializer() {

        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    function isConstructor() private view returns (bool) {

        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    uint256[50] private ______gap;
}

contract Sacrifice {

    constructor(address payable _recipient) public payable {
        selfdestruct(_recipient);
    }
}

contract ReentrancyGuard is Initializable {

    uint256 private _guardCounter;

    function initialize() public initializer {

        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }

    uint256[50] private ______gap;
}


contract ERC20Interface {

    function totalSupply() public view returns (uint256);


    function balanceOf(address tokenOwner) public view returns (uint256 balance);


    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);


    function transfer(address to, uint256 tokens) public returns (bool success);


    function approve(address spender, uint256 tokens) public returns (bool success);


    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}


contract SafeMathERC20 {

    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {

        c = a + b;
        require(c >= a);
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {

        require(b <= a);
        c = a - b;
    }

    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {

        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {

        require(b > 0);
        c = a / b;
    }
}


contract Context is Initializable {

    constructor() internal {}


    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}

contract StakingV2 is Ownable, ReentrancyGuard {

    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;


    event Deposited(
        address indexed sender,
        uint256 indexed id,
        uint256 amount,
        uint256 currentBalance,
        uint256 timestamp
    );

    event WithdrawnAll(
        address indexed sender,
        uint256 indexed id,
        uint256 totalWithdrawalAmount,
        uint256 currentBalance,
        uint256 timestamp
    );

    event ExtendedLockup(
        address indexed sender,
        uint256 indexed id,
        uint256 currentBalance,
        uint256 finalBalance,
        uint256 timestamp
    );

    event LiquidityProviderAddressSet(address value, address sender);

    struct AddressParam {
        address oldValue;
        address newValue;
        uint256 timestamp;
    }

    mapping(address => mapping(uint256 => uint256)) public balances;
    mapping(address => mapping(uint256 => uint256)) public depositDates;

    uint256 public totalStaked;

    bool private locked;

    bool private contractPaused = false;

    bool private pausedDepositsAndLockupExtensions = false;

    IERC20Mintable public token;
    IERC20Mintable public tokenReward;

    AddressParam public liquidityProviderAddressParam;

    uint256 private constant DAY = 1 days;
    uint256 private constant MONTH = 30 days;
    uint256 private constant YEAR = 365 days;

    uint256 public constant PARAM_UPDATE_DELAY = 7 days;


    modifier validDepositId(uint256 _depositId) {

        require(_depositId >= 1 && _depositId <= 5, "Invalid depositId");
        _;
    }

    modifier balanceExists(uint256 _depositId) {

        require(balances[msg.sender][_depositId] > 0, "Your deposit is zero");
        _;
    }

    modifier isNotLocked() {

        require(locked == false, "Locked, try again later");
        _;
    }

    modifier isNotPaused() {

        require(contractPaused == false, "Paused");
        _;
    }

    modifier isNotPausedOperations() {

        require(contractPaused == false, "Paused");
        _;
    }

    modifier isNotPausedDepositAndLockupExtensions() {

        require(pausedDepositsAndLockupExtensions == false, "Paused Deposits and Extensions");
        _;
    }

    function pauseContract(bool value) public onlyOwner {

        contractPaused = value;
    }

    function pauseDepositAndLockupExtensions(bool value) public onlyOwner {

        pausedDepositsAndLockupExtensions = value;
    }

    function initializeStaking(
        address _owner,
        address _tokenAddress,
        address _tokenReward,
        address _liquidityProviderAddress
    ) external initializer {

        require(_owner != address(0), "Zero address");
        require(_tokenAddress.isContract(), "Not a contract address");
        Ownable.initialize(msg.sender);
        ReentrancyGuard.initialize();
        token = IERC20Mintable(_tokenAddress);
        tokenReward = IERC20Mintable(_tokenReward);
        setLiquidityProviderAddress(_liquidityProviderAddress);
        Ownable.transferOwnership(_owner);
    }

    function setLiquidityProviderAddress(address _address) public onlyOwner {

        require(_address != address(0), "Zero address");
        require(_address != address(this), "Wrong address");
        AddressParam memory param = liquidityProviderAddressParam;
        if (param.timestamp == 0) {
            param.oldValue = _address;
        } else if (_paramUpdateDelayElapsed(param.timestamp)) {
            param.oldValue = param.newValue;
        }
        param.newValue = _address;
        param.timestamp = _now();
        liquidityProviderAddressParam = param;
        emit LiquidityProviderAddressSet(_address, msg.sender);
    }

    function _paramUpdateDelayElapsed(uint256 _paramTimestamp) internal view returns (bool) {

        return _now() > _paramTimestamp.add(PARAM_UPDATE_DELAY);
    }

    function deposit(uint256 _depositId, uint256 _amount)
        public
        validDepositId(_depositId)
        isNotLocked
        isNotPaused
        isNotPausedDepositAndLockupExtensions
    {

        require(_amount > 0, "Amount should be more than 0");

        _deposit(msg.sender, _depositId, _amount);

        _setLocked(true);
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        _setLocked(false);
    }

    function _deposit(
        address _sender,
        uint256 _depositId,
        uint256 _amount
    ) internal nonReentrant {

        uint256 currentBalance = getCurrentBalance(_depositId, _sender);
        uint256 finalBalance = calcRewards(_sender, _depositId);
        uint256 timestamp = _now();

        totalStaked = totalStaked.add(finalBalance).sub(currentBalance);
        balances[_sender][_depositId] = _amount.add(finalBalance);
        depositDates[_sender][_depositId] = _now();
        emit Deposited(_sender, _depositId, _amount, currentBalance, timestamp);
    }

    function withdrawAll(uint256 _depositId) external balanceExists(_depositId) validDepositId(_depositId) isNotPaused {

        require(isLockupPeriodExpired(_depositId), "Too early, Lockup period");
        _withdrawAll(msg.sender, _depositId);
    }

    function _withdrawAll(address _sender, uint256 _depositId)
        internal
        balanceExists(_depositId)
        validDepositId(_depositId)
        nonReentrant
    {

        uint256 currentBalance = getCurrentBalance(_depositId, _sender);
        uint256 finalBalance = calcRewards(_sender, _depositId);

        require(finalBalance > 0, "Nothing to withdraw");
        balances[_sender][_depositId] = 0;

        _setLocked(true);
        require(
            tokenReward.transferFrom(liquidityProviderAddress(), _sender, finalBalance),
            "Liquidity pool transfer failed"
        );
        _setLocked(false);

        emit WithdrawnAll(_sender, _depositId, finalBalance, currentBalance, _now());
    }

    function extendLockup(uint256 _depositId)
        external
        balanceExists(_depositId)
        validDepositId(_depositId)
        isNotPaused
        isNotPausedDepositAndLockupExtensions
    {

        require(_depositId != 1, "No lockup is set up");
        _extendLockup(msg.sender, _depositId);
    }

    function _extendLockup(address _sender, uint256 _depositId) internal nonReentrant {

        uint256 timestamp = _now();
        uint256 currentBalance = getCurrentBalance(_depositId, _sender);
        uint256 finalBalance = calcRewards(_sender, _depositId);

		totalStaked = totalStaked.add(finalBalance).sub(currentBalance);
        balances[_sender][_depositId] = finalBalance;
        depositDates[_sender][_depositId] = timestamp;
        emit ExtendedLockup(_sender, _depositId, currentBalance, finalBalance, timestamp);
    }

    function isLockupPeriodExpired(uint256 _depositId) public view validDepositId(_depositId) returns (bool) {

        uint256 lockPeriod;

        if (_depositId == 1) {
            lockPeriod = 0;
        } else if (_depositId == 2) {
            lockPeriod = MONTH * 3; // 3 months
        } else if (_depositId == 3) {
            lockPeriod = MONTH * 6; // 6 months
        } else if (_depositId == 4) {
            lockPeriod = MONTH * 9; // 9 months
        } else if (_depositId == 5) {
            lockPeriod = MONTH * 12; // 12 months
        }

        if (_now() > depositDates[msg.sender][_depositId].add(lockPeriod)) {
            return true;
        } else {
            return false;
        }
    }

    function pow(int128 _x, uint256 _n) public pure returns (int128 r) {

        r = ABDKMath64x64.fromUInt(1);
        while (_n > 0) {
            if (_n % 2 == 1) {
                r = ABDKMath64x64.mul(r, _x);
                _n -= 1;
            } else {
                _x = ABDKMath64x64.mul(_x, _x);
                _n /= 2;
            }
        }
    }

    function compound(
        uint256 _principal,
        uint256 _ratio,
        uint256 _n
    ) public view returns (uint256) {

        uint256 daysCount = _n.div(DAY);

        return
            ABDKMath64x64.mulu(
                pow(ABDKMath64x64.add(ABDKMath64x64.fromUInt(1), ABDKMath64x64.divu(_ratio, 10**18)), daysCount),
                _principal
            );
    }

    function calcRewards(address _sender, uint256 _depositId) public view validDepositId(_depositId) returns (uint256) {

        uint256 timePassed = _now().sub(depositDates[_sender][_depositId]);
        uint256 currentBalance = getCurrentBalance(_depositId, _sender);
        uint256 finalBalance;

        uint256 ratio;
        uint256 lockPeriod;

        if (_depositId == 1) {
            ratio = 100000000000000; // APY 3.7% InterestRate = 0.01
            lockPeriod = 0;
        } else if (_depositId == 2) {
            ratio = 300000000000000; // APY 11.6% InterestRate = 0.03
            lockPeriod = MONTH * 3; // 3 months
        } else if (_depositId == 3) {
            ratio = 400000000000000; // APY 15.7% InterestRate = 0.04
            lockPeriod = MONTH * 6; // 6 months
        } else if (_depositId == 4) {
            ratio = 600000000000000; // APY 25.5% InterestRate = 0.06
            lockPeriod = MONTH * 9; // 9 months
        } else if (_depositId == 5) {
            ratio = 800000000000000; // APY 33.9% InterestRate = 0.08
            lockPeriod = YEAR; // 12 months
        }

        if (currentBalance == 0) {
            return finalBalance = 0;
        }

        if (_depositId == 1) {
            finalBalance = compound(currentBalance, ratio, timePassed);

            return finalBalance;
        }

        if (timePassed > lockPeriod) {
            uint256 rewardsWithLockup = compound(currentBalance, ratio, lockPeriod).sub(currentBalance);
            finalBalance = compound(rewardsWithLockup.add(currentBalance), 100000000000000, timePassed.sub(lockPeriod));



            return finalBalance;
        }

        finalBalance = compound(currentBalance, ratio, timePassed);
        return finalBalance;
    }

    function getCurrentBalance(uint256 _depositId, address _address) public view returns (uint256 addressBalance) {

        addressBalance = balances[_address][_depositId];
    }

    function liquidityProviderAddress() public view returns (address) {

        AddressParam memory param = liquidityProviderAddressParam;
        return param.newValue;
    }

    function _setLocked(bool _locked) internal {

        locked = _locked;
    }

    function senderCurrentBalance() public view returns (uint256) {

        return msg.sender.balance;
    }

    function _now() internal view returns (uint256) {

        return block.timestamp;
    }

    function claimTokens(
        address _token,
        address payable _to,
        uint256 _amount
    ) external onlyOwner {

        require(_to != address(0) && _to != address(this), "not a valid recipient");
        require(_amount > 0, "amount should be greater than 0");
        if (_token == address(0)) {
            if (!_to.send(_amount)) {
                (new Sacrifice).value(_amount)(_to);
            }
        } else if (_token == address(token)) {
            uint256 availableAmount = token.balanceOf(address(this)).sub(totalStaked);
            require(availableAmount >= _amount, "insufficient funds");
            require(token.transfer(_to, _amount), "transfer failed");
        } else {
            IERC20 customToken = IERC20(_token);
            customToken.safeTransfer(_to, _amount);
        }
    }
}