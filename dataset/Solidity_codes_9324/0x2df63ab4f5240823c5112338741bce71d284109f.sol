pragma solidity ^0.8.0;

library ABDKMath64x64 {

  int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

  int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  function fromInt(int256 x) internal pure returns (int128) {

    unchecked {
      require(x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
      return int128(x << 64);
    }
  }

  function toInt(int128 x) internal pure returns (int64) {

    unchecked {
      return int64(x >> 64);
    }
  }

  function fromUInt(uint256 x) internal pure returns (int128) {

    unchecked {
      require(x <= 0x7FFFFFFFFFFFFFFF);
      return int128(int256(x << 64));
    }
  }

  function toUInt(int128 x) internal pure returns (uint64) {

    unchecked {
      require(x >= 0);
      return uint64(uint128(x >> 64));
    }
  }

  function from128x128(int256 x) internal pure returns (int128) {

    unchecked {
      int256 result = x >> 64;
      require(result >= MIN_64x64 && result <= MAX_64x64);
      return int128(result);
    }
  }

  function to128x128(int128 x) internal pure returns (int256) {

    unchecked {
      return int256(x) << 64;
    }
  }

  function add(int128 x, int128 y) internal pure returns (int128) {

    unchecked {
      int256 result = int256(x) + y;
      require(result >= MIN_64x64 && result <= MAX_64x64);
      return int128(result);
    }
  }

  function sub(int128 x, int128 y) internal pure returns (int128) {

    unchecked {
      int256 result = int256(x) - y;
      require(result >= MIN_64x64 && result <= MAX_64x64);
      return int128(result);
    }
  }

  function mul(int128 x, int128 y) internal pure returns (int128) {

    unchecked {
      int256 result = (int256(x) * y) >> 64;
      require(result >= MIN_64x64 && result <= MAX_64x64);
      return int128(result);
    }
  }

  function muli(int128 x, int256 y) internal pure returns (int256) {

    unchecked {
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
          require(
            absoluteResult <=
              0x8000000000000000000000000000000000000000000000000000000000000000
          );
          return -int256(absoluteResult); // We rely on overflow behavior here
        } else {
          require(
            absoluteResult <=
              0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          );
          return int256(absoluteResult);
        }
      }
    }
  }

  function mulu(int128 x, uint256 y) internal pure returns (uint256) {

    unchecked {
      if (y == 0) return 0;

      require(x >= 0);

      uint256 lo = (uint256(int256(x)) *
        (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
      uint256 hi = uint256(int256(x)) * (y >> 128);

      require(hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      hi <<= 64;

      require(
        hi <=
          0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF -
            lo
      );
      return hi + lo;
    }
  }

  function div(int128 x, int128 y) internal pure returns (int128) {

    unchecked {
      require(y != 0);
      int256 result = (int256(x) << 64) / y;
      require(result >= MIN_64x64 && result <= MAX_64x64);
      return int128(result);
    }
  }

  function divi(int256 x, int256 y) internal pure returns (int128) {

    unchecked {
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
  }

  function divu(uint256 x, uint256 y) internal pure returns (int128) {

    unchecked {
      require(y != 0);
      uint128 result = divuu(x, y);
      require(result <= uint128(MAX_64x64));
      return int128(result);
    }
  }

  function neg(int128 x) internal pure returns (int128) {

    unchecked {
      require(x != MIN_64x64);
      return -x;
    }
  }

  function abs(int128 x) internal pure returns (int128) {

    unchecked {
      require(x != MIN_64x64);
      return x < 0 ? -x : x;
    }
  }

  function inv(int128 x) internal pure returns (int128) {

    unchecked {
      require(x != 0);
      int256 result = int256(0x100000000000000000000000000000000) / x;
      require(result >= MIN_64x64 && result <= MAX_64x64);
      return int128(result);
    }
  }

  function avg(int128 x, int128 y) internal pure returns (int128) {

    unchecked {
      return int128((int256(x) + int256(y)) >> 1);
    }
  }

  function gavg(int128 x, int128 y) internal pure returns (int128) {

    unchecked {
      int256 m = int256(x) * int256(y);
      require(m >= 0);
      require(
        m < 0x4000000000000000000000000000000000000000000000000000000000000000
      );
      return int128(sqrtu(uint256(m)));
    }
  }

  function pow(int128 x, uint256 y) internal pure returns (int128) {

    unchecked {
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
  }

  function sqrt(int128 x) internal pure returns (int128) {

    unchecked {
      require(x >= 0);
      return int128(sqrtu(uint256(int256(x)) << 64));
    }
  }

  function log_2(int128 x) internal pure returns (int128) {

    unchecked {
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
      uint256 ux = uint256(int256(x)) << uint256(127 - msb);
      for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
        ux *= ux;
        uint256 b = ux >> 255;
        ux >>= 127 + b;
        result += bit * int256(b);
      }

      return int128(result);
    }
  }

  function ln(int128 x) internal pure returns (int128) {

    unchecked {
      require(x > 0);

      return
        int128(
          int256(
            (uint256(int256(log_2(x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF) >>
              128
          )
        );
    }
  }

  function exp_2(int128 x) internal pure returns (int128) {

    unchecked {
      require(x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      uint256 result = 0x80000000000000000000000000000000;

      if (x & 0x8000000000000000 > 0)
        result = (result * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
      if (x & 0x4000000000000000 > 0)
        result = (result * 0x1306FE0A31B7152DE8D5A46305C85EDEC) >> 128;
      if (x & 0x2000000000000000 > 0)
        result = (result * 0x1172B83C7D517ADCDF7C8C50EB14A791F) >> 128;
      if (x & 0x1000000000000000 > 0)
        result = (result * 0x10B5586CF9890F6298B92B71842A98363) >> 128;
      if (x & 0x800000000000000 > 0)
        result = (result * 0x1059B0D31585743AE7C548EB68CA417FD) >> 128;
      if (x & 0x400000000000000 > 0)
        result = (result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8) >> 128;
      if (x & 0x200000000000000 > 0)
        result = (result * 0x10163DA9FB33356D84A66AE336DCDFA3F) >> 128;
      if (x & 0x100000000000000 > 0)
        result = (result * 0x100B1AFA5ABCBED6129AB13EC11DC9543) >> 128;
      if (x & 0x80000000000000 > 0)
        result = (result * 0x10058C86DA1C09EA1FF19D294CF2F679B) >> 128;
      if (x & 0x40000000000000 > 0)
        result = (result * 0x1002C605E2E8CEC506D21BFC89A23A00F) >> 128;
      if (x & 0x20000000000000 > 0)
        result = (result * 0x100162F3904051FA128BCA9C55C31E5DF) >> 128;
      if (x & 0x10000000000000 > 0)
        result = (result * 0x1000B175EFFDC76BA38E31671CA939725) >> 128;
      if (x & 0x8000000000000 > 0)
        result = (result * 0x100058BA01FB9F96D6CACD4B180917C3D) >> 128;
      if (x & 0x4000000000000 > 0)
        result = (result * 0x10002C5CC37DA9491D0985C348C68E7B3) >> 128;
      if (x & 0x2000000000000 > 0)
        result = (result * 0x1000162E525EE054754457D5995292026) >> 128;
      if (x & 0x1000000000000 > 0)
        result = (result * 0x10000B17255775C040618BF4A4ADE83FC) >> 128;
      if (x & 0x800000000000 > 0)
        result = (result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB) >> 128;
      if (x & 0x400000000000 > 0)
        result = (result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9) >> 128;
      if (x & 0x200000000000 > 0)
        result = (result * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
      if (x & 0x100000000000 > 0)
        result = (result * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
      if (x & 0x80000000000 > 0)
        result = (result * 0x10000058B90CF1E6D97F9CA14DBCC1628) >> 128;
      if (x & 0x40000000000 > 0)
        result = (result * 0x1000002C5C863B73F016468F6BAC5CA2B) >> 128;
      if (x & 0x20000000000 > 0)
        result = (result * 0x100000162E430E5A18F6119E3C02282A5) >> 128;
      if (x & 0x10000000000 > 0)
        result = (result * 0x1000000B1721835514B86E6D96EFD1BFE) >> 128;
      if (x & 0x8000000000 > 0)
        result = (result * 0x100000058B90C0B48C6BE5DF846C5B2EF) >> 128;
      if (x & 0x4000000000 > 0)
        result = (result * 0x10000002C5C8601CC6B9E94213C72737A) >> 128;
      if (x & 0x2000000000 > 0)
        result = (result * 0x1000000162E42FFF037DF38AA2B219F06) >> 128;
      if (x & 0x1000000000 > 0)
        result = (result * 0x10000000B17217FBA9C739AA5819F44F9) >> 128;
      if (x & 0x800000000 > 0)
        result = (result * 0x1000000058B90BFCDEE5ACD3C1CEDC823) >> 128;
      if (x & 0x400000000 > 0)
        result = (result * 0x100000002C5C85FE31F35A6A30DA1BE50) >> 128;
      if (x & 0x200000000 > 0)
        result = (result * 0x10000000162E42FF0999CE3541B9FFFCF) >> 128;
      if (x & 0x100000000 > 0)
        result = (result * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
      if (x & 0x80000000 > 0)
        result = (result * 0x10000000058B90BFBF8479BD5A81B51AD) >> 128;
      if (x & 0x40000000 > 0)
        result = (result * 0x1000000002C5C85FDF84BD62AE30A74CC) >> 128;
      if (x & 0x20000000 > 0)
        result = (result * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
      if (x & 0x10000000 > 0)
        result = (result * 0x1000000000B17217F7D5A7716BBA4A9AE) >> 128;
      if (x & 0x8000000 > 0)
        result = (result * 0x100000000058B90BFBE9DDBAC5E109CCE) >> 128;
      if (x & 0x4000000 > 0)
        result = (result * 0x10000000002C5C85FDF4B15DE6F17EB0D) >> 128;
      if (x & 0x2000000 > 0)
        result = (result * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
      if (x & 0x1000000 > 0)
        result = (result * 0x10000000000B17217F7D20CF927C8E94C) >> 128;
      if (x & 0x800000 > 0)
        result = (result * 0x1000000000058B90BFBE8F71CB4E4B33D) >> 128;
      if (x & 0x400000 > 0)
        result = (result * 0x100000000002C5C85FDF477B662B26945) >> 128;
      if (x & 0x200000 > 0)
        result = (result * 0x10000000000162E42FEFA3AE53369388C) >> 128;
      if (x & 0x100000 > 0)
        result = (result * 0x100000000000B17217F7D1D351A389D40) >> 128;
      if (x & 0x80000 > 0)
        result = (result * 0x10000000000058B90BFBE8E8B2D3D4EDE) >> 128;
      if (x & 0x40000 > 0)
        result = (result * 0x1000000000002C5C85FDF4741BEA6E77E) >> 128;
      if (x & 0x20000 > 0)
        result = (result * 0x100000000000162E42FEFA39FE95583C2) >> 128;
      if (x & 0x10000 > 0)
        result = (result * 0x1000000000000B17217F7D1CFB72B45E1) >> 128;
      if (x & 0x8000 > 0)
        result = (result * 0x100000000000058B90BFBE8E7CC35C3F0) >> 128;
      if (x & 0x4000 > 0)
        result = (result * 0x10000000000002C5C85FDF473E242EA38) >> 128;
      if (x & 0x2000 > 0)
        result = (result * 0x1000000000000162E42FEFA39F02B772C) >> 128;
      if (x & 0x1000 > 0)
        result = (result * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
      if (x & 0x800 > 0)
        result = (result * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
      if (x & 0x400 > 0)
        result = (result * 0x100000000000002C5C85FDF473DEA871F) >> 128;
      if (x & 0x200 > 0)
        result = (result * 0x10000000000000162E42FEFA39EF44D91) >> 128;
      if (x & 0x100 > 0)
        result = (result * 0x100000000000000B17217F7D1CF79E949) >> 128;
      if (x & 0x80 > 0)
        result = (result * 0x10000000000000058B90BFBE8E7BCE544) >> 128;
      if (x & 0x40 > 0)
        result = (result * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
      if (x & 0x20 > 0)
        result = (result * 0x100000000000000162E42FEFA39EF366F) >> 128;
      if (x & 0x10 > 0)
        result = (result * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
      if (x & 0x8 > 0)
        result = (result * 0x100000000000000058B90BFBE8E7BCD6D) >> 128;
      if (x & 0x4 > 0)
        result = (result * 0x10000000000000002C5C85FDF473DE6B2) >> 128;
      if (x & 0x2 > 0)
        result = (result * 0x1000000000000000162E42FEFA39EF358) >> 128;
      if (x & 0x1 > 0)
        result = (result * 0x10000000000000000B17217F7D1CF79AB) >> 128;

      result >>= uint256(int256(63 - (x >> 64)));
      require(result <= uint256(int256(MAX_64x64)));

      return int128(int256(result));
    }
  }

  function exp(int128 x) internal pure returns (int128) {

    unchecked {
      require(x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      return
        exp_2(int128((int256(x) * 0x171547652B82FE1777D0FFDA0D23A7D12) >> 128));
    }
  }

  function divuu(uint256 x, uint256 y) private pure returns (uint128) {

    unchecked {
      require(y != 0);

      uint256 result;

      if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        result = (x << 64) / y;
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
  }

  function sqrtu(uint256 x) private pure returns (uint128) {

    unchecked {
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
}// MIT
pragma solidity >=0.4.22 <0.9.0;

contract Stake is Ownable, Pausable, ReentrancyGuard {
  using ABDKMath64x64 for int128;

  uint256 public lastSavedEpoch;
  uint256 public totalStaked;
  uint256 public START_TIME;
  ERC20 public REWARD_TOKEN;
  ERC20 public STAKING_TOKEN;
  bool public STAKING_SAME_AS_REWARD;

  constructor(address rewardToken, address stakingToken) {
    REWARD_TOKEN = ERC20(rewardToken);
    STAKING_TOKEN = ERC20(stakingToken);
    START_TIME = block.timestamp;
    STAKING_SAME_AS_REWARD = rewardToken == stakingToken;
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  uint256 public INTERVAL = 24 hours;

  function updateInterval(uint256 interval) public onlyOwner {
    INTERVAL = interval;
  }

  function getCurrentEpoch() public view returns (uint256) {
    return ((block.timestamp - START_TIME) / (INTERVAL));
  }

  int256 public DELTA_CALC_NUMERATOR = 99;
  int256 public DELTA_CALC_DENOMINATOR = 100;
  int128 public DELTA_CALC_DIVIDED =
    int128(DELTA_CALC_NUMERATOR).divi(DELTA_CALC_DENOMINATOR);

  function updateDeltaCalc(int256 num, int256 denom) public onlyOwner {
    DELTA_CALC_NUMERATOR = num;
    DELTA_CALC_DENOMINATOR = denom;
    DELTA_CALC_DIVIDED = int128(DELTA_CALC_NUMERATOR).divi(
      DELTA_CALC_DENOMINATOR
    );
  }

  function getRewardTokenBalance() public view returns (uint256) {
    uint256 totalBalance = REWARD_TOKEN.balanceOf(address(this));
    return (totalBalance - (STAKING_SAME_AS_REWARD ? totalStaked : 0));
  }

  function _getRewardsForDelta(uint256 delta) internal view returns (uint256) {
    uint256 totalBalance = REWARD_TOKEN.balanceOf(address(this));
    if (totalBalance <= totalStaked && STAKING_SAME_AS_REWARD) {
      return 0;
    }

    uint256 balance = (totalBalance -
      totalRewards -
      (STAKING_SAME_AS_REWARD ? totalStaked : 0)) / 10**18;
    int128 intBalance = ABDKMath64x64.fromUInt(balance);
    int128 b = DELTA_CALC_DIVIDED.pow(delta);
    int128 c = int128(1).fromInt().sub(b);
    int128 d = c.mul(intBalance);
    return d.toUInt();
  }

  function getRewardsForDelta(uint256 delta) public view returns (uint256) {
    return _getRewardsForDelta(delta);
  }

  uint256 public totalRewards;

  uint256 public rewardPerShare;

  function _setEpoch() internal returns (uint256) {
    uint256 epoch = getCurrentEpoch();
    if (lastSavedEpoch < epoch) {
      uint256 delta = epoch - lastSavedEpoch;
      uint256 totalRewardsAtEpoch = _getRewardsForDelta(delta) * 10**18;
      rewardPerShare += totalStaked > 0
        ? PRBMathUD60x18.div(totalRewardsAtEpoch, totalStaked)
        : 0;
      totalRewards += (totalRewardsAtEpoch);
      lastSavedEpoch = epoch;
    }
    return epoch;
  }

  struct Stake {
    bool exists;
    uint256 startEpoch;
    uint256 totalStaked;
    uint256 rewardDebt;
  }

  mapping(address => Stake) public stakes;

  function getTotalStakedByAddress(address staker)
    public
    view
    returns (uint256)
  {
    Stake memory stake = stakes[staker];
    return stake.totalStaked;
  }

  function migrate(address to) public onlyOwner {
    uint256 balance = getRewardTokenBalance();
    REWARD_TOKEN.transfer(to, balance);
  }

  function calcRewards(address staker) public view returns (uint256) {
    uint256 currentEpoch = getCurrentEpoch();
    Stake memory stake = stakes[staker];
    require(stake.exists, "Stake does not exist");

    uint256 totalNotedRewards = totalRewards;

    if (currentEpoch > lastSavedEpoch) {
      uint256 totalRewardsAtEpoch = _getRewardsForDelta(
        currentEpoch - lastSavedEpoch
      ) * 10**18;

      totalNotedRewards += totalRewardsAtEpoch;

      uint256 projectedRewardPerShare = rewardPerShare +
        (
          totalStaked > 0
            ? PRBMathUD60x18.div(totalRewardsAtEpoch, totalStaked)
            : 0
        );
      return
        PRBMathUD60x18.mul(
          projectedRewardPerShare - stake.rewardDebt,
          stake.totalStaked
        );
    } else {
      return
        PRBMathUD60x18.mul(
          rewardPerShare - stake.rewardDebt,
          stake.totalStaked
        );
    }
  }

  function emergencyWithdraw() public nonReentrant {
    _setEpoch();
    require(stakes[msg.sender].exists, "Not staking");
    totalStaked -= stakes[msg.sender].totalStaked;
    STAKING_TOKEN.transfer(msg.sender, stakes[msg.sender].totalStaked);
    delete stakes[msg.sender];
  }

  function withdrawStakedToken(uint256 amount)
    public
    nonReentrant
    whenNotPaused
  {
    uint256 currentEpoch = _setEpoch();

    require(stakes[msg.sender].exists, "Not staking");
    require(
      amount <= stakes[msg.sender].totalStaked,
      "Amount higher than amount staked"
    );
    require(amount > 0, "Amount must be gt 0");
    if (STAKING_SAME_AS_REWARD) {
      _claimAndStakeRewards(currentEpoch);
    } else {
      _claimAndWithdrawRewards(currentEpoch);
    }
    if (amount == stakes[msg.sender].totalStaked) {
      delete stakes[msg.sender];
    } else {
      stakes[msg.sender].startEpoch = currentEpoch + 1;
      stakes[msg.sender].totalStaked -= amount;
      stakes[msg.sender].rewardDebt = rewardPerShare;
    }

    totalStaked -= amount;
    STAKING_TOKEN.transfer(msg.sender, amount);
  }

  function _claimAndWithdrawRewards(uint256 currentEpoch) internal {
    require(stakes[msg.sender].exists, "Not staking");
    uint256 rewards = calcRewards(msg.sender);
    if (rewards > 0) {
      stakes[msg.sender].startEpoch = currentEpoch + 1;
      stakes[msg.sender].rewardDebt = rewardPerShare;
      totalRewards -= rewards;
      REWARD_TOKEN.transfer(msg.sender, rewards);
    }
  }

  function claimAndWithdrawRewards() public nonReentrant whenNotPaused {
    uint256 currentEpoch = _setEpoch();
    _claimAndWithdrawRewards(currentEpoch);
  }

  function _claimAndStakeRewards(uint256 currentEpoch) internal {
    require(
      STAKING_SAME_AS_REWARD,
      "Staking and reward token must be the same to stake rewards"
    );
    require(stakes[msg.sender].exists, "Not staking");
    uint256 rewards = calcRewards(msg.sender);
    if (rewards > 0) {
      stakes[msg.sender].startEpoch = currentEpoch + 1;
      stakes[msg.sender].totalStaked += rewards;
      stakes[msg.sender].rewardDebt = rewardPerShare;
      totalRewards -= rewards;
      totalStaked += rewards;
    }
  }

  function claimAndStakeRewards() public nonReentrant whenNotPaused {
    uint256 currentEpoch = _setEpoch();
    _claimAndStakeRewards(currentEpoch);
  }

  function stake(uint256 amount) public nonReentrant whenNotPaused {
    uint256 currentEpoch = _setEpoch();
    if (stakes[msg.sender].exists == false) {
      stakes[msg.sender] = Stake({
        exists: true,
        startEpoch: currentEpoch + 1,
        totalStaked: amount,
        rewardDebt: rewardPerShare
      });
    } else {

      if (STAKING_SAME_AS_REWARD) {
        _claimAndStakeRewards(currentEpoch);
      }
      else if (!STAKING_SAME_AS_REWARD) {
        _claimAndWithdrawRewards(currentEpoch);
      }

      stakes[msg.sender].totalStaked += amount;
    }
    totalStaked += amount;
    STAKING_TOKEN.transferFrom(msg.sender, address(this), amount);
  }
}