
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
}// ISC

pragma solidity 0.8.4;

interface IStrategy {


  enum Platform {
    UNKNOWN, // 0
    TETU, // 1
    QUICK, // 2
    SUSHI, // 3
    WAULT, // 4
    IRON, // 5
    COSMIC, // 6
    CURVE, // 7
    DINO, // 8
    IRON_LEND, // 9
    HERMES, // 10
    CAFE, // 11
    TETU_SWAP, // 12
    SPOOKY, // 13
    AAVE_LEND, //14
    AAVE_MAI_BAL, // 15
    GEIST, //16
    HARVEST, //17
    SCREAM_LEND, //18
    KLIMA, //19
    VESQ, //20
    QIDAO, //21
    SUNFLOWER, //22
    NACHO, //23
    STRATEGY_SPLITTER, //24
    TOMB, //25
    TAROT, //26
    BEETHOVEN, //27
    IMPERMAX, //28
    TETU_SF, //29
    ALPACA, //30
    MARKET, //31
    UNIVERSE, //32
    MAI_BAL, //33
    UMA, //34
    SPHERE, //35
    BALANCER, //36
    SLOT_37, //37
    SLOT_38, //38
    SLOT_39, //39
    SLOT_40, //40
    SLOT_41, //41
    SLOT_42, //42
    SLOT_43, //43
    SLOT_44, //44
    SLOT_45, //45
    SLOT_46, //46
    SLOT_47, //47
    SLOT_48, //48
    SLOT_49, //49
    SLOT_50 //50
  }

  function STRATEGY_NAME() external view returns (string memory);


  function withdrawAllToVault() external;


  function withdrawToVault(uint256 amount) external;


  function salvage(address recipient, address token, uint256 amount) external;


  function doHardWork() external;


  function investAllUnderlying() external;


  function emergencyExit() external;


  function pauseInvesting() external;


  function continueInvesting() external;


  function rewardTokens() external view returns (address[] memory);


  function underlying() external view returns (address);


  function underlyingBalance() external view returns (uint256);


  function rewardPoolBalance() external view returns (uint256);


  function buyBackRatio() external view returns (uint256);


  function unsalvageableTokens(address token) external view returns (bool);


  function vault() external view returns (address);


  function investedUnderlyingBalance() external view returns (uint256);


  function platform() external view returns (Platform);


  function assets() external view returns (address[] memory);


  function pausedInvesting() external view returns (bool);


  function readyToClaim() external view returns (uint256[] memory);


  function poolTotalAmount() external view returns (uint256);

}// ISC

pragma solidity 0.8.4;

interface IStrategySplitter {


  function strategies(uint idx) external view returns (address);


  function strategiesRatios(address strategy) external view returns (uint);


  function withdrawRequestsCalls(address user) external view returns (uint);


  function addStrategy(address _strategy) external;


  function removeStrategy(address _strategy) external;


  function setStrategyRatios(address[] memory _strategies, uint[] memory _ratios) external;


  function strategiesInited() external view returns (bool);


  function needRebalance() external view returns (uint);


  function wantToWithdraw() external view returns (uint);


  function maxCheapWithdraw() external view returns (uint);


  function strategiesLength() external view returns (uint);


  function allStrategies() external view returns (address[] memory);


  function strategyRewardTokens() external view returns (address[] memory);


}// ISC

pragma solidity 0.8.4;

interface ISmartVault {


  function setStrategy(address _strategy) external;


  function changeActivityStatus(bool _active) external;


  function changeProtectionMode(bool _active) external;


  function changePpfsDecreaseAllowed(bool _value) external;


  function setLockPeriod(uint256 _value) external;


  function setLockPenalty(uint256 _value) external;


  function setToInvest(uint256 _value) external;


  function doHardWork() external;


  function rebalance() external;


  function disableLock() external;


  function notifyTargetRewardAmount(address _rewardToken, uint256 reward) external;


  function notifyRewardWithoutPeriodChange(address _rewardToken, uint256 reward) external;


  function deposit(uint256 amount) external;


  function depositAndInvest(uint256 amount) external;


  function depositFor(uint256 amount, address holder) external;


  function withdraw(uint256 numberOfShares) external;


  function exit() external;


  function getAllRewards() external;


  function getReward(address rt) external;


  function underlying() external view returns (address);


  function strategy() external view returns (address);


  function getRewardTokenIndex(address rt) external view returns (uint256);


  function getPricePerFullShare() external view returns (uint256);


  function underlyingUnit() external view returns (uint256);


  function duration() external view returns (uint256);


  function underlyingBalanceInVault() external view returns (uint256);


