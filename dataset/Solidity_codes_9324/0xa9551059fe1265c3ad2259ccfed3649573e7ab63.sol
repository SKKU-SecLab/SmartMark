
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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// MIT

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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
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

library CountersUpgradeable {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC2981Upgradeable is IERC165Upgradeable {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

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
pragma solidity ^0.8.13;

abstract contract IHPMarketplaceMint {
  function marketplaceMint(
    address to,
    address creatorRoyaltyAddress,
    uint96 feeNumerator,
    string memory uri,
    string memory trackId
  ) external virtual returns(uint256);

  function canMarketplaceMint() public pure returns(bool) {
    return true;
  }
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
        _transferOwnership(msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
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
pragma solidity ^0.8.13;


abstract contract HPApprovedMarketplace is Ownable {

  event MessageSender(address sender, bool hasAccess);

  mapping(address => bool) internal _approvedMarketplaces;

  function setApprovedMarketplaceActive(address marketplaceAddress, bool approveMarket) public onlyOwner {
    _approvedMarketplaces[marketplaceAddress] = approveMarket;
  }

  function isApprovedMarketplace(address marketplaceAddress) public view returns(bool) {
    return _approvedMarketplaces[marketplaceAddress];
  }

  function msgSenderEmit() public {
    bool hasAccess = _approvedMarketplaces[msg.sender];
    emit MessageSender(msg.sender, hasAccess);
  }
}// MIT
pragma solidity ^0.8.13;



contract BuyNowMarketplaceV0002 is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable {


    bool private hasInitialized;
    address public mintAdmin;
    address payable private feeAccount; // the account that receives fees
    uint private feePercent; // the fee percentage on sales 
    uint private initialFeePercent; // the fee percentage on sales 
    CountersUpgradeable.Counter private itemCount;

    struct Item {
        uint256 itemId;
        uint tokenId;
        uint price;
        address payable seller;
        bool sold;
        bool canceled;
        IERC721Upgradeable nft;
    }

    struct MintItem {
        address royaltyAddress;
        uint96 feeNumerator;
        bool shouldMint;
        string uri;
        string trackId;
    }

    mapping(uint256 => Item) public items;
    mapping(uint256 => MintItem) public mintItems;

    event Offered(
        uint256 itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller
    );

    event Bought(
        uint256 itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed seller,
        address indexed buyer
    );

    event PaymentSplit(
        uint256 itemId,
        address indexed nft,
        uint tokenId,
        uint price,
        address indexed from,
        address indexed to
    );

    event Cancelled(
        uint256 indexed itemId,
        address indexed nft,
        uint256 indexed tokenId
    );

    event UpdateSalePrice(
        uint256 indexed itemId,
        address indexed nft,
        uint256 indexed tokenId,
        uint price,
        address seller
    );

    function initialize(uint _feePercent, uint _initialFeePercent, address payable _feeAccount, address _mintAdmin) initializer public {

        require(hasInitialized == false, "This has already been initialized");
        hasInitialized = true;
        feeAccount = _feeAccount;
        feePercent = _feePercent;
        initialFeePercent = _initialFeePercent;
        mintAdmin = _mintAdmin;
        __Ownable_init_unchained();
        __ReentrancyGuard_init();

    }

    function makeItem(IERC721Upgradeable _nft, uint _tokenId, uint _price) external nonReentrant {

        _nft.transferFrom(msg.sender, address(this), _tokenId);
        generateSaleItem(_nft, _tokenId, _price, msg.sender);
    }

    function makeItemMintable(
        IERC721Upgradeable _nft, 
        uint _price,
        address _royaltyAddress,
        uint96 _feeNumerator,
        string memory _uri,
        string memory _trackId
        ) public nonReentrant {

            require(mintAdmin == msg.sender, "Admin rights required");
            IHPMarketplaceMint marketplaceNft = IHPMarketplaceMint(address(_nft));
            require(marketplaceNft.canMarketplaceMint() == true, "This token is not compatible with marketplace minting");
            uint256 itemId = generateSaleItem(_nft, 0, _price, _royaltyAddress);

            mintItems[itemId] = MintItem (
                _royaltyAddress,
                _feeNumerator,
                true,
                _uri,
                _trackId
            );
    }

    function generateSaleItem(IERC721Upgradeable _nft, uint _tokenId, uint _price, address _seller) private returns(uint256) {

        calculateFee(_price, feePercent); // Check if the figure is too small
        require(_price > 0, "Price must be greater than zero");
        uint256 newItemId = CountersUpgradeable.current(itemCount);
        items[newItemId] = Item (
            newItemId,
            _tokenId,
            _price,
            payable(_seller),
            false,
            false,
            _nft
        );

        emit Offered(
            newItemId,
            address(_nft),
            _tokenId,
            _price,
            msg.sender
        );

        CountersUpgradeable.increment(itemCount);
        return newItemId;
    }

    function purchaseItem(uint256 _itemId) external payable nonReentrant {

        uint _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        MintItem memory mintingItem = mintItems[_itemId];
        bool shouldMint = mintingItem.shouldMint;
        uint256 newItemId = CountersUpgradeable.current(itemCount);
        require(_itemId < newItemId, "Sale does not exist");
        require(item.canceled == false, "Sale has been cancled");
        require(!item.sold, "Item already sold");
        if (!shouldMint) {
            require(item.nft.ownerOf(item.tokenId) == address(this), "The contract does not have ownership of token");
        }
        require(msg.value >= _totalPrice, "not enough ether to cover item price");
        

        uint256 tokenId = item.tokenId;
        if (shouldMint) {
            tokenId = purchaseMintItem(_itemId, item, mintingItem);
        } else {
            purchaseResaleItem(_itemId, item);
        }
        
        item.sold = true;
        
        emit Bought(
            _itemId,
            address(item.nft),
            tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    function purchaseMintItem(uint256 _itemId, Item memory item, MintItem memory mintingItem) private returns(uint256) {

        uint fee = getInitialFee(_itemId);

        uint256 sellerTransferAmount = item.price - fee;
        item.seller.transfer(sellerTransferAmount);
        feeAccount.transfer(fee);

        IHPMarketplaceMint hpMarketplaceNft = IHPMarketplaceMint(address(item.nft));
        uint256 newTokenId = hpMarketplaceNft.marketplaceMint(
            msg.sender, 
            mintingItem.royaltyAddress,
            mintingItem.feeNumerator,
            mintingItem.uri,
            mintingItem.trackId);

        emit PaymentSplit(
            _itemId,
            address(item.nft),
            newTokenId,
            sellerTransferAmount,
            msg.sender,
            item.seller);

        emit PaymentSplit(
            _itemId,
            address(item.nft),
            newTokenId,
            fee,
            msg.sender,
            feeAccount);

        return newTokenId;
        
    }

    function purchaseResaleItem(uint256 _itemId, Item memory item) private {

        uint fee = getFee(_itemId);
        IERC2981Upgradeable royaltyNft = IERC2981Upgradeable(address(item.nft));
        try royaltyNft.royaltyInfo(item.tokenId, item.price) returns (address receiver, uint256 amount) {
            uint256 sellerTransferAmount = item.price - fee - amount;
            item.seller.transfer(sellerTransferAmount);
            feeAccount.transfer(fee);
            payable(receiver).transfer(amount);

            emit PaymentSplit(
                _itemId,
                address(item.nft),
                item.tokenId,
                sellerTransferAmount,
                msg.sender,
                item.seller);

            emit PaymentSplit(
                _itemId,
                address(item.nft),
                item.tokenId,
                amount,
                msg.sender,
                receiver);
        } catch {
            uint256 sellerTransferAmount = item.price - fee;
            item.seller.transfer(sellerTransferAmount);
            feeAccount.transfer(fee);

            emit PaymentSplit(
                _itemId,
                address(item.nft),
                item.tokenId,
                sellerTransferAmount,
                msg.sender,
                item.seller);
        }

        emit PaymentSplit(
            _itemId,
            address(item.nft),
            item.tokenId,
            fee,
            msg.sender,
            feeAccount);
        
            item.nft.transferFrom(address(this), msg.sender, item.tokenId);
    }

    function cancelSale(uint256 _itemId) external nonReentrant {

        Item storage item = items[_itemId];
        MintItem memory mintingItem = mintItems[_itemId];
        require(item.sold == false, "Item has already been sold!");
        require(msg.sender == item.seller, "You do not have permission to cancel sale");

        item.canceled = true;
        
        if (!mintingItem.shouldMint) {
            item.nft.transferFrom(address(this), item.seller, item.tokenId);
        } 
        

        emit Cancelled(_itemId, address(item.nft), item.tokenId);
    }

    function updateSalePrice(uint256 _itemId, uint _price) external nonReentrant {

        Item storage item = items[_itemId];
        require(item.sold == false, "Item has already been sold!");
        require(msg.sender == item.seller, "You do not have permission to cancel sale");
        require(item.nft.ownerOf(_itemId) == address(this), "The contract does not have ownership of token");

        item.price = _price;

        emit UpdateSalePrice(_itemId, address(item.nft), item.tokenId, _price, item.seller);
    }

    function getTotalPrice(uint256 _itemId) view public returns(uint){

        return items[_itemId].price;
    }

    function getFee(uint256 _itemId) view public returns(uint) {

        return calculateFee(items[_itemId].price, feePercent);
    }

    function getInitialFee(uint256 _itemId) view public returns(uint) {

        return calculateFee(items[_itemId].price, initialFeePercent);
    }


    function calculateFee(uint amount, uint percentage)
        public
        pure
        returns (uint)
    {

        require((amount / 10000) * 10000 == amount, "Too Small");
        return (amount * percentage) / 10000;
    }

      function setMintAdmin(address newAdmin) public onlyOwner {

        mintAdmin = newAdmin;
    }

    function getMintAdmin() public view returns(address) {

        return mintAdmin;
    }

    function nftContractEmit(address nftContract) public {

        HPApprovedMarketplace emittingContract = HPApprovedMarketplace(address(nftContract));
        emittingContract.msgSenderEmit();
    }
}