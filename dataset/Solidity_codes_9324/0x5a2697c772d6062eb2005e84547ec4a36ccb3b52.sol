
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}//MIT
pragma solidity 0.7.5;


interface IStakingRewards {

    function stake(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function getReward() external;


    function exit() external;

    function lastTimeRewardApplicable() external view returns (uint256);


    function rewardPerToken() external view returns (uint256);


    function earned(address account) external view returns (uint256);


    function getRewardForDuration() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}//MIT
pragma solidity 0.7.5;


abstract contract Owned is Ownable {
    constructor(address _owner) {
        transferOwnership(_owner);
    }
}//MIT
pragma solidity 0.7.5;



abstract contract Pausable is Owned {
    bool public paused;

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }

    constructor() {
        require(owner() != address(0), "Owner must be set");
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused == paused) {
            return;
        }

        paused = _paused;

        emit PauseChanged(paused);
    }
}//MIT
pragma solidity 0.7.5;

interface IBurnableToken {

    function burn(uint256 _amount) external;

}//MIT
pragma solidity 0.7.5;



abstract contract RewardsDistributionRecipient is Owned {
    address public rewardsDistribution;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistributor");
        _;
    }

    function notifyRewardAmount(uint256 reward) virtual external;

    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

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

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}//MIT
pragma solidity 0.7.5;



abstract contract MintableToken is Owned, ERC20, IBurnableToken {
    uint256 public immutable maxAllowedTotalSupply;
    uint256 public everMinted;

    modifier assertMaxSupply(uint256 _amountToMint) {
        _assertMaxSupply(_amountToMint);
        _;
    }


    constructor (uint256 _maxAllowedTotalSupply) {
        require(_maxAllowedTotalSupply != 0, "_maxAllowedTotalSupply is empty");

        maxAllowedTotalSupply = _maxAllowedTotalSupply;
    }


    function burn(uint256 _amount) override external {
        _burn(msg.sender, _amount);
    }


    function mint(address _holder, uint256 _amount)
        virtual
        external
        onlyOwner()
        assertMaxSupply(_amount)
    {
        require(_amount != 0, "zero amount");

        _mint(_holder, _amount);
    }

    function _assertMaxSupply(uint256 _amountToMint) internal {
        uint256 everMintedTotal = everMinted + _amountToMint;
        everMinted = everMintedTotal;
        require(everMintedTotal <= maxAllowedTotalSupply, "total supply limit exceeded");
    }
}//MIT
pragma solidity 0.7.5;


abstract contract OnDemandToken is MintableToken {
    bool constant public ON_DEMAND_TOKEN = true;

    mapping (address => bool) public minters;

    event SetupMinter(address minter, bool active);

    modifier onlyOwnerOrMinter() {
        address msgSender = _msgSender();
        require(owner() == msgSender || minters[msgSender], "access denied");

        _;
    }

    function setupMinter(address _minter, bool _active) external onlyOwner() {
        minters[_minter] = _active;
        emit SetupMinter(_minter, _active);
    }

    function setupMinters(address[] calldata _minters, bool[] calldata _actives) external onlyOwner() {
        for (uint256 i; i < _minters.length; i++) {
            minters[_minters[i]] = _actives[i];
            emit SetupMinter(_minters[i], _actives[i]);
        }
    }

    function mint(address _holder, uint256 _amount)
        external
        virtual
        override
        onlyOwnerOrMinter()
        assertMaxSupply(_amount)
    {
        require(_amount != 0, "zero amount");

        _mint(_holder, _amount);
    }
}//MIT
pragma solidity 0.7.5;