  function underlyingBalanceWithInvestment() external view returns (uint256);


  function underlyingBalanceWithInvestmentForHolder(address holder) external view returns (uint256);


  function availableToInvestOut() external view returns (uint256);


  function earned(address rt, address account) external view returns (uint256);


  function earnedWithBoost(address rt, address account) external view returns (uint256);


  function rewardPerToken(address rt) external view returns (uint256);


  function lastTimeRewardApplicable(address rt) external view returns (uint256);


  function rewardTokensLength() external view returns (uint256);


  function active() external view returns (bool);


  function rewardTokens() external view returns (address[] memory);


  function periodFinishForToken(address _rt) external view returns (uint256);


  function rewardRateForToken(address _rt) external view returns (uint256);


  function lastUpdateTimeForToken(address _rt) external view returns (uint256);


  function rewardPerTokenStoredForToken(address _rt) external view returns (uint256);


  function userRewardPerTokenPaidForToken(address _rt, address account) external view returns (uint256);


  function rewardsForToken(address _rt, address account) external view returns (uint256);


  function userLastWithdrawTs(address _user) external view returns (uint256);


  function userLastDepositTs(address _user) external view returns (uint256);


  function userBoostTs(address _user) external view returns (uint256);


  function userLockTs(address _user) external view returns (uint256);


  function addRewardToken(address rt) external;


  function removeRewardToken(address rt) external;


  function stop() external;


  function ppfsDecreaseAllowed() external view returns (bool);


  function lockPeriod() external view returns (uint256);


  function lockPenalty() external view returns (uint256);


  function toInvest() external view returns (uint256);


  function depositFeeNumerator() external view returns (uint256);


  function lockAllowed() external view returns (bool);


  function protectionMode() external view returns (bool);

}// ISC

pragma solidity 0.8.4;

interface IFeeRewardForwarder {

  function distribute(uint256 _amount, address _token, address _vault) external returns (uint256);


  function notifyPsPool(address _token, uint256 _amount) external returns (uint256);


  function notifyCustomPool(address _token, address _rewardPool, uint256 _maxBuyback) external returns (uint256);


  function liquidate(address tokenIn, address tokenOut, uint256 amount) external returns (uint256);

}// ISC

pragma solidity 0.8.4;

interface IBookkeeper {


  struct PpfsChange {
    address vault;
    uint256 block;
    uint256 time;
    uint256 value;
    uint256 oldBlock;
    uint256 oldTime;
    uint256 oldValue;
  }

  struct HardWork {
    address strategy;
    uint256 block;
    uint256 time;
    uint256 targetTokenAmount;
  }

  function addVault(address _vault) external;


  function addStrategy(address _strategy) external;


  function registerStrategyEarned(uint256 _targetTokenAmount) external;


  function registerFundKeeperEarned(address _token, uint256 _fundTokenAmount) external;


  function registerUserAction(address _user, uint256 _amount, bool _deposit) external;


  function registerVaultTransfer(address from, address to, uint256 amount) external;


  function registerUserEarned(address _user, address _vault, address _rt, uint256 _amount) external;


  function registerPpfsChange(address vault, uint256 value) external;


  function registerRewardDistribution(address vault, address token, uint256 amount) external;


  function vaults() external view returns (address[] memory);


  function vaultsLength() external view returns (uint256);


  function strategies() external view returns (address[] memory);


  function strategiesLength() external view returns (uint256);


  function lastPpfsChange(address vault) external view returns (PpfsChange memory);


  function targetTokenEarned(address strategy) external view returns (uint256);


  function vaultUsersBalances(address vault, address user) external view returns (uint256);


  function userEarned(address user, address vault, address token) external view returns (uint256);


  function lastHardWork(address vault) external view returns (HardWork memory);


  function vaultUsersQuantity(address vault) external view returns (uint256);


  function fundKeeperEarned(address vault) external view returns (uint256);


  function vaultRewards(address vault, address token, uint256 idx) external view returns (uint256);


  function vaultRewardsLength(address vault, address token) external view returns (uint256);


  function strategyEarnedSnapshots(address strategy, uint256 idx) external view returns (uint256);


  function strategyEarnedSnapshotsTime(address strategy, uint256 idx) external view returns (uint256);


  function strategyEarnedSnapshotsLength(address strategy) external view returns (uint256);

}// ISC

pragma solidity 0.8.4;

interface IUpgradeSource {


  function scheduleUpgrade(address impl) external;


  function finalizeUpgrade() external;


  function shouldUpgrade() external view returns (bool, address);


}// ISC

pragma solidity 0.8.4;

interface IFundKeeper {


