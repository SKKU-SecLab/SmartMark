pragma solidity ^0.7.0;

interface IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.7.0;

interface IVotingPowerFormula {

    function convertTokensToVotingPower(uint256 amount) external view returns (uint256);

}// MIT
pragma solidity ^0.7.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction underflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT
pragma solidity ^0.7.0;

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}// MIT
pragma solidity ^0.7.0;


contract ReentrancyGuardUpgradeSafe is Initializable {

    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {

        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {



        _notEntered = true;

    }


    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }

    uint256[49] private __gap;
}// MIT
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract PrismProxy {


    struct ProxyStorage {
        address admin;

        address pendingAdmin;

        address implementation;

        address pendingImplementation;

        uint8 version;
    }

    bytes32 constant PRISM_PROXY_STORAGE_POSITION = keccak256("prism.proxy.storage");

    event NewPendingImplementation(address indexed oldPendingImplementation, address indexed newPendingImplementation);

    event NewImplementation(address indexed oldImplementation, address indexed newImplementation);

    event NewPendingAdmin(address indexed oldPendingAdmin, address indexed newPendingAdmin);

    event NewAdmin(address indexed oldAdmin, address indexed newAdmin);

    function proxyStorage() internal pure returns (ProxyStorage storage ps) {        

        bytes32 position = PRISM_PROXY_STORAGE_POSITION;
        assembly {
            ps.slot := position
        }
    }

    
    function setPendingProxyImplementation(address newPendingImplementation) public returns (bool) {

        ProxyStorage storage s = proxyStorage();
        require(msg.sender == s.admin, "Prism::setPendingProxyImp: caller must be admin");

        address oldPendingImplementation = s.pendingImplementation;

        s.pendingImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, s.pendingImplementation);

        return true;
    }

    function acceptProxyImplementation() public returns (bool) {

        ProxyStorage storage s = proxyStorage();
        require(msg.sender == s.pendingImplementation && s.pendingImplementation != address(0), "Prism::acceptProxyImp: caller must be pending implementation");
 
        address oldImplementation = s.implementation;
        address oldPendingImplementation = s.pendingImplementation;

        s.implementation = s.pendingImplementation;

        s.pendingImplementation = address(0);
        s.version++;

        emit NewImplementation(oldImplementation, s.implementation);
        emit NewPendingImplementation(oldPendingImplementation, s.pendingImplementation);

        return true;
    }

    function setPendingProxyAdmin(address newPendingAdmin) public returns (bool) {

        ProxyStorage storage s = proxyStorage();
        require(msg.sender == s.admin, "Prism::setPendingProxyAdmin: caller must be admin");

        address oldPendingAdmin = s.pendingAdmin;

        s.pendingAdmin = newPendingAdmin;

        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);

        return true;
    }

    function acceptProxyAdmin() public returns (bool) {

        ProxyStorage storage s = proxyStorage();
        require(msg.sender == s.pendingAdmin && msg.sender != address(0), "Prism::acceptProxyAdmin: caller must be pending admin");

        address oldAdmin = s.admin;
        address oldPendingAdmin = s.pendingAdmin;

        s.admin = s.pendingAdmin;

        s.pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, s.admin);
        emit NewPendingAdmin(oldPendingAdmin, s.pendingAdmin);

        return true;
    }

    function proxyAdmin() public view returns (address) {

        ProxyStorage storage s = proxyStorage();
        return s.admin;
    }

    function pendingProxyAdmin() public view returns (address) {

        ProxyStorage storage s = proxyStorage();
        return s.pendingAdmin;
    }

    function proxyImplementation() public view returns (address) {

        ProxyStorage storage s = proxyStorage();
        return s.implementation;
    }

    function pendingProxyImplementation() public view returns (address) {

        ProxyStorage storage s = proxyStorage();
        return s.pendingImplementation;
    }

    function proxyImplementationVersion() public view returns (uint8) {

        ProxyStorage storage s = proxyStorage();
        return s.version;
    }

    function _forwardToImplementation() internal {

        ProxyStorage storage s = proxyStorage();
        (bool success, ) = s.implementation.delegatecall(msg.data);

        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize())

              switch success
              case 0 { revert(free_mem_ptr, returndatasize()) }
              default { return(free_mem_ptr, returndatasize()) }
        }
    }
}// MIT
pragma solidity ^0.7.0;


