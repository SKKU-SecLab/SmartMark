
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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity ^0.8.0;

interface IWithBalance {

    function balanceOf(address owner) external view returns (uint256);

}// MIT
pragma solidity 0.8.13;


contract NFTAuction is Ownable {

    address[] public whitelistedPassCollections; //Only owners of tokens from any of these collections can make bids
    mapping(address => mapping(uint256 => Auction)) public nftContractAuctions;
    mapping(address => uint256) failedTransferCredits;
    struct Auction {
        uint32 bidIncreasePercentage;
        uint32 auctionBidPeriod; //Increments the length of time the auction is open in which a new bid can be made after each bid.
        uint64 auctionEnd;
        uint128 minPrice;
        uint128 buyNowPrice;
        uint128 nftHighestBid;
        address nftHighestBidder;
        address nftSeller;
        address whitelistedBuyer; //The seller can specify a whitelisted address for a sale (this is effectively a direct sale).
        address nftRecipient; //The bidder can specify a recipient for the NFT if their bid is successful.
        address ERC20Token; // The seller can specify an ERC20 token that can be used to bid or purchase the NFT.
        address[] feeRecipients;
        uint32[] feePercentages;
    }
    uint32 public defaultBidIncreasePercentage;
    uint32 public minimumSettableIncreasePercentage;
    uint32 public maximumMinPricePercentage;
    uint32 public defaultAuctionBidPeriod;


    event NftAuctionCreated(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        address erc20Token,
        uint128 minPrice,
        uint128 buyNowPrice,
        uint32 auctionBidPeriod,
        uint32 bidIncreasePercentage,
        address[] feeRecipients,
        uint32[] feePercentages
    );

    event SaleCreated(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        address erc20Token,
        uint128 buyNowPrice,
        address whitelistedBuyer,
        address[] feeRecipients,
        uint32[] feePercentages
    );

    event BidMade(
        address nftContractAddress,
        uint256 tokenId,
        address bidder,
        uint256 ethAmount,
        address erc20Token,
        uint256 tokenAmount
    );

    event AuctionPeriodUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint64 auctionEndPeriod
    );

    event NFTTransferredAndSellerPaid(
        address nftContractAddress,
        uint256 tokenId,
        address nftSeller,
        uint128 nftHighestBid,
        address nftHighestBidder,
        address nftRecipient
    );

    event AuctionSettled(
        address nftContractAddress,
        uint256 tokenId,
        address auctionSettler
    );

    event AuctionWithdrawn(
        address nftContractAddress,
        uint256 tokenId,
        address nftOwner
    );

    event BidWithdrawn(
        address nftContractAddress,
        uint256 tokenId,
        address highestBidder
    );

    event WhitelistedBuyerUpdated(
        address nftContractAddress,
        uint256 tokenId,
        address newWhitelistedBuyer
    );

    event MinimumPriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint256 newMinPrice
    );

    event BuyNowPriceUpdated(
        address nftContractAddress,
        uint256 tokenId,
        uint128 newBuyNowPrice
    );
    event HighestBidTaken(address nftContractAddress, uint256 tokenId);

    modifier hasWhitelistedToken() {

        { //Block scoping to prevent "Stack too deep"
            bool isWhitelisted;
            for (uint256 i = 0; i < whitelistedPassCollections.length; i++) {
                if(IWithBalance(whitelistedPassCollections[i]).balanceOf(msg.sender) > 0) {
                    isWhitelisted = true;
                    break;
                }
            }
            require(isWhitelisted, "Sender has no whitelisted NFTs");
        }
        _;
    }

    modifier isAuctionNotStartedByOwner(
        address _nftContractAddress,
        uint256 _tokenId
    ) {

        require(
            nftContractAuctions[_nftContractAddress][_tokenId].nftSeller !=
                msg.sender,
            "Auction already started by owner"
        );

        if (
            nftContractAuctions[_nftContractAddress][_tokenId].nftSeller !=
            address(0)
        ) {
            require(
                msg.sender == IERC721(_nftContractAddress).ownerOf(_tokenId),
                "Sender doesn't own NFT"
            );

            _resetAuction(_nftContractAddress, _tokenId);
        }
        _;
    }

    modifier auctionOngoing(address _nftContractAddress, uint256 _tokenId) {

        require(
            _isAuctionOngoing(_nftContractAddress, _tokenId),
            "Auction has ended"
        );
        _;
    }

    modifier priceGreaterThanZero(uint256 _price) {

        require(_price > 0, "Price cannot be 0");
        _;
    }
    modifier minPriceDoesNotExceedLimit(
        uint128 _buyNowPrice,
        uint128 _minPrice
    ) {

        require(
            _buyNowPrice == 0 ||
                _getPortionOfBid(_buyNowPrice, maximumMinPricePercentage) >=
                _minPrice,
            "MinPrice > 80% of buyNowPrice"
        );
        _;
    }

    modifier notNftSeller(address _nftContractAddress, uint256 _tokenId) {

        require(
            msg.sender !=
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Owner cannot bid on own NFT"
        );
        _;
    }
    modifier onlyNftSeller(address _nftContractAddress, uint256 _tokenId) {

        require(
            msg.sender ==
                nftContractAuctions[_nftContractAddress][_tokenId].nftSeller,
            "Only nft seller"
        );
        _;
    }
    modifier bidAmountMeetsBidRequirements(
        address _nftContractAddress,
        uint256 _tokenId,
        uint128 _tokenAmount
    ) {

        require(
            _doesBidMeetBidRequirements(
                _nftContractAddress,
                _tokenId,
                _tokenAmount
            ),
            "Not enough funds to bid on NFT"
        );
        _;
    }
    modifier onlyApplicableBuyer(
        address _nftContractAddress,
        uint256 _tokenId
    ) {

        require(
            !_isWhitelistedSale(_nftContractAddress, _tokenId) ||
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .whitelistedBuyer ==
                msg.sender,
            "Only the whitelisted buyer"
        );
        _;
    }

    modifier minimumBidNotMade(address _nftContractAddress, uint256 _tokenId) {

        require(
            !_isMinimumBidMade(_nftContractAddress, _tokenId),
            "The auction has a valid bid made"
        );
        _;
    }

    modifier paymentAccepted(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint128 _tokenAmount
    ) {

        require(
            _isPaymentAccepted(
                _nftContractAddress,
                _tokenId,
                _erc20Token,
                _tokenAmount
            ),
            "Bid to be in specified ERC20/Eth"
        );
        _;
    }

    modifier isAuctionOver(address _nftContractAddress, uint256 _tokenId) {

        require(
            !_isAuctionOngoing(_nftContractAddress, _tokenId),
            "Auction is not yet over"
        );
        _;
    }

    modifier notZeroAddress(address _address) {

        require(_address != address(0), "Cannot specify 0 address");
        _;
    }

    modifier increasePercentageAboveMinimum(uint32 _bidIncreasePercentage) {

        require(
            _bidIncreasePercentage >= minimumSettableIncreasePercentage,
            "Bid increase percentage too low"
        );
        _;
    }

    modifier isFeePercentagesLessThanMaximum(uint32[] memory _feePercentages) {

        uint32 totalPercent;
        for (uint256 i = 0; i < _feePercentages.length; i++) {
            totalPercent = totalPercent + _feePercentages[i];
        }
        require(totalPercent <= 10000, "Fee percentages exceed maximum");
        _;
    }

    modifier correctFeeRecipientsAndPercentages(
        uint256 _recipientsLength,
        uint256 _percentagesLength
    ) {

        require(
            _recipientsLength == _percentagesLength,
            "Recipients != percentages"
        );
        _;
    }

    modifier isNotASale(address _nftContractAddress, uint256 _tokenId) {

        require(
            !_isASale(_nftContractAddress, _tokenId),
            "Not applicable for a sale"
        );
        _;
    }

    constructor(address[] memory _whitelistedPassCollectionsAddresses) {
        defaultBidIncreasePercentage = 100;
        defaultAuctionBidPeriod = 86400; //1 day
        minimumSettableIncreasePercentage = 100;
        maximumMinPricePercentage = 8000;

        uint256 collectionsCount = _whitelistedPassCollectionsAddresses.length;
        for (uint256 i = 0; i < collectionsCount; i++) {
            whitelistedPassCollections.push(_whitelistedPassCollectionsAddresses[i]);
        }
    }
    function addWhitelistedCollection(address _collectionContractAddress)
    external
    onlyOwner
    {

        whitelistedPassCollections.push(_collectionContractAddress);
    }
    function removeWhitelistedCollection(uint256 index)
    external
    onlyOwner
    {

        whitelistedPassCollections[index] = whitelistedPassCollections[whitelistedPassCollections.length - 1];
        whitelistedPassCollections.pop();
    }
    function _isAuctionOngoing(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        uint64 auctionEndTimestamp = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].auctionEnd;
        return (auctionEndTimestamp == 0 ||
            block.timestamp < auctionEndTimestamp);
    }

    function _isABidMade(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        return (nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBid > 0);
    }

    function _isMinimumBidMade(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        uint128 minPrice = nftContractAuctions[_nftContractAddress][_tokenId]
            .minPrice;
        return
            minPrice > 0 &&
            (nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid >=
                minPrice);
    }

    function _isBuyNowPriceMet(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        uint128 buyNowPrice = nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice;
        return
            buyNowPrice > 0 &&
            nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid >=
            buyNowPrice;
    }

    function _doesBidMeetBidRequirements(
        address _nftContractAddress,
        uint256 _tokenId,
        uint128 _tokenAmount
    ) internal view returns (bool) {

        uint128 buyNowPrice = nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice;
        if (
            buyNowPrice > 0 &&
            (msg.value >= buyNowPrice || _tokenAmount >= buyNowPrice)
        ) {
            return true;
        }
        uint256 bidIncreaseAmount = (nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid *
            (10000 +
                _getBidIncreasePercentage(_nftContractAddress, _tokenId))) /
            10000;
        return (msg.value >= bidIncreaseAmount ||
            _tokenAmount >= bidIncreaseAmount);
    }

    function _isASale(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        return (nftContractAuctions[_nftContractAddress][_tokenId].buyNowPrice >
            0 &&
            nftContractAuctions[_nftContractAddress][_tokenId].minPrice == 0);
    }

    function _isWhitelistedSale(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (bool)
    {

        return (nftContractAuctions[_nftContractAddress][_tokenId]
            .whitelistedBuyer != address(0));
    }

    function _isHighestBidderAllowedToPurchaseNFT(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal view returns (bool) {

        return
            (!_isWhitelistedSale(_nftContractAddress, _tokenId)) ||
            _isHighestBidderWhitelisted(_nftContractAddress, _tokenId);
    }

    function _isHighestBidderWhitelisted(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal view returns (bool) {

        return (nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder ==
            nftContractAuctions[_nftContractAddress][_tokenId]
                .whitelistedBuyer);
    }

    function _isPaymentAccepted(
        address _nftContractAddress,
        uint256 _tokenId,
        address _bidERC20Token,
        uint128 _tokenAmount
    ) internal view returns (bool) {

        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
        if (_isERC20Auction(auctionERC20Token)) {
            return
                msg.value == 0 &&
                auctionERC20Token == _bidERC20Token &&
                _tokenAmount > 0;
        } else {
            return
                msg.value != 0 &&
                _bidERC20Token == address(0) &&
                _tokenAmount == 0;
        }
    }

    function _isERC20Auction(address _auctionERC20Token)
        internal
        pure
        returns (bool)
    {

        return _auctionERC20Token != address(0);
    }

    function _getPortionOfBid(uint256 _totalBid, uint256 _percentage)
        internal
        pure
        returns (uint256)
    {

        return (_totalBid * (_percentage)) / 10000;
    }


    function _getBidIncreasePercentage(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal view returns (uint32) {

        uint32 bidIncreasePercentage = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].bidIncreasePercentage;

        if (bidIncreasePercentage == 0) {
            return defaultBidIncreasePercentage;
        } else {
            return bidIncreasePercentage;
        }
    }

    function _getAuctionBidPeriod(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (uint32)
    {

        uint32 auctionBidPeriod = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].auctionBidPeriod;

        if (auctionBidPeriod == 0) {
            return defaultAuctionBidPeriod;
        } else {
            return auctionBidPeriod;
        }
    }

    function _getNftRecipient(address _nftContractAddress, uint256 _tokenId)
        internal
        view
        returns (address)
    {

        address nftRecipient = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftRecipient;

        if (nftRecipient == address(0)) {
            return
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .nftHighestBidder;
        } else {
            return nftRecipient;
        }
    }


    function _transferNftToAuctionContract(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {

        address _nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        if (IERC721(_nftContractAddress).ownerOf(_tokenId) == _nftSeller) {
            IERC721(_nftContractAddress).transferFrom(
                _nftSeller,
                address(this),
                _tokenId
            );
            require(
                IERC721(_nftContractAddress).ownerOf(_tokenId) == address(this),
                "nft transfer failed"
            );
        } else {
            require(
                IERC721(_nftContractAddress).ownerOf(_tokenId) == address(this),
                "Seller doesn't own NFT"
            );
        }
    }



    function _setupAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint128 _minPrice,
        uint128 _buyNowPrice,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    )
        internal
        minPriceDoesNotExceedLimit(_buyNowPrice, _minPrice)
        correctFeeRecipientsAndPercentages(
            _feeRecipients.length,
            _feePercentages.length
        )
        isFeePercentagesLessThanMaximum(_feePercentages)
    {

        if (_erc20Token != address(0)) {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .ERC20Token = _erc20Token;
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feeRecipients = _feeRecipients;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feePercentages = _feePercentages;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _buyNowPrice;
        nftContractAuctions[_nftContractAddress][_tokenId].minPrice = _minPrice;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = msg
            .sender;
    }

    function _createNewNftAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint128 _minPrice,
        uint128 _buyNowPrice,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    ) internal {

        _setupAuction(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _minPrice,
            _buyNowPrice,
            _feeRecipients,
            _feePercentages
        );
        emit NftAuctionCreated(
            _nftContractAddress,
            _tokenId,
            msg.sender,
            _erc20Token,
            _minPrice,
            _buyNowPrice,
            _getAuctionBidPeriod(_nftContractAddress, _tokenId),
            _getBidIncreasePercentage(_nftContractAddress, _tokenId),
            _feeRecipients,
            _feePercentages
        );
        _updateOngoingAuction(_nftContractAddress, _tokenId);
    }

    function createDefaultNftAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint128 _minPrice,
        uint128 _buyNowPrice,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    )
        external
        isAuctionNotStartedByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_minPrice)
    {

        _createNewNftAuction(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _minPrice,
            _buyNowPrice,
            _feeRecipients,
            _feePercentages
        );
    }

    function createNewNftAuction(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint128 _minPrice,
        uint128 _buyNowPrice,
        uint32 _auctionBidPeriod, //this is the time that the auction lasts until another bid occurs
        uint32 _bidIncreasePercentage,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    )
        external
        isAuctionNotStartedByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_minPrice)
        increasePercentageAboveMinimum(_bidIncreasePercentage)
    {

        nftContractAuctions[_nftContractAddress][_tokenId]
            .auctionBidPeriod = _auctionBidPeriod;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .bidIncreasePercentage = _bidIncreasePercentage;
        _createNewNftAuction(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _minPrice,
            _buyNowPrice,
            _feeRecipients,
            _feePercentages
        );
    }



    function _setupSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint128 _buyNowPrice,
        address _whitelistedBuyer,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    )
        internal
        correctFeeRecipientsAndPercentages(
            _feeRecipients.length,
            _feePercentages.length
        )
        isFeePercentagesLessThanMaximum(_feePercentages)
    {

        if (_erc20Token != address(0)) {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .ERC20Token = _erc20Token;
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feeRecipients = _feeRecipients;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .feePercentages = _feePercentages;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _buyNowPrice;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .whitelistedBuyer = _whitelistedBuyer;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = msg
            .sender;
    }

    function createSale(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint128 _buyNowPrice,
        address _whitelistedBuyer,
        address[] memory _feeRecipients,
        uint32[] memory _feePercentages
    )
        external
        isAuctionNotStartedByOwner(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_buyNowPrice)
    {

        _setupSale(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _buyNowPrice,
            _whitelistedBuyer,
            _feeRecipients,
            _feePercentages
        );

        emit SaleCreated(
            _nftContractAddress,
            _tokenId,
            msg.sender,
            _erc20Token,
            _buyNowPrice,
            _whitelistedBuyer,
            _feeRecipients,
            _feePercentages
        );
        if (_isABidMade(_nftContractAddress, _tokenId)) {
            if (
                _isHighestBidderAllowedToPurchaseNFT(
                    _nftContractAddress,
                    _tokenId
                )
            ) {
                if (_isBuyNowPriceMet(_nftContractAddress, _tokenId)) {
                    _transferNftToAuctionContract(
                        _nftContractAddress,
                        _tokenId
                    );
                    _transferNftAndPaySeller(_nftContractAddress, _tokenId);
                }
            } else {
                _reverseAndResetPreviousBid(_nftContractAddress, _tokenId);
            }
        }
    }




    function _makeBid(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint128 _tokenAmount
    )
        internal
        hasWhitelistedToken
        notNftSeller(_nftContractAddress, _tokenId)
        paymentAccepted(
            _nftContractAddress,
            _tokenId,
            _erc20Token,
            _tokenAmount
        )
        bidAmountMeetsBidRequirements(
            _nftContractAddress,
            _tokenId,
            _tokenAmount
        )
    {

        _reversePreviousBidAndUpdateHighestBid(
            _nftContractAddress,
            _tokenId,
            _tokenAmount
        );
        emit BidMade(
            _nftContractAddress,
            _tokenId,
            msg.sender,
            msg.value,
            _erc20Token,
            _tokenAmount
        );
        _updateOngoingAuction(_nftContractAddress, _tokenId);
    }

    function makeBid(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint128 _tokenAmount
    )
        external
        payable
        auctionOngoing(_nftContractAddress, _tokenId)
        onlyApplicableBuyer(_nftContractAddress, _tokenId)
    {

        _makeBid(_nftContractAddress, _tokenId, _erc20Token, _tokenAmount);
    }

    function makeCustomBid(
        address _nftContractAddress,
        uint256 _tokenId,
        address _erc20Token,
        uint128 _tokenAmount,
        address _nftRecipient
    )
        external
        payable
        auctionOngoing(_nftContractAddress, _tokenId)
        notZeroAddress(_nftRecipient)
        onlyApplicableBuyer(_nftContractAddress, _tokenId)
    {

        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftRecipient = _nftRecipient;
        _makeBid(_nftContractAddress, _tokenId, _erc20Token, _tokenAmount);
    }



    function _updateOngoingAuction(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {

        if (_isBuyNowPriceMet(_nftContractAddress, _tokenId)) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId);
            _transferNftAndPaySeller(_nftContractAddress, _tokenId);
            return;
        }
        if (_isMinimumBidMade(_nftContractAddress, _tokenId)) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId);
            _updateAuctionEnd(_nftContractAddress, _tokenId);
        }
    }

    function _updateAuctionEnd(address _nftContractAddress, uint256 _tokenId)
        internal
    {

        nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd =
            _getAuctionBidPeriod(_nftContractAddress, _tokenId) +
            uint64(block.timestamp);
        emit AuctionPeriodUpdated(
            _nftContractAddress,
            _tokenId,
            nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd
        );
    }



    function _resetAuction(address _nftContractAddress, uint256 _tokenId)
        internal
    {

        nftContractAuctions[_nftContractAddress][_tokenId].minPrice = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].buyNowPrice = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionEnd = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].auctionBidPeriod = 0;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .bidIncreasePercentage = 0;
        nftContractAuctions[_nftContractAddress][_tokenId].nftSeller = address(
            0
        );
        nftContractAuctions[_nftContractAddress][_tokenId]
            .whitelistedBuyer = address(0);
        nftContractAuctions[_nftContractAddress][_tokenId].ERC20Token = address(
            0
        );
    }

    function _resetBids(address _nftContractAddress, uint256 _tokenId)
        internal
    {

        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder = address(0);
        nftContractAuctions[_nftContractAddress][_tokenId].nftHighestBid = 0;
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftRecipient = address(0);
    }


    function _updateHighestBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint128 _tokenAmount
    ) internal {

        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
        if (_isERC20Auction(auctionERC20Token)) {
            IERC20(auctionERC20Token).transferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            );
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBid = _tokenAmount;
        } else {
            nftContractAuctions[_nftContractAddress][_tokenId]
                .nftHighestBid = uint128(msg.value);
        }
        nftContractAuctions[_nftContractAddress][_tokenId]
            .nftHighestBidder = msg.sender;
    }

    function _reverseAndResetPreviousBid(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {

        address nftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;

        uint128 nftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        _resetBids(_nftContractAddress, _tokenId);

        _payout(_nftContractAddress, _tokenId, nftHighestBidder, nftHighestBid);
    }

    function _reversePreviousBidAndUpdateHighestBid(
        address _nftContractAddress,
        uint256 _tokenId,
        uint128 _tokenAmount
    ) internal {

        address prevNftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;

        uint256 prevNftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        _updateHighestBid(_nftContractAddress, _tokenId, _tokenAmount);

        if (prevNftHighestBidder != address(0)) {
            _payout(
                _nftContractAddress,
                _tokenId,
                prevNftHighestBidder,
                prevNftHighestBid
            );
        }
    }


    function _transferNftAndPaySeller(
        address _nftContractAddress,
        uint256 _tokenId
    ) internal {

        address _nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        address _nftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;
        address _nftRecipient = _getNftRecipient(_nftContractAddress, _tokenId);
        uint128 _nftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        _resetBids(_nftContractAddress, _tokenId);

        _payFeesAndSeller(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            _nftHighestBid
        );
        IERC721(_nftContractAddress).transferFrom(
            address(this),
            _nftRecipient,
            _tokenId
        );

        _resetAuction(_nftContractAddress, _tokenId);
        emit NFTTransferredAndSellerPaid(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            _nftHighestBid,
            _nftHighestBidder,
            _nftRecipient
        );
    }

    function _payFeesAndSeller(
        address _nftContractAddress,
        uint256 _tokenId,
        address _nftSeller,
        uint256 _highestBid
    ) internal {

        uint256 feesPaid;
        for (
            uint256 i = 0;
            i <
            nftContractAuctions[_nftContractAddress][_tokenId]
                .feeRecipients
                .length;
            i++
        ) {
            uint256 fee = _getPortionOfBid(
                _highestBid,
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .feePercentages[i]
            );
            feesPaid = feesPaid + fee;
            _payout(
                _nftContractAddress,
                _tokenId,
                nftContractAuctions[_nftContractAddress][_tokenId]
                    .feeRecipients[i],
                fee
            );
        }
        _payout(
            _nftContractAddress,
            _tokenId,
            _nftSeller,
            (_highestBid - feesPaid)
        );
    }

    function _payout(
        address _nftContractAddress,
        uint256 _tokenId,
        address _recipient,
        uint256 _amount
    ) internal {

        address auctionERC20Token = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].ERC20Token;
        if (_isERC20Auction(auctionERC20Token)) {
            IERC20(auctionERC20Token).transfer(_recipient, _amount);
        } else {
            (bool success, ) = payable(_recipient).call{
                value: _amount,
                gas: 20000
            }("");
            if (!success) {
                failedTransferCredits[_recipient] =
                    failedTransferCredits[_recipient] +
                    _amount;
            }
        }
    }


    function settleAuction(address _nftContractAddress, uint256 _tokenId)
        external
        isAuctionOver(_nftContractAddress, _tokenId)
    {

        _transferNftAndPaySeller(_nftContractAddress, _tokenId);
        emit AuctionSettled(_nftContractAddress, _tokenId, msg.sender);
    }

    function withdrawAuction(address _nftContractAddress, uint256 _tokenId)
        external
    {

        require(
            IERC721(_nftContractAddress).ownerOf(_tokenId) == msg.sender,
            "Not NFT owner"
        );
        _resetAuction(_nftContractAddress, _tokenId);
        emit AuctionWithdrawn(_nftContractAddress, _tokenId, msg.sender);
    }

    function withdrawBid(address _nftContractAddress, uint256 _tokenId)
        external
        minimumBidNotMade(_nftContractAddress, _tokenId)
    {

        address nftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;
        require(msg.sender == nftHighestBidder, "Cannot withdraw funds");

        uint128 nftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        _resetBids(_nftContractAddress, _tokenId);

        _payout(_nftContractAddress, _tokenId, nftHighestBidder, nftHighestBid);

        emit BidWithdrawn(_nftContractAddress, _tokenId, msg.sender);
    }


    function updateWhitelistedBuyer(
        address _nftContractAddress,
        uint256 _tokenId,
        address _newWhitelistedBuyer
    ) external onlyNftSeller(_nftContractAddress, _tokenId) {

        require(_isASale(_nftContractAddress, _tokenId), "Not a sale");
        nftContractAuctions[_nftContractAddress][_tokenId]
            .whitelistedBuyer = _newWhitelistedBuyer;
        address nftHighestBidder = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBidder;
        uint128 nftHighestBid = nftContractAuctions[_nftContractAddress][
            _tokenId
        ].nftHighestBid;
        if (nftHighestBid > 0 && !(nftHighestBidder == _newWhitelistedBuyer)) {

            _resetBids(_nftContractAddress, _tokenId);

            _payout(
                _nftContractAddress,
                _tokenId,
                nftHighestBidder,
                nftHighestBid
            );
        }

        emit WhitelistedBuyerUpdated(
            _nftContractAddress,
            _tokenId,
            _newWhitelistedBuyer
        );
    }

    function updateMinimumPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint128 _newMinPrice
    )
        external
        onlyNftSeller(_nftContractAddress, _tokenId)
        minimumBidNotMade(_nftContractAddress, _tokenId)
        isNotASale(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_newMinPrice)
        minPriceDoesNotExceedLimit(
            nftContractAuctions[_nftContractAddress][_tokenId].buyNowPrice,
            _newMinPrice
        )
    {

        nftContractAuctions[_nftContractAddress][_tokenId]
            .minPrice = _newMinPrice;

        emit MinimumPriceUpdated(_nftContractAddress, _tokenId, _newMinPrice);

        if (_isMinimumBidMade(_nftContractAddress, _tokenId)) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId);
            _updateAuctionEnd(_nftContractAddress, _tokenId);
        }
    }

    function updateBuyNowPrice(
        address _nftContractAddress,
        uint256 _tokenId,
        uint128 _newBuyNowPrice
    )
        external
        onlyNftSeller(_nftContractAddress, _tokenId)
        priceGreaterThanZero(_newBuyNowPrice)
        minPriceDoesNotExceedLimit(
            _newBuyNowPrice,
            nftContractAuctions[_nftContractAddress][_tokenId].minPrice
        )
    {

        nftContractAuctions[_nftContractAddress][_tokenId]
            .buyNowPrice = _newBuyNowPrice;
        emit BuyNowPriceUpdated(_nftContractAddress, _tokenId, _newBuyNowPrice);
        if (_isBuyNowPriceMet(_nftContractAddress, _tokenId)) {
            _transferNftToAuctionContract(_nftContractAddress, _tokenId);
            _transferNftAndPaySeller(_nftContractAddress, _tokenId);
        }
    }

    function takeHighestBid(address _nftContractAddress, uint256 _tokenId)
        external
        onlyNftSeller(_nftContractAddress, _tokenId)
    {

        require(
            _isABidMade(_nftContractAddress, _tokenId),
            "cannot payout 0 bid"
        );
        _transferNftToAuctionContract(_nftContractAddress, _tokenId);
        _transferNftAndPaySeller(_nftContractAddress, _tokenId);
        emit HighestBidTaken(_nftContractAddress, _tokenId);
    }

    function ownerOfNFT(address _nftContractAddress, uint256 _tokenId)
        external
        view
        returns (address)
    {

        address nftSeller = nftContractAuctions[_nftContractAddress][_tokenId]
            .nftSeller;
        require(nftSeller != address(0), "NFT not deposited");

        return nftSeller;
    }

    function withdrawAllFailedCredits() external {

        uint256 amount = failedTransferCredits[msg.sender];

        require(amount != 0, "no credits to withdraw");

        failedTransferCredits[msg.sender] = 0;

        (bool successfulWithdraw, ) = msg.sender.call{
            value: amount,
            gas: 20000
        }("");
        require(successfulWithdraw, "withdraw failed");
    }

}