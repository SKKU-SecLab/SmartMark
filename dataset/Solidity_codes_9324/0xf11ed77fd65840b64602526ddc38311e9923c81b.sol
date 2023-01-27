


pragma solidity 0.8.4;

interface IKOAccessControlsLookup {

    function hasAdminRole(address _address) external view returns (bool);


    function isVerifiedArtist(uint256 _index, address _account, bytes32[] calldata _merkleProof) external view returns (bool);


    function isVerifiedArtistProxy(address _artist, address _proxy) external view returns (bool);


    function hasLegacyMinterRole(address _address) external view returns (bool);


    function hasContractRole(address _address) external view returns (bool);


    function hasContractOrAdminRole(address _address) external view returns (bool);

}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




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

}




pragma solidity 0.8.4;

interface IERC2309 {

    event ConsecutiveTransfer(uint256 indexed fromTokenId, uint256 toTokenId, address indexed fromAddress, address indexed toAddress);
}




pragma solidity 0.8.4;


interface IERC2981EditionExtension {


    function hasRoyalties(uint256 _editionId) external view returns (bool);


    function getRoyaltiesReceiver(uint256 _editionId) external view returns (address);

}

interface IERC2981 is IERC165, IERC2981EditionExtension {


    function royaltyInfo(
        uint256 _tokenId,
        uint256 _value
    ) external view returns (
        address _receiver,
        uint256 _royaltyAmount
    );


}




pragma solidity 0.8.4;


interface IHasSecondarySaleFees is IERC165 {


    event SecondarySaleFees(uint256 tokenId, address[] recipients, uint[] bps);

    function getFeeRecipients(uint256 id) external returns (address payable[] memory);


    function getFeeBps(uint256 id) external returns (uint[] memory);

}




pragma solidity 0.8.4;






interface IKODAV3 is
IERC165, // Contract introspection
IERC721, // Core NFTs
IERC2309, // Consecutive batch mint
IERC2981, // Royalties
IHasSecondarySaleFees // Rariable / Foundation royalties
{


    function getCreatorOfEdition(uint256 _editionId) external view returns (address _originalCreator);


    function getCreatorOfToken(uint256 _tokenId) external view returns (address _originalCreator);


    function getSizeOfEdition(uint256 _editionId) external view returns (uint256 _size);


    function getEditionSizeOfToken(uint256 _tokenId) external view returns (uint256 _size);


    function editionExists(uint256 _editionId) external view returns (bool);


    function isEditionSalesDisabled(uint256 _editionId) external view returns (bool);


    function isSalesDisabledOrSoldOut(uint256 _editionId) external view returns (bool);


    function maxTokenIdOfEdition(uint256 _editionId) external view returns (uint256 _tokenId);


    function getNextAvailablePrimarySaleToken(uint256 _editionId) external returns (uint256 _tokenId);


    function getReverseAvailablePrimarySaleToken(uint256 _editionId) external view returns (uint256 _tokenId);


    function facilitateNextPrimarySale(uint256 _editionId) external returns (address _receiver, address _creator, uint256 _tokenId);


    function facilitateReversePrimarySale(uint256 _editionId) external returns (address _receiver, address _creator, uint256 _tokenId);


    function royaltyAndCreatorInfo(uint256 _editionId, uint256 _value) external returns (address _receiver, address _creator, uint256 _amount);


    function updateURIIfNoSaleMade(uint256 _editionId, string calldata _newURI) external;


    function hasMadePrimarySale(uint256 _editionId) external view returns (bool);


    function isEditionSoldOut(uint256 _editionId) external view returns (bool);


    function toggleEditionSalesDisabled(uint256 _editionId) external;



    function exists(uint256 _tokenId) external view returns (bool);


    function getEditionIdOfToken(uint256 _tokenId) external pure returns (uint256 _editionId);


    function getEditionDetails(uint256 _tokenId) external view returns (address _originalCreator, address _owner, uint16 _size, uint256 _editionId, string memory _uri);


    function hadPrimarySaleOfToken(uint256 _tokenId) external view returns (bool);


}



pragma solidity 0.8.4;

interface IBuyNowMarketplace {

    event ListedForBuyNow(uint256 indexed _id, uint256 _price, address _currentOwner, uint256 _startDate);
    event BuyNowPriceChanged(uint256 indexed _id, uint256 _price);
    event BuyNowDeListed(uint256 indexed _id);
    event BuyNowPurchased(uint256 indexed _tokenId, address _buyer, address _currentOwner, uint256 _price);

    function listForBuyNow(address _creator, uint256 _id, uint128 _listingPrice, uint128 _startDate) external;


    function buyEditionToken(uint256 _id) external payable;

    function buyEditionTokenFor(uint256 _id, address _recipient) external payable;


    function setBuyNowPriceListing(uint256 _editionId, uint128 _listingPrice) external;

}

interface IEditionOffersMarketplace {

    event EditionAcceptingOffer(uint256 indexed _editionId, uint128 _startDate);
    event EditionBidPlaced(uint256 indexed _editionId, address _bidder, uint256 _amount);
    event EditionBidWithdrawn(uint256 indexed _editionId, address _bidder);
    event EditionBidAccepted(uint256 indexed _editionId, uint256 indexed _tokenId, address _bidder, uint256 _amount);
    event EditionBidRejected(uint256 indexed _editionId, address _bidder, uint256 _amount);
    event EditionConvertedFromOffersToBuyItNow(uint256 _editionId, uint128 _price, uint128 _startDate);