contract PrismProxyImplementation is Initializable {

    function become(PrismProxy prism) public {

        require(msg.sender == prism.proxyAdmin(), "Prism::become: only proxy admin can change implementation");
        require(prism.acceptProxyImplementation() == true, "Prism::become: change not authorized");
    }
}// MIT
pragma solidity ^0.7.0;

interface IArchToken {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function mint(address dst, uint256 amount) external returns (bool);

    function burn(address src, uint256 amount) external returns (bool);

    function updateTokenMetadata(string memory tokenName, string memory tokenSymbol) external returns (bool);

    function supplyManager() external view returns (address);

    function metadataManager() external view returns (address);

    function supplyChangeAllowedAfter() external view returns (uint256);

    function supplyChangeWaitingPeriod() external view returns (uint32);

    function supplyChangeWaitingPeriodMinimum() external view returns (uint32);

    function mintCap() external view returns (uint16);

    function setSupplyManager(address newSupplyManager) external returns (bool);

    function setMetadataManager(address newMetadataManager) external returns (bool);

    function setSupplyChangeWaitingPeriod(uint32 period) external returns (bool);

    function setMintCap(uint16 newCap) external returns (bool);

    event MintCapChanged(uint16 indexed oldMintCap, uint16 indexed newMintCap);
    event SupplyManagerChanged(address indexed oldManager, address indexed newManager);
    event SupplyChangeWaitingPeriodChanged(uint32 indexed oldWaitingPeriod, uint32 indexed newWaitingPeriod);
    event MetadataManagerChanged(address indexed oldManager, address indexed newManager);
    event TokenMetaUpdated(string indexed name, string indexed symbol);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
}// MIT
pragma solidity ^0.7.0;


interface IVotingPower {


    struct Stake {
        uint256 amount;
        uint256 votingPower;
    }

    function setPendingProxyImplementation(address newPendingImplementation) external returns (bool);

    function acceptProxyImplementation() external returns (bool);

    function setPendingProxyAdmin(address newPendingAdmin) external returns (bool);

    function acceptProxyAdmin() external returns (bool);

    function proxyAdmin() external view returns (address);

    function pendingProxyAdmin() external view returns (address);

    function proxyImplementation() external view returns (address);

    function pendingProxyImplementation() external view returns (address);

    function proxyImplementationVersion() external view returns (uint8);

    function become(PrismProxy prism) external;

    function initialize(address _archToken, address _vestingContract) external;

    function owner() external view returns (address);

    function archToken() external view returns (address);

    function vestingContract() external view returns (address);

    function tokenRegistry() external view returns (address);

    function lockManager() external view returns (address);

    function changeOwner(address newOwner) external;

    function setTokenRegistry(address registry) external;

    function setLockManager(address newLockManager) external;

    function stake(uint256 amount) external;

    function stakeWithPermit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function withdraw(uint256 amount) external;

    function addVotingPowerForVestingTokens(address account, uint256 amount) external;

    function removeVotingPowerForClaimedTokens(address account, uint256 amount) external;

    function addVotingPowerForLockedTokens(address account, uint256 amount) external;

    function removeVotingPowerForUnlockedTokens(address account, uint256 amount) external;

    function getARCHAmountStaked(address staker) external view returns (uint256);

    function getAmountStaked(address staker, address stakedToken) external view returns (uint256);

    function getARCHStake(address staker) external view returns (Stake memory);

    function getStake(address staker, address stakedToken) external view returns (Stake memory);

    function balanceOf(address account) external view returns (uint256);

    function balanceOfAt(address account, uint256 blockNumber) external view returns (uint256);

    event NewPendingImplementation(address indexed oldPendingImplementation, address indexed newPendingImplementation);
    event NewImplementation(address indexed oldImplementation, address indexed newImplementation);
    event NewPendingAdmin(address indexed oldPendingAdmin, address indexed newPendingAdmin);
    event NewAdmin(address indexed oldAdmin, address indexed newAdmin);
    event Staked(address indexed user, address indexed token, uint256 indexed amount, uint256 votingPower);
    event Withdrawn(address indexed user, address indexed token, uint256 indexed amount, uint256 votingPower);
    event VotingPowerChanged(address indexed voter, uint256 indexed previousBalance, uint256 indexed newBalance);
}// MIT
pragma solidity ^0.7.0;


