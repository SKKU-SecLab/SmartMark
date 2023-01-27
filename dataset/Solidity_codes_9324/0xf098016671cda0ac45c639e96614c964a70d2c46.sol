
pragma solidity ^0.8.0;
interface ILssGovernance {

    function LSS_TEAM_INDEX() external view returns(uint256);

    function TOKEN_OWNER_INDEX() external view returns(uint256);

    function COMMITEE_INDEX() external view returns(uint256);

    function committeeMembersCount() external view returns(uint256);

    function walletDisputePeriod() external view returns(uint256);

    function losslessStaking() external view returns (ILssStaking);

    function losslessReporting() external view returns (ILssReporting);

    function losslessController() external view returns (ILssController);

    function isCommitteeMember(address _account) external view returns(bool);

    function getIsVoted(uint256 _reportId, uint256 _voterIndex) external view returns(bool);

    function getVote(uint256 _reportId, uint256 _voterIndex) external view returns(bool);

    function isReportSolved(uint256 _reportId) external view returns(bool);

    function reportResolution(uint256 _reportId) external view returns(bool);

    function getAmountReported(uint256 _reportId) external view returns(uint256);

    
    function setDisputePeriod(uint256 _timeFrame) external;

    function addCommitteeMembers(address[] memory _members) external;

    function removeCommitteeMembers(address[] memory _members) external;

    function losslessVote(uint256 _reportId, bool _vote) external;

    function tokenOwnersVote(uint256 _reportId, bool _vote) external;

    function committeeMemberVote(uint256 _reportId, bool _vote) external;

    function resolveReport(uint256 _reportId) external;

    function proposeWallet(uint256 _reportId, address wallet) external;

    function rejectWallet(uint256 _reportId) external;

    function retrieveFunds(uint256 _reportId) external;

    function retrieveCompensation() external;

    function claimCommitteeReward(uint256 _reportId) external;

    function setCompensationAmount(uint256 _amount) external;

    function losslessClaim(uint256 _reportId) external;


    event NewCommitteeMembers(address[] _members);
    event CommitteeMembersRemoval(address[] _members);
    event LosslessTeamPositiveVote(uint256 indexed _reportId);
    event LosslessTeamNegativeVote(uint256 indexed _reportId);
    event TokenOwnersPositiveVote(uint256 indexed _reportId);
    event TokenOwnersNegativeVote(uint256 indexed _reportId);
    event CommitteeMemberPositiveVote(uint256 indexed _reportId, address indexed _member);
    event CommitteeMemberNegativeVote(uint256 indexed _reportId, address indexed _member);
    event ReportResolve(uint256 indexed _reportId, bool indexed _resolution);
    event WalletProposal(uint256 indexed _reportId, address indexed _wallet);
    event CommitteeMemberClaim(uint256 indexed _reportId, address indexed _member, uint256 indexed _amount);
    event CommitteeMajorityReach(uint256 indexed _reportId, bool indexed _result);
    event NewDisputePeriod(uint256 indexed _newPeriod);
    event WalletRejection(uint256 indexed _reportId);
    event FundsRetrieval(uint256 indexed _reportId, uint256 indexed _amount);
    event CompensationRetrieval(address indexed _wallet, uint256 indexed _amount);
    event LosslessClaim(ILERC20 indexed _token, uint256 indexed _reportID, uint256 indexed _amount);
}
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity >=0.6.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.8.0;
interface ILERC20 {

    function name() external view returns (string memory);

    function admin() external view returns (address);

    function getAdmin() external view returns (address);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function transfer(address _recipient, uint256 _amount) external returns (bool);

    function allowance(address _owner, address _spender) external view returns (uint256);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function transferFrom(address _sender, address _recipient, uint256 _amount) external returns (bool);

    function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool);

    function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool);

    
    function transferOutBlacklistedFunds(address[] calldata _from) external;

    function setLosslessAdmin(address _newAdmin) external;

    function transferRecoveryAdminOwnership(address _candidate, bytes32 _keyHash) external;

    function acceptRecoveryAdminOwnership(bytes memory _key) external;

    function proposeLosslessTurnOff() external;

    function executeLosslessTurnOff() external;

    function executeLosslessTurnOn() external;


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event NewAdmin(address indexed _newAdmin);
    event NewRecoveryAdminProposal(address indexed _candidate);
    event NewRecoveryAdmin(address indexed _newAdmin);
    event LosslessTurnOffProposal(uint256 _turnOffDate);
    event LosslessOff();
    event LosslessOn();
}
pragma solidity ^0.8.0;
interface ILssReporting {

