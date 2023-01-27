
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
}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface ISkaleDKG {


    struct Fp2Point {
        uint a;
        uint b;
    }

    struct G2Point {
        Fp2Point x;
        Fp2Point y;
    }

    struct Channel {
        bool active;
        uint n;
        uint startedBlockTimestamp;
        uint startedBlock;
    }

    struct ProcessDKG {
        uint numberOfBroadcasted;
        uint numberOfCompleted;
        bool[] broadcasted;
        bool[] completed;
    }

    struct ComplaintData {
        uint nodeToComplaint;
        uint fromNodeToComplaint;
        uint startComplaintBlockTimestamp;
        bool isResponse;
        bytes32 keyShare;
        G2Point sumOfVerVec;
    }

    struct KeyShare {
        bytes32[2] publicKey;
        bytes32 share;
    }
    
    event ChannelOpened(bytes32 schainHash);

    event ChannelClosed(bytes32 schainHash);

    event BroadcastAndKeyShare(
        bytes32 indexed schainHash,
        uint indexed fromNode,
        G2Point[] verificationVector,
        KeyShare[] secretKeyContribution
    );

    event AllDataReceived(bytes32 indexed schainHash, uint nodeIndex);

    event SuccessfulDKG(bytes32 indexed schainHash);

    event BadGuy(uint nodeIndex);

    event FailedDKG(bytes32 indexed schainHash);

    event NewGuy(uint nodeIndex);

    event ComplaintError(string error);

    event ComplaintSent(bytes32 indexed schainHash, uint indexed fromNodeIndex, uint indexed toNodeIndex);
    
    function alright(bytes32 schainHash, uint fromNodeIndex) external;

    function broadcast(
        bytes32 schainHash,
        uint nodeIndex,
        G2Point[] memory verificationVector,
        KeyShare[] memory secretKeyContribution
    )
        external;

    function complaintBadData(bytes32 schainHash, uint fromNodeIndex, uint toNodeIndex) external;

    function preResponse(
        bytes32 schainId,
        uint fromNodeIndex,
        G2Point[] memory verificationVector,
        G2Point[] memory verificationVectorMultiplication,
        KeyShare[] memory secretKeyContribution
    )
        external;

    function complaint(bytes32 schainHash, uint fromNodeIndex, uint toNodeIndex) external;

    function response(
        bytes32 schainHash,
        uint fromNodeIndex,
        uint secretNumber,
        G2Point memory multipliedShare
    )
        external;

    function openChannel(bytes32 schainHash) external;

    function deleteChannel(bytes32 schainHash) external;

    function setStartAlrightTimestamp(bytes32 schainHash) external;

    function setBadNode(bytes32 schainHash, uint nodeIndex) external;

    function finalizeSlashing(bytes32 schainHash, uint badNode) external;

    function getChannelStartedTime(bytes32 schainHash) external view returns (uint);

    function getChannelStartedBlock(bytes32 schainHash) external view returns (uint);

    function getNumberOfBroadcasted(bytes32 schainHash) external view returns (uint);

    function getNumberOfCompleted(bytes32 schainHash) external view returns (uint);

    function getTimeOfLastSuccessfulDKG(bytes32 schainHash) external view returns (uint);

    function getComplaintData(bytes32 schainHash) external view returns (uint, uint);

    function getComplaintStartedTime(bytes32 schainHash) external view returns (uint);

    function getAlrightStartedTime(bytes32 schainHash) external view returns (uint);

    function isChannelOpened(bytes32 schainHash) external view returns (bool);

    function isLastDKGSuccessful(bytes32 groupIndex) external view returns (bool);

    function isBroadcastPossible(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function isComplaintPossible(
        bytes32 schainHash,
        uint fromNodeIndex,
        uint toNodeIndex
    )
        external
        view
        returns (bool);

    function isAlrightPossible(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function isPreResponsePossible(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function isResponsePossible(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function isNodeBroadcasted(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function isAllDataReceived(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function checkAndReturnIndexInGroup(
        bytes32 schainHash,
        uint nodeIndex,
        bool revertCheck
    )
        external
        view
        returns (uint, bool);

    function isEveryoneBroadcasted(bytes32 schainHash) external view returns (bool);

    function hashData(
        KeyShare[] memory secretKeyContribution,
        G2Point[] memory verificationVector
    )
        external
        pure
        returns (bytes32);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface INodeRotation {

    struct Rotation {
        uint nodeIndex;
        uint newNodeIndex;
        uint freezeUntil;
        uint rotationCounter;
    }

    struct LeavingHistory {
        bytes32 schainHash;
        uint finishedRotation;
    }

    function exitFromSchain(uint nodeIndex) external returns (bool, bool);

    function freezeSchains(uint nodeIndex) external;

    function removeRotation(bytes32 schainHash) external;

    function skipRotationDelay(bytes32 schainHash) external;

    function rotateNode(
        uint nodeIndex,
        bytes32 schainHash,
        bool shouldDelay,
        bool isBadNode
    )
        external
        returns (uint newNode);

    function selectNodeToGroup(bytes32 schainHash) external returns (uint nodeIndex);

    function getRotation(bytes32 schainHash) external view returns (Rotation memory);

    function getLeavingHistory(uint nodeIndex) external view returns (LeavingHistory[] memory);

    function isRotationInProgress(bytes32 schainHash) external view returns (bool);

    function isNewNodeFound(bytes32 schainHash) external view returns (bool);

    function getPreviousNode(bytes32 schainHash, uint256 nodeIndex) external view returns (uint256);

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

interface ISchainsInternal {

    struct Schain {
        string name;
        address owner;
        uint indexInOwnerList;
        uint8 partOfNode;
        uint lifetime;
        uint startDate;
        uint startBlock;
        uint deposit;
        uint64 index;
        uint generation;
        address originator;
    }

    struct SchainType {
        uint8 partOfNode;
        uint numberOfNodes;
    }

    event SchainTypeAdded(uint indexed schainType, uint partOfNode, uint numberOfNodes);

    event SchainTypeRemoved(uint indexed schainType);

    function initializeSchain(
        string calldata name,
        address from,
        address originator,
        uint lifetime,
        uint deposit) external;

    function createGroupForSchain(
        bytes32 schainHash,
        uint numberOfNodes,
        uint8 partOfNode
    )
        external
        returns (uint[] memory);

    function changeLifetime(bytes32 schainHash, uint lifetime, uint deposit) external;

    function removeSchain(bytes32 schainHash, address from) external;

    function removeNodeFromSchain(uint nodeIndex, bytes32 schainHash) external;

    function deleteGroup(bytes32 schainHash) external;

    function setException(bytes32 schainHash, uint nodeIndex) external;

    function setNodeInGroup(bytes32 schainHash, uint nodeIndex) external;

    function removeHolesForSchain(bytes32 schainHash) external;

    function addSchainType(uint8 partOfNode, uint numberOfNodes) external;

    function removeSchainType(uint typeOfSchain) external;

    function setNumberOfSchainTypes(uint newNumberOfSchainTypes) external;

    function removeNodeFromAllExceptionSchains(uint nodeIndex) external;

    function removeAllNodesFromSchainExceptions(bytes32 schainHash) external;

    function makeSchainNodesInvisible(bytes32 schainHash) external;

    function makeSchainNodesVisible(bytes32 schainHash) external;

    function newGeneration() external;

    function addSchainForNode(uint nodeIndex, bytes32 schainHash) external;

    function removeSchainForNode(uint nodeIndex, uint schainIndex) external;

    function removeNodeFromExceptions(bytes32 schainHash, uint nodeIndex) external;

    function isSchainActive(bytes32 schainHash) external view returns (bool);

    function schainsAtSystem(uint index) external view returns (bytes32);

    function numberOfSchains() external view returns (uint64);

    function getSchains() external view returns (bytes32[] memory);

    function getSchainsPartOfNode(bytes32 schainHash) external view returns (uint8);

    function getSchainListSize(address from) external view returns (uint);

    function getSchainHashesByAddress(address from) external view returns (bytes32[] memory);

    function getSchainIdsByAddress(address from) external view returns (bytes32[] memory);

    function getSchainHashesForNode(uint nodeIndex) external view returns (bytes32[] memory);

    function getSchainIdsForNode(uint nodeIndex) external view returns (bytes32[] memory);

    function getSchainOwner(bytes32 schainHash) external view returns (address);

    function getSchainOriginator(bytes32 schainHash) external view returns (address);

    function isSchainNameAvailable(string calldata name) external view returns (bool);

    function isTimeExpired(bytes32 schainHash) external view returns (bool);

    function isOwnerAddress(address from, bytes32 schainId) external view returns (bool);

    function getSchainName(bytes32 schainHash) external view returns (string memory);

    function getActiveSchain(uint nodeIndex) external view returns (bytes32);

    function getActiveSchains(uint nodeIndex) external view returns (bytes32[] memory activeSchains);

    function getNumberOfNodesInGroup(bytes32 schainHash) external view returns (uint);

    function getNodesInGroup(bytes32 schainHash) external view returns (uint[] memory);

    function isNodeAddressesInGroup(bytes32 schainId, address sender) external view returns (bool);

    function getNodeIndexInGroup(bytes32 schainHash, uint nodeId) external view returns (uint);

    function isAnyFreeNode(bytes32 schainHash) external view returns (bool);

    function checkException(bytes32 schainHash, uint nodeIndex) external view returns (bool);

    function checkHoleForSchain(bytes32 schainHash, uint indexOfNode) external view returns (bool);

    function checkSchainOnNode(uint nodeIndex, bytes32 schainHash) external view returns (bool);

    function getSchainType(uint typeOfSchain) external view returns(uint8, uint);

    function getGeneration(bytes32 schainHash) external view returns (uint);

    function isSchainExist(bytes32 schainHash) external view returns (bool);

}// AGPL-3.0-only


pragma solidity 0.8.11;


library Random {


    function create(uint seed) internal pure returns (IRandom.RandomGenerator memory) {

        return IRandom.RandomGenerator({seed: seed});
    }

    function createFromEntropy(bytes memory entropy) internal pure returns (IRandom.RandomGenerator memory) {

        return create(uint(keccak256(entropy)));
    }

    function random(IRandom.RandomGenerator memory self) internal pure returns (uint) {

        self.seed = uint(sha256(abi.encodePacked(self.seed)));
        return self.seed;
    }

    function random(IRandom.RandomGenerator memory self, uint max) internal pure returns (uint) {

        assert(max > 0);
        uint maxRand = type(uint).max - type(uint).max % max;
        if (type(uint).max - maxRand == max - 1) {
            return random(self) % max;
        } else {
            uint rand = random(self);
            while (rand >= maxRand) {
                rand = random(self);
            }
            return rand % max;
        }
    }
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




contract NodeRotation is Permissions, INodeRotation {

    using Random for IRandom.RandomGenerator;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    struct RotationWithPreviousNodes {
        uint nodeIndex;
        uint newNodeIndex;
        uint freezeUntil;
        uint rotationCounter;
        mapping (uint256 => uint256) previousNodes;
        EnumerableSetUpgradeable.UintSet newNodeIndexes;
        mapping (uint256 => uint256) indexInLeavingHistory;
    }

    mapping (bytes32 => RotationWithPreviousNodes) private _rotations;

    mapping (uint => INodeRotation.LeavingHistory[]) public leavingHistory;

    mapping (bytes32 => bool) public waitForNewNode;

    bytes32 public constant DEBUGGER_ROLE = keccak256("DEBUGGER_ROLE");

    event RotationDelaySkipped(bytes32 indexed schainHash);

    modifier onlyDebugger() {

        require(hasRole(DEBUGGER_ROLE, msg.sender), "DEBUGGER_ROLE is required");
        _;
    }

    function exitFromSchain(uint nodeIndex) external override allow("SkaleManager") returns (bool, bool) {

        ISchainsInternal schainsInternal = ISchainsInternal(contractManager.getContract("SchainsInternal"));
        bytes32 schainHash = schainsInternal.getActiveSchain(nodeIndex);
        if (schainHash == bytes32(0)) {
            return (true, false);
        }
        _checkBeforeRotation(schainHash, nodeIndex);
        _startRotation(schainHash, nodeIndex);
        rotateNode(nodeIndex, schainHash, true, false);
        return (schainsInternal.getActiveSchain(nodeIndex) == bytes32(0) ? true : false, true);
    }

    function freezeSchains(uint nodeIndex) external override allow("Nodes") {

        bytes32[] memory schains = ISchainsInternal(
            contractManager.getContract("SchainsInternal")
        ).getSchainHashesForNode(nodeIndex);
        for (uint i = 0; i < schains.length; i++) {
            if (schains[i] != bytes32(0)) {
                _checkBeforeRotation(schains[i], nodeIndex);
            }
        }
    }

    function removeRotation(bytes32 schainHash) external override allow("Schains") {

        delete _rotations[schainHash].nodeIndex;
        delete _rotations[schainHash].newNodeIndex;
        delete _rotations[schainHash].freezeUntil;
        delete _rotations[schainHash].rotationCounter;
    }

    function skipRotationDelay(bytes32 schainHash) external override onlyDebugger {

        _rotations[schainHash].freezeUntil = block.timestamp;
        emit RotationDelaySkipped(schainHash);
    }

    function getRotation(bytes32 schainHash) external view override returns (INodeRotation.Rotation memory) {

        return Rotation({
            nodeIndex: _rotations[schainHash].nodeIndex,
            newNodeIndex: _rotations[schainHash].newNodeIndex,
            freezeUntil: _rotations[schainHash].freezeUntil,
            rotationCounter: _rotations[schainHash].rotationCounter
        });
    }

    function getLeavingHistory(uint nodeIndex) external view override returns (INodeRotation.LeavingHistory[] memory) {

        return leavingHistory[nodeIndex];
    }

    function isRotationInProgress(bytes32 schainHash) external view override returns (bool) {

        bool foundNewNode = isNewNodeFound(schainHash);
        return foundNewNode ?
            leavingHistory[_rotations[schainHash].nodeIndex][
                _rotations[schainHash].indexInLeavingHistory[_rotations[schainHash].nodeIndex]
            ].finishedRotation >= block.timestamp :
            _rotations[schainHash].freezeUntil >= block.timestamp;
    }

    function getPreviousNode(bytes32 schainHash, uint256 nodeIndex) external view override returns (uint256) {

        require(_rotations[schainHash].newNodeIndexes.contains(nodeIndex), "No previous node");
        return _rotations[schainHash].previousNodes[nodeIndex];
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);
    }

    function rotateNode(
        uint nodeIndex,
        bytes32 schainHash,
        bool shouldDelay,
        bool isBadNode
    )
        public
        override
        allowTwo("SkaleDKG", "SkaleManager")
        returns (uint newNode)
    {

        ISchainsInternal schainsInternal = ISchainsInternal(contractManager.getContract("SchainsInternal"));
        schainsInternal.removeNodeFromSchain(nodeIndex, schainHash);
        if (!isBadNode) {
            schainsInternal.removeNodeFromExceptions(schainHash, nodeIndex);
        }
        newNode = selectNodeToGroup(schainHash);
        _finishRotation(schainHash, nodeIndex, newNode, shouldDelay);
    }

    function selectNodeToGroup(bytes32 schainHash)
        public
        override
        allowThree("SkaleManager", "Schains", "SkaleDKG")
        returns (uint nodeIndex)
    {

        ISchainsInternal schainsInternal = ISchainsInternal(contractManager.getContract("SchainsInternal"));
        INodes nodes = INodes(contractManager.getContract("Nodes"));
        require(schainsInternal.isSchainActive(schainHash), "Group is not active");
        uint8 space = schainsInternal.getSchainsPartOfNode(schainHash);
        schainsInternal.makeSchainNodesInvisible(schainHash);
        require(schainsInternal.isAnyFreeNode(schainHash), "No free Nodes available for rotation");
        IRandom.RandomGenerator memory randomGenerator = Random.createFromEntropy(
            abi.encodePacked(uint(blockhash(block.number - 1)), schainHash)
        );
        nodeIndex = nodes.getRandomNodeWithFreeSpace(space, randomGenerator);
        require(nodes.removeSpaceFromNode(nodeIndex, space), "Could not remove space from nodeIndex");
        schainsInternal.makeSchainNodesVisible(schainHash);
        schainsInternal.addSchainForNode(nodeIndex, schainHash);
        schainsInternal.setException(schainHash, nodeIndex);
        schainsInternal.setNodeInGroup(schainHash, nodeIndex);
    }

    function isNewNodeFound(bytes32 schainHash) public view override returns (bool) {

        return _rotations[schainHash].newNodeIndexes.contains(_rotations[schainHash].newNodeIndex) && 
            _rotations[schainHash].previousNodes[_rotations[schainHash].newNodeIndex] ==
            _rotations[schainHash].nodeIndex;
    }


    function _startRotation(bytes32 schainHash, uint nodeIndex) private {

        _rotations[schainHash].newNodeIndex = nodeIndex;
        waitForNewNode[schainHash] = true;
    }

    function _startWaiting(bytes32 schainHash, uint nodeIndex) private {

        IConstantsHolder constants = IConstantsHolder(contractManager.getContract("ConstantsHolder"));
        _rotations[schainHash].nodeIndex = nodeIndex;
        _rotations[schainHash].freezeUntil = block.timestamp + constants.rotationDelay();
    }

    function _finishRotation(
        bytes32 schainHash,
        uint nodeIndex,
        uint newNodeIndex,
        bool shouldDelay)
        private
    {

        leavingHistory[nodeIndex].push(
            LeavingHistory(
                schainHash,
                shouldDelay ? block.timestamp + 
                    IConstantsHolder(contractManager.getContract("ConstantsHolder")).rotationDelay()
                : block.timestamp
            )
        );
        require(_rotations[schainHash].newNodeIndexes.add(newNodeIndex), "New node was already added");
        _rotations[schainHash].newNodeIndex = newNodeIndex;
        _rotations[schainHash].rotationCounter++;
        _rotations[schainHash].previousNodes[newNodeIndex] = nodeIndex;
        _rotations[schainHash].indexInLeavingHistory[nodeIndex] = leavingHistory[nodeIndex].length - 1;
        delete waitForNewNode[schainHash];
        ISkaleDKG(contractManager.getContract("SkaleDKG")).openChannel(schainHash);
    }

    function _checkBeforeRotation(bytes32 schainHash, uint nodeIndex) private {

        require(
            ISkaleDKG(contractManager.getContract("SkaleDKG")).isLastDKGSuccessful(schainHash),
            "DKG did not finish on Schain"
        );
        if (_rotations[schainHash].freezeUntil < block.timestamp) {
            _startWaiting(schainHash, nodeIndex);
        } else {
            require(_rotations[schainHash].nodeIndex == nodeIndex, "Occupied by rotation on Schain");
        }
    }
}