interface IVesting {

    
    struct Grant {
        uint256 startTime;
        uint256 amount;
        uint16 vestingDuration;
        uint16 vestingCliff;
        uint256 totalClaimed;
    }

    function owner() external view returns (address);

    function token() external view returns (IArchToken);

    function votingPower() external view returns (IVotingPower);

    function addTokenGrant(address recipient, uint256 startTime, uint256 amount, uint16 vestingDurationInDays, uint16 vestingCliffInDays) external;

    function getTokenGrant(address recipient) external view returns(Grant memory);

    function calculateGrantClaim(address recipient) external view returns (uint256);

    function vestedBalance(address account) external view returns (uint256);

    function claimedBalance(address recipient) external view returns (uint256);

    function claimVestedTokens(address recipient) external;

    function tokensVestedPerDay(address recipient) external view returns(uint256);

    function setVotingPowerContract(address newContract) external;

    function changeOwner(address newOwner) external;

    event GrantAdded(address indexed recipient, uint256 indexed amount, uint256 startTime, uint16 vestingDurationInDays, uint16 vestingCliffInDays);
    event GrantTokensClaimed(address indexed recipient, uint256 indexed amountClaimed);
    event ChangedOwner(address indexed oldOwner, address indexed newOwner);
    event ChangedVotingPower(address indexed oldContract, address indexed newContract);

}// MIT
pragma solidity ^0.7.0;

interface IVault {

    
    struct Lock {
        address token;
        address receiver;
        uint48 startTime;
        uint16 vestingDurationInDays;
        uint16 cliffDurationInDays;
        uint256 amount;
        uint256 amountClaimed;
        uint256 votingPower;
    }

    struct LockBalance {
        uint256 id;
        uint256 claimableAmount;
        Lock lock;
    }

    struct TokenBalance {
        uint256 totalAmount;
        uint256 claimableAmount;
        uint256 claimedAmount;
        uint256 votingPower;
    }

    function lockTokens(address token, address locker, address receiver, uint48 startTime, uint256 amount, uint16 lockDurationInDays, uint16 cliffDurationInDays, bool grantVotingPower) external;

    function lockTokensWithPermit(address token, address locker, address receiver, uint48 startTime, uint256 amount, uint16 lockDurationInDays, uint16 cliffDurationInDays, bool grantVotingPower, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;

    function claimUnlockedTokenAmounts(uint256[] memory lockIds, uint256[] memory amounts) external;

    function claimAllUnlockedTokens(uint256[] memory lockIds) external;

    function tokenLocks(uint256 lockId) external view returns(Lock memory);

    function allActiveLockIds() external view returns(uint256[] memory);

    function allActiveLocks() external view returns(Lock[] memory);

    function allActiveLockBalances() external view returns(LockBalance[] memory);

    function activeLockIds(address receiver) external view returns(uint256[] memory);

    function allLocks(address receiver) external view returns(Lock[] memory);

    function activeLocks(address receiver) external view returns(Lock[] memory);

    function activeLockBalances(address receiver) external view returns(LockBalance[] memory);

    function totalTokenBalance(address token) external view returns(TokenBalance memory balance);

    function tokenBalance(address token, address receiver) external view returns(TokenBalance memory balance);

    function lockBalance(uint256 lockId) external view returns (LockBalance memory);

    function claimableBalance(uint256 lockId) external view returns (uint256);

    function extendLock(uint256 lockId, uint16 vestingDaysToAdd, uint16 cliffDaysToAdd) external;

}// MIT
pragma solidity ^0.7.0;

interface ITokenRegistry {

    function owner() external view returns (address);

    function tokenFormulas(address) external view returns (address);

    function setTokenFormula(address token, address formula) external;

    function removeToken(address token) external;

    function changeOwner(address newOwner) external;

    event ChangedOwner(address indexed oldOwner, address indexed newOwner);
    event TokenAdded(address indexed token, address indexed formula);
    event TokenRemoved(address indexed token);
}// MIT
pragma solidity ^0.7.0;


struct AppStorage {
    mapping (address => uint) nonces;

