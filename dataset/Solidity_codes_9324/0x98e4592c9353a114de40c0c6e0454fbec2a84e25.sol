


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
}




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
}




pragma solidity ^0.8.0;

library EnumerableSet {


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
}




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
}




pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}




pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;

interface IERC1155ReceiverUpgradeable is IERC165Upgradeable {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}




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
}




pragma solidity ^0.8.0;



abstract contract ERC1155ReceiverUpgradeable is Initializable, ERC165Upgradeable, IERC1155ReceiverUpgradeable {
    function __ERC1155Receiver_init() internal initializer {
        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
    }

    function __ERC1155Receiver_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC1155ReceiverUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }
    uint256[50] private __gap;
}




pragma solidity ^0.8.0;


contract ERC1155HolderUpgradeable is Initializable, ERC1155ReceiverUpgradeable {

    function __ERC1155Holder_init() internal initializer {

        __ERC165_init_unchained();
        __ERC1155Receiver_init_unchained();
        __ERC1155Holder_init_unchained();
    }

    function __ERC1155Holder_init_unchained() internal initializer {

    }
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
    uint256[50] private __gap;
}




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
}




pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}




pragma solidity ^0.8.0;

interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}




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
}




pragma solidity ^0.8.0;

library StorageSlotUpgradeable {

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
}




pragma solidity ^0.8.2;




abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
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
            _functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}




pragma solidity ^0.8.0;


abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}




pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
}



pragma solidity ^0.8.10;

interface IAlturaNFTV2 {

    function initialize(
        string memory _name,
        string memory _uri,
        address _creator,
        address _factory,
        bool _public
    ) external;


    function addItem(
        uint256 maxSupply,
        uint256 supply,
        uint256 _fee
    ) external returns (uint256);


    function addItems(uint256 count, uint256 _fee) external;


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;


    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external returns (bool);


    function balanceOf(address account, uint256 id) external view returns (uint256);


    function creatorOf(uint256 id) external view returns (address);


    function royaltyOf(uint256 id) external view returns (uint256);

}



pragma solidity ^0.8.10;
interface IWETH {

    function deposit() external payable;


    function withdraw(uint256 wad) external;


    function transfer(address to, uint256 value) external returns (bool);

}