  function withdrawToController(address _token, uint256 amount) external;


}// ISC

pragma solidity 0.8.4;

interface ITetuProxy {


  function upgrade(address _newImplementation) external;


  function implementation() external returns (address);


}// ISC

pragma solidity 0.8.4;

interface IMintHelper {


  function mintAndDistribute(
    uint256 totalAmount,
    address _distributor,
    address _otherNetworkFund,
    bool mintAllAvailable
  ) external;


  function devFundsList(uint256 idx) external returns (address);


}// ISC

pragma solidity 0.8.4;

interface IAnnouncer {


  enum TimeLockOpCodes {
    Governance, // 0
    Dao, // 1
    FeeRewardForwarder, // 2
    Bookkeeper, // 3
    MintHelper, // 4
    RewardToken, // 5
    FundToken, // 6
    PsVault, // 7
    Fund, // 8
    PsRatio, // 9
    FundRatio, // 10
    ControllerTokenMove, // 11
    StrategyTokenMove, // 12
    FundTokenMove, // 13
    TetuProxyUpdate, // 14
    StrategyUpgrade, // 15
    Mint, // 16
    Announcer, // 17
    ZeroPlaceholder, //18
    VaultController, //19
    RewardBoostDuration, //20
    RewardRatioWithoutBoost, //21
    VaultStop //22
  }

  struct TimeLockInfo {
    TimeLockOpCodes opCode;
    bytes32 opHash;
    address target;
    address[] adrValues;
    uint256[] numValues;
  }

  function clearAnnounce(bytes32 opHash, TimeLockOpCodes opCode, address target) external;


  function timeLockSchedule(bytes32 opHash) external returns (uint256);


  function timeLockInfo(uint256 idx) external returns (TimeLockInfo memory);


  function announceRatioChange(TimeLockOpCodes opCode, uint256 numerator, uint256 denominator) external;


}// ISC

pragma solidity 0.8.4;

interface IBalancingStrategy {


  function rebalanceAllPipes() external;


}// ISC

pragma solidity 0.8.4;

interface IController {


  function addVaultsAndStrategies(address[] memory _vaults, address[] memory _strategies) external;


  function addStrategy(address _strategy) external;


  function governance() external view returns (address);


  function dao() external view returns (address);


  function bookkeeper() external view returns (address);


  function feeRewardForwarder() external view returns (address);


  function mintHelper() external view returns (address);


  function rewardToken() external view returns (address);


  function fundToken() external view returns (address);


  function psVault() external view returns (address);


  function fund() external view returns (address);


  function distributor() external view returns (address);


  function announcer() external view returns (address);


  function vaultController() external view returns (address);


  function whiteList(address _target) external view returns (bool);


  function vaults(address _target) external view returns (bool);


  function strategies(address _target) external view returns (bool);


  function psNumerator() external view returns (uint256);


  function psDenominator() external view returns (uint256);


  function fundNumerator() external view returns (uint256);


  function fundDenominator() external view returns (uint256);


  function isAllowedUser(address _adr) external view returns (bool);


  function isDao(address _adr) external view returns (bool);


  function isHardWorker(address _adr) external view returns (bool);


  function isRewardDistributor(address _adr) external view returns (bool);


  function isPoorRewardConsumer(address _adr) external view returns (bool);


  function isValidVault(address _vault) external view returns (bool);


  function isValidStrategy(address _strategy) external view returns (bool);


  function rebalance(address _strategy) external;


  function setPSNumeratorDenominator(uint256 numerator, uint256 denominator) external;


  function setFundNumeratorDenominator(uint256 numerator, uint256 denominator) external;


  function changeWhiteListStatus(address[] calldata _targets, bool status) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
  bool private _initialized;

  bool private _initializing;

  modifier initializer() {
    require(_initializing || !_initialized, "Initializable: contract is already initialized");

    bool isTopLevelCall = !_initializing;
    if (isTopLevelCall) {
      _initializing = true;
      _initialized = true;
    }

    _;

    if (isTopLevelCall) {
      _initializing = false;
    }
  }
}// ISC

pragma solidity 0.8.4;


