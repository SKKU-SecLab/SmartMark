
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

library MerkleProofUpgradeable {

    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
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
}// AGPL-3.0-only

pragma solidity 0.7.5;
pragma abicoder v2;

interface IPoolValidators {

    struct Operator {
        bytes32 initializeMerkleRoot;
        bytes32 finalizeMerkleRoot;
        bool locked;
        bool committed;
    }

    struct DepositData {
        address operator;
        bytes32 withdrawalCredentials;
        bytes32 depositDataRoot;
        bytes publicKey;
        bytes signature;
    }

    enum ValidatorStatus { Uninitialized, Initialized, Finalized, Failed }

    event OperatorAdded(
        address indexed operator,
        bytes32 indexed initializeMerkleRoot,
        string initializeMerkleProofs,
        bytes32 indexed finalizeMerkleRoot,
        string finalizeMerkleProofs
    );

    event OperatorCommitted(
        address indexed operator,
        uint256 collateral
    );

    event CollateralWithdrawn(
        address indexed operator,
        address indexed collateralRecipient,
        uint256 collateral
    );

    event OperatorRemoved(
        address indexed sender,
        address indexed operator
    );

    event OperatorSlashed(
        address indexed operator,
        bytes publicKey,
        uint256 refundedAmount
    );

    function initialize(address _admin, address _pool, address _oracles) external;


    function getOperator(address _operator) external view returns (bytes32, bytes32, bool);


    function collaterals(address operator) external view returns (uint256);


    function validatorStatuses(bytes32 validatorId) external view returns (ValidatorStatus);


    function addOperator(
        address _operator,
        bytes32 initializeMerkleRoot,
        string calldata initializeMerkleProofs,
        bytes32 finalizeMerkleRoot,
        string calldata finalizeMerkleProofs
    ) external;


    function commitOperator() external payable;


    function withdrawCollateral(address payable collateralRecipient) external;


    function removeOperator(address _operator) external;


    function slashOperator(DepositData calldata depositData, bytes32[] calldata merkleProof) external;


    function initializeValidator(DepositData calldata depositData, bytes32[] calldata merkleProof) external;


    function finalizeValidator(DepositData calldata depositData, bytes32[] calldata merkleProof) external;

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


interface IPool {

    event ValidatorInitialized(bytes publicKey, address operator);

    event ValidatorRegistered(bytes publicKey, address operator);

    event Refunded(address indexed sender, uint256 amount);

    event ActivationScheduled(address indexed sender, uint256 validatorIndex, uint256 value);

    event Activated(address indexed account, uint256 validatorIndex, uint256 value, address indexed sender);

    event ActivatedValidatorsUpdated(uint256 activatedValidators, address sender);

    event MinActivatingDepositUpdated(uint256 minActivatingDeposit, address sender);

    event PendingValidatorsLimitUpdated(uint256 pendingValidatorsLimit, address sender);

    event StakedWithPartner(address indexed partner, uint256 amount);

    event StakedWithReferrer(address indexed referrer, uint256 amount);

    function upgrade(address _poolValidators, address _oracles) external;


    function VALIDATOR_TOTAL_DEPOSIT() external view returns (uint256);


    function VALIDATOR_INIT_DEPOSIT() external view returns (uint256);


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


    function initializeValidator(IPoolValidators.DepositData calldata depositData) external;


    function finalizeValidator(IPoolValidators.DepositData calldata depositData) external;


