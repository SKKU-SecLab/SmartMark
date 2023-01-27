pragma solidity ^0.8.0;

interface LinkTokenInterface {


  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );


  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );


  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );


  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );


  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;


  function name()
    external
    view
    returns (
      string memory tokenName
    );


  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );


  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );


  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );


  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


}// MIT
pragma solidity ^0.8.0;

contract VRFRequestIDBase {


  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {

    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}// MIT
pragma solidity ^0.8.0;



abstract contract VRFConsumerBase is VRFRequestIDBase {

  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
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
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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
}// GPL-3.0
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;


abstract contract PermitControl is Ownable {
  using SafeMath for uint256;
  using Address for address;

  bytes32 public constant ZERO_RIGHT = hex"00000000000000000000000000000000";

  bytes32 public constant UNIVERSAL = hex"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

  bytes32 public constant MANAGER = hex"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

  mapping (address => mapping (bytes32 => mapping (bytes32 => uint256))) public
    permissions;

  mapping (bytes32 => bytes32) public managerRight;

  event PermitUpdated(address indexed updator, address indexed updatee,
    bytes32 circumstance, bytes32 indexed role, uint256 expirationTime);

  event ManagementUpdated(address indexed manager, bytes32 indexed managedRight,
    bytes32 indexed managerRight);

  modifier hasValidPermit(bytes32 _circumstance, bytes32 _right) {
    require(_msgSender() == owner()
      || hasRightUntil(_msgSender(), _circumstance, _right) > block.timestamp,
      "PermitControl: sender does not have a valid permit");
    _;
  }

  function version() external virtual pure returns (uint256) {
    return 1;
  }

  function hasRightUntil(address _address, bytes32 _circumstance,
    bytes32 _right) public view returns (uint256) {
    return permissions[_address][_circumstance][_right];
  }

  function setPermit(address _address, bytes32 _circumstance, bytes32 _right,
    uint256 _expirationTime) external virtual hasValidPermit(UNIVERSAL,
    managerRight[_right]) {
    require(_right != ZERO_RIGHT,
      "PermitControl: you may not grant the zero right");
    permissions[_address][_circumstance][_right] = _expirationTime;
    emit PermitUpdated(_msgSender(), _address, _circumstance, _right,
      _expirationTime);
  }

  function setManagerRight(bytes32 _managedRight, bytes32 _managerRight)
    external virtual hasValidPermit(UNIVERSAL, MANAGER) {
    require(_managedRight != ZERO_RIGHT,
      "PermitControl: you may not specify a manager for the zero right");
    managerRight[_managedRight] = _managerRight;
    emit ManagementUpdated(_msgSender(), _managedRight, _managerRight);
  }
}// GPL-3.0
pragma solidity ^0.8.0;



contract Named is PermitControl {


  string public name;

  bytes32 public constant UPDATE_NAME = keccak256("UPDATE_NAME");

  event NameUpdated(address indexed updater, string indexed oldName,
    string indexed newName);

  constructor(string memory _name) public {
    name = _name;
    emit NameUpdated(_msgSender(), "", _name);
  }

  function version() external virtual override pure returns (uint256) {

    return 1;
  }

  function setName(string calldata _name) external virtual
    hasValidPermit(UNIVERSAL, UPDATE_NAME) {

    string memory oldName = name;
    name = _name;
    emit NameUpdated(_msgSender(), oldName, _name);
  }
}// GPL-3.0
pragma solidity ^0.8.0;



contract Sweepable is PermitControl {

  using SafeERC20 for IERC20;

  bytes32 public constant SWEEP = keccak256("SWEEP");

  bytes32 public constant LOCK_SWEEP = keccak256("LOCK_SWEEP");

  bool public sweepLocked;

  event TokenSweep(address indexed sweeper, IERC20 indexed token,
    uint256 amount, address indexed recipient);

  event SweepLocked(address indexed locker);

  function version() external virtual override pure returns (uint256) {

    return 1;
  }

  function sweep(IERC20 _token, uint256 _amount, address _address) external
    hasValidPermit(UNIVERSAL, SWEEP) {

    require(!sweepLocked,
      "MintShop1155: the sweep function is locked");
    _token.safeTransferFrom(address(this), _address, _amount);
    emit TokenSweep(_msgSender(), _token, _amount, _address);
  }

  function lockSweep() external hasValidPermit(UNIVERSAL, LOCK_SWEEP) {

    sweepLocked = true;
    emit SweepLocked(_msgSender());
  }
}// GPL-3.0
pragma solidity ^0.8.0;



contract Random is Named, Sweepable, VRFConsumerBase {

  using SafeERC20 for IERC20;
  using SafeMath for uint256;

  bytes32 public constant SET_CHAINLINK = keccak256("SET_CHAINLINK");

  struct Chainlink {
    address coordinator;
    address link;
    bytes32 keyHash;
    uint256 fee;
  }

  Chainlink public chainlink;

  struct ChainlinkResponse {
    address requester;
    bytes32 requestId;
    bool pending;
    uint256 result;
  }

  mapping (bytes32 => ChainlinkResponse) public chainlinkResponses;

  mapping (bytes32 => bytes32) public callerIds;

  mapping (address => uint256) public callerRequestCounts;

  mapping (address => mapping (uint256 => ChainlinkResponse))
    public callerRequests;

  event ChainlinkUpdated(address indexed updater,
    Chainlink indexed oldChainlink, Chainlink indexed newChainlink);

  event RequestCreated(address indexed requester, bytes32 indexed id,
    bytes32 indexed chainlinkRequestId);

  event RequestFulfilled(bytes32 indexed chainlinkRequestId,
    uint256 indexed result);

  constructor(address _owner, string memory _name,
    Chainlink memory _chainlink) public Named(_name)
    VRFConsumerBase(_chainlink.coordinator, _chainlink.link) {

    if (_owner != owner()) {
      transferOwnership(_owner);
    }

    chainlink = _chainlink;
  }

  function version() external virtual override(Named, Sweepable) pure returns
    (uint256) {

    return 1;
  }

  function setChainlink(Chainlink calldata _chainlink) external
    hasValidPermit(UNIVERSAL, SET_CHAINLINK) {

    Chainlink memory oldChainlink = chainlink;
    chainlink = _chainlink;
    emit ChainlinkUpdated(_msgSender(), oldChainlink, _chainlink);
  }

  function random(bytes32 _id) external returns (bytes32) {

    require(chainlinkResponses[_id].requester == address(0),
      "Random: randomness has already been generated for the specified ID");

    IERC20 link = IERC20(chainlink.link);
    require(link.balanceOf(_msgSender()) >= chainlink.fee,
      "Random: you do not have enough LINK to request randomness");
    link.safeTransferFrom(_msgSender(), address(this), chainlink.fee);

    bytes32 chainlinkRequestId = requestRandomness(chainlink.keyHash,
      chainlink.fee);

    ChainlinkResponse memory chainlinkResponse = ChainlinkResponse({
      requester: _msgSender(),
      requestId: chainlinkRequestId,
      pending: true,
      result: 0
    });
    chainlinkResponses[_id] = chainlinkResponse;
    callerIds[chainlinkRequestId] = _id;
    uint256 responseIndex = callerRequestCounts[_msgSender()];
    callerRequests[_msgSender()][responseIndex] = chainlinkResponse;
    callerRequestCounts[_msgSender()] = responseIndex + 1;

    emit RequestCreated(_msgSender(), _id, chainlinkRequestId);
    return chainlinkRequestId;
  }

  function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal
    override {

    bytes32 callerId = callerIds[_requestId];
    chainlinkResponses[callerId].pending = false;
    chainlinkResponses[callerId].result = _randomness;
    emit RequestFulfilled(_requestId, _randomness);
  }

  function asRange(bytes32 _source, uint256 _origin, uint256 _bound) external
    view returns (uint256) {

    require (_bound > _origin,
      "Random: there must be at least one possible value in range");
    require(chainlinkResponses[_source].requester != address(0)
      && !chainlinkResponses[_source].pending,
      "Random: you may only interpret the results of a fulfilled request");

    return chainlinkResponses[_source].result
      .mod(_bound.sub(_origin)).add(_origin);
  }
}