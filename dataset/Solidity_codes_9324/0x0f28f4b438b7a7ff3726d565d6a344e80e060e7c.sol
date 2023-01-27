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
}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.5;

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
}pragma solidity ^0.5.0;


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
}pragma solidity ^0.5.0;


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
}pragma solidity 0.5.16;

interface IVault {


    function initializeVault(
      address _storage,
      address _underlying,
      uint256 _toInvestNumerator,
      uint256 _toInvestDenominator
    ) external ;


    function balanceOf(address) external view returns (uint256);


    function underlyingBalanceInVault() external view returns (uint256);

    function underlyingBalanceWithInvestment() external view returns (uint256);


    function governance() external view returns (address);

    function controller() external view returns (address);

    function underlying() external view returns (address);

    function strategy() external view returns (address);


    function setStrategy(address _strategy) external;

    function announceStrategyUpdate(address _strategy) external;

    function setVaultFractionToInvest(uint256 numerator, uint256 denominator) external;


    function deposit(uint256 amountWei) external;

    function depositFor(uint256 amountWei, address holder) external;


    function withdrawAll() external;

    function withdraw(uint256 numberOfShares) external;

    function getPricePerFullShare() external view returns (uint256);


    function underlyingBalanceWithInvestmentForHolder(address holder) view external returns (uint256);


    function doHardWork() external;

    function totalSupply() external view returns(uint256);

}pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}pragma solidity 0.5.16;

interface IController {


    event SharePriceChangeLog(
      address indexed vault,
      address indexed strategy,
      uint256 oldSharePrice,
      uint256 newSharePrice,
      uint256 timestamp
    );

    function greyList(address _target) external view returns(bool);


    function addVaultAndStrategy(address _vault, address _strategy) external;

    function doHardWork(address _vault) external;


    function salvage(address _token, uint256 amount) external;

    function salvageStrategy(address _strategy, address _token, uint256 amount) external;


    function notifyFee(address _underlying, uint256 fee) external;

    function profitSharingNumerator() external view returns (uint256);

    function profitSharingDenominator() external view returns (uint256);


    function feeRewardForwarder() external view returns(address);

    function setFeeRewardForwarder(address _value) external;


    function addHardWorker(address _worker) external;

    function addToWhitelist(address _target) external;

}pragma solidity 0.5.16;

interface IFeeRewardForwarderV6 {

    function poolNotifyFixedTarget(address _token, uint256 _amount) external;


    function notifyFeeAndBuybackAmounts(uint256 _feeAmount, address _pool, uint256 _buybackAmount) external;

    function notifyFeeAndBuybackAmounts(address _token, uint256 _feeAmount, address _pool, uint256 _buybackAmount) external;

    function profitSharingPool() external view returns (address);

    function configureLiquidation(address[] calldata _path, bytes32[] calldata _dexes) external;

}pragma solidity 0.5.16;

contract Storage {


  address public governance;
  address public controller;

  constructor() public {
    governance = msg.sender;
  }

  modifier onlyGovernance() {

    require(isGovernance(msg.sender), "Not governance");
    _;
  }

  function setGovernance(address _governance) public onlyGovernance {

    require(_governance != address(0), "new governance shouldn't be empty");
    governance = _governance;
  }

  function setController(address _controller) public onlyGovernance {

    require(_controller != address(0), "new controller shouldn't be empty");
    controller = _controller;
  }

  function isGovernance(address account) public view returns (bool) {

    return account == governance;
  }

  function isController(address account) public view returns (bool) {

    return account == controller;
  }
}pragma solidity 0.5.16;


contract Governable {


  Storage public store;

  constructor(address _store) public {
    require(_store != address(0), "new storage shouldn't be empty");
    store = Storage(_store);
  }

  modifier onlyGovernance() {

    require(store.isGovernance(msg.sender), "Not governance");
    _;
  }

  function setStorage(address _store) public onlyGovernance {

    require(_store != address(0), "new storage shouldn't be empty");
    store = Storage(_store);
  }

  function governance() public view returns (address) {

    return store.governance();
  }
}pragma solidity 0.5.16;


contract Controllable is Governable {


  constructor(address _storage) Governable(_storage) public {
  }

  modifier onlyController() {

    require(store.isController(msg.sender), "Not a controller");
    _;
  }

  modifier onlyControllerOrGovernance(){

    require((store.isController(msg.sender) || store.isGovernance(msg.sender)),
      "The caller must be controller or governance");
    _;
  }

  function controller() public view returns (address) {

    return store.controller();
  }
}pragma solidity 0.5.16;


