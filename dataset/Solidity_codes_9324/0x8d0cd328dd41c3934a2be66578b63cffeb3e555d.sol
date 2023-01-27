
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

library Strings {

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


contract LootClassification
{

    enum Type
    {
        Weapon,
        Chest,
        Head,
        Waist,
        Foot,
        Hand,
        Neck,
        Ring
    }
    
    enum Material
    {
        Heavy,
        Medium,
        Dark,
        Light,
        Cloth,
        Hide,
        Metal,
        Jewellery
    }
    
    enum Class
    {
        Warrior,
        Hunter,
        Mage,
        Any
    }
    
    uint256 constant public WeaponLastHeavyIndex = 4;
    uint256 constant public WeaponLastMediumIndex = 9;
    uint256 constant public WeaponLastDarkIndex = 13;
    
    function getWeaponMaterial(uint256 index) pure public returns(Material)
    {

        if (index <= WeaponLastHeavyIndex)
            return Material.Heavy;
        
        if (index <= WeaponLastMediumIndex)
            return Material.Medium;
        
        if (index <= WeaponLastDarkIndex)
            return Material.Dark;
        
        return Material.Light;
    }
    
    function getWeaponRank(uint256 index) pure public returns (uint256)
    {

        if (index <= WeaponLastHeavyIndex)
            return index + 1;
        
        if (index <= WeaponLastMediumIndex)
            return index - 4;
        
        if (index <= WeaponLastDarkIndex)
            return index - 9;
        
        return index -13;
    }
    
    uint256 constant public ChestLastClothIndex = 4;
    uint256 constant public ChestLastLeatherIndex = 9;
    
    function getChestMaterial(uint256 index) pure public returns(Material)
    {

        if (index <= ChestLastClothIndex)
            return Material.Cloth;
        
        if (index <= ChestLastLeatherIndex)
            return Material.Hide;
        
        return Material.Metal;
    }
    
    function getChestRank(uint256 index) pure public returns (uint256)
    {

        if (index <= ChestLastClothIndex)
            return index + 1;
        
        if (index <= ChestLastLeatherIndex)
            return index - 4;
        
        return index - 9;
    }
    
    uint256 constant public ArmourLastMetalIndex = 4;
    uint256 constant public ArmourLasLeatherIndex = 9;
    
    function getArmourMaterial(uint256 index) pure public returns(Material)
    {

        if (index <= ArmourLastMetalIndex)
            return Material.Metal;
        
        if (index <= ArmourLasLeatherIndex)
            return Material.Hide;
        
        return Material.Cloth;
    }
    
    function getArmourRank(uint256 index) pure public returns (uint256)
    {

        if (index <= ArmourLastMetalIndex)
            return index + 1;
        
        if (index <= ArmourLasLeatherIndex)
            return index - 4;
        
        return index - 9;
    }
    
    function getRingRank(uint256 index) pure public returns (uint256)
    {

        if (index > 2)
            return 1;
        else 
            return index + 1;
    }
    
    function getNeckRank(uint256 /*index*/) pure public returns (uint256)
    {

        return 1;
    }
    
    function getMaterial(Type lootType, uint256 index) pure public returns (Material)
    {

         if (lootType == Type.Weapon)
            return getWeaponMaterial(index);
            
        if (lootType == Type.Chest)
            return getChestMaterial(index);
            
        if (lootType == Type.Head ||
            lootType == Type.Waist ||
            lootType == Type.Foot ||
            lootType == Type.Hand)
        {
            return getArmourMaterial(index);
        }
            
        return Material.Jewellery;
    }
    
    function getClass(Type lootType, uint256 index) pure public returns (Class)
    {

        Material material = getMaterial(lootType, index);
        return getClassFromMaterial(material);
    }

    function getClassFromMaterial(Material material) pure public returns (Class)
    {   

        if (material == Material.Heavy || material == Material.Metal)
            return Class.Warrior;
            
        if (material == Material.Medium || material == Material.Hide)
            return Class.Hunter;
            
        if (material == Material.Dark || material == Material.Light || material == Material.Cloth)
            return Class.Mage;
            
        return Class.Any;
        
    }
    
    function getRank(Type lootType, uint256 index) pure public returns (uint256)
    {

        if (lootType == Type.Weapon)
            return getWeaponRank(index);
            
        if (lootType == Type.Chest)
            return getChestRank(index);
        
        if (lootType == Type.Head ||
            lootType == Type.Waist ||
            lootType == Type.Foot ||
            lootType == Type.Hand)
        {
            return getArmourRank(index);
        }
        
        if (lootType == Type.Ring)
            return getRingRank(index);
            
        return getNeckRank(index);  
    }

    function getLevel(Type lootType, uint256 index) pure public returns (uint256)
    {

        if (lootType == Type.Chest ||
            lootType == Type.Weapon ||
            lootType == Type.Head ||
            lootType == Type.Waist ||
            lootType == Type.Foot ||
            lootType == Type.Hand)
        {
            return 6 - getRank(lootType, index);
        } else {
            return 4 - getRank(lootType, index); 
        }
    }


    uint256 constant WEAPON_COUNT = 18;
    uint256 constant CHEST_COUNT = 15;
    uint256 constant HEAD_COUNT = 15;
    uint256 constant WAIST_COUNT = 15;
    uint256 constant FOOT_COUNT = 15;
    uint256 constant HAND_COUNT = 15;
    uint256 constant NECK_COUNT = 3;
    uint256 constant RING_COUNT = 5;
    uint256 constant SUFFIX_COUNT = 16;
    uint256 constant NAME_PREFIX_COUNT = 69;
    uint256 constant NAME_SUFFIX_COUNT = 18;

    function random(string memory input) internal pure returns (uint256) 
    {

        return uint256(keccak256(abi.encodePacked(input)));
    }

    function weaponComponents(uint256 tokenId) public pure returns (uint256[6] memory) 
    {

        return tokenComponents(tokenId, "WEAPON", WEAPON_COUNT);
    }
    
    function chestComponents(uint256 tokenId) public pure returns (uint256[6] memory) 
    {

        return tokenComponents(tokenId, "CHEST", CHEST_COUNT);
    }
    
    function headComponents(uint256 tokenId) public pure returns (uint256[6] memory) 
    {

        return tokenComponents(tokenId, "HEAD", HEAD_COUNT);
    }
    
    function waistComponents(uint256 tokenId) public pure returns (uint256[6] memory) 
    {

        return tokenComponents(tokenId, "WAIST", WAIST_COUNT);
    }

    function footComponents(uint256 tokenId) public pure returns (uint256[6] memory) 
    {

        return tokenComponents(tokenId, "FOOT", FOOT_COUNT);
    }
    
    function handComponents(uint256 tokenId) public pure returns (uint256[6] memory) 
    {

        return tokenComponents(tokenId, "HAND", HAND_COUNT);
    }
    
    function neckComponents(uint256 tokenId) public pure returns (uint256[6] memory) 
    {

        return tokenComponents(tokenId, "NECK", NECK_COUNT);
    }
    
    function ringComponents(uint256 tokenId) public pure returns (uint256[6] memory) 
    {

        return tokenComponents(tokenId, "RING", RING_COUNT);
    }

    function tokenComponents(uint256 tokenId, string memory keyPrefix, uint256 itemCount) 
        internal pure returns (uint256[6] memory) 
    {

        uint256[6] memory components;
        
        uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId))));
        
        components[0] = rand % itemCount;
        components[1] = 0;
        components[2] = 0;
        
        components[5] = rand % 21; //aka greatness
        if (components[5] > 14) {
            components[1] = (rand % SUFFIX_COUNT) + 1;
        }
        if (components[5] >= 19) {
            components[2] = (rand % NAME_PREFIX_COUNT) + 1;
            components[3] = (rand % NAME_SUFFIX_COUNT) + 1;
            if (components[5] == 19) {
            } else {
                components[4] = 1;
            }
        }
        return components;
    }

    function toString(uint256 value) internal pure returns (string memory) 
    {


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
pragma solidity ^0.8.0;




contract Proxy
{

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    constructor(address implementation, bytes memory data) payable
    {
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = implementation;
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = msg.sender;

        if (data.length > 0)
        {
            Address.functionDelegateCall(implementation, data, /*errorMessage*/ "init failed");
        }
    }

    fallback() external payable
    {
        _fallback();
    }

    receive() external payable 
    {
        _fallback();
    }

    function _fallback() private
    {

        address implementation = StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;

        assembly 
        {
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
}// MIT
pragma solidity ^0.8.0;




contract ProxyImplementation is Initializable
{

    bytes32 private constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    bytes32 private constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier onlyAdmin() 
    {

        require(admin() == msg.sender, "Implementation: caller is not admin");
        _;
    }

    modifier onlyOwner() 
    {

        require(owner() == msg.sender, "Implementation: caller is not owner");
        _;
    }

    function getImplementation() public view returns(address)
    {

        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function setImplementation(address implementation) public virtual onlyAdmin
    {

        require(AddressUpgradeable.isContract(implementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = implementation;
    }

    function admin() public view returns(address)
    {

        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function owner() public view returns(address)
    {

        return admin();
    }

    function setAdmin(address newAdmin) public virtual onlyAdmin
    {

        require(newAdmin != address(0), "invalid newAdmin address");
        _setAdmin(newAdmin);
    }

    function renounceAdminPowers() public virtual onlyAdmin
    {

        _setAdmin(address(0));
    }

    function _setAdmin(address newAdmin) private
    {

        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

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


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {

    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {

        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {

        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {

        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {

        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {

        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {

        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {

        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {

        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {

        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {

        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {

        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {

        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {

        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {

        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    uint256[44] private __gap;
}// MIT
pragma solidity ^0.8.0;



abstract contract ContextMixin 
{
    function msgSender() internal view returns (address payable sender)
    {
        if (msg.sender == address(this)) 
        {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly 
            {
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } 
        else 
        {
            sender = payable(msg.sender);
        }
        return sender;
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

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


contract EIP712BaseUpgradeable is Initializable {

    struct EIP712Domain {
        string name;
        string version;
        address verifyingContract;
        bytes32 salt;
    }

    string constant public ERC712_VERSION = "1";

    bytes32 internal constant EIP712_DOMAIN_TYPEHASH = keccak256(
        bytes(
            "EIP712Domain(string name,string version,address verifyingContract,bytes32 salt)"
        )
    );
    bytes32 internal domainSeperator;

    function _initializeEIP712(
        string memory name
    )
        internal
        initializer
    {

        _setDomainSeperator(name);
    }

    function _setDomainSeperator(string memory name) internal {

        domainSeperator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(ERC712_VERSION)),
                address(this),
                bytes32(getChainId())
            )
        );
    }

    function getDomainSeperator() public view returns (bytes32) {

        return domainSeperator;
    }

    function getChainId() public view returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function toTypedMessageHash(bytes32 messageHash)
        internal
        view
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19\x01", getDomainSeperator(), messageHash)
            );
    }
}// MIT

pragma solidity ^0.8.0;


contract NativeMetaTransactionUpgradeable is EIP712BaseUpgradeable {

    using SafeMathUpgradeable for uint256;
    bytes32 private constant META_TRANSACTION_TYPEHASH = keccak256(
        bytes(
            "MetaTransaction(uint256 nonce,address from,bytes functionSignature)"
        )
    );
    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );
    mapping(address => uint256) nonces;

    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) public payable returns (bytes memory) {

        MetaTransaction memory metaTx = MetaTransaction({
            nonce: nonces[userAddress],
            from: userAddress,
            functionSignature: functionSignature
        });

        require(
            verify(userAddress, metaTx, sigR, sigS, sigV),
            "Signer and signature do not match"
        );

        nonces[userAddress] = nonces[userAddress].add(1);

        emit MetaTransactionExecuted(
            userAddress,
            payable(msg.sender),
            functionSignature
        );

        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );
        require(success, "Function call not successful");

        return returnData;
    }

    function hashMetaTransaction(MetaTransaction memory metaTx)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encode(
                    META_TRANSACTION_TYPEHASH,
                    metaTx.nonce,
                    metaTx.from,
                    keccak256(metaTx.functionSignature)
                )
            );
    }

    function getNonce(address user) public view returns (uint256 nonce) {

        nonce = nonces[user];
    }

    function verify(
        address signer,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {

        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");
        return
            signer ==
            ecrecover(
                toTypedMessageHash(hashMetaTransaction(metaTx)),
                sigV,
                sigR,
                sigS
            );
    }
}// MIT
pragma solidity ^0.8.0;



contract OwnableDelegateProxy {}


contract ProxyRegistry {

    mapping(address => OwnableDelegateProxy) public proxies;
}

abstract contract ERC721TradableUpgradeable is ContextMixin, ERC721Upgradeable, NativeMetaTransactionUpgradeable
{
    using SafeMathUpgradeable for uint256;

    address proxyRegistryAddress;
    uint256 private _currentTokenId = 0;

    function __ERC721TradableUpgradeable_init_unchained(address _proxyRegistryAddress) internal initializer
    {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function isApprovedForAll(address owner, address operator)
        override
        public
        view
        returns (bool)
    {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function _msgSender()
        internal
        override
        view
        returns (address sender)
    {
        return ContextMixin.msgSender();
    }
}// MIT
pragma solidity ^0.8.0;



struct RelicProperties
{
    uint256 relicTypeId;
    uint256 materialId;
    uint256 materialOffset; // this relic's number relative to material, e.g. Gold Skull #42
    uint256 poleId;
    uint256 astralId;
    uint256 elementId;
    uint256 alignmentId;
    uint256 greatness;
}

interface IRelicMinter
{

    function getAdditionalAttributes(uint256 tokenId, bytes12 data)
        external view returns(string memory);


    function getTokenOrderIndex(uint256 tokenId, bytes12 data)
        external view returns(uint);


    function getTokenProvenance(uint256 tokenId, bytes12 data)
        external view returns(string memory);


    function getImageBaseURL()
        external view returns(string memory);

}


contract Relic is ProxyImplementation, ERC721TradableUpgradeable
{

    mapping(address => bool) private _whitelistedMinters;
    mapping(uint256 => uint256) public _tokenMintInfo;
    string public _placeholderImageURL;
    string public _animationBaseURL;
    string public _collectionName;
    string public _collectionDesc;
    string public _collectionImgURL;
    string public _collectionExtURL;
    uint256 public _feeBasisPoints;
    address public _feeRecipient;

    function init(
        string memory name,
        string memory symbol,
        address proxyRegistryAddress,
        string memory placeholderImageURL,
        string memory animationBaseURL,
        string memory collectionName,
        string memory collectionDesc,
        string memory collectionImgURL,
        string memory collectionExtURL,
        uint256 feeBasisPoints,
        address feeRecipient)
        public onlyOwner initializer
    {

        _initializeEIP712(name);
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name, symbol);
        __ERC721TradableUpgradeable_init_unchained(proxyRegistryAddress);

        _placeholderImageURL = placeholderImageURL;
        _animationBaseURL = animationBaseURL;
        _collectionName = collectionName;
        _collectionDesc = collectionDesc;
        _collectionImgURL = collectionImgURL;
        _collectionExtURL = collectionExtURL;
        _feeBasisPoints = feeBasisPoints;
        _feeRecipient = feeRecipient;
    }

    function exists(uint256 tokenId) public view returns(bool)
    {

        return _exists(tokenId);
    }

    function mint(address to, uint256 tokenId, bytes12 data) public
    {

        require(isMinterWhitelisted(_msgSender()), "minter not whitelisted");

        _tokenMintInfo[tokenId] = packTokenMintInfo(IRelicMinter(_msgSender()), data);

        _safeMint(to, tokenId);
    }

    function tokenURI(uint256 tokenId) public override view returns (string memory)
    {

        require(_exists(tokenId), "token doesn't exist");

        RelicProperties memory relicProps = getRelicProperties(tokenId);

        (IRelicMinter relicMinter, bytes12 data) = unpackTokenMintInfo(_tokenMintInfo[tokenId]);
        uint orderIndex = relicMinter.getTokenOrderIndex(tokenId, data);
        string memory provenance = relicMinter.getTokenProvenance(tokenId, data);
        string memory baseImageURL = relicMinter.getImageBaseURL();
        if (bytes(baseImageURL).length == 0)
        {
            baseImageURL = _placeholderImageURL;
        }
        string memory imageURL = getImageURLForToken(tokenId, baseImageURL, orderIndex, provenance);

        string memory attrs = string(abi.encodePacked(
           _getAttributes(relicProps),
            ",{\"trait_type\": \"Order\", \"value\": \"", getOrderSuffix(orderIndex), "\"}",
            ",{\"trait_type\": \"Provenance\", \"value\": \"", provenance, "\"}",
            relicMinter.getAdditionalAttributes(tokenId, data)
        ));

        return string(abi.encodePacked(
            "data:application/json;utf8,{"
            "\"name\": \"", getName(relicProps.relicTypeId, relicProps.materialId, relicProps.materialOffset), "\","
            "\"description\": \"Loot dungeon relic\","
            "\"image\": \"", imageURL, "\",",
            "\"external_url\": \"", imageURL,"\",", // TODO: this should be link to asset on TheCrupt
            "\"attributes\": [", attrs, "]}"
        ));
    }

    function contractURI() public view returns(string memory)
    {

        return string(abi.encodePacked(
            "data:application/json;utf8,{"
            "\"name\": \"", _collectionName, "\","
            "\"description\": \"", _collectionDesc, "\","
            "\"image\": \"", _collectionImgURL, "\",",
            "\"external_link\": \"", _collectionExtURL,"\",",
            "\"seller_fee_basis_points\": \"", StringsUpgradeable.toString(_feeBasisPoints),"\",",
            "\"fee_recipient\": \"", StringsUpgradeable.toHexString(uint256(uint160(_feeRecipient)), 20),"\"",
            "}"
        ));
    }

    function getRelicProperties(uint256 tokenId)
        public pure returns(RelicProperties memory)
    {

        RelicProperties memory props;

        uint256 relicsPerMaterialForCurrentType = 84;
        uint256 totalRelicsOfCurrentType;
        uint256 tokenIdStartForCurrentType;
        uint256 tokenIdEndForCurrentType; // exclusive

        while (true)
        {
            totalRelicsOfCurrentType = relicsPerMaterialForCurrentType << 2;
            tokenIdEndForCurrentType = tokenIdStartForCurrentType + totalRelicsOfCurrentType;

            if (tokenId < tokenIdEndForCurrentType)
            {
                break;
            }

            ++props.relicTypeId;
            tokenIdStartForCurrentType = tokenIdEndForCurrentType;
            relicsPerMaterialForCurrentType <<= 1;
        }

        uint256 relicOffset = tokenId - tokenIdStartForCurrentType;

        props.materialId = relicOffset / relicsPerMaterialForCurrentType;

        props.materialOffset = relicOffset % relicsPerMaterialForCurrentType;

        uint256 minGreatness = getMiniumGreatness(props.relicTypeId); 
        uint256 greatnessRange = 21 - minGreatness;
        props.greatness = 20 - (props.materialOffset % greatnessRange); 

       
        uint256 attributesId = relicOffset + uint256(keccak256(abi.encodePacked(props.relicTypeId, props.materialId)));

        props.alignmentId = (attributesId / greatnessRange) & 3;
        props.elementId = (attributesId / (greatnessRange * 4)) & 3;
        props.astralId = (attributesId / (greatnessRange * 16)) & 3;
        props.poleId = (attributesId / (greatnessRange * 64)) & 3;

        return props;
    }

    function packTokenMintInfo(IRelicMinter relicMinter, bytes12 data)
        public pure returns(uint256)
    {

        return (uint256(uint160(address(relicMinter))) << 96) | uint96(data);
    }

    function unpackTokenMintInfo(uint256 mintInfo)
        public pure returns(IRelicMinter relicMinter, bytes12 data)
    {

        relicMinter = IRelicMinter(address(uint160(mintInfo >> 96)));
        data = bytes12(uint96(mintInfo & 0xffffffffffffffffffffffff));
    }

    function getRelicType(uint256 relicId) public pure returns(string memory)
    {

        string[7] memory relics = ["Skull", "Crown", "Medal", "Key", "Dagger", "Gem", "Coin"];
        return relics[relicId];
    }

    function getMaterial(uint256 materialId) public pure returns(string memory)
    {

        string[4] memory materials = ["Gold", "Ice", "Fire", "Jade"];
        return materials[materialId];
    }

    function getName(uint256 relicId, uint256 materialId, uint256 materialOffset)
        public pure returns(string memory)
    {

        return string(abi.encodePacked(
            getMaterial(materialId), " ",
            getRelicType(relicId),
            " #", StringsUpgradeable.toString(materialOffset + 1)));
    }

    function getAlignment(uint256 alignmentId) public pure returns(string memory)
    {

        string[4] memory alignment = ["Good", "Evil", "Lawful", "Chaos"];
        return alignment[alignmentId];
    }

    function getElement(uint256 elementId) public pure returns(string memory)
    {

        string[4] memory element = ["Earth", "Wind", "Fire", "Water"];
        return element[elementId];
    }

    function getAstral(uint256 astralId) public pure returns(string memory)
    {

        string[4] memory astral = ["Earth", "Sun", "Moon", "Stars"];
        return astral[astralId];
    }

    function getPole(uint256 poleId) public pure returns(string memory)
    {

        string[4] memory pole = ["North", "South", "East", "West"];
        return pole[poleId];
    }

    function getMiniumGreatness(uint256 relicId) public pure returns(uint256)
    {

        uint256[7] memory greatnesses = [(uint256)(20), 19, 18,17,15,10,0];
        return greatnesses[relicId];
    }

    function getOrderSuffix(uint orderId) public pure returns(string memory)
    {

        string[16] memory suffixes = [
            "of Power",
            "of Giants",
            "of Titans",
            "of Skill",
            "of Perfection",
            "of Brilliance",
            "of Enlightenment",
            "of Protection",
            "of Anger",
            "of Rage",
            "of Fury",
            "of Vitriol",
            "of the Fox",
            "of Detection",
            "of Reflection",
            "of the Twins"
        ];
        return suffixes[orderId];
    }

    function _getURLParams(RelicProperties memory relicProps) public pure returns(string memory)
    {

        return string(abi.encodePacked(
            "relicType=", getRelicType(relicProps.relicTypeId),
            "&material=", getMaterial(relicProps.materialId),
            "&pole=", getPole(relicProps.poleId),
            "&astral=", getAstral(relicProps.astralId),
            "&element=", getElement(relicProps.elementId),
            "&alignment=", getAlignment(relicProps.alignmentId),
            "&greatness=", StringsUpgradeable.toString(relicProps.greatness)
        ));
    }

    function _getAttributes(RelicProperties memory relicProps) public pure returns(string memory)
    {

        bytes memory str = abi.encodePacked(
            "{\"trait_type\": \"Relic Type\", \"value\": \"", getRelicType(relicProps.relicTypeId),"\"},"
            "{\"trait_type\": \"Material\", \"value\": \"", getMaterial(relicProps.materialId),"\"},"
            "{\"trait_type\": \"Pole\", \"value\": \"", getPole(relicProps.poleId),"\"},"
            "{\"trait_type\": \"Astral\", \"value\": \"", getAstral(relicProps.astralId),"\"},"
            "{\"trait_type\": \"Element\", \"value\": \"", getElement(relicProps.elementId),"\"},"
            "{\"trait_type\": \"Alignment\", \"value\": \"", getAlignment(relicProps.alignmentId),"\"},"
        );

        str = abi.encodePacked(str, "{\"trait_type\": \"Greatness\", \"value\": \"", StringsUpgradeable.toString(relicProps.greatness),"\"}");

        return string(str);
    }

    function getImageURLPart1(RelicProperties memory props)
        internal pure returns(string memory)
    {

        return string(abi.encodePacked(
            Strings.toString(props.materialId),
            "-",
            Strings.toString(props.relicTypeId),
            "-"
        ));
    }

    function getImageURLPart2(RelicProperties memory props)
        internal pure returns(string memory)
    {

        return string(abi.encodePacked(
            Strings.toString(props.astralId),
            "-",
            Strings.toString(props.elementId),
            "-",
            Strings.toString(props.poleId),
            "-"
        ));
    }

    function getImageURLPart3(RelicProperties memory props)
        internal pure returns(string memory)
    {

        return string(abi.encodePacked(
            Strings.toString(props.alignmentId),
            "-",
            Strings.toString(props.greatness),
            "-"
        ));
    }

    function getImageURLForToken(uint256 tokenId, string memory baseURL, uint orderIndex, string memory provenance)
        internal pure returns(string memory)
    {

        RelicProperties memory props = getRelicProperties(tokenId);
        return string(abi.encodePacked(
            baseURL,
            getImageURLPart1(props),
            Strings.toString(orderIndex),
            "-",
            getImageURLPart2(props),
            getImageURLPart3(props),
            provenance,
            ".png"
        ));
    }

    function isMinterWhitelisted(address minter) public view returns(bool)
    {

        return _whitelistedMinters[minter];
    }

    function addWhitelistedMinter(address minter) public onlyOwner
    {

        require(AddressUpgradeable.isContract(minter), "minter is not a contract");
        require(!isMinterWhitelisted(minter), "already whitelisted");
        _whitelistedMinters[minter] = true;
    }

    function removeWhitelistedMinter(address minter) public onlyOwner
    {

        require(isMinterWhitelisted(minter), "not whitelisted");
        _whitelistedMinters[minter] = false;
    }

    function setPlaceholderImageURL(string memory placeholderImageURL) public onlyOwner
    {

        _placeholderImageURL = placeholderImageURL;
    }

    function setAnimationBaseURL(string memory animationBaseURL) public onlyOwner
    {

        _animationBaseURL = animationBaseURL;
    }

    function setCollectionName(string memory collectionName) public onlyOwner
    {

        _collectionName = collectionName;
    }

    function setCollectionDesc(string memory collectionDesc) public onlyOwner
    {

        _collectionDesc = collectionDesc;
    }

    function setCollectionImgURL(string memory collectionImgURL) public onlyOwner
    {

        _collectionImgURL = collectionImgURL;
    }

    function setCollectionExtURL(string memory collectionExtURL) public onlyOwner
    {

        _collectionExtURL = collectionExtURL;
    }

    function setFeeBasisPoints(uint256 feeBasisPoints) public onlyOwner
    {

        _feeBasisPoints = feeBasisPoints;
    }

    function setFeeRecipient(address feeRecipient) public onlyOwner
    {

        _feeRecipient = feeRecipient;
    }
}// MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {

	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {

		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {

		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {

		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}// MIT
pragma solidity ^0.8.0;




interface Loot
{

    function ownerOf(uint256 tokenId) external view returns (address);

}


contract Dungeon2 is Ownable, IRelicMinter
{

    uint256[] public _dungeons;
    uint256[] public _relicAwardsByDungeonRank;
    uint256 public _relicAwardBrackets;
    uint256 _nextDungeonCompleteRank;
    mapping(uint256 => uint256) _raids; // maps tokenId => packed raid data
    Loot internal _loot;
    LootClassification internal _lootClassification;
    Relic internal _relic;
    string public _imageBaseURL;
    mapping(address => uint256) public _lastFreeRaidForAddress; // address => last free raid block number
    uint256 public _raidingFee;
    bool public _raidingLocked;
    uint256 public _blocksBetweenFreeRaids;

    struct AwardBracket {
        uint256 max;
        uint256 relics;
    }

    string constant _EnemiesTag = "ENEMIES";
    uint256 constant ENEMY_COUNT = 18;
    string[] private _enemies = [
        "Orcs",
        "Giant Spiders",
        "Trolls",
        "Zombies",
        "Giant Rats",

        "Minotaurs",
        "Werewolves",
        "Berserkers",
        "Goblins",
        "Gnomes",

        "Ghouls",
        "Wraiths",
        "Skeletons",
        "Revenants",

        "Necromancers",
        "Warlocks",
        "Wizards",
        "Druids"
    ];

    string constant _TrapsTag = "TRAPS";
    uint256 constant TRAP_COUNT = 15;
    string[] private _traps = [

        "Trap Doors",
        "Poison Darts",
        "Flame Jets",
        "Poisoned Well",
        "Falling Net",

        "Blinding Light",
        "Lightning Bolts",
        "Pendulum Blades",
        "Snake Pits",
        "Poisonous Gas",

        "Lava Pits",
        "Burning Oil",
        "Fire-Breathing Gargoyle",
        "Hidden Arrows",
        "Spiked Pits"
    ];

    string constant _MonsterTag = "MONSTERS";
    uint256 constant MONSTER_COUNT = 15;
    string[] private _bossMonsters = [
        "Golden Dragon",
        "Black Dragon",
        "Bronze Dragon",
        "Red Dragon",
        "Wyvern",

        "Fire Giant",
        "Storm Giant",
        "Ice Giant",
        "Frost Giant",
        "Hill Giant",

        "Ogre",
        "Skeleton Lords",
        "Knights of Chaos",
        "Lizard Kings",
        "Medusa"
    ];

    string constant _ArtefactTag = "ARTEFACTS";
    uint256 constant ARTEFACT_COUNT = 15;
    string[] private _artefacts = [

        "The Purple Orb of Zhang",
        "The Horn of Calling",
        "The Wondrous Twine of Ping",
        "The Circle of Squares",
        "The Scroll of Serpents",

        "The Rod of Runes",
        "Crystal of Crimson Light",
        "Oil of Darkness",
        "Bonecrusher Bag",
        "Mirror of Madness",

        "Ankh of the Ancients",
        "The Wand of Fear",
        "The Tentacles of Terror",
        "The Altar of Ice",
        "The Creeping Hand"
    ];

    string constant _PassagewaysTag = "PASSAGEWAYS";
    uint256 constant PASSAGEWAYS_COUNT = 15;
    string[] private _passageways = [

        "Crushing Walls",
        "Loose Logs",
        "Rolling Rocks",
        "Spiked Floor",
        "Burning Coals",

        "The Hidden Pit of Doom",
        "The Sticky Stairs",
        "The Bridge of Sorrow",
        "The Maze of Madness",
        "The Flooded Tunnel",

        "The Floor of Fog",
        "The Frozen Floor",
        "The Shifting Sands",
        "The Trembling Trap",
        "The Broken Glass Floor"
    ];

    string constant _RoomsTag = "ROOMS";
    uint256 constant ROOM_COUNT = 15;
    string[] private _rooms = [

        "Room of Undead Hands",
        "Room of the Stone Claws",
        "Room of Poison Arrows",
        "Room of the Iron Bear",
        "Room of the Wandering Worm",

        "Room of the Infernal Beast",
        "Room of the Infected Slime",
        "Room of the Horned Rats",
        "Room of the Flaming Hounds",
        "Room of the Million Maggots",

        "Room of the Flaming Pits",
        "Room of the Rabid Flesh Eaters",
        "Room of the Grim Golem",
        "Room of the Chaos Firebreathers",
        "Room of the Nightmare Clones"
    ];

    string constant _TheSoullessTag = "SOULLESS";
    uint256 constant SOULLESS_COUNT = 3;
    string[] private _theSoulless = [

        "Lich Queen",
        "Zombie Lord",
        "The Grim Reaper"
    ];

    string constant _DemiGodTag = "ELEMENTS";
    uint256 constant DEMIGOD_COUNT = 5;
    string[] private _demiGods = [

        "The Bone Demon",
        "The Snake God",
        "The Howling Banshee",
        "Demonspawn",
        "The Elementals"
    ];

    function numDungeons() public view returns(uint256)
    {

        return _dungeons.length;
    }

    function getTraitIndex(uint256 dungeonId, string memory traitName, uint256 traitCount) private pure returns (uint256)
    {

        return pluckDungeonTrait(dungeonId, traitName, traitCount);
    }

    function getTraitName(uint256 dungeonId, string memory traitName, string[] storage traitList) private view returns (string memory)
    {

        uint256 index = getTraitIndex(dungeonId, traitName, traitList.length);
        return traitList[index];
    }

    function enemiesIndex(uint256 dungeonId) private pure returns (uint256)
    {

        return getTraitIndex(dungeonId, _EnemiesTag, ENEMY_COUNT);
    }

    function trapsIndex(uint256 dungeonId) private pure returns (uint256)
    {

        return getTraitIndex(dungeonId, _TrapsTag, TRAP_COUNT);
    }

    function monsterIndex(uint256 dungeonId) private pure returns (uint256)
    {

        return getTraitIndex(dungeonId, _MonsterTag, MONSTER_COUNT);
    }

    function artefactsIndex(uint256 dungeonId) private pure returns (uint256)
    {

        return getTraitIndex(dungeonId, _ArtefactTag, ARTEFACT_COUNT);
    }

    function passagewaysIndex(uint256 dungeonId) private pure returns (uint256)
    {

        return getTraitIndex(dungeonId, _PassagewaysTag, PASSAGEWAYS_COUNT);
    }

    function roomsIndex(uint256 dungeonId) private pure returns (uint256)
    {

        return getTraitIndex(dungeonId, _RoomsTag, ROOM_COUNT);
    }

    function soullessIndex(uint256 dungeonId) private pure returns (uint256)
    {

        return getTraitIndex(dungeonId, _TheSoullessTag, SOULLESS_COUNT);
    }

    function demiGodIndex(uint256 dungeonId) private pure returns (uint256)
    {

        return getTraitIndex(dungeonId, _DemiGodTag, DEMIGOD_COUNT);
    }

    function getEnemies(uint256 dungeonId) public view returns (string memory)
    {

        return getTraitName(dungeonId, _EnemiesTag, _enemies);
    }

    function getTraps(uint256 dungeonId) public view returns (string memory)
    {

        return getTraitName(dungeonId, _TrapsTag, _traps);
    }

    function getBossMonster(uint256 dungeonId) public view returns (string memory)
    {

        return getTraitName(dungeonId, _MonsterTag, _bossMonsters);
    }

    function getArtefact(uint256 dungeonId) public view returns (string memory)
    {

        return getTraitName(dungeonId, _ArtefactTag, _artefacts);
    }

    function getPassageways(uint256 dungeonId) public view returns (string memory)
    {

        return getTraitName(dungeonId, _PassagewaysTag, _passageways);
    }

    function getRooms(uint256 dungeonId) public view returns (string memory)
    {

        return getTraitName(dungeonId, _RoomsTag, _rooms);
    }

    function getTheSoulless(uint256 dungeonId) public view returns (string memory)
    {

        return getTraitName(dungeonId, _TheSoullessTag, _theSoulless);
    }

    function getDemiGod(uint256 dungeonId) public view returns (string memory)
    {

        return getTraitName(dungeonId, _DemiGodTag, _demiGods);
    }

    function pluckDungeonTrait(uint256 dungeonId, string memory keyPrefix, uint256 traitCount) internal pure returns (uint256)
    {

        uint256 rand = random(string(abi.encodePacked(keyPrefix, Strings.toString(dungeonId + 16))));

        uint256 index = rand % traitCount;
        return index;
    }

    constructor(
        uint16 dungeonCount,
        uint[8] memory startHitPoints,
        uint256[] memory relicAwards,
        address raidTokenContract,
        address lootClassificationAddress,
        address relicAddress,
        string memory imageBaseURL,
        uint256 raidingFee,
        uint256 blocksBetweenFreeRaids,
        AwardBracket[] memory awardBrackets
    )
    {
        _loot = Loot(raidTokenContract);
        _lootClassification = LootClassification(lootClassificationAddress);
        _relic = Relic(relicAddress);

        _relicAwardsByDungeonRank = relicAwards;
        _nextDungeonCompleteRank = 0;

        _imageBaseURL = imageBaseURL;

        _raidingFee = raidingFee;
        _raidingLocked = true;
        _blocksBetweenFreeRaids = blocksBetweenFreeRaids;

        for (uint16 i = 0; i < dungeonCount; i++)
        {
            _dungeons.push(packDungeon(dungeonCount, startHitPoints, 0));
        }

        uint256 relicAwardBrackets;
        require(awardBrackets.length <= 16);
        for (uint16 i = 0; i < awardBrackets.length; i++)
        {
            relicAwardBrackets |= (awardBrackets[i].max | (awardBrackets[i].relics << 8)) << (i * 16);
        }
        _relicAwardBrackets = relicAwardBrackets;
    }

    event Raid
    (
        uint256 indexed dungeonId,
        uint256 raidTokenId,
        uint256[8] damage
    );

    function raidDungeon(uint dungeonId, uint256 raidTokenId) public payable
    {

        require(!_raidingLocked, "raiding is locked");
        require(_raids[raidTokenId] == 0, "loot already used in a raid");

        require(msg.sender == _loot.ownerOf(raidTokenId), "raider does not own loot");

        uint256 dungeonCount = _dungeons.length;
        require(dungeonId < dungeonCount, "invalid dungeon");

        uint256 fee = _raidingFee;
        if (canRaidFree())
        {
            fee = 0;
            _lastFreeRaidForAddress[msg.sender] = block.number;
        }
        require(msg.value >= fee, "not enough eth sent");
        if (msg.value > fee)
        {
            payable(msg.sender).transfer(msg.value - fee);
        }

        (uint256 rank,
        uint256[8] memory dungeonHitPoints,
        uint256 rewardOffset) = unpackDungeon(_dungeons[dungeonId]);

        require(rank == dungeonCount, "dungeon already complete");

        uint256[9] memory raidHitPoints = _getRaidHitPoints(dungeonId, dungeonHitPoints, raidTokenId);
        require(raidHitPoints[8] > 0, "raid would have no affect");

        bool complete = true;
        uint256 dungeonTotalHp;
        for (uint i = 0; i < 8; i++)
        {
            dungeonTotalHp += dungeonHitPoints[i];

            dungeonHitPoints[i] -= raidHitPoints[i];
            if (dungeonHitPoints[i] > 0)
            {
                complete = false;
            }
        }

        uint256 rewardCount = getRewardCount(raidHitPoints[8]);
        _raids[raidTokenId] = packRaid(dungeonId, rewardOffset, rewardCount);
        rewardOffset += rewardCount;

        if (complete)
        {
            rank = _nextDungeonCompleteRank;
            _nextDungeonCompleteRank++;
        }

        _dungeons[dungeonId] = packDungeon(rank, dungeonHitPoints, rewardOffset);

        emit Raid(dungeonId, raidTokenId, [
            raidHitPoints[0],
            raidHitPoints[1],
            raidHitPoints[2],
            raidHitPoints[3],
            raidHitPoints[4],
            raidHitPoints[5],
            raidHitPoints[6],
            raidHitPoints[7]]);
    }

    function getRewardBrackets() public view returns (AwardBracket[] memory)
    {

        uint256 bracketCount;
        for (uint256 i = 1; i <= 16; ++i)
        {
            if ((_relicAwardBrackets >> (i * 16)) == 0)
            {
                bracketCount = i;
                break;
            }
        }

        AwardBracket[] memory relicAwardBrackets = new AwardBracket[](bracketCount);
        for (uint256 i = 0; i < bracketCount; ++i)
        {
            uint256 packedBracket = (_relicAwardBrackets >> (i * 16)) & 0xffff;
            relicAwardBrackets[i].max = packedBracket & 0xff;
            relicAwardBrackets[i].relics = packedBracket >> 8;
        }
        return relicAwardBrackets;
    }

    function getRewardCount(uint256 damage) public view returns(uint256 rewardCount)
    {

        for (uint256 i = 0; i < 16; i++)
        {
            uint256 packedBracket = (_relicAwardBrackets >> (i * 16)) & 0xffff;

            if (damage > (packedBracket & 0xff)) {
                continue;
            }
            return packedBracket >> 8;
        }
        require(false, 'invalid reward brackets configured');
    }

    function canRaidFree() public view returns(bool)
    {

        return (block.number - _lastFreeRaidForAddress[msg.sender]) > _blocksBetweenFreeRaids;
    }

    function withdraw() public onlyOwner
    {

        (bool sent,) = owner().call{value: address(this).balance}("");
        require(sent, "failed to send");
    }

    function setRaidingLock(bool locked) external onlyOwner
    {

        _raidingLocked = locked;
    }

    function setRaidingFee(uint256 raidingFee) external onlyOwner
    {

        _raidingFee = raidingFee;
    }

    function setBlocksBetweenFreeRaids(uint256 blocksBetweenFreeRaids) external onlyOwner
    {

        _blocksBetweenFreeRaids = blocksBetweenFreeRaids;
    }

    function packRaid(uint256 dungeonId, uint256 rewardFirstId, uint256 rewardCount) private pure returns(uint256)
    {

        return 1 | (dungeonId << 8) | (rewardFirstId << 16) | (rewardCount << 32);
    }
    function unpackRaid(uint256 packed)
        private pure returns(uint256 dungeonId, uint256 rewardFirstId, uint256 rewardCount)
    {

        dungeonId = (packed >> 8) & 0xff;
        rewardFirstId = (packed >> 16) & 0xffff;
        rewardCount = (packed >> 32) & 0xff;
    }

    function packDungeon(uint256 rank, uint256[8] memory hitPoints, uint256 raidRewardOffset)
        private pure returns(uint256)
    {

        return rank
        | (hitPoints[0] << 8)
        | (hitPoints[1] << 16)
        | (hitPoints[2] << 24)
        | (hitPoints[3] << 32)
        | (hitPoints[4] << 40)
        | (hitPoints[5] << 48)
        | (hitPoints[6] << 56)
        | (hitPoints[7] << 64)
        | (raidRewardOffset << 72);
    }
    function unpackDungeon(uint256 packed)
        private pure returns(uint256 rank, uint256[8] memory hitPoints, uint256 raidRewardOffset)
    {

        rank = packed & 0xff;
        hitPoints[0] = (packed >> 8) & 0xff;
        hitPoints[1] = (packed >> 16) & 0xff;
        hitPoints[2] = (packed >> 24) & 0xff;
        hitPoints[3] = (packed >> 32) & 0xff;
        hitPoints[4] = (packed >> 40) & 0xff;
        hitPoints[5] = (packed >> 48) & 0xff;
        hitPoints[6] = (packed >> 56) & 0xff;
        hitPoints[7] = (packed >> 64) & 0xff;
        raidRewardOffset = (packed >> 72) & 0xffff;
    }

    struct DungeonInfo
    {
        uint256 orderIndex;
        string enemies;
        string traps;
        string bossMonster;
        string artefact;
        string passageways;
        string rooms;
        string theSoulless;
        string demiGod;
        uint256[8] hitPoints;
        bool isOpen;
        uint256 rank;
        int256 rewards;
    }

    function getDungeons() external view returns(DungeonInfo[] memory)
    {

        DungeonInfo[] memory dungeonInfo = new DungeonInfo[](_dungeons.length);

        for (uint256 i = 0; i < _dungeons.length; ++i)
        {
            dungeonInfo[i].orderIndex = getDungeonOrderIndex(i);
            dungeonInfo[i].enemies = getEnemies(i);
            dungeonInfo[i].traps = getTraps(i);
            dungeonInfo[i].bossMonster = getBossMonster(i);
            dungeonInfo[i].artefact = getArtefact(i);
            dungeonInfo[i].passageways = getPassageways(i);
            dungeonInfo[i].rooms = getRooms(i);
            dungeonInfo[i].theSoulless = getTheSoulless(i);
            dungeonInfo[i].demiGod = getDemiGod(i);
            dungeonInfo[i].hitPoints = getDungeonRemainingHitPoints(i);
            dungeonInfo[i].isOpen = getDungeonOpen(i);
            dungeonInfo[i].rank = getDungeonRank(i);
            dungeonInfo[i].rewards = getDungeonRewardToken(i);
        }

        return dungeonInfo;
    }

    function getDungeonOrderIndex(uint dungeonId) pure public returns (uint)
    {

        return dungeonId % 16;
    }

    function getItemHitPoints(
        uint256 dungeonId,
        uint256[6] memory lootComponents,
        string memory traitName,
        uint256 traitCount,
        LootClassification.Type lootType) internal view returns(uint)
    {

        uint256 dungeonTraitIndex = getTraitIndex(dungeonId, traitName, traitCount);
        uint256 lootTypeIndex = lootComponents[0];


        bool orderMatch = lootComponents[1] == (getDungeonOrderIndex(dungeonId) + 1);
        uint256 orderScore;

        if (orderMatch)
        {
            orderScore = 2;
            if (lootComponents[4] > 0)
            {
                orderScore += 1;
            }
        }

        if (dungeonTraitIndex == lootTypeIndex)
        {
            return orderScore + 2;
        }

        LootClassification.Class dungeonClass = _lootClassification.getClass(lootType, dungeonTraitIndex);
        LootClassification.Class lootClass = _lootClassification.getClass(lootType, lootTypeIndex);
        if (dungeonClass == lootClass && dungeonClass != LootClassification.Class.Any)
        {
            uint256 dungeonRank = _lootClassification.getRank(lootType, dungeonTraitIndex);
            uint256 lootRank = _lootClassification.getRank(lootType, lootTypeIndex);

            if (lootRank <= dungeonRank)
            {
                return orderScore + 1;
            }
        }

        return orderScore;
    }

    function applyRaidItem(
        uint raidIndex,
        uint256 raidScore,
        uint256 maxScore,
        uint256[9] memory results) pure private
    {

        uint256 score = (raidScore > maxScore) ? maxScore : raidScore;
        results[raidIndex] = score;
        results[8] += score;
    }

    function getRaidHitPoints(
        uint256 dungeonId,
        uint256 lootToken) view public returns(uint256[9] memory)
    {

        (,uint256[8] memory currentHitPoints,) = unpackDungeon(_dungeons[dungeonId]);
        return _getRaidHitPoints(dungeonId, currentHitPoints, lootToken);
    }

    function getRaidHitPointsBatch(
        uint256 dungeonId,
        uint256[] memory lootTokens) view public returns(uint256[9][] memory hitPoints)
    {

        hitPoints = new uint256[9][](lootTokens.length);
        (,uint256[8] memory currentHitPoints,) = unpackDungeon(_dungeons[dungeonId]);

        for (uint256 i = 0; i < lootTokens.length; ++i) {
            hitPoints[i] = _getRaidHitPoints(dungeonId, currentHitPoints, lootTokens[i]);
        }

        return hitPoints;
    }

    function _getRaidHitPoints(
        uint256 dungeonId,
        uint256[8] memory currentHitPoints,
        uint256 lootToken) view private returns(uint256[9] memory)
    {

        uint256[8] memory itemScores;
        uint256[9] memory results;

        if (_raids[lootToken] != 0)
        {
            return results;
        }

        LootClassification lootClassification = _lootClassification;

        if (currentHitPoints[0] > 0)
        {
            uint256[6] memory weapon = lootClassification.weaponComponents(lootToken);
            itemScores[0] = getItemHitPoints(dungeonId, weapon, _EnemiesTag, ENEMY_COUNT, LootClassification.Type.Weapon);
        }

        if (currentHitPoints[1] > 0)
        {
            uint256[6] memory chest = lootClassification.chestComponents(lootToken);
            itemScores[1] = getItemHitPoints(dungeonId, chest, _TrapsTag, TRAP_COUNT, LootClassification.Type.Chest);
        }

        if (currentHitPoints[2] > 0)
        {
            uint256[6] memory head = lootClassification.headComponents(lootToken);
            itemScores[2] = getItemHitPoints(dungeonId, head, _MonsterTag, MONSTER_COUNT, LootClassification.Type.Head);
        }

        if (currentHitPoints[3] > 0)
        {
            uint256[6] memory waist = lootClassification.waistComponents(lootToken);
            itemScores[3] = getItemHitPoints(dungeonId, waist, _ArtefactTag, ARTEFACT_COUNT, LootClassification.Type.Waist);
        }

        if (currentHitPoints[4] > 0)
        {
            uint256[6] memory foot = lootClassification.footComponents(lootToken);
            itemScores[4] = getItemHitPoints(dungeonId, foot, _PassagewaysTag, PASSAGEWAYS_COUNT, LootClassification.Type.Foot);
        }

        if (currentHitPoints[5] > 0)
        {
            uint256[6] memory hand = lootClassification.handComponents(lootToken);
            itemScores[5] = getItemHitPoints(dungeonId, hand, _RoomsTag, ROOM_COUNT, LootClassification.Type.Hand);
        }

        if (currentHitPoints[6] > 0)
        {
            uint256[6] memory neck = lootClassification.neckComponents(lootToken);
            itemScores[6] = getItemHitPoints(dungeonId, neck, _TheSoullessTag, SOULLESS_COUNT, LootClassification.Type.Neck);
        }

        if (currentHitPoints[7] > 0)
        {
            uint256[6] memory ring = lootClassification.ringComponents(lootToken);
            itemScores[7] = getItemHitPoints(dungeonId, ring, _DemiGodTag, DEMIGOD_COUNT, LootClassification.Type.Ring);
        }

        for (uint i = 0; i < 8; i++)
        {
            applyRaidItem(i, itemScores[i], currentHitPoints[i], results);
        }

        return results;
    }

    function getDungeonCount() view public returns(uint256)
    {

        if (_dungeons.length == 0)
        {
            return 99;
        }
        return _dungeons.length;
    }

    function getDungeonRemainingHitPoints(uint256 dungeonId) view public returns(uint256[8] memory hitPoints)
    {

        (,hitPoints,) = unpackDungeon(_dungeons[dungeonId]);
    }

    function getDungeonRank(uint256 dungeonId) view public returns(uint256 rank)
    {

        (rank,,) = unpackDungeon(_dungeons[dungeonId]);
    }

    function getDungeonOpen(uint256 dungeonId) view public returns(bool)
    {

        if (dungeonId >= _dungeons.length)
        {
            return false;
        }

        return getDungeonRank(dungeonId) == _dungeons.length;
    }

    function getDungeonRewardToken(uint256 dungeonId) view public returns (int256)
    {

        if (dungeonId >= _dungeons.length)
        {
            return -1;
        }

        uint256 rank = getDungeonRank(dungeonId);
        if (rank >= _dungeons.length)
        {
            return -1;
        }

        return int256(_relicAwardsByDungeonRank[rank]);
    }

    function _getRewardsForToken(Loot loot, uint256 dungeonCount, uint256 tokenId)
        private view returns(uint256 dungeonId, uint256 rewardFirstId, uint256 rewardCount)
    {

        require(msg.sender == loot.ownerOf(tokenId), "sender isn't owner of loot");

        uint256 packedRaid = _raids[tokenId];
        require(packedRaid != 0, "loot bag not used in raid");

        (dungeonId, rewardFirstId, rewardCount) = unpackRaid(packedRaid);
        require(dungeonId < dungeonCount, "invalid dungeon id");

        (uint256 rank,,) = unpackDungeon(_dungeons[dungeonId]);
        require(rank < dungeonCount, "dungeon still open");

        rewardFirstId += _relicAwardsByDungeonRank[rank];
    }

    function getRewardsForToken(uint256 tokenId) public view
        returns(uint256 dungeonId, uint256 rewardFirstId, uint256 rewardCount)
    {

        return _getRewardsForToken(_loot, _dungeons.length, tokenId);
    }

    function getRewardsForTokens(uint256[] memory tokenIds) public view returns(
        uint256[] memory dungeonId,
        uint256[] memory rewardFirstId,
        uint256[] memory rewardCount)
    {

        dungeonId = new uint256[](tokenIds.length);
        rewardFirstId = new uint256[](tokenIds.length);
        rewardCount = new uint256[](tokenIds.length);

        Loot loot = _loot;
        uint256 dungeonCount = _dungeons.length;

        for (uint256 i = 0; i < tokenIds.length; ++i)
        {
            (dungeonId[i], rewardFirstId[i], rewardCount[i]) =
                _getRewardsForToken(loot, dungeonCount, tokenIds[i]);
        }
    }

    function claimRewards(uint256[] memory tokenIds) public
    {

        uint256 dungeonCount = _dungeons.length;
        Loot loot = _loot;
        Relic relic = _relic;

        for (uint256 i = 0; i < tokenIds.length; ++i)
        {
            (uint256 dungeonId, uint256 rewardFirstId, uint256 rewardCount) =
                _getRewardsForToken(loot, dungeonCount, tokenIds[i]);

            bytes12 data = bytes12(uint96(dungeonId & 0xffffffffffffffffffffffff));

            for (uint256 j = 0; j < rewardCount; ++j)
            {
                relic.mint(msg.sender, rewardFirstId + j, data);
            }
        }
    }


    function random(string memory input) internal pure returns (uint256) {

        return uint256(keccak256(abi.encodePacked(input)));
    }


    function setImageBaseURL(string memory newImageBaseURL) public onlyOwner
    {

        _imageBaseURL = newImageBaseURL;
    }

    function getTokenOrderIndex(uint256 /*tokenId*/, bytes12 data)
        external override pure returns(uint)
    {

        uint96 dungeonId = uint96(data);
        return getDungeonOrderIndex(dungeonId);
    }

    function getTokenProvenance(uint256 /*tokenId*/, bytes12 /*data*/)
        external override pure returns(string memory)
    {

        return "The Crypt: Chapter Two";
    }

    function getAdditionalAttributes(uint256 /*tokenId*/, bytes12 /*data*/)
        external override pure returns(string memory)
    {

        return "";
    }

    function getImageBaseURL() external override view returns(string memory)
    {

        return _imageBaseURL;
    }
}