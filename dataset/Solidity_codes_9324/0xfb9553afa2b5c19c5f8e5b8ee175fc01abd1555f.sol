
pragma solidity 0.5.17;


library SafeMath {


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

contract ERC20Interface {

    function totalSupply() external view returns (uint256);

    function balanceOf(address _who) external view returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);


    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}


contract HBC is ERC20Interface {


    using SafeMath for uint256;
   
    uint256 constant public TOKEN_DECIMALS = 10 ** 18;
    string public constant name            = "Hybrid Bank Cash";
    string public constant symbol          = "HBC";
    uint256 public totalTokenSupply        = 10000000000 * TOKEN_DECIMALS;
    uint8 public constant decimals         = 18;
    bool public stopped                    = false;
    address public owner;
    uint256 public totalBurned;

    event Burn(address indexed _burner, uint256 _value);
    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
    event OwnershipRenounced(address indexed _previousOwner);

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => address) private forbiddenAddresses;
 

    modifier onlyOwner() {

       require(msg.sender == owner, "Caller is not owner");
       _;
    }
    

    constructor() public {
       owner = msg.sender;
       balances[owner] = totalTokenSupply;

       emit Transfer(address(0x0), owner, balances[owner]);
    }


    function pauseTransfer() external onlyOwner {

        stopped = true;
    }


    function resumeTransfer() external onlyOwner {

        stopped = false;
    }


    function addToForbiddenAddresses(address _newAddr) external onlyOwner {

       forbiddenAddresses[_newAddr] = _newAddr;
    }


    function removeFromForbiddenAddresses(address _newAddr) external onlyOwner {

       delete forbiddenAddresses[_newAddr];
    }


    function burn(uint256 _value) onlyOwner external returns (bool) {

       require(!stopped, "Paused");

       address burner = msg.sender;

       balances[burner] = balances[burner].sub(_value, "burn amount exceeds balance");
       totalTokenSupply = totalTokenSupply.sub(_value);
       totalBurned      = totalBurned.add(_value);

       emit Burn(burner, _value);
       emit Transfer(burner, address(0x0), _value);

       return true;
    }     


    function totalSupply() external view returns (uint256) { 

       return totalTokenSupply; 
    }


    function balanceOf(address _owner) external view returns (uint256) {

       return balances[_owner];
    }


    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {    


       require(!stopped, "Paused");
 
       require(_to != address(0x0), "ERC20: transferring to zero address");

       require(_from != address(0x0), "ERC20: transferring from zero address");

       require(forbiddenAddresses[_from] != _from, "ERC20: transfer from forbidden address");

       require(forbiddenAddresses[_to] != _to, "ERC20: transfer to forbidden address");


       if (_value == 0) 
       {
           emit Transfer(_from, _to, _value);  // Follow the spec to launch the event when value is equal to 0
           return true;
       }


       require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value >= 0);

       balances[_from] = balances[_from].sub(_value, "transfer amount exceeds balance");
       allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
       balances[_to] = balances[_to].add(_value);

       emit Transfer(_from, _to, _value);

       return true;
    }


    function approve(address _spender, uint256 _tokens) external returns(bool) {


       require(!stopped, "Paused");

       require(_spender != address(0x0));

       allowed[msg.sender][_spender] = _tokens;

       emit Approval(msg.sender, _spender, _tokens);

       return true;
    }


    function allowance(address _owner, address _spender) external view returns(uint256) {


       require(!stopped, "Paused");

       require(_owner != address(0x0) && _spender != address(0x0));

       return allowed[_owner][_spender];
    }


    function transfer(address _address, uint256 _tokens) external returns(bool) {


       require(!stopped, "Paused");

       require(_address != address(0x0), "ERC20: transferring to zero address");

       require(forbiddenAddresses[msg.sender] != msg.sender, "ERC20: transfer from forbidden address");

       require(forbiddenAddresses[_address] != _address, "ERC20: transfer to forbidden address");

       if (_tokens == 0) 
       {
           emit Transfer(msg.sender, _address, _tokens);  // Follow the spec to launch the event when tokens are equal to 0
           return true;
       }


       require(balances[msg.sender] >= _tokens);

       balances[msg.sender] = (balances[msg.sender]).sub(_tokens, "transfer amount exceeds balance");
       balances[_address] = (balances[_address]).add(_tokens);

       emit Transfer(msg.sender, _address, _tokens);

       return true;
    }


    function transferOwnership(address _newOwner) external onlyOwner {


       uint256 ownerBalances;

       require(!stopped, "Paused");

       require( _newOwner != address(0x0), "ERC20: transferOwnership address is zero address");

       ownerBalances = balances[owner];

       balances[_newOwner] = (balances[_newOwner]).add(balances[owner]);
       balances[owner] = 0;
       owner = _newOwner;

       emit Transfer(msg.sender, _newOwner, ownerBalances);
   }


   function renounceOwnership() external onlyOwner {


      require(!stopped, "Paused");

      owner = address(0x0);
      emit OwnershipRenounced(owner);
   }


   function increaseApproval(address _spender, uint256 _addedValue) external returns (bool success) {


      require(!stopped, "Paused");

      allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

      return true;
   }


   function decreaseApproval(address _spender, uint256 _subtractedValue) external returns (bool success) {


      uint256 oldValue = allowed[msg.sender][_spender];

      require(!stopped, "Paused");

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

}