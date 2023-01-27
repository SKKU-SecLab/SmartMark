

pragma solidity ^0.5.0;

library Buffer_Chainlink {

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


pragma solidity ^0.5.0;


library CBOR_Chainlink {

  using Buffer_Chainlink for Buffer_Chainlink.buffer;

  uint8 private constant MAJOR_TYPE_INT = 0;
  uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
  uint8 private constant MAJOR_TYPE_BYTES = 2;
  uint8 private constant MAJOR_TYPE_STRING = 3;
  uint8 private constant MAJOR_TYPE_ARRAY = 4;
  uint8 private constant MAJOR_TYPE_MAP = 5;
  uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

  function encodeType(Buffer_Chainlink.buffer memory buf, uint8 major, uint value) private pure {

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

  function encodeIndefiniteLengthType(Buffer_Chainlink.buffer memory buf, uint8 major) private pure {

    buf.appendUint8(uint8((major << 5) | 31));
  }

  function encodeUInt(Buffer_Chainlink.buffer memory buf, uint value) internal pure {

    encodeType(buf, MAJOR_TYPE_INT, value);
  }

  function encodeInt(Buffer_Chainlink.buffer memory buf, int value) internal pure {

    if(value >= 0) {
      encodeType(buf, MAJOR_TYPE_INT, uint(value));
    } else {
      encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - value));
    }
  }

  function encodeBytes(Buffer_Chainlink.buffer memory buf, bytes memory value) internal pure {

    encodeType(buf, MAJOR_TYPE_BYTES, value.length);
    buf.append(value);
  }

  function encodeString(Buffer_Chainlink.buffer memory buf, string memory value) internal pure {

    encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);
    buf.append(bytes(value));
  }

  function startArray(Buffer_Chainlink.buffer memory buf) internal pure {

    encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
  }

  function startMap(Buffer_Chainlink.buffer memory buf) internal pure {

    encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
  }

  function endSequence(Buffer_Chainlink.buffer memory buf) internal pure {

    encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
  }
}


pragma solidity ^0.5.0;



