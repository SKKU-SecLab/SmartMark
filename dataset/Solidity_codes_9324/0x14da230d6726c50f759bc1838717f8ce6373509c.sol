
pragma solidity ^0.4.23;


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


contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor() public {
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


interface IFreezableToken {

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Freeze(address indexed owner, address indexed user, bool status);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function increaseApproval(address spender, uint256 addedValue) external returns (bool);

    function decreaseApproval(address spender, uint256 subtractedValue) external returns (bool);

    function freeze(address user) external returns (bool);

    function unfreeze(address user) external returns (bool);

    function freezing(address user) external view returns (bool);

}


contract FreezableToken is Ownable, IFreezableToken {

    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => bool) frozen;

    modifier unfreezing(address user) {

        require(!frozen[user], "Cannot transfer from a freezing address");
        _;
    }

    uint256 internal _totalSupply;

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function transfer(address _to, uint256 _value) public unfreezing(msg.sender) returns (bool) {

        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) public unfreezing(_from) returns (bool) {

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

        require(_spender != address(0));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {

        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {

        require(_spender != address(0));

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {

        require(_spender != address(0));

        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function freeze(address _user) public onlyOwner returns (bool) {

        frozen[_user] = true;
        emit Freeze(msg.sender, _user, true);
        return true;
    }

    function unfreeze(address _user) public onlyOwner returns (bool) {

        frozen[_user] = false;
        emit Freeze(msg.sender, _user, false);
        return false;
    }

    function freezing(address _user) public view returns (bool) {

        return frozen[_user];
    }
}


interface IKAT {

  function name() external view returns (string);

  function symbol() external view returns (string);

  function decimals() external view returns (uint256);

}


contract KAT is FreezableToken, IKAT {

  
  string private _name;
  string private _symbol;
  uint256 private _decimals;

  constructor() public {
    _name = "Kambria Token";
    _symbol = "KAT";
    _decimals = 18;
    _totalSupply = 5000000000 * 10 ** _decimals;

    balances[msg.sender] = _totalSupply; // coinbase
  }

  function name() public view returns (string) {

    return _name;
  }

  function symbol() public view returns (string) {

    return _symbol;
  }

  function decimals() public view returns (uint256) {

    return _decimals;
  }
}