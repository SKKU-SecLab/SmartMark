
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
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
}pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

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
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}/*
MIT License

Copyright (c) 2018 requestnetwork
Copyright (c) 2018 Fragments, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity >=0.6.6;

library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {

        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}// BSD-4-Clause
pragma solidity >=0.6.6;

library ABDKMathQuad {

  bytes16 private constant POSITIVE_ZERO = 0x00000000000000000000000000000000;

  bytes16 private constant NEGATIVE_ZERO = 0x80000000000000000000000000000000;

  bytes16 private constant POSITIVE_INFINITY = 0x7FFF0000000000000000000000000000;

  bytes16 private constant NEGATIVE_INFINITY = 0xFFFF0000000000000000000000000000;

  bytes16 private constant NaN = 0x7FFF8000000000000000000000000000;

  function fromInt (int256 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      uint256 result = uint256 (x > 0 ? x : -x);

      uint256 msb = msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;
      if (x < 0) result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  function toInt (bytes16 x) internal pure returns (int256) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    require (exponent <= 16638); // Overflow
    if (exponent < 16383) return 0; // Underflow

    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16495) result >>= 16495 - exponent;
    else if (exponent > 16495) result <<= exponent - 16495;

    if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
      require (result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
      return -int256 (result); // We rely on overflow behavior here
    } else {
      require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int256 (result);
    }
  }

  function fromUInt (uint256 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      uint256 result = x;

      uint256 msb = msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16383 + msb << 112;

      return bytes16 (uint128 (result));
    }
  }

  function toUInt (bytes16 x) internal pure returns (uint256) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    if (exponent < 16383) return 0; // Underflow

    require (uint128 (x) < 0x80000000000000000000000000000000); // Negative

    require (exponent <= 16638); // Overflow
    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16495) result >>= 16495 - exponent;
    else if (exponent > 16495) result <<= exponent - 16495;

    return result;
  }

  function from128x128 (int256 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      uint256 result = uint256 (x > 0 ? x : -x);

      uint256 msb = msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16255 + msb << 112;
      if (x < 0) result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  function to128x128 (bytes16 x) internal pure returns (int256) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    require (exponent <= 16510); // Overflow
    if (exponent < 16255) return 0; // Underflow

    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16367) result >>= 16367 - exponent;
    else if (exponent > 16367) result <<= exponent - 16367;

    if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
      require (result <= 0x8000000000000000000000000000000000000000000000000000000000000000);
      return -int256 (result); // We rely on overflow behavior here
    } else {
      require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int256 (result);
    }
  }

  function from64x64 (int128 x) internal pure returns (bytes16) {
    if (x == 0) return bytes16 (0);
    else {
      uint256 result = uint128 (x > 0 ? x : -x);

      uint256 msb = msb (result);
      if (msb < 112) result <<= 112 - msb;
      else if (msb > 112) result >>= msb - 112;

      result = result & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 16319 + msb << 112;
      if (x < 0) result |= 0x80000000000000000000000000000000;

      return bytes16 (uint128 (result));
    }
  }

  function to64x64 (bytes16 x) internal pure returns (int128) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    require (exponent <= 16446); // Overflow
    if (exponent < 16319) return 0; // Underflow

    uint256 result = uint256 (uint128 (x)) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF |
      0x10000000000000000000000000000;

    if (exponent < 16431) result >>= 16431 - exponent;
    else if (exponent > 16431) result <<= exponent - 16431;

    if (uint128 (x) >= 0x80000000000000000000000000000000) { // Negative
      require (result <= 0x80000000000000000000000000000000);
      return -int128 (result); // We rely on overflow behavior here
    } else {
      require (result <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int128 (result);
    }
  }

  function fromOctuple (bytes32 x) internal pure returns (bytes16) {
    bool negative = x & 0x8000000000000000000000000000000000000000000000000000000000000000 > 0;

    uint256 exponent = uint256 (x) >> 236 & 0x7FFFF;
    uint256 significand = uint256 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (exponent == 0x7FFFF) {
      if (significand > 0) return NaN;
      else return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
    }

    if (exponent > 278526)
      return negative ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
    else if (exponent < 245649)
      return negative ? NEGATIVE_ZERO : POSITIVE_ZERO;
    else if (exponent < 245761) {
      significand = (significand | 0x100000000000000000000000000000000000000000000000000000000000) >> 245885 - exponent;
      exponent = 0;
    } else {
      significand >>= 124;
      exponent -= 245760;
    }

    uint128 result = uint128 (significand | exponent << 112);
    if (negative) result |= 0x80000000000000000000000000000000;

    return bytes16 (result);
  }

  function toOctuple (bytes16 x) internal pure returns (bytes32) {
    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;

    uint256 result = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (exponent == 0x7FFF) exponent = 0x7FFFF; // Infinity or NaN
    else if (exponent == 0) {
      if (result > 0) {
        uint256 msb = msb (result);
        result = result << 236 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        exponent = 245649 + msb;
      }
    } else {
      result <<= 124;
      exponent += 245760;
    }

    result |= exponent << 236;
    if (uint128 (x) >= 0x80000000000000000000000000000000)
      result |= 0x8000000000000000000000000000000000000000000000000000000000000000;

    return bytes32 (result);
  }

  function fromDouble (bytes8 x) internal pure returns (bytes16) {
    uint256 exponent = uint64 (x) >> 52 & 0x7FF;

    uint256 result = uint64 (x) & 0xFFFFFFFFFFFFF;

    if (exponent == 0x7FF) exponent = 0x7FFF; // Infinity or NaN
    else if (exponent == 0) {
      if (result > 0) {
        uint256 msb = msb (result);
        result = result << 112 - msb & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        exponent = 15309 + msb;
      }
    } else {
      result <<= 60;
      exponent += 15360;
    }

    result |= exponent << 112;
    if (x & 0x8000000000000000 > 0)
      result |= 0x80000000000000000000000000000000;

    return bytes16 (uint128 (result));
  }

  function toDouble (bytes16 x) internal pure returns (bytes8) {
    bool negative = uint128 (x) >= 0x80000000000000000000000000000000;

    uint256 exponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 significand = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (exponent == 0x7FFF) {
      if (significand > 0) return 0x7FF8000000000000; // NaN
      else return negative ?
          bytes8 (0xFFF0000000000000) : // -Infinity
          bytes8 (0x7FF0000000000000); // Infinity
    }

    if (exponent > 17406)
      return negative ?
          bytes8 (0xFFF0000000000000) : // -Infinity
          bytes8 (0x7FF0000000000000); // Infinity
    else if (exponent < 15309)
      return negative ?
          bytes8 (0x8000000000000000) : // -0
          bytes8 (0x0000000000000000); // 0
    else if (exponent < 15361) {
      significand = (significand | 0x10000000000000000000000000000) >> 15421 - exponent;
      exponent = 0;
    } else {
      significand >>= 60;
      exponent -= 15360;
    }

    uint64 result = uint64 (significand | exponent << 52);
    if (negative) result |= 0x8000000000000000;

    return bytes8 (result);
  }

  function isNaN (bytes16 x) internal pure returns (bool) {
    return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF >
      0x7FFF0000000000000000000000000000;
  }

  function isInfinity (bytes16 x) internal pure returns (bool) {
    return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF ==
      0x7FFF0000000000000000000000000000;
  }

  function sign (bytes16 x) internal pure returns (int8) {
    uint128 absoluteX = uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    require (absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

    if (absoluteX == 0) return 0;
    else if (uint128 (x) >= 0x80000000000000000000000000000000) return -1;
    else return 1;
  }

  function cmp (bytes16 x, bytes16 y) internal pure returns (int8) {
    uint128 absoluteX = uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    require (absoluteX <= 0x7FFF0000000000000000000000000000); // Not NaN

    uint128 absoluteY = uint128 (y) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    require (absoluteY <= 0x7FFF0000000000000000000000000000); // Not NaN

    require (x != y || absoluteX < 0x7FFF0000000000000000000000000000);

    if (x == y) return 0;
    else {
      bool negativeX = uint128 (x) >= 0x80000000000000000000000000000000;
      bool negativeY = uint128 (y) >= 0x80000000000000000000000000000000;

      if (negativeX) {
        if (negativeY) return absoluteX > absoluteY ? -1 : int8 (1);
        else return -1; 
      } else {
        if (negativeY) return 1;
        else return absoluteX > absoluteY ? int8 (1) : -1;
      }
    }
  }

  function eq (bytes16 x, bytes16 y) internal pure returns (bool) {
    if (x == y) {
      return uint128 (x) & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF <
        0x7FFF0000000000000000000000000000;
    } else return false;
  }

  function add (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

    if (xExponent == 0x7FFF) {
      if (yExponent == 0x7FFF) { 
        if (x == y) return x;
        else return NaN;
      } else return x; 
    } else if (yExponent == 0x7FFF) return y;
    else {
      bool xSign = uint128 (x) >= 0x80000000000000000000000000000000;
      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xExponent == 0) xExponent = 1;
      else xSignifier |= 0x10000000000000000000000000000;

      bool ySign = uint128 (y) >= 0x80000000000000000000000000000000;
      uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (yExponent == 0) yExponent = 1;
      else ySignifier |= 0x10000000000000000000000000000;

      if (xSignifier == 0) return y == NEGATIVE_ZERO ? POSITIVE_ZERO : y;
      else if (ySignifier == 0) return x == NEGATIVE_ZERO ? POSITIVE_ZERO : x;
      else {
        int256 delta = int256 (xExponent) - int256 (yExponent);
  
        if (xSign == ySign) {
          if (delta > 112) return x;
          else if (delta > 0) ySignifier >>= uint256 (delta);
          else if (delta < -112) return y;
          else if (delta < 0) {
            xSignifier >>= uint256 (-delta);
            xExponent = yExponent;
          }
  
          xSignifier += ySignifier;
  
          if (xSignifier >= 0x20000000000000000000000000000) {
            xSignifier >>= 1;
            xExponent += 1;
          }
  
          if (xExponent == 0x7FFF)
            return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
          else {
            if (xSignifier < 0x10000000000000000000000000000) xExponent = 0;
            else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  
            return bytes16 (uint128 (
                (xSign ? 0x80000000000000000000000000000000 : 0) |
                (xExponent << 112) |
                xSignifier)); 
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
          else if (delta > 1) ySignifier = (ySignifier - 1 >> uint256 (delta - 1)) + 1;
          else if (delta < -112) xSignifier = 1;
          else if (delta < -1) xSignifier = (xSignifier - 1 >> uint256 (-delta - 1)) + 1;

          if (xSignifier >= ySignifier) xSignifier -= ySignifier;
          else {
            xSignifier = ySignifier - xSignifier;
            xSign = ySign;
          }

          if (xSignifier == 0)
            return POSITIVE_ZERO;

          uint256 msb = msb (xSignifier);

          if (msb == 113) {
            xSignifier = xSignifier >> 1 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            xExponent += 1;
          } else if (msb < 112) {
            uint256 shift = 112 - msb;
            if (xExponent > shift) {
              xSignifier = xSignifier << shift & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
              xExponent -= shift;
            } else {
              xSignifier <<= xExponent - 1;
              xExponent = 0;
            }
          } else xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

          if (xExponent == 0x7FFF)
            return xSign ? NEGATIVE_INFINITY : POSITIVE_INFINITY;
          else return bytes16 (uint128 (
              (xSign ? 0x80000000000000000000000000000000 : 0) |
              (xExponent << 112) |
              xSignifier));
        }
      }
    }
  }

  function sub (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    return add (x, y ^ 0x80000000000000000000000000000000);
  }

  function mul (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

    if (xExponent == 0x7FFF) {
      if (yExponent == 0x7FFF) {
        if (x == y) return x ^ y & 0x80000000000000000000000000000000;
        else if (x ^ y == 0x80000000000000000000000000000000) return x | y;
        else return NaN;
      } else {
        if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
        else return x ^ y & 0x80000000000000000000000000000000;
      }
    } else if (yExponent == 0x7FFF) {
        if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
        else return y ^ x & 0x80000000000000000000000000000000;
    } else {
      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xExponent == 0) xExponent = 1;
      else xSignifier |= 0x10000000000000000000000000000;

      uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (yExponent == 0) yExponent = 1;
      else ySignifier |= 0x10000000000000000000000000000;

      xSignifier *= ySignifier;
      if (xSignifier == 0)
        return (x ^ y) & 0x80000000000000000000000000000000 > 0 ?
            NEGATIVE_ZERO : POSITIVE_ZERO;

      xExponent += yExponent;

      uint256 msb =
        xSignifier >= 0x200000000000000000000000000000000000000000000000000000000 ? 225 :
        xSignifier >= 0x100000000000000000000000000000000000000000000000000000000 ? 224 :
        msb (xSignifier);

      if (xExponent + msb < 16496) { // Underflow
        xExponent = 0;
        xSignifier = 0;
      } else if (xExponent + msb < 16608) { // Subnormal
        if (xExponent < 16496)
          xSignifier >>= 16496 - xExponent;
        else if (xExponent > 16496)
          xSignifier <<= xExponent - 16496;
        xExponent = 0;
      } else if (xExponent + msb > 49373) {
        xExponent = 0x7FFF;
        xSignifier = 0;
      } else {
        if (msb > 112)
          xSignifier >>= msb - 112;
        else if (msb < 112)
          xSignifier <<= 112 - msb;

        xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        xExponent = xExponent + msb - 16607;
      }

      return bytes16 (uint128 (uint128 ((x ^ y) & 0x80000000000000000000000000000000) |
          xExponent << 112 | xSignifier));
    }
  }

  function div (bytes16 x, bytes16 y) internal pure returns (bytes16) {
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 yExponent = uint128 (y) >> 112 & 0x7FFF;

    if (xExponent == 0x7FFF) {
      if (yExponent == 0x7FFF) return NaN;
      else return x ^ y & 0x80000000000000000000000000000000;
    } else if (yExponent == 0x7FFF) {
      if (y & 0x0000FFFFFFFFFFFFFFFFFFFFFFFFFFFF != 0) return NaN;
      else return POSITIVE_ZERO | (x ^ y) & 0x80000000000000000000000000000000;
    } else if (y & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) {
      if (x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0) return NaN;
      else return POSITIVE_INFINITY | (x ^ y) & 0x80000000000000000000000000000000;
    } else {
      uint256 ySignifier = uint128 (y) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (yExponent == 0) yExponent = 1;
      else ySignifier |= 0x10000000000000000000000000000;

      uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xExponent == 0) {
        if (xSignifier != 0) {
          uint shift = 226 - msb (xSignifier);

          xSignifier <<= shift;

          xExponent = 1;
          yExponent += shift - 114;
        }
      }
      else {
        xSignifier = (xSignifier | 0x10000000000000000000000000000) << 114;
      }

      xSignifier = xSignifier / ySignifier;
      if (xSignifier == 0)
        return (x ^ y) & 0x80000000000000000000000000000000 > 0 ?
            NEGATIVE_ZERO : POSITIVE_ZERO;

      assert (xSignifier >= 0x1000000000000000000000000000);

      uint256 msb =
        xSignifier >= 0x80000000000000000000000000000 ? msb (xSignifier) :
        xSignifier >= 0x40000000000000000000000000000 ? 114 :
        xSignifier >= 0x20000000000000000000000000000 ? 113 : 112;

      if (xExponent + msb > yExponent + 16497) { // Overflow
        xExponent = 0x7FFF;
        xSignifier = 0;
      } else if (xExponent + msb + 16380  < yExponent) { // Underflow
        xExponent = 0;
        xSignifier = 0;
      } else if (xExponent + msb + 16268  < yExponent) { // Subnormal
        if (xExponent + 16380 > yExponent)
          xSignifier <<= xExponent + 16380 - yExponent;
        else if (xExponent + 16380 < yExponent)
          xSignifier >>= yExponent - xExponent - 16380;

        xExponent = 0;
      } else { // Normal
        if (msb > 112)
          xSignifier >>= msb - 112;

        xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

        xExponent = xExponent + msb + 16269 - yExponent;
      }

      return bytes16 (uint128 (uint128 ((x ^ y) & 0x80000000000000000000000000000000) |
          xExponent << 112 | xSignifier));
    }
  }

  function neg (bytes16 x) internal pure returns (bytes16) {
    return x ^ 0x80000000000000000000000000000000;
  }

  function abs (bytes16 x) internal pure returns (bytes16) {
    return x & 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  }

  function sqrt (bytes16 x) internal pure returns (bytes16) {
    if (uint128 (x) >  0x80000000000000000000000000000000) return NaN;
    else {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      if (xExponent == 0x7FFF) return x;
      else {
        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (xExponent == 0) xExponent = 1;
        else xSignifier |= 0x10000000000000000000000000000;

        if (xSignifier == 0) return POSITIVE_ZERO;

        bool oddExponent = xExponent & 0x1 == 0;
        xExponent = xExponent + 16383 >> 1;

        if (oddExponent) {
          if (xSignifier >= 0x10000000000000000000000000000)
            xSignifier <<= 113;
          else {
            uint256 msb = msb (xSignifier);
            uint256 shift = (226 - msb) & 0xFE;
            xSignifier <<= shift;
            xExponent -= shift - 112 >> 1;
          }
        } else {
          if (xSignifier >= 0x10000000000000000000000000000)
            xSignifier <<= 112;
          else {
            uint256 msb = msb (xSignifier);
            uint256 shift = (225 - msb) & 0xFE;
            xSignifier <<= shift;
            xExponent -= shift - 112 >> 1;
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

        return bytes16 (uint128 (xExponent << 112 | r & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
      }
    }
  }

  function log_2 (bytes16 x) internal pure returns (bytes16) {
    if (uint128 (x) > 0x80000000000000000000000000000000) return NaN;
    else if (x == 0x3FFF0000000000000000000000000000) return POSITIVE_ZERO; 
    else {
      uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
      if (xExponent == 0x7FFF) return x;
      else {
        uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
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
            uint256 msb = msb (xSignifier);
            resultSignifier = 16493 - msb;
            xSignifier <<= 127 - msb;
          }
        }

        if (xSignifier == 0x80000000000000000000000000000000) {
          if (resultNegative) resultSignifier += 1;
          uint256 shift = 112 - msb (resultSignifier);
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

        return bytes16 (uint128 ((resultNegative ? 0x80000000000000000000000000000000 : 0) |
            resultExponent << 112 | resultSignifier & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
      }
    }
  }

  function ln (bytes16 x) internal pure returns (bytes16) {
    return mul (log_2 (x), 0x3FFE62E42FEFA39EF35793C7673007E5);
  }

  function pow_2 (bytes16 x) internal pure returns (bytes16) {
    bool xNegative = uint128 (x) > 0x80000000000000000000000000000000;
    uint256 xExponent = uint128 (x) >> 112 & 0x7FFF;
    uint256 xSignifier = uint128 (x) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    if (xExponent == 0x7FFF && xSignifier != 0) return NaN;
    else if (xExponent > 16397)
      return xNegative ? POSITIVE_ZERO : POSITIVE_INFINITY;
    else if (xExponent < 16255)
      return 0x3FFF0000000000000000000000000000;
    else {
      if (xExponent == 0) xExponent = 1;
      else xSignifier |= 0x10000000000000000000000000000;

      if (xExponent > 16367)
        xSignifier <<= xExponent - 16367;
      else if (xExponent < 16367)
        xSignifier >>= 16367 - xExponent;

      if (xNegative && xSignifier > 0x406E00000000000000000000000000000000)
        return POSITIVE_ZERO;

      if (!xNegative && xSignifier > 0x3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        return POSITIVE_INFINITY;

      uint256 resultExponent = xSignifier >> 128;
      xSignifier &= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
      if (xNegative && xSignifier != 0) {
        xSignifier = ~xSignifier;
        resultExponent += 1;
      }

      uint256 resultSignifier = 0x80000000000000000000000000000000;
      if (xSignifier & 0x80000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
      if (xSignifier & 0x40000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
      if (xSignifier & 0x20000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
      if (xSignifier & 0x10000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
      if (xSignifier & 0x8000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
      if (xSignifier & 0x4000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
      if (xSignifier & 0x2000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
      if (xSignifier & 0x1000000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
      if (xSignifier & 0x800000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
      if (xSignifier & 0x400000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
      if (xSignifier & 0x200000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
      if (xSignifier & 0x100000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
      if (xSignifier & 0x80000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
      if (xSignifier & 0x40000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
      if (xSignifier & 0x20000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000162E525EE054754457D5995292026 >> 128;
      if (xSignifier & 0x10000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
      if (xSignifier & 0x8000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
      if (xSignifier & 0x4000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
      if (xSignifier & 0x2000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000162E43F4F831060E02D839A9D16D >> 128;
      if (xSignifier & 0x1000000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
      if (xSignifier & 0x800000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
      if (xSignifier & 0x400000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
      if (xSignifier & 0x200000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
      if (xSignifier & 0x100000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
      if (xSignifier & 0x80000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
      if (xSignifier & 0x40000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
      if (xSignifier & 0x20000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
      if (xSignifier & 0x10000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
      if (xSignifier & 0x8000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
      if (xSignifier & 0x4000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
      if (xSignifier & 0x2000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
      if (xSignifier & 0x1000000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
      if (xSignifier & 0x800000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
      if (xSignifier & 0x400000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
      if (xSignifier & 0x200000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000162E42FEFB2FED257559BDAA >> 128;
      if (xSignifier & 0x100000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
      if (xSignifier & 0x80000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
      if (xSignifier & 0x40000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
      if (xSignifier & 0x20000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
      if (xSignifier & 0x10000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000B17217F7D20CF927C8E94C >> 128;
      if (xSignifier & 0x8000000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
      if (xSignifier & 0x4000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000002C5C85FDF477B662B26945 >> 128;
      if (xSignifier & 0x2000000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000162E42FEFA3AE53369388C >> 128;
      if (xSignifier & 0x1000000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000B17217F7D1D351A389D40 >> 128;
      if (xSignifier & 0x800000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
      if (xSignifier & 0x400000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
      if (xSignifier & 0x200000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000162E42FEFA39FE95583C2 >> 128;
      if (xSignifier & 0x100000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
      if (xSignifier & 0x80000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
      if (xSignifier & 0x40000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000002C5C85FDF473E242EA38 >> 128;
      if (xSignifier & 0x20000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000162E42FEFA39F02B772C >> 128;
      if (xSignifier & 0x10000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
      if (xSignifier & 0x8000000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
      if (xSignifier & 0x4000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000002C5C85FDF473DEA871F >> 128;
      if (xSignifier & 0x2000000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000162E42FEFA39EF44D91 >> 128;
      if (xSignifier & 0x1000000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000B17217F7D1CF79E949 >> 128;
      if (xSignifier & 0x800000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
      if (xSignifier & 0x400000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
      if (xSignifier & 0x200000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000162E42FEFA39EF366F >> 128;
      if (xSignifier & 0x100000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000B17217F7D1CF79AFA >> 128;
      if (xSignifier & 0x80000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
      if (xSignifier & 0x40000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
      if (xSignifier & 0x20000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000162E42FEFA39EF358 >> 128;
      if (xSignifier & 0x10000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000B17217F7D1CF79AB >> 128;
      if (xSignifier & 0x8000000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000058B90BFBE8E7BCD5 >> 128;
      if (xSignifier & 0x4000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000002C5C85FDF473DE6A >> 128;
      if (xSignifier & 0x2000000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000162E42FEFA39EF34 >> 128;
      if (xSignifier & 0x1000000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000B17217F7D1CF799 >> 128;
      if (xSignifier & 0x800000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000058B90BFBE8E7BCC >> 128;
      if (xSignifier & 0x400000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000002C5C85FDF473DE5 >> 128;
      if (xSignifier & 0x200000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000162E42FEFA39EF2 >> 128;
      if (xSignifier & 0x100000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000B17217F7D1CF78 >> 128;
      if (xSignifier & 0x80000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000058B90BFBE8E7BB >> 128;
      if (xSignifier & 0x40000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000002C5C85FDF473DD >> 128;
      if (xSignifier & 0x20000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000162E42FEFA39EE >> 128;
      if (xSignifier & 0x10000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000B17217F7D1CF6 >> 128;
      if (xSignifier & 0x8000000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000058B90BFBE8E7A >> 128;
      if (xSignifier & 0x4000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000002C5C85FDF473C >> 128;
      if (xSignifier & 0x2000000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000162E42FEFA39D >> 128;
      if (xSignifier & 0x1000000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000B17217F7D1CE >> 128;
      if (xSignifier & 0x800000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000058B90BFBE8E6 >> 128;
      if (xSignifier & 0x400000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000002C5C85FDF472 >> 128;
      if (xSignifier & 0x200000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000162E42FEFA38 >> 128;
      if (xSignifier & 0x100000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000B17217F7D1B >> 128;
      if (xSignifier & 0x80000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000058B90BFBE8D >> 128;
      if (xSignifier & 0x40000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000002C5C85FDF46 >> 128;
      if (xSignifier & 0x20000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000162E42FEFA2 >> 128;
      if (xSignifier & 0x10000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000B17217F7D0 >> 128;
      if (xSignifier & 0x8000000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000058B90BFBE7 >> 128;
      if (xSignifier & 0x4000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000002C5C85FDF3 >> 128;
      if (xSignifier & 0x2000000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000162E42FEF9 >> 128;
      if (xSignifier & 0x1000000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000B17217F7C >> 128;
      if (xSignifier & 0x800000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000058B90BFBD >> 128;
      if (xSignifier & 0x400000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000002C5C85FDE >> 128;
      if (xSignifier & 0x200000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000162E42FEE >> 128;
      if (xSignifier & 0x100000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000B17217F6 >> 128;
      if (xSignifier & 0x80000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000058B90BFA >> 128;
      if (xSignifier & 0x40000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000002C5C85FC >> 128;
      if (xSignifier & 0x20000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000162E42FD >> 128;
      if (xSignifier & 0x10000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000B17217E >> 128;
      if (xSignifier & 0x8000000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000058B90BE >> 128;
      if (xSignifier & 0x4000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000002C5C85E >> 128;
      if (xSignifier & 0x2000000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000162E42E >> 128;
      if (xSignifier & 0x1000000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000B17216 >> 128;
      if (xSignifier & 0x800000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000058B90A >> 128;
      if (xSignifier & 0x400000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000002C5C84 >> 128;
      if (xSignifier & 0x200000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000162E41 >> 128;
      if (xSignifier & 0x100000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000B1720 >> 128;
      if (xSignifier & 0x80000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000058B8F >> 128;
      if (xSignifier & 0x40000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000002C5C7 >> 128;
      if (xSignifier & 0x20000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000162E3 >> 128;
      if (xSignifier & 0x10000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000B171 >> 128;
      if (xSignifier & 0x8000 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000058B8 >> 128;
      if (xSignifier & 0x4000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000002C5B >> 128;
      if (xSignifier & 0x2000 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000162D >> 128;
      if (xSignifier & 0x1000 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000B16 >> 128;
      if (xSignifier & 0x800 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000058A >> 128;
      if (xSignifier & 0x400 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000002C4 >> 128;
      if (xSignifier & 0x200 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000161 >> 128;
      if (xSignifier & 0x100 > 0) resultSignifier = resultSignifier * 0x1000000000000000000000000000000B0 >> 128;
      if (xSignifier & 0x80 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000057 >> 128;
      if (xSignifier & 0x40 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000002B >> 128;
      if (xSignifier & 0x20 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000015 >> 128;
      if (xSignifier & 0x10 > 0) resultSignifier = resultSignifier * 0x10000000000000000000000000000000A >> 128;
      if (xSignifier & 0x8 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000004 >> 128;
      if (xSignifier & 0x4 > 0) resultSignifier = resultSignifier * 0x100000000000000000000000000000001 >> 128;

      if (!xNegative) {
        resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        resultExponent += 0x3FFF;
      } else if (resultExponent <= 0x3FFE) {
        resultSignifier = resultSignifier >> 15 & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        resultExponent = 0x3FFF - resultExponent;
      } else {
        resultSignifier = resultSignifier >> resultExponent - 16367;
        resultExponent = 0;
      }

      return bytes16 (uint128 (resultExponent << 112 | resultSignifier));
    }
  }

  function exp (bytes16 x) internal pure returns (bytes16) {
    return pow_2 (mul (x, 0x3FFF71547652B82FE1777D0FFDA0D23A));
  }

  function msb (uint256 x) private pure returns (uint256) {
    require (x > 0);

    uint256 result = 0;

    if (x >= 0x100000000000000000000000000000000) { x >>= 128; result += 128; }
    if (x >= 0x10000000000000000) { x >>= 64; result += 64; }
    if (x >= 0x100000000) { x >>= 32; result += 32; }
    if (x >= 0x10000) { x >>= 16; result += 16; }
    if (x >= 0x100) { x >>= 8; result += 8; }
    if (x >= 0x10) { x >>= 4; result += 4; }
    if (x >= 0x4) { x >>= 2; result += 2; }
    if (x >= 0x2) result += 1; // No need to shift x anymore

    return result;
  }
}// MIT
pragma solidity >=0.6.6;


contract Curve {

    bytes16 private MINUS_ONE = 0xbfff0000000000000000000000000000;
    bytes16 private TENE18 = 0x403abc16d674ec800000000000000000;
    bytes16 private ONE = 0x3fff0000000000000000000000000000;

    function getCurveValue(
        uint256 priceDelta_,
        bytes16 mean_,
        bytes16 oneDivDeviationSqrtTwoPi_,
        bytes16 twoDeviationSquare_
    ) public view returns (bytes16) {

        bytes16 priceDelta =
            ABDKMathQuad.div(ABDKMathQuad.fromUInt(priceDelta_), TENE18);

        bytes16 res1 = ABDKMathQuad.sub(ABDKMathQuad.ln(priceDelta), mean_);

        bytes16 res2 =
            ABDKMathQuad.mul(
                MINUS_ONE,
                ABDKMathQuad.div(
                    ABDKMathQuad.mul(res1, res1),
                    twoDeviationSquare_
                )
            );

        return
            ABDKMathQuad.mul(
                ABDKMathQuad.mul(
                    ABDKMathQuad.div(ONE, priceDelta),
                    oneDivDeviationSqrtTwoPi_
                ),
                ABDKMathQuad.exp(res2)
            );
    }

    function uint256ToBytes16(uint256 number_, uint256 scale_)
        public
        pure
        returns (bytes16)
    {

        bytes16 number = ABDKMathQuad.fromUInt(number_);
        bytes16 scale = ABDKMathQuad.fromUInt(scale_);

        return ABDKMathQuad.div(number, scale);
    }

    function bytes16ToUnit256(bytes16 number_, uint256 scale_)
        public
        pure
        returns (uint256)
    {

        bytes16 scale = ABDKMathQuad.fromUInt(scale_);

        return ABDKMathQuad.toUInt(ABDKMathQuad.mul(number_, scale));
    }
}// MIT
pragma solidity >=0.6.6;


interface IDebasePolicy {

    function upperDeviationThreshold() external view returns (uint256);


    function lowerDeviationThreshold() external view returns (uint256);


    function priceTargetRate() external view returns (uint256);

}

interface IOracle {

    function getData() external returns (uint256, bool);


    function updateData() external;

}

contract BurnPool is Ownable, Curve, Initializable {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using Address for address;

    event LogStartNewDistributionCycle(
        uint256 exchangeRate_,
        uint256 poolShareAdded_,
        uint256 rewardRate_,
        uint256 periodFinish_,
        bytes16 curveValue_
    );

    event LogNeutralRebase(bool rewardDistributionDisabled_);
    event LogCouponsBought(
        address buyer_,
        uint256 amount_,
        uint256 couponIssued_
    );
    event LogSetOracle(IOracle oracle_);
    event LogSetRewardBlockPeriod(uint256 rewardBlockPeriod_);
    event LogSetMultiSigRewardShare(uint256 multiSigRewardShare_);
    event LogSetInitialRewardShare(uint256 initialRewardShare_);
    event LogSetMultiSigAddress(address multiSigAddress_);
    event LogSetOracleBlockPeriod(uint256 oracleBlockPeriod_);
    event LogSetEpochs(uint256 epochs_);
    event LogSetCurveShifter(uint256 curveShifter_);
    event LogSetMeanAndDeviationWithFormulaConstants(
        bytes16 mean_,
        bytes16 deviation_,
        bytes16 peakScaler_,
        bytes16 oneDivDeviationSqrtTwoPi_,
        bytes16 twoDeviationSquare_
    );
    event LogEmergencyWithdrawa(uint256 withdrawAmount_);
    event LogRewardsAccrued(
        uint256 index,
        uint256 exchangeRate_,
        uint256 rewardsAccrued_,
        uint256 expansionPercentageScaled_,
        bytes16 value_
    );
    event LogRewardClaimed(
        address user_,
        uint256 cycleIndex_,
        uint256 rewardClaimed_
    );
    event LogNewCouponCycle(
        uint256 index_,
        uint256 rewardAmount_,
        uint256 debasePerEpoch_,
        uint256 rewardBlockPeriod_,
        uint256 oracleBlockPeriod_,
        uint256 oracleLastPrice_,
        uint256 oracleNextUpdate_,
        uint256 epochsToReward_
    );

    event LogSetMinimumRewardAccruedCap(uint256 minimumRewardAccruedCap_);
    event LogSetMaximumRewardAccruedCap(uint256 maximumRewardAccruedCap_);

    event LogSetEnableMinimumRewardAccruedCap(
        bool enableMinimumRewardAccruedCap_
    );
    event LogSetEnableMaximumRewardAccruedCap(
        bool enableMaximumRewardAccruedCap_
    );

    event LogOraclePriceAndPeriod(uint256 price_, uint256 period_);
    uint256 internal constant MAX_SUPPLY = ~uint128(0); // (2^128) - 1

    IDebasePolicy public policy;
    IERC20 public debase;
    IOracle public oracle;
    address public multiSigAddress;

    address public burnPool1;
    address public burnPool2;

    bytes16 public mean;
    bytes16 public deviation;
    bytes16 public peakScaler = 0x3fff565013f27f16fc74748b3f33c2db;
    bytes16 public oneDivDeviationSqrtTwoPi;
    bytes16 public twoDeviationSquare;

    uint256 public epochs;
    uint256 public totalRewardsDistributed;

    uint256 public oracleBlockPeriod;

    uint256 public rewardsAccrued;
    uint256 public curveShifter;
    uint256 public rewardBlockPeriod = 6400;

    uint256 public initialRewardShare;
    bool public enableMaximumRewardAccruedCap = true;
    bool public enableMinimumRewardAccruedCap = true;
    uint256 public minimumRewardAccruedCap = 50000000000000000;
    uint256 public maximumRewardAccruedCap = 100000000000000000;
    uint256 public multiSigRewardShare;
    uint256 public multiSigRewardToClaimShare;
    bool public positiveToNeutralRebaseRewardsDisabled;

    enum Rebase {POSITIVE, NEUTRAL, NEGATIVE, NONE}
    Rebase public lastRebase;

    struct RewardCycle {
        uint256 rewardShare;
        uint256 debasePerEpoch;
        uint256 rewardBlockPeriod;
        uint256 oracleBlockPeriod;
        uint256 oracleLastPrice;
        uint256 oracleNextUpdate;
        uint256 epochsToReward;
        uint256 epochsRewarded;
        uint256 couponsIssued;
        uint256 rewardRate;
        uint256 periodFinish;
        uint256 lastUpdateBlock;
        uint256 rewardPerTokenStored;
        uint256 rewardDistributed;
        mapping(address => uint256) userCouponBalances;
        mapping(address => uint256) userRewardPerTokenPaid;
        mapping(address => uint256) rewards;
    }

    RewardCycle[] public rewardCycles;
    uint256 public rewardCyclesLength;

    modifier updateReward(address account, uint256 index) {

        require(rewardCyclesLength != 0, "Cycle array is empty");
        require(
            index <= rewardCyclesLength.sub(1),
            "Index should not me more than items in the cycle array"
        );

        RewardCycle storage instance = rewardCycles[index];

        instance.rewardPerTokenStored = rewardPerToken(index);
        instance.lastUpdateBlock = lastRewardApplicable(index);
        if (account != address(0)) {
            instance.rewards[account] = earned(index, account);
            instance.userRewardPerTokenPaid[account] = instance
                .rewardPerTokenStored;
        }
        _;
    }

    function setOracleBlockPeriod(uint256 oracleBlockPeriod_)
        external
        onlyOwner
    {

        oracleBlockPeriod = oracleBlockPeriod_;
        emit LogSetOracleBlockPeriod(oracleBlockPeriod);
    }

    function setCurveShifter(uint256 curveShifter_) external onlyOwner {

        curveShifter = curveShifter_;
        emit LogSetCurveShifter(curveShifter);
    }

    function setEpochs(uint256 epochs_) external onlyOwner {

        epochs = epochs_;
        emit LogSetEpochs(epochs);
    }

    function setOracle(IOracle oracle_) external onlyOwner {

        oracle = oracle_;
        emit LogSetOracle(oracle);
    }

    function setInitialRewardShare(uint256 initialRewardShare_)
        external
        onlyOwner
    {

        initialRewardShare = initialRewardShare_;
        emit LogSetInitialRewardShare(initialRewardShare);
    }

    function setMinimumRewardAccruedCap(uint256 minimumRewardAccruedCap_)
        external
        onlyOwner
    {

        minimumRewardAccruedCap = minimumRewardAccruedCap_;
        emit LogSetMinimumRewardAccruedCap(minimumRewardAccruedCap);
    }

    function setMaximumRewardAccruedCap(uint256 maximumRewardAccruedCap_)
        external
        onlyOwner
    {

        maximumRewardAccruedCap = maximumRewardAccruedCap_;
        emit LogSetMaximumRewardAccruedCap(maximumRewardAccruedCap_);
    }

    function setEnableMinimumRewardAccruedCap(
        bool enableMinimumRewardAccruedCap_
    ) external onlyOwner {

        enableMinimumRewardAccruedCap = enableMinimumRewardAccruedCap;
        emit LogSetEnableMinimumRewardAccruedCap(enableMinimumRewardAccruedCap);
    }

    function setEnableMaximumRewardAccruedCap(
        bool enableMaximumRewardAccruedCap_
    ) external onlyOwner {

        enableMaximumRewardAccruedCap = enableMaximumRewardAccruedCap_;
        emit LogSetEnableMaximumRewardAccruedCap(enableMaximumRewardAccruedCap);
    }

    function setMultiSigRewardShare(uint256 multiSigRewardShare_)
        external
        onlyOwner
    {

        multiSigRewardShare = multiSigRewardShare_;
        emit LogSetMultiSigRewardShare(multiSigRewardShare);
    }

    function setMultiSigAddress(address multiSigAddress_) external onlyOwner {

        multiSigAddress = multiSigAddress_;
        emit LogSetMultiSigAddress(multiSigAddress);
    }

    function setRewardBlockPeriod(uint256 rewardBlockPeriod_)
        external
        onlyOwner
    {

        rewardBlockPeriod = rewardBlockPeriod_;
        emit LogSetRewardBlockPeriod(rewardBlockPeriod);
    }

    function setMeanAndDeviationWithFormulaConstants(
        bytes16 mean_,
        bytes16 deviation_,
        bytes16 peakScaler_,
        bytes16 oneDivDeviationSqrtTwoPi_,
        bytes16 twoDeviationSquare_
    ) external onlyOwner {

        mean = mean_;
        deviation = deviation_;
        peakScaler = peakScaler_;
        oneDivDeviationSqrtTwoPi = oneDivDeviationSqrtTwoPi_;
        twoDeviationSquare = twoDeviationSquare_;

        emit LogSetMeanAndDeviationWithFormulaConstants(
            mean,
            deviation,
            peakScaler,
            oneDivDeviationSqrtTwoPi,
            twoDeviationSquare
        );
    }

    function getUserCouponBalance(uint256 index)
        external
        view
        returns (uint256)
    {

        require(rewardCyclesLength != 0, "Cycle array is empty");
        require(
            index <= rewardCyclesLength.sub(1),
            "Index should not me more than items in the cycle array"
        );

        RewardCycle storage instance = rewardCycles[rewardCyclesLength.sub(1)];
        return instance.userCouponBalances[msg.sender];
    }

    function initialize(
        address debase_,
        IOracle oracle_,
        IDebasePolicy policy_,
        address burnPool1_,
        address burnPool2_,
        uint256 epochs_,
        uint256 oracleBlockPeriod_,
        uint256 curveShifter_,
        uint256 initialRewardShare_,
        address multiSigAddress_,
        uint256 multiSigRewardShare_,
        bytes16 mean_,
        bytes16 deviation_,
        bytes16 oneDivDeviationSqrtTwoPi_,
        bytes16 twoDeviationSquare_
    ) external initializer onlyOwner {

        debase = IERC20(debase_);
        burnPool1 = burnPool1_;
        burnPool2 = burnPool2_;
        policy = policy_;
        oracle = oracle_;

        epochs = epochs_;
        oracleBlockPeriod = oracleBlockPeriod_;
        curveShifter = curveShifter_;
        mean = mean_;
        deviation = deviation_;
        oneDivDeviationSqrtTwoPi = oneDivDeviationSqrtTwoPi_;
        twoDeviationSquare = twoDeviationSquare_;
        initialRewardShare = initialRewardShare_;
        multiSigRewardShare = multiSigRewardShare_;
        multiSigAddress = multiSigAddress_;

        lastRebase = Rebase.NONE;
    }

    function circBalance() public view returns (uint256) {

        uint256 totalSupply = debase.totalSupply();

        return
            totalSupply
                .sub(debase.balanceOf(address(policy)))
                .sub(debase.balanceOf(burnPool1))
                .sub(debase.balanceOf(burnPool2));
    }

    function startNewCouponCycle(uint256 exchangeRate_) internal {

        if (lastRebase != Rebase.NEGATIVE) {
            lastRebase = Rebase.NEGATIVE;

            uint256 rewardAmount;

            if (rewardsAccrued == 0 && rewardCyclesLength == 0) {
                rewardAmount = circBalance().mul(initialRewardShare).div(
                    10**18
                );
            } else if (
                enableMinimumRewardAccruedCap &&
                rewardsAccrued < minimumRewardAccruedCap
            ) {
                rewardAmount = circBalance().mul(minimumRewardAccruedCap).div(
                    10**18
                );
            } else if (
                enableMaximumRewardAccruedCap &&
                rewardsAccrued > maximumRewardAccruedCap
            ) {
                rewardAmount = circBalance().mul(maximumRewardAccruedCap).div(
                    10**18
                );
            } else {
                rewardAmount = circBalance()
                    .mul(rewardsAccrued.sub(10**18))
                    .div(10**18);
            }

            uint256 rewardShare =
                rewardAmount.mul(10**18).div(debase.totalSupply());

            uint256 debasePerEpoch = rewardShare.div(epochs);

            rewardCycles.push(
                RewardCycle(
                    rewardShare,
                    debasePerEpoch,
                    rewardBlockPeriod,
                    oracleBlockPeriod,
                    exchangeRate_,
                    block.number.add(oracleBlockPeriod),
                    epochs,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0
                )
            );

            emit LogNewCouponCycle(
                rewardCyclesLength,
                rewardShare,
                debasePerEpoch,
                rewardBlockPeriod,
                oracleBlockPeriod,
                exchangeRate_,
                block.number.add(oracleBlockPeriod),
                epochs
            );

            rewardCyclesLength = rewardCyclesLength.add(1);
            positiveToNeutralRebaseRewardsDisabled = false;
            rewardsAccrued = 0;
        } else {
            RewardCycle storage instance =
                rewardCycles[rewardCyclesLength.sub(1)];

            instance.oracleLastPrice = exchangeRate_;
            instance.oracleNextUpdate = block.number.add(
                instance.oracleBlockPeriod
            );

            emit LogOraclePriceAndPeriod(
                instance.oracleLastPrice,
                instance.oracleNextUpdate
            );
        }
        oracle.updateData();
    }

    function issueRewards(
        uint256 exchangeRate_,
        uint256 debasePolicyBalance,
        bytes16 curveValue
    ) internal returns (uint256) {

        RewardCycle storage instance = rewardCycles[rewardCyclesLength.sub(1)];

        instance.epochsRewarded = instance.epochsRewarded.add(1);

        uint256 debaseShareToBeRewarded =
            bytes16ToUnit256(curveValue, instance.debasePerEpoch);

        multiSigRewardToClaimShare = debaseShareToBeRewarded
            .mul(multiSigRewardShare)
            .div(10**18);

        uint256 debaseClaimAmount =
            debase.totalSupply().mul(debaseShareToBeRewarded).div(10**18);

        uint256 multiSigRewardToClaimAmount =
            debase.totalSupply().mul(multiSigRewardToClaimShare).div(10**18);

        uint256 totalDebaseToClaim =
            debaseClaimAmount.add(multiSigRewardToClaimAmount);

        if (totalDebaseToClaim <= debasePolicyBalance) {
            startNewDistributionCycle(
                exchangeRate_,
                totalDebaseToClaim,
                debaseShareToBeRewarded,
                curveValue
            );

            return totalDebaseToClaim;
        }
        return 0;
    }

    function claimMultiSigReward() external {

        require(
            msg.sender == multiSigAddress,
            "Only multiSigAddress can claim reward"
        );

        uint256 amountToClaim =
            debase.totalSupply().mul(multiSigRewardToClaimShare).div(10**18);
        debase.transfer(multiSigAddress, amountToClaim);
        multiSigRewardToClaimShare = 0;
    }

    function checkStabilizerAndGetReward(
        int256 supplyDelta_,
        int256 rebaseLag_,
        uint256 exchangeRate_,
        uint256 debasePolicyBalance
    ) external returns (uint256) {

        require(
            msg.sender == address(policy),
            "Only debase policy contract can call this"
        );

        if (supplyDelta_ < 0) {
            startNewCouponCycle(exchangeRate_);
        } else if (supplyDelta_ == 0) {
            if (lastRebase == Rebase.POSITIVE) {
                positiveToNeutralRebaseRewardsDisabled = true;
            }
            lastRebase = Rebase.NEUTRAL;
            emit LogNeutralRebase(positiveToNeutralRebaseRewardsDisabled);
        } else {
            lastRebase = Rebase.POSITIVE;

            uint256 currentSupply = debase.totalSupply();
            uint256 newSupply = uint256(supplyDelta_.abs()).add(currentSupply);

            if (newSupply > MAX_SUPPLY) {
                newSupply = MAX_SUPPLY;
            }

            uint256 expansionPercentage =
                newSupply.mul(10**18).div(currentSupply).sub(10**18);

            uint256 targetRate =
                policy.priceTargetRate().add(policy.upperDeviationThreshold());

            uint256 offset = exchangeRate_.add(curveShifter).sub(targetRate);

            bytes16 value =
                getCurveValue(
                    offset,
                    mean,
                    oneDivDeviationSqrtTwoPi,
                    twoDeviationSquare
                );

            uint256 expansionPercentageScaled =
                bytes16ToUnit256(value, expansionPercentage).add(10**18);

            if (rewardsAccrued == 0) {
                rewardsAccrued = expansionPercentageScaled;
            } else {
                rewardsAccrued = rewardsAccrued
                    .mul(expansionPercentageScaled)
                    .div(10**18);
            }

            emit LogRewardsAccrued(
                rewardCyclesLength,
                exchangeRate_,
                rewardsAccrued,
                expansionPercentageScaled,
                value
            );

            if (
                !positiveToNeutralRebaseRewardsDisabled &&
                rewardCyclesLength != 0 &&
                rewardCycles[rewardCyclesLength.sub(1)].couponsIssued != 0 &&
                rewardCycles[rewardCyclesLength.sub(1)].epochsRewarded < epochs
            ) {
                return issueRewards(exchangeRate_, debasePolicyBalance, value);
            }
        }

        return 0;
    }

    function checkPriceOrUpdate() internal {

        uint256 lowerPriceThreshold =
            policy.priceTargetRate().sub(policy.lowerDeviationThreshold());

        RewardCycle storage instance = rewardCycles[rewardCyclesLength.sub(1)];

        if (block.number > instance.oracleNextUpdate) {
            bool valid;

            (instance.oracleLastPrice, valid) = oracle.getData();
            require(valid, "Price is invalid");

            instance.oracleNextUpdate = block.number.add(
                instance.oracleBlockPeriod
            );

            emit LogOraclePriceAndPeriod(
                instance.oracleLastPrice,
                instance.oracleNextUpdate
            );
        }

        require(
            instance.oracleLastPrice < lowerPriceThreshold,
            "Can only buy coupons if price is lower than lower threshold"
        );
    }

    function buyCoupons(uint256 debaseSent) external {

        require(
            !address(msg.sender).isContract(),
            "Caller must not be a contract"
        );
        require(
            lastRebase == Rebase.NEGATIVE,
            "Can only buy coupons with last rebase was negative"
        );
        checkPriceOrUpdate();

        RewardCycle storage instance = rewardCycles[rewardCyclesLength.sub(1)];

        instance.userCouponBalances[msg.sender] = instance.userCouponBalances[
            msg.sender
        ]
            .add(debaseSent);

        instance.couponsIssued = instance.couponsIssued.add(debaseSent);

        emit LogCouponsBought(msg.sender, debaseSent, instance.couponsIssued);
        debase.safeTransferFrom(msg.sender, address(policy), debaseSent);
    }

    function emergencyWithdraw() external onlyOwner {

        uint256 withdrawAmount = debase.balanceOf(address(this));
        debase.safeTransfer(address(policy), withdrawAmount);
        emit LogEmergencyWithdrawa(withdrawAmount);
    }

    function lastRewardApplicable(uint256 index)
        internal
        view
        returns (uint256)
    {

        return Math.min(block.number, rewardCycles[index].periodFinish);
    }

    function rewardPerToken(uint256 index) internal view returns (uint256) {

        RewardCycle memory instance = rewardCycles[index];

        if (instance.couponsIssued == 0) {
            return instance.rewardPerTokenStored;
        }

        return
            instance.rewardPerTokenStored.add(
                lastRewardApplicable(index)
                    .sub(instance.lastUpdateBlock)
                    .mul(instance.rewardRate)
                    .mul(10**18)
                    .div(instance.couponsIssued)
            );
    }

    function earned(uint256 index, address account)
        public
        view
        returns (uint256)
    {

        require(rewardCyclesLength != 0, "Cycle array is empty");
        require(
            index <= rewardCyclesLength.sub(1),
            "Index should not me more than items in the cycle array"
        );
        RewardCycle storage instance = rewardCycles[index];

        return
            instance.userCouponBalances[account]
                .mul(
                rewardPerToken(index).sub(
                    instance.userRewardPerTokenPaid[account]
                )
            )
                .div(10**18)
                .add(instance.rewards[account]);
    }

    function getReward(uint256 index) public updateReward(msg.sender, index) {

        require(
            lastRebase == Rebase.POSITIVE,
            "Can only claim rewards when last rebase was positive"
        );
        uint256 reward = earned(index, msg.sender);

        if (reward > 0) {
            RewardCycle storage instance = rewardCycles[index];

            instance.rewards[msg.sender] = 0;

            uint256 rewardToClaim =
                debase.totalSupply().mul(reward).div(10**18);

            instance.rewardDistributed = instance.rewardDistributed.add(reward);
            totalRewardsDistributed = totalRewardsDistributed.add(reward);

            emit LogRewardClaimed(msg.sender, index, rewardToClaim);
            debase.safeTransfer(msg.sender, rewardToClaim);
        }
    }

    function startNewDistributionCycle(
        uint256 exchangeRate_,
        uint256 totalDebaseToClaim,
        uint256 poolTotalShare,
        bytes16 curveValue
    ) internal updateReward(address(0), rewardCyclesLength.sub(1)) {

        RewardCycle storage instance = rewardCycles[rewardCyclesLength.sub(1)];

        uint256 poolBal =
            totalDebaseToClaim.add(debase.balanceOf(address(this)));
        require(
            poolBal < uint256(-1) / 10**18,
            "Rewards: rewards too large, would lock"
        );

        if (block.number >= instance.periodFinish) {
            instance.rewardRate = poolTotalShare.div(
                instance.rewardBlockPeriod
            );
        } else {
            uint256 remaining = instance.periodFinish.sub(block.number);
            uint256 leftover = remaining.mul(instance.rewardRate);
            instance.rewardRate = poolTotalShare.add(leftover).div(
                instance.rewardBlockPeriod
            );
        }

        instance.lastUpdateBlock = block.number;
        instance.periodFinish = block.number.add(instance.rewardBlockPeriod);

        emit LogStartNewDistributionCycle(
            exchangeRate_,
            poolTotalShare,
            instance.rewardRate,
            instance.periodFinish,
            curveValue
        );
    }
}