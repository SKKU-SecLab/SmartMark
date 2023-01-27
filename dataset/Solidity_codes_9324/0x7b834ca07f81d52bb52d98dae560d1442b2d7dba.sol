
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
}// MIT

pragma solidity ^0.8.0;


interface IRewarder {

    function onSushiReward(uint256 pid, address user, address recipient, uint256 sushiAmount, uint256 newLpAmount) external;

    function pendingTokens(uint256 pid, address user, uint256 sushiAmount) external view returns (IERC20[] memory, uint256[] memory);

}// GPL-3.0-or-later
pragma solidity ^0.8.4;


interface ITribalChief {

    struct RewardData {
        uint128 lockLength;
        uint128 rewardMultiplier;
    }

    struct PoolInfo {
        uint256 virtualTotalSupply;
        uint256 accTribePerShare;
        uint128 lastRewardBlock;
        uint120 allocPoint;
        bool unlocked;
    }

    function rewardMultipliers(uint256 _pid, uint128 _blocksLocked) external view returns (uint128);

    function stakedToken(uint256 _index) external view returns(IERC20);

    function poolInfo(uint256 _index) external view returns(uint256, uint256, uint128, uint120, bool);

    function tribePerBlock() external view returns (uint256);

    function pendingRewards(uint256 _pid, address _user) external view returns (uint256);

    function getTotalStakedInPool(uint256 pid, address user) external view returns (uint256);

    function openUserDeposits(uint256 pid, address user) external view returns (uint256);

    function numPools() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function SCALE_FACTOR() external view returns (uint256);


    function deposit(uint256 _pid, uint256 _amount, uint64 _lockLength) external;

    function harvest(uint256 pid, address to) external;

    function withdrawAllAndHarvest(uint256 pid, address to) external;

    function withdrawFromDeposit(uint256 pid, uint256 amount, address to, uint256 index) external; 

    function emergencyWithdraw(uint256 pid, address to) external;


    function updatePool(uint256 pid) external;

    function massUpdatePools(uint256[] calldata pids) external;


    function resetRewards(uint256 _pid) external;

    function set(uint256 _pid, uint120 _allocPoint, IRewarder _rewarder, bool overwrite) external;

    function add(uint120 allocPoint, IERC20 _stakedToken, IRewarder _rewarder, RewardData[] calldata rewardData) external;

    function governorWithdrawTribe(uint256 amount) external;

    function governorAddPoolMultiplier(uint256 _pid, uint64 lockLength, uint64 newRewardsMultiplier) external;

    function unlockPool(uint256 _pid) external;

    function lockPool(uint256 _pid) external;

    function updateBlockReward(uint256 newBlockReward) external;

}pragma solidity ^0.8.0;


interface IAutoRewardsDistributor {

    function setAutoRewardsDistribution() external;

}

interface ITimelock {

    function execute(
        address target,
        uint256 value,
        bytes calldata data,
        bytes32 predecessor,
        bytes32 salt
    ) external;

}