    function enableEditionOffers(uint256 _editionId, uint128 _startDate) external;


    function placeEditionBid(uint256 _editionId) external payable;

    function placeEditionBidFor(uint256 _editionId, address _bidder) external payable;


    function withdrawEditionBid(uint256 _editionId) external;


    function rejectEditionBid(uint256 _editionId) external;


    function acceptEditionBid(uint256 _editionId, uint256 _offerPrice) external;


    function convertOffersToBuyItNow(uint256 _editionId, uint128 _listingPrice, uint128 _startDate) external;

}

interface IEditionSteppedMarketplace {

    event EditionSteppedSaleListed(uint256 indexed _editionId, uint128 _basePrice, uint128 _stepPrice, uint128 _startDate);
    event EditionSteppedSaleBuy(uint256 indexed _editionId, uint256 indexed _tokenId, address _buyer, uint256 _price, uint16 _currentStep);
    event EditionSteppedAuctionUpdated(uint256 indexed _editionId, uint128 _basePrice, uint128 _stepPrice);

    function listSteppedEditionAuction(address _creator, uint256 _editionId, uint128 _basePrice, uint128 _stepPrice, uint128 _startDate) external;


    function buyNextStep(uint256 _editionId) external payable;

    function buyNextStepFor(uint256 _editionId, address _buyer) external payable;


    function convertSteppedAuctionToListing(uint256 _editionId, uint128 _listingPrice, uint128 _startDate) external;


    function convertSteppedAuctionToOffers(uint256 _editionId, uint128 _startDate) external;


    function updateSteppedAuction(uint256 _editionId, uint128 _basePrice, uint128 _stepPrice) external;

}

interface IReserveAuctionMarketplace {

    event ListedForReserveAuction(uint256 indexed _id, uint256 _reservePrice, uint128 _startDate);
    event BidPlacedOnReserveAuction(uint256 indexed _id, address _currentOwner, address _bidder, uint256 _amount, uint256 _originalBiddingEnd, uint256 _currentBiddingEnd);
    event ReserveAuctionResulted(uint256 indexed _id, uint256 _finalPrice, address _currentOwner, address _winner, address _resulter);
    event BidWithdrawnFromReserveAuction(uint256 _id, address _bidder, uint128 _bid);
    event ReservePriceUpdated(uint256 indexed _id, uint256 _reservePrice);
    event ReserveAuctionConvertedToBuyItNow(uint256 indexed _id, uint128 _listingPrice, uint128 _startDate);
    event EmergencyBidWithdrawFromReserveAuction(uint256 indexed _id, address _bidder, uint128 _bid);

    function placeBidOnReserveAuction(uint256 _id) external payable;

    function placeBidOnReserveAuctionFor(uint256 _id, address _bidder) external payable;


    function listForReserveAuction(address _creator, uint256 _id, uint128 _reservePrice, uint128 _startDate) external;


    function resultReserveAuction(uint256 _id) external;


    function withdrawBidFromReserveAuction(uint256 _id) external;


    function updateReservePriceForReserveAuction(uint256 _id, uint128 _reservePrice) external;


    function emergencyExitBidFromReserveAuction(uint256 _id) external;

}

interface IKODAV3PrimarySaleMarketplace is IEditionSteppedMarketplace, IEditionOffersMarketplace, IBuyNowMarketplace, IReserveAuctionMarketplace {

    function convertReserveAuctionToBuyItNow(uint256 _editionId, uint128 _listingPrice, uint128 _startDate) external;


    function convertReserveAuctionToOffers(uint256 _editionId, uint128 _startDate) external;

}

interface ITokenBuyNowMarketplace {

    event TokenDeListed(uint256 indexed _tokenId);

    function delistToken(uint256 _tokenId) external;

}

interface ITokenOffersMarketplace {

    event TokenBidPlaced(uint256 indexed _tokenId, address _currentOwner, address _bidder, uint256 _amount);
    event TokenBidAccepted(uint256 indexed _tokenId, address _currentOwner, address _bidder, uint256 _amount);
    event TokenBidRejected(uint256 indexed _tokenId, address _currentOwner, address _bidder, uint256 _amount);
    event TokenBidWithdrawn(uint256 indexed _tokenId, address _bidder);

    function acceptTokenBid(uint256 _tokenId, uint256 _offerPrice) external;


    function rejectTokenBid(uint256 _tokenId) external;


    function withdrawTokenBid(uint256 _tokenId) external;


    function placeTokenBid(uint256 _tokenId) external payable;

    function placeTokenBidFor(uint256 _tokenId, address _bidder) external payable;

}

interface IBuyNowSecondaryMarketplace {

    function listTokenForBuyNow(uint256 _tokenId, uint128 _listingPrice, uint128 _startDate) external;

}

interface IEditionOffersSecondaryMarketplace {

    event EditionBidPlaced(uint256 indexed _editionId, address indexed _bidder, uint256 _bid);
    event EditionBidWithdrawn(uint256 indexed _editionId, address _bidder);
    event EditionBidAccepted(uint256 indexed _tokenId, address _currentOwner, address _bidder, uint256 _amount);

    function placeEditionBid(uint256 _editionId) external payable;

    function placeEditionBidFor(uint256 _editionId, address _bidder) external payable;


    function withdrawEditionBid(uint256 _editionId) external;


    function acceptEditionBid(uint256 _tokenId, uint256 _offerPrice) external;

}

