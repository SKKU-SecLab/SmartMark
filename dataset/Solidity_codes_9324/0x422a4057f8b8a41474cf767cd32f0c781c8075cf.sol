
pragma solidity 0.5.16;

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}



interface IStakingRewards {

    function lastTimeRewardApplicable(address rewardToken) external view returns (uint256);


    function rewardPerToken(address rewardToken) external view returns (uint256);


    function earned(address account, address rewardToken) external view returns (uint256);


    function getRewardForDuration(address rewardToken) external view returns (uint256);


    function totalStakesAmount() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);



    function stake(uint256 amount) external;


    function withdraw(uint256 amount) external;


    function getReward() external;


    function exit() external;

}

interface IERC20Detailed {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}




library SafeERC20Detailed {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20Detailed token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Detailed token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Detailed token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Detailed token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Detailed token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20Detailed token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract RewardsDistributionRecipient {

    address public rewardsDistributor;

    function start() external;


    modifier onlyRewardsDistributor() {

        require(msg.sender == rewardsDistributor, "Caller is not RewardsDistribution contract");
        _;
    }
}// MIT








contract StakingRewards is
    IStakingRewards,
    RewardsDistributionRecipient,
    ReentrancyGuard
{

    using SafeMath for uint256;
    using SafeERC20Detailed for IERC20Detailed;


    IERC20Detailed public stakingToken;
    uint256 private _totalStakesAmount;
    mapping(address => uint256) private _balances;

    struct RewardInfo {
        uint256 rewardRate;
        uint256 latestRewardPerTokenSaved;
        uint256 periodFinish;
        uint256 lastUpdateTime;
        uint256 rewardDuration;

        mapping(address => uint256) userRewardPerTokenRecorded;
        mapping(address => uint256) rewards;
    }

    mapping(address => RewardInfo) public rewardsTokensMap; // structure for fast access to token's data
    address[] public rewardsTokensArr; // structure to iterate over
    uint256[] public rewardsAmountsArr;


    event RewardAdded(address[] token, uint256[] reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, address indexed rewardToken, uint256 rewardAmount);
    event RewardExtended(
        address indexed rewardToken,
        uint256 rewardAmount,
        uint256 date,
        uint256 periodToExtend
    );


    constructor(
        address[] memory _rewardsTokens,
        uint256[] memory _rewardsAmounts,
        address _stakingToken,
        uint256 _rewardsDuration
    ) public {
        for (uint i = 0; i < _rewardsTokens.length; i++) {
            rewardsTokensMap[_rewardsTokens[i]] = RewardInfo(0, 0, 0, 0, _rewardsDuration);
        }
        rewardsTokensArr = _rewardsTokens;
        rewardsAmountsArr = _rewardsAmounts;
        stakingToken = IERC20Detailed(_stakingToken);

        rewardsDistributor = msg.sender;
    }


    modifier updateReward(address account) {

        for (uint i = 0; i < rewardsTokensArr.length; i++) {
            address token = rewardsTokensArr[i];
            RewardInfo storage ri = rewardsTokensMap[token];

            ri.latestRewardPerTokenSaved = rewardPerToken(token); // Calculate the reward until now
            ri.lastUpdateTime = lastTimeRewardApplicable(token); // Update the last update time to now (or end date) for future calculations

            if (account != address(0)) {
                ri.rewards[account] = earned(account, token);
                ri.userRewardPerTokenRecorded[account] = ri.latestRewardPerTokenSaved;
            }
        }
        _;
    }


    function getRewardsTokensCount()
        external
        view
        returns (uint)
    {

        return rewardsTokensArr.length;
    }

    function getUserRewardPerTokenRecorded(address rewardToken, address user)
        external
        view
        returns (uint256)
    {

        return rewardsTokensMap[rewardToken].userRewardPerTokenRecorded[user];
    }

    function getUserReward(address rewardToken, address user)
        external
        view
        returns (uint256)
    {

        return rewardsTokensMap[rewardToken].rewards[user];
    }

    function totalStakesAmount() external view returns (uint256) {

        return _totalStakesAmount;
    }

    function balanceOf(address account) external view returns (uint256) {

        return _balances[account];
    }

    function getRewardForDuration(address rewardToken) external view returns (uint256) {

        RewardInfo storage ri = rewardsTokensMap[rewardToken];
        return ri.rewardRate.mul(ri.rewardDuration);
    }

    function hasPeriodStarted()
        external
        view
        returns (bool)
    {

        for (uint i = 0; i < rewardsTokensArr.length; i++) {
            if (rewardsTokensMap[rewardsTokensArr[i]].periodFinish != 0) {
                return true;
            }
        }

        return false;
    }

    function stake(uint256 amount)
        external
        nonReentrant
        updateReward(msg.sender)
    {

        require(amount != 0, "Cannot stake 0");
        _totalStakesAmount = _totalStakesAmount.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function exit() external {

        withdraw(_balances[msg.sender]);
        getReward();
    }

    function start()
        external
        onlyRewardsDistributor
        updateReward(address(0))
    {

        for (uint i = 0; i < rewardsTokensArr.length; i++) {
            address token = rewardsTokensArr[i];
            RewardInfo storage ri = rewardsTokensMap[token];

            ri.rewardRate = rewardsAmountsArr[i].div(ri.rewardDuration);
            uint256 balance = IERC20Detailed(token).balanceOf(address(this));
            require(
                ri.rewardRate <= balance.div(ri.rewardDuration),
                "Provided reward too high"
            );

            ri.lastUpdateTime = block.timestamp;
            ri.periodFinish = block.timestamp.add(ri.rewardDuration);
        }

        emit RewardAdded(rewardsTokensArr, rewardsAmountsArr);
    }

    function addRewards(address rewardToken, uint256 rewardAmount)
        external
        updateReward(address(0))
        onlyRewardsDistributor
    {

        uint256 periodToExtend = getPeriodsToExtend(rewardToken, rewardAmount);
        IERC20Detailed(rewardToken).safeTransferFrom(msg.sender, address(this), rewardAmount);

        RewardInfo storage ri = rewardsTokensMap[rewardToken];
        ri.periodFinish = ri.periodFinish.add(periodToExtend);
        ri.rewardDuration = ri.rewardDuration.add(periodToExtend);

        emit RewardExtended(rewardToken, rewardAmount, block.timestamp, periodToExtend);
    }

    function lastTimeRewardApplicable(address rewardToken) public view returns (uint256) {

        return Math.min(block.timestamp, rewardsTokensMap[rewardToken].periodFinish);
    }

    function rewardPerToken(address rewardToken) public view returns (uint256) {

        RewardInfo storage ri = rewardsTokensMap[rewardToken];

        if (_totalStakesAmount == 0) {
            return ri.latestRewardPerTokenSaved;
        }

        uint256 timeSinceLastSave = lastTimeRewardApplicable(rewardToken).sub(
            ri.lastUpdateTime
        );

        uint256 rewardPerTokenSinceLastSave = timeSinceLastSave
            .mul(ri.rewardRate)
            .mul(10 ** uint256(IERC20Detailed(address(stakingToken)).decimals()))
            .div(_totalStakesAmount);

        return ri.latestRewardPerTokenSaved.add(rewardPerTokenSinceLastSave);
    }

    function earned(address account, address rewardToken) public view returns (uint256) {

        RewardInfo storage ri = rewardsTokensMap[rewardToken];

        uint256 userRewardPerTokenSinceRecorded = rewardPerToken(rewardToken).sub(
            ri.userRewardPerTokenRecorded[account]
        );

        uint256 newReward = _balances[account]
            .mul(userRewardPerTokenSinceRecorded)
            .div(10 ** uint256(IERC20Detailed(address(stakingToken)).decimals()));

        return ri.rewards[account].add(newReward);
    }

    function getPeriodsToExtend(address rewardToken, uint256 rewardAmount)
        public
        view
        returns (uint256 periodToExtend)
    {

        require(rewardAmount != 0, "Rewards should be greater than zero");

        RewardInfo storage ri = rewardsTokensMap[rewardToken];
        require(ri.rewardRate != 0, "Staking is not yet started");

        periodToExtend = rewardAmount.div(ri.rewardRate);
    }

    function hasPeriodFinished()
        public
        view
        returns (bool)
    {

        for (uint i = 0; i < rewardsTokensArr.length; i++) {
            if (block.timestamp < rewardsTokensMap[rewardsTokensArr[i]].periodFinish) {
                return false;
            }
        }

        return true;
    }

    function withdraw(uint256 amount)
        public
        nonReentrant
        updateReward(msg.sender)
    {

        require(amount != 0, "Cannot withdraw 0");
        _totalStakesAmount = _totalStakesAmount.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward()
        public
        nonReentrant
        updateReward(msg.sender)
    {

        uint256 tokenArrLength = rewardsTokensArr.length;
        for (uint i = 0; i < tokenArrLength; i++) {
            address token = rewardsTokensArr[i];
            RewardInfo storage ri = rewardsTokensMap[token];

            uint256 reward = ri.rewards[msg.sender];
            if (reward != 0) {
                ri.rewards[msg.sender] = 0;
                IERC20Detailed(token).safeTransfer(msg.sender, reward);
                emit RewardPaid(msg.sender, token, reward);
            }
        }
    }
}



contract StakingRewardsFactory is Ownable {

    using SafeERC20Detailed for IERC20Detailed;

    uint256 public stakingRewardsGenesis;

    address[] public stakingTokens;

    mapping(address => address) public stakingRewardsByStakingToken;


    constructor(
        uint256 _stakingRewardsGenesis
    ) public {
        require(_stakingRewardsGenesis >= block.timestamp, 'StakingRewardsFactory::constructor: genesis too soon');

        stakingRewardsGenesis = _stakingRewardsGenesis;
    }


    function deploy(
        address            _stakingToken,
        address[] calldata _rewardsTokens,
        uint256[] calldata _rewardsAmounts,
        uint256            _rewardsDuration
    ) external onlyOwner {

        require(stakingRewardsByStakingToken[_stakingToken] == address(0), 'StakingRewardsFactory::deploy: already deployed');
        require(_rewardsDuration != 0, 'StakingRewardsFactory::deploy:The Duration should be greater than zero');
        require(_rewardsTokens.length != 0, 'StakingRewardsFactory::deploy: RewardsTokens and RewardsAmounts arrays could not be empty');
        require(_rewardsTokens.length == _rewardsAmounts.length, 'StakingRewardsFactory::deploy: RewardsTokens and RewardsAmounts should have a matching sizes');

        for (uint256 i = 0; i < _rewardsTokens.length; i++) {
            require(_rewardsTokens[i] != address(0), 'StakingRewardsFactory::deploy: Reward token address could not be invalid');
            require(_rewardsAmounts[i] != 0, 'StakingRewardsFactory::deploy: Reward must be greater than zero');
        }

        stakingRewardsByStakingToken[_stakingToken] = address(new StakingRewards(_rewardsTokens, _rewardsAmounts, _stakingToken, _rewardsDuration));

        stakingTokens.push(_stakingToken);
    }

    function extendRewardPeriod(
        address stakingToken,
        address extendRewardToken,
        uint256 extendRewardAmount
    )
        external
        onlyOwner
    {

        require(extendRewardAmount != 0, 'StakingRewardsFactory::extendRewardPeriod: Reward must be greater than zero');

        address sr = stakingRewardsByStakingToken[stakingToken]; // StakingRewards

        require(sr != address(0), 'StakingRewardsFactory::extendRewardPeriod: not deployed');
        require(hasStakingStarted(sr), 'StakingRewardsFactory::extendRewardPeriod: Staking has not started');

        (uint256 rate, , , ,) = StakingRewards(sr).rewardsTokensMap(extendRewardToken);

        require(rate != 0, 'StakingRewardsFactory::extendRewardPeriod: Token for extending reward is not known'); // its expected that valid token should have a valid rate

        IERC20Detailed(extendRewardToken).safeApprove(sr, extendRewardAmount);
        StakingRewards(sr).addRewards(extendRewardToken, extendRewardAmount);
    }


    function startStakings() external {

        require(stakingTokens.length != 0, 'StakingRewardsFactory::startStakings: called before any deploys');

        for (uint256 i = 0; i < stakingTokens.length; i++) {
            startStaking(stakingTokens[i]);
        }
    }

    function hasStakingStarted(address stakingRewards)
        public
        view
        returns (bool)
    {

        return StakingRewards(stakingRewards).hasPeriodStarted();
    }

    function startStaking(address stakingToken) public {

        require(block.timestamp >= stakingRewardsGenesis, 'StakingRewardsFactory::startStaking: not ready');

        address sr = stakingRewardsByStakingToken[stakingToken]; // StakingRewards

        StakingRewards srInstance = StakingRewards(sr);
        require(sr != address(0), 'StakingRewardsFactory::startStaking: not deployed');
        require(!hasStakingStarted(sr), 'StakingRewardsFactory::startStaking: Staking has started');

        uint256 rtsSize = srInstance.getRewardsTokensCount();
        for (uint256 i = 0; i < rtsSize; i++) {
            require(
                IERC20Detailed(srInstance.rewardsTokensArr(i))
                    .transfer(sr, srInstance.rewardsAmountsArr(i)),
                'StakingRewardsFactory::startStaking: transfer failed'
            );
        }

        srInstance.start();
    }
}