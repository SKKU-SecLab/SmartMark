
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
        __ERC165_init_unchained();
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
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
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
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();
    }

    function __AccessControlEnumerable_init_unchained() internal onlyInitializing {
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

interface IERC20Upgradeable {

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
}// MIT
pragma solidity ^0.8.0;

interface IGenericMintableTo {

    function mint(address to, uint256 amount) external;

}// MIT
pragma solidity ^0.8.0;

interface IGenericBurnableFrom {

    function burn(uint256 amount) external;


    function burnFrom(address account, uint256 amount) external;

}// MIT
pragma solidity ^0.8.0;



interface IMintableTokenUpgradeable is IGenericMintableTo, IERC20Upgradeable {


}

interface IMintableBurnableTokenUpgradeable is IMintableTokenUpgradeable, IGenericBurnableFrom {


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

library Address {

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
}// MIT
pragma solidity ^0.8.0;


contract BNPLKYCStore is Initializable, ReentrancyGuardUpgradeable {

    using ECDSAUpgradeable for bytes32;

    mapping(uint32 => address) public publicKeys;

    mapping(uint256 => uint32) public domainPermissions;

    mapping(uint256 => uint32) public userKycStatuses;

    mapping(bytes32 => uint8) public proofUsed;

    mapping(uint32 => uint256) public domainKycMode;

    uint32 public constant PROOF_MAGIC = 0xfc203827;
    uint32 public constant DOMAIN_ADMIN_PERM = 0xffff;

    uint32 public domainCount;

    function encodeKYCUserDomainKey(uint32 domain, address user) internal pure returns (uint256) {

        return (uint256(uint160(user)) << 32) | uint256(domain);
    }

    modifier onlyDomainAdmin(uint32 domain) {

        require(
            domainPermissions[encodeKYCUserDomainKey(domain, msg.sender)] == DOMAIN_ADMIN_PERM,
            "User must be an admin for this domain to perform this action"
        );
        _;
    }

    function getDomainPermissions(uint32 domain, address user) external view returns (uint32) {

        return domainPermissions[encodeKYCUserDomainKey(domain, user)];
    }

    function _setDomainPermissions(
        uint32 domain,
        address user,
        uint32 permissions
    ) internal {

        domainPermissions[encodeKYCUserDomainKey(domain, user)] = permissions;
    }

    function getKYCStatusUser(uint32 domain, address user) public view returns (uint32) {

        return userKycStatuses[encodeKYCUserDomainKey(domain, user)];
    }

    function _verifyProof(
        uint32 domain,
        address user,
        uint32 status,
        uint256 nonce,
        bytes calldata signature
    ) internal {

        require(domain != 0 && domain <= domainCount, "invalid domain");
        require(publicKeys[domain] != address(0), "this domain is disabled");
        bytes32 proofHash = getKYCSignatureHash(domain, user, status, nonce);
        require(proofHash.toEthSignedMessageHash().recover(signature) == publicKeys[domain], "invalid signature");
        require(proofUsed[proofHash] == 0, "proof already used");
        proofUsed[proofHash] = 1;
    }

    function _setKYCStatusUser(
        uint32 domain,
        address user,
        uint32 status
    ) internal {

        userKycStatuses[encodeKYCUserDomainKey(domain, user)] = status;
    }

    function _orKYCStatusUser(
        uint32 domain,
        address user,
        uint32 status
    ) internal {

        userKycStatuses[encodeKYCUserDomainKey(domain, user)] |= status;
    }

    function createNewKYCDomain(
        address admin,
        address publicKey,
        uint256 kycMode
    ) external returns (uint32) {

        require(admin != address(0), "cannot create a kyc domain with an empty user");
        uint32 id = domainCount + 1;
        domainCount = id;
        _setDomainPermissions(id, admin, DOMAIN_ADMIN_PERM);
        publicKeys[id] = publicKey;
        domainKycMode[id] = kycMode;
        return id;
    }

    function setKYCDomainPublicKey(uint32 domain, address newPublicKey) external onlyDomainAdmin(domain) {

        publicKeys[domain] = newPublicKey;
    }

    function setKYCDomainMode(uint32 domain, uint256 mode) external onlyDomainAdmin(domain) {

        domainKycMode[domain] = mode;
    }

    function checkUserBasicBitwiseMode(
        uint32 domain,
        address user,
        uint256 mode
    ) external view returns (uint256) {

        require(domain != 0 && domain <= domainCount, "invalid domain");
        require(
            user != address(0) && ((domainKycMode[domain] & mode) == 0 || (mode & getKYCStatusUser(domain, user) != 0)),
            "invalid user permissions"
        );
        return 1;
    }

    function setKYCStatusUser(
        uint32 domain,
        address user,
        uint32 status
    ) external onlyDomainAdmin(domain) {

        _setKYCStatusUser(domain, user, status);
    }

    function getKYCSignaturePayload(
        uint32 domain,
        address user,
        uint32 status,
        uint256 nonce
    ) public pure returns (bytes memory) {

        return (
            abi.encode(
                ((uint256(PROOF_MAGIC) << 224) |
                    (uint256(uint160(user)) << 64) |
                    (uint256(domain) << 32) |
                    uint256(status)),
                nonce
            )
        );
    }

    function getKYCSignatureHash(
        uint32 domain,
        address user,
        uint32 status,
        uint256 nonce
    ) public pure returns (bytes32) {

        return keccak256(getKYCSignaturePayload(domain, user, status, nonce));
    }

    function orKYCStatusWithProof(
        uint32 domain,
        address user,
        uint32 status,
        uint256 nonce,
        bytes calldata signature
    ) external {

        _verifyProof(domain, user, status, nonce, signature);
        _orKYCStatusUser(domain, user, status);
    }

    function clearKYCStatusWithProof(
        uint32 domain,
        address user,
        uint256 nonce,
        bytes calldata signature
    ) external {

        _verifyProof(domain, user, 1, nonce, signature);
        _setKYCStatusUser(domain, user, 1);
    }

    function initialize() external initializer nonReentrant {

        __ReentrancyGuard_init_unchained();
    }
}// MIT
pragma solidity ^0.8.0;



interface IBNPLProtocolConfig {

    function networkId() external view returns (uint64);


    function networkName() external view returns (string memory);


    function bnplToken() external view returns (IERC20);


    function upBeaconBankNodeManager() external view returns (UpgradeableBeacon);


    function upBeaconBankNode() external view returns (UpgradeableBeacon);


    function upBeaconBankNodeLendingPoolToken() external view returns (UpgradeableBeacon);


    function upBeaconBankNodeStakingPool() external view returns (UpgradeableBeacon);


    function upBeaconBankNodeStakingPoolToken() external view returns (UpgradeableBeacon);


    function upBeaconBankNodeLendingRewards() external view returns (UpgradeableBeacon);


    function upBeaconBNPLKYCStore() external view returns (UpgradeableBeacon);


    function bankNodeManager() external view returns (IBankNodeManager);

}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;




contract BankNodeRewardSystem is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable
{

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bytes32 public constant REWARDS_DISTRIBUTOR_ROLE = keccak256("REWARDS_DISTRIBUTOR_ROLE");
    bytes32 public constant REWARDS_DISTRIBUTOR_ADMIN_ROLE = keccak256("REWARDS_DISTRIBUTOR_ADMIN_ROLE");

    bytes32 public constant REWARDS_MANAGER = keccak256("REWARDS_MANAGER_ROLE");
    bytes32 public constant REWARDS_MANAGER_ROLE_ADMIN = keccak256("REWARDS_MANAGER_ROLE_ADMIN");

    mapping(uint32 => uint256) public periodFinish;

    mapping(uint32 => uint256) public rewardRate;

    mapping(uint32 => uint256) public rewardsDuration;

    mapping(uint32 => uint256) public lastUpdateTime;

    mapping(uint32 => uint256) public rewardPerTokenStored;

    mapping(uint256 => uint256) public userRewardPerTokenPaid;

    mapping(uint256 => uint256) public rewards;

    mapping(uint32 => uint256) public _totalSupply;

    mapping(uint256 => uint256) private _balances;

    IBankNodeManager public bankNodeManager;

    IERC20 public rewardsToken;

    uint256 public defaultRewardsDuration;

    function encodeUserBankNodeKey(address user, uint32 bankNodeId) public pure returns (uint256) {

        return (uint256(uint160(user)) << 32) | uint256(bankNodeId);
    }

    function decodeUserBankNodeKey(uint256 stakingVaultKey) external pure returns (address user, uint32 bankNodeId) {

        bankNodeId = uint32(stakingVaultKey & 0xffffffff);
        user = address(uint160(stakingVaultKey >> 32));
    }

    function encodeVaultValue(uint256 amount, uint40 depositTime) external pure returns (uint256) {

        require(
            amount <= 0xffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            "cannot encode amount larger than 2^216-1"
        );
        return (amount << 40) | uint256(depositTime);
    }

    function decodeVaultValue(uint256 vaultValue) external pure returns (uint256 amount, uint40 depositTime) {

        depositTime = uint40(vaultValue & 0xffffffffff);
        amount = vaultValue >> 40;
    }

    function _ensureAddressIERC20Not0(address tokenAddress) internal pure returns (IERC20) {

        require(tokenAddress != address(0), "invalid token address!");
        return IERC20(tokenAddress);
    }

    function _ensureContractAddressNot0(address contractAddress) internal pure returns (address) {

        require(contractAddress != address(0), "invalid token address!");
        return contractAddress;
    }

    function getStakingTokenForBankNode(uint32 bankNodeId) internal view returns (IERC20) {

        return _ensureAddressIERC20Not0(bankNodeManager.getBankNodeToken(bankNodeId));
    }

    function getPoolLiquidityTokensStakedInRewards(uint32 bankNodeId) public view returns (uint256) {

        return getStakingTokenForBankNode(bankNodeId).balanceOf(address(this));
    }

    function getInternalValueForStakedTokenAmount(uint256 amount) internal pure returns (uint256) {

        return amount;
    }

    function getStakedTokenAmountForInternalValue(uint256 amount) internal pure returns (uint256) {

        return amount;
    }

    function totalSupply(uint32 bankNodeId) external view returns (uint256) {

        return getStakedTokenAmountForInternalValue(_totalSupply[bankNodeId]);
    }

    function balanceOf(address account, uint32 bankNodeId) external view returns (uint256) {

        return getStakedTokenAmountForInternalValue(_balances[encodeUserBankNodeKey(account, bankNodeId)]);
    }

    function lastTimeRewardApplicable(uint32 bankNodeId) public view returns (uint256) {

        return block.timestamp < periodFinish[bankNodeId] ? block.timestamp : periodFinish[bankNodeId];
    }

    function rewardPerToken(uint32 bankNodeId) public view returns (uint256) {

        if (_totalSupply[bankNodeId] == 0) {
            return rewardPerTokenStored[bankNodeId];
        }
        return
            rewardPerTokenStored[bankNodeId].add(
                lastTimeRewardApplicable(bankNodeId)
                    .sub(lastUpdateTime[bankNodeId])
                    .mul(rewardRate[bankNodeId])
                    .mul(1e18)
                    .div(_totalSupply[bankNodeId])
            );
    }

    function earned(address account, uint32 bankNodeId) public view returns (uint256) {

        uint256 key = encodeUserBankNodeKey(account, bankNodeId);
        return
            ((_balances[key] * (rewardPerToken(bankNodeId) - (userRewardPerTokenPaid[key]))) / 1e18) + (rewards[key]);
    }

    function getRewardForDuration(uint32 bankNodeId) external view returns (uint256) {

        return rewardRate[bankNodeId] * rewardsDuration[bankNodeId];
    }

    function stake(uint32 bankNodeId, uint256 tokenAmount)
        external
        nonReentrant
        whenNotPaused
        updateReward(msg.sender, bankNodeId)
    {

        require(tokenAmount > 0, "Cannot stake 0");
        uint256 amount = getInternalValueForStakedTokenAmount(tokenAmount);
        require(amount > 0, "Cannot stake 0");
        require(getStakedTokenAmountForInternalValue(amount) == tokenAmount, "token amount too high!");
        _totalSupply[bankNodeId] += amount;
        _balances[encodeUserBankNodeKey(msg.sender, bankNodeId)] += amount;
        getStakingTokenForBankNode(bankNodeId).safeTransferFrom(msg.sender, address(this), tokenAmount);
        emit Staked(msg.sender, bankNodeId, tokenAmount);
    }

    function withdraw(uint32 bankNodeId, uint256 tokenAmount) public nonReentrant updateReward(msg.sender, bankNodeId) {

        require(tokenAmount > 0, "Cannot withdraw 0");
        uint256 amount = getInternalValueForStakedTokenAmount(tokenAmount);
        require(amount > 0, "Cannot withdraw 0");
        require(getStakedTokenAmountForInternalValue(amount) == tokenAmount, "token amount too high!");

        _totalSupply[bankNodeId] -= amount;
        _balances[encodeUserBankNodeKey(msg.sender, bankNodeId)] -= amount;
        getStakingTokenForBankNode(bankNodeId).safeTransfer(msg.sender, tokenAmount);
        emit Withdrawn(msg.sender, bankNodeId, tokenAmount);
    }

    function getReward(uint32 bankNodeId) public nonReentrant updateReward(msg.sender, bankNodeId) {

        uint256 reward = rewards[encodeUserBankNodeKey(msg.sender, bankNodeId)];

        if (reward > 0) {
            rewards[encodeUserBankNodeKey(msg.sender, bankNodeId)] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, bankNodeId, reward);
        }
    }

    function exit(uint32 bankNodeId) external {

        withdraw(
            bankNodeId,
            getStakedTokenAmountForInternalValue(_balances[encodeUserBankNodeKey(msg.sender, bankNodeId)])
        );
        getReward(bankNodeId);
    }

    function _notifyRewardAmount(uint32 bankNodeId, uint256 reward) internal updateReward(address(0), bankNodeId) {

        if (rewardsDuration[bankNodeId] == 0) {
            rewardsDuration[bankNodeId] = defaultRewardsDuration;
        }
        if (block.timestamp >= periodFinish[bankNodeId]) {
            rewardRate[bankNodeId] = reward / (rewardsDuration[bankNodeId]);
        } else {
            uint256 remaining = periodFinish[bankNodeId] - (block.timestamp);
            uint256 leftover = remaining * (rewardRate[bankNodeId]);
            rewardRate[bankNodeId] = (reward + leftover) / (rewardsDuration[bankNodeId]);
        }

        uint256 balance = rewardsToken.balanceOf(address(this));
        require(rewardRate[bankNodeId] <= (balance / rewardsDuration[bankNodeId]), "Provided reward too high");

        lastUpdateTime[bankNodeId] = block.timestamp;
        periodFinish[bankNodeId] = block.timestamp + (rewardsDuration[bankNodeId]);
        emit RewardAdded(bankNodeId, reward);
    }

    function notifyRewardAmount(uint32 bankNodeId, uint256 reward) external onlyRole(REWARDS_DISTRIBUTOR_ROLE) {

        _notifyRewardAmount(bankNodeId, reward);
    }


    function setRewardsDuration(uint32 bankNodeId, uint256 _rewardsDuration) external onlyRole(REWARDS_MANAGER) {

        require(
            block.timestamp > periodFinish[bankNodeId],
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration[bankNodeId] = _rewardsDuration;
        emit RewardsDurationUpdated(bankNodeId, rewardsDuration[bankNodeId]);
    }

    modifier updateReward(address account, uint32 bankNodeId) {

        if (rewardsDuration[bankNodeId] == 0) {
            rewardsDuration[bankNodeId] = defaultRewardsDuration;
        }
        rewardPerTokenStored[bankNodeId] = rewardPerToken(bankNodeId);
        lastUpdateTime[bankNodeId] = lastTimeRewardApplicable(bankNodeId);
        if (account != address(0)) {
            uint256 key = encodeUserBankNodeKey(msg.sender, bankNodeId);
            rewards[key] = earned(msg.sender, bankNodeId);
            userRewardPerTokenPaid[key] = rewardPerTokenStored[bankNodeId];
        }
        _;
    }

    event RewardAdded(uint32 indexed bankNodeId, uint256 reward);

    event Staked(address indexed user, uint32 indexed bankNodeId, uint256 amount);

    event Withdrawn(address indexed user, uint32 indexed bankNodeId, uint256 amount);

    event RewardPaid(address indexed user, uint32 indexed bankNodeId, uint256 reward);

    event RewardsDurationUpdated(uint32 indexed bankNodeId, uint256 newDuration);
}// MIT

pragma solidity ^0.8.0;




contract BankNodeLendingRewards is Initializable, BankNodeRewardSystem {

    using SafeERC20 for IERC20;

    function initialize(
        uint256 _defaultRewardsDuration,
        address _rewardsToken,
        address _bankNodeManager,
        address distributorAdmin,
        address managerAdmin
    ) external initializer {

        __ReentrancyGuard_init_unchained();
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        rewardsToken = IERC20(_rewardsToken);
        bankNodeManager = IBankNodeManager(_bankNodeManager);
        defaultRewardsDuration = _defaultRewardsDuration;

        _setupRole(REWARDS_DISTRIBUTOR_ROLE, _bankNodeManager);
        _setupRole(REWARDS_DISTRIBUTOR_ROLE, distributorAdmin);
        _setupRole(REWARDS_DISTRIBUTOR_ADMIN_ROLE, distributorAdmin);
        _setRoleAdmin(REWARDS_DISTRIBUTOR_ROLE, REWARDS_DISTRIBUTOR_ADMIN_ROLE);

        _setupRole(REWARDS_MANAGER, _bankNodeManager);
        _setupRole(REWARDS_MANAGER, managerAdmin);
        _setupRole(REWARDS_MANAGER_ROLE_ADMIN, managerAdmin);
        _setRoleAdmin(REWARDS_MANAGER, REWARDS_MANAGER_ROLE_ADMIN);
    }

    function _bnplTokensStakedToBankNode(uint32 bankNodeId) internal view returns (uint256) {

        return
            rewardsToken.balanceOf(
                _ensureContractAddressNot0(bankNodeManager.getBankNodeStakingPoolContract(bankNodeId))
            );
    }

    function getBNPLTokenDistribution(uint256 amount) external view returns (uint256[] memory) {

        uint32 nodeCount = bankNodeManager.bankNodeCount();
        uint256[] memory bnplTokensPerNode = new uint256[](nodeCount);
        uint32 i = 0;
        uint256 amt = 0;
        uint256 total = 0;
        while (i < nodeCount) {
            amt = rewardsToken.balanceOf(
                _ensureContractAddressNot0(bankNodeManager.getBankNodeStakingPoolContract(i + 1))
            );
            bnplTokensPerNode[i] = amt;
            total += amt;
            i += 1;
        }
        i = 0;
        while (i < nodeCount) {
            bnplTokensPerNode[i] = (bnplTokensPerNode[i] * amount) / total;
            i += 1;
        }
        return bnplTokensPerNode;
    }

    function distributeBNPLTokensToBankNodes(uint256 amount)
        external
        onlyRole(REWARDS_DISTRIBUTOR_ROLE)
        returns (uint256)
    {

        require(amount > 0, "cannot send 0");
        rewardsToken.safeTransferFrom(msg.sender, address(this), amount);
        uint32 nodeCount = bankNodeManager.bankNodeCount();
        uint256[] memory bnplTokensPerNode = new uint256[](nodeCount);
        uint32 i = 0;
        uint256 amt = 0;
        uint256 total = 0;
        while (i < nodeCount) {
            if (getPoolLiquidityTokensStakedInRewards(i + 1) != 0) {
                amt = rewardsToken.balanceOf(
                    _ensureContractAddressNot0(bankNodeManager.getBankNodeStakingPoolContract(i + 1))
                );
                bnplTokensPerNode[i] = amt;
                total += amt;
            }
            i += 1;
        }
        i = 0;
        while (i < nodeCount) {
            amt = (bnplTokensPerNode[i] * amount) / total;
            if (amt != 0) {
                _notifyRewardAmount(i + 1, amt);
            }
            i += 1;
        }
        return total;
    }

    function distributeBNPLTokensToBankNodes2(uint256 amount)
        external
        onlyRole(REWARDS_DISTRIBUTOR_ROLE)
        returns (uint256)
    {

        uint32 nodeCount = bankNodeManager.bankNodeCount();
        uint32 i = 0;
        uint256 amt = 0;
        uint256 total = 0;
        while (i < nodeCount) {
            total += rewardsToken.balanceOf(
                _ensureContractAddressNot0(bankNodeManager.getBankNodeStakingPoolContract(i + 1))
            );
            i += 1;
        }
        i = 0;
        while (i < nodeCount) {
            amt =
                (rewardsToken.balanceOf(
                    _ensureContractAddressNot0(bankNodeManager.getBankNodeStakingPoolContract(i + 1))
                ) * amount) /
                total;
            if (amt != 0) {
                _notifyRewardAmount(i + 1, amt);
            }
            i += 1;
        }
        return total;
    }
}// MIT
pragma solidity ^0.8.0;




interface IBankNodeManager {

    struct LendableToken {
        address tokenContract;
        address swapMarket;
        uint24 swapMarketPoolFee;
        uint8 decimals;
        uint256 valueMultiplier;
        uint16 unusedFundsLendingMode;
        address unusedFundsLendingContract;
        address unusedFundsLendingToken;
        address unusedFundsIncentivesController;
        string symbol;
        string poolSymbol;
    }

    struct BankNode {
        address bankNodeContract;
        address bankNodeToken;
        address bnplStakingPoolContract;
        address bnplStakingPoolToken;
        address lendableToken;
        address creator;
        uint32 id;
        uint64 createdAt;
        uint256 createBlock;
        string nodeName;
        string website;
        string configUrl;
    }

    struct BankNodeDetail {
        uint256 totalAssetsValueBankNode;
        uint256 totalAssetsValueStakingPool;
        uint256 tokensCirculatingBankNode;
        uint256 tokensCirculatingStakingPool;
        uint256 totalLiquidAssetsValue;
        uint256 baseTokenBalanceBankNode;
        uint256 baseTokenBalanceStakingPool;
        uint256 accountsReceivableFromLoans;
        uint256 virtualPoolTokensCount;
        address baseLiquidityToken;
        address poolLiquidityToken;
        bool isNodeDecomissioning;
        uint256 nodeOperatorBalance;
        uint256 loanRequestIndex;
        uint256 loanIndex;
        uint256 valueOfUnusedFundsLendingDeposits;
        uint256 totalLossAllTime;
        uint256 onGoingLoanCount;
        uint256 totalTokensLocked;
        uint256 getUnstakeLockupPeriod;
        uint256 tokensBondedAllTime;
        uint256 poolTokenEffectiveSupply;
        uint256 nodeTotalStaked;
        uint256 nodeBondedBalance;
        uint256 nodeOwnerBNPLRewards;
        uint256 nodeOwnerPoolTokenRewards;
    }

    struct BankNodeData {
        BankNode data;
        BankNodeDetail detail;
    }

    struct CreateBankNodeContractsInput {
        uint32 bankNodeId;
        address operatorAdmin;
        address operator;
        address lendableTokenAddress;
    }

    struct CreateBankNodeContractsOutput {
        address bankNodeContract;
        address bankNodeToken;
        address bnplStakingPoolContract;
        address bnplStakingPoolToken;
    }

    function bankNodeIdExists(uint32 bankNodeId) external view returns (uint256);


    function getBankNodeContract(uint32 bankNodeId) external view returns (address);


    function getBankNodeToken(uint32 bankNodeId) external view returns (address);


    function getBankNodeStakingPoolContract(uint32 bankNodeId) external view returns (address);


    function getBankNodeStakingPoolToken(uint32 bankNodeId) external view returns (address);


    function getBankNodeLendableToken(uint32 bankNodeId) external view returns (address);


    function getBankNodeLoansStatistic()
        external
        view
        returns (uint256 totalAmountOfAllActiveLoans, uint256 totalAmountOfAllLoans);


    function bnplKYCStore() external view returns (BNPLKYCStore);


    function initialize(
        IBNPLProtocolConfig _protocolConfig,
        address _configurator,
        uint256 _minimumBankNodeBondedAmount,
        uint256 _loanOverdueGracePeriod,
        BankNodeLendingRewards _bankNodeLendingRewards,
        BNPLKYCStore _bnplKYCStore
    ) external;


    function enabledLendableTokens(address lendableTokenAddress) external view returns (uint8);


    function lendableTokens(address lendableTokenAddress)
        external
        view
        returns (
            address tokenContract,
            address swapMarket,
            uint24 swapMarketPoolFee,
            uint8 decimals,
            uint256 valueMultiplier, //USD_VALUE = amount * valueMultiplier / 10**18
            uint16 unusedFundsLendingMode,
            address unusedFundsLendingContract,
            address unusedFundsLendingToken,
            address unusedFundsIncentivesController,
            string calldata symbol,
            string calldata poolSymbol
        );


    function bankNodes(uint32 bankNodeId)
        external
        view
        returns (
            address bankNodeContract,
            address bankNodeToken,
            address bnplStakingPoolContract,
            address bnplStakingPoolToken,
            address lendableToken,
            address creator,
            uint32 id,
            uint64 createdAt,
            uint256 createBlock,
            string calldata nodeName,
            string calldata website,
            string calldata configUrl
        );


    function bankNodeAddressToId(address bankNodeAddressTo) external view returns (uint32);


    function minimumBankNodeBondedAmount() external view returns (uint256);


    function loanOverdueGracePeriod() external view returns (uint256);


    function bankNodeCount() external view returns (uint32);


    function bnplToken() external view returns (IERC20);


    function bankNodeLendingRewards() external view returns (BankNodeLendingRewards);


    function protocolConfig() external view returns (IBNPLProtocolConfig);


    function getBankNodeList(
        uint32 start,
        uint32 count,
        bool reverse
    ) external view returns (BankNodeData[] memory, uint32);


    function getBankNodeDetail(address bankNode) external view returns (BankNodeDetail memory);


    function addLendableToken(LendableToken calldata _lendableToken, uint8 enabled) external;


    function setLendableTokenStatus(address tokenContract, uint8 enabled) external;


    function setMinimumBankNodeBondedAmount(uint256 _minimumBankNodeBondedAmount) external;


    function setLoanOverdueGracePeriod(uint256 _loanOverdueGracePeriod) external;


    function createBondedBankNode(
        address operator,
        uint256 tokensToBond,
        address lendableTokenAddress,
        string calldata nodeName,
        string calldata website,
        string calldata configUrl,
        address nodePublicKey,
        uint32 kycMode
    ) external returns (uint32);

}// agpl-3.0
pragma solidity ^0.8.0;

interface IStakedToken {

    function stake(address to, uint256 amount) external;


    function redeem(address to, uint256 amount) external;


    function cooldown() external;


    function claimRewards(address to, uint256 amount) external;


    function REWARD_TOKEN() external view returns (address);


    function stakersCooldowns(address staker) external view returns (uint256);


    function getTotalRewardsBalance(address staker) external view returns (uint256);

}// MIT
pragma solidity ^0.8.0;

interface IAaveLendingPool {

    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;


    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external;

}// agpl-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

library DistributionTypes {

    struct AssetConfigInput {
        uint104 emissionPerSecond;
        uint256 totalStaked;
        address underlyingAsset;
    }

    struct UserStakeInput {
        address underlyingAsset;
        uint256 stakedByUser;
        uint256 totalStaked;
    }
}// agpl-3.0
pragma solidity ^0.8.0;


interface IAaveDistributionManager {

    event AssetConfigUpdated(address indexed asset, uint256 emission);
    event AssetIndexUpdated(address indexed asset, uint256 index);
    event UserIndexUpdated(address indexed user, address indexed asset, uint256 index);
    event DistributionEndUpdated(uint256 newDistributionEnd);

    function setDistributionEnd(uint256 distributionEnd) external;


    function getDistributionEnd() external view returns (uint256);


    function DISTRIBUTION_END() external view returns (uint256);


    function getUserAssetData(address user, address asset) external view returns (uint256);


    function getAssetData(address asset)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

}// agpl-3.0
pragma solidity ^0.8.0;


interface IAaveIncentivesController is IAaveDistributionManager {

    event RewardsAccrued(address indexed user, uint256 amount);

    event RewardsClaimed(address indexed user, address indexed to, address indexed claimer, uint256 amount);

    event ClaimerSet(address indexed user, address indexed claimer);

    function setClaimer(address user, address claimer) external;


    function getClaimer(address user) external view returns (address);


    function configureAssets(address[] calldata assets, uint256[] calldata emissionsPerSecond) external;


    function handleAction(
        address asset,
        uint256 userBalance,
        uint256 totalSupply
    ) external;


    function getRewardsBalance(address[] calldata assets, address user) external view returns (uint256);


    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to
    ) external returns (uint256);


    function claimRewardsOnBehalf(
        address[] calldata assets,
        uint256 amount,
        address user,
        address to
    ) external returns (uint256);


    function claimRewardsToSelf(address[] calldata assets, uint256 amount) external returns (uint256);


    function getUserUnclaimedRewards(address user) external view returns (uint256);


    function REWARD_TOKEN() external view returns (address);

}// MIT
pragma solidity ^0.8.0;

interface IBNPLSwapMarket {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

}// MIT
pragma solidity ^0.8.0;

interface IUserTokenLockup {

    function totalTokensLocked() external view returns (uint256);

}// MIT
pragma solidity ^0.8.0;


interface IBankNodeStakingPoolInitializableV1 {

    function initialize(
        address bnplToken,
        address poolBNPLToken,
        address bankNodeContract,
        address bankNodeManagerContract,
        address tokenBonder,
        uint256 tokensToBond,
        BNPLKYCStore bnplKYCStore_,
        uint32 kycDomainId_
    ) external;

}

interface IBNPLNodeStakingPool is IBankNodeStakingPoolInitializableV1, IUserTokenLockup {

    function donate(uint256 donateAmount) external;


    function donateNotCountedInTotal(uint256 donateAmount) external;


    function bondTokens(uint256 bondAmount) external;


    function unbondTokens() external;


    function stakeTokens(uint256 stakeAmount) external;


    function unstakeTokens(uint256 unstakeAmount) external;


    function slash(uint256 slashAmount) external;


    function getPoolTotalAssetsValue() external view returns (uint256);


    function getPoolWithdrawConversion(uint256 withdrawAmount) external view returns (uint256);


    function virtualPoolTokensCount() external view returns (uint256);


    function baseTokenBalance() external view returns (uint256);


    function getUnstakeLockupPeriod() external pure returns (uint256);


    function tokensBondedAllTime() external view returns (uint256);


    function poolTokenEffectiveSupply() external view returns (uint256);


    function getNodeOwnerBNPLRewards() external view returns (uint256);


    function getNodeOwnerPoolTokenRewards() external view returns (uint256);


    function poolTokensCirculating() external view returns (uint256);


    function isNodeDecomissioning() external view returns (bool);


    function claimNodeOwnerPoolTokenRewards(address to) external;

}// MIT
pragma solidity ^0.8.0;





interface IBankNodeInitializableV1 {

    struct BankNodeInitializeArgsV1 {
        uint32 bankNodeId; // The id of bank node
        uint24 bnplSwapMarketPoolFee; // The configured swap market fee
        address bankNodeManager; // The address of bank node manager
        address operatorAdmin; // The admin with `OPERATOR_ADMIN_ROLE` role
        address operator; // The admin with `OPERATOR_ROLE` role
        address bnplToken; // BNPL token address
        address bnplSwapMarket; // The swap market contract (ex. Sushiswap Router)
        uint16 unusedFundsLendingMode; // Lending mode (1)
        address unusedFundsLendingContract; // Lending contract (ex. AAVE lending pool)
        address unusedFundsLendingToken; // (ex. aTokens)
        address unusedFundsIncentivesController; // (ex. AAVE incentives controller)
        address nodeStakingPool; // The staking pool of bank node
        address baseLiquidityToken; // Liquidity token contract (ex. USDT)
        address poolLiquidityToken; // Pool liquidity token contract (ex. Pool USDT)
        address nodePublicKey; // Bank node KYC public key
        uint32 kycMode; // kycMode Bank node KYC mode
    }

    function initialize(BankNodeInitializeArgsV1 calldata bankNodeInitConfig) external;

}

interface IBNPLBankNode is IBankNodeInitializableV1 {

    struct Loan {
        address borrower;
        uint256 loanAmount;
        uint64 totalLoanDuration;
        uint32 numberOfPayments;
        uint64 loanStartedAt;
        uint32 numberOfPaymentsMade;
        uint256 amountPerPayment;
        uint256 interestRatePerPayment;
        uint256 totalAmountPaid;
        uint256 remainingBalance;
        uint8 status; // 0 = ongoing, 1 = completed, 2 = overdue, 3 = written off
        uint64 statusUpdatedAt;
        uint256 loanRequestId;
    }

    function unusedFundsLendingMode() external view returns (uint16);


    function unusedFundsLendingContract() external view returns (IAaveLendingPool);


    function unusedFundsLendingToken() external view returns (IERC20);


    function unusedFundsIncentivesController() external view returns (IAaveIncentivesController);


    function bnplSwapMarket() external view returns (IBNPLSwapMarket);


    function bnplSwapMarketPoolFee() external view returns (uint24);


    function bankNodeId() external view returns (uint32);


    function getPoolTotalAssetsValue() external view returns (uint256);


    function getPoolTotalLiquidAssetsValue() external view returns (uint256);


    function nodeStakingPool() external view returns (IBNPLNodeStakingPool);


    function bankNodeManager() external view returns (IBankNodeManager);


    function baseTokenBalance() external view returns (uint256);


    function getValueOfUnusedFundsLendingDeposits() external view returns (uint256);


    function nodeOperatorBalance() external view returns (uint256);


    function accountsReceivableFromLoans() external view returns (uint256);


    function poolTokensCirculating() external view returns (uint256);


    function loanRequestIndex() external view returns (uint256);


    function onGoingLoanCount() external view returns (uint256);


    function loanIndex() external view returns (uint256);


    function totalAmountOfActiveLoans() external view returns (uint256);


    function totalAmountOfLoans() external view returns (uint256);


    function baseLiquidityToken() external view returns (IERC20);


    function poolLiquidityToken() external view returns (IMintableBurnableTokenUpgradeable);


    function interestPaidForLoan(uint256 loanId) external view returns (uint256);


    function totalLossAllTime() external view returns (uint256);


    function totalDonatedAllTime() external view returns (uint256);


    function netEarnings() external view returns (uint256);


    function totalLoansDefaulted() external view returns (uint256);


    function nodePublicKey() external view returns (address);


    function kycMode() external view returns (uint256);


    function kycDomainId() external view returns (uint32);


    function bnplKYCStore() external view returns (BNPLKYCStore);


    function loanRequests(uint256 _loanRequestId)
        external
        view
        returns (
            address borrower,
            uint256 loanAmount,
            uint64 totalLoanDuration,
            uint32 numberOfPayments,
            uint256 amountPerPayment,
            uint256 interestRatePerPayment,
            uint8 status, // 0 = under review, 1 = rejected, 2 = cancelled, 3 = *unused for now*, 4 = approved
            uint64 statusUpdatedAt,
            address statusModifiedBy,
            uint256 interestRate,
            uint256 loanId,
            uint8 messageType, // 0 = plain text, 1 = encrypted with the public key
            string memory message,
            string memory uuid
        );


    function loans(uint256 _loanId)
        external
        view
        returns (
            address borrower,
            uint256 loanAmount,
            uint64 totalLoanDuration,
            uint32 numberOfPayments,
            uint64 loanStartedAt,
            uint32 numberOfPaymentsMade,
            uint256 amountPerPayment,
            uint256 interestRatePerPayment,
            uint256 totalAmountPaid,
            uint256 remainingBalance,
            uint8 status, // 0 = ongoing, 1 = completed, 2 = overdue, 3 = written off
            uint64 statusUpdatedAt,
            uint256 loanRequestId
        );


    function donate(uint256 depositAmount) external;


    function addLiquidity(uint256 depositAmount) external;


    function removeLiquidity(uint256 poolTokensToConsume) external;


    function requestLoan(
        uint256 loanAmount,
        uint64 totalLoanDuration,
        uint32 numberOfPayments,
        uint256 interestRatePerPayment,
        uint8 messageType,
        string memory message,
        string memory uuid
    ) external;


    function denyLoanRequest(uint256 loanRequestId) external;


    function approveLoanRequest(uint256 loanRequestId) external;


    function makeLoanPayment(uint256 loanId, uint256 minTokenOut) external;


    function reportOverdueLoan(uint256 loanId, uint256 minTokenOut) external;


    function withdrawNodeOperatorBalance(uint256 amount, address to) external;


    function setKYCSettings(uint256 kycMode_, address nodePublicKey_) external;


    function setKYCDomainMode(uint32 domain, uint256 mode) external;


    function rewardToken() external view returns (IStakedToken);


    function getRewardsBalance() external view returns (uint256);


    function getCooldownStartTimestamp() external view returns (uint256);


    function getStakedTokenRewardsBalance() external view returns (uint256);


    function getStakedTokenBalance() external view returns (uint256);


    function claimLendingTokenInterest() external returns (uint256);

}// MIT
pragma solidity ^0.8.0;


contract UserTokenLockup is Initializable, IUserTokenLockup {

    event LockupCreated(address indexed user, uint32 vaultIndex, uint256 amount, uint64 unlockDate);

    event LockupClaimed(address indexed user, uint256 amount, uint32 vaultIndex);

    uint256 public override totalTokensLocked;

    mapping(address => uint256) public encodedLockupStatuses;

    mapping(uint256 => uint256) public encodedTokenLockups;

    function _UserTokenLockup_init_unchained() internal initializer {}


    function _getTime() internal view virtual returns (uint256) {

        return block.timestamp;
    }

    function _issueUnlockedTokensToUser(
        address, /*user*/
        uint256 /*amount*/
    ) internal virtual returns (uint256) {

        require(false, "you must override this function");
        return 0;
    }

    function createUserLockupStatus(
        uint256 tokensLocked,
        uint32 currentVaultIndex,
        uint32 numberOfActiveVaults
    ) internal pure returns (uint256) {

        return (tokensLocked << 64) | (uint256(currentVaultIndex) << 32) | uint256(numberOfActiveVaults);
    }

    function decodeUserLockupStatus(uint256 lockupStatus)
        internal
        pure
        returns (
            uint256 tokensLocked,
            uint32 currentVaultIndex,
            uint32 numberOfActiveVaults
        )
    {

        tokensLocked = lockupStatus >> 64;
        currentVaultIndex = uint32((lockupStatus >> 32) & 0xffffffff);
        numberOfActiveVaults = uint32(lockupStatus & 0xffffffff);
    }

    function createTokenLockupKey(address user, uint32 vaultIndex) internal pure returns (uint256) {

        return (uint256(uint160(user)) << 32) | uint256(vaultIndex);
    }

    function decodeTokenLockupKey(uint256 tokenLockupKey) internal pure returns (address user, uint32 vaultIndex) {

        vaultIndex = uint32(tokenLockupKey & 0xffffffff);
        user = address(uint160(tokenLockupKey >> 32));
    }

    function createTokenLockupValue(uint256 tokenAmount, uint64 unlockDate) internal pure returns (uint256) {

        return (uint256(unlockDate) << 192) | tokenAmount;
    }

    function decodeTokenLockupValue(uint256 tokenLockupValue)
        internal
        pure
        returns (uint256 tokenAmount, uint64 unlockDate)
    {

        tokenAmount = tokenLockupValue & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        unlockDate = uint32(tokenLockupValue >> 192);
    }

    function userLockupStatus(address user)
        public
        view
        returns (
            uint256 tokensLocked,
            uint32 currentVaultIndex,
            uint32 numberOfActiveVaults
        )
    {

        return decodeUserLockupStatus(encodedLockupStatuses[user]);
    }

    function getTokenLockup(address user, uint32 vaultIndex)
        public
        view
        returns (uint256 tokenAmount, uint64 unlockDate)
    {

        return decodeTokenLockupValue(encodedTokenLockups[createTokenLockupKey(user, vaultIndex)]);
    }

    function getNextTokenLockupForUser(address user)
        external
        view
        returns (
            uint256 tokenAmount,
            uint64 unlockDate,
            uint32 vaultIndex
        )
    {

        (, uint32 currentVaultIndex, ) = userLockupStatus(user);
        vaultIndex = currentVaultIndex;
        (tokenAmount, unlockDate) = getTokenLockup(user, currentVaultIndex);
    }

    function _createTokenLockup(
        address user,
        uint256 amount,
        uint64 unlockDate,
        bool allowAddToFutureVault
    ) internal returns (uint256) {

        require(amount > 0, "amount must be > 0");
        require(user != address(0), "cannot create a lockup for a null user");
        require(unlockDate > block.timestamp, "cannot create a lockup that expires now or in the past!");

        (uint256 tokensLocked, uint32 currentVaultIndex, uint32 numberOfActiveVaults) = userLockupStatus(user);
        require(
            amount < (0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - tokensLocked),
            "cannot store this many tokens in the locked contract at once!"
        );
        tokensLocked += amount;
        uint64 futureDate;

        if (
            numberOfActiveVaults != 0 &&
            currentVaultIndex != 0 &&
            (futureDate = uint64(encodedTokenLockups[createTokenLockupKey(user, currentVaultIndex)] >> 192)) >=
            unlockDate
        ) {
            require(
                allowAddToFutureVault || futureDate == unlockDate,
                "allowAddToFutureVault must be enabled to add to future vaults"
            );
            amount +=
                encodedTokenLockups[createTokenLockupKey(user, currentVaultIndex)] &
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            unlockDate = futureDate;
        } else {
            currentVaultIndex += 1;
            numberOfActiveVaults += 1;
        }

        totalTokensLocked += amount;

        encodedLockupStatuses[user] = createUserLockupStatus(tokensLocked, currentVaultIndex, numberOfActiveVaults);

        encodedTokenLockups[createTokenLockupKey(user, currentVaultIndex)] = createTokenLockupValue(amount, unlockDate);

        return currentVaultIndex;
    }

    function _claimNextTokenLockup(address user) internal returns (uint256) {

        require(user != address(0), "cannot claim for null user");
        (uint256 tokensLocked, uint32 currentVaultIndex, uint32 numberOfActiveVaults) = userLockupStatus(user);
        currentVaultIndex = currentVaultIndex + 1 - numberOfActiveVaults;

        require(tokensLocked > 0 && numberOfActiveVaults > 0 && currentVaultIndex > 0, "user has no tokens locked up!");
        (uint256 tokenAmount, uint64 unlockDate) = getTokenLockup(user, currentVaultIndex);
        require(tokenAmount > 0 && unlockDate <= _getTime(), "cannot claim tokens that have not matured yet!");
        numberOfActiveVaults -= 1;
        encodedLockupStatuses[user] = createUserLockupStatus(
            tokensLocked - tokenAmount,
            numberOfActiveVaults == 0 ? currentVaultIndex : (currentVaultIndex + 1),
            numberOfActiveVaults
        );
        require(totalTokensLocked >= tokenAmount, "not enough tokens locked in the contract!");
        totalTokensLocked -= tokenAmount;
        _issueUnlockedTokensToUser(user, tokenAmount);
        return tokenAmount;
    }

    function _claimUpToNextNTokenLockups(address user, uint32 maxNumberOfClaims) internal returns (uint256) {

        require(user != address(0), "cannot claim for null user");
        require(maxNumberOfClaims > 0, "cannot claim 0 lockups");
        (uint256 tokensLocked, uint32 currentVaultIndex, uint32 numberOfActiveVaults) = userLockupStatus(user);
        currentVaultIndex = currentVaultIndex + 1 - numberOfActiveVaults;

        require(tokensLocked > 0 && numberOfActiveVaults > 0 && currentVaultIndex > 0, "user has no tokens locked up!");
        uint256 curTimeShifted = _getTime() << 192;
        uint32 maxVaultIndex = (maxNumberOfClaims > numberOfActiveVaults ? numberOfActiveVaults : maxNumberOfClaims) +
            currentVaultIndex;
        uint256 userShifted = uint256(uint160(user)) << 32;
        uint256 totalAmountToClaim = 0;
        uint256 nextCandiate;

        while (
            currentVaultIndex < maxVaultIndex &&
            (nextCandiate = encodedTokenLockups[userShifted | uint256(currentVaultIndex)]) < curTimeShifted
        ) {
            totalAmountToClaim += nextCandiate & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
            currentVaultIndex++;
            numberOfActiveVaults--;
        }
        require(totalAmountToClaim > 0 && currentVaultIndex > 1, "cannot claim nothing!");
        require(totalAmountToClaim <= tokensLocked, "cannot claim more than total locked!");
        if (numberOfActiveVaults == 0) {
            currentVaultIndex--;
        }

        encodedLockupStatuses[user] = createUserLockupStatus(
            tokensLocked - totalAmountToClaim,
            currentVaultIndex,
            numberOfActiveVaults
        );
        require(totalTokensLocked >= totalAmountToClaim, "not enough tokens locked in the contract!");
        totalTokensLocked -= totalAmountToClaim;
        _issueUnlockedTokensToUser(user, totalAmountToClaim);
        return totalAmountToClaim;
    }
}// WTFPL
pragma solidity >=0.8.0;

library PRBMathCommon {

    uint256 internal constant SCALE = 1e18;

    uint256 internal constant SCALE_LPOTD = 262144;

    uint256 internal constant SCALE_INVERSE = 78156646155174841979727994598816262306175212592076161876661508869554232690281;

    function exp2(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = 0x80000000000000000000000000000000;

            if (x & 0x80000000000000000000000000000000 > 0) result = (result * 0x16A09E667F3BCC908B2FB1366EA957D3E) >> 128;
            if (x & 0x40000000000000000000000000000000 > 0) result = (result * 0x1306FE0A31B7152DE8D5A46305C85EDED) >> 128;
            if (x & 0x20000000000000000000000000000000 > 0) result = (result * 0x1172B83C7D517ADCDF7C8C50EB14A7920) >> 128;
            if (x & 0x10000000000000000000000000000000 > 0) result = (result * 0x10B5586CF9890F6298B92B71842A98364) >> 128;
            if (x & 0x8000000000000000000000000000000 > 0) result = (result * 0x1059B0D31585743AE7C548EB68CA417FE) >> 128;
            if (x & 0x4000000000000000000000000000000 > 0) result = (result * 0x102C9A3E778060EE6F7CACA4F7A29BDE9) >> 128;
            if (x & 0x2000000000000000000000000000000 > 0) result = (result * 0x10163DA9FB33356D84A66AE336DCDFA40) >> 128;
            if (x & 0x1000000000000000000000000000000 > 0) result = (result * 0x100B1AFA5ABCBED6129AB13EC11DC9544) >> 128;
            if (x & 0x800000000000000000000000000000 > 0) result = (result * 0x10058C86DA1C09EA1FF19D294CF2F679C) >> 128;
            if (x & 0x400000000000000000000000000000 > 0) result = (result * 0x1002C605E2E8CEC506D21BFC89A23A011) >> 128;
            if (x & 0x200000000000000000000000000000 > 0) result = (result * 0x100162F3904051FA128BCA9C55C31E5E0) >> 128;
            if (x & 0x100000000000000000000000000000 > 0) result = (result * 0x1000B175EFFDC76BA38E31671CA939726) >> 128;
            if (x & 0x80000000000000000000000000000 > 0) result = (result * 0x100058BA01FB9F96D6CACD4B180917C3E) >> 128;
            if (x & 0x40000000000000000000000000000 > 0) result = (result * 0x10002C5CC37DA9491D0985C348C68E7B4) >> 128;
            if (x & 0x20000000000000000000000000000 > 0) result = (result * 0x1000162E525EE054754457D5995292027) >> 128;
            if (x & 0x10000000000000000000000000000 > 0) result = (result * 0x10000B17255775C040618BF4A4ADE83FD) >> 128;
            if (x & 0x8000000000000000000000000000 > 0) result = (result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAC) >> 128;
            if (x & 0x4000000000000000000000000000 > 0) result = (result * 0x100002C5C89D5EC6CA4D7C8ACC017B7CA) >> 128;
            if (x & 0x2000000000000000000000000000 > 0) result = (result * 0x10000162E43F4F831060E02D839A9D16D) >> 128;
            if (x & 0x1000000000000000000000000000 > 0) result = (result * 0x100000B1721BCFC99D9F890EA06911763) >> 128;
            if (x & 0x800000000000000000000000000 > 0) result = (result * 0x10000058B90CF1E6D97F9CA14DBCC1629) >> 128;
            if (x & 0x400000000000000000000000000 > 0) result = (result * 0x1000002C5C863B73F016468F6BAC5CA2C) >> 128;
            if (x & 0x200000000000000000000000000 > 0) result = (result * 0x100000162E430E5A18F6119E3C02282A6) >> 128;
            if (x & 0x100000000000000000000000000 > 0) result = (result * 0x1000000B1721835514B86E6D96EFD1BFF) >> 128;
            if (x & 0x80000000000000000000000000 > 0) result = (result * 0x100000058B90C0B48C6BE5DF846C5B2F0) >> 128;
            if (x & 0x40000000000000000000000000 > 0) result = (result * 0x10000002C5C8601CC6B9E94213C72737B) >> 128;
            if (x & 0x20000000000000000000000000 > 0) result = (result * 0x1000000162E42FFF037DF38AA2B219F07) >> 128;
            if (x & 0x10000000000000000000000000 > 0) result = (result * 0x10000000B17217FBA9C739AA5819F44FA) >> 128;
            if (x & 0x8000000000000000000000000 > 0) result = (result * 0x1000000058B90BFCDEE5ACD3C1CEDC824) >> 128;
            if (x & 0x4000000000000000000000000 > 0) result = (result * 0x100000002C5C85FE31F35A6A30DA1BE51) >> 128;
            if (x & 0x2000000000000000000000000 > 0) result = (result * 0x10000000162E42FF0999CE3541B9FFFD0) >> 128;
            if (x & 0x1000000000000000000000000 > 0) result = (result * 0x100000000B17217F80F4EF5AADDA45554) >> 128;
            if (x & 0x800000000000000000000000 > 0) result = (result * 0x10000000058B90BFBF8479BD5A81B51AE) >> 128;
            if (x & 0x400000000000000000000000 > 0) result = (result * 0x1000000002C5C85FDF84BD62AE30A74CD) >> 128;
            if (x & 0x200000000000000000000000 > 0) result = (result * 0x100000000162E42FEFB2FED257559BDAA) >> 128;
            if (x & 0x100000000000000000000000 > 0) result = (result * 0x1000000000B17217F7D5A7716BBA4A9AF) >> 128;
            if (x & 0x80000000000000000000000 > 0) result = (result * 0x100000000058B90BFBE9DDBAC5E109CCF) >> 128;
            if (x & 0x40000000000000000000000 > 0) result = (result * 0x10000000002C5C85FDF4B15DE6F17EB0E) >> 128;
            if (x & 0x20000000000000000000000 > 0) result = (result * 0x1000000000162E42FEFA494F1478FDE05) >> 128;
            if (x & 0x10000000000000000000000 > 0) result = (result * 0x10000000000B17217F7D20CF927C8E94D) >> 128;
            if (x & 0x8000000000000000000000 > 0) result = (result * 0x1000000000058B90BFBE8F71CB4E4B33E) >> 128;
            if (x & 0x4000000000000000000000 > 0) result = (result * 0x100000000002C5C85FDF477B662B26946) >> 128;
            if (x & 0x2000000000000000000000 > 0) result = (result * 0x10000000000162E42FEFA3AE53369388D) >> 128;
            if (x & 0x1000000000000000000000 > 0) result = (result * 0x100000000000B17217F7D1D351A389D41) >> 128;
            if (x & 0x800000000000000000000 > 0) result = (result * 0x10000000000058B90BFBE8E8B2D3D4EDF) >> 128;
            if (x & 0x400000000000000000000 > 0) result = (result * 0x1000000000002C5C85FDF4741BEA6E77F) >> 128;
            if (x & 0x200000000000000000000 > 0) result = (result * 0x100000000000162E42FEFA39FE95583C3) >> 128;
            if (x & 0x100000000000000000000 > 0) result = (result * 0x1000000000000B17217F7D1CFB72B45E3) >> 128;
            if (x & 0x80000000000000000000 > 0) result = (result * 0x100000000000058B90BFBE8E7CC35C3F2) >> 128;
            if (x & 0x40000000000000000000 > 0) result = (result * 0x10000000000002C5C85FDF473E242EA39) >> 128;
            if (x & 0x20000000000000000000 > 0) result = (result * 0x1000000000000162E42FEFA39F02B772C) >> 128;
            if (x & 0x10000000000000000000 > 0) result = (result * 0x10000000000000B17217F7D1CF7D83C1A) >> 128;
            if (x & 0x8000000000000000000 > 0) result = (result * 0x1000000000000058B90BFBE8E7BDCBE2E) >> 128;
            if (x & 0x4000000000000000000 > 0) result = (result * 0x100000000000002C5C85FDF473DEA871F) >> 128;
            if (x & 0x2000000000000000000 > 0) result = (result * 0x10000000000000162E42FEFA39EF44D92) >> 128;
            if (x & 0x1000000000000000000 > 0) result = (result * 0x100000000000000B17217F7D1CF79E949) >> 128;
            if (x & 0x800000000000000000 > 0) result = (result * 0x10000000000000058B90BFBE8E7BCE545) >> 128;
            if (x & 0x400000000000000000 > 0) result = (result * 0x1000000000000002C5C85FDF473DE6ECA) >> 128;
            if (x & 0x200000000000000000 > 0) result = (result * 0x100000000000000162E42FEFA39EF366F) >> 128;
            if (x & 0x100000000000000000 > 0) result = (result * 0x1000000000000000B17217F7D1CF79AFA) >> 128;
            if (x & 0x80000000000000000 > 0) result = (result * 0x100000000000000058B90BFBE8E7BCD6E) >> 128;
            if (x & 0x40000000000000000 > 0) result = (result * 0x10000000000000002C5C85FDF473DE6B3) >> 128;
            if (x & 0x20000000000000000 > 0) result = (result * 0x1000000000000000162E42FEFA39EF359) >> 128;
            if (x & 0x10000000000000000 > 0) result = (result * 0x10000000000000000B17217F7D1CF79AC) >> 128;

            result = result << ((x >> 128) + 1);

            result = PRBMathCommon.mulDiv(result, 1e18, 2**128);
        }
    }

    function mostSignificantBit(uint256 x) internal pure returns (uint256 msb) {

        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            msb += 1;
        }
    }

    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {

        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        require(denominator > prod1);


        uint256 remainder;
        assembly {
            remainder := mulmod(x, y, denominator)

            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        unchecked {
            uint256 lpotdod = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, lpotdod)

                prod0 := div(prod0, lpotdod)

                lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
            }

            prod0 |= prod1 * lpotdod;

            uint256 inverse = (3 * denominator) ^ 2;

            inverse *= 2 - denominator * inverse; // inverse mod 2**8
            inverse *= 2 - denominator * inverse; // inverse mod 2**16
            inverse *= 2 - denominator * inverse; // inverse mod 2**32
            inverse *= 2 - denominator * inverse; // inverse mod 2**64
            inverse *= 2 - denominator * inverse; // inverse mod 2**128
            inverse *= 2 - denominator * inverse; // inverse mod 2**256

            result = prod0 * inverse;
            return result;
        }
    }

    function mulDivFixedPoint(uint256 x, uint256 y) internal pure returns (uint256 result) {

        uint256 prod0;
        uint256 prod1;
        assembly {
            let mm := mulmod(x, y, not(0))
            prod0 := mul(x, y)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        uint256 remainder;
        uint256 roundUpUnit;
        assembly {
            remainder := mulmod(x, y, SCALE)
            roundUpUnit := gt(remainder, 499999999999999999)
        }

        if (prod1 == 0) {
            unchecked {
                result = (prod0 / SCALE) + roundUpUnit;
                return result;
            }
        }

        require(SCALE > prod1);

        assembly {
            result := add(
                mul(
                    or(
                        div(sub(prod0, remainder), SCALE_LPOTD),
                        mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                    ),
                    SCALE_INVERSE
                ),
                roundUpUnit
            )
        }
    }

    function sqrt(uint256 x) internal pure returns (uint256 result) {

        if (x == 0) {
            return 0;
        }

        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
}// WTFPL
pragma solidity >=0.8.0;


library PRBMathUD60x18 {

    uint256 internal constant HALF_SCALE = 5e17;

    uint256 internal constant LOG2_E = 1442695040888963407;

    uint256 internal constant MAX_UD60x18 = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    uint256 internal constant MAX_WHOLE_UD60x18 = 115792089237316195423570985008687907853269984665640564039457000000000000000000;

    uint256 internal constant SCALE = 1e18;

    function avg(uint256 x, uint256 y) internal pure returns (uint256 result) {

        unchecked {
            result = (x >> 1) + (y >> 1) + (x & y & 1);
        }
    }

    function ceil(uint256 x) internal pure returns (uint256 result) {

        require(x <= MAX_WHOLE_UD60x18);
        assembly {
            let remainder := mod(x, SCALE)

            let delta := sub(SCALE, remainder)

            result := add(x, mul(delta, gt(remainder, 0)))
        }
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 result) {

        result = PRBMathCommon.mulDiv(x, SCALE, y);
    }

    function e() internal pure returns (uint256 result) {

        result = 2718281828459045235;
    }

    function exp(uint256 x) internal pure returns (uint256 result) {

        require(x < 88722839111672999628);

        unchecked {
            uint256 doubleScaleProduct = x * LOG2_E;
            result = exp2((doubleScaleProduct + HALF_SCALE) / SCALE);
        }
    }

    function exp2(uint256 x) internal pure returns (uint256 result) {

        require(x < 128e18);

        unchecked {
            uint256 x128x128 = (x << 128) / SCALE;

            result = PRBMathCommon.exp2(x128x128);
        }
    }

    function floor(uint256 x) internal pure returns (uint256 result) {

        assembly {
            let remainder := mod(x, SCALE)

            result := sub(x, mul(remainder, gt(remainder, 0)))
        }
    }

    function frac(uint256 x) internal pure returns (uint256 result) {

        assembly {
            result := mod(x, SCALE)
        }
    }

    function gm(uint256 x, uint256 y) internal pure returns (uint256 result) {

        if (x == 0) {
            return 0;
        }

        unchecked {
            uint256 xy = x * y;
            require(xy / x == y);

            result = PRBMathCommon.sqrt(xy);
        }
    }

    function inv(uint256 x) internal pure returns (uint256 result) {

        unchecked {
            result = 1e36 / x;
        }
    }

    function ln(uint256 x) internal pure returns (uint256 result) {

        unchecked { result = (log2(x) * SCALE) / LOG2_E; }
    }

    function log10(uint256 x) internal pure returns (uint256 result) {

        require(x >= SCALE);

        assembly {
            switch x
            case 1 { result := mul(SCALE, sub(0, 18)) }
            case 10 { result := mul(SCALE, sub(1, 18)) }
            case 100 { result := mul(SCALE, sub(2, 18)) }
            case 1000 { result := mul(SCALE, sub(3, 18)) }
            case 10000 { result := mul(SCALE, sub(4, 18)) }
            case 100000 { result := mul(SCALE, sub(5, 18)) }
            case 1000000 { result := mul(SCALE, sub(6, 18)) }
            case 10000000 { result := mul(SCALE, sub(7, 18)) }
            case 100000000 { result := mul(SCALE, sub(8, 18)) }
            case 1000000000 { result := mul(SCALE, sub(9, 18)) }
            case 10000000000 { result := mul(SCALE, sub(10, 18)) }
            case 100000000000 { result := mul(SCALE, sub(11, 18)) }
            case 1000000000000 { result := mul(SCALE, sub(12, 18)) }
            case 10000000000000 { result := mul(SCALE, sub(13, 18)) }
            case 100000000000000 { result := mul(SCALE, sub(14, 18)) }
            case 1000000000000000 { result := mul(SCALE, sub(15, 18)) }
            case 10000000000000000 { result := mul(SCALE, sub(16, 18)) }
            case 100000000000000000 { result := mul(SCALE, sub(17, 18)) }
            case 1000000000000000000 { result := 0 }
            case 10000000000000000000 { result := SCALE }
            case 100000000000000000000 { result := mul(SCALE, 2) }
            case 1000000000000000000000 { result := mul(SCALE, 3) }
            case 10000000000000000000000 { result := mul(SCALE, 4) }
            case 100000000000000000000000 { result := mul(SCALE, 5) }
            case 1000000000000000000000000 { result := mul(SCALE, 6) }
            case 10000000000000000000000000 { result := mul(SCALE, 7) }
            case 100000000000000000000000000 { result := mul(SCALE, 8) }
            case 1000000000000000000000000000 { result := mul(SCALE, 9) }
            case 10000000000000000000000000000 { result := mul(SCALE, 10) }
            case 100000000000000000000000000000 { result := mul(SCALE, 11) }
            case 1000000000000000000000000000000 { result := mul(SCALE, 12) }
            case 10000000000000000000000000000000 { result := mul(SCALE, 13) }
            case 100000000000000000000000000000000 { result := mul(SCALE, 14) }
            case 1000000000000000000000000000000000 { result := mul(SCALE, 15) }
            case 10000000000000000000000000000000000 { result := mul(SCALE, 16) }
            case 100000000000000000000000000000000000 { result := mul(SCALE, 17) }
            case 1000000000000000000000000000000000000 { result := mul(SCALE, 18) }
            case 10000000000000000000000000000000000000 { result := mul(SCALE, 19) }
            case 100000000000000000000000000000000000000 { result := mul(SCALE, 20) }
            case 1000000000000000000000000000000000000000 { result := mul(SCALE, 21) }
            case 10000000000000000000000000000000000000000 { result := mul(SCALE, 22) }
            case 100000000000000000000000000000000000000000 { result := mul(SCALE, 23) }
            case 1000000000000000000000000000000000000000000 { result := mul(SCALE, 24) }
            case 10000000000000000000000000000000000000000000 { result := mul(SCALE, 25) }
            case 100000000000000000000000000000000000000000000 { result := mul(SCALE, 26) }
            case 1000000000000000000000000000000000000000000000 { result := mul(SCALE, 27) }
            case 10000000000000000000000000000000000000000000000 { result := mul(SCALE, 28) }
            case 100000000000000000000000000000000000000000000000 { result := mul(SCALE, 29) }
            case 1000000000000000000000000000000000000000000000000 { result := mul(SCALE, 30) }
            case 10000000000000000000000000000000000000000000000000 { result := mul(SCALE, 31) }
            case 100000000000000000000000000000000000000000000000000 { result := mul(SCALE, 32) }
            case 1000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 33) }
            case 10000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 34) }
            case 100000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 35) }
            case 1000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 36) }
            case 10000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 37) }
            case 100000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 38) }
            case 1000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 39) }
            case 10000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 40) }
            case 100000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 41) }
            case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 42) }
            case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 43) }
            case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 44) }
            case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 45) }
            case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 46) }
            case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 47) }
            case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 48) }
            case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 49) }
            case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 50) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 51) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 52) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 53) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 54) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 55) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 56) }
            case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 57) }
            case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 58) }
            case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(SCALE, 59) }
            default {
                result := MAX_UD60x18
            }
        }

        if (result == MAX_UD60x18) {
            unchecked { result = (log2(x) * SCALE) / 332192809488736234; }
        }
    }

    function log2(uint256 x) internal pure returns (uint256 result) {

        require(x >= SCALE);
        unchecked {
            uint256 n = PRBMathCommon.mostSignificantBit(x / SCALE);

            result = n * SCALE;

            uint256 y = x >> n;

            if (y == SCALE) {
                return result;
            }

            for (uint256 delta = HALF_SCALE; delta > 0; delta >>= 1) {
                y = (y * y) / SCALE;

                if (y >= 2 * SCALE) {
                    result += delta;

                    y >>= 1;
                }
            }
        }
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 result) {

        result = PRBMathCommon.mulDivFixedPoint(x, y);
    }

    function pi() internal pure returns (uint256 result) {

        result = 3141592653589793238;
    }

    function pow(uint256 x, uint256 y) internal pure returns (uint256 result) {

        result = y & 1 > 0 ? x : SCALE;

        for (y >>= 1; y > 0; y >>= 1) {
            x = mul(x, x);

            if (y & 1 > 0) {
                result = mul(result, x);
            }
        }
    }

    function scale() internal pure returns (uint256 result) {

        result = SCALE;
    }

    function sqrt(uint256 x) internal pure returns (uint256 result) {

        require(x < 115792089237316195423570985008687907853269984665640564039458);
        unchecked {
            result = PRBMathCommon.sqrt(x * SCALE);
        }
    }
}// MIT
pragma solidity ^0.8.0;