contract RewardTokenProfitNotifier is Controllable {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 public profitSharingNumerator;
  uint256 public profitSharingDenominator;
  address public rewardToken;

  constructor(
    address _storage,
    address _rewardToken
  ) public Controllable(_storage){
    rewardToken = _rewardToken;
    profitSharingNumerator = 30; //IController(controller()).profitSharingNumerator();
    profitSharingDenominator = 100; //IController(controller()).profitSharingDenominator();
    require(profitSharingNumerator < profitSharingDenominator, "invalid profit share");
  }

  event ProfitLogInReward(uint256 profitAmount, uint256 feeAmount, uint256 timestamp);
  event ProfitAndBuybackLog(uint256 profitAmount, uint256 feeAmount, uint256 timestamp);

  function notifyProfitInRewardToken(uint256 _rewardBalance) internal {

    if( _rewardBalance > 0 ){
      uint256 feeAmount = _rewardBalance.mul(profitSharingNumerator).div(profitSharingDenominator);
      emit ProfitLogInReward(_rewardBalance, feeAmount, block.timestamp);
      IERC20(rewardToken).safeApprove(controller(), 0);
      IERC20(rewardToken).safeApprove(controller(), feeAmount);

      IController(controller()).notifyFee(
        rewardToken,
        feeAmount
      );
    } else {
      emit ProfitLogInReward(0, 0, block.timestamp);
    }
  }

  function notifyProfitAndBuybackInRewardToken(uint256 _rewardBalance, address pool, uint256 _buybackRatio) internal {

    if( _rewardBalance > 0 ){
      uint256 feeAmount = _rewardBalance.mul(profitSharingNumerator).div(profitSharingDenominator);
      address forwarder = IController(controller()).feeRewardForwarder();
      emit ProfitAndBuybackLog(_rewardBalance, feeAmount, block.timestamp);
      IERC20(rewardToken).safeApprove(forwarder, 0);
      IERC20(rewardToken).safeApprove(forwarder, _rewardBalance);

      IFeeRewardForwarderV6(forwarder).notifyFeeAndBuybackAmounts(
        rewardToken,
        feeAmount,
        pool,
        _rewardBalance.sub(feeAmount).mul(_buybackRatio).div(10000)
      );
    } else {
      emit ProfitAndBuybackLog(0, 0, block.timestamp);
    }
  }
}pragma solidity 0.5.16;

interface IStrategy {

    
    function unsalvagableTokens(address tokens) external view returns (bool);

    
    function governance() external view returns (address);

    function controller() external view returns (address);

    function underlying() external view returns (address);

    function vault() external view returns (address);


    function withdrawAllToVault() external;

    function withdrawToVault(uint256 amount) external;


    function investedUnderlyingBalance() external view returns (uint256); // itsNotMuch()


    function salvage(address recipient, address token, uint256 amount) external;


    function doHardWork() external;

    function depositArbCheck() external view returns(bool);

}// MIT
pragma solidity >=0.5.0;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}// MIT
pragma solidity >=0.5.0;


interface IUniswapV2Router02 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);


    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}/**
 * @title: Idle Token interface
 * @author: Idle Labs Inc., idle.finance
 */
pragma solidity 0.5.16;

interface IIdleTokenV3_1 {

    function tokenPrice() external view returns (uint256 price);


    function token() external view returns (address);

    function getAPRs() external view returns (address[] memory addresses, uint256[] memory aprs);



    function mintIdleToken(uint256 _amount, bool _skipRebalance, address _referral) external returns (uint256 mintedTokens);


    function redeemIdleToken(uint256 _amount) external returns (uint256 redeemedTokens);

    function redeemInterestBearingTokens(uint256 _amount) external;


    function rebalance() external returns (bool);

}pragma solidity 0.5.16;

contract IIdleTokenHelper {

  function getMintingPrice(address idleYieldToken) view external returns (uint256 mintingPrice);

  function getRedeemPrice(address idleYieldToken) view external returns (uint256 redeemPrice);

  function getRedeemPrice(address idleYieldToken, address user) view external returns (uint256 redeemPrice);

}pragma solidity 0.5.16;

interface IStakedAave {

function stake(address to, uint256 amount) external;


function redeem(address to, uint256 amount) external;


function cooldown() external;


function claimRewards(address to, uint256 amount) external;

function COOLDOWN_SECONDS() external view returns(uint256);

function UNSTAKE_WINDOW() external view returns(uint256);

function stakersCooldowns(address input) external view returns(uint256);

function stakerRewardsToClaim(address input) external view returns(uint256);

}pragma solidity 0.5.16;


