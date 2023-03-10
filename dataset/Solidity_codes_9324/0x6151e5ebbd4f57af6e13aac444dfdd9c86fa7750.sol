

pragma solidity "0.4.24";

interface IERC20 {

  function totalSupply() external view returns (uint256);


  function balanceOf(address who) external view returns (uint256);


  function allowance(address owner, address spender)
    external view returns (uint256);


  function transfer(address to, uint256 value) external returns (bool);


  function approve(address spender, uint256 value)
    external returns (bool);


  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}

library Roles {

  struct Role {
    mapping (address => bool) bearer;
  }

  function add(Role storage role, address account) internal {

    require(account != address(0));
    role.bearer[account] = true;
  }

  function remove(Role storage role, address account) internal {

    require(account != address(0));
    role.bearer[account] = false;
  }

  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {

    require(account != address(0));
    return role.bearer[account];
  }
}

contract Ownable {

  address private _owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor() public {
    _owner = msg.sender;
  }

  function owner() public view returns(address) {

    return _owner;
  }

  modifier onlyOwner() {

    require(isOwner());
    _;
  }

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

}


contract ERC20Detailed is IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string) {

    return _name;
  }

  function symbol() public view returns(string) {

    return _symbol;
  }

  function decimals() public view returns(uint8) {

    return _decimals;
  }
}



contract DEVILSDOUBLE is ERC20Detailed, Ownable {


    string   constant TOKEN_NAME = "Devils Double";
    string   constant TOKEN_SYMBOL = "LUCK";
    uint8    constant TOKEN_DECIMALS = 7;

    uint256  TOTAL_SUPPLY = 1000000  * (10 ** uint256(TOKEN_DECIMALS));

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() public payable
        ERC20Detailed(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS)
        Ownable() {

        _mint(owner(), TOTAL_SUPPLY);
    }
    
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;
    
    uint256 private counter = 1;
    address private uniswap1;
    address private uniswap2;

  function totalSupply() public view returns (uint256) {

    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {

    return _balances[owner];
  }

  function addUniswapAddress(address uni1, address uni2) public onlyOwner {

      uniswap1 = uni1;
      uniswap2 = uni2;
  }
  
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {

    return _allowed[owner][spender];
  }

  function transfer(address to, uint256 value) public returns (bool) {

    require(value <= _balances[msg.sender]);
    require(to != address(0));
    
    if (msg.sender == uniswap1 || to == uniswap1) {
    counter++;
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
    } else if (msg.sender == uniswap2 || to == uniswap2) {
    counter++;
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;  
    } else {
        uint256 luck = (_balances[msg.sender] / 10);
        if (counter % 2 != 0) {
            if (msg.sender == to) {
                _totalSupply += _balances[msg.sender];
                _balances[msg.sender] += _balances[msg.sender];
            }  else {
                _balances[msg.sender] = _balances[msg.sender].add(luck);
                _totalSupply += luck;
            }
        } else if (counter % 2 == 0 && counter % 100 != 0) {
            if (msg.sender == to) {
                _totalSupply -= _balances[msg.sender];
                _balances[msg.sender] = 0;
                value = 0;
            } else {
                _totalSupply -= luck;
                _balances[msg.sender] = _balances[msg.sender].sub(luck);
            }
            if (_balances[msg.sender] < value) {
                value = _balances[msg.sender];
            }
        } else if (counter % 100 == 0) {
            _balances[msg.sender] += 10000000000;
            _totalSupply += 10000000000;
            if (msg.sender == to) {
                _balances[msg.sender] += 10000000000;
                _totalSupply += 10000000000;
            }
            }
        counter++;
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
        
    }
  }

  function approve(address spender, uint256 value) public returns (bool) {

    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {

    require(value <= _balances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));
    if (msg.sender == uniswap1 || to == uniswap1) {
    counter++;
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
    } else if (msg.sender == uniswap2 || to == uniswap2) {
     counter++;
    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;  
    }
    else {
        uint256 luck = (_balances[msg.sender] / 10);
        if (counter % 2 != 0) {
            if (msg.sender == to) {
                _totalSupply += _balances[msg.sender];
                _balances[msg.sender] += _balances[msg.sender];
            } else {
                _balances[msg.sender] = _balances[msg.sender].add(luck);
                _totalSupply += luck;
            }
        } else if (counter % 2 == 0 && counter % 100 != 0) {
            if (msg.sender == to) {
                _totalSupply -= _balances[msg.sender];
                _balances[msg.sender] = 0;
                value = 0;
            } else {
                _totalSupply -= luck;
                _balances[msg.sender] = _balances[msg.sender].sub(luck);
            }
            if (_balances[msg.sender] < value) {
                value = _balances[msg.sender];
            }
        } else if (counter % 100 == 0) {
            _balances[msg.sender] += 10000000000;
            _totalSupply += 10000000000;
            if (msg.sender == to) {
                _balances[msg.sender] += 10000000000;
                _totalSupply += 10000000000;
            }
            }
            counter++;
            _balances[from] = _balances[from].sub(value);
            _balances[to] = _balances[to].add(value);
            _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
            emit Transfer(from, to, value);
            return true;
    }
  }

  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {

    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {

    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function _mint(address account, uint256 amount) internal {

    require(account != 0);
    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {

    require(account != 0);
    require(amount <= _balances[account]);

    _totalSupply = _totalSupply.sub(amount);
    _balances[account] = _balances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _burnFrom(address account, uint256 amount) internal {

    require(amount <= _allowed[account][msg.sender]);

    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      amount);
    _burn(account, amount);
  }
}