abstract contract ControllerStorage is Initializable, IController {

  mapping(bytes32 => uint256) private uintStorage;
  mapping(bytes32 => address) private addressStorage;

  event UpdatedAddressSlot(string indexed name, address oldValue, address newValue);
  event UpdatedUint256Slot(string indexed name, uint256 oldValue, uint256 newValue);

  function initializeControllerStorage(
    address __governance
  ) public initializer {
    _setGovernance(__governance);
  }


  function _setGovernance(address _address) internal {
    emit UpdatedAddressSlot("governance", _governance(), _address);
    setAddress("governance", _address);
  }

  function governance() external override view returns (address) {
    return _governance();
  }

  function _governance() internal view returns (address) {
    return getAddress("governance");
  }

  function _setDao(address _address) internal {
    emit UpdatedAddressSlot("dao", _dao(), _address);
    setAddress("dao", _address);
  }

  function dao() external override view returns (address) {
    return _dao();
  }

  function _dao() internal view returns (address) {
    return getAddress("dao");
  }

  function _setFeeRewardForwarder(address _address) internal {
    emit UpdatedAddressSlot("feeRewardForwarder", feeRewardForwarder(), _address);
    setAddress("feeRewardForwarder", _address);
  }

  function feeRewardForwarder() public override view returns (address) {
    return getAddress("feeRewardForwarder");
  }

  function _setBookkeeper(address _address) internal {
    emit UpdatedAddressSlot("bookkeeper", _bookkeeper(), _address);
    setAddress("bookkeeper", _address);
  }

  function bookkeeper() external override view returns (address) {
    return _bookkeeper();
  }

  function _bookkeeper() internal view returns (address) {
    return getAddress("bookkeeper");
  }

  function _setMintHelper(address _address) internal {
    emit UpdatedAddressSlot("mintHelper", mintHelper(), _address);
    setAddress("mintHelper", _address);
  }

  function mintHelper() public override view returns (address) {
    return getAddress("mintHelper");
  }

  function _setRewardToken(address _address) internal {
    emit UpdatedAddressSlot("rewardToken", rewardToken(), _address);
    setAddress("rewardToken", _address);
  }

  function rewardToken() public override view returns (address) {
    return getAddress("rewardToken");
  }

  function _setFundToken(address _address) internal {
    emit UpdatedAddressSlot("fundToken", fundToken(), _address);
    setAddress("fundToken", _address);
  }

  function fundToken() public override view returns (address) {
    return getAddress("fundToken");
  }

  function _setPsVault(address _address) internal {
    emit UpdatedAddressSlot("psVault", psVault(), _address);
    setAddress("psVault", _address);
  }

  function psVault() public override view returns (address) {
    return getAddress("psVault");
  }

  function _setFund(address _address) internal {
    emit UpdatedAddressSlot("fund", fund(), _address);
    setAddress("fund", _address);
  }

  function fund() public override view returns (address) {
    return getAddress("fund");
  }

  function _setDistributor(address _address) internal {
    emit UpdatedAddressSlot("distributor", distributor(), _address);
    setAddress("distributor", _address);
  }

  function distributor() public override view returns (address) {
    return getAddress("distributor");
  }

  function _setAnnouncer(address _address) internal {
    emit UpdatedAddressSlot("announcer", _announcer(), _address);
    setAddress("announcer", _address);
  }

  function announcer() external override view returns (address) {
    return _announcer();
  }

  function _announcer() internal view returns (address) {
    return getAddress("announcer");
  }

  function _setVaultController(address _address) internal {
    emit UpdatedAddressSlot("vaultController", vaultController(), _address);
    setAddress("vaultController", _address);
  }

  function vaultController() public override view returns (address) {
    return getAddress("vaultController");
  }

  function _setPsNumerator(uint256 _value) internal {
    emit UpdatedUint256Slot("psNumerator", psNumerator(), _value);
    setUint256("psNumerator", _value);
  }

  function psNumerator() public view override returns (uint256) {
    return getUint256("psNumerator");
  }

  function _setPsDenominator(uint256 _value) internal {
    emit UpdatedUint256Slot("psDenominator", psDenominator(), _value);
    setUint256("psDenominator", _value);
  }

  function psDenominator() public view override returns (uint256) {
    return getUint256("psDenominator");
  }

  function _setFundNumerator(uint256 _value) internal {
    emit UpdatedUint256Slot("fundNumerator", fundNumerator(), _value);
    setUint256("fundNumerator", _value);
  }

  function fundNumerator() public view override returns (uint256) {
    return getUint256("fundNumerator");
  }

  function _setFundDenominator(uint256 _value) internal {
    emit UpdatedUint256Slot("fundDenominator", fundDenominator(), _value);
    setUint256("fundDenominator", _value);
  }

  function fundDenominator() public view override returns (uint256) {
    return getUint256("fundDenominator");
  }


  function setAddress(string memory key, address _address) private {
    addressStorage[keccak256(abi.encodePacked(key))] = _address;
  }

  function getAddress(string memory key) private view returns (address) {
    return addressStorage[keccak256(abi.encodePacked(key))];
  }

  function setUint256(string memory key, uint256 _value) private {
    uintStorage[keccak256(abi.encodePacked(key))] = _value;
  }

  function getUint256(string memory key) private view returns (uint256) {
    return uintStorage[keccak256(abi.encodePacked(key))];
  }

  uint256[50] private ______gap;
}// ISC

