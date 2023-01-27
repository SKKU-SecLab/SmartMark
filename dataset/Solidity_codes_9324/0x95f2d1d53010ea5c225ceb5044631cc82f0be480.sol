
pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT
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
}pragma solidity ^0.8.0;

interface ProtectionStrategy {

    function isTransferAllowed(address token, address sender, address recipient, uint256 amount) external;

}// MIT
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
}// MIT
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


  event ReportSubmission(ILERC20 indexed _token, address indexed _account, uint256 indexed _reportId, uint256 _amount);
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
}// MIT
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


  event NewStake(ILERC20 indexed _token, address indexed _account, uint256 indexed _reportId, uint256 _amount);
  event StakerClaim(address indexed _staker, ILERC20 indexed _token, uint256 indexed _reportID, uint256 _amount);
  event NewStakingAmount(uint256 indexed _newAmount);
  event NewStakingToken(ILERC20 indexed _newToken);
  event NewReportingContract(ILssReporting indexed _newContract);
  event NewGovernanceContract(ILssGovernance indexed _newContract);
}// MIT
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
    event NewCompensationPercentage(uint256 indexed _compensationPercentage);
}// MIT
pragma solidity ^0.8.0;



contract LosslessControllerV3 is ILssController, Initializable, ContextUpgradeable, PausableUpgradeable {

    

    address override public pauseAdmin;
    address override public admin;
    address override public recoveryAdmin;


    address override public guardian;
    mapping(ILERC20 => Protections) private tokenProtections;

    struct Protection {
        bool isProtected;
        ProtectionStrategy strategy;
    }

    struct Protections {
        mapping(address => Protection) protections;
    }


    ILssStaking override public losslessStaking;
    ILssReporting override public losslessReporting;
    ILssGovernance override public losslessGovernance;

    struct LocksQueue {
        mapping(uint256 => ReceiveCheckpoint) lockedFunds;
        uint256 touchedTimestamp;
        uint256 first;
        uint256 last;
    }

    struct TokenLockedFunds {
        mapping(address => LocksQueue) queue;
    }

    mapping(ILERC20 => TokenLockedFunds) private tokenScopedLockedFunds;
    
    struct ReceiveCheckpoint {
        uint256 amount;
        uint256 timestamp;
        uint256 cummulativeAmount;
    }
    
    uint256 public constant HUNDRED = 1e2;
    uint256 override public dexTranferThreshold;
    uint256 override public settlementTimeLock;

    mapping(address => bool) override public dexList;
    mapping(address => bool) override public whitelist;
    mapping(address => bool) override public blacklist;

    struct TokenConfig {
        uint256 tokenLockTimeframe;
        uint256 proposedTokenLockTimeframe;
        uint256 changeSettlementTimelock;
        uint256 emergencyMode;
    }

    mapping(ILERC20 => TokenConfig) tokenConfig;


    modifier onlyLosslessRecoveryAdmin() {

        require(msg.sender == recoveryAdmin, "LSS: Must be recoveryAdmin");
        _;
    }

    modifier onlyLosslessAdmin() {

        require(msg.sender == admin, "LSS: Must be admin");
        _;
    }

    modifier onlyPauseAdmin() {

        require(msg.sender == pauseAdmin, "LSS: Must be pauseAdmin");
        _;
    }


    modifier onlyGuardian() {

        require(msg.sender == guardian, "LOSSLESS: Must be Guardian");
        _;
    }


    modifier onlyLosslessEnv {

        require(msg.sender == address(losslessStaking)   ||
                msg.sender == address(losslessReporting) || 
                msg.sender == address(losslessGovernance),
                "LSS: Lss SC only");
        _;
    }


    function getVersion() external pure returns (uint256) {

        return 3;
    }


    function isAddressProtected(ILERC20 _token, address _protectedAddress) public view returns (bool) {

        return tokenProtections[_token].protections[_protectedAddress].isProtected;
    }

    function getProtectedAddressStrategy(ILERC20 _token, address _protectedAddress) external view returns (address) {

        require(isAddressProtected(_token, _protectedAddress), "LSS: Address not protected");
        return address(tokenProtections[_token].protections[_protectedAddress].strategy);
    }


    function pause() override public onlyPauseAdmin  {

        _pause();
    }    
    
    function unpause() override public onlyPauseAdmin {

        _unpause();
    }

    function setAdmin(address _newAdmin) override public onlyLosslessRecoveryAdmin {

        require(_newAdmin != admin, "LERC20: Cannot set same address");
        emit AdminChange(_newAdmin);
        admin = _newAdmin;
    }

    function setRecoveryAdmin(address _newRecoveryAdmin) override public onlyLosslessRecoveryAdmin {

        require(_newRecoveryAdmin != recoveryAdmin, "LERC20: Cannot set same address");
        emit RecoveryAdminChange(_newRecoveryAdmin);
        recoveryAdmin = _newRecoveryAdmin;
    }

    function setPauseAdmin(address _newPauseAdmin) override public onlyLosslessRecoveryAdmin {

        require(_newPauseAdmin != pauseAdmin, "LERC20: Cannot set same address");
        emit PauseAdminChange(_newPauseAdmin);
        pauseAdmin = _newPauseAdmin;
    }



    function setSettlementTimeLock(uint256 _newTimelock) override public onlyLosslessAdmin {

        require(_newTimelock != settlementTimeLock, "LSS: Cannot set same value");
        settlementTimeLock = _newTimelock;
        emit NewSettlementTimelock(settlementTimeLock);
    }

    function setDexTransferThreshold(uint256 _newThreshold) override public onlyLosslessAdmin {

        require(_newThreshold != dexTranferThreshold, "LSS: Cannot set same value");
        dexTranferThreshold = _newThreshold;
        emit NewDexThreshold(dexTranferThreshold);
    }
    
    function setDexList(address[] calldata _dexList, bool _value) override public onlyLosslessAdmin {

        for(uint256 i = 0; i < _dexList.length;) {

            address adr = _dexList[i];
            require(!blacklist[adr], "LSS: An address is blacklisted");

            dexList[adr] = _value;

            if (_value) {
                emit NewDex(adr);
            } else {
                emit DexRemoval(adr);
            }

            unchecked{i++;}
        }
    }

    function setWhitelist(address[] calldata _addrList, bool _value) override public onlyLosslessAdmin {

        for(uint256 i = 0; i < _addrList.length;) {

            address adr = _addrList[i];
            require(!blacklist[adr], "LSS: An address is blacklisted");

            whitelist[adr] = _value;

            if (_value) {
                emit NewWhitelistedAddress(adr);
            } else {
                emit WhitelistedAddressRemoval(adr);
            }

            unchecked{i++;}
        }
    }

    function addToBlacklist(address _adr) override public onlyLosslessEnv {

        blacklist[_adr] = true;
        emit NewBlacklistedAddress(_adr);
    }

    function resolvedNegatively(address _adr) override public onlyLosslessEnv {

        blacklist[_adr] = false;
        emit AccountBlacklistRemoval(_adr);
    }
    
    function setStakingContractAddress(ILssStaking _adr) override public onlyLosslessAdmin {

        require(address(_adr) != address(0), "LERC20: Cannot be zero address");
        require(_adr != losslessStaking, "LSS: Cannot set same value");
        losslessStaking = _adr;
        emit NewStakingContract(_adr);
    }

    function setReportingContractAddress(ILssReporting _adr) override public onlyLosslessAdmin {

        require(address(_adr) != address(0), "LERC20: Cannot be zero address");
        require(_adr != losslessReporting, "LSS: Cannot set same value");
        losslessReporting = _adr;
        emit NewReportingContract(_adr);
    }

    function setGovernanceContractAddress(ILssGovernance _adr) override public onlyLosslessAdmin {

        require(address(_adr) != address(0), "LERC20: Cannot be zero address");
        require(_adr != losslessGovernance, "LSS: Cannot set same value");
        losslessGovernance = _adr;
        emit NewGovernanceContract(_adr);
    }

    function proposeNewSettlementPeriod(ILERC20 _token, uint256 _seconds) override public {


        TokenConfig storage config = tokenConfig[_token];

        require(msg.sender == _token.admin(), "LSS: Must be Token Admin");
        require(config.changeSettlementTimelock <= block.timestamp, "LSS: Time lock in progress");
        config.changeSettlementTimelock = block.timestamp + settlementTimeLock;
        config.proposedTokenLockTimeframe = _seconds;
        emit NewSettlementPeriodProposal(_token, _seconds);
    }

    function executeNewSettlementPeriod(ILERC20 _token) override public {


        TokenConfig storage config = tokenConfig[_token];

        require(msg.sender == _token.admin(), "LSS: Must be Token Admin");
        require(config.proposedTokenLockTimeframe != 0, "LSS: New Settlement not proposed");
        require(config.changeSettlementTimelock <= block.timestamp, "LSS: Time lock in progress");
        config.tokenLockTimeframe = config.proposedTokenLockTimeframe;
        config.proposedTokenLockTimeframe = 0; 
        emit SettlementPeriodChange(_token, config.tokenLockTimeframe);
    }

    function activateEmergency(ILERC20 _token) override external onlyLosslessEnv {

        tokenConfig[_token].emergencyMode = block.timestamp;
        emit EmergencyActive(_token);
    }

    function deactivateEmergency(ILERC20 _token) override external onlyLosslessEnv {

        tokenConfig[_token].emergencyMode = 0;
        emit EmergencyDeactivation(_token);
    }


    function setGuardian(address _newGuardian) override external onlyLosslessAdmin whenNotPaused {

        require(_newGuardian != address(0), "LSS: Cannot be zero address");
        emit GuardianSet(guardian, _newGuardian);
        guardian = _newGuardian;
    }

    function setProtectedAddress(ILERC20 _token, address _protectedAddress, ProtectionStrategy _strategy) override external onlyGuardian whenNotPaused {

        Protection storage protection = tokenProtections[_token].protections[_protectedAddress];
        protection.isProtected = true;
        protection.strategy = _strategy;
        emit NewProtectedAddress(_token, _protectedAddress, address(_strategy));
    }

    function removeProtectedAddress(ILERC20 _token, address _protectedAddress) override external onlyGuardian whenNotPaused {

        require(isAddressProtected(_token, _protectedAddress), "LSS: Address not protected");
        delete tokenProtections[_token].protections[_protectedAddress];
        emit RemovedProtectedAddress(_token, _protectedAddress);
    }

    function _getLatestOudatedCheckpoint(LocksQueue storage queue) private view returns (uint256, uint256) {

        uint256 lower = queue.first;
        uint256 upper = queue.last;
        uint256 currentTimestamp = block.timestamp;
        uint256 center = queue.first;
        ReceiveCheckpoint memory cp = queue.lockedFunds[queue.last];
        ReceiveCheckpoint memory lowestCp = queue.lockedFunds[queue.first];

        while (upper > lower) {
            center = upper - ((upper - lower) >> 1); // ceil, avoiding overflow
            cp = queue.lockedFunds[center];
            if (cp.timestamp == currentTimestamp) {
                return (cp.cummulativeAmount, center + 1);
            } else if (cp.timestamp < currentTimestamp) {
                lowestCp = cp;
                lower = center;
            }  else {
                upper = center - 1;
                center = upper;
            }
        }

        if (lowestCp.timestamp < currentTimestamp) {
            if (cp.timestamp < lowestCp.timestamp) {
                return (cp.cummulativeAmount, center);
            } else {
                return (lowestCp.cummulativeAmount, lower);
            }
        } else {
            return (0, center);
        }
    }

    function _getAvailableAmount(ILERC20 _token, address account) private returns (uint256 amount) {

        LocksQueue storage queue = tokenScopedLockedFunds[_token].queue[account];
        ReceiveCheckpoint storage cp = queue.lockedFunds[queue.last];
        (uint256 outdatedCummulative, uint256 newFirst) = _getLatestOudatedCheckpoint(queue);
        queue.first = newFirst;

        require(cp.cummulativeAmount >= outdatedCummulative, "LSS: Transfers limit reached");
        cp.cummulativeAmount = cp.cummulativeAmount - outdatedCummulative;
        return _token.balanceOf(account) - cp.cummulativeAmount;
    }


    function _enqueueLockedFunds(ReceiveCheckpoint memory _checkpoint, address _recipient) private {

        LocksQueue storage queue;

        queue = tokenScopedLockedFunds[ILERC20(msg.sender)].queue[_recipient];

        uint256 lastItem = queue.last;
        ReceiveCheckpoint storage lastCheckpoint = queue.lockedFunds[lastItem];

        if (lastCheckpoint.timestamp < _checkpoint.timestamp) {
            _checkpoint.cummulativeAmount = _checkpoint.amount + lastCheckpoint.cummulativeAmount;
            queue.lockedFunds[lastItem + 1] = _checkpoint;
            queue.last += 1;

        } else {
            lastCheckpoint.amount += _checkpoint.amount;
            lastCheckpoint.cummulativeAmount += _checkpoint.amount;
        } 

        if (queue.first == 0) {
            queue.first += 1;
        }
    }


    function retrieveBlacklistedFunds(address[] calldata _addresses, ILERC20 _token, uint256 _reportId) override public onlyLosslessEnv returns(uint256){

        uint256 totalAmount = losslessGovernance.getAmountReported(_reportId);
        
        _token.transferOutBlacklistedFunds(_addresses);
                
        (uint256 reporterReward, uint256 losslessReward, uint256 committeeReward, uint256 stakersReward) = losslessReporting.getRewards();

        uint256 toLssStaking = totalAmount * stakersReward / HUNDRED;
        uint256 toLssReporting = totalAmount * reporterReward / HUNDRED;
        uint256 toLssGovernance = totalAmount - toLssStaking - toLssReporting;

        require(_token.transfer(address(losslessStaking), toLssStaking), "LSS: Staking retrieval failed");
        require(_token.transfer(address(losslessReporting), toLssReporting), "LSS: Reporting retrieval failed");
        require(_token.transfer(address(losslessGovernance), toLssGovernance), "LSS: Governance retrieval failed");

        return totalAmount - toLssStaking - toLssReporting - (totalAmount * (committeeReward + losslessReward) / HUNDRED);
    }


    function _removeUsedUpLocks (uint256 _availableAmount, address _account, uint256 _amount) private {
        LocksQueue storage queue;
        ILERC20 token = ILERC20(msg.sender);
        queue = tokenScopedLockedFunds[token].queue[_account];
        require(queue.touchedTimestamp + tokenConfig[token].tokenLockTimeframe <= block.timestamp, "LSS: Transfers limit reached");
        uint256 amountLeft = _amount - _availableAmount;
        ReceiveCheckpoint storage cp = queue.lockedFunds[queue.last];
        cp.cummulativeAmount -= amountLeft;
        queue.touchedTimestamp = block.timestamp;

        ReceiveCheckpoint storage firstCp = queue.lockedFunds[queue.first];
        if (firstCp.timestamp < block.timestamp) {
            firstCp.cummulativeAmount = 0;
        }
    }


    function _evaluateTransfer(address _sender, address _recipient, uint256 _amount) private returns (bool) {

        ILERC20 token = ILERC20(msg.sender);

        uint256 settledAmount = _getAvailableAmount(token, _sender);
        
        TokenConfig storage config = tokenConfig[token];

        if (_amount > settledAmount) {
            require(config.emergencyMode + config.tokenLockTimeframe < block.timestamp,
                    "LSS: Emergency mode active, cannot transfer unsettled tokens");
            if (dexList[_recipient]) {
                require(_amount - settledAmount <= dexTranferThreshold,
                        "LSS: Cannot transfer over the dex threshold");
            } else { 
                _removeUsedUpLocks(settledAmount, _sender, _amount);
            }
        }

        ReceiveCheckpoint memory newCheckpoint = ReceiveCheckpoint(_amount, block.timestamp + config.tokenLockTimeframe, 0);
        _enqueueLockedFunds(newCheckpoint, _recipient);
        return true;
    }

    function beforeTransfer(address _sender, address _recipient, uint256 _amount) override external {

        ILERC20 token = ILERC20(msg.sender);
        if (tokenProtections[token].protections[_sender].isProtected) {
            tokenProtections[token].protections[_sender].strategy.isTransferAllowed(msg.sender, _sender, _recipient, _amount);
        }

        require(!blacklist[_sender], "LSS: You cannot operate");
        
        if (tokenConfig[token].tokenLockTimeframe != 0) {
            _evaluateTransfer(_sender, _recipient, _amount);
        }
    }

    function beforeTransferFrom(address _msgSender, address _sender, address _recipient, uint256 _amount) override external {

        ILERC20 token = ILERC20(msg.sender);

        if (tokenProtections[token].protections[_sender].isProtected) {
            tokenProtections[token].protections[_sender].strategy.isTransferAllowed(msg.sender, _sender, _recipient, _amount);
        }

        require(!blacklist[_msgSender], "LSS: You cannot operate");
        require(!blacklist[_sender], "LSS: Sender is blacklisted");

        if (tokenConfig[token].tokenLockTimeframe != 0) {
            _evaluateTransfer(_sender, _recipient, _amount);
        }

    }

    
    function beforeMint(address _to, uint256 _amount) override external {}


    function beforeApprove(address _sender, address _spender, uint256 _amount) override external {}


    function beforeBurn(address _account, uint256 _amount) override external {}


    function beforeIncreaseAllowance(address _msgSender, address _spender, uint256 _addedValue) override external {}


    function beforeDecreaseAllowance(address _msgSender, address _spender, uint256 _subtractedValue) override external {}




    function afterMint(address _to, uint256 _amount) external {}


    function afterApprove(address _sender, address _spender, uint256 _amount) external {}


    function afterBurn(address _account, uint256 _amount) external {}


    function afterTransfer(address _sender, address _recipient, uint256 _amount) external {}


    function afterTransferFrom(address _msgSender, address _sender, address _recipient, uint256 _amount) external {}


    function afterIncreaseAllowance(address _sender, address _spender, uint256 _addedValue) external {}


    function afterDecreaseAllowance(address _sender, address _spender, uint256 _subtractedValue) external {}

}