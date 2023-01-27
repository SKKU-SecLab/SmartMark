
pragma solidity 0.4.25;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor () public {
    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract PricingScheme is Ownable {

  using SafeMath for uint;

  address public feeWallet;

  constructor() public {
    feeWallet = msg.sender;
  }

  function setFeeWallet(address _feeWallet) public onlyOwner {

    feeWallet = _feeWallet;
  }

  uint public defaultMonthlyFeeInWei = 1e17;
  uint public defaultYearlyFeeInWei = 1e17;

  uint public exclusiveSetupFeeInWei;
  uint public exclusiveYearlyFeeInWei;

  uint public vipSetupFeeInWei;
  uint public vipYearlyFeeInWei;

  mapping (address => uint) public dappMonthlyFeeInWei;
  mapping (address => uint) public dappYearlyFeeInWei;

  mapping (address => mapping (address => uint)) public lastMonthlySubscribed;
  mapping (address => mapping (address => uint)) public lastYearlySubscribed;

  mapping (address => bool) public vipSubscribed;
  mapping (address => bool) public exclusiveSubscribed;
  mapping (address => uint) public lastVipYearlyFeePaid;
  mapping (address => uint) public lastExclusiveYearlyFeePaid;

  function setExclusiveFee(uint _setupFee, uint _yearlyFee) public onlyOwner {

    exclusiveSetupFeeInWei = _setupFee;
    exclusiveYearlyFeeInWei = _yearlyFee;
  }

  function setVipFee(uint _setupFee, uint _yearlyFee) public onlyOwner {

    vipSetupFeeInWei = _setupFee;
    vipYearlyFeeInWei = _yearlyFee;
  }

  function setDefaultFee(uint _monthlyFee, uint _yearlyFee) public onlyOwner {

    defaultMonthlyFeeInWei = _monthlyFee;
    defaultYearlyFeeInWei = _yearlyFee;
  }

  function setDappMonthlyFee(address _dappContractAddress, uint _monthlyFee) public onlyOwner {

    dappMonthlyFeeInWei[_dappContractAddress] = _monthlyFee;
  }

  function setDappYearlyFee(address _dappContractAddress, uint _yearlyFee) public onlyOwner {

    dappYearlyFeeInWei[_dappContractAddress] = _yearlyFee;
  }

  function subscribeDappMonthly(address _dappContractAddress) public payable {

    uint fee = dappMonthlyFeeInWei[_dappContractAddress];
    if (fee == 0) fee = defaultMonthlyFeeInWei;

    require(msg.value >= fee);

    lastMonthlySubscribed[msg.sender][_dappContractAddress] = now;


    feeWallet.transfer(msg.value);
  }

  function subscribeDappYearly(address _dappContractAddress) public payable {

    uint fee = dappYearlyFeeInWei[_dappContractAddress];
    if (fee == 0) fee = defaultYearlyFeeInWei;

    require(msg.value >= fee);

    lastYearlySubscribed[msg.sender][_dappContractAddress] = now;

    feeWallet.transfer(msg.value);
  }

  function subscribeVip() public payable {

    require(msg.value >= vipSetupFeeInWei);
    vipSubscribed[msg.sender] = true;
    lastVipYearlyFeePaid[msg.sender] = now;

    feeWallet.transfer(msg.value);
  }

  function subscribeExclusive() public payable {

    require(msg.value >= exclusiveSetupFeeInWei);
    exclusiveSubscribed[msg.sender] = true;
    lastExclusiveYearlyFeePaid[msg.sender] = now;

    feeWallet.transfer(msg.value);
  }

  function payVipYearlyFee() public payable {

    require(msg.value >= vipYearlyFeeInWei);
    lastVipYearlyFeePaid[msg.sender] = now;
    feeWallet.transfer(msg.value);
  }

  function payExclusiveYearlyFee() public payable {

    require(msg.value >= exclusiveYearlyFeeInWei);
    lastExclusiveYearlyFeePaid[msg.sender] = now;
    feeWallet.transfer(msg.value);
  }

  function canUseDapp(address user, address _dappContractAddress) public view returns (bool) {

    if (now.sub(365 days) < lastVipYearlyFeePaid[user]) {
      return true;
    } else if (now.sub(356 days) < lastExclusiveYearlyFeePaid[user]) {
      return true;
    } else if (now.sub(365 days) < lastYearlySubscribed[user][_dappContractAddress]) {
      return true;
    } else if (now.sub(30 days) < lastMonthlySubscribed[user][_dappContractAddress]) {
      return true;
    } else {
      return false;
    }
  }
}