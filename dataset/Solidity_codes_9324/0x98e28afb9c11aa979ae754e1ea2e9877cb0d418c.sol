

pragma solidity 0.6.12;

interface ILockedCvx{

    function lock(address _account, uint256 _amount, uint256 _spendRatio) external;

    function processExpiredLocks(bool _relock, uint256 _spendRatio, address _withdrawTo) external;

    function getReward(address _account, bool _stake) external;

    function balanceAtEpochOf(uint256 _epoch, address _user) view external returns(uint256 amount);

    function totalSupplyAtEpoch(uint256 _epoch) view external returns(uint256 supply);

    function epochCount() external view returns(uint256);

    function checkpointEpoch() external;

    function balanceOf(address _account) external view returns(uint256);

    function totalSupply() view external returns(uint256 supply);


    function addReward(
        address _rewardsToken,
        address _distributor,
        bool _useBoost
    ) external;

    function approveRewardDistributor(
        address _rewardsToken,
        address _distributor,
        bool _approved
    ) external;

    function setStakeLimits(uint256 _minimum, uint256 _maximum) external;

    function setBoost(uint256 _max, uint256 _rate, address _receivingAddress) external;

    function setKickIncentive(uint256 _rate, uint256 _delay) external;

    function shutdown() external;

    function recoverERC20(address _tokenAddress, uint256 _tokenAmount) external;

}



pragma solidity >=0.6.0 <0.8.0;

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


pragma solidity 0.6.12;


contract LockerAdmin{


    ILockedCvx public constant locker = ILockedCvx(0xD18140b4B819b895A3dba5442F959fA44994AF50);
    address public operator;

    constructor() public {
        operator = address(0xa3C5A1e09150B75ff251c1a7815A07182c3de2FB);
    }

    modifier onlyOwner() {

        require(operator == msg.sender, "!auth");
        _;
    }

    function setOperator(address _operator) external onlyOwner{

        operator = _operator;
    }


    function addReward(
        address _rewardsToken,
        address _distributor,
        bool _useBoost
    ) external onlyOwner{

        locker.addReward(_rewardsToken, _distributor, _useBoost);
    }

    function approveRewardDistributor(
        address _rewardsToken,
        address _distributor,
        bool _approved
    ) external onlyOwner{

        locker.approveRewardDistributor(_rewardsToken, _distributor, _approved);
    }


    function setStakeLimits(uint256 _minimum, uint256 _maximum) external onlyOwner {

        require(_minimum <= _maximum, "min range");
        locker.setStakeLimits(_minimum, _maximum);
    }

    function setBoost(uint256 _max, uint256 _rate, address _receivingAddress) external onlyOwner {

        require(_max < 1500, "over max payment"); //max 15%
        require(_rate < 30000, "over max rate"); //max 3x
        locker.setBoost(_max, _rate, _receivingAddress);
    }

    function setKickIncentive(uint256 _rate, uint256 _delay) external onlyOwner {

        locker.setKickIncentive(_rate, _delay);
    }

    function shutdown() external onlyOwner {

        locker.shutdown();
    }

    function recoverERC20(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {

        locker.recoverERC20(_tokenAddress, _tokenAmount);
        transferToken(_tokenAddress, _tokenAmount);
    }

    function transferToken(address _tokenAddress, uint256 _tokenAmount) public onlyOwner {

        IERC20(_tokenAddress).transfer(operator, _tokenAmount);
    }
}