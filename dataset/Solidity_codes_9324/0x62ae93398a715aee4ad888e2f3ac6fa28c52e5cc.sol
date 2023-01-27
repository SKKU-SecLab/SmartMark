
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}//Unlicense
pragma solidity ^0.8.3;

interface ERC20Interface {

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function balanceOf(address _account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

    function approve(address spender, uint tokens) external returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}// Unlicensed
pragma solidity ^0.8.3;

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

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
}// MIT
pragma solidity ^0.8.3;

library Calculator {

  function calculator(
        uint256 principal,
        uint256 n,
        uint256 apy
   ) internal pure returns (uint256 amount) {

        int128 div = ABDKMath64x64.divu(apy, 36500 * 1 days); // second rate
        int128 sum = ABDKMath64x64.add(ABDKMath64x64.fromInt(1), div);
        int128 pow = ABDKMath64x64.pow(sum, n);
        uint256 res = ABDKMath64x64.mulu(pow, principal);
        return res;
    }

  function getValueOfRepresentUmi(
      uint256 stakedLpTokens,
      uint256 lpTokenTotalSupply,
      uint112 umiReserve) internal pure returns(uint256) {

      int128 lpRatio = ABDKMath64x64.divu(stakedLpTokens, lpTokenTotalSupply);
      uint256 res = ABDKMath64x64.mulu(lpRatio, uint256(umiReserve));
      return res;
  }

}// MIT
pragma solidity ^0.8.3;

contract CommonConstants {


    bytes4 constant internal ERC1155_ACCEPTED = 0xf23a6e61; // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
    bytes4 constant internal ERC1155_BATCH_ACCEPTED = 0xbc197c81; // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
}//Unlicense
pragma solidity ^0.8.3;


abstract contract ERC1155TokenReceiver is ERC1155Receiver, CommonConstants {

    function onERC1155Received(
        address, /*operator*/
        address, /*from _msgSender*/
        uint256, /*id*/
        uint256, /*value*/
        bytes calldata /*data*/
    ) external virtual override returns (bytes4) {
        return ERC1155_ACCEPTED;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address, /*from*/
        uint256[] calldata, /*ids*/
        uint256[] calldata, /*value*/
        bytes calldata /*data*/
    ) external virtual override returns (bytes4) {
        return ERC1155_BATCH_ACCEPTED;
    }
}//Unlicense
pragma solidity ^0.8.3;