    function refund() external payable;

}// AGPL-3.0-only

pragma solidity 0.7.5;


contract PoolValidators is IPoolValidators, OwnablePausableUpgradeable, ReentrancyGuardUpgradeable  {

    using AddressUpgradeable for address payable;
    using SafeMathUpgradeable for uint256;

    mapping(bytes32 => ValidatorStatus) public override validatorStatuses;

    mapping(address => uint256) public override collaterals;

    mapping(address => Operator) private operators;

    IPool private pool;

    address private oracles;

    function initialize(address _admin, address _pool, address _oracles) external override initializer {

        require(_admin != address(0), "Pool: invalid admin address");
        require(_pool != address(0), "Pool: invalid Pool address");
        require(_oracles != address(0), "Pool: invalid Oracles address");

        __OwnablePausableUpgradeable_init(_admin);
        pool = IPool(_pool);
        oracles = _oracles;
    }

    function getOperator(address _operator) external view override returns (bytes32, bytes32, bool) {

        Operator storage operator = operators[_operator];
        return (
            operator.initializeMerkleRoot,
            operator.finalizeMerkleRoot,
            operator.locked
        );
    }

    function addOperator(
        address _operator,
        bytes32 initializeMerkleRoot,
        string calldata initializeMerkleProofs,
        bytes32 finalizeMerkleRoot,
        string calldata finalizeMerkleProofs
    )
        external override onlyAdmin whenNotPaused
    {

        require(_operator != address(0), "PoolValidators: invalid operator");
        require(
            initializeMerkleRoot != "" && finalizeMerkleRoot != "" && finalizeMerkleRoot != initializeMerkleRoot,
            "PoolValidators: invalid merkle roots"
        );
        require(
            bytes(initializeMerkleProofs).length != 0 && bytes(finalizeMerkleProofs).length != 0 &&
            keccak256(bytes(initializeMerkleProofs)) != keccak256(bytes(finalizeMerkleProofs)),
            "PoolValidators: invalid merkle proofs"
        );

        Operator storage operator = operators[_operator];
        require(!operator.locked, "PoolValidators: operator locked");
        require(operator.initializeMerkleRoot != initializeMerkleRoot, "PoolValidators: same initialize merkle root");
        require(operator.finalizeMerkleRoot != finalizeMerkleRoot, "PoolValidators: same finalize merkle root");

        operator.initializeMerkleRoot = initializeMerkleRoot;
        operator.finalizeMerkleRoot = finalizeMerkleRoot;
        operator.committed = false;

        emit OperatorAdded(
            _operator,
            initializeMerkleRoot,
            initializeMerkleProofs,
            finalizeMerkleRoot,
            finalizeMerkleProofs
        );
    }

    function commitOperator() external payable override whenNotPaused {

        Operator storage operator = operators[msg.sender];
        require(operator.initializeMerkleRoot != "" && !operator.committed, "PoolValidators: invalid operator");
        operator.committed = true;

        uint256 newCollateral = collaterals[msg.sender].add(msg.value);
        require(newCollateral >= pool.VALIDATOR_INIT_DEPOSIT(), "PoolValidators: invalid collateral");

        collaterals[msg.sender] = newCollateral;

        emit OperatorCommitted(msg.sender, msg.value);
    }

    function withdrawCollateral(address payable collateralRecipient) external override nonReentrant whenNotPaused {

        require(collateralRecipient != address(0), "PoolValidators: invalid collateral recipient");

        Operator storage operator = operators[msg.sender];
        require(operator.initializeMerkleRoot == "", "PoolValidators: operator exists");

        uint256 collateral = collaterals[msg.sender];
        require(collateral > 0, "PoolValidators: collateral does not exist");

        delete collaterals[msg.sender];

        collateralRecipient.sendValue(collateral);

        emit CollateralWithdrawn(msg.sender, collateralRecipient, collateral);
    }

    function removeOperator(address _operator) external override whenNotPaused {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || msg.sender == _operator, "PoolValidators: access denied");

        Operator storage operator = operators[_operator];
        require(operator.initializeMerkleRoot != "", "PoolValidators: invalid operator");
        require(!operator.locked, "PoolValidators: operator is locked");

        delete operators[_operator];

        emit OperatorRemoved(msg.sender, _operator);
    }

