

pragma solidity 0.4.24;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract TeamEth {

    using SafeMath for uint256;

    address public thisContractAddress;
    address public admin;
    
    uint public oneQuarterInSeconds = 7890000;
    
    
    uint256 public unlockDate1 = 1543622400;
    
    uint256 public unlockDate2 = unlockDate1.add(oneQuarterInSeconds);
    uint256 public unlockDate3 = unlockDate2.add(oneQuarterInSeconds);
    uint256 public unlockDate4 = unlockDate3.add(oneQuarterInSeconds);
    
    uint256 public createdAt;
    
    uint public ethToBeClaimed;
    
    uint public percentageQuarter1 = 25;
    uint public percentageQuarter2 = 25;
    uint public percentageQuarter3 = 25;
    
    uint public hundredPercent = 100;
    
    uint public quarter1 = hundredPercent.div(percentageQuarter1);
    uint public quarter2 = hundredPercent.div(percentageQuarter2);
    uint public quarter3 = hundredPercent.div(percentageQuarter3);
    
    bool public withdraw_1Completed;
    bool public withdraw_2Completed;
    bool public withdraw_3Completed;

    event Received(address from, uint256 amount);
    event Withdrew(address to, uint256 amount);
    
    modifier onlyAdmin {

        require(msg.sender == admin);
        _;
    }

    constructor () public {
        admin = msg.sender;
        thisContractAddress = address(this);
        createdAt = now;
    }

    function() payable public { 
    }
    
    function thisContractBalance() public view returns(uint) {

        return address(this).balance;
    }
    
    function setEthToBeClaimed() onlyAdmin public {

        ethToBeClaimed = address(this).balance;
    }

    function withdraw_1() onlyAdmin public {

       require(ethToBeClaimed > 0);
       require(withdraw_1Completed == false);
       require(now >= unlockDate1);
       msg.sender.transfer(ethToBeClaimed.div(quarter1));
       emit Withdrew(msg.sender, ethToBeClaimed.div(quarter1));    // 25%
       withdraw_1Completed = true;
    }
    
    function withdraw_2() onlyAdmin public {

       require(ethToBeClaimed > 0);
       require(withdraw_2Completed == false);
       require(now >= unlockDate2);
       msg.sender.transfer(ethToBeClaimed.div(quarter2));
       emit Withdrew(msg.sender, ethToBeClaimed.div(quarter2));    // 25%
       withdraw_2Completed = true;
    }
    
    function withdraw_3() onlyAdmin public {

       require(ethToBeClaimed > 0);
       require(withdraw_3Completed == false);
       require(now >= unlockDate3);
       msg.sender.transfer(ethToBeClaimed.div(quarter3));
       emit Withdrew(msg.sender, ethToBeClaimed.div(quarter3));    // 25%
       withdraw_3Completed = true;
    }
    
    function withdraw_4() onlyAdmin public {

       require(now >= unlockDate4);
       msg.sender.transfer(address(this).balance);
       emit Withdrew(msg.sender, address(this).balance);    // all remaining balance
    }

}