interface IKODAV3SecondarySaleMarketplace is ITokenBuyNowMarketplace, ITokenOffersMarketplace, IEditionOffersSecondaryMarketplace, IBuyNowSecondaryMarketplace {

    function convertReserveAuctionToBuyItNow(uint256 _tokenId, uint128 _listingPrice, uint128 _startDate) external;


    function convertReserveAuctionToOffers(uint256 _tokenId) external;

}




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}




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




pragma solidity 0.8.4;






abstract contract BaseMarketplace is ReentrancyGuard, Pausable {

    event AdminUpdateModulo(uint256 _modulo);
    event AdminUpdateMinBidAmount(uint256 _minBidAmount);
    event AdminUpdateAccessControls(IKOAccessControlsLookup indexed _oldAddress, IKOAccessControlsLookup indexed _newAddress);
    event AdminUpdatePlatformPrimarySaleCommission(uint256 _platformPrimarySaleCommission);
    event AdminUpdateBidLockupPeriod(uint256 _bidLockupPeriod);
    event AdminUpdatePlatformAccount(address indexed _oldAddress, address indexed _newAddress);
    event AdminRecoverERC20(IERC20 indexed _token, address indexed _recipient, uint256 _amount);
    event AdminRecoverETH(address payable indexed _recipient, uint256 _amount);

    event BidderRefunded(uint256 indexed _id, address _bidder, uint256 _bid, address _newBidder, uint256 _newOffer);
    event BidderRefundedFailed(uint256 indexed _id, address _bidder, uint256 _bid, address _newBidder, uint256 _newOffer);

    modifier onlyContract() {
        _onlyContract();
        _;
    }

    function _onlyContract() private view {
        require(accessControls.hasContractRole(_msgSender()), "Caller not contract");
    }

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    function _onlyAdmin() private view {
        require(accessControls.hasAdminRole(_msgSender()), "Caller not admin");
    }

    IKOAccessControlsLookup public accessControls;

    IKODAV3 public koda;

    address public platformAccount;

    uint256 public modulo = 100_00000;

    uint256 public minBidAmount = 0.01 ether;

    uint256 public bidLockupPeriod = 6 hours;

    constructor(IKOAccessControlsLookup _accessControls, IKODAV3 _koda, address _platformAccount) {
        koda = _koda;
        accessControls = _accessControls;
        platformAccount = _platformAccount;
    }

    function recoverERC20(IERC20 _token, address _recipient, uint256 _amount) public onlyAdmin {
        _token.transfer(_recipient, _amount);
        emit AdminRecoverERC20(_token, _recipient, _amount);
    }

    function recoverStuckETH(address payable _recipient, uint256 _amount) public onlyAdmin {
        (bool success,) = _recipient.call{value : _amount}("");
        require(success, "Unable to send recipient ETH");
        emit AdminRecoverETH(_recipient, _amount);
    }

    function updateAccessControls(IKOAccessControlsLookup _accessControls) public onlyAdmin {
        require(_accessControls.hasAdminRole(_msgSender()), "Sender must have admin role in new contract");
        emit AdminUpdateAccessControls(accessControls, _accessControls);
        accessControls = _accessControls;
    }

    function updateModulo(uint256 _modulo) public onlyAdmin {
        require(_modulo > 0, "Modulo point cannot be zero");
        modulo = _modulo;
        emit AdminUpdateModulo(_modulo);
    }

    function updateMinBidAmount(uint256 _minBidAmount) public onlyAdmin {
        minBidAmount = _minBidAmount;
        emit AdminUpdateMinBidAmount(_minBidAmount);
    }

    function updateBidLockupPeriod(uint256 _bidLockupPeriod) public onlyAdmin {
        bidLockupPeriod = _bidLockupPeriod;
        emit AdminUpdateBidLockupPeriod(_bidLockupPeriod);
    }

    function updatePlatformAccount(address _newPlatformAccount) public onlyAdmin {
        emit AdminUpdatePlatformAccount(platformAccount, _newPlatformAccount);
        platformAccount = _newPlatformAccount;
    }

    function pause() public onlyAdmin {
        super._pause();
    }

    function unpause() public onlyAdmin {
        super._unpause();
    }

    function _getLockupTime() internal view returns (uint256 lockupUntil) {
        lockupUntil = block.timestamp + bidLockupPeriod;
    }

    function _refundBidder(uint256 _id, address _receiver, uint256 _paymentAmount, address _newBidder, uint256 _newOffer) internal {
        (bool success,) = _receiver.call{value : _paymentAmount}("");
        if (!success) {
            emit BidderRefundedFailed(_id, _receiver, _paymentAmount, _newBidder, _newOffer);
        } else {
            emit BidderRefunded(_id, _receiver, _paymentAmount, _newBidder, _newOffer);
        }
    }

    function _processSale(
        uint256 _id,
        uint256 _paymentAmount,
        address _buyer,
        address _seller
    ) internal virtual returns (uint256);

    function _isListingPermitted(uint256 _id) internal virtual returns (bool);
}




pragma solidity 0.8.4;



