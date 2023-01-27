
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


library CountersUpgradeable {

    using SafeMathUpgradeable for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library ECDSAUpgradeable {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
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


interface IRewardEthToken is IERC20Upgradeable {

    struct Checkpoint {
        uint128 reward;
        uint128 rewardPerToken;
    }

    event ProtocolFeeRecipientUpdated(address recipient);

    event ProtocolFeeUpdated(uint256 protocolFee);

    event RewardsToggled(address indexed account, bool isDisabled);

    event RewardsUpdated(
        uint256 periodRewards,
        uint256 totalRewards,
        uint256 rewardPerToken,
        uint256 distributorReward,
        uint256 protocolReward
    );

    function initialize(
        address admin,
        address _stakedEthToken,
        address _oracles,
        address _protocolFeeRecipient,
        uint256 _protocolFee,
        address _merkleDistributor,
        address _whiteListManager
    ) external;


    function merkleDistributor() external view returns (address);


    function protocolFeeRecipient() external view returns (address);


    function setProtocolFeeRecipient(address recipient) external;


    function protocolFee() external view returns (uint256);


    function setProtocolFee(uint256 _protocolFee) external;


    function totalRewards() external view returns (uint128);


    function lastUpdateBlockNumber() external view returns (uint256);


    function rewardPerToken() external view returns (uint128);


    function setRewardsDisabled(address account, bool isDisabled) external;


    function checkpoints(address account) external view returns (uint128, uint128);


    function rewardsDisabled(address account) external view returns (bool);


    function updateRewardCheckpoint(address account) external returns (bool);


    function updateRewardCheckpoints(address account1, address account2) external returns (bool, bool);


    function updateTotalRewards(uint256 newTotalRewards) external;


    function claim(address account, uint256 amount) external;

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


interface IOracles {

    event RewardsVoteSubmitted(
        address indexed sender,
        address indexed oracle,
        uint256 nonce,
        uint256 totalRewards,
        uint256 activatedValidators
    );

    event MerkleRootVoteSubmitted(
        address indexed sender,
        address indexed oracle,
        uint256 nonce,
        bytes32 indexed merkleRoot,
        string merkleProofs
    );

    event RegisterValidatorsVoteSubmitted(
        address indexed sender,
        address[] oracles,
        uint256 nonce
    );

    event OracleAdded(address indexed oracle);

    event OracleRemoved(address indexed oracle);

    function initialize(
        address admin,
        address _rewardEthToken,
        address _pool,
        address _poolValidators,
        address _merkleDistributor
    ) external;


    function isOracle(address account) external view returns (bool);


    function isMerkleRootVoting() external view returns (bool);


    function currentRewardsNonce() external view returns (uint256);


    function currentValidatorsNonce() external view returns (uint256);


    function addOracle(address account) external;


    function removeOracle(address account) external;


    function submitRewards(
        uint256 totalRewards,
        uint256 activatedValidators,
        bytes[] calldata signatures
    ) external;


    function submitMerkleRoot(
        bytes32 merkleRoot,
        string calldata merkleProofs,
        bytes[] calldata signatures
    ) external;


    function registerValidators(
        IPoolValidators.DepositData[] calldata depositData,
        bytes32[][] calldata merkleProofs,
        bytes32 validatorsDepositRoot,
        bytes[] calldata signatures
    ) external;

}// AGPL-3.0-only

pragma solidity 0.7.5;


interface IMerkleDistributor {

    event MerkleRootUpdated(
        address indexed sender,
        bytes32 indexed merkleRoot,
        string merkleProofs
    );

    event PeriodicDistributionAdded(
        address indexed from,
        address indexed token,
        address indexed beneficiary,
        uint256 amount,
        uint256 startBlock,
        uint256 endBlock
    );

    event OneTimeDistributionAdded(
        address indexed from,
        address indexed origin,
        address indexed token,
        uint256 amount,
        string rewardsLink
    );

    event Claimed(address indexed account, uint256 index, address[] tokens, uint256[] amounts);

    function merkleRoot() external view returns (bytes32);


    function rewardEthToken() external view returns (address);


    function oracles() external view returns (IOracles);


    function lastUpdateBlockNumber() external view returns (uint256);


    function initialize(
        address admin,
        address _rewardEthToken,
        address _oracles
    ) external;


    function claimedBitMap(bytes32 _merkleRoot, uint256 _wordIndex) external view returns (uint256);


    function setMerkleRoot(bytes32 newMerkleRoot, string calldata merkleProofs) external;


    function distributePeriodically(
        address from,
        address token,
        address beneficiary,
        uint256 amount,
        uint256 durationInBlocks
    ) external;


    function distributeOneTime(
        address from,
        address origin,
        address token,
        uint256 amount,
        string calldata rewardsLink
    ) external;


    function isClaimed(uint256 index) external view returns (bool);


    function claim(
        uint256 index,
        address account,
        address[] calldata tokens,
        uint256[] calldata amounts,
        bytes32[] calldata merkleProof
    ) external;

}// AGPL-3.0-only

pragma solidity 0.7.5;


contract Oracles is IOracles, OwnablePausableUpgradeable {

    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    bytes32 public constant ORACLE_ROLE = keccak256("ORACLE_ROLE");

    CountersUpgradeable.Counter private rewardsNonce;

    CountersUpgradeable.Counter private validatorsNonce;

    IRewardEthToken private rewardEthToken;

    IPool private pool;

    IPoolValidators private poolValidators;

    IMerkleDistributor private merkleDistributor;

    modifier onlyOracle() {

        require(hasRole(ORACLE_ROLE, msg.sender), "Oracles: access denied");
        _;
    }

    function initialize(
        address admin,
        address _rewardEthToken,
        address _pool,
        address _poolValidators,
        address _merkleDistributor
    )
        external override initializer
    {

        require(admin != address(0), "Pool: invalid admin address");
        require(_rewardEthToken != address(0), "Pool: invalid RewardEthToken address");
        require(_pool != address(0), "Pool: invalid Pool address");
        require(_poolValidators != address(0), "Pool: invalid PoolValidators address");
        require(_merkleDistributor != address(0), "Pool: invalid MerkleDistributor address");

        __OwnablePausableUpgradeable_init(admin);

        rewardEthToken = IRewardEthToken(_rewardEthToken);
        pool = IPool(_pool);
        poolValidators = IPoolValidators(_poolValidators);
        merkleDistributor = IMerkleDistributor(_merkleDistributor);
    }

    function currentRewardsNonce() external override view returns (uint256) {

        return rewardsNonce.current();
    }

    function currentValidatorsNonce() external override view returns (uint256) {

        return validatorsNonce.current();
    }

    function isOracle(address account) external override view returns (bool) {

        return hasRole(ORACLE_ROLE, account);
    }

    function addOracle(address account) external override {

        require(account != address(0), "Oracles: invalid oracle address");
        grantRole(ORACLE_ROLE, account);
        emit OracleAdded(account);
    }

    function removeOracle(address account) external override {

        revokeRole(ORACLE_ROLE, account);
        emit OracleRemoved(account);
    }

    function isMerkleRootVoting() public override view returns (bool) {

        uint256 lastRewardBlockNumber = rewardEthToken.lastUpdateBlockNumber();
        return merkleDistributor.lastUpdateBlockNumber() < lastRewardBlockNumber && lastRewardBlockNumber != block.number;
    }

    function isEnoughSignatures(uint256 signaturesCount) internal view returns (bool) {

        uint256 totalOracles = getRoleMemberCount(ORACLE_ROLE);
        return totalOracles >= signaturesCount && signaturesCount.mul(3) > totalOracles.mul(2);
    }

    function submitRewards(
        uint256 totalRewards,
        uint256 activatedValidators,
        bytes[] calldata signatures
    )
        external override onlyOracle whenNotPaused
    {

        require(isEnoughSignatures(signatures.length), "Oracles: invalid number of signatures");

        uint256 nonce = rewardsNonce.current();
        bytes32 candidateId = ECDSAUpgradeable.toEthSignedMessageHash(
            keccak256(abi.encode(nonce, activatedValidators, totalRewards))
        );

        address[] memory signedOracles = new address[](signatures.length);
        for (uint256 i = 0; i < signatures.length; i++) {
            bytes memory signature = signatures[i];
            address signer = ECDSAUpgradeable.recover(candidateId, signature);
            require(hasRole(ORACLE_ROLE, signer), "Oracles: invalid signer");

            for (uint256 j = 0; j < i; j++) {
                require(signedOracles[j] != signer, "Oracles: repeated signature");
            }
            signedOracles[i] = signer;
            emit RewardsVoteSubmitted(msg.sender, signer, nonce, totalRewards, activatedValidators);
        }

        rewardsNonce.increment();

        rewardEthToken.updateTotalRewards(totalRewards);

        if (activatedValidators != pool.activatedValidators()) {
            pool.setActivatedValidators(activatedValidators);
        }
    }

    function submitMerkleRoot(
        bytes32 merkleRoot,
        string calldata merkleProofs,
        bytes[] calldata signatures
    )
        external override onlyOracle whenNotPaused
    {

        require(isMerkleRootVoting(), "Oracles: too early");
        require(isEnoughSignatures(signatures.length), "Oracles: invalid number of signatures");

        uint256 nonce = rewardsNonce.current();
        bytes32 candidateId = ECDSAUpgradeable.toEthSignedMessageHash(
            keccak256(abi.encode(nonce, merkleProofs, merkleRoot))
        );

        address[] memory signedOracles = new address[](signatures.length);
        for (uint256 i = 0; i < signatures.length; i++) {
            bytes memory signature = signatures[i];
            address signer = ECDSAUpgradeable.recover(candidateId, signature);
            require(hasRole(ORACLE_ROLE, signer), "Oracles: invalid signer");

            for (uint256 j = 0; j < i; j++) {
                require(signedOracles[j] != signer, "Oracles: repeated signature");
            }
            signedOracles[i] = signer;
            emit MerkleRootVoteSubmitted(msg.sender, signer, nonce, merkleRoot, merkleProofs);
        }

        rewardsNonce.increment();

        merkleDistributor.setMerkleRoot(merkleRoot, merkleProofs);
    }

    function registerValidators(
        IPoolValidators.DepositData[] calldata depositData,
        bytes32[][] calldata merkleProofs,
        bytes32 validatorsDepositRoot,
        bytes[] calldata signatures
    )
        external override onlyOracle whenNotPaused
    {

        require(
            pool.validatorRegistration().get_deposit_root() == validatorsDepositRoot,
            "Oracles: invalid validators deposit root"
        );
        require(isEnoughSignatures(signatures.length), "Oracles: invalid number of signatures");

        uint256 nonce = validatorsNonce.current();
        bytes32 candidateId = ECDSAUpgradeable.toEthSignedMessageHash(
            keccak256(abi.encode(nonce, depositData, validatorsDepositRoot))
        );

        address[] memory signedOracles = new address[](signatures.length);
        for (uint256 i = 0; i < signatures.length; i++) {
            bytes memory signature = signatures[i];
            address signer = ECDSAUpgradeable.recover(candidateId, signature);
            require(hasRole(ORACLE_ROLE, signer), "Oracles: invalid signer");

            for (uint256 j = 0; j < i; j++) {
                require(signedOracles[j] != signer, "Oracles: repeated signature");
            }
            signedOracles[i] = signer;
        }

        uint256 depositDataLength = depositData.length;
        require(merkleProofs.length == depositDataLength, "Oracles: invalid merkle proofs length");

        for (uint256 i = 0; i < depositDataLength; i++) {
            poolValidators.registerValidator(depositData[i], merkleProofs[i]);
        }

        emit RegisterValidatorsVoteSubmitted(msg.sender, signedOracles, nonce);

        validatorsNonce.increment();
    }
}