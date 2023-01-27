

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


interface ISkaleVerifier {

    function verify(
        ISkaleDKG.Fp2Point calldata signature,
        bytes32 hash,
        uint counter,
        uint hashA,
        uint hashB,
        ISkaleDKG.G2Point calldata publicKey
    )
        external
        view
        returns (bool);

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


interface IKeyStorage {


    struct KeyShare {
        bytes32[2] publicKey;
        bytes32 share;
    }
    
    function deleteKey(bytes32 schainHash) external;

    function initPublicKeyInProgress(bytes32 schainHash) external;

    function adding(bytes32 schainHash, ISkaleDKG.G2Point memory value) external;

    function finalizePublicKey(bytes32 schainHash) external;

    function getCommonPublicKey(bytes32 schainHash) external view returns (ISkaleDKG.G2Point memory);

    function getPreviousPublicKey(bytes32 schainHash) external view returns (ISkaleDKG.G2Point memory);

    function getAllPreviousPublicKeys(bytes32 schainHash) external view returns (ISkaleDKG.G2Point[] memory);

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


library Precompiled {


    function bigModExp(uint base, uint power, uint modulus) internal view returns (uint) {

        uint[6] memory inputToBigModExp;
        inputToBigModExp[0] = 32;
        inputToBigModExp[1] = 32;
        inputToBigModExp[2] = 32;
        inputToBigModExp[3] = base;
        inputToBigModExp[4] = power;
        inputToBigModExp[5] = modulus;
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(not(0), 5, inputToBigModExp, mul(6, 0x20), out, 0x20)
        }
        require(success, "BigModExp failed");
        return out[0];
    }

    function bn256ScalarMul(uint x, uint y, uint k) internal view returns (uint , uint ) {

        uint[3] memory inputToMul;
        uint[2] memory output;
        inputToMul[0] = x;
        inputToMul[1] = y;
        inputToMul[2] = k;
        bool success;
        assembly {
            success := staticcall(not(0), 7, inputToMul, 0x60, output, 0x40)
        }
        require(success, "Multiplication failed");
        return (output[0], output[1]);
    }

