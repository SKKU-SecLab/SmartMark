
pragma solidity 0.4.21;

contract ERC20Interface {

    uint public totalSupply;
    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Ownable {


  address public owner;

  function Ownable() public {

    owner = msg.sender;
  }

  function changeOwner(address newOwner) public ownerOnly {

    require(newOwner != address(0));
    owner = newOwner;
  }

  modifier ownerOnly() {

    require(msg.sender == owner);
    _;
  }
}
contract Upgradeable is Ownable{


  address public lastContract;
  address public nextContract;
  bool public isOldVersion;
  bool public allowedToUpgrade;

  function Upgradeable() public {

    allowedToUpgrade = true;
  }

  function upgradeTo(Upgradeable newContract) public ownerOnly{

    require(allowedToUpgrade && !isOldVersion);
    nextContract = newContract;
    isOldVersion = true;
    newContract.confirmUpgrade();   
  }

  function confirmUpgrade() public {

    require(lastContract == address(0));
    lastContract = msg.sender;
  }
}

contract EmergencySafe is Ownable{ 


  event PauseToggled(bool isPaused);

  bool public paused;


  modifier isNotPaused() {

    require(!paused);
    _;
  }

  modifier isPaused() {

    require(paused);
    _; 
  }

  function EmergencySafe() public {

    paused = false;
  }

  function emergencyERC20Drain(ERC20Interface token, uint amount) public ownerOnly{

    token.transfer(owner, amount);
  }

  function emergencyEthDrain(uint amount) public ownerOnly returns (bool){

    return owner.send(amount);
  }

  function togglePause() public ownerOnly {

    paused = !paused;
    emit PauseToggled(paused);
  }
}

contract IXTPaymentContract is Ownable, EmergencySafe, Upgradeable{


  event IXTPayment(address indexed from, address indexed to, uint value, string indexed action);

  ERC20Interface public tokenContract;

  mapping(string => uint) private actionPrices;
  mapping(address => bool) private allowed;

  modifier allowedOnly() {

    require(allowed[msg.sender] || msg.sender == owner);
    _;
  }

  function IXTPaymentContract(address tokenAddress) public {

    tokenContract = ERC20Interface(tokenAddress);
    allowed[owner] = true;
  }

  function transferIXT(address from, address to, string action) public allowedOnly isNotPaused returns (bool) {

    if (isOldVersion) {
      IXTPaymentContract newContract = IXTPaymentContract(nextContract);
      return newContract.transferIXT(from, to, action);
    } else {
      uint price = actionPrices[action];

      if(price != 0 && !tokenContract.transferFrom(from, to, price)){
        return false;
      } else {
        emit IXTPayment(from, to, price, action);     
        return true;
      }
    }
  }

  function setTokenAddress(address erc20Token) public ownerOnly isNotPaused {

    tokenContract = ERC20Interface(erc20Token);
  }

  function setAction(string action, uint price) public ownerOnly isNotPaused {

    actionPrices[action] = price;
  }

  function getActionPrice(string action) public view returns (uint) {

    return actionPrices[action];
  }


  function setAllowed(address allowedAddress) public ownerOnly {

    allowed[allowedAddress] = true;
  }

  function removeAllowed(address allowedAddress) public ownerOnly {

    allowed[allowedAddress] = false;
  }
}

contract Policy is Ownable, EmergencySafe, Upgradeable{


  struct InsuranceProduct {
    uint inceptionDate;
    string insuranceType;
  }

  struct PolicyInfo {
    uint blockNumber;
    uint numInsuranceProducts;
    string clientName;
    string ixlEnquiryId;
    string status;
  }

  InsuranceProduct[] public insuranceProducts;
  PolicyInfo public policyInfo;
  address private brokerEtherAddress;
  address private clientEtherAddress;
  mapping(address => bool) private cancellations;

  modifier participantOnly() {

    require(msg.sender == clientEtherAddress || msg.sender == brokerEtherAddress);
    _;
  }

  function Policy(string _clientName, address _brokerEtherAddress, address _clientEtherAddress, string _enquiryId) public {


    policyInfo = PolicyInfo({
      blockNumber: block.number,
      numInsuranceProducts: 0,
      clientName: _clientName,
      ixlEnquiryId: _enquiryId,
      status: 'In Force'
    });

    clientEtherAddress =  _clientEtherAddress;
    brokerEtherAddress =  _brokerEtherAddress;

    allowedToUpgrade = false;
  }

  function addInsuranceProduct (uint _inceptionDate, string _insuranceType) public ownerOnly isNotPaused {

    insuranceProducts.push(InsuranceProduct({
      inceptionDate: _inceptionDate,
      insuranceType: _insuranceType
    }));

    policyInfo.numInsuranceProducts++;
  }


  function revokeContract() public participantOnly {

    cancellations[msg.sender] = true;

    if (((cancellations[brokerEtherAddress] && (cancellations[clientEtherAddress] || cancellations[owner]))
        || (cancellations[clientEtherAddress] && cancellations[owner]))){
      policyInfo.status = "REVOKED";
      allowedToUpgrade = true;
    }
  }
}

contract PolicyRegistry is Ownable, EmergencySafe, Upgradeable{


  event PolicyCreated(address at, address by);

  IXTPaymentContract public IXTPayment;

  mapping (address => address[]) private policiesByParticipant;
  address[] private policies;


  function PolicyRegistry(address paymentAddress) public {

    IXTPayment = IXTPaymentContract(paymentAddress);
  }

  function createContract(string _clientName, address _brokerEtherAddress, address _clientEtherAddress, string _enquiryId) public isNotPaused {


    Policy policy = new Policy(_clientName, _brokerEtherAddress, _clientEtherAddress, _enquiryId);
    policy.changeOwner(msg.sender);
    policiesByParticipant[_brokerEtherAddress].push(policy);

    if (_clientEtherAddress != _brokerEtherAddress) {
      policiesByParticipant[_clientEtherAddress].push(policy);
    }

    if (msg.sender != _clientEtherAddress && msg.sender != _brokerEtherAddress) {
      policiesByParticipant[msg.sender].push(policy);
    }

    policies.push(policy);

    IXTPayment.transferIXT(_clientEtherAddress, owner, "create_insurance");
    emit PolicyCreated(policy, msg.sender);
  }

  function getMyPolicies() public view returns (address[]) {

    return policiesByParticipant[msg.sender];
  }

  function getAllPolicies() public view ownerOnly returns (address[]){

    return policies;
  }

  function changePaymentContract(address contractAddress) public ownerOnly{

    IXTPayment = IXTPaymentContract(contractAddress);
  }
}