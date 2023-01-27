

pragma solidity ^0.5.0;

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


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity 0.5.1;

contract IStaking {

    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

    function stake(uint256 amount, bytes calldata data) external;

    function unstake(uint256 amount, bytes calldata data) external;

    function totalStakedFor(address addr) public view returns (uint256);

    function totalStaked() public view returns (uint256);

    function token() external view returns (address);


    function supportsHistory() external pure returns (bool) {

        return false;
    }
}


pragma solidity ^0.5.0;

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


pragma solidity 0.5.1;



contract TokenPool is Ownable {

    IERC20 public token;

    constructor(IERC20 _token) public {
        token = _token;
    }

    function balance() public view returns (uint256) {

        return token.balanceOf(address(this));
    }

    function transfer(address to, uint256 value) external onlyOwner returns (bool) {

        return token.transfer(to, value);
    }

    function rescueFunds(address tokenToRescue, address to, uint256 amount) external onlyOwner returns (bool) {

        require(address(token) != tokenToRescue, 'TokenPool: Cannot claim token held by the contract');

        return IERC20(tokenToRescue).transfer(to, amount);
    }
}


pragma solidity 0.5.1;





contract RewardPool is IStaking {

    struct Accounting {
            uint256 globalTotalStakingShareSeconds;
            uint256 globalLastAccountingTimestampSec;
            uint256 globalLockedPoolBalance;
            uint256 globalUnlockedPoolBalance;
    }

    struct RewardData {
        uint256 stakingShareSecondsToBurn;
        uint256 sharesLeftToBurn;
        uint256 rewardAmount;
    }
        
    using SafeMath for uint256;

    event Staked(
        address indexed user,
        uint256 amount,
        uint256 total,
        bytes data
    );
    event Unstaked(
        address indexed user,
        uint256 amount,
        uint256 total,
        bytes data
    );
    event TokensClaimed(address indexed user, uint256 amount);
    event TokensLocked(uint256 amount, uint256 durationSec, uint256 total);
    event TokensUnlocked(uint256 amount, uint256 total);
    event AccountingUpdated();

    TokenPool private _stakingPool;
    TokenPool private _unlockedPool;
    TokenPool private _lockedPool;

    uint256 public constant BONUS_DECIMALS = 4;
    uint256 public startBonus = 0;
    uint256 public bonusPeriodSec = 0;
    uint256 public growthParamX;
    uint256 public growthParamY;

    uint256 public totalLockedShares = 0;
    uint256 public totalStakingShares = 0;
    uint256 public _totalStakingShareSeconds = 0;
    uint256 public _lastAccountingTimestampSec = now;
    uint256 public _maxUnlockSchedules = 0;
    uint256 public _initialSharesPerToken = 0;

    struct Stake {
        uint256 stakingShares;
        uint256 timestampSec;
    }

    struct UserTotals {
        uint256 stakingShares;
        uint256 stakingShareSeconds;
        uint256 lastAccountingTimestampSec;
    }

    mapping(address => UserTotals) public _userTotals;

    mapping(address => Stake[]) public _userStakes;

    struct UnlockSchedule {
        uint256 initialLockedShares;
        uint256 unlockedShares;
        uint256 lastUnlockTimestampSec;
        uint256 endAtSec;
        uint256 durationSec;
    }

    UnlockSchedule[] public unlockSchedules;

    constructor(
        IERC20 stakingToken,
        IERC20 distributionToken,
        uint256 maxUnlockSchedules,
        uint256 startBonus_,
        uint256 bonusPeriodSec_,
        uint256 growthParamX_,
        uint256 growthParamY_,
        uint256 initialSharesPerToken
    ) public {
        require(
            startBonus_ <= 10**BONUS_DECIMALS,
            "TokenGeyser: start bonus too high"
        );
        require(bonusPeriodSec_ != 0, "TokenGeyser: bonus period is zero");
        require(
            initialSharesPerToken > 0,
            "TokenGeyser: initialSharesPerToken is zero"
        );

        _stakingPool = new TokenPool(stakingToken);
        _unlockedPool = new TokenPool(distributionToken);
        _lockedPool = new TokenPool(distributionToken);
        startBonus = startBonus_;
        bonusPeriodSec = bonusPeriodSec_;
        growthParamX = growthParamX_;
        growthParamY = growthParamY_;
        _maxUnlockSchedules = maxUnlockSchedules;
        _initialSharesPerToken = initialSharesPerToken;
    }

    function stakeCount(address account) public view returns (uint256) {

        return _userStakes[account].length;
    }

    function getStakingToken() public view returns (IERC20) {

        return _stakingPool.token();
    }

    function getDistributionToken() public view returns (IERC20) {

        assert(_unlockedPool.token() == _lockedPool.token());
        return _unlockedPool.token();
    }

    function stake(uint256 amount, bytes calldata data) external {

        _stakeFor(msg.sender, msg.sender, amount);
    }

    function _stakeFor(
        address staker,
        address beneficiary,
        uint256 amount
    ) private {

        require(amount > 0, "TokenGeyser: stake amount is zero");
        require(
            beneficiary != address(0),
            "TokenGeyser: beneficiary is zero address"
        );
        require(
            totalStakingShares == 0 || totalStaked() > 0,
            "TokenGeyser: Invalid state. Staking shares exist, but no staking tokens do"
        );

        uint256 mintedStakingShares = (totalStakingShares > 0)
            ? totalStakingShares.mul(amount).div(totalStaked())
            : amount.mul(_initialSharesPerToken);
        require(
            mintedStakingShares > 0,
            "TokenGeyser: Stake amount is too small"
        );

        updateAccounting();

        UserTotals storage totals = _userTotals[beneficiary];
        totals.stakingShares = totals.stakingShares.add(mintedStakingShares);
        totals.lastAccountingTimestampSec = now;

        Stake memory newStake = Stake(mintedStakingShares, now);
        _userStakes[beneficiary].push(newStake);

        totalStakingShares = totalStakingShares.add(mintedStakingShares);

        require(
            _stakingPool.token().transferFrom(
                staker,
                address(_stakingPool),
                amount
            ),
            "TokenGeyser: transfer into staking pool failed"
        );

        emit Staked(beneficiary, amount, totalStakedFor(beneficiary), "");
    }

    function unstake(uint256 amount, bytes calldata data) external {

        _unstake(amount);
    }

    function unlockScheduleSharesPure(uint256 s, uint256 timestamp) private view returns (uint256) {

        UnlockSchedule memory schedule = unlockSchedules[s];

        if (schedule.unlockedShares >= schedule.initialLockedShares) {
            return 0;
        }

        uint256 sharesToUnlock = 0;
        if (timestamp >= schedule.endAtSec) {
            sharesToUnlock = (
                schedule.initialLockedShares.sub(schedule.unlockedShares)
            );
        } else {
            sharesToUnlock = timestamp
                .sub(schedule.lastUnlockTimestampSec)
                .mul(schedule.initialLockedShares)
                .div(schedule.durationSec);
        }

        return sharesToUnlock;
    }

    function computeNewRewardPure(
        uint256 newStakingShareSecondsToBurn,
        uint256 stakeTimeSec,
        uint256 rewardAmount,
        uint256 totalUnlocked,
        uint256 totalStakingShareSeconds,
        bool withBonus
    ) internal view returns (uint256) {

        uint256 newRewardTokens = totalUnlocked
            .mul(newStakingShareSecondsToBurn)
            .div(totalStakingShareSeconds);

        if ((stakeTimeSec >= bonusPeriodSec) || !withBonus) {
            return rewardAmount.add(newRewardTokens);
        }

        uint256 oneHundredPct = 10**BONUS_DECIMALS;

        uint256 growthFactor = stakeTimeSec.mul(oneHundredPct).div(bonusPeriodSec);

        uint256 term1 = (startBonus*oneHundredPct**3).div(oneHundredPct).mul(newRewardTokens);
        uint256 term2 = (oneHundredPct.sub(startBonus).mul(growthParamX).mul(growthFactor**2)*oneHundredPct**3).div(oneHundredPct**3).mul(newRewardTokens);
        uint256 term3 = (oneHundredPct.sub(startBonus).mul(growthParamY).mul(growthFactor)*oneHundredPct**3).div(oneHundredPct**2).mul(newRewardTokens);

        uint256 bonusedReward = term1.add(term2).add(term3).div(oneHundredPct**3);

        return rewardAmount.add(bonusedReward);
    }

    function unlockTokensPure(uint256 timestamp) public view returns (
        uint256 lockedPoolBalance,
        uint256 unlockedPoolBalance
    ) {

        uint256 globalTotalLockedShares = totalLockedShares;
        unlockedPoolBalance = _unlockedPool.balance();
        lockedPoolBalance = _lockedPool.balance();
        uint256 unlockedTokens = 0;
        uint256 lockedTokens = totalLocked();
        
        if (globalTotalLockedShares == 0) {
            unlockedTokens = lockedTokens;
        } else {
            uint256 unlockedShares = 0;
            for (uint256 s = 0; s < unlockSchedules.length; s++) {
                unlockedShares = unlockedShares.add(unlockScheduleSharesPure(s, timestamp));
            }
            unlockedTokens = unlockedShares.mul(lockedTokens).div(
                globalTotalLockedShares
            );
            globalTotalLockedShares = globalTotalLockedShares.sub(unlockedShares);
        }

        if (unlockedTokens > 0) {
            lockedPoolBalance -= unlockedTokens;
            unlockedPoolBalance += unlockedTokens;
        }

        return (
            lockedPoolBalance,
            unlockedPoolBalance
        );
    }

    function updateAccountingPure(uint256 timestamp) public view returns (
        uint256 globalTotalStakingShareSeconds,
        uint256 globalLastAccountingTimestampSec,
        uint256 globalLockedPoolBalance,
        uint256 globalUnlockedPoolBalance
    ){

        globalTotalStakingShareSeconds = _totalStakingShareSeconds;
        globalLastAccountingTimestampSec = _lastAccountingTimestampSec;

        (
            uint256 lockedPoolBalance,
            uint256 unlockedPoolBalance
        ) = unlockTokensPure(timestamp);

        uint256 newStakingShareSeconds = timestamp
            .sub(globalLastAccountingTimestampSec)
            .mul(totalStakingShares);
        globalTotalStakingShareSeconds = globalTotalStakingShareSeconds.add(
            newStakingShareSeconds
        );
        globalLastAccountingTimestampSec = timestamp;

        return (
            globalTotalStakingShareSeconds,
            globalLastAccountingTimestampSec,
            lockedPoolBalance,
            unlockedPoolBalance
        );
    }

    function unstakeQuery(uint256 amount, bool withBonus, uint256 bonusTimestamp, uint256 unlockTimestamp) public view returns (uint256) {

        bonusTimestamp += 30;
        unlockTimestamp += 30;

        if(bonusTimestamp == 0) {
            bonusTimestamp = now;
        }

        if(unlockTimestamp == 0) {
            unlockTimestamp = now;
        }

        Accounting memory accounting;

        (
            accounting.globalTotalStakingShareSeconds,
            accounting.globalLastAccountingTimestampSec,
            accounting.globalLockedPoolBalance,
            accounting.globalUnlockedPoolBalance
        ) = updateAccountingPure(unlockTimestamp);  
        
        if(amount < 1) {
            return 0;
        }
        
        require(
            totalStakedFor(msg.sender) >= amount,
            "TokenGeyser: unstake amount is greater than total user stakes"
        );

        Stake[] memory accountStakes = _userStakes[msg.sender];

        RewardData memory data;

        data.stakingShareSecondsToBurn = 0;
        data.sharesLeftToBurn = totalStakingShares.mul(amount).div(
            totalStaked()
        );
        data.rewardAmount = 0;

        uint256 i = accountStakes.length - 1;

        while (data.sharesLeftToBurn > 0) {
            uint256 newStakingShareSecondsToBurn = 0;

            if (
                accountStakes[i].stakingShares <=
                data.sharesLeftToBurn
            ) {
                newStakingShareSecondsToBurn = accountStakes[accountStakes
                    .length - 1]
                    .stakingShares
                    .mul(
                    unlockTimestamp.sub(
                        accountStakes[i].timestampSec
                    )
                );

                
                data.rewardAmount = computeNewRewardPure(
                    newStakingShareSecondsToBurn,
                    bonusTimestamp.sub(
                        accountStakes[i].timestampSec
                    ),
                    data.rewardAmount,
                    accounting.globalUnlockedPoolBalance,
                    accounting.globalTotalStakingShareSeconds,
                    withBonus
                );
                
                data.stakingShareSecondsToBurn = data.stakingShareSecondsToBurn.add(
                    newStakingShareSecondsToBurn
                );
                data.sharesLeftToBurn = data.sharesLeftToBurn.sub(
                    accountStakes[i].stakingShares
                );
                i--;
            } else {
                newStakingShareSecondsToBurn = data.sharesLeftToBurn.mul(
                    unlockTimestamp.sub(
                        accountStakes[i].timestampSec
                    )
                );

                data.rewardAmount = computeNewRewardPure(
                    newStakingShareSecondsToBurn,
                    unlockTimestamp.sub(
                        accountStakes[i].timestampSec
                    ),
                    data.rewardAmount,
                    accounting.globalUnlockedPoolBalance,
                    accounting.globalTotalStakingShareSeconds,
                    withBonus
                );

                data.stakingShareSecondsToBurn = data.stakingShareSecondsToBurn.add(
                    newStakingShareSecondsToBurn
                );
                accountStakes[i]
                    .stakingShares = accountStakes[i]
                    .stakingShares
                    .sub(data.sharesLeftToBurn);
                data.sharesLeftToBurn = 0;
            }
        }

        return data.rewardAmount;
    }

    function _unstake(uint256 amount) private returns (uint256) {

        updateAccounting();

        require(amount > 0, "TokenGeyser: unstake amount is zero");
        require(
            totalStakedFor(msg.sender) >= amount,
            "TokenGeyser: unstake amount is greater than total user stakes"
        );

        uint256 stakingSharesToBurn = totalStakingShares.mul(amount).div(
            totalStaked()
        );
        require(
            stakingSharesToBurn > 0,
            "TokenGeyser: Unable to unstake amount this small"
        );

        UserTotals storage totals = _userTotals[msg.sender];
        Stake[] storage accountStakes = _userStakes[msg.sender];

        uint256 stakingShareSecondsToBurn = 0;
        uint256 sharesLeftToBurn = stakingSharesToBurn;
        uint256 rewardAmount = 0;
        while (sharesLeftToBurn > 0) {
            Stake storage lastStake = accountStakes[accountStakes.length - 1];
            uint256 stakeTimeSec = now.sub(lastStake.timestampSec);
            uint256 newStakingShareSecondsToBurn = 0;

            if (lastStake.stakingShares <= sharesLeftToBurn) {
                newStakingShareSecondsToBurn = lastStake.stakingShares.mul(
                    stakeTimeSec
                );

                rewardAmount = computeNewReward(
                    rewardAmount,
                    newStakingShareSecondsToBurn,
                    stakeTimeSec
                );
                stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(
                    newStakingShareSecondsToBurn
                );
                sharesLeftToBurn = sharesLeftToBurn.sub(
                    lastStake.stakingShares
                );
                accountStakes.length--;
            } else {
                newStakingShareSecondsToBurn = sharesLeftToBurn.mul(
                    stakeTimeSec
                );
                rewardAmount = computeNewReward(
                    rewardAmount,
                    newStakingShareSecondsToBurn,
                    stakeTimeSec
                );

                stakingShareSecondsToBurn = stakingShareSecondsToBurn.add(
                    newStakingShareSecondsToBurn
                );
                lastStake.stakingShares = lastStake.stakingShares.sub(
                    sharesLeftToBurn
                );
                sharesLeftToBurn = 0;
            }
        }
        totals.stakingShareSeconds = totals.stakingShareSeconds.sub(
            stakingShareSecondsToBurn
        );
        totals.stakingShares = totals.stakingShares.sub(stakingSharesToBurn);

        _totalStakingShareSeconds = _totalStakingShareSeconds.sub(
            stakingShareSecondsToBurn
        );
        totalStakingShares = totalStakingShares.sub(stakingSharesToBurn);

        require(
            _stakingPool.transfer(msg.sender, amount),
            "TokenGeyser: transfer out of staking pool failed"
        );
        require(
            _unlockedPool.transfer(msg.sender, rewardAmount),
            "TokenGeyser: transfer out of unlocked pool failed"
        );

        emit Unstaked(msg.sender, amount, totalStakedFor(msg.sender), "");
        emit TokensClaimed(msg.sender, rewardAmount);

        require(
            totalStakingShares == 0 || totalStaked() > 0,
            "TokenGeyser: Error unstaking. Staking shares exist, but no staking tokens do"
        );
        return rewardAmount;
    }

    function computeNewReward(
        uint256 currentRewardTokens,
        uint256 stakingShareSeconds,
        uint256 stakeTimeSec
    ) private view returns (uint256) {

        uint256 newRewardTokens = totalUnlocked().mul(stakingShareSeconds).div(
            _totalStakingShareSeconds
        );

        if (stakeTimeSec >= bonusPeriodSec) {
            return currentRewardTokens.add(newRewardTokens);
        }

        uint256 oneHundredPct = 10**BONUS_DECIMALS;

        uint256 growthFactor = stakeTimeSec.mul(oneHundredPct).div(bonusPeriodSec);

        uint256 term1 = (startBonus*oneHundredPct**3).div(oneHundredPct).mul(newRewardTokens);
        uint256 term2 = (oneHundredPct.sub(startBonus).mul(growthParamX).mul(growthFactor**2)*oneHundredPct**3).div(oneHundredPct**3).mul(newRewardTokens);
        uint256 term3 = (oneHundredPct.sub(startBonus).mul(growthParamY).mul(growthFactor)*oneHundredPct**3).div(oneHundredPct**2).mul(newRewardTokens);

        uint256 bonusedReward = term1.add(term2).add(term3).div(oneHundredPct**3);

        return currentRewardTokens.add(bonusedReward);
    }

    function totalStakedFor(address addr) public view returns (uint256) {

        return
            totalStakingShares > 0
                ? totalStaked().mul(_userTotals[addr].stakingShares).div(
                    totalStakingShares
                )
                : 0;
    }

    function totalStaked() public view returns (uint256) {

        return _stakingPool.balance();
    }

    function token() external view returns (address) {

        return address(getStakingToken());
    }

    function updateAccounting()
        public
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        unlockTokens();

        uint256 newStakingShareSeconds = now
            .sub(_lastAccountingTimestampSec)
            .mul(totalStakingShares);
        _totalStakingShareSeconds = _totalStakingShareSeconds.add(
            newStakingShareSeconds
        );
        _lastAccountingTimestampSec = now;

        UserTotals storage totals = _userTotals[msg.sender];
        uint256 newUserStakingShareSeconds = now
            .sub(totals.lastAccountingTimestampSec)
            .mul(totals.stakingShares);
        totals.stakingShareSeconds = totals.stakingShareSeconds.add(
            newUserStakingShareSeconds
        );
        totals.lastAccountingTimestampSec = now;

        uint256 totalUserRewards = (_totalStakingShareSeconds > 0)
            ? totalUnlocked().mul(totals.stakingShareSeconds).div(
                _totalStakingShareSeconds
            )
            : 0;

        emit AccountingUpdated();

        return (
            totalLocked(),
            totalUnlocked(),
            totals.stakingShareSeconds,
            _totalStakingShareSeconds,
            totalUserRewards,
            now
        );
    }

    function totalLocked() public view returns (uint256) {

        return _lockedPool.balance();
    }

    function totalUnlocked() public view returns (uint256) {

        return _unlockedPool.balance();
    }

    function unlockScheduleCount() public view returns (uint256) {

        return unlockSchedules.length;
    }

    function lockTokens(uint256 amount, uint256 durationSec)
        external
    {

        require(
            unlockSchedules.length < _maxUnlockSchedules,
            "Reached maximum unlock schedules"
        );

        uint256 minTokenAmount = 1000000;

        require(
            amount >= minTokenAmount.mul((10**uint256(18))),
            "Amount too low for unlock schedule"
        );

        updateAccounting();

        uint256 lockedTokens = totalLocked();
        uint256 mintedLockedShares = (lockedTokens > 0)
            ? totalLockedShares.mul(amount).div(lockedTokens)
            : amount.mul(_initialSharesPerToken);

        UnlockSchedule memory schedule;
        schedule.initialLockedShares = mintedLockedShares;
        schedule.lastUnlockTimestampSec = now;
        schedule.endAtSec = now.add(durationSec);
        schedule.durationSec = durationSec;
        unlockSchedules.push(schedule);

        totalLockedShares = totalLockedShares.add(mintedLockedShares);

        require(
            _lockedPool.token().transferFrom(
                msg.sender,
                address(_lockedPool),
                amount
            ),
            "TokenGeyser: transfer into locked pool failed"
        );
        emit TokensLocked(amount, durationSec, totalLocked());
    }

    function unlockTokens() public returns (uint256) {

        uint256 unlockedTokens = 0;
        uint256 lockedTokens = totalLocked();

        if (totalLockedShares == 0) {
            unlockedTokens = lockedTokens;
        } else {
            uint256 unlockedShares = 0;
            for (uint256 s = 0; s < unlockSchedules.length; s++) {
                unlockedShares = unlockedShares.add(unlockScheduleShares(s));
            }
            unlockedTokens = unlockedShares.mul(lockedTokens).div(
                totalLockedShares
            );
            totalLockedShares = totalLockedShares.sub(unlockedShares);
        }

        if (unlockedTokens > 0) {
            require(
                _lockedPool.transfer(address(_unlockedPool), unlockedTokens),
                "TokenGeyser: transfer out of locked pool failed"
            );
            emit TokensUnlocked(unlockedTokens, totalLocked());
        }

        return unlockedTokens;
    }

    function unlockScheduleShares(uint256 s) private returns (uint256) {

        UnlockSchedule storage schedule = unlockSchedules[s];

        if (schedule.unlockedShares >= schedule.initialLockedShares) {
            return 0;
        }

        uint256 sharesToUnlock = 0;
        if (now >= schedule.endAtSec) {
            sharesToUnlock = (
                schedule.initialLockedShares.sub(schedule.unlockedShares)
            );
            schedule.lastUnlockTimestampSec = schedule.endAtSec;
        } else {
            sharesToUnlock = now
                .sub(schedule.lastUnlockTimestampSec)
                .mul(schedule.initialLockedShares)
                .div(schedule.durationSec);
            schedule.lastUnlockTimestampSec = now;
        }

        schedule.unlockedShares = schedule.unlockedShares.add(sharesToUnlock);
        return sharesToUnlock;
    }
}