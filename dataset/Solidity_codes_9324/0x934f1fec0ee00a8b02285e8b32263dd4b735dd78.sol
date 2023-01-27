
pragma solidity 0.4.15;

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

  function pause() onlyOwner whenNotPaused returns (bool) {

    paused = true;
    Pause();
    return true;
  }

  function unpause() onlyOwner whenPaused returns (bool) {

    paused = false;
    Unpause();
    return true;
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



contract PausableToken is StandardToken, Pausable {


  function transfer(address _to, uint _value) whenNotPaused returns (bool) {

    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenNotPaused returns (bool) {

    return super.transferFrom(_from, _to, _value);
  }
}


contract PallyCoin is PausableToken {

   using SafeMath for uint256;

   string public constant name = 'PallyCoin';

   string public constant symbol = 'PAL';

   uint8 public constant decimals = 18;

   uint256 public constant totalSupply = 100e24; // 100M tokens with 18 decimals

   uint256 public tokensDistributedPresale = 0;

   uint256 public tokensDistributedCrowdsale = 0;

   address public crowdsale;

   modifier onlyCrowdsale() {

      require(msg.sender == crowdsale);
      _;
   }

   event RefundedTokens(address indexed user, uint256 tokens);

   function PallyCoin() {

      balances[msg.sender] = 40e24; // 40M tokens wei
   }

   function setCrowdsaleAddress(address _crowdsale) external onlyOwner whenNotPaused {

      require(_crowdsale != address(0));

      crowdsale = _crowdsale;
   }

   function distributePresaleTokens(address _buyer, uint tokens) external onlyOwner whenNotPaused {

      require(_buyer != address(0));
      require(tokens > 0 && tokens <= 10e24);

      require(tokensDistributedPresale < 10e24);

      tokensDistributedPresale = tokensDistributedPresale.add(tokens);
      balances[_buyer] = balances[_buyer].add(tokens);
   }

   function distributeICOTokens(address _buyer, uint tokens) external onlyCrowdsale whenNotPaused {

      require(_buyer != address(0));
      require(tokens > 0);

      require(tokensDistributedCrowdsale < 50e24);

      tokensDistributedCrowdsale = tokensDistributedCrowdsale.add(tokens);
      balances[_buyer] = balances[_buyer].add(tokens);
   }

   function refundTokens(address _buyer, uint256 tokens) external onlyCrowdsale whenNotPaused {

      require(_buyer != address(0));
      require(tokens > 0);
      require(balances[_buyer] >= tokens);

      balances[_buyer] = balances[_buyer].sub(tokens);
      RefundedTokens(_buyer, tokens);
   }
}


contract RefundVault is Ownable {

  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  address public wallet;
  address private crowdsale;
  State public state;
  uint256 public weiBalance;

  mapping (address => uint256) public deposited;

  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);
  event LogDeposited(address indexed buyer, uint256 amount);
  event VaultClosed();

  modifier onlyCrowdsale() {

      require(msg.sender == crowdsale);
      _;
  }

  function RefundVault(address _wallet) {

    require(_wallet != 0x0);

    wallet = _wallet;
    crowdsale = msg.sender;
    state = State.Active;
  }

  function deposit(address investor) external payable onlyCrowdsale {

    require(state == State.Active);

    weiBalance = weiBalance.add(msg.value);
    deposited[investor] = deposited[investor].add(msg.value);
    LogDeposited(msg.sender, msg.value);
  }

  function close() external onlyCrowdsale {

    require(state == State.Active);

    state = State.Closed;
    wallet.transfer(weiBalance);
    VaultClosed();
  }

  function enableRefunds() external onlyCrowdsale {

    require(state == State.Active);

    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) external onlyCrowdsale {

    require(state == State.Refunding);

    uint256 depositedValue = deposited[investor];
    weiBalance = weiBalance.sub(depositedValue);
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}



contract Crowdsale is Pausable {

   using SafeMath for uint256;

   PallyCoin public token;

   RefundVault public vault;

   uint256 public startTime = 1508065200;

   uint256 public endTime = 1510570800;

   address public wallet;

   uint256 public rate;

   uint256 public rateTier2;

   uint256 public rateTier3;

   uint256 public rateTier4;

   uint256 public weiRaised = 0;

   uint256 public tokensRaised = 0;

   uint256 public constant maxTokensRaised = 50e24;

   uint256 public constant minPurchase = 100 finney; // 0.1 ether

   uint256 public constant maxPurchase = 1000 ether;

   uint256 public constant minimumGoal = 7.5e24;

   bool public isRefunding = false;

   bool public isEnded = false;

   mapping(address => uint256) public crowdsaleBalances;

   mapping(address => uint256) public tokensBought;

   event TokenPurchase(address indexed buyer, uint256 value, uint256 amountOfTokens);

   event Finalized();

   function Crowdsale(
      address _wallet,
      address _tokenAddress,
      uint256 _startTime,
      uint256 _endTime
   ) {

      require(_wallet != address(0));
      require(_tokenAddress != address(0));

      if(_startTime > 0 && _endTime > 0)
         require(_startTime < _endTime);

      wallet = _wallet;
      token = PallyCoin(_tokenAddress);
      vault = new RefundVault(_wallet);

      if(_startTime > 0)
         startTime = _startTime;

      if(_endTime > 0)
         endTime = _endTime;
   }

   function () payable {
      buyTokens();
   }

   function buyTokens() public payable whenNotPaused {

      require(validPurchase());

      uint256 tokens = 0;
      uint256 amountPaid = calculateExcessBalance();

      if(tokensRaised < 12.5e24) {

         tokens = amountPaid.mul(rate);

         if(tokensRaised.add(tokens) > 12.5e24)
            tokens = calculateExcessTokens(amountPaid, 12.5e24, 1, rate);
      } else if(tokensRaised >= 12.5e24 && tokensRaised < 25e24) {

         tokens = amountPaid.mul(rateTier2);

         if(tokensRaised.add(tokens) > 25e24)
            tokens = calculateExcessTokens(amountPaid, 25e24, 2, rateTier2);
      } else if(tokensRaised >= 25e24 && tokensRaised < 37.5e24) {

         tokens = amountPaid.mul(rateTier3);

         if(tokensRaised.add(tokens) > 37.5e24)
            tokens = calculateExcessTokens(amountPaid, 37.5e24, 3, rateTier3);
      } else if(tokensRaised >= 37.5e24) {

         tokens = amountPaid.mul(rateTier4);
      }

      weiRaised = weiRaised.add(amountPaid);
      tokensRaised = tokensRaised.add(tokens);
      token.distributeICOTokens(msg.sender, tokens);

      tokensBought[msg.sender] = tokensBought[msg.sender].add(tokens);
      TokenPurchase(msg.sender, amountPaid, tokens);

      forwardFunds(amountPaid);
   }

   function forwardFunds(uint256 amountPaid) internal whenNotPaused {

      if(goalReached()) {
         wallet.transfer(amountPaid);
      } else {
         vault.deposit.value(amountPaid)(msg.sender);
      }

      checkCompletedCrowdsale();
   }

   function calculateExcessBalance() internal whenNotPaused returns(uint256) {

      uint256 amountPaid = msg.value;
      uint256 differenceWei = 0;
      uint256 exceedingBalance = 0;

      if(tokensRaised >= 37.5e24) {
         uint256 addedTokens = tokensRaised.add(amountPaid.mul(rateTier4));

         if(addedTokens > maxTokensRaised) {

            uint256 difference = addedTokens.sub(maxTokensRaised);
            differenceWei = difference.div(rateTier4);

            amountPaid = amountPaid.sub(differenceWei);
         }
      }

      uint256 addedBalance = crowdsaleBalances[msg.sender].add(amountPaid);

      if(addedBalance <= maxPurchase) {
         crowdsaleBalances[msg.sender] = crowdsaleBalances[msg.sender].add(amountPaid);
      } else {

         exceedingBalance = addedBalance.sub(maxPurchase);
         amountPaid = msg.value.sub(exceedingBalance);

         crowdsaleBalances[msg.sender] = crowdsaleBalances[msg.sender].add(amountPaid);
      }

      if(differenceWei > 0)
         msg.sender.transfer(differenceWei);

      if(exceedingBalance > 0) {

         msg.sender.transfer(exceedingBalance);
      }

      return amountPaid;
   }

   function setTierRates(uint256 tier1, uint256 tier2, uint256 tier3, uint256 tier4)
      external onlyOwner whenNotPaused
   {

      require(tier1 > 0 && tier2 > 0 && tier3 > 0 && tier4 > 0);

      rate = tier1;
      rateTier2 = tier2;
      rateTier3 = tier3;
      rateTier4 = tier4;
   }

   function checkCompletedCrowdsale() public whenNotPaused {

      if(!isEnded) {
         if(hasEnded() && !goalReached()){
            vault.enableRefunds();

            isRefunding = true;
            isEnded = true;
            Finalized();
         } else if(hasEnded() && goalReached()) {
            vault.close();

            isEnded = true;
            Finalized();
         }
      }
   }

   function claimRefund() public whenNotPaused {

     require(hasEnded() && !goalReached() && isRefunding);

     vault.refund(msg.sender);
     token.refundTokens(msg.sender, tokensBought[msg.sender]);
   }

   function calculateExcessTokens(
      uint256 amount,
      uint256 tokensThisTier,
      uint256 tierSelected,
      uint256 _rate
   ) public constant returns(uint256 totalTokens) {

      require(amount > 0 && tokensThisTier > 0 && _rate > 0);
      require(tierSelected >= 1 && tierSelected <= 4);

      uint weiThisTier = tokensThisTier.sub(tokensRaised).div(_rate);
      uint weiNextTier = amount.sub(weiThisTier);
      uint tokensNextTier = 0;

      if(tierSelected != 4)
         tokensNextTier = calculateTokensTier(weiNextTier, tierSelected.add(1));
      else
         msg.sender.transfer(weiNextTier);

      totalTokens = tokensThisTier.sub(tokensRaised).add(tokensNextTier);
   }

   function calculateTokensTier(uint256 weiPaid, uint256 tierSelected)
        internal constant returns(uint256 calculatedTokens)
   {

      require(weiPaid > 0);
      require(tierSelected >= 1 && tierSelected <= 4);

      if(tierSelected == 1)
         calculatedTokens = weiPaid.mul(rate);
      else if(tierSelected == 2)
         calculatedTokens = weiPaid.mul(rateTier2);
      else if(tierSelected == 3)
         calculatedTokens = weiPaid.mul(rateTier3);
      else
         calculatedTokens = weiPaid.mul(rateTier4);
   }


   function validPurchase() internal constant returns(bool) {

      bool withinPeriod = now >= startTime && now <= endTime;
      bool nonZeroPurchase = msg.value > 0;
      bool withinTokenLimit = tokensRaised < maxTokensRaised;
      bool minimumPurchase = msg.value >= minPurchase;
      bool hasBalanceAvailable = crowdsaleBalances[msg.sender] < maxPurchase;

      return withinPeriod && nonZeroPurchase && withinTokenLimit && minimumPurchase && hasBalanceAvailable;
   }

   function goalReached() public constant returns(bool) {

      return tokensRaised >= minimumGoal;
   }

   function hasEnded() public constant returns(bool) {

      return now > endTime || tokensRaised >= maxTokensRaised;
   }
}