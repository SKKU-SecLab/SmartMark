
pragma solidity >=0.8.0;





library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}




library BufferChainlink {

  struct buffer {
    bytes buf;
    uint256 capacity;
  }

  function init(buffer memory buf, uint256 capacity) internal pure returns (buffer memory) {

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

  function fromBytes(bytes memory b) internal pure returns (buffer memory) {

    buffer memory buf;
    buf.buf = b;
    buf.capacity = b.length;
    return buf;
  }

  function resize(buffer memory buf, uint256 capacity) private pure {

    bytes memory oldbuf = buf.buf;
    init(buf, capacity);
    append(buf, oldbuf);
  }

  function max(uint256 a, uint256 b) private pure returns (uint256) {

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

  function write(
    buffer memory buf,
    uint256 off,
    bytes memory data,
    uint256 len
  ) internal pure returns (buffer memory) {

    require(len <= data.length);

    if (off + len > buf.capacity) {
      resize(buf, max(buf.capacity, len + off) * 2);
    }

    uint256 dest;
    uint256 src;
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

    unchecked {
      uint256 mask = (256**(32 - len)) - 1;
      assembly {
        let srcpart := and(mload(src), not(mask))
        let destpart := and(mload(dest), mask)
        mstore(dest, or(destpart, srcpart))
      }
    }

    return buf;
  }

  function append(
    buffer memory buf,
    bytes memory data,
    uint256 len
  ) internal pure returns (buffer memory) {

    return write(buf, buf.buf.length, data, len);
  }

  function append(buffer memory buf, bytes memory data) internal pure returns (buffer memory) {

    return write(buf, buf.buf.length, data, data.length);
  }

  function writeUint8(
    buffer memory buf,
    uint256 off,
    uint8 data
  ) internal pure returns (buffer memory) {

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

  function appendUint8(buffer memory buf, uint8 data) internal pure returns (buffer memory) {

    return writeUint8(buf, buf.buf.length, data);
  }

  function write(
    buffer memory buf,
    uint256 off,
    bytes32 data,
    uint256 len
  ) private pure returns (buffer memory) {

    if (len + off > buf.capacity) {
      resize(buf, (len + off) * 2);
    }

    unchecked {
      uint256 mask = (256**len) - 1;
      data = data >> (8 * (32 - len));
      assembly {
        let bufptr := mload(buf)
        let dest := add(add(bufptr, off), len)
        mstore(dest, or(and(mload(dest), not(mask)), data))
        if gt(add(off, len), mload(bufptr)) {
          mstore(bufptr, add(off, len))
        }
      }
    }
    return buf;
  }

  function writeBytes20(
    buffer memory buf,
    uint256 off,
    bytes20 data
  ) internal pure returns (buffer memory) {

    return write(buf, off, bytes32(data), 20);
  }

  function appendBytes20(buffer memory buf, bytes20 data) internal pure returns (buffer memory) {

    return write(buf, buf.buf.length, bytes32(data), 20);
  }

  function appendBytes32(buffer memory buf, bytes32 data) internal pure returns (buffer memory) {

    return write(buf, buf.buf.length, data, 32);
  }

  function writeInt(
    buffer memory buf,
    uint256 off,
    uint256 data,
    uint256 len
  ) private pure returns (buffer memory) {

    if (len + off > buf.capacity) {
      resize(buf, (len + off) * 2);
    }

    uint256 mask = (256**len) - 1;
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

  function appendInt(
    buffer memory buf,
    uint256 data,
    uint256 len
  ) internal pure returns (buffer memory) {

    return writeInt(buf, buf.buf.length, data, len);
  }
}




library CBORChainlink {

  using BufferChainlink for BufferChainlink.buffer;

  uint8 private constant MAJOR_TYPE_INT = 0;
  uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
  uint8 private constant MAJOR_TYPE_BYTES = 2;
  uint8 private constant MAJOR_TYPE_STRING = 3;
  uint8 private constant MAJOR_TYPE_ARRAY = 4;
  uint8 private constant MAJOR_TYPE_MAP = 5;
  uint8 private constant MAJOR_TYPE_TAG = 6;
  uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

  uint8 private constant TAG_TYPE_BIGNUM = 2;
  uint8 private constant TAG_TYPE_NEGATIVE_BIGNUM = 3;

  function encodeFixedNumeric(BufferChainlink.buffer memory buf, uint8 major, uint64 value) private pure {

    if(value <= 23) {
      buf.appendUint8(uint8((major << 5) | value));
    } else if (value <= 0xFF) {
      buf.appendUint8(uint8((major << 5) | 24));
      buf.appendInt(value, 1);
    } else if (value <= 0xFFFF) {
      buf.appendUint8(uint8((major << 5) | 25));
      buf.appendInt(value, 2);
    } else if (value <= 0xFFFFFFFF) {
      buf.appendUint8(uint8((major << 5) | 26));
      buf.appendInt(value, 4);
    } else {
      buf.appendUint8(uint8((major << 5) | 27));
      buf.appendInt(value, 8);
    }
  }

  function encodeIndefiniteLengthType(BufferChainlink.buffer memory buf, uint8 major) private pure {

    buf.appendUint8(uint8((major << 5) | 31));
  }

  function encodeUInt(BufferChainlink.buffer memory buf, uint value) internal pure {

    if(value > 0xFFFFFFFFFFFFFFFF) {
      encodeBigNum(buf, value);
    } else {
      encodeFixedNumeric(buf, MAJOR_TYPE_INT, uint64(value));
    }
  }

  function encodeInt(BufferChainlink.buffer memory buf, int value) internal pure {

    if(value < -0x10000000000000000) {
      encodeSignedBigNum(buf, value);
    } else if(value > 0xFFFFFFFFFFFFFFFF) {
      encodeBigNum(buf, uint(value));
    } else if(value >= 0) {
      encodeFixedNumeric(buf, MAJOR_TYPE_INT, uint64(uint256(value)));
    } else {
      encodeFixedNumeric(buf, MAJOR_TYPE_NEGATIVE_INT, uint64(uint256(-1 - value)));
    }
  }

  function encodeBytes(BufferChainlink.buffer memory buf, bytes memory value) internal pure {

    encodeFixedNumeric(buf, MAJOR_TYPE_BYTES, uint64(value.length));
    buf.append(value);
  }

  function encodeBigNum(BufferChainlink.buffer memory buf, uint value) internal pure {

    buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_BIGNUM));
    encodeBytes(buf, abi.encode(value));
  }

  function encodeSignedBigNum(BufferChainlink.buffer memory buf, int input) internal pure {

    buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_NEGATIVE_BIGNUM));
    encodeBytes(buf, abi.encode(uint256(-1 - input)));
  }

  function encodeString(BufferChainlink.buffer memory buf, string memory value) internal pure {

    encodeFixedNumeric(buf, MAJOR_TYPE_STRING, uint64(bytes(value).length));
    buf.append(bytes(value));
  }

  function startArray(BufferChainlink.buffer memory buf) internal pure {

    encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
  }

  function startMap(BufferChainlink.buffer memory buf) internal pure {

    encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
  }

  function endSequence(BufferChainlink.buffer memory buf) internal pure {

    encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
  }
}





