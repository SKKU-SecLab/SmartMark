
pragma solidity ^0.8.0;

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;


    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}// MIT

pragma solidity ^0.8.0;

interface IERC777Recipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

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
}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IDistributor {

    event WithdrawBounty(
        address holder,
        uint validatorId,
        address destination,
        uint amount
    );

    event WithdrawFee(
        uint validatorId,
        address destination,
        uint amount
    );

    event BountyWasPaid(
        uint validatorId,
        uint amount
    );
    
    function getAndUpdateEarnedBountyAmount(uint validatorId) external returns (uint earned, uint endMonth);

    function withdrawBounty(uint validatorId, address to) external;

    function withdrawFee(address to) external;

    function getAndUpdateEarnedBountyAmountOf(address wallet, uint validatorId)
        external
        returns (uint earned, uint endMonth);

    function getEarnedFeeAmount() external view returns (uint earned, uint endMonth);

    function getEarnedFeeAmountOf(uint validatorId) external view returns (uint earned, uint endMonth);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IValidatorService {

    struct Validator {
        string name;
        address validatorAddress;
        address requestedAddress;
        string description;
        uint feeRate;
        uint registrationTime;
        uint minimumDelegationAmount;
        bool acceptNewRequests;
    }
    
    event ValidatorRegistered(
        uint validatorId
    );

    event ValidatorAddressChanged(
        uint validatorId,
        address newAddress
    );

    event ValidatorWasEnabled(
        uint validatorId
    );

    event ValidatorWasDisabled(
        uint validatorId
    );

    event NodeAddressWasAdded(
        uint validatorId,
        address nodeAddress
    );

    event NodeAddressWasRemoved(
        uint validatorId,
        address nodeAddress
    );

    event WhitelistDisabled(bool status);

    event RequestNewAddress(uint indexed validatorId, address previousAddress, address newAddress);

    event SetMinimumDelegationAmount(uint indexed validatorId, uint previousMDA, uint newMDA);

    event SetValidatorName(uint indexed validatorId, string previousName, string newName);

    event SetValidatorDescription(uint indexed validatorId, string previousDescription, string newDescription);

    event AcceptingNewRequests(uint indexed validatorId, bool status);
    
    function registerValidator(
        string calldata name,
        string calldata description,
        uint feeRate,
        uint minimumDelegationAmount
    )
        external
        returns (uint validatorId);

    function enableValidator(uint validatorId) external;

    function disableValidator(uint validatorId) external;

    function disableWhitelist() external;

    function requestForNewAddress(address newValidatorAddress) external;

    function confirmNewAddress(uint validatorId) external;

    function linkNodeAddress(address nodeAddress, bytes calldata sig) external;

    function unlinkNodeAddress(address nodeAddress) external;

    function setValidatorMDA(uint minimumDelegationAmount) external;

    function setValidatorName(string calldata newName) external;

    function setValidatorDescription(string calldata newDescription) external;

    function startAcceptingNewRequests() external;

    function stopAcceptingNewRequests() external;

    function removeNodeAddress(uint validatorId, address nodeAddress) external;

    function getAndUpdateBondAmount(uint validatorId) external returns (uint);

    function getMyNodesAddresses() external view returns (address[] memory);

    function getTrustedValidators() external view returns (uint[] memory);

    function checkValidatorAddressToId(address validatorAddress, uint validatorId)
        external
        view
        returns (bool);

    function getValidatorIdByNodeAddress(address nodeAddress) external view returns (uint validatorId);

    function checkValidatorCanReceiveDelegation(uint validatorId, uint amount) external view;

    function getNodeAddresses(uint validatorId) external view returns (address[] memory);

    function validatorExists(uint validatorId) external view returns (bool);

    function validatorAddressExists(address validatorAddress) external view returns (bool);

    function checkIfValidatorAddressExists(address validatorAddress) external view;

    function getValidator(uint validatorId) external view returns (Validator memory);

    function getValidatorId(address validatorAddress) external view returns (uint);

    function isAcceptingNewRequests(uint validatorId) external view returns (bool);

    function isAuthorizedValidator(uint validatorId) external view returns (bool);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IDelegationController {

    enum State {
        PROPOSED,
        ACCEPTED,
        CANCELED,
        REJECTED,
        DELEGATED,
        UNDELEGATION_REQUESTED,
        COMPLETED
    }

    struct Delegation {
        address holder; // address of token owner
        uint validatorId;
        uint amount;
        uint delegationPeriod;
        uint created; // time of delegation creation
        uint started; // month when a delegation becomes active
        uint finished; // first month after a delegation ends
        string info;
    }

    event Confiscated(
        uint indexed validatorId,
        uint amount
    );

    event SlashesProcessed(
        address indexed holder,
        uint limit
    );

    event DelegationProposed(
        uint delegationId
    );

    event DelegationAccepted(
        uint delegationId
    );

    event DelegationRequestCanceledByUser(
        uint delegationId
    );

    event UndelegationRequested(
        uint delegationId
    );
    
    function getAndUpdateDelegatedToValidatorNow(uint validatorId) external returns (uint);

    function getAndUpdateDelegatedAmount(address holder) external returns (uint);

    function getAndUpdateEffectiveDelegatedByHolderToValidator(address holder, uint validatorId, uint month)
        external
        returns (uint effectiveDelegated);

    function delegate(
        uint validatorId,
        uint amount,
        uint delegationPeriod,
        string calldata info
    )
        external;

    function cancelPendingDelegation(uint delegationId) external;

    function acceptPendingDelegation(uint delegationId) external;

    function requestUndelegation(uint delegationId) external;

    function confiscate(uint validatorId, uint amount) external;

    function getAndUpdateEffectiveDelegatedToValidator(uint validatorId, uint month) external returns (uint);

    function getAndUpdateDelegatedByHolderToValidatorNow(address holder, uint validatorId) external returns (uint);

    function processSlashes(address holder, uint limit) external;

    function processAllSlashes(address holder) external;

    function getEffectiveDelegatedValuesByValidator(uint validatorId) external view returns (uint[] memory);

    function getEffectiveDelegatedToValidator(uint validatorId, uint month) external view returns (uint);

    function getDelegatedToValidator(uint validatorId, uint month) external view returns (uint);

    function getDelegation(uint delegationId) external view returns (Delegation memory);

    function getFirstDelegationMonth(address holder, uint validatorId) external view returns(uint);

    function getDelegationsByValidatorLength(uint validatorId) external view returns (uint);

    function getDelegationsByHolderLength(address holder) external view returns (uint);

    function getState(uint delegationId) external view returns (State state);

    function getLockedInPendingDelegations(address holder) external view returns (uint);

    function hasUnprocessedSlashes(address holder) external view returns (bool);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface ITimeHelpers {

    function calculateProofOfUseLockEndTime(uint month, uint lockUpPeriodDays) external view returns (uint timestamp);

    function getCurrentMonth() external view returns (uint);

    function timestampToYear(uint timestamp) external view returns (uint);

    function timestampToMonth(uint timestamp) external view returns (uint);

    function monthToTimestamp(uint month) external view returns (uint timestamp);

    function addDays(uint fromTimestamp, uint n) external pure returns (uint);

    function addMonths(uint fromTimestamp, uint n) external pure returns (uint);

    function addYears(uint fromTimestamp, uint n) external pure returns (uint);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IContractManager {

    event ContractUpgraded(string contractsName, address contractsAddress);

    function initialize() external;

    function setContractsAddress(string calldata contractsName, address newContractsAddress) external;

    function contracts(bytes32 nameHash) external view returns (address);

    function getDelegationPeriodManager() external view returns (address);

    function getBounty() external view returns (address);

    function getValidatorService() external view returns (address);

    function getTimeHelpers() external view returns (address);

    function getConstantsHolder() external view returns (address);

    function getSkaleToken() external view returns (address);

    function getTokenState() external view returns (address);

    function getPunisher() external view returns (address);

    function getContract(string calldata name) external view returns (address);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IPermissions {

    function initialize(address contractManagerAddress) external;

}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


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

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IAccessControlUpgradeableLegacy {

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    
    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

}// AGPL-3.0-only

pragma solidity ^0.8.7;



contract InitializableWithGap is Initializable {

    uint256[50] private ______gap;
}// MIT
pragma solidity ^0.8.7;


abstract contract AccessControlUpgradeableLegacy is InitializableWithGap, ContextUpgradeable, IAccessControlUpgradeableLegacy {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {


    }

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    struct RoleData {
        EnumerableSetUpgradeable.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
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
}// AGPL-3.0-only


pragma solidity 0.8.11;




contract Permissions is AccessControlUpgradeableLegacy, IPermissions {

    using AddressUpgradeable for address;
    
    IContractManager public contractManager;

    modifier onlyOwner() {

        require(_isOwner(), "Caller is not the owner");
        _;
    }

    modifier onlyAdmin() {

        require(_isAdmin(msg.sender), "Caller is not an admin");
        _;
    }

    modifier allow(string memory contractName) {

        require(
            contractManager.getContract(contractName) == msg.sender || _isOwner(),
            "Message sender is invalid");
        _;
    }

    modifier allowTwo(string memory contractName1, string memory contractName2) {

        require(
            contractManager.getContract(contractName1) == msg.sender ||
            contractManager.getContract(contractName2) == msg.sender ||
            _isOwner(),
            "Message sender is invalid");
        _;
    }

    modifier allowThree(string memory contractName1, string memory contractName2, string memory contractName3) {

        require(
            contractManager.getContract(contractName1) == msg.sender ||
            contractManager.getContract(contractName2) == msg.sender ||
            contractManager.getContract(contractName3) == msg.sender ||
            _isOwner(),
            "Message sender is invalid");
        _;
    }

    function initialize(address contractManagerAddress) public virtual override initializer {

        AccessControlUpgradeableLegacy.__AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setContractManager(contractManagerAddress);
    }

    function _isOwner() internal view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _isAdmin(address account) internal view returns (bool) {

        address skaleManagerAddress = contractManager.contracts(keccak256(abi.encodePacked("SkaleManager")));
        if (skaleManagerAddress != address(0)) {
            AccessControlUpgradeableLegacy skaleManager = AccessControlUpgradeableLegacy(skaleManagerAddress);
            return skaleManager.hasRole(keccak256("ADMIN_ROLE"), account) || _isOwner();
        } else {
            return _isOwner();
        }
    }

    function _setContractManager(address contractManagerAddress) private {

        require(contractManagerAddress != address(0), "ContractManager address is not set");
        require(contractManagerAddress.isContract(), "Address is not contract");
        contractManager = IContractManager(contractManagerAddress);
    }
}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IConstantsHolder {


    event ConstantUpdated(
        bytes32 indexed constantHash,
        uint previousValue,
        uint newValue
    );

    function setPeriods(uint32 newRewardPeriod, uint32 newDeltaPeriod) external;

    function setCheckTime(uint newCheckTime) external;

    function setLatency(uint32 newAllowableLatency) external;

    function setMSR(uint newMSR) external;

    function setLaunchTimestamp(uint timestamp) external;

    function setRotationDelay(uint newDelay) external;

    function setProofOfUseLockUpPeriod(uint periodDays) external;

    function setProofOfUseDelegationPercentage(uint percentage) external;

    function setLimitValidatorsPerDelegator(uint newLimit) external;

    function setSchainCreationTimeStamp(uint timestamp) external;

    function setMinimalSchainLifetime(uint lifetime) external;

    function setComplaintTimeLimit(uint timeLimit) external;

    function msr() external view returns (uint);

    function launchTimestamp() external view returns (uint);

    function rotationDelay() external view returns (uint);

    function limitValidatorsPerDelegator() external view returns (uint);

    function schainCreationTimeStamp() external view returns (uint);

    function minimalSchainLifetime() external view returns (uint);

    function complaintTimeLimit() external view returns (uint);

}// AGPL-3.0-only


pragma solidity 0.8.11;




contract ConstantsHolder is Permissions, IConstantsHolder {


    uint public constant NODE_DEPOSIT = 100 * 1e18;

    uint8 public constant TOTAL_SPACE_ON_NODE = 128;

    uint8 public constant SMALL_DIVISOR = 128;

    uint8 public constant MEDIUM_DIVISOR = 32;

    uint8 public constant LARGE_DIVISOR = 1;

    uint8 public constant MEDIUM_TEST_DIVISOR = 4;

    uint public constant NUMBER_OF_NODES_FOR_SCHAIN = 16;

    uint public constant NUMBER_OF_NODES_FOR_TEST_SCHAIN = 2;

    uint public constant NUMBER_OF_NODES_FOR_MEDIUM_TEST_SCHAIN = 4;    

    uint32 public constant SECONDS_TO_YEAR = 31622400;

    uint public constant NUMBER_OF_MONITORS = 24;

    uint public constant OPTIMAL_LOAD_PERCENTAGE = 80;

    uint public constant ADJUSTMENT_SPEED = 1000;

    uint public constant COOLDOWN_TIME = 60;

    uint public constant MIN_PRICE = 10**6;

    uint public constant MSR_REDUCING_COEFFICIENT = 2;

    uint public constant DOWNTIME_THRESHOLD_PART = 30;

    uint public constant BOUNTY_LOCKUP_MONTHS = 2;

    uint public constant ALRIGHT_DELTA = 134161;
    uint public constant BROADCAST_DELTA = 177490;
    uint public constant COMPLAINT_BAD_DATA_DELTA = 80995;
    uint public constant PRE_RESPONSE_DELTA = 100061;
    uint public constant COMPLAINT_DELTA = 104611;
    uint public constant RESPONSE_DELTA = 49132;

    uint public msr;

    uint32 public rewardPeriod;

    uint32 public allowableLatency;

    uint32 public deltaPeriod;

    uint public checkTime;


    uint public launchTimestamp;

    uint public rotationDelay;

    uint public proofOfUseLockUpPeriodDays;

    uint public proofOfUseDelegationPercentage;

    uint public limitValidatorsPerDelegator;

    uint256 public firstDelegationsMonth; // deprecated

    uint public schainCreationTimeStamp;

    uint public minimalSchainLifetime;

    uint public complaintTimeLimit;

    bytes32 public constant CONSTANTS_HOLDER_MANAGER_ROLE = keccak256("CONSTANTS_HOLDER_MANAGER_ROLE");

    modifier onlyConstantsHolderManager() {

        require(hasRole(CONSTANTS_HOLDER_MANAGER_ROLE, msg.sender), "CONSTANTS_HOLDER_MANAGER_ROLE is required");
        _;
    }

    function setPeriods(uint32 newRewardPeriod, uint32 newDeltaPeriod) external override onlyConstantsHolderManager {

        require(
            newRewardPeriod >= newDeltaPeriod && newRewardPeriod - newDeltaPeriod >= checkTime,
            "Incorrect Periods"
        );
        emit ConstantUpdated(
            keccak256(abi.encodePacked("RewardPeriod")),
            uint(rewardPeriod),
            uint(newRewardPeriod)
        );
        rewardPeriod = newRewardPeriod;
        emit ConstantUpdated(
            keccak256(abi.encodePacked("DeltaPeriod")),
            uint(deltaPeriod),
            uint(newDeltaPeriod)
        );
        deltaPeriod = newDeltaPeriod;
    }

    function setCheckTime(uint newCheckTime) external override onlyConstantsHolderManager {

        require(rewardPeriod - deltaPeriod >= checkTime, "Incorrect check time");
        emit ConstantUpdated(
            keccak256(abi.encodePacked("CheckTime")),
            uint(checkTime),
            uint(newCheckTime)
        );
        checkTime = newCheckTime;
    }    

    function setLatency(uint32 newAllowableLatency) external override onlyConstantsHolderManager {

        emit ConstantUpdated(
            keccak256(abi.encodePacked("AllowableLatency")),
            uint(allowableLatency),
            uint(newAllowableLatency)
        );
        allowableLatency = newAllowableLatency;
    }

    function setMSR(uint newMSR) external override onlyConstantsHolderManager {

        emit ConstantUpdated(
            keccak256(abi.encodePacked("MSR")),
            uint(msr),
            uint(newMSR)
        );
        msr = newMSR;
    }

    function setLaunchTimestamp(uint timestamp) external override onlyConstantsHolderManager {

        require(
            block.timestamp < launchTimestamp,
            "Cannot set network launch timestamp because network is already launched"
        );
        emit ConstantUpdated(
            keccak256(abi.encodePacked("LaunchTimestamp")),
            uint(launchTimestamp),
            uint(timestamp)
        );
        launchTimestamp = timestamp;
    }

    function setRotationDelay(uint newDelay) external override onlyConstantsHolderManager {

        emit ConstantUpdated(
            keccak256(abi.encodePacked("RotationDelay")),
            uint(rotationDelay),
            uint(newDelay)
        );
        rotationDelay = newDelay;
    }

    function setProofOfUseLockUpPeriod(uint periodDays) external override onlyConstantsHolderManager {

        emit ConstantUpdated(
            keccak256(abi.encodePacked("ProofOfUseLockUpPeriodDays")),
            uint(proofOfUseLockUpPeriodDays),
            uint(periodDays)
        );
        proofOfUseLockUpPeriodDays = periodDays;
    }

    function setProofOfUseDelegationPercentage(uint percentage) external override onlyConstantsHolderManager {

        require(percentage <= 100, "Percentage value is incorrect");
        emit ConstantUpdated(
            keccak256(abi.encodePacked("ProofOfUseDelegationPercentage")),
            uint(proofOfUseDelegationPercentage),
            uint(percentage)
        );
        proofOfUseDelegationPercentage = percentage;
    }

    function setLimitValidatorsPerDelegator(uint newLimit) external override onlyConstantsHolderManager {

        emit ConstantUpdated(
            keccak256(abi.encodePacked("LimitValidatorsPerDelegator")),
            uint(limitValidatorsPerDelegator),
            uint(newLimit)
        );
        limitValidatorsPerDelegator = newLimit;
    }

    function setSchainCreationTimeStamp(uint timestamp) external override onlyConstantsHolderManager {

        emit ConstantUpdated(
            keccak256(abi.encodePacked("SchainCreationTimeStamp")),
            uint(schainCreationTimeStamp),
            uint(timestamp)
        );
        schainCreationTimeStamp = timestamp;
    }

    function setMinimalSchainLifetime(uint lifetime) external override onlyConstantsHolderManager {

        emit ConstantUpdated(
            keccak256(abi.encodePacked("MinimalSchainLifetime")),
            uint(minimalSchainLifetime),
            uint(lifetime)
        );
        minimalSchainLifetime = lifetime;
    }

    function setComplaintTimeLimit(uint timeLimit) external override onlyConstantsHolderManager {

        emit ConstantUpdated(
            keccak256(abi.encodePacked("ComplaintTimeLimit")),
            uint(complaintTimeLimit),
            uint(timeLimit)
        );
        complaintTimeLimit = timeLimit;
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);

        msr = 0;
        rewardPeriod = 2592000;
        allowableLatency = 150000;
        deltaPeriod = 3600;
        checkTime = 300;
        launchTimestamp = type(uint).max;
        rotationDelay = 12 hours;
        proofOfUseLockUpPeriodDays = 90;
        proofOfUseDelegationPercentage = 50;
        limitValidatorsPerDelegator = 20;
        firstDelegationsMonth = 0;
        complaintTimeLimit = 1800;
    }
}// AGPL-3.0-only


pragma solidity 0.8.11;


library MathUtils {


    uint constant private _EPS = 1e6;

    event UnderflowError(
        uint a,
        uint b
    );    

    function boundedSub(uint256 a, uint256 b) internal returns (uint256) {

        if (a >= b) {
            return a - b;
        } else {
            emit UnderflowError(a, b);
            return 0;
        }
    }

    function boundedSubWithoutEvent(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a >= b) {
            return a - b;
        } else {
            return 0;
        }
    }

    function muchGreater(uint256 a, uint256 b) internal pure returns (bool) {

        assert(type(uint).max - _EPS > b);
        return a > b + _EPS;
    }

    function approximatelyEqual(uint256 a, uint256 b) internal pure returns (bool) {

        if (a > b) {
            return a - b < _EPS;
        } else {
            return b - a < _EPS;
        }
    }
}// AGPL-3.0-only


pragma solidity 0.8.11;





contract Distributor is Permissions, IERC777Recipient, IDistributor {

    using MathUtils for uint;

    IERC1820Registry private _erc1820;

    mapping (uint => mapping (uint => uint)) private _bountyPaid;
    mapping (uint => mapping (uint => uint)) private _feePaid;
    mapping (address => mapping (uint => uint)) private _firstUnwithdrawnMonth;
    mapping (uint => uint) private _firstUnwithdrawnMonthForValidator;

    function getAndUpdateEarnedBountyAmount(uint validatorId) external override returns (uint earned, uint endMonth) {

        return getAndUpdateEarnedBountyAmountOf(msg.sender, validatorId);
    }

    function withdrawBounty(uint validatorId, address to) external override {

        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

        require(block.timestamp >= timeHelpers.addMonths(
                constantsHolder.launchTimestamp(),
                constantsHolder.BOUNTY_LOCKUP_MONTHS()
            ), "Bounty is locked");

        uint bounty;
        uint endMonth;
        (bounty, endMonth) = getAndUpdateEarnedBountyAmountOf(msg.sender, validatorId);

        _firstUnwithdrawnMonth[msg.sender][validatorId] = endMonth;

        IERC20 skaleToken = IERC20(contractManager.getContract("SkaleToken"));
        require(skaleToken.transfer(to, bounty), "Failed to transfer tokens");

        emit WithdrawBounty(
            msg.sender,
            validatorId,
            to,
            bounty
        );
    }

    function withdrawFee(address to) external override {

        IValidatorService validatorService = IValidatorService(contractManager.getContract("ValidatorService"));
        IERC20 skaleToken = IERC20(contractManager.getContract("SkaleToken"));
        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

        require(block.timestamp >= timeHelpers.addMonths(
                constantsHolder.launchTimestamp(),
                constantsHolder.BOUNTY_LOCKUP_MONTHS()
            ), "Fee is locked");
        uint validatorId = validatorService.getValidatorId(msg.sender);

        uint fee;
        uint endMonth;
        (fee, endMonth) = getEarnedFeeAmountOf(validatorId);

        _firstUnwithdrawnMonthForValidator[validatorId] = endMonth;

        require(skaleToken.transfer(to, fee), "Failed to transfer tokens");

        emit WithdrawFee(
            validatorId,
            to,
            fee
        );
    }

    function tokensReceived(
        address,
        address,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata
    )
        external
        override
        allow("SkaleToken")
    {

        require(to == address(this), "Receiver is incorrect");
        require(userData.length == 32, "Data length is incorrect");
        uint validatorId = abi.decode(userData, (uint));
        _distributeBounty(amount, validatorId);
    }

    function getEarnedFeeAmount() external view override returns (uint earned, uint endMonth) {

        IValidatorService validatorService = IValidatorService(contractManager.getContract("ValidatorService"));
        return getEarnedFeeAmountOf(validatorService.getValidatorId(msg.sender));
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);
        _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    function getAndUpdateEarnedBountyAmountOf(address wallet, uint validatorId)
        public
        override
        returns (uint earned, uint endMonth)
    {

        IDelegationController delegationController = IDelegationController(
            contractManager.getContract("DelegationController"));
        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));

        uint currentMonth = timeHelpers.getCurrentMonth();

        uint startMonth = _firstUnwithdrawnMonth[wallet][validatorId];
        if (startMonth == 0) {
            startMonth = delegationController.getFirstDelegationMonth(wallet, validatorId);
            if (startMonth == 0) {
                return (0, 0);
            }
        }

        earned = 0;
        endMonth = currentMonth;
        if (endMonth > startMonth + 12) {
            endMonth = startMonth + 12;
        }
        for (uint i = startMonth; i < endMonth; ++i) {
            uint effectiveDelegatedToValidator =
                delegationController.getAndUpdateEffectiveDelegatedToValidator(validatorId, i);
            if (effectiveDelegatedToValidator.muchGreater(0)) {
                earned = earned + 
                    _bountyPaid[validatorId][i] *
                    delegationController.getAndUpdateEffectiveDelegatedByHolderToValidator(wallet, validatorId, i) /
                    effectiveDelegatedToValidator;
            }
        }
    }

    function getEarnedFeeAmountOf(uint validatorId) public view override returns (uint earned, uint endMonth) {

        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));

        uint currentMonth = timeHelpers.getCurrentMonth();

        uint startMonth = _firstUnwithdrawnMonthForValidator[validatorId];
        if (startMonth == 0) {
            return (0, 0);
        }

        earned = 0;
        endMonth = currentMonth;
        if (endMonth > startMonth + 12) {
            endMonth = startMonth + 12;
        }
        for (uint i = startMonth; i < endMonth; ++i) {
            earned = earned + _feePaid[validatorId][i];
        }
    }


    function _distributeBounty(uint amount, uint validatorId) private {

        ITimeHelpers timeHelpers = ITimeHelpers(contractManager.getContract("TimeHelpers"));
        IValidatorService validatorService = IValidatorService(contractManager.getContract("ValidatorService"));

        uint currentMonth = timeHelpers.getCurrentMonth();
        uint feeRate = validatorService.getValidator(validatorId).feeRate;

        uint fee = amount * feeRate / 1000;
        uint bounty = amount - fee;
        _bountyPaid[validatorId][currentMonth] = _bountyPaid[validatorId][currentMonth] + bounty;
        _feePaid[validatorId][currentMonth] = _feePaid[validatorId][currentMonth] + fee;

        if (_firstUnwithdrawnMonthForValidator[validatorId] == 0) {
            _firstUnwithdrawnMonthForValidator[validatorId] = currentMonth;
        }

        emit BountyWasPaid(validatorId, amount);
    }
}