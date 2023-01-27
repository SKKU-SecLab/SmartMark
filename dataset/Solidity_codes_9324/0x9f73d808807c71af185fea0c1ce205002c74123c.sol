


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


contract EthRaised {

    using SafeMath for uint256;

    address public thisContractAddress;
    address public admin;
    
    uint public createdAt;
    
    address public ethertoteDevelopmentWallet = 
    0x1a3c1ca46c58e9b140485A9B0B740d42aB3B4a26;
    
    address public toteLiquidatorWallet = 
    0x8AF2dA3182a3dae379d51367a34480Bd5d04F4e2;
    
    address public teamEthContract = 
    0x67ed24A0dB2Ae01C4841Cd8aef1DA519B588E2B2;
    

    bool public ethertoteDevelopmentTransferComplete;
    bool public toteLiquidatorTransferComplete;
    bool public teamEthTransferComplete;


    
    uint public ethToBeDistributed;
    
    bool public ethToBeDistributedSet;


    uint public divForEthertoteDevelopmentWallet = 2;
    
    uint public divForEthertoteLiquidatorWallet = 4;
    
    uint public divForTeamEthContract = 4;

    
    event Received(uint256);
    event SentToTeamEth(uint256);
    event SentToLiquidator(uint256);
    event SentToDev(uint256);
    
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
    
    
    function _A_tokenSaleCompleted() onlyAdmin public {

        require(ethToBeDistributedSet == false);
        ethToBeDistributed = address(this).balance;
        ethToBeDistributedSet = true;
        emit Received(now);
    }   
    
    
    function _B_sendToEthertoteDevelopmentWallet() onlyAdmin public {

       require(ethertoteDevelopmentTransferComplete == false);
       require(ethToBeDistributed > 0);
       address(ethertoteDevelopmentWallet).transfer(ethToBeDistributed.div(divForEthertoteDevelopmentWallet));
       emit SentToDev(ethToBeDistributed.div(divForEthertoteDevelopmentWallet)); 
       ethertoteDevelopmentTransferComplete = true;
    }
    
    function _C_sendToToteLiquidatorWallet() onlyAdmin public {

       require(toteLiquidatorTransferComplete == false);
       require(ethToBeDistributed > 0);
       address(toteLiquidatorWallet).transfer(ethToBeDistributed.div(divForEthertoteLiquidatorWallet));
       emit SentToLiquidator(ethToBeDistributed.div(divForEthertoteLiquidatorWallet)); 
       toteLiquidatorTransferComplete = true;
    }

    function _D_sendToTeamEthContract() onlyAdmin public {

       require(teamEthTransferComplete == false);
       require(ethToBeDistributed > 0);
       address(teamEthContract).transfer(ethToBeDistributed.div(divForTeamEthContract));
       emit SentToTeamEth(ethToBeDistributed.div(divForTeamEthContract)); 
       teamEthTransferComplete = true;
    }
    
    function ClaimEth() onlyAdmin public {

        require(ethertoteDevelopmentTransferComplete == true);
        require(toteLiquidatorTransferComplete == true);
        require(teamEthTransferComplete == true);
        
        require(address(this).balance > 0);
        address(admin).transfer(address(this).balance);

    }
}