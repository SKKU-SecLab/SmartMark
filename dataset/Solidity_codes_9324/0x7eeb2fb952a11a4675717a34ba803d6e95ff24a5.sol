
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


interface IMessageProxy {


    struct Message {
        address sender;
        address destinationContract;
        bytes data;
    }

    struct Signature {
        uint256[2] blsSignature;
        uint256 hashA;
        uint256 hashB;
        uint256 counter;
    }

    function addConnectedChain(string calldata schainName) external;

    function postIncomingMessages(
        string calldata fromSchainName,
        uint256 startingCounter,
        Message[] calldata messages,
        Signature calldata sign
    ) external;

    function setNewGasLimit(uint256 newGasLimit) external;

    function registerExtraContractForAll(address extraContract) external;

    function removeExtraContractForAll(address extraContract) external;    

    function removeConnectedChain(string memory schainName) external;

    function postOutgoingMessage(
        bytes32 targetChainHash,
        address targetContract,
        bytes memory data
    ) external;

    function registerExtraContract(string memory chainName, address extraContract) external;

    function removeExtraContract(string memory schainName, address extraContract) external;

    function setVersion(string calldata newVersion) external;

    function isContractRegistered(
        bytes32 schainHash,
        address contractAddress
    ) external view returns (bool);

    function getContractRegisteredLength(bytes32 schainHash) external view returns (uint256);

    function getContractRegisteredRange(
        bytes32 schainHash,
        uint256 from,
        uint256 to
    )
        external
        view
        returns (address[] memory);

    function getOutgoingMessagesCounter(string calldata targetSchainName) external view returns (uint256);

    function getIncomingMessagesCounter(string calldata fromSchainName) external view returns (uint256);

    function isConnectedChain(string memory schainName) external view returns (bool);

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



interface ISkaleManagerClient {

    function initialize(IContractManager newContractManagerOfSkaleManager) external;

    function isSchainOwner(address sender, bytes32 schainHash) external view returns (bool);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;


interface ITwin is ISkaleManagerClient {

    function addSchainContract(string calldata schainName, address contractReceiver) external;

    function removeSchainContract(string calldata schainName) external;

    function hasSchainContract(string calldata schainName) external view returns (bool);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;



interface ILinker is ITwin {

    function registerMainnetContract(address newMainnetContract) external;

    function removeMainnetContract(address mainnetContract) external;

    function connectSchain(string calldata schainName, address[] calldata schainContracts) external;

    function kill(string calldata schainName) external;

    function disconnectSchain(string calldata schainName) external;

    function isNotKilled(bytes32 schainHash) external view returns (bool);

    function hasMainnetContract(address mainnetContract) external view returns (bool);

    function hasSchain(string calldata schainName) external view returns (bool connected);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;





interface ICommunityPool is ITwin {

    function initialize(
        IContractManager contractManagerOfSkaleManagerValue,
        ILinker linker,
        IMessageProxyForMainnet messageProxyValue
    ) external;

    function refundGasByUser(bytes32 schainHash, address payable node, address user, uint gas) external returns (uint);

    function rechargeUserWallet(string calldata schainName, address user) external payable;

    function withdrawFunds(string calldata schainName, uint amount) external;

    function setMinTransactionGas(uint newMinTransactionGas) external;    

    function refundGasBySchainWallet(
        bytes32 schainHash,
        address payable node,
        uint gas
    ) external returns (bool);

    function getBalance(address user, string calldata schainName) external view returns (uint);

    function checkUserBalance(bytes32 schainHash, address receiver) external view returns (bool);

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;


interface IMessageProxyForMainnet is IMessageProxy {

    function setCommunityPool(ICommunityPool newCommunityPoolAddress) external;

    function setNewHeaderMessageGasCost(uint256 newHeaderMessageGasCost) external;

    function setNewMessageGasCost(uint256 newMessageGasCost) external;