library Chainlink {

  uint256 internal constant defaultBufferSize = 256; // solhint-disable-line const-name-snakecase

  using CBORChainlink for BufferChainlink.buffer;

  struct Request {
    bytes32 id;
    address callbackAddress;
    bytes4 callbackFunctionId;
    uint256 nonce;
    BufferChainlink.buffer buf;
  }

  function initialize(
    Request memory self,
    bytes32 jobId,
    address callbackAddr,
    bytes4 callbackFunc
  ) internal pure returns (Chainlink.Request memory) {

    BufferChainlink.init(self.buf, defaultBufferSize);
    self.id = jobId;
    self.callbackAddress = callbackAddr;
    self.callbackFunctionId = callbackFunc;
    return self;
  }

  function setBuffer(Request memory self, bytes memory data) internal pure {

    BufferChainlink.init(self.buf, data.length);
    BufferChainlink.append(self.buf, data);
  }

  function add(
    Request memory self,
    string memory key,
    string memory value
  ) internal pure {

    self.buf.encodeString(key);
    self.buf.encodeString(value);
  }

  function addBytes(
    Request memory self,
    string memory key,
    bytes memory value
  ) internal pure {

    self.buf.encodeString(key);
    self.buf.encodeBytes(value);
  }

  function addInt(
    Request memory self,
    string memory key,
    int256 value
  ) internal pure {

    self.buf.encodeString(key);
    self.buf.encodeInt(value);
  }

  function addUint(
    Request memory self,
    string memory key,
    uint256 value
  ) internal pure {

    self.buf.encodeString(key);
    self.buf.encodeUInt(value);
  }

  function addStringArray(
    Request memory self,
    string memory key,
    string[] memory values
  ) internal pure {

    self.buf.encodeString(key);
    self.buf.startArray();
    for (uint256 i = 0; i < values.length; i++) {
      self.buf.encodeString(values[i]);
    }
    self.buf.endSequence();
  }
}