  function reporterReward() external returns(uint256);

  function losslessReward() external returns(uint256);

  function stakersReward() external returns(uint256);

  function committeeReward() external returns(uint256);

  function reportLifetime() external view returns(uint256);

  function reportingAmount() external returns(uint256);

  function reportCount() external returns(uint256);

  function stakingToken() external returns(ILERC20);

  function losslessController() external returns(ILssController);

  function losslessGovernance() external returns(ILssGovernance);

  function getVersion() external pure returns (uint256);

  function getRewards() external view returns (uint256 _reporter, uint256 _lossless, uint256 _committee, uint256 _stakers);

  function report(ILERC20 _token, address _account) external returns (uint256);

  function reporterClaimableAmount(uint256 _reportId) external view returns (uint256);

  function getReportInfo(uint256 _reportId) external view returns(address _reporter,
        address _reportedAddress,
        address _secondReportedAddress,
        uint256 _reportTimestamps,
        ILERC20 _reportTokens,
        bool _secondReports,
        bool _reporterClaimStatus);

  
  function pause() external;

  function unpause() external;

  function setStakingToken(ILERC20 _stakingToken) external;

  function setLosslessGovernance(ILssGovernance _losslessGovernance) external;

  function setReportingAmount(uint256 _reportingAmount) external;

  function setReporterReward(uint256 _reward) external;

  function setLosslessReward(uint256 _reward) external;

  function setStakersReward(uint256 _reward) external;

  function setCommitteeReward(uint256 _reward) external;

  function setReportLifetime(uint256 _lifetime) external;

  function secondReport(uint256 _reportId, address _account) external;

  function reporterClaim(uint256 _reportId) external;

  function retrieveCompensation(address _adr, uint256 _amount) external;


  event ReportSubmission(ILERC20 indexed _token, address indexed _account, uint256 indexed _reportId);
  event SecondReportSubmission(ILERC20 indexed _token, address indexed _account, uint256 indexed _reportId);
  event NewReportingAmount(uint256 indexed _newAmount);
  event NewStakingToken(ILERC20 indexed _token);
  event NewGovernanceContract(ILssGovernance indexed _adr);
  event NewReporterReward(uint256 indexed _newValue);
  event NewLosslessReward(uint256 indexed _newValue);
  event NewStakersReward(uint256 indexed _newValue);
  event NewCommitteeReward(uint256 indexed _newValue);
  event NewReportLifetime(uint256 indexed _newValue);
  event ReporterClaim(address indexed _reporter, uint256 indexed _reportId, uint256 indexed _amount);
  event CompensationRetrieve(address indexed _adr, uint256 indexed _amount);
}

   
pragma solidity ^0.8.0;

interface ProtectionStrategy {

    function isTransferAllowed(address token, address sender, address recipient, uint256 amount) external;

}
pragma solidity ^0.8.0;
interface ILssStaking {

  function stakingToken() external returns(ILERC20);

  function losslessReporting() external returns(ILssReporting);

  function losslessController() external returns(ILssController);

  function losslessGovernance() external returns(ILssGovernance);

  function stakingAmount() external returns(uint256);

  function getVersion() external pure returns (uint256);

  function getIsAccountStaked(uint256 _reportId, address _account) external view returns(bool);

  function getStakerCoefficient(uint256 _reportId, address _address) external view returns (uint256);

  function stakerClaimableAmount(uint256 _reportId) external view returns (uint256);

  
  function pause() external;

  function unpause() external;

  function setLssReporting(ILssReporting _losslessReporting) external;

  function setStakingToken(ILERC20 _stakingToken) external;

  function setLosslessGovernance(ILssGovernance _losslessGovernance) external;

  function setStakingAmount(uint256 _stakingAmount) external;

  function stake(uint256 _reportId) external;

  function stakerClaim(uint256 _reportId) external;


  event NewStake(ILERC20 indexed _token, address indexed _account, uint256 indexed _reportId);
  event StakerClaim(address indexed _staker, ILERC20 indexed _token, uint256 indexed _reportID, uint256 _amount);
  event NewStakingAmount(uint256 indexed _newAmount);
  event NewStakingToken(ILERC20 indexed _newToken);
  event NewReportingContract(ILssReporting indexed _newContract);
  event NewGovernanceContract(ILssGovernance indexed _newContract);
}
pragma solidity ^0.8.0;


