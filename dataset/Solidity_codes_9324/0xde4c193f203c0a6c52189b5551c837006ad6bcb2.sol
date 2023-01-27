
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
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
    function __ERC165_init() internal onlyInitializing {
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
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

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
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
    function __AccessControlEnumerable_init() internal onlyInitializing {
    }

    function __AccessControlEnumerable_init_unchained() internal onlyInitializing {
    }
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

library TokensHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeApprove: approve failed");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransfer: transfer failed");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeTransferFrom: transfer failed");
    }

    function safeTransferNativeTokens(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "safeTransferNativeTokens: transfer failed");
    }

    function safeMint(
        address token,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x40c10f19, to, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeMint: mint failed");
    }

    function safeBurn(address token, uint256 amount) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x42966c68, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeBurn: burn failed");
    }

    function safeBurnFrom(
        address token,
        address from,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x79cc6790, from, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "safeBurnFrom: burn failed");
    }
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


contract UpgradeableBeacon is IBeacon, Ownable {

    address private _implementation;

    event Upgraded(address indexed implementation);

    constructor(address implementation_) {
        _setImplementation(implementation_);
    }

    function implementation() public view virtual override returns (address) {

        return _implementation;
    }

    function upgradeTo(address newImplementation) public virtual onlyOwner {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}// MIT

pragma solidity ^0.8.0;

library StorageSlot {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        if (StorageSlot.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822Proxiable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract BeaconProxy is Proxy, ERC1967Upgrade {

    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    function _beacon() internal view virtual returns (address) {

        return _getBeacon();
    }

    function _implementation() internal view virtual override returns (address) {

        return IBeacon(_getBeacon()).implementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {

        _upgradeBeaconToAndCall(beacon, data, false);
    }
}// MIT
pragma solidity ^0.8.0;





contract ParadiseBridge is Initializable, AccessControlEnumerableUpgradeable, ReentrancyGuardUpgradeable {

    struct BridgeableTokensConfig {
        bool enabled;
        bool burn;
        uint256 minBridgeAmount;
        uint256 maxBridgeAmount;
        uint256 bridgeFee;
    }

    struct BridgeApprovalConfig {
        bool enabled;
        bool transfer;
    }

    struct TokensOnChain {
        address token;
        uint256 chainId;
    }

    event BridgeToSubmitted(
        address indexed token,
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        uint256 fees,
        uint256 sourceChain,
        uint256 targetChain
    );

    event BridgeToApproved(
        bytes32 indexed txhash,
        address indexed targetToken,
        address indexed recipient,
        uint256 amount,
        uint256 sourceChain,
        uint256 targetChain
    );

    event TokensDeposit(address indexed from, uint256 amount);

    event FeeRecipientChanged(address indexed newRecipient);

    event BridgeRunningStatusChanged(bool indexed newRunningStatus);

    event BridgeFeeUpdated(address indexed token, uint256 newFee);

    event BridgeAssetsMigrated(address indexed operator, address indexed token, uint256 amount);

    event BridgeableTokenUpdated(
        address indexed token,
        uint256 indexed targetChain,
        bool enable,
        bool burn,
        uint256 minBridgeAmount,
        uint256 maxBridgeAmount,
        uint256 bridgeFee
    );

    event BridgeApprovalConfigUpdated(address indexed token, bool enabled, bool transfer);

    bytes32 public constant BRIDGE_APPROVER_ROLE = keccak256("BRIDGE_APPROVER_ROLE");

    mapping(bytes32 => BridgeableTokensConfig) private _bridgeableTokens;
    mapping(address => BridgeApprovalConfig) public bridgeApprovalConfig;

    address public feeRecipient;

    bool public bridgeIsRunning;

    bool public globalFeeStatus;

    modifier checkTokenAddress(address token) {

        require(Address.isContract(token), "invalid token address");
        _;
    }

    modifier needBridgeIsRunning() {

        require(bridgeIsRunning, "bridge is not running");
        _;
    }

    modifier checkBridgeApprovalStatus(address token) {

        require(bridgeApprovalConfig[token].enabled, "token is not approved");
        _;
    }

    modifier checkArrayLength(uint256 lenA, uint256 lenB) {

        require(lenA == lenB, "arrays should equal in length");
        _;
    }

    function initialize(
        bool _bridgeRunningStatus,
        bool _globalFeeStatus,
        address _feeRecipient
    ) external nonReentrant initializer {

        __Context_init_unchained();
        __ReentrancyGuard_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(BRIDGE_APPROVER_ROLE, DEFAULT_ADMIN_ROLE);

        _setBridgeRunningStatus(_bridgeRunningStatus);
        globalFeeStatus = _globalFeeStatus;

        _setFeeRecipient(_feeRecipient);
    }

    function _encodeTokenWithChainId(address _token, uint256 _chainId) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_token, _chainId));
    }

    function chainId() public view returns (uint256 id) {

        assembly {
            id := chainid()
        }
    }

    function bridgeableTokens(address token, uint256 targetChainId)
        public
        view
        returns (BridgeableTokensConfig memory config)
    {

        BridgeableTokensConfig memory _tokenConfig = _bridgeableTokens[_encodeTokenWithChainId(token, targetChainId)];
        if (!globalFeeStatus) {
            _tokenConfig.bridgeFee = 0;
        }
        return _tokenConfig;
    }

    function _setBridgeRunningStatus(bool newRunningStatus) internal {

        bridgeIsRunning = newRunningStatus;
        emit BridgeRunningStatusChanged(newRunningStatus);
    }

    function _checkTokenAddress(address token) internal view {

        require(token == address(0) || Address.isContract(token), "invalid token address");
    }

    function _setFeeRecipient(address newRecipient) internal {

        require(newRecipient != address(0) && newRecipient != address(this), "invalid fees recipient");
        feeRecipient = newRecipient;
        emit FeeRecipientChanged(newRecipient);
    }

    function _setBridgeFee(
        address _token,
        uint256 _chainId,
        uint256 newFee
    ) internal {

        BridgeableTokensConfig storage _tokenConfig = _bridgeableTokens[_encodeTokenWithChainId(_token, _chainId)];
        if (_tokenConfig.bridgeFee == newFee) return;

        require(
            (newFee < _tokenConfig.maxBridgeAmount) &&
                ((_tokenConfig.maxBridgeAmount - newFee) >= _tokenConfig.minBridgeAmount),
            "invalid fee config"
        );
        _tokenConfig.bridgeFee = newFee;

        emit BridgeFeeUpdated(_token, newFee);
    }

    function bridgeTokensTo(
        address token,
        address recipient,
        uint256 amount,
        uint256 targetChainId
    ) external nonReentrant needBridgeIsRunning checkTokenAddress(token) {

        require(recipient != address(0), "invalid recipient");

        BridgeableTokensConfig storage _tokenConfig = _bridgeableTokens[_encodeTokenWithChainId(token, targetChainId)];

        require(_tokenConfig.enabled, "token is not bridgeable");
        require(amount > _tokenConfig.bridgeFee, "bridge amount should be greater than fees");

        if (globalFeeStatus && _tokenConfig.bridgeFee > 0) {
            TokensHelper.safeTransferFrom(token, msg.sender, feeRecipient, _tokenConfig.bridgeFee);
            amount -= _tokenConfig.bridgeFee;
        }

        require(
            (amount >= _tokenConfig.minBridgeAmount) && (amount <= _tokenConfig.maxBridgeAmount),
            "invalid bridge amount range"
        );

        if (_tokenConfig.burn) {
            TokensHelper.safeBurnFrom(token, msg.sender, amount);
        } else {
            TokensHelper.safeTransferFrom(token, msg.sender, address(this), amount);
        }

        emit BridgeToSubmitted(token, msg.sender, recipient, amount, _tokenConfig.bridgeFee, chainId(), targetChainId);
    }

    function bridgeNativeTokensTo(address recipient, uint256 targetChainId)
        external
        payable
        nonReentrant
        needBridgeIsRunning
    {

        require(recipient != address(0), "invalid recipient");

        uint256 amount = msg.value;
        BridgeableTokensConfig storage _tokenConfig = _bridgeableTokens[
            _encodeTokenWithChainId(address(0), targetChainId)
        ];

        require(_tokenConfig.enabled, "token is not bridgeable");
        require(amount > _tokenConfig.bridgeFee, "bridge amount should be greater than fees");

        if (globalFeeStatus && _tokenConfig.bridgeFee > 0) {
            TokensHelper.safeTransferNativeTokens(feeRecipient, _tokenConfig.bridgeFee);
            amount -= _tokenConfig.bridgeFee;
        }

        require(
            (amount >= _tokenConfig.minBridgeAmount) && (amount <= _tokenConfig.maxBridgeAmount),
            "invalid bridge amount range"
        );

        emit BridgeToSubmitted(
            address(0),
            msg.sender,
            recipient,
            amount,
            _tokenConfig.bridgeFee,
            chainId(),
            targetChainId
        );
    }

    function approveBridgeTo(
        bytes32 txHash,
        uint256 sourceChainId,
        address targetToken,
        address recipient,
        uint256 amount
    )
        external
        nonReentrant
        onlyRole(BRIDGE_APPROVER_ROLE)
        needBridgeIsRunning
        checkTokenAddress(targetToken)
        checkBridgeApprovalStatus(targetToken)
    {

        if (bridgeApprovalConfig[targetToken].transfer) {
            TokensHelper.safeTransfer(targetToken, recipient, amount);
        } else {
            TokensHelper.safeMint(targetToken, recipient, amount);
        }
        emit BridgeToApproved(txHash, targetToken, recipient, amount, sourceChainId, chainId());
    }

    function approveBridgeToNative(
        bytes32 txHash,
        uint256 sourceChainId,
        address recipient,
        uint256 amount
    ) external nonReentrant onlyRole(BRIDGE_APPROVER_ROLE) needBridgeIsRunning checkBridgeApprovalStatus(address(0)) {

        TokensHelper.safeTransferNativeTokens(recipient, amount);
        emit BridgeToApproved(txHash, address(0), recipient, amount, sourceChainId, chainId());
    }

    function addBridgeableTokens(TokensOnChain[] memory tokensOnChain, BridgeableTokensConfig[] memory configs)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        checkArrayLength(tokensOnChain.length, configs.length)
    {

        for (uint256 i; i < tokensOnChain.length; i++) {
            _checkTokenAddress(tokensOnChain[i].token);
            if (configs[i].maxBridgeAmount == 0) {
                configs[i].maxBridgeAmount = type(uint256).max;
            }
            require(configs[i].maxBridgeAmount > configs[i].minBridgeAmount, "invalid bridge amount limit");
            _bridgeableTokens[_encodeTokenWithChainId(tokensOnChain[i].token, tokensOnChain[i].chainId)] = configs[i];
            emit BridgeableTokenUpdated(
                tokensOnChain[i].token,
                tokensOnChain[i].chainId,
                configs[i].enabled,
                configs[i].burn,
                configs[i].minBridgeAmount,
                configs[i].maxBridgeAmount,
                configs[i].bridgeFee
            );
        }
    }

    function setBridgeFees(TokensOnChain[] memory tokensOnChain, uint256[] memory fees)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        checkArrayLength(tokensOnChain.length, fees.length)
    {

        for (uint256 i; i < tokensOnChain.length; i++) {
            _checkTokenAddress(tokensOnChain[i].token);
            _setBridgeFee(tokensOnChain[i].token, tokensOnChain[i].chainId, fees[i]);
        }
    }

    function addBridgeApprovalConfig(address[] memory tokenAddresses, BridgeApprovalConfig[] memory configs)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        checkArrayLength(tokenAddresses.length, configs.length)
    {

        for (uint256 i; i < tokenAddresses.length; i++) {
            _checkTokenAddress(tokenAddresses[i]);
            bridgeApprovalConfig[tokenAddresses[i]] = configs[i];
            emit BridgeApprovalConfigUpdated(tokenAddresses[i], configs[i].enabled, configs[i].transfer);
        }
    }

    function setBridgeRunningStatus(bool bridgeRunningStatus) external onlyRole(DEFAULT_ADMIN_ROLE) {

        _setBridgeRunningStatus(bridgeRunningStatus);
    }

    function depositNativeTokens() external payable {

        emit TokensDeposit(msg.sender, msg.value);
    }

    function setFeeRecipient(address newRecipient) external onlyRole(DEFAULT_ADMIN_ROLE) {

        _setFeeRecipient(newRecipient);
    }

    function setGlobalFeeStatus(bool newFeeStatus) external onlyRole(DEFAULT_ADMIN_ROLE) {

        globalFeeStatus = newFeeStatus;
    }

    function migrateAssets(uint256 amount) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {

        TokensHelper.safeTransferNativeTokens(msg.sender, amount);
        emit BridgeAssetsMigrated(msg.sender, address(0), amount);
    }

    function migrateAssets(address token, uint256 amount) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {

        TokensHelper.safeTransfer(token, msg.sender, amount);
        emit BridgeAssetsMigrated(msg.sender, token, amount);
    }

    function migrateAssets(address[] memory tokens, uint256 amount) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {

        for (uint256 i; i < tokens.length; i++) {
            TokensHelper.safeTransfer(tokens[i], msg.sender, amount);
            emit BridgeAssetsMigrated(msg.sender, tokens[i], amount);
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC1822Proxiable {

    function proxiableUUID() external view returns (bytes32);

}