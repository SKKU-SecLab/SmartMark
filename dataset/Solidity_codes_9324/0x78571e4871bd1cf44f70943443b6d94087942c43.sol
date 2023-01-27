pragma solidity 0.5.16;


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity 0.5.16;



interface IRewardDistributionRecipient {

    function notifyRewardAmount(uint256 reward) external;


    function rewardToken() external view returns (IERC20 token);

}pragma solidity 0.5.16;



contract RewardsInitiator {

    string constant private ERROR_TOO_EARLY = "REWARDS_CTRL:TOO_EARLY";
    string constant private ERROR_ALREADY_INITIATED = "REWARDS_CTRL:ALREADY_INITIATED";

    uint256 public earliestStartTime;

    IRewardDistributionRecipient public uniPool;
    IRewardDistributionRecipient public bptPool;

    bool initiated;

    constructor(uint256 _earliestStartTime, address _uniPool, address _bptPool) public {
        earliestStartTime = _earliestStartTime;
        uniPool = IRewardDistributionRecipient(_uniPool);
        bptPool = IRewardDistributionRecipient(_bptPool);
    }

    function initiate() external {

        require(block.timestamp >= earliestStartTime, ERROR_TOO_EARLY);
        require(!initiated, ERROR_ALREADY_INITIATED);

        uint256 uniRewardBalance = poolRewardBalance(uniPool);
        uniPool.notifyRewardAmount(uniRewardBalance);

        uint256 bptRewardBalance = poolRewardBalance(bptPool);
        bptPool.notifyRewardAmount(bptRewardBalance);

        initiated = true;
    }

    function poolRewardBalance(IRewardDistributionRecipient _pool) public view returns (uint256) {

        IERC20 rewardToken = _pool.rewardToken();
        return rewardToken.balanceOf(address(_pool));
    }
}