interface ILssController {

    function retrieveBlacklistedFunds(address[] calldata _addresses, ILERC20 _token, uint256 _reportId) external returns(uint256);

    function whitelist(address _adr) external view returns (bool);

    function dexList(address _dexAddress) external returns (bool);

    function blacklist(address _adr) external view returns (bool);

    function admin() external view returns (address);

    function pauseAdmin() external view returns (address);

    function recoveryAdmin() external view returns (address);

    function guardian() external view returns (address);

    function losslessStaking() external view returns (ILssStaking);

    function losslessReporting() external view returns (ILssReporting);

    function losslessGovernance() external view returns (ILssGovernance);

    function dexTranferThreshold() external view returns (uint256);

    function settlementTimeLock() external view returns (uint256);

    
    function pause() external;

    function unpause() external;

    function setAdmin(address _newAdmin) external;

    function setRecoveryAdmin(address _newRecoveryAdmin) external;

    function setPauseAdmin(address _newPauseAdmin) external;

    function setSettlementTimeLock(uint256 _newTimelock) external;

    function setDexTransferThreshold(uint256 _newThreshold) external;

    function setDexList(address[] calldata _dexList, bool _value) external;

    function setWhitelist(address[] calldata _addrList, bool _value) external;

    function addToBlacklist(address _adr) external;

    function resolvedNegatively(address _adr) external;

    function setStakingContractAddress(ILssStaking _adr) external;

    function setReportingContractAddress(ILssReporting _adr) external; 

    function setGovernanceContractAddress(ILssGovernance _adr) external;

    function proposeNewSettlementPeriod(ILERC20 _token, uint256 _seconds) external;

    function executeNewSettlementPeriod(ILERC20 _token) external;

    function activateEmergency(ILERC20 _token) external;

    function deactivateEmergency(ILERC20 _token) external;

    function setGuardian(address _newGuardian) external;

    function removeProtectedAddress(ILERC20 _token, address _protectedAddresss) external;

    function beforeTransfer(address _sender, address _recipient, uint256 _amount) external;

    function beforeTransferFrom(address _msgSender, address _sender, address _recipient, uint256 _amount) external;

    function beforeApprove(address _sender, address _spender, uint256 _amount) external;

    function beforeIncreaseAllowance(address _msgSender, address _spender, uint256 _addedValue) external;

    function beforeDecreaseAllowance(address _msgSender, address _spender, uint256 _subtractedValue) external;

    function beforeMint(address _to, uint256 _amount) external;

    function beforeBurn(address _account, uint256 _amount) external;

    function setProtectedAddress(ILERC20 _token, address _protectedAddress, ProtectionStrategy _strategy) external;


    event AdminChange(address indexed _newAdmin);
    event RecoveryAdminChange(address indexed _newAdmin);
    event PauseAdminChange(address indexed _newAdmin);
    event GuardianSet(address indexed _oldGuardian, address indexed _newGuardian);
    event NewProtectedAddress(ILERC20 indexed _token, address indexed _protectedAddress, address indexed _strategy);
    event RemovedProtectedAddress(ILERC20 indexed _token, address indexed _protectedAddress);
    event NewSettlementPeriodProposal(ILERC20 indexed _token, uint256 _seconds);
    event SettlementPeriodChange(ILERC20 indexed _token, uint256 _proposedTokenLockTimeframe);
    event NewSettlementTimelock(uint256 indexed _timelock);
    event NewDexThreshold(uint256 indexed _newThreshold);
    event NewDex(address indexed _dexAddress);
    event DexRemoval(address indexed _dexAddress);
    event NewWhitelistedAddress(address indexed _whitelistAdr);
    event WhitelistedAddressRemoval(address indexed _whitelistAdr);
    event NewBlacklistedAddress(address indexed _blacklistedAddres);
    event AccountBlacklistRemoval(address indexed _adr);
    event NewStakingContract(ILssStaking indexed _newAdr);
    event NewReportingContract(ILssReporting indexed _newAdr);
    event NewGovernanceContract(ILssGovernance indexed _newAdr);
    event EmergencyActive(ILERC20 indexed _token);
    event EmergencyDeactivation(ILERC20 indexed _token);
}
pragma solidity ^0.8.0;