contract TribalChiefSyncV2 {

    ITribalChief public immutable tribalChief;
    IAutoRewardsDistributor public immutable autoRewardsDistributor;
    ITimelock public immutable timelock;

    mapping(uint256 => uint256) public rewardsSchedule;

    uint256[] public rewardsArray;

    struct RewardData {
        uint128 lockLength;
        uint128 rewardMultiplier;
    }

    constructor(
        ITribalChief _tribalChief,
        IAutoRewardsDistributor _autoRewardsDistributor,
        ITimelock _timelock,
        uint256[] memory rewards,
        uint256[] memory timestamps
    ) {
        tribalChief = _tribalChief;
        autoRewardsDistributor = _autoRewardsDistributor;
        timelock = _timelock;

        require(rewards.length == timestamps.length, "length");

        uint256 lastReward = type(uint256).max;
        uint256 lastTimestamp = block.timestamp;
        uint256 len = rewards.length;
        rewardsArray = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            uint256 nextReward = rewards[i];
            uint256 nextTimestamp = timestamps[i];
            
            require(nextReward < lastReward, "rewards");
            require(nextTimestamp > lastTimestamp, "timestamp");
            
            rewardsSchedule[nextReward] = nextTimestamp;
            rewardsArray[len - i - 1] = nextReward;

            lastReward = nextReward;
            lastTimestamp = nextTimestamp;
        }
    }

    modifier update {

        uint256 numPools = tribalChief.numPools();
        uint256[] memory pids = new uint256[](numPools);
        for (uint256 i = 0; i < numPools; i++) {
            pids[i] = i;
        }
        tribalChief.massUpdatePools(pids);
        _;
        autoRewardsDistributor.setAutoRewardsDistribution();
    }

    function autoDecreaseRewards() external update {

        require(isRewardDecreaseAvailable(), "time not passed");
        uint256 tribePerBlock = nextRewardsRate();
        tribalChief.updateBlockReward(tribePerBlock);
        rewardsArray.pop();
    }

    function isRewardDecreaseAvailable() public view returns(bool) {

        return rewardsArray.length > 0 && nextRewardTimestamp() < block.timestamp;
    }

    function nextRewardTimestamp() public view returns(uint256) {

        return rewardsSchedule[nextRewardsRate()];
    }

    function nextRewardsRate() public view returns(uint256) {

        return rewardsArray[rewardsArray.length - 1];
    }

    function decreaseRewards(uint256 tribePerBlock, bytes32 salt) external update {

        bytes memory data = abi.encodeWithSelector(
            tribalChief.updateBlockReward.selector, 
            tribePerBlock
        );
        timelock.execute(
            address(tribalChief), 
            0, 
            data, 
            bytes32(0), 
            salt
        );
    }

    function addPool(
        uint120 allocPoint, 
        address stakedToken, 
        address rewarder, 
        RewardData[] memory rewardData, 
        bytes32 salt
    ) external update {

        bytes memory data = abi.encodeWithSelector(
            tribalChief.add.selector, 
            allocPoint,
            stakedToken,
            rewarder,
            rewardData
        );
        timelock.execute(
            address(tribalChief), 
            0, 
            data, 
            bytes32(0), 
            salt
        );
    }

    function setPool(
        uint256 pid,
        uint120 allocPoint,
        IRewarder rewarder,
        bool overwrite,
        bytes32 salt
    ) external update {

        bytes memory data = abi.encodeWithSelector(
            tribalChief.set.selector,
            pid,
            allocPoint,
            rewarder,
            overwrite
        );
        timelock.execute(
            address(tribalChief), 
            0, 
            data, 
            bytes32(0), 
            salt
        );
    }

    function resetPool(
        uint256 pid,
        bytes32 salt
    ) external update {

        bytes memory data = abi.encodeWithSelector(
            tribalChief.resetRewards.selector,
            pid
        );
        timelock.execute(
            address(tribalChief), 
            0, 
            data, 
            bytes32(0), 
            salt
        );
    }
}pragma solidity ^0.8.0;


contract TribalChiefSyncExtension {

    TribalChiefSyncV2 public immutable tribalChiefSync;

    constructor(TribalChiefSyncV2 _tribalChiefSync) {
        tribalChiefSync = _tribalChiefSync;
    }

    modifier update(IAutoRewardsDistributor[] calldata distributors) {

        _;
        unchecked {
            for (uint256 i = 0; i < distributors.length; i++) {
                distributors[i].setAutoRewardsDistribution();
            }
        }
    }

    function autoDecreaseRewards(IAutoRewardsDistributor[] calldata distributors) external update(distributors) {

        tribalChiefSync.autoDecreaseRewards();
    }

    function decreaseRewards(uint256 tribePerBlock, bytes32 salt, IAutoRewardsDistributor[] calldata distributors) external update(distributors) {

        tribalChiefSync.decreaseRewards(tribePerBlock, salt);
    }

    function addPool(
        uint120 allocPoint, 
        address stakedToken, 
        address rewarder, 
        TribalChiefSyncV2.RewardData[] calldata rewardData, 
        bytes32 salt,
        IAutoRewardsDistributor[] calldata distributors
    ) external update(distributors) {

        tribalChiefSync.addPool(allocPoint, stakedToken, rewarder, rewardData, salt);
    }

    function setPool(
        uint256 pid,
        uint120 allocPoint,
        IRewarder rewarder,
        bool overwrite,
        bytes32 salt,
        IAutoRewardsDistributor[] calldata distributors
    ) external update(distributors) {

        tribalChiefSync.setPool(pid, allocPoint, rewarder, overwrite, salt);
    }

    function resetPool(
        uint256 pid,
        bytes32 salt,
        IAutoRewardsDistributor[] calldata distributors
    ) external update(distributors) {

        tribalChiefSync.resetPool(pid, salt);
    }
}