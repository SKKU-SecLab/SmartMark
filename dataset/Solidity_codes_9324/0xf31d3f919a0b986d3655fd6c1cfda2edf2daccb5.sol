

pragma solidity ^0.5.0;

contract Context {

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

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
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
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.0;

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
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

interface IOffChainAssetValuatorV2 {



    event AssetsValueUpdated(uint newAssetsValue);
    event AssetTypeSet(uint tokenId, string assetType, bool isAdded);


    function initialize(
        address owner,
        address guardian,
        address linkToken,
        uint oraclePayment,
        uint offChainAssetsValue,
        bytes32 offChainAssetsValueJobId
    ) external;


    function addSupportedAssetTypeByTokenId(
        uint tokenId,
        string calldata assetType
    ) external;


    function removeSupportedAssetTypeByTokenId(
        uint tokenId,
        string calldata assetType
    ) external;


    function setCollateralValueJobId(
        bytes32 jobId
    ) external;


    function setOraclePayment(
        uint oraclePayment
    ) external;


    function submitGetOffChainAssetsValueRequest(
        address oracle
    ) external;


    function fulfillGetOffChainAssetsValueRequest(
        bytes32 requestId,
        uint offChainAssetsValue
    ) external;



    function oraclePayment() external view returns (uint);


    function lastUpdatedTimestamp() external view returns (uint);


    function lastUpdatedBlockNumber() external view returns (uint);


    function offChainAssetsValueJobId() external view returns (bytes32);


    function getOffChainAssetsValue() external view returns (uint);


    function getOffChainAssetsValueByTokenId(
        uint tokenId
    ) external view returns (uint);


    function isSupportedAssetTypeByAssetIntroducer(
        uint tokenId,
        string calldata assetType
    ) external view returns (bool);


    function getAllAssetTypes() external view returns (string[] memory);


}




pragma solidity ^0.5.0;




contract AtmLike is Ownable {


    using SafeERC20 for IERC20;

    function deposit(address token, uint amount) public onlyOwner {

        IERC20(token).safeTransferFrom(_msgSender(), address(this), amount);
    }

    function withdraw(address token, address recipient, uint amount) public onlyOwner {

        IERC20(token).safeTransfer(recipient, amount);
    }

}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;


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

  function allowance(address owner, address spender) external returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external returns (uint256 balance);

  function decimals() external returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external returns (string memory tokenName);

  function symbol() external returns (string memory tokenSymbol);

  function totalSupply() external returns (uint256 totalTokensIssued);

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

contract ENSResolver {

  function addr(bytes32 node) public view returns (address);

}


pragma solidity ^0.5.0;



pragma solidity ^0.5.0;








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


pragma solidity ^0.5.0;








contract UpgradeableChainlinkClient {

    using Chainlink for Chainlink.Request;
    using SafeMath for uint256;

    uint256 constant internal LINK = 10 ** 18;
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


contract IOwnableOrGuardian is Initializable {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event GuardianTransferred(address indexed previousGuardian, address indexed newGuardian);

    modifier onlyOwnerOrGuardian {

        require(
            msg.sender == _owner || msg.sender == _guardian,
            "OwnableOrGuardian: UNAUTHORIZED_OWNER_OR_GUARDIAN"
        );
        _;
    }

    modifier onlyOwner {

        require(
            msg.sender == _owner,
            "OwnableOrGuardian: UNAUTHORIZED"
        );
        _;
    }

    address internal _owner;
    address internal _guardian;


    function owner() external view returns (address) {

        return _owner;
    }

    function guardian() external view returns (address) {

        return _guardian;
    }


    function initialize(
        address owner,
        address guardian
    ) public initializer {

        _transferOwnership(owner);
        _transferGuardian(guardian);
    }

    function transferOwnership(
        address owner
    )
    public
    onlyOwner {

        require(
            owner != address(0),
            "OwnableOrGuardian::transferOwnership: INVALID_OWNER"
        );
        _transferOwnership(owner);
    }

    function renounceOwnership() public onlyOwner {

        _transferOwnership(address(0));
    }

    function transferGuardian(
        address guardian
    )
    public
    onlyOwner {

        require(
            guardian != address(0),
            "OwnableOrGuardian::transferGuardian: INVALID_OWNER"
        );
        _transferGuardian(guardian);
    }

    function renounceGuardian() public onlyOwnerOrGuardian {

        _transferGuardian(address(0));
    }


    function _transferOwnership(
        address owner
    )
    internal {

        address previousOwner = _owner;
        _owner = owner;
        emit OwnershipTransferred(previousOwner, owner);
    }

    function _transferGuardian(
        address guardian
    )
    internal {

        address previousGuardian = _guardian;
        _guardian = guardian;
        emit GuardianTransferred(previousGuardian, guardian);
    }

}




pragma solidity ^0.5.0;


contract OwnableOrGuardian is IOwnableOrGuardian {


    constructor(
        address owner,
        address guardian
    ) public {
        IOwnableOrGuardian.initialize(owner, guardian);
    }

}




pragma solidity ^0.5.0;





contract OffChainAssetValuatorData is IOwnableOrGuardian, UpgradeableChainlinkClient  {


    using SafeERC20 for IERC20;


    uint internal _oraclePayment;

    bytes32 internal _offChainAssetsValueJobId;

    uint internal _offChainAssetsValue;

    uint internal _lastUpdatedTimestamp;

    uint internal _lastUpdatedBlockNumber;

    bytes32[] internal _allAssetTypes;

    mapping(bytes32 => uint) internal _assetTypeToNumberOfUsesMap;

    mapping(uint => mapping(bytes32 => bool)) internal _assetIntroducerToAssetTypeToIsSupportedMap;


    function deposit(address token, uint amount) public onlyOwnerOrGuardian {

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(address token, address recipient, uint amount) public onlyOwnerOrGuardian {

        IERC20(token).safeTransfer(recipient, amount);
    }

}




pragma solidity ^0.5.0;








contract OffChainAssetValuatorImplV2 is IOffChainAssetValuatorV2, OffChainAssetValuatorData {



    function initialize(
        address owner,
        address guardian,
        address linkToken,
        uint oraclePayment,
        uint offChainAssetsValue,
        bytes32 offChainAssetsValueJobId
    )
    external
    initializer {

        IOwnableOrGuardian.initialize(owner, guardian);

        setChainlinkToken(linkToken);
        _oraclePayment = oraclePayment;
        _offChainAssetsValueJobId = offChainAssetsValueJobId;
        _offChainAssetsValue = offChainAssetsValue;
        _lastUpdatedTimestamp = block.timestamp;
        _lastUpdatedBlockNumber = block.number;
    }

    function addSupportedAssetTypeByTokenId(
        uint tokenId,
        string calldata assetType
    )
    external
    onlyOwnerOrGuardian {

        bytes32 bytesAssetType = _sanitizeAndConvertAssetTypeToBytes(assetType);

        require(
            !_assetIntroducerToAssetTypeToIsSupportedMap[tokenId][bytesAssetType],
            "OffChainAssetValuatorImplV2::addSupportedAssetTypeByTokenId: ALREADY_SUPPORTED"
        );

        uint numberOfUses = _assetTypeToNumberOfUsesMap[bytesAssetType];
        if (numberOfUses == 0) {
            _allAssetTypes.push(bytesAssetType);
        }

        _assetTypeToNumberOfUsesMap[bytesAssetType] = numberOfUses.add(1);
        _assetIntroducerToAssetTypeToIsSupportedMap[tokenId][bytesAssetType] = true;

        emit AssetTypeSet(tokenId, assetType, true);
    }

    function removeSupportedAssetTypeByTokenId(
        uint tokenId,
        string calldata assetType
    )
    onlyOwnerOrGuardian
    external {

        bytes32 bytesAssetType = _sanitizeAndConvertAssetTypeToBytes(assetType);

        require(
            _assetIntroducerToAssetTypeToIsSupportedMap[tokenId][bytesAssetType],
            "OffChainAssetValuatorImplV2::addSupportedAssetTypeByTokenId: NOT_SUPPORTED"
        );

        uint numberOfUses = _assetTypeToNumberOfUsesMap[bytesAssetType];
        if (numberOfUses == 1) {
            bytes32[] memory allAssetTypes = _allAssetTypes;
            for (uint i = 0; i < allAssetTypes.length; i++) {
                if (allAssetTypes[i] == bytesAssetType) {
                    delete _allAssetTypes[i];
                    break;
                }
            }
        }

        _assetTypeToNumberOfUsesMap[bytesAssetType] = numberOfUses.sub(1);
        _assetIntroducerToAssetTypeToIsSupportedMap[tokenId][bytesAssetType] = false;

        emit AssetTypeSet(tokenId, assetType, false);
    }

    function setCollateralValueJobId(
        bytes32 offChainAssetsValueJobId
    )
    public
    onlyOwnerOrGuardian {

        _offChainAssetsValueJobId = offChainAssetsValueJobId;
    }

    function setOraclePayment(
        uint oraclePayment
    )
    public
    onlyOwnerOrGuardian {

        _oraclePayment = oraclePayment;
    }

    function submitGetOffChainAssetsValueRequest(
        address oracle
    )
    public
    onlyOwnerOrGuardian {

        Chainlink.Request memory request = buildChainlinkRequest(
            _offChainAssetsValueJobId,
            address(this),
            this.fulfillGetOffChainAssetsValueRequest.selector
        );
        request.add("action", "sumActive");
        request.addInt("times", 1 ether);
        sendChainlinkRequestTo(oracle, request, _oraclePayment);
    }

    function fulfillGetOffChainAssetsValueRequest(
        bytes32 requestId,
        uint offChainAssetsValue
    )
    public
    recordChainlinkFulfillment(requestId) {

        _offChainAssetsValue = offChainAssetsValue;
        _lastUpdatedTimestamp = block.timestamp;
        _lastUpdatedBlockNumber = block.number;

        emit AssetsValueUpdated(offChainAssetsValue);
    }


    function oraclePayment() external view returns (uint) {

        return _oraclePayment;
    }

    function lastUpdatedTimestamp() external view returns (uint) {

        return _lastUpdatedTimestamp;
    }

    function lastUpdatedBlockNumber() external view returns (uint) {

        return _lastUpdatedBlockNumber;
    }

    function offChainAssetsValueJobId() external view returns (bytes32) {

        return _offChainAssetsValueJobId;
    }

    function getOffChainAssetsValue() external view returns (uint) {

        return _offChainAssetsValue;
    }

    function getOffChainAssetsValueByTokenId(
        uint tokenId
    ) external view returns (uint) {

        if (tokenId == 0) {
            return _offChainAssetsValue;
        } else {
            revert("OffChainAssetValuatorImplV2::getOffChainAssetsValueByTokenId NOT_IMPLEMENTED");
        }
    }

    function isSupportedAssetTypeByAssetIntroducer(
        uint tokenId,
        string calldata assetType
    ) external view returns (bool) {

        bytes32 bytesAssetType = _sanitizeAndConvertAssetTypeToBytes(assetType);
        return _assetIntroducerToAssetTypeToIsSupportedMap[0][bytesAssetType] || _assetIntroducerToAssetTypeToIsSupportedMap[tokenId][bytesAssetType];
    }

    function getAllAssetTypes() external view returns (string[] memory) {

        bytes32[] memory allAssetTypes = _allAssetTypes;
        string[] memory result = new string[](allAssetTypes.length);
        for (uint i = 0; i < allAssetTypes.length; i++) {
            result[i] = string(abi.encodePacked(allAssetTypes[i]));
        }
        return result;
    }


    function _sanitizeAndConvertAssetTypeToBytes(
        string memory assetType
    ) internal pure returns (bytes32 bytesAssetType) {

        require(
            bytes(assetType).length <= 32,
            "OffChainAssetValuatorImplV2::_sanitizeAndConvertAssetTypeString: INVALID_LENGTH"
        );

        assembly {
            bytesAssetType := mload(add(assetType, 32))
        }
    }

}