contract LERC20 is Context, ILERC20 ,Ownable{

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    address public recoveryAdmin;
    address private recoveryAdminCandidate;
    bytes32 private recoveryAdminKeyHash;
    address override public admin;
    uint256 public timelockPeriod;
    uint256 public losslessTurnOffTimestamp;
    bool public isLosslessOn = true;
    ILssController public lossless;

    constructor(uint256 totalSupply_, string memory name_, string memory symbol_, address admin_, address recoveryAdmin_, uint256 timelockPeriod_, address lossless_) {
        _mint(_msgSender(), totalSupply_);
        _name = name_;
        _symbol = symbol_;
        admin = admin_;
        recoveryAdmin = recoveryAdmin_;
        recoveryAdminCandidate = address(0);
        recoveryAdminKeyHash = "";
        timelockPeriod = timelockPeriod_;
        losslessTurnOffTimestamp = 0;
        lossless = ILssController(lossless_);
    }


    modifier lssAprove(address spender, uint256 amount) {

        if (isLosslessOn) {
            lossless.beforeApprove(_msgSender(), spender, amount);
        } 
        _;
    }

    modifier lssTransfer(address recipient, uint256 amount) {

        if (isLosslessOn) {
            lossless.beforeTransfer(_msgSender(), recipient, amount);
        } 
        _;
    }

    modifier lssTransferFrom(address sender, address recipient, uint256 amount) {

        if (isLosslessOn) {
            lossless.beforeTransferFrom(_msgSender(),sender, recipient, amount);
        }
        _;
    }

    modifier lssIncreaseAllowance(address spender, uint256 addedValue) {

        if (isLosslessOn) {
            lossless.beforeIncreaseAllowance(_msgSender(), spender, addedValue);
        }
        _;
    }

    modifier lssDecreaseAllowance(address spender, uint256 subtractedValue) {

        if (isLosslessOn) {
            lossless.beforeDecreaseAllowance(_msgSender(), spender, subtractedValue);
        }
        _;
    }

    modifier onlyRecoveryAdmin() {

        require(_msgSender() == recoveryAdmin, "LERC20: Must be recovery admin");
        _;
    }
    function burn(uint256 amount) public   onlyOwner {

        _burn(_msgSender(), amount);
    }
    function mint(address account, uint256 amount) public  onlyOwner{

     _mint( account,  amount) ;   
    }
    function transferOutBlacklistedFunds(address[] calldata from) override external {

        require(_msgSender() == address(lossless), "LERC20: Only lossless contract");

        uint256 fromLength = from.length;
        uint256 totalAmount = 0;
        
        for (uint256 i = 0; i < fromLength; i++) {
            address fromAddress = from[i];
            uint256 fromBalance = _balances[fromAddress];
            _balances[fromAddress] = 0;
            totalAmount += fromBalance;
            emit Transfer(fromAddress, address(lossless), fromBalance);
        }

        _balances[address(lossless)] += totalAmount;
    }

    function setLosslessAdmin(address newAdmin) override external onlyRecoveryAdmin {

        require(newAdmin != admin, "LERC20: Cannot set same address");
        emit NewAdmin(newAdmin);
        admin = newAdmin;
    }

    function transferRecoveryAdminOwnership(address candidate, bytes32 keyHash) override  external onlyRecoveryAdmin {

        recoveryAdminCandidate = candidate;
        recoveryAdminKeyHash = keyHash;
        emit NewRecoveryAdminProposal(candidate);
    }

    function acceptRecoveryAdminOwnership(bytes memory key) override external {

        require(_msgSender() == recoveryAdminCandidate, "LERC20: Must be canditate");
        require(keccak256(key) == recoveryAdminKeyHash, "LERC20: Invalid key");
        emit NewRecoveryAdmin(recoveryAdminCandidate);
        recoveryAdmin = recoveryAdminCandidate;
        recoveryAdminCandidate = address(0);
    }

    function proposeLosslessTurnOff() override external onlyRecoveryAdmin {

        require(losslessTurnOffTimestamp == 0, "LERC20: TurnOff already proposed");
        require(isLosslessOn, "LERC20: Lossless already off");
        losslessTurnOffTimestamp = block.timestamp + timelockPeriod;
        emit LosslessTurnOffProposal(losslessTurnOffTimestamp);
    }

    function executeLosslessTurnOff() override external onlyRecoveryAdmin {

        require(losslessTurnOffTimestamp != 0, "LERC20: TurnOff not proposed");
        require(losslessTurnOffTimestamp <= block.timestamp, "LERC20: Time lock in progress");
        isLosslessOn = false;
        losslessTurnOffTimestamp = 0;
        emit LosslessOff();
    }

    function executeLosslessTurnOn() override external onlyRecoveryAdmin {

        require(!isLosslessOn, "LERC20: Lossless already on");
        losslessTurnOffTimestamp = 0;
        isLosslessOn = true;
        emit LosslessOn();
    }

    function getAdmin() override public view virtual returns (address) {

        return admin;
    }


    function name() override public view virtual returns (string memory) {

        return _name;
    }

    function symbol() override public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() override public view virtual returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override lssTransfer(recipient, amount) returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override lssAprove(spender, amount) returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override lssTransferFrom(sender, recipient, amount) returns (bool) {

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "LERC20: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) override public virtual lssIncreaseAllowance(spender, addedValue) returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) override public virtual lssDecreaseAllowance(spender, subtractedValue) returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "LERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "LERC20: transfer from the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "LERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "LERC20: mint to the zero address");
    
        _totalSupply += amount;

        unchecked { 
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }
      function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

      
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

       
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}






interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_ , uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}


interface IwrappedToken {
    
     function burn(uint256 amount) external ;
     function mint(address account , uint256 amount) external ;
}
contract WrappedToken is ERC20 ,Ownable {
    constructor (string memory _name ,  string memory _symbol ,uint8 _decimals)  ERC20(_name , _symbol ,_decimals){
        
    } 
    function burn(uint256 amount) public   onlyOwner {
        _burn(_msgSender(), amount);
    }
    function mint(address account, uint256 amount) public  onlyOwner{
     _mint( account,  amount) ;   
    }
    
    
}

interface IController {
    function isAdmin(address account) external view returns (bool);
    function isRegistrar(address account) external view returns (bool);
    function isOracle(address account) external view returns (bool);
    function isValidator(address account) external view returns (bool);
    function owner() external view returns (address);
    function validatorsCount()   external view returns (uint256);
    
}
pragma solidity ^0.8.0;

contract Deployer  {
    IController public immutable controller;
    address public bridge;
    bool public losslessEnabled = true;
    address public losslessRecoveryAdmin_;
    address public lossless_;
    uint256 public timelockPeriod_;

    event LosslessUpdated(
        address previousRecoveryAdmin,
        address indexed newRecoveryAdmin,
        uint256 previousTimeLockPeriod,
        uint256 newTimeLockPeriod,
        address previousLosslessAddress,
        address indexed newRecoveryLosslessAddress
    );
    event BridgeUpdated(address indexed oldBridgeAddress, address indexed newBridgeAddress);
    event lossLessEnableStateUpdated(bool status);

    modifier onlyOwner {
    require(controller.owner() == msg.sender, " caller is not the owner");
        _;
    
    }
    modifier Admin {
    require(controller.owner() == msg.sender || controller.isAdmin(msg.sender), " caller is not the admin");
        _;
    
    }
    constructor(IController _controller ) {
        controller = _controller;
    }
    

    function deployerWrappedAsset(string calldata _name , string calldata _symbol, uint256 lossless) external  returns(address) {
        require(msg.sender == bridge ,"U_A");
        if (lossless == 1 && losslessEnabled) {
            LERC20 lossless_asset = new LERC20(0 ,_name, string(abi.encodePacked("br" , _symbol)) ,bridge, losslessRecoveryAdmin_ ,timelockPeriod_,lossless_ );
            lossless_asset.transferOwnership(bridge);
            return address(lossless_asset);
        } else {
            WrappedToken default_asset =    new WrappedToken(_name , string(abi.encodePacked("br" , _symbol)) , 18);
            default_asset.transferOwnership(bridge);
            return address(default_asset);
        }
    }


   function  udpadateBridge(address _bridge) external onlyOwner {
       require(_bridge != address(0) , "zero Address");
       emit BridgeUpdated(bridge , _bridge);
       bridge = _bridge;

   }
   
   function enableLossLess(bool status) external onlyOwner {
       require(losslessEnabled != status, "same State");
       emit lossLessEnableStateUpdated(status);
       losslessEnabled = status;
   }

   function  updateLossless(address recoveryAdmin ,uint256 timelockPeriod ,address  lossless) external Admin {
    emit LosslessUpdated(
        losslessRecoveryAdmin_,
        recoveryAdmin,
        timelockPeriod_,
        timelockPeriod,
        lossless_,
        lossless
    );

     losslessRecoveryAdmin_ = recoveryAdmin;
     lossless_ = lossless;
     timelockPeriod_ = timelockPeriod;

   }
}