    function bn256Pairing(
        uint x1,
        uint y1,
        uint a1,
        uint b1,
        uint c1,
        uint d1,
        uint x2,
        uint y2,
        uint a2,
        uint b2,
        uint c2,
        uint d2)
        internal view returns (bool)
    {

        bool success;
        uint[12] memory inputToPairing;
        inputToPairing[0] = x1;
        inputToPairing[1] = y1;
        inputToPairing[2] = a1;
        inputToPairing[3] = b1;
        inputToPairing[4] = c1;
        inputToPairing[5] = d1;
        inputToPairing[6] = x2;
        inputToPairing[7] = y2;
        inputToPairing[8] = a2;
        inputToPairing[9] = b2;
        inputToPairing[10] = c2;
        inputToPairing[11] = d2;
        uint[1] memory out;
        assembly {
            success := staticcall(not(0), 8, inputToPairing, mul(12, 0x20), out, 0x20)
        }
        require(success, "Pairing check failed");
        return out[0] != 0;
    }
}// AGPL-3.0-only



pragma solidity 0.8.11;




library Fp2Operations {


    uint constant public P = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    function inverseFp2(ISkaleDKG.Fp2Point memory value) internal view returns (ISkaleDKG.Fp2Point memory result) {

        uint p = P;
        uint t0 = mulmod(value.a, value.a, p);
        uint t1 = mulmod(value.b, value.b, p);
        uint t2 = mulmod(p - 1, t1, p);
        if (t0 >= t2) {
            t2 = addmod(t0, p - t2, p);
        } else {
            t2 = (p - addmod(t2, p - t0, p)) % p;
        }
        uint t3 = Precompiled.bigModExp(t2, p - 2, p);
        result.a = mulmod(value.a, t3, p);
        result.b = (p - mulmod(value.b, t3, p)) % p;
    }

    function addFp2(ISkaleDKG.Fp2Point memory value1, ISkaleDKG.Fp2Point memory value2)
        internal
        pure
        returns (ISkaleDKG.Fp2Point memory)
    {

        return ISkaleDKG.Fp2Point({ a: addmod(value1.a, value2.a, P), b: addmod(value1.b, value2.b, P) });
    }

    function scalarMulFp2(ISkaleDKG.Fp2Point memory value, uint scalar)
        internal
        pure
        returns (ISkaleDKG.Fp2Point memory)
    {

        return ISkaleDKG.Fp2Point({ a: mulmod(scalar, value.a, P), b: mulmod(scalar, value.b, P) });
    }

    function minusFp2(ISkaleDKG.Fp2Point memory diminished, ISkaleDKG.Fp2Point memory subtracted) internal pure
        returns (ISkaleDKG.Fp2Point memory difference)
    {

        uint p = P;
        if (diminished.a >= subtracted.a) {
            difference.a = addmod(diminished.a, p - subtracted.a, p);
        } else {
            difference.a = (p - addmod(subtracted.a, p - diminished.a, p)) % p;
        }
        if (diminished.b >= subtracted.b) {
            difference.b = addmod(diminished.b, p - subtracted.b, p);
        } else {
            difference.b = (p - addmod(subtracted.b, p - diminished.b, p)) % p;
        }
    }

    function mulFp2(
        ISkaleDKG.Fp2Point memory value1,
        ISkaleDKG.Fp2Point memory value2
    )
        internal
        pure
        returns (ISkaleDKG.Fp2Point memory result)
    {

        uint p = P;
        ISkaleDKG.Fp2Point memory point = ISkaleDKG.Fp2Point({
            a: mulmod(value1.a, value2.a, p),
            b: mulmod(value1.b, value2.b, p)});
        result.a = addmod(
            point.a,
            mulmod(p - 1, point.b, p),
            p);
        result.b = addmod(
            mulmod(
                addmod(value1.a, value1.b, p),
                addmod(value2.a, value2.b, p),
                p),
            p - addmod(point.a, point.b, p),
            p);
    }

    function squaredFp2(ISkaleDKG.Fp2Point memory value) internal pure returns (ISkaleDKG.Fp2Point memory) {

        uint p = P;
        uint ab = mulmod(value.a, value.b, p);
        uint multiplication = mulmod(addmod(value.a, value.b, p), addmod(value.a, mulmod(p - 1, value.b, p), p), p);
        return ISkaleDKG.Fp2Point({ a: multiplication, b: addmod(ab, ab, p) });
    }

    function isEqual(
        ISkaleDKG.Fp2Point memory value1,
        ISkaleDKG.Fp2Point memory value2
    )
        internal
        pure
        returns (bool)
    {

        return value1.a == value2.a && value1.b == value2.b;
    }
}

library G1Operations {

    using Fp2Operations for ISkaleDKG.Fp2Point;

    function getG1Generator() internal pure returns (ISkaleDKG.Fp2Point memory) {

        return ISkaleDKG.Fp2Point({
            a: 1,
            b: 2
        });
    }

    function isG1Point(uint x, uint y) internal pure returns (bool) {

        uint p = Fp2Operations.P;
        return mulmod(y, y, p) == 
            addmod(mulmod(mulmod(x, x, p), x, p), 3, p);
    }

    function isG1(ISkaleDKG.Fp2Point memory point) internal pure returns (bool) {

        return isG1Point(point.a, point.b);
    }

    function checkRange(ISkaleDKG.Fp2Point memory point) internal pure returns (bool) {

        return point.a < Fp2Operations.P && point.b < Fp2Operations.P;
    }

    function negate(uint y) internal pure returns (uint) {

        return (Fp2Operations.P - y) % Fp2Operations.P;
    }

}


library G2Operations {

    using Fp2Operations for ISkaleDKG.Fp2Point;

    function doubleG2(ISkaleDKG.G2Point memory value)
        internal
        view
        returns (ISkaleDKG.G2Point memory result)
    {

        if (isG2Zero(value)) {
            return value;
        } else {
            ISkaleDKG.Fp2Point memory s =
                value.x.squaredFp2().scalarMulFp2(3).mulFp2(value.y.scalarMulFp2(2).inverseFp2());
            result.x = s.squaredFp2().minusFp2(value.x.addFp2(value.x));
            result.y = value.y.addFp2(s.mulFp2(result.x.minusFp2(value.x)));
            uint p = Fp2Operations.P;
            result.y.a = (p - result.y.a) % p;
            result.y.b = (p - result.y.b) % p;
        }
    }

    function addG2(
        ISkaleDKG.G2Point memory value1,
        ISkaleDKG.G2Point memory value2
    )
        internal
        view
        returns (ISkaleDKG.G2Point memory sum)
    {

        if (isG2Zero(value1)) {
            return value2;
        }
        if (isG2Zero(value2)) {
            return value1;
        }
        if (isEqual(value1, value2)) {
            return doubleG2(value1);
        }
        if (value1.x.isEqual(value2.x)) {
            sum.x.a = 0;
            sum.x.b = 0;
            sum.y.a = 1;
            sum.y.b = 0;
            return sum;
        }

        ISkaleDKG.Fp2Point memory s = value2.y.minusFp2(value1.y).mulFp2(value2.x.minusFp2(value1.x).inverseFp2());
        sum.x = s.squaredFp2().minusFp2(value1.x.addFp2(value2.x));
        sum.y = value1.y.addFp2(s.mulFp2(sum.x.minusFp2(value1.x)));
        uint p = Fp2Operations.P;
        sum.y.a = (p - sum.y.a) % p;
        sum.y.b = (p - sum.y.b) % p;
    }

    function getTWISTB() internal pure returns (ISkaleDKG.Fp2Point memory) {

        return ISkaleDKG.Fp2Point({
            a: 19485874751759354771024239261021720505790618469301721065564631296452457478373,
            b: 266929791119991161246907387137283842545076965332900288569378510910307636690
        });
    }

    function getG2Generator() internal pure returns (ISkaleDKG.G2Point memory) {

        return ISkaleDKG.G2Point({
            x: ISkaleDKG.Fp2Point({
                a: 10857046999023057135944570762232829481370756359578518086990519993285655852781,
                b: 11559732032986387107991004021392285783925812861821192530917403151452391805634
            }),
            y: ISkaleDKG.Fp2Point({
                a: 8495653923123431417604973247489272438418190587263600148770280649306958101930,
                b: 4082367875863433681332203403145435568316851327593401208105741076214120093531
            })
        });
    }

    function getG2Zero() internal pure returns (ISkaleDKG.G2Point memory) {

        return ISkaleDKG.G2Point({
            x: ISkaleDKG.Fp2Point({
                a: 0,
                b: 0
            }),
            y: ISkaleDKG.Fp2Point({
                a: 1,
                b: 0
            })
        });
    }

    function isG2Point(ISkaleDKG.Fp2Point memory x, ISkaleDKG.Fp2Point memory y) internal pure returns (bool) {

        if (isG2ZeroPoint(x, y)) {
            return true;
        }
        ISkaleDKG.Fp2Point memory squaredY = y.squaredFp2();
        ISkaleDKG.Fp2Point memory res = squaredY.minusFp2(
                x.squaredFp2().mulFp2(x)
            ).minusFp2(getTWISTB());
        return res.a == 0 && res.b == 0;
    }

    function isG2(ISkaleDKG.G2Point memory value) internal pure returns (bool) {

        return isG2Point(value.x, value.y);
    }

    function isG2ZeroPoint(
        ISkaleDKG.Fp2Point memory x,
        ISkaleDKG.Fp2Point memory y
    )
        internal
        pure
        returns (bool)
    {

        return x.a == 0 && x.b == 0 && y.a == 1 && y.b == 0;
    }

    function isG2Zero(ISkaleDKG.G2Point memory value) internal pure returns (bool) {

        return value.x.a == 0 && value.x.b == 0 && value.y.a == 1 && value.y.b == 0;
    }

    function isEqual(
        ISkaleDKG.G2Point memory value1,
        ISkaleDKG.G2Point memory value2
    )
        internal
        pure
        returns (bool)
    {

        return value1.x.isEqual(value2.x) && value1.y.isEqual(value2.y);
    }
}// AGPL-3.0-only


pragma solidity 0.8.11;




contract Schains is Permissions, ISchains {

    using AddressUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

    struct SchainParameters {
        uint lifetime;
        uint8 typeOfSchain;
        uint16 nonce;
        string name;
        address originator;
        SchainOption[] options;
    }

    mapping (bytes32 => EnumerableSetUpgradeable.Bytes32Set) private _optionsIndex;
    mapping (bytes32 => mapping (bytes32 => SchainOption)) private _options;

    bytes32 public constant SCHAIN_CREATOR_ROLE = keccak256("SCHAIN_CREATOR_ROLE");

    modifier schainExists(ISchainsInternal schainsInternal, bytes32 schainHash) {

        require(schainsInternal.isSchainExist(schainHash), "The schain does not exist");
        _;
    }

    function addSchain(address from, uint deposit, bytes calldata data) external override allow("SkaleManager") {

        SchainParameters memory schainParameters = abi.decode(data, (SchainParameters));
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getConstantsHolder());
        uint schainCreationTimeStamp = constantsHolder.schainCreationTimeStamp();
        uint minSchainLifetime = constantsHolder.minimalSchainLifetime();
        require(block.timestamp >= schainCreationTimeStamp, "It is not a time for creating Schain");
        require(
            schainParameters.lifetime >= minSchainLifetime,
            "Minimal schain lifetime should be satisfied"
        );
        require(
            getSchainPrice(schainParameters.typeOfSchain, schainParameters.lifetime) <= deposit,
            "Not enough money to create Schain");
        _addSchain(from, deposit, schainParameters);
    }

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
        payable
        override
    {

        require(hasRole(SCHAIN_CREATOR_ROLE, msg.sender), "Sender is not authorized to create schain");

        SchainParameters memory schainParameters = SchainParameters({
            lifetime: lifetime,
            typeOfSchain: typeOfSchain,
            nonce: nonce,
            name: name,
            originator: schainOriginator,
            options: options
        });

        address _schainOwner;
        if (schainOwner != address(0)) {
            _schainOwner = schainOwner;
        } else {
            _schainOwner = msg.sender;
        }

        _addSchain(_schainOwner, 0, schainParameters);
        bytes32 schainHash = keccak256(abi.encodePacked(name));
        IWallets(payable(contractManager.getContract("Wallets"))).rechargeSchainWallet{value: msg.value}(schainHash);
    }

