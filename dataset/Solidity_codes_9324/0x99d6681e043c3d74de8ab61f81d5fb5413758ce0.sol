
pragma solidity ^0.8.0;


contract ReversePonzi {

    
    address payable owner; //the devs, gotta pay these cunts something
    address payable leader; //the current leader, set to win 1000x returns
    uint256 gameNumber;
    uint256 lastBlockPlayedOn;
    uint256 blocksPerGame;
    uint256 betsThisGame;
    
    event newPayment(address player, uint amount, uint betsThisGame); // Event for when shit goes down bruh
    
    constructor(){
        owner = payable(msg.sender); //the devs, gotta pay these cunts something
        leader = payable(msg.sender); //the current leader, set to win 1000x returns
        gameNumber = 1;
        lastBlockPlayedOn = block.number;
        blocksPerGame = 6646;
        betsThisGame = 0;
    }
    
    function getStats() public view returns (uint256, uint256, uint256, address, uint256){

        uint256 blocksLeft = lastBlockPlayedOn + blocksPerGame - block.number;
        uint256 minamount = address(this).balance * 90 / 100 / 1000;
        return ( address(this).balance, gameNumber, blocksLeft, leader, minamount);
    }
    
    receive() external payable { //when some cunt sends fundz

        
        uint256 amountRequired = (address(this).balance - msg.value) * 90 / 100 / 1000; //it's 90% of the contract balance, divided by 1000, so it's a 1000x multiple;
        
        if(amountRequired > msg.value){
            revert("Send more money cunt");
        }
    
        
        if(block.number > lastBlockPlayedOn + blocksPerGame){
            revert("Too late cunt");
        }
        
        leader = payable(msg.sender);
        lastBlockPlayedOn = block.number;
        
        betsThisGame++;
        
        emit newPayment(msg.sender, msg.value, betsThisGame);
    }
    
    function finishGame() public payable{

        if(block.number < lastBlockPlayedOn + blocksPerGame){
            revert("Slow down cunt, game aint done yet");
        }
        
        uint amountForLeader = address(this).balance * 90 / 100;
        uint amountForDevs = address(this).balance * 5 / 100;
        
        address payable devAddress = owner;
        devAddress.transfer(amountForDevs);
        
        
        address payable leaderAddress = payable(leader);
        leader = payable(owner);
        leaderAddress.transfer(amountForLeader);
        
        gameNumber++;
        lastBlockPlayedOn = block.number;
        betsThisGame = 0;
        
    }
    
}