abstract contract LockSettings is Ownable {
    uint256 public constant RATE_DECIMALS = 10 ** 6;
    uint256 public constant MAX_MULTIPLIER = 5 * RATE_DECIMALS;

    mapping(address => mapping(uint256 => uint256)) public multipliers;

    mapping(address => mapping(uint256 => uint256)) public periodIndexes;

    mapping(address => uint256[]) public periods;

    event TokenSettings(address indexed token, uint256 period, uint256 multiplier);

    function removePeriods(address _token, uint256[] calldata _periods) external onlyOwner {
        for (uint256 i; i < _periods.length; i++) {
            if (_periods[i] == 0) revert("InvalidSettings");

            multipliers[_token][_periods[i]] = 0;
            _removePeriod(_token, _periods[i]);

            emit TokenSettings(_token, _periods[i], 0);
        }
    }

    function setLockingTokenSettings(address _token, uint256[] calldata _periods, uint256[] calldata _multipliers)
        external
        onlyOwner
    {
        if (_periods.length == 0) revert("EmptyPeriods");
        if (_periods.length != _multipliers.length) revert("ArraysNotMatch");

        for (uint256 i; i < _periods.length; i++) {
            if (_periods[i] == 0) revert("InvalidSettings");
            if (_multipliers[i] < RATE_DECIMALS) revert("multiplier must be >= 1e6");
            if (_multipliers[i] > MAX_MULTIPLIER) revert("multiplier overflow");

            multipliers[_token][_periods[i]] = _multipliers[i];
            emit TokenSettings(_token, _periods[i], _multipliers[i]);

            if (_multipliers[i] == 0) _removePeriod(_token, _periods[i]);
            else _addPeriod(_token, _periods[i]);
        }
    }

    function periodsCount(address _token) external view returns (uint256) {
        return periods[_token].length;
    }

    function getPeriods(address _token) external view returns (uint256[] memory) {
        return periods[_token];
    }

    function _addPeriod(address _token, uint256 _period) internal {
        uint256 key = periodIndexes[_token][_period];
        if (key != 0) return;

        periods[_token].push(_period);
        periodIndexes[_token][_period] = periods[_token].length;
    }

    function _removePeriod(address _token, uint256 _period) internal {
        uint256 key = periodIndexes[_token][_period];
        if (key == 0) return;

        periods[_token][key - 1] = periods[_token][periods[_token].length - 1];
        periodIndexes[_token][_period] = 0;
        periods[_token].pop();
    }
}//MIT
pragma solidity 0.7.5;

interface ISwapReceiver {
    function swapMint(address _holder, uint256 _amount) external;
}//MIT
pragma solidity 0.7.5;




abstract contract SwappableTokenV2 is Owned, ERC20 {
    struct SwapData {
        uint32 swappedSoFar;
        uint32 usedLimit;
        uint32 dailyCup;
        uint32 dailyCupTimestamp;
        uint32 swapEnabledAt;
    }

    uint256 public constant ONE = 1e18;

    uint256 public immutable swapStartsOn;
    ISwapReceiver public immutable umb;

    SwapData public swapData;

    event LogStartEarlySwapNow(uint time);
    event LogSwap(address indexed swappedTo, uint amount);
    event LogDailyCup(uint newCup);

    constructor(address _umb, uint32 _swapStartsOn, uint32 _dailyCup) {
        require(_dailyCup != 0, "invalid dailyCup");
        require(_swapStartsOn > block.timestamp, "invalid swapStartsOn");
        require(ERC20(_umb).decimals() == 18, "invalid UMB token");

        swapStartsOn = _swapStartsOn;
        umb = ISwapReceiver(_umb);
        swapData.dailyCup = _dailyCup;
    }

    function swapForUMB() external {
        SwapData memory data = swapData;

        (uint256 limit, bool fullLimit) = _currentLimit(data);
        require(limit != 0, "swapping period not started OR limit");

        uint256 amountToSwap = balanceOf(msg.sender);
        require(amountToSwap != 0, "you dont have tokens to swap");

        uint32 amountWoDecimals = uint32(amountToSwap / ONE);
        require(amountWoDecimals <= limit, "daily CUP limit");

        swapData.usedLimit = uint32(fullLimit ? amountWoDecimals : data.usedLimit + amountWoDecimals);
        swapData.swappedSoFar += amountWoDecimals;
        if (fullLimit) swapData.dailyCupTimestamp = uint32(block.timestamp);

        _burn(msg.sender, amountToSwap);
        umb.swapMint(msg.sender, amountToSwap);

        emit LogSwap(msg.sender, amountToSwap);
    }

    function startEarlySwap() external onlyOwner {
        require(block.timestamp < swapStartsOn, "swap is already allowed");
        require(swapData.swapEnabledAt == 0, "swap was already enabled");

        swapData.swapEnabledAt = uint32(block.timestamp);
        emit LogStartEarlySwapNow(block.timestamp);
    }

    function setDailyCup(uint32 _cup) external onlyOwner {
        swapData.dailyCup = _cup;
        emit LogDailyCup(_cup);
    }

    function isSwapStarted() external view returns (bool) {
        return block.timestamp >= swapStartsOn || swapData.swapEnabledAt != 0;
    }

    function canSwapTokens(address _address) external view returns (bool) {
        uint256 balance = balanceOf(_address);
        if (balance == 0) return false;

        (uint256 limit,) = _currentLimit(swapData);
        return balance / ONE <= limit;
    }

    function currentLimit() external view returns (uint256 limit) {
        (limit,) = _currentLimit(swapData);
        limit *= ONE;
    }

    function _currentLimit(SwapData memory data) internal view returns (uint256 limit, bool fullLimit) {
        if (block.timestamp < swapStartsOn && data.swapEnabledAt == 0) return (0, false);

        fullLimit = block.timestamp - data.dailyCupTimestamp >= 24 hours;
        limit = fullLimit ? data.dailyCup : data.dailyCup - data.usedLimit;
    }
}//MIT
pragma solidity 0.7.5;



