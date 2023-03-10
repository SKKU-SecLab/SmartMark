
pragma solidity ^0.4.11;


contract ERC20Basic {

  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}



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



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {

    return balances[_owner];
  }

}







contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) public constant returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
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

  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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


contract BurnableToken is StandardToken {


    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {

        require(_value > 0);
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}



contract CJToken is BurnableToken, Ownable {


    string public constant name = "ConnectJob";
    string public constant symbol = "CJT";
    uint public constant decimals = 18;
    uint256 public constant initialSupply = 300000000 * (10 ** uint256(decimals));

    function CJToken() {

        totalSupply = initialSupply;
        balances[msg.sender] = initialSupply; // Send all tokens to owner
    }
}


contract Crowdsale is Ownable {

    using SafeMath for uint256;

    address public multisigVault;

    CJToken public coin;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public weiRaised;
    uint256 public tokensSold;
    uint256 public maxCap;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function Crowdsale(address _CJTokenAddress, address _to, uint256 _maxCap) {

        coin = CJToken(_CJTokenAddress);
        multisigVault = _to;
        maxCap = _maxCap;

        startTime = now; // for testing we use now
        endTime = startTime + 75 days; // ICO end on Apr 30 2018 00:00:00 GMT
    }

    function () payable {
        buyTokens(msg.sender);
    }

    function setMultiSigVault(address _multisigVault) public onlyOwner {

        require(_multisigVault != address(0));
        multisigVault = _multisigVault;
    }

    function getTokenAmount(uint256 _weiAmount) internal returns(uint256) {

        if (_weiAmount < 0.001 * (10 ** 18)) {
          return 0;
        }

        uint256 tokens = _weiAmount.mul(2400);
        if(now < startTime + 7 * 1 days) {
            tokens += (tokens * 12) / 100; // 12% for first week
        } else if(now < startTime + 14 * 1 days) {
            tokens += (tokens * 9) / 100; // 9% for second week
        } else if(now < startTime + 21 * 1 days) {
            tokens += (tokens * 6) / 100; // 6% for third week
        } else if(now < startTime + 28 * 1 days) {
            tokens += (tokens * 3) / 100; // 3% for fourth week
        }

        return tokens;
    }

    function buyTokens(address beneficiary) payable {

        require(beneficiary != 0x0);
        require(msg.value != 0);
        require(!hasEnded());
        require(now > startTime);

        uint256 weiAmount = msg.value;
        uint256 refundWeiAmount = 0;

        uint256 tokens = getTokenAmount(weiAmount);
        require(tokens > 0);

        if (tokensSold + tokens > maxCap) {
          uint256 overSoldTokens = (tokensSold + tokens) - maxCap;
          refundWeiAmount = weiAmount * overSoldTokens / tokens;
          weiAmount = weiAmount - refundWeiAmount;
          tokens = tokens - overSoldTokens;
        }

        weiRaised = weiRaised.add(weiAmount);
        tokensSold = tokensSold.add(tokens);

        coin.transfer(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        multisigVault.transfer(weiAmount);

        if (refundWeiAmount > 0) {
          beneficiary.transfer(refundWeiAmount);
        }
    }

    function hasEnded() public constant returns (bool) {

        return now > endTime || tokensSold >= maxCap;
    }

    function finalizeCrowdsale() {

        require(hasEnded());
        require(coin.balanceOf(this) > 0);

        coin.burn(coin.balanceOf(this));
    }
}