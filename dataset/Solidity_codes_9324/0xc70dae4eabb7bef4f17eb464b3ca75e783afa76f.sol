
pragma solidity 0.4.23;

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

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {

    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {

    assert(token.approve(spender, value));
  }
}


contract AdvisorLockUP {

  using SafeERC20 for ERC20Basic;
  using SafeMath for uint256;

  ERC20Basic public token;

  address public beneficiary;

  uint256 public releaseTime;
  
  uint256 public month = 30 days;

  uint256 public maxThreshold = 0;
  
  uint public total_amount = 190000000 * 10 ** uint256(18);
  
  uint public twenty_percent_of_amount = (total_amount.mul(2)).div(10);
  
  uint8 current_month = 1;
  
  bool internal token_set = false;

  constructor() public {
    beneficiary = 0xA6ae9438b17997d68c3CD5e4b5B51CEE85ceD030;
    releaseTime = now + 3 * month;
  }

    function setToken(address _token) public{

        require(!token_set);
        token_set = true;
        token = ERC20Basic(_token);
    }
  function release() public {

    require(now >= releaseTime);
    assert(current_month <= 5);
    
    uint diff = now - releaseTime;
    if (diff > month){
        releaseTime = now;
    }else{
        releaseTime = now.add(month.sub(diff));
    }
    
    current_month++;
    token.safeTransfer(beneficiary, twenty_percent_of_amount);
    
  }
}