


pragma solidity 0.6.12;

interface IPiRouterFactory {

  function buildRouter(address _piToken, bytes calldata _args) external returns (address);

}


interface ISushiBar {

  function enter(uint256 _amount) external;


  function leave(uint256 _amount) external;

}


pragma experimental ABIEncoderV2;

interface IPowerPoke {

  function authorizeReporter(uint256 userId_, address pokerKey_) external view;


  function authorizeNonReporter(uint256 userId_, address pokerKey_) external view;


  function authorizeNonReporterWithDeposit(
    uint256 userId_,
    address pokerKey_,
    uint256 overrideMinDeposit_
  ) external view;


  function authorizePoker(uint256 userId_, address pokerKey_) external view;


  function authorizePokerWithDeposit(
    uint256 userId_,
    address pokerKey_,
    uint256 overrideMinStake_
  ) external view;


  function slashReporter(uint256 slasherId_, uint256 times_) external;


  function reward(
    uint256 userId_,
    uint256 gasUsed_,
    uint256 compensationPlan_,
    bytes calldata pokeOptions_
  ) external;


  function transferClientOwnership(address client_, address to_) external;


  function addCredit(address client_, uint256 amount_) external;


  function withdrawCredit(
    address client_,
    address to_,
    uint256 amount_
  ) external;


  function setReportIntervals(
    address client_,
    uint256 minReportInterval_,
    uint256 maxReportInterval_
  ) external;


  function setSlasherHeartbeat(address client_, uint256 slasherHeartbeat_) external;


  function setGasPriceLimit(address client_, uint256 gasPriceLimit_) external;


  function setFixedCompensations(
    address client_,
    uint256 eth_,
    uint256 cvp_
  ) external;


  function setBonusPlan(
    address client_,
    uint256 planId_,
    bool active_,
    uint64 bonusNominator_,
    uint64 bonusDenominator_,
    uint64 perGas_
  ) external;


  function setMinimalDeposit(address client_, uint256 defaultMinDeposit_) external;


  function withdrawRewards(uint256 userId_, address to_) external;


  function setPokerKeyRewardWithdrawAllowance(uint256 userId_, bool allow_) external;


  function addClient(
    address client_,
    address owner_,
    bool canSlash_,
    uint256 gasPriceLimit_,
    uint256 minReportInterval_,
    uint256 maxReportInterval_
  ) external;


  function setClientActiveFlag(address client_, bool active_) external;


  function setCanSlashFlag(address client_, bool canSlash) external;


  function setOracle(address oracle_) external;


  function pause() external;


  function unpause() external;


  function creditOf(address client_) external view returns (uint256);


  function ownerOf(address client_) external view returns (address);


  function getMinMaxReportIntervals(address client_) external view returns (uint256 min, uint256 max);


  function getSlasherHeartbeat(address client_) external view returns (uint256);


  function getGasPriceLimit(address client_) external view returns (uint256);


  function getPokerBonus(
    address client_,
    uint256 bonusPlanId_,
    uint256 gasUsed_,
    uint256 userDeposit_
  ) external view returns (uint256);


  function getGasPriceFor(address client_) external view returns (uint256);

}


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
}


library SafeERC20 {

  using SafeMath for uint256;
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

    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

    uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
  }

  function _callOptionalReturn(IERC20 token, bytes memory data) private {


    bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) { // Return data is optional
      require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
  }
}


interface WrappedPiErc20Interface is IERC20 {

  function deposit(uint256 _amount) external payable returns (uint256);


  function withdraw(uint256 _amount) external payable returns (uint256);


  function changeRouter(address _newRouter) external;


  function setEthFee(uint256 _newEthFee) external;


  function withdrawEthFee(address payable receiver) external;


  function approveUnderlying(address _to, uint256 _amount) external;


