

pragma solidity ^0.6.1;

contract hashelot_dayrings{ // Son of a lockdown


    address payable private owner;

    address payable [] public stackPlayers;

    uint public stackValue; // Current value to enter the bet
    uint public stackTime;  // The block.number at which the bet started
    uint public stackWait; // What a difference a day made
    uint public stackSoFar; // Total amount of winnings

    constructor() public{ // Once and for all
        owner = msg.sender;
        stackSoFar = 0;
        stackWait = 5748;
    }

    modifier OwnerOnly{

        if(msg.sender == owner){
            _;
        }
    }

    function dustStack() OwnerOnly public payable{

        require (block.number > stackTime+stackWait, "Unable to dust: there is an ongoing bet.");
        if (stackPlayers.length >= 1){
          closeBet();
        }
        uint _balance = address(this).balance;
        if(_balance > 0){ // Is there something to dust?
          owner.transfer(_balance);
        }
    }

    function closeBet() public payable {

        uint _block = block.number;
        require (_block > stackTime+stackWait && stackPlayers.length >= 1, "Bet closing error: no bet to claim.");
        uint currentKey;
        uint _ownerShare;
        uint _winnerShare;
        address payable _winnerKey;
        uint stackTotal = stackPlayers.length*stackValue;
        _ownerShare = stackTotal/100*2;
        _winnerShare = stackTotal-_ownerShare;


        currentKey = uint(keccak256(abi.encodePacked(blockhash(stackTime+stackWait+1), stackPlayers[0])));
        _winnerKey = stackPlayers[0];

        for (uint k = 1; k < stackPlayers.length; k++){
          if(uint(keccak256(abi.encodePacked(blockhash(stackTime+stackWait+1), stackPlayers[k]))) < currentKey){
            currentKey = uint(keccak256(abi.encodePacked(blockhash(stackTime+stackWait+1), stackPlayers[k])));
            _winnerKey = stackPlayers[k];
          }
        }  // Gotcha!

        owner.transfer(_ownerShare);

        _winnerKey.transfer(_winnerShare);
        stackSoFar = stackSoFar+_winnerShare; // Update the total amount won
        stackValue = 0;
        stackTime = 0;
        delete stackPlayers; // Closing previous bets
    }

    function checkBalance() public view returns (uint){

        return address(this).balance;
    }

    function checkPlayers() public view returns (uint){

        return stackPlayers.length;
    }

    function depositStack() public payable{

        require (msg.value >= 1 finney, "Deposit error: not enough cash."); // At least 1 finney bets

        uint _block = block.number;

        if (_block > stackTime+stackWait) { // There is no bet in progress

          if (stackPlayers.length >= 1){
            closeBet();
          }

          stackValue = msg.value; // New value one needs to enter the bet
          stackTime = _block; // The game starts now!
          stackPlayers.push(msg.sender);

        }else{ // There actually is a bet in progress!

          bool alreadyIn = false;
          for (uint k = 0; k < stackPlayers.length; k++){
            if (stackPlayers[k] == msg.sender){
              alreadyIn = true;
            }
          }

          if (alreadyIn){ // Hey, don't play twice!
            msg.sender.transfer(msg.value);
          }else{ // You can enter the round
            if (msg.value >= stackValue) {
              uint playerChange = msg.value-stackValue;
              if (playerChange > 0) {
                msg.sender.transfer(playerChange);
              }
              stackPlayers.push(msg.sender); // Another player enters the bet
            }else{ // Too poor to enter the bet
              msg.sender.transfer(msg.value);
            }
          }
        }
    }
}