
pragma solidity ^0.8.4;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC1155 is IERC165 {

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id)
        external
        view
        returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator)
        external
        view
        returns (bool);


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

}

interface IERC1155Receiver is IERC165 {

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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC721 is IERC165 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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


    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IDiscountManager {

    function getDiscount(address buyer)
        external
        view
        returns (uint256 discount);

}

contract ShiryoMarket is IERC1155Receiver, ReentrancyGuard {

    using SafeMath for uint256;

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

     modifier onlyClevel() {

        require(msg.sender == walletA || msg.sender == walletB || msg.sender == owner);
    _;
    }

    address walletA;
    address walletB;
    uint256 walletBPercentage = 20;

    using Counters for Counters.Counter;
    Counters.Counter public _itemIds; // Id for each individual item
    Counters.Counter private _itemsSold; // Number of items sold
    Counters.Counter private _itemsCancelled; // Number of items sold
    Counters.Counter private _offerIds; // Tracking offers

    address payable public owner; // The owner of the market contract
    address public discountManager = address(0x0); // a contract that can be callled to discover if there is a discount on the transaction fee.

    uint256 public saleFeePercentage = 5; // Percentage fee paid to team for each sale
    uint256 public accumulatedFee = 0;

    uint256 public volumeTraded = 0; // Total amount traded

    enum TokenType {
        ERC721, //0
        ERC1155, //1
        ERC20 //2
    }

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketOffer {
        uint256 offerId;
        uint256 itemId;
        address payable bidder;
        uint256 offerAmount;
        uint256 offerTime;
        bool cancelled;
        bool accepted;
    }

    struct MarketItem {
        uint256 itemId;
        address tokenContract;
        TokenType tokenType;
        uint256 tokenId; // 0 If token is ERC20
        uint256 amount; // 1 unless QTY of ERC20
        address payable seller;
        address payable buyer;
        string category;
        uint256 price;
        bool isSold;
        bool cancelled;
    }

    mapping(uint256 => MarketItem) public idToMarketItem;

    mapping(uint256 => uint256[]) public itemIdToMarketOfferIds;

    mapping(uint256 => MarketOffer) public offerIdToMarketOffer;

    mapping(address => uint256[]) public bidderToMarketOfferIds;

    mapping(address => bool) public approvedSourceContracts;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        uint256 amount,
        address seller,
        address owner,
        string category,
        uint256 price
    );

    event MarketSaleCreated(
        uint256 indexed itemId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        address seller,
        address buyer,
        string category,
        uint256 price
    );

    event ItemOfferCreated(
        uint256 indexed itemId,
        address indexed tokenContract,
        address owner,
        address bidder,
        uint256 bidAmount
    );

    function transferAnyToken(
        TokenType _tokenType,
        address _tokenContract,
        address _from,
        address _to,
        uint256 _tokenId,
        uint256 _amount
    ) internal {

        if (_tokenType == TokenType.ERC721) {
            IERC721(_tokenContract).transferFrom(_from, _to, _tokenId);
            return;
        }

        if (_tokenType == TokenType.ERC1155) {
            IERC1155(_tokenContract).safeTransferFrom(
                _from,
                _to,
                _tokenId,
                1,
                ""
            ); // amount - only 1 of an ERC1155 per item
            return;
        }

        if (_tokenType == TokenType.ERC20) {
            if (_from==address(this)){
                IERC20(_tokenContract).approve(address(this), _amount);
            }
            IERC20(_tokenContract).transferFrom(_from, _to, _amount); // amount - ERC20 can be multiple tokens per item (bundle)
            return;
        }
    }

    
    function createMarketItem(
        address _tokenContract,
        TokenType _tokenType,
        uint256 _tokenId,
        uint256 _amount,
        uint256 _price,
        string calldata _category
    ) public nonReentrant {

        require(_price > 0, "No item for free here");
        require(_amount > 0, "At least one token");
        require(approvedSourceContracts[_tokenContract]==true,"Token contract not approved");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        idToMarketItem[itemId] = MarketItem(
            itemId,
            _tokenContract,
            _tokenType,
            _tokenId,
            _amount,
            payable(msg.sender),
            payable(address(0)), // No owner for the item
            _category,
            _price,
            false,
            false
        );

        transferAnyToken(
            _tokenType,
            _tokenContract,
            msg.sender,
            address(this),
            _tokenId,
            _amount
        );

        emit MarketItemCreated(
            itemId,
            _tokenContract,
            _tokenId,
            _amount,
            msg.sender,
            address(0),
            _category,
            _price
        );
    }