abstract contract BuyNowMarketplace is IBuyNowMarketplace, BaseMarketplace {
    struct Listing {
        uint128 price;
        uint128 startDate;
        address seller;
    }

    mapping(uint256 => Listing) public editionOrTokenListings;

    function listForBuyNow(address _seller, uint256 _id, uint128 _listingPrice, uint128 _startDate)
    public
    override
    whenNotPaused {
        require(_isListingPermitted(_id), "Listing is not permitted");
        require(_isBuyNowListingPermitted(_id), "Buy now listing invalid");
        require(_listingPrice >= minBidAmount, "Listing price not enough");

        editionOrTokenListings[_id] = Listing(_listingPrice, _startDate, _seller);

        emit ListedForBuyNow(_id, _listingPrice, _seller, _startDate);
    }

    function buyEditionToken(uint256 _id)
    public
    override
    payable
    whenNotPaused
    nonReentrant {
        _facilitateBuyNow(_id, _msgSender());
    }

    function buyEditionTokenFor(uint256 _id, address _recipient)
    public
    override
    payable
    whenNotPaused
    nonReentrant {
        _facilitateBuyNow(_id, _recipient);
    }

    function setBuyNowPriceListing(uint256 _id, uint128 _listingPrice)
    public
    override
    whenNotPaused {
        require(
            editionOrTokenListings[_id].seller == _msgSender()
            || accessControls.isVerifiedArtistProxy(editionOrTokenListings[_id].seller, _msgSender()),
            "Only seller can change price"
        );

        editionOrTokenListings[_id].price = _listingPrice;

        emit BuyNowPriceChanged(_id, _listingPrice);
    }

    function _facilitateBuyNow(uint256 _id, address _recipient) internal {
        Listing storage listing = editionOrTokenListings[_id];
        require(address(0) != listing.seller, "No listing found");
        require(msg.value >= listing.price, "List price not satisfied");
        require(block.timestamp >= listing.startDate, "List not available yet");

        uint256 tokenId = _processSale(_id, msg.value, _recipient, listing.seller);

        emit BuyNowPurchased(tokenId, _recipient, listing.seller, msg.value);
    }

    function _isBuyNowListingPermitted(uint256 _id) internal virtual returns (bool);
}




pragma solidity 0.8.4;





