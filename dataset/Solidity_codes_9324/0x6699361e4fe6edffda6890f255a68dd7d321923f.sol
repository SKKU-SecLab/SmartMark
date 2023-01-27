

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



contract EthertoteToken {

    function thisContractAddress() public pure returns (address) {}

    function balanceOf(address) public pure returns (uint256) {}
    function transfer(address, uint) public {}

}



contract TeamTokens {
    using SafeMath for uint256;
    
    EthertoteToken public token;

    address public admin;
    address public thisContractAddress;
    
    address public tokenContractAddress = 0x740A61Ad4fb99AF22Fb42cA25F548640ae64911D;
    
    uint256 public unlockDate1 = 1543622400;
    
    uint256 public unlockDate2 = 1551398400;
    
    uint256 public unlockDate3 = 1559347200;
    
    uint256 public unlockDate4 = 1567296000;
    
    uint256 public createdAt;
    
    uint public tokensToBeClaimed;
    
    bool public claimAmountSet;
    
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


    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }
    
    event ReceivedTokens(address from, uint256 amount);
    event WithdrewTokens(address tokenContract, address to, uint256 amount);

    constructor () public {
        admin = msg.sender;
        thisContractAddress = address(this);
        createdAt = now;
        
        thisContractAddress = address(this);

        token = EthertoteToken(tokenContractAddress);
    }
    
  function thisContractTokenBalance() public view returns(uint) {
      return token.balanceOf(thisContractAddress);
  }
  
  function thisContractBalance() public view returns(uint) {
      return address(this).balance;
  }

    function() payable public { 
        emit ReceivedTokens(msg.sender, msg.value);
    }

    function setTokensToBeClaimed() onlyAdmin public {
        require(claimAmountSet == false);
        tokensToBeClaimed = token.balanceOf(thisContractAddress);
        claimAmountSet = true;
    }


    function withdraw1() onlyAdmin public {
       require(now >= unlockDate1);
       require(withdraw_1Completed == false);
       require(claimAmountSet == true);
       token.transfer(admin, (tokensToBeClaimed.div(quarter1)));
       
       emit WithdrewTokens(thisContractAddress, admin, (tokensToBeClaimed.div(quarter1)));    // 25%
       withdraw_1Completed = true;
    }
    
    function withdraw2() onlyAdmin public {
       require(now >= unlockDate2);
       require(withdraw_2Completed == false);
       require(claimAmountSet == true);
       token.transfer(admin, (tokensToBeClaimed.div(quarter2)));
       
       emit WithdrewTokens(thisContractAddress, admin, (tokensToBeClaimed.div(quarter2)));    // 25%
       withdraw_2Completed = true;
    }
    
    function withdraw3() onlyAdmin public {
       require(now >= unlockDate3);
       require(withdraw_3Completed == false);
       require(claimAmountSet == true);
       token.transfer(admin, (tokensToBeClaimed.div(quarter3)));
       
       emit WithdrewTokens(thisContractAddress, admin, (tokensToBeClaimed.div(quarter3)));    // 25%
       withdraw_3Completed = true;
    }
    
    function withdraw4() onlyAdmin public {
       require(now >= unlockDate4);
       require(withdraw_3Completed == true);
       token.transfer(admin, (thisContractTokenBalance()));
       
       emit WithdrewTokens(thisContractAddress, admin, (thisContractTokenBalance()));    // 25%
    }
    
    
    function infoWithdraw1() public view returns(address, uint256, uint256, uint256) {
        return (admin, unlockDate1, createdAt, (tokensToBeClaimed.div(quarter1)));
    }

    function infoWithdraw2() public view returns(address, uint256, uint256, uint256) {
        return (admin, unlockDate2, createdAt, (tokensToBeClaimed.div(quarter2)));
    }
    
    function infoWithdraw13() public view returns(address, uint256, uint256, uint256) {
        return (admin, unlockDate3, createdAt, (tokensToBeClaimed.div(quarter3)));
    }
    
    function infoWithdraw4() public view returns(address, uint256, uint256, uint256) {
        return (admin, unlockDate4, createdAt, (thisContractTokenBalance()));
    }


    function ClaimEth() onlyAdmin public {
        require(address(this).balance > 0);
        address(admin).transfer(address(this).balance);

    }


}