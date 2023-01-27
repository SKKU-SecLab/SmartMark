
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

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
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// GPL-3.0

pragma solidity >=0.6.0;

interface RNGInterface {


  event RandomNumberRequested(uint32 indexed requestId, address indexed sender);

  event RandomNumberCompleted(uint32 indexed requestId, uint256 randomNumber);

  function getLastRequestId() external view returns (uint32 requestId);


  function getRequestFee() external view returns (address feeToken, uint256 requestFee);


  function requestRandomNumber() external returns (uint32 requestId, uint32 lockBlock);


  function isRequestComplete(uint32 requestId) external view returns (bool isCompleted);


  function randomNumber(uint32 requestId) external returns (uint256 randomNum);

}// GPL-3.0

pragma solidity ^0.6.6;



contract RNGBlockhash is RNGInterface, Ownable {

  using SafeMath for uint256;
  using SafeCast for uint256;

  uint32 internal requestCount;

  mapping(uint32 => uint256) internal randomNumbers;

  mapping(uint32 => uint32) internal requestLockBlock;

  constructor() public { }

  function getLastRequestId() external override view returns (uint32 requestId) {

    return requestCount;
  }

  function getRequestFee() external override view returns (address feeToken, uint256 requestFee) {

    return (address(0), 0);
  }

  function requestRandomNumber() external virtual override returns (uint32 requestId, uint32 lockBlock) {

    requestId = _getNextRequestId();
    lockBlock = uint32(block.number);

    requestLockBlock[requestId] = lockBlock;

    emit RandomNumberRequested(requestId, msg.sender);
  }

  function isRequestComplete(uint32 requestId) external virtual override view returns (bool isCompleted) {

    return _isRequestComplete(requestId);
  }

  function randomNumber(uint32 requestId) external virtual override returns (uint256 randomNum) {

    require(_isRequestComplete(requestId), "RNGBlockhash/request-incomplete");

    if (randomNumbers[requestId] == 0) {
      _storeResult(requestId, _getSeed());
    }

    return randomNumbers[requestId];
  }

  function _isRequestComplete(uint32 requestId) internal view returns (bool) {

    return block.number > (requestLockBlock[requestId] + 1);
  }

  function _getNextRequestId() internal returns (uint32 requestId) {

    requestCount = uint256(requestCount).add(1).toUint32();
    requestId = requestCount;
  }

  function _getSeed() internal virtual view returns (uint256 seed) {

    return uint256(blockhash(block.number - 1));
  }

  function _storeResult(uint32 requestId, uint256 result) internal {

    randomNumbers[requestId] = result;

    emit RandomNumberCompleted(requestId, result);
  }
}