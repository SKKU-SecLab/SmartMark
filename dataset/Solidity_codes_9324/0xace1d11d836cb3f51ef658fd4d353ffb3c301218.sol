pragma solidity 0.7.5;

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return div(a, b, 'SafeMath: division by zero');
  }

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b > 0, errorMessage);
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    return mod(a, b, 'SafeMath: modulo by zero');
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {

    require(b != 0, errorMessage);
    return a % b;
  }
}//Unlicense
pragma solidity 0.7.5;
pragma abicoder v2;

interface ITimelockExecutor {

  enum ActionsSetState {
    Queued,
    Executed,
    Canceled,
    Expired
  }

  struct ActionsSet {
    address[] targets;
    uint256[] values;
    string[] signatures;
    bytes[] calldatas;
    bool[] withDelegatecalls;
    uint256 executionTime;
    bool executed;
    bool canceled;
  }

  event ActionsSetQueued(
    uint256 id,
    address[] targets,
    uint256[] values,
    string[] signatures,
    bytes[] calldatas,
    bool[] withDelegatecalls,
    uint256 executionTime
  );

  event ActionsSetExecuted(uint256 id, address indexed initiatorExecution, bytes[] returnedData);

  event ActionsSetCanceled(uint256 id);

  event GuardianUpdate(address previousGuardian, address newGuardian);

  event DelayUpdate(uint256 previousDelay, uint256 newDelay);

  event GracePeriodUpdate(uint256 previousGracePeriod, uint256 newGracePeriod);

  event MinimumDelayUpdate(uint256 previousMinimumDelay, uint256 newMinimumDelay);

  event MaximumDelayUpdate(uint256 previousMaximumDelay, uint256 newMaximumDelay);

  function execute(uint256 actionsSetId) external payable;


  function cancel(uint256 actionsSetId) external;


  function getActionsSetById(uint256 actionsSetId) external view returns (ActionsSet memory);


  function getCurrentState(uint256 actionsSetId) external view returns (ActionsSetState);


  function isActionQueued(bytes32 actionHash) external view returns (bool);


  function updateGuardian(address guardian) external;


  function updateDelay(uint256 delay) external;


  function updateGracePeriod(uint256 gracePeriod) external;


  function updateMinimumDelay(uint256 minimumDelay) external;


  function updateMaximumDelay(uint256 maximumDelay) external;


  function getDelay() external view returns (uint256);


  function getGracePeriod() external view returns (uint256);


  function getMinimumDelay() external view returns (uint256);


  function getMaximumDelay() external view returns (uint256);


  function getGuardian() external view returns (address);


  function getActionsSetCount() external view returns (uint256);

}// agpl-3.0
pragma solidity 0.7.5;


