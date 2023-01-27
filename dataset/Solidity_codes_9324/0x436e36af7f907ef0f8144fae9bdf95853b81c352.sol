

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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
}

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
}

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

contract CentaurStakingV1 is Ownable {


	using SafeMath for uint;

	event Deposit(uint256 _timestmap, address indexed _address, uint256 _amount);
	event Withdraw(uint256 _timestamp, address indexed _address, uint256 _amount);

	IERC20 public tokenContract = IERC20(0x03042482d64577A7bdb282260e2eA4c8a89C064B);
	address public fundingAddress = 0x6359EAdBB84C8f7683E26F392A1573Ab6a37B4b4;

	uint256 public currentRewardPercentage;
	
	uint256 constant initialRewardPercentage = 1000; // 10%
	uint256 constant finalRewardPercetage = 500; // 5%

	uint256 constant rewardDecrementCycle = 10000000 * 1 ether; // Decrement when TVL hits certain volume
	uint256 constant percentageDecrementPerCycle = 50; // 0.5%

	uint256 public constant stakeLockDuration = 30 days;

	uint256 public stakeStartTimestamp;
	uint256 public stakeEndTimestamp;

	mapping(address => StakeInfo[]) stakeHolders;

	struct StakeInfo {
		uint256 startTimestamp;
		uint256 amountStaked;
		uint256 rewardPercentage;
		bool withdrawn;
	}

	uint256 public totalValueLocked;


	constructor() public {
		currentRewardPercentage = initialRewardPercentage;
		stakeStartTimestamp = block.timestamp + 7 days; // Stake event will start 7 days from deployment
		stakeEndTimestamp = stakeStartTimestamp + 30 days; // Stake event is going to run for 30 days
	}


	function updateFundingAddress(address _address) public onlyOwner {

		require(block.timestamp < stakeStartTimestamp);

		fundingAddress = _address;
	}

	function changeStartTimestamp(uint256 _timestamp) public onlyOwner {

		require(block.timestamp < stakeStartTimestamp);

		stakeStartTimestamp = _timestamp;
	}

	function changeEndTimestamp(uint256 _timestamp) public onlyOwner {

		require(block.timestamp < stakeEndTimestamp);
		require(_timestamp > stakeStartTimestamp);

		stakeEndTimestamp = _timestamp;
	}


    function deposit(uint256 _amount) public {

    	require(block.timestamp > stakeStartTimestamp && block.timestamp < stakeEndTimestamp, "Contract is not accepting deposits at the moment");
    	require(_amount > 0, "Amount has to be more than 0");
    	require(stakeHolders[msg.sender].length < 1000, "Prevent Denial of Service");

    	require(tokenContract.transferFrom(msg.sender, address(this), _amount));
		emit Deposit(block.timestamp, msg.sender, _amount);

    	uint256 stakeAmount = _amount;
		uint256 stakeRewards = 0;

		while(stakeAmount >= amountToNextDecrement()) {

			uint256 amountToNextDecrement = amountToNextDecrement();

	    	StakeInfo memory newStake;
	    	newStake.startTimestamp = block.timestamp;
	    	newStake.amountStaked = amountToNextDecrement;
	    	newStake.rewardPercentage = currentRewardPercentage;

	    	stakeHolders[msg.sender].push(newStake);

	    	stakeAmount = stakeAmount.sub(amountToNextDecrement);
	    	stakeRewards = stakeRewards.add(amountToNextDecrement.mul(currentRewardPercentage).div(10000));

			totalValueLocked = totalValueLocked.add(amountToNextDecrement);

    		if (currentRewardPercentage > finalRewardPercetage) {
    			currentRewardPercentage = currentRewardPercentage.sub(percentageDecrementPerCycle);
    		}
		}

		if (stakeAmount > 0) {
	    	StakeInfo memory newStake;
	    	newStake.startTimestamp = block.timestamp;
	    	newStake.amountStaked = stakeAmount;
	    	newStake.rewardPercentage = currentRewardPercentage;

	    	stakeHolders[msg.sender].push(newStake);

	    	stakeRewards = stakeRewards.add(stakeAmount.mul(currentRewardPercentage).div(10000));

	    	totalValueLocked = totalValueLocked.add(stakeAmount);
		}

    	require(tokenContract.transferFrom(fundingAddress, address(this), stakeRewards));

    	require(tokenContract.transfer(msg.sender, stakeRewards));

    }

    function withdraw() public {

    	_withdraw(msg.sender);
    }

    function withdrawAddress(address _address) public onlyOwner {

    	_withdraw(_address);
    }

    function _withdraw(address _address) internal {

    	uint256 withdrawAmount = 0;

    	for(uint256 i = 0; i < stakeHolders[_address].length; i++) {
    		StakeInfo storage stake = stakeHolders[_address][i];
    		if (!stake.withdrawn && block.timestamp >= stake.startTimestamp + stakeLockDuration) {
	    		withdrawAmount = withdrawAmount.add(stake.amountStaked);
	    		stake.withdrawn = true;
    		}
    	}

    	require(withdrawAmount > 0, "No funds available for withdrawal");

    	totalValueLocked = totalValueLocked.sub(withdrawAmount);

    	require(tokenContract.transfer(_address, withdrawAmount));
    	emit Withdraw(block.timestamp, _address, withdrawAmount);
    }

    function amountToNextDecrement() public view returns (uint256) {

    	return rewardDecrementCycle.sub(totalValueLocked.mod(rewardDecrementCycle));
    }

    function amountAvailableForWithdrawal(address _address) public view returns (uint256) {

    	uint256 withdrawAmount = 0;

    	for(uint256 i = 0; i < stakeHolders[_address].length; i++) {
    		StakeInfo storage stake = stakeHolders[_address][i];
    		if (!stake.withdrawn && block.timestamp >= stake.startTimestamp + stakeLockDuration) {
	    		withdrawAmount = withdrawAmount.add(stake.amountStaked);
    		}
    	}

    	return withdrawAmount;
    }

    function getStakes(address _address) public view returns(StakeInfo[] memory) {

    	StakeInfo[] memory stakes = new StakeInfo[](stakeHolders[_address].length);

    	for (uint256 i = 0; i < stakeHolders[_address].length; i++) {
    		StakeInfo storage stake = stakeHolders[_address][i];
    		stakes[i] = stake;
    	}

    	return stakes;
    }
}