library BankNodeUtils {

    using PRBMathUD60x18 for uint256;

    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function calculateSlashAmount(
        uint256 prevNodeBalance,
        uint256 nodeLoss,
        uint256 poolBalance
    ) internal pure returns (uint256) {

        uint256 slashRatio = (nodeLoss * PRBMathUD60x18.scale()).div(prevNodeBalance * PRBMathUD60x18.scale());
        return (poolBalance * slashRatio) / PRBMathUD60x18.scale();
    }

    function getMonthlyInterestPayment(
        uint256 loanAmount,
        uint256 interestAmount,
        uint256 numberOfPayments,
        uint256 currentMonth
    ) internal pure returns (uint256) {

        return
            (loanAmount *
                getPrincipleForMonth(interestAmount, numberOfPayments, currentMonth - 1).mul(interestAmount)) /
            PRBMathUD60x18.scale();
    }

    function getPrincipleForMonth(
        uint256 interestAmount,
        uint256 numberOfPayments,
        uint256 currentMonth
    ) internal pure returns (uint256) {

        uint256 ip1m = (PRBMathUD60x18.scale() + interestAmount).pow(currentMonth);
        uint256 right = getPaymentMultiplier(interestAmount, numberOfPayments).mul(
            (ip1m - PRBMathUD60x18.scale()).div(interestAmount)
        );
        return ip1m - right;
    }

    function getMonthlyPayment(
        uint256 loanAmount,
        uint256 interestAmount,
        uint256 numberOfPayments
    ) internal pure returns (uint256) {

        return (loanAmount * getPaymentMultiplier(interestAmount, numberOfPayments)) / PRBMathUD60x18.scale();
    }

    function getPaymentMultiplier(uint256 interestAmount, uint256 numberOfPayments) internal pure returns (uint256) {

        uint256 ip1n = (PRBMathUD60x18.scale() + interestAmount).pow(numberOfPayments);
        uint256 result = interestAmount.mul(ip1n).div((ip1n - PRBMathUD60x18.scale()));
        return result;
    }

    function getSwapExactTokensPath(address tokenIn, address tokenOut) internal pure returns (address[] memory) {

        address[] memory path = new address[](3);
        path[0] = address(tokenIn);
        path[1] = WETH;
        path[2] = address(tokenOut);
        return path;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }
}// GPL-3.0-or-later
pragma solidity ^0.8.0;

library TransferHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper::safeTransferETH: ETH transfer failed");
    }
}// MIT
pragma solidity ^0.8.0;






contract BNPLStakingPool is
    Initializable,
    ReentrancyGuardUpgradeable,
    AccessControlEnumerableUpgradeable,
    UserTokenLockup,
    IBNPLNodeStakingPool
{

    using PRBMathUD60x18 for uint256;
    event Stake(address indexed user, uint256 bnplStakeAmount, uint256 poolTokensMinted);

    event Unstake(address indexed user, uint256 bnplUnstakeAmount, uint256 poolTokensBurned);

    event Donation(address indexed user, uint256 donationAmount);

    event Bond(address indexed user, uint256 bondAmount);

    event Unbond(address indexed user, uint256 unbondAmount);

    event Slash(address indexed recipient, uint256 slashAmount);

    uint32 public constant BNPL_STAKER_NEEDS_KYC = 1 << 3;

    bytes32 public constant SLASHER_ROLE = keccak256("SLASHER_ROLE");
    bytes32 public constant NODE_REWARDS_MANAGER_ROLE = keccak256("NODE_REWARDS_MANAGER_ROLE");

    IERC20 public BASE_LIQUIDITY_TOKEN;

    IMintableBurnableTokenUpgradeable public POOL_LIQUIDITY_TOKEN;

    IBNPLBankNode public bankNode;

    IBankNodeManager public bankNodeManager;

    uint256 public override baseTokenBalance;

    uint256 public override tokensBondedAllTime;

    uint256 public override poolTokenEffectiveSupply;

    uint256 public override virtualPoolTokensCount;

    uint256 public totalDonatedAllTime;

    uint256 public totalSlashedAllTime;

    BNPLKYCStore public bnplKYCStore;

    uint32 public kycDomainId;

    function initialize(
        address bnplToken,
        address poolBNPLToken,
        address bankNodeContract,
        address bankNodeManagerContract,
        address tokenBonder,
        uint256 tokensToBond,
        BNPLKYCStore bnplKYCStore_,
        uint32 kycDomainId_
    ) external override initializer nonReentrant {

        require(bnplToken != address(0), "bnplToken cannot be 0");
        require(poolBNPLToken != address(0), "poolBNPLToken cannot be 0");
        require(bankNodeContract != address(0), "slasherAdmin cannot be 0");
        require(tokenBonder != address(0), "tokenBonder cannot be 0");
        require(tokensToBond > 0, "tokensToBond cannot be 0");

        __ReentrancyGuard_init_unchained();
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlEnumerable_init_unchained();

        BASE_LIQUIDITY_TOKEN = IERC20(bnplToken);
        POOL_LIQUIDITY_TOKEN = IMintableBurnableTokenUpgradeable(poolBNPLToken);

        bankNode = IBNPLBankNode(bankNodeContract);
        bankNodeManager = IBankNodeManager(bankNodeManagerContract);

        _setupRole(SLASHER_ROLE, bankNodeContract);
        _setupRole(NODE_REWARDS_MANAGER_ROLE, tokenBonder);

        require(BASE_LIQUIDITY_TOKEN.balanceOf(address(this)) >= tokensToBond, "tokens to bond not sent");
        baseTokenBalance = tokensToBond;
        tokensBondedAllTime = tokensToBond;
        poolTokenEffectiveSupply = tokensToBond;
        virtualPoolTokensCount = tokensToBond;
        bnplKYCStore = bnplKYCStore_;
        kycDomainId = kycDomainId_;
        POOL_LIQUIDITY_TOKEN.mint(address(this), tokensToBond);
        emit Bond(tokenBonder, tokensToBond);
    }

    function poolTokensCirculating() external view override returns (uint256) {

        return poolTokenEffectiveSupply - POOL_LIQUIDITY_TOKEN.balanceOf(address(this));
    }

    function getUnstakeLockupPeriod() public pure override returns (uint256) {

        return 7 days;
    }

    function getPoolTotalAssetsValue() public view override returns (uint256) {

        return baseTokenBalance;
    }

    function isNodeDecomissioning() public view override returns (bool) {

        return
            getPoolWithdrawConversion(POOL_LIQUIDITY_TOKEN.balanceOf(address(this))) <
            ((bankNodeManager.minimumBankNodeBondedAmount() * 75) / 100);
    }

    function getPoolDepositConversion(uint256 depositAmount) public view returns (uint256) {

        uint256 poolTotalAssetsValue = getPoolTotalAssetsValue();
        return (depositAmount * poolTokenEffectiveSupply) / (poolTotalAssetsValue > 0 ? poolTotalAssetsValue : 1);
    }

    function getPoolWithdrawConversion(uint256 withdrawAmount) public view override returns (uint256) {

        return
            (withdrawAmount * getPoolTotalAssetsValue()) /
            (poolTokenEffectiveSupply > 0 ? poolTokenEffectiveSupply : 1);
    }

    function _issueUnlockedTokensToUser(address user, uint256 amount) internal override returns (uint256) {

        require(
            amount != 0 && amount <= poolTokenEffectiveSupply,
            "poolTokenAmount cannot be 0 or more than circulating"
        );

        require(poolTokenEffectiveSupply != 0, "poolTokenEffectiveSupply must not be 0");
        require(getPoolTotalAssetsValue() != 0, "total asset value must not be 0");

        uint256 baseTokensOut = getPoolWithdrawConversion(amount);
        poolTokenEffectiveSupply -= amount;
        require(baseTokenBalance >= baseTokensOut, "base tokens balance must be >= out");
        baseTokenBalance -= baseTokensOut;
        TransferHelper.safeTransfer(address(BASE_LIQUIDITY_TOKEN), user, baseTokensOut);
        emit Unstake(user, baseTokensOut, amount);
        return baseTokensOut;
    }

    function _removeLiquidityAndLock(
        address user,
        uint256 poolTokensToConsume,
        uint256 unstakeLockupPeriod
    ) internal returns (uint256) {

        require(unstakeLockupPeriod != 0, "lockup period cannot be 0");
        require(user != address(this) && user != address(0), "invalid user");

        require(
            poolTokensToConsume > 0 && poolTokensToConsume <= poolTokenEffectiveSupply,
            "poolTokenAmount cannot be 0 or more than circulating"
        );

        require(poolTokenEffectiveSupply != 0, "poolTokenEffectiveSupply must not be 0");
        POOL_LIQUIDITY_TOKEN.burnFrom(user, poolTokensToConsume);
        _createTokenLockup(user, poolTokensToConsume, uint64(block.timestamp + unstakeLockupPeriod), true);
        return 0;
    }

    function _mintPoolTokensForUser(address user, uint256 mintAmount) private {

        require(user != address(0), "user cannot be null");

        require(mintAmount != 0, "mint amount cannot be 0");
        uint256 newMintTokensCirculating = poolTokenEffectiveSupply + mintAmount;
        poolTokenEffectiveSupply = newMintTokensCirculating;
        POOL_LIQUIDITY_TOKEN.mint(user, mintAmount);
        require(poolTokenEffectiveSupply == newMintTokensCirculating);
    }

    function _processDonation(
        address sender,
        uint256 depositAmount,
        bool countedIntoTotal
    ) private {

        require(sender != address(this) && sender != address(0), "invalid sender");
        require(depositAmount != 0, "depositAmount cannot be 0");

        require(poolTokenEffectiveSupply != 0, "poolTokenEffectiveSupply must not be 0");
        TransferHelper.safeTransferFrom(address(BASE_LIQUIDITY_TOKEN), sender, address(this), depositAmount);
        baseTokenBalance += depositAmount;
        if (countedIntoTotal) {
            totalDonatedAllTime += depositAmount;
        }
        emit Donation(sender, depositAmount);
    }

    function _processBondTokens(address sender, uint256 depositAmount) private {

        require(sender != address(this) && sender != address(0), "invalid sender");
        require(depositAmount != 0, "depositAmount cannot be 0");

        require(poolTokenEffectiveSupply != 0, "poolTokenEffectiveSupply must not be 0");
        TransferHelper.safeTransferFrom(address(BASE_LIQUIDITY_TOKEN), sender, address(this), depositAmount);
        uint256 selfMint = getPoolDepositConversion(depositAmount);
        _mintPoolTokensForUser(address(this), selfMint);
        virtualPoolTokensCount += selfMint;
        baseTokenBalance += depositAmount;
        tokensBondedAllTime += depositAmount;
        emit Bond(sender, depositAmount);
    }

    function _processUnbondTokens(address sender) private {

        require(sender != address(this) && sender != address(0), "invalid sender");
        require(bankNode.onGoingLoanCount() == 0, "Cannot unbond, there are ongoing loans");

        uint256 pTokens = POOL_LIQUIDITY_TOKEN.balanceOf(address(this));
        uint256 totalBonded = getPoolWithdrawConversion(pTokens);
        require(totalBonded != 0, "Insufficient bonded amount");

        TransferHelper.safeTransfer(address(BASE_LIQUIDITY_TOKEN), sender, totalBonded);
        POOL_LIQUIDITY_TOKEN.burn(pTokens);

        poolTokenEffectiveSupply -= pTokens;
        virtualPoolTokensCount -= pTokens;
        baseTokenBalance -= totalBonded;

        emit Unbond(sender, totalBonded);
    }

    function _setupLiquidityFirst(address user, uint256 depositAmount) private returns (uint256) {

        require(user != address(this) && user != address(0), "invalid user");
        require(depositAmount != 0, "depositAmount cannot be 0");

        require(poolTokenEffectiveSupply == 0, "poolTokenEffectiveSupply must be 0");
        uint256 totalAssetValue = getPoolTotalAssetsValue();

        TransferHelper.safeTransferFrom(address(BASE_LIQUIDITY_TOKEN), user, address(this), depositAmount);

        require(poolTokenEffectiveSupply == 0, "poolTokenEffectiveSupply must be 0");
        require(getPoolTotalAssetsValue() == totalAssetValue, "total asset value must not change");

        baseTokenBalance += depositAmount;
        uint256 newTotalAssetValue = getPoolTotalAssetsValue();
        require(newTotalAssetValue != 0 && newTotalAssetValue >= depositAmount);
        uint256 poolTokensOut = newTotalAssetValue;
        _mintPoolTokensForUser(user, poolTokensOut);
        emit Stake(user, depositAmount, poolTokensOut);
        return poolTokensOut;
    }

    function _addLiquidityNormal(address user, uint256 depositAmount) private returns (uint256) {

        require(user != address(this) && user != address(0), "invalid user");
        require(depositAmount != 0, "depositAmount cannot be 0");

        require(poolTokenEffectiveSupply != 0, "poolTokenEffectiveSupply must not be 0");
        require(getPoolTotalAssetsValue() != 0, "total asset value must not be 0");

        TransferHelper.safeTransferFrom(address(BASE_LIQUIDITY_TOKEN), user, address(this), depositAmount);
        require(poolTokenEffectiveSupply != 0, "poolTokenEffectiveSupply cannot be 0");

        uint256 totalAssetValue = getPoolTotalAssetsValue();
        require(totalAssetValue != 0, "total asset value cannot be 0");
        uint256 poolTokensOut = getPoolDepositConversion(depositAmount);

        baseTokenBalance += depositAmount;
        _mintPoolTokensForUser(user, poolTokensOut);
        emit Stake(user, depositAmount, poolTokensOut);
        return poolTokensOut;
    }

    function _addLiquidity(address user, uint256 depositAmount) private returns (uint256) {

        require(user != address(this) && user != address(0), "invalid user");
        require(!isNodeDecomissioning(), "BankNode bonded amount is less than 75% of the minimum");

        require(depositAmount != 0, "depositAmount cannot be 0");
        if (poolTokenEffectiveSupply == 0) {
            return _setupLiquidityFirst(user, depositAmount);
        } else {
            return _addLiquidityNormal(user, depositAmount);
        }
    }

    function _removeLiquidityNoLockup(address user, uint256 poolTokensToConsume) private returns (uint256) {

        require(user != address(this) && user != address(0), "invalid user");

        require(
            poolTokensToConsume != 0 && poolTokensToConsume <= poolTokenEffectiveSupply,
            "poolTokenAmount cannot be 0 or more than circulating"
        );

        require(poolTokenEffectiveSupply != 0, "poolTokenEffectiveSupply must not be 0");
        require(getPoolTotalAssetsValue() != 0, "total asset value must not be 0");

        uint256 baseTokensOut = getPoolWithdrawConversion(poolTokensToConsume);
        poolTokenEffectiveSupply -= poolTokensToConsume;
        require(baseTokenBalance >= baseTokensOut, "base tokens balance must be >= out");
        TransferHelper.safeTransferFrom(address(POOL_LIQUIDITY_TOKEN), user, address(this), poolTokensToConsume);
        require(baseTokenBalance >= baseTokensOut, "base tokens balance must be >= out");
        baseTokenBalance -= baseTokensOut;
        TransferHelper.safeTransfer(address(BASE_LIQUIDITY_TOKEN), user, baseTokensOut);
        emit Unstake(user, baseTokensOut, poolTokensToConsume);
        return baseTokensOut;
    }

    function _removeLiquidity(address user, uint256 poolTokensToConsume) internal returns (uint256) {

        require(poolTokensToConsume != 0, "poolTokensToConsume cannot be 0");
        uint256 unstakeLockupPeriod = getUnstakeLockupPeriod();
        if (unstakeLockupPeriod == 0) {
            return _removeLiquidityNoLockup(user, poolTokensToConsume);
        } else {
            return _removeLiquidityAndLock(user, poolTokensToConsume, unstakeLockupPeriod);
        }
    }

    function donate(uint256 donateAmount) external override nonReentrant {

        require(donateAmount != 0, "donateAmount cannot be 0");
        _processDonation(msg.sender, donateAmount, true);
    }

    function donateNotCountedInTotal(uint256 donateAmount) external override nonReentrant {

        require(donateAmount != 0, "donateAmount cannot be 0");
        _processDonation(msg.sender, donateAmount, false);
    }

    function bondTokens(uint256 bondAmount) external override nonReentrant onlyRole(NODE_REWARDS_MANAGER_ROLE) {

        require(bondAmount != 0, "bondAmount cannot be 0");
        _processBondTokens(msg.sender, bondAmount);
    }

    function unbondTokens() external override nonReentrant onlyRole(NODE_REWARDS_MANAGER_ROLE) {

        _processUnbondTokens(msg.sender);
    }

    function stakeTokens(uint256 stakeAmount) external override nonReentrant {

        require(
            bnplKYCStore.checkUserBasicBitwiseMode(kycDomainId, msg.sender, BNPL_STAKER_NEEDS_KYC) == 1,
            "borrower needs kyc"
        );
        require(stakeAmount != 0, "stakeAmount cannot be 0");
        _addLiquidity(msg.sender, stakeAmount);
    }

    function unstakeTokens(uint256 unstakeAmount) external override nonReentrant {

        require(unstakeAmount != 0, "unstakeAmount cannot be 0");
        _removeLiquidity(msg.sender, unstakeAmount);
    }

    function _slash(uint256 slashAmount, address recipient) private {

        require(slashAmount < getPoolTotalAssetsValue(), "cannot slash more than the pool balance");
        baseTokenBalance -= slashAmount;
        totalSlashedAllTime += slashAmount;
        TransferHelper.safeTransfer(address(BASE_LIQUIDITY_TOKEN), recipient, slashAmount);
        emit Slash(recipient, slashAmount);
    }

    function slash(uint256 slashAmount) external override onlyRole(SLASHER_ROLE) nonReentrant {

        _slash(slashAmount, msg.sender);
    }

    function getNodeOwnerPoolTokenRewards() public view override returns (uint256) {

        uint256 equivalentPoolTokens = getPoolDepositConversion(tokensBondedAllTime);
        uint256 ownerPoolTokens = POOL_LIQUIDITY_TOKEN.balanceOf(address(this));
        if (ownerPoolTokens > equivalentPoolTokens) {
            return ownerPoolTokens - equivalentPoolTokens;
        }
        return 0;
    }

    function getNodeOwnerBNPLRewards() external view override returns (uint256) {

        uint256 rewardsAmount = getNodeOwnerPoolTokenRewards();
        if (rewardsAmount != 0) {
            return getPoolWithdrawConversion(rewardsAmount);
        }
        return 0;
    }

    function claimNodeOwnerPoolTokenRewards(address to)
        external
        override
        onlyRole(NODE_REWARDS_MANAGER_ROLE)
        nonReentrant
    {

        uint256 poolTokenRewards = getNodeOwnerPoolTokenRewards();
        require(poolTokenRewards > 0, "cannot claim 0 rewards");
        virtualPoolTokensCount -= poolTokenRewards;
        POOL_LIQUIDITY_TOKEN.transfer(to, poolTokenRewards);
    }

    function calculateSlashAmount(
        uint256 prevNodeBalance,
        uint256 nodeLoss,
        uint256 poolBalance
    ) external pure returns (uint256) {

        uint256 slashRatio = (nodeLoss * PRBMathUD60x18.scale()).div(prevNodeBalance * PRBMathUD60x18.scale());
        return (poolBalance * slashRatio) / PRBMathUD60x18.scale();
    }

    function claimTokenLockup(address user) external nonReentrant returns (uint256) {

        return _claimNextTokenLockup(user);
    }

    function claimTokenNextNLockups(address user, uint32 maxNumberOfClaims) external nonReentrant returns (uint256) {

        return _claimUpToNextNTokenLockups(user, maxNumberOfClaims);
    }

    function unlockLendingTokenInterest() external onlyRole(NODE_REWARDS_MANAGER_ROLE) nonReentrant {

        bankNode.rewardToken().cooldown();
    }

    function distributeDividends() external onlyRole(NODE_REWARDS_MANAGER_ROLE) nonReentrant {

        bankNode.rewardToken().claimRewards(address(this), type(uint256).max);

        uint256 rewardTokenAmount = IERC20(address(bankNode.rewardToken())).balanceOf(address(this));
        require(rewardTokenAmount > 0, "rewardTokenAmount must be > 0");

        TransferHelper.safeApprove(address(bankNode.rewardToken()), address(bankNode.rewardToken()), rewardTokenAmount);
        bankNode.rewardToken().redeem(address(this), rewardTokenAmount);

        IERC20 swapToken = IERC20(bankNode.rewardToken().REWARD_TOKEN());

        uint256 donateAmount = bankNode.bnplSwapMarket().swapExactTokensForTokens(
            swapToken.balanceOf(address(this)),
            0,
            BankNodeUtils.getSwapExactTokensPath(address(swapToken), address(BASE_LIQUIDITY_TOKEN)),
            address(this),
            block.timestamp
        )[2];
        require(donateAmount > 0, "swap amount must be > 0");

        TransferHelper.safeApprove(address(BASE_LIQUIDITY_TOKEN), address(this), donateAmount);
        _processDonation(msg.sender, donateAmount, false);
    }
}