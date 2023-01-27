pragma solidity ^0.5.0;
 contract ERC20Interface {

    function totalSupply() public  view returns (uint);

    function balanceOf(address tokenOwner) public  view returns (uint256 balance);

    function allowance(address tokenOwner, address spender) public  view returns (uint256 remaining);

    function transfer(address to, uint256 tokens) public  returns (bool success);

    function approve(address spender, uint256 tokens) public  returns (bool success);

    function transferFrom(address from, address to, uint256 tokens) public  returns (bool success);


    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}// "UNLICENSED "
pragma solidity ^0.5.0;
 
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
  
  function ceil(uint a, uint m) internal pure returns (uint r) {

    return (a + m - 1) / m * m;
  }
}pragma solidity ^0.5.0;

contract TokenTimeLock {


    using SafeMath for uint256;
    address public beneficiary;

     uint256 startTime;

     uint256 counter; 
     
     address owner;
    
    uint256  releaseAmount;
    uint256 public totalTokenLocked;
    ERC20Interface token;
    
    constructor(address _owner)public{
        owner = _owner;
    }

    function lockedToken(address _beneficiary,  uint256 _amount, address _token) public {

        token = ERC20Interface(_token);
        require(msg.sender == owner, "Only owner locked token");
        require(beneficiary == address(0),"Already Add token by beneficiary");
        require(token.balanceOf(msg.sender) >= _amount, "You have not enough Balance to Loked");
       token.transferFrom(msg.sender, address(this), _amount);
        beneficiary = _beneficiary;
        startTime = block.timestamp;
        totalTokenLocked = _amount;

    }

    function withdrawToken(uint256 _amount) public {

        require(msg.sender == beneficiary, "Only benificiary can unlock token");
        if(block.timestamp > (counter.mul(30 days)).add(startTime) )
           counter++;
        uint256 amount = (token.balanceOf(address(this)));
        require(amount > 0, "no Token to release");

        require(releaseAmount.add(_amount) <= counter.mul(20950), "Not enough Balance left to Withdraw this month");
        releaseAmount = releaseAmount.add(_amount);

        token.transfer(beneficiary, _amount);
    }
    function changeBeneficiary(address _beni) public {

        require(msg.sender == beneficiary,"Un authorize call only Beneficiary change Ownership");
        beneficiary = _beni;
    }
    
    function tokenLeft() public view returns (uint256 balance) {

        require(msg.sender == owner ||msg.sender == beneficiary,"Only Owner or beneficiary Call");
        return  totalTokenLocked.sub(releaseAmount);
    }

}


