
pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
pragma solidity ^0.8.0;

interface AggregatorInterface {

  function latestAnswer()
    external
    view
    returns (
      int256
    );

  
  function latestTimestamp()
    external
    view
    returns (
      uint256
    );


  function latestRound()
    external
    view
    returns (
      uint256
    );


  function getAnswer(
    uint256 roundId
  )
    external
    view
    returns (
      int256
    );


  function getTimestamp(
    uint256 roundId
  )
    external
    view
    returns (
      uint256
    );


  event AnswerUpdated(
    int256 indexed current,
    uint256 indexed roundId,
    uint256 updatedAt
  );

  event NewRound(
    uint256 indexed roundId,
    address indexed startedBy,
    uint256 startedAt
  );
}// MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {


  function decimals()
    external
    view
    returns (
      uint8
    );


  function description()
    external
    view
    returns (
      string memory
    );


  function version()
    external
    view
    returns (
      uint256
    );


  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}// MIT
pragma solidity ^0.8.0;


interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{

}// MIT
pragma solidity ^0.8.0;
pragma abicoder v2;


interface FeedRegistryInterface {

  struct Phase {
    uint16 phaseId;
    uint80 startingAggregatorRoundId;
    uint80 endingAggregatorRoundId;
  }

  event FeedProposed(
    address indexed asset,
    address indexed denomination,
    address indexed proposedAggregator,
    address currentAggregator,
    address sender
  );
  event FeedConfirmed(
    address indexed asset,
    address indexed denomination,
    address indexed latestAggregator,
    address previousAggregator,
    uint16 nextPhaseId,
    address sender
  );


  function decimals(
    address base,
    address quote
  )
    external
    view
    returns (
      uint8
    );


  function description(
    address base,
    address quote
  )
    external
    view
    returns (
      string memory
    );


  function version(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256
    );


  function latestRoundData(
    address base,
    address quote
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function getRoundData(
    address base,
    address quote,
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );



  function latestAnswer(
    address base,
    address quote
  )
    external
    view
    returns (
      int256 answer
    );


  function latestTimestamp(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256 timestamp
    );


  function latestRound(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256 roundId
    );


  function getAnswer(
    address base,
    address quote,
    uint256 roundId
  )
    external
    view
    returns (
      int256 answer
    );


  function getTimestamp(
    address base,
    address quote,
    uint256 roundId
  )
    external
    view
    returns (
      uint256 timestamp
    );



  function getFeed(
    address base,
    address quote
  )
    external
    view
    returns (
      AggregatorV2V3Interface aggregator
    );


  function getPhaseFeed(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      AggregatorV2V3Interface aggregator
    );


  function isFeedEnabled(
    address aggregator
  )
    external
    view
    returns (
      bool
    );


  function getPhase(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      Phase memory phase
    );



  function getRoundFeed(
    address base,
    address quote,
    uint80 roundId
  )
    external
    view
    returns (
      AggregatorV2V3Interface aggregator
    );


  function getPhaseRange(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      uint80 startingRoundId,
      uint80 endingRoundId
    );


  function getPreviousRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external
    view
    returns (
      uint80 previousRoundId
    );


  function getNextRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external
    view
    returns (
      uint80 nextRoundId
    );



  function proposeFeed(
    address base,
    address quote,
    address aggregator
  ) external;


  function confirmFeed(
    address base,
    address quote,
    address aggregator
  ) external;



  function getProposedFeed(
    address base,
    address quote
  )
    external
    view
    returns (
      AggregatorV2V3Interface proposedAggregator
    );


  function proposedGetRoundData(
    address base,
    address quote,
    uint80 roundId
  )
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function proposedLatestRoundData(
    address base,
    address quote
  )
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function getCurrentPhaseId(
    address base,
    address quote
  )
    external
    view
    returns (
      uint16 currentPhaseId
    );

}// MIT

pragma solidity ^0.8.0;

library Denominations {

  address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  address public constant BTC = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;

  address public constant USD = address(840);
  address public constant GBP = address(826);
  address public constant EUR = address(978);
  address public constant JPY = address(392);
  address public constant KRW = address(410);
  address public constant CNY = address(156);
  address public constant AUD = address(36);
  address public constant CAD = address(124);
  address public constant CHF = address(756);
  address public constant ARS = address(32);
  address public constant PHP = address(608);
  address public constant NZD = address(554);
  address public constant SGD = address(702);
  address public constant NGN = address(566);
  address public constant ZAR = address(710);
  address public constant RUB = address(643);
  address public constant INR = address(356);
  address public constant BRL = address(986);
}//MIT
pragma solidity 0.8.9;

interface IPaymentStreamFactory {

  event StreamCreated(
    uint256 id,
    address indexed stream,
    address indexed payer,
    address indexed payee,
    uint256 usdAmount
  );

  event CustomFeedMappingUpdated(
    address indexed token,
    address indexed tokenDenomination
  );

  event FeedRegistryUpdated(
    address indexed previousFeedRegistry,
    address indexed newFeedRegistry
  );

  function updateFeedRegistry(address newAddress) external;


  function usdToTokenAmount(address _token, uint256 _amount)
    external
    view
    returns (uint256);