    function slashOperator(DepositData calldata depositData, bytes32[] calldata merkleProof) external override onlyAdmin whenNotPaused {

        Operator storage operator = operators[depositData.operator];
        bytes32 initializeMerkleRoot = operator.initializeMerkleRoot;
        require(initializeMerkleRoot != "" && operator.locked, "PoolValidators: invalid operator");

        bytes32 node = keccak256(abi.encode(
            depositData.publicKey,
            depositData.withdrawalCredentials,
            depositData.signature,
            depositData.depositDataRoot
        ));
        require(
            MerkleProofUpgradeable.verify(merkleProof, initializeMerkleRoot, node),
            "PoolValidators: invalid merkle proof"
        );

        uint256 refundAmount = pool.VALIDATOR_INIT_DEPOSIT();
        uint256 operatorCollateral = collaterals[depositData.operator];
        if (refundAmount > operatorCollateral) {
            refundAmount = operatorCollateral;
        }

        bytes32 validatorId = keccak256(abi.encode(depositData.publicKey));
        require(
            validatorStatuses[validatorId] == ValidatorStatus.Initialized,
            "PoolValidators: invalid validator status"
        );
        validatorStatuses[validatorId] = ValidatorStatus.Failed;

        delete operators[depositData.operator];

        collaterals[depositData.operator] = operatorCollateral.sub(refundAmount);

        pool.refund{value : refundAmount}();
        emit OperatorSlashed(depositData.operator, depositData.publicKey, refundAmount);
    }

    function initializeValidator(DepositData calldata depositData, bytes32[] calldata merkleProof) external override {

        require(msg.sender == oracles, "PoolValidators: access denied");

        bytes32 validatorId = keccak256(abi.encode(depositData.publicKey));
        require(
            validatorStatuses[validatorId] == ValidatorStatus.Uninitialized,
            "PoolValidators: invalid validator status"
        );
        validatorStatuses[validatorId] = ValidatorStatus.Initialized;

        Operator storage operator = operators[depositData.operator];
        (
            bytes32 initializeMerkleRoot,
            bool locked,
            bool committed
        ) = (
            operator.initializeMerkleRoot,
            operator.locked,
            operator.committed
        );
        require(committed, "PoolValidators: operator not committed");
        require(
            collaterals[depositData.operator] >= pool.VALIDATOR_INIT_DEPOSIT(),
            "PoolValidators: invalid operator collateral"
        );

        bytes32 node = keccak256(abi.encode(
            depositData.publicKey,
            depositData.withdrawalCredentials,
            depositData.signature,
            depositData.depositDataRoot
        ));
        require(
            MerkleProofUpgradeable.verify(merkleProof, initializeMerkleRoot, node),
            "PoolValidators: invalid merkle proof"
        );

        require(!locked, "PoolValidators: operator already locked");
        operator.locked = true;

        pool.initializeValidator(depositData);
    }

    function finalizeValidator(DepositData calldata depositData, bytes32[] calldata merkleProof) external override {

        require(msg.sender == oracles, "PoolValidators: access denied");

        bytes32 validatorId = keccak256(abi.encode(depositData.publicKey));
        require(
            validatorStatuses[validatorId] == ValidatorStatus.Initialized,
            "PoolValidators: invalid validator status"
        );
        validatorStatuses[validatorId] = ValidatorStatus.Finalized;

        Operator storage operator = operators[depositData.operator];
        (bytes32 finalizeMerkleRoot, bool locked) = (operator.finalizeMerkleRoot, operator.locked);
        require(finalizeMerkleRoot != "", "PoolValidators: invalid operator");

        bytes32 node = keccak256(abi.encode(
            depositData.publicKey,
            depositData.withdrawalCredentials,
            depositData.signature,
            depositData.depositDataRoot
        ));
        require(
            MerkleProofUpgradeable.verify(merkleProof, finalizeMerkleRoot, node),
            "PoolValidators: invalid merkle proof"
        );

        require(locked, "PoolValidators: operator not locked");
        operator.locked = false;

        pool.finalizeValidator(depositData);
    }
}