pragma solidity 0.8.4;

interface IControllable {


  function isController(address _contract) external view returns (bool);


  function isGovernance(address _contract) external view returns (bool);


}// ISC

pragma solidity 0.8.4;

interface IControllableExtended {


  function created() external view returns (uint256 ts);


  function controller() external view returns (address adr);


}// ISC

pragma solidity 0.8.4;


abstract contract ControllableV2 is Initializable, IControllable, IControllableExtended {

  bytes32 internal constant _CONTROLLER_SLOT = bytes32(uint256(keccak256("eip1967.controllable.controller")) - 1);
  bytes32 internal constant _CREATED_SLOT = bytes32(uint256(keccak256("eip1967.controllable.created")) - 1);
  bytes32 internal constant _CREATED_BLOCK_SLOT = bytes32(uint256(keccak256("eip1967.controllable.created_block")) - 1);

  event ContractInitialized(address controller, uint ts, uint block);

  function initializeControllable(address __controller) public initializer {
    _setController(__controller);
    _setCreated(block.timestamp);
    _setCreatedBlock(block.number);
    emit ContractInitialized(__controller, block.timestamp, block.number);
  }

  function isController(address _value) external override view returns (bool) {
    return _isController(_value);
  }

  function _isController(address _value) internal view returns (bool) {
    return _value == _controller();
  }

  function isGovernance(address _value) external override view returns (bool) {
    return _isGovernance(_value);
  }

  function _isGovernance(address _value) internal view returns (bool) {
    return IController(_controller()).governance() == _value;
  }


  function controller() external view override returns (address) {
    return _controller();
  }

  function _controller() internal view returns (address result) {
    bytes32 slot = _CONTROLLER_SLOT;
    assembly {
      result := sload(slot)
    }
  }

  function _setController(address _newController) private {
    require(_newController != address(0));
    bytes32 slot = _CONTROLLER_SLOT;
    assembly {
      sstore(slot, _newController)
    }
  }

  function created() external view override returns (uint256 ts) {
    bytes32 slot = _CREATED_SLOT;
    assembly {
      ts := sload(slot)
    }
  }

  function _setCreated(uint256 _value) private {
    bytes32 slot = _CREATED_SLOT;
    assembly {
      sstore(slot, _value)
    }
  }

  function createdBlock() external view returns (uint256 ts) {
    bytes32 slot = _CREATED_BLOCK_SLOT;
    assembly {
      ts := sload(slot)
    }
  }

  function _setCreatedBlock(uint256 _value) private {
    bytes32 slot = _CREATED_BLOCK_SLOT;
    assembly {
      sstore(slot, _value)
    }
  }

}// ISC

pragma solidity 0.8.4;


