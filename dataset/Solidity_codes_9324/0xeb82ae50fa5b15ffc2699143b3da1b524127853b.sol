
pragma solidity ^0.5.11;


contract Ponzi{

    
    uint256 magicNum = 10007585; // numerator
    uint256 magicDen = 10000000; // denominator
    
    uint256[] public compTable; // compound interest table
    
    address payable public educator;
    address payable public killer;
    
    struct Player {
        uint id;
        uint deposit; // principle deposit
        uint regTime; // registration time
    }
    
    struct PlayerRecord {
        address record;
        uint deposit; // principle deposit
        uint regTime; // registration time
        uint withdrawl; // total taken out
        uint exitTime;  // time exited
    }
    
    mapping (address => Player) public players; // tracking active players
    PlayerRecord[] public playerLog; // tracking long term
 
    constructor() public{
        educator=msg.sender;
        killer=msg.sender;
        compTable.push(magicDen); // make sure the first element is set
    }
    
    function () external payable { // deposit
    
        require(msg.sender==tx.origin, "HUMANS ONLY"); // humans only!
        require(players[msg.sender].deposit == 0, "ONE DEPOSIT PER PLAYER");
        require(msg.value>0, "GOTTA PAY TO PLAY");
        
        players[msg.sender].id=playerLog.length;
        players[msg.sender].deposit=msg.value;
        players[msg.sender].regTime=block.timestamp;
        
        PlayerRecord memory newRecord;
        newRecord.record=msg.sender;
        newRecord.deposit=msg.value;
        newRecord.regTime=block.timestamp;
        playerLog.push(newRecord);
    }
    
    function withdraw() public returns(bool result) {

        require(msg.sender==tx.origin, "HUMANS ONLY"); // humans only!
        require(players[msg.sender].deposit!=0, "NEW CONTRACT WHO DIS?");
        uint256 hrs = getAge();
        require(hrs>24, "24hr COOLDOWN PERIOD IN EFFECT");
        require(hrs<compTable.length,"TABLE TOO SMALL");
        
        uint256 winnings = players[msg.sender].deposit*compTable[hrs]/magicDen;
        
        result = msg.sender.send(winnings); // sure hope there was enough in the vault.. 
        playerLog[players[msg.sender].id].exitTime=block.timestamp;

        if(result) {
            playerLog[players[msg.sender].id].withdrawl=winnings; // set 
            result=educator.send(winnings/1000);
        }
        else {
            playerLog[players[msg.sender].id].withdrawl=0;
        }
        
        delete players[msg.sender]; 
    }
    
    function getWealthAtTime(uint256 hrs) public view returns (uint256) {

        return players[msg.sender].deposit*compTable[hrs]/magicDen;
    }
    
    function getWealth() public view returns (uint256) {

        return players[msg.sender].deposit*compTable[getAge()]/magicDen;
    }
    
    function getAge() public view returns (uint256) {

        return (block.timestamp-players[msg.sender].regTime)/3600; // age in hours
    }
    
    function getBalance() public view returns(uint256) {

        return address(this).balance;
    }
    
    function getLogCount() public view returns(uint256) {

        return playerLog.length;
    }
    
    function getTableSize() public view returns(uint256) {

        return compTable.length; //??????
    }
    
    function updateEducator(address payable newEducator) public {

        require(msg.sender==educator,"NO");
        educator=newEducator;
    }
    
    function breakGlass() public {

        require(msg.sender==killer,"NICE TRY");
        selfdestruct(educator);
    }
    
    function updateKiller(address payable newKiller) public {

        require(msg.sender==killer);
        killer=newKiller;
    }
    
    function bumpComp(uint256 count) public returns (uint256) {

        for(uint i=0;i<count;++i) {
          compTable.push(compTable[compTable.length-1]*magicNum/magicDen);
        }
        return compTable.length;
    }

}