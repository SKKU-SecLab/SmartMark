


pragma solidity 0.6.7;

abstract contract TokenLike {
    function balanceOf(address) virtual public view returns (uint256);
    function transfer(address, uint256) virtual external returns (bool);
}

contract AutoRewardDripper {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) virtual external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) virtual external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "AutoRewardDripper/account-not-authorized");
        _;
    }

    uint256   public lastRewardBlock;
    uint256   public rewardPerBlock;
    uint256   public rewardTimeline;
    uint256   public lastRewardCalculation;
    uint256   public rewardCalculationDelay;
    address   public requestor;
    TokenLike public rewardToken;

    uint256 public constant MAX_REWARD_TIMELINE = 2250000;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(bytes32 indexed parameter, uint256 data);
    event ModifyParameters(bytes32 indexed parameter, address data);
    event DripReward(address requestor, uint256 amountToTransfer);
    event TransferTokenOut(address dst, uint256 amount);
    event RecomputePerBlockReward(uint256 rewardPerBlock);

    constructor(
      address requestor_,
      address rewardToken_,
      uint256 rewardTimeline_,
      uint256 rewardCalculationDelay_
    ) public {
        require(requestor_ != address(0), "AutoRewardDripper/null-requoestor");
        require(rewardToken_ != address(0), "AutoRewardDripper/null-reward-token");
        require(rewardTimeline_ > 0, "AutoRewardDripper/null-reward-time");
        require(rewardTimeline_ <= MAX_REWARD_TIMELINE, "AutoRewardDripper/high-reward-timeline");
        require(rewardCalculationDelay_ > 0, "AutoRewardDripper/null-reward-calc-delay");

        authorizedAccounts[msg.sender] = 1;

        rewardTimeline         = rewardTimeline_;
        requestor              = requestor_;
        rewardCalculationDelay = rewardCalculationDelay_;
        rewardToken            = TokenLike(rewardToken_);
        lastRewardBlock        = block.number;

        emit AddAuthorization(msg.sender);
        emit ModifyParameters("rewardTimeline", rewardTimeline);
        emit ModifyParameters("rewardCalculationDelay", rewardCalculationDelay);
        emit ModifyParameters("requestor", requestor);
        emit ModifyParameters("lastRewardBlock", lastRewardBlock);
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    function subtract(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "AutoRewardDripper/sub-underflow");
    }
    function multiply(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "AutoRewardDripper/mul-overflow");
    }

    function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized {

        if (parameter == "lastRewardBlock") {
            require(data >= block.number, "AutoRewardDripper/invalid-last-reward-block");
            lastRewardBlock = data;
        } else if (parameter == "rewardPerBlock") {
            require(data > 0, "AutoRewardDripper/invalid-reward-per-block");
            rewardPerBlock = data;
        } else if (parameter == "rewardCalculationDelay") {
            require(data > 0, "AutoRewardDripper/invalid-reward-calculation-delay");
            rewardCalculationDelay = data;
        } else if (parameter == "rewardTimeline") {
            require(data > 0 && data <= MAX_REWARD_TIMELINE, "AutoRewardDripper/invalid-reward-timeline");
            rewardTimeline = data;
        }
        else revert("AutoRewardDripper/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }
    function modifyParameters(bytes32 parameter, address data) external isAuthorized {

        require(data != address(0), "AutoRewardDripper/null-data");
        if (parameter == "requestor") {
            requestor = data;
        }
        else revert("AutoRewardDripper/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }

    function transferTokenOut(address dst, uint256 amount) external isAuthorized {

        require(dst != address(0), "AutoRewardDripper/null-dst");
        require(amount > 0, "AutoRewardDripper/null-amount");

        require(rewardToken.transfer(dst, amount), "AutoRewardDripper/failed-transfer");

        emit TransferTokenOut(dst, amount);
    }
    function dripReward() external {

        dripReward(msg.sender);
    }
    function recomputePerBlockReward() public {

        uint256 remainingBalance = rewardToken.balanceOf(address(this));
        if (either(remainingBalance == 0, subtract(now, lastRewardCalculation) < rewardCalculationDelay)) return;
        lastRewardCalculation    = now;
        rewardPerBlock           = (rewardTimeline >= remainingBalance) ? remainingBalance : remainingBalance / rewardTimeline;
        emit RecomputePerBlockReward(rewardPerBlock);
    }
    function dripReward(address to) public {

        if (lastRewardBlock >= block.number) return;
        require(msg.sender == requestor, "AutoRewardDripper/invalid-caller");

        uint256 remainingBalance = rewardToken.balanceOf(address(this));
        uint256 amountToTransfer = multiply(subtract(block.number, lastRewardBlock), rewardPerBlock);
        amountToTransfer         = (amountToTransfer > remainingBalance) ? remainingBalance : amountToTransfer;

        lastRewardBlock = block.number;
        recomputePerBlockReward();

        if (amountToTransfer == 0) return;
        require(rewardToken.transfer(to, amountToTransfer), "AutoRewardDripper/failed-transfer");

        emit DripReward(to, amountToTransfer);
    }
}