interface ENSInterface {

  event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

  event Transfer(bytes32 indexed node, address owner);

  event NewResolver(bytes32 indexed node, address resolver);

  event NewTTL(bytes32 indexed node, uint64 ttl);

  function setSubnodeOwner(
    bytes32 node,
    bytes32 label,
    address owner
  ) external;


  function setResolver(bytes32 node, address resolver) external;


  function setOwner(bytes32 node, address owner) external;


  function setTTL(bytes32 node, uint64 ttl) external;


  function owner(bytes32 node) external view returns (address);


  function resolver(bytes32 node) external view returns (address);


  function ttl(bytes32 node) external view returns (uint64);

}




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


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);


  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool success);

}




interface ChainlinkRequestInterface {

  function oracleRequest(
    address sender,
    uint256 requestPrice,
    bytes32 serviceAgreementID,
    address callbackAddress,
    bytes4 callbackFunctionId,
    uint256 nonce,
    uint256 dataVersion,
    bytes calldata data
  ) external;


  function cancelOracleRequest(
    bytes32 requestId,
    uint256 payment,
    bytes4 callbackFunctionId,
    uint256 expiration
  ) external;

}




interface OracleInterface {

  function fulfillOracleRequest(
    bytes32 requestId,
    uint256 payment,
    address callbackAddress,
    bytes4 callbackFunctionId,
    uint256 expiration,
    bytes32 data
  ) external returns (bool);


  function isAuthorizedSender(address node) external view returns (bool);


  function withdraw(address recipient, uint256 amount) external;


  function withdrawable() external view returns (uint256);

}





interface OperatorInterface is OracleInterface, ChainlinkRequestInterface {

  function operatorRequest(
    address sender,
    uint256 payment,
    bytes32 specId,
    bytes4 callbackFunctionId,
    uint256 nonce,
    uint256 dataVersion,
    bytes calldata data
  ) external;


  function fulfillOracleRequest2(
    bytes32 requestId,
    uint256 payment,
    address callbackAddress,
    bytes4 callbackFunctionId,
    uint256 expiration,
    bytes calldata data
  ) external returns (bool);


  function ownerTransferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  ) external returns (bool success);


  function distributeFunds(address payable[] calldata receivers, uint256[] calldata amounts) external payable;


  function getAuthorizedSenders() external returns (address[] memory);


  function setAuthorizedSenders(address[] calldata senders) external;


  function getForwarder() external returns (address);

}




interface PointerInterface {

  function getAddress() external view returns (address);

}




abstract contract ENSResolver_Chainlink {
  function addr(bytes32 node) public view virtual returns (address);
}