    function messageInProgress() external view returns (bool);

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

}// MIT

pragma solidity ^0.8.0;

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;


interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
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


abstract contract AccessControlEnumerableUpgradeable is Initializable, IAccessControlEnumerableUpgradeable, AccessControlUpgradeable {
    function __AccessControlEnumerable_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function __AccessControlEnumerable_init_unchained() internal initializer {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override(AccessControlUpgradeable, IAccessControlUpgradeable) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override(AccessControlUpgradeable, IAccessControlUpgradeable) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override(AccessControlUpgradeable, IAccessControlUpgradeable) {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
    uint256[49] private __gap;
}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;


interface IMessageReceiver {

    function postMessage(
        bytes32 schainHash,
        address sender,
        bytes calldata data
    )
        external;

}// AGPL-3.0-only


pragma solidity >=0.6.10 <0.9.0;



interface IGasReimbursable is IMessageReceiver {

    function gasPayer(
        bytes32 schainHash,
        address sender,
        bytes calldata data
    )
        external
        returns (address);

}// AGPL-3.0-only


pragma solidity 0.8.6;



abstract contract MessageProxy is AccessControlEnumerableUpgradeable, IMessageProxy {
    using AddressUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    struct ConnectedChainInfo {
        uint256 incomingMessageCounter;
        uint256 outgoingMessageCounter;
        bool inited;
    }

    bytes32 public constant MAINNET_HASH = keccak256(abi.encodePacked("Mainnet"));
    bytes32 public constant CHAIN_CONNECTOR_ROLE = keccak256("CHAIN_CONNECTOR_ROLE");
    bytes32 public constant EXTRA_CONTRACT_REGISTRAR_ROLE = keccak256("EXTRA_CONTRACT_REGISTRAR_ROLE");
    bytes32 public constant CONSTANT_SETTER_ROLE = keccak256("CONSTANT_SETTER_ROLE");
    uint256 public constant MESSAGES_LENGTH = 10;
    uint256 public constant REVERT_REASON_LENGTH = 64;

    mapping(bytes32 => ConnectedChainInfo) public connectedChains;
    mapping(bytes32 => mapping(address => bool)) internal deprecatedRegistryContracts;

    uint256 public gasLimit;

    event OutgoingMessage(
        bytes32 indexed dstChainHash,
        uint256 indexed msgCounter,
        address indexed srcContract,
        address dstContract,
        bytes data
    );

    event PostMessageError(
        uint256 indexed msgCounter,
        bytes message
    );

    event GasLimitWasChanged(
        uint256 oldValue,
        uint256 newValue
    );

    event VersionUpdated(string oldVersion, string newVersion);

    event ExtraContractRegistered(
        bytes32 indexed chainHash,
        address contractAddress
    );

    event ExtraContractRemoved(
        bytes32 indexed chainHash,
        address contractAddress
    );

    modifier onlyChainConnector() {
        require(hasRole(CHAIN_CONNECTOR_ROLE, msg.sender), "CHAIN_CONNECTOR_ROLE is required");
        _;
    }

    modifier onlyExtraContractRegistrar() {
        require(hasRole(EXTRA_CONTRACT_REGISTRAR_ROLE, msg.sender), "EXTRA_CONTRACT_REGISTRAR_ROLE is required");
        _;
    }

    modifier onlyConstantSetter() {
        require(hasRole(CONSTANT_SETTER_ROLE, msg.sender), "Not enough permissions to set constant");
        _;
    }    

    function setNewGasLimit(uint256 newGasLimit) external override onlyConstantSetter {
        emit GasLimitWasChanged(gasLimit, newGasLimit);
        gasLimit = newGasLimit;
    }

    function postIncomingMessages(
        string calldata fromSchainName,
        uint256 startingCounter,
        Message[] calldata messages,
        Signature calldata sign
    )
        external
        virtual
        override;

    function registerExtraContractForAll(address extraContract) external override onlyExtraContractRegistrar {
        require(extraContract.isContract(), "Given address is not a contract");
        require(!_getRegistryContracts()[bytes32(0)].contains(extraContract), "Extra contract is already registered");
        _getRegistryContracts()[bytes32(0)].add(extraContract);
        emit ExtraContractRegistered(bytes32(0), extraContract);
    }

    function removeExtraContractForAll(address extraContract) external override onlyExtraContractRegistrar {
        require(_getRegistryContracts()[bytes32(0)].contains(extraContract), "Extra contract is not registered");
        _getRegistryContracts()[bytes32(0)].remove(extraContract);
        emit ExtraContractRemoved(bytes32(0), extraContract);
    }

    function getContractRegisteredLength(bytes32 schainHash) external view override returns (uint256) {
        return _getRegistryContracts()[schainHash].length();
    }

    function getContractRegisteredRange(
        bytes32 schainHash,
        uint256 from,
        uint256 to
    )
        external
        view
        override
        returns (address[] memory contractsInRange)
    {
        require(
            from < to && to - from <= 10 && to <= _getRegistryContracts()[schainHash].length(),
            "Range is incorrect"
        );
        contractsInRange = new address[](to - from);
        for (uint256 i = from; i < to; i++) {
            contractsInRange[i - from] = _getRegistryContracts()[schainHash].at(i);
        }
    }

    function getOutgoingMessagesCounter(string calldata targetSchainName)
        external
        view
        override
        returns (uint256)
    {
        bytes32 dstChainHash = keccak256(abi.encodePacked(targetSchainName));
        require(connectedChains[dstChainHash].inited, "Destination chain is not initialized");
        return connectedChains[dstChainHash].outgoingMessageCounter;
    }

    function getIncomingMessagesCounter(string calldata fromSchainName)
        external
        view
        override
        returns (uint256)
    {
        bytes32 srcChainHash = keccak256(abi.encodePacked(fromSchainName));
        require(connectedChains[srcChainHash].inited, "Source chain is not initialized");
        return connectedChains[srcChainHash].incomingMessageCounter;
    }

    function initializeMessageProxy(uint newGasLimit) public initializer {
        AccessControlEnumerableUpgradeable.__AccessControlEnumerable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CHAIN_CONNECTOR_ROLE, msg.sender);
        _setupRole(EXTRA_CONTRACT_REGISTRAR_ROLE, msg.sender);
        _setupRole(CONSTANT_SETTER_ROLE, msg.sender);
        gasLimit = newGasLimit;
    }

    function postOutgoingMessage(
        bytes32 targetChainHash,
        address targetContract,
        bytes memory data
    )
        public
        override
        virtual
    {
        require(connectedChains[targetChainHash].inited, "Destination chain is not initialized");
        _authorizeOutgoingMessageSender(targetChainHash);
        
        emit OutgoingMessage(
            targetChainHash,
            connectedChains[targetChainHash].outgoingMessageCounter,
            msg.sender,
            targetContract,
            data
        );

        connectedChains[targetChainHash].outgoingMessageCounter += 1;
    }

    function removeConnectedChain(string memory schainName) public virtual override onlyChainConnector {
        bytes32 schainHash = keccak256(abi.encodePacked(schainName));
        require(connectedChains[schainHash].inited, "Chain is not initialized");
        delete connectedChains[schainHash];
    }    

    function isConnectedChain(
        string memory schainName
    )
        public
        view
        virtual
        override
        returns (bool)
    {
        return connectedChains[keccak256(abi.encodePacked(schainName))].inited;
    }

    function isContractRegistered(
        bytes32 schainHash,
        address contractAddress
    )
        public
        view
        override
        returns (bool)
    {
        return _getRegistryContracts()[schainHash].contains(contractAddress);
    }

    function _registerExtraContract(
        bytes32 chainHash,
        address extraContract
    )
        internal
    {      
        require(extraContract.isContract(), "Given address is not a contract");
        require(!_getRegistryContracts()[chainHash].contains(extraContract), "Extra contract is already registered");
        require(
            !_getRegistryContracts()[bytes32(0)].contains(extraContract),
            "Extra contract is already registered for all chains"
        );
        
        _getRegistryContracts()[chainHash].add(extraContract);
        emit ExtraContractRegistered(chainHash, extraContract);
    }

    function _removeExtraContract(
        bytes32 chainHash,
        address extraContract
    )
        internal
    {
        require(_getRegistryContracts()[chainHash].contains(extraContract), "Extra contract is not registered");
        _getRegistryContracts()[chainHash].remove(extraContract);
        emit ExtraContractRemoved(chainHash, extraContract);
    }

    function _addConnectedChain(bytes32 schainHash) internal onlyChainConnector {
        require(!connectedChains[schainHash].inited,"Chain is already connected");
        connectedChains[schainHash] = ConnectedChainInfo({
            incomingMessageCounter: 0,
            outgoingMessageCounter: 0,
            inited: true
        });
    }

    function _callReceiverContract(
        bytes32 schainHash,
        Message calldata message,
        uint counter
    )
        internal
    {
        if (!message.destinationContract.isContract()) {
            emit PostMessageError(
                counter,
                "Destination contract is not a contract"
            );
            return;
        }
        try IMessageReceiver(message.destinationContract).postMessage{gas: gasLimit}(
            schainHash,
            message.sender,
            message.data
        ) {
            return;
        } catch Error(string memory reason) {
            emit PostMessageError(
                counter,
                _getSlice(bytes(reason), REVERT_REASON_LENGTH)
            );
        } catch Panic(uint errorCode) {
               emit PostMessageError(
                counter,
                abi.encodePacked(errorCode)
            );
        } catch (bytes memory revertData) {
            emit PostMessageError(
                counter,
                _getSlice(revertData, REVERT_REASON_LENGTH)
            );
        }
    }

    function _getGasPayer(
        bytes32 schainHash,
        Message calldata message,
        uint counter
    )
        internal
        returns (address)
    {
        try IGasReimbursable(message.destinationContract).gasPayer{gas: gasLimit}(
            schainHash,
            message.sender,
            message.data
        ) returns (address receiver) {
            return receiver;
        } catch Error(string memory reason) {
            emit PostMessageError(
                counter,
                _getSlice(bytes(reason), REVERT_REASON_LENGTH)
            );
            return address(0);
        } catch Panic(uint errorCode) {
               emit PostMessageError(
                counter,
                abi.encodePacked(errorCode)
            );
            return address(0);
        } catch (bytes memory revertData) {
            emit PostMessageError(
                counter,
                _getSlice(revertData, REVERT_REASON_LENGTH)
            );
            return address(0);
        }
    }

    function _authorizeOutgoingMessageSender(bytes32 targetChainHash) internal view virtual {
        require(
            isContractRegistered(bytes32(0), msg.sender) || isContractRegistered(targetChainHash, msg.sender),
            "Sender contract is not registered"
        );        
    }

    function _getRegistryContracts()
        internal
        view
        virtual
        returns (mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) storage);

    function _hashedArray(
        Message[] calldata messages,
        uint256 startingCounter,
        string calldata fromChainName
    )
        internal
        pure
        returns (bytes32)
    {
        bytes32 sourceHash = keccak256(abi.encodePacked(fromChainName));
        bytes32 hash = keccak256(abi.encodePacked(sourceHash, bytes32(startingCounter)));
        for (uint256 i = 0; i < messages.length; i++) {
            hash = keccak256(
                abi.encodePacked(
                    abi.encode(
                        hash,
                        messages[i].sender,
                        messages[i].destinationContract
                    ),
                    messages[i].data
                )
            );
        }
        return hash;
    }

    function _getSlice(bytes memory text, uint end) private pure returns (bytes memory) {
        uint slicedEnd = end < text.length ? end : text.length;
        bytes memory sliced = new bytes(slicedEnd);
        for(uint i = 0; i < slicedEnd; i++){
            sliced[i] = text[i];
        }
        return sliced;    
    }
}// AGPL-3.0-only


pragma solidity 0.8.6;



contract SkaleManagerClient is Initializable, AccessControlEnumerableUpgradeable, ISkaleManagerClient {


    IContractManager public contractManagerOfSkaleManager;

    modifier onlySchainOwner(string memory schainName) {

        require(
            isSchainOwner(msg.sender, keccak256(abi.encodePacked(schainName))),
            "Sender is not an Schain owner"
        );
        _;
    }

    function initialize(
        IContractManager newContractManagerOfSkaleManager
    )
        public
        override
        virtual
        initializer
    {

        AccessControlEnumerableUpgradeable.__AccessControlEnumerable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        contractManagerOfSkaleManager = newContractManagerOfSkaleManager;
    }

    function isSchainOwner(address sender, bytes32 schainHash) public view override returns (bool) {

        address skaleChainsInternal = contractManagerOfSkaleManager.getContract("SchainsInternal");
        return ISchainsInternal(skaleChainsInternal).isOwnerAddress(sender, schainHash);
    }
}// AGPL-3.0-only


pragma solidity 0.8.6;


library Messages {


    enum MessageType {
        EMPTY,
        TRANSFER_ETH,
        TRANSFER_ERC20,
        TRANSFER_ERC20_AND_TOTAL_SUPPLY,
        TRANSFER_ERC20_AND_TOKEN_INFO,
        TRANSFER_ERC721,
        TRANSFER_ERC721_AND_TOKEN_INFO,
        USER_STATUS,
        INTERCHAIN_CONNECTION,
        TRANSFER_ERC1155,
        TRANSFER_ERC1155_AND_TOKEN_INFO,
        TRANSFER_ERC1155_BATCH,
        TRANSFER_ERC1155_BATCH_AND_TOKEN_INFO,
        TRANSFER_ERC721_WITH_METADATA,
        TRANSFER_ERC721_WITH_METADATA_AND_TOKEN_INFO
    }

    struct BaseMessage {
        MessageType messageType;
    }

    struct TransferEthMessage {
        BaseMessage message;
        address receiver;
        uint256 amount;
    }

    struct UserStatusMessage {
        BaseMessage message;
        address receiver;
        bool isActive;
    }

    struct TransferErc20Message {
        BaseMessage message;
        address token;
        address receiver;
        uint256 amount;
    }

    struct Erc20TokenInfo {
        string name;
        uint8 decimals;
        string symbol;
    }

    struct TransferErc20AndTotalSupplyMessage {
        TransferErc20Message baseErc20transfer;
        uint256 totalSupply;
    }

    struct TransferErc20AndTokenInfoMessage {
        TransferErc20Message baseErc20transfer;
        uint256 totalSupply;
        Erc20TokenInfo tokenInfo;
    }

    struct TransferErc721Message {
        BaseMessage message;
        address token;
        address receiver;
        uint256 tokenId;
    }

    struct TransferErc721MessageWithMetadata {
        TransferErc721Message erc721message;
        string tokenURI;
    }

    struct Erc721TokenInfo {
        string name;
        string symbol;
    }

    struct TransferErc721AndTokenInfoMessage {
        TransferErc721Message baseErc721transfer;
        Erc721TokenInfo tokenInfo;
    }

    struct TransferErc721WithMetadataAndTokenInfoMessage {
        TransferErc721MessageWithMetadata baseErc721transferWithMetadata;
        Erc721TokenInfo tokenInfo;
    }

    struct InterchainConnectionMessage {
        BaseMessage message;
        bool isAllowed;
    }

    struct TransferErc1155Message {
        BaseMessage message;
        address token;
        address receiver;
        uint256 id;
        uint256 amount;
    }

    struct TransferErc1155BatchMessage {
        BaseMessage message;
        address token;
        address receiver;
        uint256[] ids;
        uint256[] amounts;
    }

    struct Erc1155TokenInfo {
        string uri;
    }

    struct TransferErc1155AndTokenInfoMessage {
        TransferErc1155Message baseErc1155transfer;
        Erc1155TokenInfo tokenInfo;
    }

    struct TransferErc1155BatchAndTokenInfoMessage {
        TransferErc1155BatchMessage baseErc1155Batchtransfer;
        Erc1155TokenInfo tokenInfo;
    }


    function getMessageType(bytes calldata data) internal pure returns (MessageType) {

        uint256 firstWord = abi.decode(data, (uint256));
        if (firstWord % 32 == 0) {
            return getMessageType(data[firstWord:]);
        } else {
            return abi.decode(data, (Messages.MessageType));
        }
    }

    function encodeTransferEthMessage(address receiver, uint256 amount) internal pure returns (bytes memory) {

        TransferEthMessage memory message = TransferEthMessage(
            BaseMessage(MessageType.TRANSFER_ETH),
            receiver,
            amount
        );
        return abi.encode(message);
    }

    function decodeTransferEthMessage(
        bytes calldata data
    ) internal pure returns (TransferEthMessage memory) {

        require(getMessageType(data) == MessageType.TRANSFER_ETH, "Message type is not ETH transfer");
        return abi.decode(data, (TransferEthMessage));
    }

    function encodeTransferErc20Message(
        address token,
        address receiver,
        uint256 amount
    ) internal pure returns (bytes memory) {

        TransferErc20Message memory message = TransferErc20Message(
            BaseMessage(MessageType.TRANSFER_ERC20),
            token,
            receiver,
            amount
        );
        return abi.encode(message);
    }

    function encodeTransferErc20AndTotalSupplyMessage(
        address token,
        address receiver,
        uint256 amount,
        uint256 totalSupply
    ) internal pure returns (bytes memory) {

        TransferErc20AndTotalSupplyMessage memory message = TransferErc20AndTotalSupplyMessage(
            TransferErc20Message(
                BaseMessage(MessageType.TRANSFER_ERC20_AND_TOTAL_SUPPLY),
                token,
                receiver,
                amount
            ),
            totalSupply
        );
        return abi.encode(message);
    }

    function decodeTransferErc20Message(
        bytes calldata data
    ) internal pure returns (TransferErc20Message memory) {

        require(getMessageType(data) == MessageType.TRANSFER_ERC20, "Message type is not ERC20 transfer");
        return abi.decode(data, (TransferErc20Message));
    }

    function decodeTransferErc20AndTotalSupplyMessage(
        bytes calldata data
    ) internal pure returns (TransferErc20AndTotalSupplyMessage memory) {

        require(
            getMessageType(data) == MessageType.TRANSFER_ERC20_AND_TOTAL_SUPPLY,
            "Message type is not ERC20 transfer and total supply"
        );
        return abi.decode(data, (TransferErc20AndTotalSupplyMessage));
    }

    function encodeTransferErc20AndTokenInfoMessage(
        address token,
        address receiver,
        uint256 amount,
        uint256 totalSupply,
        Erc20TokenInfo memory tokenInfo
    ) internal pure returns (bytes memory) {

        TransferErc20AndTokenInfoMessage memory message = TransferErc20AndTokenInfoMessage(
            TransferErc20Message(
                BaseMessage(MessageType.TRANSFER_ERC20_AND_TOKEN_INFO),
                token,
                receiver,
                amount
            ),
            totalSupply,
            tokenInfo
        );
        return abi.encode(message);
    }

    function decodeTransferErc20AndTokenInfoMessage(
        bytes calldata data
    ) internal pure returns (TransferErc20AndTokenInfoMessage memory) {

        require(
            getMessageType(data) == MessageType.TRANSFER_ERC20_AND_TOKEN_INFO,
            "Message type is not ERC20 transfer with token info"
        );
        return abi.decode(data, (TransferErc20AndTokenInfoMessage));
    }

    function encodeTransferErc721Message(
        address token,
        address receiver,
        uint256 tokenId
    ) internal pure returns (bytes memory) {

        TransferErc721Message memory message = TransferErc721Message(
            BaseMessage(MessageType.TRANSFER_ERC721),
            token,
            receiver,
            tokenId
        );
        return abi.encode(message);
    }

    function decodeTransferErc721Message(
        bytes calldata data
    ) internal pure returns (TransferErc721Message memory) {

        require(getMessageType(data) == MessageType.TRANSFER_ERC721, "Message type is not ERC721 transfer");
        return abi.decode(data, (TransferErc721Message));
    }

    function encodeTransferErc721AndTokenInfoMessage(
        address token,
        address receiver,
        uint256 tokenId,
        Erc721TokenInfo memory tokenInfo
    ) internal pure returns (bytes memory) {

        TransferErc721AndTokenInfoMessage memory message = TransferErc721AndTokenInfoMessage(
            TransferErc721Message(
                BaseMessage(MessageType.TRANSFER_ERC721_AND_TOKEN_INFO),
                token,
                receiver,
                tokenId
            ),
            tokenInfo
        );
        return abi.encode(message);
    }

    function decodeTransferErc721AndTokenInfoMessage(
        bytes calldata data
    ) internal pure returns (TransferErc721AndTokenInfoMessage memory) {

        require(
            getMessageType(data) == MessageType.TRANSFER_ERC721_AND_TOKEN_INFO,
            "Message type is not ERC721 transfer with token info"
        );
        return abi.decode(data, (TransferErc721AndTokenInfoMessage));
    }

    function encodeTransferErc721MessageWithMetadata(
        address token,
        address receiver,
        uint256 tokenId,
        string memory tokenURI
    ) internal pure returns (bytes memory) {

        TransferErc721MessageWithMetadata memory message = TransferErc721MessageWithMetadata(
            TransferErc721Message(
                BaseMessage(MessageType.TRANSFER_ERC721_WITH_METADATA),
                token,
                receiver,
                tokenId
            ),
            tokenURI
        );
        return abi.encode(message);
    }

    function decodeTransferErc721MessageWithMetadata(
        bytes calldata data
    ) internal pure returns (TransferErc721MessageWithMetadata memory) {

        require(
            getMessageType(data) == MessageType.TRANSFER_ERC721_WITH_METADATA,
            "Message type is not ERC721 transfer"
        );
        return abi.decode(data, (TransferErc721MessageWithMetadata));
    }

    function encodeTransferErc721WithMetadataAndTokenInfoMessage(
        address token,
        address receiver,
        uint256 tokenId,
        string memory tokenURI,
        Erc721TokenInfo memory tokenInfo
    ) internal pure returns (bytes memory) {

        TransferErc721WithMetadataAndTokenInfoMessage memory message = TransferErc721WithMetadataAndTokenInfoMessage(
            TransferErc721MessageWithMetadata(
                TransferErc721Message(
                    BaseMessage(MessageType.TRANSFER_ERC721_WITH_METADATA_AND_TOKEN_INFO),
                    token,
                    receiver,
                    tokenId
                ),
                tokenURI
            ),
            tokenInfo
        );
        return abi.encode(message);
    }

    function decodeTransferErc721WithMetadataAndTokenInfoMessage(
        bytes calldata data
    ) internal pure returns (TransferErc721WithMetadataAndTokenInfoMessage memory) {

        require(
            getMessageType(data) == MessageType.TRANSFER_ERC721_WITH_METADATA_AND_TOKEN_INFO,
            "Message type is not ERC721 transfer with token info"
        );
        return abi.decode(data, (TransferErc721WithMetadataAndTokenInfoMessage));
    }

    function encodeActivateUserMessage(address receiver) internal pure returns (bytes memory){

        return _encodeUserStatusMessage(receiver, true);
    }

    function encodeLockUserMessage(address receiver) internal pure returns (bytes memory){

        return _encodeUserStatusMessage(receiver, false);
    }

    function decodeUserStatusMessage(bytes calldata data) internal pure returns (UserStatusMessage memory) {

        require(getMessageType(data) == MessageType.USER_STATUS, "Message type is not User Status");
        return abi.decode(data, (UserStatusMessage));
    }


    function encodeInterchainConnectionMessage(bool isAllowed) internal pure returns (bytes memory) {

        InterchainConnectionMessage memory message = InterchainConnectionMessage(
            BaseMessage(MessageType.INTERCHAIN_CONNECTION),
            isAllowed
        );
        return abi.encode(message);
    }

    function decodeInterchainConnectionMessage(bytes calldata data)
        internal
        pure
        returns (InterchainConnectionMessage memory)
    {

        require(getMessageType(data) == MessageType.INTERCHAIN_CONNECTION, "Message type is not Interchain connection");
        return abi.decode(data, (InterchainConnectionMessage));
    }

    function encodeTransferErc1155Message(
        address token,
        address receiver,
        uint256 id,
        uint256 amount
    ) internal pure returns (bytes memory) {

        TransferErc1155Message memory message = TransferErc1155Message(
            BaseMessage(MessageType.TRANSFER_ERC1155),
            token,
            receiver,
            id,
            amount
        );
        return abi.encode(message);
    }

    function decodeTransferErc1155Message(
        bytes calldata data
    ) internal pure returns (TransferErc1155Message memory) {

        require(getMessageType(data) == MessageType.TRANSFER_ERC1155, "Message type is not ERC1155 transfer");
        return abi.decode(data, (TransferErc1155Message));
    }

    function encodeTransferErc1155AndTokenInfoMessage(
        address token,
        address receiver,
        uint256 id,
        uint256 amount,
        Erc1155TokenInfo memory tokenInfo
    ) internal pure returns (bytes memory) {

        TransferErc1155AndTokenInfoMessage memory message = TransferErc1155AndTokenInfoMessage(
            TransferErc1155Message(
                BaseMessage(MessageType.TRANSFER_ERC1155_AND_TOKEN_INFO),
                token,
                receiver,
                id,
                amount
            ),
            tokenInfo
        );
        return abi.encode(message);
    }

    function decodeTransferErc1155AndTokenInfoMessage(
        bytes calldata data
    ) internal pure returns (TransferErc1155AndTokenInfoMessage memory) {

        require(
            getMessageType(data) == MessageType.TRANSFER_ERC1155_AND_TOKEN_INFO,
            "Message type is not ERC1155AndTokenInfo transfer"
        );
        return abi.decode(data, (TransferErc1155AndTokenInfoMessage));
    }

    function encodeTransferErc1155BatchMessage(
        address token,
        address receiver,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal pure returns (bytes memory) {

        TransferErc1155BatchMessage memory message = TransferErc1155BatchMessage(
            BaseMessage(MessageType.TRANSFER_ERC1155_BATCH),
            token,
            receiver,
            ids,
            amounts
        );
        return abi.encode(message);
    }

    function decodeTransferErc1155BatchMessage(
        bytes calldata data
    ) internal pure returns (TransferErc1155BatchMessage memory) {

        require(
            getMessageType(data) == MessageType.TRANSFER_ERC1155_BATCH,
            "Message type is not ERC1155Batch transfer"
        );
        return abi.decode(data, (TransferErc1155BatchMessage));
    }

    function encodeTransferErc1155BatchAndTokenInfoMessage(
        address token,
        address receiver,
        uint256[] memory ids,
        uint256[] memory amounts,
        Erc1155TokenInfo memory tokenInfo
    ) internal pure returns (bytes memory) {

        TransferErc1155BatchAndTokenInfoMessage memory message = TransferErc1155BatchAndTokenInfoMessage(
            TransferErc1155BatchMessage(
                BaseMessage(MessageType.TRANSFER_ERC1155_BATCH_AND_TOKEN_INFO),
                token,
                receiver,
                ids,
                amounts
            ),
            tokenInfo
        );
        return abi.encode(message);
    }

    function decodeTransferErc1155BatchAndTokenInfoMessage(
        bytes calldata data
    ) internal pure returns (TransferErc1155BatchAndTokenInfoMessage memory) {

        require(
            getMessageType(data) == MessageType.TRANSFER_ERC1155_BATCH_AND_TOKEN_INFO,
            "Message type is not ERC1155BatchAndTokenInfo transfer"
        );
        return abi.decode(data, (TransferErc1155BatchAndTokenInfoMessage));
    }

    function _encodeUserStatusMessage(address receiver, bool isActive) private pure returns (bytes memory) {

        UserStatusMessage memory message = UserStatusMessage(
            BaseMessage(MessageType.USER_STATUS),
            receiver,
            isActive
        );
        return abi.encode(message);
    }

}// AGPL-3.0-only


pragma solidity 0.8.6;



abstract contract Twin is SkaleManagerClient, ITwin {

    IMessageProxyForMainnet public messageProxy;
    mapping(bytes32 => address) public schainLinks;
    bytes32 public constant LINKER_ROLE = keccak256("LINKER_ROLE");

    modifier onlyMessageProxy() {
        require(msg.sender == address(messageProxy), "Sender is not a MessageProxy");
        _;
    }

    function addSchainContract(string calldata schainName, address contractReceiver) external override {
        bytes32 schainHash = keccak256(abi.encodePacked(schainName));
        require(
            hasRole(LINKER_ROLE, msg.sender) ||
            isSchainOwner(msg.sender, schainHash), "Not authorized caller"
        );
        require(schainLinks[schainHash] == address(0), "SKALE chain is already set");
        require(contractReceiver != address(0), "Incorrect address of contract receiver on Schain");
        schainLinks[schainHash] = contractReceiver;
    }

    function removeSchainContract(string calldata schainName) external override {
        bytes32 schainHash = keccak256(abi.encodePacked(schainName));
        require(
            hasRole(LINKER_ROLE, msg.sender) ||
            isSchainOwner(msg.sender, schainHash), "Not authorized caller"
        );
        require(schainLinks[schainHash] != address(0), "SKALE chain is not set");
        delete schainLinks[schainHash];
    }

    function hasSchainContract(string calldata schainName) external view override returns (bool) {
        return schainLinks[keccak256(abi.encodePacked(schainName))] != address(0);
    }
    
    function initialize(
        IContractManager contractManagerOfSkaleManagerValue,
        IMessageProxyForMainnet newMessageProxy
    )
        public
        virtual
        initializer
    {
        SkaleManagerClient.initialize(contractManagerOfSkaleManagerValue);
        messageProxy = newMessageProxy;
    }
}// AGPL-3.0-only


pragma solidity 0.8.6;




contract CommunityPool is Twin, ICommunityPool {


    using AddressUpgradeable for address payable;

    bytes32 public constant CONSTANT_SETTER_ROLE = keccak256("CONSTANT_SETTER_ROLE");

    mapping(address => mapping(bytes32 => uint)) private _userWallets;

    mapping(address => mapping(bytes32 => bool)) public activeUsers;

    uint public minTransactionGas;    

    event MinTransactionGasWasChanged(
        uint oldValue,
        uint newValue
    );

    function initialize(
        IContractManager contractManagerOfSkaleManagerValue,
        ILinker linker,
        IMessageProxyForMainnet messageProxyValue
    )
        external
        override
        initializer
    {

        Twin.initialize(contractManagerOfSkaleManagerValue, messageProxyValue);
        _setupRole(LINKER_ROLE, address(linker));
        minTransactionGas = 1e6;
    }

    function refundGasByUser(
        bytes32 schainHash,
        address payable node,
        address user,
        uint gas
    )
        external
        override
        onlyMessageProxy
        returns (uint)
    {

        require(node != address(0), "Node address must be set");
        if (!activeUsers[user][schainHash]) {
            return gas;
        }
        uint amount = tx.gasprice * gas;
        if (amount > _userWallets[user][schainHash]) {
            amount = _userWallets[user][schainHash];
        }
        _userWallets[user][schainHash] = _userWallets[user][schainHash] - amount;
        if (!_balanceIsSufficient(schainHash, user, 0)) {
            activeUsers[user][schainHash] = false;
            messageProxy.postOutgoingMessage(
                schainHash,
                schainLinks[schainHash],
                Messages.encodeLockUserMessage(user)
            );
        }
        node.sendValue(amount);
        return (tx.gasprice * gas - amount) / tx.gasprice;
    }

    function refundGasBySchainWallet(
        bytes32 schainHash,
        address payable node,
        uint gas
    )
        external
        override
        onlyMessageProxy
        returns (bool)
    {

        if (gas > 0) {
            IWallets(payable(contractManagerOfSkaleManager.getContract("Wallets"))).refundGasBySchain(
                schainHash,
                node,
                gas,
                false
            );
        }
        return true;
    }

    function rechargeUserWallet(string calldata schainName, address user) external payable override {

        bytes32 schainHash = keccak256(abi.encodePacked(schainName));
        require(
            _balanceIsSufficient(schainHash, user, msg.value),
            "Not enough ETH for transaction"
        );
        _userWallets[user][schainHash] = _userWallets[user][schainHash] + msg.value;
        if (!activeUsers[user][schainHash]) {
            activeUsers[user][schainHash] = true;
            messageProxy.postOutgoingMessage(
                schainHash,
                schainLinks[schainHash],
                Messages.encodeActivateUserMessage(user)
            );
        }
    }

    function withdrawFunds(string calldata schainName, uint amount) external override {

        bytes32 schainHash = keccak256(abi.encodePacked(schainName));
        require(amount <= _userWallets[msg.sender][schainHash], "Balance is too low");
        require(!messageProxy.messageInProgress(), "Message is in progress");
        _userWallets[msg.sender][schainHash] = _userWallets[msg.sender][schainHash] - amount;
        if (
            !_balanceIsSufficient(schainHash, msg.sender, 0) &&
            activeUsers[msg.sender][schainHash]
        ) {
            activeUsers[msg.sender][schainHash] = false;
            messageProxy.postOutgoingMessage(
                schainHash,
                schainLinks[schainHash],
                Messages.encodeLockUserMessage(msg.sender)
            );
        }
        payable(msg.sender).sendValue(amount);
    }

    function setMinTransactionGas(uint newMinTransactionGas) external override {

        require(hasRole(CONSTANT_SETTER_ROLE, msg.sender), "CONSTANT_SETTER_ROLE is required");
        emit MinTransactionGasWasChanged(minTransactionGas, newMinTransactionGas);
        minTransactionGas = newMinTransactionGas;
    }

    function getBalance(address user, string calldata schainName) external view override returns (uint) {

        return _userWallets[user][keccak256(abi.encodePacked(schainName))];
    }

    function checkUserBalance(bytes32 schainHash, address receiver) external view override returns (bool) {

        return activeUsers[receiver][schainHash] && _balanceIsSufficient(schainHash, receiver, 0);
    }
    function _balanceIsSufficient(bytes32 schainHash, address receiver, uint256 delta) private view returns (bool) {

        return delta + _userWallets[receiver][schainHash] >= minTransactionGas * tx.gasprice;
    } 
}// AGPL-3.0-only


pragma solidity 0.8.6;




interface IMessageProxyForMainnetInitializeFunction is IMessageProxyForMainnet {

    function initializeAllRegisteredContracts(
        bytes32 schainHash,
        address[] calldata contracts
    ) external;

}


contract MessageProxyForMainnet is SkaleManagerClient, MessageProxy, IMessageProxyForMainnetInitializeFunction {


    using AddressUpgradeable for address;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;


    ICommunityPool public communityPool;

    uint256 public headerMessageGasCost;
    uint256 public messageGasCost;
    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _registryContracts;
    string public version;
    bool public override messageInProgress;

    event GasCostMessageHeaderWasChanged(
        uint256 oldValue,
        uint256 newValue
    );

    event GasCostMessageWasChanged(
        uint256 oldValue,
        uint256 newValue
    );

    modifier messageInProgressLocker() {

        require(!messageInProgress, "Message is in progress");
        messageInProgress = true;
        _;
        messageInProgress = false;
    }

    function initializeAllRegisteredContracts(
        bytes32 schainHash,
        address[] calldata contracts
    ) external override {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Sender is not authorized");
        for (uint256 i = 0; i < contracts.length; i++) {
            if (
                deprecatedRegistryContracts[schainHash][contracts[i]] &&
                !_registryContracts[schainHash].contains(contracts[i])
            ) {
                _registryContracts[schainHash].add(contracts[i]);
                delete deprecatedRegistryContracts[schainHash][contracts[i]];
            }
        }
    }

    function addConnectedChain(string calldata schainName) external override {

        bytes32 schainHash = keccak256(abi.encodePacked(schainName));
        require(ISchainsInternal(
            contractManagerOfSkaleManager.getContract("SchainsInternal")
        ).isSchainExist(schainHash), "SKALE chain must exist");
        _addConnectedChain(schainHash);
    }

    function setCommunityPool(ICommunityPool newCommunityPoolAddress) external override {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Not authorized caller");
        require(address(newCommunityPoolAddress) != address(0), "CommunityPool address has to be set");
        communityPool = newCommunityPoolAddress;
    }

    function registerExtraContract(string memory schainName, address extraContract) external override {

        bytes32 schainHash = keccak256(abi.encodePacked(schainName));
        require(
            hasRole(EXTRA_CONTRACT_REGISTRAR_ROLE, msg.sender) ||
            isSchainOwner(msg.sender, schainHash),
            "Not enough permissions to register extra contract"
        );
        require(schainHash != MAINNET_HASH, "Schain hash can not be equal Mainnet");        
        _registerExtraContract(schainHash, extraContract);
    }

    function removeExtraContract(string memory schainName, address extraContract) external override {

        bytes32 schainHash = keccak256(abi.encodePacked(schainName));
        require(
            hasRole(EXTRA_CONTRACT_REGISTRAR_ROLE, msg.sender) ||
            isSchainOwner(msg.sender, schainHash),
            "Not enough permissions to register extra contract"
        );
        require(schainHash != MAINNET_HASH, "Schain hash can not be equal Mainnet");
        _removeExtraContract(schainHash, extraContract);
    }

    function postIncomingMessages(
        string calldata fromSchainName,
        uint256 startingCounter,
        Message[] calldata messages,
        Signature calldata sign
    )
        external
        override(IMessageProxy, MessageProxy)
        messageInProgressLocker
    {

        uint256 gasTotal = gasleft();
        bytes32 fromSchainHash = keccak256(abi.encodePacked(fromSchainName));
        require(_checkSchainBalance(fromSchainHash), "Schain wallet has not enough funds");
        require(connectedChains[fromSchainHash].inited, "Chain is not initialized");
        require(messages.length <= MESSAGES_LENGTH, "Too many messages");
        require(
            startingCounter == connectedChains[fromSchainHash].incomingMessageCounter,
            "Starting counter is not equal to incoming message counter");

        require(_verifyMessages(
            fromSchainName,
            _hashedArray(messages, startingCounter, fromSchainName), sign),
            "Signature is not verified");
        uint additionalGasPerMessage = 
            (gasTotal - gasleft() + headerMessageGasCost + messages.length * messageGasCost) / messages.length;
        uint notReimbursedGas = 0;
        connectedChains[fromSchainHash].incomingMessageCounter += messages.length;
        for (uint256 i = 0; i < messages.length; i++) {
            gasTotal = gasleft();
            if (isContractRegistered(bytes32(0), messages[i].destinationContract)) {
                address receiver = _getGasPayer(fromSchainHash, messages[i], startingCounter + i);
                _callReceiverContract(fromSchainHash, messages[i], startingCounter + i);
                notReimbursedGas += communityPool.refundGasByUser(
                    fromSchainHash,
                    payable(msg.sender),
                    receiver,
                    gasTotal - gasleft() + additionalGasPerMessage
                );
            } else {
                _callReceiverContract(fromSchainHash, messages[i], startingCounter + i);
                notReimbursedGas += gasTotal - gasleft() + additionalGasPerMessage;
            }
        }
        communityPool.refundGasBySchainWallet(fromSchainHash, payable(msg.sender), notReimbursedGas);
    }

    function setNewHeaderMessageGasCost(uint256 newHeaderMessageGasCost) external override onlyConstantSetter {

        emit GasCostMessageHeaderWasChanged(headerMessageGasCost, newHeaderMessageGasCost);
        headerMessageGasCost = newHeaderMessageGasCost;
    }

    function setNewMessageGasCost(uint256 newMessageGasCost) external override onlyConstantSetter {

        emit GasCostMessageWasChanged(messageGasCost, newMessageGasCost);
        messageGasCost = newMessageGasCost;
    }

    function setVersion(string calldata newVersion) external override {

        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "DEFAULT_ADMIN_ROLE is required");
        emit VersionUpdated(version, newVersion);
        version = newVersion;
    }

    function initialize(IContractManager contractManagerOfSkaleManagerValue) public virtual override initializer {

        SkaleManagerClient.initialize(contractManagerOfSkaleManagerValue);
        MessageProxy.initializeMessageProxy(1e6);
        headerMessageGasCost = 73800;
        messageGasCost = 9000;
    }

    function isConnectedChain(
        string memory schainName
    )
        public
        view
        override(IMessageProxy, MessageProxy)
        returns (bool)
    {

        require(keccak256(abi.encodePacked(schainName)) != MAINNET_HASH, "Schain id can not be equal Mainnet");
        return super.isConnectedChain(schainName);
    }


    function _authorizeOutgoingMessageSender(bytes32 targetChainHash) internal view override {

        require(
            isContractRegistered(bytes32(0), msg.sender)
                || isContractRegistered(targetChainHash, msg.sender)
                || isSchainOwner(msg.sender, targetChainHash),
            "Sender contract is not registered"
        );        
    }

    function _verifyMessages(
        string calldata fromSchainName,
        bytes32 hashedMessages,
        MessageProxyForMainnet.Signature calldata sign
    )
        internal
        view
        returns (bool)
    {

        return ISchains(
            contractManagerOfSkaleManager.getContract("Schains")
        ).verifySchainSignature(
            sign.blsSignature[0],
            sign.blsSignature[1],
            hashedMessages,
            sign.counter,
            sign.hashA,
            sign.hashB,
            fromSchainName
        );
    }

    function _checkSchainBalance(bytes32 schainHash) internal view returns (bool) {

        return IWallets(
            payable(contractManagerOfSkaleManager.getContract("Wallets"))
        ).getSchainBalance(schainHash) >= (MESSAGES_LENGTH + 1) * gasLimit * tx.gasprice;
    }

    function _getRegistryContracts()
        internal
        view
        override
        returns (mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) storage)
    {

        return _registryContracts;
    }
}