
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
}// MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {

  function latestAnswer() external view returns (int256);


  function latestTimestamp() external view returns (uint256);


  function latestRound() external view returns (uint256);


  function getAnswer(uint256 roundId) external view returns (int256);


  function getTimestamp(uint256 roundId) external view returns (uint256);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}// MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);


  function description() external view returns (string memory);


  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
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


interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface {}// MIT

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


  function decimals(address base, address quote) external view returns (uint8);


  function description(address base, address quote) external view returns (string memory);


  function version(address base, address quote) external view returns (uint256);


  function latestRoundData(address base, address quote)
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



  function latestAnswer(address base, address quote) external view returns (int256 answer);


  function latestTimestamp(address base, address quote) external view returns (uint256 timestamp);


  function latestRound(address base, address quote) external view returns (uint256 roundId);


  function getAnswer(
    address base,
    address quote,
    uint256 roundId
  ) external view returns (int256 answer);


  function getTimestamp(
    address base,
    address quote,
    uint256 roundId
  ) external view returns (uint256 timestamp);



  function getFeed(address base, address quote) external view returns (AggregatorV2V3Interface aggregator);


  function getPhaseFeed(
    address base,
    address quote,
    uint16 phaseId
  ) external view returns (AggregatorV2V3Interface aggregator);


  function isFeedEnabled(address aggregator) external view returns (bool);


  function getPhase(
    address base,
    address quote,
    uint16 phaseId
  ) external view returns (Phase memory phase);



  function getRoundFeed(
    address base,
    address quote,
    uint80 roundId
  ) external view returns (AggregatorV2V3Interface aggregator);


  function getPhaseRange(
    address base,
    address quote,
    uint16 phaseId
  ) external view returns (uint80 startingRoundId, uint80 endingRoundId);


  function getPreviousRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external view returns (uint80 previousRoundId);


  function getNextRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external view returns (uint80 nextRoundId);



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



  function getProposedFeed(address base, address quote)
    external
    view
    returns (AggregatorV2V3Interface proposedAggregator);


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


  function proposedLatestRoundData(address base, address quote)
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function getCurrentPhaseId(address base, address quote) external view returns (uint16 currentPhaseId);

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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// UNLICENSED
pragma solidity ^0.8.0;


contract DustSweeper is Ownable, ReentrancyGuard {

  using SafeERC20 for IERC20;

  uint256 private takerDiscountPercent;
  uint256 private protocolFeePercent;
  address private protocolWallet;

  struct TokenData {
    address tokenAddress;
    uint256 tokenPrice;
  }
  mapping(address => uint8) private tokenDecimals;

  address private chainLinkRegistry;
  address private quoteETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  constructor(
    address _chainLinkRegistry,
    address _protocolWallet,
    uint256 _takerDiscountPercent,
    uint256 _protocolFeePercent
  ) {
    chainLinkRegistry = _chainLinkRegistry;
    protocolWallet = _protocolWallet;
    takerDiscountPercent = _takerDiscountPercent;
    protocolFeePercent = _protocolFeePercent;
  }

  function sweepDust(
    address[] calldata makers,
    address[] calldata tokenAddresses
  ) external payable nonReentrant {

    require(makers.length > 0 && makers.length == tokenAddresses.length, "Passed order data in invalid format");
    uint256 ethSent = msg.value;
    uint256 totalNativeAmount = 0;
    TokenData memory lastToken;
    for (uint256 i = 0; i < makers.length; i++) {
      if (tokenDecimals[tokenAddresses[i]] == 0) {
        bytes memory decData = Address.functionStaticCall(tokenAddresses[i], abi.encodeWithSignature("decimals()"));
        tokenDecimals[tokenAddresses[i]] = abi.decode(decData, (uint8));
      }
      require(tokenDecimals[tokenAddresses[i]] > 0, "Failed to fetch token decimals");

      if (i == 0 || lastToken.tokenPrice == 0 || lastToken.tokenAddress != tokenAddresses[i]) {
        lastToken = TokenData(tokenAddresses[i], uint256(getPrice(tokenAddresses[i], quoteETH)));
      }
      require(lastToken.tokenPrice > 0, "Failed to fetch token price!");

      uint256 allowance = IERC20(tokenAddresses[i]).allowance(makers[i], address(this));
      require(allowance > 0, "Allowance for specified token is 0");

      uint256 nativeAmt = allowance * lastToken.tokenPrice / 10**tokenDecimals[tokenAddresses[i]];
      totalNativeAmount += nativeAmt;

      uint256 distribution = nativeAmt * (10**4 - takerDiscountPercent) / 10**4;
      ethSent -= distribution;

      Address.sendValue(payable(makers[i]), distribution);

      IERC20(tokenAddresses[i]).safeTransferFrom(makers[i], msg.sender, allowance);
    }

    uint256 protocolNative = totalNativeAmount * protocolFeePercent / 10**4;
    ethSent -= protocolNative;
    Address.sendValue(payable(protocolWallet), protocolNative);

    if (ethSent > 10000) {
      Address.sendValue(payable(msg.sender), ethSent);
    }
  }

  function getPrice(address base, address quote) public view returns(int256) {

    (,int256 price,,,) = FeedRegistryInterface(chainLinkRegistry).latestRoundData(base, quote);
    return price;
  }

  function getTakerDiscountPercent() view external returns(uint256) {

    return takerDiscountPercent;
  }

  function setTakerDiscountPercent(uint256 _takerDiscountPercent) external onlyOwner {

    if (_takerDiscountPercent <= 5000) { // 50%
      takerDiscountPercent = _takerDiscountPercent;
    }
  }

  function getProtocolFeePercent() view external returns(uint256) {

    return protocolFeePercent;
  }

  function setProtocolFeePercent(uint256 _protocolFeePercent) external onlyOwner {

    if (_protocolFeePercent <= 1000) { // 10%
      protocolFeePercent = _protocolFeePercent;
    }
  }

  function getChainLinkRegistry() view external returns(address) {

    return chainLinkRegistry;
  }

  function setChainLinkRegistry(address _chainLinkRegistry) external onlyOwner {

    chainLinkRegistry = _chainLinkRegistry;
  }

  function getProtocolWallet() view external returns(address) {

    return protocolWallet;
  }

  function setProtocolWallet(address _protocolWallet) external onlyOwner {

    protocolWallet = _protocolWallet;
  }

  receive() external payable {}
  fallback() external payable {}

  function removeBalance(address tokenAddress) external onlyOwner {

    if (tokenAddress == address(0)) {
      Address.sendValue(payable(msg.sender), address(this).balance);
    } else {
      uint256 tokenBalance = IERC20(tokenAddress).balanceOf(address(this));
      if (tokenBalance > 0) {
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenBalance);
      }
    }
  }

}