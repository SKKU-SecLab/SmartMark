



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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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



pragma solidity ^0.8.6;

interface IKoansToken is IERC721 {

    event KoanCreated(uint256 indexed tokenId);

    event KoanBurned(uint256 indexed tokenId);

    event FoundersDAOUpdated(address koansDAO);

    event MinterUpdated(address minter);

    event MinterLocked();

    function setContractURIHash(string memory newContractURIHash) external;

    
    function setFoundersDAO(address _foundersDAO) external;


    function setMinter(address _minter) external;

    
    function lockMinter() external;


    function mintFoundersDAOKoan(string memory _foundersDAOMetadataURI) external;


    function mint() external returns (uint256);


    function burn(uint256 tokenId) external;


    function setMetadataURI(uint256 tokenId, string memory metadataURI) external;


}



pragma solidity ^0.8.6;

interface ISashoToken is IERC20 {


    function mint(address account, uint256 rawAmount) external;


    function burn(uint256 tokenId) external;


    function delegate(address delegatee) external;


    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) external;


    function setMinter(address minter) external;


    function lockMinter() external;


    function getCurrentVotes(address account) external view returns (uint96);


    function getPriorVotes(address account, uint blockNumber) external view returns (uint96);

}



pragma solidity ^0.8.6;

interface IKoansAuctionHouse {

    struct Auction {
        uint256 koanId;
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        address payable bidder;
        bool settled;
        address payable payoutAddress;
    }

    event AuctionCreated(uint256 indexed koanId, uint256 startTime, uint256 endTime);

    event AuctionBid(uint256 indexed koanId, address sender, uint256 value, bool extended);

    event AuctionExtended(uint256 indexed koanId, uint256 endTime);

    event AuctionSettled(uint256 indexed koanId, address winner, uint256 amount);

    event AuctionTimeBufferUpdated(uint256 timeBuffer);

    event AuctionReservePriceUpdated(uint256 reservePrice);

    event AuctionMinBidIncrementPercentageUpdated(uint256 minBidIncrementPercentage);

    event PayoutRewardBPUpdated(uint256 artistRewardBP);

    event AuctionDurationUpdated(uint256 duration);

    function settleCurrentAndCreateNewAuction() external;


    function settleAuction() external;


    function createBid(uint256 koanId) external payable;


    function addOffer(string memory _uri, address _payoutAddress) external;


    function pause() external;


    function unpause() external;


    function setTimeBuffer(uint256 _timeBuffer) external;


    function setReservePrice(uint256 _reservePrice) external;


    function setMinBidIncrementPercentage(uint8 _minBidIncrementPercentage) external;


    function setPayoutRewardBP(uint256 _payoutRewardBP) external;


    function setDuration(uint256 _duration) external;


    function setOfferAddress(address _koanOfferAddress) external;


}




pragma solidity ^0.8.6;

interface IWETH {

    function deposit() external payable;


    function withdraw(uint256 wad) external;


    function transfer(address to, uint256 value) external returns (bool);

}







pragma solidity ^0.8.6;








