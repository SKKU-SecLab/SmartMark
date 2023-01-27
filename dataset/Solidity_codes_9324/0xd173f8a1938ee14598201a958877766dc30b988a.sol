
pragma solidity 0.4.24;

interface ERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function transferFrom(address from, address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value) external returns (bool);

}


contract Migratable {

  event Migrated(string contractName, string migrationId);

  mapping (string => mapping (string => bool)) internal migrated;


  modifier isInitializer(string contractName, string migrationId) {

    require(!isMigrated(contractName, migrationId));
    _;
    emit Migrated(contractName, migrationId);
    migrated[contractName][migrationId] = true;
  }

  modifier isMigration(string contractName, string requiredMigrationId, string newMigrationId) {

    require(isMigrated(contractName, requiredMigrationId) && !isMigrated(contractName, newMigrationId));
    _;
    emit Migrated(contractName, newMigrationId);
    migrated[contractName][newMigrationId] = true;
  }

  function isMigrated(string contractName, string migrationId) public view returns(bool) {

    return migrated[contractName][migrationId];
  }
}


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }
    c = a * b;
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

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Escrow is Migratable {

    using SafeMath for uint256;

    ERC20 internal escrowToken;
    uint256 internal escrowId = 0;
    address escrowDapp;    

    enum EscrowStatus {
        New,
        Completed,
        Cancelled
    }

    struct EscrowRecord {
        uint256 id;
        address client;
        address provider;
        uint256 amount;
        EscrowStatus status;
        uint256 createdAt;
        uint256 closedAt;
        uint256 paidToDappAmount;
        uint256 paidToProviderAmount;
        uint256 paidToClientAmount;
        uint256 paidToArbiterAmount;
    }

    mapping(uint256 => EscrowRecord) internal escrows;

    event OnInitialize(address indexed token, address indexed dApp);
    event OnCreateEscrow(address indexed dapp, address indexed client, address indexed provider, uint256 amount, uint256 payToDappAmount);
    event OnCompleteEscrow(address indexed dapp, uint256 indexed escrowId);
    event OnCancelEscrowByProvider(address indexed dapp, uint256 indexed escrowId);
    event OnCancelEscrow(address indexed dapp, uint256 indexed escrowId, uint256 payToProviderAmount, address indexed arbiter, uint256 payToArbiterAmount);
    
    function initialize(ERC20 _token, address _dApp) 
    internal 
    isInitializer("Escrow", "0.1.3") {

        require(_token != address(0) && _dApp != address(0));
        
        escrowToken = _token;
        escrowDapp = _dApp;

        emit OnInitialize(_token, _dApp);
    }

    function createEscrow(address _client, address _provider, uint256 _amount, uint256 _payToDappAmount) 
    internal 
    returns (uint256) {

        require(_client != address(0) && _provider != address(0) && _amount > 0 && _payToDappAmount >= 0);
        require(escrowToken.transferFrom(_client, address(this), _amount));

        uint256 id = ++escrowId;
        EscrowRecord storage escrow = escrows[id];
        escrow.id = id;
        escrow.client = _client;
        escrow.provider = _provider;
        escrow.amount = _amount;
        escrow.createdAt = block.number;
        escrow.status = EscrowStatus.New;
        escrow.paidToProviderAmount = 0;
        escrow.paidToClientAmount = 0;
        escrow.paidToArbiterAmount = 0;

        if (_payToDappAmount > 0) {
            escrow.paidToDappAmount = _payToDappAmount;
            require(escrowToken.transfer(escrowDapp, _payToDappAmount));
        }

        emit OnCreateEscrow(escrowDapp, _client, _provider, _amount, _payToDappAmount);

        return id;
    }

    function completeEscrow(uint256 _escrowId) 
    internal 
    returns (bool) {

        require(escrows[_escrowId].status == EscrowStatus.New);
        require(escrows[_escrowId].client == msg.sender);

        escrows[_escrowId].status = EscrowStatus.Completed;
        escrows[_escrowId].paidToProviderAmount = escrows[_escrowId].amount.sub(escrows[_escrowId].paidToDappAmount);
        escrows[_escrowId].closedAt = block.number;

        require(escrowToken.transfer(escrows[_escrowId].provider, escrows[_escrowId].paidToProviderAmount));

        emit OnCompleteEscrow(escrowDapp, _escrowId);

        return true;
    }

    function cancelEscrowByProvider(uint256 _escrowId) 
    internal 
    returns (bool) {

        require(escrows[_escrowId].status == EscrowStatus.New);
        require(escrows[_escrowId].provider == msg.sender);

        escrows[_escrowId].paidToClientAmount = escrows[_escrowId].amount.sub(escrows[_escrowId].paidToDappAmount);
        escrows[_escrowId].status = EscrowStatus.Cancelled;
        escrows[_escrowId].closedAt = block.number;

        require(escrowToken.transfer(escrows[_escrowId].client, escrows[_escrowId].paidToClientAmount));

        emit OnCancelEscrowByProvider(escrowDapp, _escrowId);

        return true;
    }    

    function cancelEscrow(uint256 _escrowId, uint256 _payToProviderAmount, address arbiter, uint256 _payToArbiterAmount) 
    internal 
    returns (bool) {

        require(escrows[_escrowId].status == EscrowStatus.New);
        require(_payToProviderAmount >= 0 && _payToArbiterAmount >= 0);
        require(escrows[_escrowId].amount >= escrows[_escrowId].paidToDappAmount.add(_payToArbiterAmount).add(_payToProviderAmount));

        escrows[_escrowId].status = EscrowStatus.Cancelled;        
        escrows[_escrowId].closedAt = block.number;

        if (_payToArbiterAmount > 0) {
            require(arbiter != address(0));
            escrows[_escrowId].paidToArbiterAmount = _payToArbiterAmount;
            require(escrowToken.transfer(arbiter, _payToArbiterAmount));
        }                

        if (_payToProviderAmount > 0) {
            escrows[_escrowId].paidToProviderAmount = _payToProviderAmount;
            require(escrowToken.transfer(escrows[_escrowId].provider, _payToProviderAmount));
        }        

        uint256 totalPaid = escrows[_escrowId].paidToDappAmount.add(_payToArbiterAmount).add(_payToProviderAmount);
        escrows[_escrowId].paidToClientAmount = escrows[_escrowId].amount.sub(totalPaid);        
        if (escrows[_escrowId].paidToClientAmount > 0) {
            require(escrowToken.transfer(escrows[_escrowId].client, escrows[_escrowId].paidToClientAmount));
        }       

        emit OnCancelEscrow(escrowDapp, _escrowId, _payToProviderAmount, arbiter, _payToArbiterAmount); 

        return true;
    }

    function getEscrow(uint256 _escrowId) 
    public 
    view
    returns (
      address client, 
      address provider, 
      uint256 amount, 
      uint8 status, 
      uint256 createdAt, 
      uint256 closedAt, 
      uint256 paidToProviderAmount) 
      {      

      require(_escrowId > 0 && escrows[_escrowId].createdAt > 0);
      return (
        escrows[_escrowId].client, 
        escrows[_escrowId].provider, 
        escrows[_escrowId].amount, 
        uint8(escrows[_escrowId].status),
        escrows[_escrowId].createdAt, 
        escrows[_escrowId].closedAt, 
        escrows[_escrowId].paidToProviderAmount
        );       
    }

    function getEscrowPayments(uint256 _escrowId) 
    public 
    view
    returns (
      uint8 status,
      uint256 amount, 
      uint256 paidToDappAmount,
      uint256 paidToProviderAmount,
      uint256 paidToClientAmount,      
      uint256 paidToArbiterAmount)
      {      

      require(_escrowId > 0 && escrows[_escrowId].createdAt > 0);
      return (
        uint8(escrows[_escrowId].status), 
        escrows[_escrowId].amount, 
        escrows[_escrowId].paidToDappAmount,
        escrows[_escrowId].paidToProviderAmount,
        escrows[_escrowId].paidToClientAmount,        
        escrows[_escrowId].paidToArbiterAmount
        );       
    }    
}

