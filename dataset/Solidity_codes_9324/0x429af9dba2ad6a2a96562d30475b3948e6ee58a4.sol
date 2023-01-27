
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

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


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

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

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


interface IPaw is IERC20 {

    function updateReward(address _address) external;

}

interface IKumaVerse is IERC721 {


}

interface IKumaTracker is IERC1155 {}//MIT

pragma solidity ^0.8.0;



abstract contract Ownable {
    address public owner;
    constructor() {owner = msg.sender;}
    modifier onlyOwner {require(owner == msg.sender, "Not Owner!");

        _;}
    function transferOwnership(address new_) external onlyOwner {owner = new_;}

}

interface IOwnable {

    function owner() external view returns (address);

}

contract PawShop is Ownable {



    event WLVendingItemAdded(address indexed operator_, WLVendingItem item_);
    event WLVendingItemModified(address indexed operator_, WLVendingItem before_, WLVendingItem after_);
    event WLVendingItemRemoved(address indexed operator_, WLVendingItem item_);
    event WLVendingItemPurchased(address indexed purchaser_, uint256 index_, WLVendingItem object_);


    IERC20 paw;
    IERC1155 tracker;
    IKumaVerse  kumaContract;

    constructor(address _pawContract, address _trackerContract, address _kumaverseContract) {
        paw = IERC20(_pawContract);
        tracker = IERC1155(_trackerContract);
        kumaContract = IKumaVerse(_kumaverseContract);
    }

    struct WLVendingItem {
        string title;
        string imageUri;
        string projectUri;
        string description;

        uint32 amountAvailable;
        uint32 amountPurchased;

        uint32 startTime;
        uint32 endTime;

        uint256 price;

        uint128 holdersType;
        uint128 category;
    }

    modifier onlyAdmin() {

        require(shopAdmin[msg.sender], "You are not admin");
        _;
    }

    mapping(address => bool) public shopAdmin;
    WLVendingItem[] public WLVendingItemsDb;

    mapping(uint256 => address[]) public contractToWLPurchasers;
    mapping(uint256 => mapping(address => bool)) public contractToWLPurchased;

    function setPermission(address _toUpdate, bool _isAdmin) external onlyOwner() {

        shopAdmin[_toUpdate] = _isAdmin;
    }

    function addItem(WLVendingItem memory WLVendingItem_) external onlyAdmin() {

        require(bytes(WLVendingItem_.title).length > 0,
            "You must specify a Title!");
        require(uint256(WLVendingItem_.endTime) > block.timestamp,
            "Already expired timestamp!");
        require(WLVendingItem_.endTime > WLVendingItem_.startTime,
            "endTime > startTime!");

        WLVendingItem_.amountPurchased = 0;

        WLVendingItemsDb.push(WLVendingItem_);

        emit WLVendingItemAdded(msg.sender, WLVendingItem_);
    }

    function editItem(uint256 index_, WLVendingItem memory WLVendingItem_) external onlyAdmin() {

        WLVendingItem memory _item = WLVendingItemsDb[index_];

        require(bytes(_item.title).length > 0,
            "This WLVendingItem does not exist!");
        require(bytes(WLVendingItem_.title).length > 0,
            "Title must not be empty!");

        require(WLVendingItem_.amountAvailable >= _item.amountPurchased,
            "Amount Available must be >= Amount Purchased!");

        WLVendingItemsDb[index_] = WLVendingItem_;

        emit WLVendingItemModified(msg.sender, _item, WLVendingItem_);
    }

    function deleteMostRecentWLVendingItem() external onlyAdmin() {

        uint256 _lastIndex = WLVendingItemsDb.length - 1;

        WLVendingItem memory _item = WLVendingItemsDb[_lastIndex];

        require(_item.amountPurchased == 0,
            "Cannot delete item with already bought goods!");

        WLVendingItemsDb.pop();
        emit WLVendingItemRemoved(msg.sender, _item);
    }
    function buyItem(uint256 index_) external {


        WLVendingItem memory _object = getWLVendingObject(index_);

        require(bytes(_object.title).length > 0,
            "This WLVendingObject does not exist!");
        require(_object.amountAvailable > _object.amountPurchased,
            "No more WL remaining!");
        require(_object.startTime <= block.timestamp,
            "Not started yet!");
        require(_object.endTime >= block.timestamp,
            "Past deadline!");
        require(!contractToWLPurchased[index_][msg.sender],
            "Already purchased!");
        require(_object.price != 0,
            "Item does not have a set price!");
        require(paw.balanceOf(msg.sender) >= _object.price,
            "Not enough tokens!");
        require(canBuy(msg.sender, _object.holdersType), "You can't buy this");
        paw .transferFrom(msg.sender, address(this), _object.price);

        contractToWLPurchased[index_][msg.sender] = true;
        contractToWLPurchasers[index_].push(msg.sender);

        WLVendingItemsDb[index_].amountPurchased++;

        emit WLVendingItemPurchased(msg.sender, index_, _object);
    }

    function canBuy(address _buyer, uint256 _holdersType) internal returns (bool) {


        if (_holdersType == 0) {
            return true;
        } else if (_holdersType == 1) {
            uint256 kumaBalance = kumaContract.balanceOf(_buyer);
            if (kumaBalance > 0) {
                return true;
            }
        } else if (_holdersType == 2) {
            uint256 trackerBalance = tracker.balanceOf(_buyer, 1);
            if (trackerBalance > 0) {
                return true;
            }
        }
        return false;
    }

    function getWLPurchasersOf(uint256 index_) public view
    returns (address[] memory) {

        return contractToWLPurchasers[index_];
    }

    function getWLVendingItemsLength() public view
    returns (uint256) {

        return WLVendingItemsDb.length;
    }

    function getWLVendingItemsAll() public view
    returns (WLVendingItem[] memory) {

        return WLVendingItemsDb;
    }

    function raw_getWLVendingItemsPaginated(uint256 start_,
        uint256 end_) public view returns (WLVendingItem[] memory) {

        uint256 _arrayLength = end_ - start_ + 1;
        WLVendingItem[] memory _items = new WLVendingItem[](_arrayLength);
        uint256 _index;

        for (uint256 i = 0; i < _arrayLength; i++) {
            _items[_index++] = WLVendingItemsDb[start_ + i];
        }

        return _items;
    }

    function getWLVendingObject(uint256 index_) public
    view returns (WLVendingItem memory) {

        WLVendingItem memory _item = WLVendingItemsDb[index_];
        return _item;
    }

    function getWLVendingObjectsPaginated(uint256 start_,
        uint256 end_) public view returns (WLVendingItem[] memory) {

        uint256 _arrayLength = end_ - start_ + 1;
        WLVendingItem[] memory _objects = new WLVendingItem[](_arrayLength);
        uint256 _index;

        for (uint256 i = 0; i < _arrayLength; i++) {

            uint256 _itemIndex = start_ + i;

            WLVendingItem memory _item = WLVendingItemsDb[_itemIndex];

            _objects[_index++] = _item;
        }

        return _objects;
    }
}