library Chainlink {

  uint256 internal constant defaultBufferSize = 256; // solhint-disable-line const-name-snakecase

  using CBOR_Chainlink for Buffer_Chainlink.buffer;

  struct Request {
    bytes32 id;
    address callbackAddress;
    bytes4 callbackFunctionId;
    uint256 nonce;
    Buffer_Chainlink.buffer buf;
  }

  function initialize(
    Request memory self,
    bytes32 _id,
    address _callbackAddress,
    bytes4 _callbackFunction
  ) internal pure returns (Chainlink.Request memory) {

    Buffer_Chainlink.init(self.buf, defaultBufferSize);
    self.id = _id;
    self.callbackAddress = _callbackAddress;
    self.callbackFunctionId = _callbackFunction;
    return self;
  }

  function setBuffer(Request memory self, bytes memory _data)
    internal pure
  {

    Buffer_Chainlink.init(self.buf, _data.length);
    Buffer_Chainlink.append(self.buf, _data);
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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

interface PointerInterface {

  function getAddress() external view returns (address);

}


pragma solidity ^0.5.0;

contract ENSResolver_Chainlink {

  function addr(bytes32 node) public view returns (address);

}


pragma solidity ^0.5.0;

library SafeMath_Chainlink {

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


pragma solidity ^0.5.0;








contract ChainlinkClient {

  using Chainlink for Chainlink.Request;
  using SafeMath_Chainlink for uint256;

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
    ENSResolver_Chainlink resolver = ENSResolver_Chainlink(ens.resolver(linkSubnode));
    setChainlinkToken(resolver.addr(linkSubnode));
    updateChainlinkOracleWithENS();
  }

  function updateChainlinkOracleWithENS()
    internal
  {

    bytes32 oracleSubnode = keccak256(abi.encodePacked(ensNode, ENS_ORACLE_SUBNAME));
    ENSResolver_Chainlink resolver = ENSResolver_Chainlink(ens.resolver(oracleSubnode));
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


pragma solidity ^0.5.0;

interface OracleInterface {

  function fulfillOracleRequest(
    bytes32 requestId,
    uint256 payment,
    address callbackAddress,
    bytes4 callbackFunctionId,
    uint256 expiration,
    bytes32 data
  ) external returns (bool);

  function getAuthorizationStatus(address node) external view returns (bool);

  function setFulfillmentPermission(address node, bool allowed) external;

  function withdraw(address recipient, uint256 amount) external;

  function withdrawable() external view returns (uint256);

}


pragma solidity ^0.5.0;


library strings {

    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {

        for(; len >= 32; len -= 32) {
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
    }

    function toSlice(string memory self) internal pure returns (slice memory) {

        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    function concat(slice memory self, slice memory other) internal pure returns (string memory) {

        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }
}


pragma solidity ^0.5.0;

library BytesLib {

    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
        internal
        pure
        returns (bytes memory)
    {

        bytes memory tempBytes;
        assembly {
            tempBytes := mload(0x40)
            let length := mload(_preBytes)
            mstore(tempBytes, length)
            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)
            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))
            mc := end
            end := add(mc, length)
            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }
            mstore(0x40, and(
              add(add(end, iszero(add(length, mload(_preBytes)))), 31),
              not(31) // Round down to the nearest 32 bytes.
            ))
        }
        return tempBytes;
    }
    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {

        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                    _preBytes_slot,
                    add(
                        fslot,
                        add(
                            mul(
                                div(
                                    mload(add(_postBytes, 0x20)),
                                    exp(0x100, sub(32, mlength))
                                ),
                                exp(0x100, sub(32, newlength))
                            ),
                            mul(mlength, 2)
                        )
                    )
                )
            }
            case 1 {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))
                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)
                sstore(
                    sc,
                    add(
                        and(
                            fslot,
                            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                        ),
                        and(mload(mc), mask)
                    )
                )
                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }
                mask := exp(0x100, sub(mc, end))
                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                mstore(0x0, _preBytes_slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))
                sstore(_preBytes_slot, add(mul(newlength, 2), 1))
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)
                sstore(sc, add(sload(sc), and(mload(mc), mask)))
                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }
                mask := exp(0x100, sub(mc, end))
                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }
    function slice(
        bytes memory _bytes,
        uint _start,
        uint _length
    )
        internal
        pure
        returns (bytes memory)
    {

        require(_bytes.length >= (_start + _length));
        bytes memory tempBytes;
        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)
                let lengthmod := and(_length, 31)
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)
                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }
                mstore(tempBytes, _length)
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)
                mstore(0x40, add(tempBytes, 0x20))
            }
        }
        return tempBytes;
    }
    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20));
        address tempAddress;
        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }
        return tempAddress;
    }
    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1));
        uint8 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }
        return tempUint;
    }
    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        require(_bytes.length >= (_start + 2));
        uint16 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }
        return tempUint;
    }
    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        require(_bytes.length >= (_start + 4));
        uint32 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }
        return tempUint;
    }
    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {

        require(_bytes.length >= (_start + 8));
        uint64 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }
        return tempUint;
    }
    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {

        require(_bytes.length >= (_start + 12));
        uint96 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }
        return tempUint;
    }
    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {

        require(_bytes.length >= (_start + 16));
        uint128 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }
        return tempUint;
    }
    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32));
        uint256 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }
    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));
        bytes32 tempBytes32;
        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }
        return tempBytes32;
    }
    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {

        bool success = true;
        assembly {
            let length := mload(_preBytes)
            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1
                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)
                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }
        return success;
    }
    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
        internal
        view
        returns (bool)
    {

        bool success = true;
        assembly {
            let fslot := sload(_preBytes_slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)
                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1
                        mstore(0x0, _preBytes_slot)
                        let sc := keccak256(0x0, 0x20)
                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }
        return success;
    }
}