contract IdleFinanceStrategy is IStrategy, RewardTokenProfitNotifier {


  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  event ProfitsNotCollected(address);
  event Liquidating(address, uint256);

  address public referral;
  IERC20 public underlying;
  address public idleUnderlying;
  uint256 public virtualPrice;
  IIdleTokenHelper public idleTokenHelper;

  address public vault;
  address public stkaave;

  address[] public rewardTokens;
  mapping(address => address[]) public reward2WETH;
  address[] public WETH2underlying;
  mapping(address => bool) public sell;
  mapping(address => bool) public useUni;

  address public constant uniswapRouterV2 = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  address public constant sushiswapRouterV2 = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
  address public constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

  bool public claimAllowed;
  bool public protected;

  bool public allowedRewardClaimable = false;
  address public multiSig = address(0xF49440C1F012d041802b25A73e5B0B9166a75c02);

  mapping (address => bool) public unsalvagableTokens;

  modifier restricted() {

    require(msg.sender == vault || msg.sender == address(controller()) || msg.sender == address(governance()),
      "The sender has to be the controller or vault or governance");
    _;
  }

  modifier onlyMultiSigOrGovernance() {

    require(msg.sender == multiSig || msg.sender == governance(), "The sender has to be multiSig or governance");
    _;
  }

  modifier updateVirtualPrice() {

    if (protected) {
      require(virtualPrice <= idleTokenHelper.getRedeemPrice(idleUnderlying), "virtual price is higher than needed");
    }
    _;
    virtualPrice = idleTokenHelper.getRedeemPrice(idleUnderlying);
  }

  constructor(
    address _storage,
    address _underlying,
    address _idleUnderlying,
    address _vault,
    address _stkaave
  ) RewardTokenProfitNotifier(_storage, weth) public {
    stkaave = _stkaave;
    underlying = IERC20(_underlying);
    idleUnderlying = _idleUnderlying;
    vault = _vault;
    protected = true;

    unsalvagableTokens[_underlying] = true;
    unsalvagableTokens[_idleUnderlying] = true;
    for (uint256 i = 0; i < rewardTokens.length; i++) {
      address token = rewardTokens[i];
      unsalvagableTokens[token] = true;
    }
    referral = address(0xf00dD244228F51547f0563e60bCa65a30FBF5f7f);
    claimAllowed = true;

    idleTokenHelper = IIdleTokenHelper(0x04Ce60ed10F6D2CfF3AA015fc7b950D13c113be5);
    virtualPrice = idleTokenHelper.getRedeemPrice(idleUnderlying);
  }

  function depositArbCheck() public view returns(bool) {

    return true;
  }

  function setReferral(address _newRef) public onlyGovernance {

    referral = _newRef;
  }

  function investAllUnderlying() public restricted updateVirtualPrice {

    uint256 balance = underlying.balanceOf(address(this));
    underlying.safeApprove(address(idleUnderlying), 0);
    underlying.safeApprove(address(idleUnderlying), balance);
    IIdleTokenV3_1(idleUnderlying).mintIdleToken(balance, true, referral);
  }

  function withdrawAllToVault() external restricted updateVirtualPrice {

    withdrawAll();
    IERC20(address(underlying)).safeTransfer(vault, underlying.balanceOf(address(this)));
  }

  function withdrawAll() internal {

    uint256 balance = IERC20(idleUnderlying).balanceOf(address(this));

    IIdleTokenV3_1(idleUnderlying).redeemIdleToken(balance);

    liquidateRewards();
  }

  function withdrawToVault(uint256 amountUnderlying) public restricted {

    uint256 balanceBefore = underlying.balanceOf(address(this));
    uint256 totalIdleLpTokens = IERC20(idleUnderlying).balanceOf(address(this));
    uint256 totalUnderlyingBalance = totalIdleLpTokens.mul(virtualPrice).div(1e18);
    uint256 ratio = amountUnderlying.mul(1e18).div(totalUnderlyingBalance);
    uint256 toRedeem = totalIdleLpTokens.mul(ratio).div(1e18);
    IIdleTokenV3_1(idleUnderlying).redeemIdleToken(toRedeem);
    uint256 balanceAfter = underlying.balanceOf(address(this));
    underlying.safeTransfer(vault, balanceAfter.sub(balanceBefore));
  }

  function doHardWork() public restricted updateVirtualPrice {

    if (claimAllowed) {
      claim();
    }
    liquidateRewards();

    investAllUnderlying();

  }

  function salvage(address recipient, address token, uint256 amount) public onlyGovernance {

    require(!unsalvagableTokens[token], "token is defined as not salvagable");
    IERC20(token).safeTransfer(recipient, amount);
  }

  function claim() internal {

    IIdleTokenV3_1(idleUnderlying).redeemIdleToken(0);

    uint256 claimableAave = IStakedAave(stkaave).stakerRewardsToClaim(address(this));
    if (claimableAave > 0) {
      IStakedAave(stkaave).claimRewards(address(this), claimableAave);
    }
  }

  function liquidateRewards() internal {

    uint256 startingWethBalance = IERC20(weth).balanceOf(address(this));
    for (uint256 i=0;i<rewardTokens.length;i++) {
      address token = rewardTokens[i];
      if (!sell[token]) {
        emit ProfitsNotCollected(token);
        continue;
      }

      uint256 balance = IERC20(token).balanceOf(address(this));
      if (balance > 0) {
        emit Liquidating(token, balance);
        address routerV2;
        if(useUni[token]) {
          routerV2 = uniswapRouterV2;
        } else {
          routerV2 = sushiswapRouterV2;
        }
        IERC20(token).safeApprove(routerV2, 0);
        IERC20(token).safeApprove(routerV2, balance);
        IUniswapV2Router02(routerV2).swapExactTokensForTokens(
          balance, 1, reward2WETH[token], address(this), block.timestamp
        );
      }
    }

    uint256 wethBalance = IERC20(weth).balanceOf(address(this));
    if (address(underlying) == weth) {
      wethBalance = wethBalance.sub(startingWethBalance);
    }
    notifyProfitInRewardToken(wethBalance);

    uint256 remainingWethBalance = IERC20(weth).balanceOf(address(this));

    if (remainingWethBalance > 0 && address(underlying) != weth) {
      emit Liquidating(weth, remainingWethBalance);
      address routerV2;
      if(useUni[address(underlying)]) {
        routerV2 = uniswapRouterV2;
      } else {
        routerV2 = sushiswapRouterV2;
      }
      IERC20(weth).safeApprove(routerV2, 0);
      IERC20(weth).safeApprove(routerV2, remainingWethBalance);
      IUniswapV2Router02(routerV2).swapExactTokensForTokens(
        remainingWethBalance, 1, WETH2underlying, address(this), block.timestamp
      );
    }
  }

  function investedUnderlyingBalance() public view returns (uint256) {

    if (protected) {
      require(virtualPrice <= idleTokenHelper.getRedeemPrice(idleUnderlying), "virtual price is higher than needed");
    }
    uint256 invested = IERC20(idleUnderlying).balanceOf(address(this)).mul(virtualPrice).div(1e18);
    return invested.add(IERC20(underlying).balanceOf(address(this)));
  }

  function setLiquidation(address _token, bool _sell) public onlyGovernance {

     sell[_token] = _sell;
  }

  function setClaimAllowed(bool _claimAllowed) public onlyGovernance {

    claimAllowed = _claimAllowed;
  }

  function setProtected(bool _protected) public onlyGovernance {

    protected = _protected;
  }

  function setMultiSig(address _address) public onlyGovernance {

    multiSig = _address;
  }

  function setRewardClaimable(bool flag) public onlyGovernance {

    allowedRewardClaimable = flag;
  }

  function claimReward() public onlyMultiSigOrGovernance {

    require(allowedRewardClaimable, "reward claimable is not allowed");
    claim();
    uint256 stkAaveBalance = IERC20(stkaave).balanceOf(address(this));
    if (stkAaveBalance > 0){
      IERC20(stkaave).safeTransfer(msg.sender, stkAaveBalance);
    }
  }
}pragma solidity 0.5.16;

