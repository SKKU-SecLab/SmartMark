
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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// UNLICENSED

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface I1inchAggregationRouterV4 {

  struct SwapDescription {
    address srcToken;
    address dstToken;
    address srcReceiver;
    address dstReceiver;
    uint256 amount;
    uint256 minReturnAmount;
    uint256 flags;
    bytes permit;
  }

  event OrderFilledRFQ(bytes32 orderHash,uint256 makingAmount) ;

  event OwnershipTransferred(address indexed previousOwner,address indexed newOwner) ;

  event Swapped(address sender,address srcToken,address dstToken,address dstReceiver,uint256 spentAmount,uint256 returnAmount) ;

  function DOMAIN_SEPARATOR() external view returns (bytes32) ;


  function LIMIT_ORDER_RFQ_TYPEHASH() external view returns (bytes32) ;


  function cancelOrderRFQ(uint256 orderInfo) external;


  function destroy() external;


  function fillOrderRFQ(LimitOrderProtocolRFQ.OrderRFQ memory order,bytes memory signature,uint256 makingAmount,uint256 takingAmount) external payable returns (uint256 , uint256) ;


  function fillOrderRFQTo(LimitOrderProtocolRFQ.OrderRFQ memory order,bytes memory signature,uint256 makingAmount,uint256 takingAmount,address target) external payable returns (uint256 , uint256) ;


  function fillOrderRFQToWithPermit(LimitOrderProtocolRFQ.OrderRFQ memory order,bytes memory signature,uint256 makingAmount,uint256 takingAmount,address target,bytes memory permit) external  returns (uint256 , uint256) ;


  function invalidatorForOrderRFQ(address maker,uint256 slot) external view returns (uint256) ;


  function owner() external view returns (address) ;


  function renounceOwnership() external;


  function rescueFunds(address token,uint256 amount) external;


  function swap(address caller,SwapDescription memory desc,bytes memory data) external payable returns (uint256 returnAmount, uint256 gasLeft);


  function transferOwnership(address newOwner) external;


  function uniswapV3Swap(uint256 amount,uint256 minReturn,uint256[] memory pools) external payable returns (uint256 returnAmount) ;


  function uniswapV3SwapCallback(int256 amount0Delta,int256 amount1Delta,bytes memory ) external;


  function uniswapV3SwapTo(address recipient,uint256 amount,uint256 minReturn,uint256[] memory pools) external payable returns (uint256 returnAmount) ;


  function uniswapV3SwapToWithPermit(address recipient,address srcToken,uint256 amount,uint256 minReturn,uint256[] memory pools,bytes memory permit) external  returns (uint256 returnAmount) ;


  function unoswap(address srcToken,uint256 amount,uint256 minReturn,bytes32[] memory pools) external payable returns (uint256 returnAmount) ;


  function unoswapWithPermit(address srcToken,uint256 amount,uint256 minReturn,bytes32[] memory pools,bytes memory permit) external  returns (uint256 returnAmount) ;


  receive () external payable;
}

interface LimitOrderProtocolRFQ {

  struct OrderRFQ {
    uint256 info;
    address makerAsset;
    address takerAsset;
    address maker;
    address allowedSender;
    uint256 makingAmount;
    uint256 takingAmount;
  }
}// Unlicensed

pragma solidity >=0.7.0 <0.9.0;

interface IChainlinkOracle {

    function latestAnswer() external view returns (int256);

}// Unlicensed

pragma solidity >=0.7.0 <0.9.0;

interface ICustomPriceOracle {

    function getPriceInUSD() external returns (uint256);

}// Apache-2.0

pragma solidity >=0.7.0 <0.9.0;

interface IWETH9 {

