

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


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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


pragma solidity >=0.4.0;

interface IErc20Swap {

    function getRate(address src, address dst, uint256 srcAmount) external view returns(uint expectedRate, uint slippageRate);  // real rate = returned value / 1e18

    function swap(address src, uint srcAmount, address dest, uint maxDestAmount, uint minConversionRate) external payable;


    event LogTokenSwap(
        address indexed _userAddress,
        address indexed _userSentTokenAddress,
        uint _userSentTokenAmount,
        address indexed _userReceivedTokenAddress,
        uint _userReceivedTokenAmount
    );
}


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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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


pragma solidity >=0.5.0;


contract Destructible is Ownable {

  function destroy() public onlyOwner {

    selfdestruct(address(bytes20(owner())));
  }

  function destroyAndSend(address payable _recipient) public onlyOwner {

    selfdestruct(_recipient);
  }
}


pragma solidity >=0.4.24;


contract Pausable is Ownable {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {

    require(!paused, "The contract is paused");
    _;
  }

  modifier whenPaused() {

    require(paused, "The contract is not paused");
    _;
  }

  function pause() public onlyOwner whenNotPaused {

    paused = true;
    emit Pause();
  }

  function unpause() public onlyOwner whenPaused {

    paused = false;
    emit Unpause();
  }
}


pragma solidity ^0.5.0;

interface IBadStaticCallERC20 {


    function balanceOf(address account) external returns (uint256);


    function allowance(address owner, address spender) external returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

}


pragma solidity >=0.4.24;





contract Withdrawable is Ownable {

  using SafeERC20 for IERC20;
  address constant ETHER = address(0);

  event LogWithdrawToken(
    address indexed _from,
    address indexed _token,
    uint amount
  );

  function withdrawAll(address _tokenAddress) public onlyOwner {

    uint tokenBalance;
    if (_tokenAddress == ETHER) {
      address self = address(this); // workaround for a possible solidity bug
      tokenBalance = self.balance;
    } else {
      tokenBalance = IBadStaticCallERC20(_tokenAddress).balanceOf(address(this));
    }
    _withdraw(_tokenAddress, tokenBalance);
  }

  function _withdraw(address _tokenAddress, uint _amount) internal {

    if (_tokenAddress == ETHER) {
      msg.sender.transfer(_amount);
    } else {
      IERC20(_tokenAddress).safeTransfer(msg.sender, _amount);
    }
    emit LogWithdrawToken(msg.sender, _tokenAddress, _amount);
  }

}


pragma solidity >=0.4.24;




contract WithdrawOperator is Withdrawable {

  address public withdrawOperator;

  event SetWithdrawOperator(address oldOperator, address newOperator);

  constructor() public {
    withdrawOperator = msg.sender;
  }

  function setWithdrawOperator(address _operator) public onlyOwner {

    emit SetWithdrawOperator(withdrawOperator, _operator);
    withdrawOperator = _operator;
  }

  function withdraw(address _tokenAddress, uint _amount) public {

    require(msg.sender == withdrawOperator || msg.sender == owner(), "caller is not allowed");
    _withdraw(_tokenAddress, _amount);
  }
}


pragma solidity ^0.5.0;




library SafeStaticCallERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeApprove(IBadStaticCallERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeProxyERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function callOptionalReturn(IBadStaticCallERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeProxyERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeProxyERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeProxyERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.0;





contract WithFee is Ownable {

  using SafeERC20 for IERC20;
  using SafeMath for uint;
  address payable public feeWallet;
  uint public storedSpread;
  uint constant spreadDecimals = 6;
  uint constant spreadUnit = 10 ** spreadDecimals;

  event LogFee(address token, uint amount);

  constructor(address payable _wallet, uint _spread) public {
    require(_wallet != address(0), "_wallet == address(0)");
    require(_spread < spreadUnit, "spread >= spreadUnit");
    feeWallet = _wallet;
    storedSpread = _spread;
  }

  function setFeeWallet(address payable _wallet) external onlyOwner {

    require(_wallet != address(0), "_wallet == address(0)");
    feeWallet = _wallet;
  }

  function setSpread(uint _spread) external onlyOwner {

    storedSpread = _spread;
  }

  function _getFee(uint underlyingTokenTotal) internal view returns(uint) {

    return underlyingTokenTotal.mul(storedSpread).div(spreadUnit);
  }

  function _payFee(address feeToken, uint fee) internal {

    if (fee > 0) {
      if (feeToken == address(0)) {
        feeWallet.transfer(fee);
      } else {
        IERC20(feeToken).safeTransfer(feeWallet, fee);
      }
      emit LogFee(feeToken, fee);
    }
  }

}


pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}


pragma solidity ^0.5.0;

library LowLevel {

  function staticCallContractAddr(address target, bytes memory payload) internal view
    returns (bool success_, address result_)
  {

    (bool success, bytes memory result) = address(target).staticcall(payload);
    if (success && result.length == 32) {
      return (true, abi.decode(result, (address)));
    }
    return (false, address(0));
  }

  function callContractAddr(address target, bytes memory payload) internal
    returns (bool success_, address result_)
  {

    (bool success, bytes memory result) = address(target).call(payload);
    if (success && result.length == 32) {
      return (true, abi.decode(result, (address)));
    }
    return (false, address(0));
  }

  function staticCallContractUint(address target, bytes memory payload) internal view
    returns (bool success_, uint result_)
  {

    (bool success, bytes memory result) = address(target).staticcall(payload);
    if (success && result.length == 32) {
      return (true, abi.decode(result, (uint)));
    }
    return (false, 0);
  }

  function callContractUint(address target, bytes memory payload) internal
    returns (bool success_, uint result_)
  {

    (bool success, bytes memory result) = address(target).call(payload);
    if (success && result.length == 32) {
      return (true, abi.decode(result, (uint)));
    }
    return (false, 0);
  }
}


pragma solidity ^0.5.0;





contract RateNormalization is Ownable {

  using SafeMath for uint;

  struct RateAdjustment {
    uint factor;
    bool multiply;
  }

  mapping (address => mapping(address => RateAdjustment)) public rateAdjustment;
  mapping (address => uint) public forcedDecimals;

  function _getAdjustment(address src, address dest) private view returns(RateAdjustment memory) {

    RateAdjustment memory adj = rateAdjustment[src][dest];
    if (adj.factor == 0) {
      uint srcDecimals = _getDecimals(src);
      uint destDecimals = _getDecimals(dest);
      if (srcDecimals != destDecimals) {
        if (srcDecimals > destDecimals) {
          adj.multiply = true;
          adj.factor = 10 ** (srcDecimals - destDecimals);
        } else {
          adj.multiply = false;
          adj.factor = 10 ** (destDecimals - srcDecimals);
        }
      }
    }
    return adj;
  }

  function normalizeRate(address src, address dest, uint256 rate) public view
    returns(uint)
  {

    RateAdjustment memory adj = _getAdjustment(src, dest);
    if (adj.factor > 1) {
      rate = adj.multiply
        ? rate.mul(adj.factor)
        : rate.div(adj.factor);
    }
    return rate;
  }

  function denormalizeRate(address src, address dest, uint256 rate) public view
    returns(uint)
  {

    RateAdjustment memory adj = _getAdjustment(src, dest);
    if (adj.factor > 1) {
      rate = adj.multiply  // invert multiply/divide for denormalization
        ? rate.div(adj.factor)
        : rate.mul(adj.factor);
    }
    return rate;
  }

  function denormalizeRate(address src, address dest, uint256 rate, uint256 slippage) public view
    returns(uint, uint)
  {

    RateAdjustment memory adj = _getAdjustment(src, dest);
    if (adj.factor > 1) {
      if (adj.multiply) {
        rate = rate.div(adj.factor);
        slippage = slippage.div(adj.factor);
      } else {
        rate = rate.mul(adj.factor);
        slippage = slippage.mul(adj.factor);
      }
    }
    return (rate, slippage);
  }

  function _getDecimals(address token) internal view returns(uint) {

    uint forced = forcedDecimals[token];
    if (forced > 0) return forced;
    bytes memory payload = abi.encodeWithSignature("decimals()");
    (bool success, uint decimals) = LowLevel.staticCallContractUint(token, payload);
    require(success, "the token doesn't expose the decimals number");
    return decimals;
  }

  function setRateAdjustmentFactor(address src, address dest, uint factor, bool multiply) public onlyOwner {

    rateAdjustment[src][dest] = RateAdjustment(factor, multiply);
    rateAdjustment[dest][src] = RateAdjustment(factor, !multiply);
  }

  function setForcedDecimals(address token, uint decimals) public onlyOwner {

    forcedDecimals[token] = decimals;
  }

}


pragma solidity ^0.5.0;












contract LiquidityERC20Swap is Destructible, Pausable, WithdrawOperator, WithFee, RateNormalization, IErc20Swap {

  using SafeMath for uint;
  using SafeERC20 for IERC20;
  using SafeStaticCallERC20 for IBadStaticCallERC20;
  uint constant expScale = 1e18;

  address public token1;
  address public token2;
  address public feeToken;

  uint public rate1to2;
  uint public rate2to1;
  uint public rateDeadline;

  event SetRate(uint rate1to2, uint rate2to1, uint deadline);

  constructor (address _token1, address _token2, address payable _wallet, uint _spread) public
    WithFee(_wallet, _spread)
  {
    require(_token1 != address(0) && _token2 != address(0), "invalid tokens");
    token1 = _token1;
    token2 = _token2;
    feeToken = _token2;
  }

  function setFeeToken(address _token) public onlyOwner {

    require(_token == token1 || _token == token2, "invalid token address");
    feeToken = _token;
  }


  function setRate(uint _rate1to2, uint _rate2to1, uint _deadline) public onlyOwner {

    require(_deadline > now, "deadline <= now");
    _setRate(_rate1to2, _rate2to1, _deadline);
  }

  function _setRate(uint _rate1to2, uint _rate2to1, uint _deadline) internal {

    rate1to2 = _rate1to2;
    rate2to1 = _rate2to1;
    rateDeadline = _deadline;
    emit SetRate(rate1to2, rate2to1, rateDeadline);
  }

  function _getDestAmount(address src, address dest, uint srcAmount) internal view returns(uint toUserAmount, uint feeAmount) {

    uint rate;
    if (now > rateDeadline) {
      rate = 0;
    } else if (src == token1 && dest == token2) {
      rate = rate1to2;
    } else if (src == token2 && dest == token1) {
      rate = rate2to1;
    } else {
      rate = 0;
    }
    if (feeToken == src) {
      feeAmount = _getFee(srcAmount);
      toUserAmount = srcAmount.sub(feeAmount).mul(rate).div(expScale);
    } else if (feeToken == dest) {
      uint intermediate = srcAmount.mul(rate).div(expScale);
      feeAmount = _getFee(intermediate);
      toUserAmount = intermediate.sub(feeAmount);
    } else {
      toUserAmount = 0;
      feeAmount = 0;
    }
  }

  function getRate(address src, address dest, uint256 srcAmount) public view
    returns(uint rate, uint slippage)
  {

    (uint toUserAmount, ) = _getDestAmount(src, dest, srcAmount);
    if (toUserAmount > IERC20(dest).balanceOf(address(this))) {
      rate = 0;
    } else {
      rate = normalizeRate(src, dest, toUserAmount.mul(expScale).div(srcAmount));
    }
    slippage = rate;
  }

  function swap(address src, uint srcAmount, address dest, uint /* maxDestAmount */, uint minConversionRate)
    public payable whenNotPaused
  {

    require(msg.value == 0, "ethers not supported");
    require(srcAmount != 0, "srcAmount == 0");
    require(
      IBadStaticCallERC20(src).allowance(msg.sender, address(this)) >= srcAmount, // 0xdd62ed3e
      "ERC20 allowance < srcAmount"
    );

    (uint toUserAmount, uint feeAmount) = _getDestAmount(src, dest, srcAmount);

    uint actualRate = normalizeRate(src, dest, toUserAmount.mul(expScale).div(srcAmount));
    require(toUserAmount > 0, "toUserAmount == 0");
    require(actualRate >= minConversionRate, "rate < minConversionRate");

    require(toUserAmount <= IBadStaticCallERC20(dest).balanceOf(address(this)), "Insufficient funds");

    uint srcExpectedBalance = IBadStaticCallERC20(src).balanceOf(address(this)).add(srcAmount);
    IERC20(src).safeTransferFrom(msg.sender, address(this), srcAmount);   // 0x23b872dd
    require(srcExpectedBalance == IBadStaticCallERC20(src).balanceOf(address(this)), "Unexpected src balance");

    _payFee(feeToken, feeAmount);

    IERC20(dest).safeTransfer(msg.sender, toUserAmount);

    emit LogTokenSwap(
      msg.sender,
      src,
      srcAmount,
      dest,
      toUserAmount
    );
  }

}


pragma solidity ^0.5.0;



contract LiquidityERC20SwapOldCompatibility is LiquidityERC20Swap {

  using SafeMath for uint;

  address public operator;
  uint public defaultRateDuration = 24 hours;

  constructor (address _token1, address _token2, address payable _wallet, uint _spread) public
    LiquidityERC20Swap(_token1, _token2, _wallet, _spread)
  {
    operator = msg.sender;
  }

  modifier onlyOperator() {

    require(msg.sender == operator, "msg sender is not the operator address");
    _;
  }

  function setOperator(address _operator) public onlyOwner {

    operator = _operator;
  }

  function setDefaultRateDuration(uint _defaultRateDuration) public onlyOwner {

    defaultRateDuration = _defaultRateDuration;
  }

  function setRateAndRateDecimals(
    uint _buyRate,
    uint _buyRateDecimals,
    uint _sellRate,
    uint _sellRateDecimals
  )
    public
    onlyOperator
    returns (bool)
  {

    require(_buyRateDecimals == 18, "_buyRateDecimals != 18");
    require(_sellRateDecimals == 18, "_sellRateDecimals != 18");
    _setRate(_sellRate, _buyRate, now + defaultRateDuration);
    return true;
  }

  function buyRate() public view returns(uint) {

    return rate2to1;
  }

  function buyRateDecimals() public pure returns(uint) {

    return 18;
  }

  function sellRate() public view returns(uint) {

    return rate1to2;
  }

  function sellRateDecimals() public pure returns(uint) {

    return 18;
  }

}