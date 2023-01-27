
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

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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

    function setRevshareAdmin(address _address) external;

    function setRevsharePercentage(uint256 _amount) external;

    function revshareClaim(uint256 _reportId) external;


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
    event NewRevshareAdmin(address indexed _revshareAdmin);
    event NewRevsharePercentage(uint256 indexed _revsharePercentage);
    event RevshareClaim(ILERC20 indexed _token, uint256 indexed _reportID, uint256 indexed _amount);
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
}// Unlicensed
pragma solidity ^0.8.0;



contract LosslessGovernance is ILssGovernance, Initializable, AccessControlUpgradeable, PausableUpgradeable {


    uint256 override public constant LSS_TEAM_INDEX = 0;
    uint256 override public constant TOKEN_OWNER_INDEX = 1;
    uint256 override public constant COMMITEE_INDEX = 2;

    bytes32 public constant COMMITTEE_ROLE = keccak256("COMMITTEE_ROLE");

    uint256 override public committeeMembersCount;

    uint256 override public walletDisputePeriod;

    uint256 public compensationPercentage;

    uint256 public constant HUNDRED = 1e2;

    ILssReporting override public losslessReporting;
    ILssController override public losslessController;
    ILssStaking override public losslessStaking;

    struct Vote {
        mapping(address => bool) committeeMemberVoted;
        mapping(address => bool) committeeMemberClaimed;
        bool[] committeeVotes;
        bool[3] votes;
        bool[3] voted;
        bool resolved;
        bool resolution;
        bool losslessPayed;
        uint256 amountReported;
    }
    mapping(uint256 => Vote) public reportVotes;

    struct ProposedWallet {
        uint16 proposal;
        uint16 committeeDisagree;
        uint256 retrievalAmount;
        uint256 timestamp;
        address wallet;
        bool status;
        bool losslessVote;
        bool losslessVoted;
        bool tokenOwnersVote;
        bool tokenOwnersVoted;
        bool walletAccepted;
        mapping (uint16 => MemberVotesOnProposal) memberVotesOnProposal;
    }

    mapping(uint256 => ProposedWallet) public proposedWalletOnReport;

    struct Compensation {
        uint256 amount;
        bool payed;
    }

    struct MemberVotesOnProposal {
        mapping (address => bool) memberVoted;
    }

    mapping(address => Compensation) private compensation;

    address[] private reportedAddresses;


    uint256 public revsharePercent;
    address public revshareAdmin;
    mapping(uint256 => bool) public revsharePayed;

    function initialize(ILssReporting _losslessReporting, ILssController _losslessController, ILssStaking _losslessStaking, uint256 _walletDisputePeriod) public initializer {

        losslessReporting = _losslessReporting;
        losslessController = _losslessController;
        losslessStaking = _losslessStaking;
        walletDisputePeriod = _walletDisputePeriod;
        committeeMembersCount = 0;
    }

    modifier onlyLosslessAdmin() {

        require(msg.sender == losslessController.admin(), "LSS: Must be admin");
        _;
    }

    modifier onlyLosslessPauseAdmin() {

        require(msg.sender == losslessController.pauseAdmin(), "LSS: Must be pauseAdmin");
        _;
    }


    function pause() public onlyLosslessPauseAdmin  {

        _pause();
    }    
    
    function unpause() public onlyLosslessPauseAdmin {

        _unpause();
    }

    
    function getVersion() external pure returns (uint256) {

        return 1;
    }
    
    function isCommitteeMember(address _account) override public view returns(bool) {

        return hasRole(COMMITTEE_ROLE, _account);
    }

    function getIsVoted(uint256 _reportId, uint256 _voterIndex) override public view returns(bool) {

        return reportVotes[_reportId].voted[_voterIndex];
    }

    function getVote(uint256 _reportId, uint256 _voterIndex) override public view returns(bool) {

        return reportVotes[_reportId].votes[_voterIndex];
    }

    function isReportSolved(uint256 _reportId) override public view returns(bool){

        return reportVotes[_reportId].resolved;
    }

    function reportResolution(uint256 _reportId) override public view returns(bool){

        return reportVotes[_reportId].resolution;
    }

    function setDisputePeriod(uint256 _timeFrame) override public onlyLosslessAdmin whenNotPaused {

        require(_timeFrame != walletDisputePeriod, "LSS: Already set to that amount");
        walletDisputePeriod = _timeFrame;
        emit NewDisputePeriod(walletDisputePeriod);
    }

    function setCompensationAmount(uint256 _amount) override public onlyLosslessAdmin {

        require(_amount <= 100, "LSS: Invalid amount");
        require(_amount != compensationPercentage, "LSS: Already set to that amount");
        compensationPercentage = _amount;
        emit NewCompensationPercentage(compensationPercentage);
    }

    function setRevshareAdmin(address _address) override public onlyLosslessAdmin {

        require(_address != revshareAdmin, "LSS: Already set to that address");
        revshareAdmin = _address;
        emit NewRevshareAdmin(revshareAdmin);
    }
    
    function setRevsharePercentage(uint256 _amount) override public onlyLosslessAdmin {

        require(_amount <= 100, "LSS: Invalid amount");
        require(_amount != revsharePercent, "LSS: Already set to that amount");
        revsharePercent = _amount;
        emit NewRevsharePercentage(revsharePercent);
    }


    function _getCommitteeMajorityReachedResult(uint256 _reportId) private view returns(bool isMajorityReached, bool result) {        

        Vote storage reportVote = reportVotes[_reportId];
        uint256 committeeLength = reportVote.committeeVotes.length;
        uint256 committeeQuorum = (committeeMembersCount >> 1) + 1; 

        uint256 agreeCount;
        for(uint256 i = 0; i < committeeLength;) {
            if (reportVote.committeeVotes[i]) {
                agreeCount += 1;
            }
            unchecked{i++;}
        }

        if (agreeCount >= committeeQuorum) {
            return (true, true);
        } else if ((committeeLength - agreeCount) >= committeeQuorum) {
            return (true, false);
        } else {
            return (false, false);
        }
    }

    function getAmountReported(uint256 _reportId) override external view returns(uint256) {

        return reportVotes[_reportId].amountReported;
    }

    function addCommitteeMembers(address[] memory _members) override public onlyLosslessAdmin whenNotPaused {

        committeeMembersCount += _members.length;

        for(uint256 i = 0; i < _members.length;) {
            address newMember = _members[i];
            require(!isCommitteeMember(newMember), "LSS: duplicate members");
            _grantRole(COMMITTEE_ROLE, newMember);

            unchecked{i++;}
        }

        emit NewCommitteeMembers(_members);
    } 

    function removeCommitteeMembers(address[] memory _members) override public onlyLosslessAdmin whenNotPaused {  

        require(committeeMembersCount >= _members.length, "LSS: Not enough members to remove");

        committeeMembersCount -= _members.length;

        for(uint256 i = 0; i < _members.length;) {
            address newMember = _members[i];
            require(isCommitteeMember(newMember), "LSS: An address is not member");
            _revokeRole(COMMITTEE_ROLE, newMember);
            unchecked{i++;}
        }

        emit CommitteeMembersRemoval(_members);
    }

    function losslessVote(uint256 _reportId, bool _vote) override public onlyLosslessAdmin whenNotPaused {

        require(!isReportSolved(_reportId), "LSS: Report already solved");
        require(isReportActive(_reportId), "LSS: report is not valid");
        
        Vote storage reportVote = reportVotes[_reportId];
        
        require(!reportVote.voted[LSS_TEAM_INDEX], "LSS: LSS already voted");

        reportVote.voted[LSS_TEAM_INDEX] = true;
        reportVote.votes[LSS_TEAM_INDEX] = _vote;

        if (_vote) {
            emit LosslessTeamPositiveVote(_reportId);
        } else {
            emit LosslessTeamNegativeVote(_reportId);
        }
    }

    function tokenOwnersVote(uint256 _reportId, bool _vote) override public whenNotPaused {

        require(!isReportSolved(_reportId), "LSS: Report already solved");
        require(isReportActive(_reportId), "LSS: report is not valid");

        (,,,,ILERC20 reportTokens,,) = losslessReporting.getReportInfo(_reportId);

        require(msg.sender == reportTokens.admin(), "LSS: Must be token owner");

        Vote storage reportVote = reportVotes[_reportId];

        require(!reportVote.voted[TOKEN_OWNER_INDEX], "LSS: owners already voted");
        
        reportVote.voted[TOKEN_OWNER_INDEX] = true;
        reportVote.votes[TOKEN_OWNER_INDEX] = _vote;

        if (_vote) {
            emit TokenOwnersPositiveVote(_reportId);
        } else {
            emit TokenOwnersNegativeVote(_reportId);
        }
    }

    function committeeMemberVote(uint256 _reportId, bool _vote) override public whenNotPaused {

        require(!isReportSolved(_reportId), "LSS: Report already solved");
        require(isCommitteeMember(msg.sender), "LSS: Must be a committee member");
        require(isReportActive(_reportId), "LSS: report is not valid");

        Vote storage reportVote = reportVotes[_reportId];

        require(!reportVote.committeeMemberVoted[msg.sender], "LSS: Member already voted");
        
        reportVote.committeeMemberVoted[msg.sender] = true;
        reportVote.committeeVotes.push(_vote);

        (bool isMajorityReached, bool result) = _getCommitteeMajorityReachedResult(_reportId);

        if (isMajorityReached) {
            reportVote.votes[COMMITEE_INDEX] = result;
            reportVote.voted[COMMITEE_INDEX] = true;
            emit CommitteeMajorityReach(_reportId, result);
        }

        if (_vote) {
            emit CommitteeMemberPositiveVote(_reportId, msg.sender);
        } else {
            emit CommitteeMemberNegativeVote(_reportId, msg.sender);
        }
    }

    function resolveReport(uint256 _reportId) override public whenNotPaused {


        require(!isReportSolved(_reportId), "LSS: Report already solved");


        (,,,uint256 reportTimestamps,,,) = losslessReporting.getReportInfo(_reportId);
        
        if (reportTimestamps + losslessReporting.reportLifetime() > block.timestamp) {
            _resolveActive(_reportId);
        } else {
            _resolveExpired(_reportId);
        }
        
        reportVotes[_reportId].resolved = true;
        delete reportedAddresses;

        emit ReportResolve(_reportId, reportVotes[_reportId].resolution);
    }

    function _resolveActive(uint256 _reportId) private {

                
        (,address reportedAddress, address secondReportedAddress,, ILERC20 token, bool secondReports,) = losslessReporting.getReportInfo(_reportId);

        Vote storage reportVote = reportVotes[_reportId];

        uint256 agreeCount = 0;
        uint256 voteCount = 0;

        if (getIsVoted(_reportId, LSS_TEAM_INDEX)){voteCount += 1;
        if (getVote(_reportId, LSS_TEAM_INDEX)){ agreeCount += 1;}}
        if (getIsVoted(_reportId, TOKEN_OWNER_INDEX)){voteCount += 1;
        if (getVote(_reportId, TOKEN_OWNER_INDEX)){ agreeCount += 1;}}

        (bool committeeResoluted, bool committeeResolution) = _getCommitteeMajorityReachedResult(_reportId);
        if (committeeResoluted) {voteCount += 1;
        if (committeeResolution) {agreeCount += 1;}}

        require(voteCount >= 2, "LSS: Not enough votes");
        require(!(voteCount == 2 && agreeCount == 1), "LSS: Need another vote to untie");

        reportedAddresses.push(reportedAddress);

        if (secondReports) {
            reportedAddresses.push(secondReportedAddress);
        }

        if (agreeCount > (voteCount - agreeCount)){
            reportVote.resolution = true;
            for(uint256 i; i < reportedAddresses.length;) {
                reportVote.amountReported += token.balanceOf(reportedAddresses[i]);
                unchecked{i++;}
            }
            proposedWalletOnReport[_reportId].retrievalAmount = losslessController.retrieveBlacklistedFunds(reportedAddresses, token, _reportId);
            losslessController.deactivateEmergency(token);
        }else{
            reportVote.resolution = false;
            _compensateAddresses(reportedAddresses);
        }
    } 

    function _resolveExpired(uint256 _reportId) private {

        (,address reportedAddress, address secondReportedAddress,,,bool secondReports,) = losslessReporting.getReportInfo(_reportId);

        reportedAddresses.push(reportedAddress);

        if (secondReports) {
            reportedAddresses.push(secondReportedAddress);
        }

        reportVotes[_reportId].resolution = false;
        _compensateAddresses(reportedAddresses);
    }

    function _compensateAddresses(address[] memory _addresses) private {
        uint256 reportingAmount = losslessReporting.reportingAmount();
        uint256 compensationAmount = (reportingAmount * compensationPercentage) / HUNDRED;

        
        for(uint256 i = 0; i < _addresses.length;) {
            address singleAddress = _addresses[i];
            Compensation storage addressCompensation = compensation[singleAddress]; 
            losslessController.resolvedNegatively(singleAddress);      
            addressCompensation.amount += compensationAmount;
            addressCompensation.payed = false;
            unchecked{i++;}
        }
    }

    function isReportActive(uint256 _reportId) public view returns(bool) {
        (,,,uint256 reportTimestamps,,,) = losslessReporting.getReportInfo(_reportId);
        return reportTimestamps != 0 && reportTimestamps + losslessReporting.reportLifetime() > block.timestamp;
    }


    function proposeWallet(uint256 _reportId, address _wallet) override public whenNotPaused {
        (,,,uint256 reportTimestamps, ILERC20 reportTokens,,) = losslessReporting.getReportInfo(_reportId);

        require(msg.sender == losslessController.admin() || 
                msg.sender == reportTokens.admin(),
                "LSS: Role cannot propose");
        require(reportTimestamps != 0, "LSS: Report does not exist");
        require(reportResolution(_reportId), "LSS: Report solved negatively");
        require(_wallet != address(0), "LSS: Wallet cannot ber zero adr");

        ProposedWallet storage proposedWallet = proposedWalletOnReport[_reportId];

        require(proposedWallet.wallet == address(0), "LSS: Wallet already proposed");

        proposedWallet.wallet = _wallet;
        proposedWallet.timestamp = block.timestamp;
        proposedWallet.losslessVote = true;
        proposedWallet.tokenOwnersVote = true;
        proposedWallet.walletAccepted = true;

        emit WalletProposal(_reportId, _wallet);
    }

    function rejectWallet(uint256 _reportId) override public whenNotPaused {
        (,,,uint256 reportTimestamps,ILERC20 reportTokens,,) = losslessReporting.getReportInfo(_reportId);

        ProposedWallet storage proposedWallet = proposedWalletOnReport[_reportId];

        require(block.timestamp <= (proposedWallet.timestamp + walletDisputePeriod), "LSS: Dispute period closed");
        require(reportTimestamps != 0, "LSS: Report does not exist");

        if (hasRole(COMMITTEE_ROLE, msg.sender)) {
            require(!proposedWallet.memberVotesOnProposal[proposedWallet.proposal].memberVoted[msg.sender], "LSS: Already Voted");
            proposedWallet.committeeDisagree += 1;
            proposedWallet.memberVotesOnProposal[proposedWallet.proposal].memberVoted[msg.sender] = true;
        } else if (msg.sender == losslessController.admin()) {
            require(!proposedWallet.losslessVoted, "LSS: Already Voted");
            proposedWallet.losslessVote = false;
            proposedWallet.losslessVoted = true;
        } else if (msg.sender == reportTokens.admin()) {
            require(!proposedWallet.tokenOwnersVoted, "LSS: Already Voted");
            proposedWallet.tokenOwnersVote = false;
            proposedWallet.tokenOwnersVoted = true;
        } else revert ("LSS: Role cannot reject.");

        if (!_determineProposedWallet(_reportId)) {
            emit WalletRejection(_reportId);
        }
    }

    function retrieveFunds(uint256 _reportId) override public whenNotPaused {
        (,,,uint256 reportTimestamps, ILERC20 reportTokens,,) = losslessReporting.getReportInfo(_reportId);

        ProposedWallet storage proposedWallet = proposedWalletOnReport[_reportId];

        require(block.timestamp >= (proposedWallet.timestamp + walletDisputePeriod), "LSS: Dispute period not closed");
        require(reportTimestamps != 0, "LSS: Report does not exist");
        require(!proposedWallet.status, "LSS: Funds already claimed");
        require(proposedWallet.walletAccepted, "LSS: Wallet rejected");
        require(proposedWallet.wallet == msg.sender, "LSS: Only proposed adr can claim");

        proposedWallet.status = true;

        require(reportTokens.transfer(msg.sender, proposedWallet.retrievalAmount), 
        "LSS: Funds retrieve failed");

        emit FundsRetrieval(_reportId, proposedWallet.retrievalAmount);
    }

    function _determineProposedWallet(uint256 _reportId) private returns(bool){
        
        ProposedWallet storage proposedWallet = proposedWalletOnReport[_reportId];
        uint256 agreementCount;
        
        if (proposedWallet.committeeDisagree < (committeeMembersCount >> 1)+1 ){
            agreementCount += 1;
        }

        if (proposedWallet.losslessVote) {
            agreementCount += 1;
        }

        if (proposedWallet.tokenOwnersVote) {
            agreementCount += 1;
        }
        
        if (agreementCount >= 2) {
            return true;
        }

        proposedWallet.wallet = address(0);
        proposedWallet.timestamp = block.timestamp;
        proposedWallet.status = false;
        proposedWallet.losslessVote = true;
        proposedWallet.losslessVoted = false;
        proposedWallet.tokenOwnersVote = true;
        proposedWallet.tokenOwnersVoted = false;
        proposedWallet.walletAccepted = false;
        proposedWallet.committeeDisagree = 0;
        proposedWallet.proposal += 1;

        return false;
    }

    function retrieveCompensation() override public whenNotPaused {
        require(!compensation[msg.sender].payed, "LSS: Already retrieved");
        require(compensation[msg.sender].amount != 0, "LSS: No retribution assigned");
        
        compensation[msg.sender].payed = true;

        losslessReporting.retrieveCompensation(msg.sender, compensation[msg.sender].amount);

        emit CompensationRetrieval(msg.sender, compensation[msg.sender].amount);

        compensation[msg.sender].amount = 0;

    }

    function isContract(address _addr) private view returns (bool){
         uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size != 0);
    }

    function claimCommitteeReward(uint256 _reportId) override public whenNotPaused {
        require(reportResolution(_reportId), "LSS: Report solved negatively");

        Vote storage reportVote = reportVotes[_reportId];

        require(reportVote.committeeMemberVoted[msg.sender], "LSS: Did not vote on report");
        require(!reportVote.committeeMemberClaimed[msg.sender], "LSS: Already claimed");

        (,,,,ILERC20 reportTokens,,) = losslessReporting.getReportInfo(_reportId);

        uint256 numberOfMembersVote = reportVote.committeeVotes.length;
        uint256 committeeReward = losslessReporting.committeeReward();

        uint256 compensationPerMember = (reportVote.amountReported * committeeReward /  HUNDRED) / numberOfMembersVote;

        reportVote.committeeMemberClaimed[msg.sender] = true;

        require(reportTokens.transfer(msg.sender, compensationPerMember), "LSS: Reward transfer failed");

        emit CommitteeMemberClaim(_reportId, msg.sender, compensationPerMember);
    }

    function losslessClaim(uint256 _reportId) override public whenNotPaused onlyLosslessAdmin {
        require(reportResolution(_reportId), "LSS: Report solved negatively");   

        Vote storage reportVote = reportVotes[_reportId];

        require(!reportVote.losslessPayed, "LSS: Already claimed");

        (,,,,ILERC20 reportTokens,,) = losslessReporting.getReportInfo(_reportId);

        uint256 amountToClaim = reportVote.amountReported * losslessReporting.losslessReward() / HUNDRED;

        if (revshareAdmin != address(0)) {
            uint256 shared = amountToClaim * revsharePercent / HUNDRED;
            amountToClaim -= shared;
        }

        reportVote.losslessPayed = true;
        require(reportTokens.transfer(losslessController.admin(), amountToClaim), 
        "LSS: Reward transfer failed");

        emit LosslessClaim(reportTokens, _reportId, amountToClaim);
    }

        
    function revshareClaim(uint256 _reportId) override public whenNotPaused {
        require(msg.sender == revshareAdmin, "LSS: Must be revshareAdmin");
        require(reportResolution(_reportId), "LSS: Report solved negatively");   

        Vote storage reportVote = reportVotes[_reportId];

        require(!revsharePayed[_reportId], "LSS: Already claimed");

        (,,,,ILERC20 reportTokens,,) = losslessReporting.getReportInfo(_reportId);

        uint256 losslessReward = reportVote.amountReported * losslessReporting.losslessReward() / HUNDRED;
        uint256 amountToClaim = losslessReward * revsharePercent / HUNDRED;

        revsharePayed[_reportId] = true;
        require(reportTokens.transfer(msg.sender, amountToClaim), 
        "LSS: Reward transfer failed");

        emit RevshareClaim(reportTokens, _reportId, amountToClaim);
    }

}