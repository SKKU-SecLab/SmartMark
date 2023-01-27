

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


pragma solidity ^0.5.0;



interface IRewardDistributionRecipient {

    function notifyRewardAmount(uint256 reward) external;


    function rewardToken() external view returns (IERC20 token);

}


pragma solidity 0.5.16;




contract RewardsInitiator {

    string constant private ERROR_TOO_EARLY = "REWARDS_CTRL:TOO_EARLY";

    uint256 constant public earliestStartTime = 1603983600; // 2020-10-29 15:00 UTC

    IRewardDistributionRecipient public uniPool = IRewardDistributionRecipient(0x37B7870148b4B815cb6A4728a84816Cc1150e3aa);
    IRewardDistributionRecipient public bptPool = IRewardDistributionRecipient(0x7F2b9E4134Ba2f7E99859aE40436Cbe888E86B79);

    function initiate() external {

        require(block.timestamp >= earliestStartTime, ERROR_TOO_EARLY);

        uint256 uniRewardBalance = poolRewardBalance(uniPool);
        uniPool.notifyRewardAmount(uniRewardBalance);

        uint256 bptRewardBalance = poolRewardBalance(bptPool);
        bptPool.notifyRewardAmount(bptRewardBalance);
    }

    function poolRewardBalance(IRewardDistributionRecipient _pool) public view returns (uint256) {

        IERC20 rewardToken = _pool.rewardToken();
        return rewardToken.balanceOf(address(_pool));
    }
}