abstract contract TimelockExecutorBase is ITimelockExecutor {
  using SafeMath for uint256;

  uint256 private _delay;
  uint256 private _gracePeriod;
  uint256 private _minimumDelay;
  uint256 private _maximumDelay;
  address private _guardian;
  uint256 private _actionsSetCounter;

  mapping(uint256 => ActionsSet) private _actionsSets;
  mapping(bytes32 => bool) private _queuedActions;

  modifier onlyGuardian() {
    require(msg.sender == _guardian, 'ONLY_BY_GUARDIAN');
    _;
  }

  modifier onlyThis() {
    require(msg.sender == address(this), 'UNAUTHORIZED_ORIGIN_ONLY_THIS');
    _;
  }

  constructor(
    uint256 delay,
    uint256 gracePeriod,
    uint256 minimumDelay,
    uint256 maximumDelay,
    address guardian
  ) {
    require(delay >= minimumDelay, 'DELAY_SHORTER_THAN_MINIMUM');
    require(delay <= maximumDelay, 'DELAY_LONGER_THAN_MAXIMUM');
    _delay = delay;
    _gracePeriod = gracePeriod;
    _minimumDelay = minimumDelay;
    _maximumDelay = maximumDelay;
    _guardian = guardian;
  }

  function execute(uint256 actionsSetId) external payable override {
    require(getCurrentState(actionsSetId) == ActionsSetState.Queued, 'ONLY_QUEUED_ACTIONS');

    ActionsSet storage actionsSet = _actionsSets[actionsSetId];
    require(block.timestamp >= actionsSet.executionTime, 'TIMELOCK_NOT_FINISHED');

    actionsSet.executed = true;
    uint256 actionCount = actionsSet.targets.length;

    bytes[] memory returnedData = new bytes[](actionCount);
    for (uint256 i = 0; i < actionCount; i++) {
      returnedData[i] = _executeTransaction(
        actionsSet.targets[i],
        actionsSet.values[i],
        actionsSet.signatures[i],
        actionsSet.calldatas[i],
        actionsSet.executionTime,
        actionsSet.withDelegatecalls[i]
      );
    }
    emit ActionsSetExecuted(actionsSetId, msg.sender, returnedData);
  }

  function cancel(uint256 actionsSetId) external override onlyGuardian {
    ActionsSetState state = getCurrentState(actionsSetId);
    require(state == ActionsSetState.Queued, 'ONLY_BEFORE_EXECUTED');

    ActionsSet storage actionsSet = _actionsSets[actionsSetId];
    actionsSet.canceled = true;
    for (uint256 i = 0; i < actionsSet.targets.length; i++) {
      _cancelTransaction(
        actionsSet.targets[i],
        actionsSet.values[i],
        actionsSet.signatures[i],
        actionsSet.calldatas[i],
        actionsSet.executionTime,
        actionsSet.withDelegatecalls[i]
      );
    }

    emit ActionsSetCanceled(actionsSetId);
  }

  function getActionsSetById(uint256 actionsSetId)
    external
    view
    override
    returns (ActionsSet memory)
  {
    return _actionsSets[actionsSetId];
  }

  function getCurrentState(uint256 actionsSetId) public view override returns (ActionsSetState) {
    require(_actionsSetCounter >= actionsSetId, 'INVALID_ACTION_ID');
    ActionsSet storage actionsSet = _actionsSets[actionsSetId];
    if (actionsSet.canceled) {
      return ActionsSetState.Canceled;
    } else if (actionsSet.executed) {
      return ActionsSetState.Executed;
    } else if (block.timestamp > actionsSet.executionTime.add(_gracePeriod)) {
      return ActionsSetState.Expired;
    } else {
      return ActionsSetState.Queued;
    }
  }

  function isActionQueued(bytes32 actionHash) public view override returns (bool) {
    return _queuedActions[actionHash];
  }

  function receiveFunds() external payable {}

  function updateGuardian(address guardian) external override onlyThis {
    emit GuardianUpdate(_guardian, guardian);
    _guardian = guardian;
  }

  function updateDelay(uint256 delay) external override onlyThis {
    _validateDelay(delay);
    emit DelayUpdate(_delay, delay);
    _delay = delay;
  }

  function updateGracePeriod(uint256 gracePeriod) external override onlyThis {
    emit GracePeriodUpdate(_gracePeriod, gracePeriod);
    _gracePeriod = gracePeriod;
  }

  function updateMinimumDelay(uint256 minimumDelay) external override onlyThis {
    uint256 previousMinimumDelay = _minimumDelay;
    _minimumDelay = minimumDelay;
    _validateDelay(_delay);
    emit MinimumDelayUpdate(previousMinimumDelay, minimumDelay);
  }

  function updateMaximumDelay(uint256 maximumDelay) external override onlyThis {
    uint256 previousMaximumDelay = _maximumDelay;
    _maximumDelay = maximumDelay;
    _validateDelay(_delay);
    emit MaximumDelayUpdate(previousMaximumDelay, maximumDelay);
  }

  function getDelay() external view override returns (uint256) {
    return _delay;
  }

  function getGracePeriod() external view override returns (uint256) {
    return _gracePeriod;
  }

  function getMinimumDelay() external view override returns (uint256) {
    return _minimumDelay;
  }

  function getMaximumDelay() external view override returns (uint256) {
    return _maximumDelay;
  }

  function getGuardian() external view override returns (address) {
    return _guardian;
  }

  function getActionsSetCount() external view override returns (uint256) {
    return _actionsSetCounter;
  }

  function executeDelegateCall(address target, bytes calldata data)
    external
    payable
    onlyThis
    returns (bool, bytes memory)
  {
    bool success;
    bytes memory resultData;
    (success, resultData) = target.delegatecall(data);
    return (success, resultData);
  }

  function _queue(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory calldatas,
    bool[] memory withDelegatecalls
  ) internal {
    require(targets.length != 0, 'INVALID_EMPTY_TARGETS');
    require(
      targets.length == values.length &&
        targets.length == signatures.length &&
        targets.length == calldatas.length &&
        targets.length == withDelegatecalls.length,
      'INCONSISTENT_PARAMS_LENGTH'
    );

    uint256 actionsSetId = _actionsSetCounter;
    uint256 executionTime = block.timestamp.add(_delay);
    _actionsSetCounter++;

    for (uint256 i = 0; i < targets.length; i++) {
      bytes32 actionHash =
        keccak256(
          abi.encode(
            targets[i],
            values[i],
            signatures[i],
            calldatas[i],
            executionTime,
            withDelegatecalls[i]
          )
        );
      require(!isActionQueued(actionHash), 'DUPLICATED_ACTION');
      _queuedActions[actionHash] = true;
    }

    ActionsSet storage actionsSet = _actionsSets[actionsSetId];
    actionsSet.targets = targets;
    actionsSet.values = values;
    actionsSet.signatures = signatures;
    actionsSet.calldatas = calldatas;
    actionsSet.withDelegatecalls = withDelegatecalls;
    actionsSet.executionTime = executionTime;

    emit ActionsSetQueued(
      actionsSetId,
      targets,
      values,
      signatures,
      calldatas,
      withDelegatecalls,
      executionTime
    );
  }

  function _executeTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) internal returns (bytes memory) {
    require(address(this).balance >= value, 'NOT_ENOUGH_CONTRACT_BALANCE');

    bytes32 actionHash =
      keccak256(abi.encode(target, value, signature, data, executionTime, withDelegatecall));
    _queuedActions[actionHash] = false;

    bytes memory callData;
    if (bytes(signature).length == 0) {
      callData = data;
    } else {
      callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
    }

    bool success;
    bytes memory resultData;
    if (withDelegatecall) {
      (success, resultData) = this.executeDelegateCall{value: value}(target, callData);
    } else {
      (success, resultData) = target.call{value: value}(callData);
    }
    return _verifyCallResult(success, resultData);
  }

  function _cancelTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) internal {
    bytes32 actionHash =
      keccak256(abi.encode(target, value, signature, data, executionTime, withDelegatecall));
    _queuedActions[actionHash] = false;
  }

  function _validateDelay(uint256 delay) internal view {
    require(delay >= _minimumDelay, 'DELAY_SHORTER_THAN_MINIMUM');
    require(delay <= _maximumDelay, 'DELAY_LONGER_THAN_MAXIMUM');
  }

  function _verifyCallResult(bool success, bytes memory returndata)
    private
    pure
    returns (bytes memory)
  {
    if (success) {
      return returndata;
    } else {
      if (returndata.length > 0) {

        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert('FAILED_ACTION_EXECUTION');
      }
    }
  }
}// agpl-3.0
pragma solidity 0.7.5;


