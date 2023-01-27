
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

pragma solidity >=0.6.0 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT
pragma experimental ABIEncoderV2;
pragma solidity ^0.6.0;

contract NFTAuctionSale is Ownable {

    using SafeMath for uint256;

    event NewAuctionItemCreated(uint256 auctionId);
    event EmergencyStarted();
    event EmergencyStopped();
    event BidPlaced(
        uint256 auctionId,
        address paymentTokenAddress,
        uint256 bidId,
        address addr,
        uint256 bidPrice,
        uint256 timestamp,
        address transaction
    );
    event BidReplaced(
        uint256 auctionId,
        address paymentTokenAddress,
        uint256 bidId,
        address addr,
        uint256 bidPrice,
        uint256 timestamp,
        address transaction
    );

    event RewardClaimed(address addr, uint256 auctionId, uint256 tokenCount);
    event BidIncreased(
        uint256 auctionId,
        address paymentTokenAddress,
        uint256 bidId,
        address addr,
        uint256 bidPrice,
        uint256 timestamp,
        address transaction
    );

    struct AuctionProgress {
        uint256 currentPrice;
        address bidder;
    }

    struct AuctionInfo {
        uint256 startTime;
        uint256 endTime;
        uint256 totalSupply;
        uint256 startPrice;
        address paymentTokenAddress; // ERC20
        address auctionItemAddress; // ERC1155
        uint256 auctionItemTokenId;
    }

    address public salesPerson = address(0);

    bool private emergencyStop = false;

    mapping(uint256 => AuctionInfo) private auctions;
    mapping(uint256 => mapping(uint256 => AuctionProgress)) private bids;
    mapping(uint256 => mapping(address => uint256)) private currentBids;

    uint256 public totalAuctionCount = 0;

    constructor() public {}

    modifier onlySalesPerson {

        require(
            _msgSender() == salesPerson,
            "Only salesPerson can call this function"
        );
        _;
    }

    function setSalesPerson(address _salesPerson) external onlyOwner {

        salesPerson = _salesPerson;
    }

    function max(uint256 a, uint256 b) private pure returns (uint256) {

        return a > b ? a : b;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {

        return a < b ? a : b;
    }

    function getBatchAuctions(uint256 fromId)
        external
        view
        returns (AuctionInfo[] memory)
    {

        require(fromId <= totalAuctionCount, "Invalid auction id");
        AuctionInfo[] memory currentAuctions =
            new AuctionInfo[](totalAuctionCount - fromId + 1);
        for (uint256 i = fromId; i <= totalAuctionCount; i++) {
            AuctionInfo storage auction = auctions[i];
            currentAuctions[i - fromId] = auction;
        }
        return currentAuctions;
    }

    function getBids(uint256 auctionId)
        external
        view
        returns (AuctionProgress[] memory)
    {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        AuctionInfo storage auction = auctions[auctionId];
        AuctionProgress[] memory lBids =
            new AuctionProgress[](auction.totalSupply);
        mapping(uint256 => AuctionProgress) storage auctionBids =
            bids[auctionId];
        for (uint256 i = 0; i < auction.totalSupply; i++) {
            AuctionProgress storage lBid = auctionBids[i];
            lBids[i] = lBid;
        }
        return lBids;
    }

    function getMaxPrice(uint256 auctionId) public view returns (uint256) {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        AuctionInfo storage auction = auctions[auctionId];
        mapping(uint256 => AuctionProgress) storage auctionBids =
            bids[auctionId];

        uint256 maxPrice = auctionBids[0].currentPrice;
        for (uint256 i = 1; i < auction.totalSupply; i++) {
            maxPrice = max(maxPrice, auctionBids[i].currentPrice);
        }

        return maxPrice;
    }

    function getMinPrice(uint256 auctionId) public view returns (uint256) {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        AuctionInfo storage auction = auctions[auctionId];
        mapping(uint256 => AuctionProgress) storage auctionBids =
            bids[auctionId];

        uint256 minPrice = auctionBids[0].currentPrice;
        for (uint256 i = 1; i < auction.totalSupply; i++) {
            minPrice = min(minPrice, auctionBids[i].currentPrice);
        }

        return minPrice;
    }

    function transferERC20(address tokenAddr) external onlySalesPerson {

        IERC20 erc20 = IERC20(tokenAddr);
        erc20.transfer(_msgSender(), erc20.balanceOf(address(this)));
    }

    function transferETH() external onlySalesPerson {

        _msgSender().transfer(address(this).balance);
    }

    function createAuction(
        address paymentTokenAddress,
        address auctionItemAddress,
        uint256 auctionItemTokenId,
        uint256 startPrice,
        uint256 totalSupply,
        uint256 startTime,
        uint256 endTime
    ) external onlyOwner {

        require(
            salesPerson != address(0),
            "Salesperson address should be valid"
        );
        require(emergencyStop == false, "Emergency stopped");
        require(totalSupply > 0, "Total supply should be greater than 0");
        IERC1155 auctionToken = IERC1155(auctionItemAddress);

        require(
            auctionToken.supportsInterface(0xd9b67a26),
            "Auction token is not ERC1155"
        );

        require(
            auctionToken.balanceOf(salesPerson, auctionItemTokenId) >=
                totalSupply,
            "NFT balance not sufficient"
        );

        require(
            auctionToken.isApprovedForAll(salesPerson, address(this)),
            "Auction token from sales person has no allowance for this contract"
        );


        totalAuctionCount = totalAuctionCount.add(1);
        auctions[totalAuctionCount] = AuctionInfo(
            startTime,
            endTime,
            totalSupply,
            startPrice,
            paymentTokenAddress,
            auctionItemAddress,
            auctionItemTokenId
        );

        emit NewAuctionItemCreated(totalAuctionCount);
    }

    function claimReward(uint256 auctionId) external {

        require(emergencyStop == false, "Emergency stopped");
        require(auctionId <= totalAuctionCount, "Auction id is invalid");

        require(
            auctions[auctionId].endTime <= block.timestamp,
            "Auction is not ended yet"
        );

        mapping(address => uint256) storage auctionCurrentBids =
            currentBids[auctionId];
        uint256 totalWon = auctionCurrentBids[_msgSender()];

        require(totalWon > 0, "Nothing to claim");

        auctionCurrentBids[_msgSender()] = 0;

        IERC1155(auctions[auctionId].auctionItemAddress).safeTransferFrom(
            salesPerson,
            _msgSender(),
            auctions[auctionId].auctionItemTokenId,
            totalWon,
            ""
        );

        emit RewardClaimed(_msgSender(), auctionId, totalWon);
    }

    function increaseMyBidETH(uint256 auctionId) external payable {

        require(emergencyStop == false, "Emergency stopped");
        require(auctionId <= totalAuctionCount, "Auction id is invalid");
        require(msg.value > 0, "Wrong amount");
        require(
            block.timestamp < auctions[auctionId].endTime,
            "Auction is ended"
        );

        AuctionInfo storage auction = auctions[auctionId];

        require(
            auction.paymentTokenAddress == address(0),
            "Cannot use ETH in this auction"
        );

        uint256 count = currentBids[auctionId][_msgSender()];
        require(count > 0, "Not in current bids");

        mapping(uint256 => AuctionProgress) storage auctionBids =
            bids[auctionId];

        for (uint256 i = 0; i < auction.totalSupply; i++) {
            AuctionProgress storage progress = auctionBids[i];
            if (progress.bidder == _msgSender()) {
                progress.currentPrice = progress.currentPrice.add(msg.value);
                emit BidIncreased(
                    auctionId,
                    auction.paymentTokenAddress,
                    i,
                    _msgSender(),
                    progress.currentPrice,
                    block.timestamp,
                    tx.origin
                );
            }
        }
    }

    function makeBidETH(uint256 auctionId)
        external
        payable
        isBidAvailable(auctionId)
    {

        uint256 minIndex = 0;
        uint256 minPrice = getMinPrice(auctionId);

        AuctionInfo storage auction = auctions[auctionId];
        require(
            auction.paymentTokenAddress == address(0),
            "Cannot use ETH in this auction"
        );
        require(
            msg.value >= auction.startPrice && msg.value > minPrice,
            "Cannot place bid at low price"
        );

        mapping(address => uint256) storage auctionCurrentBids =
            currentBids[auctionId];
        require(
            auctionCurrentBids[_msgSender()] < 1,
            "Max bid per wallet exceeded"
        );

        mapping(uint256 => AuctionProgress) storage auctionBids =
            bids[auctionId];

        for (uint256 i = 0; i < auction.totalSupply; i++) {
            if (auctionBids[i].currentPrice == 0) {
                minIndex = i;
                break;
            } else if (auctionBids[i].currentPrice == minPrice) {
                minIndex = i;
            }
        }

        if (auctionBids[minIndex].currentPrice != 0) {
            (bool sent, bytes memory data) =
                address(auctionBids[minIndex].bidder).call{
                    value: auctionBids[minIndex].currentPrice
                }("");
            require(sent, "Failed to send Ether");

            auctionCurrentBids[auctionBids[minIndex].bidder]--;

            emit BidReplaced(
                auctionId,
                auction.paymentTokenAddress,
                minIndex,
                auctionBids[minIndex].bidder,
                auctionBids[minIndex].currentPrice,
                block.timestamp,
                tx.origin
            );
        }

        auctionBids[minIndex].currentPrice = msg.value;
        auctionBids[minIndex].bidder = _msgSender();

        auctionCurrentBids[_msgSender()] = auctionCurrentBids[_msgSender()].add(
            1
        );

        emit BidPlaced(
            auctionId,
            auction.paymentTokenAddress,
            minIndex,
            _msgSender(),
            msg.value,
            block.timestamp,
            tx.origin
        );
    }

    function increaseMyBid(uint256 auctionId, uint256 increaseAmount) external {

        require(emergencyStop == false, "Emergency stopped");
        require(auctionId <= totalAuctionCount, "Auction id is invalid");
        require(increaseAmount > 0, "Wrong amount");
        require(
            block.timestamp < auctions[auctionId].endTime,
            "Auction is ended"
        );

        AuctionInfo storage auction = auctions[auctionId];

        require(auction.paymentTokenAddress != address(0), "Wrong function");

        uint256 count = currentBids[auctionId][_msgSender()];
        require(count > 0, "Not in current bids");

        IERC20(auction.paymentTokenAddress).transferFrom(
            _msgSender(),
            address(this),
            increaseAmount * count
        );

        mapping(uint256 => AuctionProgress) storage auctionBids =
            bids[auctionId];

        for (uint256 i = 0; i < auction.totalSupply; i++) {
            AuctionProgress storage progress = auctionBids[i];
            if (progress.bidder == _msgSender()) {
                progress.currentPrice = progress.currentPrice.add(
                    increaseAmount
                );
                emit BidIncreased(
                    auctionId,
                    auction.paymentTokenAddress,
                    i,
                    _msgSender(),
                    progress.currentPrice,
                    block.timestamp,
                    tx.origin
                );
            }
        }
    }

    function makeBid(uint256 auctionId, uint256 bidPrice)
        external
        isBidAvailable(auctionId)
    {

        uint256 minIndex = 0;
        uint256 minPrice = getMinPrice(auctionId);

        AuctionInfo storage auction = auctions[auctionId];
        require(auction.paymentTokenAddress != address(0), "Wrong function");
        IERC20 paymentToken = IERC20(auction.paymentTokenAddress);
        require(
            bidPrice >= auction.startPrice && bidPrice > minPrice,
            "Cannot place bid at low price"
        );

        uint256 allowance = paymentToken.allowance(_msgSender(), address(this));
        require(allowance >= bidPrice, "Check the token allowance");

        mapping(address => uint256) storage auctionCurrentBids =
            currentBids[auctionId];
        require(
            auctionCurrentBids[_msgSender()] < 1,
            "Max bid per wallet exceeded"
        );

        mapping(uint256 => AuctionProgress) storage auctionBids =
            bids[auctionId];

        for (uint256 i = 0; i < auction.totalSupply; i++) {
            if (auctionBids[i].currentPrice == 0) {
                minIndex = i;
                break;
            } else if (auctionBids[i].currentPrice == minPrice) {
                minIndex = i;
            }
        }

        paymentToken.transferFrom(_msgSender(), address(this), bidPrice);

        if (auctionBids[minIndex].currentPrice != 0) {
            paymentToken.transferFrom(
                address(this),
                auctionBids[minIndex].bidder,
                auctionBids[minIndex].currentPrice
            );
            auctionCurrentBids[auctionBids[minIndex].bidder]--;

            emit BidReplaced(
                auctionId,
                auction.paymentTokenAddress,
                minIndex,
                auctionBids[minIndex].bidder,
                auctionBids[minIndex].currentPrice,
                block.timestamp,
                tx.origin
            );
        }

        auctionBids[minIndex].currentPrice = bidPrice;
        auctionBids[minIndex].bidder = _msgSender();

        auctionCurrentBids[_msgSender()] = auctionCurrentBids[_msgSender()].add(
            1
        );

        emit BidPlaced(
            auctionId,
            auction.paymentTokenAddress,
            minIndex,
            _msgSender(),
            bidPrice,
            block.timestamp,
            tx.origin
        );
    }

    modifier isBidAvailable(uint256 auctionId) {

        require(
            !emergencyStop &&
                auctionId <= totalAuctionCount &&
                auctions[auctionId].startTime <= block.timestamp &&
                auctions[auctionId].endTime > block.timestamp
        );
        _;
    }

    function isAuctionFinished(uint256 auctionId) external view returns (bool) {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        return (emergencyStop || auctions[auctionId].endTime < block.timestamp);
    }

    function getTimeRemaining(uint256 auctionId)
        external
        view
        returns (uint256)
    {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        return auctions[auctionId].endTime - block.timestamp;
    }

    function setEmergencyStart() external onlyOwner {

        emergencyStop = true;
        emit EmergencyStarted();
    }

    function setEmergencyStop() external onlyOwner {

        emergencyStop = false;
        emit EmergencyStopped();
    }

    function setStartTimeForAuction(uint256 auctionId, uint256 startTime)
        external
        onlyOwner
    {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        auctions[auctionId].startTime = startTime;
    }

    function setEndTimeForAuction(uint256 auctionId, uint256 endTime)
        external
        onlyOwner
    {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        auctions[auctionId].endTime = endTime;
    }

    function setTotalSupplyForAuction(uint256 auctionId, uint256 totalSupply)
        external
        onlyOwner
    {

        require(totalSupply > 0, "Total supply should be greater than 0");
        require(auctionId <= totalAuctionCount, "Invalid auction id");
        auctions[auctionId].totalSupply = totalSupply;
    }

    function setStartPriceForAuction(uint256 auctionId, uint256 startPrice)
        external
        onlyOwner
    {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        auctions[auctionId].startPrice = startPrice;
    }

    function setPaymentTokenAddressForAuction(
        uint256 auctionId,
        address paymentTokenAddress
    ) external onlyOwner {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        auctions[auctionId].paymentTokenAddress = paymentTokenAddress;
    }

    function setAuctionItemAddress(
        uint256 auctionId,
        address auctionItemAddress
    ) external onlyOwner {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        auctions[auctionId].auctionItemAddress = auctionItemAddress;
    }

    function setAuctionItemTokenId(
        uint256 auctionId,
        uint256 auctionItemTokenId
    ) external onlyOwner {

        require(auctionId <= totalAuctionCount, "Invalid auction id");
        auctions[auctionId].auctionItemTokenId = auctionItemTokenId;
    }
}