
pragma solidity ^0.6.6;

contract PlusOne {

    uint constant public incrementPercent = 10; // each player must play at list 10% more than the previous player
    uint constant public feePercent = 19;

    address public owner;
    address public lastPlayer;
    uint256 public fees;
    uint256 public playerTimeout;
    uint256 public gameTimeout;
    uint256 public minimumDeposit;
    bool public winnerFundWithdrawn;

    constructor() public payable {
        owner = msg.sender;
        gameTimeout = block.number + 2102400; // approx 1 year
        playerTimeout = gameTimeout;
        fees = msg.value * feePercent / 100;
        lastPlayer = msg.sender;
        setMinimumDeposit(msg.value);
    }
    
    function play() payable public {

        require(msg.value >= minimumDeposit, 'Send more than minimumDeposit');

        setMinimumDeposit(msg.value);
        fees += msg.value * feePercent / 100;

        if (block.number < playerTimeout && block.number < gameTimeout) {
            lastPlayer = msg.sender;
            playerTimeout = block.number + 17280; // approx 3 days
        }
    }
    
    function setMinimumDeposit(uint256 currentDeposit) private {

        minimumDeposit = currentDeposit * (100 + incrementPercent) / 100; // Next player will need to play with at least 10% more
    }
    
    function withdraw() public {

        require(!winnerFundWithdrawn, 'Already withdrawn');
        require(block.number >= playerTimeout || block.number >= gameTimeout);

        winnerFundWithdrawn = true;
        payable(lastPlayer).transfer(address(this).balance - fees);
    }
    
    function withdrawFees() public {

        require(msg.sender == owner, 'Not owner');
        
        if (winnerFundWithdrawn) {
            payable(owner).transfer(address(this).balance);
        }
        else {
            fees = 0;
            payable(owner).transfer(fees);
        }
    }
    
    receive() external payable { }
}