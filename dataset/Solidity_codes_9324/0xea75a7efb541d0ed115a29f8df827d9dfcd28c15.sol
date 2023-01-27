
pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSetUpgradeable {


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
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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
}// MIT

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using AddressUpgradeable for address;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// AGPL-3.0-only

pragma solidity 0.7.5;

interface IOwnablePausable {

    function isAdmin(address _account) external view returns (bool);


    function addAdmin(address _account) external;


    function removeAdmin(address _account) external;


    function isPauser(address _account) external view returns (bool);


    function addPauser(address _account) external;


    function removePauser(address _account) external;


    function pause() external;


    function unpause() external;

}// AGPL-3.0-only

pragma solidity 0.7.5;


abstract contract OwnablePausableUpgradeable is IOwnablePausable, PausableUpgradeable, AccessControlUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "OwnablePausable: access denied");
        _;
    }

    modifier onlyPauser() {
        require(hasRole(PAUSER_ROLE, msg.sender), "OwnablePausable: access denied");
        _;
    }

    function __OwnablePausableUpgradeable_init(address _admin) internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
        __OwnablePausableUpgradeable_init_unchained(_admin);
    }

    function __OwnablePausableUpgradeable_init_unchained(address _admin) internal initializer {
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(PAUSER_ROLE, _admin);
    }

    function isAdmin(address _account) external override view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _account);
    }

    function addAdmin(address _account) external override {
        grantRole(DEFAULT_ADMIN_ROLE, _account);
    }

    function removeAdmin(address _account) external override {
        revokeRole(DEFAULT_ADMIN_ROLE, _account);
    }

    function isPauser(address _account) external override view returns (bool) {
        return hasRole(PAUSER_ROLE, _account);
    }

    function addPauser(address _account) external override {
        grantRole(PAUSER_ROLE, _account);
    }

    function removePauser(address _account) external override {
        revokeRole(PAUSER_ROLE, _account);
    }

    function pause() external override onlyPauser {
        _pause();
    }

    function unpause() external override onlyPauser {
        _unpause();
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// AGPL-3.0-only

pragma solidity 0.7.5;


interface IStakedEthToken is IERC20Upgradeable {

    function initialize(
        address admin,
        address _pool,
        address _rewardEthToken,
        address _whiteListManager
    ) external;


    function totalDeposits() external view returns (uint256);


    function distributorPrincipal() external view returns (uint256);


    function toggleRewards(address account, bool isDisabled) external;


    function mint(address account, uint256 amount) external;

}// AGPL-3.0-only

pragma solidity 0.7.5;

interface IDepositContract {

    event DepositEvent(
        bytes pubkey,
        bytes withdrawal_credentials,
        bytes amount,
        bytes signature,
        bytes index
    );

    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;


    function get_deposit_root() external view returns (bytes32);


    function get_deposit_count() external view returns (bytes memory);

}// AGPL-3.0-only

pragma solidity 0.7.5;
pragma abicoder v2;

interface IPoolValidators {

    struct Operator {
        bytes32 depositDataMerkleRoot;
        bool committed;
    }

    struct DepositData {
        address operator;
        bytes32 withdrawalCredentials;
        bytes32 depositDataRoot;
        bytes publicKey;
        bytes signature;
    }

    event OperatorAdded(
        address indexed operator,
        bytes32 indexed depositDataMerkleRoot,
        string depositDataMerkleProofs
    );

    event OperatorCommitted(address indexed operator);

    event OperatorRemoved(
        address indexed sender,
        address indexed operator
    );

    function initialize(address _admin, address _pool, address _oracles) external;


    function getOperator(address _operator) external view returns (bytes32, bool);


    function isValidatorRegistered(bytes32 validatorId) external view returns (bool);


    function addOperator(
        address _operator,
        bytes32 depositDataMerkleRoot,
        string calldata depositDataMerkleProofs
    ) external;


    function commitOperator() external;


    function removeOperator(address _operator) external;


    function registerValidator(DepositData calldata depositData, bytes32[] calldata merkleProof) external;

}// AGPL-3.0-only

pragma solidity 0.7.5;


interface IPool {

    event ValidatorRegistered(bytes publicKey, address operator);

    event Refunded(address indexed sender, uint256 amount);

    event ActivationScheduled(address indexed sender, uint256 validatorIndex, uint256 value);

    event Activated(address indexed account, uint256 validatorIndex, uint256 value, address indexed sender);

    event ActivatedValidatorsUpdated(uint256 activatedValidators, address sender);

    event MinActivatingDepositUpdated(uint256 minActivatingDeposit, address sender);

    event PendingValidatorsLimitUpdated(uint256 pendingValidatorsLimit, address sender);

    event StakedWithPartner(address indexed partner, uint256 amount);

    event StakedWithReferrer(address indexed referrer, uint256 amount);

    function initialize(
        address admin,
        bytes32 _withdrawalCredentials,
        address _validatorRegistration,
        address _stakedEthToken,
        address _validators,
        address _oracles,
        address _whiteListManager,
        uint256 _minActivatingDeposit,
        uint256 _pendingValidatorsLimit
    ) external;


    function VALIDATOR_TOTAL_DEPOSIT() external view returns (uint256);


    function pendingValidators() external view returns (uint256);


    function activatedValidators() external view returns (uint256);


    function withdrawalCredentials() external view returns (bytes32);


    function minActivatingDeposit() external view returns (uint256);


    function pendingValidatorsLimit() external view returns (uint256);


    function activations(address account, uint256 validatorIndex) external view returns (uint256);


    function setMinActivatingDeposit(uint256 newMinActivatingDeposit) external;


    function setActivatedValidators(uint256 newActivatedValidators) external;


    function setPendingValidatorsLimit(uint256 newPendingValidatorsLimit) external;


    function canActivate(uint256 validatorIndex) external view returns (bool);


    function validatorRegistration() external view returns (IDepositContract);


    function stakeOnBehalf(address recipient) external payable;


    function stake() external payable;


    function stakeWithPartner(address partner) external payable;


    function stakeWithPartnerOnBehalf(address partner, address recipient) external payable;


    function stakeWithReferrer(address referrer) external payable;


    function stakeWithReferrerOnBehalf(address referrer, address recipient) external payable;


    function activate(address account, uint256 validatorIndex) external;


    function activateMultiple(address account, uint256[] calldata validatorIndexes) external;


    function registerValidator(IPoolValidators.DepositData calldata depositData) external;


    function refund() external payable;

}// AGPL-3.0-only

pragma solidity 0.7.5;


interface IWhiteListManager {

    event ManagerAdded(address account);

    event ManagerRemoved(address account);

    event WhiteListUpdated(address indexed account, bool approved);

    function whitelistedAccounts(address account) external view returns (bool);


    function initialize(address admin) external;


    function updateWhiteList(address account, bool approved) external;


    function isManager(address account) external view returns (bool);


    function addManager(address account) external;


    function removeManager(address account) external;

}// AGPL-3.0-only

pragma solidity 0.7.5;


contract Pool is IPool, OwnablePausableUpgradeable {

    using SafeMathUpgradeable for uint256;

    uint256 public constant override VALIDATOR_TOTAL_DEPOSIT = 32 ether;

    uint256 public override activatedValidators;

    bytes32 public override withdrawalCredentials;

    IDepositContract public override validatorRegistration;

    IStakedEthToken private stakedEthToken;

    IPoolValidators private validators;

    address private oracles;

    IWhiteListManager private whiteListManager;

    mapping(address => mapping(uint256 => uint256)) public override activations;

    uint256 public override pendingValidators;

    uint256 public override minActivatingDeposit;

    uint256 public override pendingValidatorsLimit;

    function initialize(
        address admin,
        bytes32 _withdrawalCredentials,
        address _validatorRegistration,
        address _stakedEthToken,
        address _validators,
        address _oracles,
        address _whiteListManager,
        uint256 _minActivatingDeposit,
        uint256 _pendingValidatorsLimit
    )
        external override initializer
    {

        require(admin != address(0), "Pool: invalid admin address");
        require(_withdrawalCredentials != "", "Pool: invalid withdrawal credentials");
        require(_validatorRegistration != address(0), "Pool: invalid ValidatorRegistration address");
        require(_stakedEthToken != address(0), "Pool: invalid StakedEthToken address");
        require(_validators != address(0), "Pool: invalid Validators address");
        require(_oracles != address(0), "Pool: invalid Oracles address");
        require(_pendingValidatorsLimit < 1e4, "Pool: invalid limit");

        __OwnablePausableUpgradeable_init(admin);

        withdrawalCredentials = _withdrawalCredentials;
        validatorRegistration = IDepositContract(_validatorRegistration);
        stakedEthToken = IStakedEthToken(_stakedEthToken);
        validators = IPoolValidators(_validators);
        oracles = _oracles;
        whiteListManager = IWhiteListManager(_whiteListManager);

        minActivatingDeposit = _minActivatingDeposit;
        emit MinActivatingDepositUpdated(_minActivatingDeposit, msg.sender);

        pendingValidatorsLimit = _pendingValidatorsLimit;
        emit PendingValidatorsLimitUpdated(_pendingValidatorsLimit, msg.sender);
    }

    function setMinActivatingDeposit(uint256 newMinActivatingDeposit) external override onlyAdmin {

        minActivatingDeposit = newMinActivatingDeposit;
        emit MinActivatingDepositUpdated(newMinActivatingDeposit, msg.sender);
    }

    function setPendingValidatorsLimit(uint256 newPendingValidatorsLimit) external override onlyAdmin {

        require(newPendingValidatorsLimit < 1e4, "Pool: invalid limit");
        pendingValidatorsLimit = newPendingValidatorsLimit;
        emit PendingValidatorsLimitUpdated(newPendingValidatorsLimit, msg.sender);
    }

    function setActivatedValidators(uint256 newActivatedValidators) external override {

        require(msg.sender == oracles || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Pool: access denied");

        pendingValidators = pendingValidators.sub(newActivatedValidators.sub(activatedValidators));
        activatedValidators = newActivatedValidators;
        emit ActivatedValidatorsUpdated(newActivatedValidators, msg.sender);
    }

    function stake() external payable override {

        _stake(msg.sender, msg.value);
    }

    function stakeOnBehalf(address recipient) external payable override {

        _stake(recipient, msg.value);
    }

    receive() external payable {
        _stake(msg.sender, msg.value);
    }

    function stakeWithPartner(address partner) external payable override {

        _stake(msg.sender, msg.value);
        emit StakedWithPartner(partner, msg.value);
    }

    function stakeWithPartnerOnBehalf(address partner, address recipient) external payable override {

        _stake(recipient, msg.value);
        emit StakedWithPartner(partner, msg.value);
    }

    function stakeWithReferrer(address referrer) external payable override {

        _stake(msg.sender, msg.value);
        emit StakedWithReferrer(referrer, msg.value);
    }

    function stakeWithReferrerOnBehalf(address referrer, address recipient) external payable override {

        _stake(recipient, msg.value);
        emit StakedWithReferrer(referrer, msg.value);
    }

    function _stake(address recipient, uint256 value) internal whenNotPaused {

        require(whiteListManager.whitelistedAccounts(recipient), "Pool: invalid recipient address");
        if (recipient != msg.sender) {
            require(whiteListManager.whitelistedAccounts(msg.sender), "Pool: invalid sender address");
        }
        require(value > 0, "Pool: invalid deposit amount");

        if (value <= minActivatingDeposit) {
            stakedEthToken.mint(recipient, value);
            return;
        }

        uint256 _pendingValidators = pendingValidators.add((address(this).balance).div(VALIDATOR_TOTAL_DEPOSIT));
        uint256 _activatedValidators = activatedValidators; // gas savings
        uint256 validatorIndex = _activatedValidators.add(_pendingValidators);
        if (validatorIndex.mul(1e4) <= _activatedValidators.mul(pendingValidatorsLimit.add(1e4))) {
            stakedEthToken.mint(recipient, value);
        } else {
            activations[recipient][validatorIndex] = activations[recipient][validatorIndex].add(value);
            emit ActivationScheduled(recipient, validatorIndex, value);
        }
    }

    function canActivate(uint256 validatorIndex) external view override returns (bool) {

        return validatorIndex.mul(1e4) <= activatedValidators.mul(pendingValidatorsLimit.add(1e4));
    }

    function activate(address account, uint256 validatorIndex) external override whenNotPaused {

        uint256 activatedAmount = _activateAmount(
            account,
            validatorIndex,
            activatedValidators.mul(pendingValidatorsLimit.add(1e4))
        );

        stakedEthToken.mint(account, activatedAmount);
    }

    function activateMultiple(address account, uint256[] calldata validatorIndexes) external override whenNotPaused {

        uint256 toMint;
        uint256 maxValidatorIndex = activatedValidators.mul(pendingValidatorsLimit.add(1e4));
        for (uint256 i = 0; i < validatorIndexes.length; i++) {
            uint256 activatedAmount = _activateAmount(account, validatorIndexes[i], maxValidatorIndex);
            toMint = toMint.add(activatedAmount);
        }
        stakedEthToken.mint(account, toMint);
    }

    function _activateAmount(
        address account,
        uint256 validatorIndex,
        uint256 maxValidatorIndex
    )
        internal returns (uint256 amount)
    {

        require(validatorIndex.mul(1e4) <= maxValidatorIndex, "Pool: validator is not active yet");

        amount = activations[account][validatorIndex];
        require(amount > 0, "Pool: invalid validator index");

        delete activations[account][validatorIndex];
        emit Activated(account, validatorIndex, amount, msg.sender);
    }

    function registerValidator(IPoolValidators.DepositData calldata depositData) external override whenNotPaused {

        require(msg.sender == address(validators), "Pool: access denied");
        require(depositData.withdrawalCredentials == withdrawalCredentials, "Pool: invalid withdrawal credentials");

        pendingValidators = pendingValidators.add(1);
        emit ValidatorRegistered(depositData.publicKey, depositData.operator);

        validatorRegistration.deposit{value : VALIDATOR_TOTAL_DEPOSIT}(
            depositData.publicKey,
            abi.encodePacked(depositData.withdrawalCredentials),
            depositData.signature,
            depositData.depositDataRoot
        );
    }

    function refund() external override payable {

        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender) && whiteListManager.whitelistedAccounts(msg.sender),
            "Pool: access denied"
        );
        require(msg.value > 0, "Pool: invalid refund amount");
        emit Refunded(msg.sender, msg.value);
    }
}