abstract contract ChainlinkClient {
  using Chainlink for Chainlink.Request;

  uint256 internal constant LINK_DIVISIBILITY = 10**18;
  uint256 private constant AMOUNT_OVERRIDE = 0;
  address private constant SENDER_OVERRIDE = address(0);
  uint256 private constant ORACLE_ARGS_VERSION = 1;
  uint256 private constant OPERATOR_ARGS_VERSION = 2;
  bytes32 private constant ENS_TOKEN_SUBNAME = keccak256("link");
  bytes32 private constant ENS_ORACLE_SUBNAME = keccak256("oracle");
  address private constant LINK_TOKEN_POINTER = 0xC89bD4E1632D3A43CB03AAAd5262cbe4038Bc571;

  ENSInterface private s_ens;
  bytes32 private s_ensNode;
  LinkTokenInterface private s_link;
  OperatorInterface private s_oracle;
  uint256 private s_requestCount = 1;
  mapping(bytes32 => address) private s_pendingRequests;

  event ChainlinkRequested(bytes32 indexed id);
  event ChainlinkFulfilled(bytes32 indexed id);
  event ChainlinkCancelled(bytes32 indexed id);

  function buildChainlinkRequest(
    bytes32 specId,
    address callbackAddr,
    bytes4 callbackFunctionSignature
  ) internal pure returns (Chainlink.Request memory) {
    Chainlink.Request memory req;
    return req.initialize(specId, callbackAddr, callbackFunctionSignature);
  }

  function buildOperatorRequest(bytes32 specId, bytes4 callbackFunctionSignature)
    internal
    view
    returns (Chainlink.Request memory)
  {
    Chainlink.Request memory req;
    return req.initialize(specId, address(this), callbackFunctionSignature);
  }

  function sendChainlinkRequest(Chainlink.Request memory req, uint256 payment) internal returns (bytes32) {
    return sendChainlinkRequestTo(address(s_oracle), req, payment);
  }

  function sendChainlinkRequestTo(
    address oracleAddress,
    Chainlink.Request memory req,
    uint256 payment
  ) internal returns (bytes32 requestId) {
    uint256 nonce = s_requestCount;
    s_requestCount = nonce + 1;
    bytes memory encodedRequest = abi.encodeWithSelector(
      ChainlinkRequestInterface.oracleRequest.selector,
      SENDER_OVERRIDE, // Sender value - overridden by onTokenTransfer by the requesting contract's address
      AMOUNT_OVERRIDE, // Amount value - overridden by onTokenTransfer by the actual amount of LINK sent
      req.id,
      address(this),
      req.callbackFunctionId,
      nonce,
      ORACLE_ARGS_VERSION,
      req.buf.buf
    );
    return _rawRequest(oracleAddress, nonce, payment, encodedRequest);
  }

  function sendOperatorRequest(Chainlink.Request memory req, uint256 payment) internal returns (bytes32) {
    return sendOperatorRequestTo(address(s_oracle), req, payment);
  }

  function sendOperatorRequestTo(
    address oracleAddress,
    Chainlink.Request memory req,
    uint256 payment
  ) internal returns (bytes32 requestId) {
    uint256 nonce = s_requestCount;
    s_requestCount = nonce + 1;
    bytes memory encodedRequest = abi.encodeWithSelector(
      OperatorInterface.operatorRequest.selector,
      SENDER_OVERRIDE, // Sender value - overridden by onTokenTransfer by the requesting contract's address
      AMOUNT_OVERRIDE, // Amount value - overridden by onTokenTransfer by the actual amount of LINK sent
      req.id,
      req.callbackFunctionId,
      nonce,
      OPERATOR_ARGS_VERSION,
      req.buf.buf
    );
    return _rawRequest(oracleAddress, nonce, payment, encodedRequest);
  }

  function _rawRequest(
    address oracleAddress,
    uint256 nonce,
    uint256 payment,
    bytes memory encodedRequest
  ) private returns (bytes32 requestId) {
    requestId = keccak256(abi.encodePacked(this, nonce));
    s_pendingRequests[requestId] = oracleAddress;
    emit ChainlinkRequested(requestId);
    require(s_link.transferAndCall(oracleAddress, payment, encodedRequest), "unable to transferAndCall to oracle");
  }

  function cancelChainlinkRequest(
    bytes32 requestId,
    uint256 payment,
    bytes4 callbackFunc,
    uint256 expiration
  ) internal {
    OperatorInterface requested = OperatorInterface(s_pendingRequests[requestId]);
    delete s_pendingRequests[requestId];
    emit ChainlinkCancelled(requestId);
    requested.cancelOracleRequest(requestId, payment, callbackFunc, expiration);
  }

  function getNextRequestCount() internal view returns (uint256) {
    return s_requestCount;
  }

  function setChainlinkOracle(address oracleAddress) internal {
    s_oracle = OperatorInterface(oracleAddress);
  }

  function setChainlinkToken(address linkAddress) internal {
    s_link = LinkTokenInterface(linkAddress);
  }

  function setPublicChainlinkToken() internal {
    setChainlinkToken(PointerInterface(LINK_TOKEN_POINTER).getAddress());
  }

  function chainlinkTokenAddress() internal view returns (address) {
    return address(s_link);
  }

  function chainlinkOracleAddress() internal view returns (address) {
    return address(s_oracle);
  }

  function addChainlinkExternalRequest(address oracleAddress, bytes32 requestId) internal notPendingRequest(requestId) {
    s_pendingRequests[requestId] = oracleAddress;
  }

  function useChainlinkWithENS(address ensAddress, bytes32 node) internal {
    s_ens = ENSInterface(ensAddress);
    s_ensNode = node;
    bytes32 linkSubnode = keccak256(abi.encodePacked(s_ensNode, ENS_TOKEN_SUBNAME));
    ENSResolver_Chainlink resolver = ENSResolver_Chainlink(s_ens.resolver(linkSubnode));
    setChainlinkToken(resolver.addr(linkSubnode));
    updateChainlinkOracleWithENS();
  }

  function updateChainlinkOracleWithENS() internal {
    bytes32 oracleSubnode = keccak256(abi.encodePacked(s_ensNode, ENS_ORACLE_SUBNAME));
    ENSResolver_Chainlink resolver = ENSResolver_Chainlink(s_ens.resolver(oracleSubnode));
    setChainlinkOracle(resolver.addr(oracleSubnode));
  }

  function validateChainlinkCallback(bytes32 requestId)
    internal
    recordChainlinkFulfillment(requestId)
  {

  }

  modifier recordChainlinkFulfillment(bytes32 requestId) {
    require(msg.sender == s_pendingRequests[requestId], "Source must be the oracle of the request");
    delete s_pendingRequests[requestId];
    emit ChainlinkFulfilled(requestId);
    _;
  }

  modifier notPendingRequest(bytes32 requestId) {
    require(s_pendingRequests[requestId] == address(0), "Request is already pending");
    _;
  }
}





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





