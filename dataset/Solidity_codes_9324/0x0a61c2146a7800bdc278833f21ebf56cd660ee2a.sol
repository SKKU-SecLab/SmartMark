
pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.8.4;

interface ICollectableDust {

  event DustSent(address _to, address token, uint256 amount);

  function sendDust(address _to, address _token, uint256 _amount) external;

}// MIT

pragma solidity 0.8.4;



abstract
contract CollectableDust is ICollectableDust {

  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;

  address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  EnumerableSet.AddressSet internal protocolTokens;

  constructor() {}

  function _addProtocolToken(address _token) internal {

    require(!protocolTokens.contains(_token), 'collectable-dust/token-is-part-of-the-protocol');
    protocolTokens.add(_token);
  }

  function _removeProtocolToken(address _token) internal {

    require(protocolTokens.contains(_token), 'collectable-dust/token-not-part-of-the-protocol');
    protocolTokens.remove(_token);
  }

  function _sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) internal {

    require(_to != address(0), 'collectable-dust/cant-send-dust-to-zero-address');
    require(!protocolTokens.contains(_token), 'collectable-dust/token-is-part-of-the-protocol');
    if (_token == ETH_ADDRESS) {
      payable(_to).transfer(_amount);
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
    emit DustSent(_to, _token, _amount);
  }
}// MIT
pragma solidity 0.8.4;

interface IGovernable {

  event PendingGovernorSet(address pendingGovernor);
  event GovernorAccepted();

  function setPendingGovernor(address _pendingGovernor) external;

  function acceptGovernor() external;


  function governor() external view returns (address _governor);

  function pendingGovernor() external view returns (address _pendingGovernor);


  function isGovernor(address _account) external view returns (bool _isGovernor);

}// MIT

pragma solidity 0.8.4;


abstract
contract Governable is IGovernable {

  address public override governor;
  address public override pendingGovernor;

  constructor(address _governor) {
    require(_governor != address(0), 'governable/governor-should-not-be-zero-address');
    governor = _governor;
  }

  function _setPendingGovernor(address _pendingGovernor) internal {

    require(_pendingGovernor != address(0), 'governable/pending-governor-should-not-be-zero-addres');
    pendingGovernor = _pendingGovernor;
    emit PendingGovernorSet(_pendingGovernor);
  }

  function _acceptGovernor() internal {

    governor = pendingGovernor;
    pendingGovernor = address(0);
    emit GovernorAccepted();
  }

  function isGovernor(address _account) public view override returns (bool _isGovernor) {

    return _account == governor;
  }

  modifier onlyGovernor {

    require(isGovernor(msg.sender), 'governable/only-governor');
    _;
  }

  modifier onlyPendingGovernor {

    require(msg.sender == pendingGovernor, 'governable/only-pending-governor');
    _;
  }
}// MIT
pragma solidity 0.8.4;

interface IStealthRelayer {

  function caller() external view returns (address _caller);


  function forceBlockProtection() external view returns (bool _forceBlockProtection);


  function jobs() external view returns (address[] memory _jobsList);


  function setForceBlockProtection(bool _forceBlockProtection) external;


  function addJobs(address[] calldata _jobsList) external;


  function addJob(address _job) external;


  function removeJobs(address[] calldata _jobsList) external;


  function removeJob(address _job) external;


  function execute(
    address _address,
    bytes memory _callData,
    bytes32 _stealthHash,
    uint256 _blockNumber
  ) external payable returns (bytes memory _returnData);


  function executeAndPay(
    address _address,
    bytes memory _callData,
    bytes32 _stealthHash,
    uint256 _blockNumber,
    uint256 _payment
  ) external payable returns (bytes memory _returnData);


  function executeWithoutBlockProtection(
    address _address,
    bytes memory _callData,
    bytes32 _stealthHash
  ) external payable returns (bytes memory _returnData);


  function executeWithoutBlockProtectionAndPay(
    address _job,
    bytes memory _callData,
    bytes32 _stealthHash,
    uint256 _payment
  ) external payable returns (bytes memory _returnData);

}// MIT
pragma solidity 0.8.4;

interface IStealthVault {