abstract contract ReserveAuctionMarketplace is IReserveAuctionMarketplace, BaseMarketplace {
    event AdminUpdateReserveAuctionBidExtensionWindow(uint128 _reserveAuctionBidExtensionWindow);
    event AdminUpdateReserveAuctionLengthOnceReserveMet(uint128 _reserveAuctionLengthOnceReserveMet);

    struct ReserveAuction {
        address seller;
        address bidder;
        uint128 reservePrice;
        uint128 bid;
        uint128 startDate;
        uint128 biddingEnd;
    }

    mapping(uint256 => ReserveAuction) public editionOrTokenWithReserveAuctions;

    uint128 public reserveAuctionBidExtensionWindow = 15 minutes;

    uint128 public reserveAuctionLengthOnceReserveMet = 24 hours;

    function listForReserveAuction(
        address _creator,
        uint256 _id,
        uint128 _reservePrice,
        uint128 _startDate
    ) public
    override
    whenNotPaused {
        require(_isListingPermitted(_id), "Listing not permitted");
        require(_isReserveListingPermitted(_id), "Reserve listing not permitted");
        require(_reservePrice >= minBidAmount, "Reserve price must be at least min bid");

        editionOrTokenWithReserveAuctions[_id] = ReserveAuction({
        seller : _creator,
        bidder : address(0),
        reservePrice : _reservePrice,
        startDate : _startDate,
        biddingEnd : 0,
        bid : 0
        });

        emit ListedForReserveAuction(_id, _reservePrice, _startDate);
    }

    function placeBidOnReserveAuction(uint256 _id)
    public
    override
    payable
    whenNotPaused
    nonReentrant {
        _placeBidOnReserveAuction(_id, _msgSender());
    }

    function placeBidOnReserveAuctionFor(uint256 _id, address _bidder)
    public
    override
    payable
    whenNotPaused
    nonReentrant {
        _placeBidOnReserveAuction(_id, _bidder);
    }

    function _placeBidOnReserveAuction(uint256 _id, address _bidder) internal {
        ReserveAuction storage reserveAuction = editionOrTokenWithReserveAuctions[_id];
        require(reserveAuction.reservePrice > 0, "Not set up for reserve auction");
        require(block.timestamp >= reserveAuction.startDate, "Not accepting bids yet");
        require(msg.value >= reserveAuction.bid + minBidAmount, "You have not exceeded previous bid by min bid amount");

        uint128 originalBiddingEnd = reserveAuction.biddingEnd;

        bool isCountDownTriggered = originalBiddingEnd > 0;

        if (msg.value >= reserveAuction.reservePrice && !isCountDownTriggered) {
            reserveAuction.biddingEnd = uint128(block.timestamp) + reserveAuctionLengthOnceReserveMet;
        }
        else if (isCountDownTriggered) {

            require(block.timestamp < originalBiddingEnd, "No longer accepting bids");
            uint128 secondsUntilBiddingEnd = originalBiddingEnd - uint128(block.timestamp);

            if (secondsUntilBiddingEnd <= reserveAuctionBidExtensionWindow) {
                reserveAuction.biddingEnd = reserveAuction.biddingEnd + reserveAuctionBidExtensionWindow;
            }
        }

        if (reserveAuction.bid > 0) {
            _refundBidder(_id, reserveAuction.bidder, reserveAuction.bid, _bidder, msg.value);
        }

        reserveAuction.bid = uint128(msg.value);
        reserveAuction.bidder = _bidder;

        emit BidPlacedOnReserveAuction(_id, reserveAuction.seller, _bidder, msg.value, originalBiddingEnd, reserveAuction.biddingEnd);
    }

    function resultReserveAuction(uint256 _id)
    public
    override
    whenNotPaused
    nonReentrant {
        ReserveAuction storage reserveAuction = editionOrTokenWithReserveAuctions[_id];

        require(reserveAuction.reservePrice > 0, "No active auction");
        require(reserveAuction.bid >= reserveAuction.reservePrice, "Reserve not met");
        require(block.timestamp > reserveAuction.biddingEnd, "Bidding has not yet ended");


        address winner = reserveAuction.bidder;
        address seller = reserveAuction.seller;
        uint256 winningBid = reserveAuction.bid;
        delete editionOrTokenWithReserveAuctions[_id];

        _processSale(_id, winningBid, winner, seller);

        emit ReserveAuctionResulted(_id, winningBid, seller, winner, _msgSender());
    }

    function withdrawBidFromReserveAuction(uint256 _id)
    public
    override
    whenNotPaused
    nonReentrant {
        ReserveAuction storage reserveAuction = editionOrTokenWithReserveAuctions[_id];

        require(reserveAuction.reservePrice > 0, "No reserve auction in flight");
        require(reserveAuction.bid < reserveAuction.reservePrice, "Bids can only be withdrawn if reserve not met");
        require(reserveAuction.bidder == _msgSender(), "Only the bidder can withdraw their bid");

        uint256 bidToRefund = reserveAuction.bid;
        _refundBidder(_id, reserveAuction.bidder, bidToRefund, address(0), 0);

        reserveAuction.bidder = address(0);
        reserveAuction.bid = 0;

        emit BidWithdrawnFromReserveAuction(_id, _msgSender(), uint128(bidToRefund));
    }

    function updateReservePriceForReserveAuction(uint256 _id, uint128 _reservePrice)
    public
    override
    whenNotPaused
    nonReentrant {
        ReserveAuction storage reserveAuction = editionOrTokenWithReserveAuctions[_id];

        require(
            reserveAuction.seller == _msgSender()
            || accessControls.isVerifiedArtistProxy(reserveAuction.seller, _msgSender()),
            "Not the seller"
        );

        require(reserveAuction.biddingEnd == 0, "Reserve countdown commenced");
        require(_reservePrice >= minBidAmount, "Reserve must be at least min bid");

        if (reserveAuction.bid >= _reservePrice) {
            reserveAuction.biddingEnd = uint128(block.timestamp) + reserveAuctionLengthOnceReserveMet;
        }

        reserveAuction.reservePrice = _reservePrice;

        emit ReservePriceUpdated(_id, _reservePrice);
    }

    function emergencyExitBidFromReserveAuction(uint256 _id)
    public
    override
    whenNotPaused
    nonReentrant {
        ReserveAuction storage reserveAuction = editionOrTokenWithReserveAuctions[_id];

        require(reserveAuction.bid > 0, "No bid in flight");
        require(_hasReserveListingBeenInvalidated(_id), "Bid cannot be withdrawn as reserve auction listing is valid");

        bool isSeller = reserveAuction.seller == _msgSender();
        bool isBidder = reserveAuction.bidder == _msgSender();
        require(
            isSeller
            || isBidder
            || accessControls.isVerifiedArtistProxy(reserveAuction.seller, _msgSender())
            || accessControls.hasContractOrAdminRole(_msgSender()),
            "Only seller, bidder, contract or platform admin"
        );

        _refundBidder(_id, reserveAuction.bidder, reserveAuction.bid, address(0), 0);

        emit EmergencyBidWithdrawFromReserveAuction(_id, reserveAuction.bidder, reserveAuction.bid);

        delete editionOrTokenWithReserveAuctions[_id];
    }

    function updateReserveAuctionBidExtensionWindow(uint128 _reserveAuctionBidExtensionWindow) onlyAdmin public {
        reserveAuctionBidExtensionWindow = _reserveAuctionBidExtensionWindow;
        emit AdminUpdateReserveAuctionBidExtensionWindow(_reserveAuctionBidExtensionWindow);
    }

    function updateReserveAuctionLengthOnceReserveMet(uint128 _reserveAuctionLengthOnceReserveMet) onlyAdmin public {
        reserveAuctionLengthOnceReserveMet = _reserveAuctionLengthOnceReserveMet;
        emit AdminUpdateReserveAuctionLengthOnceReserveMet(_reserveAuctionLengthOnceReserveMet);
    }

    function _isReserveListingPermitted(uint256 _id) internal virtual returns (bool);

    function _hasReserveListingBeenInvalidated(uint256 _id) internal virtual returns (bool);

    function _removeReserveAuctionListing(uint256 _id) internal {
        ReserveAuction storage reserveAuction = editionOrTokenWithReserveAuctions[_id];

        require(reserveAuction.reservePrice > 0, "No active auction");
        require(reserveAuction.bid < reserveAuction.reservePrice, "Can only convert before reserve met");
        require(reserveAuction.seller == _msgSender(), "Only the seller can convert");

        if (reserveAuction.bid > 0) {
            _refundBidder(_id, reserveAuction.bidder, reserveAuction.bid, address(0), 0);
        }

        delete editionOrTokenWithReserveAuctions[_id];
    }
}




pragma solidity 0.8.4;