contract BokkyPooBahsDateTimeContract {

    uint public constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint public constant SECONDS_PER_HOUR = 60 * 60;
    uint public constant SECONDS_PER_MINUTE = 60;
    int public constant OFFSET19700101 = 2440588;

    uint public constant DOW_MON = 1;
    uint public constant DOW_TUE = 2;
    uint public constant DOW_WED = 3;
    uint public constant DOW_THU = 4;
    uint public constant DOW_FRI = 5;
    uint public constant DOW_SAT = 6;
    uint public constant DOW_SUN = 7;

    function _now() public view returns (uint timestamp) {

        timestamp = block.timestamp;
    }
    function _nowDateTime() public view returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {

        (year, month, day, hour, minute, second) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(block.timestamp);
    }
    function _daysFromDate(uint year, uint month, uint day) public pure returns (uint _days) {

        return BokkyPooBahsDateTimeLibrary._daysFromDate(year, month, day);
    }
    function _daysToDate(uint _days) public pure returns (uint year, uint month, uint day) {

        return BokkyPooBahsDateTimeLibrary._daysToDate(_days);
    }
    function timestampFromDate(uint year, uint month, uint day) public pure returns (uint timestamp) {

        return BokkyPooBahsDateTimeLibrary.timestampFromDate(year, month, day);
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (uint timestamp) {

        return BokkyPooBahsDateTimeLibrary.timestampFromDateTime(year, month, day, hour, minute, second);
    }
    function timestampToDate(uint timestamp) public pure returns (uint year, uint month, uint day) {

        (year, month, day) = BokkyPooBahsDateTimeLibrary.timestampToDate(timestamp);
    }
    function timestampToDateTime(uint timestamp) public pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {

        (year, month, day, hour, minute, second) = BokkyPooBahsDateTimeLibrary.timestampToDateTime(timestamp);
    }

    function isValidDate(uint year, uint month, uint day) public pure returns (bool valid) {

        valid = BokkyPooBahsDateTimeLibrary.isValidDate(year, month, day);
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) public pure returns (bool valid) {

        valid = BokkyPooBahsDateTimeLibrary.isValidDateTime(year, month, day, hour, minute, second);
    }
    function isLeapYear(uint timestamp) public pure returns (bool leapYear) {

        leapYear = BokkyPooBahsDateTimeLibrary.isLeapYear(timestamp);
    }
    function _isLeapYear(uint year) public pure returns (bool leapYear) {

        leapYear = BokkyPooBahsDateTimeLibrary._isLeapYear(year);
    }
    function isWeekDay(uint timestamp) public pure returns (bool weekDay) {

        weekDay = BokkyPooBahsDateTimeLibrary.isWeekDay(timestamp);
    }
    function isWeekEnd(uint timestamp) public pure returns (bool weekEnd) {

        weekEnd = BokkyPooBahsDateTimeLibrary.isWeekEnd(timestamp);
    }

    function getDaysInMonth(uint timestamp) public pure returns (uint daysInMonth) {

        daysInMonth = BokkyPooBahsDateTimeLibrary.getDaysInMonth(timestamp);
    }
    function _getDaysInMonth(uint year, uint month) public pure returns (uint daysInMonth) {

        daysInMonth = BokkyPooBahsDateTimeLibrary._getDaysInMonth(year, month);
    }
    function getDayOfWeek(uint timestamp) public pure returns (uint dayOfWeek) {

        dayOfWeek = BokkyPooBahsDateTimeLibrary.getDayOfWeek(timestamp);
    }

    function getYear(uint timestamp) public pure returns (uint year) {

        year = BokkyPooBahsDateTimeLibrary.getYear(timestamp);
    }
    function getMonth(uint timestamp) public pure returns (uint month) {

        month = BokkyPooBahsDateTimeLibrary.getMonth(timestamp);
    }
    function getDay(uint timestamp) public pure returns (uint day) {

        day = BokkyPooBahsDateTimeLibrary.getDay(timestamp);
    }
    function getHour(uint timestamp) public pure returns (uint hour) {

        hour = BokkyPooBahsDateTimeLibrary.getHour(timestamp);
    }
    function getMinute(uint timestamp) public pure returns (uint minute) {

        minute = BokkyPooBahsDateTimeLibrary.getMinute(timestamp);
    }
    function getSecond(uint timestamp) public pure returns (uint second) {

        second = BokkyPooBahsDateTimeLibrary.getSecond(timestamp);
    }

    function addYears(uint timestamp, uint _years) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.addYears(timestamp, _years);
    }
    function addMonths(uint timestamp, uint _months) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.addMonths(timestamp, _months);
    }
    function addDays(uint timestamp, uint _days) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.addDays(timestamp, _days);
    }
    function addHours(uint timestamp, uint _hours) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.addHours(timestamp, _hours);
    }
    function addMinutes(uint timestamp, uint _minutes) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.addMinutes(timestamp, _minutes);
    }
    function addSeconds(uint timestamp, uint _seconds) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.addSeconds(timestamp, _seconds);
    }

    function subYears(uint timestamp, uint _years) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.subYears(timestamp, _years);
    }
    function subMonths(uint timestamp, uint _months) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.subMonths(timestamp, _months);
    }
    function subDays(uint timestamp, uint _days) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.subDays(timestamp, _days);
    }
    function subHours(uint timestamp, uint _hours) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.subHours(timestamp, _hours);
    }
    function subMinutes(uint timestamp, uint _minutes) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.subMinutes(timestamp, _minutes);
    }
    function subSeconds(uint timestamp, uint _seconds) public pure returns (uint newTimestamp) {

        newTimestamp = BokkyPooBahsDateTimeLibrary.subSeconds(timestamp, _seconds);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) public pure returns (uint _years) {

        _years = BokkyPooBahsDateTimeLibrary.diffYears(fromTimestamp, toTimestamp);
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) public pure returns (uint _months) {

        _months = BokkyPooBahsDateTimeLibrary.diffMonths(fromTimestamp, toTimestamp);
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) public pure returns (uint _days) {

        _days = BokkyPooBahsDateTimeLibrary.diffDays(fromTimestamp, toTimestamp);
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) public pure returns (uint _hours) {

        _hours = BokkyPooBahsDateTimeLibrary.diffHours(fromTimestamp, toTimestamp);
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) public pure returns (uint _minutes) {

        _minutes = BokkyPooBahsDateTimeLibrary.diffMinutes(fromTimestamp, toTimestamp);
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) public pure returns (uint _seconds) {

        _seconds = BokkyPooBahsDateTimeLibrary.diffSeconds(fromTimestamp, toTimestamp);
    }
}




contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor (address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}




library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}














contract CPITrackerOracle is Owned, ChainlinkClient {

    using Chainlink for Chainlink.Request;
  
    BokkyPooBahsDateTimeContract public time_contract;
    address public timelock_address;
    address public bot_address;

    uint256 public cpi_last = 28012600000; // Dec 2021 CPI-U, 280.126 * 100000000
    uint256 public cpi_target = 28193300000; // Jan 2022 CPI-U, 281.933 * 100000000
    uint256 public peg_price_last = 1e18; // Use currPegPrice(). Will always be in Dec 2021 dollars
    uint256 public peg_price_target = 1006450668627688968; // Will always be in Dec 2021 dollars

    address public oracle; // Chainlink CPI oracle address
    bytes32 public jobId; // Job ID for the CPI-U date
    uint256 public fee; // LINK token fee

    uint256 public stored_year = 2022; // Last time (year) the stored CPI data was updated
    uint256 public stored_month = 1; // Last time (month) the stored CPI data was updated
    uint256 public lastUpdateTime = 1644886800; // Last time the stored CPI data was updated.
    uint256 public ramp_period = 28 * 86400; // Apply the CPI delta to the peg price over a set period
    uint256 public future_ramp_period = 28 * 86400;
    CPIObservation[] public cpi_observations; // Historical tracking of CPI data

    uint256 public max_delta_frac = 25000; // 2.5%. Max month-to-month CPI delta. 

    string[13] public month_names; // English names of the 12 months
    uint256 public fulfill_ready_day = 15; // Date of the month that CPI data is expected to by ready by


    
    struct CPIObservation {
        uint256 result_year;
        uint256 result_month;
        uint256 cpi_target;
        uint256 peg_price_target;
        uint256 timestamp;
    }


    modifier onlyByOwnGov() {

        require(msg.sender == owner || msg.sender == timelock_address, "Not owner or timelock");
        _;
    }

    modifier onlyByOwnGovBot() {

        require(msg.sender == owner || msg.sender == timelock_address || msg.sender == bot_address, "Not owner, tlck, or bot");
        _;
    }


    constructor (
        address _creator_address,
        address _timelock_address
    ) Owned(_creator_address) {
        timelock_address = _timelock_address;

        month_names = [
            '',
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
        ];

        setPublicChainlinkToken();
        time_contract = BokkyPooBahsDateTimeContract(0x90503D86E120B3B309CEBf00C2CA013aB3624736);
        oracle = 0x049Bd8C3adC3fE7d3Fc2a44541d955A537c2A484;
        jobId = "1c309d42c7084b34b1acf1a89e7b51fc";
        fee = 50e18; // 50 LINK



        cpi_observations.push(CPIObservation(
            2021,
            12,
            cpi_last,
            peg_price_last,
            1642208400 // Dec data observed on Jan 15 2021
        ));

        cpi_observations.push(CPIObservation(
            2022,
            1,
            cpi_target,
            peg_price_target,
            1644886800 // Jan data observed on Feb 15 2022
        ));
    }

    function upcomingCPIParams() public view returns (
        uint256 upcoming_year,
        uint256 upcoming_month, 
        uint256 upcoming_timestamp
    ) {

        if (stored_month == 12) {
            upcoming_year = stored_year + 1;
            upcoming_month = 1;
        }
        else {
            upcoming_year = stored_year;
            upcoming_month = stored_month + 1;
        }

        upcoming_timestamp = time_contract.timestampFromDate(upcoming_year, upcoming_month, fulfill_ready_day);
    }

    function upcomingSerie() external view returns (string memory serie_name) {

        (uint256 upcoming_year, uint256 upcoming_month, ) = upcomingCPIParams();

        return string(abi.encodePacked("CUSR0000SA0", " ", month_names[upcoming_month], " ", Strings.toString(upcoming_year)));
    }

    function currDeltaFracE6() public view returns (int256) {

        return int256(((peg_price_target - peg_price_last) * 1e6) / peg_price_last);
    }

    function currDeltaFracAbsE6() public view returns (uint256) {

        int256 curr_delta_frac = currDeltaFracE6();
        if (curr_delta_frac > 0) return uint256(curr_delta_frac);
        else return uint256(-curr_delta_frac);
    }

    function currPegPrice() external view returns (uint256) {

        uint256 elapsed_time = block.timestamp - lastUpdateTime;
        if (elapsed_time >= ramp_period) {
            return peg_price_target;
        }
        else {
            int256 fractional_price_delta = (int256(peg_price_target - peg_price_last) * int256(elapsed_time)) / int256(ramp_period);
            return uint256(int256(peg_price_last) + int256(fractional_price_delta));
        }
    }


    function requestCPIData() external onlyByOwnGovBot returns (bytes32 requestId) 
    {

        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        (uint256 upcoming_year, uint256 upcoming_month, uint256 upcoming_timestamp) = upcomingCPIParams();

        require(block.timestamp >= upcoming_timestamp, "Too early");

        request.add("serie", "CUSR0000SA0"); // CPI-U: https://data.bls.gov/timeseries/CUSR0000SA0
        request.add("month", month_names[upcoming_month]);
        request.add("year", Strings.toString(upcoming_year)); 
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function fulfill(bytes32 _requestId, uint256 result) public recordChainlinkFulfillment(_requestId)
    {

        cpi_last = cpi_target;
        peg_price_last = peg_price_target;

        cpi_target = result;
        peg_price_target = (peg_price_last * cpi_target) / cpi_last;

        require(currDeltaFracAbsE6() <= max_delta_frac, "Delta too high");

        lastUpdateTime = block.timestamp;

        (uint256 result_year, uint256 result_month, ) = upcomingCPIParams();
        stored_year = result_year;
        stored_month = result_month;

        ramp_period = future_ramp_period;

        cpi_observations.push(CPIObservation(
            result_year,
            result_month,
            cpi_target,
            peg_price_target,
            block.timestamp
        ));

        emit CPIUpdated(result_year, result_month, result, peg_price_target, ramp_period);
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunc,
        uint256 _expiration
    ) external onlyByOwnGovBot {

        cancelChainlinkRequest(_requestId, _payment, _callbackFunc, _expiration);
    }
    

    function setTimelock(address _new_timelock_address) external onlyByOwnGov {

        timelock_address = _new_timelock_address;
    }

    function setBot(address _new_bot_address) external onlyByOwnGov {

        bot_address = _new_bot_address;
    }

    function setOracleInfo(address _oracle, bytes32 _jobId, uint256 _fee) external onlyByOwnGov {

        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
    }

    function setMaxDeltaFrac(uint256 _max_delta_frac) external onlyByOwnGov {

        max_delta_frac = _max_delta_frac; 
    }

    function setFulfillReadyDay(uint256 _fulfill_ready_day) external onlyByOwnGov {

        fulfill_ready_day = _fulfill_ready_day; 
    }

    function setFutureRampPeriod(uint256 _future_ramp_period) external onlyByOwnGov {

        future_ramp_period = _future_ramp_period; // In sec
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyByOwnGov {

        TransferHelper.safeTransfer(tokenAddress, owner, tokenAmount);
    }

    
    event CPIUpdated(uint256 year, uint256 month, uint256 result, uint256 peg_price_target, uint256 ramp_period);
}