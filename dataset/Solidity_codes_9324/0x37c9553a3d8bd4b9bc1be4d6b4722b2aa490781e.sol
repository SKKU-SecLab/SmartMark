



pragma solidity ^0.8.6;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

}



pragma solidity ^0.8.6;

library Roots {


    function nthRoot(uint _a, uint _n, uint _dp, uint _maxIts) pure internal returns(uint) {

        assert (_n > 1);

        uint one = 10 ** (1 + _dp);
        uint a0 = one ** _n * _a;

        uint xNew = one;

        uint iter = 0;
        while (iter < _maxIts) {
            uint x = xNew;
            uint t0 = x ** (_n - 1);
            if (x * t0 > a0) {
                xNew = x - (x - a0 / t0) / _n;
            } else {
                xNew = x + (a0 / t0 - x) / _n;
            }
            ++iter;
            if(xNew == x) {
                break;
            }
        }

        return (xNew + 5) / 10;
    }
}



pragma solidity >=0.6.0;

library Base64 {

    string internal constant TABLE_ENCODE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    bytes  internal constant TABLE_DECODE = hex"0000000000000000000000000000000000000000000000000000000000000000"
                                            hex"00000000000000000000003e0000003f3435363738393a3b3c3d000000000000"
                                            hex"00000102030405060708090a0b0c0d0e0f101112131415161718190000000000"
                                            hex"001a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132330000000000";

    function encode(bytes memory data) internal pure returns (string memory) {

        if (data.length == 0) return '';

        string memory table = TABLE_ENCODE;

        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr( 6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(        input,  0x3F))))
                resultPtr := add(resultPtr, 1)
            }

            switch mod(mload(data), 3)
            case 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }
            case 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }
        }

        return result;
    }

    function decode(string memory _data) internal pure returns (bytes memory) {

        bytes memory data = bytes(_data);

        if (data.length == 0) return new bytes(0);
        require(data.length % 4 == 0, "invalid base64 decoder input");

        bytes memory table = TABLE_DECODE;

        uint256 decodedLen = (data.length / 4) * 3;

        bytes memory result = new bytes(decodedLen + 32);

        assembly {
            let lastBytes := mload(add(data, mload(data)))
            if eq(and(lastBytes, 0xFF), 0x3d) {
                decodedLen := sub(decodedLen, 1)
                if eq(and(lastBytes, 0xFFFF), 0x3d3d) {
                    decodedLen := sub(decodedLen, 1)
                }
            }

            mstore(result, decodedLen)

            let tablePtr := add(table, 1)

            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
               dataPtr := add(dataPtr, 4)
               let input := mload(dataPtr)

               let output := add(
                   add(
                       shl(18, and(mload(add(tablePtr, and(shr(24, input), 0xFF))), 0xFF)),
                       shl(12, and(mload(add(tablePtr, and(shr(16, input), 0xFF))), 0xFF))),
                   add(
                       shl( 6, and(mload(add(tablePtr, and(shr( 8, input), 0xFF))), 0xFF)),
                               and(mload(add(tablePtr, and(        input , 0xFF))), 0xFF)
                    )
                )
                mstore(resultPtr, shl(232, output))
                resultPtr := add(resultPtr, 3)
            }
        }

        return result;
    }
}


pragma solidity ^0.8.6;

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
}


pragma solidity ^0.8.6;





interface ICombineMetadata {    

    function tokenMetadata(
        uint256 tokenId, 
        uint256 rarity, 
        uint256 tokenDensity, 
        uint256 alphaDensity, 
        bool isAlpha, 
        uint256 mergeCount) external view returns (string memory);

}

