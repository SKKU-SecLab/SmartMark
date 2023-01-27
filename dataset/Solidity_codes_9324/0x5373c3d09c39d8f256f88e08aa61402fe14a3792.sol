
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


contract Bookkeeper is IBookkeeper, Initializable, ControllableV2 {


  string public constant VERSION = "1.2.0";

  address[] public _vaults;
  address[] public _strategies;
  mapping(address => uint256) public override targetTokenEarned;
  mapping(address => HardWork) private _lastHardWork;
  mapping(address => mapping(address => uint256)) public override vaultUsersBalances;
  mapping(address => mapping(address => mapping(address => uint256))) public override userEarned;
  mapping(address => uint256) public override vaultUsersQuantity;
  mapping(address => PpfsChange) private _lastPpfsChange;
  mapping(address => uint256) public override fundKeeperEarned;
  mapping(address => mapping(address => uint256[])) public override vaultRewards;
  mapping(address => mapping(address => uint256)) public override vaultRewardsLength;
  mapping(address => uint256[]) public override strategyEarnedSnapshots;
  mapping(address => uint256[]) public override strategyEarnedSnapshotsTime;
  mapping(address => uint256) public override strategyEarnedSnapshotsLength;

  event RegisterVault(address value);
  event RemoveVault(address value);
  event RegisterStrategy(address value);
  event RemoveStrategy(address value);
  event RegisterStrategyEarned(address indexed strategy, uint256 amount);
  event RegisterFundKeeperEarned(address indexed token, uint256 amount);
  event RegisterUserAction(address indexed user, uint256 amount, bool deposit);
  event RegisterUserEarned(address indexed user, address vault, address token, uint256 amount);
  event RegisterPpfsChange(address indexed vault, uint256 oldValue, uint256 newValue);
  event RewardDistribution(address indexed vault, address token, uint256 amount, uint256 time);

  function initialize(address _controller) external initializer {

    ControllableV2.initializeControllable(_controller);
  }

  modifier onlyStrategy() {

    require(IController(_controller()).strategies(msg.sender), "B: Only exist strategy");
    _;
  }

  modifier onlyController() {

    require(_controller() == msg.sender, "B: Not controller");
    _;
  }


  modifier onlyControllerOrGovernance() {

    require(_isController(msg.sender) || _isGovernance(msg.sender), "B: Not controller or gov");
    _;
  }

  modifier onlyFeeRewardForwarderOrStrategy() {

    require(IController(_controller()).feeRewardForwarder() == msg.sender
      || IController(_controller()).strategies(msg.sender), "B: Only exist forwarder or strategy");
    _;
  }

  modifier onlyVault() {

    require(IController(_controller()).vaults(msg.sender), "B: Only exist vault");
    _;
  }

  function addVault(address _vault) public override onlyController {

    require(isVaultExist(_vault), "B: Vault is not registered in controller");
    _vaults.push(_vault);
    emit RegisterVault(_vault);
  }

  function addStrategy(address _strategy) public override onlyController {

    require(isStrategyExist(_strategy), "B: Strategy is not registered in controller");
    _strategies.push(_strategy);
    emit RegisterStrategy(_strategy);
  }

  function registerStrategyEarned(uint256 _targetTokenAmount) external override onlyStrategy {

    targetTokenEarned[msg.sender] = targetTokenEarned[msg.sender] + _targetTokenAmount;

    _lastHardWork[msg.sender] = HardWork(
      msg.sender,
      block.number,
      block.timestamp,
      _targetTokenAmount
    );
    emit RegisterStrategyEarned(msg.sender, _targetTokenAmount);
  }

  function registerFundKeeperEarned(address _token, uint256 _fundTokenAmount) external override onlyFeeRewardForwarderOrStrategy {

    fundKeeperEarned[_token] = fundKeeperEarned[_token] + _fundTokenAmount;
    emit RegisterFundKeeperEarned(_token, _fundTokenAmount);
  }

  function registerPpfsChange(address vault, uint256 value)
  external override onlyFeeRewardForwarderOrStrategy {

    PpfsChange memory lastPpfs = _lastPpfsChange[vault];
    _lastPpfsChange[vault] = PpfsChange(
      vault,
      block.number,
      block.timestamp,
      value,
      lastPpfs.block,
      lastPpfs.time,
      lastPpfs.value
    );
    emit RegisterPpfsChange(vault, lastPpfs.value, value);
  }

  function registerRewardDistribution(address vault, address rewardToken, uint256 amount)
  external override onlyVault {

    vaultRewards[vault][rewardToken].push(amount);
    vaultRewardsLength[vault][rewardToken] = vaultRewards[vault][rewardToken].length;

    address strategy = ISmartVault(vault).strategy();
    if (IStrategy(strategy).platform() == IStrategy.Platform.STRATEGY_SPLITTER) {
      address[] memory subStrategies = IStrategySplitter(strategy).allStrategies();
      for (uint i; i < subStrategies.length; i++) {
        address subStrategy = subStrategies[i];

        uint currentEarned = targetTokenEarned[subStrategy];
        uint currentLength = strategyEarnedSnapshotsLength[subStrategy];
        if (currentLength > 0) {
          uint prevEarned = strategyEarnedSnapshots[subStrategy][currentLength - 1];
          if (currentEarned == prevEarned) {
            continue;
          }
        }

        strategyEarnedSnapshots[subStrategy].push(currentEarned);
        strategyEarnedSnapshotsTime[subStrategy].push(block.timestamp);
        strategyEarnedSnapshotsLength[subStrategy] = strategyEarnedSnapshots[subStrategy].length;
      }
    } else {
      uint currentEarned = targetTokenEarned[strategy];
      uint currentLength = strategyEarnedSnapshotsLength[strategy];
      if (currentLength > 0) {
        uint prevEarned = strategyEarnedSnapshots[strategy][currentLength - 1];
        if (currentEarned != prevEarned) {
          strategyEarnedSnapshots[strategy].push(currentEarned);
          strategyEarnedSnapshotsTime[strategy].push(block.timestamp);
          strategyEarnedSnapshotsLength[strategy] = strategyEarnedSnapshots[strategy].length;
        }
      }
    }
    emit RewardDistribution(vault, rewardToken, amount, block.timestamp);
  }

  function registerUserAction(address _user, uint256 _amount, bool _deposit)
  external override onlyVault {

    if (vaultUsersBalances[msg.sender][_user] == 0) {
      vaultUsersQuantity[msg.sender] = vaultUsersQuantity[msg.sender] + 1;
    }
    if (_deposit) {
      vaultUsersBalances[msg.sender][_user] = vaultUsersBalances[msg.sender][_user] + _amount;
    } else {
      if (vaultUsersBalances[msg.sender][_user] >= _amount) {
        vaultUsersBalances[msg.sender][_user] = vaultUsersBalances[msg.sender][_user] - _amount;
      }
    }
    if (vaultUsersBalances[msg.sender][_user] == 0) {
      vaultUsersQuantity[msg.sender] = vaultUsersQuantity[msg.sender] - 1;
    }
    emit RegisterUserAction(_user, _amount, _deposit);
  }

  function registerVaultTransfer(address from, address to, uint256 amount) external override onlyVault {

    if (vaultUsersBalances[msg.sender][from] < amount || amount == 0) {
      return;
    }

    if (from == address(0) || to == address(0)) {
      return;
    }

    vaultUsersBalances[msg.sender][from] = vaultUsersBalances[msg.sender][from] - amount;

    if (vaultUsersBalances[msg.sender][to] == 0) {
      vaultUsersQuantity[msg.sender] = vaultUsersQuantity[msg.sender] + 1;
    }
    vaultUsersBalances[msg.sender][to] = vaultUsersBalances[msg.sender][to] + amount;

    if (vaultUsersBalances[msg.sender][from] == 0) {
      vaultUsersQuantity[msg.sender] = vaultUsersQuantity[msg.sender] - 1;
    }
  }

  function registerUserEarned(address _user, address _vault, address _rt, uint256 _amount)
  external override onlyVault {

    userEarned[_user][_vault][_rt] = userEarned[_user][_vault][_rt] + _amount;
    emit RegisterUserEarned(_user, _vault, _rt, _amount);
  }

  function vaults() external override view returns (address[] memory) {

    return _vaults;
  }

  function vaultsLength() external override view returns (uint256) {

    return _vaults.length;
  }

  function strategies() external override view returns (address[] memory) {

    return _strategies;
  }

  function strategiesLength() external override view returns (uint256) {

    return _strategies.length;
  }

  function lastHardWork(address strategy) external view override returns (HardWork memory) {

    return _lastHardWork[strategy];
  }

  function lastPpfsChange(address vault) external view override returns (PpfsChange memory) {

    return _lastPpfsChange[vault];
  }

  function isVaultExist(address _value) internal view returns (bool) {

    return IController(_controller()).isValidVault(_value);
  }

  function isStrategyExist(address _value) internal view returns (bool) {

    return IController(_controller()).isValidStrategy(_value);
  }

  function removeFromVaults(uint256 index) external onlyControllerOrGovernance {

    require(index < _vaults.length, "B: Wrong index");
    emit RemoveVault(_vaults[index]);
    _vaults[index] = _vaults[_vaults.length - 1];
    _vaults.pop();
  }

  function removeFromStrategies(uint256 index) external onlyControllerOrGovernance {

    require(index < _strategies.length, "B: Wrong index");
    emit RemoveStrategy(_strategies[index]);
    _strategies[index] = _strategies[_strategies.length - 1];
    _strategies.pop();
  }

}