  function ours(address _a) external view returns (bool);


  function getStreamsCount() external view returns (uint256);


  function getStream(uint256 _idx) external view returns (address);

}// MIT

pragma solidity ^0.8.0;

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant alphabet = "0123456789abcdef";

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
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping (address => bool) members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId
            || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if(!hasRole(role, account)) {
            revert(string(abi.encodePacked(
                "AccessControl: account ",
                Strings.toHexString(uint160(account), 20),
                " is missing role ",
                Strings.toHexString(uint256(role), 32)
            )));
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}//MIT
pragma solidity 0.8.9;

interface IPaymentStream {

  event Claimed(uint256 usdAmount, uint256 tokenAmount);
  event StreamPaused();
  event StreamUnpaused();
  event StreamUpdated(uint256 usdAmount, uint256 endTime);

  event FundingAddressUpdated(
    address indexed previousFundingAddress,
    address indexed newFundingAddress
  );
  event PayeeUpdated(address indexed previousPayee, address indexed newPayee);

  function claim() external;


  function pauseStream() external;


  function unpauseStream() external;


  function delegatePausable(address delegate) external;


  function revokePausable(address delegate) external;


  function updateFundingRate(uint256 usdAmount, uint256 endTime) external;


  function updateFundingAddress(address newFundingAddress) external;


  function updatePayee(address newPayee) external;


  function claimableToken() external view returns (uint256);


  function claimable() external view returns (uint256);

}//MIT
pragma solidity 0.8.9;


interface IPaymentStreamFactoryMetadata is IPaymentStreamFactory {

  function NAME() external view returns (string memory);


