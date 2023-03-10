
pragma solidity ^0.4.11;



library SafeMath {

  function mul(uint256 a, uint256 b) internal returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {

  address public owner;


  function Ownable() {

    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner {

    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract ERC20Basic {

  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);

  function transfer(address to, uint256 value) returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) returns (bool) {

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {

    return balances[_owner];
  }

}


contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) returns (bool);

  function approve(address spender, uint256 value) returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) allowed;


  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {

    var _allowance = allowed[_from][msg.sender];


    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) returns (bool) {


    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

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

  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {

    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  function finishMinting() onlyOwner returns (bool) {

    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract SuperOneToken is StandardToken, Ownable {

    using SafeMath for uint256;

    string  public constant name = "Super One Token";
    string  public constant symbol = "SOT";
    uint8   public constant decimals = 18;

    uint256 public startDate;
    uint256 public endDate;

    uint256 public saleCap;

    address public wallet;

    uint256 public weiRaised;

    mapping(address => bytes32) public sotpreUserIDs;

    event TokenPurchase(address indexed purchaser, uint256 value,
                        uint256 amount);
    event PreICOTokenPushed(address indexed buyer, uint256 amount);
    event UserIDChanged(address owner, bytes32 user_id);

    modifier uninitialized() {

        require(wallet == 0x0);
        _;
    }

    function SuperOneToken() {

    }

    function initialize(address _wallet, uint256 _start, uint256 _end,
                        uint256 _saleCap, uint256 _totalSupply)
                        onlyOwner uninitialized {

        require(_start >= getCurrentTimestamp());
        require(_start < _end);
        require(_wallet != 0x0);
        require(_totalSupply > _saleCap);

        startDate = _start;
        endDate = _end;
        saleCap = _saleCap;
        wallet = _wallet;
        totalSupply = _totalSupply;

        balances[wallet] = _totalSupply.sub(saleCap);
        balances[0x1] = saleCap;
    }

    function supply() internal returns (uint256) {

        return balances[0x1];
    }

    function getCurrentTimestamp() internal returns (uint256) {

        return now;
    }

    function getRateAt(uint256 at) constant returns (uint256) {

        if (at < startDate) {
            return 0;        
        } else {
            return 4000; //[email??protected] 0.05
        }
    }

    function () payable {
        buyTokens(msg.sender, msg.value);
    }

    function push(address buyer, uint256 amount) onlyOwner {

        require(balances[wallet] >= amount);

        uint256 actualRate = 4000;  // pre-ICO has also fixed rate of 4000
        uint256 weiAmount = amount.div(actualRate);
        uint256 updatedWeiRaised = weiRaised.add(weiAmount);

        balances[wallet] = balances[wallet].sub(amount);
        balances[buyer] = balances[buyer].add(amount);
        PreICOTokenPushed(buyer, amount);

        weiRaised = updatedWeiRaised;
    }

    function buyTokens(address sender, uint256 value) internal {

        require(saleActive());
        require(value >= 1 ether);

        uint256 weiAmount = value;
        uint256 updatedWeiRaised = weiRaised.add(weiAmount);

        uint256 actualRate = getRateAt(getCurrentTimestamp());
        uint256 amount = weiAmount.mul(actualRate);
        

        require(supply() >= amount);

        balances[0x1] = balances[0x1].sub(amount);
        balances[sender] = balances[sender].add(amount);
        TokenPurchase(sender, weiAmount, amount);

        weiRaised = updatedWeiRaised;

        wallet.transfer(msg.value);
    }

    function finalize() onlyOwner {

        require(!saleActive());

        balances[wallet] = balances[wallet].add(balances[0x1]);
        balances[0x1] = 0;
    }

    function saleActive() public constant returns (bool) {

        return (getCurrentTimestamp() >= startDate &&
                getCurrentTimestamp() < endDate && supply() > 0);
    }

    function setUserID(bytes32 user_id) {

        sotpreUserIDs[msg.sender] = user_id;
        UserIDChanged(msg.sender, user_id);
    }
    
     function destroyToken() onlyOwner {

          require(!saleActive());
          
          balances[wallet] = balances[wallet].add(balances[0x1]);
          balances[0x1] = 0;
          selfdestruct(wallet);
        
    }
}