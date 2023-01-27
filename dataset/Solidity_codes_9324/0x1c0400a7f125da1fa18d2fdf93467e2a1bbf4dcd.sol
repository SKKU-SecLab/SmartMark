
pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
pragma solidity >=0.8.11 <0.9.0;


contract Marketplace is OwnableUpgradeable, ReentrancyGuardUpgradeable {


    enum Types {
        regular,
        auction,
        offer
    }

    struct Bid {
        address payable buyer;
        uint256 amount;
        bool isWinner;
        bool isChargedBack;
    }

    struct Lot {
        address nft;
        address payable seller;
        uint256 tokenId;
        Types offerType;
        uint256 price;
        uint256 stopPrice;
        uint256 auctionStart;
        uint256 auctionEnd;
        bool isSold;
        bool isCanceled;
    }

    struct Royalty {
        uint256 percent;
        address receiver;
    }

    uint256 private constant FEES_MULTIPLIER = 10000;

    uint256 public serviceFee;

    uint256 public maxRoyaltyPercent;

    address payable public feesCollector;

    address public ara;

    address public rad;

    mapping(address => bool) public banList;

    mapping(address => uint256[]) private lotsOfSeller;

    mapping(uint256 => Bid[]) public bidsOfLot;

    mapping(address => mapping(uint256 => Royalty)) public royalties;

    Lot[] public lots;


    event ServiceFeeChanged(uint256 newFee);

    event MaxRoyaltyChanged(uint256 newMaxRoyaltyPercent);

    event UserBanStatusChanged(address indexed user, bool isBanned);

    event ARAAddressChanged(address indexed oldAddress, address indexed newAddress);

    event RADAddressChanged(address indexed oldAddress, address indexed newAddress);

    event RegularLotCreated(uint256 indexed lotId, address indexed seller);

    event AuctionLotCreated(uint256 indexed lotId, address indexed seller);

    event OfferLotCreated(uint256 indexed lotId, address indexed seller);

    event TokenRemovedFromSale(uint256 indexed lotId, bool indexed removedBySeller);

    event Sold(uint256 indexed lotId, address indexed buyer, uint256 price, uint256 fee, uint256 royalty);

    event FailedTx(uint256 indexed lotId, uint256 bidId, address indexed recipient, uint256 amount);

    event RoyaltySet(address indexed nft, uint256 indexed tokenId, address receiver, uint256 percent);

    event NewOffer(address indexed buyer, uint256 price, uint256 indexed lotId);

    event OfferAccepted(uint256 indexed lotId);


    modifier notBanned() {

        require(!banList[msg.sender], "you are banned");
        _;
    }

    modifier lotIsActive(uint256 lotId) {

        Lot memory lot = lots[lotId];
        require(!lot.isSold, "lot already sold");
        require(!lot.isCanceled, "lot canceled");
        _;
    }


    function getLots(
        uint256 from,
        uint256 to,
        bool getActive,
        bool getSold,
        bool getCanceled
    ) external view returns (Lot[] memory _filteredLots) {

        require(from < lots.length, "value is bigger than lots count");
        if (to == 0 || to >= lots.length) to = lots.length - 1;
        Lot[] memory _tempLots = new Lot[](lots.length);
        uint256 _count = 0;
        for (uint256 i = from; i <= to; i++) {
            if (
                (getActive && (!lots[i].isSold && !lots[i].isCanceled)) ||
                (getSold && lots[i].isSold) ||
                (getCanceled && lots[i].isCanceled)
            ) {
                _tempLots[_count] = lots[i];
                _count++;
            }
        }
        _filteredLots = new Lot[](_count);
        for (uint256 i = 0; i < _count; i++) {
            _filteredLots[i] = _tempLots[i];
        }
    }

    function getLotsOfSeller(address seller) external view returns (uint256[] memory) {

        return lotsOfSeller[seller];
    }

    function getBidsOfLot(uint256 lotId) external view returns (Bid[] memory) {

        return bidsOfLot[lotId];
    }

    function getLotId(address nft, uint256 tokenId) external view returns (bool _isFound, uint256 _lotId) {

        require(nft != address(0), "zero_addr");
        _isFound = false;
        _lotId = 0;
        for (uint256 i; i < lots.length; i++) {
            Lot memory _lot = lots[i];
            if (_lot.nft == nft && _lot.tokenId == tokenId && !_lot.isCanceled && !_lot.isSold) {
                _isFound = true;
                _lotId = i;
                break;
            }
        }
    }

    function getBidsOf(address bidder, uint256 lotId) external view returns (Bid memory _bid) {

        for (uint256 i = 0; i < bidsOfLot[lotId].length; i++) {
            _bid = bidsOfLot[lotId][i];
            if (_bid.buyer == bidder && !_bid.isChargedBack) {
                return _bid;
            }
        }
        revert("bid not found");
    }


    function setServiceFee(uint256 newServiceFee) external onlyOwner {

        require(serviceFee != newServiceFee, "similar amount");
        serviceFee = newServiceFee;
        emit ServiceFeeChanged(newServiceFee);
    }

    function setBanStatus(address user, bool isBanned) external onlyOwner {

        require(banList[user] != isBanned, "address already have this status");
        banList[user] = isBanned;
        emit UserBanStatusChanged(user, isBanned);
    }

    function setARAAddress(address _ara) external onlyOwner {

        require(_ara != address(0), "zero address");
        require(_ara != ara, "same address");
        address _oldARA = ara;
        ara = _ara;
        emit ARAAddressChanged(_oldARA, ara);
    }

    function setRADAddress(address _rad) external onlyOwner {

        require(_rad != address(0), "zero address");
        require(_rad != rad, "same address");
        address _oldRAD = rad;
        rad = _rad;
        emit RADAddressChanged(_oldRAD, rad);
    }

    function setMaxRoyalty(uint256 newMaxRoyaltyPercent) external onlyOwner {

        require(maxRoyaltyPercent != newMaxRoyaltyPercent, "similar amount");
        maxRoyaltyPercent = newMaxRoyaltyPercent;
        emit MaxRoyaltyChanged(newMaxRoyaltyPercent);
    }

    function setRoyalty(
        address nftToken,
        uint256 tokenId,
        uint256 royaltyPercent
    ) external {

        require(royaltyPercent <= maxRoyaltyPercent, "% is too big");
        Royalty storage _royalty = royalties[nftToken][tokenId];
        require(_royalty.percent == 0, "Royalty % already set");
        require(_royalty.receiver == address(0), "Royalty address already set");
        address _tokenOwner = IERC721Upgradeable(nftToken).ownerOf(tokenId);
        require(msg.sender == _tokenOwner, "not owner");
        _royalty.percent = royaltyPercent;
        _royalty.receiver = msg.sender;
        emit RoyaltySet(nftToken, tokenId, msg.sender, royaltyPercent);
    }


    function makeRegularOffer(
        address nft,
        uint256 tokenId,
        uint256 price
    ) external notBanned returns (uint256 _lotId) {

        require(nft != address(0), "zero address for NFT");
        require(price > 0, "price should be greater than 0");
        IERC721Upgradeable(nft).safeTransferFrom(msg.sender, address(this), tokenId);
        Lot memory newLot = Lot(nft, payable(msg.sender), tokenId, Types.regular, price, 0, 0, 0, false, false);
        lots.push(newLot);
        _lotId = lots.length - 1;
        lotsOfSeller[msg.sender].push(_lotId);
        emit RegularLotCreated(_lotId, msg.sender);
    }

    function makeAuctionOffer(
        address nft,
        uint256 tokenId,
        uint256 price,
        uint256 stopPrice,
        uint256 auctionStart,
        uint256 auctionEnd
    ) external notBanned returns (uint256 _lotId) {

        require(nft != address(0), "zero address");
        require(auctionStart > 0, "auction start time should be greater than 0");
        require(auctionEnd > auctionStart, "auction end time should be greater than auction start time");
        require(price > 0, "price should be greater than 0");
        if (stopPrice > 0) {
            require(stopPrice > price, "stop price should be greater than price");
        }
        IERC721Upgradeable(nft).safeTransferFrom(msg.sender, address(this), tokenId);
        Lot memory newLot = Lot(
            nft,
            payable(msg.sender),
            tokenId,
            Types.auction,
            price,
            stopPrice,
            auctionStart,
            auctionEnd,
            false,
            false
        );
        lots.push(newLot);
        _lotId = lots.length - 1;
        lotsOfSeller[msg.sender].push(_lotId);
        emit AuctionLotCreated(_lotId, msg.sender);
    }

    function addTokenForOffers(address nft, uint256 tokenId) external notBanned returns (uint256 _lotId) {

        require(nft != address(0), "zero address for NFT");
        IERC721Upgradeable(nft).safeTransferFrom(msg.sender, address(this), tokenId);
        Lot memory newLot = Lot(nft, payable(msg.sender), tokenId, Types.offer, 0, 0, 0, 0, false, false);
        lots.push(newLot);
        _lotId = lots.length - 1;
        lotsOfSeller[msg.sender].push(_lotId);
        emit RegularLotCreated(_lotId, msg.sender);
    }

    function removeLot(uint256 lotId) external lotIsActive(lotId) nonReentrant {

        Lot storage lot = lots[lotId];
        require(msg.sender == lot.seller || msg.sender == owner(), "only owner or seller can remove");
        lot.isCanceled = true;
        if (lot.offerType != Types.regular) {
            Bid[] storage bids = bidsOfLot[lotId];
            for (uint256 i = 0; i < bids.length; i++) {
                Bid storage _bid = bids[i];
                if (!_bid.isChargedBack && !_bid.isWinner) {
                    _bid.isChargedBack = true;
                    (bool sent, ) = _bid.buyer.call{value: _bid.amount}("");
                    require(sent, "something went wrong");
                }
            }
        }
        IERC721Upgradeable(lot.nft).safeTransferFrom(address(this), lot.seller, lot.tokenId);
        emit TokenRemovedFromSale(lotId, msg.sender == lot.seller);
    }

    function changeRegularOfferPrice(uint256 lotId, uint256 newPrice) external lotIsActive(lotId) {

        Lot storage _lot = lots[lotId];
        require(msg.sender == _lot.seller, "not seller");
        require(_lot.offerType == Types.regular, "only regular offer");
        require(_lot.price != newPrice, "same");
        _lot.price = newPrice;
    }

    function makeOffer(uint256 lotId) external payable notBanned lotIsActive(lotId) nonReentrant {

        Lot storage lot = lots[lotId];
        require(lot.offerType == Types.offer, "only offer lot type");
        Bid[] storage _bids = bidsOfLot[lotId];
        if (_bids.length > 0) {
            (bool _hasActiveBid, uint256 _activeBidId) = _getLastActiveBid(lotId);
            if (_hasActiveBid) {
                require(msg.value > _bids[_activeBidId].amount);
                (bool _isOk, uint256 _id) = _getMyLastOfferBid(lotId);
                if (_isOk) {
                    Bid storage _lastBid = _bids[_id];
                    _lastBid.isChargedBack = true;
                    (bool isTransfered, ) = _lastBid.buyer.call{value: _lastBid.amount}("");
                    require(isTransfered, "payment error");
                }
            }
        }
        Bid memory _newBid = Bid(payable(msg.sender), msg.value, false, false);
        (bool isOk, ) = payable(address(this)).call{value: msg.value}("");
        require(isOk, "payment error");
        _bids.push(_newBid);
        emit NewOffer(msg.sender, msg.value, lotId);
    }

    function acceptOffer(uint256 lotId) external payable notBanned lotIsActive(lotId) nonReentrant {

        Lot storage lot = lots[lotId];
        require(lot.seller == msg.sender, "seller only");
        require(lot.offerType == Types.offer, "only offer lot type");
        Bid[] storage _bids = bidsOfLot[lotId];
        require(_bids.length > 0, "no bids");
        (bool _hasActiveBid, uint256 _activeBidId) = _getLastActiveBid(lotId);
        require(_hasActiveBid, "no active bids");
        Bid storage _winner = _bids[_activeBidId];
        _winner.isWinner = true;
        _buy(lot, _winner.amount, lotId);
        emit OfferAccepted(lotId);
    }

    function buy(uint256 lotId) external payable notBanned lotIsActive(lotId) nonReentrant {

        Lot storage lot = lots[lotId];
        require(lot.offerType == Types.regular, "only regular lot type");
        require(msg.value == lot.price, "wrong ether amount");
        _buy(lot, lot.price, lotId);
    }

    function bid(uint256 lotId) external payable notBanned lotIsActive(lotId) nonReentrant {

        Lot storage lot = lots[lotId];
        require(lot.offerType == Types.auction, "only auction lot type");
        require(lot.auctionStart <= block.timestamp, "auction is not started yet");
        require(lot.auctionEnd >= block.timestamp, "auction already finished");
        Bid[] storage bids = bidsOfLot[lotId];
        uint256 bidAmount = msg.value;
        for (uint256 i = 0; i < bids.length; i++) {
            if (bids[i].buyer == msg.sender && !bids[i].isChargedBack) {
                bidAmount += bids[i].amount;
            }
        }
        if (lot.stopPrice != 0) {
            require(bidAmount <= lot.stopPrice, "amount should be less or equal to stop price");
        }
        require(bidAmount >= lot.price, "amount should be great or equal to lot price");
        if (bids.length > 0) {
            require(bids[bids.length - 1].amount < bidAmount, "bid should be greater than last");
        }
        (bool fundsInMarketplace, ) = payable(address(this)).call{value: msg.value}("");
        require(fundsInMarketplace, "payment error (bidder)");
        Bid memory newBid = Bid(payable(msg.sender), bidAmount, false, false);
        for (uint256 i = 0; i < bids.length; i++) {
            if (bids[i].buyer == msg.sender && !bids[i].isChargedBack) {
                bids[i].isChargedBack = true;
            }
        }
        bids.push(newBid);
        if (lot.stopPrice != 0 && bidAmount == lot.stopPrice) {
            lot.auctionEnd = block.timestamp - 1;
            _finalize(lotId);
        }
    }

    function finalize(uint256 lotId) external notBanned lotIsActive(lotId) nonReentrant {

        _finalize(lotId);
    }


    function _getMyLastOfferBid(uint256 _lotId) internal view returns (bool _isOk, uint256 _bidId) {

        Bid[] memory _bids = bidsOfLot[_lotId];
        if (_bids.length > 0) {
            for (uint256 _i = _bids.length - 1; _i >= 0; _i--) {
                if (_bids[_i].buyer == msg.sender && !_bids[_i].isChargedBack) {
                    _isOk = true;
                    _bidId = _i;
                    break;
                }
            }
        }
    }

    function _getLastActiveBid(uint256 _lotId) internal view returns (bool _isOk, uint256 _bidId) {

        Bid[] memory _bids = bidsOfLot[_lotId];
        if (_bids.length > 0) {
            for (uint256 _i = _bids.length - 1; _i >= 0; _i--) {
                if (!_bids[_i].isChargedBack) {
                    _isOk = true;
                    _bidId = _i;
                    break;
                }
            }
        }
    }

    function _buy(
        Lot storage lot,
        uint256 price,
        uint256 lotId
    ) internal {

        uint256 _fee = (price * serviceFee) / FEES_MULTIPLIER;
        uint256 _royaltyPercent = 0;
        bool _payRoyalty = IERC20Upgradeable(ara).balanceOf(lot.seller) < 50000 ether;
        if (_payRoyalty) {
            _payRoyalty = IERC721Upgradeable(rad).balanceOf(lot.seller) < 1;
        }
        if (_payRoyalty) {
            Royalty memory _royalty = royalties[lot.nft][lot.tokenId];
            if (_royalty.percent > 0) {
                _royaltyPercent = (price * _royalty.percent) / FEES_MULTIPLIER;
                (bool payedRoyalty, ) = payable(_royalty.receiver).call{value: _royaltyPercent}("");
                require(payedRoyalty, "payment error (royalty)");
            }
        }
        (bool payedToSeller, ) = lot.seller.call{value: price - _fee - _royaltyPercent}("");
        require(payedToSeller, "payment error (seller)");
        (bool payedToFeesCollector, ) = feesCollector.call{value: _fee}("");
        require(payedToFeesCollector, "payment error (fees collector)");
        lot.isSold = true;
        IERC721Upgradeable(lot.nft).safeTransferFrom(address(this), msg.sender, lot.tokenId);
        emit Sold(lotId, msg.sender, price, _fee, _royaltyPercent);
    }

    function _finalize(uint256 lotId) internal {

        Lot storage lot = lots[lotId];
        Bid[] storage bids = bidsOfLot[lotId];
        require(bids.length > 0, "no bids");
        require(lot.auctionEnd < block.timestamp, "auction is not finished yet");
        uint256 winnerId;
        if (bids.length == 1) {
            winnerId = 0;
        } else {
            winnerId = bids.length - 1;
            for (uint256 i = 0; i < bids.length - 1; i++) {
                Bid storage _bid = bids[i];
                if (!_bid.isChargedBack) {
                    _bid.isChargedBack = true;
                    (bool success, ) = _bid.buyer.call{value: _bid.amount}("");
                    if (!success) {
                        emit FailedTx(lotId, i, _bid.buyer, _bid.amount);
                    }
                }
            }
        }
        bids[winnerId].isWinner = true;
        _buy(lot, bids[winnerId].amount, lotId);
    }


    function initialize(address _ara, address _rad) public initializer {

        __Ownable_init();
        __ReentrancyGuard_init();
        feesCollector = payable(msg.sender);
        serviceFee = 0;
        maxRoyaltyPercent = 1000; // 10%
        ara = _ara;
        rad = _rad;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {

        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }

    receive() external payable {}
}