contract StakingLockable is LockSettings, RewardsDistributionRecipient, ReentrancyGuard, Pausable {
    struct Times {
        uint32 periodFinish;
        uint32 rewardsDuration;
        uint32 lastUpdateTime;
        uint96 totalRewardsSupply;
    }

    struct Balance {
        uint96 umbBalance;
        uint96 lockedWithBonus;
        uint32 nextLockIndex;
        uint160 userRewardPerTokenPaid;
        uint96 rewards;
    }

    struct Supply {
        uint128 totalBalance;
        uint128 totalBonus;
    }

    struct Lock {
        uint8 tokenId;
        uint120 amount;
        uint32 lockDate;
        uint32 unlockDate;
        uint32 multiplier;
        uint32 withdrawnAt;
    }

    uint8 public constant UMB_ID = 2 ** 0;
    uint8 public constant RUMB1_ID = 2 ** 1;
    uint8 public constant RUMB2_ID = 2 ** 2;

    uint256 public immutable maxEverTotalRewards;

    address public immutable umb;
    address public immutable rUmb1;
    address public immutable rUmb2;

    uint256 public rewardRate = 0;
    uint256 public rewardPerTokenStored;

    Supply public totalSupply;

    Times public timeData;

    mapping(address => Balance) public balances;

    mapping(address => mapping(uint256 => Lock)) public locks;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount, uint256 bonus);

    event LockedTokens(
        address indexed user,
        address indexed token,
        uint256 lockId,
        uint256 amount,
        uint256 period,
        uint256 multiplier
    );

    event UnlockedTokens(address indexed user, address indexed token, uint256 lockId, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event FarmingFinished();
    event Swap1to2(uint256 swapped);

    modifier updateReward(address _account) virtual {
        uint256 newRewardPerTokenStored = rewardPerToken();
        rewardPerTokenStored = newRewardPerTokenStored;
        timeData.lastUpdateTime = uint32(lastTimeRewardApplicable());

        if (_account != address(0)) {
            balances[_account].rewards = uint96(earned(_account));
            balances[_account].userRewardPerTokenPaid = uint160(newRewardPerTokenStored);
        }

        _;
    }

    constructor(
        address _owner,
        address _rewardsDistribution,
        address _umb,
        address _rUmb1,
        address _rUmb2
    ) Owned(_owner) {
        require(
            (
                MintableToken(_umb).maxAllowedTotalSupply() +
                MintableToken(_rUmb1).maxAllowedTotalSupply() +
                MintableToken(_rUmb2).maxAllowedTotalSupply()
            ) * MAX_MULTIPLIER / RATE_DECIMALS <= type(uint96).max,
            "staking overflow"
        );

        require(
            MintableToken(_rUmb2).maxAllowedTotalSupply() * MAX_MULTIPLIER / RATE_DECIMALS <= type(uint96).max,
            "rewards overflow"
        );

        require(OnDemandToken(_rUmb2).ON_DEMAND_TOKEN(), "rewardsToken must be OnDemandToken");

        umb = _umb;
        rUmb1 = _rUmb1;
        rUmb2 = _rUmb2;

        rewardsDistribution = _rewardsDistribution;
        timeData.rewardsDuration = 2592000; // 30 days
        maxEverTotalRewards = MintableToken(_rUmb2).maxAllowedTotalSupply();
    }

    function lockTokens(address _token, uint256 _amount, uint256 _period) external {
        if (_token == rUmb2 && !SwappableTokenV2(rUmb2).isSwapStarted()) {
            revert("locking rUMB2 not available yet");
        }

        _lockTokens(msg.sender, _token, _amount, _period);
    }

    function unlockTokens(uint256[] calldata _ids) external {
        _unlockTokensFor(msg.sender, _ids, msg.sender);
    }

    function restart(uint256 _rewardsDuration, uint256 _reward) external {
        setRewardsDuration(_rewardsDuration);
        notifyRewardAmount(_reward);
    }

    function finishFarming() external onlyOwner {
        Times memory t = timeData;
        require(block.timestamp < t.periodFinish, "can't stop if not started or already finished");

        if (totalSupply.totalBalance != 0) {
            uint32 remaining = uint32(t.periodFinish - block.timestamp);
            timeData.rewardsDuration = t.rewardsDuration - remaining;
        }

        timeData.periodFinish = uint32(block.timestamp);

        emit FarmingFinished();
    }

    function exit() external {
        _withdraw(type(uint256).max, msg.sender, msg.sender);
        _getReward(msg.sender, msg.sender);
    }

    function exitAndUnlock(uint256[] calldata _lockIds) external {
        _withdraw(type(uint256).max, msg.sender, msg.sender);
        _unlockTokensFor(msg.sender, _lockIds, msg.sender);
        _getReward(msg.sender, msg.sender);
    }

    function stake(uint256 _amount) external {
        _stake(umb, msg.sender, _amount, 0);
    }

    function getReward() external {
        _getReward(msg.sender, msg.sender);
    }

    function swap1to2() public {
        if (!SwappableTokenV2(rUmb2).isSwapStarted()) return;

        uint256 myBalance = IERC20(rUmb1).balanceOf(address(this));
        if (myBalance == 0) return;

        IBurnableToken(rUmb1).burn(myBalance);
        OnDemandToken(rUmb2).mint(address(this), myBalance);

        emit Swap1to2(myBalance);
    }

    function notifyRewardAmount(
        uint256 _reward
    ) override public onlyRewardsDistribution updateReward(address(0)) {
        swap1to2();

        Times memory t = timeData;
        uint256 newRewardRate;

        if (block.timestamp >= t.periodFinish) {
            newRewardRate = _reward / t.rewardsDuration;
        } else {
            uint256 remaining = t.periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            newRewardRate = (_reward + leftover) / t.rewardsDuration;
        }

        require(newRewardRate != 0, "invalid rewardRate");

        rewardRate = newRewardRate;

        uint256 totalRewardsSupply = timeData.totalRewardsSupply + _reward;
        require(totalRewardsSupply <= maxEverTotalRewards, "rewards overflow");

        timeData.totalRewardsSupply = uint96(totalRewardsSupply);
        timeData.lastUpdateTime = uint32(block.timestamp);
        timeData.periodFinish = uint32(block.timestamp + t.rewardsDuration);

        emit RewardAdded(_reward);
    }

    function setRewardsDuration(uint256 _rewardsDuration) public onlyRewardsDistribution {
        require(_rewardsDuration != 0, "empty _rewardsDuration");

        require(
            block.timestamp > timeData.periodFinish,
            "Previous period must be complete before changing the duration"
        );

        timeData.rewardsDuration = uint32(_rewardsDuration);
        emit RewardsDurationUpdated(_rewardsDuration);
    }

    function withdraw(uint256 _amount) public {
        _withdraw(_amount, msg.sender, msg.sender);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        uint256 periodFinish = timeData.periodFinish;
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() public view returns (uint256 perToken) {
        Supply memory s = totalSupply;

        if (s.totalBalance == 0) {
            return rewardPerTokenStored;
        }

        perToken = rewardPerTokenStored + (
            (lastTimeRewardApplicable() - timeData.lastUpdateTime) * rewardRate * 1e18 / (s.totalBalance + s.totalBonus)
        );
    }

    function earned(address _account) virtual public view returns (uint256) {
        Balance memory b = balances[_account];
        uint256 totalBalance = b.umbBalance + b.lockedWithBonus;
        return (totalBalance * (rewardPerToken() - b.userRewardPerTokenPaid) / 1e18) + b.rewards;
    }

    function calculateBonus(uint256 _amount, uint256 _multiplier) public pure returns (uint256 bonus) {
        if (_multiplier <= RATE_DECIMALS) return 0;

        bonus = _amount * _multiplier / RATE_DECIMALS - _amount;
    }

    function _stake(address _token, address _user, uint256 _amount, uint256 _bonus)
        internal
        nonReentrant
        notPaused
        updateReward(_user)
    {
        uint256 amountWithBonus = _amount + _bonus;

        require(timeData.periodFinish > block.timestamp, "Stake period not started yet");
        require(amountWithBonus != 0, "Cannot stake 0");

        totalSupply.totalBalance += uint96(_amount);
        totalSupply.totalBonus += uint128(_bonus);

        if (_bonus == 0) {
            balances[_user].umbBalance += uint96(_amount);
        } else {
            balances[_user].lockedWithBonus += uint96(amountWithBonus);
        }

        require(IERC20(_token).transferFrom(_user, address(this), _amount), "token transfer failed");

        emit Staked(_user, _amount, _bonus);
    }

    function _lockTokens(address _user, address _token, uint256 _amount, uint256 _period) internal notPaused {
        uint256 multiplier = multipliers[_token][_period];
        require(multiplier != 0, "invalid period or not supported token");

        uint256 stakeBonus = calculateBonus(_amount, multiplier);

        _stake(_token, _user, _amount, stakeBonus);
        _addLock(_user, _token, _amount, _period, multiplier);
    }

    function _addLock(address _user, address _token, uint256 _amount, uint256 _period, uint256 _multiplier) internal {
        uint256 newIndex = balances[_user].nextLockIndex;
        if (newIndex == type(uint32).max) revert("nextLockIndex overflow");

        balances[_user].nextLockIndex = uint32(newIndex + 1);

        Lock storage lock = locks[_user][newIndex];

        lock.amount = uint120(_amount);
        lock.multiplier = uint32(_multiplier);
        lock.lockDate = uint32(block.timestamp);
        lock.unlockDate = uint32(block.timestamp + _period);

        if (_token == rUmb2) lock.tokenId = RUMB2_ID;
        else if (_token == rUmb1) lock.tokenId = RUMB1_ID;
        else lock.tokenId = UMB_ID;

        emit LockedTokens(_user, _token, newIndex, _amount, _period, _multiplier);
    }

    function _unlockTokensFor(address _user, uint256[] calldata _indexes, address _recipient)
        internal
        returns (address token, uint256 totalRawAmount)
    {
        uint256 totalBonus;
        uint256 acceptedTokenId;
        bool isSwapStarted = SwappableTokenV2(rUmb2).isSwapStarted();

        for (uint256 i; i < _indexes.length; i++) {
            (uint256 amount, uint256 bonus, uint256 tokenId) = _markAsUnlocked(_user, _indexes[i]);
            if (amount == 0) continue;

            if (acceptedTokenId == 0) {
                acceptedTokenId = tokenId;
                token = _idToToken(tokenId);


                if (token == rUmb1 && isSwapStarted) {
                    token = rUmb2;
                    acceptedTokenId = RUMB2_ID;
                }
            } else if (acceptedTokenId != tokenId) {
                if (acceptedTokenId == RUMB2_ID && tokenId == RUMB1_ID) {
                } else revert("batch unlock possible only for the same tokens");
            }

            emit UnlockedTokens(_user, token, _indexes[i], amount);

            totalRawAmount += amount;
            totalBonus += bonus;
        }

        if (totalRawAmount == 0) revert("nothing to unlock");
        _withdrawUnlockedTokens(_user, token, _recipient, totalRawAmount, totalBonus);
    }

    function _withdrawUnlockedTokens(
        address _user,
        address _token,
        address _recipient,
        uint256 _totalRawAmount,
        uint256 _totalBonus
    )
        internal
    {
        uint256 amountWithBonus = _totalRawAmount + _totalBonus;

        balances[_user].lockedWithBonus -= uint96(amountWithBonus);

        totalSupply.totalBalance -= uint96(_totalRawAmount);
        totalSupply.totalBonus -= uint128(_totalBonus);

        require(IERC20(_token).transfer(_recipient, _totalRawAmount), "withdraw unlocking failed");
    }

    function _markAsUnlocked(address _user, uint256 _index)
        internal
        returns (uint256 amount, uint256 bonus, uint256 tokenId)
    {
        Lock memory lock = locks[_user][_index];

        if (lock.withdrawnAt != 0) revert("DepositAlreadyWithdrawn");
        if (block.timestamp < lock.unlockDate) revert("DepositLocked");

        if (lock.amount == 0) return (0, 0, 0);

        locks[_user][_index].withdrawnAt = uint32(block.timestamp);

        return (lock.amount, calculateBonus(lock.amount, lock.multiplier), lock.tokenId);
    }

    function _withdraw(uint256 _amount, address _user, address _recipient) internal nonReentrant updateReward(_user) {
        Balance memory balance = balances[_user];

        if (_amount == type(uint256).max) _amount = balance.umbBalance;
        else require(balance.umbBalance >= _amount, "withdraw amount to high");

        if (_amount == 0) return;

        totalSupply.totalBalance -= uint120(_amount);
        balances[_user].umbBalance = uint96(balance.umbBalance - _amount);

        require(IERC20(umb).transfer(_recipient, _amount), "token transfer failed");

        emit Withdrawn(_user, _amount);
    }

    function _getReward(address _user, address _recipient)
        internal
        nonReentrant
        updateReward(_user)
        returns (uint256 reward)
    {
        reward = balances[_user].rewards;

        if (reward != 0) {
            balances[_user].rewards = 0;
            OnDemandToken(address(rUmb2)).mint(_recipient, reward);
            emit RewardPaid(_user, reward);
        }
    }

    function _idToToken(uint256 _tokenId) internal view returns (address token) {
        if (_tokenId == RUMB2_ID) token = rUmb2;
        else if (_tokenId == RUMB1_ID) token = rUmb1;
        else if (_tokenId == UMB_ID) token = umb;
        else return address(0);
    }
}//MIT
pragma solidity >=0.7.5 <0.9.0;

interface IMigrationReceiver {

    function migrateTokenCallback(address _token, address _user, uint256 _amount, bytes calldata _data) external;
}//MIT
pragma solidity 0.7.5;


contract StakingRewardsV2 is StakingLockable {
    constructor(
        address _owner,
        address _rewardsDistribution,
        address _umb,
        address _rUmb1,
        address _rUmb2
    ) StakingLockable(_owner, _rewardsDistribution, _umb, _rUmb1, _rUmb2) {}

    function getRewardAndMigrate(IMigrationReceiver _newPool, bytes calldata _data) external {
        uint256 reward = _getReward(msg.sender, address(_newPool));
        _newPool.migrateTokenCallback(rUmb2, msg.sender, reward, _data);
    }

    function withdrawAndMigrate(IMigrationReceiver _newPool, uint256 _amount, bytes calldata _data) external {
        _withdraw(_amount, msg.sender, address(_newPool));
        _newPool.migrateTokenCallback(umb, msg.sender, _amount, _data);
    }

    function unlockAndMigrate(IMigrationReceiver _newPool, uint256[] calldata _ids, bytes calldata _data) external {
        (address token, uint256 totalRawAmount) = _unlockTokensFor(msg.sender, _ids, address(_newPool));
        _newPool.migrateTokenCallback(token, msg.sender, totalRawAmount, _data);
    }
}