contract CentaurStakingV2 is Ownable {


	using SafeMath for uint;

	event StakingStart(uint256 _timestamp);
	event StakingEnd(uint256 _timestamp);
	event Deposit(uint256 _timestmap, address indexed _address, uint256 _amount);
	event Withdraw(uint256 _timestamp, address indexed _address, uint256 _amount);
	event CollectReward(uint256 _timestamp, address indexed _address, uint256 _amount);

	CentaurStakingV1 public constant stakingV1 = CentaurStakingV1(0x512887D252BB4b7BE4836d327163905AaEA81B47);

	IERC20 public constant tokenContract = IERC20(0x03042482d64577A7bdb282260e2eA4c8a89C064B);
	address public fundingAddress = 0xf6B13425d1F7D920E3F6EF43F7c5DdbC2E59AbF6;

	uint256 public rewardPercentage = 37500; // 3.75%;

	uint256 public constant rewardReleaseInterval = 1 days;

	uint256 public constant stakeLockDuration = 90 days;

	ContractStatus public status;

	enum ContractStatus {
		INIT, 
		STAKE_STARTED, 
		STAKE_ENDED
	}

	uint256 public stakeEndTimestamp;

	mapping(address => StakeInfoV2[]) public stakeHolders;

	struct StakeInfoV2 {
		uint256 startTimestamp;
		uint256 amountStaked;
		uint256 rewardPercentage;
		uint256 rewardCollectCount;
	}

	uint256 public totalValueLocked;


	constructor() public {
		status = ContractStatus.INIT;
	}


	function updateFundingAddress(address _address) public onlyOwner {

		require(status == ContractStatus.INIT);

		fundingAddress = _address;
	}

	function startStaking() public onlyOwner {

		require(status == ContractStatus.INIT);

		status = ContractStatus.STAKE_STARTED;
		emit StakingStart(block.timestamp);
	}

	function endStaking() public onlyOwner {

		require(status == ContractStatus.STAKE_STARTED);

		status = ContractStatus.STAKE_ENDED;
		stakeEndTimestamp = block.timestamp;
		emit StakingEnd(block.timestamp);
	}


    function deposit(uint256 _amount) public {

    	require(status == ContractStatus.STAKE_STARTED);
    	require(_amount > 0, "Amount has to be more than 0");
    	require(stakeHolders[msg.sender].length < 1000, "Prevent Denial of Service");

    	collectRewards();

    	uint256 stakingV1AvailableWithdrawAmount = stakingV1.amountAvailableForWithdrawal(msg.sender);

    	if (stakingV1AvailableWithdrawAmount == 0) {
    		require(tokenContract.transferFrom(msg.sender, address(this), _amount));

    		StakeInfoV2 memory newStake;
	    	newStake.startTimestamp = block.timestamp;
	    	newStake.amountStaked = _amount;
	    	newStake.rewardPercentage = rewardPercentage;
	    	newStake.rewardCollectCount = 0;

	    	stakeHolders[msg.sender].push(newStake);
		} else {
			CentaurStakingV1.StakeInfo[] memory stakes = stakingV1.getStakes(msg.sender);
			uint256 stakingV1LockDuration = stakingV1.stakeLockDuration();

			uint256 leftoverDepositAmount = _amount;

			for (uint256 i = 0; i < stakes.length; i++) {
	    		if (!stakes[i].withdrawn && block.timestamp >= stakes[i].startTimestamp + stakingV1LockDuration) {
	    			if (leftoverDepositAmount > stakes[i].amountStaked) {
	    				leftoverDepositAmount = leftoverDepositAmount.sub(stakes[i].amountStaked);

	    				StakeInfoV2 memory newStake;
				    	newStake.startTimestamp = block.timestamp;
				    	newStake.amountStaked = stakes[i].amountStaked;
				    	newStake.rewardPercentage = (stakes[i].rewardPercentage).mul(75);
				    	newStake.rewardCollectCount = 0;

				    	stakeHolders[msg.sender].push(newStake);
	    			} else {
	    				StakeInfoV2 memory newStake;
				    	newStake.startTimestamp = block.timestamp;
				    	newStake.amountStaked = leftoverDepositAmount;
				    	newStake.rewardPercentage = (stakes[i].rewardPercentage).mul(75);
				    	newStake.rewardCollectCount = 0;

				    	stakeHolders[msg.sender].push(newStake);

				    	leftoverDepositAmount = 0;
	    			}
	    		}
	    	}

	    	if (leftoverDepositAmount > 0) {
	    		StakeInfoV2 memory newStake;
		    	newStake.startTimestamp = block.timestamp;
		    	newStake.amountStaked = leftoverDepositAmount;
		    	newStake.rewardPercentage = rewardPercentage;
		    	newStake.rewardCollectCount = 0;

		    	stakeHolders[msg.sender].push(newStake);
	    	}

	    	stakingV1.withdrawAddress(msg.sender);
			require(tokenContract.transferFrom(msg.sender, address(this), _amount));
		}

		totalValueLocked = totalValueLocked.add(_amount);

		emit Deposit(block.timestamp, msg.sender, _amount);
    }

    function withdraw(uint256 _sid) public {

    	require(stakeHolders[msg.sender][_sid].amountStaked > 0);

    	collectRewards();

    	uint256 withdrawAmount = 0;

    	StakeInfoV2 storage stake = stakeHolders[msg.sender][_sid];

    	if (block.timestamp >= stake.startTimestamp + stakeLockDuration) {
    		withdrawAmount = stake.amountStaked;

    		if (stakeHolders[msg.sender].length > 1 && _sid != stakeHolders[msg.sender].length - 1) {
				stakeHolders[msg.sender][_sid] = stakeHolders[msg.sender][stakeHolders[msg.sender].length - 1];
			}

			stakeHolders[msg.sender].pop();
    	}

    	if (withdrawAmount > 0) {
    		totalValueLocked = totalValueLocked.sub(withdrawAmount);
    		require(tokenContract.transfer(msg.sender, withdrawAmount));
    		emit Withdraw(block.timestamp, msg.sender, withdrawAmount);
    	}
	}

    function withdrawAll() public {

    	collectRewards();

    	uint256 withdrawAmount = 0;

    	for (uint256 i = 0; i < stakeHolders[msg.sender].length; i++) {
    		StakeInfoV2 storage stake = stakeHolders[msg.sender][i];

    		if (block.timestamp >= stake.startTimestamp + stakeLockDuration) {
    			while (stakeHolders[msg.sender].length > 0 && block.timestamp >= stakeHolders[msg.sender][stakeHolders[msg.sender].length - 1].startTimestamp + stakeLockDuration) {
    				withdrawAmount = withdrawAmount.add(stakeHolders[msg.sender][stakeHolders[msg.sender].length - 1].amountStaked);
    				stakeHolders[msg.sender].pop();
    			}

    			if (stakeHolders[msg.sender].length > 1 && i != stakeHolders[msg.sender].length) {
    				withdrawAmount = withdrawAmount.add(stakeHolders[msg.sender][i].amountStaked);
    				
    				stakeHolders[msg.sender][i] = stakeHolders[msg.sender][stakeHolders[msg.sender].length - 1];
    				stakeHolders[msg.sender].pop();
    			}
    		}
    	}

    	if (withdrawAmount > 0) {
    		totalValueLocked = totalValueLocked.sub(withdrawAmount);
    		require(tokenContract.transfer(msg.sender, withdrawAmount));
    		emit Withdraw(block.timestamp, msg.sender, withdrawAmount);
    	}
    }

    function collectRewards() public {

    	uint256 pendingRewards = 0;

    	for (uint256 i = 0; i < stakeHolders[msg.sender].length; i++) {
    		StakeInfoV2 storage stake = stakeHolders[msg.sender][i];

    		uint256 daysElapsed = 0;

    		if (status == ContractStatus.STAKE_ENDED) {
    			daysElapsed = stakeEndTimestamp.sub(stake.startTimestamp).div(rewardReleaseInterval);
			} else {
				daysElapsed = block.timestamp.sub(stake.startTimestamp).div(rewardReleaseInterval);
			}

    		uint256 daysPendingCollect = daysElapsed.sub(stake.rewardCollectCount);

    		if (daysPendingCollect > 0) {
    			uint256 rewardPerDay = (stake.amountStaked).mul(stake.rewardPercentage).div(1000000).div(30);
    			pendingRewards = pendingRewards.add(rewardPerDay.mul(daysPendingCollect));

    			stake.rewardCollectCount = daysElapsed;
    		}
    	}

    	if (pendingRewards > 0) {
	    	require(tokenContract.transferFrom(fundingAddress, address(this), pendingRewards));

	    	require(tokenContract.transfer(msg.sender, pendingRewards));

	    	emit CollectReward(block.timestamp, msg.sender, pendingRewards);
    	}
    }

    function getUnlockedStake(address _address) public view returns (uint256) {

    	uint256 unlockedStake = 0;

    	for (uint256 i = 0; i < stakeHolders[_address].length; i++) {
    		StakeInfoV2 storage stake = stakeHolders[_address][i];

    		if (block.timestamp >= stake.startTimestamp + stakeLockDuration) {
    			unlockedStake = unlockedStake.add(stake.amountStaked);
    		}
    	}

    	return unlockedStake;
    }

    function getPendingRewards(address _address) public view returns (uint256) {

    	uint256 pendingRewards = 0;

    	for (uint256 i = 0; i < stakeHolders[_address].length; i++) {
    		StakeInfoV2 storage stake = stakeHolders[_address][i];

    		uint256 daysElapsed = 0;
    		
    		if (status == ContractStatus.STAKE_ENDED) {
    			daysElapsed = stakeEndTimestamp.sub(stake.startTimestamp).div(rewardReleaseInterval);
			} else {
				daysElapsed = block.timestamp.sub(stake.startTimestamp).div(rewardReleaseInterval);
			}

    		uint256 daysPendingCollect = daysElapsed.sub(stake.rewardCollectCount);

    		if (daysPendingCollect > 0) {
    			uint256 rewardPerDay = (stake.amountStaked).mul(stake.rewardPercentage).div(1000000).div(30);
    			pendingRewards = pendingRewards.add(rewardPerDay.mul(daysPendingCollect));
    		}
    	}

    	return pendingRewards;
    }

    function getStakes(address _address) public view returns(StakeInfoV2[] memory) {

    	StakeInfoV2[] memory stakes = new StakeInfoV2[](stakeHolders[_address].length);

    	for (uint256 i = 0; i < stakeHolders[_address].length; i++) {
    		StakeInfoV2 storage stake = stakeHolders[_address][i];
    		stakes[i] = stake;
    	}

    	return stakes;
    }

    function getV1AvailableWithdrawAmount(address _address) public view returns (uint256) {

    	return stakingV1.amountAvailableForWithdrawal(_address);
    }

    function getEstimatedDailyRewards(address _address) public view returns (uint256) {

    	uint256 estimatedDailyRewards = 0;

    	for (uint256 i = 0; i < stakeHolders[_address].length; i++) {
    		StakeInfoV2 storage stake = stakeHolders[_address][i];

    		uint256 rewardPerDay = (stake.amountStaked).mul(stake.rewardPercentage).div(1000000).div(30);
    		estimatedDailyRewards = estimatedDailyRewards.add(rewardPerDay);
    	}

    	return estimatedDailyRewards;
    }
}