

pragma solidity ^0.7.0;


library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address addr)
        internal
    {

        role.bearer[addr] = true;
    }

    function remove(Role storage role, address addr)
        internal
    {

        role.bearer[addr] = false;
    }

    function check(Role storage role, address addr)
        view
        internal
    {

        require(has(role, addr));
    }

    function has(Role storage role, address addr)
        view
        internal
        returns (bool)
    {

        return role.bearer[addr];
    }
}


abstract contract RBAC {
    using Roles for Roles.Role;

    mapping (string => Roles.Role) private roles;

    event RoleAdded(address addr, string roleName);
    event RoleRemoved(address addr, string roleName);

    string public constant ROLE_ADMIN = "admin";


    constructor () {
        addRole(msg.sender, ROLE_ADMIN);
    }

    function addRole(address addr, string memory roleName)
        internal
    {
        roles[roleName].add(addr);
        emit RoleAdded(addr, roleName);
    }

    function removeRole(address addr, string memory roleName)
        internal
    {
        roles[roleName].remove(addr);
        emit RoleRemoved(addr, roleName);
    }

    function checkRole(address addr, string memory roleName)
        view
        public
    {
        roles[roleName].check(addr);
    }

    function hasRole(address addr, string memory roleName)
        view
        public
        returns (bool)
    {
        return roles[roleName].has(addr);
    }

    function adminAddRole(address addr, string memory roleName)
        onlyAdmin
        public
    {
        addRole(addr, roleName);
    }

    function adminRemoveRole(address addr, string memory roleName)
        onlyAdmin
        public
    {
        removeRole(addr, roleName);
    }


    modifier onlyRole(string memory roleName)
    {
        checkRole(msg.sender, roleName);
        _;
    }

    modifier onlyAdmin()
    {
        checkRole(msg.sender, ROLE_ADMIN);
        _;
    }



}


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


abstract contract ERC20Basic {
    
  uint256 public totalSupply;
  function balanceOf(address who) public view virtual returns (uint256);
  function transfer(address to, uint256 value) public virtual returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is ERC20Basic {

  using SafeMath for uint256;
  using SafeMath for uint;


  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public override returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view override returns (uint256 balance) {

    return balances[_owner];
  }

}


contract BurnableToken is BasicToken {

    using SafeMath for uint;
    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {

        require(_value <= balances[msg.sender]);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
}


contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


   constructor() {
       owner = msg.sender;
   }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


abstract contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view virtual returns (uint256);
  function transferFrom(address from, address to, uint256 value) public virtual returns (bool);
  function approve(address spender, uint256 value) public virtual returns (bool);
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


contract StandardToken is ERC20, BasicToken {

  using SafeMath for uint;
  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public override returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view override returns (uint256) {

    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}



contract MintableToken is StandardToken, Ownable {

  using SafeMath for uint;
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {

    require(!mintingFinished);
    _;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


contract Recurly is StandardToken, BurnableToken, MintableToken, RBAC {

  using SafeMath for uint;
  string public constant name = "Recurly";
  string public constant symbol = "RCR";
  uint8 public constant decimals = 18;
  string constant public ROLE_TRANSFER = "transfer";
    
  constructor() {
      totalSupply = 0;
  }

  function hodlerTransfer(address _from, uint256 _value) external onlyRole(ROLE_TRANSFER) returns (bool) {

    require(_from != address(0));
    require(_value > 0);

    address _hodler = msg.sender;

    balances[_from] = balances[_from].sub(_value);
    balances[_hodler] = balances[_hodler].add(_value);

    emit Transfer(_from, _hodler, _value);

    return true;
  }
}


contract CLERK is StandardToken, BurnableToken, RBAC {

  using SafeMath for uint;
  string public constant name = "Defi Clerk";
  string public constant symbol = "CLERK";
  uint8 public constant decimals = 18;
  string constant public ROLE_MINT = "mint";

  event MintLog(address indexed to, uint256 amount);

  constructor() {
    totalSupply = 0;
  }

  function mint(address _to, uint256 _amount) external onlyRole(ROLE_MINT) returns (bool) {

    require(_to != address(0));
    require(_amount > 0);

    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);

    emit MintLog(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    
    return true;
  }
}



contract Hodler is Ownable {

  using SafeMath for uint256;
  using SafeERC20 for Recurly;
  using SafeERC20 for CLERK;

  Recurly public recurly;
  CLERK public clerk;
 
  struct Item {
    uint256 id;
    address beneficiary;
    uint256 value;
    uint256 releaseTime;
    bool fulfilled;
  }

  mapping(address => mapping(uint256 => Item)) private items;

  
  constructor(address _recurly, address _clerk) {
      require(_recurly != address(0));
      
      recurly = Recurly(_recurly);
      changeClerkAddress(_clerk);
  }


  function changeClerkAddress(address _clerk) public onlyOwner {

    require(_clerk != address(0));

    clerk = CLERK(_clerk);
  }

  function hodl(uint256 _id, uint256 _value, uint256 _months) external {

    require(_id > 0);
    require(_value > 0);
    require(_months == 3 || _months == 6 || _months == 12);

    address _user = msg.sender;

    Item storage item = items[_user][_id];
    require(item.id != _id);

    uint256 _seconds = _months.mul(2628000);
    uint256 _now = block.timestamp;
    uint256 _releaseTime = _now.add(_seconds);
    require(_releaseTime > _now);

    uint256 balance = recurly.balanceOf(_user);
    require(balance >= _value);

    uint256 userPercentage = _months.div(3);
    uint256 userClerkAmount = _value.mul(userPercentage).div(100);

    items[_user][_id] = Item(_id, _user, _value, _releaseTime, false);

    assert(recurly.hodlerTransfer(_user, _value));

    assert(clerk.mint(_user, userClerkAmount));
  }

  function release(uint256 _id) external {

    require(_id > 0);

    address _user = msg.sender;

    Item storage item = items[_user][_id];

    require(item.id == _id);
    require(!item.fulfilled);
    require(block.timestamp >= item.releaseTime);

    uint256 balance = recurly.balanceOf(address(this));
    require(balance >= item.value);

    item.fulfilled = true;

    recurly.safeTransfer(item.beneficiary, item.value);
  }

  function getItem(address _user, uint256 _id) public view returns (uint256, address, uint256, uint256, bool) {

    Item storage item = items[_user][_id];

    return (
      item.id,
      item.beneficiary,
      item.value,
      item.releaseTime,
      item.fulfilled
    );
  }
}