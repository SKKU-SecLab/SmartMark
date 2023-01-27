
pragma solidity ^0.4.24;

interface token {

    function transfer(address _receiver, uint _amount) returns (bool success);

}

contract owned {

    address public owner;

    function owned() {

        owner = msg.sender;
    }

    modifier onlyOwner() { 

        require (msg.sender == owner); 
        _; 
    }

    function ownerTransferOwnership(address newOwner) onlyOwner
    {

        owner = newOwner;
    }
}

contract SafeMath {

  function safeMul(uint256 a, uint256 b) internal returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {

    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {

    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {

    if (!assertion) {
      throw;
    }
  }
}

contract BOSTokenCrowdfund is owned, SafeMath {



    modifier onlyAllowPublicWithdraw() { 

        require (allowPublicWithdraw); 
        _; 
    }

    uint public sellPrice = 0.000004 ether;
    uint public amountRaised;
    token public tokenReward;
    bool public crowdsaleClosed = false;
    mapping (address => uint) public balanceOf;
    bool public allowPublicWithdraw = false;

    event LogFundTransfer(address indexed Backer, uint indexed Amount, bool indexed IsContribution);

    function BOSTokenCrowdfund(
        token _addressOfTokenUsedAsReward
    ) {

        tokenReward = token(_addressOfTokenUsedAsReward);
    }

    function () payable
    {
        require (!crowdsaleClosed);
        require (msg.value > 0);

        uint tokens = SafeMath.safeMul(SafeMath.safeDiv(msg.value, sellPrice), 1 ether);
        if(tokenReward.transfer(msg.sender, tokens)) {
            LogFundTransfer(msg.sender, msg.value, true); 
        } else {
            throw;
        }

        amountRaised = SafeMath.safeAdd(amountRaised, msg.value);
        balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], msg.value);
    }

    function publicWithdraw() public
        onlyAllowPublicWithdraw
    {

        calcRefund(msg.sender);
    }

    function calcRefund(address _addressToRefund) internal
    {

        uint amount = balanceOf[_addressToRefund];
        balanceOf[_addressToRefund] = 0;
        if (amount > 0) {
            _addressToRefund.transfer(amount);
            LogFundTransfer(_addressToRefund, amount, false);
        }
    }

    function withdrawAmountTo (uint256 _amount, address _to) public
        onlyOwner
    {
        _to.transfer(_amount);
        LogFundTransfer(_to, _amount, false);
    }

    function ownerSetCrowdsaleClosed (bool status) public onlyOwner
    {
        crowdsaleClosed = status;
    }

    function ownerSetAllowPublicWithdraw (bool status) public onlyOwner
    {
        allowPublicWithdraw = status;
    }
}