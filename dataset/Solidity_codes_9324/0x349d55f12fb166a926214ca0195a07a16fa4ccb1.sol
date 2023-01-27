

pragma solidity ^0.7.0;


contract Context {

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.7.0;


 
abstract contract Pausable is Context {

     bool private _paused;

    event Paused(address account);

    event Unpaused(address account);   

    constructor ()  {
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
}



pragma solidity ^0.7.0;


 abstract contract Ownable is Pausable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address ownerAddress)  {
        _owner = ownerAddress;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



pragma solidity ^0.7.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}



pragma solidity ^0.7.0;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity ^0.7.0;









abstract contract Admin is Ownable {
    struct tokenInfo {
        bool isExist;
        uint8 decimal;
        uint256 userMinStake;
        uint256 userMaxStake;
        uint256 totalMaxStake;
        uint256 lockableDays;
        bool optionableStatus;
    }

    using SafeMath for uint256;
    address[] public tokens;
    mapping(address => address[]) public tokensSequenceList;
    mapping(address => tokenInfo) public tokenDetails;
    mapping(address => mapping(address => uint256)) public tokenDailyDistribution;
    mapping(address => mapping(address => bool)) public tokenBlockedStatus;
    uint256[] public intervalDays = [1, 8, 15, 22, 29, 36];
    uint256 public constant DAYS = 1 days;
    uint256 public constant HOURS = 1 hours;
    uint256 public stakeDuration;
    uint256 public refPercentage;
    uint256 public optionableBenefit;

    event TokenDetails(
        address indexed tokenAddress,
        uint256 userMinStake,
        uint256 userMaxStake,
        uint256 totalMaxStake,
        uint256 updatedTime
    );
    
    event LockableTokenDetails(
        address indexed tokenAddress,
        uint256 lockableDys,
        bool optionalbleStatus,
        uint256 updatedTime
    );
    
    event DailyDistributionDetails(
        address indexed stakedTokenAddress,
        address indexed rewardTokenAddress,
        uint256 rewards,
        uint256 time
    );
    
    event SequenceDetails(
        address indexed stakedTokenAddress,
        address []  rewardTokenSequence,
        uint256 time
    );
    
    event StakeDurationDetails(
        uint256 updatedDuration,
        uint256 time
    );
    
    event OptionableBenefitDetails(
        uint256 updatedBenefit,
        uint256 time
    );
    
    event ReferrerPercentageDetails(
        uint256 updatedRefPercentage,
        uint256 time
    );
    
    event IntervalDaysDetails(
        uint256[] updatedIntervals,
        uint256 time
    );
    
    event BlockedDetails(
        address indexed stakedTokenAddress,
        address indexed rewardTokenAddress,
        bool blockedStatus,
        uint256 time
    );
    
    event WithdrawDetails(
        address indexed tokenAddress,
        uint256 withdrawalAmount,
        uint256 time
    );


    constructor(address _owner) Ownable(_owner) {
        stakeDuration = 90 days;
        optionableBenefit = 2;
    }

    function addToken(
        address tokenAddress,
        uint256 userMinStake,
        uint256 userMaxStake,
        uint256 totalStake,
        uint8 decimal
    ) public onlyOwner returns (bool) {
        if (!(tokenDetails[tokenAddress].isExist))
            tokens.push(tokenAddress);

        tokenDetails[tokenAddress].isExist = true;
        tokenDetails[tokenAddress].decimal = decimal;
        tokenDetails[tokenAddress].userMinStake = userMinStake;
        tokenDetails[tokenAddress].userMaxStake = userMaxStake;
        tokenDetails[tokenAddress].totalMaxStake = totalStake;

        emit TokenDetails(
            tokenAddress,
            userMinStake,
            userMaxStake,
            totalStake,
            block.timestamp
        );
        return true;
    }

    function setDailyDistribution(
        address[] memory stakedToken,
        address[] memory rewardToken,
        uint256[] memory dailyDistribution
    ) public onlyOwner {
        require(
            stakedToken.length == rewardToken.length &&
                rewardToken.length == dailyDistribution.length,
            "Invalid Input"
        );

        for (uint8 i = 0; i < stakedToken.length; i++) {
            require(
                tokenDetails[stakedToken[i]].isExist &&
                    tokenDetails[rewardToken[i]].isExist,
                "Token not exist"
            );
            tokenDailyDistribution[stakedToken[i]][
                rewardToken[i]
            ] = dailyDistribution[i];
            
            emit DailyDistributionDetails(
                stakedToken[i],
                rewardToken[i],
                dailyDistribution[i],
                block.timestamp
            );
        }
        
        
    }

    function updateSequence(
        address stakedToken,
        address[] memory rewardTokenSequence
    ) public onlyOwner {
        tokensSequenceList[stakedToken] = new address[](0);
        require(
            tokenDetails[stakedToken].isExist,
            "Staked Token Not Exist"
        );
        for (uint8 i = 0; i < rewardTokenSequence.length; i++) {
            require(
                rewardTokenSequence.length <= tokens.length,
                "Invalid Input"
            );
            require(
                tokenDetails[rewardTokenSequence[i]].isExist,
                "Reward Token Not Exist"
            );
            tokensSequenceList[stakedToken].push(rewardTokenSequence[i]);
        }
        
        emit SequenceDetails(
            stakedToken,
            tokensSequenceList[stakedToken],
            block.timestamp
        );
        
        
    }

    function updateToken(
        address tokenAddress,
        uint256 userMinStake,
        uint256 userMaxStake,
        uint256 totalStake
    ) public onlyOwner {
        require(tokenDetails[tokenAddress].isExist, "Token Not Exist");
        tokenDetails[tokenAddress].userMinStake = userMinStake;
        tokenDetails[tokenAddress].userMaxStake = userMaxStake;
        tokenDetails[tokenAddress].totalMaxStake = totalStake;

        emit TokenDetails(
            tokenAddress,
            userMinStake,
            userMaxStake,
            totalStake,
            block.timestamp
        );
    }

    function lockableToken(
        address tokenAddress,
        uint8 lockableStatus,
        uint256 lockedDays,
        bool optionableStatus
    ) public onlyOwner {
        require(
            lockableStatus == 1 || lockableStatus == 2 || lockableStatus == 3,
            "Invalid Lockable Status"
        );
        require(tokenDetails[tokenAddress].isExist == true, "Token Not Exist");

        if (lockableStatus == 1) {
            tokenDetails[tokenAddress].lockableDays = block.timestamp.add(
                lockedDays
            );
        } else if (lockableStatus == 2)
            tokenDetails[tokenAddress].lockableDays = 0;
        else if (lockableStatus == 3)
            tokenDetails[tokenAddress].optionableStatus = optionableStatus;
            
            
        emit LockableTokenDetails (
            tokenAddress,
            tokenDetails[tokenAddress].lockableDays,
            tokenDetails[tokenAddress].optionableStatus,
            block.timestamp
        );
    }

    function updateStakeDuration(uint256 durationTime) public onlyOwner {
        stakeDuration = durationTime;
        
        emit StakeDurationDetails(
            stakeDuration,
            block.timestamp
        );
    }

    function updateOptionableBenefit(uint256 benefit) public onlyOwner {
        optionableBenefit = benefit;
        
        emit OptionableBenefitDetails(
            optionableBenefit,
            block.timestamp
        );
    }

    function updateRefPercentage(uint256 refPer) public onlyOwner {
        refPercentage = refPer;
        
        emit ReferrerPercentageDetails(
            refPercentage,
            block.timestamp
        );
    }

    function updateIntervalDays(uint256[] memory _interval) public onlyOwner {
        intervalDays = new uint256[](0);

        for (uint8 i = 0; i < _interval.length; i++) {
            uint256 noD = stakeDuration.div(DAYS);
            require(noD > _interval[i], "Invalid Interval Day");
            intervalDays.push(_interval[i]);
        }
        
        emit IntervalDaysDetails(
            intervalDays,
            block.timestamp
        );
        
        
    }

    function changeTokenBlockedStatus(
        address stakedToken,
        address rewardToken,
        bool status
    ) public onlyOwner {
        require(
            tokenDetails[stakedToken].isExist &&
                tokenDetails[rewardToken].isExist,
            "Token not exist"
        );
        tokenBlockedStatus[stakedToken][rewardToken] = status;
        
        
        emit BlockedDetails(
            stakedToken,
            rewardToken,
            tokenBlockedStatus[stakedToken][rewardToken],
            block.timestamp
        );
    }

    function safeWithdraw(address tokenAddress, uint256 amount)
        public
        onlyOwner
    {
        require(
            IERC20(tokenAddress).balanceOf(address(this)) >= amount,
            "Insufficient Balance"
        );
        require(
            IERC20(tokenAddress).transfer(owner(), amount),
            "Transfer failed"
        );
        
        
        emit WithdrawDetails(
            tokenAddress,
            amount,
            block.timestamp
        );
    }
    
    function viewTokensCount() external view returns(uint256) {
        return tokens.length;
    }
}




pragma solidity ^0.7.0;



contract Unifarmv3 is Admin {

    using SafeMath for uint256;

    struct stakeInfo {
        address user;
        uint8[] stakeOption;
        bool[] isActive;
        address[] referrer;
        address[] tokenAddress;
        uint256[] stakeId;
        uint256[] stakedAmount;
        uint256[] startTime;
    }

    mapping(address => stakeInfo) public stakingDetails;
    mapping(address => mapping(address => uint256)) public userTotalStaking;
    mapping(address => uint256) public totalStaking;
    uint256 public poolStartTime;

    event Stake(
        address indexed userAddress,
        address indexed tokenAddress,
        uint256 stakedAmount,
        uint256 time
    );
    event Claim(
        address indexed userAddress,
        address indexed stakedTokenAddress,
        address indexed tokenAddress,
        uint256 claimRewards,
        uint256 time
    );
    event UnStake(
        address indexed userAddress,
        address indexed unStakedtokenAddress,
        uint256 unStakedAmount,
        uint256 time
    );

    constructor(address _owner) Admin(_owner) {
        poolStartTime = block.timestamp;
    }

    function stake(
        address referrerAddress,
        address tokenAddress,
        uint8 stakeOption,
        uint256 amount
    ) external whenNotPaused {

        require(
            tokenDetails[tokenAddress].isExist,
            "STAKE : Token is not Exist"
        );
        require(
            userTotalStaking[msg.sender][tokenAddress].add(amount) >=
                tokenDetails[tokenAddress].userMinStake,
            "STAKE : Min Amount should be within permit"
        );
        require(
            userTotalStaking[msg.sender][tokenAddress].add(amount) <=
                tokenDetails[tokenAddress].userMaxStake,
            "STAKE : Max Amount should be within permit"
        );
        require(
            totalStaking[tokenAddress].add(amount) <=
                tokenDetails[tokenAddress].totalMaxStake,
            "STAKE : Maxlimit exceeds"
        );

        stakingDetails[msg.sender].stakeId.push(
            stakingDetails[msg.sender].stakeId.length
        );
        stakingDetails[msg.sender].isActive.push(true);
        stakingDetails[msg.sender].user = msg.sender;
        stakingDetails[msg.sender].referrer.push(referrerAddress);
        stakingDetails[msg.sender].tokenAddress.push(tokenAddress);
        stakingDetails[msg.sender].stakeOption.push(stakeOption);
        stakingDetails[msg.sender].startTime.push(block.timestamp);
    
        stakingDetails[msg.sender].stakedAmount.push(amount);
        totalStaking[tokenAddress] = totalStaking[tokenAddress].add(
            amount
        );
        userTotalStaking[msg.sender][tokenAddress] = userTotalStaking[
            msg.sender
        ][tokenAddress]
            .add(amount);

        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount),
                "Transfer Failed");

        emit Stake(msg.sender, tokenAddress, amount, block.timestamp);
    }

    function claimRewards1(uint256 stakeId, uint256 stakedAmount, uint256 totalStake) internal {

        uint256 interval;

        interval = stakingDetails[msg.sender].startTime[stakeId].add(
            stakeDuration
        );
        if (interval > block.timestamp) {
            uint256 endOfProfit = block.timestamp;
            interval = endOfProfit.sub(
                stakingDetails[msg.sender].startTime[stakeId]
            );
        } else {
            uint256 endOfProfit =
                stakingDetails[msg.sender].startTime[stakeId].add(
                    stakeDuration
                );
            interval = endOfProfit.sub(
                stakingDetails[msg.sender].startTime[stakeId]
            );
        }

        if (interval >= HOURS)
            _rewardCalculation(stakeId, stakedAmount, interval, totalStake);
    }
    
    
    function claimRewards2(uint256 stakeId, uint256 stakedAmount, uint256 totalStake) internal {

        uint256 interval;
        uint256 contractInterval;
        uint256 endOfProfit; 

        interval = poolStartTime.add(stakeDuration);
        
        if (interval > block.timestamp) 
            endOfProfit = block.timestamp;
           
        else 
            endOfProfit = poolStartTime.add(stakeDuration);
        
        interval = endOfProfit.sub(stakingDetails[msg.sender].startTime[stakeId]); 
        contractInterval = endOfProfit.sub(poolStartTime);

        if (interval >= HOURS) 
            _rewardCalculation2(stakeId, stakedAmount, interval, contractInterval, totalStake);
    }


    function _rewardCalculation(
        uint256 stakeId,
        uint256 stakedAmount,
        uint256 interval, 
        uint256 totalStake
    ) internal {

        uint256 rewardsEarned;
        uint256 noOfDays;
        uint256 noOfHours;
        
        noOfHours = interval.div(HOURS);
        noOfDays = interval.div(DAYS);
        rewardsEarned = noOfHours.mul(
            getOneDayReward(
                stakedAmount,
                stakingDetails[msg.sender].tokenAddress[stakeId],
                stakingDetails[msg.sender].tokenAddress[stakeId],
                totalStake
            )
        );

        if (stakingDetails[msg.sender].referrer[stakeId] != address(0)) {
            uint256 refEarned =
                (rewardsEarned.mul(refPercentage)).div(100 ether);
            rewardsEarned = rewardsEarned.sub(refEarned);

            require(IERC20(stakingDetails[msg.sender].tokenAddress[stakeId]).transfer(
                stakingDetails[msg.sender].referrer[stakeId],
                refEarned) == true, "Transfer Failed");
        }

        sendToken(
            stakingDetails[msg.sender].tokenAddress[stakeId],
            stakingDetails[msg.sender].tokenAddress[stakeId],
            rewardsEarned
        );

        uint8 i = 1;
        while (i < intervalDays.length) {
            
            if (noOfDays >= intervalDays[i]) {
                uint256 balHours = noOfHours.sub((intervalDays[i].sub(1)).mul(24));
                

                address rewardToken =
                    tokensSequenceList[
                        stakingDetails[msg.sender].tokenAddress[stakeId]][i];

                if ( rewardToken != stakingDetails[msg.sender].tokenAddress[stakeId] 
                        && tokenBlockedStatus[stakingDetails[msg.sender].tokenAddress[stakeId]][rewardToken] ==  false) {
                    rewardsEarned = balHours.mul(
                        getOneDayReward(
                            stakedAmount,
                            stakingDetails[msg.sender].tokenAddress[stakeId],
                            rewardToken,
                            totalStake
                        )
                    );


                    if (
                        stakingDetails[msg.sender].referrer[stakeId] !=
                        address(0)
                    ) {
                        uint256 refEarned =
                            (rewardsEarned.mul(refPercentage)).div(100 ether);
                        rewardsEarned = rewardsEarned.sub(refEarned);

                        require(IERC20(rewardToken)
                            .transfer(
                            stakingDetails[msg.sender].referrer[stakeId],
                            refEarned) == true, "Transfer Failed");
                    }

                    sendToken(
                        stakingDetails[msg.sender].tokenAddress[stakeId],
                        rewardToken,
                        rewardsEarned
                    );
                }
                i = i + 1;
            } else {
                break;
            }
        }
    }
    
    
    function _rewardCalculation2(
        uint256 stakeId,
        uint256 stakedAmount,
        uint256 interval,
        uint256 contractInterval,
        uint256 totalStake
    ) internal {

        uint256 rewardsEarned;
        uint256[2] memory count;
        uint256[2] memory conCount;

        count[0] = interval.div(DAYS); 
        conCount[0] = contractInterval.div(DAYS); 
        
        count[1] = interval.div(HOURS);
        conCount[1] = contractInterval.div(HOURS);
        
        rewardsEarned = count[1].mul(
            getOneDayReward(
                stakedAmount,
                stakingDetails[msg.sender].tokenAddress[stakeId],
                stakingDetails[msg.sender].tokenAddress[stakeId],
                totalStake
            )
        );

        if (stakingDetails[msg.sender].referrer[stakeId] != address(0)) {
            uint256 refEarned =
                (rewardsEarned.mul(refPercentage)).div(100 ether);
            rewardsEarned = rewardsEarned.sub(refEarned);

            require(IERC20(stakingDetails[msg.sender].tokenAddress[stakeId]).transfer(
                stakingDetails[msg.sender].referrer[stakeId],
                refEarned) == true, "Transfer Failed");
        }

        sendToken(
            stakingDetails[msg.sender].tokenAddress[stakeId],
            stakingDetails[msg.sender].tokenAddress[stakeId],
            rewardsEarned
        );

        uint8 i = 1;
        while (i < intervalDays.length) {
            uint256 userStakingDuration = stakingDetails[msg.sender].startTime[stakeId].sub(poolStartTime); 
            
            if (conCount[0] >= intervalDays[i] && intervalDays[i] >= userStakingDuration.div(DAYS)) {
                uint256 balHours = conCount[1].sub((intervalDays[i].sub(1)).mul(24));
                address rewardToken = tokensSequenceList[stakingDetails[msg.sender].tokenAddress[stakeId]][i];

                if ( rewardToken != stakingDetails[msg.sender].tokenAddress[stakeId] 
                        && tokenBlockedStatus[stakingDetails[msg.sender].tokenAddress[stakeId]][rewardToken] ==  false) {
                    
                    rewardsEarned = balHours.mul(getOneDayReward(stakedAmount, stakingDetails[msg.sender].tokenAddress[stakeId], rewardToken, totalStake));


                    if (
                        stakingDetails[msg.sender].referrer[stakeId] != address(0)) {
                        uint256 refEarned = (rewardsEarned.mul(refPercentage)).div(100 ether);
                        rewardsEarned = rewardsEarned.sub(refEarned);

                        require(IERC20(rewardToken).transfer(stakingDetails[msg.sender].referrer[stakeId],refEarned), "Transfer Failed");
                    }

                    sendToken(
                        stakingDetails[msg.sender].tokenAddress[stakeId],
                        rewardToken,
                        rewardsEarned
                    );
                }               
            
            }
            else {

                address rewardToken = tokensSequenceList[stakingDetails[msg.sender].tokenAddress[stakeId]][i];

                if ( rewardToken != stakingDetails[msg.sender].tokenAddress[stakeId] 
                        && tokenBlockedStatus[stakingDetails[msg.sender].tokenAddress[stakeId]][rewardToken] ==  false) {
                    
                    rewardsEarned = count[1].mul(getOneDayReward(stakedAmount, stakingDetails[msg.sender].tokenAddress[stakeId], rewardToken, totalStake));

                    if (
                        stakingDetails[msg.sender].referrer[stakeId] != address(0)) {
                        uint256 refEarned = (rewardsEarned.mul(refPercentage)).div(100 ether);
                        rewardsEarned = rewardsEarned.sub(refEarned);

                        require(IERC20(rewardToken).transfer(stakingDetails[msg.sender].referrer[stakeId],refEarned), "Transfer Failed");
                    }

                    sendToken(
                        stakingDetails[msg.sender].tokenAddress[stakeId],
                        rewardToken,
                        rewardsEarned
                    );
                }               
               
            }
            i = i + 1;
        }
    }


    function getOneDayReward(
        uint256 stakedAmount,
        address stakedToken,
        address rewardToken,
        uint256 totalStake
    ) public view returns (uint256 reward) {

        
        uint256 lockBenefit;
        
        if (tokenDetails[stakedToken].optionableStatus) {
            stakedAmount = stakedAmount.mul(optionableBenefit);
            lockBenefit = stakedAmount.mul(optionableBenefit.sub(1));
            reward = (stakedAmount.mul(tokenDailyDistribution[stakedToken][rewardToken])).div(totalStake.add(lockBenefit));
        }
        else 
            reward = (stakedAmount.mul(tokenDailyDistribution[stakedToken][rewardToken])).div(totalStake);
        
    }
 
    function sendToken(
        address stakedToken,
        address tokenAddress,
        uint256 amount
    ) internal {

        if (tokenAddress != address(0)) {
            require(
                IERC20(tokenAddress).balanceOf(address(this)) >= amount,
                "SEND : Insufficient Balance"
            );
            require(IERC20(tokenAddress).transfer(msg.sender, amount), 
                    "Transfer failed");

            emit Claim(
                msg.sender,
                stakedToken,
                tokenAddress,
                amount,
                block.timestamp
            );
        }
    }

    function unStake(uint256 stakeId) external whenNotPaused returns (bool) {

        
        address stakedToken = stakingDetails[msg.sender].tokenAddress[stakeId];
        
        require(
            tokenDetails[stakedToken].lockableDays <= block.timestamp,
            "Token Locked"
        );
        
        if(tokenDetails[stakedToken].optionableStatus)
            require(stakingDetails[msg.sender].startTime[stakeId].add(stakeDuration) <= block.timestamp, 
            "Locked in optional lock");
            
        require(
            stakingDetails[msg.sender].stakedAmount[stakeId] > 0,
            "CLAIM : Insufficient Staked Amount"
        );

        uint256 stakedAmount = stakingDetails[msg.sender].stakedAmount[stakeId];
        uint256 totalStaking1 =  totalStaking[stakedToken];
        totalStaking[stakedToken] = totalStaking[stakedToken].sub(stakedAmount);
        userTotalStaking[msg.sender][stakedToken] =  userTotalStaking[msg.sender][stakedToken].sub(stakedAmount);
        stakingDetails[msg.sender].stakedAmount[stakeId] = 0;        
        stakingDetails[msg.sender].isActive[stakeId] = false;

        require(
            IERC20(stakingDetails[msg.sender].tokenAddress[stakeId]).balanceOf(
                address(this)
            ) >= stakedAmount,
            "UNSTAKE : Insufficient Balance"
        );

        IERC20(stakingDetails[msg.sender].tokenAddress[stakeId]).transfer(
            msg.sender,
            stakedAmount
        );

        
        if(stakingDetails[msg.sender].stakeOption[stakeId] == 1) 
            claimRewards1(stakeId, stakedAmount, totalStaking1);

        else if(stakingDetails[msg.sender].stakeOption[stakeId] == 2) 
            claimRewards2(stakeId, stakedAmount, totalStaking1);
        

        emit UnStake(
            msg.sender,
            stakingDetails[msg.sender].tokenAddress[stakeId],
            stakedAmount,
            block.timestamp
        );
        return true;
    }

    function viewStakingDetails(address _user)
        public
        view
        returns (
            address[] memory,
            address[] memory,
            bool[] memory,
            uint8[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {

        return (
            stakingDetails[_user].referrer,
            stakingDetails[_user].tokenAddress,
            stakingDetails[_user].isActive,
            stakingDetails[_user].stakeOption,
            stakingDetails[_user].stakeId,
            stakingDetails[_user].stakedAmount,
            stakingDetails[_user].startTime
        );
    }

}