  function VERSION() external view returns (string memory);

}//MIT
pragma solidity 0.8.9;


contract PaymentStream is AccessControl, IPaymentStream {

  using SafeERC20 for IERC20;

  string public VERSION;
  string public constant NAME = "PaymentStream";

  address public immutable payer;
  address public immutable token;

  address public payee;
  address public fundingAddress;

  uint256 public usdAmount;
  uint256 public startTime;
  uint256 public secs;
  uint256 public usdPerSec;
  uint256 public claimed;

  bool public paused;

  IPaymentStreamFactoryMetadata public immutable factory;

  bytes32 private constant ADMIN_ROLE = keccak256(abi.encodePacked("admin"));
  bytes32 private constant PAUSABLE_ROLE =
    keccak256(abi.encodePacked("pausable"));

  modifier onlyPayer() {

    require(_msgSender() == payer, "not-stream-owner");
    _;
  }

  modifier onlyPayerOrDelegated() {

    require(
      _msgSender() == payer || hasRole(PAUSABLE_ROLE, _msgSender()),
      "not-stream-owner-or-delegated"
    );
    _;
  }

  modifier onlyPayee() {

    require(_msgSender() == payee, "not-payee");
    _;
  }

  constructor(
    address _payer,
    address _payee,
    uint256 _usdAmount,
    address _token,
    address _fundingAddress,
    uint256 _endTime
  ) {
    factory = IPaymentStreamFactoryMetadata(_msgSender());

    VERSION = factory.VERSION();

    require(_endTime > block.timestamp, "invalid-end-time");
    require(_payee != _fundingAddress, "payee-is-funding-address");
    require(
      _payee != address(0) && _fundingAddress != address(0),
      "payee-or-funding-address-is-0"
    );

    require(_usdAmount > 0, "usd-amount-is-0");

    payee = _payee;
    usdAmount = _usdAmount;
    token = _token;
    fundingAddress = _fundingAddress;
    payer = _payer;
    startTime = block.timestamp;
    secs = _endTime - block.timestamp;
    usdPerSec = _usdAmount / secs;

    require(usdPerSec != 0, "usd-per-sec-is-0");

    _setupRole(ADMIN_ROLE, _payer);
    _setRoleAdmin(PAUSABLE_ROLE, ADMIN_ROLE);
  }

  function delegatePausable(address _delegate) external override {

    require(_delegate != address(0), "invalid-delegate");

    grantRole(PAUSABLE_ROLE, _delegate);
  }

  function revokePausable(address _delegate) external override {

    revokeRole(PAUSABLE_ROLE, _delegate);
  }

  function pauseStream() external override onlyPayerOrDelegated {

    paused = true;
    emit StreamPaused();
  }

  function unpauseStream() external override onlyPayerOrDelegated {

    paused = false;
    emit StreamUnpaused();
  }

  function updatePayee(address _newPayee) external override onlyPayer {

    require(_newPayee != address(0), "invalid-new-payee");
    require(_newPayee != payee, "same-new-payee");
    require(_newPayee != fundingAddress, "new-payee-is-funding-address");

    _claim();

    emit PayeeUpdated(payee, _newPayee);
    payee = _newPayee;
  }

  function updateFundingAddress(address _newFundingAddress)
    external
    override
    onlyPayer
  {

    require(_newFundingAddress != address(0), "invalid-new-funding-address");
    require(_newFundingAddress != fundingAddress, "same-new-funding-address");
    require(_newFundingAddress != payee, "new-funding-address-is-payee");

    emit FundingAddressUpdated(fundingAddress, _newFundingAddress);

    fundingAddress = _newFundingAddress;
  }

  function updateFundingRate(uint256 _usdAmount, uint256 _endTime)
    external
    override
    onlyPayer
  {

    require(_endTime > block.timestamp, "invalid-end-time");

    _claim();

    usdAmount = _usdAmount;
    startTime = block.timestamp;
    secs = _endTime - block.timestamp;
    usdPerSec = _usdAmount / secs;
    claimed = 0;

    emit StreamUpdated(_usdAmount, _endTime);
  }

  function claim() external override onlyPayee {

    require(!paused, "stream-is-paused");
    _claim();
  }

  function claimable() external view override returns (uint256) {

    return _claimable();
  }

  function claimableToken() external view override returns (uint256) {

    return factory.usdToTokenAmount(token, _claimable());
  }

  function _claim() internal {

    uint256 _accumulated = _claimable();

    if (_accumulated == 0) return;

    uint256 _amount = factory.usdToTokenAmount(token, _accumulated);

    claimed += _accumulated;

    IERC20(token).safeTransferFrom(fundingAddress, payee, _amount);

    emit Claimed(_accumulated, _amount);
  }

  function _claimable() internal view returns (uint256) {

    uint256 _elapsed = block.timestamp - startTime;

    if (_elapsed > secs) {
      return usdAmount - claimed; // no more drips to avoid floating point dust
    }

    return (usdPerSec * _elapsed) - claimed;
  }
}//MIT
pragma solidity 0.8.9;


contract PaymentStreamFactory is IPaymentStreamFactory, Ownable {

  string public constant VERSION = "1.0.2";
  string public constant NAME = "PaymentStreamFactory";

  address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  address[] private allStreams;
  mapping(address => bool) private isOurs;

  FeedRegistryInterface public feedRegistry;

  mapping(address => address) public customFeedMapping;

  constructor(address _feedRegistry) {
    feedRegistry = FeedRegistryInterface(_feedRegistry);

    customFeedMapping[WETH] = Denominations.ETH;
  }

  function createStream(
    address _payee,
    uint256 _usdAmount,
    address _token,
    address _fundingAddress,
    uint256 _endTime
  ) external returns (address streamAddress) {

    usdToTokenAmount(_token, _usdAmount);

    streamAddress = address(
      new PaymentStream(
        _msgSender(),
        _payee,
        _usdAmount,
        _token,
        _fundingAddress,
        _endTime
      )
    );

    allStreams.push(streamAddress);
    isOurs[streamAddress] = true;

    emit StreamCreated(
      allStreams.length - 1,
      streamAddress,
      _msgSender(),
      _payee,
      _usdAmount
    );
  }

  function updateFeedRegistry(address _newAddress) external override onlyOwner {

    require(_newAddress != address(0), "invalid-feed-registry-address");
    require(_newAddress != address(feedRegistry), "same-feed-registry-address");

    emit FeedRegistryUpdated(address(feedRegistry), _newAddress);
    feedRegistry = FeedRegistryInterface(_newAddress);
  }

  function updateCustomFeedMapping(address _token, address _denomination)
    external
    onlyOwner
  {

    require(_denomination != address(0), "invalid-custom-feed-map");
    require(_denomination != customFeedMapping[_token], "same-custom-feed-map");

    customFeedMapping[_token] = _denomination;
    emit CustomFeedMappingUpdated(_token, _denomination);
  }

  function usdToTokenAmount(address _token, uint256 _amount)
    public
    view
    override
    returns (uint256 lastPrice)
  {

    try
      feedRegistry.getFeed(_tokenDenomination(_token), Denominations.USD)
    returns (AggregatorV2V3Interface) {
      uint256 _quote = _getQuote(_token, Denominations.USD);
      lastPrice =
        ((_amount * 1e18) / _quote) /
        10**(18 - IERC20Metadata(_token).decimals());
    } catch {
      uint256 _ethQuote = _getQuote(_token, Denominations.ETH);
      uint256 _ethUsdQuote = _getQuote(Denominations.ETH, Denominations.USD);
      uint256 _amountInETH = (_amount * 1e18) / _ethUsdQuote;
      lastPrice =
        ((_amountInETH * 1e18) / _ethQuote) /
        10**(18 - IERC20Metadata(_token).decimals());
    }
  }

  function ours(address _a) external view override returns (bool) {

    return isOurs[_a];
  }

  function getStreamsCount() external view override returns (uint256) {

    return allStreams.length;
  }

  function getStream(uint256 _idx) external view override returns (address) {

    return allStreams[_idx];
  }

  function _getQuote(address _base, address _quote)
    internal
    view
    returns (uint256)
  {

    (, int256 _price, , , ) =
      feedRegistry.latestRoundData(_tokenDenomination(_base), _quote);

    _price = (_quote == Denominations.USD) ? _price * 1e10 : _price;
    return uint256(_price);
  }

  function _tokenDenomination(address _token) internal view returns (address) {

    return
      (customFeedMapping[_token] == address(0))
        ? _token
        : customFeedMapping[_token];
  }
}