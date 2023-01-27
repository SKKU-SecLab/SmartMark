

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

interface PointerInterface {

  function getAddress() external view returns (address);

}


pragma solidity ^0.6.0;

abstract contract ENSResolver {
  function addr(bytes32 node) public view virtual returns (address);
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


pragma solidity ^0.6.0;

abstract contract LinkTokenReceiver {

  bytes4 constant private ORACLE_REQUEST_SELECTOR = 0x40429946;
  uint256 constant private SELECTOR_LENGTH = 4;
  uint256 constant private EXPECTED_REQUEST_WORDS = 2;
  uint256 constant private MINIMUM_REQUEST_LENGTH = SELECTOR_LENGTH + (32 * EXPECTED_REQUEST_WORDS);
  function onTokenTransfer(
    address _sender,
    uint256 _amount,
    bytes memory _data
  )
    public
    onlyLINK
    validRequestLength(_data)
    permittedFunctionsForLINK(_data)
  {
    assembly {
      mstore(add(_data, 36), _sender) // ensure correct sender is passed
      mstore(add(_data, 68), _amount)    // ensure correct amount is passed
    }
    (bool success, ) = address(this).delegatecall(_data); // calls oracleRequest
    require(success, "Unable to create request");
  }

  function getChainlinkToken() public view virtual returns (address);

  modifier onlyLINK() {
    require(msg.sender == getChainlinkToken(), "Must use LINK token");
    _;
  }

  modifier permittedFunctionsForLINK(bytes memory _data) {
    bytes4 funcSelector;
    assembly {
      funcSelector := mload(add(_data, 32))
    }
    require(funcSelector == ORACLE_REQUEST_SELECTOR, "Must use whitelisted functions");
    _;
  }

  modifier validRequestLength(bytes memory _data) {
    require(_data.length >= MINIMUM_REQUEST_LENGTH, "Invalid request length");
    _;
  }
}


pragma solidity ^0.6.0;

library SignedSafeMath {

  int256 constant private _INT256_MIN = -2**255;

  function mul(int256 a, int256 b) internal pure returns (int256) {

    if (a == 0) {
      return 0;
    }

    require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

    int256 c = a * b;
    require(c / a == b, "SignedSafeMath: multiplication overflow");

    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {

    require(b != 0, "SignedSafeMath: division by zero");
    require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

    int256 c = a / b;

    return c;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {

    int256 c = a - b;
    require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

    return c;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {

    int256 c = a + b;
    require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

    return c;
  }

  function avg(int256 _a, int256 _b)
    internal
    pure
    returns (int256)
  {

    if ((_a < 0 && _b > 0) || (_a > 0 && _b < 0)) {
      return add(_a, _b) / 2;
    }
    int256 remainder = (_a % 2 + _b % 2) / 2;
    return add(add(_a / 2, _b / 2), remainder);
  }
}


pragma solidity ^0.6.0;



library Median {

  using SignedSafeMath for int256;

  int256 constant INT_MAX = 2**255-1;

  function calculate(int256[] memory list)
    internal
    pure
    returns (int256)
  {

    return calculateInplace(copy(list));
  }

  function calculateInplace(int256[] memory list)
    internal
    pure
    returns (int256)
  {

    require(0 < list.length, "list must not be empty");
    uint256 len = list.length;
    uint256 middleIndex = len / 2;
    if (len % 2 == 0) {
      int256 median1;
      int256 median2;
      (median1, median2) = quickselectTwo(list, 0, len - 1, middleIndex - 1, middleIndex);
      return SignedSafeMath.avg(median1, median2);
    } else {
      return quickselect(list, 0, len - 1, middleIndex);
    }
  }

  uint256 constant SHORTSELECTTWO_MAX_LENGTH = 7;

  function shortSelectTwo(
    int256[] memory list,
    uint256 lo,
    uint256 hi,
    uint256 k1,
    uint256 k2
  )
    private
    pure
    returns (int256 k1th, int256 k2th)
  {


    uint256 len = hi + 1 - lo;
    int256 x0 = list[lo + 0];
    int256 x1 = 1 < len ? list[lo + 1] : INT_MAX;
    int256 x2 = 2 < len ? list[lo + 2] : INT_MAX;
    int256 x3 = 3 < len ? list[lo + 3] : INT_MAX;
    int256 x4 = 4 < len ? list[lo + 4] : INT_MAX;
    int256 x5 = 5 < len ? list[lo + 5] : INT_MAX;
    int256 x6 = 6 < len ? list[lo + 6] : INT_MAX;

    if (x0 > x1) {(x0, x1) = (x1, x0);}
    if (x2 > x3) {(x2, x3) = (x3, x2);}
    if (x4 > x5) {(x4, x5) = (x5, x4);}
    if (x0 > x2) {(x0, x2) = (x2, x0);}
    if (x1 > x3) {(x1, x3) = (x3, x1);}
    if (x4 > x6) {(x4, x6) = (x6, x4);}
    if (x1 > x2) {(x1, x2) = (x2, x1);}
    if (x5 > x6) {(x5, x6) = (x6, x5);}
    if (x0 > x4) {(x0, x4) = (x4, x0);}
    if (x1 > x5) {(x1, x5) = (x5, x1);}
    if (x2 > x6) {(x2, x6) = (x6, x2);}
    if (x1 > x4) {(x1, x4) = (x4, x1);}
    if (x3 > x6) {(x3, x6) = (x6, x3);}
    if (x2 > x4) {(x2, x4) = (x4, x2);}
    if (x3 > x5) {(x3, x5) = (x5, x3);}
    if (x3 > x4) {(x3, x4) = (x4, x3);}

    uint256 index1 = k1 - lo;
    if (index1 == 0) {k1th = x0;}
    else if (index1 == 1) {k1th = x1;}
    else if (index1 == 2) {k1th = x2;}
    else if (index1 == 3) {k1th = x3;}
    else if (index1 == 4) {k1th = x4;}
    else if (index1 == 5) {k1th = x5;}
    else if (index1 == 6) {k1th = x6;}
    else {revert("k1 out of bounds");}

    uint256 index2 = k2 - lo;
    if (k1 == k2) {return (k1th, k1th);}
    else if (index2 == 0) {return (k1th, x0);}
    else if (index2 == 1) {return (k1th, x1);}
    else if (index2 == 2) {return (k1th, x2);}
    else if (index2 == 3) {return (k1th, x3);}
    else if (index2 == 4) {return (k1th, x4);}
    else if (index2 == 5) {return (k1th, x5);}
    else if (index2 == 6) {return (k1th, x6);}
    else {revert("k2 out of bounds");}
  }

  function quickselect(int256[] memory list, uint256 lo, uint256 hi, uint256 k)
    private
    pure
    returns (int256 kth)
  {

    require(lo <= k);
    require(k <= hi);
    while (lo < hi) {
      if (hi - lo < SHORTSELECTTWO_MAX_LENGTH) {
        int256 ignore;
        (kth, ignore) = shortSelectTwo(list, lo, hi, k, k);
        return kth;
      }
      uint256 pivotIndex = partition(list, lo, hi);
      if (k <= pivotIndex) {
        hi = pivotIndex;
      } else {
        lo = pivotIndex + 1;
      }
    }
    return list[lo];
  }

  function quickselectTwo(
    int256[] memory list,
    uint256 lo,
    uint256 hi,
    uint256 k1,
    uint256 k2
  )
    internal // for testing
    pure
    returns (int256 k1th, int256 k2th)
  {

    require(k1 < k2);
    require(lo <= k1 && k1 <= hi);
    require(lo <= k2 && k2 <= hi);

    while (true) {
      if (hi - lo < SHORTSELECTTWO_MAX_LENGTH) {
        return shortSelectTwo(list, lo, hi, k1, k2);
      }
      uint256 pivotIdx = partition(list, lo, hi);
      if (k2 <= pivotIdx) {
        hi = pivotIdx;
      } else if (pivotIdx < k1) {
        lo = pivotIdx + 1;
      } else {
        assert(k1 <= pivotIdx && pivotIdx < k2);
        k1th = quickselect(list, lo, pivotIdx, k1);
        k2th = quickselect(list, pivotIdx + 1, hi, k2);
        return (k1th, k2th);
      }
    }
  }

  function partition(int256[] memory list, uint256 lo, uint256 hi)
    private
    pure
    returns (uint256)
  {

    int256 pivot = list[(lo + hi) / 2];
    lo -= 1; // this can underflow. that's intentional.
    hi += 1;
    while (true) {
      do {
        lo += 1;
      } while (list[lo] < pivot);
      do {
        hi -= 1;
      } while (list[hi] > pivot);
      if (lo < hi) {
        (list[lo], list[hi]) = (list[hi], list[lo]);
      } else {
        return hi;
      }
    }
  }

  function copy(int256[] memory list)
    private
    pure
    returns(int256[] memory)
  {

    int256[] memory list2 = new int256[](list.length);
    for (uint256 i = 0; i < list.length; i++) {
      list2[i] = list[i];
    }
    return list2;
  }
}


pragma solidity ^0.6.0;

contract Owned {


  address payable public owner;
  address private pendingOwner;

  event OwnershipTransferRequested(
    address indexed from,
    address indexed to
  );
  event OwnershipTransferred(
    address indexed from,
    address indexed to
  );

  constructor() public {
    owner = msg.sender;
  }

  function transferOwnership(address _to)
    external
    onlyOwner()
  {

    pendingOwner = _to;

    emit OwnershipTransferRequested(owner, _to);
  }

  function acceptOwnership()
    external
  {

    require(msg.sender == pendingOwner, "Must be proposed owner");

    address oldOwner = owner;
    owner = msg.sender;
    pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "Only callable by owner");
    _;
  }

}


pragma solidity ^0.6.0;

interface AccessControllerInterface {

  function hasAccess(address user, bytes calldata data) external view returns (bool);

}


pragma solidity ^0.6.0;



contract SimpleWriteAccessController is AccessControllerInterface, Owned {


  bool public checkEnabled;
  mapping(address => bool) internal accessList;

  event AddedAccess(address user);
  event RemovedAccess(address user);
  event CheckAccessEnabled();
  event CheckAccessDisabled();

  constructor()
    public
  {
    checkEnabled = true;
  }

  function hasAccess(
    address _user,
    bytes memory
  )
    public
    view
    virtual
    override
    returns (bool)
  {

    return accessList[_user] || !checkEnabled;
  }

  function addAccess(address _user)
    external
    onlyOwner()
  {

    if (!accessList[_user]) {
      accessList[_user] = true;

      emit AddedAccess(_user);
    }
  }

  function removeAccess(address _user)
    external
    onlyOwner()
  {

    if (accessList[_user]) {
      accessList[_user] = false;

      emit RemovedAccess(_user);
    }
  }

  function enableAccessCheck()
    external
    onlyOwner()
  {

    if (!checkEnabled) {
      checkEnabled = true;

      emit CheckAccessEnabled();
    }
  }

  function disableAccessCheck()
    external
    onlyOwner()
  {

    if (checkEnabled) {
      checkEnabled = false;

      emit CheckAccessDisabled();
    }
  }

  modifier checkAccess() {

    require(hasAccess(msg.sender, msg.data), "No access");
    _;
  }
}


pragma solidity 0.6.6;






contract PreCoordinator is
  ChainlinkClient,
  LinkTokenReceiver,
  SimpleWriteAccessController,
  ChainlinkRequestInterface
{

  using SafeMath for uint256;

  uint256 constant private MAX_ORACLE_COUNT = 45;

  uint256 private globalNonce;

  struct ServiceAgreement {
    uint256 totalPayment;
    uint256 minResponses;
    address[] oracles;
    bytes32[] jobIds;
    uint256[] payments;
  }

  struct Requester {
    bytes4 callbackFunctionId;
    address sender;
    address callbackAddress;
    int256[] responses;
  }

  mapping(bytes32 => ServiceAgreement) internal serviceAgreements;
  mapping(bytes32 => bytes32) internal serviceAgreementRequests;
  mapping(bytes32 => Requester) internal requesters;
  mapping(bytes32 => bytes32) internal requests;

  event NewServiceAgreement(bytes32 indexed saId, uint256 payment, uint256 minresponses);
  event ServiceAgreementRequested(bytes32 indexed saId, bytes32 indexed requestId, uint256 payment);
  event ServiceAgreementResponseReceived(bytes32 indexed saId, bytes32 indexed requestId, address indexed oracle, int256 answer);
  event ServiceAgreementAnswerUpdated(bytes32 indexed saId, bytes32 indexed requestId, int256 answer);
  event ServiceAgreementDeleted(bytes32 indexed saId);

  constructor(address _link) public {
    if(_link == address(0)) {
      setPublicChainlinkToken();
    } else {
      setChainlinkToken(_link);
    }
  }

  function createServiceAgreement(
    uint256 _minResponses,
    address[] calldata _oracles,
    bytes32[] calldata _jobIds,
    uint256[] calldata _payments
  )
    external returns (bytes32 saId)
  {

    require(_minResponses > 0, "Min responses must be > 0");
    require(_oracles.length == _jobIds.length && _oracles.length == _payments.length, "Unmet length");
    require(_oracles.length <= MAX_ORACLE_COUNT, "Cannot have more than 45 oracles");
    require(_oracles.length >= _minResponses, "Invalid min responses");
    uint256 totalPayment;
    for (uint i = 0; i < _payments.length; i++) {
      totalPayment = totalPayment.add(_payments[i]);
    }
    saId = keccak256(abi.encodePacked(globalNonce, now));
    globalNonce++; // yes, let it overflow
    serviceAgreements[saId] = ServiceAgreement(totalPayment, _minResponses, _oracles, _jobIds, _payments);

    emit NewServiceAgreement(saId, totalPayment, _minResponses);
  }

  function getServiceAgreement(bytes32 _saId)
    external view returns
  (
    uint256 totalPayment,
    uint256 minResponses,
    address[] memory oracles,
    bytes32[] memory jobIds,
    uint256[] memory payments
  )
  {

    return
    (
      serviceAgreements[_saId].totalPayment,
      serviceAgreements[_saId].minResponses,
      serviceAgreements[_saId].oracles,
      serviceAgreements[_saId].jobIds,
      serviceAgreements[_saId].payments
    );
  }

  function getChainlinkToken() public view override returns (address) {

    return chainlinkTokenAddress();
  }

  function oracleRequest(
    address _sender,
    uint256 _payment,
    bytes32 _saId,
    address _callbackAddress,
    bytes4 _callbackFunctionId,
    uint256 _nonce,
    uint256,
    bytes calldata _data
  )
    external
    onlyLINK
    override
    checkCallbackAddress(_callbackAddress)
  {

    require(hasAccess(_sender, _data));

    uint256 totalPayment = serviceAgreements[_saId].totalPayment;
    require(_payment >= totalPayment, "Insufficient payment");
    bytes32 callbackRequestId = keccak256(abi.encodePacked(_sender, _nonce));
    require(requesters[callbackRequestId].sender == address(0), "Nonce already in-use");
    requesters[callbackRequestId].callbackFunctionId = _callbackFunctionId;
    requesters[callbackRequestId].callbackAddress = _callbackAddress;
    requesters[callbackRequestId].sender = _sender;
    createRequests(_saId, callbackRequestId, _data);
    if (_payment > totalPayment) {
      uint256 overage = _payment.sub(totalPayment);
      LinkTokenInterface _link = LinkTokenInterface(chainlinkTokenAddress());
      assert(_link.transfer(_sender, overage));
    }
  }

  function createRequests(bytes32 _saId, bytes32 _incomingRequestId, bytes memory _data) private {

    ServiceAgreement memory sa = serviceAgreements[_saId];
    require(sa.minResponses > 0, "Invalid service agreement");
    Chainlink.Request memory request;
    bytes32 outgoingRequestId;
    emit ServiceAgreementRequested(_saId, _incomingRequestId, sa.totalPayment);
    for (uint i = 0; i < sa.oracles.length; i++) {
      request = buildChainlinkRequest(sa.jobIds[i], address(this), this.chainlinkCallback.selector);
      request.setBuffer(_data);
      outgoingRequestId = sendChainlinkRequestTo(sa.oracles[i], request, sa.payments[i]);
      requests[outgoingRequestId] = _incomingRequestId;
      serviceAgreementRequests[outgoingRequestId] = _saId;
    }
  }

  function chainlinkCallback(bytes32 _requestId, int256 _data)
    external
    recordChainlinkFulfillment(_requestId)
    returns (bool)
  {

    ServiceAgreement memory sa = serviceAgreements[serviceAgreementRequests[_requestId]];
    bytes32 cbRequestId = requests[_requestId];
    bytes32 saId = serviceAgreementRequests[_requestId];
    delete requests[_requestId];
    delete serviceAgreementRequests[_requestId];
    emit ServiceAgreementResponseReceived(saId, cbRequestId, msg.sender, _data);
    requesters[cbRequestId].responses.push(_data);
    Requester memory req = requesters[cbRequestId];
    if (req.responses.length == sa.oracles.length) delete requesters[cbRequestId];
    bool success = true;
    if (req.responses.length == sa.minResponses) {
      int256 result = Median.calculate(req.responses);
      emit ServiceAgreementAnswerUpdated(saId, cbRequestId, result);
      (success, ) = req.callbackAddress.call(abi.encodeWithSelector(req.callbackFunctionId, cbRequestId, result));
    }
    return success;
  }

  function withdrawLink() external onlyOwner {

    LinkTokenInterface _link = LinkTokenInterface(chainlinkTokenAddress());
    require(_link.transfer(msg.sender, _link.balanceOf(address(this))), "Unable to transfer");
  }

  function cancelOracleRequest(
    bytes32 _requestId,
    uint256 _payment,
    bytes4 _callbackFunctionId,
    uint256 _expiration
  )
    external
    override
  {

    bytes32 cbRequestId = requests[_requestId];
    delete requests[_requestId];
    delete serviceAgreementRequests[_requestId];
    Requester memory req = requesters[cbRequestId];
    require(req.sender == msg.sender, "Only requester can cancel");
    delete requesters[cbRequestId];
    cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
    LinkTokenInterface _link = LinkTokenInterface(chainlinkTokenAddress());
    require(_link.transfer(req.sender, _payment), "Unable to transfer");
  }

  modifier checkCallbackAddress(address _to) {

    require(_to != chainlinkTokenAddress(), "Cannot callback to LINK");
    _;
  }
}