
pragma solidity ^0.8.12;


abstract contract ReentrancyGuard {
    uint8 private constant _NOT_ENTERED = 1;
    uint8 private constant _ENTERED = 2;
    uint8 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "Reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

abstract contract Adminable {
    address private _admin1;
    address private _admin2;

    constructor() {
        _set(1, msg.sender);
    }

    function admin(uint8 idx) public view returns (address) {
        if (idx == 1) {
            return _admin1;
        } else if (idx == 2) {
            return _admin2;
        }
        return address(0);
    }

    modifier onlyAdmin() {
        require(
            _admin1 == msg.sender || _admin2 == msg.sender,
            "Caller not admin"
        );
        _;
    }

    function addAdmin(uint8 idx, address addr) public onlyAdmin {
        require(addr != address(0), "Invalid address");
        require(addr != _admin1 && addr != _admin2, "Already admin");
        require(idx == 1 || idx == 2, "Invalid index");
        _set(idx, addr);
    }

    function isAdmin(address addr) public view returns (bool) {
        return addr == _admin1 || addr == _admin2;
    }

    function _set(uint8 idx, address addr) private {
        if (idx == 1) {
            _admin1 = addr;
        } else {
            _admin2 = addr;
        }
    }
}


interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC2981 {

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount);

}

interface IERC721 {

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


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
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

}

