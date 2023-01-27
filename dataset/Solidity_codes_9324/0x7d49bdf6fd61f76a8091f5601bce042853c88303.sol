

pragma solidity 0.6.9;

contract Try06A1
{

    using SafeMath for uint256;
    
    address admin;

    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public decimal;
  
    
    event Transfer (address payable indexed _to,uint256 indexed _value);
    event Approve (address payable indexed _from, address payable indexed _to, uint256 indexed _value);
    event TransferFrom (address payable indexed _owner,address payable indexed _from, address payable indexed _to, uint256 _amount);

    mapping (address => uint256) public balances;
    
    mapping (address => mapping (address => uint256)) public allowance;
    
    constructor () public 
    {
        admin = msg.sender;
        name = "Try06A1";
        symbol = "TRY6A1";
        totalSupply = 4000000000;
        decimal = 16;
        balances[admin] = (totalSupply) * (10 ** decimal);
  
    }
    
    modifier isValidAmount (uint256 _value)
    {

        require (_value > 0, "Invalid amount!");
        _;
    }
    
    function transfer (address payable _to, uint256 _value) public 
    isValidAmount (_value)
    returns (bool success)
    {
        require (balances[msg.sender] > _value, "Insuffcient balance");
        
        _transfer (msg.sender, _to, _value);    
       
        emit Transfer (_to, _value);
       
        return true;
    }
    
    function approve (address payable _spender, uint256 _value) public 
    isValidAmount (_value)
    returns (bool success)
    {
        require (_spender != address(0), "Address not Exist");
        require (_value > 0, "Invalid amount");
        require (balances[msg.sender] > 0, "Insuffcient balance");
        
        allowance[_spender][msg.sender] = _value;
        
        emit Approve (msg.sender, _spender, _value);
        
        return true;
    }
    
    function transferFrom (address payable _from, address payable _to, uint256 _amount) public 
    isValidAmount (_amount)
    returns (bool success)
    {
        require (allowance[msg.sender][_from] >= _amount);
        require (balances[_from] > _amount, "The owner has Insufficent balance");
        
        allowance[msg.sender][_from] -= _amount;
        balances[_from] -=_amount;
        balances[_to] += _amount;
        
        emit TransferFrom (_from, msg.sender, _to, _amount);
        
        return true;
    }
    
    function _transfer (address _from, address _to, uint256 _value) internal isValidAmount (_value){
        
        require (_to != address(0), "Address not Exist");
        require (balances[_from] > _value, "Insufficent balance");
        
        balances[_to] += _value;
        balances[_from] -= _value;
    }
}

library SafeMath {

function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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