contract LpNftStakingFarm is
    Context,
    Ownable,
    ReentrancyGuard,
    Pausable,
    ERC1155TokenReceiver
{

    using Address for address;
    using SafeMath for uint256;
    using Calculator for uint256;

    event ContractFunded(
        address indexed sender,
        uint256 amount,
        uint256 timestamp
    );

    event Staked(address indexed sender, uint256 balance, uint256 timestamp);

    event Unstaked(
        address indexed sender,
        uint256 apy,
        uint256 balance,
        uint256 umiInterest,
        uint256 timePassed,
        uint256 timestamp
    );

    event BaseApySet(uint256 value, address sender);

    event NftApySet(address indexed nftAddress, uint256 nftId, uint256 value, address sender);

    event NftStaked(
        address indexed sender,
        address indexed nftAddress,
        uint256 nftId,
        uint256 amount,
        uint256 timestamp
    );

    event NftsBatchStaked(
        address indexed sender,
        address indexed nftAddress,
        uint256[] nftIds,
        uint256[] amounts,
        uint256 timestamp
    );

    event NftUnstaked(
        address indexed sender,
        address indexed nftAddress,
        uint256 nftId,
        uint256 amount,
        uint256 timestamp
    );

    event NftsBatchUnstaked(
        address indexed sender,
        address indexed nftAddress,
        uint256[] nftIds,
        uint256[] amounts,
        uint256 timestamp
    );

    event Claimed(
        address indexed sender,
        uint256 principal,
        uint256 interest,
        uint256 claimTimestamp
    );

    IUniswapV2Pair public lpToken;
    ERC20Interface public umiToken;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public stakeDates;
    uint256 public totalStaked;

    mapping(address => uint256) public funding;
    uint256 public totalFunding;

    mapping(address => mapping(uint256 => uint8)) public nftApys;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public nftBalances;
    mapping(address => mapping(address => NftSet)) userNftIds;
    uint256 public totalNftStaked;
    struct NftSet {
        uint256[] ids;
        mapping(uint256 => bool) isIn;
    }
    address[] public nftAddresses;
    mapping(address => bool) public isNftSupported;
    address private firstNft = 0xd194f079Cc291Fe9DB7Dad95444eEc1246413636;
    address private secondNft = 0x90ad78735BC59a5dCb6a038728684c484CD5860D;

    uint256 public BASE_APY = 33; // stand for 33%

    constructor(address _umiAddress, address _lpAddress) {
        require(
            _umiAddress.isContract() && _lpAddress.isContract(),
            "must use contract address"
        );
        umiToken = ERC20Interface(_umiAddress);
        lpToken = IUniswapV2Pair(_lpAddress);
        
        nftAddresses.push(firstNft);
        nftAddresses.push(secondNft);
        isNftSupported[firstNft] = true;
        isNftSupported[secondNft] = true;
        
        initApys();
    }

    function fundingContract(uint256 _amount) external nonReentrant {

        require(_amount > 0, "_amount should be more than 0");
        funding[msg.sender] += _amount;
        totalFunding += _amount;
        require(
            umiToken.transferFrom(msg.sender, address(this), _amount),
            "transferFrom failed"
        );
        emit ContractFunded(msg.sender, _amount, _now());
    }

    function setBaseApy(uint256 _APY) public onlyOwner {

        BASE_APY = _APY;
        emit BaseApySet(BASE_APY, msg.sender);
    }

    function stake(uint256 _amount) public whenNotPaused nonReentrant {

        _stake(msg.sender, _amount);
    }

    function _stake(address _sender, uint256 _amount) internal {

        require(_amount > 0, "stake amount should be more than 0");
        uint256 umiInterest = calculateUmiTokenRewards(_sender);

        balances[_sender] = balances[_sender].add(_amount);
        totalStaked = totalStaked.add(_amount);
        uint256 stakeTimestamp = _now();
        stakeDates[_sender] = stakeTimestamp;
        emit Staked(_sender, _amount, stakeTimestamp);
        require(
            lpToken.transferFrom(_sender, address(this), _amount),
            "transfer failed"
        );
        transferUmiInterest(_sender, umiInterest);
    }
    
    function transferUmiInterest(address recipient, uint256 amount) internal {

        if (amount <= 0) {
            return;
        }
        totalFunding = totalFunding.sub(amount);
        require(
                umiToken.transfer(recipient, amount),
                "transfer umi interest failed"
            );
    }

    function unstake() external whenNotPaused nonReentrant {

        _unstake(msg.sender);
    }

    function _unstake(address _sender) internal {

        uint256 balance = balances[msg.sender];
        require(balance > 0, "insufficient funds");
        (uint256 totalWithInterest, uint256 principalOfRepresentUmi, uint256 timePassed) =
            calculateRewardsAndTimePassed(_sender, 0);
        require(
            totalWithInterest > 0 && timePassed > 0,
            "totalWithInterest<=0 or timePassed<=0"
        );
        balances[_sender] = 0;
        stakeDates[_sender] = 0;
        totalStaked = totalStaked.sub(balance);

        uint256 interest = totalWithInterest.sub(principalOfRepresentUmi);
        uint256 umiInterestAmount = 0;
        if (interest > 0 && totalFunding >= interest) {
            umiInterestAmount = interest;
            totalFunding = totalFunding.sub(interest);
        }
        if (umiInterestAmount > 0) {
            require(
                umiToken.transfer(_sender, umiInterestAmount),
                "_unstake umi transfer failed"
            );
        }
        require(
            lpToken.transfer(_sender, balance),
            "_unstake: lp transfer failed"
        );
        emit Unstaked(
            _sender,
            getTotalApyOfUser(_sender),
            balance,
            umiInterestAmount,
            timePassed,
            _now()
        );
    }

    function stakeNft(
        address nftAddress,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external whenNotPaused nonReentrant {

        require(isInWhitelist(nftAddress, id), "stakeNft: nft id not in whitelist");
        _stakeNft(msg.sender, address(this), nftAddress, id, value, data);
    }

    function _stakeNft(
        address _from,
        address _to,
        address _nftAddress,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) internal {

        uint256 umiInterest = calculateUmiTokenRewards(_from);
        stakeDates[_from] = balances[_from] > 0 ?  _now() : 0;

        nftBalances[_from][_nftAddress][_id] = nftBalances[_from][_nftAddress][_id].add(_value);
        setUserNftIds(_from, _nftAddress, _id);
        totalNftStaked = totalNftStaked.add(_value);

        getERC1155(_nftAddress).safeTransferFrom(_from, _to, _id, _value, _data);
        transferUmiInterest(_from, umiInterest);
        emit NftStaked(_from, _nftAddress, _id, _value, _now());
    }

    function batchStakeNfts(
        address nftAddress,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external whenNotPaused nonReentrant {

        require(
            ids.length == values.length,
            "ids and values length mismatch"
        );
        _batchStakeNfts(msg.sender, address(this), nftAddress, ids, values, data);
    }

    function _batchStakeNfts(
        address _from,
        address _to,
        address _nftAddress,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes calldata _data
    ) internal {

        uint256 umiInterest = calculateUmiTokenRewards(_from);
        stakeDates[_from] = balances[_from] > 0 ?  _now() : 0;

        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            uint256 value = _values[i];

            require(isInWhitelist(_nftAddress, id), "nft id not in whitelist");

            nftBalances[_from][_nftAddress][id] = nftBalances[_from][_nftAddress][id].add(value);
            setUserNftIds(_from, _nftAddress, id);
            totalNftStaked = totalNftStaked.add(value);
        }

        getERC1155(_nftAddress).safeBatchTransferFrom(_from, _to, _ids, _values, _data);
        transferUmiInterest(msg.sender, umiInterest);
        emit NftsBatchStaked(_from, _nftAddress, _ids, _values, _now());
    }

    function unstakeNft(
        address nftAddress,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external whenNotPaused nonReentrant {

        _unstakeNft(nftAddress, id, value, data);
    }

    function _unstakeNft(
        address _nftAddress,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) internal {

        uint256 umiInterest = calculateUmiTokenRewards(msg.sender);
        stakeDates[msg.sender] = balances[msg.sender] > 0 ?  _now() : 0;

        uint256 nftBalance = nftBalances[msg.sender][_nftAddress][_id];
        require(
            nftBalance >= _value,
            "insufficient balance for unstake"
        );

        nftBalances[msg.sender][_nftAddress][_id] = nftBalance.sub(_value);
        totalNftStaked = totalNftStaked.sub(_value);
        if (nftBalances[msg.sender][_nftAddress][_id] == 0) {
            removeUserNftId(_nftAddress, _id);
        }

        getERC1155(_nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _id,
            _value,
            _data
        );
        transferUmiInterest(msg.sender, umiInterest);
        emit NftUnstaked(msg.sender, _nftAddress, _id, _value, _now());
    }

    function batchUnstakeNfts(
        address nftAddress,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external whenNotPaused nonReentrant {

        require(
            ids.length == values.length,
            "ids and values length mismatch"
        );
        _batchUnstakeNfts(address(this), msg.sender, nftAddress, ids, values, data);
    }

    function _batchUnstakeNfts(
        address _from,
        address _to,
        address _nftAddress,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) internal {

        uint256 umiInterest = calculateUmiTokenRewards(_from);
        stakeDates[_from] = balances[_from] > 0 ?  _now() : 0;

        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 id = _ids[i];
            uint256 value = _values[i];

            uint256 nftBalance = nftBalances[msg.sender][_nftAddress][id];
            require(
                nftBalance >= value,
                "insufficient nft balance for unstake"
            );
            nftBalances[msg.sender][_nftAddress][id] = nftBalance.sub(value);
            totalNftStaked = totalNftStaked.sub(value);
            if (nftBalances[msg.sender][_nftAddress][id] == 0) {
                removeUserNftId(_nftAddress, id);
            }
        }

        getERC1155(_nftAddress).safeBatchTransferFrom(_from, _to, _ids, _values, _data);
        transferUmiInterest(msg.sender, umiInterest);
        emit NftsBatchUnstaked(msg.sender, _nftAddress, _ids, _values, _now());
    }

    function claim() external whenNotPaused nonReentrant {

        uint256 balance = balances[msg.sender];
        require(balance > 0, "balance should more than 0");
        (uint256 totalWithInterest, uint256 principalOfRepresentUmi, uint256 timePassed) = calculateRewardsAndTimePassed(msg.sender, 0);
        require(
            totalWithInterest > 0 && timePassed >= 0,
            "calculate rewards and TimePassed error"
        );
        uint256 interest = totalWithInterest.sub(principalOfRepresentUmi);
        require(interest > 0, "claim interest must more than 0");
        require(totalFunding >= interest, "total funding not enough to pay interest");
        totalFunding = totalFunding.sub(interest);
        uint256 claimTimestamp = _now();
        stakeDates[msg.sender] = claimTimestamp;
        require(
            umiToken.transfer(msg.sender, interest),
            "claim: transfer failed"
        );
        emit Claimed(msg.sender, balance, interest, claimTimestamp);
    }

    function calculateUmiTokenRewards(address _from) public view returns(uint256) {

        uint256 balance = balances[_from];
        if (balance <= 0) {
            return 0;
        }
        (uint256 totalWithInterest, uint principalOfRepresentUmi, uint256 timePassed) =
            calculateRewardsAndTimePassed(_from, 0);
        require(
            totalWithInterest > 0 && timePassed >= 0,
            "calculate rewards and TimePassed error"
        );
        return totalWithInterest.sub(principalOfRepresentUmi);
    }

    function calculateRewardsAndTimePassed(address _user, uint256 _amount)
        internal
        view
        returns (uint256, uint256, uint256)
    {

        uint256 currentBalance = balances[_user];
        uint256 amount = _amount == 0 ? currentBalance : _amount;
        uint256 stakeDate = stakeDates[_user];
        uint256 timePassed = _now().sub(stakeDate);
        if (timePassed < 1 seconds) {
            return (0, 0, timePassed);
        }
        uint256 totalApy = getTotalApyOfUser(_user);
        uint256 lpTokenTotalSupply = lpToken.totalSupply();
        (uint112 umiReserve,,) = lpToken.getReserves();
        uint256 principalOfRepresentUmi = Calculator.getValueOfRepresentUmi(amount, lpTokenTotalSupply, umiReserve);
        uint256 totalWithInterest =
            Calculator.calculator(principalOfRepresentUmi, timePassed, totalApy);
        return (totalWithInterest, principalOfRepresentUmi, timePassed);
    }

    function getUmiBalance(address addr) public view returns (uint256) {

        return umiToken.balanceOf(addr);
    }
    
    function getERC1155(address _nftAddress) internal pure returns(IERC1155) {

       IERC1155 nftContract = IERC1155(_nftAddress);
       return nftContract;
    }

    function getLpBalance(address addr) public view returns (uint256) {

        return lpToken.balanceOf(addr);
    }

    function getNftBalance(address user, address nftAddress, uint256 id)
        public
        view
        returns (uint256)
    {

        return getERC1155(nftAddress).balanceOf(user, id);
    }

    function getUserNftIds(address user, address nftAddress)
        public
        view
        returns (uint256[] memory)
    {

        return userNftIds[user][nftAddress].ids;
    }

    function getUserNftIdsLength(address user, address nftAddress) public view returns (uint256) {

        return userNftIds[user][nftAddress].ids.length;
    }

    function isNftIdExist(address user, address nftAddress, uint256 nftId)
        public
        view
        returns (bool)
    {

        NftSet storage nftSet = userNftIds[user][nftAddress];
        mapping(uint256 => bool) storage isIn = nftSet.isIn;
        return isIn[nftId];
    }

    function setUserNftIds(address user, address nftAddress, uint256 nftId) internal {

        NftSet storage nftSet = userNftIds[user][nftAddress];
        uint256[] storage ids = nftSet.ids;
        mapping(uint256 => bool) storage isIn = nftSet.isIn;
        if (!isIn[nftId]) {
            ids.push(nftId);
            isIn[nftId] = true;
        }
    }

    function removeUserNftId(address nftAddress, uint256 nftId) internal {

        NftSet storage nftSet = userNftIds[msg.sender][nftAddress];
        uint256[] storage ids = nftSet.ids;
        mapping(uint256 => bool) storage isIn = nftSet.isIn;
        require(ids.length > 0, "remove user nft ids, ids length must > 0");

        for (uint256 i = 0; i < ids.length; i++) {
            if (ids[i] == nftId) {
                ids[i] = ids[ids.length - 1];
                isIn[nftId] = false;
                ids.pop();
            }
        }
    }

    function setApyByTokenId(address nftAddress, uint256 id, uint8 apy) public onlyOwner {

        require(nftAddress != address(0), "nft address incorrect");
        require(id > 0 && apy > 0, "nft and apy must > 0");
        if (!isNftSupported[nftAddress]) {
           nftAddresses.push(nftAddress);
           isNftSupported[nftAddress] = true;
        }
        nftApys[nftAddress][id] = apy;
        emit NftApySet(nftAddress, id, apy, msg.sender);
    }

    function isInWhitelist(address nftAddress, uint256 id) public view returns(bool) {

        return nftApys[nftAddress][id] > 0;
    }

    function getTotalApyOfUser(address user) public view returns (uint256) {

        uint256 balanceOfUmi = balances[user];
        if (balanceOfUmi <= 0) {
            return 0;
        }
        uint256 totalApy = BASE_APY;
        
        for (uint256 i = 0; i< nftAddresses.length; i++) {
            uint256[] memory nftIds = getUserNftIds(user, nftAddresses[i]);
            if (nftIds.length <= 0) {
                continue;
            }
            for (uint256 j = 0; j < nftIds.length; j++) {
                uint256 nftId = nftIds[j];
                uint256 balance = nftBalances[user][nftAddresses[i]][nftId];
                uint256 apy = nftApys[nftAddresses[i]][nftId];
                totalApy = totalApy.add(balance.mul(apy));
            }
        }
        
        return totalApy;
    }

    function _now() internal view returns (uint256) {

        return block.timestamp; // solium-disable-line security/no-block-members
    }

    function pause() public onlyOwner {

        _pause();
    }

    function unpause() public onlyOwner {

        _unpause();
    }

    function initApys() internal onlyOwner {

        nftApys[firstNft][59] = 1;
        nftApys[firstNft][18] = 2;
        nftApys[firstNft][19] = 2;
        nftApys[firstNft][20] = 2;
        nftApys[firstNft][1] = 10;
        nftApys[firstNft][2] = 10;
        nftApys[firstNft][4] = 10;
        nftApys[firstNft][5] = 10;
        nftApys[firstNft][6] = 10;
        nftApys[firstNft][7] = 10;
        nftApys[firstNft][8] = 10;
        nftApys[firstNft][9] = 10;
        nftApys[firstNft][12] = 10;
        nftApys[firstNft][13] = 10;
        nftApys[firstNft][14] = 10;
        nftApys[firstNft][15] = 10;
        nftApys[firstNft][16] = 10;
        nftApys[firstNft][22] = 10;
        nftApys[firstNft][23] = 10;
        nftApys[firstNft][24] = 10;
        nftApys[firstNft][26] = 10;
        nftApys[firstNft][27] = 10;
        nftApys[firstNft][28] = 10;
        nftApys[firstNft][29] = 10;
        nftApys[firstNft][30] = 10;
        nftApys[firstNft][31] = 10;
        nftApys[firstNft][32] = 10;
        nftApys[firstNft][33] = 10;
        nftApys[firstNft][35] = 10;
        nftApys[firstNft][36] = 10;
        nftApys[firstNft][37] = 10;
        nftApys[firstNft][3] = 20;
        nftApys[firstNft][11] = 20;
        nftApys[firstNft][25] = 20;
        nftApys[firstNft][34] = 20;
        nftApys[firstNft][17] = 30;
        nftApys[firstNft][38] = 40;
        nftApys[firstNft][39] = 40;
        nftApys[firstNft][40] = 40;
        nftApys[firstNft][41] = 40;
        nftApys[firstNft][42] = 40;
        nftApys[firstNft][43] = 40;
        nftApys[firstNft][44] = 40;

        nftApys[firstNft][52] = 40;
        nftApys[firstNft][60] = 40;
        nftApys[firstNft][61] = 40;
        nftApys[firstNft][62] = 40;
        nftApys[firstNft][63] = 40;
        nftApys[firstNft][64] = 40;
        nftApys[firstNft][65] = 40;
        nftApys[firstNft][66] = 40;
        nftApys[firstNft][67] = 40;
        nftApys[firstNft][45] = 80;
        nftApys[firstNft][46] = 80;
        nftApys[firstNft][47] = 80;
        nftApys[firstNft][48] = 80;
        nftApys[firstNft][49] = 80;
        nftApys[firstNft][50] = 80;
        
        nftApys[secondNft][1] = 20;
        nftApys[secondNft][2] = 102;
        nftApys[secondNft][3] = 102;
        nftApys[secondNft][4] = 102;
        nftApys[secondNft][5] = 102;
        nftApys[secondNft][6] = 102;
        nftApys[secondNft][7] = 102;
        nftApys[secondNft][8] = 102;
        nftApys[secondNft][9] = 102;
        nftApys[secondNft][10] = 102;
        nftApys[secondNft][12] = 102;
        nftApys[secondNft][13] = 102;
        nftApys[secondNft][14] = 102;
        nftApys[secondNft][15] = 102;
        nftApys[secondNft][16] = 102;
        nftApys[secondNft][18] = 102;
        nftApys[secondNft][19] = 102;
        nftApys[secondNft][20] = 102;
        nftApys[secondNft][21] = 102;
        nftApys[secondNft][22] = 102;
        nftApys[secondNft][23] = 102;
    }

}