    function cancelMarketItem(uint256 itemId) public {

        require(itemId <= _itemIds.current());
        require(idToMarketItem[itemId].seller == msg.sender);
        require(
            idToMarketItem[itemId].cancelled == false &&
                idToMarketItem[itemId].isSold == false
        );

        idToMarketItem[itemId].cancelled = true;
        _itemsCancelled.increment();

        transferAnyToken(
            idToMarketItem[itemId].tokenType,
            idToMarketItem[itemId].tokenContract,
            address(this),
            msg.sender,
            idToMarketItem[itemId].tokenId,
            idToMarketItem[itemId].amount
        );
    }


    function createMarketSale(uint256 itemId) public payable nonReentrant {

        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(
            msg.value == price,
            "Not the correct message value"
        );
        require(
            idToMarketItem[itemId].isSold == false,
            "This item is already sold."
        );
        require(
            idToMarketItem[itemId].cancelled == false,
            "This item is not for sale."
        );
        require(
            idToMarketItem[itemId].seller != msg.sender,
            "Cannot buy your own item."
        );

        uint256 fees = SafeMath.div(price, 100).mul(saleFeePercentage);

        if (discountManager != address(0x0)) {
            uint256 feeDiscountPercent = IDiscountManager(discountManager)
                .getDiscount(msg.sender);
            fees = fees.div(100).mul(feeDiscountPercent);
        }

        uint256 saleAmount = price.sub(fees);
        idToMarketItem[itemId].seller.transfer(saleAmount);
        accumulatedFee+=fees;

        transferAnyToken(
            idToMarketItem[itemId].tokenType,
            idToMarketItem[itemId].tokenContract,
            address(this),
            msg.sender,
            tokenId,
            idToMarketItem[itemId].amount
        );

        idToMarketItem[itemId].isSold = true;
        idToMarketItem[itemId].buyer = payable(msg.sender);

        _itemsSold.increment();
        volumeTraded = volumeTraded.add(price);

        emit MarketSaleCreated(
            itemId,
            idToMarketItem[itemId].tokenContract,
            tokenId,
            idToMarketItem[itemId].seller,
            msg.sender,
            idToMarketItem[itemId].category,
            price
        );
    }

    function getMarketItemsByPage(uint256 _from, uint256 _to) external view returns (MarketItem[] memory) {

        require(_from < _itemIds.current() && _to <= _itemIds.current(), "Page out of range.");

        uint256 itemCount;
        for (uint256 i = _from; i <= _to; i++) {
            if (
                idToMarketItem[i].buyer == address(0) &&
                idToMarketItem[i].cancelled == false &&
                idToMarketItem[i].isSold == false
            ){
                itemCount++;
            }
        }

        uint256 currentIndex = 0;
        MarketItem[] memory marketItems = new MarketItem[](itemCount);
        for (uint256 i = _from; i <= _to; i++) {

             if (
                idToMarketItem[i].buyer == address(0) &&
                idToMarketItem[i].cancelled == false &&
                idToMarketItem[i].isSold == false
            ){
                uint256 currentId = idToMarketItem[i].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                marketItems[currentIndex] = currentItem;
                currentIndex += 1;
            }

        }
        return marketItems;
    }