  event Bonded(address indexed _caller, uint256 _amount, uint256 _finalBond);
  event Unbonded(address indexed _caller, uint256 _amount, uint256 _finalBond);
  event ReportedHash(bytes32 _hash, address _reportedBy);
  event PenaltyApplied(bytes32 _hash, address _caller, uint256 _penalty, address _reportedBy);
  event ValidatedHash(bytes32 _hash, address _caller, uint256 _penalty);

  event StealthContractEnabled(address indexed _caller, address _contract);

  event StealthContractsEnabled(address indexed _caller, address[] _contracts);

  event StealthContractDisabled(address indexed _caller, address _contract);

  event StealthContractsDisabled(address indexed _caller, address[] _contracts);

  function isStealthVault() external pure returns (bool);


  function callers() external view returns (address[] memory _callers);


  function callerContracts(address _caller) external view returns (address[] memory _contracts);


  function gasBuffer() external view returns (uint256 _gasBuffer);


  function totalBonded() external view returns (uint256 _totalBonded);


  function bonded(address _caller) external view returns (uint256 _bond);


  function canUnbondAt(address _caller) external view returns (uint256 _canUnbondAt);


  function caller(address _caller) external view returns (bool _enabled);


  function callerStealthContract(address _caller, address _contract) external view returns (bool _enabled);


  function hashReportedBy(bytes32 _hash) external view returns (address _reportedBy);


  function setGasBuffer(uint256 _gasBuffer) external;


  function transferGovernorBond(address _caller, uint256 _amount) external;


  function transferBondToGovernor(address _caller, uint256 _amount) external;


  function bond() external payable;


  function startUnbond() external;


  function cancelUnbond() external;


  function unbondAll() external;


  function unbond(uint256 _amount) external;


  function enableStealthContract(address _contract) external;


  function enableStealthContracts(address[] calldata _contracts) external;


  function disableStealthContract(address _contract) external;


  function disableStealthContracts(address[] calldata _contracts) external;


  function validateHash(
    address _caller,
    bytes32 _hash,
    uint256 _penalty
  ) external returns (bool);


  function reportHash(bytes32 _hash) external;


  function reportHashAndPay(bytes32 _hash) external payable;

}// MIT

pragma solidity 0.8.4;

interface IStealthTx {

  event StealthVaultSet(address _stealthVault);
  event PenaltySet(uint256 _penalty);
  event MigratedStealthVault(address _migratedTo);

  function stealthVault() external view returns (address);


  function penalty() external view returns (uint256);


  function setStealthVault(address _stealthVault) external;


  function setPenalty(uint256 _penalty) external;

}// MIT

pragma solidity 0.8.4;


abstract contract StealthTx is IStealthTx {
  address public override stealthVault;
  uint256 public override penalty = 1 ether;

  constructor(address _stealthVault) {
    _setStealthVault(_stealthVault);
  }

  modifier validateStealthTx(bytes32 _stealthHash) {
    if (!_validateStealthTx(_stealthHash)) return;
    _;
  }

  modifier validateStealthTxAndBlock(bytes32 _stealthHash, uint256 _blockNumber) {
    if (!_validateStealthTxAndBlock(_stealthHash, _blockNumber)) return;
    _;
  }

  function _validateStealthTx(bytes32 _stealthHash) internal returns (bool) {
    return IStealthVault(stealthVault).validateHash(msg.sender, _stealthHash, penalty);
  }

  function _validateStealthTxAndBlock(bytes32 _stealthHash, uint256 _blockNumber) internal returns (bool) {
    require(block.number == _blockNumber, 'ST: wrong block');
    return _validateStealthTx(_stealthHash);
  }

  function _setPenalty(uint256 _penalty) internal {
    require(_penalty > 0, 'ST: zero penalty');
    penalty = _penalty;
    emit PenaltySet(_penalty);
  }

  function _setStealthVault(address _stealthVault) internal {
    require(_stealthVault != address(0), 'ST: zero address');
    require(IStealthVault(_stealthVault).isStealthVault(), 'ST: not stealth vault');
    stealthVault = _stealthVault;
    emit StealthVaultSet(_stealthVault);
  }
}// MIT