contract NFTAuction is ReentrancyGuard, Adminable, IERC721Receiver {


    struct Auction {
        address nft;
        address bidder;
        address seller;
        uint256 tokenId;
        uint256 amount;
        uint64 startAt;
        uint64 endAt;
        uint64 minOutbid;
        uint16 extensionDuration;
        uint16 extensionTrigger;
        uint16 hostFee;
    }

    event AuctionCreated(
        address indexed seller,
        address indexed nft,
        uint256 indexed tokenId,
        uint256 startPrice,
        uint256 auctionId,
        uint64 startAt,
        uint64 endAt
    );

    event AuctionUpdated(uint256 indexed auctionId, uint256 startPrice);

    event AuctionCancelled(uint256 indexed auctionId);

    event AuctionCanceledByAdmin(uint256 indexed auctionId, string reason);

    event AuctionFinalized(
        uint256 indexed auctionId,
        address seller,
        address bidder,
        uint64 endAt,
        uint256 amount
    );

    event BidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount,
        uint64 endTime
    );

    event WithdrawFailed(address indexed user, uint256 amount);
    event WithdrawSuccess(address indexed user, uint256 amount);

    mapping(address => mapping(uint256 => uint256))  private _nftToTokenIdToAuctionId;
    mapping(uint256 => Auction) private _auctionIdToAuction;
    mapping(address => uint256) private _pendingWithdraws;
    uint256 private _auctionId;
    uint256 private _minStartPrice;
    uint32 private _minAuctionDuration;
    uint32 private _minDurationExt;
    uint32 private _maxDurationExt;
    uint32 private _readGasLimit;
    uint32 private _lowGasLimit;
    uint32 private _mediumGasLimit;
    uint16 private _royaltyLimit;
    uint16 private _hostFee;
    address private _hostTreasury;

    constructor() ReentrancyGuard() Adminable() {}


    function setHostTreasury(address addr) public onlyAdmin {

        require(addr != address(0), "Invalid address");
        _hostTreasury = addr;
    }

    function setHostFee(uint16 fee) public onlyAdmin {

        require(fee > 0, "Invalid fee");
        _hostFee = fee;
    }

    function setHostFeeForAuction(uint256 auctionId, uint16 fee)
        public
        onlyAdmin
    {

        require(fee > 0, "Invalid fee");
        _auctionIdToAuction[auctionId].hostFee = fee;
    }

    function updateConfig(
        uint256 minStartPrice,
        uint32 minAuctionDuration,
        uint32 minDurationExt,
        uint32 maxDurationExt,
        uint16 royaltyLimit,
        uint32 lowGasLimit,
        uint32 mediumGasLimit,
        uint32 readGasLimit
    ) public onlyAdmin {

        if (minStartPrice > 0) {
            _minStartPrice = minStartPrice;
        }

        if (minAuctionDuration > 0) {
            _minAuctionDuration = minAuctionDuration;
        }

        if (minDurationExt > 0) {
            _minDurationExt = minDurationExt;
        }

        if (maxDurationExt > 0) {
            _maxDurationExt = maxDurationExt;
        }

        if (royaltyLimit > 0) {
            _royaltyLimit = royaltyLimit;
        }

        if (lowGasLimit > 0) {
            _lowGasLimit = lowGasLimit;
        }

        if (mediumGasLimit > 0) {
            _mediumGasLimit = mediumGasLimit;
        }

        if (readGasLimit > 0) {
            _readGasLimit = readGasLimit;
        }
    }

    function getConfig()
        public
        view
        returns (
            uint256,
            uint32,
            uint32,
            uint32,
            uint16,
            uint32,
            uint32,
            address,
            uint16
        )
    {

        return (
            _minStartPrice,
            _minAuctionDuration,
            _minDurationExt,
            _maxDurationExt,
            _royaltyLimit,
            _lowGasLimit,
            _mediumGasLimit,
            _hostTreasury,
            _hostFee
        );
    }

    function getAuctionId(address nft, uint256 tokenId)
        public
        view
        returns (uint256)
    {

        return _nftToTokenIdToAuctionId[nft][tokenId];
    }

    function getAuctionDetails(uint256 auctionId)
        public
        view
        returns (
            address,
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            uint256,
            uint16
        )
    {

        Auction memory auction = _auctionIdToAuction[auctionId];
        require(auction.nft != address(0), "Auction not found");
        return (
            auction.seller,
            auction.startAt,
            auction.endAt,
            auction.extensionDuration,
            auction.bidder,
            auction.amount,
            auction.minOutbid,
            auction.hostFee == 1
                ? 0
                : (auction.hostFee > 1 ? auction.hostFee : _hostFee)
        );
    }

    function createAuctionFor(
        address nft,
        address seller,
        uint256 tokenId,
        uint256 startPrice,
        uint64 startAt,
        uint64 endAt,
        uint64 minOutbid,
        uint16 extensionDuration,
        uint16 extensionTrigger,
        uint16 hostFee
    ) public nonReentrant onlyAdmin {

        _createAuction(
            nft,
            seller,
            tokenId,
            startPrice,
            startAt,
            endAt,
            minOutbid,
            extensionDuration,
            extensionTrigger,
            hostFee
        );
    }

    function createAuction(
        address nft,
        uint256 tokenId,
        uint256 startPrice,
        uint64 startAt,
        uint64 endAt,
        uint64 minOutbid,
        uint16 extensionDuration,
        uint16 extensionTrigger
    ) public nonReentrant {

        _createAuction(
            nft,
            msg.sender,
            tokenId,
            startPrice,
            startAt,
            endAt,
            minOutbid,
            extensionDuration,
            extensionTrigger,
            0
        );
    }

    function updateAuction(uint256 auctionId, uint256 startPrice) public {

        Auction storage auction = _auctionIdToAuction[auctionId];
        require(auction.bidder == address(0), "Auction in progress");
        require(
            auction.seller == msg.sender || isAdmin(msg.sender),
            "Unauthorized"
        );

        auction.amount = startPrice;

        emit AuctionUpdated(auctionId, startPrice);
    }

    function cancelAuction(uint256 auctionId) public nonReentrant {

        Auction memory auction = _auctionIdToAuction[auctionId];
        require(auction.bidder == address(0), "Auction in progress");
        require(
            auction.seller == msg.sender || isAdmin(msg.sender),
            "Unauthorized"
        );

        delete _nftToTokenIdToAuctionId[auction.nft][auction.tokenId];
        delete _auctionIdToAuction[auctionId];

        IERC721(auction.nft).transferFrom(
            address(this),
            auction.seller,
            auction.tokenId
        );

        emit AuctionCancelled(auctionId);
    }

    function adminCancelAuction(uint256 auctionId, string memory reason)
        public
        onlyAdmin
    {

        require(bytes(reason).length > 0, "Reason required");
        Auction memory auction = _auctionIdToAuction[auctionId];
        require(auction.amount != 0, "Auction not found");

        delete _nftToTokenIdToAuctionId[auction.nft][auction.tokenId];
        delete _auctionIdToAuction[auctionId];

        IERC721(auction.nft).transferFrom(
            address(this),
            auction.seller,
            auction.tokenId
        );

        if (auction.bidder != address(0)) {
            _trySendAmount(auction.bidder, auction.amount, _mediumGasLimit);
        }

        emit AuctionCanceledByAdmin(auctionId, reason);
    }

    function placeBid(uint256 auctionId) public payable nonReentrant {

        Auction storage auction = _auctionIdToAuction[auctionId];
        require(auction.amount != 0, "Auction not found");
        require(auction.endAt >= block.timestamp, "Auction is over");
        require(auction.startAt <= block.timestamp, "Auction not started");

        if (auction.bidder == address(0)) {
            require(msg.value >= auction.amount, "Bid amount too low");

            auction.amount = msg.value;
            auction.bidder = payable(msg.sender);
        } else {
            require(msg.value > auction.amount, "Bid amount too low");
            uint256 outbid;
            unchecked {
                outbid = msg.value - auction.amount;
            }
            require(outbid >= auction.minOutbid, "Bid amount too low");

            uint256 prevAmount = auction.amount;
            address prevBidder = auction.bidder;
            auction.amount = msg.value;
            auction.bidder = payable(msg.sender);

            unchecked {
                if (
                    auction.endAt - block.timestamp < auction.extensionTrigger
                ) {
                    auction.endAt = auction.endAt + auction.extensionDuration;
                }
            }

            _trySendAmount(prevBidder, prevAmount, _lowGasLimit);
        }

        emit BidPlaced(auctionId, msg.sender, msg.value, auction.endAt);
    }

    function finalizeAuction(uint256 auctionId) public nonReentrant {

        Auction memory auction = _auctionIdToAuction[auctionId];
        require(auction.amount != 0, "Auction not found");
        require(auction.endAt < block.timestamp, "Auction in progress");

        delete _nftToTokenIdToAuctionId[auction.nft][auction.tokenId];
        delete _auctionIdToAuction[auctionId];

        if (auction.bidder == address(0)) {
            IERC721(auction.nft).transferFrom(
                address(this),
                auction.seller,
                auction.tokenId
            );

            return;
        }

        IERC721(auction.nft).transferFrom(
            address(this),
            auction.bidder,
            auction.tokenId
        );

        address creatorAddress;
        uint256 hostCut;
        uint256 creatorCut;
        uint256 sellerCut;

        if (IERC165(auction.nft).supportsInterface(type(IERC2981).interfaceId)) {
            (
                address creatorRoyaltyAddress,
                uint256 creatorRoyaltyAmount
            ) = IERC2981(auction.nft).royaltyInfo{gas: _readGasLimit}(
                    auction.tokenId,
                    auction.amount
                );

            if (creatorRoyaltyAddress != auction.seller) {
                uint256 royatlyLimit = (auction.amount * _royaltyLimit) /
                    10000;

                creatorCut = royatlyLimit >= creatorRoyaltyAmount
                    ? creatorRoyaltyAmount
                    : royatlyLimit;
                creatorAddress = creatorRoyaltyAddress;
            }
        }

        uint16 hostFee = auction.hostFee == 1
            ? 0
            : (auction.hostFee > 1 ? auction.hostFee : _hostFee);
        hostCut = (auction.amount * hostFee) / 10000;
        sellerCut = auction.amount - hostCut - creatorCut;

        _trySendAmount(_hostTreasury, hostCut, _lowGasLimit);
        _trySendAmount(auction.seller, sellerCut, _mediumGasLimit);
        _trySendAmount(creatorAddress, creatorCut, _mediumGasLimit);

        emit AuctionFinalized(
            auctionId,
            auction.seller,
            auction.bidder,
            auction.endAt,
            auction.amount
        );
    }

    function withdrawFor(address user) public nonReentrant {

        uint256 amount = _pendingWithdraws[user];
        require(amount > 0, "Nothing to withdraw");
        require(address(this).balance >= amount, "Insufficient balance");

        _pendingWithdraws[user] = 0;

        (bool success, ) = payable(user).call{value: amount}("");
        require(success, "Withdraw failed");

        emit WithdrawSuccess(user, amount);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public pure returns (bytes4) {

        return this.onERC721Received.selector;
    }

    function _createAuction(
        address nft,
        address seller,
        uint256 tokenId,
        uint256 startPrice,
        uint64 startAt,
        uint64 endAt,
        uint64 minOutbid,
        uint16 extensionDuration,
        uint16 extensionTrigger,
        uint16 hostFee
    ) private {

        require(startPrice > _minStartPrice, "Starting price too low");
        require(
            _nftToTokenIdToAuctionId[nft][tokenId] == 0,
            "NFT already on auction"
        );
        require(
            startAt < endAt && (endAt - startAt) >= _minAuctionDuration,
            "Invalid auction duration"
        );
        require(
            extensionDuration >= _minDurationExt &&
                extensionDuration <= _maxDurationExt,
            "Extension duration out of bounds"
        );

        uint256 auctionId = _getNextAuctionId();
        _nftToTokenIdToAuctionId[nft][tokenId] = auctionId;
        _auctionIdToAuction[auctionId] = Auction(
            nft,
            address(0),
            seller,
            tokenId,
            startPrice,
            startAt,
            endAt,
            minOutbid,
            extensionDuration,
            extensionTrigger,
            hostFee
        );

        IERC721(nft).transferFrom(seller, address(this), tokenId);

        emit AuctionCreated(
            seller,
            nft,
            tokenId,
            startPrice,
            auctionId,
            startAt,
            endAt
        );
    }

    function _getNextAuctionId() private returns (uint256) {

        return ++_auctionId;
    }

    function _trySendAmount(
        address user,
        uint256 amount,
        uint256 gasLimit
    ) private {

        if (amount == 0 || address(0) == user) {
            return;
        }

        (bool success, ) = payable(user).call{value: amount, gas: gasLimit}("");
        if (!success) {
            _pendingWithdraws[user] += amount;
            emit WithdrawFailed(user, amount);
        }
    }
}