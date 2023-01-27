
pragma solidity ^0.4.13;


library SafeMath {


  function mul(uint a, uint b) internal returns (uint) {

    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {

    return a / b;
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

  function assertTrue(bool val) internal {

    assert(val);
  }

  function assertFalse(bool val) internal {

    assert(!val);
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


contract BasicToken is ERC20Basic {

  using SafeMath for uint;

  mapping (address => uint) balances;

  modifier onlyPayloadSize(uint size) {

     if (msg.data.length < size + 4) {
       revert();
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

    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) revert();
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {

    return allowed[_owner][_spender];
  }
}

contract Controller {


  function proxyPayment(address _owner) payable returns(bool);


  function onTransfer(address _from, address _to, uint _amount) returns(bool);


  function onApprove(address _owner, address _spender, uint _amount) returns(bool);

}


contract Controlled {


  address public controller;

  function Controlled() {

    controller = msg.sender;
  }

  function changeController(address _controller) onlyController {

    controller = _controller;
  }

  modifier onlyController {

    if (msg.sender != controller) revert();
    _;
  }
}


contract BurnableToken is StandardToken {


  address public constant BURN_ADDRESS = 0;

  event Burned(address burner, uint burnedAmount);

  function burn(uint burnAmount) {

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(burnAmount);
    totalSupply = totalSupply.sub(burnAmount);

    Burned(burner, burnAmount);
    Transfer(burner, BURN_ADDRESS, burnAmount);
  }
}


contract MintableToken is StandardToken, Controlled {


  event Mint(address indexed to, uint value);
  event MintFinished();

  bool public mintingFinished = false;
  uint public totalSupply = 0;

  function mint(address _to, uint _amount) onlyController canMint returns (bool) {

    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  function finishMinting() onlyController returns (bool) {

    mintingFinished = true;
    MintFinished();
    return true;
  }

  modifier canMint() {

    if (mintingFinished) revert();
    _;
  }
}


contract LimitedTransferToken is ERC20 {


  modifier canTransfer(address _sender, uint _value) {

    if (_value > transferableTokens(_sender, uint64(now))) revert();
    _;
  }

  function transfer(address _to, uint _value) canTransfer(msg.sender, _value) {

    super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) canTransfer(_from, _value) {

    super.transferFrom(_from, _to, _value);
  }

  function transferableTokens(address holder, uint64 /* time */) constant public returns (uint256) {

    return balanceOf(holder);
  }
}


contract UpgradeAgent {


  uint public originalSupply;

  function isUpgradeAgent() public constant returns (bool) {

    return true;
  }

  function upgradeFrom(address _from, uint256 _value) public;

}


contract UpgradeableToken is StandardToken {


  address public upgradeController;

  UpgradeAgent public upgradeAgent;

  uint256 public totalUpgraded;

  enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

  event Upgrade(address indexed from, address indexed to, uint256 value);

  event UpgradeAgentSet(address agent);

  function UpgradeableToken(address _upgradeController) {

    upgradeController = _upgradeController;
  }

  function upgrade(uint256 value) public {

      UpgradeState state = getUpgradeState();
      if (!(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading)) {
        revert(); // called in an invalid state
      }

      if (value == 0) revert(); // validate input value

      balances[msg.sender] = balances[msg.sender].sub(value);

      totalSupply = totalSupply.sub(value);
      totalUpgraded = totalUpgraded.add(value);

      upgradeAgent.upgradeFrom(msg.sender, value);
      Upgrade(msg.sender, upgradeAgent, value);
  }

  function setUpgradeAgent(address agent) external {

      if (!canUpgrade()) {
        revert();
      }

      if (agent == 0x0) revert();
      if (msg.sender != upgradeController) revert(); // only upgrade controller can designate the next agent
      if (getUpgradeState() == UpgradeState.Upgrading) revert(); // upgrade has already started for an agent

      upgradeAgent = UpgradeAgent(agent);

      if (!upgradeAgent.isUpgradeAgent()) revert(); // bad interface
      if (upgradeAgent.originalSupply() != totalSupply) revert(); // ensure that token supplies match in source and target

      UpgradeAgentSet(upgradeAgent);
  }

  function getUpgradeState() public constant returns(UpgradeState) {

    if (!canUpgrade()) return UpgradeState.NotAllowed;
    else if (address(upgradeAgent) == 0x0) return UpgradeState.WaitingForAgent;
    else if (totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
    else return UpgradeState.Upgrading;
  }

  function setUpgradeController(address controller) public {

      if (controller == 0x0) revert();
      if (msg.sender != upgradeController) revert();
      upgradeController = controller;
  }

  function canUpgrade() public constant returns(bool) {

     return true;
  }
}


contract VestedToken is StandardToken, LimitedTransferToken {


  uint256 MAX_GRANTS_PER_ADDRESS = 20;

  struct TokenGrant {
    address granter;     // 20 bytes
    uint256 value;       // 32 bytes
    uint64 cliff;
    uint64 vesting;
    uint64 start;        // 3 * 8 = 24 bytes
    bool revokable;
    bool burnsOnRevoke;  // 2 * 1 = 2 bits? or 2 bytes?
  } // total 78 bytes = 3 sstore per operation (32 per sstore)

  mapping (address => TokenGrant[]) public grants;

  event NewTokenGrant(address indexed from, address indexed to, uint256 value, uint256 grantId);

  function grantVestedTokens(
    address _to,
    uint256 _value,
    uint64 _start,
    uint64 _cliff,
    uint64 _vesting,
    bool _revokable,
    bool _burnsOnRevoke
  ) public {


    if (_cliff < _start || _vesting < _cliff) {
      revert();
    }

    if (tokenGrantsCount(_to) > MAX_GRANTS_PER_ADDRESS) revert();  // To prevent a user being spammed and have his balance

    uint count = grants[_to].push(
                TokenGrant(
                  _revokable ? msg.sender : 0,  // avoid storing an extra 20 bytes when it is non-revokable
                  _value,
                  _cliff,
                  _vesting,
                  _start,
                  _revokable,
                  _burnsOnRevoke
                )
              );
    transfer(_to, _value);
    NewTokenGrant(msg.sender, _to, _value, count - 1);
  }

  function revokeTokenGrant(address _holder, uint _grantId) public {

    TokenGrant storage grant = grants[_holder][_grantId];

    if (!grant.revokable) { // check if grant is revokable
      revert();
    }

    if (grant.granter != msg.sender) { // only granter to revoke the grant
      revert();
    }

    address receiver = grant.burnsOnRevoke ? 0x0 : msg.sender;
    uint256 nonVested = nonVestedTokens(grant, uint64(now));

    delete grants[_holder][_grantId];
    grants[_holder][_grantId] = grants[_holder][grants[_holder].length.sub(1)];
    grants[_holder].length -= 1;

    balances[receiver] = balances[receiver].add(nonVested);
    balances[_holder] = balances[_holder].sub(nonVested);

    Transfer(_holder, receiver, nonVested);
  }

  function transferableTokens(address holder, uint64 time) constant public returns (uint256) {

    uint256 grantIndex = tokenGrantsCount(holder);
    if (grantIndex == 0) return balanceOf(holder); // shortcut for holder without grants

    uint256 nonVested = 0;
    for (uint256 i = 0; i < grantIndex; i++) {
      nonVested = nonVested.add(nonVestedTokens(grants[holder][i], time));
    }

    uint256 vestedTransferable = balanceOf(holder).sub(nonVested);

    return SafeMath.min256(vestedTransferable, super.transferableTokens(holder, time));
  }

  function tokenGrantsCount(address _holder) constant returns (uint index) {

    return grants[_holder].length;
  }

  function calculateVestedTokens(uint256 tokens, uint256 time, uint256 start, uint256 cliff, uint256 vesting) constant returns (uint256) {

      if (time < cliff) return 0;
      if (time >= vesting) return tokens;


      uint vestedTokens = tokens.mul(time.sub(start)).div(vesting.sub(start));
      return vestedTokens;
  }

  function tokenGrant(address _holder, uint _grantId) constant returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting, bool revokable, bool burnsOnRevoke) {

    TokenGrant storage grant = grants[_holder][_grantId];

    granter = grant.granter;
    value = grant.value;
    start = grant.start;
    cliff = grant.cliff;
    vesting = grant.vesting;
    revokable = grant.revokable;
    burnsOnRevoke = grant.burnsOnRevoke;

    vested = vestedTokens(grant, uint64(now));
  }

  function vestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {

    return calculateVestedTokens(
      grant.value,
      uint256(time),
      uint256(grant.start),
      uint256(grant.cliff),
      uint256(grant.vesting)
    );
  }

  function nonVestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {

    return grant.value.sub(vestedTokens(grant, time));
  }

  function lastTokenIsTransferableDate(address holder) constant public returns (uint64 date) {

    date = uint64(now);
    uint256 grantIndex = grants[holder].length;
    for (uint256 i = 0; i < grantIndex; i++) {
      date = SafeMath.max64(grants[holder][i].vesting, date);
    }
  }
}


contract ProvideToken is BurnableToken, MintableToken, VestedToken, UpgradeableToken {


  string public constant name = 'Provide';
  string public constant symbol = 'PRVD';
  uint public constant decimals = 8;

  function ProvideToken()  UpgradeableToken(msg.sender) { }


  function() public payable {
    if (isContract(controller)) {
      if (!Controller(controller).proxyPayment.value(msg.value)(msg.sender)) revert();
    } else {
      revert();
    }
  }

  function isContract(address _addr) constant internal returns(bool) {

    uint size;
    if (_addr == address(0)) return false;
    assembly {
      size := extcodesize(_addr)
    }
    return size > 0;
  }
}