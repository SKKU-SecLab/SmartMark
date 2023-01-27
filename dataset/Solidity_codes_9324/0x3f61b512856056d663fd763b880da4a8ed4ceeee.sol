
pragma solidity ^0.4.15;


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


contract ERC20Basic {

  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

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


pragma solidity ^0.4.15;





contract TokenTimelock is Ownable {

  using SafeERC20 for ERC20Basic;

  ERC20Basic public token;

  address public beneficiary;

  uint256 public releaseTime;

  bool public kycValid = false;

  function TokenTimelock(ERC20Basic _token, address _beneficiary, uint256 _releaseTime) public {

    require(_releaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  function release() public {

    require(now >= releaseTime);
    require(kycValid);

    uint256 amount = token.balanceOf(this);
    require(amount > 0);

    token.safeTransfer(beneficiary, amount);
  }

  function setValidKYC(bool _valid) public onlyOwner {

    kycValid = _valid;
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


contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {

    return balances[_owner];
  }

}


contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];


    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

    return allowed[_owner][_spender];
  }

  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {

    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner public returns (bool) {

    mintingFinished = true;
    MintFinished();
    return true;
  }
}


contract TutellusToken is MintableToken {

   string public name = "Tutellus";
   string public symbol = "TUT";
   uint8 public decimals = 18;
}


contract Crowdsale {

  using SafeMath for uint256;

  MintableToken public token;

  uint256 public startTime;
  uint256 public endTime;

  address public wallet;

  uint256 public rate;

  uint256 public weiRaised;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {

    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  function createTokenContract() internal returns (MintableToken) {

    return new MintableToken();
  }


  function () payable {
    buyTokens(msg.sender);
  }

  function buyTokens(address beneficiary) public payable {

    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    uint256 tokens = weiAmount.mul(rate);

    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  function forwardFunds() internal {

    wallet.transfer(msg.value);
  }

  function validPurchase() internal constant returns (bool) {

    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  function hasEnded() public constant returns (bool) {

    return now > endTime;
  }


}


contract CappedCrowdsale is Crowdsale {

  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {

    require(_cap > 0);
    cap = _cap;
  }

  function validPurchase() internal constant returns (bool) {

    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  function hasEnded() public constant returns (bool) {

    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}


contract FinalizableCrowdsale is Crowdsale, Ownable {

  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  function finalize() onlyOwner public {

    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

  function finalization() internal {

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
    Pause();
  }

  function unpause() onlyOwner whenPaused public {

    paused = false;
    Unpause();
  }
}


contract TutellusCrowdsale is CappedCrowdsale, FinalizableCrowdsale, Pausable {

    event ConditionsAdded(address indexed beneficiary, uint256 rate);
    
    mapping(address => uint256) public conditions;

    mapping(address => address) public timelocksContracts;

    uint256 salePercent = 60;   // Percent of TUTs for sale
    uint256 poolPercent = 30;   // Percent of TUTs for pool
    uint256 teamPercent = 10;   // Percent of TUTs for team

    uint256 vestingLimit = 700 ether;
    uint256 specialLimit = 300 ether;

    uint256 minPreICO = 10 ether;
    uint256 minICO = 0.5 ether;

    address teamTimelock;   //Team TokenTimelock.

    function TutellusCrowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _cap,
        address _wallet,
        address _teamTimelock,
        address _tokenAddress
    )
        CappedCrowdsale(_cap)
        Crowdsale(_startTime, _endTime, 1000, _wallet)
    {

        require(_teamTimelock != address(0));
        teamTimelock = _teamTimelock;

        if (_tokenAddress != address(0)) {
            token = TutellusToken(_tokenAddress);
        }
    }

    function addSpecialRateConditions(address _address, uint256 _rate) public onlyOwner {

        require(_address != address(0));
        require(_rate > 0);

        conditions[_address] = _rate;
        ConditionsAdded(_address, _rate);
    }

    function getRateByTime() public constant returns (uint256) {

        uint256 timeNow = now;
        if (timeNow > (startTime + 11 weeks)) {
            return 1000;
        } else if (timeNow > (startTime + 10 weeks)) {
            return 1050; // + 5%
        } else if (timeNow > (startTime + 9 weeks)) {
            return 1100; // + 10%
        } else if (timeNow > (startTime + 8 weeks)) {
            return 1200; // + 20%
        } else if (timeNow > (startTime + 6 weeks)) {
            return 1350; // + 35%
        } else if (timeNow > (startTime + 4 weeks)) {
            return 1400; // + 40%
        } else if (timeNow > (startTime + 2 weeks)) {
            return 1450; // + 45%
        } else {
            return 1500; // + 50%
        }
    }

    function getTimelock(address _address) public constant returns(address) {

        return timelocksContracts[_address];
    }

    function getValidTimelock(address _address) internal returns(address) {

        address timelockAddress = getTimelock(_address);
        if (timelockAddress == address(0)) {
            timelockAddress = new TokenTimelock(token, _address, endTime);
            timelocksContracts[_address] = timelockAddress;
        }
        return timelockAddress;
    }

    function buyTokens(address beneficiary) whenNotPaused public payable {

        require(beneficiary != address(0));
        require(msg.value >= minICO && msg.value <= vestingLimit);
        require(validPurchase());

        uint256 rate;
        address contractAddress;

        if (conditions[beneficiary] != 0) {
            require(msg.value >= specialLimit);
            rate = conditions[beneficiary];
        } else {
            rate = getRateByTime();
            if (rate > 1200) {
                require(msg.value >= minPreICO);
            }
        }

        contractAddress = getValidTimelock(beneficiary);

        mintTokens(rate, contractAddress, beneficiary);
    }

    function mintTokens(uint _rate, address _address, address beneficiary) internal {

        uint256 weiAmount = msg.value;

        uint256 tokens = weiAmount.mul(_rate);

        weiRaised = weiRaised.add(weiAmount);

        token.mint(_address, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    function poolTokensByPercent(uint256 _percent) internal returns(uint256) {

        return token.totalSupply().mul(_percent).div(salePercent);
    }

    function finalization() internal {

        uint256 tokensPool = poolTokensByPercent(poolPercent);
        uint256 tokensTeam = poolTokensByPercent(teamPercent);

        token.mint(wallet, tokensPool);
        token.mint(teamTimelock, tokensTeam);
    }

    function createTokenContract() internal returns (MintableToken) {

        return new TutellusToken();
    }
}