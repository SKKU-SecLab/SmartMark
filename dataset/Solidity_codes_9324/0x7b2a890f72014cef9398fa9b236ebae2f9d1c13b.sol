
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


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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


contract Marketplace is OwnableUpgradeable {

    
    struct Listing { 
        string nameAndDesc;
        string image;
        uint256 slots;
        uint256 expiry;
        uint256 price;
        uint256 maxCount;
        string socials;
        bool deleted;
    }

    struct Whitelist { 
        uint256 listingIndex;
        string discordId;
        uint256 count;
        uint256 total;
    }

    mapping (address => bool) public admins;
    mapping (address => Whitelist[]) public owned;
    mapping (address => mapping (uint256=> uint256)) public bought;

    Listing[] public listings;

    address public essence;
    address public babyDraco;
    uint256 public minHold;
    address public draco;

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    event Purchase(address indexed _from, uint256 _index, string _discordId, uint256 _count, uint256 _total);

    modifier onlyAdmin() {

        require(admins[msg.sender], "Not admin");
        _;
    }

    function initialize() public initializer {

        OwnableUpgradeable.__Ownable_init();
    }

    function setEssence(address _essence) public onlyOwner {

        essence = _essence;
    }

    function setDraco(address _draco) public onlyOwner {

        draco = _draco;
    }

    function setBabyDraco(address _babyDraco) public onlyOwner {

        babyDraco = _babyDraco;
    }

    function setMinHold(uint256 _minHold) public onlyOwner {

        minHold = _minHold;
    }

    function setAdmin(address _admin, bool _permission) public onlyOwner {

        admins[_admin] = _permission;
    }

    function addListing(string calldata _nameAndDesc, string calldata _image, uint256 _slots, uint256 _expiry, uint256 _price, uint256 _maxCount, string calldata _socials) public onlyAdmin {

        Listing memory listing = Listing(_nameAndDesc, _image, _slots, _expiry, _price, _maxCount, _socials, false);
        listings.push(listing);
    }

    function editListing(uint256 _index, string calldata _nameAndDesc, string calldata _image, uint256 _slots, uint256 _expiry, uint256 _price, uint256 _maxCount, string calldata _socials) public onlyAdmin {

        listings[_index].nameAndDesc = _nameAndDesc;
        listings[_index].image = _image;
        listings[_index].slots = _slots;
        listings[_index].expiry = _expiry;
        listings[_index].price = _price;
        listings[_index].maxCount = _maxCount;
        listings[_index].socials = _socials;
    }

    function removeListing(uint256 _index) public onlyAdmin {

        listings[_index].deleted = true;
    }

    function getListings() public view returns (Listing[] memory) {

        return listings;
    }

    function getOwned(address _address) public view returns (Whitelist[] memory) {

        return owned[_address];
    }

    function purchase(uint256 _index, string calldata _discordId, uint256 _count) public {

        Listing storage listing = listings[_index];
        uint256 total = listing.price * _count;
        uint256 addedCount = bought[msg.sender][_index] + _count;
        require(tx.origin == msg.sender,                                 "?");
        require(!listing.deleted,                                        "Deleted");
        require(block.timestamp < listing.expiry,                        "Expired");
        require(_count > 0 && _count <= listing.slots,                   "No slots");
        require(addedCount <= listing.maxCount,                          "Exceed limit");
        require(total <= IERC20(essence).balanceOf(msg.sender),          "Not enough balance");
        require(IERC721(draco).balanceOf(msg.sender) >= minHold || IERC721(babyDraco).balanceOf(msg.sender) >= minHold,    "Need to hold min draco");
        listing.slots -= _count;
        bought[msg.sender][_index] = addedCount;
        owned[msg.sender].push(Whitelist(_index, _discordId, _count, total));
        IERC20(essence).transferFrom(msg.sender, BURN_ADDRESS, total);
        emit Purchase(msg.sender, _index, _discordId, _count, total);
    }
}