interface IBorrowRecipient {


  function pullLoan(uint256 _amount) external;


}pragma solidity 0.5.16;



contract IdleBorrowableStrategy is IdleFinanceStrategy {


  using SafeERC20 for IERC20;

  uint256 public borrowedShares;
  uint256 public underlyingUnit;
  address public borrowRecipient;
  uint256 public loanInUnderlying;

  constructor(
    address _storage,
    address _underlying,
    address _idleUnderlying,
    address _vault,
    address _stkaave
  )
  IdleFinanceStrategy(
    _storage,
    _underlying,
    _idleUnderlying,
    _vault,
    _stkaave
  )
  public {
    underlyingUnit = 10 ** uint256(ERC20Detailed(_vault).decimals());
  }

  function borrowInUnderlying(bool _exitFirst, bool _reinvest, uint256 _amountInUnderlying) external onlyGovernance {

    require(borrowRecipient != address(0), "Borrow recipient is not configured");
    uint256 pricePerShareBefore = IVault(vault).getPricePerFullShare();
    if (_exitFirst) {
      withdrawAll();
    }

    uint256 amountInShares = _amountInUnderlying
      .mul(IVault(vault).totalSupply())
      .div(IVault(vault).underlyingBalanceWithInvestment());
    borrowedShares = borrowedShares.add(amountInShares);
    IERC20(underlying).safeApprove(borrowRecipient, 0);
    IERC20(underlying).safeApprove(borrowRecipient, _amountInUnderlying);
    IBorrowRecipient(borrowRecipient).pullLoan(_amountInUnderlying);

    if (_reinvest) {
      investAllUnderlying();
    }

    updateLoanInUnderlying();

    require(IVault(vault).getPricePerFullShare() >= pricePerShareBefore, "Share value dropped");
  }

  function repayInUnderlying(uint256 _amountInUnderlying) public {

    uint256 pricePerShareBefore = IVault(vault).getPricePerFullShare();
    IERC20(underlying).safeTransferFrom(msg.sender, address(this), _amountInUnderlying);

    uint256 amountInShares = _amountInUnderlying
      .mul(underlyingUnit)
      .div(pricePerShareBefore);

    if (amountInShares >= borrowedShares) {
      borrowedShares = 0;
    } else {
      borrowedShares = borrowedShares.sub(amountInShares);
    }

    IERC20(underlying).safeTransfer(vault, _amountInUnderlying);
    updateLoanInUnderlying();

    require(IVault(vault).getPricePerFullShare() >= pricePerShareBefore, "Share value dropped");
  }

  function investedUnderlyingBalance() public view returns (uint256) {

    return super.investedUnderlyingBalance().add(loanInUnderlying);
  }

  function withdrawToVault(uint256 amountUnderlying) public restricted {

    uint256 idleInvestment = super.investedUnderlyingBalance();
    require (amountUnderlying <= idleInvestment, "Loan needs repaying");
    super.withdrawToVault(amountUnderlying);
  }

  function doHardWork() public restricted updateVirtualPrice {

    super.doHardWork();
    updateLoanInUnderlying();
  }

  function updateLoanInUnderlying() internal {

    loanInUnderlying = getLoanInUnderlying();
  }

  function getLoanInUnderlying() public view returns(uint256) {

    uint256 inIdleAndStrategy = super.investedUnderlyingBalance();
    uint256 inVault = IERC20(underlying).balanceOf(vault);
    uint256 realPricePerFullShare = inIdleAndStrategy.add(inVault)
      .mul(underlyingUnit)
      .div(IERC20(vault).totalSupply().sub(borrowedShares));
    uint256 loanInUnderlying = borrowedShares
      .mul(realPricePerFullShare)
      .div(underlyingUnit);
    return loanInUnderlying;
  }

  function setBorrowRecipient(address _borrowRecipient) external onlyGovernance {

    require(_borrowRecipient != address(0), "Use removeBorrowRecipient instead");
    borrowRecipient = _borrowRecipient;
  }

  function removeBorrowRecipient() external onlyGovernance {

    require(borrowedShares == 0, "Repay the loan first");
    borrowRecipient = address(0);
  }

  function emergencySetBorrowedShares(uint256 _newBorrowedShares) external {

    require(msg.sender == 0xF49440C1F012d041802b25A73e5B0B9166a75c02, "Only community");
    borrowedShares = _newBorrowedShares;
    updateLoanInUnderlying();
  }
}pragma solidity 0.5.16;

