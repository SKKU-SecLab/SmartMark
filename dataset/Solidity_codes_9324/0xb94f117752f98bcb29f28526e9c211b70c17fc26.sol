
pragma solidity ^0.4.24;

contract Proxied {

    address public masterCopy;
}

contract Proxy is Proxied {

    constructor(address _masterCopy)
        public
    {
        require(_masterCopy != 0);
        masterCopy = _masterCopy;
    }

    function ()
        external
        payable
    {
        address _masterCopy = masterCopy;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch success
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
}



contract Token {


    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function transfer(address to, uint value) public returns (bool);

    function transferFrom(address from, address to, uint value) public returns (bool);

    function approve(address spender, uint value) public returns (bool);

    function balanceOf(address owner) public view returns (uint);

    function allowance(address owner, address spender) public view returns (uint);

    function totalSupply() public view returns (uint);

}



contract Oracle {


    function isOutcomeSet() public view returns (bool);

    function getOutcome() public view returns (int);

}







library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
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

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}







contract CentralizedBugOracleData {

  event OwnerReplacement(address indexed newOwner);
  event OutcomeAssignment(int outcome);

  address public owner;
  bytes public ipfsHash;
  bool public isSet;
  int public outcome;
  address public maker;
  address public taker;

  modifier isOwner () {

      require(msg.sender == owner);
      _;
  }
}

contract CentralizedBugOracleProxy is Proxy, CentralizedBugOracleData {


    constructor(address proxied, address _owner, bytes _ipfsHash, address _maker, address _taker)
        public
        Proxy(proxied)
    {
        require(_ipfsHash.length == 46);
        owner = _owner;
        ipfsHash = _ipfsHash;
        maker = _maker;
        taker = _taker;
    }
}

contract CentralizedBugOracle is Proxied,Oracle, CentralizedBugOracleData{


  function setOutcome(int _outcome)
      public
      isOwner
  {

      require(!isSet);
      _setOutcome(_outcome);
  }

  function isOutcomeSet()
      public
      view
      returns (bool)
  {

      return isSet;
  }

  function getOutcome()
      public
      view
      returns (int)
  {

      return outcome;
  }


  function _setOutcome(int _outcome) internal {

    isSet = true;
    outcome = _outcome;
    emit OutcomeAssignment(_outcome);
  }


}