    IArchToken archToken;

    IVesting vesting;

    address owner;
    
    address lockManager;

    ITokenRegistry tokenRegistry;
}

struct Checkpoint {
    uint32 fromBlock;
    uint256 votes;
}

struct CheckpointStorage {
    mapping (address => mapping (uint32 => Checkpoint)) checkpoints;

    mapping (address => uint32) numCheckpoints;
}

struct Stake {
    uint256 amount;
    uint256 votingPower;
}

struct StakeStorage {
    mapping (address => mapping (address => Stake)) stakes;
}

library VotingPowerStorage {

    bytes32 constant VOTING_POWER_APP_STORAGE_POSITION = keccak256("voting.power.app.storage");
    bytes32 constant VOTING_POWER_CHECKPOINT_STORAGE_POSITION = keccak256("voting.power.checkpoint.storage");
    bytes32 constant VOTING_POWER_STAKE_STORAGE_POSITION = keccak256("voting.power.stake.storage");
    
    function appStorage() internal pure returns (AppStorage storage app) {        

        bytes32 position = VOTING_POWER_APP_STORAGE_POSITION;
        assembly {
            app.slot := position
        }
    }

    function checkpointStorage() internal pure returns (CheckpointStorage storage cs) {        

        bytes32 position = VOTING_POWER_CHECKPOINT_STORAGE_POSITION;
        assembly {
            cs.slot := position
        }
    }

    function stakeStorage() internal pure returns (StakeStorage storage ss) {        

        bytes32 position = VOTING_POWER_STAKE_STORAGE_POSITION;
        assembly {
            ss.slot := position
        }
    }
}// MIT
pragma solidity ^0.7.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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
pragma solidity ^0.7.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity ^0.7.0;


contract VotingPower is PrismProxyImplementation, ReentrancyGuardUpgradeSafe {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event Staked(address indexed user, address indexed token, uint256 indexed amount, uint256 votingPower);

    event Withdrawn(address indexed user, address indexed token, uint256 indexed amount, uint256 votingPower);

    event VotingPowerChanged(address indexed voter, uint256 indexed previousBalance, uint256 indexed newBalance);

    event ChangedOwner(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner {

        AppStorage storage app = VotingPowerStorage.appStorage();
        require(app.owner == address(0) || msg.sender == app.owner, "only owner");
        _;
    }

    function initialize(
        address _archToken,
        address _vestingContract
    ) public initializer {

        __ReentrancyGuard_init_unchained();
        AppStorage storage app = VotingPowerStorage.appStorage();
        app.archToken = IArchToken(_archToken);
        app.vesting = IVesting(_vestingContract);
    }

    function archToken() public view returns (address) {

        AppStorage storage app = VotingPowerStorage.appStorage();
        return address(app.archToken);
    }

    function decimals() public pure returns (uint8) {

        return 18;
    }

    function vestingContract() public view returns (address) {

        AppStorage storage app = VotingPowerStorage.appStorage();
        return address(app.vesting);
    }

    function tokenRegistry() public view returns (address) {

        AppStorage storage app = VotingPowerStorage.appStorage();
        return address(app.tokenRegistry);
    }

    function lockManager() public view returns (address) {

        AppStorage storage app = VotingPowerStorage.appStorage();
        return app.lockManager;
    }

    function owner() public view returns (address) {

        AppStorage storage app = VotingPowerStorage.appStorage();
        return app.owner;
    }

    function setTokenRegistry(address registry) public onlyOwner {

        AppStorage storage app = VotingPowerStorage.appStorage();
        app.tokenRegistry = ITokenRegistry(registry);
    }

    function setLockManager(address newLockManager) public onlyOwner {

        AppStorage storage app = VotingPowerStorage.appStorage();
        app.lockManager = newLockManager;
    }

    function changeOwner(address newOwner) external onlyOwner {

        require(newOwner != address(0) && newOwner != address(this), "VP::changeOwner: not valid address");
        AppStorage storage app = VotingPowerStorage.appStorage();
        emit ChangedOwner(app.owner, newOwner);
        app.owner = newOwner;   
    }

    function stakeWithPermit(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external nonReentrant {

        require(amount > 0, "VP::stakeWithPermit: cannot stake 0");
        AppStorage storage app = VotingPowerStorage.appStorage();
        require(app.archToken.balanceOf(msg.sender) >= amount, "VP::stakeWithPermit: not enough tokens");

        app.archToken.permit(msg.sender, address(this), amount, deadline, v, r, s);

        _stake(msg.sender, address(app.archToken), amount, amount);
    }

    function stake(uint256 amount) external nonReentrant {

        AppStorage storage app = VotingPowerStorage.appStorage();
        require(amount > 0, "VP::stake: cannot stake 0");
        require(app.archToken.balanceOf(msg.sender) >= amount, "VP::stake: not enough tokens");
        require(app.archToken.allowance(msg.sender, address(this)) >= amount, "VP::stake: must approve tokens before staking");

        _stake(msg.sender, address(app.archToken), amount, amount);
    }

    function stake(address token, uint256 amount) external nonReentrant {

        IERC20 lptoken = IERC20(token);
        require(amount > 0, "VP::stake: cannot stake 0");
        require(lptoken.balanceOf(msg.sender) >= amount, "VP::stake: not enough tokens");
        require(lptoken.allowance(msg.sender, address(this)) >= amount, "VP::stake: must approve tokens before staking");

        AppStorage storage app = VotingPowerStorage.appStorage();
        address tokenFormulaAddress = app.tokenRegistry.tokenFormulas(token);
        require(tokenFormulaAddress != address(0), "VP::stake: token not supported");
        
        IVotingPowerFormula tokenFormula = IVotingPowerFormula(tokenFormulaAddress);
        uint256 votingPower = tokenFormula.convertTokensToVotingPower(amount);
        _stake(msg.sender, token, amount, votingPower);
    }

    function addVotingPowerForVestingTokens(address account, uint256 amount) external nonReentrant {

        AppStorage storage app = VotingPowerStorage.appStorage();
        require(amount > 0, "VP::addVPforVT: cannot add 0 voting power");
        require(msg.sender == address(app.vesting), "VP::addVPforVT: only vesting contract");

        _increaseVotingPower(account, amount);
    }

    function removeVotingPowerForClaimedTokens(address account, uint256 amount) external nonReentrant {

        AppStorage storage app = VotingPowerStorage.appStorage();
        require(amount > 0, "VP::removeVPforCT: cannot remove 0 voting power");
        require(msg.sender == address(app.vesting), "VP::removeVPforCT: only vesting contract");

        _decreaseVotingPower(account, amount);
    }

    function addVotingPowerForLockedTokens(address account, uint256 amount) external nonReentrant {

        AppStorage storage app = VotingPowerStorage.appStorage();
        require(amount > 0, "VP::addVPforLT: cannot add 0 voting power");
        require(msg.sender == app.lockManager, "VP::addVPforLT: only lockManager contract");

        _increaseVotingPower(account, amount);
    }

    function removeVotingPowerForUnlockedTokens(address account, uint256 amount) external nonReentrant {

        AppStorage storage app = VotingPowerStorage.appStorage();
        require(amount > 0, "VP::removeVPforUT: cannot remove 0 voting power");
        require(msg.sender == app.lockManager, "VP::removeVPforUT: only lockManager contract");

        _decreaseVotingPower(account, amount);
    }

    function withdraw(uint256 amount) external nonReentrant {

        require(amount > 0, "VP::withdraw: cannot withdraw 0");
        AppStorage storage app = VotingPowerStorage.appStorage();
        _withdraw(msg.sender, address(app.archToken), amount, amount);
    }

    function withdraw(address token, uint256 amount) external nonReentrant {

        require(amount > 0, "VP::withdraw: cannot withdraw 0");
        Stake memory s = getStake(msg.sender, token);
        uint256 vpToWithdraw = amount.mul(s.votingPower).div(s.amount);
        _withdraw(msg.sender, token, amount, vpToWithdraw);
    }

    function getARCHAmountStaked(address staker) public view returns (uint256) {

        return getARCHStake(staker).amount;
    }

    function getAmountStaked(address staker, address stakedToken) public view returns (uint256) {

        return getStake(staker, stakedToken).amount;
    }

    function getARCHStake(address staker) public view returns (Stake memory) {

        AppStorage storage app = VotingPowerStorage.appStorage();
        return getStake(staker, address(app.archToken));
    }

    function getStake(address staker, address stakedToken) public view returns (Stake memory) {

        StakeStorage storage ss = VotingPowerStorage.stakeStorage();
        return ss.stakes[staker][stakedToken];
    }

    function balanceOf(address account) public view returns (uint256) {

        CheckpointStorage storage cs = VotingPowerStorage.checkpointStorage();
        uint32 nCheckpoints = cs.numCheckpoints[account];
        return nCheckpoints > 0 ? cs.checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    function balanceOfAt(address account, uint256 blockNumber) public view returns (uint256) {

        require(blockNumber < block.number, "VP::balanceOfAt: not yet determined");
        
        CheckpointStorage storage cs = VotingPowerStorage.checkpointStorage();
        uint32 nCheckpoints = cs.numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        if (cs.checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return cs.checkpoints[account][nCheckpoints - 1].votes;
        }

        if (cs.checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = cs.checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return cs.checkpoints[account][lower].votes;
    }

    function _stake(address voter, address token, uint256 tokenAmount, uint256 votingPower) internal {

        IERC20(token).safeTransferFrom(voter, address(this), tokenAmount);

        StakeStorage storage ss = VotingPowerStorage.stakeStorage();
        ss.stakes[voter][token].amount = ss.stakes[voter][token].amount.add(tokenAmount);
        ss.stakes[voter][token].votingPower = ss.stakes[voter][token].votingPower.add(votingPower);

        emit Staked(voter, token, tokenAmount, votingPower);

        _increaseVotingPower(voter, votingPower);
    }

    function _withdraw(address voter, address token, uint256 tokenAmount, uint256 votingPower) internal {

        StakeStorage storage ss = VotingPowerStorage.stakeStorage();
        require(ss.stakes[voter][token].amount >= tokenAmount, "VP::_withdraw: not enough tokens staked");
        require(ss.stakes[voter][token].votingPower >= votingPower, "VP::_withdraw: not enough voting power");
        ss.stakes[voter][token].amount = ss.stakes[voter][token].amount.sub(tokenAmount);
        ss.stakes[voter][token].votingPower = ss.stakes[voter][token].votingPower.sub(votingPower);
        
        IERC20(token).safeTransfer(voter, tokenAmount);

        emit Withdrawn(voter, token, tokenAmount, votingPower);
        
        _decreaseVotingPower(voter, votingPower);
    }

    function _increaseVotingPower(address voter, uint256 amount) internal {

        CheckpointStorage storage cs = VotingPowerStorage.checkpointStorage();
        uint32 checkpointNum = cs.numCheckpoints[voter];
        uint256 votingPowerOld = checkpointNum > 0 ? cs.checkpoints[voter][checkpointNum - 1].votes : 0;
        uint256 votingPowerNew = votingPowerOld.add(amount);
        _writeCheckpoint(voter, checkpointNum, votingPowerOld, votingPowerNew);
    }

    function _decreaseVotingPower(address voter, uint256 amount) internal {

        CheckpointStorage storage cs = VotingPowerStorage.checkpointStorage();
        uint32 checkpointNum = cs.numCheckpoints[voter];
        uint256 votingPowerOld = checkpointNum > 0 ? cs.checkpoints[voter][checkpointNum - 1].votes : 0;
        uint256 votingPowerNew = votingPowerOld.sub(amount);
        _writeCheckpoint(voter, checkpointNum, votingPowerOld, votingPowerNew);
    }

    function _writeCheckpoint(address voter, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {

      uint32 blockNumber = _safe32(block.number, "VP::_writeCheckpoint: block number exceeds 32 bits");

      CheckpointStorage storage cs = VotingPowerStorage.checkpointStorage();
      if (nCheckpoints > 0 && cs.checkpoints[voter][nCheckpoints - 1].fromBlock == blockNumber) {
          cs.checkpoints[voter][nCheckpoints - 1].votes = newVotes;
      } else {
          cs.checkpoints[voter][nCheckpoints] = Checkpoint(blockNumber, newVotes);
          cs.numCheckpoints[voter] = nCheckpoints + 1;
      }

      emit VotingPowerChanged(voter, oldVotes, newVotes);
    }

    function _safe32(uint256 n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }
}