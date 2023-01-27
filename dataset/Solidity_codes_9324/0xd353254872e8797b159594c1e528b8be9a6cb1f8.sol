
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


contract Announcer is ControllableV2, IAnnouncer {


  string public constant VERSION = "1.2.0";
  bytes32 internal constant _TIME_LOCK_SLOT = 0x244FE7C39AF244D294615908664E79A2F65DD3F4D5C387AF1D52197F465D1C2E;

  mapping(bytes32 => uint256) public override timeLockSchedule;
  TimeLockInfo[] private _timeLockInfos;
  mapping(TimeLockOpCodes => uint256) public timeLockIndexes;
  mapping(TimeLockOpCodes => mapping(address => uint256)) public multiTimeLockIndexes;
  mapping(TimeLockOpCodes => bool) public multiOpCodes;

  event AddressChangeAnnounce(TimeLockOpCodes opCode, address newAddress);
  event UintChangeAnnounce(TimeLockOpCodes opCode, uint256 newValue);
  event RatioChangeAnnounced(TimeLockOpCodes opCode, uint256 numerator, uint256 denominator);
  event TokenMoveAnnounced(TimeLockOpCodes opCode, address target, address token, uint256 amount);
  event ProxyUpgradeAnnounced(address _contract, address _implementation);
  event MintAnnounced(uint256 totalAmount, address _distributor, address _otherNetworkFund);
  event AnnounceClosed(bytes32 opHash);
  event StrategyUpgradeAnnounced(address _contract, address _implementation);
  event VaultStop(address _contract);

  constructor() {
    require(_TIME_LOCK_SLOT == bytes32(uint256(keccak256("eip1967.announcer.timeLock")) - 1), "wrong timeLock");
  }

  function initialize(address _controller, uint256 _timeLock) external initializer {

    ControllableV2.initializeControllable(_controller);

    bytes32 slot = _TIME_LOCK_SLOT;
    assembly {
      sstore(slot, _timeLock)
    }

    _timeLockInfos.push(TimeLockInfo(TimeLockOpCodes.ZeroPlaceholder, 0, address(0), new address[](0), new uint256[](0)));
  }

  modifier onlyGovernance() {

    require(_isGovernance(msg.sender), "not governance");
    _;
  }

  modifier onlyGovernanceOrDao() {

    require(_isGovernance(msg.sender)
      || IController(_controller()).isDao(msg.sender), "not governance or dao");
    _;
  }

  modifier onlyControlMembers() {

    require(
      _isGovernance(msg.sender)
      || _isController(msg.sender)
      || IController(_controller()).isDao(msg.sender)
      || IController(_controller()).vaultController() == msg.sender
    , "not control member");
    _;
  }


  function timeLock() public view returns (uint256 result) {

    bytes32 slot = _TIME_LOCK_SLOT;
    assembly {
      result := sload(slot)
    }
  }

  function timeLockInfosLength() external view returns (uint256) {

    return _timeLockInfos.length;
  }

  function timeLockInfo(uint256 idx) external override view returns (TimeLockInfo memory) {

    return _timeLockInfos[idx];
  }


  function announceAddressChange(TimeLockOpCodes opCode, address newAddress) external onlyGovernance {

    require(timeLockIndexes[opCode] == 0, "already announced");
    require(newAddress != address(0), "zero address");
    bytes32 opHash = keccak256(abi.encode(opCode, newAddress));
    timeLockSchedule[opHash] = block.timestamp + timeLock();

    address[] memory values = new address[](1);
    values[0] = newAddress;
    _timeLockInfos.push(TimeLockInfo(opCode, opHash, _controller(), values, new uint256[](0)));
    timeLockIndexes[opCode] = (_timeLockInfos.length - 1);

    emit AddressChangeAnnounce(opCode, newAddress);
  }

  function announceUintChange(TimeLockOpCodes opCode, uint256 newValue) external onlyGovernance {

    require(timeLockIndexes[opCode] == 0, "already announced");
    bytes32 opHash = keccak256(abi.encode(opCode, newValue));
    timeLockSchedule[opHash] = block.timestamp + timeLock();

    uint256[] memory values = new uint256[](1);
    values[0] = newValue;
    _timeLockInfos.push(TimeLockInfo(opCode, opHash, address(0), new address[](0), values));
    timeLockIndexes[opCode] = (_timeLockInfos.length - 1);

    emit UintChangeAnnounce(opCode, newValue);
  }

  function announceRatioChange(TimeLockOpCodes opCode, uint256 numerator, uint256 denominator) external override onlyGovernanceOrDao {

    require(timeLockIndexes[opCode] == 0, "already announced");
    require(numerator <= denominator, "invalid values");
    require(denominator != 0, "cannot divide by 0");
    bytes32 opHash = keccak256(abi.encode(opCode, numerator, denominator));
    timeLockSchedule[opHash] = block.timestamp + timeLock();

    uint256[] memory values = new uint256[](2);
    values[0] = numerator;
    values[1] = denominator;
    _timeLockInfos.push(TimeLockInfo(opCode, opHash, _controller(), new address[](0), values));
    timeLockIndexes[opCode] = (_timeLockInfos.length - 1);

    emit RatioChangeAnnounced(opCode, numerator, denominator);
  }

  function announceTokenMove(TimeLockOpCodes opCode, address target, address token, uint256 amount)
  external onlyGovernance {

    require(timeLockIndexes[opCode] == 0, "already announced");
    require(target != address(0), "zero target");
    require(token != address(0), "zero token");
    require(amount != 0, "zero amount");
    bytes32 opHash = keccak256(abi.encode(opCode, target, token, amount));
    timeLockSchedule[opHash] = block.timestamp + timeLock();

    address[] memory adrValues = new address[](1);
    adrValues[0] = token;
    uint256[] memory intValues = new uint256[](1);
    intValues[0] = amount;
    _timeLockInfos.push(TimeLockInfo(opCode, opHash, target, adrValues, intValues));
    timeLockIndexes[opCode] = (_timeLockInfos.length - 1);

    emit TokenMoveAnnounced(opCode, target, token, amount);
  }

  function announceMint(
    uint256 totalAmount,
    address _distributor,
    address _otherNetworkFund,
    bool mintAllAvailable
  ) external onlyGovernance {

    TimeLockOpCodes opCode = TimeLockOpCodes.Mint;

    require(timeLockIndexes[opCode] == 0, "already announced");
    require(totalAmount != 0 || mintAllAvailable, "zero amount");
    require(_distributor != address(0), "zero distributor");
    require(_otherNetworkFund != address(0), "zero fund");

    bytes32 opHash = keccak256(abi.encode(opCode, totalAmount, _distributor, _otherNetworkFund, mintAllAvailable));
    timeLockSchedule[opHash] = block.timestamp + timeLock();

    address[] memory adrValues = new address[](2);
    adrValues[0] = _distributor;
    adrValues[1] = _otherNetworkFund;
    uint256[] memory intValues = new uint256[](1);
    intValues[0] = totalAmount;

    address mintHelper = IController(_controller()).mintHelper();

    _timeLockInfos.push(TimeLockInfo(opCode, opHash, mintHelper, adrValues, intValues));
    timeLockIndexes[opCode] = _timeLockInfos.length - 1;

    emit MintAnnounced(totalAmount, _distributor, _otherNetworkFund);
  }

  function announceTetuProxyUpgradeBatch(address[] calldata _contracts, address[] calldata _implementations)
  external onlyGovernance {

    require(_contracts.length == _implementations.length, "wrong arrays");
    for (uint256 i = 0; i < _contracts.length; i++) {
      announceTetuProxyUpgrade(_contracts[i], _implementations[i]);
    }
  }

  function announceTetuProxyUpgrade(address _contract, address _implementation) public onlyGovernance {

    TimeLockOpCodes opCode = TimeLockOpCodes.TetuProxyUpdate;

    require(multiTimeLockIndexes[opCode][_contract] == 0, "already announced");
    require(_contract != address(0), "zero contract");
    require(_implementation != address(0), "zero implementation");

    bytes32 opHash = keccak256(abi.encode(opCode, _contract, _implementation));
    timeLockSchedule[opHash] = block.timestamp + timeLock();

    address[] memory values = new address[](1);
    values[0] = _implementation;
    _timeLockInfos.push(TimeLockInfo(opCode, opHash, _contract, values, new uint256[](0)));
    multiTimeLockIndexes[opCode][_contract] = (_timeLockInfos.length - 1);

    emit ProxyUpgradeAnnounced(_contract, _implementation);
  }

  function announceStrategyUpgrades(address[] calldata _targets, address[] calldata _strategies) external onlyGovernance {

    TimeLockOpCodes opCode = TimeLockOpCodes.StrategyUpgrade;
    require(_targets.length == _strategies.length, "wrong arrays");
    for (uint256 i = 0; i < _targets.length; i++) {
      require(multiTimeLockIndexes[opCode][_targets[i]] == 0, "already announced");
      bytes32 opHash = keccak256(abi.encode(opCode, _targets[i], _strategies[i]));
      timeLockSchedule[opHash] = block.timestamp + timeLock();

      address[] memory values = new address[](1);
      values[0] = _strategies[i];
      _timeLockInfos.push(TimeLockInfo(opCode, opHash, _targets[i], values, new uint256[](0)));
      multiTimeLockIndexes[opCode][_targets[i]] = (_timeLockInfos.length - 1);

      emit StrategyUpgradeAnnounced(_targets[i], _strategies[i]);
    }
  }

  function announceVaultStopBatch(address[] calldata _vaults) external onlyGovernance {

    TimeLockOpCodes opCode = TimeLockOpCodes.VaultStop;
    for (uint256 i = 0; i < _vaults.length; i++) {
      require(multiTimeLockIndexes[opCode][_vaults[i]] == 0, "already announced");
      bytes32 opHash = keccak256(abi.encode(opCode, _vaults[i]));
      timeLockSchedule[opHash] = block.timestamp + timeLock();

      _timeLockInfos.push(TimeLockInfo(opCode, opHash, _vaults[i], new address[](0), new uint256[](0)));
      multiTimeLockIndexes[opCode][_vaults[i]] = (_timeLockInfos.length - 1);

      emit VaultStop(_vaults[i]);
    }
  }

  function closeAnnounce(TimeLockOpCodes opCode, bytes32 opHash, address target) external onlyGovernance {

    clearAnnounce(opHash, opCode, target);
    emit AnnounceClosed(opHash);
  }

  function clearAnnounce(bytes32 opHash, TimeLockOpCodes opCode, address target) public override onlyControlMembers {

    timeLockSchedule[opHash] = 0;
    if (multiTimeLockIndexes[opCode][target] != 0) {
      multiTimeLockIndexes[opCode][target] = 0;
    } else {
      timeLockIndexes[opCode] = 0;
    }
  }

}