    function deleteSchain(address from, string calldata name) external override allow("SkaleManager") {

        ISchainsInternal schainsInternal = ISchainsInternal(contractManager.getContract("SchainsInternal"));
        bytes32 schainHash = keccak256(abi.encodePacked(name));
        require(
            schainsInternal.isOwnerAddress(from, schainHash),
            "Message sender is not the owner of the Schain"
        );

        _deleteSchain(name, schainsInternal);
    }

    function deleteSchainByRoot(string calldata name) external override allow("SkaleManager") {

        _deleteSchain(name, ISchainsInternal(contractManager.getContract("SchainsInternal")));
    }

    function restartSchainCreation(string calldata name) external override allow("SkaleManager") {

        INodeRotation nodeRotation = INodeRotation(contractManager.getContract("NodeRotation"));
        bytes32 schainHash = keccak256(abi.encodePacked(name));
        ISkaleDKG skaleDKG = ISkaleDKG(contractManager.getContract("SkaleDKG"));
        require(!skaleDKG.isLastDKGSuccessful(schainHash), "DKG success");
        ISchainsInternal schainsInternal = ISchainsInternal(
            contractManager.getContract("SchainsInternal"));
        require(schainsInternal.isAnyFreeNode(schainHash), "No free Nodes for new group formation");
        uint newNodeIndex = nodeRotation.selectNodeToGroup(schainHash);
        skaleDKG.openChannel(schainHash);
        emit NodeAdded(schainHash, newNodeIndex);
    }


