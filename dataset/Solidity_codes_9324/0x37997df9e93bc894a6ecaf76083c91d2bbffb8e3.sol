

pragma solidity ^0.6.0;


library BokkyPooBahsDateTimeLibrary {


    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {

        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {

        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {

        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {

        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {

        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {

        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {

        (uint year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {

        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {

        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {

        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {

        (uint year, uint month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {

        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {

        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {

        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {

        (,month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {

        (,,day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {

        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {

        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {

        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {

        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {

        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {

        require(fromTimestamp <= toTimestamp);
        (uint fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {

        require(fromTimestamp <= toTimestamp);
        (uint fromYear, uint fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear, uint toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {

        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {

        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {

        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {

        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}


pragma solidity ^0.6.0;

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
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

    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}


pragma solidity ^0.6.0;

abstract contract ENSResolver {
  function addr(bytes32 node) public view virtual returns (address);
}


pragma solidity ^0.6.0;

interface PointerInterface {

  function getAddress() external view returns (address);

}


pragma solidity ^0.6.0;

interface ChainlinkRequestInterface {

  function oracleRequest(
    address sender,
    uint256 requestPrice,
    bytes32 serviceAgreementID,
    address callbackAddress,
    bytes4 callbackFunctionId,
    uint256 nonce,
    uint256 dataVersion, // Currently unused, always "1"
    bytes calldata data
  ) external;


  function cancelOracleRequest(
    bytes32 requestId,
    uint256 payment,
    bytes4 callbackFunctionId,
    uint256 expiration
  ) external;

}


pragma solidity ^0.6.0;

interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);

}


pragma solidity ^0.6.0;

interface ENSInterface {


  event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

  event Transfer(bytes32 indexed node, address owner);

  event NewResolver(bytes32 indexed node, address resolver);

  event NewTTL(bytes32 indexed node, uint64 ttl);


  function setSubnodeOwner(bytes32 node, bytes32 label, address _owner) external;

  function setResolver(bytes32 node, address _resolver) external;

  function setOwner(bytes32 node, address _owner) external;

  function setTTL(bytes32 node, uint64 _ttl) external;

  function owner(bytes32 node) external view returns (address);

  function resolver(bytes32 node) external view returns (address);

  function ttl(bytes32 node) external view returns (uint64);


}


pragma solidity ^0.6.0;

library Buffer {

  struct buffer {
    bytes buf;
    uint capacity;
  }

  function init(buffer memory buf, uint capacity) internal pure returns(buffer memory) {

    if (capacity % 32 != 0) {
      capacity += 32 - (capacity % 32);
    }
    buf.capacity = capacity;
    assembly {
      let ptr := mload(0x40)
      mstore(buf, ptr)
      mstore(ptr, 0)
      mstore(0x40, add(32, add(ptr, capacity)))
    }
    return buf;
  }

  function fromBytes(bytes memory b) internal pure returns(buffer memory) {

    buffer memory buf;
    buf.buf = b;
    buf.capacity = b.length;
    return buf;
  }

  function resize(buffer memory buf, uint capacity) private pure {

    bytes memory oldbuf = buf.buf;
    init(buf, capacity);
    append(buf, oldbuf);
  }

  function max(uint a, uint b) private pure returns(uint) {

    if (a > b) {
      return a;
    }
    return b;
  }

  function truncate(buffer memory buf) internal pure returns (buffer memory) {

    assembly {
      let bufptr := mload(buf)
      mstore(bufptr, 0)
    }
    return buf;
  }

  function write(buffer memory buf, uint off, bytes memory data, uint len) internal pure returns(buffer memory) {

    require(len <= data.length);

    if (off + len > buf.capacity) {
      resize(buf, max(buf.capacity, len + off) * 2);
    }

    uint dest;
    uint src;
    assembly {
      let bufptr := mload(buf)
      let buflen := mload(bufptr)
      dest := add(add(bufptr, 32), off)
      if gt(add(len, off), buflen) {
        mstore(bufptr, add(len, off))
      }
      src := add(data, 32)
    }

    for (; len >= 32; len -= 32) {
      assembly {
        mstore(dest, mload(src))
      }
      dest += 32;
      src += 32;
    }

    uint mask = 256 ** (32 - len) - 1;
    assembly {
      let srcpart := and(mload(src), not(mask))
      let destpart := and(mload(dest), mask)
      mstore(dest, or(destpart, srcpart))
    }

    return buf;
  }

  function append(buffer memory buf, bytes memory data, uint len) internal pure returns (buffer memory) {

    return write(buf, buf.buf.length, data, len);
  }

  function append(buffer memory buf, bytes memory data) internal pure returns (buffer memory) {

    return write(buf, buf.buf.length, data, data.length);
  }

  function writeUint8(buffer memory buf, uint off, uint8 data) internal pure returns(buffer memory) {

    if (off >= buf.capacity) {
      resize(buf, buf.capacity * 2);
    }

    assembly {
      let bufptr := mload(buf)
      let buflen := mload(bufptr)
      let dest := add(add(bufptr, off), 32)
      mstore8(dest, data)
      if eq(off, buflen) {
        mstore(bufptr, add(buflen, 1))
      }
    }
    return buf;
  }

  function appendUint8(buffer memory buf, uint8 data) internal pure returns(buffer memory) {

    return writeUint8(buf, buf.buf.length, data);
  }

  function write(buffer memory buf, uint off, bytes32 data, uint len) private pure returns(buffer memory) {

    if (len + off > buf.capacity) {
      resize(buf, (len + off) * 2);
    }

    uint mask = 256 ** len - 1;
    data = data >> (8 * (32 - len));
    assembly {
      let bufptr := mload(buf)
      let dest := add(add(bufptr, off), len)
      mstore(dest, or(and(mload(dest), not(mask)), data))
      if gt(add(off, len), mload(bufptr)) {
        mstore(bufptr, add(off, len))
      }
    }
    return buf;
  }

  function writeBytes20(buffer memory buf, uint off, bytes20 data) internal pure returns (buffer memory) {

    return write(buf, off, bytes32(data), 20);
  }

  function appendBytes20(buffer memory buf, bytes20 data) internal pure returns (buffer memory) {

    return write(buf, buf.buf.length, bytes32(data), 20);
  }

  function appendBytes32(buffer memory buf, bytes32 data) internal pure returns (buffer memory) {

    return write(buf, buf.buf.length, data, 32);
  }

  function writeInt(buffer memory buf, uint off, uint data, uint len) private pure returns(buffer memory) {

    if (len + off > buf.capacity) {
      resize(buf, (len + off) * 2);
    }

    uint mask = 256 ** len - 1;
    assembly {
      let bufptr := mload(buf)
      let dest := add(add(bufptr, off), len)
      mstore(dest, or(and(mload(dest), not(mask)), data))
      if gt(add(off, len), mload(bufptr)) {
        mstore(bufptr, add(off, len))
      }
    }
    return buf;
  }

  function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {

    return writeInt(buf, buf.buf.length, data, len);
  }
}


pragma solidity ^0.6.0;


library CBOR {

  using Buffer for Buffer.buffer;

  uint8 private constant MAJOR_TYPE_INT = 0;
  uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
  uint8 private constant MAJOR_TYPE_BYTES = 2;
  uint8 private constant MAJOR_TYPE_STRING = 3;
  uint8 private constant MAJOR_TYPE_ARRAY = 4;
  uint8 private constant MAJOR_TYPE_MAP = 5;
  uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

  function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {

    if(value <= 23) {
      buf.appendUint8(uint8((major << 5) | value));
    } else if(value <= 0xFF) {
      buf.appendUint8(uint8((major << 5) | 24));
      buf.appendInt(value, 1);
    } else if(value <= 0xFFFF) {
      buf.appendUint8(uint8((major << 5) | 25));
      buf.appendInt(value, 2);
    } else if(value <= 0xFFFFFFFF) {
      buf.appendUint8(uint8((major << 5) | 26));
      buf.appendInt(value, 4);
    } else if(value <= 0xFFFFFFFFFFFFFFFF) {
      buf.appendUint8(uint8((major << 5) | 27));
      buf.appendInt(value, 8);
    }
  }

  function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private pure {

    buf.appendUint8(uint8((major << 5) | 31));
  }

  function encodeUInt(Buffer.buffer memory buf, uint value) internal pure {

    encodeType(buf, MAJOR_TYPE_INT, value);
  }

  function encodeInt(Buffer.buffer memory buf, int value) internal pure {

    if(value >= 0) {
      encodeType(buf, MAJOR_TYPE_INT, uint(value));
    } else {
      encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - value));
    }
  }

  function encodeBytes(Buffer.buffer memory buf, bytes memory value) internal pure {

    encodeType(buf, MAJOR_TYPE_BYTES, value.length);
    buf.append(value);
  }

  function encodeString(Buffer.buffer memory buf, string memory value) internal pure {

    encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);
    buf.append(bytes(value));
  }

  function startArray(Buffer.buffer memory buf) internal pure {

    encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
  }

  function startMap(Buffer.buffer memory buf) internal pure {

    encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
  }

  function endSequence(Buffer.buffer memory buf) internal pure {

    encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
  }
}


pragma solidity ^0.6.0;



library Chainlink {

  uint256 internal constant defaultBufferSize = 256; // solhint-disable-line const-name-snakecase

  using CBOR for Buffer.buffer;

  struct Request {
    bytes32 id;
    address callbackAddress;
    bytes4 callbackFunctionId;
    uint256 nonce;
    Buffer.buffer buf;
  }

  function initialize(
    Request memory self,
    bytes32 _id,
    address _callbackAddress,
    bytes4 _callbackFunction
  ) internal pure returns (Chainlink.Request memory) {

    Buffer.init(self.buf, defaultBufferSize);
    self.id = _id;
    self.callbackAddress = _callbackAddress;
    self.callbackFunctionId = _callbackFunction;
    return self;
  }

  function setBuffer(Request memory self, bytes memory _data)
    internal pure
  {

    Buffer.init(self.buf, _data.length);
    Buffer.append(self.buf, _data);
  }

  function add(Request memory self, string memory _key, string memory _value)
    internal pure
  {

    self.buf.encodeString(_key);
    self.buf.encodeString(_value);
  }

  function addBytes(Request memory self, string memory _key, bytes memory _value)
    internal pure
  {

    self.buf.encodeString(_key);
    self.buf.encodeBytes(_value);
  }

  function addInt(Request memory self, string memory _key, int256 _value)
    internal pure
  {

    self.buf.encodeString(_key);
    self.buf.encodeInt(_value);
  }

  function addUint(Request memory self, string memory _key, uint256 _value)
    internal pure
  {

    self.buf.encodeString(_key);
    self.buf.encodeUInt(_value);
  }

  function addStringArray(Request memory self, string memory _key, string[] memory _values)
    internal pure
  {

    self.buf.encodeString(_key);
    self.buf.startArray();
    for (uint256 i = 0; i < _values.length; i++) {
      self.buf.encodeString(_values[i]);
    }
    self.buf.endSequence();
  }
}


pragma solidity ^0.6.0;








contract ChainlinkClient {

  using Chainlink for Chainlink.Request;
  using SafeMath for uint256;

  uint256 constant internal LINK = 10**18;
  uint256 constant private AMOUNT_OVERRIDE = 0;
  address constant private SENDER_OVERRIDE = address(0);
  uint256 constant private ARGS_VERSION = 1;
  bytes32 constant private ENS_TOKEN_SUBNAME = keccak256("link");
  bytes32 constant private ENS_ORACLE_SUBNAME = keccak256("oracle");
  address constant private LINK_TOKEN_POINTER = 0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;

  ENSInterface private ens;
  bytes32 private ensNode;
  LinkTokenInterface private link;
  ChainlinkRequestInterface private oracle;
  uint256 private requestCount = 1;
  mapping(bytes32 => address) private pendingRequests;

  event ChainlinkRequested(bytes32 indexed id);
  event ChainlinkFulfilled(bytes32 indexed id);
  event ChainlinkCancelled(bytes32 indexed id);

  function buildChainlinkRequest(
    bytes32 _specId,
    address _callbackAddress,
    bytes4 _callbackFunctionSignature
  ) internal pure returns (Chainlink.Request memory) {

    Chainlink.Request memory req;
    return req.initialize(_specId, _callbackAddress, _callbackFunctionSignature);
  }

  function sendChainlinkRequest(Chainlink.Request memory _req, uint256 _payment)
    internal
    returns (bytes32)
  {

    return sendChainlinkRequestTo(address(oracle), _req, _payment);
  }

  function sendChainlinkRequestTo(address _oracle, Chainlink.Request memory _req, uint256 _payment)
    internal
    returns (bytes32 requestId)
  {

    requestId = keccak256(abi.encodePacked(this, requestCount));
    _req.nonce = requestCount;
    pendingRequests[requestId] = _oracle;
    emit ChainlinkRequested(requestId);
    require(link.transferAndCall(_oracle, _payment, encodeRequest(_req)), "unable to transferAndCall to oracle");
    requestCount += 1;

    return requestId;
  }

  function cancelChainlinkRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunc,
    uint256 _expiration
  )
    internal
  {

    ChainlinkRequestInterface requested = ChainlinkRequestInterface(pendingRequests[_requestId]);
    delete pendingRequests[_requestId];
    emit ChainlinkCancelled(_requestId);
    requested.cancelOracleRequest(_requestId, _payment, _callbackFunc, _expiration);
  }

  function setChainlinkOracle(address _oracle) internal {

    oracle = ChainlinkRequestInterface(_oracle);
  }

  function setChainlinkToken(address _link) internal {

    link = LinkTokenInterface(_link);
  }

  function setPublicChainlinkToken() internal {

    setChainlinkToken(PointerInterface(LINK_TOKEN_POINTER).getAddress());
  }

  function chainlinkTokenAddress()
    internal
    view
    returns (address)
  {

    return address(link);
  }

  function chainlinkOracleAddress()
    internal
    view
    returns (address)
  {

    return address(oracle);
  }

  function addChainlinkExternalRequest(address _oracle, bytes32 _requestId)
    internal
    notPendingRequest(_requestId)
  {

    pendingRequests[_requestId] = _oracle;
  }

  function useChainlinkWithENS(address _ens, bytes32 _node)
    internal
  {

    ens = ENSInterface(_ens);
    ensNode = _node;
    bytes32 linkSubnode = keccak256(abi.encodePacked(ensNode, ENS_TOKEN_SUBNAME));
    ENSResolver resolver = ENSResolver(ens.resolver(linkSubnode));
    setChainlinkToken(resolver.addr(linkSubnode));
    updateChainlinkOracleWithENS();
  }

  function updateChainlinkOracleWithENS()
    internal
  {

    bytes32 oracleSubnode = keccak256(abi.encodePacked(ensNode, ENS_ORACLE_SUBNAME));
    ENSResolver resolver = ENSResolver(ens.resolver(oracleSubnode));
    setChainlinkOracle(resolver.addr(oracleSubnode));
  }

  function encodeRequest(Chainlink.Request memory _req)
    private
    view
    returns (bytes memory)
  {

    return abi.encodeWithSelector(
      oracle.oracleRequest.selector,
      SENDER_OVERRIDE, // Sender value - overridden by onTokenTransfer by the requesting contract's address
      AMOUNT_OVERRIDE, // Amount value - overridden by onTokenTransfer by the actual amount of LINK sent
      _req.id,
      _req.callbackAddress,
      _req.callbackFunctionId,
      _req.nonce,
      ARGS_VERSION,
      _req.buf.buf);
  }

  function validateChainlinkCallback(bytes32 _requestId)
    internal
    recordChainlinkFulfillment(_requestId)
  {}


  modifier recordChainlinkFulfillment(bytes32 _requestId) {

    require(msg.sender == pendingRequests[_requestId],
            "Source must be the oracle of the request");
    delete pendingRequests[_requestId];
    emit ChainlinkFulfilled(_requestId);
    _;
  }

  modifier notPendingRequest(bytes32 _requestId) {

    require(pendingRequests[_requestId] == address(0), "Request is already pending");
    _;
  }
}



pragma solidity 0.6.10;





abstract contract ERC20Token {
    function transferFrom(address from, address to, uint value) public virtual;
    function transfer(address recipient, uint256 amount) public virtual;
    function balanceOf(address account) external view virtual returns (uint256);
    function stakedOf(address _user) public view virtual returns (uint256);
    function dividendsOf(address _user) public view virtual returns (uint256);
    function totalStaked() public view virtual returns (uint256);
    function totalUnlockedSupply() public view virtual returns (uint256);
    function transferFromEx(address from, address to, uint value) public virtual;
}



contract S is ChainlinkClient {

using BokkyPooBahsDateTimeLibrary for uint;

 struct TradeMeta {
    uint256 lastPrice;
    bytes32 linkRequestId;
    uint256 durationCap;
    uint256 acceptedAt;
 }

  struct Trade {
    string ticker;
    uint256 initPrice;
    address buyer;
    address seller;
    uint amountStock;
    uint256 fundsBuyer;
    bool isClosed;
    uint256 priceCreationReqTimeout;
  }

  mapping(address => uint256[]) public addressTrades;
  mapping(bytes32 => uint256) public linkRequestIdToTrade;
  Trade[] public trades;
  TradeMeta[] public tradesMeta;

  bytes32[] trades_ticker;
  uint256[] trades_dsellerPercentage;
  uint256[] trades_maxAmountStock;
  uint256[] trades_minAmountStock;
  bool[] trades_isActive;
  bool[] trades_isCancelled;
  uint256[] trades_fundsSeller;
  uint8[17][] afkHours;


  uint256 public oraclePaymentDefault;
  uint256 public linkToS;
  address public owner;
  address public DAI_token;
  address public SToken;
  uint256 public divPool;
  mapping(address => bool) public oracles;


  event TradeClosed(uint256 tradeID, uint256 price);
  event TradeConfirmed(uint256 tradeID, uint256 price);
  event RequestTradeClosed(uint256 tradeID);
  event OfferCreated(string ticker, uint256 maxAmountStock, uint256 minAmountStock,
                     uint256 dsellerOfferPrice, address dseller);
  event OfferAccepted(uint256 tradeID);
  event OfferCancelled(uint256 tradeID);
  event DaiDivsClaimed(address claimer);


  constructor() public {
    owner = msg.sender;
    setPublicChainlinkToken();
    oraclePaymentDefault = LINK;
    linkToS = 0;
  }

  function setPayment(uint256 _linkAmount, uint256 _linkToS) public
  {

    require(msg.sender == owner);
    oraclePaymentDefault = _linkAmount;
    linkToS = _linkToS;
  }

  function setDAIToken(address _token) public
  {

    require(msg.sender == owner);
    DAI_token = _token;
  }

 function setSToken(address _token) public
  {

    require(msg.sender == owner);
    SToken = _token;
  }

  function setOracle(address _oracle, bool _isCertified) public
  {

    require(msg.sender == owner);
    oracles[_oracle] = _isCertified;

  }


  function createDsellerOffer(uint256 _maxAmountStock, uint256 _minAmountStock,
                             string memory _ticker, bytes32 _tickerBytes,
                             uint256 _fundsSeller, uint256 _dsellerPercentage,
                             uint8[17] memory _afkHours, uint256 _durationCap) public
  {

    trades.push(Trade(_ticker, 0, address(0x0), msg.sender, 0, 0, false, 0));
    tradesMeta.push(TradeMeta(0,0, _durationCap, 0));
    afkHours.push(_afkHours);
    trades_ticker.push(_tickerBytes);
    trades_maxAmountStock.push(_maxAmountStock);
    trades_minAmountStock.push(_minAmountStock);
    trades_dsellerPercentage.push(_dsellerPercentage);
    trades_isActive.push(false);
    trades_isCancelled.push(false);
    addressTrades[msg.sender].push(trades.length-1);
    ERC20Token DAI = ERC20Token(DAI_token);
    DAI.transferFrom(msg.sender, address(this), _fundsSeller);
    trades_fundsSeller.push(_fundsSeller);
    emit OfferCreated(_ticker, _maxAmountStock, _minAmountStock, _dsellerPercentage, msg.sender);
  }

  function cancelDsellerOffer(uint256 _tradeID) public
  {

    require(!trades_isActive[_tradeID], "Trade already active");
    require(!trades[_tradeID].isClosed, "Trade already closed");
    require(!trades_isCancelled[_tradeID], "Trade has been cancelled");
    require(trades[_tradeID].seller == msg.sender);
    require(trades[_tradeID].priceCreationReqTimeout == 0 || trades[_tradeID].priceCreationReqTimeout < block.timestamp);
    trades_isCancelled[_tradeID] = true;
    ERC20Token DAI = ERC20Token(DAI_token);
    DAI.transfer( msg.sender, trades_fundsSeller[_tradeID]);
    trades_fundsSeller[_tradeID] = 0;
    emit OfferCancelled(_tradeID);
  }

  function ceil(uint a, uint m) view private  returns (uint ) {

    return ((a + m - 1) / m) * m;
  }

  function acceptDsellerOffer(uint256 _tradeID, uint256 _amountStock, uint256 _fundsSeller,
                             uint256 dsellerPercentage,
                             address _oracle, bytes32 _jobId,
                             uint256 _oraclePayment) public
  {

    require(!trades_isActive[_tradeID], "Trade already active");
    require(!trades[_tradeID].isClosed, "Trade already closed");
    require(!trades_isCancelled[_tradeID], "Trade has been cancelled");
    require(trades[_tradeID].seller != msg.sender, "Same party");
    require(trades[_tradeID].priceCreationReqTimeout == 0 || trades[_tradeID].priceCreationReqTimeout < block.timestamp, "Trade has not expired");
    require(trades_fundsSeller[_tradeID] == _fundsSeller, "Funds moved");
    require(trades_dsellerPercentage[_tradeID] == dsellerPercentage, "Percentage changed");
    require(trades_minAmountStock[_tradeID] <= _amountStock, "Under min stock amount");
    require(trades_maxAmountStock[_tradeID] >= _amountStock, "Over max stock amount");
    require(oracles[_oracle], "Incorrect oracle address");
    uint8[17] memory _afkHours = afkHours[_tradeID];
    uint256 currentHour = BokkyPooBahsDateTimeLibrary.getHour(block.timestamp);
    for (uint i=0; i<_afkHours.length; i++) {
      if (_afkHours[i] == currentHour) {
        revert("Entering at AFK hour");
      }
    }
    uint256 payment;
    if (_oraclePayment > oraclePaymentDefault) {
      payment = oraclePaymentDefault;
    } else {
      payment = _oraclePayment;
    }
    if (linkToS != 0) {
      fundWithLinkOrS(payment);
    }
    Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this._acceptDsellerOffer.selector);
    req.add("ticker", trades[_tradeID].ticker);
    bytes32 reqId = sendChainlinkRequestTo(_oracle, req, payment);
    linkRequestIdToTrade[reqId] = _tradeID;
    trades[_tradeID].buyer = msg.sender;
    trades[_tradeID].priceCreationReqTimeout = block.timestamp.add(3600);
    trades[_tradeID].amountStock = ceil(_amountStock, 1000);
    addressTrades[msg.sender].push(_tradeID);
    emit OfferAccepted(_tradeID);
  }

function _acceptDsellerOffer(bytes32 _requestId, uint256 _price)
  public
  recordChainlinkFulfillment(_requestId)
{

  uint256 tradeID = linkRequestIdToTrade[_requestId];
  Trade memory trade = trades[tradeID];
  require(!trades_isActive[tradeID], "Trade already active");
  require(!trade.isClosed, "Trade already closed");
  require(!trades_isCancelled[tradeID], "Trade has been cancelled");
  require(trade.priceCreationReqTimeout > block.timestamp, "Request expired");
  uint256 presentValueBuyer = trade.amountStock.mul(_price.mul(trades_dsellerPercentage[tradeID]).div(100).div(1000));
  trades[tradeID].fundsBuyer = presentValueBuyer;
  ERC20Token DAI = ERC20Token(DAI_token);
  DAI.transferFrom(trade.buyer, address(this), presentValueBuyer);
  trades_isActive[tradeID] = true;
  tradesMeta[tradeID].acceptedAt = block.timestamp;
  trades[tradeID].initPrice = _price;
  trades[tradeID].priceCreationReqTimeout = 0;
  emit TradeConfirmed(tradeID, _price);
}

function fundWithLinkOrS(uint256 linkPayment) public {

  ERC20Token ST = ERC20Token(SToken);
  uint256 sBalance = ST.balanceOf(msg.sender);
  uint256 sPayment = linkPayment.mul(linkToS).div(100);
  if (sBalance >= sPayment) {
    ST.transferFromEx(msg.sender, address(this), sPayment);
  } else {
    LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
    require(link.transferFrom(msg.sender, address(this), linkPayment));
  }
}

function closeTrade(uint256 _tradeID, address _oracle, bytes32 _jobId,
                    uint256 _oraclePayment) public
{

  require(trades_isActive[_tradeID], "Trade is not active");
  require(!trades[_tradeID].isClosed, "Trade already closed");
  require(oracles[_oracle], "Incorrect oracle address");
  bool calledByBuyer = trades[_tradeID].buyer == msg.sender;
  bool calledBySeller = trades[_tradeID].seller == msg.sender;
  if (!calledByBuyer && !calledBySeller) {
    revert("Not a party");
  }
  if (calledBySeller &&
     (tradesMeta[_tradeID].acceptedAt.add(tradesMeta[_tradeID].durationCap) > block.timestamp ||
      tradesMeta[_tradeID].durationCap == 0)) {
    revert("Seller timelock pending");
  }
  uint8[17] memory _afkHours = afkHours[_tradeID];
  uint256 currentHour = BokkyPooBahsDateTimeLibrary.getHour(block.timestamp);
  for (uint i=0; i<_afkHours.length; i++) {
            if (_afkHours[i] == currentHour) {
               revert("Closing at AFK hour");
      }
  }
  uint256 payment;
  if (_oraclePayment > oraclePaymentDefault) {
    payment = oraclePaymentDefault;
  } else {
    payment = _oraclePayment;
  }
  if (linkToS != 0) {
    fundWithLinkOrS(payment);
  }
  trades[_tradeID].priceCreationReqTimeout = block.timestamp.add(3600);
  Chainlink.Request memory req = buildChainlinkRequest(_jobId, address(this), this._closeTrade.selector);
  req.add("ticker", trades[_tradeID].ticker);
  bytes32 reqId = sendChainlinkRequestTo(_oracle, req, payment);
  linkRequestIdToTrade[reqId] = _tradeID;
  emit RequestTradeClosed(_tradeID);
}


function _closeTrade(bytes32 _requestId, uint256 _price)
  public
  recordChainlinkFulfillment(_requestId)
{

  uint256 tradeID = linkRequestIdToTrade[_requestId];
  Trade memory trade = trades[tradeID];
  uint256 presentValue = trade.amountStock.mul(_price).div(1000);
  uint256 initValue = trade.amountStock.mul(trade.initPrice.mul(trades_dsellerPercentage[tradeID]).div(100)).div(1000);
  uint256 sendToBuyer;
  uint256 sendToSeller;
  if (presentValue > initValue) {
      uint256 buyerProfit = presentValue.sub(initValue);
      if (buyerProfit > trades_fundsSeller[tradeID]) {
        buyerProfit = trades_fundsSeller[tradeID];
      }
      uint256 buyerProfitShare = buyerProfit.mul(95).div(100);
      divPool = divPool.add(buyerProfit.mul(5).div(100));
      sendToBuyer = trade.fundsBuyer.add(buyerProfitShare);
      sendToSeller = trades_fundsSeller[tradeID].sub(buyerProfit);
  }
  if (presentValue <= initValue) {
      uint256 sellerProfit = initValue.sub(presentValue);
      sendToSeller = trades_fundsSeller[tradeID].add(sellerProfit);
      sendToBuyer = trade.fundsBuyer.sub(sellerProfit);
  }
  trades_fundsSeller[tradeID] = 0;
  trades[tradeID].fundsBuyer = 0;
  ERC20Token DAI = ERC20Token(DAI_token);
  if (sendToSeller > 0) {
         DAI.transfer(trade.seller, sendToSeller);
  }
  if (sendToBuyer > 0) {
         DAI.transfer(trade.buyer, sendToBuyer);
  }
  trades[tradeID].isClosed = true;
  tradesMeta[tradeID].lastPrice = _price;
  tradesMeta[tradeID].linkRequestId = _requestId;
  trades[tradeID].priceCreationReqTimeout = 0;
  emit TradeClosed(tradeID, _price);
}

  function daiDividends(address _forHolder) public view returns (uint256)
  {

      uint256 totalOpenPool = divPool;
      ERC20Token ST = ERC20Token(SToken);
      uint256 userSDividends = ST.dividendsOf(_forHolder);
      uint256 totalUnlocked = ST.totalUnlockedSupply();
      return totalOpenPool.mul(userSDividends).div(totalUnlocked);
  }

  function claimDaiDividends(address _forHolder, uint256 _dividends) public
  {

    require(msg.sender == SToken);
    ERC20Token DAI = ERC20Token(DAI_token);
    ERC20Token ST = ERC20Token(SToken);
    uint256 totalOpenPool = divPool;
    uint256 totalUnlocked = ST.totalUnlockedSupply();
    uint256 divsDue = totalOpenPool.mul(_dividends).div(totalUnlocked);
    divPool = divPool.sub(divsDue);
    DAI.transfer(_forHolder, divsDue);
    emit DaiDivsClaimed(msg.sender);
  }
   function getTradePublic(uint256 i) public view returns (bytes32, uint256, uint256, uint256, bool, bool, uint256 ){

     return(trades_ticker[i], trades_dsellerPercentage[i], trades_maxAmountStock[i],
            trades_minAmountStock[i], trades_isActive[i], trades_isCancelled[i], trades_fundsSeller[i] );
   }

    function tradesLength() public view returns( uint256 ){

        return trades.length;
    }

  function getAfkHoursForTrade(uint256 _tradeID) public view returns (uint8[17] memory )
  {

     return afkHours[_tradeID];
  }

    function getTradeTickers() public view returns( bytes32[] memory){

        return trades_ticker;
    }

    function getTradeDsellerPercentage() public view returns( uint256[] memory){

        return trades_dsellerPercentage;
    }

    function getTradeMaxAmountStock() public view returns( uint256[] memory){

        return trades_maxAmountStock;
    }

    function getTradeMinAmountStock() public view returns( uint256[] memory){

        return trades_minAmountStock;
    }

    function getTradeIsActive() public view returns( bool[] memory){

        return trades_isActive;
    }

    function getTradeIsCancelled() public view returns( bool[] memory){

        return trades_isCancelled;
    }

    function getTradeFundsSeller() public view returns( uint256[] memory){

        return trades_fundsSeller;
    }

    function getAddressTrades(address _of) public view returns( uint256[] memory){

        return addressTrades[_of];
    }
}