contract AlturaNFTFactoryV2 is
    UUPSUpgradeable,
    ERC1155HolderUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public constant PERCENTS_DIVIDER = 1000;
    uint256 public constant FEE_MAX_PERCENT = 300;
    uint256 public constant DEFAULT_FEE_PERCENT = 40;

    address public wethAddress;

    struct Item {
        uint256 item_id;
        address collection;
        uint256 token_id;
        address creator;
        address owner;
        uint256 balance;
        address currency;
        uint256 price;
        uint256 royalty;
        uint256 totalSold;
        bool bValid;
    }

    address[] public collections;
    mapping(address => address) public collectionCreators;
    mapping(uint256 => Item) public items;
    uint256 public currentItemId;

    uint256 public totalSold; /* Total NFT token amount sold */
    uint256 public totalSwapped; /* Total swap count */

    mapping(address => uint256) public swapFees; // swap fees (currency => fee) : percent divider = 1000
    address public feeAddress;

    EnumerableSet.AddressSet private _supportedTokens; //payment token (ERC20)

    address public targetAddress;

    struct Offer {
        uint256 item_id;
        address collection;
        uint256 token_id;
        address owner;
        uint256 amount;
        address currency;
        uint256 price;
        uint256 matched;
        uint256 expire;
        bool bValid;
    }
    uint256 public currentOfferId;
    mapping(uint256 => Offer) public offers;

    event CollectionCreated(address collection_address, address owner, string name, string uri, bool isPublic);
    event ItemListed(
        uint256 id,
        address collection,
        uint256 token_id,
        uint256 amount,
        uint256 price,
        address currency,
        address creator,
        address owner,
        uint256 royalty
    );
    event ItemDelisted(uint256 id, address collection, uint256 token_id);
    event ItemPriceUpdated(uint256 id, address collection, uint256 token_id, uint256 price, address currency);
    event ItemAdded(uint256 id, uint256 amount, uint256 balance);
    event ItemRemoved(uint256 id, uint256 amount, uint256 balance);

    event Swapped(address buyer, address seller, uint256 id, address collection, uint256 token_id, uint256 amount);

    event OfferCreated(
        uint256 id,
        uint256 item_id,
        address collection,
        uint256 token_id,
        uint256 amount,
        uint256 price,
        address currency,
        uint256 expire,
        address creator
    );

    event OfferMatched(
        uint256 id,
        uint256 amount,
        uint256 price,
        address currency,
        uint256 matched,
        address buyer,
        address seller
    );

    event OfferCancelled(uint256 id, uint256 amount);

    function initialize(address _fee, address _weth) public initializer {

        __Ownable_init();
        __ERC1155Holder_init();
        __ReentrancyGuard_init();

        wethAddress = _weth;

        feeAddress = _fee;
        swapFees[address(0x0)] = 40;

        createCollection("AlturaNFT", "https://api.alturanft.com/meta/alturanft/", true);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}


    function setFeeAddress(address _address) external onlyOwner {

        require(_address != address(0x0), "invalid address");
        feeAddress = _address;
    }

    function setSwapFeePercent(address currency, uint256 _percent) external onlyOwner {

        require(_percent < FEE_MAX_PERCENT, "too big swap fee");
        swapFees[currency] = _percent;
    }

    function setTarget(address _target) external onlyOwner {

        require(_target != address(0), "!zero address");

        targetAddress = _target;
    }

    function createCollection(
        string memory _name,
        string memory _uri,
        bool bPublic
    ) public returns (address collection) {

        collection = Clones.clone(targetAddress);
        IAlturaNFTV2(collection).initialize(_name, _uri, msg.sender, address(this), bPublic);

        collections.push(collection);
        collectionCreators[collection] = msg.sender;

        emit CollectionCreated(collection, msg.sender, _name, _uri, bPublic);
    }

    function list(
        address _collection,
        uint256 _token_id,
        uint256 _amount,
        uint256 _price,
        address _currency,
        bool _bMint
    ) public {

        require(_price > 0, "invalid price");
        require(_amount > 0, "invalid amount");

        IAlturaNFTV2 nft = IAlturaNFTV2(_collection);
        if (_bMint) {
            require(nft.mint(address(this), _token_id, _amount, "Mint by AluturaNFT"), "mint failed");
        } else {
            nft.safeTransferFrom(msg.sender, address(this), _token_id, _amount, "List");
        }

        currentItemId = currentItemId.add(1);
        items[currentItemId].item_id = currentItemId;
        items[currentItemId].collection = _collection;
        items[currentItemId].token_id = _token_id;
        items[currentItemId].owner = msg.sender;
        items[currentItemId].balance = _amount;
        items[currentItemId].price = _price;
        items[currentItemId].currency = _currency;
        items[currentItemId].bValid = true;

        try nft.creatorOf(_token_id) returns (address creator) {
            items[currentItemId].creator = creator;
            items[currentItemId].royalty = nft.royaltyOf(_token_id);
        } catch (
            bytes memory /*lowLevelData*/
        ) {}

        emit ItemListed(
            currentItemId,
            _collection,
            _token_id,
            _amount,
            _price,
            _currency,
            items[currentItemId].creator,
            msg.sender,
            items[currentItemId].royalty
        );
    }

    function delist(uint256 _id) external {

        require(items[_id].bValid, "invalid Item id");
        require(items[_id].owner == msg.sender || msg.sender == owner(), "only owner can delist");

        IAlturaNFTV2(items[_id].collection).safeTransferFrom(
            address(this),
            items[_id].owner,
            items[_id].token_id,
            items[_id].balance,
            "delist from Altura Marketplace"
        );
        items[_id].balance = 0;
        items[_id].bValid = false;

        emit ItemDelisted(_id, items[_id].collection, items[_id].token_id);
    }

    function addItems(uint256 _id, uint256 _amount) external {

        require(items[_id].bValid, "invalid Item id");
        require(items[_id].owner == msg.sender, "only owner can add items");

        IAlturaNFTV2(items[_id].collection).safeTransferFrom(
            msg.sender,
            address(this),
            items[_id].token_id,
            _amount,
            "add items to Altura Marketplace"
        );
        items[_id].balance = items[_id].balance.add(_amount);

        emit ItemAdded(_id, _amount, items[_id].balance);
    }

    function removeItems(uint256 _id, uint256 _amount) external {

        require(items[_id].bValid, "invalid Item id");
        require(items[_id].owner == msg.sender, "only owner can remove items");

        IAlturaNFTV2(items[_id].collection).safeTransferFrom(
            address(this),
            msg.sender,
            items[_id].token_id,
            _amount,
            "remove items from Altura Marketplace"
        );
        items[_id].balance = items[_id].balance.sub(_amount, "insufficient balance of item");

        emit ItemRemoved(_id, _amount, items[_id].balance);
    }

    function updatePrice(
        uint256 _id,
        address _currency,
        uint256 _price
    ) external {

        require(_price > 0, "invalid new price");
        require(items[_id].bValid, "invalid Item id");
        require(items[_id].owner == msg.sender || msg.sender == owner(), "only owner can update price");

        items[_id].price = _price;
        items[_id].currency = _currency;

        emit ItemPriceUpdated(_id, items[_id].collection, items[_id].token_id, _price, _currency);
    }

    function buy(uint256 _id, uint256 _amount) external payable nonReentrant {

        require(items[_id].bValid, "invalid Item id");
        require(items[_id].balance >= _amount, "insufficient NFT balance");
        require(items[_id].currency != address(0x0) || items[_id].price.mul(_amount) == msg.value, "Invalid amount");

        Item memory item = items[_id];
        uint256 swapFee = swapFees[item.currency];
        if (swapFee == 0x0) {
            swapFee = DEFAULT_FEE_PERCENT;
        }
        uint256 plutusAmount = item.price.mul(_amount);
        uint256 ownerPercent = PERCENTS_DIVIDER.sub(swapFee).sub(item.royalty);

        if (item.currency == address(0x0)) {
            if (swapFee > 0) {
                require(
                    _safeTransferETH(feeAddress, plutusAmount.mul(swapFee).div(PERCENTS_DIVIDER)),
                    "failed to transfer admin fee"
                );
            }
            if (item.royalty > 0) {
                require(
                    _safeTransferETH(item.creator, plutusAmount.mul(item.royalty).div(PERCENTS_DIVIDER)),
                    "failed to transfer creator fee"
                );
            }
            require(
                _safeTransferETH(item.owner, plutusAmount.mul(ownerPercent).div(PERCENTS_DIVIDER)),
                "failed to transfer to owner"
            );
        } else {
            if (swapFee > 0) {
                require(
                    IERC20(item.currency).transferFrom(
                        msg.sender,
                        feeAddress,
                        plutusAmount.mul(swapFee).div(PERCENTS_DIVIDER)
                    ),
                    "failed to transfer admin fee"
                );
            }
            if (item.royalty > 0) {
                require(
                    IERC20(item.currency).transferFrom(
                        msg.sender,
                        item.creator,
                        plutusAmount.mul(item.royalty).div(PERCENTS_DIVIDER)
                    ),
                    "failed to transfer creator fee"
                );
            }
            require(
                IERC20(item.currency).transferFrom(
                    msg.sender,
                    item.owner,
                    plutusAmount.mul(ownerPercent).div(PERCENTS_DIVIDER)
                ),
                "failed to transfer to owner"
            );
        }

        IAlturaNFTV2(items[_id].collection).safeTransferFrom(
            address(this),
            msg.sender,
            item.token_id,
            _amount,
            "buy from Altura Marketplace"
        );

        items[_id].balance = items[_id].balance.sub(_amount);
        items[_id].totalSold = items[_id].totalSold.add(_amount);

        totalSold = totalSold.add(_amount);
        totalSwapped = totalSwapped.add(1);

        emit Swapped(msg.sender, item.owner, _id, items[_id].collection, items[_id].token_id, _amount);
    }

    function makeOffer(
        address _collection,
        uint256 _token_id,
        uint256 _amount,
        address _currency,
        uint256 _price,
        uint256 _expire
    ) external {

        require(_price > 0, "invalid price");
        require(_expire > block.timestamp, "invalid expire");
        require(_currency != address(0x0), "not allow native asset");
        require(
            _price.mul(_amount) <= IERC20(_currency).balanceOf(msg.sender) &&
                _price.mul(_amount) <= IERC20(_currency).allowance(msg.sender, address(this)),
            "insufficient balance or allowance"
        );

        currentOfferId = currentOfferId.add(1);
        offers[currentOfferId].collection = _collection;
        offers[currentOfferId].token_id = _token_id;
        offers[currentOfferId].owner = msg.sender;
        offers[currentOfferId].amount = _amount;
        offers[currentOfferId].currency = _currency;
        offers[currentOfferId].price = _price;
        offers[currentOfferId].matched = 0;
        offers[currentOfferId].expire = _expire;
        offers[currentOfferId].bValid = true;

        emit OfferCreated(currentOfferId, 0, _collection, _token_id, _amount, _price, _currency, _expire, msg.sender);
    }

    function acceptOffer(uint256 _offerId, uint256 _amount) external {

        Offer memory offer = offers[_offerId];
        require(offer.bValid, "invalid Offer id");
        require(offer.owner != msg.sender, "offer owner can't accept offer");
        require(offer.expire > block.timestamp, "offer expired");
        require(offer.amount.sub(offer.matched) >= _amount, "insufficient offer amount");

        uint256 balance = IAlturaNFTV2(offer.collection).balanceOf(msg.sender, offer.token_id);
        require(balance >= _amount, "insufficient NFT balance");

        uint256 swapFee = swapFees[offer.currency];
        if (swapFee == 0x0) {
            swapFee = DEFAULT_FEE_PERCENT;
        }
        uint256 plutusAmount = offer.price.mul(_amount);
        uint256 royalty = IAlturaNFTV2(offer.collection).royaltyOf(offer.token_id);

        if (swapFee > 0) {
            require(
                IERC20(offer.currency).transferFrom(
                    offer.owner,
                    feeAddress,
                    plutusAmount.mul(swapFee).div(PERCENTS_DIVIDER)
                ),
                "failed to transfer admin fee"
            );
        }
        if (royalty > 0) {
            require(
                IERC20(offer.currency).transferFrom(
                    offer.owner,
                    IAlturaNFTV2(offer.collection).creatorOf(offer.token_id),
                    plutusAmount.mul(royalty).div(PERCENTS_DIVIDER)
                ),
                "failed to transfer creator fee"
            );
        }
        require(
            IERC20(offer.currency).transferFrom(
                offer.owner,
                msg.sender,
                plutusAmount.mul(PERCENTS_DIVIDER.sub(swapFee).sub(royalty)).div(PERCENTS_DIVIDER)
            ),
            "failed to transfer to owner"
        );

        IAlturaNFTV2(offer.collection).safeTransferFrom(
            msg.sender,
            offer.owner,
            offer.token_id,
            _amount,
            "buy from Altura"
        );

        offers[_offerId].matched = offers[_offerId].matched.add(_amount);
        offers[_offerId].bValid = offers[_offerId].matched < offers[_offerId].amount;

        totalSold = totalSold.add(_amount);
        totalSwapped = totalSwapped.add(1);

        emit OfferMatched(
            _offerId,
            _amount,
            offer.price,
            offer.currency,
            offers[_offerId].matched,
            offer.owner,
            msg.sender
        );
    }

    function cancelOffer(uint256 _id, uint256 _amount) external {

        Offer memory offer = offers[_id];
        require(offer.bValid, "invalid Offer id");
        require(offer.owner == msg.sender, "owner can cancel offer");
        require(_amount > 0 && offer.amount >= offer.matched + _amount, "invalid amount");

        uint256 remaining = offer.amount.sub(offer.matched).sub(_amount);
        offers[_id].matched = offers[_id].matched.add(_amount);
        if (remaining == 0) {
            offers[_id].bValid = false;
        }

        emit OfferCancelled(_id, _amount);
    }

    function _safeTransferETH(address to, uint256 value) internal returns (bool) {

        (bool success, ) = to.call{value: value}(new bytes(0));
        if (!success) {
            IWETH(wethAddress).deposit{value: value}();
            return IERC20(wethAddress).transfer(to, value);
        }
        return success;
    }

    receive() external payable {}

    uint256[49] private __gap;
}