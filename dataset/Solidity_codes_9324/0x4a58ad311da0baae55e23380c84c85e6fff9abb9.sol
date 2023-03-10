
pragma solidity 0.5.12;


library SafeMath 
{



  function mul(uint256 a, uint256 b) internal pure returns(uint256 c) 
  {

     if (a == 0) 
     {
     	return 0;
     }

     c = a * b;
     require(c / a == b, "SafeMath: multiplication overflow");

     return c;
  }


  function div(uint256 a, uint256 b) internal pure returns(uint256) 
  {

     require( b > 0, "SafeMath: division by zero");

     return a / b;
  }


  function sub(uint256 a, uint256 b) internal pure returns(uint256) 
  {

     require(b <= a, "SafeMath: subtraction overflow");

     return a - b;
  }


  function add(uint256 a, uint256 b) internal pure returns(uint256 c) 
  {

     c = a + b;

     require(c >= a, "SafeMath: addition overflow");
     return c;
  }
}

contract ERC20Interface
{

    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function approve(address _spender, uint256 _value) public returns (bool);


    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}


contract IFL is ERC20Interface
{

    using SafeMath for uint256;
   
    uint256 constant public TOKEN_DECIMALS = 10 ** 18;
    string public constant name            = "iflag";
    string public constant symbol          = "IFL";
    uint256 public totalTokenSupply        = 60000000 * TOKEN_DECIMALS;

    uint8 public constant decimals         = 18;
    address public owner;
    uint256 public totalBurned;

    event Burn(address indexed _burner, uint256 _value);
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

    struct ClaimLimit 
    {
       uint256 time_limit_epoch;
       bool    limitSet;
    }

    mapping(address => ClaimLimit) public claimLimits;
    mapping(address => uint256) public  balances;
    mapping(address => mapping(address => uint256)) internal  allowed;
 

    modifier onlyOwner() 
    {

       require(msg.sender == owner);
       _;
    }
    

    constructor() public
    {
       owner = msg.sender;
       balances[address(this)] = totalTokenSupply;

       emit Transfer(address(0x0), address(this), balances[address(this)]);
    }


     function burn(uint256 _value) onlyOwner public returns (bool) 
     {

        require(_value <= balances[msg.sender]);

        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);
        totalTokenSupply = totalTokenSupply.sub(_value);
        totalBurned      = totalBurned.add(_value);

        emit Burn(burner, _value);
        emit Transfer(burner, address(0x0), _value);
        return true;
     }     


     function totalSupply() public view returns(uint256 _totalSupply) 
     {

        _totalSupply = totalTokenSupply;
        return _totalSupply;
     }


    function balanceOf(address _owner) public view returns (uint256) 
    {

       return balances[_owner];
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)     
    {


       if (_value == 0) 
       {
           emit Transfer(_from, _to, _value);  // Follow the spec to launch the event when value is equal to 0
           return true;
       }

       require(!claimLimits[msg.sender].limitSet, "Limit is set and use claim");
       require(_to != address(0x0));
       require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value >= 0);

       balances[_from] = balances[_from].sub(_value);
       allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
       balances[_to] = balances[_to].add(_value);

       emit Transfer(_from, _to, _value);
       return true;
    }


    function transferTo(address _address, uint256 _tokens) external onlyOwner returns(bool) 
    {

       require( _address != address(0x0)); 
       require( balances[address(this)] >= _tokens.mul(TOKEN_DECIMALS) && _tokens.mul(TOKEN_DECIMALS) > 0);

       balances[address(this)] = ( balances[address(this)]).sub(_tokens.mul(TOKEN_DECIMALS));
       balances[_address] = (balances[_address]).add(_tokens.mul(TOKEN_DECIMALS));

       emit Transfer(address(this), _address, _tokens.mul(TOKEN_DECIMALS));
       return true;
    }


    function approve(address _spender, uint256 _tokens) public returns(bool)
    {

       require(_spender != address(0x0));

       allowed[msg.sender][_spender] = _tokens;

       emit Approval(msg.sender, _spender, _tokens);
       return true;
    }


    function allowance(address _owner, address _spender) public view returns(uint256)
    {

       require(_owner != address(0x0) && _spender != address(0x0));

       return allowed[_owner][_spender];
    }


    function transfer(address _address, uint256 _tokens) public returns(bool)
    {


       if (_tokens == 0) 
       {
           emit Transfer(msg.sender, _address, _tokens);  // Follow the spec to launch the event when tokens are equal to 0
           return true;
       }

       require(!claimLimits[msg.sender].limitSet, "Limit is set and use claim");
       require(_address != address(0x0));
       require(balances[msg.sender] >= _tokens);

       balances[msg.sender] = (balances[msg.sender]).sub(_tokens);
       balances[_address] = (balances[_address]).add(_tokens);

       emit Transfer(msg.sender, _address, _tokens);
       return true;
    }


    function transferOwnership(address _newOwner)public onlyOwner
    {

       require( _newOwner != address(0x0));

       balances[_newOwner] = (balances[_newOwner]).add(balances[owner]);
       balances[owner] = 0;
       owner = _newOwner;

       emit Transfer(msg.sender, _newOwner, balances[_newOwner]);
   }


   function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) 
   {


      allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
   }


   function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) 
   {

      uint256 oldValue = allowed[msg.sender][_spender];


      if (_subtractedValue > oldValue) 
      {
         allowed[msg.sender][_spender] = 0;
      }
      else 
      {
         allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
      }

      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
   }


   function claim(address _recipient) public
   {

      require(_recipient != address(0x0), "Invalid recipient");
      require(msg.sender != _recipient, "Self transfer");
      require(claimLimits[msg.sender].limitSet, "Limit not set");

      require (now > claimLimits[msg.sender].time_limit_epoch, "Time limit");
       
      uint256 tokens = balances[msg.sender];
       
      balances[msg.sender] = (balances[msg.sender]).sub(tokens);
      balances[_recipient] = (balances[_recipient]).add(tokens);
       
      emit Transfer(msg.sender, _recipient, tokens);
   }
 

   function setClaimLimit(address _address, uint256 _days) public onlyOwner
   {

      require(balances[_address] > 0, "No tokens");

      claimLimits[_address].time_limit_epoch = (now + ((_days).mul(1 days)));
   		
      claimLimits[_address].limitSet = true;
   }


   function resetClaimLimit(address _address) public onlyOwner
   {

      claimLimits[_address].limitSet = false;
   }

}