pragma solidity ^0.5.0;
contract DualOracleOwnerInterface {

    
    function owner1() public view returns (address);

    
    function owner2() public view returns (address);

    
    function oracle() public view returns (address);

    
    function withdraw(address _recipient, uint256 _amount) external;

    
    function withdrawable() external view returns (uint256);

    
    function setFulfillmentPermission(address _node, bool _allowed) external;

    
    function changeOwner1(address owner1) public;

    
    function changeOwner2(address owner2) public;

    
    function transferOwnership(address newOwner) public;

}


pragma solidity ^0.5.0;

contract GamePoolInterface {

    function initialize(address tokenAdr,
                        address carAdr,
                        address factory) public;

                        
    function BZNclaimed(uint256 tokenId) public returns (bool);

    
    function _preorderFill() public;

    
    function migrate(address newToken) public;

    
    function setGameBalance(address _gameBalance) public;

    
    function setLimitAndStart(uint256 amount) public;

    
    function dailyLimit() public view returns (uint256);

    
    function rewardPlayer(address player, uint256 amount) public;

}


pragma solidity ^0.5.0;

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public payable returns (bool);

}


pragma solidity ^0.5.0;

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


pragma solidity ^0.5.0;


contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


pragma solidity ^0.5.0;


contract BurnableToken is ERC20 {

  event Burn(address indexed burner, uint256 value);
  function burn(uint256 _value) public;

}


pragma solidity ^0.5.0;


contract StandardBurnableToken is BurnableToken {

  function burnFrom(address _from, uint256 _value) public;

}


pragma solidity >=0.4.24 <0.7.0;


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
}


pragma solidity ^0.5.0;


contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;



contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function initialize(address sender) public initializer {

        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;












contract GameBalance is Initializable, ChainlinkClient, ApproveAndCallFallBack, Ownable {

    using strings for *;
    using BytesLib for bytes;

    event depositEvent(address from, string username, uint256 bznAmount, uint256 ethAmount);
    event withdrawEvent(address linked, string username, uint256 bznAmount, uint256 ethAmount);

    string public constant usernameJobId = "3736cccf3f444c12a78583fe4bb8f7dd";
    string private constant usernameApiURL = "https://us-central1-war-riders-account-system.cloudfunctions.net/app/usertoaddress/";

    DualOracleOwnerInterface private oracleProxy;
    LinkTokenInterface private linkToken;
    GamePoolInterface public gamePool;

    uint256 public gasRequirement;
    bool public isPaused;
    address payable internal gasUser;

    mapping(bytes32 => uint256) public bznHoldings;
    mapping(bytes32 => uint256) public ethHoldings;
    mapping(bytes32 => string) public hashToUser;

    struct WithdrawlRequest {
        string username;
        bytes32 userhash;
        uint256 bzn;
        uint256 eth;
    }

    mapping(bytes32 => WithdrawlRequest) pendingRequests;

    StandardBurnableToken internal bzn;

    uint256 internal withdrawableEth;
    uint256 public depositBZNLimit;
    uint256 public depositETHLimit;
    uint256 public withdrawlBZNLimit;
    uint256 public withdrawlETHLimit;
    uint256 public linkRequirement;
    string internal chJobId;

    modifier notPaused {

        require(!isPaused);
        _;
    }

    modifier onlyOracleNode {

        OracleInterface _oracle = OracleInterface(chainlinkOracleAddress());

        require(_oracle.getAuthorizationStatus(msg.sender));
        _;
    }

    function initialize(address _link, address _gamepool, address _oracle, address _bzn, address owner) public initializer {

        Ownable.initialize(owner);
        
        if (_link == address(0)) {
            setPublicChainlinkToken();
        } else {
            setChainlinkToken(_link);
        }

        linkToken = LinkTokenInterface(chainlinkTokenAddress());
        oracleProxy = DualOracleOwnerInterface(_oracle);

        setChainlinkOracle(oracleProxy.oracle());

        gamePool = GamePoolInterface(_gamepool);

        bzn = StandardBurnableToken(_bzn);
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {

        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
          return 0x0;
        }

        assembly { // solhint-disable-line no-inline-assembly
          result := mload(add(source, 32))
        }
    }

    function _lower(bytes1 _b1)
        private
        pure
        returns (bytes1) {

        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }
        return _b1;
    }

    function lower(string memory _base)
        internal
        pure
        returns (string memory) {

        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    function stringToUint(string memory s) public pure returns (uint result) {

        bytes memory b = bytes(s);
        uint i;
        result = 0;
        for (i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            } else {
                revert();
            }
        }
    }

    function withdraw(uint256 amount) public onlyOwner {

        uint256 trueAmount = amountWithdrawable();

        require(amount <= trueAmount);

        withdrawableEth -= amount;

        address payable _owner = address(uint160(owner()));

        _owner.transfer(amount);
    }

    function setGasRequirement(uint256 gas) public onlyOwner {

        gasRequirement = gas;
    }

    function setGasUser(address payable user) public onlyOwner {

        gasUser = user;
    }

    function amountWithdrawable() public view returns (uint256) {

        return withdrawableEth - 500000000000000;
    }

    function setPause(bool state) public onlyOwner {

        isPaused = state;
    }

    function setLimits(uint256 bznDeposit, uint256 bznWithdraw, uint256 ethDeposit, uint256 ethWithdraw) public onlyOwner {

        depositETHLimit = ethDeposit;
        depositBZNLimit = bznDeposit;
        withdrawlETHLimit = ethWithdraw;
        withdrawlBZNLimit = bznWithdraw;
    }

    function usernameAsHash(string memory username) public pure returns (bytes32) {

        string memory correctedUsername = lower(username);

        bytes32 userhash = keccak256(abi.encode(correctedUsername));

        return userhash;
    }

    function singleWithdraw(bytes32 userhash, uint256 bznSpent,
                            uint256 bznMined, uint256 bznWithdraw,
                            uint256 ethSpent, uint256 ethWithdraw) external onlyOracleNode notPaused returns (bool) {

        if (bznMined > 0) {
            bznHoldings[userhash] += bznMined;
        }

        if (bznSpent > 0) {
            require(bznSpent <= bznHoldings[userhash], "Oversepnt BZN");

            bznHoldings[userhash] -= bznSpent;
        }

        require(ethWithdraw <= withdrawlETHLimit, "Over withdrew ETH over limit");
        require(bznWithdraw <= withdrawlBZNLimit, "Over withdrew BZN over limit");
        require(bznWithdraw <= bznHoldings[userhash], "Over withdrew BZN");
        require(ethSpent + ethWithdraw + gasRequirement <= ethHoldings[userhash], "Over spent ETH or not enough gas");

        ethHoldings[userhash] -= ethSpent + gasRequirement;

        if (bznWithdraw > 0 || ethWithdraw > 0) {
            string memory username = hashToUser[userhash];

            Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(chJobId), address(this), this.fulfillUsername.selector);

            string memory url = usernameApiURL.toSlice().concat(username.toSlice());

            req.add("get", url);
            req.add("path", "message");

            if (linkToken.balanceOf(address(this)) < linkRequirement) {
                oracleProxy.withdraw(address(this), linkRequirement);
            }

            bytes32 requestId = sendChainlinkRequest(req, linkRequirement);

            pendingRequests[requestId] = WithdrawlRequest(username, userhash, bznWithdraw, ethWithdraw);
        }

        if (bznMined > 0) {
            gamePool.rewardPlayer(address(this), bznMined);
        }

        if (bznSpent > 0) {
            uint256 bznBurned = (bznSpent * 30) / 100;
            bzn.burn(bznBurned);
            uint256 leftOverBZN = bznSpent - bznBurned;

            bzn.transfer(address(gamePool), leftOverBZN);
        }

        gasUser.transfer(gasRequirement);

        withdrawableEth += ethSpent;
    }

    function batchWithdraw(bytes calldata data) onlyOracleNode notPaused external returns (bool) {

        uint256 index = 0;
        uint256 totalEthSpent = 0;

        uint256 totalBznSpent = 0;
        uint256 totalBZNMined = 0;
        uint256 collectedGas = 0;

        while (index < data.length) {
            bytes memory section = data.slice(index, 192);
            index += 192;

            bytes32 userhash;
            uint256 bznSpent;
            uint256 bznMined;
            uint256 bznWithdraw;
            uint256 ethSpent;
            uint256 ethWithdraw;

            (userhash, bznSpent, bznMined, bznWithdraw, ethSpent, ethWithdraw) = abi.decode(section, (bytes32,uint256,uint256,uint256,uint256,uint256));

            if (bznMined > 0) {
                totalBZNMined += bznMined;
                bznHoldings[userhash] += bznMined;
            }

            if (bznSpent > 0) {
                require(bznSpent <= bznHoldings[userhash]);

                totalBznSpent += bznSpent;
                bznHoldings[userhash] -= bznSpent;
            }

            require(ethWithdraw <= withdrawlETHLimit);
            require(bznWithdraw <= withdrawlBZNLimit);
            require(bznWithdraw <= bznHoldings[userhash]);
            require(ethSpent + ethWithdraw + gasRequirement <= ethHoldings[userhash]);

            totalEthSpent += ethSpent;
            collectedGas += gasRequirement;
            ethHoldings[userhash] -= ethSpent + gasRequirement;

            if (bznWithdraw > 0 || ethWithdraw > 0) {
                string memory username = hashToUser[userhash];

                Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(chJobId), address(this), this.fulfillUsername.selector);

                string memory url = usernameApiURL.toSlice().concat(username.toSlice());

                req.add("get", url);
                req.add("path", "message");

                if (linkToken.balanceOf(address(this)) < linkRequirement) {
                    oracleProxy.withdraw(address(this), linkRequirement);
                }

                bytes32 requestId = sendChainlinkRequest(req, linkRequirement);

                pendingRequests[requestId] = WithdrawlRequest(username, userhash, bznWithdraw, ethWithdraw);
            }
        }

        if (totalBZNMined > 0) {
            gamePool.rewardPlayer(address(this), totalBZNMined);
        }

        if (totalBznSpent > 0) {
            uint256 bznBurned = (totalBznSpent * 30) / 100;
            bzn.burn(bznBurned);
            totalBznSpent -= bznBurned;

            bzn.transfer(address(gamePool), totalBznSpent);
        }

        gasUser.transfer(collectedGas);

        withdrawableEth += totalEthSpent;
    }

    function fulfillUsername(bytes32 _requestId, uint256 _address) public recordChainlinkFulfillment(_requestId) {

        address payable linkedAddress = address(uint160(_address));

        WithdrawlRequest memory req = pendingRequests[_requestId];

        if (req.bzn > 0) {
            bznHoldings[req.userhash] -= req.bzn;
            bzn.transfer(linkedAddress, req.bzn);
        }

        if (req.eth > 0) {
            ethHoldings[req.userhash] -= req.eth;
            linkedAddress.transfer(req.eth);
        }

        emit withdrawEvent(linkedAddress, req.username, req.bzn, req.eth);

        delete pendingRequests[_requestId];
    }

    function deposit(address from, uint256 amount, string memory username) internal {

        bytes32 userhash = usernameAsHash(username);

        bzn.transferFrom(from, address(this), amount);

        bznHoldings[userhash] += amount;
        ethHoldings[userhash] += msg.value;
        hashToUser[userhash] = username;

        require(amount <= depositBZNLimit);
        require(msg.value <= depositETHLimit);

        emit depositEvent(from, username, amount, msg.value);
    }

    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) notPaused public payable returns (bool) {

        string memory username;

        (username) = abi.decode(data, (string));

        deposit(from, tokens, username);

        return true;
    }

    function setLinkPayment(uint256 payment) public onlyOwner {

        linkRequirement = payment;
    }

    function changeJobId(string memory jobId) public onlyOwner {

        chJobId = jobId;
    }

    function updateOracleProxy(address new_oracle) public onlyOwner {

        oracleProxy = DualOracleOwnerInterface(new_oracle);

        setChainlinkOracle(oracleProxy.oracle());
    }
}