contract CanWorkAdmin {

  function addSig(address signer, bytes32 id) external returns (uint8);

  function resetSignature(bytes32 id) external returns (bool);  

  function getSignersCount(bytes32 id) external view returns (uint8);

  function getSigner(bytes32 id, uint index) external view returns (address,bool);

  function hasRole(address addr, string roleName) external view returns (bool);

}

contract CanWorkJob is Escrow {

    
    using SafeMath for uint256;
    
    CanWorkAdmin canworkAdmin;    
    string public constant ROLE_ADMIN = "admin";
    string public constant ROLE_OWNER = "owner";

    uint8 internal CANWORK_PAYMENT_PERCENTAGE;  

    enum JobStatus {
        New,
        Completed,
        Cancelled
    }

    struct Job {
      bytes32 id;
      address client;
      address provider;
      uint256 escrowId;
      JobStatus status;
      uint256 amount;
    }

    mapping(bytes32 => Job) internal jobs;
    address dApp;

    event OnCreateJob(address indexed dapp, bytes32 indexed jobId, address client, address indexed provider, uint256 totalCosts);
    event OnCompleteJob(address indexed dapp, bytes32 indexed jobId);
    event OnCancelJobByProvider(address indexed dapp, bytes32 indexed jobId);
    event OnCancelJobByAdmin(address indexed dapp, bytes32 indexed jobId, uint256 payToProviderAmount, address indexed arbiter, uint256 payToArbiterAmount);

    function initialize(ERC20 _token, CanWorkAdmin _canworkAdmin, address _dApp)
    public 
    isInitializer("CanWorkJob", "0.1.3") {

        require(_token != address(0) && _canworkAdmin != address(0) && _dApp != address(0));        

        Escrow.initialize(_token, _dApp);

        canworkAdmin = CanWorkAdmin(_canworkAdmin);
        
        dApp = _dApp;        

        CANWORK_PAYMENT_PERCENTAGE = 1;
    }

    function createJob(bytes32 _jobId, address _client, address _provider, uint256 _totalCosts) 
    public 
    returns (bool) {

        require(_jobId[0] != 0);
        require(jobs[_jobId].id[0] == 0);

        uint256 payToDappAmount = _totalCosts.mul(CANWORK_PAYMENT_PERCENTAGE).div(100);

        jobs[_jobId].id = _jobId;
        jobs[_jobId].client = _client;
        jobs[_jobId].provider = _provider;
        jobs[_jobId].status = JobStatus.New;
        jobs[_jobId].amount = _totalCosts;
        jobs[_jobId].escrowId = createEscrow(_client, _provider, _totalCosts, payToDappAmount);

        emit OnCreateJob(dApp, _jobId, _client, _provider, _totalCosts);

        return true;
    }

    function completeJob(bytes32 _jobId) 
    public 
    returns (bool) {  

        require(_jobId[0] != 0);
        require(jobs[_jobId].status == JobStatus.New);
        require(jobs[_jobId].client == msg.sender);   
        
        require(completeEscrow(jobs[_jobId].escrowId));
        
        jobs[_jobId].status = JobStatus.Completed;

        emit OnCompleteJob(dApp, _jobId);

        return true;
    }

    function cancelJobByProvider(bytes32 _jobId) 
    public 
    returns (bool) {

        require(_jobId[0] != 0);  
        require(jobs[_jobId].status == JobStatus.New);
        require(jobs[_jobId].provider == msg.sender);
        
        require(cancelEscrowByProvider(jobs[_jobId].escrowId));
        
        jobs[_jobId].status = JobStatus.Cancelled;

        emit OnCancelJobByProvider(dApp, _jobId);

        return true;
    }

    function cancelJobByAdmin(bytes32 _jobId, uint256 _payToProviderAmount, address _arbiter, uint256 _payToArbiterAmount) 
    public 
    returns (bool) {

        require(_jobId[0] != 0);  
        require(jobs[_jobId].status == JobStatus.New);
        require(canworkAdmin.hasRole(msg.sender, ROLE_ADMIN));
        
        uint maxArbiterPayment = jobs[_jobId].amount.mul(5).div(100);

        require(_payToArbiterAmount <= maxArbiterPayment);        
        
        require(cancelEscrow(jobs[_jobId].escrowId, _payToProviderAmount, _arbiter, _payToArbiterAmount));

        jobs[_jobId].status = JobStatus.Cancelled;

        emit OnCancelJobByAdmin(dApp, _jobId, _payToProviderAmount, _arbiter, _payToArbiterAmount);

        return true;
    }

    function getJob(bytes32 _jobId) 
    public 
    view 
    returns (
      address client, 
      address provider,
      uint256 amount,
      uint8 status, 
      uint256 createdAt, 
      uint256 closedAt, 
      uint256 paidToProviderAmount
      ) {

      require(_jobId[0] != 0); 
      require(jobs[_jobId].id[0] != 0);

      return getEscrow(jobs[_jobId].escrowId);
    }

    function getJobPayments(bytes32 _jobId) 
    public 
    view 
    returns (
      uint8 status,
      uint256 amount,     
      uint256 paidToDappAmount,
      uint256 paidToProviderAmount,
      uint256 paidToClientAmount,
      uint256 paidToArbiterAmount
      ) {

      require(_jobId[0] != 0); 
      require(jobs[_jobId].id[0] != 0);

      return getEscrowPayments(jobs[_jobId].escrowId);
    } 
}

