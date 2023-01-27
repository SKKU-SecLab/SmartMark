
pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// MIT

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
}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface ICollectableDust {

  event DustSent(address _to, address token, uint256 amount);

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external;

}// MIT
pragma solidity >=0.8.4 <0.9.0;



abstract contract CollectableDust is ICollectableDust {
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
pragma solidity >=0.8.4 <0.9.0;

interface IGovernable {

  event PendingGovernorSet(address pendingGovernor);
  event GovernorAccepted();

  function setPendingGovernor(address _pendingGovernor) external;


  function acceptGovernor() external;


  function governor() external view returns (address _governor);


  function pendingGovernor() external view returns (address _pendingGovernor);


  function isGovernor(address _account) external view returns (bool _isGovernor);

}// MIT
pragma solidity >=0.8.4 <0.9.0;


contract Governable is IGovernable {

  address public override governor;
  address public override pendingGovernor;

  constructor(address _governor) {
    require(_governor != address(0), 'governable/governor-should-not-be-zero-address');
    governor = _governor;
  }

  function setPendingGovernor(address _pendingGovernor) external virtual override onlyGovernor {

    _setPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external virtual override onlyPendingGovernor {

    _acceptGovernor();
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

  modifier onlyGovernor() {

    require(isGovernor(msg.sender), 'governable/only-governor');
    _;
  }

  modifier onlyPendingGovernor() {

    require(msg.sender == pendingGovernor, 'governable/only-pending-governor');
    _;
  }
}// MIT
pragma solidity >=0.8.4 <0.9.0;

interface IManageable {

  event PendingManagerSet(address pendingManager);
  event ManagerAccepted();

  function setPendingManager(address _pendingManager) external;


  function acceptManager() external;


  function manager() external view returns (address _manager);


  function pendingManager() external view returns (address _pendingManager);


  function isManager(address _account) external view returns (bool _isManager);

}// MIT
pragma solidity >=0.8.4 <0.9.0;


abstract contract Manageable is IManageable {
  address public override manager;
  address public override pendingManager;

  constructor(address _manager) {
    require(_manager != address(0), 'manageable/manager-should-not-be-zero-address');
    manager = _manager;
  }

  function _setPendingManager(address _pendingManager) internal {
    require(_pendingManager != address(0), 'manageable/pending-manager-should-not-be-zero-addres');
    pendingManager = _pendingManager;
    emit PendingManagerSet(_pendingManager);
  }

  function _acceptManager() internal {
    manager = pendingManager;
    pendingManager = address(0);
    emit ManagerAccepted();
  }

  function isManager(address _account) public view override returns (bool _isManager) {
    return _account == manager;
  }

  modifier onlyManager() {
    require(isManager(msg.sender), 'manageable/only-manager');
    _;
  }

  modifier onlyPendingManager() {
    require(msg.sender == pendingManager, 'manageable/only-pending-manager');
    _;
  }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT
pragma solidity ^0.8.4;

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


  function eoaAuthCallProtection() external view returns (bool _eoaAuthCallProtection);


  function callers() external view returns (address[] memory _callers);


  function callerContracts(address _caller) external view returns (address[] memory _contracts);


  function gasBuffer() external view returns (uint256 _gasBuffer);


  function totalBonded() external view returns (uint256 _totalBonded);


  function bonded(address _caller) external view returns (uint256 _bond);


  function canUnbondAt(address _caller) external view returns (uint256 _canUnbondAt);


  function caller(address _caller) external view returns (bool _enabled);


  function callerStealthContract(address _caller, address _contract) external view returns (bool _enabled);


  function hashReportedBy(bytes32 _hash) external view returns (address _reportedBy);


  function setEoaAuthCallProtection(bool _eoaAuthCallProtection) external;


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

pragma solidity ^0.8.4;



contract StealthVault is Governable, Manageable, CollectableDust, ReentrancyGuard, IStealthVault {

  using EnumerableSet for EnumerableSet.AddressSet;

  bool public override eoaAuthCallProtection;

  uint256 public override gasBuffer = 69_420; // why not
  uint256 public override totalBonded;
  mapping(address => uint256) public override bonded;
  mapping(address => uint256) public override canUnbondAt;

  mapping(address => EnumerableSet.AddressSet) internal _callerStealthContracts;
  mapping(bytes32 => address) public override hashReportedBy;

  EnumerableSet.AddressSet internal _callers;

  constructor() Governable(msg.sender) Manageable(msg.sender) {}

  function isStealthVault() external pure override returns (bool) {

    return true;
  }

  function callers() external view override returns (address[] memory _callersList) {

    _callersList = new address[](_callers.length());
    for (uint256 i; i < _callers.length(); i++) {
      _callersList[i] = _callers.at(i);
    }
  }

  function callerContracts(address _caller) external view override returns (address[] memory _callerContractsList) {

    _callerContractsList = new address[](_callerStealthContracts[_caller].length());
    for (uint256 i; i < _callerStealthContracts[_caller].length(); i++) {
      _callerContractsList[i] = _callerStealthContracts[_caller].at(i);
    }
  }

  function caller(address _caller) external view override returns (bool _enabled) {

    return _callers.contains(_caller);
  }

  function callerStealthContract(address _caller, address _contract) external view override returns (bool _enabled) {

    return _callerStealthContracts[_caller].contains(_contract);
  }

  function bond() external payable override nonReentrant {

    require(msg.value > 0, 'SV: bond more than zero');
    bonded[msg.sender] = bonded[msg.sender] + msg.value;
    totalBonded = totalBonded + msg.value;
    emit Bonded(msg.sender, msg.value, bonded[msg.sender]);
  }

  function unbondAll() external override {

    unbond(bonded[msg.sender]);
  }

  function startUnbond() public override nonReentrant {

    canUnbondAt[msg.sender] = block.timestamp + 4 days;
  }

  function cancelUnbond() public override nonReentrant {

    canUnbondAt[msg.sender] = 0;
  }

  function unbond(uint256 _amount) public override nonReentrant {

    require(_amount > 0, 'SV: more than zero');
    require(_amount <= bonded[msg.sender], 'SV: amount too high');
    require(canUnbondAt[msg.sender] > 0, 'SV: not unbondind');
    require(block.timestamp > canUnbondAt[msg.sender], 'SV: unbond in cooldown');

    bonded[msg.sender] = bonded[msg.sender] - _amount;
    totalBonded = totalBonded - _amount;
    canUnbondAt[msg.sender] = 0;

    payable(msg.sender).transfer(_amount);
    emit Unbonded(msg.sender, _amount, bonded[msg.sender]);
  }

  function _penalize(
    address _caller,
    uint256 _penalty,
    address _reportedBy
  ) internal {

    bonded[_caller] = bonded[_caller] - _penalty;
    uint256 _amountReward = _penalty / 10;
    bonded[_reportedBy] = bonded[_reportedBy] + _amountReward;
    bonded[governor] = bonded[governor] + (_penalty - _amountReward);
  }

  modifier OnlyOneCallStack() {

    if (eoaAuthCallProtection) {
      uint256 _gasLeftPlusBuffer = gasleft() + gasBuffer;
      require(_gasLeftPlusBuffer >= (block.gaslimit * 63) / 64, 'SV: eoa gas check failed');
    }
    _;
  }

  function validateHash(
    address _caller,
    bytes32 _hash,
    uint256 _penalty
  ) external virtual override OnlyOneCallStack nonReentrant returns (bool _valid) {

    require(_caller == tx.origin, 'SV: not eoa');
    require(_callerStealthContracts[_caller].contains(msg.sender), 'SV: contract not enabled');
    require(bonded[_caller] >= _penalty, 'SV: not enough bonded');
    require(canUnbondAt[_caller] == 0, 'SV: unbonding');

    address reportedBy = hashReportedBy[_hash];
    if (reportedBy != address(0)) {
      _penalize(_caller, _penalty, reportedBy);

      emit PenaltyApplied(_hash, _caller, _penalty, reportedBy);

      return false;
    }
    emit ValidatedHash(_hash, _caller, _penalty);
    return true;
  }

  function reportHash(bytes32 _hash) external override nonReentrant {

    _reportHash(_hash);
  }

  function reportHashAndPay(bytes32 _hash) external payable override nonReentrant {

    _reportHash(_hash);
    block.coinbase.transfer(msg.value);
  }

  function _reportHash(bytes32 _hash) internal {

    require(hashReportedBy[_hash] == address(0), 'SV: hash already reported');
    hashReportedBy[_hash] = msg.sender;
    emit ReportedHash(_hash, msg.sender);
  }

  function enableStealthContract(address _contract) external override nonReentrant {

    _addCallerContract(_contract);
    emit StealthContractEnabled(msg.sender, _contract);
  }

  function enableStealthContracts(address[] calldata _contracts) external override nonReentrant {

    for (uint256 i = 0; i < _contracts.length; i++) {
      _addCallerContract(_contracts[i]);
    }
    emit StealthContractsEnabled(msg.sender, _contracts);
  }

  function disableStealthContract(address _contract) external override nonReentrant {

    _removeCallerContract(_contract);
    emit StealthContractDisabled(msg.sender, _contract);
  }

  function disableStealthContracts(address[] calldata _contracts) external override nonReentrant {

    for (uint256 i = 0; i < _contracts.length; i++) {
      _removeCallerContract(_contracts[i]);
    }
    emit StealthContractsDisabled(msg.sender, _contracts);
  }

  function _addCallerContract(address _contract) internal {

    _callers.add(msg.sender);
    require(_callerStealthContracts[msg.sender].add(_contract), 'SV: contract already added');
  }

  function _removeCallerContract(address _contract) internal {

    require(_callerStealthContracts[msg.sender].remove(_contract), 'SV: contract not found');
    if (_callerStealthContracts[msg.sender].length() == 0) _callers.remove(msg.sender);
  }

  function setEoaAuthCallProtection(bool _eoaAuthCallProtection) external override onlyManager {

    require(eoaAuthCallProtection != _eoaAuthCallProtection, 'SV: no change');
    eoaAuthCallProtection = _eoaAuthCallProtection;
  }

  function setGasBuffer(uint256 _gasBuffer) external virtual override onlyManager {

    require(_gasBuffer < (block.gaslimit * 63) / 64, 'SV: gasBuffer too high');
    gasBuffer = _gasBuffer;
  }

  function transferGovernorBond(address _caller, uint256 _amount) external override onlyGovernor {

    bonded[governor] = bonded[governor] - _amount;
    bonded[_caller] = bonded[_caller] + _amount;
  }

  function transferBondToGovernor(address _caller, uint256 _amount) external override onlyGovernor {

    bonded[_caller] = bonded[_caller] - _amount;
    bonded[governor] = bonded[governor] + _amount;
  }

  function setPendingManager(address _pendingManager) external override onlyGovernor {

    _setPendingManager(_pendingManager);
  }

  function acceptManager() external override onlyPendingManager {

    _acceptManager();
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