contract CombineMetadata is ICombineMetadata {

    
    struct ERC721MetadataStructure {
        bool isImageLinked;
        string name;
        string description;
        string createdBy;
        string image;
        ERC721MetadataAttribute[] attributes;
    }

    struct ERC721MetadataAttribute {
        bool includeDisplayType;
        bool includeTraitType;
        bool isValueAString;
        string displayType;
        string traitType;
        string value;
    }
    
    using ABDKMath64x64 for int128;    
    using Base64 for string;
    using Roots for uint;    
    using Strings for uint256;    
    
    address public owner;  

    string private _name;
    string private _imageBaseURI;
    string private _imageExtension;
    uint256 private _maxRadius;
    string[] private _imageParts;
    mapping (string => string) private _classStyles;
  
    string constant private _OFFSET_TAG = '<OFFSET>';
    string constant private _RADIUS_TAG = '<RADIUS>';
    string constant private _CLASS_TAG = '<CLASS>';  
    string constant private _CLASS_STYLE_TAG = '<CLASS_STYLE>';

    function getRadius() public view returns (uint256) { 

        return _maxRadius;
    }
  
    constructor() {
        owner = msg.sender;
        _name = "c";
        _imageBaseURI = ""; // Set to empty string - results in on-chain SVG generation by default unless this is set later
        _imageExtension = ""; // Set to empty string - can be changed later to remain empty, .png, .mp4, etc
        _maxRadius = 2000;

        _imageParts.push("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' width='2000' height='2000'>");
            _imageParts.push("<style>");
                _imageParts.push(".m1 #c{fill: #fff;}");
                _imageParts.push(".m1 #r{fill: #000;}");
                _imageParts.push(".m2 #c{fill: #fff;}");
                _imageParts.push(".m2 #r{fill: #10a;}"); // b
                _imageParts.push(".m3 #c{fill: #df0;}"); // y
                _imageParts.push(".m3 #r{fill: #000;}");
                _imageParts.push(".m4 #c{fill: #f00;}"); // r
                _imageParts.push(".m4 #r{fill: #000;}");
                _imageParts.push(".a #c{fill: #000 !important;}"); // b
                _imageParts.push(".a #r{fill: #000 !important;}");
                _imageParts.push(_CLASS_STYLE_TAG);
            _imageParts.push("</style>");
            _imageParts.push("<g class='");
                _imageParts.push(_CLASS_TAG);
                _imageParts.push("'>");
                    _imageParts.push("<rect id='r' width='2000' height='2000'/>");
                    _imageParts.push("<rect id='c' x='");
                        _imageParts.push(_OFFSET_TAG);
                    _imageParts.push("' y='");
                        _imageParts.push(_OFFSET_TAG);
                    _imageParts.push("' width='");
                        _imageParts.push(_RADIUS_TAG);
                    _imageParts.push("' height='");
                        _imageParts.push(_RADIUS_TAG);
                    _imageParts.push("'/>");

            _imageParts.push("</g>");                
        _imageParts.push("</svg>");
    }        
    
    function setName(string calldata name_) external { 

        _requireOnlyOwner();       
        _name = name_;
    }

    function setImageBaseURI(string calldata imageBaseURI_, string calldata imageExtension_) external {        

        _requireOnlyOwner();
        _imageBaseURI = imageBaseURI_;
        _imageExtension = imageExtension_;
    }

    function setMaxRadius(uint256 maxRadius_) external {

        _requireOnlyOwner();
        _maxRadius = maxRadius_;
    }    

    function tokenMetadata(uint256 tokenId, uint256 rarity, uint256 tokenDensity, uint256 alphaDensity, bool isAlpha, uint256 mergeCount) external view override returns (string memory) {        

        string memory base64Json = Base64.encode(bytes(string(abi.encodePacked(_getJson(tokenId, rarity, tokenDensity, alphaDensity, isAlpha, mergeCount)))));
        return string(abi.encodePacked('data:application/json;base64,', base64Json));
    }

    function updateImageParts(string[] memory imageParts_) public {

        _requireOnlyOwner();
        _imageParts = imageParts_;
    }

    function updateClassStyle(string calldata cssClass, string calldata cssStyle) external {

        _requireOnlyOwner();
        _classStyles[cssClass] = cssStyle;
    }

    function getClassStyle(string memory cssClass) public view returns (string memory) {

        return _classStyles[cssClass];
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function imageBaseURI() public view returns (string memory) {

        return _imageBaseURI;
    }

    function imageExtension() public view returns (string memory) {

        return _imageExtension;
    }

    function maxRadius() public view returns (uint256) {

        return _maxRadius;
    }            

    function getClassString(uint256 tokenId, uint256 rarity, bool isAlpha, bool offchainImage) public pure returns (string memory) {

        return _getClassString(tokenId, rarity, isAlpha, offchainImage);
    }

    function _getJson(uint256 tokenId, uint256 rarity, uint256 tokenDensity, uint256 alphaDensity, bool isAlpha, uint256 mergeCount) private view returns (string memory) {        

        string memory imageData = 
            bytes(_imageBaseURI).length == 0 ? 
                _getSvg(tokenId, rarity, tokenDensity, alphaDensity, isAlpha) :
                string(abi.encodePacked(imageBaseURI(), _getClassString(tokenId, rarity, isAlpha, true), "_", uint256(int256(_getScaledRadius(tokenDensity, alphaDensity, _maxRadius).toInt())).toString(), imageExtension()));

        ERC721MetadataStructure memory metadata = ERC721MetadataStructure({
            isImageLinked: bytes(_imageBaseURI).length > 0, 
            name: string(abi.encodePacked(name(), "(", tokenDensity.toString(), ") #", tokenId.toString())),
            description: tokenDensity.toString(),
            createdBy: "Hak",
            image: imageData,
            attributes: _getJsonAttributes(tokenId, rarity, tokenDensity, mergeCount, isAlpha)
        });

        return _generateERC721Metadata(metadata);
    }        

    function _getJsonAttributes(uint256 tokenId, uint256 rarity, uint256 tokenDensity, uint256 mergeCount, bool isAlpha) private pure returns (ERC721MetadataAttribute[] memory) {

        uint256 tensDigit = tokenId % 100 / 10;
        uint256 onesDigit = tokenId % 10;
        uint256 class = tensDigit * 10 + onesDigit;

        ERC721MetadataAttribute[] memory metadataAttributes = new ERC721MetadataAttribute[](5);
        metadataAttributes[0] = _getERC721MetadataAttribute(false, true, false, "", "Density", tokenDensity.toString());
        metadataAttributes[1] = _getERC721MetadataAttribute(false, true, false, "", "Alpha", isAlpha ? "1" : "0");
        metadataAttributes[2] = _getERC721MetadataAttribute(false, true, false, "", "Tier", rarity.toString());
        metadataAttributes[3] = _getERC721MetadataAttribute(false, true, false, "", "Class", class.toString());
        metadataAttributes[4] = _getERC721MetadataAttribute(false, true, false, "", "Combines", mergeCount.toString());
        return metadataAttributes;
    }    

    function _getERC721MetadataAttribute(bool includeDisplayType, bool includeTraitType, bool isValueAString, string memory displayType, string memory traitType, string memory value) private pure returns (ERC721MetadataAttribute memory) {

        ERC721MetadataAttribute memory attribute = ERC721MetadataAttribute({
            includeDisplayType: includeDisplayType,
            includeTraitType: includeTraitType,
            isValueAString: isValueAString,
            displayType: displayType,
            traitType: traitType,
            value: value
        });

        return attribute;
    }    

    function _getSvg(uint256 tokenId, uint256 rarity, uint256 tokenDensity, uint256 alphaDensity, bool isAlpha) private view returns (string memory) {

        bytes memory byteString;
        int128 radius = _getScaledRadius(tokenDensity, alphaDensity, _maxRadius);
        int128 offset = _getOffset(radius, _maxRadius);
        for (uint i = 0; i < _imageParts.length; i++) {
          if (_checkTag(_imageParts[i], _RADIUS_TAG)) {
            byteString = abi.encodePacked(byteString, _floatToString(radius));
          } else if (_checkTag(_imageParts[i], _OFFSET_TAG)) {
            byteString = abi.encodePacked(byteString, _floatToString(offset));
          } else if (_checkTag(_imageParts[i], _CLASS_TAG)) {
            byteString = abi.encodePacked(byteString, _getClassString(tokenId, rarity, isAlpha, false));
          } else if (_checkTag(_imageParts[i], _CLASS_STYLE_TAG)) {
              uint256 tensDigit = tokenId % 100 / 10;
              uint256 onesDigit = tokenId % 10;
              uint256 class = tensDigit * 10 + onesDigit;
              string memory classCss = getClassStyle(_getTokenIdClass(class));
              if(bytes(classCss).length > 0) {
                  byteString = abi.encodePacked(byteString, classCss);
              }            
          } else {
            byteString = abi.encodePacked(byteString, _imageParts[i]);
          }
        }
        return string(byteString); 
    }

    function _getScaledRadius(uint256 tokenDensity, uint256 alphaDensity, uint256 maximumRadius) private pure returns (int128) {

        int128 radiusDensity = _getRadius64x64(tokenDensity);
        int128 radiusAlphaDensity = _getRadius64x64(alphaDensity);
        int128 scalePercentage = ABDKMath64x64.div(radiusDensity, radiusAlphaDensity);                
        int128 scaledRadius = ABDKMath64x64.mul(ABDKMath64x64.fromUInt(maximumRadius), scalePercentage);
        if(uint256(int256(scaledRadius.toInt())) == 0) {
            scaledRadius = ABDKMath64x64.fromUInt(1);
        }
        return scaledRadius;
    }

    function _getOffset(int128 radius, uint256 maximumRadius) private pure returns (int128) {

        
        int128 remainLength = ABDKMath64x64.sub(ABDKMath64x64.fromUInt(maximumRadius), radius);                
        int128 offset = ABDKMath64x64.div(remainLength, ABDKMath64x64.fromUInt(2));
        if(uint256(int256(offset.toInt())) == 0) {
            offset = ABDKMath64x64.fromUInt(0);
        }
        return offset;
    }

    function _getRadius64x64(uint256 density) private pure returns (int128) {        

        int128 cubeRootScalar = ABDKMath64x64.divu(62035049089, 100000000000);
        int128 cubeRootDensity = ABDKMath64x64.divu(density.nthRoot(3, 6, 32), 1000000);
        int128 radius = ABDKMath64x64.mul(cubeRootDensity, cubeRootScalar);        
        return radius;
    }            

    function _generateERC721Metadata(ERC721MetadataStructure memory metadata) private pure returns (string memory) {

      bytes memory byteString;    
    
        byteString = abi.encodePacked(
          byteString,
          _openJsonObject());
    
        byteString = abi.encodePacked(
          byteString,
          _pushJsonPrimitiveStringAttribute("name", metadata.name, true));
    
        byteString = abi.encodePacked(
          byteString,
          _pushJsonPrimitiveStringAttribute("description", metadata.description, true));
    
        byteString = abi.encodePacked(
          byteString,
          _pushJsonPrimitiveStringAttribute("created_by", metadata.createdBy, true));
    
        if(metadata.isImageLinked) {
            byteString = abi.encodePacked(
                byteString,
                _pushJsonPrimitiveStringAttribute("image", metadata.image, true));
        } else {
            byteString = abi.encodePacked(
                byteString,
                _pushJsonPrimitiveStringAttribute("image_data", metadata.image, true));
        }

        byteString = abi.encodePacked(
          byteString,
          _pushJsonComplexAttribute("attributes", _getAttributes(metadata.attributes), false));
    
        byteString = abi.encodePacked(
          byteString,
          _closeJsonObject());
    
        return string(byteString);
    }

    function _getAttributes(ERC721MetadataAttribute[] memory attributes) private pure returns (string memory) {

        bytes memory byteString;
    
        byteString = abi.encodePacked(
          byteString,
          _openJsonArray());
    
        for (uint i = 0; i < attributes.length; i++) {
          ERC721MetadataAttribute memory attribute = attributes[i];

          byteString = abi.encodePacked(
            byteString,
            _pushJsonArrayElement(_getAttribute(attribute), i < (attributes.length - 1)));
        }
    
        byteString = abi.encodePacked(
          byteString,
          _closeJsonArray());
    
        return string(byteString);
    }

    function _getAttribute(ERC721MetadataAttribute memory attribute) private pure returns (string memory) {

        bytes memory byteString;
        
        byteString = abi.encodePacked(
          byteString,
          _openJsonObject());
    
        if(attribute.includeDisplayType) {
          byteString = abi.encodePacked(
            byteString,
            _pushJsonPrimitiveStringAttribute("display_type", attribute.displayType, true));
        }
    
        if(attribute.includeTraitType) {
          byteString = abi.encodePacked(
            byteString,
            _pushJsonPrimitiveStringAttribute("trait_type", attribute.traitType, true));
        }
    
        if(attribute.isValueAString) {
          byteString = abi.encodePacked(
            byteString,
            _pushJsonPrimitiveStringAttribute("value", attribute.value, false));
        } else {
          byteString = abi.encodePacked(
            byteString,
            _pushJsonPrimitiveNonStringAttribute("value", attribute.value, false));
        }
    
        byteString = abi.encodePacked(
          byteString,
          _closeJsonObject());
    
        return string(byteString);
    }

    function _getClassString(uint256 tokenId, uint256 rarity, bool isAlpha, bool offchainImage) private pure returns (string memory) {

        bytes memory byteString;    
    
        byteString = abi.encodePacked(byteString, _getRarityClass(rarity));
        
        if(isAlpha) {
            byteString = abi.encodePacked(
              byteString,
              string(abi.encodePacked(offchainImage ? "_" : " ", "a")));
        }

        uint256 tensDigit = tokenId % 100 / 10;
        uint256 onesDigit = tokenId % 10;
        uint256 class = tensDigit * 10 + onesDigit;

        byteString = abi.encodePacked(
          byteString,
          string(abi.encodePacked(offchainImage ? "_" : " ", _getTokenIdClass(class))));

        return string(byteString);    
    }

    function _getRarityClass(uint256 rarity) private pure returns (string memory) {

        return string(abi.encodePacked("m", rarity.toString()));
    }

    function _getTokenIdClass(uint256 class) private pure returns (string memory) {

        return string(abi.encodePacked("c", class.toString()));
    }

    function _checkTag(string storage a, string memory b) private pure returns (bool) {

        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function _floatToString(int128 value) private pure returns (string memory) {

        uint256 decimal4 = (value & 0xFFFFFFFFFFFFFFFF).mulu(10000);
        return string(abi.encodePacked(uint256(int256(value.toInt())).toString(), '.', _decimal4ToString(decimal4)));
    }
  
    function _decimal4ToString(uint256 decimal4) private pure returns (string memory) {

        bytes memory decimal4Characters = new bytes(4);
        for (uint i = 0; i < 4; i++) {
          decimal4Characters[3 - i] = bytes1(uint8(0x30 + decimal4 % 10));
          decimal4 /= 10;
        }
        return string(abi.encodePacked(decimal4Characters));
    }

    function _requireOnlyOwner() private view {

        require(msg.sender == owner, "You are not the owner");
    }

    function _openJsonObject() private pure returns (string memory) {        

        return string(abi.encodePacked("{"));
    }

    function _closeJsonObject() private pure returns (string memory) {
        return string(abi.encodePacked("}"));
    }

    function _openJsonArray() private pure returns (string memory) {        

        return string(abi.encodePacked("["));
    }

    function _closeJsonArray() private pure returns (string memory) {        

        return string(abi.encodePacked("]"));
    }

    function _pushJsonPrimitiveStringAttribute(string memory key, string memory value, bool insertComma) private pure returns (string memory) {

        return string(abi.encodePacked('"', key, '": "', value, '"', insertComma ? ',' : ''));
    }

    function _pushJsonPrimitiveNonStringAttribute(string memory key, string memory value, bool insertComma) private pure returns (string memory) {

        return string(abi.encodePacked('"', key, '": ', value, insertComma ? ',' : ''));
    }

    function _pushJsonComplexAttribute(string memory key, string memory value, bool insertComma) private pure returns (string memory) {

        return string(abi.encodePacked('"', key, '": ', value, insertComma ? ',' : ''));
    }

    function _pushJsonArrayElement(string memory value, bool insertComma) private pure returns (string memory) {

        return string(abi.encodePacked(value, insertComma ? ',' : ''));
    }
}


pragma solidity ^0.8.6;


interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface ERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed fromAddress, address indexed toAddress);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}