contract ArcTimelock is TimelockExecutorBase {

  address private _ethereumGovernanceExecutor;

  event EthereumGovernanceExecutorUpdate(
    address previousEthereumGovernanceExecutor,
    address newEthereumGovernanceExecutor
  );

  modifier onlyEthereumGovernanceExecutor() {

    require(msg.sender == _ethereumGovernanceExecutor, 'UNAUTHORIZED_EXECUTOR');
    _;
  }

  constructor(
    address ethereumGovernanceExecutor,
    uint256 delay,
    uint256 gracePeriod,
    uint256 minimumDelay,
    uint256 maximumDelay,
    address guardian
  ) TimelockExecutorBase(delay, gracePeriod, minimumDelay, maximumDelay, guardian) {
    _ethereumGovernanceExecutor = ethereumGovernanceExecutor;
  }

  function queue(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory calldatas,
    bool[] memory withDelegatecalls
  ) external onlyEthereumGovernanceExecutor {

    _queue(targets, values, signatures, calldatas, withDelegatecalls);
  }

  function updateEthereumGovernanceExecutor(address ethereumGovernanceExecutor) external onlyThis {

    emit EthereumGovernanceExecutorUpdate(_ethereumGovernanceExecutor, ethereumGovernanceExecutor);
    _ethereumGovernanceExecutor = ethereumGovernanceExecutor;
  }

  function getEthereumGovernanceExecutor() external view returns (address) {

    return _ethereumGovernanceExecutor;
  }
}