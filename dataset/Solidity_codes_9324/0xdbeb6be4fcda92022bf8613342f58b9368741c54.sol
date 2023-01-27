
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


library SafeCastUpgradeable {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
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

interface IERC20PermitUpgradeable {

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract EIP712Upgradeable is Initializable {
    bytes32 private _HASHED_NAME;
    bytes32 private _HASHED_VERSION;
    bytes32 private constant _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function __EIP712_init(string memory name, string memory version) internal initializer {
        __EIP712_init_unchained(name, version);
    }

    function __EIP712_init_unchained(string memory name, string memory version) internal initializer {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash());
    }

    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                name,
                version,
                _getChainId(),
                address(this)
            )
        );
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        assembly {
            chainId := chainid()
        }
    }

    function _EIP712NameHash() internal virtual view returns (bytes32) {
        return _HASHED_NAME;
    }

    function _EIP712VersionHash() internal virtual view returns (bytes32) {
        return _HASHED_VERSION;
    }
    uint256[50] private __gap;
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

pragma solidity 0.7.5;



abstract contract ERC20Upgradeable is Initializable, IERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (sender != msg.sender && currentAllowance != uint256(-1)) {
            _approve(sender, msg.sender, currentAllowance.sub(amount));
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual;

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    uint256[44] private __gap;
}// MIT

pragma solidity 0.7.5;


abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20PermitUpgradeable, EIP712Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    mapping (address => CountersUpgradeable.Counter) private _nonces;

    bytes32 private _PERMIT_TYPEHASH;

    function __ERC20Permit_init(string memory name) internal initializer {
        __EIP712_init_unchained(name, "1");
        __ERC20Permit_init_unchained();
    }

    function __ERC20Permit_init_unchained() internal initializer {
        _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _nonces[owner].current(),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSAUpgradeable.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, value);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
    uint256[49] private __gap;
}// AGPL-3.0-only

pragma solidity 0.7.5;


