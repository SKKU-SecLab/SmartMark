
pragma solidity ^0.6.0;

abstract contract Token {

    uint256 public totalSupply;

    function balanceOf(address _owner) virtual external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) virtual external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) virtual external returns (bool success);

    function approve(address _spender, uint256 _value) virtual external returns (bool success);

    function allowance(address _owner, address _spender) virtual external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

pragma solidity ^0.6.0;


contract BaseToken is Token {


    function transfer(address _to, uint256 _value) override virtual external returns (bool success) {

        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) override virtual external returns (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view override virtual external returns (uint256 balance) {

        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) override virtual external returns (bool success) {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) override virtual external view returns (uint256 remaining) {

      return allowed[_owner][_spender];
    }

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
}

pragma solidity ^0.5.0 || ^0.6.0;

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

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


contract Files is BaseToken {


    using ABDKMath64x64 for int128;

    enum EntryKind { NONE, DOWNLOADS, LINK, CATEGORY }

    uint256 constant LINK_KIND_LINK = 0;
    uint256 constant LINK_KIND_MESSAGE = 1;

    string public name;
    uint8 public decimals;
    string public symbol;

    int128 public salesOwnersShare = int128(1).divi(int128(10)); // 10%
    int128 public upvotesOwnersShare = int128(1).divi(int128(2)); // 50%
    int128 public uploadOwnersShare = int128(15).divi(int128(100)); // 15%
    int128 public buyerAffiliateShare = int128(1).divi(int128(10)); // 10%
    int128 public sellerAffiliateShare = int128(15).divi(int128(100)); // 15%

    uint maxId = 0;

    mapping (uint => EntryKind) entries;

    mapping (string => mapping (string => uint)) categoryTitles; // locale => (title => id)

    mapping (string => address payable) nickAddresses;
    mapping (address => string) addressNicks;

    event SetOwner(address payable owner); // share is 64.64 fixed point number
    event SetSalesOwnerShare(int128 share); // share is 64.64 fixed point number
    event SetUpvotesOwnerShare(int128 share); // share is 64.64 fixed point number
    event SetUploadOwnerShare(int128 share); // share is 64.64 fixed point number
    event SetBuyerAffiliateShare(int128 share); // share is 64.64 fixed point number
    event SetSellerAffiliateShare(int128 share); // share is 64.64 fixed point number
    event SetNick(address payable indexed owner, string nick);
    event SetARWallet(address payable indexed owner, string arWallet);
    event SetAuthorInfo(address payable indexed owner, string link, string shortDescription, string description, string locale);
    event ItemCreated(uint indexed itemId);
    event SetItemOwner(uint indexed itemId, address payable indexed owner);
    event ItemUpdated(uint indexed itemId, ItemInfo info);
    event LinkUpdated(uint indexed linkId,
                      string link,
                      string title,
                      string shortDescription,
                      string description,
                      string locale,
                      uint256 indexed linkKind);
    event ItemCoverUpdated(uint indexed itemId, uint indexed version, bytes cover, uint width, uint height);
    event ItemFilesUpdated(uint indexed itemId, string format, uint indexed version, bytes hash);
    event SetLastItemVersion(uint indexed itemId, uint version);
    event CategoryCreated(uint256 indexed categoryId, address indexed owner); // zero owner - no owner
    event CategoryUpdated(uint256 indexed categoryId, string title, string locale);
    event OwnedCategoryUpdated(uint256 indexed categoryId,
                               string title, string shortDescription,
                               string description,
                               string locale,
                               address indexed owner);
    event ChildParentVote(uint child,
                          uint parent,
                          int256 value,
                          int256 featureLevel,
                          bool primary); // Vote is primary if it's an owner's vote.
    event Pay(address indexed payer, address indexed payee, uint indexed itemId, uint256 value);
    event Donate(address indexed payer, address indexed payee, uint indexed itemId, uint256 value);

    address payable public founder;
    mapping (uint => address payable) public itemOwners;
    mapping (uint => mapping (uint => int256)) private childParentVotes;
    mapping (uint => uint256) public pricesETH;
    mapping (uint => uint256) public pricesAR;

    constructor(address payable _founder, uint256 _initialBalance) public {
        founder = _founder;
        name = "Zon Directory PST Token (ETH)";
        decimals = 18;
        symbol = "ZDPSTE";
        balances[_founder] = _initialBalance;
        totalSupply = _initialBalance;
    }


    function setOwner(address payable _founder) external {

        require(msg.sender == founder, "Access denied.");
        require(_founder != address(0), "Zero address."); // also prevents makeing owned categories unowned (spam)
        founder = _founder;
        emit SetOwner(_founder);
    }

    function setSalesOwnersShare(int128 _share) external {

        require(msg.sender == founder, "Access denied.");
        salesOwnersShare = _share;
        emit SetSalesOwnerShare(_share);
    }

    function setUpvotesOwnersShare(int128 _share) external {

        require(msg.sender == founder, "Access denied.");
        upvotesOwnersShare = _share;
        emit SetUpvotesOwnerShare(_share);
    }

    function setUploadOwnersShare(int128 _share) external {

        require(msg.sender == founder, "Access denied.");
        uploadOwnersShare = _share;
        emit SetUploadOwnerShare(_share);
    }

    function setBuyerAffiliateShare(int128 _share) external {

        require(msg.sender == founder, "Access denied.");
        buyerAffiliateShare = _share;
        emit SetBuyerAffiliateShare(_share);
    }

    function setSellerAffiliateShare(int128 _share) external {

        require(msg.sender == founder, "Access denied.");
        sellerAffiliateShare = _share;
        emit SetSellerAffiliateShare(_share);
    }

    function setItemOwner(uint _itemId, address payable _owner) external {

        require(itemOwners[_itemId] == msg.sender, "Access denied.");
        itemOwners[_itemId] = _owner;
        emit SetItemOwner(_itemId, _owner);
    }


    function setARWallet(string calldata _arWallet) external {

        emit SetARWallet(msg.sender, _arWallet);
    }

    function setNick(string calldata _nick) external {

        require(nickAddresses[_nick] == address(0), "Nick taken.");
        nickAddresses[addressNicks[msg.sender]] = address(0);
        nickAddresses[_nick] = msg.sender;
        addressNicks[msg.sender] = _nick;
        emit SetNick(msg.sender, _nick);
    }

    function setAuthorInfo(string calldata _link,
                           string calldata _shortDescription,
                           string calldata _description,
                           string calldata _locale) external {

        emit SetAuthorInfo(msg.sender, _link, _shortDescription, _description, _locale);
    }


    struct ItemInfo {
        string title;
        string shortDescription;
        string description;
        uint256 priceETH;
        uint256 priceAR;
        string locale;
        string license;
    }

    function createItem(ItemInfo calldata _info, address payable _affiliate) external returns (uint)
    {

        require(bytes(_info.title).length != 0, "Empty title.");
        setAffiliate(_affiliate);
        itemOwners[++maxId] = msg.sender;
        pricesETH[maxId] = _info.priceETH;
        pricesAR[maxId] = _info.priceAR;
        entries[maxId] = EntryKind.DOWNLOADS;
        emit ItemCreated(maxId);
        emit SetItemOwner(maxId, msg.sender);
        emit ItemUpdated(maxId, _info);
        return maxId;
    }

    function updateItem(uint _itemId, ItemInfo calldata _info) external
    {

        require(itemOwners[_itemId] == msg.sender, "Attempt to modify other's item.");
        require(entries[_itemId] == EntryKind.DOWNLOADS, "Item does not exist.");
        require(bytes(_info.title).length != 0, "Empty title.");
        pricesETH[_itemId] = _info.priceETH;
        pricesAR[_itemId] = _info.priceAR;
        emit ItemUpdated(_itemId, _info);
    }

    struct LinkInfo {
        string link;
        string title;
        string shortDescription;
        string description;
        string locale;
        uint256 linkKind;
    }

    function createLink(LinkInfo calldata _info, bool _owned, address payable _affiliate) external returns (uint)
    {

        require(bytes(_info.title).length != 0, "Empty title.");
        setAffiliate(_affiliate);
        address payable _owner = _owned ? msg.sender : address(0);
        itemOwners[++maxId] = _owner;
        entries[maxId] = EntryKind.LINK;
        emit ItemCreated(maxId);
        if (_owned) emit SetItemOwner(maxId, _owner);
        emit LinkUpdated(maxId, _info.link, _info.title, _info.shortDescription, _info.description, _info.locale, _info.linkKind);
        return maxId;
    }

    function updateLink(uint _linkId, LinkInfo calldata _info) external
    {

        require(itemOwners[_linkId] == msg.sender, "Attempt to modify other's link."); // only owned links
        require(bytes(_info.title).length != 0, "Empty title.");
        require(entries[_linkId] == EntryKind.LINK, "Link does not exist.");
        emit LinkUpdated(_linkId,
                         _info.link,
                         _info.title,
                         _info.shortDescription,
                         _info.description,
                         _info.locale,
                         _info.linkKind);
    }

    function updateItemCover(uint _itemId, uint _version, bytes calldata _cover, uint _width, uint _height) external {

        require(itemOwners[_itemId] == msg.sender, "Access denied."); // only owned entries
        EntryKind kind = entries[_itemId];
        require(kind != EntryKind.NONE, "Entry does not exist.");
        emit ItemCoverUpdated(_itemId, _version, _cover, _width, _height);
    }

    function uploadFile(uint _itemId, uint _version, string calldata _format, bytes calldata _hash) external {

        require(_hash.length == 32, "Wrong hash length.");
        require(itemOwners[_itemId] == msg.sender, "Attempt to modify other's item.");
        require(entries[_itemId] == EntryKind.DOWNLOADS, "Item does not exist.");
        emit ItemFilesUpdated(_itemId, _format, _version, _hash);
    }

    function setLastItemVersion(uint _itemId, uint _version) external {

        require(itemOwners[_itemId] == msg.sender, "Attempt to modify other's item.");
        require(entries[_itemId] == EntryKind.DOWNLOADS, "Item does not exist.");
        emit SetLastItemVersion(_itemId, _version);
    }

    function pay(uint _itemId, address payable _affiliate) external payable returns (bytes memory) {

        require(pricesETH[_itemId] <= msg.value, "Paid too little.");
        require(entries[_itemId] == EntryKind.DOWNLOADS, "Item does not exist.");
        setAffiliate(_affiliate);
        uint256 _shareholdersShare = uint256(salesOwnersShare.muli(int256(msg.value)));
        address payable _author = itemOwners[_itemId];
        payToShareholders(_shareholdersShare, _author);
        uint256 toAuthor = msg.value - _shareholdersShare;
        _author.transfer(toAuthor);
        emit Pay(msg.sender, itemOwners[_itemId], _itemId, toAuthor);
    }

    function donate(uint _itemId, address payable _affiliate) external payable returns (bytes memory) {

        require(entries[_itemId] == EntryKind.DOWNLOADS, "Item does not exist.");
        setAffiliate(_affiliate);
        uint256 _shareholdersShare = uint256(salesOwnersShare.muli(int256(msg.value)));
        address payable _author = itemOwners[_itemId];
        payToShareholders(_shareholdersShare, _author);
        uint256 toAuthor = msg.value - _shareholdersShare;
        _author.transfer(toAuthor);
        emit Donate(msg.sender, itemOwners[_itemId], _itemId, toAuthor);
    }


    function createCategory(string calldata _title, string calldata _locale, address payable _affiliate) external returns (uint) {

        require(bytes(_title).length != 0, "Empty title.");
        setAffiliate(_affiliate);
        ++maxId;
        uint _id = categoryTitles[_locale][_title];
        if(_id != 0)
            return _id;
        else
            categoryTitles[_locale][_title] = maxId;
        entries[maxId] = EntryKind.CATEGORY;
        emit CategoryCreated(maxId, address(0));
        emit CategoryUpdated(maxId, _title, _locale);
        return maxId;
    }

    struct OwnedCategoryInfo {
        string title;
        string shortDescription;
        string description;
        string locale;
    }

    function createOwnedCategory(OwnedCategoryInfo calldata _info, address payable _affiliate) external returns (uint) {

        require(bytes(_info.title).length != 0, "Empty title.");
        setAffiliate(_affiliate);
        ++maxId;
        entries[maxId] = EntryKind.CATEGORY;
        itemOwners[maxId] = msg.sender;
        emit CategoryCreated(maxId, msg.sender);
        emit SetItemOwner(maxId, msg.sender);
        emit OwnedCategoryUpdated(maxId, _info.title, _info.shortDescription, _info.description, _info.locale, msg.sender);
        return maxId;
    }

    function updateOwnedCategory(uint _categoryId, OwnedCategoryInfo calldata _info) external {

        require(itemOwners[_categoryId] == msg.sender, "Access denied.");
        require(entries[_categoryId] == EntryKind.CATEGORY, "Must be a category.");
        emit OwnedCategoryUpdated(_categoryId, _info.title, _info.shortDescription, _info.description, _info.locale, msg.sender);
    }


    function voteChildParent(uint _child, uint _parent, bool _yes, address payable _affiliate) external payable {

        require(entries[_child] != EntryKind.NONE, "Child does not exist.");
        require(entries[_parent] == EntryKind.CATEGORY, "Must be a category.");
        setAffiliate(_affiliate);
        int256 _value = _yes ? int256(msg.value) : -int256(msg.value);
        if(_value == 0) return; // We don't want to pollute the events with zero votes.
        int256 _newValue = childParentVotes[_child][_parent] + _value;
        childParentVotes[_child][_parent] = _newValue;
        address payable _owner = itemOwners[_child];
        if(_yes && _owner != address(0)) {
            uint256 _shareholdersShare = uint256(upvotesOwnersShare.muli(int256(msg.value)));
            payToShareholders(_shareholdersShare, _owner);
            _owner.transfer(msg.value - _shareholdersShare);
        } else
            payToShareholders(msg.value, address(0));
        emit ChildParentVote(_child, _parent, _newValue, 0, false);
    }

    function voteForOwnChild(uint _child, uint _parent) external payable {

        require(entries[_child] != EntryKind.NONE, "Child does not exist.");
        require(entries[_parent] == EntryKind.CATEGORY, "Must be a category.");
        address _owner = itemOwners[_child];
        require(_owner == msg.sender, "Must be owner.");
        if(msg.value == 0) return; // We don't want to pollute the events with zero votes.
        int256 _value = upvotesOwnersShare.inv().muli(int256(msg.value));
        int256 _newValue = childParentVotes[_child][_parent] + _value;
        childParentVotes[_child][_parent] = _newValue;
        payToShareholders(msg.value, address(0));
        emit ChildParentVote(_child, _parent, _newValue, 0, false);
    }

    function setMyChildParent(uint _child, uint _parent, int256 _value, int256 _featureLevel) external {

        require(entries[_child] != EntryKind.NONE, "Child does not exist.");
        require(entries[_parent] == EntryKind.CATEGORY, "Must be a category.");
        require(itemOwners[_parent] == msg.sender, "Access denied.");
        emit ChildParentVote(_child, _parent, _value, _featureLevel, true);
    }

    function getChildParentVotes(uint _child, uint _parent) external view returns (int256) {

        return childParentVotes[_child][_parent];
    }


    uint256 totalDividends = 0;
    uint256 totalDividendsPaid = 0; // actually paid sum
    mapping(address => uint256) lastTotalDivedends; // the value of totalDividends after the last payment to an address

    function _dividendsOwing(address _account) internal view returns(uint256) {

        uint256 _newDividends = totalDividends - lastTotalDivedends[_account];
        return (balances[_account] * _newDividends) / totalSupply; // rounding down
    }

    function dividendsOwing(address _account) external view returns(uint256) {

        return _dividendsOwing(_account);
    }

    function withdrawProfit() external {

        uint256 _owing = _dividendsOwing(msg.sender);


        if(_owing > 0) {
            msg.sender.transfer(_owing);
            totalDividendsPaid += _owing;
            lastTotalDivedends[msg.sender] = totalDividends;
        }
    }

    function payToShareholders(uint256 _amount, address _author) internal {

        address payable _affiliate = affiliates[msg.sender];
        uint256 _shareHoldersAmount = _amount;
        if(uint(_affiliate) > 1) {
            uint256 _buyerAffiliateAmount = uint256(buyerAffiliateShare.muli(int256(_amount)));
            _affiliate.transfer(_buyerAffiliateAmount);
            require(_shareHoldersAmount >= _buyerAffiliateAmount, "Attempt to pay negative amount.");
            _shareHoldersAmount -= _buyerAffiliateAmount;
        }
        if(uint(_author) > 1) {
            uint256 _sellerAffiliateAmount = uint256(sellerAffiliateShare.muli(int256(_amount)));
            payable(_author).transfer(_sellerAffiliateAmount);
            require(_shareHoldersAmount >= _sellerAffiliateAmount, "Attempt to pay negative amount.");
            _shareHoldersAmount -= _sellerAffiliateAmount;
        }
        totalDividends += _shareHoldersAmount;
    }


    mapping (address => address payable) affiliates;

    function setAffiliate(address payable _affiliate) internal {

        if(uint256(_affiliate) > 1)
            affiliates[_affiliate] = _affiliate;
    }
}

pragma solidity >=0.4.21 <0.7.0;

contract Migrations {

  address public owner;
  uint public last_completed_migration;

  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {

    if (msg.sender == owner) _;
  }

  function setCompleted(uint completed) public restricted {

    last_completed_migration = completed;
  }
}