  function callExternal(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external;


  struct ExternalCallData {
    address destination;
    bytes4 signature;
    bytes args;
    uint256 value;
  }

  function callExternalMultiple(ExternalCallData[] calldata calls) external;


  function getUnderlyingBalance() external view returns (uint256);

}


interface IPoolRestrictions {

  function getMaxTotalSupply(address _pool) external view returns (uint256);


  function isVotingSignatureAllowed(address _votingAddress, bytes4 _signature) external view returns (bool);


  function isVotingSenderAllowed(address _votingAddress, address _sender) external view returns (bool);


  function isWithoutFee(address _addr) external view returns (bool);

}



interface PowerIndexBasicRouterInterface {

  function setVotingAndStaking(address _voting, address _staking) external;


  function setReserveConfig(uint256 _reserveRatio, uint256 _claimRewardsInterval) external;


  function getPiEquivalentForUnderlying(
    uint256 _underlyingAmount,
    IERC20 _underlyingToken,
    uint256 _piTotalSupply
  ) external view returns (uint256);


  function getPiEquivalentForUnderlyingPure(
    uint256 _underlyingAmount,
    uint256 _totalUnderlyingWrapped,
    uint256 _piTotalSupply
  ) external pure returns (uint256);


  function getUnderlyingEquivalentForPi(
    uint256 _piAmount,
    IERC20 _underlyingToken,
    uint256 _piTotalSupply
  ) external view returns (uint256);


  function getUnderlyingEquivalentForPiPure(
    uint256 _piAmount,
    uint256 _totalUnderlyingWrapped,
    uint256 _piTotalSupply
  ) external pure returns (uint256);

}


interface BMathInterface {

  function calcInGivenOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 tokenBalanceOut,
    uint256 tokenWeightOut,
    uint256 tokenAmountOut,
    uint256 swapFee
  ) external pure returns (uint256 tokenAmountIn);


  function calcSingleInGivenPoolOut(
    uint256 tokenBalanceIn,
    uint256 tokenWeightIn,
    uint256 poolSupply,
    uint256 totalWeight,
    uint256 poolAmountOut,
    uint256 swapFee
  ) external pure returns (uint256 tokenAmountIn);

}


interface BPoolInterface is IERC20, BMathInterface {

  function joinPool(uint256 poolAmountOut, uint256[] calldata maxAmountsIn) external;


  function exitPool(uint256 poolAmountIn, uint256[] calldata minAmountsOut) external;


