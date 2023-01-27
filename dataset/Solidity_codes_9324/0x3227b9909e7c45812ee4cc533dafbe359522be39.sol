
pragma solidity ^0.4.24;
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
 
library SafeMath {

    
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }
 
  function balanceOf(address _owner) public constant returns (uint256 balance) {

    return balances[_owner];
  }
 
}
 
contract StandardToken is ERC20, BasicToken {

 
  mapping (address => mapping (address => uint256)) allowed;
 
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

    uint256 _allowance = allowed[_from][msg.sender];
 
 
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
 
  function approve(address _spender, uint256 _value) public returns (bool) {

 
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
 
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
 
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {

    return allowed[_owner][_spender];
  }
  
}
 
 
contract BurnableToken is StandardToken {

 
  function burn(uint256 _value) public {

    require(_value > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Burn(burner, _value);
    emit Transfer(msg.sender, address(0), _value);
}
 
  event Burn(address indexed burner, uint256 indexed value);
}

contract TMBToken is BurnableToken {

    
  string public constant name = "Teambrella Token";
    
  string public constant symbol = "TMB";
    
  uint32 public constant decimals = 18;
    
  uint256 public constant INITIAL_SUPPLY = 17500000E18;  // 60% is for sale:  10000000E18 max during the sale + 500000E18 max bonus during the pre-sale
  
  uint256 public constant lockPeriodStart = 1536796740;  // end of sale 2018-09-12 23:59
    
  bool public stopped = true;
  address public owner;
  
  mapping(address => uint256) public unlockTimes;

  modifier isRunning() {

    if (stopped) {
        if (msg.sender != owner)
            revert();
      }
    _;
  }

  modifier isNotLocked() {

    
    if (now < lockPeriodStart + 730 days) {
        if (now < unlockTimes[msg.sender])
            revert();
      }
    _;
  }

  constructor() public {
    owner = msg.sender;
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
  }
  
  function start() public {

    require(msg.sender == owner);
    stopped = false;
  }

  function lockAddress(address _addr, uint256 _period) public {

      require(msg.sender == owner);
      require(stopped); // not possible to lock addresses after start of the contract
      unlockTimes[_addr] = lockPeriodStart + _period;
  }

  function transfer(address _to, uint256 _value) public isRunning isNotLocked returns (bool) {

    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public isRunning returns (bool) {

    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public isRunning isNotLocked returns (bool) {

    return super.approve(_spender, _value);
  }

  
}

contract TMBTokenSale {

    
    using SafeMath for uint256;
    
    address public multisigOwner;

    address public multisigFunds;
    address public company;
    address public partners;
    

    uint256 public constant soldPercent = 60;
    uint256 public constant partnersPercent = 5;
    uint256 public constant companyPercent = 35;

    uint256 public constant softcap = 2000 * 1 ether;
    uint256 public constant presalecap = 2500 * 1 ether;
    uint256 public constant hardcap = 10000 * 1 ether;
 
    uint256 public constant startPresale = 1532304000; // 2018-07-23 00:00
    uint256 public constant endPresale = 1534118340; // 2018-08-12 23:59

    uint256 public constant startSale = 1534118400; // 2018-08-13 00:00
    uint256 public constant endSale = 1536796740; // 2018-09-12 23:59

    TMBToken public token = new TMBToken();

    bool public stoppedSale = false;
    bool public stoppedPresale = false;

    uint256 public receivedEth = 0;
    uint256 public deliveredEth = 0;
    
    uint256 public issuedTokens;
 
    mapping(address => uint256) public preBalances;
    mapping(address => uint256) public saleBalances;
    
    bool tokensaleFinished = false;
    
    event ReservedPresale(address indexed to, uint256 value);
    event ReservedSale(address indexed to, uint256 value);
    event Issued(address indexed to, uint256 value);
    event Refunded(address indexed to, uint256 value);

    constructor() public {
        
        multisigOwner = 0x101B8fA4F9fA10B9800aCa7b2f4F4841d24DA48E;

        multisigFunds = 0xc65484367BdD9265D487d905A5AAe228e9eE1000;
        company = 0x993C5743Fe73a805d125051f77A32cFAaEF08427;
        partners = 0x66885Bf2915b687E37253F8efB50Cc01f9452802;

    }
 
    modifier isAfterPresale() {

    	require(now > endPresale || (stoppedPresale && now > startPresale));
    	_;
    }

    modifier isAfterSale() {

    	require(now > endSale || (stoppedSale && now > startSale));
    	_;
    }
	
    modifier isAboveSoftCap() {

        require(receivedEth >= softcap);
        _;
    }

    modifier onlyOwner() {

        require(multisigOwner == msg.sender);
        _;
    }
    
    function() external payable {
      reserveFunds();
    }

   function reserveFunds() public payable {

       
       uint256 _value = msg.value;
       address _addr = msg.sender;
       
       require (!isContract(_addr));
       require(_value >= 0.01 * 1 ether);
       
       uint256 _totalFundedEth;
       
       if (!stoppedPresale && now > startPresale && now < endPresale)
       {
           _totalFundedEth = preBalances[_addr].add(_value);
           preBalances[_addr] = _totalFundedEth;
           receivedEth = receivedEth.add(_value);
           emit ReservedPresale(_addr, _value);
       }
       else if (!stoppedSale && now > startSale && now < endSale)
       {
           _totalFundedEth = saleBalances[_addr].add(_value);
           saleBalances[_addr] = _totalFundedEth;
           receivedEth = receivedEth.add(_value);
           emit ReservedSale(_addr, _value);
       }
       else
       {
           revert();
       }
    }

    function stopPresale() public onlyOwner {

        stoppedPresale = true;
    }
    
    function stopSale() public onlyOwner {

        stoppedSale = true;
    }

    function isContract(address _addr) constant internal returns(bool) {

	    uint256 size;
	    if (_addr == 0) return false;
	    assembly {
		    size := extcodesize(_addr)
	    }
	    return size > 0;
    }

    function issueTokens(address _addr, uint256 _valTokens) internal {


        token.transfer(_addr, _valTokens);
        issuedTokens = issuedTokens.add(_valTokens);
        emit Issued(_addr, _valTokens);
    }

    function deliverPresale(address _addr, uint256 _valEth) internal {


        uint256 _issuedTokens = _valEth * 1200; // _valEth * rate + 20% presale bonus, rate == 1000
        uint256 _newDeliveredEth = deliveredEth.add(_valEth);
        require(_newDeliveredEth < presalecap);
        multisigFunds.transfer(_valEth);
        deliveredEth = _newDeliveredEth;

        issueTokens(_addr, _issuedTokens);
    }
    
    function deliverSale(address _addr, uint256 _valEth) internal {


        uint256 _issuedTokens = _valEth * 1000; // _valEth * rate, rate == 1000
        uint256 _newDeliveredEth = deliveredEth.add(_valEth);
        require(_newDeliveredEth < hardcap);
        multisigFunds.transfer(_valEth);
        deliveredEth = _newDeliveredEth;

        issueTokens(_addr, _issuedTokens);
    }
    
    function refund() public isAfterSale {

        require(receivedEth < softcap);
        uint256 _value = preBalances[msg.sender]; 
        _value += saleBalances[msg.sender]; 
        if (_value > 0)
        {
            preBalances[msg.sender] = 0;
            saleBalances[msg.sender] = 0; 
            msg.sender.transfer(_value);
            emit Refunded(msg.sender, _value);
        }
    }

    function issueTokensPresale(address _addr, uint256 _val) public onlyOwner isAfterPresale isAboveSoftCap {


        require(_val >= 0);
        require(!tokensaleFinished);
        
        uint256 _fundedEth = preBalances[_addr];
        if (_fundedEth > 0)
        {
            if (_fundedEth > _val)
            {
                uint256 _refunded = _fundedEth.sub(_val);
                _addr.transfer(_refunded);
                emit Refunded(_addr, _refunded);
                _fundedEth = _val;
            }

            if (_fundedEth > 0)
            {
                deliverPresale(_addr, _fundedEth);
            }
            preBalances[_addr] = 0;
        }
    }

    function issueTokensSale(address _addr, uint256 _val) public onlyOwner isAfterSale isAboveSoftCap {


        require(_val >= 0);
        require(!tokensaleFinished);
        
        uint256 _fundedEth = saleBalances[_addr];
        if (_fundedEth > 0)
        {
            if (_fundedEth > _val)
            {
                uint256 _refunded = _fundedEth.sub(_val);
                _addr.transfer(_refunded);
                emit Refunded(_addr, _refunded);
                _fundedEth = _val;
            }

            if (_fundedEth > 0)
            {
                deliverSale(_addr, _fundedEth);
            }
            saleBalances[_addr] = 0;
        }
    }

    function issueTokensPresale(address[] _addrs) public onlyOwner isAfterPresale isAboveSoftCap {


        require(!tokensaleFinished);

        for (uint256 i; i < _addrs.length; i++)
        {
            address _addr = _addrs[i];
            uint256 _fundedEth = preBalances[_addr];
            if (_fundedEth > 0)
            {
                deliverPresale(_addr, _fundedEth);
                preBalances[_addr] = 0;
            }            
        }
    }

    function issueTokensSale(address[] _addrs) public onlyOwner isAfterSale isAboveSoftCap {


        require(!tokensaleFinished);

        for (uint256 i; i < _addrs.length; i++)
        {
            address _addr = _addrs[i];
            uint256 _fundedEth = saleBalances[_addr];
            if (_fundedEth > 0)
            {
                deliverSale(_addr, _fundedEth);
                saleBalances[_addr] = 0;
            }            
        }
    }
    
    function refundTokensPresale(address[] _addrs) public onlyOwner isAfterPresale {


        for (uint256 i; i < _addrs.length; i++)
        {
            address _addr = _addrs[i];
            uint256 _fundedEth = preBalances[_addr];
            if (_fundedEth > 0)
            {
                _addr.transfer(_fundedEth);
                emit Refunded(_addr, _fundedEth);
                preBalances[_addr] = 0;
            }
        }
    }

    function refundTokensSale(address[] _addrs) public onlyOwner isAfterSale {


        for (uint256 i; i < _addrs.length; i++)
        {
            address _addr = _addrs[i];
            uint256 _fundedEth = saleBalances[_addr];
            if (_fundedEth > 0)
            {
                _addr.transfer(_fundedEth);
                emit Refunded(_addr, _fundedEth);
                saleBalances[_addr] = 0;
            }
        }
    }

    function lockAddress(address _addr, uint256 _period) public onlyOwner {

        token.lockAddress(_addr, _period);
    }

    function finalize() public onlyOwner isAfterSale isAboveSoftCap {


        require(!tokensaleFinished);

        tokensaleFinished = true;
        
        uint256 _soldTokens = issuedTokens;
        
        uint256 _partnersTokens = _soldTokens * partnersPercent / soldPercent;
        issueTokens(partners, _partnersTokens);

        uint256 _companyTokens = _soldTokens * companyPercent / soldPercent;
        issueTokens(company, _companyTokens);
        token.lockAddress(company, 730 days);

        uint256 _tokensToBurn = token.balanceOf(this); //token.INITIAL_SUPPLY().sub(issuedTokens);
        token.burn(_tokensToBurn);
        token.start();
    }
}