interface ERC721Metadata {

    function name() external view returns (string memory _name);

    function symbol() external view returns (string memory _symbol);

    function tokenURI(uint256 _tokenId) external view returns (string memory);

}

contract Combine is ERC721, ERC721Metadata {

 
    ICombineMetadata public _metadataGenerator;

    bool public frozen;

    string private _name;
    string private _symbol;

    uint256 constant private CLASS_MULTIPLIER = 100000; // 100k

    uint256 constant private MIN_CLASS_INCL = 1; 
    uint256 constant private MAX_CLASS_INCL = 4;

    uint256 constant private MIN_DENSITY_INCL = 1; 
    uint256 constant private MAX_DENSITY_EXCL = CLASS_MULTIPLIER - 1;

    uint256 public _saleStartTime = 1640969999;
    uint256 public _saleEndTime = 1699999999;

    uint256 public _maxSupply = 5000;
    uint256 public _maxDensity = 25000;

    uint256 public _unitPrice = 25e15;

    uint256 public _freeIndex = 101;
 
    uint256 public _nextMintId;
 
    uint256 public _countToken;

    uint256 immutable public _percentageTotal;
    uint256 public _percentageRoyalty;

    uint256 public _alphaDensity;

    uint256 public _alphaId;

    uint256 public _densityTotal;

    address public _hak;
    address public _collab;
    address public _fund;
    address public _receiver;
    address constant public _dead = 0x000000000000000000000000000000000000dEaD;

    event AlphaDensityUpdate(uint256 indexed tokenId, uint256 alphaDensity);

    event DensityUpdate(uint256 indexed tokenIdBurned, uint256 indexed tokenIdPersist, uint256 density);

    uint256[5001] private _tokenIdArray;

    mapping (uint256 => uint256) private _tokenIdToIndex;

    mapping (address => bool) private _blacklistAddress;

    mapping (address => bool) private _whitelistAddress;

    mapping (address => uint256) private _tokens;

    mapping (address => uint256) private _balances;

    mapping (uint256 => uint256) private _values;

    mapping (uint256 => uint256) private _combineCount;

    mapping (uint256 => address) private _owners;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;


    function getCombineCount(uint256 tokenId) public view returns (uint256 combineCount) {

        require(_exists(tokenId), "nonexistent token");
        return _combineCount[tokenId];
    }

    function getTokenIdFromArray(uint256 index) public view returns (uint256 tokenId) {

        return _tokenIdArray[index];
    }

    function getIndexFromTokenId(uint256 tokenId) public view returns (uint256 index) {

        return _tokenIdToIndex[tokenId];
    }

    modifier onlyHak() {

        require(_msgSender() == _hak, "msg.sender is not hak");
        _;
    }

    modifier onlyValidWhitelist() {

        require(_whitelistAddress[_msgSender()], "invalid msg.sender");
        _;
    }

    modifier notFrozen() {

        require(!frozen, "transfer frozen");
        _;
    }

    function ensureValidClass(uint256 class) private pure {

        require(MIN_CLASS_INCL <= class && class <= MAX_CLASS_INCL, "class must be [1,4].");
    }

    function ensureValidDensity(uint256 density) private pure {

        require(MIN_DENSITY_INCL <= density && density < MAX_DENSITY_EXCL, "density must be [1,100k-1).");
    }
   
    constructor(address metadataGenerator_, address collab_, address fund_) {

        _metadataGenerator = ICombineMetadata(metadataGenerator_);
        _name = "combine.";
        _symbol = "c";

        _hak = msg.sender;
        _collab = collab_;
        _fund = fund_;
        _receiver = _hak;

        _percentageTotal = 10000;
        _percentageRoyalty = 1000;

        _blacklistAddress[address(this)] = true;            

        _values[1] = encodeClassAndDensity(1, 10);         
        _owners[1] = msg.sender;
        _tokens[msg.sender] = 1;
        emit Transfer(address(0), msg.sender, 1);
        _countToken++;
        _balances[msg.sender]++;
        _densityTotal = 10;
        _alphaDensity = 10;
        _alphaId = 1;
        emit AlphaDensityUpdate(1, 10);

        _tokenIdToIndex[1] = 1;
        _tokenIdArray[_countToken] = 1;
        _nextMintId = 2;
    }
        
    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    } 

    function totalSupply() public view returns (uint256) {

        return _countToken;
    }
 
    function combine(uint256 tokenIdRcvr, uint256 tokenIdSndr) external onlyValidWhitelist notFrozen returns (uint256 tokenIdDead) {        

        address owner = ownerOf(tokenIdRcvr);
        require(owner == ownerOf(tokenIdSndr), "disparate owner");
        require(_msgSender() == owner, "not token owner.");

        _balances[owner] -= 1;

        tokenIdDead = _combine(tokenIdRcvr, tokenIdSndr);

        delete _owners[tokenIdDead];

        emit Transfer(owner, address(0), tokenIdDead);
    }

    function _transfer(address owner, address from, address to, uint256 tokenId) internal notFrozen {

        require(owner == from, "token not own");
        require(to != address(0), "cannot transfer to zero addr");
        require(!_blacklistAddress[to], "cannot transfer to blacklist");

        if (to == _dead) {
            _burnNoEmitTransfer(owner, tokenId);

            emit Transfer(from, _dead, tokenId);
            emit Transfer(_dead, address(0), tokenId);
        } else {
            _approve(owner, address(0), tokenId);

            emit Transfer(from, to, tokenId);

            if (from == to) {
                return;
            }



            bool fromIsWhitelisted = isWhitelisted(from);
            bool toIsWhitelisted = isWhitelisted(to);

            if (fromIsWhitelisted) {
                _balances[from] -= 1;
            } else {
                delete _balances[from];
            }
            if (toIsWhitelisted) {
                _balances[to] += 1;
            } else if (_tokens[to] == 0) {
                _balances[to] = 1;
            } else {
            }

            if (toIsWhitelisted) {
                _owners[tokenId] = to;
            } else {
                uint256 currentTokenId = _tokens[to];

                if (currentTokenId == 0) {
                    _owners[tokenId] = to;

                    _tokens[to] = tokenId;
                } else {
                    uint256 sentTokenId = tokenId;

                    uint256 deadTokenId = _combine(currentTokenId, sentTokenId);

                    emit Transfer(to, address(0), deadTokenId);

                    uint256 aliveTokenId = currentTokenId;
                    if (currentTokenId == deadTokenId) {
                        aliveTokenId = sentTokenId;
                    }

                    delete _owners[deadTokenId];

                    if (currentTokenId != aliveTokenId) {
                        _owners[aliveTokenId] = to;

                        _tokens[to] = aliveTokenId;
                    }
                }
            }

            if (!fromIsWhitelisted) {
                delete _tokens[from];
            }
        }
    }

    function _increaseDensity(uint256 tokenId, uint256 density_) private {

        uint256 currentDensity = decodeDensity(_values[tokenId]);
        _values[tokenId] += density_;

        uint256 newDensity = currentDensity + density_;

        if(newDensity > _alphaDensity) {
            _alphaId = tokenId;
            _alphaDensity = newDensity;
            emit AlphaDensityUpdate(_alphaId, newDensity);
        }

        emit DensityUpdate(0, tokenId, newDensity);
    }

    function _combine(uint256 tokenIdRcvr, uint256 tokenIdSndr) internal returns (uint256 tokenIdDead) {

        require(tokenIdRcvr != tokenIdSndr, "identical tokenId");

        uint256 densityRcvr = decodeDensity(_values[tokenIdRcvr]);
        uint256 densitySndr = decodeDensity(_values[tokenIdSndr]);
        
        uint256 densitySmall = densityRcvr;
        uint256 densityLarge = densitySndr;

        uint256 tokenIdSmall = tokenIdRcvr;
        uint256 tokenIdLarge = tokenIdSndr;

        if (densityRcvr >= densitySndr) {

            densitySmall = densitySndr;
            densityLarge = densityRcvr;

            tokenIdSmall = tokenIdSndr;
            tokenIdLarge = tokenIdRcvr;
        }

        _values[tokenIdLarge] += densitySmall;

        uint256 combinedDensity = densityLarge + densitySmall;

        if(combinedDensity > _alphaDensity) {
            _alphaId = tokenIdLarge;
            _alphaDensity = combinedDensity;
            emit AlphaDensityUpdate(_alphaId, combinedDensity);
        }
        
        _combineCount[tokenIdLarge]++;

        delete _values[tokenIdSmall];

        uint256 indexToReplace = _tokenIdToIndex[tokenIdSmall];
        uint256 lastTokenId = _tokenIdArray[_countToken];
        _tokenIdArray[indexToReplace] = lastTokenId;
        _tokenIdToIndex[lastTokenId] = indexToReplace;
        _countToken--;

        emit DensityUpdate(tokenIdSmall, tokenIdLarge, combinedDensity);

        return tokenIdSmall;
    }

    function setRoyaltyBips(uint256 percentageRoyalty_) external onlyHak {

        require(percentageRoyalty_ <= _percentageTotal, "more than 100%");
        _percentageRoyalty = percentageRoyalty_;
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address, uint256) {

        uint256 royaltyAmount = (salePrice * _percentageRoyalty) / _percentageTotal;
        return (_receiver, royaltyAmount);
    }

    function setBlacklistAddress(address address_, bool status) external onlyHak {

        _blacklistAddress[address_] = status;
    }

    function setCollab(address collab_) external onlyHak {  

        _collab = collab_;
    }

    function setFund(address fund_) external onlyHak {  

        _fund = fund_;
    }

    function setHak(address hak_) external onlyHak {

        require(address(this).balance < 1e16, "be careful");
        _hak = hak_;
    }

    function setUnitPrice(uint256 unitPrice_) external onlyHak {

        _unitPrice = unitPrice_;
    }

    function setSaleStartTime(uint256 startTime_) external onlyHak {

        require(
            startTime_ < _saleEndTime,
            "invalid time"
        );
        _saleStartTime = startTime_;
    }

    function setSaleEndTime(uint256 endTime_) external onlyHak {

        require(
            _saleStartTime < endTime_,
            "invalid time"
        );
        _saleEndTime = endTime_;
    }

    function setMaxSupply(uint256 count_) external onlyHak {

        require(_nextMintId <= count_, "invalid supply count");
        _maxSupply = count_;
    }

    function setFreeIndex(uint256 index_) external onlyHak {

        require(_nextMintId <= index_ && index_ <= _maxSupply, "invalid index");
        _freeIndex = index_;
    }
    
    function setMaxDensity(uint256 density_) external onlyHak {

        require(_densityTotal <= density_ && density_ <= MAX_DENSITY_EXCL, "invalid density");
        _maxDensity = density_;
    }

    function setRoyaltyReceiver(address receiver_) external onlyHak {  

        _receiver = receiver_;
    }
    
    function setMetadataGenerator(address metadataGenerator_) external onlyHak {  

        _metadataGenerator = ICombineMetadata(metadataGenerator_);
    }
   
    function whitelistUpdate(address address_, bool status) external onlyHak {


        if(status == false) {
            require(balanceOf(address_) <= 1, "addr cannot be removed");
        }

        _whitelistAddress[address_] = status;
    }

    function isWhitelisted(address address_) public view returns (bool) {

        return _whitelistAddress[address_];
    }

    function isBlacklisted(address address_) public view returns (bool) {

        return _blacklistAddress[address_];
    }

    function ownerOf(uint256 tokenId) public view override returns (address owner) {

        owner = _owners[tokenId]; 
        require(owner != address(0), "nonexistent token");
    }

    function mint(uint256 _densityToMint) external payable {

        require(
            block.timestamp >= _saleStartTime && block.timestamp < _saleEndTime,
            "sale not open"
        );
        require(_nextMintId < _maxSupply, "max supply reached");
        require(
            tx.origin == msg.sender,
            "cannot use custom contract"
        );

        bool ownACube = _balances[msg.sender] != 0;
        
        uint256 index = _nextMintId;
        uint256 alphaId = _alphaId;
        uint256 alphaDensity = _alphaDensity;

        uint256 paidCount = _densityToMint;

        if (msg.sender == _hak){
            paidCount = 0;
        
        } // first few are free for density 1 (nonholder only)
        else if (index <= _freeIndex && !ownACube){
            paidCount--;
        }

        require(
            msg.value >= paidCount * _unitPrice,
            "insufficient ETH"
        );

        uint256 prevDensityTotal = _densityTotal;
        uint256 newDensityTotal = prevDensityTotal + _densityToMint;
        require(
            newDensityTotal <= _maxDensity,
            "total max density reached"
        );
        _densityTotal = newDensityTotal;

        if (ownACube){
            require(!isWhitelisted(msg.sender), "cannot update wl density");
            _increaseDensity(tokenOf(msg.sender), _densityToMint);
            return;
        }

        uint256 class = (random() % 100) < 5 ? 2 : 1;

        _values[index] = encodeClassAndDensity(class, _densityToMint);         
        _owners[index] = msg.sender;


        _countToken++;

        if (alphaDensity < _densityToMint){
            alphaDensity = _densityToMint;
            alphaId = index;
        }

        _tokenIdArray[index] = index;
        _tokenIdToIndex[index] = index;

        _transfer(address(0), address(0), msg.sender, index);

        index++;
        _nextMintId = index; 


        if(_alphaId != alphaId) {
            _alphaId = alphaId;
            _alphaDensity = alphaDensity;
            emit AlphaDensityUpdate(alphaId, alphaDensity);
        }        
    }

    function random() private view returns (uint256) {

        bytes32 randomHash = keccak256(
            abi.encode(
                block.timestamp,
                block.difficulty,
                block.coinbase,
                msg.sender
            )
        );
        return uint256(randomHash);
    }
   

    function freeze(bool state_) external onlyHak {

        frozen = state_;
    }

    function _destroy(uint256 tokenId) private {

        address owner = _owners[tokenId];
        require(owner != address(0), "nonexistent token");
        _burnNoEmitTransfer(owner, tokenId);
        if (msg.value > 0){
            (bool success,) = owner.call{value: msg.value}("");
            require(success, "transfer failed");
        }
        emit Transfer(owner, address(0), tokenId);
    }

    function destroyWithMercy(uint256 tokenId) external payable onlyHak {

        _destroy(tokenId);
    }

    function destroyRandomWithMercy() external payable onlyHak {

        uint256 tokenId = _tokenIdArray[(random() % (_countToken)) + 1];
        uint256 newTokenId;
        while ((random() % _alphaDensity) > densityOf(tokenId)){
            newTokenId = _tokenIdArray[(random() % (_countToken)) + 1];
            if (tokenId == newTokenId){
                break;
            } else {
                tokenId = newTokenId;
            }
        }
        _destroy(tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {

        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "non ERC721Receiver implementer");
    }

    function transferFrom(address from, address to, uint256 tokenId) public virtual override {

        (address owner, bool isApprovedOrOwner) = _isApprovedOrOwner(_msgSender(), tokenId);
        require(isApprovedOrOwner, "not owner nor approved");
        _transfer(owner, from, to, tokenId);
    }

    function balanceOf(address owner) public view override returns (uint256) {

        return _balances[owner];        
    }

    function densityOf(uint256 tokenId) public view virtual returns (uint256) {

        uint256 value = getValueOf(tokenId);
        return decodeDensity(value);
    }

    function getValueOf(uint256 tokenId) public view virtual returns (uint256 value) {

        value = _values[tokenId];
        require(value != 0, "nonexistent token");
    }

    function tokenOf(address owner) public view virtual returns (uint256) {

        require(!isWhitelisted(owner), "tokenOf undefined");
        uint256 token = _tokens[owner];
        return token;
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ownerOf(tokenId);
        require(to != owner, "approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    function _approve(address owner, address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "nonexistent token");       
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        require(operator != _msgSender(), "approve to caller");
        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function exists(uint256 tokenId) public view returns (bool) {

        return _exists(tokenId);
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (address owner, bool isApprovedOrOwner) {

        owner = _owners[tokenId];

        require(owner != address(0), "nonexistent token");

        isApprovedOrOwner = (spender == owner || _tokenApprovals[tokenId] == spender || isApprovedForAll(owner, spender));
    }   

    function tokenURI(uint256 tokenId) public virtual view override returns (string memory) {

        require(_exists(tokenId), "nonexistent token");
        
        return _metadataGenerator.tokenMetadata(
            tokenId, 
            decodeClass(_values[tokenId]), 
            decodeDensity(_values[tokenId]), 
            decodeDensity(_values[_alphaId]), 
            tokenId == _alphaId,
            getCombineCount(tokenId));
    }

    function updateTokenClass(uint tokenId, uint256 class) external onlyHak {

        require(_exists(tokenId), "nonexistent token");
        _values[tokenId] = encodeClassAndDensity(class, densityOf(tokenId));
    }

    function encodeClassAndDensity(uint256 class, uint256 density) public pure returns (uint256) {

        ensureValidClass(class);
        ensureValidDensity(density);
        return ((class * CLASS_MULTIPLIER) + density);
    }

    function decodeClassAndDensity(uint256 value) public pure returns (uint256, uint256) {

        uint256 class = decodeClass(value);
        uint256 density = decodeDensity(value);
        return (class, density);
    }

    function decodeClass(uint256 value) public pure returns (uint256 class) {

        class = value / CLASS_MULTIPLIER; // integer division is ‘checked’ in Solidity 0.8.x
        ensureValidClass(class);
    }    

    function decodeDensity(uint256 value) public pure returns (uint256 density) {

        density = value % CLASS_MULTIPLIER; // integer modulo is ‘checked’ in Solidity 0.8.x
        ensureValidDensity(density);
    }

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }

    function withdrawAll() public onlyHak {

        uint256 currentBal = address(this).balance;
        require(currentBal > 0);
        if (_collab == _hak){
            _withdraw(_hak, address(this).balance);
        } else {
            _withdraw(_collab, currentBal / 4); // 25%
            _withdraw(_fund, currentBal / 2); // 50%
            _withdraw(_hak, address(this).balance); // 25%
        }
    }

    function _withdraw(address _addr, uint256 _amt) private {

        (bool success,) = _addr.call{value: _amt}("");
        require(success, "transfer failed");
    }
     
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {

        if (isContract(to)) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("non ERC721Receiver implementer");
                }
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
        return true;
    }    

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        bytes4 _ERC165_ = 0x01ffc9a7;
        bytes4 _ERC721_ = 0x80ac58cd;
        bytes4 _ERC2981_ = 0x2a55205a;
        bytes4 _ERC721Metadata_ = 0x5b5e139f;
        return interfaceId == _ERC165_ 
            || interfaceId == _ERC721_
            || interfaceId == _ERC2981_
            || interfaceId == _ERC721Metadata_;
    }


    function burn(uint256 tokenId) public notFrozen {

        (address owner, bool isApprovedOrOwner) = _isApprovedOrOwner(_msgSender(), tokenId);
        require(isApprovedOrOwner, "not owner nor approved");

        _burnNoEmitTransfer(owner, tokenId);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burnNoEmitTransfer(address owner, uint256 tokenId) internal {

        _approve(owner, address(0), tokenId);

        _densityTotal -= decodeDensity(_values[tokenId]);

        delete _tokens[owner];
        delete _owners[tokenId];
        delete _values[tokenId];

        uint256 indexToReplace = _tokenIdToIndex[tokenId];
        uint256 lastTokenId = _tokenIdArray[_countToken];
        _tokenIdArray[indexToReplace] = lastTokenId;
        _tokenIdToIndex[lastTokenId] = indexToReplace;
        _countToken--;



        _balances[owner] -= 1;        

        emit DensityUpdate(tokenId, 0, 0);
    }
}