contract IdleBorrowableStrategyUSDTMainnet is IdleBorrowableStrategy {


  address constant public __usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  address constant public __idleUnderlying= address(0xF34842d05A1c888Ca02769A633DF37177415C2f8);
  address constant public __comp = address(0xc00e94Cb662C3520282E6f5717214004A7f26888);
  address constant public __idle = address(0x875773784Af8135eA0ef43b5a374AaD105c5D39e);
  address constant public __stkaave = address(0x4da27a545c0c5B758a6BA100e3a049001de870f5);
  address constant public __aave = address(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);

  constructor(
    address _storage,
    address _vault
  )
  IdleBorrowableStrategy(
    _storage,
    __usdt,
    __idleUnderlying,
    _vault,
    __stkaave
  )
  public {
    rewardTokens = [__comp, __idle, __aave];
    reward2WETH[__comp] = [__comp, weth];
    reward2WETH[__idle] = [__idle, weth];
    reward2WETH[__aave] = [__aave, weth];
    WETH2underlying = [weth, __usdt];
    sell[__comp] = true;
    sell[__idle] = true;
    sell[__aave] = true;
    useUni[__comp] = false;
    useUni[__idle] = false;
    useUni[__aave] = false;
    useUni[__usdt] = false;
    allowedRewardClaimable = true;
  }
}