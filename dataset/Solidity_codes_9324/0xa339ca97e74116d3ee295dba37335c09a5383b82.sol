
pragma solidity ^0.5.7;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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




contract GsnPs {

    using SafeMath for uint;
    address   owner;    // This is the current owner of the contract.
    mapping (address => uint) internal balance;
    
    event PsExcute(address from, uint amount);
    event GdpSentFromAccount(address from, address to, uint amount);
    event GdpSentFromContract(address from, address to, uint amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  uint public target=0;
  uint public blockheight=0;
  uint public fulfillmentrate=100;
  constructor () public {  // the contract's constructor function.
        owner = msg.sender;
    }



  function getBalance() public view returns (uint256) {

        
        require(msg.sender == owner); // Only the Owner of this contract can run this function.
        return address(this).balance;
    }

    function acceptPs() payable public {

        require(fulfillmentrate >=90,"fulfillment rate less than 90% , stop ps");
        balance[address(this)]+= msg.value;  
        emit PsExcute(msg.sender, msg.value);
    }

    function TransferToGsContractFromOwnerAccount(address payable receiver, uint amount) public {

        require(msg.sender == owner, "You're not owner of the account"); // Only the Owner of this contract can run this function.
        require(amount < address(this).balance, "Insufficient balance.");
        receiver.transfer(amount);
        emit GdpSentFromAccount(msg.sender, receiver, amount);
    }
    
    function transferOwnership(address newOwner) public {

     require(msg.sender == owner, "You're not owner of the contract"); 
     require(newOwner != address(0));
     owner = newOwner;
     emit OwnershipTransferred(owner, newOwner);
   
    }
  
   function SetGsnBlockHeight(uint newTarget, uint newBlockheight) public {

        require(msg.sender == owner, "You're not owner of the account");
        blockheight=newBlockheight;
        target=newTarget;
        
   }
   
  function getGsnBlockheight() public view returns (uint256) {

        return blockheight;
    }

  function getGsnTarget() public view returns (uint256) {

        return target;
    }    

  function resetFulfillmentRate(uint rate) public{

       require(rate>0,"invalid rate");
       require(rate<=100,"invalid rate");
       fulfillmentrate=rate;
  }
  
  function() external payable {
     emit PsExcute(msg.sender, msg.value);
    }
    
 

    
}