
pragma solidity ^0.4.24;



library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  function Ownable() {

    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract ERC20Basic {

  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is ERC20Basic, Ownable {

  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping(address => bool) public allowedAddresses;
  mapping(address => bool) public lockedAddresses;
  bool public locked = true;

  function allowAddress(address _addr, bool _allowed) public onlyOwner {

    require(_addr != owner);
    allowedAddresses[_addr] = _allowed;
  }

  function lockAddress(address _addr, bool _locked) public onlyOwner {

    require(_addr != owner);
    lockedAddresses[_addr] = _locked;
  }

  function setLocked(bool _locked) public onlyOwner {

    locked = _locked;
  }

  function canTransfer(address _addr) public constant returns (bool) {

    if(locked){
      if(!allowedAddresses[_addr]&&_addr!=owner) return false;
    }else if(lockedAddresses[_addr]) return false;

    return true;
  }




  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(canTransfer(msg.sender));
    

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {

    return balances[_owner];
  }
}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(canTransfer(msg.sender));

    uint256 _allowance = allowed[_from][msg.sender];


    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

    return allowed[_owner][_spender];
  }

  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}


contract BurnableToken is StandardToken {


    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {

        require(_value > 0);
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
        Transfer(burner, address(0), _value);
    }
}

contract Cubebit is BurnableToken {


    string public constant name = "Cubebit";
    string public constant symbol = "CUB";
    uint public constant decimals = 18;
    uint256 public constant initialSupply = 300000000 * (10 ** uint256(decimals));

    function Cubebit () {
        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply; // Send all tokens to owner
        allowedAddresses[owner] = true;
    }

}// UNLICENSED

pragma solidity <=0.7.5;



interface IStaking{

    
    function stake() external returns(bool);

    
    function claim() external returns(bool);

    
    function forceclaim() external returns(bool);

    
    function drain() external returns(bool);

    
    function specificDrain(uint256 amount) external returns(bool);

    
    function fetchhistory(address user) external returns(uint256[],uint256[],uint256[]);

    
}

contract CUB_STAKING {

    Cubebit public cube_address;
    address public owner;
    
    struct History{
        uint256[] time;
        uint256[] amount;
        bool[] isclaimed;
    }
    
    
    struct User{
        uint256 staked;
        uint256 claimed;
        uint256 laststake;
    }
    
    constructor(address contract_address) public{
        cube_address = Cubebit(contract_address);
        owner = msg.sender;
    }
    
    mapping(address => User) public users;
    mapping(address => History) history;
    
    function stake(uint256 _amount) public returns(bool){

        require(cube_address.allowance(msg.sender,address(this)) >= _amount,'Allowance Exceeded');
        require(cube_address.balanceOf(msg.sender) >= _amount,'Insufficient Balance');
        User storage u = users[msg.sender];
        u.staked = SafeMath.add(u.staked,_amount);
        u.laststake = block.timestamp;
        History storage h = history[msg.sender];
        h.time.push(block.timestamp);
        h.amount.push(_amount);
        h.isclaimed.push(false);
        cube_address.transferFrom(msg.sender,address(this),_amount);
        return true;
    }
    
    function claim() public returns(bool,uint256 am){

        User storage u = users[msg.sender];
        require(u.staked > 0, 'Nothing Staked');
        require(block.timestamp > u.laststake + 365 days,'Maturity Not Reached');
        uint256 p = SafeMath.mul(u.staked,12);
        uint256 i = SafeMath.div(p,100);
        History storage h = history[msg.sender];
        h.time.push(block.timestamp);
        h.amount.push(i);
        h.isclaimed.push(true);
        u.claimed = SafeMath.add(u.claimed,i);
        u.staked = 0;
        u.laststake = 0;
        cube_address.transfer(msg.sender,i);
        return(true,i);
    }
    
    function forceclaim() public returns(bool){

        User storage u = users[msg.sender];
        require(u.staked > 0,'Nothing Staked');
        u.claimed = SafeMath.add(u.claimed,u.staked);
        History storage h = history[msg.sender];
        h.time.push(block.timestamp);
        h.amount.push(u.staked);
        h.isclaimed.push(true);
        cube_address.transfer(msg.sender,u.staked);
        u.staked = 0;
        u.laststake = 0;
        return true;
    }
    
    function fetchhistory(address user) public view returns(uint256[] time,uint256[] staked,bool[] claimed){

        History storage h = history[user];
        return(h.time,h.amount,h.isclaimed);
    }
    
    function changeOwner(address new_owner) public returns(bool){

        require(msg.sender==owner,'Not Owner');
        owner = new_owner;
    }
    
    function drain() public returns(bool){

        require(msg.sender==owner,'Not Owner');
        cube_address.transfer(owner,cube_address.balanceOf(address(this)));
    }
    
    function specificDrain(uint256 amount) public returns(bool){

        require(msg.sender==owner,'Not Owner');
        cube_address.transfer(owner,amount);
    }
    
}