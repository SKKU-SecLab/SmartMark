
pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMathUpgradeable {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
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

pragma solidity >=0.6.0 <0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    using SafeMathUpgradeable for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC20CappedUpgradeable is Initializable, ERC20Upgradeable {
    using SafeMathUpgradeable for uint256;

    uint256 private _cap;

    function __ERC20Capped_init(uint256 cap_) internal initializer {
        __Context_init_unchained();
        __ERC20Capped_init_unchained(cap_);
    }

    function __ERC20Capped_init_unchained(uint256 cap_) internal initializer {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    function cap() public view returns (uint256) {
        return _cap;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) { // When minting tokens
            require(totalSupply().add(amount) <= _cap, "ERC20Capped: cap exceeded");
        }
    }
    uint256[49] private __gap;
}pragma solidity 0.6.6;


contract EglToken is Initializable, ContextUpgradeable, ERC20CappedUpgradeable {

    function initialize(
        address initialRecipient, 
        string memory name, 
        string memory symbol, 
        uint256 initialSupply
    ) 
        public 
        initializer 
    {

        require(initialRecipient != address(0), "EGLTOKEN:INVALID_RECIPIENT");

        __ERC20_init(name, symbol);
        __ERC20Capped_init_unchained(initialSupply);

        _mint(initialRecipient, initialSupply);
    }
}pragma solidity 0.6.6;

interface IEglGenesis {

    function owner() external view returns(address);

    function cumulativeBalance() external view returns(uint);

    function canContribute() external view returns(bool);

    function canWithdraw() external view returns(bool);

    function contributors(address contributor) external view returns(uint, uint, uint, uint);

}pragma solidity ^0.6.0;

library Math {

    function umax(uint a, uint b) internal pure returns (uint) {

        return a >= b ? a : b;
    }

    function umin(uint a, uint b) internal pure returns (uint) {

        return a < b ? a : b;
    }

    function max(int a, int b) internal pure returns (int) {

        return a >= b ? a : b;
    }

    function min(int a, int b) internal pure returns (int) {

        return a < b ? a : b;
    }

    function udelta(uint a, uint b) internal pure returns (uint) {

        return a > b ? a - b : b - a;
    } 
    function delta(int a, int b) internal pure returns (int) {

        return a > b ? a - b : b - a;
    } 
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SignedSafeMathUpgradeable {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
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

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}pragma solidity 0.6.6;



contract EglContract is Initializable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

    using Math for *;
    using SafeMathUpgradeable for *;
    using SignedSafeMathUpgradeable for int;

    uint8 constant WEEKS_IN_YEAR = 52;
    uint constant DECIMAL_PRECISION = 10**18;

    int public desiredEgl;
    int public baselineEgl;
    int public initialEgl;
    int public tallyVotesGasLimit;

    uint public creatorEglsTotal;
    uint public liquidityEglMatchingTotal;

    uint16 public currentEpoch;
    uint public currentEpochStartDate;
    uint public tokensInCirculation;

    uint[52] public voterRewardSums;
    uint[8] public votesTotal;
    uint[8] public voteWeightsSum;
    uint[8] public gasTargetSum;

    mapping(address => Voter) public voters;
    mapping(address => Supporter) public supporters;
    mapping(address => uint) public seeders;

    struct Voter {
        uint8 lockupDuration;
        uint16 voteEpoch;
        uint releaseDate;
        uint tokensLocked;
        uint gasTarget;
    }

    struct Supporter {
        uint32 claimed;
        uint poolTokens;
        uint firstEgl;
        uint lastEgl;
    }

    EglToken private eglToken;
    IERC20Upgradeable private balancerPoolToken;
    IEglGenesis private eglGenesis;

    address private creatorRewardsAddress;
    
    int private epochGasLimitSum;
    int private epochVoteCount;
    int private desiredEglThreshold;

    uint24 private votingPauseSeconds;
    uint32 private epochLength;
    uint private firstEpochStartDate;
    uint private latestRewardSwept;
    uint private minLiquidityTokensLockup;
    uint private creatorRewardFirstEpoch;
    uint private remainingPoolReward;
    uint private remainingCreatorReward;
    uint private remainingDaoBalance;
    uint private remainingSeederBalance;
    uint private remainingSupporterBalance;
    uint private remainingBptBalance;
    uint private remainingVoterReward;
    uint private lastSerializedEgl;
    uint private ethEglRatio;
    uint private ethBptRatio;
    uint private voterRewardMultiplier;
    uint private gasTargetTolerance;    
    uint16 private voteThresholdGracePeriod;

    event Initialized(
        address deployer,
        address eglContract,
        address eglToken,
        address genesisContract,
        address balancerToken,
        uint totalGenesisEth,
        uint ethEglRatio,
        uint ethBptRatio,
        uint minLiquidityTokensLockup,
        uint firstEpochStartDate,
        uint votingPauseSeconds,
        uint epochLength,
        uint date
    );
    event Vote(
        address caller,
        uint16 currentEpoch,
        uint gasTarget,
        uint eglAmount,
        uint8 lockupDuration,
        uint releaseDate,
        uint epochVoteWeightSum,
        uint epochGasTargetSum,
        uint epochVoterRewardSum,
        uint epochTotalVotes,
        uint date
    );
    event ReVote(
        address caller, 
        uint gasTarget, 
        uint eglAmount, 
        uint date
    );
    event Withdraw(
        address caller,
        uint16 currentEpoch,
        uint tokensLocked,
        uint rewardTokens,
        uint gasTarget,
        uint epochVoterRewardSum,
        uint epochTotalVotes,
        uint epochVoteWeightSum,
        uint epochGasTargetSum,
        uint date
    );
    event VotesTallied(
        address caller,
        uint16 currentEpoch,
        int desiredEgl,
        int averageGasTarget,
        uint votingThreshold,
        uint actualVotePercentage,
        int baselineEgl,
        uint tokensInCirculation,
        uint date
    );
    event CreatorRewardsClaimed(
        address caller,
        address creatorRewardAddress,
        uint amountClaimed,
        uint lastSerializedEgl,
        uint remainingCreatorReward,
        uint16 currentEpoch,
        uint date
    );
    event VoteThresholdMet(
        address caller,
        uint16 currentEpoch,
        int desiredEgl,
        uint voteThreshold,
        uint actualVotePercentage,
        int gasLimitSum,
        int voteCount,
        int baselineEgl,
        uint date
    );
    event VoteThresholdFailed(
        address caller,
        uint16 currentEpoch,
        int desiredEgl,
        uint voteThreshold,
        uint actualVotePercentage,
        int baselineEgl,
        int initialEgl,
        uint timeSinceFirstEpoch,
        uint gracePeriodSeconds,
        uint date
    );
    event PoolRewardsSwept(
        address caller, 
        address coinbaseAddress,
        uint blockNumber, 
        int blockGasLimit, 
        uint blockReward, 
        uint date
    );
    event BlockRewardCalculated(
        uint blockNumber, 
        uint16 currentEpoch,
        uint remainingPoolReward,
        int blockGasLimit, 
        int desiredEgl,
        int tallyVotesGasLimit,
        uint proximityRewardPercent,
        uint totalRewardPercent,
        uint blockReward,
        uint date
    );
    event SeedAccountClaimed(
        address seedAddress, 
        uint individualSeedAmount, 
        uint releaseDate,
        uint date
    );
    event VoterRewardCalculated(
        address voter,
        uint16 currentEpoch,
        uint voterReward,
        uint epochVoterReward,
        uint voteWeight,
        uint rewardMultiplier,
        uint weeksDiv,
        uint epochVoterRewardSum,
        uint remainingVoterRewards,
        uint date
    );
    event SupporterTokensClaimed(
        address caller,
        uint amountContributed,
        uint gasTarget,
        uint lockDuration,
        uint ethEglRatio,
        uint ethBptRatio,
        uint bonusEglsReceived,
        uint poolTokensReceived,
        uint remainingSupporterBalance,
        uint remainingBptBalance, 
        uint date
    );
    event PoolTokensWithdrawn(
        address caller, 
        uint currentSerializedEgl, 
        uint poolTokensDue, 
        uint poolTokens, 
        uint firstEgl, 
        uint lastEgl, 
        uint eglReleaseDate,
        uint date
    );  
    event SerializedEglCalculated(
        uint currentEpoch, 
        uint secondsSinceEglStart,
        uint timePassedPercentage, 
        uint serializedEgl,
        uint maxSupply,
        uint date
    );
    event SeedAccountAdded(
        address seedAccount,
        uint seedAmount,
        uint remainingSeederBalance,
        uint date
    );
    
    receive() external payable {
        revert("EGL:NO_PAYMENTS");
    }

    function initialize(
        address _token,
        address _poolToken,
        address _genesis,
        uint _currentEpochStartDate,
        uint24 _votingPauseSeconds,
        uint32 _epochLength,
        address[] memory _seedAccounts,
        uint[] memory _seedAmounts,
        address _creatorRewardsAccount
    ) 
        public 
        initializer 
    {

        require(_token != address(0), "EGL:INVALID_EGL_TOKEN_ADDR");
        require(_poolToken != address(0), "EGL:INVALID_BP_TOKEN_ADDR");
        require(_genesis != address(0), "EGL:INVALID_GENESIS_ADDR");

        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();

        eglToken = EglToken(_token);
        balancerPoolToken = IERC20Upgradeable(_poolToken);
        eglGenesis = IEglGenesis(_genesis);        

        creatorEglsTotal = 750000000 ether;
        remainingCreatorReward = creatorEglsTotal;

        liquidityEglMatchingTotal = 750000000 ether;
        remainingPoolReward = 1250000000 ether;        
        remainingDaoBalance = 250000000 ether;
        remainingSeederBalance = 50000000 ether;
        remainingSupporterBalance = 500000000 ether;
        remainingVoterReward = 500000000 ether;
        
        voterRewardMultiplier = 362844.70 ether;

        uint totalGenesisEth = eglGenesis.cumulativeBalance();
        require(totalGenesisEth > 0, "EGL:NO_GENESIS_BALANCE");

        remainingBptBalance = balancerPoolToken.balanceOf(eglGenesis.owner());
        require(remainingBptBalance > 0, "EGL:NO_BPT_BALANCE");
        ethEglRatio = liquidityEglMatchingTotal.mul(DECIMAL_PRECISION)
            .div(totalGenesisEth);
        ethBptRatio = remainingBptBalance.mul(DECIMAL_PRECISION)
            .div(totalGenesisEth);

        creatorRewardFirstEpoch = 10;
        minLiquidityTokensLockup = _epochLength.mul(10);

        firstEpochStartDate = _currentEpochStartDate;
        currentEpochStartDate = _currentEpochStartDate;
        votingPauseSeconds = _votingPauseSeconds;
        epochLength = _epochLength;
        creatorRewardsAddress = _creatorRewardsAccount;
        tokensInCirculation = liquidityEglMatchingTotal;
        tallyVotesGasLimit = int(block.gaslimit);
        
        baselineEgl = int(block.gaslimit);
        initialEgl = baselineEgl;
        desiredEgl = baselineEgl;

        gasTargetTolerance = 4000000;
        desiredEglThreshold = 1000000;
        voteThresholdGracePeriod = 7;

        if (_seedAccounts.length > 0) {
            for (uint8 i = 0; i < _seedAccounts.length; i++) {
                addSeedAccount(_seedAccounts[i], _seedAmounts[i]);
            }
        }
        
        emit Initialized(
            msg.sender,
            address(this),
            address(eglToken),
            address(eglGenesis), 
            address(balancerPoolToken), 
            totalGenesisEth,
            ethEglRatio,
            ethBptRatio,
            minLiquidityTokensLockup,
            firstEpochStartDate,
            votingPauseSeconds,
            epochLength,
            block.timestamp
        );
    }

    function claimSupporterEgls(uint _gasTarget, uint8 _lockupDuration) external whenNotPaused {

        require(remainingSupporterBalance > 0, "EGL:SUPPORTER_EGLS_DEPLETED");
        require(remainingBptBalance > 0, "EGL:BPT_BALANCE_DEPLETED");
        require(
            eglGenesis.canContribute() == false && eglGenesis.canWithdraw() == false, 
            "EGL:GENESIS_LOCKED"
        );
        require(supporters[msg.sender].claimed == 0, "EGL:ALREADY_CLAIMED");

        (uint contributionAmount, uint cumulativeBalance, ,) = eglGenesis.contributors(msg.sender);
        require(contributionAmount > 0, "EGL:NOT_CONTRIBUTED");

        if (block.timestamp > currentEpochStartDate.add(epochLength))
            tallyVotes();
        
        uint serializedEgls = contributionAmount.mul(ethEglRatio).div(DECIMAL_PRECISION);
        uint firstEgl = cumulativeBalance.sub(contributionAmount)
            .mul(ethEglRatio)
            .div(DECIMAL_PRECISION);
        uint lastEgl = firstEgl.add(serializedEgls);
        uint bonusEglsDue = Math.umin(
            _calculateBonusEglsDue(firstEgl, lastEgl), 
            remainingSupporterBalance
        );
        uint poolTokensDue = Math.umin(
            contributionAmount.mul(ethBptRatio).div(DECIMAL_PRECISION),
            remainingBptBalance
        );

        remainingSupporterBalance = remainingSupporterBalance.sub(bonusEglsDue);
        remainingBptBalance = remainingBptBalance.sub(poolTokensDue);
        tokensInCirculation = tokensInCirculation.add(bonusEglsDue);

        Supporter storage _supporter = supporters[msg.sender];        
        _supporter.claimed = 1;
        _supporter.poolTokens = poolTokensDue;
        _supporter.firstEgl = firstEgl;
        _supporter.lastEgl = lastEgl;        
        
        emit SupporterTokensClaimed(
            msg.sender,
            contributionAmount,
            _gasTarget,
            _lockupDuration,
            ethEglRatio,
            ethBptRatio,
            bonusEglsDue,
            poolTokensDue,
            remainingSupporterBalance,
            remainingBptBalance,
            block.timestamp
        );

        _internalVote(
            msg.sender,
            _gasTarget,
            bonusEglsDue,
            _lockupDuration,
            firstEpochStartDate.add(epochLength.mul(WEEKS_IN_YEAR))
        );
    }

    function claimSeederEgls(uint _gasTarget, uint8 _lockupDuration) external whenNotPaused {

        require(seeders[msg.sender] > 0, "EGL:NOT_SEEDER");
        if (block.timestamp > currentEpochStartDate.add(epochLength))
            tallyVotes();
        
        uint seedAmount = seeders[msg.sender];
        delete seeders[msg.sender];

        tokensInCirculation = tokensInCirculation.add(seedAmount);
        uint releaseDate = firstEpochStartDate.add(epochLength.mul(WEEKS_IN_YEAR));
        emit SeedAccountClaimed(msg.sender, seedAmount, releaseDate, block.timestamp);

        _internalVote(
            msg.sender,
            _gasTarget,
            seedAmount,
            _lockupDuration,
            releaseDate
        );
    }

    function vote(
        uint _gasTarget,
        uint _eglAmount,
        uint8 _lockupDuration
    ) 
        external 
        whenNotPaused
        nonReentrant 
    {

        require(_eglAmount >= 1 ether, "EGL:AMNT_TOO_LOW");
        require(_eglAmount <= eglToken.balanceOf(msg.sender), "EGL:INSUFFICIENT_EGL_BALANCE");
        require(eglToken.allowance(msg.sender, address(this)) >= _eglAmount, "EGL:INSUFFICIENT_ALLOWANCE");
        if (block.timestamp > currentEpochStartDate.add(epochLength))
            tallyVotes();

        bool success = eglToken.transferFrom(msg.sender, address(this), _eglAmount);
        require(success, "EGL:TOKEN_TRANSFER_FAILED");
        _internalVote(
            msg.sender,
            _gasTarget,
            _eglAmount,
            _lockupDuration,
            0
        );
    }

    function reVote(
        uint _gasTarget,
        uint _eglAmount,
        uint8 _lockupDuration
    ) 
        external 
        whenNotPaused
        nonReentrant
    {

        require(voters[msg.sender].tokensLocked > 0, "EGL:NOT_VOTED");
        if (_eglAmount > 0) {
            require(_eglAmount >= 1 ether, "EGL:AMNT_TOO_LOW");
            require(_eglAmount <= eglToken.balanceOf(msg.sender), "EGL:INSUFFICIENT_EGL_BALANCE");
            require(eglToken.allowance(msg.sender, address(this)) >= _eglAmount, "EGL:INSUFFICIENT_ALLOWANCE");
            bool success = eglToken.transferFrom(msg.sender, address(this), _eglAmount);
            require(success, "EGL:TOKEN_TRANSFER_FAILED");
        }
        if (block.timestamp > currentEpochStartDate.add(epochLength))
            tallyVotes();

        uint originalReleaseDate = voters[msg.sender].releaseDate;
        _eglAmount = _eglAmount.add(_internalWithdraw(msg.sender));
        _internalVote(
            msg.sender,
            _gasTarget,
            _eglAmount,
            _lockupDuration,
            originalReleaseDate
        );
        emit ReVote(msg.sender, _gasTarget, _eglAmount, block.timestamp);
    }

    function withdraw() external whenNotPaused {

        require(voters[msg.sender].tokensLocked > 0, "EGL:NOT_VOTED");
        require(block.timestamp > voters[msg.sender].releaseDate, "EGL:NOT_RELEASE_DATE");
        bool success = eglToken.transfer(msg.sender, _internalWithdraw(msg.sender));
        require(success, "EGL:TOKEN_TRANSFER_FAILED");
    }

    function sweepPoolRewards() external whenNotPaused {

        require(block.number > latestRewardSwept, "EGL:ALREADY_SWEPT");
        latestRewardSwept = block.number;
        int blockGasLimit = int(block.gaslimit);
        uint blockReward = _calculateBlockReward(blockGasLimit, desiredEgl, tallyVotesGasLimit);
        if (blockReward > 0) {
            remainingPoolReward = remainingPoolReward.sub(blockReward);
            tokensInCirculation = tokensInCirculation.add(blockReward);
            bool success = eglToken.transfer(block.coinbase, Math.umin(eglToken.balanceOf(address(this)), blockReward));
            require(success, "EGL:TOKEN_TRANSFER_FAILED");
        }

        emit PoolRewardsSwept(
            msg.sender, 
            block.coinbase,
            latestRewardSwept, 
            blockGasLimit, 
            blockReward,
            block.timestamp
        );
    }

    function withdrawPoolTokens() external whenNotPaused {

        require(supporters[msg.sender].poolTokens > 0, "EGL:NO_POOL_TOKENS");
        require(block.timestamp.sub(firstEpochStartDate) > minLiquidityTokensLockup, "EGL:ALL_TOKENS_LOCKED");

        uint currentSerializedEgl = _calculateSerializedEgl(
            block.timestamp.sub(firstEpochStartDate), 
            liquidityEglMatchingTotal, 
            minLiquidityTokensLockup
        );

        Voter storage _voter = voters[msg.sender];
        Supporter storage _supporter = supporters[msg.sender];
        require(_supporter.firstEgl <= currentSerializedEgl, "EGL:ADDR_TOKENS_LOCKED");

        uint poolTokensDue;
        if (currentSerializedEgl >= _supporter.lastEgl) {
            poolTokensDue = _supporter.poolTokens;
            _supporter.poolTokens = 0;
            
            uint releaseEpoch = _voter.voteEpoch.add(_voter.lockupDuration);
            _voter.releaseDate = releaseEpoch > currentEpoch
                ? block.timestamp.add(releaseEpoch.sub(currentEpoch).mul(epochLength))
                : block.timestamp;

            emit PoolTokensWithdrawn(
                msg.sender, 
                currentSerializedEgl, 
                poolTokensDue, 
                _supporter.poolTokens,
                _supporter.firstEgl, 
                _supporter.lastEgl, 
                _voter.releaseDate,
                block.timestamp
            );
        } else {
            poolTokensDue = _calculateCurrentPoolTokensDue(
                currentSerializedEgl, 
                _supporter.firstEgl, 
                _supporter.lastEgl, 
                _supporter.poolTokens
            );
            _supporter.poolTokens = _supporter.poolTokens.sub(poolTokensDue);
            emit PoolTokensWithdrawn(
                msg.sender,
                currentSerializedEgl,
                poolTokensDue,
                _supporter.poolTokens,
                _supporter.firstEgl,
                _supporter.lastEgl,
                _voter.releaseDate,
                block.timestamp
            );
            _supporter.firstEgl = currentSerializedEgl;
        }        

        bool success = balancerPoolToken.transfer(
            msg.sender, 
            Math.umin(balancerPoolToken.balanceOf(address(this)), poolTokensDue)
        );        
        require(success, "EGL:TOKEN_TRANSFER_FAILED");
    }

    function pauseEgl() external onlyOwner whenNotPaused {

        _pause();
    }

    function unpauseEgl() external onlyOwner whenPaused {

        _unpause();
    }

    function tallyVotes() public whenNotPaused {

        require(block.timestamp > currentEpochStartDate.add(epochLength), "EGL:VOTE_NOT_ENDED");
        tallyVotesGasLimit = int(block.gaslimit);

        uint votingThreshold = currentEpoch <= voteThresholdGracePeriod
            ? DECIMAL_PRECISION.mul(10)
            : DECIMAL_PRECISION.mul(30);

	    if (currentEpoch >= WEEKS_IN_YEAR) {
            uint actualThreshold = votingThreshold.add(
                (DECIMAL_PRECISION.mul(20).div(WEEKS_IN_YEAR.mul(2)))
                .mul(currentEpoch.sub(WEEKS_IN_YEAR.sub(1)))
            );
            votingThreshold = Math.umin(actualThreshold, 50 * DECIMAL_PRECISION);
        }

        int averageGasTarget = voteWeightsSum[0] > 0
            ? int(gasTargetSum[0].div(voteWeightsSum[0]))
            : 0;
        uint votePercentage = _calculatePercentageOfTokensInCirculation(votesTotal[0]);
        if (votePercentage >= votingThreshold) {
            epochGasLimitSum = epochGasLimitSum.add(int(tallyVotesGasLimit));
            epochVoteCount = epochVoteCount.add(1);
            baselineEgl = epochGasLimitSum.div(epochVoteCount);

            desiredEgl = baselineEgl > averageGasTarget
                ? baselineEgl.sub(baselineEgl.sub(averageGasTarget).min(desiredEglThreshold))
                : baselineEgl.add(averageGasTarget.sub(baselineEgl).min(desiredEglThreshold));

            if (
                desiredEgl >= tallyVotesGasLimit.sub(10000) &&
                desiredEgl <= tallyVotesGasLimit.add(10000)
            ) 
                desiredEgl = tallyVotesGasLimit;

            emit VoteThresholdMet(
                msg.sender,
                currentEpoch,
                desiredEgl,
                votingThreshold,
                votePercentage,
                epochGasLimitSum,
                epochVoteCount,
                baselineEgl,
                block.timestamp
            );
        } else {
            if (block.timestamp.sub(firstEpochStartDate) >= epochLength.mul(voteThresholdGracePeriod))
                desiredEgl = tallyVotesGasLimit.mul(95).div(100);

            emit VoteThresholdFailed(
                msg.sender,
                currentEpoch,
                desiredEgl,
                votingThreshold,
                votePercentage,
                baselineEgl,
                initialEgl,
                block.timestamp.sub(firstEpochStartDate),
                epochLength.mul(6),
                block.timestamp
            );
        }

        for (uint8 i = 0; i < 7; i++) {
            voteWeightsSum[i] = voteWeightsSum[i + 1];
            gasTargetSum[i] = gasTargetSum[i + 1];
            votesTotal[i] = votesTotal[i + 1];
        }
        voteWeightsSum[7] = 0;
        gasTargetSum[7] = 0;
        votesTotal[7] = 0;

        epochGasLimitSum = 0;
        epochVoteCount = 0;

        if (currentEpoch >= creatorRewardFirstEpoch && remainingCreatorReward > 0)
            _issueCreatorRewards(currentEpoch);

        currentEpoch += 1;
        currentEpochStartDate = currentEpochStartDate.add(epochLength);

        emit VotesTallied(
            msg.sender,
            currentEpoch - 1,
            desiredEgl,
            averageGasTarget,
            votingThreshold,
            votePercentage,
            baselineEgl,
            tokensInCirculation,
            block.timestamp
        );
    }

    function addSeedAccount(address _seedAccount, uint _seedAmount) public onlyOwner {

        require(_seedAmount <= remainingSeederBalance, "EGL:INSUFFICIENT_SEED_BALANCE");
        require(seeders[_seedAccount] == 0, "EGL:ALREADY_SEEDER");
        require(voters[_seedAccount].tokensLocked == 0, "EGL:ALREADY_HAS_VOTE");
        require(eglToken.balanceOf(_seedAccount) == 0, "EGL:ALREADY_HAS_EGLS");
        require(block.timestamp < firstEpochStartDate.add(minLiquidityTokensLockup), "EGL:SEED_PERIOD_PASSED");
        (uint contributorAmount,,,) = eglGenesis.contributors(_seedAccount);
        require(contributorAmount == 0, "EGL:IS_CONTRIBUTOR");
        
        remainingSeederBalance = remainingSeederBalance.sub(_seedAmount);
        remainingDaoBalance = remainingDaoBalance.sub(_seedAmount);
        seeders[_seedAccount] = _seedAmount;
        emit SeedAccountAdded(
            _seedAccount,
            _seedAmount,
            remainingSeederBalance,
            block.timestamp
        );
    }

    function renounceOwnership() public override onlyOwner {

        revert("EGL:NO_RENOUNCE_OWNERSHIP");
    }

    function _internalVote(
        address _voter,
        uint _gasTarget,
        uint _eglAmount,
        uint8 _lockupDuration,
        uint _releaseTime
    ) internal {

        require(_voter != address(0), "EGL:VOTER_ADDRESS_0");
        require(block.timestamp >= firstEpochStartDate, "EGL:VOTING_NOT_STARTED");
        require(voters[_voter].tokensLocked == 0, "EGL:ALREADY_VOTED");
        require(
            Math.udelta(_gasTarget, block.gaslimit) < gasTargetTolerance,
            "EGL:INVALID_GAS_TARGET"
        );

        require(_lockupDuration >= 1 && _lockupDuration <= 8, "EGL:INVALID_LOCKUP");
        require(block.timestamp < currentEpochStartDate.add(epochLength), "EGL:VOTE_TOO_FAR");
        require(block.timestamp < currentEpochStartDate.add(epochLength).sub(votingPauseSeconds), "EGL:VOTE_TOO_CLOSE");

        epochGasLimitSum = epochGasLimitSum.add(int(block.gaslimit));
        epochVoteCount = epochVoteCount.add(1);

        uint updatedReleaseDate = block.timestamp.add(_lockupDuration.mul(epochLength)).umax(_releaseTime);

        Voter storage voter = voters[_voter];
        voter.voteEpoch = currentEpoch;
        voter.lockupDuration = _lockupDuration;
        voter.releaseDate = updatedReleaseDate;
        voter.tokensLocked = _eglAmount;
        voter.gasTarget = _gasTarget;

        uint voteWeight = _eglAmount.mul(_lockupDuration);
        for (uint8 i = 0; i < _lockupDuration; i++) {
            voteWeightsSum[i] = voteWeightsSum[i].add(voteWeight);
            gasTargetSum[i] = gasTargetSum[i].add(_gasTarget.mul(voteWeight));
            if (currentEpoch.add(i) < WEEKS_IN_YEAR)
                voterRewardSums[currentEpoch.add(i)] = voterRewardSums[currentEpoch.add(i)].add(voteWeight);
            votesTotal[i] = votesTotal[i].add(_eglAmount);
        }

        emit Vote(
            _voter,
            currentEpoch,
            _gasTarget,
            _eglAmount,
            _lockupDuration,
            updatedReleaseDate,
            voteWeightsSum[0],
            gasTargetSum[0],
            currentEpoch < WEEKS_IN_YEAR ? voterRewardSums[currentEpoch]: 0,
            votesTotal[0],
            block.timestamp
        );
    }

    function _internalWithdraw(address _voter) internal returns (uint totalWithdrawn) {

        require(_voter != address(0), "EGL:VOTER_ADDRESS_0");
        Voter storage voter = voters[_voter];
        uint16 voterEpoch = voter.voteEpoch;
        uint originalEglAmount = voter.tokensLocked;
        uint8 lockupDuration = voter.lockupDuration;
        uint gasTarget = voter.gasTarget;
        delete voters[_voter];

        uint voteWeight = originalEglAmount.mul(lockupDuration);
        uint voterReward = _calculateVoterReward(_voter, currentEpoch, voterEpoch, lockupDuration, voteWeight);        

        uint voterInterval = voterEpoch.add(lockupDuration);
        uint affectedEpochs = currentEpoch < voterInterval ? voterInterval.sub(currentEpoch) : 0;
        for (uint8 i = 0; i < affectedEpochs; i++) {
            voteWeightsSum[i] = voteWeightsSum[i].sub(voteWeight);
            gasTargetSum[i] = gasTargetSum[i].sub(voteWeight.mul(gasTarget));
            if (currentEpoch.add(i) < WEEKS_IN_YEAR) {
                voterRewardSums[currentEpoch.add(i)] = voterRewardSums[currentEpoch.add(i)].sub(voteWeight);
            }
            votesTotal[i] = votesTotal[i].sub(originalEglAmount);
        }
        
        tokensInCirculation = tokensInCirculation.add(voterReward);

        emit Withdraw(
            _voter,
            currentEpoch,
            originalEglAmount,
            voterReward,
            gasTarget,
            currentEpoch < WEEKS_IN_YEAR ? voterRewardSums[currentEpoch]: 0,
            votesTotal[0],
            voteWeightsSum[0],
            gasTargetSum[0],
            block.timestamp
        );
        totalWithdrawn = originalEglAmount.add(voterReward);
    }

    function _issueCreatorRewards(uint _rewardEpoch) internal {

        uint serializedEgl = _calculateSerializedEgl(
            _rewardEpoch.mul(epochLength), 
            creatorEglsTotal,
            creatorRewardFirstEpoch.mul(epochLength)
        );
        uint creatorRewardForEpoch = serializedEgl > 0
            ? serializedEgl.sub(lastSerializedEgl).umin(remainingCreatorReward)
            : 0;
                
        bool success = eglToken.transfer(creatorRewardsAddress, creatorRewardForEpoch);
        require(success, "EGL:TOKEN_TRANSFER_FAILED");
        remainingCreatorReward = remainingCreatorReward.sub(creatorRewardForEpoch);
        tokensInCirculation = tokensInCirculation.add(creatorRewardForEpoch);

        emit CreatorRewardsClaimed(
            msg.sender,
            creatorRewardsAddress,
            creatorRewardForEpoch,
            lastSerializedEgl,
            remainingCreatorReward,
            currentEpoch,
            block.timestamp
        );
        lastSerializedEgl = serializedEgl;
    }

    function _calculateBlockReward(
        int _blockGasLimit, 
        int _desiredEgl, 
        int _tallyVotesGasLimit
    ) 
        internal 
        returns (uint blockReward) 
    {

        uint totalRewardPercent;
        uint proximityRewardPercent;
        int eglDelta = Math.delta(_tallyVotesGasLimit, _desiredEgl);
        int actualDelta = Math.delta(_tallyVotesGasLimit, _blockGasLimit);
        int ceiling = _desiredEgl.add(10000);
        int floor = _desiredEgl.sub(10000);

        if (_blockGasLimit >= floor && _blockGasLimit <= ceiling) {
            totalRewardPercent = DECIMAL_PRECISION.mul(100);
        } else if (eglDelta > 0 && (
                (
                    _desiredEgl > _tallyVotesGasLimit 
                    && _blockGasLimit > _tallyVotesGasLimit 
                    && _blockGasLimit <= ceiling
                ) || (
                    _desiredEgl < _tallyVotesGasLimit 
                    && _blockGasLimit < _tallyVotesGasLimit 
                    && _blockGasLimit >= floor
                )
            )            
        ) {
            proximityRewardPercent = uint(actualDelta.mul(int(DECIMAL_PRECISION))
                .div(eglDelta))
                .mul(75);                
            totalRewardPercent = proximityRewardPercent.add(DECIMAL_PRECISION.mul(25));
        }

        blockReward = totalRewardPercent.mul(remainingPoolReward.div(2500000))
            .div(DECIMAL_PRECISION)
            .div(100);

        emit BlockRewardCalculated(
            block.number,
            currentEpoch,
            remainingPoolReward,
            _blockGasLimit,
            _desiredEgl,
            _tallyVotesGasLimit,
            proximityRewardPercent,
            totalRewardPercent, 
            blockReward,
            block.timestamp
        );
    }

    function _calculateSerializedEgl(uint _timeSinceOrigin, uint _maxEglSupply, uint _timeLocked) 
        internal                  
        returns (uint serializedEgl) 
    {

        if (_timeSinceOrigin >= epochLength.mul(WEEKS_IN_YEAR))
            return _maxEglSupply;

        uint timePassedPercentage = _timeSinceOrigin
            .sub(_timeLocked)
            .mul(DECIMAL_PRECISION)
            .div(
                epochLength.mul(WEEKS_IN_YEAR).sub(_timeLocked)
            );

        serializedEgl = ((timePassedPercentage.div(10**8))**4)
            .mul(_maxEglSupply.div(DECIMAL_PRECISION))
            .mul(10**8)
            .div((10**10)**3);

        emit SerializedEglCalculated(
            currentEpoch, 
            _timeSinceOrigin,
            timePassedPercentage.mul(100), 
            serializedEgl, 
            _maxEglSupply,
            block.timestamp
        );
    }

    function _calculateCurrentPoolTokensDue(
        uint _currentEgl, 
        uint _firstEgl, 
        uint _lastEgl, 
        uint _totalPoolTokens
    ) 
        internal 
        pure
        returns (uint poolTokensDue) 
    {

        require(_firstEgl < _lastEgl, "EGL:INVALID_SERIALIZED_EGLS");

        if (_currentEgl < _firstEgl) 
            return 0;

        uint eglsReleased = (_currentEgl.umin(_lastEgl)).sub(_firstEgl);
        poolTokensDue = _totalPoolTokens
            .mul(eglsReleased)
            .div(
                _lastEgl.sub(_firstEgl)
            );
    }

    function _calculateBonusEglsDue(
        uint _firstEgl, 
        uint _lastEgl
    )
        internal    
        pure     
        returns (uint bonusEglsDue)  
    {

        require(_firstEgl < _lastEgl, "EGL:INVALID_SERIALIZED_EGLS");

        bonusEglsDue = (_lastEgl.div(DECIMAL_PRECISION)**4)
            .sub(_firstEgl.div(DECIMAL_PRECISION)**4)
            .mul(DECIMAL_PRECISION)
            .div(
                (81/128)*(10**27)
            );
    }

    function _calculateVoterReward(
        address _voter,
        uint16 _currentEpoch,
        uint16 _voterEpoch,
        uint8 _lockupDuration,
        uint _voteWeight
    ) 
        internal         
        returns(uint rewardsDue) 
    {

        require(_voter != address(0), "EGL:VOTER_ADDRESS_0");

        uint rewardEpochs = _voterEpoch.add(_lockupDuration).umin(_currentEpoch).umin(WEEKS_IN_YEAR);
        for (uint16 i = _voterEpoch; i < rewardEpochs; i++) {
            uint epochReward = voterRewardSums[i] > 0 
                ? Math.umin(
                    _voteWeight.mul(voterRewardMultiplier)
                        .mul(WEEKS_IN_YEAR.sub(i))
                        .div(voterRewardSums[i]),
                    remainingVoterReward
                )
                : 0;
            rewardsDue = rewardsDue.add(epochReward);
            remainingVoterReward = remainingVoterReward.sub(epochReward);
            emit VoterRewardCalculated(
                _voter,
                _currentEpoch,
                rewardsDue,
                epochReward,
                _voteWeight,
                voterRewardMultiplier,
                WEEKS_IN_YEAR.sub(i),
                voterRewardSums[i],
                remainingVoterReward,
                block.timestamp
            );
        }
    }

    function _calculatePercentageOfTokensInCirculation(uint _total) 
        internal 
        view 
        returns (uint votePercentage) 
    {

        votePercentage = tokensInCirculation > 0
            ? _total.mul(DECIMAL_PRECISION).mul(100).div(tokensInCirculation)
            : 0;
    }
}