contract KODAV3PrimaryMarketplace is
IKODAV3PrimarySaleMarketplace,
BaseMarketplace,
ReserveAuctionMarketplace,
BuyNowMarketplace {


    event PrimaryMarketplaceDeployed();
    event AdminSetKoCommissionOverrideForCreator(address indexed _creator, uint256 _koCommission);
    event AdminSetKoCommissionOverrideForEdition(uint256 indexed _editionId, uint256 _koCommission);
    event ConvertFromBuyNowToOffers(uint256 indexed _editionId, uint128 _startDate);
    event ConvertSteppedAuctionToBuyNow(uint256 indexed _editionId, uint128 _listingPrice, uint128 _startDate);
    event ReserveAuctionConvertedToOffers(uint256 indexed _editionId, uint128 _startDate);

    struct KOCommissionOverride {
        bool active;
        uint256 koCommission;
    }

    struct Offer {
        uint256 offer;
        address bidder;
        uint256 lockupUntil;
    }

    struct Stepped {
        uint128 basePrice;
        uint128 stepPrice;
        uint128 startDate;
        address seller;
        uint16 currentStep;
    }

    mapping(uint256 => KOCommissionOverride) public koCommissionOverrideForEditions;

    mapping(address => KOCommissionOverride) public koCommissionOverrideForCreators;

    mapping(uint256 => Offer) public editionOffers;

    mapping(uint256 => uint256) public editionOffersStartDate;

    mapping(uint256 => Stepped) public editionStep;

    uint256 public platformPrimarySaleCommission = 15_00000;  // 15.00000%

    constructor(IKOAccessControlsLookup _accessControls, IKODAV3 _koda, address _platformAccount)
    BaseMarketplace(_accessControls, _koda, _platformAccount) {
        emit PrimaryMarketplaceDeployed();
    }

    function convertFromBuyNowToOffers(uint256 _editionId, uint128 _startDate)
    public
    whenNotPaused {

        require(
            editionOrTokenListings[_editionId].seller == _msgSender()
            || accessControls.isVerifiedArtistProxy(editionOrTokenListings[_editionId].seller, _msgSender()),
            "Only seller can convert"
        );

        delete editionOrTokenListings[_editionId];

        editionOffersStartDate[_editionId] = _startDate;

        emit ConvertFromBuyNowToOffers(_editionId, _startDate);
    }


    function enableEditionOffers(uint256 _editionId, uint128 _startDate)
    external
    override
    whenNotPaused
    onlyContract {

        editionOffersStartDate[_editionId] = _startDate;

        emit EditionAcceptingOffer(_editionId, _startDate);
    }

    function placeEditionBid(uint256 _editionId)
    public
    override
    payable
    whenNotPaused
    nonReentrant {

        _placeEditionBid(_editionId, _msgSender());
    }

    function placeEditionBidFor(uint256 _editionId, address _bidder)
    public
    override
    payable
    whenNotPaused
    nonReentrant {

        _placeEditionBid(_editionId, _bidder);
    }

    function withdrawEditionBid(uint256 _editionId)
    public
    override
    whenNotPaused
    nonReentrant {

        Offer storage offer = editionOffers[_editionId];
        require(offer.offer > 0, "No open bid");
        require(offer.bidder == _msgSender(), "Not the top bidder");
        require(block.timestamp >= offer.lockupUntil, "Bid lockup not elapsed");

        _refundBidder(_editionId, offer.bidder, offer.offer, address(0), 0);

        emit EditionBidWithdrawn(_editionId, _msgSender());

        delete editionOffers[_editionId];
    }

    function rejectEditionBid(uint256 _editionId)
    public
    override
    whenNotPaused
    nonReentrant {

        Offer storage offer = editionOffers[_editionId];
        require(offer.bidder != address(0), "No open bid");

        address creatorOfEdition = koda.getCreatorOfEdition(_editionId);
        require(
            creatorOfEdition == _msgSender()
            || accessControls.isVerifiedArtistProxy(creatorOfEdition, _msgSender()),
            "Caller not the creator"
        );

        _refundBidder(_editionId, offer.bidder, offer.offer, address(0), 0);

        emit EditionBidRejected(_editionId, offer.bidder, offer.offer);

        delete editionOffers[_editionId];
    }

    function acceptEditionBid(uint256 _editionId, uint256 _offerPrice)
    public
    override
    whenNotPaused
    nonReentrant {

        Offer storage offer = editionOffers[_editionId];
        require(offer.bidder != address(0), "No open bid");
        require(offer.offer >= _offerPrice, "Offer price has changed");

        address creatorOfEdition = koda.getCreatorOfEdition(_editionId);
        require(
            creatorOfEdition == _msgSender()
            || accessControls.isVerifiedArtistProxy(creatorOfEdition, _msgSender()),
            "Not creator"
        );

        uint256 tokenId = _facilitateNextPrimarySale(_editionId, offer.offer, offer.bidder, false);

        emit EditionBidAccepted(_editionId, tokenId, offer.bidder, offer.offer);

        delete editionOffers[_editionId];
    }

    function adminRejectEditionBid(uint256 _editionId) public onlyAdmin nonReentrant {

        Offer storage offer = editionOffers[_editionId];
        require(offer.bidder != address(0), "No open bid");

        if (offer.offer > 0) {
            _refundBidder(_editionId, offer.bidder, offer.offer, address(0), 0);
        }

        emit EditionBidRejected(_editionId, offer.bidder, offer.offer);

        delete editionOffers[_editionId];
    }

    function convertOffersToBuyItNow(uint256 _editionId, uint128 _listingPrice, uint128 _startDate)
    public
    override
    whenNotPaused
    nonReentrant {

        require(!_isEditionListed(_editionId), "Edition is listed");

        address creatorOfEdition = koda.getCreatorOfEdition(_editionId);
        require(
            creatorOfEdition == _msgSender()
            || accessControls.isVerifiedArtistProxy(creatorOfEdition, _msgSender()),
            "Not creator"
        );

        require(_listingPrice >= minBidAmount, "Listing price not enough");

        Offer storage offer = editionOffers[_editionId];
        if (offer.offer > 0) {
            _refundBidder(_editionId, offer.bidder, offer.offer, address(0), 0);
        }

        delete editionOffers[_editionId];

        delete editionOffersStartDate[_editionId];

        editionOrTokenListings[_editionId] = Listing(_listingPrice, _startDate, _msgSender());

        emit EditionConvertedFromOffersToBuyItNow(_editionId, _listingPrice, _startDate);
    }

    function listSteppedEditionAuction(address _creator, uint256 _editionId, uint128 _basePrice, uint128 _stepPrice, uint128 _startDate)
    public
    override
    whenNotPaused
    onlyContract {

        require(_basePrice >= minBidAmount, "Base price not enough");

        editionStep[_editionId] = Stepped(
            _basePrice,
            _stepPrice,
            _startDate,
            _creator,
            uint16(0)
        );

        emit EditionSteppedSaleListed(_editionId, _basePrice, _stepPrice, _startDate);
    }

    function updateSteppedAuction(uint256 _editionId, uint128 _basePrice, uint128 _stepPrice)
    public
    override
    whenNotPaused {

        Stepped storage steppedAuction = editionStep[_editionId];

        require(
            steppedAuction.seller == _msgSender()
            || accessControls.isVerifiedArtistProxy(steppedAuction.seller, _msgSender()),
            "Only seller"
        );

        require(steppedAuction.currentStep == 0, "Only when no sales");
        require(_basePrice >= minBidAmount, "Base price not enough");

        steppedAuction.basePrice = _basePrice;
        steppedAuction.stepPrice = _stepPrice;

        emit EditionSteppedAuctionUpdated(_editionId, _basePrice, _stepPrice);
    }

    function buyNextStep(uint256 _editionId)
    public
    override
    payable
    whenNotPaused
    nonReentrant {

        _buyNextStep(_editionId, _msgSender());
    }

    function buyNextStepFor(uint256 _editionId, address _buyer)
    public
    override
    payable
    whenNotPaused
    nonReentrant {

        _buyNextStep(_editionId, _buyer);
    }

    function _buyNextStep(uint256 _editionId, address _buyer) internal {

        Stepped storage steppedAuction = editionStep[_editionId];
        require(steppedAuction.seller != address(0), "Edition not listed for stepped auction");
        require(steppedAuction.startDate <= block.timestamp, "Not started yet");

        uint256 expectedPrice = _getNextEditionSteppedPrice(_editionId);
        require(msg.value >= expectedPrice, "Expected price not met");

        uint256 tokenId = _facilitateNextPrimarySale(_editionId, expectedPrice, _buyer, true);

        uint16 step = steppedAuction.currentStep;

        steppedAuction.currentStep = step + 1;

        if (msg.value > expectedPrice) {
            (bool success,) = _msgSender().call{value : msg.value - expectedPrice}("");
            require(success, "failed to send overspend back");
        }

        emit EditionSteppedSaleBuy(_editionId, tokenId, _buyer, expectedPrice, step);
    }

    function convertSteppedAuctionToListing(uint256 _editionId, uint128 _listingPrice, uint128 _startDate)
    public
    override
    nonReentrant
    whenNotPaused {

        Stepped storage steppedAuction = editionStep[_editionId];
        require(_listingPrice >= minBidAmount, "List price not enough");

        require(
            steppedAuction.seller == _msgSender()
            || accessControls.isVerifiedArtistProxy(steppedAuction.seller, _msgSender()),
            "Only seller can convert"
        );

        editionOrTokenListings[_editionId] = Listing(_listingPrice, _startDate, steppedAuction.seller);

        emit ConvertSteppedAuctionToBuyNow(_editionId, _listingPrice, _startDate);

        delete editionStep[_editionId];
    }

    function convertSteppedAuctionToOffers(uint256 _editionId, uint128 _startDate)
    public
    override
    whenNotPaused {

        Stepped storage steppedAuction = editionStep[_editionId];

        require(
            steppedAuction.seller == _msgSender()
            || accessControls.isVerifiedArtistProxy(steppedAuction.seller, _msgSender()),
            "Only seller can convert"
        );

        editionOffersStartDate[_editionId] = _startDate;

        delete editionStep[_editionId];

        emit ConvertFromBuyNowToOffers(_editionId, _startDate);
    }

    function getNextEditionSteppedPrice(uint256 _editionId) public view returns (uint256 price) {

        price = _getNextEditionSteppedPrice(_editionId);
    }

    function _getNextEditionSteppedPrice(uint256 _editionId) internal view returns (uint256 price) {

        Stepped storage steppedAuction = editionStep[_editionId];
        uint256 stepAmount = uint256(steppedAuction.stepPrice) * uint256(steppedAuction.currentStep);
        price = uint256(steppedAuction.basePrice) + stepAmount;
    }

    function convertReserveAuctionToBuyItNow(uint256 _editionId, uint128 _listingPrice, uint128 _startDate)
    public
    override
    whenNotPaused
    nonReentrant {

        require(_listingPrice >= minBidAmount, "Listing price not enough");
        _removeReserveAuctionListing(_editionId);

        editionOrTokenListings[_editionId] = Listing(_listingPrice, _startDate, _msgSender());

        emit ReserveAuctionConvertedToBuyItNow(_editionId, _listingPrice, _startDate);
    }

    function convertReserveAuctionToOffers(uint256 _editionId, uint128 _startDate)
    public
    override
    whenNotPaused
    nonReentrant {

        _removeReserveAuctionListing(_editionId);

        editionOffersStartDate[_editionId] = _startDate;

        emit ReserveAuctionConvertedToOffers(_editionId, _startDate);
    }


    function updatePlatformPrimarySaleCommission(uint256 _platformPrimarySaleCommission) public onlyAdmin {

        platformPrimarySaleCommission = _platformPrimarySaleCommission;
        emit AdminUpdatePlatformPrimarySaleCommission(_platformPrimarySaleCommission);
    }

    function setKoCommissionOverrideForCreator(address _creator, bool _active, uint256 _koCommission) public onlyAdmin {

        KOCommissionOverride storage koCommissionOverride = koCommissionOverrideForCreators[_creator];
        koCommissionOverride.active = _active;
        koCommissionOverride.koCommission = _koCommission;

        emit AdminSetKoCommissionOverrideForCreator(_creator, _koCommission);
    }

    function setKoCommissionOverrideForEdition(uint256 _editionId, bool _active, uint256 _koCommission) public onlyAdmin {

        KOCommissionOverride storage koCommissionOverride = koCommissionOverrideForEditions[_editionId];
        koCommissionOverride.active = _active;
        koCommissionOverride.koCommission = _koCommission;

        emit AdminSetKoCommissionOverrideForEdition(_editionId, _koCommission);
    }


    function _isListingPermitted(uint256 _editionId) internal view override returns (bool) {

        return !_isEditionListed(_editionId);
    }

    function _isReserveListingPermitted(uint256 _editionId) internal view override returns (bool) {

        return koda.getSizeOfEdition(_editionId) == 1 && accessControls.hasContractRole(_msgSender());
    }

    function _hasReserveListingBeenInvalidated(uint256 _id) internal view override returns (bool) {

        bool isApprovalActiveForMarketplace = koda.isApprovedForAll(
            editionOrTokenWithReserveAuctions[_id].seller,
            address(this)
        );

        return !isApprovalActiveForMarketplace || koda.isSalesDisabledOrSoldOut(_id);
    }

    function _isBuyNowListingPermitted(uint256) internal view override returns (bool) {

        return accessControls.hasContractRole(_msgSender());
    }

    function _processSale(uint256 _id, uint256 _paymentAmount, address _buyer, address) internal override returns (uint256) {

        return _facilitateNextPrimarySale(_id, _paymentAmount, _buyer, false);
    }

    function _facilitateNextPrimarySale(uint256 _editionId, uint256 _paymentAmount, address _buyer, bool _reverse) internal returns (uint256) {

        (address receiver, address creator, uint256 tokenId) = _reverse
        ? koda.facilitateReversePrimarySale(_editionId)
        : koda.facilitateNextPrimarySale(_editionId);

        _handleEditionSaleFunds(_editionId, creator, receiver, _paymentAmount);

        koda.safeTransferFrom(creator, _buyer, tokenId);


        return tokenId;
    }

    function _handleEditionSaleFunds(uint256 _editionId, address _creator, address _receiver, uint256 _paymentAmount) internal {

        uint256 primarySaleCommission;

        if (koCommissionOverrideForEditions[_editionId].active) {
            primarySaleCommission = koCommissionOverrideForEditions[_editionId].koCommission;
        }
        else if (koCommissionOverrideForCreators[_creator].active) {
            primarySaleCommission = koCommissionOverrideForCreators[_creator].koCommission;
        }
        else {
            primarySaleCommission = platformPrimarySaleCommission;
        }

        uint256 koCommission = (_paymentAmount / modulo) * primarySaleCommission;
        if (koCommission > 0) {
            (bool koCommissionSuccess,) = platformAccount.call{value : koCommission}("");
            require(koCommissionSuccess, "Edition commission payment failed");
        }

        (bool success,) = _receiver.call{value : _paymentAmount - koCommission}("");
        require(success, "Edition payment failed");
    }

    function _isEditionListed(uint256 _editionId) internal view returns (bool) {

        if (editionOrTokenListings[_editionId].seller != address(0)) {
            return true;
        }

        if (editionStep[_editionId].seller != address(0)) {
            return true;
        }

        if (editionOrTokenWithReserveAuctions[_editionId].seller != address(0)) {
            return true;
        }

        return false;
    }

    function _placeEditionBid(uint256 _editionId, address _bidder) internal {

        require(!_isEditionListed(_editionId), "Edition is listed");

        Offer storage offer = editionOffers[_editionId];
        require(msg.value >= offer.offer + minBidAmount, "Bid not high enough");

        uint256 startDate = editionOffersStartDate[_editionId];
        if (startDate > 0) {
            require(block.timestamp >= startDate, "Not yet accepting offers");

            delete editionOffersStartDate[_editionId];
        }

        if (offer.offer > 0) {
            _refundBidder(_editionId, offer.bidder, offer.offer, _msgSender(), msg.value);
        }

        editionOffers[_editionId] = Offer(msg.value, _bidder, _getLockupTime());

        emit EditionBidPlaced(_editionId, _bidder, msg.value);
    }
}