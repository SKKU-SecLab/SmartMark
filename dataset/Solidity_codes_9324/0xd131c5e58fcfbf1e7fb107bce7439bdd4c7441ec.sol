
pragma solidity 0.5.11;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }
}

contract ERC20 {

  function totalSupply()public view returns (uint total_Supply);

  function balanceOf(address who)public view returns (uint256);

  function allowance(address owner, address spender)public view returns (uint);

  function transferFrom(address from, address to, uint value)public returns (bool ok);

  function approve(address spender, uint value)public returns (bool ok);

  function transfer(address to, uint value)public returns (bool ok);

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
  
}


contract ARMB is ERC20
{ using SafeMath for uint256;

    string private constant _name = "ARMB";
    
    string private constant _symbol = "ARMB";
    
    uint8 private constant _decimals = 2;
    
    uint256 private Totalsupply;
    
    address private _owner; 
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    event Mint(address indexed from, address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event ChangeOwnerShip(address indexed newOwner);


    modifier onlyOwner() {

        require(msg.sender == _owner, "Only owner is allowed");
        _;
    }
    
    constructor() public
    {
        _owner = msg.sender;
       
    }
    
    function name() public pure returns (string memory) {

        return _name;
    }
    
    function symbol() public pure returns (string memory) {

        return _symbol;
    }
    
    function decimals() public pure returns (uint8) {

        return _decimals;
    }
    
     function owner() public view returns (address) {

        return _owner;
    }

  
    function mintTokens(address receiver, uint256 _amount) external onlyOwner returns (bool){

        require(receiver != address(0), "Address can not be 0x0");
        require(_amount > 0, "Value should larger than 0");
        balances[receiver] = (balances[receiver]).add(_amount);
        Totalsupply = (Totalsupply).add(_amount);
        emit Mint(msg.sender, receiver, _amount);
        emit Transfer(address(0), receiver, _amount);
        return true;
       }
    
 
    
    function burnTokens(address receiver, uint256 _amount) external onlyOwner returns (bool){

        require(balances[receiver] >= _amount, "Amount cannot exceeed the balance");
        require(_amount > 0, "Value should larger than 0");
        balances[receiver] = (balances[receiver]).sub(_amount);
        Totalsupply = Totalsupply.sub(_amount);
        emit Burn(receiver, _amount);
        emit Transfer(receiver, address(0), _amount);
        return true;
    }
    
   
     function totalSupply() public view returns (uint256 ) {

         return Totalsupply;
     }
    
     function balanceOf(address investor)public view returns (uint256 ) {

         return balances[investor];
     }
    
     function transferFrom( address _from, address _to, uint256 _amount ) public returns (bool success) {

     require( _to != address(0), "Receiver can not be 0x0");
     require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
     balances[_from] = (balances[_from]).sub(_amount);
     allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
     balances[_to] = (balances[_to]).add(_amount);
     emit Transfer(_from, _to, _amount);
     return true;
         }
    
     function approve(address _spender, uint256 _amount) public returns (bool success) {

         require( _spender != address(0), "Address can not be 0x0");
         require(balances[msg.sender] >= _amount, "Balance does not have enough tokens");
         allowed[msg.sender][_spender] = _amount;
         emit Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _from, address _spender) public view returns (uint256) {

         require( _from != address(0), "Address can not be 0x0");
         require( _spender != address(0), "Address can not be 0x0");
         return allowed[_from][_spender];
   }

     function transfer(address _to, uint256 _amount) public returns (bool) {

        require( _to != address(0), "Receiver can not be 0x0");
        require(balances[msg.sender] >= _amount && _amount >= 0);
        balances[msg.sender] = (balances[msg.sender]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
         }
    
	function transferOwnership(address newOwner) external onlyOwner
	{

	    require( newOwner != address(0), "Address can not be 0x0");
	    uint256 _previousBalance = balances[_owner];
	    balances[newOwner] = (balances[newOwner]).add(balances[_owner]);
	    balances[_owner] = 0;
	    _owner = newOwner;
	    emit ChangeOwnerShip(newOwner);
	    emit Transfer(msg.sender, newOwner, _previousBalance);
	}
	
}