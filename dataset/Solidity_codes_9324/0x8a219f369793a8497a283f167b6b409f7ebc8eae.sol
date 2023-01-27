
pragma solidity ^0.4.21;

library SmartMatrix {


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


contract SmartSageMatrix {

    address public minter;
    event LogWithdrawal(address sender, uint amount);
    
    mapping (address => uint) public balances;

    event Sent(address from, address to, uint amount);

    constructor() public {
        minter = msg.sender;
    }

    function mint(address receiver, uint amount) public {

        if (msg.sender != minter) return;
        balances[receiver] += amount;
    }

    function send(address receiver, uint amount) public {

        if (balances[msg.sender] < amount) return;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
    
    function getBalance() public view returns(uint balance) {

        return address(this).balance;
    }
    
    
     function withdraw(uint amount) public returns(bool success) {

        require(msg.sender==minter);
        emit LogWithdrawal(msg.sender, amount);
        msg.sender.transfer(amount);
        return true;
    }
    
      
        event Multisended(uint256 value , address sender);
        using SmartMatrix for uint256;
    
        function multisendEther(address[] _contributors, uint256[] _balances) public payable {

            uint256 total = msg.value;
            uint256 i = 0;
            for (i; i < _contributors.length; i++) {
                require(total >= _balances[i] );
                total = total.sub(_balances[i]);
                _contributors[i].transfer(_balances[i]);
            }
            emit Multisended(msg.value, msg.sender);
        
        }
    
    
}