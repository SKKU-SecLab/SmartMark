



pragma solidity ^0.8.0;

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



pragma solidity 0.8.4;


contract Staking {

    struct Campaign {
        uint256 funds;
        uint256 endDate;
    }
    struct StakeInfo {
        uint256 amount;
        uint64 startDate;
        uint64 endDate;
        uint64 rate;
        uint64 coeff;
    }

    uint256 constant TT = 365 * 24 * 60 * 60;
    address public tokenAddress;
    uint256 constant RATE_DECIMALS = 3;
    uint256[3] public currentRate;
    uint256[3] public powLawCoeff;
    uint256[3] public periods = [30 days, 60 days, 90 days];
    uint256 public maxStaking;
    address public owner;
    Campaign public campaignInfo;

    mapping(address => uint256) private stakeId;
    mapping(address => mapping(uint256 => StakeInfo)) private stakes;
    mapping(address => uint256) private balances;


    event NewCampaign(uint256 funds, uint256 endDate);

    event CampaignEdited(uint256 addedFunds, uint256 newEndDate);

    event RewardFundsRemoved(uint256 amount);

    event ParamsChanged(
        uint256[3] oldRates,
        uint256[3] newRates,
        uint256[3] oldCoeffs,
        uint256[3] newCoeffs,
        uint256 maxStaking
    );

    event Staked(
        address indexed account,
        uint256 amount,
        uint256 startDate,
        uint256 endDate,
        uint256 rate,
        uint256 powLawCoeff,
        uint256 stakeId
    );

    event UnStaked(
        address indexed account,
        uint256 amount,
        uint256 reward,
        uint256 stakeId
    );

    constructor(address _tokenAddress) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
    }

    modifier onlyAdmin() {

        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function getStake(address account, uint256 userStakeId)
        public
        view
        returns (StakeInfo memory)
    {

        return stakes[account][userStakeId];
    }

    function getStackAndReward(address account, uint256 userStakeId)
        public
        view
        returns (
            uint256 amount,
            uint256 reward,
            uint256 maxReward
        )
    {

        amount = stakes[account][userStakeId].amount;
        uint256 startDate = stakes[account][userStakeId].startDate;
        uint256 endDate = stakes[account][userStakeId].endDate;
        uint256 rate = stakes[account][userStakeId].rate;
        uint256 coeff = stakes[account][userStakeId].coeff;
        uint256 fd = endDate <= block.timestamp ? endDate : block.timestamp;
        uint256 tp = endDate - startDate;
        uint256 dt = fd - startDate;
        reward =
            (rate * amount * (dt**(coeff + 1))) /
            (TT * (tp**coeff) * (10**RATE_DECIMALS));
        maxReward = (amount * rate * tp) / (TT * (10**RATE_DECIMALS));
    }

    function getMaxReward(
        uint256 amount,
        uint256 rate,
        uint256 tp
    ) public pure returns (uint256 maxReward) {

        maxReward = (amount * rate * tp) / (TT * (10**RATE_DECIMALS));
    }

    function newCampaign(uint256 funds, uint256 endDate) public onlyAdmin {

        require(campaignInfo.endDate < block.timestamp, "Campaign Active");
        IERC20 wliti = IERC20(tokenAddress);
        require(
            wliti.transferFrom(msg.sender, address(this), funds),
            "trasfer failed"
        );
        campaignInfo.funds = campaignInfo.funds + funds;
        campaignInfo.endDate = endDate;
        emit NewCampaign(funds, endDate);
    }

    function editCampaign(uint256 funds, uint256 endDate) public onlyAdmin {

        require(campaignInfo.endDate > block.timestamp, "Campaign inactive");
        require(endDate >= campaignInfo.endDate, "Campaign can't be shortened");
        campaignInfo.endDate = endDate;
        if (funds != 0) {
            IERC20 wliti = IERC20(tokenAddress);
            require(
                wliti.transferFrom(msg.sender, address(this), funds),
                "transfer failed"
            );
            campaignInfo.funds = campaignInfo.funds + funds;
        }
        emit CampaignEdited(funds, endDate);
    }

    function removeRewardFunds() public onlyAdmin {

        require(
            campaignInfo.endDate + (90 days) < block.timestamp,
            "Campaign Active"
        );
        IERC20 wliti = IERC20(tokenAddress);
        require(wliti.transfer(owner, campaignInfo.funds), "transfer failed");
        emit RewardFundsRemoved(campaignInfo.funds);
        campaignInfo.funds = 0;
    }

    function setNewParams(
        uint256[3] memory rates,
        uint256[3] memory coeffs,
        uint256 maxStaking_
    ) public onlyAdmin {

        emit ParamsChanged(
            currentRate,
            rates,
            powLawCoeff,
            coeffs,
            maxStaking_
        );
        currentRate = rates;
        powLawCoeff = coeffs;
        maxStaking = maxStaking_;
    }

    function stake(uint256 amount, uint256 periodIndex)
        public
        returns (uint256)
    {

        uint256 userStakeId = stakeFor(msg.sender, amount, periodIndex);
        return userStakeId;
    }

    function stakeFor(
        address account,
        uint256 amount,
        uint256 periodIndex
    ) public returns (uint256) {

        require(account != address(0), "Invalid address passed");
        require(balances[account] + amount <= maxStaking, "Max exceeded");
        require(campaignInfo.endDate > block.timestamp, "Campaign ended");
        require(periodIndex <= 2, "Invalid period ID");
        require(amount != 0, "Staking zero token");

        uint256 maxReward = getMaxReward(
            amount,
            currentRate[periodIndex],
            periods[periodIndex]
        );
        require(
            campaignInfo.funds >= maxReward,
            "Not enough funds in the contract"
        );

        campaignInfo.funds = campaignInfo.funds - maxReward;
        balances[account] = balances[account] + amount;

        IERC20 wliti = IERC20(tokenAddress);
        require(
            wliti.transferFrom(msg.sender, address(this), amount),
            "transfer failed"
        );

        uint256 userStakeId = stakeId[account];
        stakes[account][userStakeId] = StakeInfo(
            amount,
            uint64(block.timestamp),
            uint64(block.timestamp + periods[periodIndex]),
            uint64(currentRate[periodIndex]),
            uint64(powLawCoeff[periodIndex])
        );

        emit Staked(
            msg.sender,
            amount,
            block.timestamp,
            block.timestamp + periods[periodIndex],
            currentRate[periodIndex],
            powLawCoeff[periodIndex],
            userStakeId
        );
        stakeId[account] = userStakeId + 1;
        return userStakeId;
    }

    function reStake(uint256 userStakeId_, uint256 periodIndex)
        public
        returns (uint256)
    {

        require(campaignInfo.endDate > block.timestamp, "Campaign ended");
        require(periodIndex <= 2, "Invalid period ID");

        (uint256 amount, uint256 reward, uint256 maxReward) = getStackAndReward(
            msg.sender,
            userStakeId_
        );
        require(amount != 0, "Invalid stake ID");
        campaignInfo.funds = campaignInfo.funds + (maxReward - reward);
        emit UnStaked(msg.sender, amount, reward, userStakeId_);

        amount = amount + reward;
        maxReward = getMaxReward(
            amount,
            currentRate[periodIndex],
            periods[periodIndex]
        );

        require(balances[msg.sender] + amount <= maxStaking, "Max exceeded");
        require(
            campaignInfo.funds >= maxReward,
            "Not enough funds in the contract"
        );
        campaignInfo.funds = campaignInfo.funds - maxReward;
        balances[msg.sender] = balances[msg.sender] + reward; // only the reward is newly added to the staked amount

        uint256 userStakeId = stakeId[msg.sender];
        stakes[msg.sender][userStakeId] = StakeInfo(
            amount,
            uint64(block.timestamp),
            uint64(block.timestamp + periods[periodIndex]),
            uint64(currentRate[periodIndex]),
            uint64(powLawCoeff[periodIndex])
        );

        emit Staked(
            msg.sender,
            amount,
            block.timestamp,
            block.timestamp + periods[periodIndex],
            currentRate[periodIndex],
            powLawCoeff[periodIndex],
            userStakeId
        );
        delete stakes[msg.sender][userStakeId_];
        stakeId[msg.sender] = userStakeId + 1;

        return userStakeId;
    }

    function unstake(uint256 userStakeId) public {

        (uint256 amount, uint256 reward, uint256 maxReward) = getStackAndReward(
            msg.sender,
            userStakeId
        );
        require(amount != 0, "Invalid stake ID");
        IERC20 wliti = IERC20(tokenAddress);
        require(wliti.transfer(msg.sender, amount + reward), "transfer failed");
        delete stakes[msg.sender][userStakeId];
        campaignInfo.funds = campaignInfo.funds + (maxReward - reward);
        balances[msg.sender] = balances[msg.sender] - amount;
        emit UnStaked(msg.sender, amount, reward, userStakeId);
    }

    function unstakeMany(uint256[] memory userStakeId) public {

        require(userStakeId.length <= 10, "Number of un-stakes limted to 10");
        uint256 totalAmount;
        uint256 totalReward;
        uint256 totalMaxReward;
        for (uint256 i = 0; i < userStakeId.length; i++) {
            uint256 ind = userStakeId[i];
            (
                uint256 amount,
                uint256 reward,
                uint256 maxReward
            ) = getStackAndReward(msg.sender, ind);
            if (amount == 0) continue;
            totalAmount = totalAmount + amount;
            totalReward = totalReward + reward;
            totalMaxReward = totalMaxReward + maxReward;
            delete stakes[msg.sender][ind];
            emit UnStaked(msg.sender, amount, reward, ind);
        }
        campaignInfo.funds =
            campaignInfo.funds -
            (totalMaxReward - totalReward);
        balances[msg.sender] = balances[msg.sender] - totalAmount;
        IERC20 wliti = IERC20(tokenAddress);
        require(
            wliti.transfer(msg.sender, totalAmount + totalReward),
            "transfer failed"
        );
    }
}