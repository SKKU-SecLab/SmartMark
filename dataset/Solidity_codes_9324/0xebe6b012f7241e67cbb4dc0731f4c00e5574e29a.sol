

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


pragma solidity ^0.5.0;




contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {

        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {

        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
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


pragma solidity >=0.4.0;

interface ICToken {

    function exchangeRateStored() external view returns (uint);


    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(address src, address dst, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);


}


pragma solidity >=0.4.0;


contract  ICErc20 is ICToken {

    function underlying() external view returns (address);


    function mint(uint mintAmount) external returns (uint);

    function redeem(uint redeemTokens) external returns (uint);

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

interface IBadStaticCallERC20 {


    function balanceOf(address account) external returns (uint256);


    function allowance(address owner, address spender) external returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);

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


pragma solidity >=0.4.24;




contract Withdrawable is Ownable {

  using SafeERC20 for ERC20;
  address constant ETHER = address(0);

  event LogWithdrawToken(
    address indexed _from,
    address indexed _token,
    uint amount
  );

  function withdrawToken(address _tokenAddress) public onlyOwner {

    uint tokenBalance;
    if (_tokenAddress == ETHER) {
      address self = address(this); // workaround for a possible solidity bug
      tokenBalance = self.balance;
      msg.sender.transfer(tokenBalance);
    } else {
      tokenBalance = ERC20(_tokenAddress).balanceOf(address(this));
      ERC20(_tokenAddress).safeTransfer(msg.sender, tokenBalance);
    }
    emit LogWithdrawToken(msg.sender, _tokenAddress, tokenBalance);
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


pragma solidity >=0.4.24;













contract WrappedTokenSwap is Withdrawable, Pausable, Destructible, WithFee, IErc20Swap
{

  using SafeMath for uint;
  using SafeERC20 for IERC20;
  using SafeStaticCallERC20 for IBadStaticCallERC20;
  address constant ETHER = address(0);
  uint constant rateDecimals = 18;
  uint constant rateUnit = 10 ** rateDecimals;

  mapping(address => mapping(address => bool)) public forcedIsWrap;

  function wrap(address src, uint unwrappedAmount, address dest) private;

  function unwrap(address src, uint wrappedAmount, address dest) private;

  function getExchangedAmount(address src, uint srcAmount, address dest) private view returns(uint);

  function getUnderlyingPayload() private pure returns (bytes memory);


  function setIsWrap(address src, address dest) public onlyOwner {

    forcedIsWrap[src][dest] = true;
  }

  function clearIsWrap(address src, address dest) public onlyOwner {

    delete forcedIsWrap[src][dest];
  }

  function isWrap(address src, address dest) internal view returns(bool) {

    if (forcedIsWrap[src][dest]) {
      return true;
    } else if (forcedIsWrap[dest][src]) {
      return false;
    } else {
      bytes memory payload = getUnderlyingPayload();
      (bool success, address underlying) = LowLevel.staticCallContractAddr(src, payload);
      if (success && underlying != address(0)) {
        require(dest == underlying, "Invalid pair");
        return false;
      } else {
        (success, underlying) = LowLevel.staticCallContractAddr(dest, payload);
        require(success && src == underlying, "Invalid pair");
        return true;
      }
    }
  }

  function isWrapNonStatic(address src, address dest) internal returns(bool) {

    if (forcedIsWrap[src][dest]) {
      return true;
    } else if (forcedIsWrap[dest][src]) {
      return false;
    } else {
      bytes memory payload = getUnderlyingPayload();
      (bool success, address underlying) = LowLevel.callContractAddr(src, payload);
      if (success && underlying != address(0)) {
        require(dest == underlying, "Invalid pair");
        return false;
      } else {
        (success, underlying) = LowLevel.callContractAddr(dest, payload);
        require(success && src == underlying, "Invalid pair");
        return true;
      }
    }
  }

  constructor(
    address _wallet,
    uint _spread
  )
    public WithFee(address(bytes20(_wallet)), _spread)
  {}

  function() external {
    revert("fallback function not allowed");
  }

  function getRate(address src, address dest, uint256 /*srcAmount*/) public view
    returns(uint, uint)
  {

    uint rate = getAmount(src, dest, rateUnit);
    return (rate, rate);
  }

  function getAmount(address src, address dest, uint256 srcAmount)
    public view returns(uint toUserAmount)
  {

    if (isWrap(src, dest)) {
      uint fee = _getFee(srcAmount);
      toUserAmount = getExchangedAmount(src, srcAmount.sub(fee), dest);
    } else {
      uint amount = getExchangedAmount(src, srcAmount, dest);
      toUserAmount = amount.sub(_getFee(amount));
    }
  }

  event UnexpectedBalance(address token, uint balance);

  function emptyBalance(address token) private {

    uint balance = IBadStaticCallERC20(token).balanceOf(address(this));   // 0x70a08231
    if (balance > 0) {
      IERC20(token).safeTransfer(owner(), balance);
      emit UnexpectedBalance(token, balance);
    }
  }

  function initSwap(address src, address dest) private {

    emptyBalance(address(src));
    emptyBalance(address(dest));
  }

  function swap(address src, uint srcAmount, address dest, uint /*maxDestAmount*/, uint /*minConversionRate*/) public payable
    whenNotPaused
  {

    require(msg.value == 0, "ethers not supported");
    require(srcAmount != 0, "srcAmount == 0");
    require(
      IBadStaticCallERC20(src).allowance(msg.sender, address(this)) >= srcAmount, // 0xdd62ed3e
      "ERC20 allowance < srcAmount"
    );
    uint toUserAmount;
    uint fee;
    address feeToken;

    initSwap(src, dest);

    IERC20(src).safeTransferFrom(msg.sender, address(this), srcAmount);   // 0x23b872dd

    if (isWrapNonStatic(src, dest)) {
      fee = _getFee(srcAmount);
      feeToken = src;
      uint toSwap = srcAmount.sub(fee);
      wrap(src, toSwap, dest);
      toUserAmount = IBadStaticCallERC20(dest).balanceOf(address(this));
    } else {
      unwrap(src, srcAmount, dest);
      uint unwrappedAmount = IBadStaticCallERC20(dest).balanceOf(address(this));
      fee = _getFee(unwrappedAmount);
      feeToken = dest;
      toUserAmount = unwrappedAmount.sub(fee);
    }
    require(toUserAmount > 0, "toUserAmount must be greater than 0");
    IERC20(dest).safeTransfer(msg.sender, toUserAmount);
    _payFee(feeToken, fee);

    emit LogTokenSwap(
      msg.sender,
      src,
      srcAmount,
      dest,
      toUserAmount
    );
  }

}


pragma solidity >=0.4.24;



contract AdjustedRateWrappedTokenSwap is RateNormalization, WrappedTokenSwap
{

  function getRate(address src, address dest, uint256 srcAmount) public view
    returns(uint, uint)
  {

    (uint denormalizedRate, ) = super.getRate(src, dest, srcAmount);
    uint rate = normalizeRate(src, dest, denormalizedRate);
    return (rate, rate);
  }
}


pragma solidity >=0.4.24;






contract CErc20Swap is AdjustedRateWrappedTokenSwap
{

  using SafeMath for uint;
  using SafeERC20 for ERC20;
  uint constant expScale = 1e18;

  constructor(address _wallet, uint _spread)
    public WrappedTokenSwap(_wallet, _spread)
  {}

  function getUnderlyingPayload() private pure returns (bytes memory){

    return abi.encodeWithSignature("underlying()");
  }

  function wrap(address src, uint unwrappedAmount, address dest) private {

    ERC20(src).safeApprove(dest, unwrappedAmount);
    require(ICErc20(dest).mint(unwrappedAmount) == 0, "Cannot mint");
  }

  function unwrap(address src, uint wrappedAmount, address /*dest*/) private {

    require(ICErc20(src).redeem(wrappedAmount) == 0, "Cannot redeem");
  }

  function getExchangedAmount(address src, uint srcAmount, address dest) private view returns(uint) {

    if (isWrap(src, dest)) {
      uint rate = ICErc20(dest).exchangeRateStored();
      return srcAmount.mul(expScale).div(rate);
    } else {
      uint rate = ICErc20(src).exchangeRateStored();
      return srcAmount.mul(rate).div(expScale);
    }
  }
}