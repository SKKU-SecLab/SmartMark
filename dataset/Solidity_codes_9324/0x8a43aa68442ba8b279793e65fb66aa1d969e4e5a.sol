
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// BSD-4-Clause
pragma solidity ^0.8.0;

library ABDKMath64x64 {

  int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

  int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  function fromInt (int256 x) internal pure returns (int128) {
    unchecked {
      require (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (x << 64);
    }
  }

  function toInt (int128 x) internal pure returns (int64) {
    unchecked {
      return int64 (x >> 64);
    }
  }

  function fromUInt (uint256 x) internal pure returns (int128) {
    unchecked {
      require (x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (int256 (x << 64));
    }
  }

  function toUInt (int128 x) internal pure returns (uint64) {
    unchecked {
      require (x >= 0);
      return uint64 (uint128 (x >> 64));
    }
  }

  function from128x128 (int256 x) internal pure returns (int128) {
    unchecked {
      int256 result = x >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  function to128x128 (int128 x) internal pure returns (int256) {
    unchecked {
      return int256 (x) << 64;
    }
  }

  function add (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) + y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  function sub (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) - y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  function mul (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) * y >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  function muli (int128 x, int256 y) internal pure returns (int256) {
    unchecked {
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
  }

  function mulu (int128 x, uint256 y) internal pure returns (uint256) {
    unchecked {
      if (y == 0) return 0;

      require (x >= 0);

      uint256 lo = (uint256 (int256 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
      uint256 hi = uint256 (int256 (x)) * (y >> 128);

      require (hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      hi <<= 64;

      require (hi <=
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
      return hi + lo;
    }
  }

  function div (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      int256 result = (int256 (x) << 64) / y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  function divi (int256 x, int256 y) internal pure returns (int128) {
    unchecked {
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
  }

  function divu (uint256 x, uint256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      uint128 result = divuu (x, y);
      require (result <= uint128 (MAX_64x64));
      return int128 (result);
    }
  }

  function neg (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return -x;
    }
  }

  function abs (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return x < 0 ? -x : x;
    }
  }

  function inv (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != 0);
      int256 result = int256 (0x100000000000000000000000000000000) / x;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  function avg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      return int128 ((int256 (x) + int256 (y)) >> 1);
    }
  }

  function gavg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 m = int256 (x) * int256 (y);
      require (m >= 0);
      require (m <
          0x4000000000000000000000000000000000000000000000000000000000000000);
      return int128 (sqrtu (uint256 (m)));
    }
  }

  function pow (int128 x, uint256 y) internal pure returns (int128) {
    unchecked {
      bool negative = x < 0 && y & 1 == 1;

      uint256 absX = uint128 (x < 0 ? -x : x);
      uint256 absResult;
      absResult = 0x100000000000000000000000000000000;

      if (absX <= 0x10000000000000000) {
        absX <<= 63;
        while (y != 0) {
          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x2 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x4 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x8 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          y >>= 4;
        }

        absResult >>= 64;
      } else {
        uint256 absXShift = 63;
        if (absX < 0x1000000000000000000000000) { absX <<= 32; absXShift -= 32; }
        if (absX < 0x10000000000000000000000000000) { absX <<= 16; absXShift -= 16; }
        if (absX < 0x1000000000000000000000000000000) { absX <<= 8; absXShift -= 8; }
        if (absX < 0x10000000000000000000000000000000) { absX <<= 4; absXShift -= 4; }
        if (absX < 0x40000000000000000000000000000000) { absX <<= 2; absXShift -= 2; }
        if (absX < 0x80000000000000000000000000000000) { absX <<= 1; absXShift -= 1; }

        uint256 resultShift = 0;
        while (y != 0) {
          require (absXShift < 64);

          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
            resultShift += absXShift;
            if (absResult > 0x100000000000000000000000000000000) {
              absResult >>= 1;
              resultShift += 1;
            }
          }
          absX = absX * absX >> 127;
          absXShift <<= 1;
          if (absX >= 0x100000000000000000000000000000000) {
              absX >>= 1;
              absXShift += 1;
          }

          y >>= 1;
        }

        require (resultShift < 64);
        absResult >>= 64 - resultShift;
      }
      int256 result = negative ? -int256 (absResult) : int256 (absResult);
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  function sqrt (int128 x) internal pure returns (int128) {
    unchecked {
      require (x >= 0);
      return int128 (sqrtu (uint256 (int256 (x)) << 64));
    }
  }

  function log_2 (int128 x) internal pure returns (int128) {
    unchecked {
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
      uint256 ux = uint256 (int256 (x)) << uint256 (127 - msb);
      for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
        ux *= ux;
        uint256 b = ux >> 255;
        ux >>= 127 + b;
        result += bit * int256 (b);
      }

      return int128 (result);
    }
  }

  function ln (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);

      return int128 (int256 (
          uint256 (int256 (log_2 (x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
    }
  }

  function exp_2 (int128 x) internal pure returns (int128) {
    unchecked {
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

      result >>= uint256 (int256 (63 - (x >> 64)));
      require (result <= uint256 (int256 (MAX_64x64)));

      return int128 (int256 (result));
    }
  }

  function exp (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      return exp_2 (
          int128 (int256 (x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
    }
  }

  function divuu (uint256 x, uint256 y) private pure returns (uint128) {
    unchecked {
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
  }

  function sqrtu (uint256 x) private pure returns (uint128) {
    unchecked {
      if (x == 0) return 0;
      else {
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
        if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
        if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
        if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
        if (xx >= 0x100) { xx >>= 8; r <<= 4; }
        if (xx >= 0x10) { xx >>= 4; r <<= 2; }
        if (xx >= 0x8) { r <<= 1; }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return uint128 (r < r1 ? r : r1);
      }
    }
  }
}// contracts/SchnoodleFarmingV2.sol
pragma solidity ^0.8.0;


contract SchnoodleFarmingV2 is Initializable, OwnableUpgradeable {

    address private _schnoodle;
    uint256 _depositId;
    mapping(address => Deposit[]) private _accountDeposits;
    mapping(address => Unbond[]) private _accountUnbonds;
    mapping(address => uint256) private _balances;
    uint256 private _totalTokens;
    uint256 private _cumulativeTotal;
    uint256 private _checkpointBlock;
    uint256 private _totalDepositWeight;

    SigmoidParams private _sigmoidParams;

    uint256 private _vestingBlocksFactor;
    uint256 private _unbondingBlocksFactor;
    uint256 private _maxUnbondingBlocks;

    struct Deposit {
        uint256 id;
        uint256 amount;
        uint256 blockNumber;
        uint256 vestingBlocks;
        uint256 unbondingBlocks;
        uint256 multiplier;
    }

    struct DepositReward {
        Deposit deposit;
        uint256 reward;
    }

    struct Unbond {
        uint256 amount;
        uint256 expiryBlock;
    }

    struct SigmoidParams {
        uint256 k; // Higher value increases slope severity
        uint256 a; // Higher value increases slope severity and shifts right
    }

    function initialize(address schnoodle) public initializer {

        __Ownable_init();
        _schnoodle = schnoodle;
        _sigmoidParams = SigmoidParams(5, 1);
    }

    function configure() external onlyOwner {

        _vestingBlocksFactor = 1000;
        _unbondingBlocksFactor = 20;
        _maxUnbondingBlocks = 3000000;
    }


    function addDeposit(uint256 amount, uint256 vestingBlocks, uint256 unbondingBlocks) external {

        address msgSender = _msgSender();

        require(amount <= balanceOf(msgSender) - lockedBalanceOf(msgSender), "SchnoodleFarming: deposit amount exceeds unlocked balance");

        Deposit memory deposit;
        uint256 cumulativeTotal;

        (deposit, cumulativeTotal, _totalTokens, _totalDepositWeight) = _buildDeposit(amount, vestingBlocks, unbondingBlocks);
        _depositId++;
        _accountDeposits[msgSender].push(deposit);
        _cumulativeTotal = cumulativeTotal;
        _checkpointBlock = deposit.blockNumber;
        _balances[msgSender] += amount;

        emit Deposited(msgSender, deposit.id, deposit.amount, deposit.vestingBlocks, deposit.unbondingBlocks, deposit.multiplier, _totalTokens, _totalDepositWeight, _cumulativeTotal);
    }

    function updateDeposit(uint256 id, uint256 vestingBlocks, uint256 unbondingBlocks) external {

        address msgSender = _msgSender();
        (Deposit storage deposit,,) = _getDeposit(msgSender, id);
        deposit.vestingBlocks = vestingBlocks;
        deposit.unbondingBlocks = unbondingBlocks;
        (uint256 multiplier,,) = _getMultiplier(deposit.amount, vestingBlocks, unbondingBlocks);
        require(multiplier > deposit.multiplier, "SchnoodleFarming: no benefit to update deposit with supplied changes");
        deposit.multiplier = multiplier;

        emit UpdatedDeposit(msgSender, id, deposit.vestingBlocks, deposit.unbondingBlocks, deposit.multiplier);
    }

    function withdraw(uint256 id, uint256 amount) external {

        address msgSender = _msgSender();
        uint256 blockNumber = block.number;
        Unbond[] storage unbonds = _accountUnbonds[msgSender];

        for (uint256 i = unbonds.length; i > 0; i--) {
            if (unbonds[i - 1].expiryBlock <= blockNumber) {
                unbonds[i - 1] = unbonds[unbonds.length - 1];
                unbonds.pop();
            }
        }

        (Deposit storage deposit, Deposit[] storage deposits, uint256 index) = _getDeposit(msgSender, id);
        require(deposit.amount >= amount, "SchnoodleFarming: cannot withdraw more than deposited");
        require(deposit.blockNumber + _vestingBlocksFactor * deposit.vestingBlocks / 1000 < blockNumber, "SchnoodleFarming: cannot withdraw during vesting blocks");

        (uint256 netReward, uint256 grossReward, uint256 newCumulativeTotal) = _getRewardInfo(deposit, amount, blockNumber);

        (_totalTokens, _totalDepositWeight) = _getAggregatedTotals(-int256(amount), deposit.vestingBlocks, deposit.unbondingBlocks);
        _cumulativeTotal = newCumulativeTotal;
        _checkpointBlock = blockNumber;
        _balances[msgSender] -= amount;
        deposit.amount -= amount;

        unbonds.push(Unbond(amount, blockNumber + _unbondingBlocksFactor * deposit.unbondingBlocks / 1000));

        if (deposit.amount == 0) {
            deposits[index] = deposits[deposits.length - 1];
            deposits.pop();
        }

        farmingReward(msgSender, netReward, grossReward);

        emit Withdrawn(msgSender, id, amount, netReward, grossReward, _totalTokens, _totalDepositWeight, _cumulativeTotal);
    }

    function _buildDeposit(uint256 amount, uint256 vestingBlocks, uint256 unbondingBlocks) private view returns (Deposit memory, uint256, uint256, uint256) {

        (uint256 multiplier, uint256 totalTokens, uint256 totalDepositWeight) = _getMultiplier(amount, vestingBlocks, unbondingBlocks);
        uint256 blockNumber = block.number;
        return (Deposit(_depositId, amount, blockNumber, vestingBlocks, unbondingBlocks, multiplier), _getCumulativeTotal(blockNumber), totalTokens, totalDepositWeight);
    }

    function _getDeposit(address account, uint256 id) private view returns(Deposit storage, Deposit[] storage, uint256) {

        Deposit[] storage deposits = _accountDeposits[account];

        for (uint256 i = 0; i < deposits.length; i++) {
            Deposit storage deposit = deposits[i];
            if (deposit.id == id) {
                return (deposit, deposits, i);
            }
        }

        revert("SchnoodleFarming: deposit not found");
    }

    function changeVestingBlocksFactor(uint256 rate) external onlyOwner {

        _vestingBlocksFactor = rate;
        emit VestingBlocksFactorChanged(rate);
    }

    function getVestingBlocksFactor() external view returns(uint256) {

        return _vestingBlocksFactor;
    }

    function changeUnbondingBlocksFactor(uint256 rate) external onlyOwner {

        _unbondingBlocksFactor = rate;
        emit UnbondingBlocksFactorChanged(rate);
    }

    function getUnbondingBlocksFactor() external view returns(uint256) {

        return _unbondingBlocksFactor;
    }

    function changeMaxUnbondingBlocks(uint256 max) external onlyOwner {

        _maxUnbondingBlocks = max;
        emit MaxUnbondingBlocksChanged(max);
    }

    function getMaxUnbondingBlocks() external view returns(uint256) {

        return _maxUnbondingBlocks;
    }


    function getReward(uint256 amount, uint256 vestingBlocks, uint256 unbondingBlocks, uint256 rewardBlock) external view returns(uint256) {

        (Deposit memory deposit, uint256 cumulativeTotal, uint256 totalTokens, uint256 totalDepositWeight) = _buildDeposit(amount, vestingBlocks, unbondingBlocks);
        return _getReward(deposit, rewardBlock, deposit.blockNumber, cumulativeTotal, totalDepositWeight, totalTokens);
    }

    function getReward(address account, uint256 id, uint256 rewardBlock) external view returns(uint256) {

        (Deposit memory deposit,,) = _getDeposit(account, id);
        return _getReward(deposit, rewardBlock);
    }

    function _getReward(Deposit memory deposit, uint256 rewardBlock) private view returns(uint256) {

        return _getReward(deposit, rewardBlock, _checkpointBlock, _cumulativeTotal, _totalDepositWeight, _totalTokens);
    }

    function _getReward(Deposit memory deposit, uint256 rewardBlock, uint256 checkpointBlock, uint256 cumulativeTotal, uint256 totalDepositWeight, uint256 totalTokens) private view returns(uint256) {

        (uint256 netReward,,) = _getRewardInfo(deposit, deposit.amount, rewardBlock, checkpointBlock, cumulativeTotal, totalDepositWeight, totalTokens);
        return netReward;
    }

    function _getRewardInfo(Deposit memory deposit, uint256 amount, uint256 rewardBlock) private view returns(uint256, uint256, uint256) {

        return _getRewardInfo(deposit, amount, rewardBlock, _checkpointBlock, _cumulativeTotal, _totalDepositWeight, _totalTokens);
    }

    function _getRewardInfo(Deposit memory deposit, uint256 amount, uint256 rewardBlock, uint256 checkpointBlock, uint256 cumulativeTotal, uint256 totalDepositWeight, uint256 totalTokens) private view returns(uint256, uint256, uint256) {

        uint256 cumulativeAmount = amount * (MathUpgradeable.max(rewardBlock, deposit.blockNumber) - deposit.blockNumber);

        uint256 newCumulativeTotal = _getCumulativeTotal(rewardBlock, checkpointBlock, cumulativeTotal, totalTokens);

        if (cumulativeAmount > 0 && totalDepositWeight > 0) {
            uint256 grossReward = balanceOf(getFarmingFund()) * cumulativeAmount / newCumulativeTotal;
            uint256 netReward = deposit.multiplier * grossReward / 1000;

            return (netReward, grossReward, newCumulativeTotal - cumulativeAmount);
        }

        return (0, 0, newCumulativeTotal);
    }


    function _getMultiplier(uint256 amount, uint256 vestingBlocks, uint256 unbondingBlocks) private view returns(uint256, uint256, uint256) {

        require(amount > 0, "SchnoodleFarming: deposit amount must be greater than zero");
        require(vestingBlocks > 0, "SchnoodleFarming: vesting blocks must be greater than zero");
        require(unbondingBlocks > 0, "SchnoodleFarming: unbonding blocks must be greater than zero");
        require(unbondingBlocks <= _maxUnbondingBlocks, "SchnoodleFarming: unbonding blocks is greater than the defined maximum");

        (uint256 totalTokens, uint256 totalDepositWeight) = _getAggregatedTotals(int256(amount), vestingBlocks, unbondingBlocks);
        uint256 lockProductWeightedAverage = totalDepositWeight / totalTokens;

        int128 z = ABDKMath64x64.mul(
            ABDKMath64x64.div(
                ABDKMath64x64.fromInt(-int256(_sigmoidParams.k)),
                ABDKMath64x64.fromUInt(lockProductWeightedAverage)
            ),
            ABDKMath64x64.fromInt(int256(vestingBlocks * unbondingBlocks) - int256(lockProductWeightedAverage))
        );

        int128 one = ABDKMath64x64.fromUInt(1);
        uint256 multiplier = ABDKMath64x64.toUInt(
            ABDKMath64x64.mul(
                ABDKMath64x64.fromUInt(1000),
                ABDKMath64x64.div(
                    one,
                    ABDKMath64x64.pow(
                        ABDKMath64x64.add(
                            one,
                            ABDKMath64x64.exp(z)
                        ),
                        _sigmoidParams.a
                    )
                )
            )
        );

        return (multiplier, totalTokens, totalDepositWeight);
    }

    function changeSigmoidParams(uint256 k, uint256 a) external onlyOwner {

        _sigmoidParams = SigmoidParams(k, a);
    }

    function sigmoidParams() external view returns(SigmoidParams memory) {

        return _sigmoidParams;
    }

    
    function _getCumulativeTotal(uint256 rewardBlock) private view returns(uint256) {

        return _getCumulativeTotal(rewardBlock, _checkpointBlock, _cumulativeTotal, _totalTokens);
    }

    function _getCumulativeTotal(uint256 rewardBlock, uint256 checkpointBlock, uint256 cumulativeTotal, uint256 totalTokens) private pure returns(uint256) {

        return cumulativeTotal + totalTokens * (rewardBlock - checkpointBlock);
    }

    function _getAggregatedTotals(int256 amountDelta, uint256 vestingBlocks, uint256 unbondingBlocks) private view returns(uint256, uint256) {

        return (
            uint256(int256(_totalTokens) + amountDelta), // Aggregate total tokens
            uint256(int256(_totalDepositWeight) + amountDelta * int256(vestingBlocks) * int256(unbondingBlocks)) // Aggregate total deposit weight
        );
    }


    function depositedBalanceOf(address account) public view returns(uint256) {

        return _balances[account];
    }

    function unbondingBalanceOf(address account) public view returns(uint256) {

        uint256 blockNumber = block.number;
        uint256 total;
        Unbond[] storage unbonds = _accountUnbonds[account];

        for (uint256 i = 0; i < unbonds.length; i++) {
            Unbond memory unbond = unbonds[i];
            if (unbond.expiryBlock > blockNumber) {
                total += unbond.amount;
            }
        }

        return total;
    }

    function lockedBalanceOf(address account) public view returns (uint256) {

        return unbondingBalanceOf(account) + depositedBalanceOf(account);
    }


    function getFarmingSummary(address account) public view returns(DepositReward[] memory) {

        Deposit[] storage deposits = _accountDeposits[account];
        DepositReward[] memory depositRewards = new DepositReward[](deposits.length);
        uint256 rewardBlock = block.number;

        for (uint256 i = 0; i < deposits.length; i++) {
            depositRewards[i] = DepositReward(deposits[i], _getReward(deposits[i], rewardBlock));
        }

        return depositRewards;
    }

    function getUnbondingSummary(address account) public view returns(Unbond[] memory) {

        return _accountUnbonds[account];
    }


    function getFarmingFund() private view returns (address) {

        (bool success, bytes memory result) = _schnoodle.staticcall(abi.encodeWithSignature("getFarmingFund()"));
        assert(success);
        return abi.decode(result, (address));
    }

    function balanceOf(address account) private view returns(uint256) {

        (bool success, bytes memory result) = _schnoodle.staticcall(abi.encodeWithSignature("balanceOf(address)", account));
        assert(success);
        return abi.decode(result, (uint256));
    }

    function farmingReward(address account, uint256 netReward, uint256 grossReward) private {

        (bool success,) = _schnoodle.call(abi.encodeWithSignature("farmingReward(address,uint256,uint256)", account, netReward, grossReward));
        assert(success);
    }


    event Deposited(address indexed account, uint256 depositId, uint256 amount, uint256 vestingBlocks, uint256 unbondingBlocks, uint256 multiplier, uint256 totalTokens, uint256 totalDepositWeight, uint256 cumulativeTotal);

    event UpdatedDeposit(address indexed account, uint256 depositId, uint256 vestingBlocks, uint256 unbondingBlocks, uint256 multiplier);

    event Withdrawn(address indexed account, uint256 depositId, uint256 amount, uint256 netReward, uint256 grossReward, uint256 totalTokens, uint256 totalDepositWeight, uint256 cumulativeTotal);

    event VestingBlocksFactorChanged(uint256 rate);

    event UnbondingBlocksFactorChanged(uint256 rate);

    event MaxUnbondingBlocksChanged(uint256 max);
}