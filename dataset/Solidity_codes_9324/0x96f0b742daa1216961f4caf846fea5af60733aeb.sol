
pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract CrowdsaleToken {

    using SafeMath for uint256;
    string public constant name = 'Rocketclock';
    string public constant symbol = 'RCLK';
    address payable owner;
    address payable contractaddress;
    uint256 public constant totalSupply = 1000;

    mapping (address => uint256) public balanceOf;

    event Transfer(address payable indexed from, address payable indexed to, uint256 value);

    modifier onlyOwner() {

        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    constructor() public{
        contractaddress = address(this);
        owner = msg.sender;
        balanceOf[owner] = totalSupply;

    }

    function _transfer(address payable _from, address payable _to, uint256 _value) internal {

        require (_to != address(0x0));                      // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] > _value);                // Check if the sender has enough
        require (balanceOf[_to].add(_value) > balanceOf[_to]); // Check for overflows
        balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    function transfer(address payable _to, uint256 _value) public returns (bool success) {


        _transfer(msg.sender, _to, _value);
        return true;

    }

    function crownfundTokenBalanceToOwner(address payable _from) public onlyOwner returns (bool success) {

      CrowdSale c = CrowdSale(_from);
      address crowdsaleOwner = c.getOwner();
      if (crowdsaleOwner == owner ) {
        uint256 _value = balanceOf[_from];
        balanceOf[_from] = 0;
        balanceOf[owner] = balanceOf[owner].add(_value);
        emit Transfer(_from, owner, _value);
        return true;
      }
      else{
        return false;
      }

    }

    function () external payable onlyOwner{}


    function getBalance(address addr) public view returns(uint256) {

      return balanceOf[addr];
    }

    function getEtherBalance() public view returns(uint256) {

      return address(this).balance;
    }

    function getOwner() public view returns(address) {

      return owner;
    }

}

contract CrowdSale {

    using SafeMath for uint256;

    address payable public beneficiary;
    address payable public crowdsaleAddress;
    address payable public tokenAddress;
    address payable public owner;
    uint public fundingGoal;
    uint public amountRaised;
    uint public tokensSold;
    uint public deadline;
    uint public downloaddeadline;
    uint public emergencydeadline;
    uint public initiation;
    uint256 public constant totalprice = 250 finney;
    uint256 public constant price = 150 finney;
    uint256 public constant collateral = 100 finney;
    uint public constant amount = 1;
    uint public constant tokenGoal = 990;

    CrowdsaleToken public tokenReward;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public balanceCollateral;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;

    event GoalReached(address beneficiary, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    modifier onlyOwner() {

        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    constructor(
        address payable ifSuccessfulSendTo,
        address payable addressOfTokenUsedAsReward
    )public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = 75 * 1 ether;
        deadline = now + 60 * 1 days;
        downloaddeadline = now + 120 * 1 days;
        emergencydeadline = now + 180 * 1 days;
        initiation = now;
        crowdsaleAddress = address(this);
        tokenAddress = addressOfTokenUsedAsReward;
        tokenReward = CrowdsaleToken(addressOfTokenUsedAsReward);
        owner = msg.sender;
    }


    function () external payable {

      require(!crowdsaleClosed);
      if (now <= deadline){

        uint256 _value = msg.value;
        if(_value >= totalprice){
          uint256 _value_price = _value.sub(collateral);
          balanceOf[msg.sender] = balanceOf[msg.sender].add(_value_price);
          balanceCollateral[msg.sender] = balanceCollateral[msg.sender].add(collateral);
          tokensSold += amount;
          amountRaised += _value_price;
          tokenReward.transfer(msg.sender, amount);
          emit FundTransfer(msg.sender, amount, true);
        }
        else{
          amountRaised += msg.value;
        }
      }
      else{
        revert();
      }

    }

    modifier afterDeadline() { if (now >= deadline) _; }

    modifier afterDownloadDeadline() { if (now >= downloaddeadline) _; }

    modifier afterEmergencyDeadline() { if (now >= emergencydeadline) _; }

    modifier goalReached() { if (amountRaised >= fundingGoal) _; }


    function checkGoalReached() public afterDeadline returns(bool) {

        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
        return crowdsaleClosed;
    }

    function getCrowdsaleOwnerTokenBalance() view public returns (uint256){


      uint256 ownertokenbalance = tokenReward.getBalance(owner);
      uint256 crowdsaletokenbalance = tokenReward.getBalance(crowdsaleAddress);
      uint256 total = ownertokenbalance.add(crowdsaletokenbalance);
      return total;
    }

    function getDownload() public afterDeadline returns(bool) {


      if (tokenReward.getBalance(msg.sender) >= amount){
        tokenReward.transfer(owner, amount);
        emit FundTransfer(owner, amount, true);

        uint256 returnamount = balanceCollateral[msg.sender];
        balanceCollateral[msg.sender] = 0;
        if (returnamount > 0) {
            if (msg.sender.send(returnamount)) {
                emit FundTransfer(msg.sender, returnamount, false);
            } else {
                balanceCollateral[msg.sender] = returnamount;
            }
        }
        return true;
      }
      else{
        return false;
      }

    }

    function safeWithdrawal() public afterDeadline {

        if (!fundingGoalReached) {
            uint256 returnamount = balanceOf[msg.sender].add(balanceCollateral[msg.sender]);
            balanceOf[msg.sender] = 0;
            balanceCollateral[msg.sender] = 0;
            if (returnamount >= totalprice) {
                if (msg.sender.send(returnamount)) {
                    emit FundTransfer(msg.sender, returnamount, false);
                } else {
                    balanceOf[msg.sender] = returnamount;
                }
            }
        }

    }

    function safeWithdrawalNoDownload() public afterDownloadDeadline {

        if (this.getCrowdsaleOwnerTokenBalance() < tokenGoal) {
            uint256 returnamount = balanceOf[msg.sender].add(balanceCollateral[msg.sender]);
            balanceOf[msg.sender] = 0;
            balanceCollateral[msg.sender] = 0;
            if (returnamount >= totalprice) {
                if (msg.sender.send(returnamount)) {
                    emit FundTransfer(msg.sender, returnamount, false);
                } else {
                    balanceOf[msg.sender] = returnamount;
                }
            }
        }

    }

    function crowdfundWithdrawal() public afterDownloadDeadline onlyOwner {

      if (this.getCrowdsaleOwnerTokenBalance() >= tokenGoal){
        if (fundingGoalReached && beneficiary == msg.sender) {

          if (beneficiary.send(amountRaised)) {
              emit FundTransfer(beneficiary, amountRaised, false);
          }

        }
      }

    }

    function emergencyWithdrawal() public afterEmergencyDeadline onlyOwner {


        if (beneficiary == msg.sender) {

          if (beneficiary.send(address(this).balance)) {
              emit FundTransfer(beneficiary, address(this).balance, false);
          }

        }

    }

    function closeDeadline() public goalReached onlyOwner {

      deadline = now;
    }

    function getcrowdsaleClosed() public view returns(bool) {

      return crowdsaleClosed;
    }

    function getfundingGoalReached() public view returns(bool) {

      return fundingGoalReached;
    }

    function getOwner() public view returns(address) {

      return owner;
    }

    function getbalanceOf(address _from) public view returns(uint256) {

      return balanceOf[_from];
    }

}