    function verifySchainSignature(
        uint signatureA,
        uint signatureB,
        bytes32 hash,
        uint counter,
        uint hashA,
        uint hashB,
        string calldata schainName
    )
        external
        view
        override
        returns (bool)
    {

        ISkaleVerifier skaleVerifier = ISkaleVerifier(contractManager.getContract("SkaleVerifier"));
        ISkaleDKG.G2Point memory publicKey = G2Operations.getG2Zero();
        bytes32 schainHash = keccak256(abi.encodePacked(schainName));
        if (
            INodeRotation(contractManager.getContract("NodeRotation")).isNewNodeFound(schainHash) &&
            INodeRotation(contractManager.getContract("NodeRotation")).isRotationInProgress(schainHash) &&
            ISkaleDKG(contractManager.getContract("SkaleDKG")).isLastDKGSuccessful(schainHash)
        ) {
            publicKey = IKeyStorage(
                contractManager.getContract("KeyStorage")
            ).getPreviousPublicKey(
                schainHash
            );
        } else {
            publicKey = IKeyStorage(
                contractManager.getContract("KeyStorage")
            ).getCommonPublicKey(
                schainHash
            );
        }
        return skaleVerifier.verify(
            ISkaleDKG.Fp2Point({
                a: signatureA,
                b: signatureB
            }),
            hash, counter,
            hashA, hashB,
            publicKey
        );
    }

