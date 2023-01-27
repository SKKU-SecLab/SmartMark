
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


pragma solidity 0.8.11;





contract SchainsInternal is Permissions, ISchainsInternal {


    using Random for IRandom.RandomGenerator;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    mapping (bytes32 => Schain) public schains;

    mapping (bytes32 => bool) public override isSchainActive;

    mapping (bytes32 => uint[]) public schainsGroups;

    mapping (bytes32 => mapping (uint => bool)) private _exceptionsForGroups;
    mapping (address => bytes32[]) public schainIndexes;
    mapping (uint => bytes32[]) public schainsForNodes;

    mapping (uint => uint[]) public holesForNodes;

    mapping (bytes32 => uint[]) public holesForSchains;

    bytes32[] public override schainsAtSystem;

    uint64 public override numberOfSchains;
    uint public sumOfSchainsResources;

    mapping (bytes32 => bool) public usedSchainNames;

    mapping (uint => SchainType) public schainTypes;
    uint public numberOfSchainTypes;

    mapping (bytes32 => mapping (uint => uint)) public placeOfSchainOnNode;

    mapping (uint => bytes32[]) private _nodeToLockedSchains;

    mapping (bytes32 => uint[]) private _schainToExceptionNodes;

    EnumerableSetUpgradeable.UintSet private _keysOfSchainTypes;

    uint public currentGeneration;

    bytes32 public constant SCHAIN_TYPE_MANAGER_ROLE = keccak256("SCHAIN_TYPE_MANAGER_ROLE");
    bytes32 public constant DEBUGGER_ROLE = keccak256("DEBUGGER_ROLE");
    bytes32 public constant GENERATION_MANAGER_ROLE = keccak256("GENERATION_MANAGER_ROLE");

    modifier onlySchainTypeManager() {

        require(hasRole(SCHAIN_TYPE_MANAGER_ROLE, msg.sender), "SCHAIN_TYPE_MANAGER_ROLE is required");
        _;
    }

    modifier onlyDebugger() {

        require(hasRole(DEBUGGER_ROLE, msg.sender), "DEBUGGER_ROLE is required");
        _;
    }

    modifier onlyGenerationManager() {

        require(hasRole(GENERATION_MANAGER_ROLE, msg.sender), "GENERATION_MANAGER_ROLE is required");
        _;
    }

    modifier schainExists(bytes32 schainHash) {

        require(isSchainExist(schainHash), "The schain does not exist");
        _;
    }

    function initializeSchain(
        string calldata name,
        address from,
        address originator,
        uint lifetime,
        uint deposit
    )
        external
        override
        allow("Schains")
    {

        bytes32 schainHash = keccak256(abi.encodePacked(name));

        schains[schainHash] = Schain({
            name: name,
            owner: from,
            indexInOwnerList: schainIndexes[from].length,
            partOfNode: 0,
            startDate: block.timestamp,            
            startBlock: block.number,
            lifetime: lifetime,
            deposit: deposit,
            index: numberOfSchains,
            generation: currentGeneration,
            originator: originator
        });
        isSchainActive[schainHash] = true;
        numberOfSchains++;
        schainIndexes[from].push(schainHash);
        schainsAtSystem.push(schainHash);
        usedSchainNames[schainHash] = true;
    }

    function createGroupForSchain(
        bytes32 schainHash,
        uint numberOfNodes,
        uint8 partOfNode
    )
        external
        override
        allow("Schains")
        schainExists(schainHash)
        returns (uint[] memory)
    {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        schains[schainHash].partOfNode = partOfNode;
        if (partOfNode > 0) {
            sumOfSchainsResources = sumOfSchainsResources +
                numberOfNodes * constantsHolder.TOTAL_SPACE_ON_NODE() / partOfNode;
        }
        return _generateGroup(schainHash, numberOfNodes);
    }

    function changeLifetime(
        bytes32 schainHash,
        uint lifetime,
        uint deposit
    )
        external
        override
        allow("Schains")
        schainExists(schainHash)
    {

        schains[schainHash].deposit = schains[schainHash].deposit + deposit;
        schains[schainHash].lifetime = schains[schainHash].lifetime + lifetime;
    }

    function removeSchain(bytes32 schainHash, address from)
        external
        override
        allow("Schains")
        schainExists(schainHash)
    {

        isSchainActive[schainHash] = false;
        uint length = schainIndexes[from].length;
        uint index = schains[schainHash].indexInOwnerList;
        if (index != length - 1) {
            bytes32 lastSchainHash = schainIndexes[from][length - 1];
            schains[lastSchainHash].indexInOwnerList = index;
            schainIndexes[from][index] = lastSchainHash;
        }
        schainIndexes[from].pop();

        for (uint i = 0; i + 1 < schainsAtSystem.length; i++) {
            if (schainsAtSystem[i] == schainHash) {
                schainsAtSystem[i] = schainsAtSystem[schainsAtSystem.length - 1];
                break;
            }
        }
        schainsAtSystem.pop();

        delete schains[schainHash];
        numberOfSchains--;
    }

    function removeNodeFromSchain(
        uint nodeIndex,
        bytes32 schainHash
    )
        external
        override
        allowThree("NodeRotation", "SkaleDKG", "Schains")
        schainExists(schainHash)
    {

        uint indexOfNode = _findNode(schainHash, nodeIndex);
        uint indexOfLastNode = schainsGroups[schainHash].length - 1;

        if (indexOfNode == indexOfLastNode) {
            schainsGroups[schainHash].pop();
        } else {
            delete schainsGroups[schainHash][indexOfNode];
            if (holesForSchains[schainHash].length > 0 && holesForSchains[schainHash][0] > indexOfNode) {
                uint hole = holesForSchains[schainHash][0];
                holesForSchains[schainHash][0] = indexOfNode;
                holesForSchains[schainHash].push(hole);
            } else {
                holesForSchains[schainHash].push(indexOfNode);
            }
        }

        removeSchainForNode(nodeIndex, placeOfSchainOnNode[schainHash][nodeIndex] - 1);
        delete placeOfSchainOnNode[schainHash][nodeIndex];
        INodes nodes = INodes(contractManager.getContract("Nodes"));
        nodes.addSpaceToNode(nodeIndex, schains[schainHash].partOfNode);
    }

    function deleteGroup(bytes32 schainHash) external override allow("Schains") schainExists(schainHash) {

        ISkaleDKG skaleDKG = ISkaleDKG(contractManager.getContract("SkaleDKG"));
        delete schainsGroups[schainHash];
        skaleDKG.deleteChannel(schainHash);
    }

    function setException(
        bytes32 schainHash,
        uint nodeIndex
    )
        external
        override
        allowTwo("Schains", "NodeRotation")
        schainExists(schainHash)
    {

        _setException(schainHash, nodeIndex);
    }

    function setNodeInGroup(
        bytes32 schainHash,
        uint nodeIndex
    )
        external
        override
        allowTwo("Schains", "NodeRotation")
        schainExists(schainHash)
    {

        if (holesForSchains[schainHash].length == 0) {
            schainsGroups[schainHash].push(nodeIndex);
        } else {
            schainsGroups[schainHash][holesForSchains[schainHash][0]] = nodeIndex;
            uint min = type(uint).max;
            uint index = 0;
            for (uint i = 1; i < holesForSchains[schainHash].length; i++) {
                if (min > holesForSchains[schainHash][i]) {
                    min = holesForSchains[schainHash][i];
                    index = i;
                }
            }
            if (min == type(uint).max) {
                delete holesForSchains[schainHash];
            } else {
                holesForSchains[schainHash][0] = min;
                holesForSchains[schainHash][index] =
                    holesForSchains[schainHash][holesForSchains[schainHash].length - 1];
                holesForSchains[schainHash].pop();
            }
        }
    }

    function removeHolesForSchain(bytes32 schainHash) external override allow("Schains") schainExists(schainHash) {

        delete holesForSchains[schainHash];
    }

    function addSchainType(uint8 partOfNode, uint numberOfNodes) external override onlySchainTypeManager {

        require(_keysOfSchainTypes.add(numberOfSchainTypes + 1), "Schain type is already added");
        schainTypes[numberOfSchainTypes + 1].partOfNode = partOfNode;
        schainTypes[numberOfSchainTypes + 1].numberOfNodes = numberOfNodes;
        numberOfSchainTypes++;
        emit SchainTypeAdded(numberOfSchainTypes, partOfNode, numberOfNodes);
    }

    function removeSchainType(uint typeOfSchain) external override onlySchainTypeManager {

        require(_keysOfSchainTypes.remove(typeOfSchain), "Schain type is already removed");
        delete schainTypes[typeOfSchain].partOfNode;
        delete schainTypes[typeOfSchain].numberOfNodes;
        emit SchainTypeRemoved(typeOfSchain);
    }

    function setNumberOfSchainTypes(uint newNumberOfSchainTypes) external override onlySchainTypeManager {

        numberOfSchainTypes = newNumberOfSchainTypes;
    }

    function removeNodeFromAllExceptionSchains(uint nodeIndex) external override allow("SkaleManager") {

        uint len = _nodeToLockedSchains[nodeIndex].length;
        for (uint i = len; i > 0; i--) {
            removeNodeFromExceptions(_nodeToLockedSchains[nodeIndex][i - 1], nodeIndex);
        }
    }

    function removeAllNodesFromSchainExceptions(bytes32 schainHash) external override allow("Schains") {

        for (uint i = 0; i < _schainToExceptionNodes[schainHash].length; ++i) {
            removeNodeFromExceptions(schainHash, _schainToExceptionNodes[schainHash][i]);
        }
    }


    function makeSchainNodesInvisible(
        bytes32 schainHash
    )
        external
        override
        allowTwo("NodeRotation", "SkaleDKG")
        schainExists(schainHash)
    {

        INodes nodes = INodes(contractManager.getContract("Nodes"));
        for (uint i = 0; i < _schainToExceptionNodes[schainHash].length; i++) {
            nodes.makeNodeInvisible(_schainToExceptionNodes[schainHash][i]);
        }
    }

    function makeSchainNodesVisible(
        bytes32 schainHash
    )
        external
        override
        allowTwo("NodeRotation", "SkaleDKG")
        schainExists(schainHash)
    {

        _makeSchainNodesVisible(schainHash);
    }

    function newGeneration() external override onlyGenerationManager {

        currentGeneration += 1;
    }

    function getSchains() external view override returns (bytes32[] memory) {

        return schainsAtSystem;
    }

    function getSchainsPartOfNode(bytes32 schainHash) external view override schainExists(schainHash) returns (uint8) {

        return schains[schainHash].partOfNode;
    }

    function getSchainListSize(address from) external view override returns (uint) {

        return schainIndexes[from].length;
    }

    function getSchainHashesByAddress(address from) external view override returns (bytes32[] memory) {

        return schainIndexes[from];
    }

    function getSchainIdsByAddress(address from) external view override returns (bytes32[] memory) {

        return schainIndexes[from];
    }

    function getSchainHashesForNode(uint nodeIndex) external view override returns (bytes32[] memory) {

        return schainsForNodes[nodeIndex];
    }

    function getSchainIdsForNode(uint nodeIndex) external view override returns (bytes32[] memory) {

        return schainsForNodes[nodeIndex];
    }

    function getSchainOwner(bytes32 schainHash) external view override schainExists(schainHash) returns (address) {

        return schains[schainHash].owner;
    }

    function getSchainOriginator(bytes32 schainHash)
        external
        view
        override
        schainExists(schainHash)
        returns (address)
    {

        require(schains[schainHash].originator != address(0), "Originator address is not set");
        return schains[schainHash].originator;
    }

    function isSchainNameAvailable(string calldata name) external view override returns (bool) {

        bytes32 schainHash = keccak256(abi.encodePacked(name));
        return schains[schainHash].owner == address(0) &&
            !usedSchainNames[schainHash] &&
            keccak256(abi.encodePacked(name)) != keccak256(abi.encodePacked("Mainnet")) &&
            bytes(name).length > 0;
    }

    function isTimeExpired(bytes32 schainHash) external view override schainExists(schainHash) returns (bool) {

        return uint(schains[schainHash].startDate) + schains[schainHash].lifetime < block.timestamp;
    }

    function isOwnerAddress(
        address from,
        bytes32 schainHash
    )
        external
        view
        override
        schainExists(schainHash)
        returns (bool)
    {

        return schains[schainHash].owner == from;
    }

    function getSchainName(bytes32 schainHash)
        external
        view
        override schainExists(schainHash)
        returns (string memory)
    {

        return schains[schainHash].name;
    }

    function getActiveSchain(uint nodeIndex) external view override returns (bytes32) {

        for (uint i = schainsForNodes[nodeIndex].length; i > 0; i--) {
            if (schainsForNodes[nodeIndex][i - 1] != bytes32(0)) {
                return schainsForNodes[nodeIndex][i - 1];
            }
        }
        return bytes32(0);
    }

    function getActiveSchains(uint nodeIndex) external view override returns (bytes32[] memory activeSchains) {

        uint activeAmount = 0;
        for (uint i = 0; i < schainsForNodes[nodeIndex].length; i++) {
            if (schainsForNodes[nodeIndex][i] != bytes32(0)) {
                activeAmount++;
            }
        }

        uint cursor = 0;
        activeSchains = new bytes32[](activeAmount);
        for (uint i = schainsForNodes[nodeIndex].length; i > 0; i--) {
            if (schainsForNodes[nodeIndex][i - 1] != bytes32(0)) {
                activeSchains[cursor++] = schainsForNodes[nodeIndex][i - 1];
            }
        }
    }

    function getNumberOfNodesInGroup(bytes32 schainHash)
        external
        view
        override
        schainExists(schainHash)
        returns (uint)
    {

        return schainsGroups[schainHash].length;
    }

    function getNodesInGroup(bytes32 schainHash)
        external
        view
        override
        schainExists(schainHash)
        returns (uint[] memory)
    {

        return schainsGroups[schainHash];
    }

    function isNodeAddressesInGroup(
        bytes32 schainHash,
        address sender
    )
        external
        view
        override
        schainExists(schainHash)
        returns (bool)
    {

        INodes nodes = INodes(contractManager.getContract("Nodes"));
        for (uint i = 0; i < schainsGroups[schainHash].length; i++) {
            if (nodes.getNodeAddress(schainsGroups[schainHash][i]) == sender) {
                return true;
            }
        }
        return false;
    }

    function getNodeIndexInGroup(
        bytes32 schainHash,
        uint nodeId
    )
        external
        view
        override
        schainExists(schainHash)
        returns (uint)
    {

        for (uint index = 0; index < schainsGroups[schainHash].length; index++) {
            if (schainsGroups[schainHash][index] == nodeId) {
                return index;
            }
        }
        return schainsGroups[schainHash].length;
    }

    function isAnyFreeNode(bytes32 schainHash) external view override schainExists(schainHash) returns (bool) {

        INodes nodes = INodes(contractManager.getContract("Nodes"));
        uint8 space = schains[schainHash].partOfNode;
        return nodes.countNodesWithFreeSpace(space) > 0;
    }

    function checkException(bytes32 schainHash, uint nodeIndex)
        external
        view
        override
        schainExists(schainHash)
        returns (bool)
    {

        return _exceptionsForGroups[schainHash][nodeIndex];
    }

    function checkHoleForSchain(
        bytes32 schainHash,
        uint indexOfNode
    )
        external
        view
        override
        schainExists(schainHash)
        returns (bool)
    {

        for (uint i = 0; i < holesForSchains[schainHash].length; i++) {
            if (holesForSchains[schainHash][i] == indexOfNode) {
                return true;
            }
        }
        return false;
    }

    function checkSchainOnNode(
        uint nodeIndex,
        bytes32 schainHash
    )
        external
        view
        override
        schainExists(schainHash)
        returns (bool)
    {

        return placeOfSchainOnNode[schainHash][nodeIndex] != 0;
    }

    function getSchainType(uint typeOfSchain) external view override returns(uint8, uint) {

        require(_keysOfSchainTypes.contains(typeOfSchain), "Invalid type of schain");
        return (schainTypes[typeOfSchain].partOfNode, schainTypes[typeOfSchain].numberOfNodes);
    }

    function getGeneration(bytes32 schainHash) external view override schainExists(schainHash) returns (uint) {

        return schains[schainHash].generation;
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);

        numberOfSchains = 0;
        sumOfSchainsResources = 0;
        numberOfSchainTypes = 0;
    }

    function addSchainForNode(
        uint nodeIndex,
        bytes32 schainHash
    )
        public
        override
        allowTwo("Schains", "NodeRotation")
        schainExists(schainHash)
    {

        if (holesForNodes[nodeIndex].length == 0) {
            schainsForNodes[nodeIndex].push(schainHash);
            placeOfSchainOnNode[schainHash][nodeIndex] = schainsForNodes[nodeIndex].length;
        } else {
            uint lastHoleOfNode = holesForNodes[nodeIndex][holesForNodes[nodeIndex].length - 1];
            schainsForNodes[nodeIndex][lastHoleOfNode] = schainHash;
            placeOfSchainOnNode[schainHash][nodeIndex] = lastHoleOfNode + 1;
            holesForNodes[nodeIndex].pop();
        }
    }

    function removeSchainForNode(uint nodeIndex, uint schainIndex)
        public
        override
        allowThree("NodeRotation", "SkaleDKG", "Schains")
    {

        uint length = schainsForNodes[nodeIndex].length;
        if (schainIndex == length - 1) {
            schainsForNodes[nodeIndex].pop();
        } else {
            delete schainsForNodes[nodeIndex][schainIndex];
            if (holesForNodes[nodeIndex].length > 0 && holesForNodes[nodeIndex][0] > schainIndex) {
                uint hole = holesForNodes[nodeIndex][0];
                holesForNodes[nodeIndex][0] = schainIndex;
                holesForNodes[nodeIndex].push(hole);
            } else {
                holesForNodes[nodeIndex].push(schainIndex);
            }
        }
    }

    function removeNodeFromExceptions(bytes32 schainHash, uint nodeIndex)
        public
        override
        allowThree("Schains", "NodeRotation", "SkaleManager")
        schainExists(schainHash)
    {

        _exceptionsForGroups[schainHash][nodeIndex] = false;
        uint len = _nodeToLockedSchains[nodeIndex].length;
        for (uint i = len; i > 0; i--) {
            if (_nodeToLockedSchains[nodeIndex][i - 1] == schainHash) {
                if (i != len) {
                    _nodeToLockedSchains[nodeIndex][i - 1] = _nodeToLockedSchains[nodeIndex][len - 1];
                }
                _nodeToLockedSchains[nodeIndex].pop();
                break;
            }
        }
        len = _schainToExceptionNodes[schainHash].length;
        for (uint i = len; i > 0; i--) {
            if (_schainToExceptionNodes[schainHash][i - 1] == nodeIndex) {
                if (i != len) {
                    _schainToExceptionNodes[schainHash][i - 1] = _schainToExceptionNodes[schainHash][len - 1];
                }
                _schainToExceptionNodes[schainHash].pop();
                break;
            }
        }
    }

    function isSchainExist(bytes32 schainHash) public view override returns (bool) {

        return bytes(schains[schainHash].name).length != 0;
    }

    function _getNodeToLockedSchains() internal view returns (mapping(uint => bytes32[]) storage) {

        return _nodeToLockedSchains;
    }

    function _getSchainToExceptionNodes() internal view returns (mapping(bytes32 => uint[]) storage) {

        return _schainToExceptionNodes;
    }

    function _generateGroup(bytes32 schainHash, uint numberOfNodes) private returns (uint[] memory nodesInGroup) {

        INodes nodes = INodes(contractManager.getContract("Nodes"));
        uint8 space = schains[schainHash].partOfNode;
        nodesInGroup = new uint[](numberOfNodes);

        require(nodes.countNodesWithFreeSpace(space) >= nodesInGroup.length, "Not enough nodes to create Schain");
        IRandom.RandomGenerator memory randomGenerator = Random.createFromEntropy(
            abi.encodePacked(uint(blockhash(block.number - 1)), schainHash)
        );
        for (uint i = 0; i < numberOfNodes; i++) {
            uint node = nodes.getRandomNodeWithFreeSpace(space, randomGenerator);
            nodesInGroup[i] = node;
            _setException(schainHash, node);
            addSchainForNode(node, schainHash);
            nodes.makeNodeInvisible(node);
            require(nodes.removeSpaceFromNode(node, space), "Could not remove space from Node");
        }
        schainsGroups[schainHash] = nodesInGroup;
        _makeSchainNodesVisible(schainHash);
    }

    function _setException(bytes32 schainHash, uint nodeIndex) private {

        _exceptionsForGroups[schainHash][nodeIndex] = true;
        _nodeToLockedSchains[nodeIndex].push(schainHash);
        _schainToExceptionNodes[schainHash].push(nodeIndex);
    }

    function _makeSchainNodesVisible(bytes32 schainHash) private {

        INodes nodes = INodes(contractManager.getContract("Nodes"));
        for (uint i = 0; i < _schainToExceptionNodes[schainHash].length; i++) {
            nodes.makeNodeVisible(_schainToExceptionNodes[schainHash][i]);
        }
    }

    function _findNode(bytes32 schainHash, uint nodeIndex) private view returns (uint) {

        uint[] memory nodesInGroup = schainsGroups[schainHash];
        uint index;
        for (index = 0; index < nodesInGroup.length; index++) {
            if (nodesInGroup[index] == nodeIndex) {
                return index;
            }
        }
        return index;
    }

}