contract Controller is Initializable, ControllableV2, ControllerStorage {

  using SafeERC20 for IERC20;
  using Address for address;

  string public constant VERSION = "1.4.1";

  mapping(address => bool) public override whiteList;
  mapping(address => bool) public override vaults;
  mapping(address => bool) public override strategies;
  mapping(address => bool) public hardWorkers;
  mapping(address => bool) public rewardDistribution;
  mapping(address => bool) public pureRewardConsumers;


  event HardWorkerAdded(address value);
  event HardWorkerRemoved(address value);
  event WhiteListStatusChanged(address target, bool status);
  event VaultAndStrategyAdded(address vault, address strategy);
  event ControllerTokenMoved(address indexed recipient, address indexed token, uint256 amount);
  event StrategyTokenMoved(address indexed strategy, address indexed token, uint256 amount);
  event FundKeeperTokenMoved(address indexed fund, address indexed token, uint256 amount);
  event SharePriceChangeLog(
    address indexed vault,
    address indexed strategy,
    uint256 oldSharePrice,
    uint256 newSharePrice,
    uint256 timestamp
  );
  event VaultStrategyChanged(address vault, address oldStrategy, address newStrategy);
  event ProxyUpgraded(address target, address oldLogic, address newLogic);
  event Minted(
    address mintHelper,
    uint totalAmount,
    address distributor,
    address otherNetworkFund,
    bool mintAllAvailable
  );
  event DistributorChanged(address distributor);

  function initialize() external initializer {

    ControllableV2.initializeControllable(address(this));
    ControllerStorage.initializeControllerStorage(
      msg.sender
    );
    setPSNumeratorDenominator(1000, 1000);
    setFundNumeratorDenominator(100, 1000);
  }


  function onlyGovernance() view private {

    require(_governance() == msg.sender, "C: Not governance");
  }

  function onlyGovernanceOrDao() view private {

    require(_governance() == msg.sender || _dao() == msg.sender, "C: Not governance or dao");
  }

  function timeLock(
    bytes32 opHash,
    IAnnouncer.TimeLockOpCodes opCode,
    bool isEmptyValue,
    address target
  ) private {

    if (!isEmptyValue) {
      require(_announcer() != address(0), "C: Zero announcer");
      require(IAnnouncer(_announcer()).timeLockSchedule(opHash) > 0, "C: Not announced");
      require(IAnnouncer(_announcer()).timeLockSchedule(opHash) < block.timestamp, "C: Too early");
      IAnnouncer(_announcer()).clearAnnounce(opHash, opCode, target);
    }
  }




  function setVaultStrategyBatch(address[] calldata _vaults, address[] calldata _strategies) external {

    onlyGovernance();
    require(_vaults.length == _strategies.length, "C: Wrong arrays");
    for (uint256 i = 0; i < _vaults.length; i++) {
      _setVaultStrategy(_vaults[i], _strategies[i]);
    }
  }

  function _setVaultStrategy(address _target, address _strategy) private {

    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.StrategyUpgrade, _target, _strategy)),
      IAnnouncer.TimeLockOpCodes.StrategyUpgrade,
      ISmartVault(_target).strategy() == address(0),
      _target
    );
    emit VaultStrategyChanged(_target, ISmartVault(_target).strategy(), _strategy);
    ISmartVault(_target).setStrategy(_strategy);
  }

  function addStrategiesToSplitter(address _splitter, address[] calldata _strategies) external {

    onlyGovernance();
    for (uint256 i = 0; i < _strategies.length; i++) {
      _addStrategyToSplitter(_splitter, _strategies[i]);
    }
  }

  function _addStrategyToSplitter(address _splitter, address _strategy) internal {

    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.StrategyUpgrade, _splitter, _strategy)),
      IAnnouncer.TimeLockOpCodes.StrategyUpgrade,
      !IStrategySplitter(_splitter).strategiesInited(),
      _splitter
    );
    IStrategySplitter(_splitter).addStrategy(_strategy);
    rewardDistribution[_strategy] = true;
    if (!strategies[_strategy]) {
      strategies[_strategy] = true;
      IBookkeeper(_bookkeeper()).addStrategy(_strategy);
    }
  }

  function upgradeTetuProxyBatch(
    address[] calldata _contracts,
    address[] calldata _implementations
  ) external {

    onlyGovernance();
    require(_contracts.length == _implementations.length, "wrong arrays");
    for (uint256 i = 0; i < _contracts.length; i++) {
      _upgradeTetuProxy(_contracts[i], _implementations[i]);
    }
  }

  function _upgradeTetuProxy(address _contract, address _implementation) private {

    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.TetuProxyUpdate, _contract, _implementation)),
      IAnnouncer.TimeLockOpCodes.TetuProxyUpdate,
      false,
      _contract
    );
    emit ProxyUpgraded(_contract, ITetuProxy(_contract).implementation(), _implementation);
    ITetuProxy(_contract).upgrade(_implementation);
  }

  function mintAndDistribute(
    uint256 totalAmount,
    bool mintAllAvailable
  ) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.Mint, totalAmount, distributor(), fund(), mintAllAvailable)),
      IAnnouncer.TimeLockOpCodes.Mint,
      false,
      address(0)
    );
    require(distributor() != address(0), "C: Zero distributor");
    require(fund() != address(0), "C: Zero fund");
    IMintHelper(mintHelper()).mintAndDistribute(totalAmount, distributor(), fund(), mintAllAvailable);
    emit Minted(mintHelper(), totalAmount, distributor(), fund(), mintAllAvailable);
  }


  function setGovernance(address newValue) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.Governance, newValue)),
      IAnnouncer.TimeLockOpCodes.Governance,
      _governance() == address(0),
      address(0)
    );
    _setGovernance(newValue);
  }

  function setDao(address newValue) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.Dao, newValue)),
      IAnnouncer.TimeLockOpCodes.Dao,
      _dao() == address(0),
      address(0)
    );
    _setDao(newValue);
  }

  function setFeeRewardForwarder(address _feeRewardForwarder) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.FeeRewardForwarder, _feeRewardForwarder)),
      IAnnouncer.TimeLockOpCodes.FeeRewardForwarder,
      feeRewardForwarder() == address(0),
      address(0)
    );
    rewardDistribution[feeRewardForwarder()] = false;
    _setFeeRewardForwarder(_feeRewardForwarder);
    rewardDistribution[feeRewardForwarder()] = true;
  }

  function setBookkeeper(address newValue) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.Bookkeeper, newValue)),
      IAnnouncer.TimeLockOpCodes.Bookkeeper,
      _bookkeeper() == address(0),
      address(0)
    );
    _setBookkeeper(newValue);
  }

  function setMintHelper(address _newValue) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.MintHelper, _newValue)),
      IAnnouncer.TimeLockOpCodes.MintHelper,
      mintHelper() == address(0),
      address(0)
    );
    _setMintHelper(_newValue);
    require(IMintHelper(mintHelper()).devFundsList(0) != address(0), "C: Wrong");
  }

  function setRewardToken(address _newValue) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.RewardToken, _newValue)),
      IAnnouncer.TimeLockOpCodes.RewardToken,
      rewardToken() == address(0),
      address(0)
    );
    _setRewardToken(_newValue);
  }

  function setFundToken(address _newValue) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.FundToken, _newValue)),
      IAnnouncer.TimeLockOpCodes.FundToken,
      fundToken() == address(0),
      address(0)
    );
    _setFundToken(_newValue);
  }

  function setPsVault(address _newValue) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.PsVault, _newValue)),
      IAnnouncer.TimeLockOpCodes.PsVault,
      psVault() == address(0),
      address(0)
    );
    _setPsVault(_newValue);
  }

  function setFund(address _newValue) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.Fund, _newValue)),
      IAnnouncer.TimeLockOpCodes.Fund,
      fund() == address(0),
      address(0)
    );
    _setFund(_newValue);
  }

  function setAnnouncer(address _newValue) external {

    onlyGovernance();
    bytes32 opHash = keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.Announcer, _newValue));
    if (_announcer() != address(0)) {
      require(IAnnouncer(_announcer()).timeLockSchedule(opHash) > 0, "C: Not announced");
      require(IAnnouncer(_announcer()).timeLockSchedule(opHash) < block.timestamp, "C: Too early");
    }

    _setAnnouncer(_newValue);

    IAnnouncer.TimeLockInfo memory info = IAnnouncer(_announcer()).timeLockInfo(0);
    require(info.opCode == IAnnouncer.TimeLockOpCodes.ZeroPlaceholder, "C: Wrong");
  }

  function setVaultController(address _newValue) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.VaultController, _newValue)),
      IAnnouncer.TimeLockOpCodes.VaultController,
      vaultController() == address(0),
      address(0)
    );
    _setVaultController(_newValue);
  }


  function setPSNumeratorDenominator(uint256 numerator, uint256 denominator) public override {

    onlyGovernanceOrDao();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.PsRatio, numerator, denominator)),
      IAnnouncer.TimeLockOpCodes.PsRatio,
      psNumerator() == 0 && psDenominator() == 0,
      address(0)
    );
    _setPsNumerator(numerator);
    _setPsDenominator(denominator);
  }

  function setFundNumeratorDenominator(uint256 numerator, uint256 denominator) public override {

    onlyGovernanceOrDao();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.FundRatio, numerator, denominator)),
      IAnnouncer.TimeLockOpCodes.FundRatio,
      fundNumerator() == 0 && fundDenominator() == 0,
      address(0)
    );
    _setFundNumerator(numerator);
    _setFundDenominator(denominator);
  }


  function controllerTokenMove(address _recipient, address _token, uint256 _amount) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.ControllerTokenMove, _recipient, _token, _amount)),
      IAnnouncer.TimeLockOpCodes.ControllerTokenMove,
      false,
      address(0)
    );
    IERC20(_token).safeTransfer(_recipient, _amount);
    emit ControllerTokenMoved(_recipient, _token, _amount);
  }

  function strategyTokenMove(address _strategy, address _token, uint256 _amount) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.StrategyTokenMove, _strategy, _token, _amount)),
      IAnnouncer.TimeLockOpCodes.StrategyTokenMove,
      false,
      address(0)
    );
    IStrategy(_strategy).salvage(_governance(), _token, _amount);
    emit StrategyTokenMoved(_strategy, _token, _amount);
  }

  function fundKeeperTokenMove(address _fund, address _token, uint256 _amount) external {

    onlyGovernance();
    timeLock(
      keccak256(abi.encode(IAnnouncer.TimeLockOpCodes.FundTokenMove, _fund, _token, _amount)),
      IAnnouncer.TimeLockOpCodes.FundTokenMove,
      false,
      address(0)
    );
    IFundKeeper(_fund).withdrawToController(_token, _amount);
    emit FundKeeperTokenMoved(_fund, _token, _amount);
  }


  function setDistributor(address _distributor) external {

    onlyGovernance();
    require(_distributor != address(0));
    _setDistributor(_distributor);
    emit DistributorChanged(_distributor);
  }

  function setRewardDistribution(address[] calldata _newRewardDistribution, bool _flag) external {

    onlyGovernance();
    for (uint256 i = 0; i < _newRewardDistribution.length; i++) {
      rewardDistribution[_newRewardDistribution[i]] = _flag;
    }
  }

  function setPureRewardConsumers(address[] calldata _targets, bool _flag) external {

    onlyGovernance();
    for (uint256 i = 0; i < _targets.length; i++) {
      pureRewardConsumers[_targets[i]] = _flag;
    }
  }

  function addHardWorker(address _worker) external {

    onlyGovernance();
    require(_worker != address(0));
    hardWorkers[_worker] = true;
    emit HardWorkerAdded(_worker);
  }

  function removeHardWorker(address _worker) external {

    onlyGovernance();
    require(_worker != address(0));
    hardWorkers[_worker] = false;
    emit HardWorkerRemoved(_worker);
  }

  function changeWhiteListStatus(address[] calldata _targets, bool status) external override {

    onlyGovernanceOrDao();
    for (uint256 i = 0; i < _targets.length; i++) {
      whiteList[_targets[i]] = status;
      emit WhiteListStatusChanged(_targets[i], status);
    }
  }

  function addVaultsAndStrategies(address[] memory _vaults, address[] memory _strategies) external override {

    onlyGovernance();
    require(_vaults.length == _strategies.length, "arrays wrong length");
    for (uint256 i = 0; i < _vaults.length; i++) {
      _addVaultAndStrategy(_vaults[i], _strategies[i]);
    }
  }

  function _addVaultAndStrategy(address _vault, address _strategy) private {

    require(_vault != address(0), "new vault shouldn't be empty");
    require(!vaults[_vault], "vault already exists");
    require(!strategies[_strategy], "strategy already exists");
    require(_strategy != address(0), "new strategy must not be empty");
    require(IControllable(_vault).isController(address(this)));

    vaults[_vault] = true;
    IBookkeeper(_bookkeeper()).addVault(_vault);

    _setVaultStrategy(_vault, _strategy);
    emit VaultAndStrategyAdded(_vault, _strategy);
  }

  function addStrategy(address _strategy) external override {

    require(vaults[msg.sender], "C: Not vault");
    if (!strategies[_strategy]) {
      strategies[_strategy] = true;
      IBookkeeper(_bookkeeper()).addStrategy(_strategy);
    }
  }

  function doHardWork(address _vault) external {

    require(hardWorkers[msg.sender] || _isGovernance(msg.sender), "C: Not hardworker or governance");
    require(vaults[_vault], "C: Not vault");
    uint256 oldSharePrice = ISmartVault(_vault).getPricePerFullShare();
    ISmartVault(_vault).doHardWork();
    emit SharePriceChangeLog(
      _vault,
      ISmartVault(_vault).strategy(),
      oldSharePrice,
      ISmartVault(_vault).getPricePerFullShare(),
      block.timestamp
    );
  }

  function rebalance(address _strategy) external override {

    require(hardWorkers[msg.sender], "C: Not hardworker");
    require(strategies[_strategy], "C: Not strategy");
    IBalancingStrategy(_strategy).rebalanceAllPipes();
  }


  function isDao(address _adr) external view override returns (bool) {

    return _dao() == _adr;
  }

  function isHardWorker(address _adr) external override view returns (bool) {

    return hardWorkers[_adr] || _governance() == _adr;
  }

  function isRewardDistributor(address _adr) external override view returns (bool) {

    return rewardDistribution[_adr] || _governance() == _adr || strategies[_adr];
  }

  function isPoorRewardConsumer(address _adr) external override view returns (bool) {

    return pureRewardConsumers[_adr];
  }

  function isAllowedUser(address _adr) external view override returns (bool) {

    return isNotSmartContract(_adr)
    || whiteList[_adr]
    || _governance() == _adr
    || hardWorkers[_adr]
    || rewardDistribution[_adr]
    || pureRewardConsumers[_adr]
    || vaults[_adr]
    || strategies[_adr];
  }

  function isNotSmartContract(address _adr) private view returns (bool) {

    return _adr == tx.origin;
  }

  function isValidVault(address _vault) external override view returns (bool) {

    return vaults[_vault];
  }

  function isValidStrategy(address _strategy) external override view returns (bool) {

    return strategies[_strategy];
  }
}