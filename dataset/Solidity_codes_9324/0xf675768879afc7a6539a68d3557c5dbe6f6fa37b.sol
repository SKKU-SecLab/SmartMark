
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

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface ISkaleManager {

    event VersionUpdated(string oldVersion, string newVersion);

    event BountyReceived(
        uint indexed nodeIndex,
        address owner,
        uint averageDowntime,
        uint averageLatency,
        uint bounty,
        uint previousBlockEvent
    );
    
    function createNode(
        uint16 port,
        uint16 nonce,
        bytes4 ip,
        bytes4 publicIp,
        bytes32[2] calldata publicKey,
        string calldata name,
        string calldata domainName
    )
        external;

    function nodeExit(uint nodeIndex) external;

    function deleteSchain(string calldata name) external;

    function deleteSchainByRoot(string calldata name) external;

    function getBounty(uint nodeIndex) external;

    function setVersion(string calldata newVersion) external;

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;

interface IMintableToken {

    function mint(
        address account,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    )
        external
        returns (bool);

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

interface ISchains {


    struct SchainOption {
        string name;
        bytes value;
    }
    
    event SchainCreated(
        string name,
        address owner,
        uint partOfNode,
        uint lifetime,
        uint numberOfNodes,
        uint deposit,
        uint16 nonce,
        bytes32 schainHash
    );

    event SchainDeleted(
        address owner,
        string name,
        bytes32 indexed schainHash
    );

    event NodeRotated(
        bytes32 schainHash,
        uint oldNode,
        uint newNode
    );

    event NodeAdded(
        bytes32 schainHash,
        uint newNode
    );

    event SchainNodes(
        string name,
        bytes32 schainHash,
        uint[] nodesInGroup
    );

    function addSchain(address from, uint deposit, bytes calldata data) external;

    function addSchainByFoundation(
        uint lifetime,
        uint8 typeOfSchain,
        uint16 nonce,
        string calldata name,
        address schainOwner,
        address schainOriginator,
        SchainOption[] calldata options
    )
        external
        payable;

    function deleteSchain(address from, string calldata name) external;

    function deleteSchainByRoot(string calldata name) external;

    function restartSchainCreation(string calldata name) external;

    function verifySchainSignature(
        uint256 signA,
        uint256 signB,
        bytes32 hash,
        uint256 counter,
        uint256 hashA,
        uint256 hashB,
        string calldata schainName
    )
        external
        view
        returns (bool);

    function getSchainPrice(uint typeOfSchain, uint lifetime) external view returns (uint);

    function getOption(bytes32 schainHash, string calldata optionName) external view returns (bytes memory);

    function getOptions(bytes32 schainHash) external view returns (SchainOption[] memory);

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

interface IWallets {

    event ValidatorWalletRecharged(address sponsor, uint amount, uint validatorId);

    event SchainWalletRecharged(address sponsor, uint amount, bytes32 schainHash);

    event NodeRefundedByValidator(address node, uint validatorId, uint amount);

    event NodeRefundedBySchain(address node, bytes32 schainHash, uint amount);

    event WithdrawFromValidatorWallet(uint indexed validatorId, uint amount);

    event WithdrawFromSchainWallet(bytes32 indexed schainHash, uint amount);

    receive() external payable;
    function refundGasByValidator(uint validatorId, address payable spender, uint spentGas) external;

    function refundGasByValidatorToSchain(uint validatorId, bytes32 schainHash) external;

    function refundGasBySchain(bytes32 schainId, address payable spender, uint spentGas, bool isDebt) external;

    function withdrawFundsFromSchainWallet(address payable schainOwner, bytes32 schainHash) external;

    function withdrawFundsFromValidatorWallet(uint amount) external;

    function rechargeValidatorWallet(uint validatorId) external payable;

    function rechargeSchainWallet(bytes32 schainId) external payable;

    function getSchainBalance(bytes32 schainHash) external view returns (uint);

    function getValidatorBalance(uint validatorId) external view returns (uint);

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




contract SkaleManager is IERC777Recipient, ISkaleManager, Permissions {


    IERC1820Registry private _erc1820;

    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    bytes32 constant public ADMIN_ROLE = keccak256("ADMIN_ROLE");

    string public version;

    bytes32 public constant SCHAIN_REMOVAL_ROLE = keccak256("SCHAIN_REMOVAL_ROLE");

    function tokensReceived(
        address, // operator
        address from,
        address to,
        uint256 value,
        bytes calldata userData,
        bytes calldata // operator data
    )
        external
        override
        allow("SkaleToken")
    {

        require(to == address(this), "Receiver is incorrect");
        if (userData.length > 0) {
            ISchains schains = ISchains(
                contractManager.getContract("Schains"));
            schains.addSchain(from, value, userData);
        }
    }

    function createNode(
        uint16 port,
        uint16 nonce,
        bytes4 ip,
        bytes4 publicIp,
        bytes32[2] calldata publicKey,
        string calldata name,
        string calldata domainName
    )
        external
        override
    {

        INodes nodes = INodes(contractManager.getContract("Nodes"));
        nodes.checkPossibilityCreatingNode(msg.sender);

        INodes.NodeCreationParams memory params = INodes.NodeCreationParams({
            name: name,
            ip: ip,
            publicIp: publicIp,
            port: port,
            publicKey: publicKey,
            nonce: nonce,
            domainName: domainName
        });
        nodes.createNode(msg.sender, params);
    }

    function nodeExit(uint nodeIndex) external override {

        uint gasTotal = gasleft();
        IValidatorService validatorService = IValidatorService(contractManager.getContract("ValidatorService"));
        INodeRotation nodeRotation = INodeRotation(contractManager.getContract("NodeRotation"));
        INodes nodes = INodes(contractManager.getContract("Nodes"));
        uint validatorId = nodes.getValidatorId(nodeIndex);
        bool permitted = (_isOwner() || nodes.isNodeExist(msg.sender, nodeIndex));
        if (!permitted && validatorService.validatorAddressExists(msg.sender)) {
            permitted = validatorService.getValidatorId(msg.sender) == validatorId;
        }
        require(permitted, "Sender is not permitted to call this function");
        require(nodes.isNodeLeaving(nodeIndex), "Node should be Leaving");
        (bool completed, bool isSchains) = nodeRotation.exitFromSchain(nodeIndex);
        if (completed) {
            ISchainsInternal(
                contractManager.getContract("SchainsInternal")
            ).removeNodeFromAllExceptionSchains(nodeIndex);
            require(nodes.completeExit(nodeIndex), "Finishing of node exit is failed");
            nodes.changeNodeFinishTime(
                nodeIndex,
                block.timestamp + (
                    isSchains ?
                    IConstantsHolder(contractManager.getContract("ConstantsHolder")).rotationDelay() :
                    0
                )
            );
            nodes.deleteNodeForValidator(validatorId, nodeIndex);
        }
        _refundGasByValidator(validatorId, payable(msg.sender), gasTotal - gasleft());
    }

    function deleteSchain(string calldata name) external override {

        ISchains schains = ISchains(contractManager.getContract("Schains"));
        schains.deleteSchain(msg.sender, name);
    }

    function deleteSchainByRoot(string calldata name) external override {

        require(hasRole(SCHAIN_REMOVAL_ROLE, msg.sender), "SCHAIN_REMOVAL_ROLE is required");
        ISchains schains = ISchains(contractManager.getContract("Schains"));
        schains.deleteSchainByRoot(name);
    }

    function getBounty(uint nodeIndex) external override {

        uint gasTotal = gasleft();
        INodes nodes = INodes(contractManager.getContract("Nodes"));
        require(nodes.isNodeExist(msg.sender, nodeIndex), "Node does not exist for Message sender");
        require(nodes.isTimeForReward(nodeIndex), "Not time for bounty");
        require(!nodes.isNodeLeft(nodeIndex), "The node must not be in Left state");
        require(!nodes.incompliant(nodeIndex), "The node is incompliant");
        IBountyV2 bountyContract = IBountyV2(contractManager.getContract("Bounty"));

        uint bounty = bountyContract.calculateBounty(nodeIndex);

        nodes.changeNodeLastRewardDate(nodeIndex);
        uint validatorId = nodes.getValidatorId(nodeIndex);
        if (bounty > 0) {
            _payBounty(bounty, validatorId);
        }

        emit BountyReceived(
            nodeIndex,
            msg.sender,
            0,
            0,
            bounty,
            type(uint).max);
        
        _refundGasByValidator(validatorId, payable(msg.sender), gasTotal - gasleft());
    }

    function setVersion(string calldata newVersion) external override onlyOwner {

        emit VersionUpdated(version, newVersion);
        version = newVersion;
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);
        _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        _erc1820.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }

    function _payBounty(uint bounty, uint validatorId) private {

        IERC777 skaleToken = IERC777(contractManager.getContract("SkaleToken"));
        IDistributor distributor = IDistributor(contractManager.getContract("Distributor"));
        
        require(
            IMintableToken(address(skaleToken)).mint(address(distributor), bounty, abi.encode(validatorId), ""),
            "Token was not minted"
        );
    }

    function _refundGasByValidator(uint validatorId, address payable spender, uint spentGas) private {

        uint gasCostOfRefundGasByValidator = 55723;
        IWallets(payable(contractManager.getContract("Wallets")))
        .refundGasByValidator(validatorId, spender, spentGas + gasCostOfRefundGasByValidator);
    }
}