contract KoansAuctionHouse is IKoansAuctionHouse, Pausable, ReentrancyGuard, Ownable {

    IKoansToken public koans;

    ISashoToken public sashos;

    address public weth;

    uint256 public timeBuffer;

    uint256 public reservePrice;

    uint8 public minBidIncrementPercentage;

    uint256 public duration;

    IKoansAuctionHouse.Auction public auction;

    string[] public offerURIs;

    address payable[] public offerPayoutAddresses;

    uint256 public nextOfferURIIndex;

    address public koanOfferAddress;

    uint256 public payoutRewardBP;

    address public koansFoundersAddress;


    constructor(
        IKoansToken _koans,
        ISashoToken _sashos,
        address _weth,
        uint256 _timeBuffer,
        uint256 _reservePrice,
        uint8 _minBidIncrementPercentage,
        uint256 _duration,
        address _koanOfferAddress,
        address _koansFoundersAddress
    ) {
        _pause();

        koans = _koans;
        sashos = _sashos;
        weth = _weth;
        timeBuffer = _timeBuffer;
        reservePrice = _reservePrice;
        minBidIncrementPercentage = _minBidIncrementPercentage;
        duration = _duration;
        koanOfferAddress = _koanOfferAddress;
        payoutRewardBP = 5000;
        nextOfferURIIndex = 0;
        koansFoundersAddress = _koansFoundersAddress;
    }

    function settleCurrentAndCreateNewAuction() external override nonReentrant whenNotPaused {

        _settleAuction();
        _createAuction();
    }

    function settleAuction() external override whenPaused nonReentrant {

        _settleAuction();
    }

    function createBid(uint256 koanId) external payable override nonReentrant {

        IKoansAuctionHouse.Auction memory _auction = auction;

        require(_auction.koanId == koanId, "Koan not up for auction");
        require(block.timestamp < _auction.endTime, "Auction expired");
        require(msg.value >= reservePrice, "Must send at least reservePrice");
        require(
            msg.value >= _auction.amount + ((_auction.amount * minBidIncrementPercentage) / 100),
            "Insufficient bid."
        );

        address payable lastBidder = _auction.bidder;

        if (lastBidder != address(0)) {
            _safeTransferETHWithFallback(lastBidder, _auction.amount);
        }

        auction.amount = msg.value;
        auction.bidder = payable(msg.sender);

        bool extended = _auction.endTime - block.timestamp < timeBuffer;
        if (extended) {
            auction.endTime = _auction.endTime = block.timestamp + timeBuffer;
        }

        emit AuctionBid(_auction.koanId, msg.sender, msg.value, extended);

        if (extended) {
            emit AuctionExtended(_auction.koanId, _auction.endTime);
        }
    }

    function addOffer(string memory _uri, address _payoutAddress) external override nonReentrant {

        require(msg.sender == koanOfferAddress, "Must be Offer contract");
        offerURIs.push(_uri);
        offerPayoutAddresses.push(payable(_payoutAddress));
    }  

    function pause() external override onlyOwner {

        _pause();
    }

    function unpause() external override onlyOwner {

        _unpause();

        if (auction.startTime == 0 || auction.settled) {
            _createAuction();
        }
    }

    function setTimeBuffer(uint256 _timeBuffer) external override onlyOwner {

        timeBuffer = _timeBuffer;

        emit AuctionTimeBufferUpdated(_timeBuffer);
    }

    function setReservePrice(uint256 _reservePrice) external override onlyOwner {

        reservePrice = _reservePrice;

        emit AuctionReservePriceUpdated(_reservePrice);
    }

    function setMinBidIncrementPercentage(uint8 _minBidIncrementPercentage) external override onlyOwner {

        minBidIncrementPercentage = _minBidIncrementPercentage;

        emit AuctionMinBidIncrementPercentageUpdated(_minBidIncrementPercentage);
    }

    function setPayoutRewardBP(uint256 _payoutRewardBP) external override onlyOwner {

        require(_payoutRewardBP <= 10000, "BP greater than 10000");
        if (auction.koanId < 100) {
            require(_payoutRewardBP <= 9000, "BP greather than 9000");
        }
        payoutRewardBP = _payoutRewardBP;

        emit PayoutRewardBPUpdated(_payoutRewardBP);
    }

    function setDuration(uint256 _duration) external override onlyOwner {

        duration = _duration;
        
        emit AuctionDurationUpdated(_duration);
    }

    function setOfferAddress(address _koanOfferAddress) external override onlyOwner {

        koanOfferAddress = _koanOfferAddress;
    }

    function _createAuction() internal {

        require(nextOfferURIIndex < offerURIs.length, "No proposed URIs ready.");
        try koans.mint() returns (uint256 koanId) {
            uint256 startTime = block.timestamp;
            uint256 endTime = startTime + duration;
            koans.setMetadataURI(koanId, offerURIs[nextOfferURIIndex]);
            auction = Auction({
                koanId: koanId,
                amount: 0,
                startTime: startTime,
                endTime: endTime,
                bidder: payable(0),
                settled: false,
                payoutAddress: offerPayoutAddresses[nextOfferURIIndex]
            });

            nextOfferURIIndex += 1;

            emit AuctionCreated(koanId, startTime, endTime);
        } catch Error(string memory) {
            _pause();
        }
    }

    function _settleAuction() internal {

        IKoansAuctionHouse.Auction memory _auction = auction;

        require(_auction.startTime != 0, "Auction hasn't begun");
        require(!_auction.settled, "Auction has already been settled");
        require(block.timestamp >= _auction.endTime, "Auction hasn't completed");

        auction.settled = true;

        if (_auction.bidder == address(0)) {
            koans.burn(_auction.koanId);
        } else {
            koans.transferFrom(address(this), _auction.bidder, _auction.koanId);
        }


        if (_auction.amount > 0) {
            uint256 koansFoundersReward = 0;
            if (auction.koanId < 100) {
                koansFoundersReward = _auction.amount * 1000 / 10000;
                _safeTransferETHWithFallback(koansFoundersAddress, koansFoundersReward);
            }
            uint256 payoutReward = _auction.amount * payoutRewardBP / 10000;
            _safeTransferETHWithFallback(_auction.payoutAddress, payoutReward);
            _safeTransferETHWithFallback(owner(), (_auction.amount - koansFoundersReward) - payoutReward);
        }

        sashos.mint(owner(), 1000000 ether);

        emit AuctionSettled(_auction.koanId, _auction.bidder, _auction.amount);
    }

    function _safeTransferETHWithFallback(address to, uint256 amount) internal {

        if (!_safeTransferETH(to, amount)) {
            IWETH(weth).deposit{ value: amount }();
            IERC20(weth).transfer(to, amount);
        }
    }

    function _safeTransferETH(address to, uint256 value) internal returns (bool) {

        (bool success, ) = to.call{ value: value, gas: 30_000 }(new bytes(0));
        return success;
    }
}