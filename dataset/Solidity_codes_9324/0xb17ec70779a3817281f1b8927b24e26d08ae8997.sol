
pragma solidity ^0.7.4;

library SafeMath {

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

    function neg(uint256 a) internal pure returns (uint256) {

        uint256 c = 0 - a;

        return c;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

interface IStaking {

    function stake(uint256 _amount) external;

    function unStake(uint256 _id) external;

    function claimReward(uint256 _amount) external returns (bool);

    function stats(address _address) external view returns (
        uint256 totalStaked,
        uint256 totalRewards,
        uint256 myShare,
        uint256[] memory myStakes,
        uint256[] memory myStakesExpirations,
        uint256 myRewardsTotal,
        uint256 myRewardsAvailable,
        uint256 my24hRewards
    );


    event Staked(address _staker, uint amount, uint startTime, uint endTime);
    event UnStaked(address _staker, uint amount);
    event Rewarded(address _rewardant, uint amount);
}

abstract contract AbstractStakingContract is IStaking {
    using SafeMath for uint;

    struct Stake {
        uint256 amount;
        uint startTime;
        uint endTime;
    }
    struct Reward {
        uint256 amount;
        uint256 timeStamp;
    }

    uint internal SECONDS_IN_DAY = 86400;
    uint256 internal MAX_INT = uint256(-1);
    uint internal deployedTimestamp;

    uint256 public totalStakedTokens;
    bool public acceptingNewStakes = true;
    uint256 public stakingPeriodInSec;
    uint public rewardVestingPeriodInSecs;
    uint public rewardsInterval = SECONDS_IN_DAY;

    uint internal firstStakeStart;
    mapping(address => Stake[]) internal stakes;
    mapping(address => uint256) internal claimedRewards;
    mapping(uint => uint256) internal totalRewards;
    mapping(uint => mapping(address => uint256)) internal rewards;
    mapping(uint => uint256) public rewardsDailyPool;
    mapping(uint => uint256) public totalStakeDaily;
    mapping(address => uint256) internal totalStakeAddress;
    uint[] internal rewardDays;
    uint[] internal stakeDays;
    mapping(address => uint) internal stakers;
    address[] internal stakersStore;

    IERC20 public stakingToken;
    IERC20 public rewardsToken;

    event SystemUpdated(string key, uint256 value);
    event StakeChanged(uint256 amount, uint256 total, uint day, uint timestamp);

    modifier onlyWhenAcceptingNewStakes() {
        require(
            acceptingNewStakes,
            "not accepting new stakes"
        );

        _;
    }

    function stake(address _stakeOwner, uint256 _amount) internal returns (Stake memory) {
        require(
            _stakeOwner != address(0),
            "stake owner can't be 0"
        );
        require(
            _amount > 0,
            "amount must be greater than 0"
        );

        Stake memory stakeData = Stake(_amount, block.timestamp, block.timestamp + stakingPeriodInSec);

        require(
            stakingToken.transferFrom(msg.sender, address(this), _amount),
            "insufficient allowance"
        );

        stakes[_stakeOwner].push(stakeData);

        _addStaker(_stakeOwner);
        _changeTotalStake(_amount);
        totalStakeAddress[_stakeOwner] = totalStakeAddress[_stakeOwner].add(_amount);


        if (firstStakeStart == 0) {
            firstStakeStart = stakeData.startTime;
        }
        return stakeData;
    }

    function _changeTotalStake(uint256 _amount) internal {
        totalStakedTokens = totalStakedTokens + _amount;
        uint _day = _rewardDay();
        uint256 _total = _increaseDailyStaked(_day, _amount);
        _reCalcDailyRewards(_total, _day);

        emit StakeChanged(_amount, _total, _day, block.timestamp);
    }

    function _removeStakeIdx(address _owner, uint index) internal {
        uint _length = stakes[_owner].length;
        for (uint i = index; i < _length - 1; i++) {
            stakes[_owner][i] = stakes[_owner][i + 1];
        }
        delete stakes[_owner][stakes[_owner].length - 1];
        stakes[_owner].pop();
    }

    struct DayData {
        uint day;
        uint256 stakedTotal;
        uint256 rewardsPool;
    }

    function _getReward(address _stakeOwner) internal view returns (uint256 _totalReward, uint256 _availableReward) {
        _totalReward = 0;
        _availableReward = 0;

        uint256 _reward;
        uint256 _now = _thisDay(block.timestamp);
        uint256 _lastDay = _thisDay();
        for (uint256 _day = _rewardDay(max(firstStakeStart, deployedTimestamp)); _day <= _lastDay && _day <= _now; _day += rewardsInterval) {
            uint _day_reward = rewards[_day][_stakeOwner];
            if (_day_reward > 0) {
                _reward = _day_reward;
            }
            if (_reward == MAX_INT) {
                _reward = 0;
            }

            _totalReward = _totalReward.add(_reward);
            if (_day < block.timestamp - rewardVestingPeriodInSecs) {
                _availableReward = _availableReward.add(_reward);
            }
        }

        _availableReward = _availableReward.sub(claimedRewards[_stakeOwner]);
    }

    function _getTotalRewards() internal view returns (uint256 _total) {
        _total = 0;

        uint256 _rewards;
        uint256 _now = _thisDay(block.timestamp);
        uint256 _lastDay = _thisDay();
        for (uint256 _day = _rewardDay(max(firstStakeStart, deployedTimestamp)); _day <= _lastDay && _day <= _now; _day += rewardsInterval) {
            if (totalRewards[_day] > 0) {
                _rewards = totalRewards[_day];
            }
            if (_rewards == MAX_INT) {
                _rewards = 0;
            }

            _total = _total.add(_rewards);
        }
    }

    function _thisDay() internal view returns (uint) {
        return _thisDay(block.timestamp);
    }

    function _thisDay(uint _timeStamp) internal view returns (uint) {
        return _timeStamp.div(rewardsInterval).mul(rewardsInterval);
    }

    function _rewardDay() internal view returns (uint) {
        return _rewardDay(block.timestamp);
    }

    function _rewardDay(uint _timeStamp) internal view returns (uint) {
        return _timeStamp.div(rewardsInterval).add(1).mul(rewardsInterval);
    }

    function _dailyRewardPool(uint _forDay) internal view returns (uint256) {
        for (uint idx = rewardDays.length - 1; idx >= 0; idx--) {
            if (rewardDays[idx] <= _forDay) {
                return rewardsDailyPool[rewardDays[idx]];
            }
        }

        return rewardsDailyPool[deployedTimestamp];
    }

    function _reCalcDailyRewards(uint _day) internal {
        _reCalcDailyRewards(_dailyStakedVolume(_day), _day);
    }
    function _reCalcDailyRewards(uint256 dailyTotal, uint _day) internal {
        uint256 _stakeHolders_length = stakersStore.length;
        uint256 rewardsPool = _dailyRewardPool(_day);
        uint256 _total = 0;

        for (uint256 i = 1; dailyTotal > 0 && i < _stakeHolders_length; i++) {
            address _stakeHolder = stakersStore[i];
            uint256 _stakes_length = stakes[_stakeHolder].length;
            uint256 _staked = 0;

            for (uint256 j = 0; j < _stakes_length; j++) {
                Stake storage _stake = stakes[_stakeHolder][j];
                if (_rewardDay(_stake.startTime) > _day) {
                    continue;
                }

                _staked = _staked.add(_stake.amount);
            }

            if (_staked == 0) {
                rewards[_day][_stakeHolder] = MAX_INT;
                continue;
            }

            uint256 _share = _staked.mul(1000).div(dailyTotal);
            uint256 _reward = rewardsPool.mul(_share).div(1000);
            rewards[_day][_stakeHolder] = _reward;
            _total = _total.add(_reward);
        }

        if (_total == 0) {
            _total = MAX_INT;
        }
        totalRewards[_day] = _total;
    }

    function _increaseDailyStaked(uint _day, uint256 _diff) internal returns (uint256) {
        uint256 dailyStaked = totalStakeDaily[_day];
        if (dailyStaked == 0) {
            dailyStaked = _dailyStakedVolume(_day);
            stakeDays.push(_day);
        }
        if (dailyStaked == MAX_INT) {
            dailyStaked = 0;
        }

        uint256 _total = dailyStaked + _diff;
        if (_total == 0) {
            _total = MAX_INT;
        }
        return totalStakeDaily[_day] = _total;
    }

    function _dailyStakedVolume(uint _forDay) internal view returns (uint256 _staked) {
        _staked = 0;
        if (stakeDays.length == 0) {return 0;}

        for (uint idx = stakeDays.length - 1; idx >= 0; idx--) {
            uint _total;
            uint day = stakeDays[idx];
            if (day <= _forDay && (_total = totalStakeDaily[day]) > 0) {
                if (_total == MAX_INT) {
                    _total = 0;
                }
                return _total;
            }
        }
    }

    function _totalStaked(address _stakeOwner) internal view returns (uint256) {
        return totalStakeAddress[_stakeOwner];
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function _addStaker(address _staker) internal {
        if (!_isStaker(_staker)) {
            stakers[_staker] = stakersStore.length;
            stakersStore.push(_staker);
        }
    }

    function _isStaker(address _staker) internal view returns (bool) {
        if (_staker != address(0) && stakers[_staker] > 0) {
            return true;
        }
        return false;
    }

    function _getPosition(uint pos) internal view returns (address) {
        require(pos > 0);
        return stakersStore[pos];
    }

    function _24hRewards(address _address) internal view returns (uint256) {
        if (totalStakedTokens == 0) {
            return 0;
        }

        uint256 share = _totalStaked(_address).mul(1000).div(totalStakedTokens);
        uint256 rewardsPool = _dailyRewardPool(_rewardDay(block.timestamp));

        return rewardsPool.mul(share).div(1000);
    }
}

abstract contract OwnersStakingContract is AbstractStakingContract {
    address internal owner;

    constructor() {
        owner = msg.sender;
    }

    function setNextDayRewardPool(uint256 _rewardPool) external
    {
        uint nextDay = _rewardDay(block.timestamp);
        rewardsDailyPool[nextDay] = _rewardPool;
        rewardDays.push(nextDay);

        _reCalcDailyRewards(nextDay);

        emit SystemUpdated("nextDayReward", _rewardPool);
    }

    function setRewardVestingPeriodInSecs(uint _rewardVestingPeriodInSecs) external ownerOnly {
        rewardVestingPeriodInSecs = _rewardVestingPeriodInSecs;
        _reCalcDailyRewards(_rewardDay(block.timestamp));

        emit SystemUpdated("rewardVestingPeriodInDays", rewardVestingPeriodInSecs);
    }

    function setStakingPeriodInSec(uint _stakingPeriodInSec) external ownerOnly {
        stakingPeriodInSec = _stakingPeriodInSec;
        _reCalcDailyRewards(_rewardDay(block.timestamp));

        emit SystemUpdated("stakingPeriodInSec", stakingPeriodInSec);
    }

    function setRewardsInterval(uint _rewardsInterval) external ownerOnly {
        rewardsInterval = _rewardsInterval;
        _reCalcDailyRewards(_rewardDay(block.timestamp));

        emit SystemUpdated("rewardsInterval", rewardsInterval);
    }

    function setAcceptingNewStakes(bool _acceptingNewStakes) external ownerOnly {
        acceptingNewStakes = _acceptingNewStakes;
        emit SystemUpdated("acceptingNewStakes", acceptingNewStakes ? 1 : 0);
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "Oops. Not an owner");

        _;
    }
}

contract StakingContract is OwnersStakingContract, ReentrancyGuard {

    using SafeMath for uint;

    constructor(
        uint256 _stakingPeriodInSec,
        uint _rewardVestingPeriodInSecs,
        IERC20 _stakingToken,
        IERC20 _rewardsToken,
        uint256 _rewardsDailyPool
    ) {
        require(
            _stakingPeriodInSec > 0,
            "staking period must be greater than 0"
        );
        require(
            address(_stakingToken) != address(0),
            "Staking token must not be 0"
        );
        require(
            address(_rewardsToken) != address(0),
            "Rewards token must not be 0"
        );
        require(
            _rewardsDailyPool > 0,
            "Rewards pool must not be 0"
        );

        stakingPeriodInSec = _stakingPeriodInSec;
        rewardVestingPeriodInSecs = _rewardVestingPeriodInSecs;
        stakingToken = _stakingToken;
        rewardsToken = _rewardsToken;
        deployedTimestamp = block.timestamp;
        rewardsDailyPool[deployedTimestamp] = _rewardsDailyPool;
        rewardDays.push(deployedTimestamp);
        stakersStore.push(address(0));
    }

    function stake(uint256 _amount)
    external
    override
    onlyWhenAcceptingNewStakes
    nonReentrant
    {

        address stakeOwner = msg.sender;
        Stake memory _stake = stake(stakeOwner, _amount);

        emit Staked(stakeOwner, _stake.amount, _stake.startTime, _stake.endTime);
    }

    function unStake(uint256 _idx)
    external
    override
    {

        address stakeOwner = msg.sender;
        require(_idx < stakes[stakeOwner].length, "unstake - idx should be a valid staking index");

        uint256 stakedAmount = stakes[stakeOwner][_idx].amount;
        uint256 stakingEndTime = stakes[stakeOwner][_idx].endTime;

        require(stakingEndTime <= block.timestamp,
            "unstake - unable to unstake. you should wait until stake period is over");


        stakingToken.transfer(stakeOwner, stakedAmount);
        totalStakeAddress[stakeOwner] = totalStakeAddress[stakeOwner].sub(stakedAmount);
        _changeTotalStake(- stakedAmount);
        _removeStakeIdx(stakeOwner, _idx);

        emit UnStaked(stakeOwner, stakedAmount);
    }

    function claimReward(uint256 _amount)
    external
    override
    returns (bool success)
    {

        address requester = msg.sender;
        (, uint256 available) = _getReward(requester);

        require(available >= _amount, "claimReward: amount requested is greater than available");

        rewardsToken.transfer(requester, _amount);
        claimedRewards[requester] = claimedRewards[requester].add(_amount);

        emit Rewarded(requester, _amount);

        return true;
    }

    function stats(address _address)
    external
    view
    override
    returns (
        uint256 totalStaked,
        uint256 totalRewards,
        uint256 myShare,
        uint256[] memory myStakes,
        uint256[] memory myStakesExpirations,
        uint256 myRewardsTotal,
        uint256 myRewardsAvailable,
        uint256 my24hRewards
    )
    {

        myShare = 0;
        totalStaked = totalStakedTokens;
        totalRewards = _getTotalRewards();

        if (_address == address(0)) {
            return (totalStaked, totalRewards, myShare, myStakes, myStakesExpirations, myRewardsTotal, myRewardsAvailable, my24hRewards);
        }

        if (totalStakedTokens > 0) {
            myShare = _totalStaked(_address).mul(100).div(totalStakedTokens);
        }

        my24hRewards = _24hRewards(_address);

        myStakes = new uint256[](stakes[_address].length);
        myStakesExpirations = new uint256[](stakes[_address].length);

        uint _length = stakes[_address].length;
        for (uint8 i = 0; i < _length; ++i) {
            myStakes[i] = stakes[_address][i].amount;
            myStakesExpirations[i] = stakes[_address][i].endTime;
        }

        (myRewardsTotal, myRewardsAvailable) = _getReward(_address);
    }
}