contract CanWork is CanWorkJob {

  ERC20 canYaCoin;  

  event OnEmeregencyTransfer(address indexed toAddress, uint256 balance);

  function initialize(ERC20 _token, CanWorkAdmin _canworkAdmin, address _dApp) 
  public 
  isInitializer("CanWork", "0.1.2") {

      require(_token != address(0) && _canworkAdmin != address(0) && _dApp != address(0));

      CanWorkJob.initialize(_token, _canworkAdmin, _dApp);      

      canYaCoin = _token;        
  }
  
  function emergencyTransfer(address toAddress) 
  public     
  returns (bool) {

    require(toAddress != address(0));
    require(canworkAdmin.hasRole(msg.sender, ROLE_OWNER));

    bytes32 uniqueId = keccak256(abi.encodePacked(address(this), toAddress, "emergencyTransfer"));

    if (canworkAdmin.getSignersCount(uniqueId) < 2) {
      canworkAdmin.addSig(msg.sender, uniqueId);
      return false;
    }

    canworkAdmin.addSig(msg.sender, uniqueId);

    canworkAdmin.resetSignature(uniqueId);

    uint256 balance = canYaCoin.balanceOf(address(this));
    canYaCoin.transfer(toAddress, balance);

    emit OnEmeregencyTransfer(toAddress, balance);

    return true;
  }

  function getEmergencyTransferSignersCount(address _toAddress)
  public 
  view 
  returns(uint)
  {   

    bytes32 uniqueId = keccak256(abi.encodePacked(address(this), _toAddress, "emergencyTransfer"));
    return canworkAdmin.getSignersCount(uniqueId);
  }    

  function getEmergencyTransferSigner(address _toAddress, uint index)
  public 
  view 
  returns (address,bool)
  {

    bytes32 uniqueId = keccak256(abi.encodePacked(address(this), _toAddress, "emergencyTransfer"));
    return canworkAdmin.getSigner(uniqueId, index);
  }  
  
}