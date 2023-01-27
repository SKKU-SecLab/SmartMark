
pragma solidity ^0.4.25;

contract Lottery {


    event LotteryTicketPurchased(address indexed _purchaser, uint256 _ticketID);
    event LotteryAmountPaid(address indexed _winner, uint64 _ticketID, uint256 _amount);
    event LotteryTicketPurchased2(address indexed _purchaser2, uint256 _ticketID2);
    event LotteryAmountPaid2(address indexed _winner2, uint64 _ticketID2, uint256 _amount2);
    event LotteryTicketPurchased3(address indexed _purchaser3, uint256 _ticketID3);
    event LotteryAmountPaid3(address indexed _winner3, uint64 _ticketID3, uint256 _amount3);

    uint64 public ticketPrice = 0.1 ether;
    uint64 public ticketMax = 5;
    uint64 public ticketPrice2 = 1 ether;
    uint64 public ticketMax2 = 5;
    uint64 public ticketPrice3 = 2 ether;
    uint64 public ticketMax3 = 5;
    address owner;
    address[6] public ticketMapping;
    uint256 public ticketsBought = 0;
    address[6] public ticketMapping2;
    uint256 public ticketsBought2 = 0;
    address[6] public ticketMapping3;
    uint256 public ticketsBought3 = 0;
    address public fee = 0xd44f59581056EaF5d601edD1244Ff4AA55516666;
    
  
    modifier allTicketsSold() {

      require(ticketsBought >= ticketMax);
      _;
    }
    modifier allTicketsSold2() {

      require(ticketsBought2 >= ticketMax2);
      _;
    }
    modifier allTicketsSold3() {

      require(ticketsBought3 >= ticketMax3);
      _;
    }
    constructor() public{
        owner = msg.sender;
    }

    function() payable public{
      revert();
    }

    function buyTicket(uint16 _ticket) payable public returns (bool) {

      require(msg.value == ticketPrice);
      require(_ticket > 0 && _ticket < ticketMax + 1);
      require(ticketMapping[_ticket] == address(0));
      require(ticketsBought < ticketMax);

      address purchaser = msg.sender;
      ticketsBought += 1;
      ticketMapping[_ticket] = purchaser;
      fee.transfer(0.01 ether);
      emit LotteryTicketPurchased(purchaser, _ticket);

      if (ticketsBought>=ticketMax) {
        sendReward();
      }

      return true;
    }

    function buyTicket2(uint16 _ticket2) payable public returns (bool) {

      require(msg.value == ticketPrice2);
      require(_ticket2 > 0 && _ticket2 < ticketMax2 + 1);
      require(ticketMapping2[_ticket2] == address(0));
      require(ticketsBought2 < ticketMax2);

      address purchaser2 = msg.sender;
      ticketsBought2 += 1;
      ticketMapping2[_ticket2] = purchaser2;
      fee.transfer(0.1 ether);
      emit LotteryTicketPurchased2(purchaser2, _ticket2);

      if (ticketsBought2>=ticketMax2) {
        sendReward2();
      }

      return true;
    }

function buyTicket3(uint16 _ticket3) payable public returns (bool) {

      require(msg.value == ticketPrice3);
      require(_ticket3 > 0 && _ticket3 < ticketMax3 + 1);
      require(ticketMapping3[_ticket3] == address(0));
      require(ticketsBought3 < ticketMax3);

      address purchaser3 = msg.sender;
      ticketsBought3 += 1;
      ticketMapping3[_ticket3] = purchaser3;
      fee.transfer(0.2 ether);
      emit LotteryTicketPurchased3(purchaser3, _ticket3);

      if (ticketsBought3>=ticketMax3) {
        sendReward3();
      }

      return true;
    }

    function sendReward() public allTicketsSold returns (address) {

      uint64 winningNumber = lotteryPicker();
      address winner = ticketMapping[winningNumber];
      uint256 totalAmount = ticketMax * ticketPrice;

      require(winner != address(0));

      reset();
      winner.transfer(0.45 ether);
      emit LotteryAmountPaid(winner, winningNumber, totalAmount);
      return winner;
    }

    function sendReward2() public allTicketsSold2 returns (address) {

      uint64 winningNumber2 = lotteryPicker2();
      address winner2 = ticketMapping2[winningNumber2];
      uint256 totalAmount2 = ticketMax2 * ticketPrice2;

      require(winner2 != address(0));

      reset2();
      winner2.transfer(4.5 ether);
      emit LotteryAmountPaid2(winner2, winningNumber2, totalAmount2);
      return winner2;
    }

    function sendReward3() public allTicketsSold3 returns (address) {

      uint64 winningNumber3 = lotteryPicker3();
      address winner3 = ticketMapping3[winningNumber3];
      uint256 totalAmount3 = ticketMax3 * ticketPrice3;

      require(winner3 != address(0));

      reset3();
      winner3.transfer(9 ether);
      emit LotteryAmountPaid3(winner3, winningNumber3, totalAmount3);
      return winner3;
    }

    function lotteryPicker() public view allTicketsSold returns (uint64) {

      bytes memory entropy = abi.encodePacked(block.timestamp, block.number);
      bytes32 hash = sha256(entropy);
      return uint64(hash) % ticketMax;
    }

    function lotteryPicker2() public view allTicketsSold2 returns (uint64) {

      bytes memory entropy2 = abi.encodePacked(block.timestamp, block.number);
      bytes32 hash = sha256(entropy2);
      return uint64(hash) % ticketMax2;
    }

    function lotteryPicker3() public view allTicketsSold3 returns (uint64) {

      bytes memory entropy3 = abi.encodePacked(block.timestamp, block.number);
      bytes32 hash = sha256(entropy3);
      return uint64(hash) % ticketMax3;
    }

    function reset() private allTicketsSold returns (bool) {

      ticketsBought = 0;
      for(uint x = 0; x < ticketMax+1; x++) {
        delete ticketMapping[x];
      }
      return true;
    }

    function reset2() private allTicketsSold2 returns (bool) {

      ticketsBought2 = 0;
      for(uint x = 0; x < ticketMax2+1; x++) {
        delete ticketMapping2[x];
      }
      return true;
    }

    function reset3() private allTicketsSold3 returns (bool) {

      ticketsBought3 = 0;
      for(uint x = 0; x < ticketMax3+1; x++) {
        delete ticketMapping3[x];
      }
      return true;
    }
    
    function restart() public returns (bool){

        require (msg.sender == owner);
        ticketsBought = 0;
      for(uint x = 0; x < ticketMax+1; x++) {
        delete ticketMapping[x];
      }
      return true;
    }

    function restart2() public returns (bool){

        require (msg.sender == owner);
        ticketsBought2 = 0;
      for(uint x = 0; x < ticketMax2+1; x++) {
        delete ticketMapping2[x];
      }
      return true;
    }

    function restart3() public returns (bool){

        require (msg.sender == owner);
        ticketsBought3 = 0;
      for(uint x = 0; x < ticketMax3+1; x++) {
        delete ticketMapping3[x];
      }
      return true;
    }
    function getTicketsPurchased() public view returns(address[6]) {

      return ticketMapping;
    }

    function getTicketsPurchased2() public view returns(address[6]) {

      return ticketMapping2;
    }

    function getTicketsPurchased3() public view returns(address[6]) {

      return ticketMapping3;
    }
}