contract OracleVendingMachine {

  using SafeMath for *;


  event OracleProposed(address maker, address taker, uint256 index, bytes hash);
  event OracleAccepted(address maker, address taker, uint256 index, bytes hash);
  event OracleDeployed(address maker, address taker, uint256 index, bytes hash, address oracle);
  event OracleRevoked(address maker, address taker, uint256 index, bytes hash);

  event FeeUpdated(uint256 newFee);
  event OracleUpgraded(address newAddress);
  event PaymentTokenChanged(address newToken);
  event StatusChanged(bool newStatus);
  event OracleBoughtFor(address buyer, address maker, address taker, uint256 index, bytes ipfsHash, address oracle);

  address public owner;
  uint public fee;
  Oracle public oracleMasterCopy;
  Token public paymentToken;
  bool public open;


  mapping (address => uint256) public balances;
  mapping (address => bool) public balanceChecked;
  mapping (address => mapping (address => uint256)) public oracleIndexes;
  mapping (address => mapping (address => mapping (uint256 => proposal))) public oracleProposed;
  mapping (address => mapping (address => mapping (uint256 => address))) public oracleDeployed;

  struct proposal {
    bytes hash;
    address oracleMasterCopy;
    uint256 fee;
  }

  modifier isOwner () {

      require(msg.sender == owner);
      _;
  }

  modifier whenOpen() {

    require(open);
    _;
  }

  constructor(uint _fee, address _token, address _oracleMasterCopy) public {
    owner = msg.sender;
    fee = _fee;
    paymentToken = Token(_token);
    oracleMasterCopy = Oracle(_oracleMasterCopy);
    open = true;
  }

  function changeFee(uint _fee) public isOwner {

      fee = _fee;
      emit FeeUpdated(_fee);
  }

  function upgradeOracle(address _oracleMasterCopy) public isOwner {

    require(_oracleMasterCopy != 0x0);
    oracleMasterCopy = Oracle(_oracleMasterCopy);
    emit OracleUpgraded(_oracleMasterCopy);
  }

  function changePaymentToken(address _paymentToken) public isOwner {

    require(_paymentToken != 0x0);
    paymentToken = Token(_paymentToken);
    emit PaymentTokenChanged(_paymentToken);
  }

  function modifyOpenStatus(bool status) public isOwner {

    open = status;
    emit StatusChanged(status);
  }


  function deployOracle(proposal _proposal, address maker, address taker, uint256 index) internal returns(Oracle oracle){

    require(oracleDeployed[maker][taker][index] == address(0));
    oracle = CentralizedBugOracle(new CentralizedBugOracleProxy(_proposal.oracleMasterCopy, owner, _proposal.hash, maker, taker));
    oracleDeployed[maker][taker][index] = oracle;
    emit OracleDeployed(maker, taker, index, _proposal.hash, oracle);
  }


  function confirmOracle(address maker, uint index) public returns(Oracle oracle) {

    require(oracleProposed[maker][msg.sender][index].fee > 0);

    if(!balanceChecked[msg.sender]) checkBalance(msg.sender);
    balances[msg.sender] = balances[msg.sender].sub(fee);

    oracle = deployOracle(oracleProposed[maker][msg.sender][index], maker, msg.sender, index);
    oracleIndexes[maker][msg.sender] += 1;
    emit OracleAccepted(maker, msg.sender, index, oracleProposed[maker][msg.sender][index].hash);
  }


  function buyOracle(bytes _ipfsHash, address taker) public whenOpen returns (uint index){

    if(!balanceChecked[msg.sender]) checkBalance(msg.sender);
    balances[msg.sender] = balances[msg.sender].sub(fee);
    index = oracleIndexes[msg.sender][taker];
    oracleProposed[msg.sender][taker][index] = proposal(_ipfsHash, oracleMasterCopy, fee);
    emit OracleProposed(msg.sender, taker, index, _ipfsHash);
  }

  function buyOracleFor(bytes _ipfsHash, address maker, address taker) public whenOpen isOwner returns(Oracle oracle){

    if(!balanceChecked[maker]) checkBalance(maker);
    if(!balanceChecked[taker]) checkBalance(taker);

    balances[maker] = balances[maker].sub(fee);
    balances[taker] = balances[taker].sub(fee);

    uint256 index = oracleIndexes[maker][taker];
    proposal memory oracleProposal  = proposal(_ipfsHash, oracleMasterCopy, fee);

    oracleProposed[maker][taker][index] = oracleProposal;
    oracle = deployOracle(oracleProposal,maker,taker,index);
    oracleDeployed[maker][taker][oracleIndexes[maker][taker]] = oracle;
    oracleIndexes[maker][taker] += 1;
    emit OracleBoughtFor(msg.sender, maker, taker, index, _ipfsHash, oracle);
  }

  function revokeOracle(address taker, uint256 index) public {

    require(oracleProposed[msg.sender][taker][index].fee >  0);
    require(oracleDeployed[msg.sender][taker][index] == address(0));
    proposal memory oracleProposal = oracleProposed[msg.sender][taker][index];
    oracleProposed[msg.sender][taker][index].hash = "";
    oracleProposed[msg.sender][taker][index].fee = 0;
    oracleProposed[msg.sender][taker][index].oracleMasterCopy = address(0);

    balances[msg.sender] = balances[msg.sender].add(oracleProposal.fee);
    emit OracleRevoked(msg.sender, taker, index, oracleProposal.hash);
  }

  function checkBalance(address holder) public {

    require(!balanceChecked[holder]);
    balances[holder] = paymentToken.balanceOf(holder);
    balanceChecked[holder] = true;
  }

}