    function deposit() external payable;

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function decimals() external view returns (uint256);


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


library ISafeERC20 {

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
pragma solidity ^0.8.7;



contract TZWAP is Ownable, Pausable {


  using ISafeERC20 for IERC20;

  I1inchAggregationRouterV4 public aggregationRouterV4;
  IWETH9 public weth;

  uint public minInterval = 60;

  uint public minNumOfIntervals = 3;

  uint public percentagePrecision =  10 ** 5;

  uint public orderCount;
  mapping (uint => TWAPOrder) public orders;
  mapping (address => uint[]) public userOrders;
  mapping (uint => Fill[]) public fills;
  mapping (address => Oracle) public oracles;
  mapping (address => bool) public whitelist;

  bool public isWhitelistActive;

  struct Oracle {
    address oracleAddress;
    bool isChainlink;
  }

  struct TWAPOrder {
    address creator;
    address srcToken;
    address dstToken;
    uint interval;
    uint tickSize;
    uint total;
    uint minFees;
    uint maxFees;
    uint created;
    bool killed;
  }
  
  struct Fill {
    address filler;
    uint ticksFilled;
    uint srcTokensSwapped;
    uint dstTokensReceived;
    uint fees;
    uint timestamp;
  }


  struct swapParams {
    address caller;
    I1inchAggregationRouterV4.SwapDescription desc;
    bytes data;
  }

  struct unoswapParams {
    address srcToken;
    uint256 amount;
    uint256 minReturn;
    bytes32[] pools;
  }

  struct uniswapV3Params {
    uint256 amount;
    uint256 minReturn;
    uint256[] pools;
  }

  event LogNewOrder(uint id);
  event LogNewFill(uint id, uint fillIndex);
  event LogOrderKilled(uint id);

  constructor(
    address payable _aggregationRouterV4Address,
    address payable _wethAddress
  ) {
    aggregationRouterV4 = I1inchAggregationRouterV4(_aggregationRouterV4Address);
    weth = IWETH9(_wethAddress);
    isWhitelistActive = true;
  }

  receive() external payable {}

  function newOrder(
    TWAPOrder memory order
  )
  payable
  public
  whenNotPaused
  returns (bool) {

    require(order.srcToken != address(0), "Invalid srcToken address");
    require(order.dstToken != address(0), "Invalid dstToken address");
    require(order.interval >= minInterval, "Invalid interval");
    require(order.tickSize > 0, "Invalid tickSize");
    require(order.total > order.tickSize && order.total % order.tickSize == 0, "Invalid total");
    require(order.total / order.tickSize > minNumOfIntervals, "Number of intervals is too less");
    order.creator = msg.sender;
    order.created = block.timestamp;
    order.killed = false;

    if (order.srcToken == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
      require(msg.value == order.total, "Invalid msg value");
      weth.deposit{value: msg.value}();
      order.srcToken = address(weth);
    }
    else {
      require(IERC20(order.srcToken).transferFrom(msg.sender, address(this), order.total));
    }

    require(oracles[order.srcToken].oracleAddress != address(0) && oracles[order.dstToken].oracleAddress != address(0), "Oracle is missing");

    orders[orderCount++] = order;
    userOrders[msg.sender].push(orderCount - 1);
    emit LogNewOrder(orderCount - 1);

    return true;
  }

  function fillOrder(
    uint id,
    uint swapType,
    swapParams calldata _swapParams,
    unoswapParams calldata _unoswapParams,
    uniswapV3Params calldata _uniswapV3Params
  )
  public
  whenNotPaused
  returns (uint) {

    if (isWhitelistActive)
      require(whitelist[msg.sender] == true, "Not whitelisted");

    require(orders[id].created != 0, "Invalid order");
    require(!orders[id].killed, "Order was killed");
    require(getSrcTokensSwappedForOrder(id) < orders[id].total, "Order is already filled");

    uint ticksToFill = getTicksToFill(id);

    require(ticksToFill > 0, "Interval must pass before next fill");

    uint timeElapsed = getTimeElapsedSinceLastFill(id);

    fills[id].push(
      Fill({
        filler: msg.sender, 
        ticksFilled: ticksToFill, 
        srcTokensSwapped: 0, // Update after swap
        dstTokensReceived: 0, // Update after swap
        fees: 0, // Update after swap
        timestamp: block.timestamp
      })
    );

    _executeSwap(id, ticksToFill, swapType, _swapParams, _unoswapParams, _uniswapV3Params);

    _setFeesAndDistribute(id, timeElapsed);

    emit LogNewFill(id, fills[id].length - 1);

    return fills[id][fills[id].length - 1].fees;
  }

  function _ensureSwapValidityAndUpdate(
    uint id,
    uint256 srcTokensSwapped,
    uint256 dstTokensReceived
  )
  internal {

    uint srcTokenPriceInUsd;
    uint dstTokenPriceInUsd;

    if (oracles[orders[id].srcToken].isChainlink)
      srcTokenPriceInUsd = uint(IChainlinkOracle(oracles[orders[id].srcToken].oracleAddress).latestAnswer());
    else
      srcTokenPriceInUsd = ICustomPriceOracle(oracles[orders[id].srcToken].oracleAddress).getPriceInUSD();

    if (oracles[orders[id].dstToken].isChainlink)
      dstTokenPriceInUsd = uint(IChainlinkOracle(oracles[orders[id].dstToken].oracleAddress).latestAnswer());
    else
      dstTokenPriceInUsd = ICustomPriceOracle(oracles[orders[id].dstToken].oracleAddress).getPriceInUSD();

    uint srcTokenDecimals = IERC20(orders[id].srcToken).decimals();
    uint dstTokenDecimals = IERC20(orders[id].dstToken).decimals();
    uint minDstTokenReceived = (900 * srcTokensSwapped * srcTokenPriceInUsd * (10 ** dstTokenDecimals)) / (1000 * dstTokenPriceInUsd * (10 ** srcTokenDecimals));

    require(dstTokensReceived > minDstTokenReceived, "Tokens received are not enough");

    fills[id][fills[id].length - 1].srcTokensSwapped = srcTokensSwapped;
    fills[id][fills[id].length - 1].dstTokensReceived = dstTokensReceived;
  }

  function _setFeesAndDistribute(
    uint id,
    uint timeElapsed
  )
  internal {

    uint timeElapsedSinceCallable;

    if (fills[id].length > 1)
      timeElapsedSinceCallable = timeElapsed - orders[id].interval;
    else
      timeElapsedSinceCallable = timeElapsed;

    uint minFeesAmount = (fills[id][fills[id].length - 1].dstTokensReceived / fills[id][fills[id].length - 1].ticksFilled) * orders[id].minFees / percentagePrecision;
    uint maxFeesAmount = (fills[id][fills[id].length - 1].dstTokensReceived / fills[id][fills[id].length - 1].ticksFilled) * orders[id].maxFees / percentagePrecision;

    fills[id][fills[id].length - 1].fees = Math.min(maxFeesAmount, minFeesAmount * ((1000 + timeElapsedSinceCallable / 6) / 1000));

    IERC20(orders[id].dstToken).safeTransfer(
      msg.sender,
      fills[id][fills[id].length - 1].fees
    );

    IERC20(orders[id].dstToken).safeTransfer(
      orders[id].creator,
      fills[id][fills[id].length - 1].dstTokensReceived - fills[id][fills[id].length - 1].fees
    );
  }


  function _executeSwap(
    uint id,
    uint ticksToFill,
    uint swapType,
    swapParams calldata _swapParams,
    unoswapParams calldata _unoswapParams,
    uniswapV3Params calldata _uniswapV3Params
  ) internal {

    uint preSwapSrcTokenBalance = IERC20(orders[id].srcToken).balanceOf(address(this));
    uint preSwapDstTokenBalance = IERC20(orders[id].dstToken).balanceOf(address(this));

    if (IERC20(orders[id].srcToken).allowance(address(this), address(aggregationRouterV4)) == 0)
      IERC20(orders[id].srcToken).safeIncreaseAllowance(address(aggregationRouterV4), 2**256 - 1);

    if (swapType == 0) aggregationRouterV4.swap(_swapParams.caller, _swapParams.desc, _swapParams.data);
    else if (swapType == 1) aggregationRouterV4.unoswap(_unoswapParams.srcToken, _unoswapParams.amount, _unoswapParams.minReturn, _unoswapParams.pools);
    else aggregationRouterV4.uniswapV3Swap(_uniswapV3Params.amount, _uniswapV3Params.minReturn, _uniswapV3Params.pools);

    uint256 srcTokensSwapped = preSwapSrcTokenBalance - IERC20(orders[id].srcToken).balanceOf(address(this));
    uint256 dstTokensReceived = IERC20(orders[id].dstToken).balanceOf(address(this)) - preSwapDstTokenBalance;

    _ensureSwapValidityAndUpdate(id, srcTokensSwapped, dstTokensReceived);

    require(srcTokensSwapped == ticksToFill * orders[id].tickSize, "Invalid amount");
    require(getSrcTokensSwappedForOrder(id) <= orders[id].total, "Overbought");
}

  function killOrder(
    uint id
  )
  public
  whenNotPaused
  returns (bool) {

    require(msg.sender == orders[id].creator, "Invalid sender");
    require(!orders[id].killed, "Order already killed");
    orders[id].killed = true;
    IERC20(orders[id].srcToken).safeTransfer(
      orders[id].creator, 
      orders[id].total - getSrcTokensSwappedForOrder(id)
    );
    emit LogOrderKilled(id);
    return true;
  }

  function getDstTokensReceivedForOrder(uint id)
  public
  view
  returns (uint) {

    require(orders[id].created != 0, "Invalid order");
    uint dstTokensReceived = 0;
    for (uint i = 0; i < fills[id].length; i++) 
      dstTokensReceived += fills[id][i].dstTokensReceived;
    return dstTokensReceived;
  }

  function getTimeElapsedSinceLastFill(uint id)
  public
  view
  returns (uint) {

    uint timeElapsed;

    if (fills[id].length > 0) {
      timeElapsed = block.timestamp - fills[id][fills[id].length - 1].timestamp;
    } else
      timeElapsed = block.timestamp - orders[id].created;

    return timeElapsed;
  }

  function getSrcTokensSwappedForOrder(uint id)
  public
  view
  returns (uint) {

    require(orders[id].created != 0, "Invalid order");
    uint srcTokensSwapped = 0;
    for (uint i = 0; i < fills[id].length; i++) 
      srcTokensSwapped += fills[id][i].srcTokensSwapped;
    return srcTokensSwapped;
  }

  function getTicksFilled(uint id)
  public
  view
  returns (uint) {

    require(orders[id].created != 0, "Invalid order");
    uint ticksFilled = 0;
    for (uint i = 0; i < fills[id].length; i++)
      ticksFilled += fills[id][i].ticksFilled;
    return ticksFilled;
  }

  function getTicksToFill(uint id)
  public view
  returns (uint) {

    uint timeElapsed = getTimeElapsedSinceLastFill(id);

    uint ticksToFill = timeElapsed / orders[id].interval;
    uint ticksFilled = getTicksFilled(id);
    uint maxTicksFillable = (orders[id].total / orders[id].tickSize) - ticksFilled;

    if (ticksToFill >= maxTicksFillable) return maxTicksFillable;
    else return ticksToFill;
  }

  function getSrcTokensToSwap(uint id)
  public view
  returns (uint) {

    return getTicksToFill(id) * orders[id].tickSize;
  }

  function isOrderActive(uint id) 
  public
  view
  returns (bool) {

    return orders[id].created != 0 && 
      !orders[id].killed && 
      getSrcTokensSwappedForOrder(id) < orders[id].total;
  }

  function addOracle(address token, Oracle memory oracle)
  public
  onlyOwner
  {

    require(oracles[token].oracleAddress == address(0), "Oracles cannot be updated");

    oracles[token] = oracle;
  }

  function toggleWhitelist(bool value)
  public
  onlyOwner
  {

    isWhitelistActive = value;
  }

  function addToWhitelist(address authorized)
  public
  onlyOwner
  {

    whitelist[authorized] = true;
  }

  function removeFromWhitelist(address authorized)
  public
  onlyOwner
  {

    whitelist[authorized] = false;
  }
}