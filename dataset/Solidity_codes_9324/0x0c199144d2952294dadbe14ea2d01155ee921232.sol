
pragma solidity >=0.4.25 <0.6.0;


contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);


}

contract Ownable {

  address public owner;

    address public creator;

    modifier onlyTokenOwner() {

        require(msg.sender == creator || msg.sender == owner);
        _;
    }


  constructor() public {
    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyTokenOwner public {

    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

  function transferCreator(address newCreator) onlyTokenOwner public {

    if (newCreator != address(0)) {
      creator = newCreator;
    }
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

  modifier whenPaused {

    require(paused);
    _;
  }

  function pause() onlyTokenOwner whenNotPaused public returns (bool) {

    paused = true;
    emit Pause();
    return true;
  }

  function unpause() onlyTokenOwner whenPaused public returns (bool) {

    paused = false;
    emit Unpause();
    return true;
  }
}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public view returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {

    uint value = _value;
    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[_to] = balances[_to].add(value);
    emit Transfer(msg.sender, _to, value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {

    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    uint _allowance = allowed[_from][msg.sender];
    uint value = _value;
    balances[_to] = balances[_to].add(value);
    balances[_from] = balances[_from].sub(value);
    allowed[_from][msg.sender] = _allowance.sub(value);
    emit Transfer(_from, _to, value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    uint value = _value;
    require((value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = value;
    emit Approval(msg.sender, _spender, value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

    return allowed[_owner][_spender];
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

  function mint(address _to, uint256 _amount) onlyTokenOwner canMint public returns (bool) {

    uint amount = _amount;
    totalSupply = totalSupply.add(amount);
    balances[_to] = balances[_to].add(amount);
    emit Mint(_to, amount);
    return true;
  }

  function finishMinting() onlyTokenOwner public returns (bool) {

    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

contract PausableToken is StandardToken, Pausable {


  function transfer(address _to, uint _value) whenNotPaused public returns (bool) {

    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenNotPaused public returns (bool) {

    return super.transferFrom(_from, _to, _value);
  }
}

contract BurnableToken is StandardToken {


    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {

        require(_value > 0);
        uint value = _value;
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Burn(msg.sender, value);
    }

}

contract ERCDetailed is BurnableToken, PausableToken, MintableToken {


    string private _name;
    string private _symbol;
    uint256 private _decimals;

    constructor (string memory name, string memory symbol, uint256 decimals, address _creator) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        creator = _creator;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint256) {

        return _decimals;
    }

    function burn(uint256 _value) whenNotPaused public {

        super.burn(_value);
    }
}

contract TokenFactory is Ownable {

    address[] public deployedTokens;
    ERCDetailed public newToken;
    mapping (address => address) public myTokens;

    uint public tokenFee = 0.01 ether;
    function setTokenFee(uint _fee) external onlyOwner {

      tokenFee = _fee;
}

    function createToken(string _name, string _symbol, uint256 _decimals) external payable returns (ERCDetailed) {

        require(msg.value == tokenFee);
        newToken = new ERCDetailed(_name, _symbol, _decimals, msg.sender);
        deployedTokens.push(address(newToken));
        myTokens[address(newToken)] = msg.sender;
        return(newToken);
    }

    function getDeployedTokens() public view returns (address[] memory) {

        return deployedTokens;
    }

      function withdraw() external onlyOwner {

      address _owner = address(uint160(owner));
      _owner.transfer(address(this).balance);
      }
}