    function getOption(bytes32 schainHash, string calldata optionName) external view override returns (bytes memory) {

        bytes32 optionHash = keccak256(abi.encodePacked(optionName));
        ISchainsInternal schainsInternal = ISchainsInternal(
            contractManager.getContract("SchainsInternal"));
        return _getOption(schainHash, optionHash, schainsInternal);
    }

    function getOptions(bytes32 schainHash) external view override returns (SchainOption[] memory) {

        SchainOption[] memory options = new SchainOption[](_optionsIndex[schainHash].length());
        for (uint i = 0; i < options.length; ++i) {
            options[i] = _options[schainHash][_optionsIndex[schainHash].at(i)];
        }
        return options;
    }

    function initialize(address newContractsAddress) public override initializer {

        Permissions.initialize(newContractsAddress);
    }

    function getSchainPrice(uint typeOfSchain, uint lifetime) public view override returns (uint) {

        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getConstantsHolder());
        ISchainsInternal schainsInternal = ISchainsInternal(contractManager.getContract("SchainsInternal"));
        uint nodeDeposit = constantsHolder.NODE_DEPOSIT();
        uint numberOfNodes;
        uint8 divisor;
        (divisor, numberOfNodes) = schainsInternal.getSchainType(typeOfSchain);
        if (divisor == 0) {
            return 1e18;
        } else {
            uint up = nodeDeposit * numberOfNodes * lifetime * 2;
            uint down = uint(
                uint(constantsHolder.SMALL_DIVISOR())
                * uint(constantsHolder.SECONDS_TO_YEAR())
                / divisor
            );
            return up / down;
        }
    }


    function _initializeSchainInSchainsInternal(
        string memory name,
        address from,
        address originator,
        uint deposit,
        uint lifetime,
        ISchainsInternal schainsInternal,
        SchainOption[] memory options
    )
        private
    {

        require(schainsInternal.isSchainNameAvailable(name), "Schain name is not available");

        bytes32 schainHash = keccak256(abi.encodePacked(name));
        for (uint i = 0; i < options.length; ++i) {
            _setOption(schainHash, options[i]);
        }

        schainsInternal.initializeSchain(name, from, originator, lifetime, deposit);
    }

    function _createGroupForSchain(
        string memory schainName,
        bytes32 schainHash,
        uint numberOfNodes,
        uint8 partOfNode,
        ISchainsInternal schainsInternal
    )
        private
    {

        uint[] memory nodesInGroup = schainsInternal.createGroupForSchain(schainHash, numberOfNodes, partOfNode);
        ISkaleDKG(contractManager.getContract("SkaleDKG")).openChannel(schainHash);

        emit SchainNodes(
            schainName,
            schainHash,
            nodesInGroup);
    }

    function _addSchain(address from, uint deposit, SchainParameters memory schainParameters) private {

        ISchainsInternal schainsInternal = ISchainsInternal(contractManager.getContract("SchainsInternal"));

        require(!schainParameters.originator.isContract(), "Originator address must be not a contract");
        if (from.isContract()) {
            require(schainParameters.originator != address(0), "Originator address is not provided");
        } else {
            schainParameters.originator = address(0);
        }

        _initializeSchainInSchainsInternal(
            schainParameters.name,
            from,
            schainParameters.originator,
            deposit,
            schainParameters.lifetime,
            schainsInternal,
            schainParameters.options
        );

        uint numberOfNodes;
        uint8 partOfNode;
        (partOfNode, numberOfNodes) = schainsInternal.getSchainType(schainParameters.typeOfSchain);

        _createGroupForSchain(
            schainParameters.name,
            keccak256(abi.encodePacked(schainParameters.name)),
            numberOfNodes,
            partOfNode,
            schainsInternal
        );

        emit SchainCreated(
            schainParameters.name,
            from,
            partOfNode,
            schainParameters.lifetime,
            numberOfNodes,
            deposit,
            schainParameters.nonce,
            keccak256(abi.encodePacked(schainParameters.name)));
    }

    function _deleteSchain(string calldata name, ISchainsInternal schainsInternal) private {

        INodeRotation nodeRotation = INodeRotation(contractManager.getContract("NodeRotation"));

        bytes32 schainHash = keccak256(abi.encodePacked(name));
        require(schainsInternal.isSchainExist(schainHash), "Schain does not exist");

        _deleteOptions(schainHash, schainsInternal);

        uint[] memory nodesInGroup = schainsInternal.getNodesInGroup(schainHash);
        for (uint i = 0; i < nodesInGroup.length; i++) {
            if (schainsInternal.checkHoleForSchain(schainHash, i)) {
                continue;
            }
            require(
                schainsInternal.checkSchainOnNode(nodesInGroup[i], schainHash),
                "Some Node does not contain given Schain"
            );
            schainsInternal.removeNodeFromSchain(nodesInGroup[i], schainHash);
            schainsInternal.removeNodeFromExceptions(schainHash, nodesInGroup[i]);
        }
        schainsInternal.removeAllNodesFromSchainExceptions(schainHash);
        schainsInternal.deleteGroup(schainHash);
        address from = schainsInternal.getSchainOwner(schainHash);
        schainsInternal.removeHolesForSchain(schainHash);
        nodeRotation.removeRotation(schainHash);
        schainsInternal.removeSchain(schainHash, from);
        IWallets(
            payable(contractManager.getContract("Wallets"))
        ).withdrawFundsFromSchainWallet(payable(from), schainHash);
        emit SchainDeleted(from, name, schainHash);
    }

    function _setOption(
        bytes32 schainHash,
        SchainOption memory option
    )
        private
    {

        bytes32 optionHash = keccak256(abi.encodePacked(option.name));
        _options[schainHash][optionHash] = option;
        require(_optionsIndex[schainHash].add(optionHash), "The option has been set already");
    }

    function _deleteOptions(
        bytes32 schainHash,
        ISchainsInternal schainsInternal
    )
        private
        schainExists(schainsInternal, schainHash)
    {

        while (_optionsIndex[schainHash].length() > 0) {
            bytes32 optionHash = _optionsIndex[schainHash].at(0);
            delete _options[schainHash][optionHash];
            require(_optionsIndex[schainHash].remove(optionHash), "Removing error");
        }
    }

    function _getOption(
        bytes32 schainHash,
        bytes32 optionHash,
        ISchainsInternal schainsInternal
    )
        private
        view
        schainExists(schainsInternal, schainHash)
        returns (bytes memory)
    {

        require(_optionsIndex[schainHash].contains(optionHash), "Option is not set");
        return _options[schainHash][optionHash].value;
    }
}