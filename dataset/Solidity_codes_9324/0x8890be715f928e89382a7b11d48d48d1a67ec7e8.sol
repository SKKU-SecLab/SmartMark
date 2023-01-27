
pragma solidity ^0.4.15;

library SafeMath {

  function mul(uint a, uint b) internal returns (uint) {

    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint a, uint b) internal returns (uint) {

    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }
  function sub(uint a, uint b) internal returns (uint) {

    assert(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal returns (uint) {

    uint c = a + b;
    assert(c >= a);
    return c;
  }
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {

    return a >= b ? a : b;
  }
  function min64(uint64 a, uint64 b) internal constant returns (uint64) {

    return a < b ? a : b;
  }
  function max256(uint256 a, uint256 b) internal constant returns (uint256) {

    return a >= b ? a : b;
  }
  function min256(uint256 a, uint256 b) internal constant returns (uint256) {

    return a < b ? a : b;
  }
  function assert(bool assertion) internal {

    if (!assertion) {
      throw;
    }
  }
}

contract Ownable {

    address public owner;

    function Ownable() {

        owner = msg.sender;
    }

    modifier onlyOwner {

        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {

        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


contract Pausable is Ownable {

  bool public stopped;

  modifier stopInEmergency {

    if (stopped) {
      throw;
    }
    _;
  }
  
  modifier onlyInEmergency {

    if (!stopped) {
      throw;
    }
    _;
  }

  function emergencyStop() external onlyOwner {

    stopped = true;
  }

  function release() external onlyOwner onlyInEmergency {

    stopped = false;
  }

}


contract ERC20Basic {

  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);

  function transfer(address to, uint value);

  event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender) constant returns (uint);

  function transferFrom(address from, address to, uint value);

  function approve(address spender, uint value);

  event Approval(address indexed owner, address indexed spender, uint value);
}

contract PullPayment {


  using SafeMath for uint;
  
  mapping(address => uint) public payments;

  event LogRefundETH(address to, uint value);


  function asyncSend(address dest, uint amount) internal {

    payments[dest] = payments[dest].add(amount);
  }

  function withdrawPayments() {

    address payee = msg.sender;
    uint payment = payments[payee];
    
    if (payment == 0) {
      throw;
    }

    if (this.balance < payment) {
      throw;
    }

    payments[payee] = 0;

    if (!payee.send(payment)) {
      throw;
    }
    LogRefundETH(payee,payment);
  }
}


contract BasicToken is ERC20Basic {

  
  using SafeMath for uint;
  
  mapping(address => uint) balances;
  
  modifier onlyPayloadSize(uint size) {

     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) constant returns (uint balance) {

    return balances[_owner];
  }
}


contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;

  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {

    var _allowance = allowed[_from][msg.sender];
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint _value) {

    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {

    return allowed[_owner][_spender];
  }
}

contract ERRLCoin is StandardToken, Ownable {

  using SafeMath for uint256;

  string public name = "420 ErrL";
  string public symbol = "ERRL";
  uint256 public decimals = 18;
  uint256 constant public ERRL_UNIT = 10 ** 18;
  uint256 public INITIAL_SUPPLY = 1000000000000 * ERRL_UNIT; // 1 trillion ( 1,000,000,000,000 ) ERRL COINS
  uint256 public totalAllocated = 0;             // Counter to keep track of overall token allocation
  uint256 public remaintokens=0;
  uint256 public factor=35;
    uint256 constant public maxOwnerSupply = 16000000000 * ERRL_UNIT;           // Owner seperate allocation
    uint256 constant public DeveloperSupply = 2000000000 * ERRL_UNIT;     //  Developer's allocation


address public constant OWNERSTAKE = 0xea38f5e13FF11A4F519AC1a8a9AE526979750B01;
   address public constant  DEVSTAKE = 0x625151089d010F2b1B7a72d16Defe2390D596dF8;
   



  event Burn(address indexed from, uint256 value);

  function ERRLCoin() {

      
        totalAllocated+=maxOwnerSupply+DeveloperSupply;  // Add to total Allocated funds

   remaintokens=INITIAL_SUPPLY-totalAllocated;
      
    totalSupply = INITIAL_SUPPLY;
    balances[OWNERSTAKE] = maxOwnerSupply; // owner seperate ERRL tokens
    balances[DEVSTAKE] = DeveloperSupply; // Developer's share of ERRL tokens for coding the contract
    balances[msg.sender] = remaintokens; // Send remaining tokens to owner's primary wallet from where contract is deployed
  }

  function burn(uint _value) onlyOwner returns (bool) {

    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Transfer(msg.sender, 0x0, _value);
    return true;
  }

}

contract Crowdsale is Pausable, PullPayment {

    
    using SafeMath for uint;

    struct Backer {
    uint weiReceived; // Amount of Ether given
    uint coinSent;
  }

  
 uint public constant MIN_CAP = 0; // no minimum cap
  uint public constant MAX_CAP = 600000000000 * 10 **18; 


  uint private constant CROWDSALE_PERIOD = 3000 days;
   
  uint public constant COIN_PER_ETHER = 700000 * 10**18; // 700,000 ERRL coins per eth,  1 eth=350$ Canadian , 1 ERRL coin=0.0005$ Canadian
                                        

  ERRLCoin public coin;
  address public multisigEther;
  uint public etherReceived;
  
  uint public ETHToSend;
  
  
  uint public coinSentToEther;
  uint public startTime;
  uint public endTime;
  
  
  
  
  
  bool public crowdsaleClosed=false;
  
  

  mapping(address => Backer) public backers;


  

  modifier respectTimeFrame() {

    require ((now > startTime) || (now < endTime )) ;
    _;
  }

  event LogReceivedETH(address addr, uint value);
  event LogCoinsEmited(address indexed from, uint amount);

  function Crowdsale(address _ERRLCoinAddress, address _to) {

    coin = ERRLCoin(_ERRLCoinAddress);
    multisigEther = _to;
  }

  function() stopInEmergency respectTimeFrame payable {
    receiveETH(msg.sender);
  }

  function start() onlyOwner {

   
    startTime = now ;           
    endTime =  now + CROWDSALE_PERIOD;  

    crowdsaleClosed=false;
   
  
   
  }

  function receiveETH(address beneficiary) internal {


address OWNERICO_STAKE = 0x03bC8e32389082653ea4c25AcF427508499c0Bcb;
    
    uint coinToSend = bonus(msg.value.mul(COIN_PER_ETHER).div(1 ether)); // Compute the number of ERRLCoin to send

    require(coinToSend.add(coinSentToEther) < MAX_CAP); 
    require(crowdsaleClosed == false);
    
    

    Backer backer = backers[beneficiary];
    coin.transfer(beneficiary, coinToSend); // Transfer ERRLCoins right now 

    backer.coinSent = backer.coinSent.add(coinToSend);
uint factor=35;

ETHToSend = msg.value;

ETHToSend=(ETHToSend * 35) / 100;



    
    
    
    if (ETHToSend > 0) {
      beneficiary.transfer(ETHToSend);
    }
    
LogRefundETH(msg.sender, ETHToSend);
    
    

    etherReceived = etherReceived.add((msg.value.mul(65)).div(100)); // Update the total wei collected during the crowdfunding
    
    coinSentToEther = coinSentToEther.add(coinToSend);

    LogCoinsEmited(msg.sender ,coinToSend);
    LogReceivedETH(beneficiary, etherReceived); 

   
    coin.transfer(OWNERICO_STAKE,coinToSend); // Transfer ERRLCoins right now to beneficiary ownerICO  
   

    coinSentToEther = coinSentToEther.add(coinToSend);

    LogCoinsEmited(OWNERICO_STAKE ,coinToSend);
    
    
    
  }
  

  function bonus(uint amount) internal constant returns (uint) {

    
    return amount;
  }

 

  function drain() onlyOwner {

    if (!owner.send(this.balance)) throw;
    crowdsaleClosed = true;
  }

  function setMultisig(address addr) onlyOwner public {

    require(addr != address(0));
    multisigEther = addr;
  }

  function backERRLCoinOwner() onlyOwner public {

    coin.transferOwnership(owner);
  }

  function getRemainCoins() onlyOwner public {

      
    var remains = MAX_CAP - coinSentToEther;
    
    Backer backer = backers[owner];
    coin.transfer(owner, remains); // Transfer ERRLCoins right now 

    backer.coinSent = backer.coinSent.add(remains);

    coinSentToEther = coinSentToEther.add(remains);

    LogCoinsEmited(this ,remains);
    LogReceivedETH(owner, etherReceived); 
  }


  

}