pragma solidity 0.8.4;



contract StealthRelayer is Governable, CollectableDust, StealthTx, IStealthRelayer {

  using Address for address;
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet internal _jobs;

  bool public override forceBlockProtection;
  address public override caller;

  constructor(address _stealthVault) Governable(msg.sender) StealthTx(_stealthVault) {}

  modifier onlyValidJob(address _job) {

    require(_jobs.contains(_job), 'SR: invalid job');
    _;
  }

  modifier setsCaller() {

    caller = msg.sender;
    _;
    caller = address(0);
  }

  function execute(
    address _job,
    bytes memory _callData,
    bytes32 _stealthHash,
    uint256 _blockNumber
  )
    external
    payable
    override
    onlyValidJob(_job)
    validateStealthTxAndBlock(_stealthHash, _blockNumber)
    setsCaller()
    returns (bytes memory _returnData)
  {

    return _callWithValue(_job, _callData, msg.value);
  }

  function executeAndPay(
    address _job,
    bytes memory _callData,
    bytes32 _stealthHash,
    uint256 _blockNumber,
    uint256 _payment
  )
    external
    payable
    override
    onlyValidJob(_job)
    validateStealthTxAndBlock(_stealthHash, _blockNumber)
    setsCaller()
    returns (bytes memory _returnData)
  {

    _returnData = _callWithValue(_job, _callData, msg.value - _payment);
    block.coinbase.transfer(_payment);
  }

  function executeWithoutBlockProtection(
    address _job,
    bytes memory _callData,
    bytes32 _stealthHash
  ) external payable override onlyValidJob(_job) validateStealthTx(_stealthHash) setsCaller() returns (bytes memory _returnData) {

    require(!forceBlockProtection, 'SR: block protection required');
    return _callWithValue(_job, _callData, msg.value);
  }

  function executeWithoutBlockProtectionAndPay(
    address _job,
    bytes memory _callData,
    bytes32 _stealthHash,
    uint256 _payment
  ) external payable override onlyValidJob(_job) validateStealthTx(_stealthHash) setsCaller() returns (bytes memory _returnData) {

    require(!forceBlockProtection, 'SR: block protection required');
    _returnData = _callWithValue(_job, _callData, msg.value - _payment);
    block.coinbase.transfer(_payment);
  }

  function _callWithValue(
    address _job,
    bytes memory _callData,
    uint256 _value
  ) internal returns (bytes memory _returnData) {

    return _job.functionCallWithValue(_callData, _value, 'SR: call reverted');
  }

  function setForceBlockProtection(bool _forceBlockProtection) external override onlyGovernor {

    forceBlockProtection = _forceBlockProtection;
  }

  function jobs() external view override returns (address[] memory _jobsList) {

    _jobsList = new address[](_jobs.length());
    for (uint256 i; i < _jobs.length(); i++) {
      _jobsList[i] = _jobs.at(i);
    }
  }

  function addJobs(address[] calldata _jobsList) external override onlyGovernor {

    for (uint256 i = 0; i < _jobsList.length; i++) {
      _addJob(_jobsList[i]);
    }
  }

  function addJob(address _job) external override onlyGovernor {

    _addJob(_job);
  }

  function _addJob(address _job) internal {

    require(_jobs.add(_job), 'SR: job already added');
  }

  function removeJobs(address[] calldata _jobsList) external override onlyGovernor {

    for (uint256 i = 0; i < _jobsList.length; i++) {
      _removeJob(_jobsList[i]);
    }
  }

  function removeJob(address _job) external override onlyGovernor {

    _removeJob(_job);
  }

  function _removeJob(address _job) internal {

    require(_jobs.remove(_job), 'SR: job not found');
  }

  function setPenalty(uint256 _penalty) external override onlyGovernor {

    _setPenalty(_penalty);
  }

  function setStealthVault(address _stealthVault) external override onlyGovernor {

    _setStealthVault(_stealthVault);
  }

  function setPendingGovernor(address _pendingGovernor) external override onlyGovernor {

    _setPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external override onlyPendingGovernor {

    _acceptGovernor();
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {

    _sendDust(_to, _token, _amount);
  }
}