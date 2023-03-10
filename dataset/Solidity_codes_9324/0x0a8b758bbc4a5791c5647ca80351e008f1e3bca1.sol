
pragma solidity ^0.4.23;

contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract Pausable is Ownable {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {

    require(!paused);
    _;
  }

  modifier whenPaused() {

    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {

    paused = true;
    emit Pause();
  }

  function unpause() onlyOwner whenPaused public {

    paused = false;
    emit Unpause();
  }
}

contract Claimable is Ownable {

  address public pendingOwner;

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {

    pendingOwner = newOwner;
  }

  function claimOwnership() onlyPendingOwner public {

    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

contract AccessByGame is Pausable, Claimable {

  mapping(address => bool) internal contractAccess;

  modifier onlyAccessByGame {

    require(!paused && (msg.sender == owner || contractAccess[msg.sender] == true));
    _;
  }

  function grantAccess(address _address)
    onlyOwner
    public
  {

    contractAccess[_address] = true;
  }

  function revokeAccess(address _address)
    onlyOwner
    public
  {

    contractAccess[_address] = false;
  }
}

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract ERC827 is ERC20 {

  function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool);


  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool);


  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool);

}

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {

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

contract ERC827Caller {

  function makeCall(address _target, bytes _data) external payable returns (bool) {

    return _target.call.value(msg.value)(_data);
  }
}

contract ERC827Token is ERC827, StandardToken {

  ERC827Caller internal caller_;

  constructor() public {
    caller_ = new ERC827Caller();
  }

  function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool)
  {

    require(_spender != address(this));

    super.approve(_spender, _value);

    require(caller_.makeCall.value(msg.value)(_spender, _data));

    return true;
  }

  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    returns (bool)
  {

    require(_to != address(this));

    super.transfer(_to, _value);

    require(caller_.makeCall.value(msg.value)(_to, _data));
    return true;
  }

  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public payable returns (bool)
  {

    require(_to != address(this));

    super.transferFrom(_from, _to, _value);

    require(caller_.makeCall.value(msg.value)(_to, _data));
    return true;
  }

  function increaseApprovalAndCall(
    address _spender,
    uint _addedValue,
    bytes _data
  )
    public
    payable
    returns (bool)
  {

    require(_spender != address(this));

    super.increaseApproval(_spender, _addedValue);

    require(caller_.makeCall.value(msg.value)(_spender, _data));

    return true;
  }

  function decreaseApprovalAndCall(
    address _spender,
    uint _subtractedValue,
    bytes _data
  )
    public
    payable
    returns (bool)
  {

    require(_spender != address(this));

    super.decreaseApproval(_spender, _subtractedValue);

    require(caller_.makeCall.value(msg.value)(_spender, _data));

    return true;
  }

}

contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {

    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {

    require(msg.sender == owner);
    _;
  }

  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {

    totalSupply_ = totalSupply_.add(_amount);
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

contract EverGold is ERC827Token, MintableToken, AccessByGame {

  string public constant name = "Ever Gold";
  string public constant symbol = "EG";
  uint8 public constant decimals = 0;

  function mint(
    address _to,
    uint256 _amount
  )
    onlyAccessByGame
    canMint
    public
    returns (bool)
  {

    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }
  function transfer(address _to, uint256 _value)
    public
    whenNotPaused
    returns (bool)
  {

    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value)
    public
    whenNotPaused
    returns (bool)
  {

    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value)
    public
    whenNotPaused
    returns (bool)
  {

    return super.approve(_spender, _value);
  }

  function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
    public
    payable
    whenNotPaused
    returns (bool)
  {

    return super.approveAndCall(_spender, _value, _data);
  }

  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    whenNotPaused
    returns (bool)
  {

    return super.transferAndCall(_to, _value, _data);
  }

  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public
    payable
    whenNotPaused
    returns (bool)
  {

    return super.transferFromAndCall(_from, _to, _value, _data);
  }

  function increaseApprovalAndCall(
    address _spender,
    uint _addedValue,
    bytes _data
  )
    public
    payable
    whenNotPaused
    returns (bool)
  {

    return super.increaseApprovalAndCall(_spender, _addedValue, _data);
  }

  function decreaseApprovalAndCall(
    address _spender,
    uint _subtractedValue,
    bytes _data
  )
    public
    payable
    whenNotPaused
    returns (bool)
  {

    return super.decreaseApprovalAndCall(_spender, _subtractedValue, _data);
  }
}

contract ItemToken is AccessByGame {

  struct Item {
    bytes16 name;
    uint16 price;
    uint16 power;
    bool enabled;
  }

  EverGold internal goldToken;

  Item[] private items;

  uint8 public itemKindCount = 0;

  mapping (address => mapping (uint256 => uint256)) private ownedItems;

  event NewItem(bytes32 name, uint16 price, uint16 power);
  event UseItem(uint256 itemid, uint256 amount);

  constructor()
    public
  {
    addItem("None", 0, 0, false);
    addItem("Arrow", 10, 10, true);
    addItem("Tiger", 30, 20, true);
    addItem("Spear", 50, 30, true);
    addItem("Wood", 50, 20, true);
    addItem("Fire", 50, 20, true);
    addItem("Earth", 50, 20, true);
    addItem("Metal", 50, 20, true);
    addItem("Water", 50, 20, true);
  }

  function setGoldContract(address _goldTokenAddress)
    public
    onlyOwner
  {

    require(_goldTokenAddress != address(0));

    goldToken = EverGold(_goldTokenAddress);
  }

  function buy(address _to, uint256 _itemid, uint256 _amount)
    public
    onlyAccessByGame
    whenNotPaused
    returns (bool)
  {

    require(_amount > 0);
    require(_itemid > 0 && _itemid < itemKindCount);
    ownedItems[_to][_itemid] += _amount;

    return true;
  }

  function useItem(address _owner, uint256 _itemid, uint256 _amount)
    public
    onlyAccessByGame
    whenNotPaused
    returns (bool)
  {

    require(_amount > 0);
    require((_itemid > 0) && (_itemid < itemKindCount));
    require(_amount <= ownedItems[_owner][_itemid]);

    ownedItems[_owner][_itemid] -= _amount;

    emit UseItem(_itemid, _amount);

    return true;
  }

  function addItem(bytes16 _name, uint16 _price, uint16 _power, bool _enabled)
    public
    onlyOwner()
    returns (bool)
  {

    require(_name != 0x0);
    items.push(Item({
      name:_name,
      price: _price,
      power: _power,
      enabled: _enabled
      }));
    itemKindCount++;

    emit NewItem(_name, _price, _power);
    return true;
  }

  function setItemAvailable(uint256 _itemid, bool _enabled)
    public
    onlyOwner()
  {

    require(_itemid > 0 && _itemid < itemKindCount);

    items[_itemid].enabled = _enabled;
  }

  function getItemCounts()
    public
    view
    returns (uint256[])
  {

    uint256[] memory itemCounts = new uint256[](itemKindCount);
    for (uint256 i = 0; i < itemKindCount; i++) {
      itemCounts[i] = ownedItems[msg.sender][i];
    }
    return itemCounts;
  }

  function getItemCount(uint256 _itemid)
    public
    view
    returns (uint256)
  {

    require(_itemid > 0 && _itemid < itemKindCount);
    return ownedItems[msg.sender][_itemid];
  }

  function getItemKindCount()
    public
    view
    returns (uint256)
  {

    return itemKindCount;
  }

  function getItem(uint256 _itemid)
    public
    view
    returns (bytes16 name, uint16 price, uint16 power, bool enabled)
  {

    require(_itemid < itemKindCount);
    return (items[_itemid].name, items[_itemid].price, items[_itemid].power, items[_itemid].enabled);
  }

  function getPower(uint256 _itemid)
    public
    view
    returns (uint16 power)
  {

    require(_itemid < itemKindCount);
    return items[_itemid].power;
  }

  function getPrice(uint256 _itemid)
    public
    view
    returns (uint16)
  {

    require(_itemid < itemKindCount);
    return items[_itemid].price;
  }
}