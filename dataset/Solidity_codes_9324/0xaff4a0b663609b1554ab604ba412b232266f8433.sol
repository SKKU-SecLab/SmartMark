
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


struct CrowdsaleBaseConfig {
  IERC20 token;

  uint8 tokenDecimals;

  IERC20 USD;

  uint8 USDDecimals;

  uint256 rate;

  uint256 phaseSwitchTimestamp;

  Stage[] stages;

  AggregatorV3Interface priceFeed;

  PriceRestrictions priceRestrictions;

  uint256 maxUsdValue;
}

struct PriceRestrictions {
  uint256 timeDiff;

  uint256 minValue;

  uint256 maxValue;
}

struct Stage {
  uint256 timestamp;
  uint256 percent;
}

interface AggregatorV3Interface {

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


library PriceFeedClient {

  function currentPrice(AggregatorV3Interface priceFeed, PriceRestrictions memory priceRestrictions)
    internal
    view
    returns (uint256)
  {

    (, int256 answer, , uint256 updatedAt, ) = priceFeed.latestRoundData();
    uint256 price = uint256(answer);

    require(answer >= 0, 'CS: invalid price feed');
    require(
      updatedAt >= block.timestamp - priceRestrictions.timeDiff,
      'CS: old price feed timestamp'
    );
    require(updatedAt <= block.timestamp, 'CS: future price feed timestamp');
    require(price >= priceRestrictions.minValue, 'CS: price feed value below min value');
    require(price <= priceRestrictions.maxValue, 'CS: price feed value exceeds max value');

    return price;
  }
}// MIT
pragma solidity ^0.8.0;


contract Crowdsale is Ownable, ReentrancyGuard, Pausable {

  using PriceFeedClient for AggregatorV3Interface;
  using SafeERC20 for IERC20;


  uint8 internal constant ETH_DECIMALS = 18;
  uint256 internal constant USD_PRICE = 100000000;

  CrowdsaleBaseConfig internal config;

  uint256 public locked;

  mapping(address => uint256) public balance;

  mapping(address => uint256) public maxBalance;

  event Buy(address indexed from, uint256 indexed value);
  event Claim(address indexed from, uint256 indexed value);


  constructor(CrowdsaleBaseConfig memory _config) {
    _initializeConfig(_config);
  }


  receive() external payable {
    _buy(msg.value, false);
  }

  function buyForUSD(uint256 value) external {

    _buy(value, true);
  }

  function _buy(uint256 value, bool stable) internal nonReentrant onlySalePhase whenNotPaused {

    require(value != 0, 'CS: transaction value is zero');

    uint8 decimals = stable ? config.USDDecimals : ETH_DECIMALS;

    uint256 price = stable ? USD_PRICE : _currentEthPrice();

    require(
      _toUsd(value, price, decimals) <= config.maxUsdValue,
      'CS: transaction value exceeds maximal value in usd'
    );

    uint256 tokens = _calculateTokenAmount(
      value,
      price,
      config.rate,
      config.tokenDecimals,
      decimals
    );

    require(tokens > 0, 'CS: token amount is zero');

    uint256 availableTokens = _tokenBalance() - locked;
    require(availableTokens >= tokens, 'CS: not enough tokens on sale');

    if (stable) {
      config.USD.safeTransferFrom(msg.sender, address(this), value);
    }

    balance[msg.sender] += tokens;
    maxBalance[msg.sender] += tokens;
    locked += tokens;

    emit Buy(msg.sender, tokens);
  }

  function claim(uint256 value) external nonReentrant onlyVestingPhase whenNotPaused {

    require(balance[msg.sender] != 0, 'CS: sender has 0 tokens');
    require(balance[msg.sender] >= value, 'CS: not enough tokens');

    require(value <= _maxTokensToUnlock(msg.sender), 'CS: value exceeds unlocked percentage');

    config.token.safeTransfer(msg.sender, value);

    balance[msg.sender] -= value;
    locked -= value;

    emit Claim(msg.sender, value);
  }


  function configuration() external view returns (CrowdsaleBaseConfig memory) {

    return _configuration();
  }

  function currentEthPrice() external view returns (uint256) {

    return _currentEthPrice();
  }

  function tokenBalance() external view returns (uint256) {

    return _tokenBalance();
  }

  function freeBalance() external view returns (uint256) {

    return _freeBalance();
  }

  function unlockedPercentage() external view returns (uint256) {

    return _calculateUnlockedPercentage(config.stages, block.timestamp);
  }

  function calculateTokenAmountForETH(uint256 value) external view returns (uint256) {

    return
      _calculateTokenAmount(
        value,
        _currentEthPrice(),
        config.rate,
        config.tokenDecimals,
        ETH_DECIMALS
      );
  }

  function calculateTokenAmountForUSD(uint256 value) external view returns (uint256) {

    return
      _calculateTokenAmount(
        value,
        USD_PRICE,
        config.rate,
        config.tokenDecimals,
        config.USDDecimals
      );
  }

  function calculatePaymentForETH(uint256 tokens) external view returns (uint256) {

    return
      _calculatePayment(
        tokens,
        _currentEthPrice(),
        config.rate,
        config.tokenDecimals,
        ETH_DECIMALS
      );
  }

  function calculatePaymentForUSD(uint256 tokens) external view returns (uint256) {

    return
      _calculatePayment(
        tokens,
        USD_PRICE,
        config.rate,
        config.tokenDecimals,
        config.USDDecimals
      );
  }

  function maxTokensToUnlock(address sender) external view returns (uint256) {

    return _maxTokensToUnlock(sender);
  }


  function fund() external payable onlyOwner {}


  function transferEth(address payable to, uint256 value) external onlyOwner {

    to.transfer(value);
  }

  function transferToken(address to, uint256 value) external onlyOwner {

    uint256 free = _tokenBalance() - locked;

    require(value <= free, 'CS: value exceeds locked value');

    config.token.safeTransfer(to, value);
  }

  function transferOtherToken(
    IERC20 otherToken,
    address to,
    uint256 value
  ) external onlyOwner {

    require(config.token != otherToken, 'CS: invalid token address');

    otherToken.safeTransfer(to, value);
  }

  function pause() external onlyOwner {

    _pause();
  }

  function unpause() external onlyOwner {

    _unpause();
  }


  function _tokenBalance() internal view returns (uint256) {

    return config.token.balanceOf(address(this));
  }

  function _freeBalance() internal view returns (uint256) {

    return _tokenBalance() - locked;
  }

  function _currentEthPrice() internal view returns (uint256) {

    return config.priceFeed.currentPrice(config.priceRestrictions);
  }

  function _maxTokensToUnlock(address sender) internal view returns (uint256) {

    uint256 percentage = _calculateUnlockedPercentage(config.stages, block.timestamp);
    uint256 unlocked = _calculateMaxTokensToUnlock(balance[sender], maxBalance[sender], percentage);

    return unlocked;
  }

  function _calculateTokenAmount(
    uint256 value,
    uint256 price,
    uint256 rate,
    uint8 tokenDecimals,
    uint8 paymentDecimals
  ) internal pure returns (uint256) {

    return (price * value * uint256(10)**tokenDecimals) / rate / uint256(10)**paymentDecimals;
  }

  function _calculatePayment(
    uint256 tokens,
    uint256 price,
    uint256 rate,
    uint8 tokenDecimals,
    uint8 paymentDecimals
  ) internal pure returns (uint256) {

    return (tokens * rate * uint256(10)**paymentDecimals) / uint256(10)**tokenDecimals / price;
  }

  function _toUsd(
    uint256 value,
    uint256 price,
    uint8 paymentDecimals
  ) internal pure returns (uint256) {

    return (price * value) / uint256(10)**paymentDecimals;
  }

  function _calculateMaxTokensToUnlock(
    uint256 _balance,
    uint256 _maxBalance,
    uint256 _percentage
  ) internal pure returns (uint256) {

    if (_percentage == 0) return 0;
    if (_percentage >= 100) return _balance;

    uint256 maxTotal = (_maxBalance * _percentage) / 100;
    return maxTotal - (_maxBalance - _balance);
  }

  function _calculateUnlockedPercentage(Stage[] memory stages, uint256 currentTimestamp)
    internal
    pure
    returns (uint256)
  {

    if (stages.length == 0) return 100;

    uint256 unlocked = 0;

    for (uint256 i = 0; i < stages.length; i++) {
      if (currentTimestamp >= stages[i].timestamp) {
        unlocked = stages[i].percent;
      } else {
        break;
      }
    }

    return unlocked;
  }

  function _configuration() internal view returns (CrowdsaleBaseConfig memory) {

    CrowdsaleBaseConfig memory _config = config;
    Stage[] memory _stages = new Stage[](config.stages.length);

    for (uint8 i = 0; i < config.stages.length; i++) {
      _stages[i] = config.stages[i];
    }

    _config.stages = _stages;
    return _config;
  }

  function _initializeConfig(CrowdsaleBaseConfig memory _config) internal {

    config.token = _config.token;
    config.tokenDecimals = _config.tokenDecimals;
    config.USD = _config.USD;
    config.USDDecimals = _config.USDDecimals;
    config.rate = _config.rate;
    config.phaseSwitchTimestamp = _config.phaseSwitchTimestamp;
    config.priceFeed = _config.priceFeed;
    config.priceRestrictions = _config.priceRestrictions;
    config.maxUsdValue = _config.maxUsdValue;

    for (uint256 i = 0; i < _config.stages.length; i++) {
      config.stages.push(_config.stages[i]);
    }
  }


  modifier onlySalePhase() {

    require(block.timestamp < config.phaseSwitchTimestamp, 'CS: invalid phase, expected sale');
    _;
  }

  modifier onlyVestingPhase() {

    require(block.timestamp >= config.phaseSwitchTimestamp, 'CS: invalid phase, expected vesting');
    _;
  }
}