  function swapExactAmountIn(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external returns (uint256, uint256);


  function swapExactAmountOut(
    address,
    uint256,
    address,
    uint256,
    uint256
  ) external returns (uint256, uint256);


  function joinswapExternAmountIn(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function joinswapPoolAmountOut(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function exitswapPoolAmountIn(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function exitswapExternAmountOut(
    address,
    uint256,
    uint256
  ) external returns (uint256);


  function getDenormalizedWeight(address) external view returns (uint256);


  function getBalance(address) external view returns (uint256);


  function getSwapFee() external view returns (uint256);


  function getTotalDenormalizedWeight() external view returns (uint256);


  function getCommunityFee()
  external
  view
  returns (
    uint256,
    uint256,
    uint256,
    address
  );


  function calcAmountWithCommunityFee(
    uint256,
    uint256,
    address
  ) external view returns (uint256, uint256);


  function getRestrictions() external view returns (address);


  function isPublicSwap() external view returns (bool);


  function isFinalized() external view returns (bool);


  function isBound(address t) external view returns (bool);


  function getCurrentTokens() external view returns (address[] memory tokens);


  function getFinalTokens() external view returns (address[] memory tokens);


  function setSwapFee(uint256) external;


  function setCommunityFeeAndReceiver(
    uint256,
    uint256,
    uint256,
    address
  ) external;


  function setController(address) external;


  function setPublicSwap(bool) external;


  function finalize() external;


  function bind(
    address,
    uint256,
    uint256
  ) external;


  function rebind(
    address,
    uint256,
    uint256
  ) external;


  function unbind(address) external;


  function gulp(address) external;


  function callVoting(
    address voting,
    bytes4 signature,
    bytes calldata args,
    uint256 value
  ) external;


  function getMinWeight() external view returns (uint256);


  function getMaxBoundTokens() external view returns (uint256);

}


abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}


abstract contract Ownable is Context {
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
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
}


interface PowerIndexNaiveRouterInterface {

  function migrateToNewRouter(
    address _piToken,
    address payable _newRouter,
    address[] memory _tokens
  ) external;


  function piTokenCallback(address sender, uint256 _withdrawAmount) external payable;

}


contract PowerIndexNaiveRouter is PowerIndexNaiveRouterInterface, Ownable {

  using SafeMath for uint256;

  function migrateToNewRouter(
    address _piToken,
    address payable _newRouter,
    address[] memory _tokens
  ) public virtual override onlyOwner {

    WrappedPiErc20Interface(_piToken).changeRouter(_newRouter);
  }

  function piTokenCallback(address sender, uint256 _withdrawAmount) external payable virtual override {

  }
}


contract PowerIndexBasicRouter is PowerIndexBasicRouterInterface, PowerIndexNaiveRouter {

  using SafeERC20 for IERC20;

  uint256 public constant HUNDRED_PCT = 1 ether;

  event SetVotingAndStaking(address indexed voting, address indexed staking);
  event SetReserveConfig(uint256 ratio, uint256 claimRewardsInterval);
  event SetRebalancingInterval(uint256 rebalancingInterval);
  event IgnoreRebalancing(uint256 blockTimestamp, uint256 lastRebalancedAt, uint256 rebalancingInterval);
  event RewardPool(address indexed pool, uint256 amount);
  event SetRewardPools(uint256 len, address[] rewardPools);
  event SetPvpFee(uint256 pvpFee);

  enum ReserveStatus { EQUILIBRIUM, SHORTAGE, EXCESS }

  struct BasicConfig {
    address poolRestrictions;
    address powerPoke;
    address voting;
    address staking;
    uint256 reserveRatio;
    uint256 reserveRatioToForceRebalance;
    uint256 claimRewardsInterval;
    address pvp;
    uint256 pvpFee;
    address[] rewardPools;
  }

  WrappedPiErc20Interface public immutable piToken;
  address public immutable pvp;

  IPoolRestrictions public poolRestrictions;
  IPowerPoke public powerPoke;
  address public voting;
  address public staking;
  uint256 public reserveRatio;
  uint256 public claimRewardsInterval;
  uint256 public lastClaimRewardsAt;
  uint256 public lastRebalancedAt;
  uint256 public reserveRatioToForceRebalance;
  uint256 public pvpFee;

  address[] internal rewardPools;

  uint256 internal constant COMPENSATION_PLAN_1_ID = 1;

  modifier onlyPiToken() {

    require(msg.sender == address(piToken), "ONLY_PI_TOKEN_ALLOWED");
    _;
  }

  modifier onlyEOA() {

    require(tx.origin == msg.sender, "ONLY_EOA");
    _;
  }

  modifier onlyReporter(uint256 _reporterId, bytes calldata _rewardOpts) {

    uint256 gasStart = gasleft();
    powerPoke.authorizeReporter(_reporterId, msg.sender);
    _;
    _reward(_reporterId, gasStart, COMPENSATION_PLAN_1_ID, _rewardOpts);
  }

  modifier onlyNonReporter(uint256 _reporterId, bytes calldata _rewardOpts) {

    uint256 gasStart = gasleft();
    powerPoke.authorizeNonReporter(_reporterId, msg.sender);
    _;
    _reward(_reporterId, gasStart, COMPENSATION_PLAN_1_ID, _rewardOpts);
  }

  constructor(address _piToken, BasicConfig memory _basicConfig) public PowerIndexNaiveRouter() Ownable() {
    require(_piToken != address(0), "INVALID_PI_TOKEN");
    require(_basicConfig.reserveRatio <= HUNDRED_PCT, "RR_GT_HUNDRED_PCT");
    require(_basicConfig.pvpFee < HUNDRED_PCT, "PVP_FEE_GTE_HUNDRED_PCT");
    require(_basicConfig.pvp != address(0), "INVALID_PVP_ADDR");
    require(_basicConfig.poolRestrictions != address(0), "INVALID_POOL_RESTRICTIONS_ADDR");

    piToken = WrappedPiErc20Interface(_piToken);
    poolRestrictions = IPoolRestrictions(_basicConfig.poolRestrictions);
    powerPoke = IPowerPoke(_basicConfig.powerPoke);
    voting = _basicConfig.voting;
    staking = _basicConfig.staking;
    reserveRatio = _basicConfig.reserveRatio;
    reserveRatioToForceRebalance = _basicConfig.reserveRatioToForceRebalance;
    claimRewardsInterval = _basicConfig.claimRewardsInterval;
    pvp = _basicConfig.pvp;
    pvpFee = _basicConfig.pvpFee;
    rewardPools = _basicConfig.rewardPools;
  }

  receive() external payable {}


  function setVotingAndStaking(address _voting, address _staking) external override onlyOwner {

    voting = _voting;
    staking = _staking;
    emit SetVotingAndStaking(_voting, _staking);
  }

  function setReserveConfig(uint256 _reserveRatio, uint256 _claimRewardsInterval) public virtual override onlyOwner {

    require(_reserveRatio <= HUNDRED_PCT, "RR_GREATER_THAN_100_PCT");
    reserveRatio = _reserveRatio;
    claimRewardsInterval = _claimRewardsInterval;
    emit SetReserveConfig(_reserveRatio, _claimRewardsInterval);
  }

  function setRewardPools(address[] calldata _rewardPools) external onlyOwner {

    require(_rewardPools.length > 0, "AT_LEAST_ONE_EXPECTED");
    rewardPools = _rewardPools;
    emit SetRewardPools(_rewardPools.length, _rewardPools);
  }

  function setPvpFee(uint256 _pvpFee) external onlyOwner {

    require(_pvpFee < HUNDRED_PCT, "PVP_FEE_OVER_THE_LIMIT");
    pvpFee = _pvpFee;
    emit SetPvpFee(_pvpFee);
  }

  function setPiTokenEthFee(uint256 _ethFee) external onlyOwner {

    require(_ethFee <= 0.1 ether, "ETH_FEE_OVER_THE_LIMIT");
    piToken.setEthFee(_ethFee);
  }

  function withdrawEthFee(address payable _receiver) external onlyOwner {

    piToken.withdrawEthFee(_receiver);
  }

  function migrateToNewRouter(
    address _piToken,
    address payable _newRouter,
    address[] memory _tokens
  ) public override onlyOwner {

    super.migrateToNewRouter(_piToken, _newRouter, _tokens);

    _newRouter.transfer(address(this).balance);

    uint256 len = _tokens.length;
    for (uint256 i = 0; i < len; i++) {
      IERC20 t = IERC20(_tokens[i]);
      t.safeTransfer(_newRouter, t.balanceOf(address(this)));
    }
  }

  function pokeFromReporter(
    uint256 _reporterId,
    bool _claimAndDistributeRewards,
    bytes calldata _rewardOpts
  ) external onlyReporter(_reporterId, _rewardOpts) onlyEOA {

    (uint256 minInterval, ) = _getMinMaxReportInterval();
    (ReserveStatus status, uint256 diff, bool forceRebalance) = getReserveStatus(_getUnderlyingStaked(), 0);
    require(forceRebalance || lastRebalancedAt + minInterval < block.timestamp, "MIN_INTERVAL_NOT_REACHED");
    require(status != ReserveStatus.EQUILIBRIUM, "RESERVE_STATUS_EQUILIBRIUM");
    _rebalancePoke(status, diff);
    _postPoke(_claimAndDistributeRewards);
  }

  function pokeFromSlasher(
    uint256 _reporterId,
    bool _claimAndDistributeRewards,
    bytes calldata _rewardOpts
  ) external onlyNonReporter(_reporterId, _rewardOpts) onlyEOA {

    (, uint256 maxInterval) = _getMinMaxReportInterval();
    (ReserveStatus status, uint256 diff, bool forceRebalance) = getReserveStatus(_getUnderlyingStaked(), 0);
    require(forceRebalance || lastRebalancedAt + maxInterval < block.timestamp, "MAX_INTERVAL_NOT_REACHED");
    require(status != ReserveStatus.EQUILIBRIUM, "RESERVE_STATUS_EQUILIBRIUM");
    _rebalancePoke(status, diff);
    _postPoke(_claimAndDistributeRewards);
  }

  function poke(bool _claimAndDistributeRewards) external onlyEOA {

    (ReserveStatus status, uint256 diff, ) = getReserveStatus(_getUnderlyingStaked(), 0);
    _rebalancePoke(status, diff);
    _postPoke(_claimAndDistributeRewards);
  }

  function _postPoke(bool _claimAndDistributeRewards) internal {

    lastRebalancedAt = block.timestamp;

    if (_claimAndDistributeRewards && lastClaimRewardsAt + claimRewardsInterval < block.timestamp) {
      _claimRewards();
      _distributeRewards();
      lastClaimRewardsAt = block.timestamp;
    }
  }

  function _rebalancePoke(ReserveStatus reserveStatus, uint256 sushiDiff) internal virtual {

  }

  function _claimRewards() internal virtual {

  }

  function _distributeRewards() internal virtual {

  }

  function _callVoting(bytes4 _sig, bytes memory _data) internal {

    piToken.callExternal(voting, _sig, _data, 0);
  }

  function _callStaking(bytes4 _sig, bytes memory _data) internal {

    piToken.callExternal(staking, _sig, _data, 0);
  }

  function _checkVotingSenderAllowed() internal view {

    require(poolRestrictions.isVotingSenderAllowed(voting, msg.sender), "SENDER_NOT_ALLOWED");
  }

  function _distributeRewardToPvp(uint256 _totalReward, IERC20 _underlying)
  internal
  returns (uint256 pvpReward, uint256 remainder)
  {

    pvpReward = 0;
    remainder = 0;

    if (pvpFee > 0) {
      pvpReward = _totalReward.mul(pvpFee).div(HUNDRED_PCT);
      remainder = _totalReward.sub(pvpReward);
      _underlying.safeTransfer(pvp, pvpReward);
    } else {
      remainder = _totalReward;
    }
  }

  function _distributePiRemainderToPools(IERC20 _piToken)
  internal
  returns (uint256 piBalanceToDistribute, address[] memory pools)
  {

    pools = rewardPools;
    uint256 poolsLen = pools.length;
    require(poolsLen > 0, "MISSING_REWARD_POOLS");

    piBalanceToDistribute = piToken.balanceOf(address(this));
    require(piBalanceToDistribute > 0, "NO_POOL_REWARDS_PI");

    uint256 totalPiOnPools = 0;
    for (uint256 i = 0; i < poolsLen; i++) {
      totalPiOnPools = totalPiOnPools.add(_piToken.balanceOf(pools[i]));
    }
    require(totalPiOnPools > 0, "TOTAL_PI_IS_0");

    for (uint256 i = 0; i < poolsLen; i++) {
      address pool = pools[i];
      uint256 poolPiBalance = piToken.balanceOf(pool);
      if (poolPiBalance == 0) {
        continue;
      }

      uint256 poolReward = piBalanceToDistribute.mul(poolPiBalance) / totalPiOnPools;

      piToken.transfer(pool, poolReward);

      BPoolInterface(pool).gulp(address(piToken));
      emit RewardPool(pool, poolReward);
    }
  }

  function getReserveStatusForStakedBalance()
  public
  view
  returns (
    ReserveStatus status,
    uint256 diff,
    bool forceRebalance
  )
  {

    return getReserveStatus(_getUnderlyingStaked(), 0);
  }

  function getReserveStatus(uint256 _stakedBalance, uint256 _withdrawAmount)
  public
  view
  returns (
    ReserveStatus status,
    uint256 diff,
    bool forceRebalance
  )
  {

    uint256 expectedReserveAmount;
    (status, diff, expectedReserveAmount) = getReserveStatusPure(
      reserveRatio,
      piToken.getUnderlyingBalance(),
      _stakedBalance,
      _withdrawAmount
    );

    if (status == ReserveStatus.SHORTAGE) {
      uint256 currentRatio = expectedReserveAmount.sub(diff).mul(HUNDRED_PCT).div(expectedReserveAmount);
      forceRebalance = reserveRatioToForceRebalance >= currentRatio;
    }
  }

  function _getUnderlyingStaked() internal view virtual returns (uint256) {

    if (staking == address(0)) {
      return 0;
    }
    return IERC20(staking).balanceOf(address(piToken));
  }

  function getUnderlyingStaked() external view returns (uint256) {

    return _getUnderlyingStaked();
  }

  function getRewardPools() external view returns (address[] memory) {

    return rewardPools;
  }

  function getPiEquivalentForUnderlying(
    uint256 _underlyingAmount,
    IERC20 _underlyingToken,
    uint256 _piTotalSupply
  ) public view virtual override returns (uint256) {

    uint256 underlyingOnPiToken = _underlyingToken.balanceOf(address(piToken));
    return
    getPiEquivalentForUnderlyingPure(
      _underlyingAmount,
      underlyingOnPiToken.add(_getUnderlyingStaked()),
      _piTotalSupply
    );
  }

  function getPiEquivalentForUnderlyingPure(
    uint256 _underlyingAmount,
    uint256 _totalUnderlyingWrapped,
    uint256 _piTotalSupply
  ) public pure virtual override returns (uint256) {

    if (_piTotalSupply == 0) {
      return _underlyingAmount;
    }
    return _piTotalSupply.mul(_underlyingAmount).div(_totalUnderlyingWrapped);
  }

  function getUnderlyingEquivalentForPi(
    uint256 _piAmount,
    IERC20 _underlyingToken,
    uint256 _piTotalSupply
  ) public view virtual override returns (uint256) {

    uint256 underlyingOnPiToken = _underlyingToken.balanceOf(address(piToken));
    return
    getUnderlyingEquivalentForPiPure(
      _piAmount,
      underlyingOnPiToken.add(_getUnderlyingStaked()),
      _piTotalSupply
    );
  }

  function getUnderlyingEquivalentForPiPure(
    uint256 _piAmount,
    uint256 _totalUnderlyingWrapped,
    uint256 _piTotalSupply
  ) public pure virtual override returns (uint256) {

    if (_piTotalSupply == 0) {
      return _piAmount;
    }
    return _totalUnderlyingWrapped.mul(_piAmount).div(_piTotalSupply);
  }

  function getReserveStatusPure(
    uint256 _reserveRatioPct,
    uint256 _leftOnPiToken,
    uint256 _stakedBalance,
    uint256 _withdrawAmount
  )
  public
  pure
  returns (
    ReserveStatus status,
    uint256 diff,
    uint256 expectedReserveAmount
  )
  {

    require(_reserveRatioPct <= HUNDRED_PCT, "RR_GREATER_THAN_100_PCT");
    expectedReserveAmount = getExpectedReserveAmount(_reserveRatioPct, _leftOnPiToken, _stakedBalance, _withdrawAmount);

    if (expectedReserveAmount > _leftOnPiToken) {
      status = ReserveStatus.SHORTAGE;
      diff = expectedReserveAmount.sub(_leftOnPiToken);
    } else if (expectedReserveAmount < _leftOnPiToken) {
      status = ReserveStatus.EXCESS;
      diff = _leftOnPiToken.sub(expectedReserveAmount);
    } else {
      status = ReserveStatus.EQUILIBRIUM;
      diff = 0;
    }
  }

  function getExpectedReserveAmount(
    uint256 _reserveRatioPct,
    uint256 _leftOnPiToken,
    uint256 _stakedBalance,
    uint256 _withdrawAmount
  ) public pure returns (uint256) {

    return
    _reserveRatioPct.mul(_stakedBalance.add(_leftOnPiToken).sub(_withdrawAmount)).div(HUNDRED_PCT).add(
      _withdrawAmount
    );
  }

  function _reward(
    uint256 _reporterId,
    uint256 _gasStart,
    uint256 _compensationPlan,
    bytes calldata _rewardOpts
  ) internal {

    powerPoke.reward(_reporterId, _gasStart.sub(gasleft()), _compensationPlan, _rewardOpts);
  }

  function _getMinMaxReportInterval() internal view returns (uint256 min, uint256 max) {

    return powerPoke.getMinMaxReportIntervals(address(this));
  }
}


contract SushiPowerIndexRouter is PowerIndexBasicRouter {

  event Stake(address indexed sender, uint256 amount);
  event Redeem(address indexed sender, uint256 amount);
  event IgnoreDueMissingStaking();
  event ClaimRewards(
    address indexed sender,
    uint256 xSushiBurned,
    uint256 expectedSushiReward,
    uint256 releasedSushiReward
  );
  event DistributeRewards(
    address indexed sender,
    uint256 sushiReward,
    uint256 pvpReward,
    uint256 poolRewardsUnderlying,
    uint256 poolRewardsPi,
    address[] pools
  );

  struct SushiConfig {
    address SUSHI;
  }

  IERC20 internal immutable SUSHI;

  constructor(
    address _piToken,
    BasicConfig memory _basicConfig,
    SushiConfig memory _sushiConfig
  ) public PowerIndexBasicRouter(_piToken, _basicConfig) {
    SUSHI = IERC20(_sushiConfig.SUSHI);
  }


  function _claimRewards() internal override {

    uint256 rewardsPending = getPendingRewards();
    require(rewardsPending > 0, "NOTHING_TO_CLAIM");

    uint256 sushiBefore = SUSHI.balanceOf(address(piToken));
    uint256 xSushiToBurn = getXSushiForSushi(rewardsPending);

    _callStaking(ISushiBar.leave.selector, abi.encode(xSushiToBurn));
    uint256 released = SUSHI.balanceOf(address(piToken)).sub(sushiBefore);
    require(released > 0, "NOTHING_RELEASED");

    piToken.callExternal(address(SUSHI), SUSHI.transfer.selector, abi.encode(address(this), released), 0);

    emit ClaimRewards(msg.sender, xSushiToBurn, rewardsPending, released);
  }

  function _distributeRewards() internal override {

    uint256 pendingReward = SUSHI.balanceOf(address(this));
    require(pendingReward > 0, "NO_PENDING_REWARD");

    (uint256 pvpReward, uint256 poolRewardsUnderlying) = _distributeRewardToPvp(pendingReward, SUSHI);
    require(poolRewardsUnderlying > 0, "NO_POOL_REWARDS_UNDERLYING");

    SUSHI.approve(address(piToken), poolRewardsUnderlying);
    piToken.deposit(poolRewardsUnderlying);

    (uint256 poolRewardsPi, address[] memory pools) = _distributePiRemainderToPools(piToken);

    emit DistributeRewards(msg.sender, pendingReward, pvpReward, poolRewardsUnderlying, poolRewardsPi, pools);
  }


  function getXSushiForSushi(uint256 _sushi) public view returns (uint256) {

    return _sushi.mul(IERC20(staking).totalSupply()) / SUSHI.balanceOf(staking);
  }

  function getSushiForXSushi(uint256 _xSushi) public view returns (uint256) {

    return _xSushi.mul(SUSHI.balanceOf(staking)) / IERC20(staking).totalSupply();
  }

  function getUnderlyingBackedByXSushi() public view returns (uint256) {

    if (staking == address(0)) {
      return 0;
    }

    uint256 xSushiAtPiToken = IERC20(staking).balanceOf(address(piToken));
    if (xSushiAtPiToken == 0) {
      return 0;
    }

    return getSushiForXSushi(xSushiAtPiToken);
  }

  function getPendingRewards() public view returns (uint256 amount) {

    amount = SUSHI.balanceOf(address(piToken)).add(getUnderlyingBackedByXSushi()).add(1).sub(piToken.totalSupply());
    return amount == 1 ? 0 : amount;
  }


  function getPiEquivalentForUnderlying(
    uint256 _underlyingAmount,
    IERC20, /* _underlyingToken */
    uint256 /* _piTotalSupply */
  ) public view override returns (uint256) {

    return _underlyingAmount;
  }

  function getPiEquivalentForUnderlyingPure(
    uint256 _underlyingAmount,
    uint256, /* _totalUnderlyingWrapped */
    uint256 /* _piTotalSupply */
  ) public pure override returns (uint256) {

    return _underlyingAmount;
  }

  function getUnderlyingEquivalentForPi(
    uint256 _piAmount,
    IERC20, /* _underlyingToken */
    uint256 /* _piTotalSupply */
  ) public view override returns (uint256) {

    return _piAmount;
  }

  function getUnderlyingEquivalentForPiPure(
    uint256 _piAmount,
    uint256, /* _totalUnderlyingWrapped */
    uint256 /* _piTotalSupply */
  ) public pure override returns (uint256) {

    return _piAmount;
  }


  function stake(uint256 _sushi) external onlyOwner {

    _stake(_sushi);
  }

  function redeem(uint256 _xSushi) external onlyOwner {

    _redeem(_xSushi);
  }


  function _rebalancePoke(ReserveStatus reserveStatus, uint256 sushiDiff) internal override {

    require(staking != address(0), "STACKING_IS_NULL");

    if (reserveStatus == ReserveStatus.SHORTAGE) {
      _redeem(getXSushiForSushi(sushiDiff));
    } else if (reserveStatus == ReserveStatus.EXCESS) {
      _stake(sushiDiff);
    }
  }


  function _getUnderlyingStaked() internal view override returns (uint256) {

    return piToken.totalSupply().sub(SUSHI.balanceOf(address(piToken)));
  }

  function _stake(uint256 _sushi) internal {

    require(_sushi > 0, "CANT_STAKE_0");

    piToken.approveUnderlying(staking, _sushi);
    _callStaking(ISushiBar(0).enter.selector, abi.encode(_sushi));

    emit Stake(msg.sender, _sushi);
  }

  function _redeem(uint256 _xSushi) internal {

    require(_xSushi > 0, "CANT_REDEEM_0");

    _callStaking(ISushiBar(0).leave.selector, abi.encode(_xSushi));

    emit Redeem(msg.sender, _xSushi);
  }
}


contract SushiPowerIndexRouterFactory is IPiRouterFactory {

  event BuildSushiRouter(address indexed builder, address indexed piToken, address indexed router);

  function buildRouter(address _piToken, bytes calldata _args) external override returns (address) {

    (PowerIndexBasicRouter.BasicConfig memory _basicConfig, SushiPowerIndexRouter.SushiConfig memory _sushiConfig) =
    abi.decode(_args, (PowerIndexBasicRouter.BasicConfig, SushiPowerIndexRouter.SushiConfig));

    address router = address(new SushiPowerIndexRouter(_piToken, _basicConfig, _sushiConfig));

    emit BuildSushiRouter(msg.sender, _piToken, router);

    Ownable(router).transferOwnership(msg.sender);

    return router;
  }
}