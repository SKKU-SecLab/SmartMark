
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


library ECDSAUpgradeable {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
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




contract ValidatorService is Permissions, IValidatorService {


    using ECDSAUpgradeable for bytes32;

    mapping (uint => Validator) public validators;
    mapping (uint => bool) private _trustedValidators;
    uint[] public trustedValidatorsList;
    mapping (address => uint) private _validatorAddressToId;
    mapping (address => uint) private _nodeAddressToValidatorId;
    mapping (uint => address[]) private _nodeAddresses;
    uint public numberOfValidators;
    bool public useWhitelist;

    bytes32 public constant VALIDATOR_MANAGER_ROLE = keccak256("VALIDATOR_MANAGER_ROLE");

    modifier onlyValidatorManager() {

        require(hasRole(VALIDATOR_MANAGER_ROLE, msg.sender), "VALIDATOR_MANAGER_ROLE is required");
        _;
    }

    modifier checkValidatorExists(uint validatorId) {

        require(validatorExists(validatorId), "Validator with such ID does not exist");
        _;
    }

    function registerValidator(
        string calldata name,
        string calldata description,
        uint feeRate,
        uint minimumDelegationAmount
    )
        external
        override
        returns (uint validatorId)
    {

        require(!validatorAddressExists(msg.sender), "Validator with such address already exists");
        require(feeRate <= 1000, "Fee rate of validator should be lower than 100%");
        validatorId = ++numberOfValidators;
        validators[validatorId] = IValidatorService.Validator(
            name,
            msg.sender,
            address(0),
            description,
            feeRate,
            block.timestamp,
            minimumDelegationAmount,
            true
        );
        _setValidatorAddress(validatorId, msg.sender);

        emit ValidatorRegistered(validatorId);
    }

    function enableValidator(uint validatorId)
        external
        override
        checkValidatorExists(validatorId)
        onlyValidatorManager
    {

        require(!_trustedValidators[validatorId], "Validator is already enabled");
        _trustedValidators[validatorId] = true;
        trustedValidatorsList.push(validatorId);
        emit ValidatorWasEnabled(validatorId);
    }

    function disableValidator(uint validatorId)
        external
        override
        checkValidatorExists(validatorId)
        onlyValidatorManager
    {

        require(_trustedValidators[validatorId], "Validator is already disabled");
        _trustedValidators[validatorId] = false;
        uint position = _find(trustedValidatorsList, validatorId);
        if (position < trustedValidatorsList.length) {
            trustedValidatorsList[position] =
                trustedValidatorsList[trustedValidatorsList.length - 1];
        }
        trustedValidatorsList.pop();
        emit ValidatorWasDisabled(validatorId);
    }

    function disableWhitelist() external override onlyValidatorManager {

        useWhitelist = false;
        emit WhitelistDisabled(false);
    }

    function requestForNewAddress(address newValidatorAddress) external override {

        require(newValidatorAddress != address(0), "New address cannot be null");
        require(_validatorAddressToId[newValidatorAddress] == 0, "Address already registered");
        uint validatorId = getValidatorId(msg.sender);

        validators[validatorId].requestedAddress = newValidatorAddress;
        emit RequestNewAddress(validatorId, msg.sender, newValidatorAddress);
    }

    function confirmNewAddress(uint validatorId)
        external
        override
        checkValidatorExists(validatorId)
    {

        require(
            getValidator(validatorId).requestedAddress == msg.sender,
            "The validator address cannot be changed because it is not the actual owner"
        );
        delete validators[validatorId].requestedAddress;
        _setValidatorAddress(validatorId, msg.sender);

        emit ValidatorAddressChanged(validatorId, validators[validatorId].validatorAddress);
    }

    function linkNodeAddress(address nodeAddress, bytes calldata sig) external override {

        uint validatorId = getValidatorId(msg.sender);
        require(
            keccak256(abi.encodePacked(validatorId)).toEthSignedMessageHash().recover(sig) == nodeAddress,
            "Signature is not pass"
        );
        require(_validatorAddressToId[nodeAddress] == 0, "Node address is a validator");

        _addNodeAddress(validatorId, nodeAddress);
        emit NodeAddressWasAdded(validatorId, nodeAddress);
    }

    function unlinkNodeAddress(address nodeAddress) external override {

        uint validatorId = getValidatorId(msg.sender);

        this.removeNodeAddress(validatorId, nodeAddress);
        emit NodeAddressWasRemoved(validatorId, nodeAddress);
    }

    function setValidatorMDA(uint minimumDelegationAmount) external override {

        uint validatorId = getValidatorId(msg.sender);
        
        emit SetMinimumDelegationAmount(
            validatorId,
            validators[validatorId].minimumDelegationAmount,
            minimumDelegationAmount
        );
        validators[validatorId].minimumDelegationAmount = minimumDelegationAmount;
    }

    function setValidatorName(string calldata newName) external override {

        uint validatorId = getValidatorId(msg.sender);

        emit SetValidatorName(validatorId, validators[validatorId].name, newName);
        validators[validatorId].name = newName;
    }

    function setValidatorDescription(string calldata newDescription) external override {

        uint validatorId = getValidatorId(msg.sender);

        emit SetValidatorDescription(validatorId, validators[validatorId].description, newDescription);
        validators[validatorId].description = newDescription;
    }

    function startAcceptingNewRequests() external override {

        uint validatorId = getValidatorId(msg.sender);
        require(!isAcceptingNewRequests(validatorId), "Accepting request is already enabled");

        validators[validatorId].acceptNewRequests = true;
        emit AcceptingNewRequests(validatorId, true);
    }

    function stopAcceptingNewRequests() external override {

        uint validatorId = getValidatorId(msg.sender);
        require(isAcceptingNewRequests(validatorId), "Accepting request is already disabled");

        validators[validatorId].acceptNewRequests = false;
        emit AcceptingNewRequests(validatorId, false);
    }

    function removeNodeAddress(uint validatorId, address nodeAddress)
        external
        override
        allowTwo("ValidatorService", "Nodes")
    {

        require(_nodeAddressToValidatorId[nodeAddress] == validatorId,
            "Validator does not have permissions to unlink node");
        delete _nodeAddressToValidatorId[nodeAddress];
        for (uint i = 0; i < _nodeAddresses[validatorId].length; ++i) {
            if (_nodeAddresses[validatorId][i] == nodeAddress) {
                if (i + 1 < _nodeAddresses[validatorId].length) {
                    _nodeAddresses[validatorId][i] =
                        _nodeAddresses[validatorId][_nodeAddresses[validatorId].length - 1];
                }
                delete _nodeAddresses[validatorId][_nodeAddresses[validatorId].length - 1];
                _nodeAddresses[validatorId].pop();
                break;
            }
        }
    }

    function getAndUpdateBondAmount(uint validatorId)
        external
        override
        returns (uint)
    {

        IDelegationController delegationController = IDelegationController(
            contractManager.getContract("DelegationController")
        );
        return delegationController.getAndUpdateDelegatedByHolderToValidatorNow(
            getValidator(validatorId).validatorAddress,
            validatorId
        );
    }

    function getMyNodesAddresses() external view override returns (address[] memory) {

        return getNodeAddresses(getValidatorId(msg.sender));
    }

    function getTrustedValidators() external view override returns (uint[] memory) {

        return trustedValidatorsList;
    }

    function checkValidatorAddressToId(address validatorAddress, uint validatorId)
        external
        view
        override
        returns (bool)
    {

        return getValidatorId(validatorAddress) == validatorId ? true : false;
    }

    function getValidatorIdByNodeAddress(address nodeAddress) external view override returns (uint validatorId) {

        validatorId = _nodeAddressToValidatorId[nodeAddress];
        require(validatorId != 0, "Node address is not assigned to a validator");
    }

    function checkValidatorCanReceiveDelegation(uint validatorId, uint amount) external view override {

        require(isAuthorizedValidator(validatorId), "Validator is not authorized to accept delegation request");
        require(isAcceptingNewRequests(validatorId), "The validator is not currently accepting new requests");
        require(
            validators[validatorId].minimumDelegationAmount <= amount,
            "Amount does not meet the validator's minimum delegation amount"
        );
    }

    function initialize(address contractManagerAddress) public override initializer {

        Permissions.initialize(contractManagerAddress);
        useWhitelist = true;
    }

    function getNodeAddresses(uint validatorId) public view override returns (address[] memory) {

        return _nodeAddresses[validatorId];
    }

    function validatorExists(uint validatorId) public view override returns (bool) {

        return validatorId <= numberOfValidators && validatorId != 0;
    }

    function validatorAddressExists(address validatorAddress) public view override returns (bool) {

        return _validatorAddressToId[validatorAddress] != 0;
    }

    function checkIfValidatorAddressExists(address validatorAddress) public view override {

        require(validatorAddressExists(validatorAddress), "Validator address does not exist");
    }

    function getValidator(uint validatorId)
        public
        view
        override
        checkValidatorExists(validatorId)
        returns (IValidatorService.Validator memory)
    {

        return validators[validatorId];
    }

    function getValidatorId(address validatorAddress) public view override returns (uint) {

        checkIfValidatorAddressExists(validatorAddress);
        return _validatorAddressToId[validatorAddress];
    }

    function isAcceptingNewRequests(uint validatorId)
        public
        view
        override
        checkValidatorExists(validatorId)
        returns (bool)
    {

        return validators[validatorId].acceptNewRequests;
    }

    function isAuthorizedValidator(uint validatorId)
        public
        view
        override
        checkValidatorExists(validatorId)
        returns (bool)
    {

        return _trustedValidators[validatorId] || !useWhitelist;
    }


    function _setValidatorAddress(uint validatorId, address validatorAddress) private {

        if (_validatorAddressToId[validatorAddress] == validatorId) {
            return;
        }
        require(_validatorAddressToId[validatorAddress] == 0, "Address is in use by another validator");
        address oldAddress = validators[validatorId].validatorAddress;
        delete _validatorAddressToId[oldAddress];
        _nodeAddressToValidatorId[validatorAddress] = validatorId;
        validators[validatorId].validatorAddress = validatorAddress;
        _validatorAddressToId[validatorAddress] = validatorId;
    }

    function _addNodeAddress(uint validatorId, address nodeAddress) private {

        if (_nodeAddressToValidatorId[nodeAddress] == validatorId) {
            return;
        }
        require(_nodeAddressToValidatorId[nodeAddress] == 0, "Validator cannot override node address");
        _nodeAddressToValidatorId[nodeAddress] = validatorId;
        _nodeAddresses[validatorId].push(nodeAddress);
    }

    function _find(uint[] memory array, uint index) private pure returns (uint) {

        uint i;
        for (i = 0; i < array.length; i++) {
            if (array[i] == index) {
                return i;
            }
        }
        return array.length;
    }
}