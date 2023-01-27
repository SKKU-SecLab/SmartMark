
pragma solidity ^0.6.0;


contract PaytoWin {

  uint256 public lastblock;
  uint256 public lastbuy;
  address payable public biggestWhale;
  address payable public owner;
   
  constructor() public {
    owner = msg.sender;
  }

  event BiggerWhale(address whale, uint256 buyin);
  event RoundEnded(address whale, uint256 pot);

  function claim() external {

    address payable whale = biggestWhale;
    require(now >= 1 days + lastblock, "Must wait 24 hours to claim winnings.");
    require(whale != address(0), "No current whales.");
    lastbuy = 0;
    biggestWhale = address(0);
    owner.transfer(address(this).balance / 50);
    uint256 pot = address(this).balance;
    whale.transfer(pot);
    emit RoundEnded(whale, pot);
  }

  function Buy() external payable {

    require(msg.value > lastbuy, "Insufficient input.");
    address payable whale = biggestWhale;
    lastbuy = msg.value;
    biggestWhale = msg.sender;
    lastblock = now;
    if (whale != address(0)) whale.transfer(lastbuy / 2);
    emit BiggerWhale(msg.sender, msg.value);
  }

  function timeRemaining() external view returns (uint256) {

    if (now >= 1 days + lastblock) return 0;
    return (1 days + lastblock) - now;
  }    function lstbuy() public view returns (uint) {
        return lastbuy;

    }
    }