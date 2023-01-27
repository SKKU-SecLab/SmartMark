
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// GPL-2.0-or-later
pragma solidity 0.8.9;


library Util {

    function getERC20Decimals(IERC20 _token) internal view returns (uint8) {

        return IERC20Metadata(address(_token)).decimals();
    }

    function checkedTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {

        require(amount > 0, "checkedTransferFrom: amount zero");
        uint256 balanceBefore = token.balanceOf(to);
        token.transferFrom(from, to, amount);
        uint256 receivedAmount = token.balanceOf(to) - balanceBefore;
        require(receivedAmount == amount, "checkedTransferFrom: not amount");
        return receivedAmount;
    }

    function checkedTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) internal returns (uint256) {

        require(amount > 0, "checkedTransfer: amount zero");
        uint256 balanceBefore = token.balanceOf(to);
        token.transfer(to, amount);
        uint256 receivedAmount = token.balanceOf(to) - balanceBefore;
        require(receivedAmount == amount, "checkedTransfer: not amount");
        return receivedAmount;
    }

    function convertDecimals(
        uint256 _number,
        uint256 _currentDecimals,
        uint256 _targetDecimals
    ) internal pure returns (uint256) {

        uint256 diffDecimals;

        uint256 amountCorrected = _number;

        if (_targetDecimals < _currentDecimals) {
            diffDecimals = _currentDecimals - _targetDecimals;
            amountCorrected = _number / (uint256(10)**diffDecimals);
        } else if (_targetDecimals > _currentDecimals) {
            diffDecimals = _targetDecimals - _currentDecimals;
            amountCorrected = _number * (uint256(10)**diffDecimals);
        }

        return (amountCorrected);
    }

    function convertDecimalsERC20(
        uint256 _number,
        IERC20 _sourceToken,
        IERC20 _targetToken
    ) internal view returns (uint256) {

        return convertDecimals(_number, getERC20Decimals(_sourceToken), getERC20Decimals(_targetToken));
    }

    function removeValueFromArray(IERC20 value, IERC20[] storage array) internal {

        bool shift = false;
        uint256 i = 0;
        while (i < array.length - 1) {
            if (array[i] == value) shift = true;
            if (shift) {
                array[i] = array[i + 1];
            }
            i++;
        }
        array.pop();
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// GPL-2.0-or-later
pragma solidity 0.8.9;



library PeriodStaking {

    event StakedPeriod(address indexed staker, IERC20 indexed stakableToken, uint256 amount);
    event UnstakedPeriod(address indexed unstaker, IERC20 indexed stakedToken, uint256 amount, uint256 totalStakedBalance);
    event ClaimedRewardsPeriod(address indexed claimer, IERC20 stakedToken, IERC20 rewardToken, uint256 amount);
    event ChangedEndRewardPeriod(uint256 indexed _periodId, uint256 _periodStart, uint256 _periodEnd);

    struct PeriodStakingStorage {
        mapping(uint256 => RewardPeriod) rewardPeriods;
        mapping(address => WalletStakingState) walletStakedAmounts;
        mapping(uint256 => mapping(address => uint256)) walletStakingScores;
        uint256 currentRewardPeriodId;
        uint256 duration;
        IERC20 rewardToken;
        mapping(uint256 => mapping(address => uint256)) walletRewardableCapital;
    }

    struct RewardPeriod {
        uint256 id;
        uint256 start;
        uint256 end;
        uint256 totalRewards;
        uint256 totalStakingScore;
        uint256 finalStakedAmount;
        IERC20 rewardToken;
    }

    struct WalletStakingState {
        uint256 stakedBalance;
        uint256 lastUpdate;
        mapping(IERC20 => uint256) outstandingRewards;
    }

    function getRewardPeriods(PeriodStakingStorage storage periodStakingStorage) external view returns (RewardPeriod[] memory) {

        RewardPeriod[] memory rewardPeriodsArray = new RewardPeriod[](periodStakingStorage.currentRewardPeriodId);

        for (uint256 i = 1; i <= periodStakingStorage.currentRewardPeriodId; i++) {
            RewardPeriod storage rewardPeriod = periodStakingStorage.rewardPeriods[i];
            rewardPeriodsArray[i - 1] = rewardPeriod;
        }
        return rewardPeriodsArray;
    }

    function setEndRewardPeriod(PeriodStakingStorage storage periodStakingStorage, uint256 periodEnd) external {

        RewardPeriod storage currentRewardPeriod = periodStakingStorage.rewardPeriods[periodStakingStorage.currentRewardPeriodId];
        require(currentRewardPeriod.id > 0, "no reward periods");
        require(currentRewardPeriod.start < block.number && currentRewardPeriod.end > block.number, "not inside any reward period");

        if (periodEnd == 0) {
            currentRewardPeriod.end = block.number;
        } else {
            require(periodEnd >= block.number, "end of period in the past");
            currentRewardPeriod.end = periodEnd;
        }
        emit ChangedEndRewardPeriod(currentRewardPeriod.id, currentRewardPeriod.start, currentRewardPeriod.end);
    }

    function startNextRewardPeriod(PeriodStakingStorage storage periodStakingStorage, uint256 periodStart) external {

        require(periodStakingStorage.duration > 0 && address(periodStakingStorage.rewardToken) != address(0), "duration and/or rewardToken not configured");

        RewardPeriod storage currentRewardPeriod = periodStakingStorage.rewardPeriods[periodStakingStorage.currentRewardPeriodId];
        if (periodStakingStorage.currentRewardPeriodId > 0) {
            require(currentRewardPeriod.end > 0 && currentRewardPeriod.end < block.number, "current period has not ended yet");
        }
        periodStakingStorage.currentRewardPeriodId += 1;
        RewardPeriod storage nextRewardPeriod = periodStakingStorage.rewardPeriods[periodStakingStorage.currentRewardPeriodId];
        nextRewardPeriod.rewardToken = periodStakingStorage.rewardToken;

        nextRewardPeriod.id = periodStakingStorage.currentRewardPeriodId;

        if (periodStart == 0) {
            nextRewardPeriod.start = currentRewardPeriod.end != 0 ? currentRewardPeriod.end : block.number;
        } else if (periodStart == 1) {
            nextRewardPeriod.start = block.number;
        } else {
            nextRewardPeriod.start = periodStart;
        }

        nextRewardPeriod.end = nextRewardPeriod.start + periodStakingStorage.duration;
        nextRewardPeriod.finalStakedAmount = currentRewardPeriod.finalStakedAmount;
        nextRewardPeriod.totalStakingScore = currentRewardPeriod.finalStakedAmount * (nextRewardPeriod.end - nextRewardPeriod.start);
    }

    function depositRewardPeriodRewards(
        PeriodStakingStorage storage periodStakingStorage,
        uint256 rewardPeriodId,
        uint256 _totalRewards
    ) public {

        RewardPeriod storage rewardPeriod = periodStakingStorage.rewardPeriods[rewardPeriodId];

        require(rewardPeriod.end > 0 && rewardPeriod.end < block.number, "period has not ended");

        periodStakingStorage.rewardPeriods[rewardPeriodId].totalRewards = Util.checkedTransferFrom(rewardPeriod.rewardToken, msg.sender, address(this), _totalRewards);
    }

    function updatePeriod(PeriodStakingStorage storage periodStakingStorage) internal {

        WalletStakingState storage walletStakedAmount = periodStakingStorage.walletStakedAmounts[msg.sender];
        if (walletStakedAmount.stakedBalance > 0 && walletStakedAmount.lastUpdate < periodStakingStorage.currentRewardPeriodId && walletStakedAmount.lastUpdate > 0) {
            uint256 i = walletStakedAmount.lastUpdate + 1;
            for (; i <= periodStakingStorage.currentRewardPeriodId; i++) {
                RewardPeriod storage rewardPeriod = periodStakingStorage.rewardPeriods[i];
                periodStakingStorage.walletStakingScores[i][msg.sender] = walletStakedAmount.stakedBalance * (rewardPeriod.end - rewardPeriod.start);
                periodStakingStorage.walletRewardableCapital[i][msg.sender] = walletStakedAmount.stakedBalance;
            }
        }
        walletStakedAmount.lastUpdate = periodStakingStorage.currentRewardPeriodId;
    }

    function getWalletRewardPeriodStakingScore(
        PeriodStakingStorage storage periodStakingStorage,
        address wallet,
        uint256 period
    ) public view returns (uint256) {

        WalletStakingState storage walletStakedAmount = periodStakingStorage.walletStakedAmounts[wallet];
        RewardPeriod storage rewardPeriod = periodStakingStorage.rewardPeriods[period];
        if (walletStakedAmount.lastUpdate > 0 && walletStakedAmount.lastUpdate < period) {
            return walletStakedAmount.stakedBalance * (rewardPeriod.end - rewardPeriod.start);
        } else {
            return periodStakingStorage.walletStakingScores[period][wallet];
        }
    }

    function stakeRewardPeriod(
        PeriodStakingStorage storage periodStakingStorage,
        uint256 amount,
        IERC20 lendingPoolToken
    ) external {

        RewardPeriod storage currentRewardPeriod = periodStakingStorage.rewardPeriods[periodStakingStorage.currentRewardPeriodId];
        require(currentRewardPeriod.start <= block.number && currentRewardPeriod.end > block.number, "no active period");

        updatePeriod(periodStakingStorage);

        amount = Util.checkedTransferFrom(lendingPoolToken, msg.sender, address(this), amount);
        emit StakedPeriod(msg.sender, lendingPoolToken, amount);

        periodStakingStorage.walletStakedAmounts[msg.sender].stakedBalance += amount;

        currentRewardPeriod.finalStakedAmount += amount;

        currentRewardPeriod.totalStakingScore += (currentRewardPeriod.end - block.number) * amount;

        periodStakingStorage.walletStakingScores[periodStakingStorage.currentRewardPeriodId][msg.sender] += (currentRewardPeriod.end - block.number) * amount;
        uint256 value = calculateRewardableCapital(currentRewardPeriod, amount, false);
        periodStakingStorage.walletRewardableCapital[periodStakingStorage.currentRewardPeriodId][msg.sender] += value;
    }

    function unstakeRewardPeriod(
        PeriodStakingStorage storage periodStakingStorage,
        uint256 amount,
        IERC20 lendingPoolToken
    ) external {

        require(amount <= periodStakingStorage.walletStakedAmounts[msg.sender].stakedBalance, "amount greater than staked amount");
        updatePeriod(periodStakingStorage);

        RewardPeriod storage currentRewardPeriod = periodStakingStorage.rewardPeriods[periodStakingStorage.currentRewardPeriodId];

        periodStakingStorage.walletStakedAmounts[msg.sender].stakedBalance -= amount;
        currentRewardPeriod.finalStakedAmount -= amount;
        if (currentRewardPeriod.end > block.number) {
            currentRewardPeriod.totalStakingScore -= (currentRewardPeriod.end - block.number) * amount;
            periodStakingStorage.walletStakingScores[periodStakingStorage.currentRewardPeriodId][msg.sender] -= (currentRewardPeriod.end - block.number) * amount;
            uint256 value = calculateRewardableCapital(currentRewardPeriod, amount, false);
            periodStakingStorage.walletRewardableCapital[periodStakingStorage.currentRewardPeriodId][msg.sender] -= value;
        }
        lendingPoolToken.transfer(msg.sender, amount);
        emit UnstakedPeriod(msg.sender, lendingPoolToken, amount, periodStakingStorage.walletStakedAmounts[msg.sender].stakedBalance);
    }

    function claimRewardPeriod(
        PeriodStakingStorage storage periodStakingStorage,
        uint256 rewardPeriodId,
        IERC20 lendingPoolToken
    ) external {

        RewardPeriod storage rewardPeriod = periodStakingStorage.rewardPeriods[rewardPeriodId];
        require(rewardPeriod.end > 0 && rewardPeriod.end < block.number && rewardPeriod.totalRewards > 0, "period not ready for claiming");
        updatePeriod(periodStakingStorage);

        require(periodStakingStorage.walletStakingScores[rewardPeriodId][msg.sender] > 0, "no rewards to claim");

        uint256 payableRewardAmount = calculatePeriodRewards(
            rewardPeriod.rewardToken,
            rewardPeriod.totalRewards,
            rewardPeriod.totalStakingScore,
            periodStakingStorage.walletStakingScores[rewardPeriodId][msg.sender]
        );
        periodStakingStorage.walletStakingScores[rewardPeriodId][msg.sender] = 0;


        rewardPeriod.rewardToken.transfer(msg.sender, payableRewardAmount);
        emit ClaimedRewardsPeriod(msg.sender, lendingPoolToken, rewardPeriod.rewardToken, payableRewardAmount);
    }

    function calculateWalletRewardsPeriod(
        PeriodStakingStorage storage periodStakingStorage,
        address wallet,
        uint256 rewardPeriodId,
        uint256 projectedTotalRewards
    ) public view returns (uint256) {

        RewardPeriod storage rewardPeriod = periodStakingStorage.rewardPeriods[rewardPeriodId];
        if (projectedTotalRewards == 0) {
            projectedTotalRewards = rewardPeriod.totalRewards;
        }
        return
            calculatePeriodRewards(
                rewardPeriod.rewardToken,
                projectedTotalRewards,
                rewardPeriod.totalStakingScore,
                getWalletRewardPeriodStakingScore(periodStakingStorage, wallet, rewardPeriodId)
            );
    }

    function calculateWalletRewardsYieldPeriod(
        PeriodStakingStorage storage periodStakingStorage,
        address wallet,
        uint256 rewardPeriodId,
        uint256 yieldPeriod,
        IERC20 lendingPoolToken
    ) public view returns (uint256) {

        RewardPeriod storage rewardPeriod = periodStakingStorage.rewardPeriods[rewardPeriodId];
        if (rewardPeriod.id == 0) return 0; // request for non-existent periodID

        if (rewardPeriod.totalRewards != 0) {
            return calculateWalletRewardsPeriod(periodStakingStorage, wallet, rewardPeriodId, rewardPeriod.totalRewards);
        }

        uint256 walletRewardableCapital = periodStakingStorage.walletRewardableCapital[rewardPeriod.id][wallet];
        uint256 currentStakedBalance = periodStakingStorage.walletStakedAmounts[wallet].stakedBalance;

        if (currentStakedBalance != 0 && walletRewardableCapital == 0) {
            walletRewardableCapital = calculateRewardableCapital(rewardPeriod, currentStakedBalance, true);
        } else if (rewardPeriod.end > block.number) {
            walletRewardableCapital -= calculateRewardableCapital(rewardPeriod, currentStakedBalance, false);
        }

        uint256 walletRewards18 = (walletRewardableCapital * yieldPeriod) / 10000 / 100;
        return Util.convertDecimalsERC20(walletRewards18, lendingPoolToken, rewardPeriod.rewardToken);
    }

    function calculatePeriodRewards(
        IERC20 rewardToken,
        uint256 totalPeriodRewards,
        uint256 totalPeriodStakingScore,
        uint256 walletStakingScore
    ) public view returns (uint256) {

        if (totalPeriodStakingScore == 0) {
            return 0;
        }
        uint256 rewardTokenDecimals = Util.getERC20Decimals(rewardToken);

        uint256 _numerator = (walletStakingScore * totalPeriodRewards) * 10**(rewardTokenDecimals + 1);
        uint256 payableRewardAmount = ((_numerator / totalPeriodStakingScore) + 5) / 10;

        return payableRewardAmount / (uint256(10)**rewardTokenDecimals);
    }

    function calculateRewardableCapital(
        RewardPeriod memory rewardPeriod,
        uint256 amount,
        bool invert
    ) internal view returns (uint256) {

        uint256 blockNumber = block.number;
        if (block.number > rewardPeriod.end) {
            if (invert) {
                blockNumber = rewardPeriod.end;
            } else {
                blockNumber = rewardPeriod.start;
            }
        }
        uint256 stakingDuration;
        if (invert) {
            stakingDuration = (blockNumber - rewardPeriod.start) * 10**18;
        } else {
            stakingDuration = (rewardPeriod.end - blockNumber) * 10**18;
        }
        uint256 periodDuration = (rewardPeriod.end - rewardPeriod.start);

        if (periodDuration == 0 || stakingDuration == 0 || amount == 0) {
            return 0;
        }
        return (amount * (stakingDuration / periodDuration)) / 10**18;
    }
}