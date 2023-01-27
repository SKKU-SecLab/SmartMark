
pragma solidity ^0.8.8;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _potentialOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnerNominated(address potentialOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function potentialOwner() public view returns (address) {
        return _potentialOwner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function nominatePotentialOwner(address newOwner) public virtual onlyOwner {
        _potentialOwner = newOwner;
        emit OwnerNominated(newOwner);
    }

    function acceptOwnership () public virtual {
        require(msg.sender == _potentialOwner, 'You must be nominated as potential owner before you can accept ownership');
        emit OwnershipTransferred(_owner, _potentialOwner);
        _owner = _potentialOwner;
        _potentialOwner = address(0);
    }
}

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

interface IItemFactory {


    function totalSupply(uint256 boxType) external view returns (uint256);


    function addItem(
        uint256 boxType,
        uint256 itemId,
        uint256 rarity,
        uint256 itemInitialLevel,
        uint256 itemInitialExperience
    ) external;


    function getRandomItem(uint256 randomness, uint256 boxType)
        external
        view
        returns (uint256 itemId);


    function getItemInitialLevel(uint256[] memory boxTypes, uint256[] memory itemIds)
        external
        view
        returns (uint256);


    function getItemInitialExperience(uint256[] memory boxTypes, uint256[] memory itemIds)
        external
        view
        returns (uint256);


    event ItemAdded(
        uint256 indexed boxType,
        uint256 indexed itemId,
        uint256 rarity,
        uint256 itemInitialLevel,
        uint256 itemInitialExperience
    );

    event ItemUpdated(
        uint256 indexed boxType,
        uint256 indexed itemId,
        uint256 rarity,
        uint256 itemInitialLevel,
        uint256 itemInitialExperience
    );

}

contract ItemFactory is Ownable, IItemFactory {

    using EnumerableSet for EnumerableSet.UintSet;

    EnumerableSet.UintSet private _supportedBoxTypes; // BoxType

    struct RarityInfo {
        uint256 zeroIndex;
        uint256 rarity;
    }

    struct Items {
        uint256 totalRarity;
        uint256[] itemIds;
        mapping(uint256 => RarityInfo) itemIdToRarity;
        mapping(uint256 => uint256) itemInitialLevel;
        mapping(uint256 => uint256) itemInitialExperience;
    }
    mapping(uint256 => Items) private _items;

    constructor() {
        _supportedBoxTypes.add(1); // #1
        _supportedBoxTypes.add(2); // #2
        _supportedBoxTypes.add(3); // #3
        _supportedBoxTypes.add(4); // #4
        _supportedBoxTypes.add(5); // #5
        _supportedBoxTypes.add(6); // #6
        _supportedBoxTypes.add(7); // #7
    }

    modifier onlySupportedBoxType(uint256 boxType_) {

        require(
            _supportedBoxTypes.contains(boxType_),
            "ItemFactory: unsupported box type"
        );
        _;
    }

    function supportedBoxTypes() external view returns (uint256[] memory) {

        return _supportedBoxTypes.values();
    }

    function totalSupply(uint256 boxType_) external view returns (uint256) {

        return _items[boxType_].itemIds.length;
    }

    function addBoxType(uint256 boxType_) external onlyOwner {

        require(_supportedBoxTypes.add(boxType_), "ItemFactory::addBoxType box type is already supported");
    }

    function getItemRarity(uint256 boxType_, uint256 itemId_) external view returns(uint256) {

        return _items[boxType_].itemIdToRarity[itemId_].rarity;
    }

    function getItemIds(uint256 boxType_) external view returns (uint256[] memory) {

        return _items[boxType_].itemIds;
    }

    function getItemProperties(uint256 boxType_, uint256 itemId_) external view returns(uint256, uint256) {

        return(_items[boxType_].itemInitialLevel[itemId_], _items[boxType_].itemInitialExperience[itemId_]);
    }

    function getItemTotalRarity(uint256 boxType_) external view returns(uint256) {

        return _items[boxType_].totalRarity;
    }

    function getItemInitialLevel(uint256[] memory boxTypes_, uint256[] memory itemIds_) external view returns(uint256) {

        uint256 totalLevel = 0;
        for(uint256 i = 0; i < itemIds_.length; i++) {
            totalLevel = totalLevel + _items[boxTypes_[i]].itemInitialLevel[itemIds_[i]];
        }
        return totalLevel;
    }

    function getItemInitialExperience(uint256[] memory boxTypes_, uint256[] memory itemIds_) external view returns(uint256) {

        uint256 totalExperience = 0;
        for(uint256 i = 0; i < itemIds_.length; i++) {
            totalExperience = totalExperience + _items[boxTypes_[i]].itemInitialExperience[itemIds_[i]];
        }
        return totalExperience;
    }

    function updateItem(
        uint256 boxType_,
        uint256 itemId_,
        uint256 rarity_,
        uint256 itemInitialLevel_,
        uint256 itemInitialExperience_
    ) external
        onlyOwner
        onlySupportedBoxType(boxType_)
    {

        require(itemId_ > uint256(0), "ItemFactory::updateItem itemId_ is 0");
        require(rarity_ > uint256(0), "ItemFactory::updateItem rarity_ is 0");

        Items storage _itemsForSpecificType = _items[boxType_];
        require(
            _itemsForSpecificType.itemIdToRarity[itemId_].rarity > uint256(0),
            "ItemFactory::updateItem itemId_ is not existed"
        );
        
        _itemsForSpecificType.totalRarity =
            _itemsForSpecificType.totalRarity - _itemsForSpecificType.itemIdToRarity[itemId_].rarity + rarity_;

        _itemsForSpecificType.itemInitialLevel[itemId_] = itemInitialLevel_;
        _itemsForSpecificType.itemInitialExperience[itemId_] = itemInitialExperience_;

        _itemsForSpecificType.itemIdToRarity[itemId_].rarity = rarity_;

        if(_itemsForSpecificType.itemIds.length > 1) {
            uint256 totalRarity_ = 0;
            for(uint256 i = 1; i < _itemsForSpecificType.itemIds.length; i++) {
                totalRarity_ = totalRarity_ + _itemsForSpecificType.itemIdToRarity[_itemsForSpecificType.itemIds[i - 1]].rarity;
                _itemsForSpecificType.itemIdToRarity[_itemsForSpecificType.itemIds[i]].zeroIndex = totalRarity_;
            }
        }

        emit ItemUpdated(
            boxType_,
            itemId_,
            rarity_,
            itemInitialLevel_,
            itemInitialExperience_
        );
    }

    function addItem(
        uint256 boxType_,
        uint256 itemId_,
        uint256 rarity_,
        uint256 itemInitialLevel_,
        uint256 itemInitialExperience_
    ) external
        onlyOwner
        onlySupportedBoxType(boxType_)
    {

        require(itemId_ > uint256(0), "ItemFactory::addItem itemId_ is 0");
        require(rarity_ > uint256(0), "ItemFactory::addItem rarity_ is 0");

        Items storage _itemsForSpecificType = _items[boxType_];
        require(
            _itemsForSpecificType.itemIdToRarity[itemId_].rarity == uint256(0),
            "ItemFactory: itemId_ is already existed"
        );

        _itemsForSpecificType.itemIds.push(itemId_);

        _itemsForSpecificType.itemIdToRarity[itemId_].zeroIndex = _itemsForSpecificType.totalRarity;
        _itemsForSpecificType.itemIdToRarity[itemId_].rarity = rarity_;

        _itemsForSpecificType.totalRarity += rarity_;

        _itemsForSpecificType.itemInitialLevel[itemId_] = itemInitialLevel_;
        _itemsForSpecificType.itemInitialExperience[itemId_] = itemInitialExperience_;

        emit ItemAdded(
            boxType_,
            itemId_,
            rarity_,
            itemInitialLevel_,
            itemInitialExperience_
        );
    }

    function getRandomItem(uint256 randomness_, uint256 boxType_) public view
        onlySupportedBoxType(boxType_)
        returns (uint256 _itemId) {

        Items storage _itemsForSpecificType = _items[boxType_];
        require(
            _itemsForSpecificType.totalRarity > 0,
            "ItemFactory: add items for this type before using function"
        );

        uint256 _randomNumber = randomness_ % _itemsForSpecificType.totalRarity;

        for (uint256 i = 0; i < _itemsForSpecificType.itemIds.length; i++) {
            RarityInfo storage _rarityInfo = _itemsForSpecificType
                .itemIdToRarity[_itemsForSpecificType.itemIds[i]];

            if (_rarityInfo.zeroIndex <= _randomNumber && _randomNumber < _rarityInfo.zeroIndex + _rarityInfo.rarity) {
                _itemId = _itemsForSpecificType.itemIds[i];
                break;
            }
        }
    }
}