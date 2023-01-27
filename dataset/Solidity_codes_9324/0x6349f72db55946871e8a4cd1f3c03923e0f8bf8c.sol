
pragma solidity ^0.4.24;


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





library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}










contract Claimable is Ownable {

  address public pendingOwner;

  modifier onlyPendingOwner() {

    require(msg.sender == pendingOwner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {

    pendingOwner = newOwner;
  }

  function claimOwnership() public onlyPendingOwner {

    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}



contract ClaimableEx is Claimable {

  function cancelOwnershipTransfer() onlyOwner public {

    pendingOwner = owner;
  }
}






contract AddressSet is Ownable {

  mapping(address => bool) exist;
  address[] elements;

  function add(address _addr) onlyOwner public returns (bool) {

    if (contains(_addr)) {
      return false;
    }

    exist[_addr] = true;
    elements.push(_addr);
    return true;
  }

  function contains(address _addr) public view returns (bool) {

    return exist[_addr];
  }

  function elementAt(uint256 _index) onlyOwner public view returns (address) {

    require(_index < elements.length);

    return elements[_index];
  }

  function getTheNumberOfElements() onlyOwner public view returns (uint256) {

    return elements.length;
  }
}



contract BalanceSheet is ClaimableEx {

  using SafeMath for uint256;

  mapping (address => uint256) private balances;

  AddressSet private holderSet;

  constructor() public {
    holderSet = new AddressSet();
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

  function addBalance(address _addr, uint256 _value) public onlyOwner {

    balances[_addr] = balances[_addr].add(_value);

    _checkHolderSet(_addr);
  }

  function subBalance(address _addr, uint256 _value) public onlyOwner {

    balances[_addr] = balances[_addr].sub(_value);
  }

  function setBalance(address _addr, uint256 _value) public onlyOwner {

    balances[_addr] = _value;

    _checkHolderSet(_addr);
  }

  function setBalanceBatch(
    address[] _addrs,
    uint256[] _values
  )
    public
    onlyOwner
  {

    uint256 _count = _addrs.length;
    require(_count == _values.length);

    for(uint256 _i = 0; _i < _count; _i++) {
      setBalance(_addrs[_i], _values[_i]);
    }
  }

  function getTheNumberOfHolders() public view returns (uint256) {

    return holderSet.getTheNumberOfElements();
  }

  function getHolder(uint256 _index) public view returns (address) {

    return holderSet.elementAt(_index);
  }

  function _checkHolderSet(address _addr) internal {

    if (!holderSet.contains(_addr)) {
      holderSet.add(_addr);
    }
  }
}