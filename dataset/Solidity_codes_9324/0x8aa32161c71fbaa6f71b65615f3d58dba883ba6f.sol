
pragma solidity ^0.4.11;

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

contract ERC20Basic {

  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);

  function transfer(address to, uint256 value) returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) returns (bool);

  function approve(address spender, uint256 value) returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract EstateCoin is MintableToken {

    
    string public constant name = "EstateCoin";
    
    string public constant symbol = "ESC";
    
    uint32 public constant decimals = 2;
    
    uint256 public maxTokens = 12100000000000000000000000;

  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {

    if (totalSupply.add(_amount) > maxTokens) {
        throw;
    }

    return super.mint(_to, _amount);
  }
}

contract RefundVault is Ownable {

  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) {

    require(_wallet != 0x0);
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {

    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {

    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {

    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {

    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}

contract ESCCrowdsale is Ownable {

  using SafeMath for uint256;

  MintableToken public token;

  uint256 public startTime;
  uint256 public endTime;

  address public wallet;

  uint256 public rate;

  uint256 public weiRaised;
  
  uint256 public tokenSold = 0;
  
  uint256 public cap;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  event TokenBonus(address indexed purchaser, address indexed beneficiary, uint256 amount);

  bool public isFinalized = false;

  event Finalized();

  uint256 public goal;

  RefundVault public vault;

  function ESCCrowdsale() {

    startTime = 1507204800;//1507204800 //5rd October 2017 12:00:00 GMT
    endTime = 1507982400; //14th October 2017 12:00:00 GMT
    rate = 250; //250ESC = 1ETH
    wallet = msg.sender;
    cap = 42550000000000000000000;
    vault = new RefundVault(wallet);
    goal = 2950000000000000000000; // Minimal goal is 2950ETH = 4400ETH - 1450ETH(funding on Waves Platform)

    token = createTokenContract();
  }

  function createTokenContract() internal returns (MintableToken) {

    return EstateCoin(0xAb519Ef511ee029adC74a469d1ed44955E9d5Cdf);
  }

  function () payable {
    buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) public payable {

    require(beneficiary != 0x0);
    require(validPurchase());

    if (weiRaised.add(msg.value) > cap) {
        throw;
    }

    uint256 weiAmount = msg.value;

    uint256 tokens = weiAmount.mul(rate);
    
    if (token.mint(beneficiary, tokens)) {
        weiRaised = weiRaised.add(weiAmount);

        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    
        forwardFunds();
    
        tokenSold = tokenSold.add(tokens);
        uint256 bonus = 0;
        if (now < 1507291200) {
            bonus = tokens.div(20); //5%
        } else if (now < 1507377600) {
            bonus = tokens.div(25); //4%
        } else if (now < 1507464000) {
            bonus = tokens.div(33); //3%
        } else if (now < 1507550400) {
            bonus = tokens.div(50); //2%
        } else if (now < 1507636800) {
            bonus = tokens.div(100); //1%
        }
        
        if (bonus > 0) {
            token.mint(beneficiary, bonus);
            TokenBonus(msg.sender, beneficiary, bonus);
        }
    }
  }
    
  function transferTokens(address _to, uint256 _amount) onlyOwner public returns (bool) {

    require(!isFinalized);
    require(!hasEnded());
    require(_to != 0x0);
    require(_amount > 0);
    
    token.mint(_to, _amount);
    tokenSold += _amount;
    
    return true;
  }

  function forwardFunds() internal {

    vault.deposit.value(msg.value)(msg.sender);
  }

  function validPurchase() internal constant returns (bool) {

    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  function hasEnded() public constant returns (bool) {

    bool capReached = weiRaised >= cap;
    return (now > endTime) || capReached;
  }
    
  function finalize() onlyOwner public {

    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }
  
  function claimRefund() public {

    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  function finalization() internal {

    if (goalReached()) {
      token.mint(wallet, tokenSold.div(10)); //10% for owners, bounty, promo...
      vault.close();
    } else {
      vault.enableRefunds();
    }
  }

  function goalReached() public constant returns (bool) {

    return weiRaised >= goal;
  }

}