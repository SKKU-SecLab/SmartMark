
pragma solidity ^0.8.0;

interface IERC777 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function granularity() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;


    function burn(uint256 amount, bytes calldata data) external;


    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);


    function authorizeOperator(address operator) external;


    function revokeOperator(address operator) external;


    function defaultOperators() external view returns (address[] memory);


    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
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

interface IDelegationPeriodManager {

    event DelegationPeriodWasSet(
        uint length,
        uint stakeMultiplier
    );
    
    function setDelegationPeriod(uint monthsCount, uint stakeMultiplier) external;

    function stakeMultipliers(uint monthsCount) external view returns (uint);

    function isDelegationPeriodAllowed(uint monthsCount) external view returns (bool);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IPunisher {

    event Slash(
        uint validatorId,
        uint amount
    );

    event Forgive(
        address wallet,
        uint amount
    );
    
    function slash(uint validatorId, uint amount) external;

    function forgive(address holder, uint amount) external;

    function handleSlash(address holder, uint amount) external;

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface ITokenState {

    event LockerWasAdded(
        string locker
    );

    event LockerWasRemoved(
        string locker
    );
    
    function removeLocker(string calldata locker) external;

    function addLocker(string memory locker) external;

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

interface ILocker {

    function getAndUpdateLockedAmount(address wallet) external returns (uint);


    function getAndUpdateForbiddenForDelegationAmount(address wallet) external returns (uint);

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

interface IBountyV2 {


    event BountyReduction(bool status);
    event NodeCreationWindowWasChanged(
        uint oldValue,
        uint newValue
    );

    function calculateBounty(uint nodeIndex) external returns (uint);

    function enableBountyReduction() external;

    function disableBountyReduction() external;

    function setNodeCreationWindowSeconds(uint window) external;

    function handleDelegationAdd(uint amount, uint month) external;

    function handleDelegationRemoving(uint amount, uint month) external;

    function estimateBounty(uint nodeIndex) external view returns (uint);

    function getNextRewardTimestamp(uint nodeIndex) external view returns (uint);

    function getEffectiveDelegatedSum() external view returns (uint[] memory);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;


interface IRandom {

    struct RandomGenerator {
        uint seed;
    }
}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;


interface INodes {

    enum NodeStatus {Active, Leaving, Left, In_Maintenance}

    struct Node {
        string name;
        bytes4 ip;
        bytes4 publicIP;
        uint16 port;
        bytes32[2] publicKey;
        uint startBlock;
        uint lastRewardDate;
        uint finishTime;
        NodeStatus status;
        uint validatorId;
    }

    struct CreatedNodes {
        mapping (uint => bool) isNodeExist;
        uint numberOfNodes;
    }

    struct SpaceManaging {
        uint8 freeSpace;
        uint indexInSpaceMap;
    }

    struct NodeCreationParams {
        string name;
        bytes4 ip;
        bytes4 publicIp;
        uint16 port;
        bytes32[2] publicKey;
        uint16 nonce;
        string domainName;
    }
    
    event NodeCreated(
        uint nodeIndex,
        address owner,
        string name,
        bytes4 ip,
        bytes4 publicIP,
        uint16 port,
        uint16 nonce,
        string domainName
    );

    event ExitCompleted(
        uint nodeIndex
    );

    event ExitInitialized(
        uint nodeIndex,
        uint startLeavingPeriod
    );

    event IncompliantNode(
        uint indexed nodeIndex,
        bool status
    );

    event MaintenanceNode(
        uint indexed nodeIndex,
        bool status
    );

    event IPChanged(
        uint indexed nodeIndex,
        bytes4 previousIP,
        bytes4 newIP
    );
    
    function removeSpaceFromNode(uint nodeIndex, uint8 space) external returns (bool);

    function addSpaceToNode(uint nodeIndex, uint8 space) external;

    function changeNodeLastRewardDate(uint nodeIndex) external;

    function changeNodeFinishTime(uint nodeIndex, uint time) external;

    function createNode(address from, NodeCreationParams calldata params) external;

    function initExit(uint nodeIndex) external;

    function completeExit(uint nodeIndex) external returns (bool);

    function deleteNodeForValidator(uint validatorId, uint nodeIndex) external;

    function checkPossibilityCreatingNode(address nodeAddress) external;

    function checkPossibilityToMaintainNode(uint validatorId, uint nodeIndex) external returns (bool);

    function setNodeInMaintenance(uint nodeIndex) external;

    function removeNodeFromInMaintenance(uint nodeIndex) external;

    function setNodeIncompliant(uint nodeIndex) external;

    function setNodeCompliant(uint nodeIndex) external;

    function setDomainName(uint nodeIndex, string memory domainName) external;

    function makeNodeVisible(uint nodeIndex) external;

    function makeNodeInvisible(uint nodeIndex) external;

    function changeIP(uint nodeIndex, bytes4 newIP, bytes4 newPublicIP) external;

    function numberOfActiveNodes() external view returns (uint);

    function incompliant(uint nodeIndex) external view returns (bool);

    function getRandomNodeWithFreeSpace(
        uint8 freeSpace,
        IRandom.RandomGenerator memory randomGenerator
    )
        external
        view
        returns (uint);

    function isTimeForReward(uint nodeIndex) external view returns (bool);

    function getNodeIP(uint nodeIndex) external view returns (bytes4);

    function getNodeDomainName(uint nodeIndex) external view returns (string memory);

    function getNodePort(uint nodeIndex) external view returns (uint16);

    function getNodePublicKey(uint nodeIndex) external view returns (bytes32[2] memory);

    function getNodeAddress(uint nodeIndex) external view returns (address);

    function getNodeFinishTime(uint nodeIndex) external view returns (uint);

    function isNodeLeft(uint nodeIndex) external view returns (bool);

    function isNodeInMaintenance(uint nodeIndex) external view returns (bool);

    function getNodeLastRewardDate(uint nodeIndex) external view returns (uint);

    function getNodeNextRewardDate(uint nodeIndex) external view returns (uint);

    function getNumberOfNodes() external view returns (uint);

    function getNumberOnlineNodes() external view returns (uint);

    function getActiveNodeIds() external view returns (uint[] memory activeNodeIds);

    function getNodeStatus(uint nodeIndex) external view returns (NodeStatus);

    function getValidatorNodeIndexes(uint validatorId) external view returns (uint[] memory);

    function countNodesWithFreeSpace(uint8 freeSpace) external view returns (uint count);

    function getValidatorId(uint nodeIndex) external view returns (uint);

    function isNodeExist(address from, uint nodeIndex) external view returns (bool);

    function isNodeActive(uint nodeIndex) external view returns (bool);

    function isNodeLeaving(uint nodeIndex) external view returns (bool);

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


pragma solidity 0.8.11;


library FractionUtils {


    struct Fraction {
        uint numerator;
        uint denominator;
    }

    function createFraction(uint numerator, uint denominator) internal pure returns (Fraction memory) {

        require(denominator > 0, "Division by zero");
        Fraction memory fraction = Fraction({numerator: numerator, denominator: denominator});
        reduceFraction(fraction);
        return fraction;
    }

    function createFraction(uint value) internal pure returns (Fraction memory) {

        return createFraction(value, 1);
    }

    function reduceFraction(Fraction memory fraction) internal pure {

        uint _gcd = gcd(fraction.numerator, fraction.denominator);
        fraction.numerator = fraction.numerator / _gcd;
        fraction.denominator = fraction.denominator / _gcd;
    }
    
    function multiplyFraction(Fraction memory a, Fraction memory b) internal pure returns (Fraction memory) {

        return createFraction(a.numerator * b.numerator, a.denominator * b.denominator);
    }

    function gcd(uint a, uint b) internal pure returns (uint) {

        uint _a = a;
        uint _b = b;
        if (_b > _a) {
            (_a, _b) = swap(_a, _b);
        }
        while (_b > 0) {
            _a = _a % _b;
            (_a, _b) = swap (_a, _b);
        }
        return _a;
    }

    function swap(uint a, uint b) internal pure returns (uint, uint) {

        return (b, a);
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


library PartialDifferences {

    using MathUtils for uint;

    struct Sequence {
        mapping (uint => uint) addDiff;
        mapping (uint => uint) subtractDiff;
        mapping (uint => uint) value;

        uint firstUnprocessedMonth;
        uint lastChangedMonth;
    }

    struct Value {
        mapping (uint => uint) addDiff;
        mapping (uint => uint) subtractDiff;

        uint value;
        uint firstUnprocessedMonth;
        uint lastChangedMonth;
    }


    function addToSequence(Sequence storage sequence, uint diff, uint month) internal {

        require(sequence.firstUnprocessedMonth <= month, "Cannot add to the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
        }
        sequence.addDiff[month] = sequence.addDiff[month] + diff;
        if (sequence.lastChangedMonth != month) {
            sequence.lastChangedMonth = month;
        }
    }

    function subtractFromSequence(Sequence storage sequence, uint diff, uint month) internal {

        require(sequence.firstUnprocessedMonth <= month, "Cannot subtract from the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
        }
        sequence.subtractDiff[month] = sequence.subtractDiff[month] + diff;
        if (sequence.lastChangedMonth != month) {
            sequence.lastChangedMonth = month;
        }
    }

    function getAndUpdateValueInSequence(Sequence storage sequence, uint month) internal returns (uint) {

        if (sequence.firstUnprocessedMonth == 0) {
            return 0;
        }

        if (sequence.firstUnprocessedMonth <= month) {
            for (uint i = sequence.firstUnprocessedMonth; i <= month; ++i) {
                uint nextValue = (sequence.value[i - 1] + sequence.addDiff[i]).boundedSub(sequence.subtractDiff[i]);
                if (sequence.value[i] != nextValue) {
                    sequence.value[i] = nextValue;
                }
                if (sequence.addDiff[i] > 0) {
                    delete sequence.addDiff[i];
                }
                if (sequence.subtractDiff[i] > 0) {
                    delete sequence.subtractDiff[i];
                }
            }
            sequence.firstUnprocessedMonth = month + 1;
        }

        return sequence.value[month];
    }

    function reduceSequence(
        Sequence storage sequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month) internal
    {

        require(month + 1 >= sequence.firstUnprocessedMonth, "Cannot reduce value in the past");
        require(
            reducingCoefficient.numerator <= reducingCoefficient.denominator,
            "Increasing of values is not implemented");
        if (sequence.firstUnprocessedMonth == 0) {
            return;
        }
        uint value = getAndUpdateValueInSequence(sequence, month);
        if (value.approximatelyEqual(0)) {
            return;
        }

        sequence.value[month] = sequence.value[month]
            * reducingCoefficient.numerator
            / reducingCoefficient.denominator;

        for (uint i = month + 1; i <= sequence.lastChangedMonth; ++i) {
            sequence.subtractDiff[i] = sequence.subtractDiff[i]
                * reducingCoefficient.numerator
                / reducingCoefficient.denominator;
        }
    }


    function addToValue(Value storage sequence, uint diff, uint month) internal {

        require(sequence.firstUnprocessedMonth <= month, "Cannot add to the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
            sequence.lastChangedMonth = month;
        }
        if (month > sequence.lastChangedMonth) {
            sequence.lastChangedMonth = month;
        }

        if (month >= sequence.firstUnprocessedMonth) {
            sequence.addDiff[month] = sequence.addDiff[month] + diff;
        } else {
            sequence.value = sequence.value + diff;
        }
    }

    function subtractFromValue(Value storage sequence, uint diff, uint month) internal {

        require(sequence.firstUnprocessedMonth <= month + 1, "Cannot subtract from the past");
        if (sequence.firstUnprocessedMonth == 0) {
            sequence.firstUnprocessedMonth = month;
            sequence.lastChangedMonth = month;
        }
        if (month > sequence.lastChangedMonth) {
            sequence.lastChangedMonth = month;
        }

        if (month >= sequence.firstUnprocessedMonth) {
            sequence.subtractDiff[month] = sequence.subtractDiff[month] + diff;
        } else {
            sequence.value = sequence.value.boundedSub(diff);
        }
    }

    function getAndUpdateValue(Value storage sequence, uint month) internal returns (uint) {

        require(
            month + 1 >= sequence.firstUnprocessedMonth,
            "Cannot calculate value in the past");
        if (sequence.firstUnprocessedMonth == 0) {
            return 0;
        }

        if (sequence.firstUnprocessedMonth <= month) {
            uint value = sequence.value;
            for (uint i = sequence.firstUnprocessedMonth; i <= month; ++i) {
                value = (value + sequence.addDiff[i]).boundedSub(sequence.subtractDiff[i]);
                if (sequence.addDiff[i] > 0) {
                    delete sequence.addDiff[i];
                }
                if (sequence.subtractDiff[i] > 0) {
                    delete sequence.subtractDiff[i];
                }
            }
            if (sequence.value != value) {
                sequence.value = value;
            }
            sequence.firstUnprocessedMonth = month + 1;
        }

        return sequence.value;
    }

    function reduceValue(
        Value storage sequence,
        uint amount,
        uint month)
        internal returns (FractionUtils.Fraction memory)
    {

        require(month + 1 >= sequence.firstUnprocessedMonth, "Cannot reduce value in the past");
        if (sequence.firstUnprocessedMonth == 0) {
            return FractionUtils.createFraction(0);
        }
        uint value = getAndUpdateValue(sequence, month);
        if (value.approximatelyEqual(0)) {
            return FractionUtils.createFraction(0);
        }

        uint _amount = amount;
        if (value < amount) {
            _amount = value;
        }

        FractionUtils.Fraction memory reducingCoefficient =
            FractionUtils.createFraction(value.boundedSub(_amount), value);
        reduceValueByCoefficient(sequence, reducingCoefficient, month);
        return reducingCoefficient;
    }

    function reduceValueByCoefficient(
        Value storage sequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month)
        internal
    {

        reduceValueByCoefficientAndUpdateSumIfNeeded(
            sequence,
            sequence,
            reducingCoefficient,
            month,
            false);
    }

    function reduceValueByCoefficientAndUpdateSum(
        Value storage sequence,
        Value storage sumSequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month) internal
    {

        reduceValueByCoefficientAndUpdateSumIfNeeded(
            sequence,
            sumSequence,
            reducingCoefficient,
            month,
            true);
    }

    function reduceValueByCoefficientAndUpdateSumIfNeeded(
        Value storage sequence,
        Value storage sumSequence,
        FractionUtils.Fraction memory reducingCoefficient,
        uint month,
        bool hasSumSequence) internal
    {

        require(month + 1 >= sequence.firstUnprocessedMonth, "Cannot reduce value in the past");
        if (hasSumSequence) {
            require(month + 1 >= sumSequence.firstUnprocessedMonth, "Cannot reduce value in the past");
        }
        require(
            reducingCoefficient.numerator <= reducingCoefficient.denominator,
            "Increasing of values is not implemented");
        if (sequence.firstUnprocessedMonth == 0) {
            return;
        }
        uint value = getAndUpdateValue(sequence, month);
        if (value.approximatelyEqual(0)) {
            return;
        }

        uint newValue = sequence.value * reducingCoefficient.numerator / reducingCoefficient.denominator;
        if (hasSumSequence) {
            subtractFromValue(sumSequence, sequence.value.boundedSub(newValue), month);
        }
        sequence.value = newValue;

        for (uint i = month + 1; i <= sequence.lastChangedMonth; ++i) {
            uint newDiff = sequence.subtractDiff[i]
                * reducingCoefficient.numerator
                / reducingCoefficient.denominator;
            if (hasSumSequence) {
                sumSequence.subtractDiff[i] = sumSequence.subtractDiff[i]
                    .boundedSub(sequence.subtractDiff[i].boundedSub(newDiff));
            }
            sequence.subtractDiff[i] = newDiff;
        }
    }

    function getValueInSequence(Sequence storage sequence, uint month) internal view returns (uint) {

        if (sequence.firstUnprocessedMonth == 0) {
            return 0;
        }

        if (sequence.firstUnprocessedMonth <= month) {
            uint value = sequence.value[sequence.firstUnprocessedMonth - 1];
            for (uint i = sequence.firstUnprocessedMonth; i <= month; ++i) {
                value = value + sequence.addDiff[i] - sequence.subtractDiff[i];
            }
            return value;
        } else {
            return sequence.value[month];
        }
    }

    function getValuesInSequence(Sequence storage sequence) internal view returns (uint[] memory values) {

        if (sequence.firstUnprocessedMonth == 0) {
            return values;
        }
        uint begin = sequence.firstUnprocessedMonth - 1;
        uint end = sequence.lastChangedMonth + 1;
        if (end <= begin) {
            end = begin + 1;
        }
        values = new uint[](end - begin);
        values[0] = sequence.value[sequence.firstUnprocessedMonth - 1];
        for (uint i = 0; i + 1 < values.length; ++i) {
            uint month = sequence.firstUnprocessedMonth + i;
            values[i + 1] = values[i] + sequence.addDiff[month] - sequence.subtractDiff[month];
        }
    }

    function getValue(Value storage sequence, uint month) internal view returns (uint) {

        require(
            month + 1 >= sequence.firstUnprocessedMonth,
            "Cannot calculate value in the past");
        if (sequence.firstUnprocessedMonth == 0) {
            return 0;
        }

        if (sequence.firstUnprocessedMonth <= month) {
            uint value = sequence.value;
            for (uint i = sequence.firstUnprocessedMonth; i <= month; ++i) {
                value = value + sequence.addDiff[i] - sequence.subtractDiff[i];
            }
            return value;
        } else {
            return sequence.value;
        }
    }

    function getValues(Value storage sequence) internal view returns (uint[] memory values) {

        if (sequence.firstUnprocessedMonth == 0) {
            return values;
        }
        uint begin = sequence.firstUnprocessedMonth - 1;
        uint end = sequence.lastChangedMonth + 1;
        if (end <= begin) {
            end = begin + 1;
        }
        values = new uint[](end - begin);
        values[0] = sequence.value;
        for (uint i = 0; i + 1 < values.length; ++i) {
            uint month = sequence.firstUnprocessedMonth + i;
            values[i + 1] = values[i] + sequence.addDiff[month] - sequence.subtractDiff[month];
        }
    }
}// AGPL-3.0-only


pragma solidity 0.8.11;




contract DelegationController is Permissions, ILocker, IDelegationController {

    using MathUtils for uint;
    using PartialDifferences for PartialDifferences.Sequence;
    using PartialDifferences for PartialDifferences.Value;
    using FractionUtils for FractionUtils.Fraction;

    struct SlashingLogEvent {
        FractionUtils.Fraction reducingCoefficient;
        uint nextMonth;
    }

    struct SlashingLog {
        mapping (uint => SlashingLogEvent) slashes;
        uint firstMonth;
        uint lastMonth;
    }

    struct DelegationExtras {
        uint lastSlashingMonthBeforeDelegation;
    }

    struct SlashingEvent {
        FractionUtils.Fraction reducingCoefficient;
        uint validatorId;
        uint month;
    }

    struct SlashingSignal {
        address holder;
        uint penalty;
    }

    struct LockedInPending {
        uint amount;
        uint month;
    }

    struct FirstDelegationMonth {
        uint value;
        mapping (uint => uint) byValidator;
    }

    struct ValidatorsStatistics {
        uint number;
        mapping (uint => uint) delegated;
    }

    uint public constant UNDELEGATION_PROHIBITION_WINDOW_SECONDS = 3 * 24 * 60 * 60;

    Delegation[] public delegations;

    mapping (uint => uint[]) public delegationsByValidator;

    mapping (address => uint[]) public delegationsByHolder;

    mapping(uint => DelegationExtras) private _delegationExtras;

    mapping (uint => PartialDifferences.Value) private _delegatedToValidator;
    mapping (uint => PartialDifferences.Sequence) private _effectiveDelegatedToValidator;

    mapping (uint => SlashingLog) private _slashesOfValidator;

    mapping (address => PartialDifferences.Value) private _delegatedByHolder;
    mapping (address => mapping (uint => PartialDifferences.Value)) private _delegatedByHolderToValidator;
    mapping (address => mapping (uint => PartialDifferences.Sequence)) private _effectiveDelegatedByHolderToValidator;

    SlashingEvent[] private _slashes;
    mapping (address => uint) private _firstUnprocessedSlashByHolder;

    mapping (address => FirstDelegationMonth) private _firstDelegationMonth;

    mapping (address => LockedInPending) private _lockedInPendingDelegations;

    mapping (address => ValidatorsStatistics) private _numberOfValidatorsPerDelegator;

    modifier checkDelegationExists(uint delegationId) {

        require(delegationId < delegations.length, "Delegation does not exist");
        _;
    }

    function getAndUpdateDelegatedToValidatorNow(uint validatorId) external override returns (uint) {

        return _getAndUpdateDelegatedToValidator(validatorId, _getCurrentMonth());
    }

    function getAndUpdateDelegatedAmount(address holder) external override returns (uint) {

        return _getAndUpdateDelegatedByHolder(holder);
    }

    function getAndUpdateEffectiveDelegatedByHolderToValidator(address holder, uint validatorId, uint month)
        external
        override
        allow("Distributor")
        returns (uint effectiveDelegated)
    {

        SlashingSignal[] memory slashingSignals = _processAllSlashesWithoutSignals(holder);
        effectiveDelegated = _effectiveDelegatedByHolderToValidator[holder][validatorId]
            .getAndUpdateValueInSequence(month);
        _sendSlashingSignals(slashingSignals);
    }

    function delegate(
        uint validatorId,
        uint amount,
        uint delegationPeriod,
        string calldata info
    )
        external
        override
    {

        require(
            _getDelegationPeriodManager().isDelegationPeriodAllowed(delegationPeriod),
            "This delegation period is not allowed");
        _getValidatorService().checkValidatorCanReceiveDelegation(validatorId, amount);        
        _checkIfDelegationIsAllowed(msg.sender, validatorId);

        SlashingSignal[] memory slashingSignals = _processAllSlashesWithoutSignals(msg.sender);

        uint delegationId = _addDelegation(
            msg.sender,
            validatorId,
            amount,
            delegationPeriod,
            info);

        uint holderBalance = IERC777(contractManager.getSkaleToken()).balanceOf(msg.sender);
        uint forbiddenForDelegation = ILocker(contractManager.getTokenState())
            .getAndUpdateForbiddenForDelegationAmount(msg.sender);
        require(holderBalance >= forbiddenForDelegation, "Token holder does not have enough tokens to delegate");

        emit DelegationProposed(delegationId);

        _sendSlashingSignals(slashingSignals);
    }

    function getAndUpdateLockedAmount(address wallet) external override returns (uint) {

        return _getAndUpdateLockedAmount(wallet);
    }

    function getAndUpdateForbiddenForDelegationAmount(address wallet) external override returns (uint) {

        return _getAndUpdateLockedAmount(wallet);
    }

    function cancelPendingDelegation(uint delegationId) external override checkDelegationExists(delegationId) {

        require(msg.sender == delegations[delegationId].holder, "Only token holders can cancel delegation request");
        require(getState(delegationId) == State.PROPOSED, "Token holders are only able to cancel PROPOSED delegations");

        delegations[delegationId].finished = _getCurrentMonth();
        _subtractFromLockedInPendingDelegations(delegations[delegationId].holder, delegations[delegationId].amount);

        emit DelegationRequestCanceledByUser(delegationId);
    }

    function acceptPendingDelegation(uint delegationId) external override checkDelegationExists(delegationId) {

        require(
            _getValidatorService().checkValidatorAddressToId(msg.sender, delegations[delegationId].validatorId),
            "No permissions to accept request");
        _accept(delegationId);
    }

    function requestUndelegation(uint delegationId) external override checkDelegationExists(delegationId) {

        require(getState(delegationId) == State.DELEGATED, "Cannot request undelegation");
        IValidatorService validatorService = _getValidatorService();
        require(
            delegations[delegationId].holder == msg.sender ||
            (validatorService.validatorAddressExists(msg.sender) &&
            delegations[delegationId].validatorId == validatorService.getValidatorId(msg.sender)),
            "Permission denied to request undelegation");
        _removeValidatorFromValidatorsPerDelegators(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId);
        processAllSlashes(msg.sender);
        delegations[delegationId].finished = _calculateDelegationEndMonth(delegationId);

        require(
            block.timestamp + UNDELEGATION_PROHIBITION_WINDOW_SECONDS
                < _getTimeHelpers().monthToTimestamp(delegations[delegationId].finished),
            "Undelegation requests must be sent 3 days before the end of delegation period"
        );

        _subtractFromAllStatistics(delegationId);
        
        emit UndelegationRequested(delegationId);
    }

    function confiscate(uint validatorId, uint amount) external override allow("Punisher") {

        uint currentMonth = _getCurrentMonth();
        FractionUtils.Fraction memory coefficient =
            _delegatedToValidator[validatorId].reduceValue(amount, currentMonth);

        uint initialEffectiveDelegated =
            _effectiveDelegatedToValidator[validatorId].getAndUpdateValueInSequence(currentMonth);
        uint[] memory initialSubtractions = new uint[](0);
        if (currentMonth < _effectiveDelegatedToValidator[validatorId].lastChangedMonth) {
            initialSubtractions = new uint[](
                _effectiveDelegatedToValidator[validatorId].lastChangedMonth - currentMonth
            );
            for (uint i = 0; i < initialSubtractions.length; ++i) {
                initialSubtractions[i] = _effectiveDelegatedToValidator[validatorId]
                    .subtractDiff[currentMonth + i + 1];
            }
        }

        _effectiveDelegatedToValidator[validatorId].reduceSequence(coefficient, currentMonth);
        _putToSlashingLog(_slashesOfValidator[validatorId], coefficient, currentMonth);
        _slashes.push(SlashingEvent({reducingCoefficient: coefficient, validatorId: validatorId, month: currentMonth}));

        IBountyV2 bounty = _getBounty();
        bounty.handleDelegationRemoving(
            initialEffectiveDelegated - 
                _effectiveDelegatedToValidator[validatorId].getAndUpdateValueInSequence(currentMonth),
            currentMonth
        );
        for (uint i = 0; i < initialSubtractions.length; ++i) {
            bounty.handleDelegationAdd(
                initialSubtractions[i] - 
                    _effectiveDelegatedToValidator[validatorId].subtractDiff[currentMonth + i + 1],
                currentMonth + i + 1
            );
        }
        emit Confiscated(validatorId, amount);
    }

    function getAndUpdateEffectiveDelegatedToValidator(uint validatorId, uint month)
        external
        override
        allowTwo("Bounty", "Distributor")
        returns (uint)
    {

        return _effectiveDelegatedToValidator[validatorId].getAndUpdateValueInSequence(month);
    }

    function getAndUpdateDelegatedByHolderToValidatorNow(address holder, uint validatorId)
        external
        override
        returns (uint)
    {

        return _getAndUpdateDelegatedByHolderToValidator(holder, validatorId, _getCurrentMonth());
    }

    function getEffectiveDelegatedValuesByValidator(uint validatorId) external view override returns (uint[] memory) {

        return _effectiveDelegatedToValidator[validatorId].getValuesInSequence();
    }

    function getEffectiveDelegatedToValidator(uint validatorId, uint month) external view override returns (uint) {

        return _effectiveDelegatedToValidator[validatorId].getValueInSequence(month);
    }

    function getDelegatedToValidator(uint validatorId, uint month) external view override returns (uint) {

        return _delegatedToValidator[validatorId].getValue(month);
    }

    function getDelegation(uint delegationId)
        external
        view
        override
        checkDelegationExists(delegationId)
        returns (Delegation memory)
    {

        return delegations[delegationId];
    }

    function getFirstDelegationMonth(address holder, uint validatorId) external view override returns(uint) {

        return _firstDelegationMonth[holder].byValidator[validatorId];
    }

    function getDelegationsByValidatorLength(uint validatorId) external view override returns (uint) {

        return delegationsByValidator[validatorId].length;
    }

    function getDelegationsByHolderLength(address holder) external view override returns (uint) {

        return delegationsByHolder[holder].length;
    }

    function initialize(address contractsAddress) public override initializer {

        Permissions.initialize(contractsAddress);
    }

    function processSlashes(address holder, uint limit) public override {

        _sendSlashingSignals(_processSlashesWithoutSignals(holder, limit));
        emit SlashesProcessed(holder, limit);
    }

    function processAllSlashes(address holder) public override {

        processSlashes(holder, 0);
    }

    function getState(uint delegationId)
        public
        view
        override
        checkDelegationExists(delegationId)
        returns (State state)
    {

        if (delegations[delegationId].started == 0) {
            if (delegations[delegationId].finished == 0) {
                if (_getCurrentMonth() == _getTimeHelpers().timestampToMonth(delegations[delegationId].created)) {
                    return State.PROPOSED;
                } else {
                    return State.REJECTED;
                }
            } else {
                return State.CANCELED;
            }
        } else {
            if (_getCurrentMonth() < delegations[delegationId].started) {
                return State.ACCEPTED;
            } else {
                if (delegations[delegationId].finished == 0) {
                    return State.DELEGATED;
                } else {
                    if (_getCurrentMonth() < delegations[delegationId].finished) {
                        return State.UNDELEGATION_REQUESTED;
                    } else {
                        return State.COMPLETED;
                    }
                }
            }
        }
    }

    function getLockedInPendingDelegations(address holder) public view override returns (uint) {

        uint currentMonth = _getCurrentMonth();
        if (_lockedInPendingDelegations[holder].month < currentMonth) {
            return 0;
        } else {
            return _lockedInPendingDelegations[holder].amount;
        }
    }

    function hasUnprocessedSlashes(address holder) public view override returns (bool) {

        return _everDelegated(holder) && _firstUnprocessedSlashByHolder[holder] < _slashes.length;
    }    


    function _getAndUpdateDelegatedToValidator(uint validatorId, uint month)
        private returns (uint)
    {

        return _delegatedToValidator[validatorId].getAndUpdateValue(month);
    }

    function _addDelegation(
        address holder,
        uint validatorId,
        uint amount,
        uint delegationPeriod,
        string memory info
    )
        private
        returns (uint delegationId)
    {

        delegationId = delegations.length;
        delegations.push(Delegation(
            holder,
            validatorId,
            amount,
            delegationPeriod,
            block.timestamp,
            0,
            0,
            info
        ));
        delegationsByValidator[validatorId].push(delegationId);
        delegationsByHolder[holder].push(delegationId);
        _addToLockedInPendingDelegations(delegations[delegationId].holder, delegations[delegationId].amount);
    }

    function _addToDelegatedToValidator(uint validatorId, uint amount, uint month) private {

        _delegatedToValidator[validatorId].addToValue(amount, month);
    }

    function _addToEffectiveDelegatedToValidator(uint validatorId, uint effectiveAmount, uint month) private {

        _effectiveDelegatedToValidator[validatorId].addToSequence(effectiveAmount, month);
    }

    function _addToDelegatedByHolder(address holder, uint amount, uint month) private {

        _delegatedByHolder[holder].addToValue(amount, month);
    }

    function _addToDelegatedByHolderToValidator(
        address holder, uint validatorId, uint amount, uint month) private
    {

        _delegatedByHolderToValidator[holder][validatorId].addToValue(amount, month);
    }

    function _addValidatorToValidatorsPerDelegators(address holder, uint validatorId) private {

        if (_numberOfValidatorsPerDelegator[holder].delegated[validatorId] == 0) {
            _numberOfValidatorsPerDelegator[holder].number += 1;
        }
        _numberOfValidatorsPerDelegator[holder].delegated[validatorId] += 1;
    }

    function _removeFromDelegatedByHolder(address holder, uint amount, uint month) private {

        _delegatedByHolder[holder].subtractFromValue(amount, month);
    }

    function _removeFromDelegatedByHolderToValidator(
        address holder, uint validatorId, uint amount, uint month) private
    {

        _delegatedByHolderToValidator[holder][validatorId].subtractFromValue(amount, month);
    }

    function _removeValidatorFromValidatorsPerDelegators(address holder, uint validatorId) private {

        if (_numberOfValidatorsPerDelegator[holder].delegated[validatorId] == 1) {
            _numberOfValidatorsPerDelegator[holder].number -= 1;
        }
        _numberOfValidatorsPerDelegator[holder].delegated[validatorId] -= 1;
    }

    function _addToEffectiveDelegatedByHolderToValidator(
        address holder,
        uint validatorId,
        uint effectiveAmount,
        uint month)
        private
    {

        _effectiveDelegatedByHolderToValidator[holder][validatorId].addToSequence(effectiveAmount, month);
    }

    function _removeFromEffectiveDelegatedByHolderToValidator(
        address holder,
        uint validatorId,
        uint effectiveAmount,
        uint month)
        private
    {

        _effectiveDelegatedByHolderToValidator[holder][validatorId].subtractFromSequence(effectiveAmount, month);
    }

    function _getAndUpdateDelegatedByHolder(address holder) private returns (uint) {

        uint currentMonth = _getCurrentMonth();
        processAllSlashes(holder);
        return _delegatedByHolder[holder].getAndUpdateValue(currentMonth);
    }

    function _getAndUpdateDelegatedByHolderToValidator(
        address holder,
        uint validatorId,
        uint month)
        private returns (uint)
    {

        return _delegatedByHolderToValidator[holder][validatorId].getAndUpdateValue(month);
    }

    function _addToLockedInPendingDelegations(address holder, uint amount) private {

        uint currentMonth = _getCurrentMonth();
        if (_lockedInPendingDelegations[holder].month < currentMonth) {
            _lockedInPendingDelegations[holder].amount = amount;
            _lockedInPendingDelegations[holder].month = currentMonth;
        } else {
            assert(_lockedInPendingDelegations[holder].month == currentMonth);
            _lockedInPendingDelegations[holder].amount = _lockedInPendingDelegations[holder].amount + amount;
        }
    }

    function _subtractFromLockedInPendingDelegations(address holder, uint amount) private {

        uint currentMonth = _getCurrentMonth();
        assert(_lockedInPendingDelegations[holder].month == currentMonth);
        _lockedInPendingDelegations[holder].amount = _lockedInPendingDelegations[holder].amount - amount;
    }

    function _getAndUpdateLockedAmount(address wallet) private returns (uint) {

        return _getAndUpdateDelegatedByHolder(wallet) + getLockedInPendingDelegations(wallet);
    }

    function _updateFirstDelegationMonth(address holder, uint validatorId, uint month) private {

        if (_firstDelegationMonth[holder].value == 0) {
            _firstDelegationMonth[holder].value = month;
            _firstUnprocessedSlashByHolder[holder] = _slashes.length;
        }
        if (_firstDelegationMonth[holder].byValidator[validatorId] == 0) {
            _firstDelegationMonth[holder].byValidator[validatorId] = month;
        }
    }

    function _removeFromDelegatedToValidator(uint validatorId, uint amount, uint month) private {

        _delegatedToValidator[validatorId].subtractFromValue(amount, month);
    }

    function _removeFromEffectiveDelegatedToValidator(uint validatorId, uint effectiveAmount, uint month) private {

        _effectiveDelegatedToValidator[validatorId].subtractFromSequence(effectiveAmount, month);
    }

    function _putToSlashingLog(
        SlashingLog storage log,
        FractionUtils.Fraction memory coefficient,
        uint month)
        private
    {

        if (log.firstMonth == 0) {
            log.firstMonth = month;
            log.lastMonth = month;
            log.slashes[month].reducingCoefficient = coefficient;
            log.slashes[month].nextMonth = 0;
        } else {
            require(log.lastMonth <= month, "Cannot put slashing event in the past");
            if (log.lastMonth == month) {
                log.slashes[month].reducingCoefficient =
                    log.slashes[month].reducingCoefficient.multiplyFraction(coefficient);
            } else {
                log.slashes[month].reducingCoefficient = coefficient;
                log.slashes[month].nextMonth = 0;
                log.slashes[log.lastMonth].nextMonth = month;
                log.lastMonth = month;
            }
        }
    }

    function _processSlashesWithoutSignals(address holder, uint limit)
        private returns (SlashingSignal[] memory slashingSignals)
    {

        if (hasUnprocessedSlashes(holder)) {
            uint index = _firstUnprocessedSlashByHolder[holder];
            uint end = _slashes.length;
            if (limit > 0 && (index + limit) < end) {
                end = index + limit;
            }
            slashingSignals = new SlashingSignal[](end - index);
            uint begin = index;
            for (; index < end; ++index) {
                uint validatorId = _slashes[index].validatorId;
                uint month = _slashes[index].month;
                uint oldValue = _getAndUpdateDelegatedByHolderToValidator(holder, validatorId, month);
                if (oldValue.muchGreater(0)) {
                    _delegatedByHolderToValidator[holder][validatorId].reduceValueByCoefficientAndUpdateSum(
                        _delegatedByHolder[holder],
                        _slashes[index].reducingCoefficient,
                        month);
                    _effectiveDelegatedByHolderToValidator[holder][validatorId].reduceSequence(
                        _slashes[index].reducingCoefficient,
                        month);
                    slashingSignals[index - begin].holder = holder;
                    slashingSignals[index - begin].penalty
                        = oldValue.boundedSub(_getAndUpdateDelegatedByHolderToValidator(holder, validatorId, month));
                }
            }
            _firstUnprocessedSlashByHolder[holder] = end;
        }
    }

    function _processAllSlashesWithoutSignals(address holder)
        private returns (SlashingSignal[] memory slashingSignals)
    {

        return _processSlashesWithoutSignals(holder, 0);
    }

    function _sendSlashingSignals(SlashingSignal[] memory slashingSignals) private {

        IPunisher punisher = IPunisher(contractManager.getPunisher());
        address previousHolder = address(0);
        uint accumulatedPenalty = 0;
        for (uint i = 0; i < slashingSignals.length; ++i) {
            if (slashingSignals[i].holder != previousHolder) {
                if (accumulatedPenalty > 0) {
                    punisher.handleSlash(previousHolder, accumulatedPenalty);
                }
                previousHolder = slashingSignals[i].holder;
                accumulatedPenalty = slashingSignals[i].penalty;
            } else {
                accumulatedPenalty = accumulatedPenalty + slashingSignals[i].penalty;
            }
        }
        if (accumulatedPenalty > 0) {
            punisher.handleSlash(previousHolder, accumulatedPenalty);
        }
    }

    function _addToAllStatistics(uint delegationId) private {

        uint currentMonth = _getCurrentMonth();
        delegations[delegationId].started = currentMonth + 1;
        if (_slashesOfValidator[delegations[delegationId].validatorId].lastMonth > 0) {
            _delegationExtras[delegationId].lastSlashingMonthBeforeDelegation =
                _slashesOfValidator[delegations[delegationId].validatorId].lastMonth;
        }

        _addToDelegatedToValidator(
            delegations[delegationId].validatorId,
            delegations[delegationId].amount,
            currentMonth + 1);
        _addToDelegatedByHolder(
            delegations[delegationId].holder,
            delegations[delegationId].amount,
            currentMonth + 1);
        _addToDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            delegations[delegationId].amount,
            currentMonth + 1);
        _updateFirstDelegationMonth(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            currentMonth + 1);
        uint effectiveAmount = delegations[delegationId].amount * 
            _getDelegationPeriodManager().stakeMultipliers(delegations[delegationId].delegationPeriod);
        _addToEffectiveDelegatedToValidator(
            delegations[delegationId].validatorId,
            effectiveAmount,
            currentMonth + 1);
        _addToEffectiveDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            effectiveAmount,
            currentMonth + 1);
        _addValidatorToValidatorsPerDelegators(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId
        );
    }

    function _subtractFromAllStatistics(uint delegationId) private {

        uint amountAfterSlashing = _calculateDelegationAmountAfterSlashing(delegationId);
        _removeFromDelegatedToValidator(
            delegations[delegationId].validatorId,
            amountAfterSlashing,
            delegations[delegationId].finished);
        _removeFromDelegatedByHolder(
            delegations[delegationId].holder,
            amountAfterSlashing,
            delegations[delegationId].finished);
        _removeFromDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            amountAfterSlashing,
            delegations[delegationId].finished);
        uint effectiveAmount = amountAfterSlashing *
                _getDelegationPeriodManager().stakeMultipliers(delegations[delegationId].delegationPeriod);
        _removeFromEffectiveDelegatedToValidator(
            delegations[delegationId].validatorId,
            effectiveAmount,
            delegations[delegationId].finished);
        _removeFromEffectiveDelegatedByHolderToValidator(
            delegations[delegationId].holder,
            delegations[delegationId].validatorId,
            effectiveAmount,
            delegations[delegationId].finished);
        _getBounty().handleDelegationRemoving(
            effectiveAmount,
            delegations[delegationId].finished);
    }

    function _accept(uint delegationId) private {

        _checkIfDelegationIsAllowed(delegations[delegationId].holder, delegations[delegationId].validatorId);
        
        State currentState = getState(delegationId);
        if (currentState != State.PROPOSED) {
            if (currentState == State.ACCEPTED ||
                currentState == State.DELEGATED ||
                currentState == State.UNDELEGATION_REQUESTED ||
                currentState == State.COMPLETED)
            {
                revert("The delegation has been already accepted");
            } else if (currentState == State.CANCELED) {
                revert("The delegation has been cancelled by token holder");
            } else if (currentState == State.REJECTED) {
                revert("The delegation request is outdated");
            }
        }
        require(currentState == State.PROPOSED, "Cannot set delegation state to accepted");

        SlashingSignal[] memory slashingSignals = _processAllSlashesWithoutSignals(delegations[delegationId].holder);

        _addToAllStatistics(delegationId);
        
        uint amount = delegations[delegationId].amount;

        uint effectiveAmount = amount * 
            _getDelegationPeriodManager().stakeMultipliers(delegations[delegationId].delegationPeriod);
        _getBounty().handleDelegationAdd(
            effectiveAmount,
            delegations[delegationId].started
        );

        _sendSlashingSignals(slashingSignals);
        emit DelegationAccepted(delegationId);
    }

    function _getCurrentMonth() private view returns (uint) {

        return _getTimeHelpers().getCurrentMonth();
    }

    function _everDelegated(address holder) private view returns (bool) {

        return _firstDelegationMonth[holder].value > 0;
    }

    function _calculateDelegationEndMonth(uint delegationId) private view returns (uint) {

        uint currentMonth = _getCurrentMonth();
        uint started = delegations[delegationId].started;

        if (currentMonth < started) {
            return started + delegations[delegationId].delegationPeriod;
        } else {
            uint completedPeriods = (currentMonth - started) / delegations[delegationId].delegationPeriod;
            return started + (completedPeriods + 1) * delegations[delegationId].delegationPeriod;
        }
    }

    function _calculateDelegationAmountAfterSlashing(uint delegationId) private view returns (uint) {

        uint startMonth = _delegationExtras[delegationId].lastSlashingMonthBeforeDelegation;
        uint validatorId = delegations[delegationId].validatorId;
        uint amount = delegations[delegationId].amount;
        if (startMonth == 0) {
            startMonth = _slashesOfValidator[validatorId].firstMonth;
            if (startMonth == 0) {
                return amount;
            }
        }
        for (uint i = startMonth;
            i > 0 && i < delegations[delegationId].finished;
            i = _slashesOfValidator[validatorId].slashes[i].nextMonth) {
            if (i >= delegations[delegationId].started) {
                amount = amount
                    * _slashesOfValidator[validatorId].slashes[i].reducingCoefficient.numerator
                    / _slashesOfValidator[validatorId].slashes[i].reducingCoefficient.denominator;
            }
        }
        return amount;
    }

    function _checkIfDelegationIsAllowed(address holder, uint validatorId) private view {

        require(
            _numberOfValidatorsPerDelegator[holder].delegated[validatorId] > 0 ||
                _numberOfValidatorsPerDelegator[holder].number < _getConstantsHolder().limitValidatorsPerDelegator(),
            "Limit of validators is reached"
        );
    }

    function _getDelegationPeriodManager() private view returns (IDelegationPeriodManager) {

        return IDelegationPeriodManager(contractManager.getDelegationPeriodManager());
    }

    function _getBounty() private view returns (IBountyV2) {

        return IBountyV2(contractManager.getBounty());
    }

    function _getValidatorService() private view returns (IValidatorService) {

        return IValidatorService(contractManager.getValidatorService());
    }

    function _getTimeHelpers() private view returns (ITimeHelpers) {

        return ITimeHelpers(contractManager.getTimeHelpers());
    }

    function _getConstantsHolder() private view returns (IConstantsHolder) {

        return IConstantsHolder(contractManager.getConstantsHolder());
    }
}