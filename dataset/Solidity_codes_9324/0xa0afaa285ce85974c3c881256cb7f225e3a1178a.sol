



pragma solidity ^0.6.0;


interface IERC20 {


  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint256);

  function totalSupply() external view returns (uint256);

  function balanceOf(address _owner) external view returns (uint256);


  function transfer(address _to, uint256 _value) external returns (bool);


  function allowance(address _owner, address _spender)
    external view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    external returns (bool);


  function approve(address _spender, uint256 _value) external returns (bool);


  function increaseApproval(address _spender, uint256 _addedValue)
    external returns (bool);


  function decreaseApproval(address _spender, uint256 _subtractedValue)
    external returns (bool);

}


pragma solidity ^0.6.0;


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


pragma solidity ^0.6.0;




contract TokenERC20 is IERC20 {

  using SafeMath for uint256;

  string internal name_;
  string internal symbol_;
  uint256 internal decimals_;

  uint256 internal totalSupply_;
  mapping(address => uint256) internal balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _decimals,
    address _initialAccount,
    uint256 _initialSupply
  ) public {
    name_ = _name;
    symbol_ = _symbol;
    decimals_ = _decimals;
    totalSupply_ = _initialSupply;
    balances[_initialAccount] = _initialSupply;

    emit Transfer(address(0), _initialAccount, _initialSupply);
  }

  function name() external override view returns (string memory) {

    return name_;
  }

  function symbol() external override view returns (string memory) {

    return symbol_;
  }

  function decimals() external override view returns (uint256) {

    return decimals_;
  }

  function totalSupply() external override view returns (uint256) {

    return totalSupply_;
  }

  function balanceOf(address _owner) external override view returns (uint256) {

    return balances[_owner];
  }

  function allowance(address _owner, address _spender)
    external override view returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function transfer(address _to, uint256 _value) external override returns (bool) {

    require(_to != address(0), "TE01");
    require(_value <= balances[msg.sender], "TE02");

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value)
    external override returns (bool)
  {

    require(_to != address(0), "TE01");
    require(_value <= balances[_from], "TE02");
    require(_value <= allowed[_from][msg.sender], "TE03");

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) external override returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(address _spender, uint _addedValue)
    external override returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue)
    external override returns (bool)
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


pragma solidity ^0.6.0;



abstract contract IWrappedERC20 is IERC20 {

  function base() public view virtual returns (IERC20);

  function deposit(uint256 _value) public virtual returns (bool);
  function depositTo(address _to, uint256 _value) public virtual returns (bool);

  function withdraw(uint256 _value) public virtual returns (bool);
  function withdrawFrom(address _from, address _to, uint256 _value) public virtual returns (bool);

  event Deposit(address indexed _address, uint256 value);
  event Withdrawal(address indexed _address, uint256 value);
}


pragma solidity ^0.6.0;




contract WrappedERC20 is TokenERC20, IWrappedERC20 {


  IERC20 internal base_;
  uint256 internal ratio_;

  constructor(
    string memory _name,
    string memory _symbol,
    uint256 _decimals,
    IERC20 _base
  ) public
    TokenERC20(_name, _symbol, _decimals, address(0), 0)
  {
    ratio_ = 10 ** _decimals.sub(_base.decimals());
    base_ = _base;
  }

  function base() public view override returns (IERC20) {

    return base_;
  }

  function deposit(uint256 _value) public override returns (bool) {

    return depositTo(msg.sender, _value);
  }

  function depositTo(address _to, uint256 _value) public override returns (bool) {

    require(_to != address(0), "WE01");
    require(base_.transferFrom(msg.sender, address(this), _value), "WE02");

    uint256 wrappedValue = _value.mul(ratio_);
    balances[_to] = balances[_to].add(wrappedValue);
    totalSupply_ = totalSupply_.add(wrappedValue);
    emit Transfer(address(0), _to, wrappedValue);
    return true;
  }

  function withdraw(uint256 _value) public override returns (bool) {

    return withdrawFrom(msg.sender, msg.sender, _value);
  }

  function withdrawFrom(address _from, address _to, uint256 _value) public override returns (bool) {

    require(_to != address(0), "WE01");
    uint256 wrappedValue = _value.mul(ratio_);
    require(wrappedValue <= balances[_from], "WE03");

    if (_from != msg.sender) {
      require(wrappedValue <= allowed[_from][msg.sender], "WE04");
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(wrappedValue);
    }

    balances[_from] = balances[_from].sub(wrappedValue);
    totalSupply_ = totalSupply_.sub(wrappedValue);
    emit Transfer(_from, address(0), wrappedValue);

    require(base_.transfer(_to, _value), "WE05");
    return true;
  }
}