contract RewardEthToken is IRewardEthToken, OwnablePausableUpgradeable, ERC20PermitUpgradeable {

    using SafeMathUpgradeable for uint256;
    using SafeCastUpgradeable for uint256;

    IStakedEthToken private stakedEthToken;

    address private oracles;

    mapping(address => Checkpoint) public override checkpoints;

    address public override protocolFeeRecipient;

    uint256 public override protocolFee;

    uint128 public override totalRewards;

    uint128 public override rewardPerToken;

    uint256 public override lastUpdateBlockNumber;

    address public override merkleDistributor;

    mapping(address => bool) public override rewardsDisabled;

    IWhiteListManager private whiteListManager;

    function initialize(
        address admin,
        address _stakedEthToken,
        address _oracles,
        address _protocolFeeRecipient,
        uint256 _protocolFee,
        address _merkleDistributor,
        address _whiteListManager
    )
        external override initializer
    {

        require(admin != address(0), "RewardEthToken: invalid admin address");
        require(_stakedEthToken != address(0), "RewardEthToken: invalid StakedEthToken address");
        require(_oracles != address(0), "RewardEthToken: invalid Oracles address");
        require(_protocolFeeRecipient != address(0), "RewardEthToken: invalid protocol fee recipient address");
        require(_protocolFee < 1e4, "RewardEthToken: invalid protocol fee");
        require(_merkleDistributor != address(0), "RewardEthToken: invalid MerkleDistributor address");

        __OwnablePausableUpgradeable_init(admin);
        __ERC20_init("Reward ETH Harbour", "rETH-h");
        __ERC20Permit_init("Reward ETH Harbour");

        stakedEthToken = IStakedEthToken(_stakedEthToken);
        oracles = _oracles;
        protocolFeeRecipient = _protocolFeeRecipient;
        protocolFee = _protocolFee;
        merkleDistributor = _merkleDistributor;
        whiteListManager = IWhiteListManager(_whiteListManager);
    }

    function setRewardsDisabled(address account, bool isDisabled) external override {

        require(msg.sender == address(stakedEthToken), "RewardEthToken: access denied");
        require(rewardsDisabled[account] != isDisabled, "RewardEthToken: value did not change");

        uint128 _rewardPerToken = rewardPerToken;
        checkpoints[account] = Checkpoint({
            reward: _balanceOf(account, _rewardPerToken).toUint128(),
            rewardPerToken: _rewardPerToken
        });

        rewardsDisabled[account] = isDisabled;
        emit RewardsToggled(account, isDisabled);
    }

    function setProtocolFeeRecipient(address recipient) external override onlyAdmin {

        protocolFeeRecipient = recipient;
        emit ProtocolFeeRecipientUpdated(recipient);
    }

    function setProtocolFee(uint256 _protocolFee) external override onlyAdmin {

        require(_protocolFee < 1e4, "RewardEthToken: invalid protocol fee");
        protocolFee = _protocolFee;
        emit ProtocolFeeUpdated(_protocolFee);
    }

    function totalSupply() external view override returns (uint256) {

        return totalRewards;
    }

    function balanceOf(address account) external view override returns (uint256) {

        return _balanceOf(account, rewardPerToken);
    }

    function _balanceOf(address account, uint256 _rewardPerToken) internal view returns (uint256) {

        Checkpoint memory cp = checkpoints[account];

        if (_rewardPerToken == cp.rewardPerToken || rewardsDisabled[account]) return cp.reward;

        uint256 stakedEthAmount;
        if (account == address(0)) {
            stakedEthAmount = stakedEthToken.distributorPrincipal();
        } else {
            stakedEthAmount = stakedEthToken.balanceOf(account);
        }
        if (stakedEthAmount == 0) return cp.reward;

        return _calculateNewReward(cp.reward, stakedEthAmount, _rewardPerToken.sub(cp.rewardPerToken));
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override whenNotPaused {

        require(whiteListManager.whitelistedAccounts(sender), "RewardEthToken: invalid sender");
        require(whiteListManager.whitelistedAccounts(recipient), "RewardEthToken: invalid receiver");
        require(block.number > lastUpdateBlockNumber, "RewardEthToken: cannot transfer during rewards update");

        uint128 _rewardPerToken = rewardPerToken; // gas savings
        checkpoints[sender] = Checkpoint({
            reward: _balanceOf(sender, _rewardPerToken).sub(amount).toUint128(),
            rewardPerToken: _rewardPerToken
        });
        checkpoints[recipient] = Checkpoint({
            reward: _balanceOf(recipient, _rewardPerToken).add(amount).toUint128(),
            rewardPerToken: _rewardPerToken
        });

        emit Transfer(sender, recipient, amount);
    }

    function updateRewardCheckpoint(address account) external override returns (bool accRewardsDisabled) {

        accRewardsDisabled = rewardsDisabled[account];
        if (!accRewardsDisabled) _updateRewardCheckpoint(account, rewardPerToken);
    }

    function _updateRewardCheckpoint(address account, uint128 newRewardPerToken) internal {

        Checkpoint memory cp = checkpoints[account];
        if (newRewardPerToken == cp.rewardPerToken) return;

        uint256 stakedEthAmount;
        if (account == address(0)) {
            stakedEthAmount = stakedEthToken.distributorPrincipal();
        } else {
            stakedEthAmount = stakedEthToken.balanceOf(account);
        }
        if (stakedEthAmount == 0) {
            checkpoints[account] = Checkpoint({
                reward: cp.reward,
                rewardPerToken: newRewardPerToken
            });
        } else {
            uint256 periodRewardPerToken = uint256(newRewardPerToken).sub(cp.rewardPerToken);
            checkpoints[account] = Checkpoint({
                reward: _calculateNewReward(cp.reward, stakedEthAmount, periodRewardPerToken).toUint128(),
                rewardPerToken: newRewardPerToken
            });
        }
    }

    function _calculateNewReward(
        uint256 currentReward,
        uint256 stakedEthAmount,
        uint256 periodRewardPerToken
    )
        internal pure returns (uint256)
    {

        return currentReward.add(stakedEthAmount.mul(periodRewardPerToken).div(1e18));
    }

    function updateRewardCheckpoints(address account1, address account2) external override returns (bool rewardsDisabled1, bool rewardsDisabled2) {

        rewardsDisabled1 = rewardsDisabled[account1];
        rewardsDisabled2 = rewardsDisabled[account2];
        if (!rewardsDisabled1 || !rewardsDisabled2) {
            uint128 newRewardPerToken = rewardPerToken;
            if (!rewardsDisabled1) _updateRewardCheckpoint(account1, newRewardPerToken);
            if (!rewardsDisabled2) _updateRewardCheckpoint(account2, newRewardPerToken);
        }
    }

    function updateTotalRewards(uint256 newTotalRewards) external override {

        require(msg.sender == oracles, "RewardEthToken: access denied");

        uint256 periodRewards = newTotalRewards.sub(totalRewards);
        if (periodRewards == 0) {
            lastUpdateBlockNumber = block.number;
            emit RewardsUpdated(0, newTotalRewards, rewardPerToken, 0, 0);
            return;
        }

        uint256 protocolReward = periodRewards.mul(protocolFee).div(1e4);
        uint256 prevRewardPerToken = rewardPerToken;
        uint256 newRewardPerToken = prevRewardPerToken.add(periodRewards.sub(protocolReward).mul(1e18).div(stakedEthToken.totalDeposits()));
        uint128 newRewardPerToken128 = newRewardPerToken.toUint128();

        uint256 prevDistributorBalance = _balanceOf(address(0), prevRewardPerToken);

        (totalRewards, rewardPerToken) = (newTotalRewards.toUint128(), newRewardPerToken128);

        uint256 newDistributorBalance = _balanceOf(address(0), newRewardPerToken);
        address _protocolFeeRecipient = protocolFeeRecipient;
        if (_protocolFeeRecipient == address(0) && protocolReward > 0) {
            newDistributorBalance = newDistributorBalance.add(protocolReward);
        } else if (protocolReward > 0) {
            checkpoints[_protocolFeeRecipient] = Checkpoint({
                reward: _balanceOf(_protocolFeeRecipient, newRewardPerToken).add(protocolReward).toUint128(),
                rewardPerToken: newRewardPerToken128
            });
        }

        if (newDistributorBalance != prevDistributorBalance) {
            checkpoints[address(0)] = Checkpoint({
                reward: newDistributorBalance.toUint128(),
                rewardPerToken: newRewardPerToken128
            });
        }

        lastUpdateBlockNumber = block.number;
        emit RewardsUpdated(
            periodRewards,
            newTotalRewards,
            newRewardPerToken,
            newDistributorBalance.sub(prevDistributorBalance),
            _protocolFeeRecipient == address(0) ? protocolReward: 0
        );
    }

    function claim(address account, uint256 amount) external override {

        require(msg.sender == merkleDistributor, "RewardEthToken: access denied");
        require(whiteListManager.whitelistedAccounts(account), "RewardEthToken: invalid account");

        uint128 _rewardPerToken = rewardPerToken;
        checkpoints[address(0)] = Checkpoint({
            reward: _balanceOf(address(0), _rewardPerToken).sub(amount).toUint128(),
            rewardPerToken: _rewardPerToken
        });
        checkpoints[account] = Checkpoint({
            reward: _balanceOf(account, _rewardPerToken).add(amount).toUint128(),
            rewardPerToken: _rewardPerToken
        });
        emit Transfer(address(0), account, amount);
    }
}