    function getMarketItems() external view returns (MarketItem[] memory) {

        uint256 itemCount = _itemIds.current();
        uint256 unsoldItemCount = _itemIds.current() -
            (_itemsSold.current() + _itemsCancelled.current());
        uint256 currentIndex = 0;

        MarketItem[] memory marketItems = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (
                idToMarketItem[i + 1].buyer == address(0) &&
                idToMarketItem[i + 1].cancelled == false &&
                idToMarketItem[i + 1].isSold == false
            ) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                marketItems[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return marketItems;
    }

    function getMarketItemsBySeller(address _seller)
        external
        view
        returns (MarketItem[] memory)
    {

        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (
                idToMarketItem[i + 1].seller == _seller &&
                idToMarketItem[i + 1].cancelled == false &&
                idToMarketItem[i + 1].isSold == false //&&
            ) {
                itemCount += 1; // No dynamic length. Predefined length has to be made
            }
        }

        MarketItem[] memory marketItems = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (
                idToMarketItem[i + 1].seller == _seller &&
                idToMarketItem[i + 1].cancelled == false &&
                idToMarketItem[i + 1].isSold == false //&&
            ) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                marketItems[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return marketItems;
    }

    function getMarketItemsBySellerByPage(address _seller, uint256 _from , uint256 _to)
        external
        view
        returns (MarketItem[] memory)
    {

        require(_from < _itemIds.current() && _to <= _itemIds.current(), "Page out of range.");

        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = _from; i <= _to; i++) {
            if (
                idToMarketItem[i].seller == _seller &&
                idToMarketItem[i].cancelled == false &&
                idToMarketItem[i].isSold == false //&&
            ) {
                itemCount += 1; // No dynamic length. Predefined length has to be made
            }
        }

        MarketItem[] memory marketItems = new MarketItem[](itemCount);
        for (uint256 i =  _from; i <= _to; i++) {
            if (
                idToMarketItem[i].seller == _seller &&
                idToMarketItem[i].cancelled == false &&
                idToMarketItem[i].isSold == false //&&
            ) {
                uint256 currentId = idToMarketItem[i].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                marketItems[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return marketItems;
    }

    function getItemsByCategory(string calldata category)
        external
        view
        returns (MarketItem[] memory)
    {

        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (
                keccak256(abi.encodePacked(idToMarketItem[i + 1].category)) ==
                keccak256(abi.encodePacked(category)) &&
                idToMarketItem[i + 1].buyer == address(0) &&
                idToMarketItem[i + 1].cancelled == false &&
                idToMarketItem[i + 1].isSold == false
            ) {
                itemCount += 1;
            }
        }

        MarketItem[] memory marketItems = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (
                keccak256(abi.encodePacked(idToMarketItem[i + 1].category)) ==
                keccak256(abi.encodePacked(category)) &&
                idToMarketItem[i + 1].buyer == address(0) &&
                idToMarketItem[i + 1].cancelled == false &&
                idToMarketItem[i + 1].isSold == false
            ) {
                uint256 currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                marketItems[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return marketItems;
    }

    function getItemsSold() external view returns (uint256) {

        return _itemsSold.current();
    }

    function numberOfItemsListed() external view returns (uint256) {

        uint256 unsoldItemCount = _itemIds.current() -
            (_itemsSold.current() + _itemsCancelled.current());
        return unsoldItemCount;
    }





    function makeItemOffer(uint256 _itemId) public payable nonReentrant {

        require(
            idToMarketItem[_itemId].tokenContract != address(0x0) &&
                idToMarketItem[_itemId].isSold == false &&
                idToMarketItem[_itemId].cancelled == false,
            "Invalid item id."
        );
        require(msg.value > 0, "Can't offer nothing.");

        _offerIds.increment();
        uint256 offerId = _offerIds.current();

        MarketOffer memory offer = MarketOffer(
            offerId,
            _itemId,
            payable(msg.sender),
            msg.value,
            block.timestamp,
            false,
            false
        );

        offerIdToMarketOffer[offerId] = offer;
        itemIdToMarketOfferIds[_itemId].push(offerId);
        bidderToMarketOfferIds[msg.sender].push(offerId);

        emit ItemOfferCreated(
            _itemId,
            idToMarketItem[_itemId].tokenContract,
            idToMarketItem[_itemId].seller,
            msg.sender,
            msg.value
        );
    }

    function acceptItemOffer(uint256 _offerId) public nonReentrant {

        uint256 itemId = offerIdToMarketOffer[_offerId].itemId;

        require(idToMarketItem[itemId].seller == msg.sender, "Not item seller");

        require(
            offerIdToMarketOffer[_offerId].accepted == false &&
                offerIdToMarketOffer[_offerId].cancelled == false,
            "Already accepted or cancelled."
        );

        uint256 price = offerIdToMarketOffer[_offerId].offerAmount;
        address bidder = payable(offerIdToMarketOffer[_offerId].bidder);

        uint256 fees = SafeMath.div(price, 100).mul(saleFeePercentage);

        if (discountManager != address(0x0)) {
            uint256 feeDiscountPercent = IDiscountManager(discountManager)
                .getDiscount(msg.sender);
            fees = fees.div(100).mul(feeDiscountPercent);
        }

        uint256 saleAmount = price.sub(fees);
        payable(msg.sender).transfer(saleAmount);
        if (fees > 0) {
            accumulatedFee+=fees;
        }

        transferAnyToken(
            idToMarketItem[itemId].tokenType,
            idToMarketItem[itemId].tokenContract,
            address(this),
            offerIdToMarketOffer[_offerId].bidder,
            idToMarketItem[itemId].tokenId,
            idToMarketItem[itemId].amount
        );

        offerIdToMarketOffer[_offerId].accepted = true;
        
        idToMarketItem[itemId].isSold = true;
        idToMarketItem[itemId].buyer = offerIdToMarketOffer[_offerId].bidder;

        _itemsSold.increment();

        emit MarketSaleCreated(
            itemId,
            idToMarketItem[itemId].tokenContract,
            idToMarketItem[itemId].tokenId,
            msg.sender,
            bidder,
            idToMarketItem[itemId].category,
            price
        );

        volumeTraded = volumeTraded.add(price);
    }

    function canceItemOffer(uint256 _offerId) public nonReentrant {

        require(
            offerIdToMarketOffer[_offerId].bidder == msg.sender &&
                offerIdToMarketOffer[_offerId].cancelled == false,
            "Wrong bidder or offer is already cancelled"
        );
        require(
            offerIdToMarketOffer[_offerId].accepted == false,
            "Already accepted."
        );

        address bidder = offerIdToMarketOffer[_offerId].bidder;

        offerIdToMarketOffer[_offerId].cancelled = true;
        payable(bidder).transfer(offerIdToMarketOffer[_offerId].offerAmount);

    }

     function getOffersByBidder(address _bidder)
        external
        view
        returns (MarketOffer[] memory)
    {

        uint256 openOfferCount = 0;
        uint256[] memory itemOfferIds = bidderToMarketOfferIds[_bidder];

        for (uint256 i = 0; i < itemOfferIds.length; i++) {
            if (
                offerIdToMarketOffer[itemOfferIds[i]].accepted == false &&
                offerIdToMarketOffer[itemOfferIds[i]].cancelled == false
            ) {
                openOfferCount++;
            }
        }

        MarketOffer[] memory openOffers = new MarketOffer[](openOfferCount);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < itemOfferIds.length; i++) {
            if (
                offerIdToMarketOffer[itemOfferIds[i]].accepted == false &&
                offerIdToMarketOffer[itemOfferIds[i]].cancelled == false
            ) {
                MarketOffer memory currentItem = offerIdToMarketOffer[
                    itemOfferIds[i]
                ];
                openOffers[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return openOffers;
    }

     function getTotalOffersMadeByBidder(address _bidder) external view returns (uint256){

         return bidderToMarketOfferIds[_bidder].length;
     }

     function getOpenOffersByBidderByPage(address _bidder, uint256 _from , uint256 _to)
        external
        view
        returns (MarketOffer[] memory)
    {

        uint256 openOfferCount = 0;
        uint256[] memory itemOfferIds = bidderToMarketOfferIds[_bidder];

        for (uint256 i = _from; i <= _to; i++) {
            if (
                offerIdToMarketOffer[itemOfferIds[i]].accepted == false &&
                offerIdToMarketOffer[itemOfferIds[i]].cancelled == false
            ) {
                openOfferCount++;
            }
        }

        MarketOffer[] memory openOffers = new MarketOffer[](openOfferCount);
        uint256 currentIndex = 0;
        for (uint256 i = _from; i <= _to; i++) {
            if (
                offerIdToMarketOffer[itemOfferIds[i]].accepted == false &&
                offerIdToMarketOffer[itemOfferIds[i]].cancelled == false
            ) {
                MarketOffer memory currentItem = offerIdToMarketOffer[
                    itemOfferIds[i]
                ];
                openOffers[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return openOffers;
    }

    function getItemOffers(uint256 _itemId)
        external
        view
        returns (MarketOffer[] memory)
    {

        uint256 openOfferCount = 0;
        uint256[] memory itemOfferIds = itemIdToMarketOfferIds[_itemId];

        for (uint256 i = 0; i < itemOfferIds.length; i++) {
            if (
                offerIdToMarketOffer[itemOfferIds[i]].accepted == false &&
                offerIdToMarketOffer[itemOfferIds[i]].cancelled == false
            ) {
                openOfferCount++;
            }
        }

        MarketOffer[] memory openOffers = new MarketOffer[](openOfferCount);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < itemOfferIds.length; i++) {
            if (
                offerIdToMarketOffer[itemOfferIds[i]].accepted == false &&
                offerIdToMarketOffer[itemOfferIds[i]].cancelled == false
            ) {
                MarketOffer memory currentItem = offerIdToMarketOffer[
                    itemOfferIds[i]
                ];
                openOffers[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return openOffers;
    }

    function setSalePercentageFee(uint256 _amount) public onlyOwner {

        require(_amount <= 5, "5% maximum fee allowed.");
        saleFeePercentage = _amount;
    }

    function setOwner(address _owner) public onlyOwner {

        require(_owner != address(0x0), "0x0 address not permitted");
        owner = payable(_owner);
    }

    function setDiscountManager(address _discountManager) public onlyOwner {

        require(_discountManager != address(0x0), "0x0 address not permitted");
        discountManager = _discountManager;
    }

    function setSourceContractApproved(address _tokenContract, bool _approved) external onlyOwner {

        approvedSourceContracts[_tokenContract]=_approved;
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


    function supportsInterface(bytes4 interfaceId) override external pure returns (bool){

            return interfaceId == type(IERC1155Receiver).interfaceId
            || true;
    }

    function withdraw_all() external onlyClevel {

        require (accumulatedFee > 0);
        uint256 amountB = SafeMath.div(accumulatedFee,100).mul(walletBPercentage);
        uint256 amountA = accumulatedFee.sub(amountB);
        accumulatedFee = 0;
        payable(walletA).transfer(amountA);
        payable(walletB).transfer(amountB);
    }

    function setWalletA(address _walletA) external onlyOwner {

        require (_walletA != address(0x0), "Invalid wallet");
        walletA = _walletA;
    }

    function setWalletB(address _walletB) external onlyOwner {

        require (_walletB != address(0x0), "Invalid wallet.");
        walletB = _walletB;
    }

    function setWalletBPercentage(uint256 _percentage) external onlyOwner {

        require (_percentage>walletBPercentage && _percentage<=100, "Invalid new slice.");
        walletBPercentage = _percentage;
    }

}

library Counters {

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
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}