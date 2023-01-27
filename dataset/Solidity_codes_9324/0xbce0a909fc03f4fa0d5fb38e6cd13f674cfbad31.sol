



pragma solidity ^0.5.2;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}


pragma solidity ^0.5.2;


contract DollarAuction {

    using SafeMath for uint256;

    uint256 public constant minimumBidDelta = 1e15;
    uint256 constant twentyFourHours = 24 * 60 * 60;
    uint256 constant tenthEth = 1e17;
    uint256 public expiryTime;
    uint256 public prize;
    address payable private originalOwner;
    address payable public largestDonor;
    address payable public winningBidder;
    address payable public losingBidder;
    uint256 public largestPrizeIncrease;
    uint256 public winningBid;
    uint256 public losingBid;

    constructor() public payable {
        originalOwner = msg.sender;
        reset();
    }

    modifier onlyActiveAuction() {

        require(isActiveAuction(), "Auction not active, call restart to start a new auction.");
        _;
    }

    modifier onlyInactiveAuction() {

        require(!isActiveAuction(), "Auction not expired. Wait for expiryTime to pass.");
        _;
    }

    function increasePrize() public payable onlyActiveAuction {

        require(msg.value >= largestPrizeIncrease.add(minimumBidDelta),
            "Must be larger than largestPrizeIncrease + minimumBidDelta");

        prize = prize.add(msg.value);
        largestDonor = msg.sender;
        largestPrizeIncrease = msg.value;
    }

    function bid() public payable onlyActiveAuction {

        uint bidAmount = msg.value;

        require(bidAmount >= winningBid.add(minimumBidDelta), "Bid too small");

        repayThirdPlace();
        updateLosingBidder();
        updateWinningBidder(bidAmount, msg.sender);

        if(expiryTime < block.timestamp + twentyFourHours){
            expiryTime = block.timestamp + twentyFourHours;
        }
    }

    function withdrawPrize() public onlyInactiveAuction {


        if (!winningBidder.send(prize)){
            if(!losingBidder.send(prize)){
                if(!largestDonor.send(prize)){
                    originalOwner.transfer(prize);
                }
            }
        }

        uint256 bids = winningBid.add(losingBid);
        if(!largestDonor.send(bids)){
            if(!winningBidder.send(bids)){
                if(!losingBidder.send(bids)){
                    originalOwner.transfer(bids);
                }
            }
        }

        prize = 0;
    }

    function restart() public payable onlyInactiveAuction {

        if (prize != 0) {
            withdrawPrize();
        }
        reset();
    }

    function reset() internal onlyInactiveAuction {

        require(msg.value >= minimumBidDelta, "Prize must be at least minimumBidDelta");
        expiryTime = block.timestamp + 2*twentyFourHours;
        prize = msg.value;
        largestDonor = msg.sender;
        winningBidder = msg.sender;
        losingBidder = msg.sender;
        winningBid = 0;
        losingBid = 0;
        largestPrizeIncrease = msg.value;
    }

    function updateWinningBidder(uint256 _bid, address payable _bidder) internal {

        winningBid = _bid;
        winningBidder = _bidder;
    }

    function updateLosingBidder() internal {

        losingBidder = winningBidder;
        losingBid = winningBid;
    }

    function repayThirdPlace() internal {

        bool successfulRepayment = losingBidder.send(losingBid);

        if (!successfulRepayment){
            prize += losingBid;
        }
    }

    function isActiveAuction() public view returns(bool) {

        return block.timestamp < expiryTime;
    }

    function() external payable {
        bid();
    }
}