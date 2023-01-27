
pragma solidity 0.6.7;

abstract contract StabilityFeeTreasuryLike {
    function modifyParameters(bytes32, uint256) virtual external;
}
abstract contract OracleRelayerLike {
    function redemptionPrice() virtual public returns (uint256);
}

contract SFTreasuryCoreParamAdjuster {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "SFTreasuryCoreParamAdjuster/account-not-authorized");
        _;
    }

    struct FundedFunction {
        uint256 latestExpectedCalls;
        uint256 latestMaxReward;      // [wad]
    }

    uint256                  public updateDelay;                       // [seconds]
    uint256                  public lastUpdateTime;                    // [unit timestamp]
    uint256                  public dynamicRawTreasuryCapacity;        // [wad]
    uint256                  public treasuryCapacityMultiplier;        // [hundred]
    uint256                  public minTreasuryCapacity;               // [rad]
    uint256                  public minimumFundsMultiplier;            // [hundred]
    uint256                  public minMinimumFunds;                   // [rad]
    uint256                  public pullFundsMinThresholdMultiplier;   // [hundred]
    uint256                  public minPullFundsThreshold;             // [rad]

    mapping(address => uint256) public rewardAdjusters;

    mapping(address => mapping(bytes4 => FundedFunction)) public whitelistedFundedFunctions;

    StabilityFeeTreasuryLike public treasury;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event AddRewardAdjuster(address adjuster);
    event RemoveRewardAdjuster(address adjuster);
    event ModifyParameters(bytes32 parameter, uint256 val);
    event ModifyParameters(bytes32 parameter, address addr);
    event ModifyParameters(address targetContract, bytes4 targetFunction, bytes32 parameter, uint256 val);
    event AddFundedFunction(address targetContract, bytes4 targetFunction, uint256 latestExpectedCalls);
    event RemoveFundedFunction(address targetContract, bytes4 targetFunction);
    event AdjustMaxReward(address targetContract, bytes4 targetFunction, uint256 newMaxReward, uint256 dynamicCapacity);
    event UpdateTreasuryParameters(uint256 newMinPullFundsThreshold, uint256 newMinimumFunds, uint256 newTreasuryCapacity);

    constructor(
      address treasury_,
      uint256 updateDelay_,
      uint256 lastUpdateTime_,
      uint256 treasuryCapacityMultiplier_,
      uint256 minTreasuryCapacity_,
      uint256 minimumFundsMultiplier_,
      uint256 minMinimumFunds_,
      uint256 pullFundsMinThresholdMultiplier_,
      uint256 minPullFundsThreshold_
    ) public {
        require(treasury_ != address(0), "SFTreasuryCoreParamAdjuster/null-treasury");

        require(updateDelay_ > 0, "SFTreasuryCoreParamAdjuster/null-update-delay");
        require(lastUpdateTime_ > now, "SFTreasuryCoreParamAdjuster/invalid-last-update-time");
        require(both(treasuryCapacityMultiplier_ >= HUNDRED, treasuryCapacityMultiplier_ <= THOUSAND), "SFTreasuryCoreParamAdjuster/invalid-capacity-mul");
        require(minTreasuryCapacity_ > 0, "SFTreasuryCoreParamAdjuster/invalid-min-capacity");
        require(both(minimumFundsMultiplier_ >= HUNDRED, minimumFundsMultiplier_ <= THOUSAND), "SFTreasuryCoreParamAdjuster/invalid-min-funds-mul");
        require(minMinimumFunds_ > 0, "SFTreasuryCoreParamAdjuster/null-min-minimum-funds");
        require(both(pullFundsMinThresholdMultiplier_ >= HUNDRED, pullFundsMinThresholdMultiplier_ <= THOUSAND), "SFTreasuryCoreParamAdjuster/invalid-pull-funds-threshold-mul");
        require(minPullFundsThreshold_ > 0, "SFTreasuryCoreParamAdjuster/null-min-pull-funds-threshold");

        authorizedAccounts[msg.sender]   = 1;

        treasury                         = StabilityFeeTreasuryLike(treasury_);

        updateDelay                      = updateDelay_;
        lastUpdateTime                   = lastUpdateTime_;
        treasuryCapacityMultiplier       = treasuryCapacityMultiplier_;
        minTreasuryCapacity              = minTreasuryCapacity_;
        minimumFundsMultiplier           = minimumFundsMultiplier_;
        minMinimumFunds                  = minMinimumFunds_;
        pullFundsMinThresholdMultiplier  = pullFundsMinThresholdMultiplier_;
        minPullFundsThreshold            = minPullFundsThreshold_;

        emit AddAuthorization(msg.sender);
        emit ModifyParameters("treasury", treasury_);
        emit ModifyParameters("updateDelay", updateDelay);
        emit ModifyParameters("lastUpdateTime", lastUpdateTime);
        emit ModifyParameters("minTreasuryCapacity", minTreasuryCapacity);
        emit ModifyParameters("minMinimumFunds", minMinimumFunds);
        emit ModifyParameters("minPullFundsThreshold", minPullFundsThreshold);
        emit ModifyParameters("treasuryCapacityMultiplier", treasuryCapacityMultiplier);
        emit ModifyParameters("minimumFundsMultiplier", minimumFundsMultiplier);
        emit ModifyParameters("pullFundsMinThresholdMultiplier", pullFundsMinThresholdMultiplier);
    }

    uint256 public constant RAY      = 10 ** 27;
    uint256 public constant WAD      = 10 ** 18;
    uint256 public constant HUNDRED  = 100;
    uint256 public constant THOUSAND = 1000;
    function addition(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "SFTreasuryCoreParamAdjuster/add-uint-uint-overflow");
    }
    function subtract(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "SFTreasuryCoreParamAdjuster/sub-uint-uint-underflow");
    }
    function multiply(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x, "SFTreasuryCoreParamAdjuster/multiply-uint-uint-overflow");
    }
    function maximum(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = (x >= y) ? x : y;
    }

    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }

    function modifyParameters(bytes32 parameter, uint256 val) external isAuthorized {

        require(val > 0, "SFTreasuryCoreParamAdjuster/null-value");

        if (parameter == "updateDelay") {
            updateDelay = val;
        }
        else if (parameter == "dynamicRawTreasuryCapacity") {
            dynamicRawTreasuryCapacity = val;
        }
        else if (parameter == "treasuryCapacityMultiplier") {
            require(both(val >= HUNDRED, val <= THOUSAND), "SFTreasuryCoreParamAdjuster/invalid-capacity-mul");
            treasuryCapacityMultiplier = val;
        }
        else if (parameter == "minimumFundsMultiplier") {
            require(both(val >= HUNDRED, val <= THOUSAND), "SFTreasuryCoreParamAdjuster/invalid-min-funds-mul");
            minimumFundsMultiplier = val;
        }
        else if (parameter == "pullFundsMinThresholdMultiplier") {
            require(both(val >= HUNDRED, val <= THOUSAND), "SFTreasuryCoreParamAdjuster/invalid-pull-funds-threshold-mul");
            pullFundsMinThresholdMultiplier = val;
        }
        else if (parameter == "minTreasuryCapacity") {
            minTreasuryCapacity = val;
        }
        else if (parameter == "minMinimumFunds") {
            minMinimumFunds = val;
        }
        else if (parameter == "minPullFundsThreshold") {
            minPullFundsThreshold = val;
        }
        else revert("SFTreasuryCoreParamAdjuster/modify-unrecognized-param");
        emit ModifyParameters(parameter, val);
    }
    function modifyParameters(bytes32 parameter, address addr) external isAuthorized {

        require(addr != address(0), "SFTreasuryCoreParamAdjuster/null-address");

        if (parameter == "treasury") {
            treasury = StabilityFeeTreasuryLike(addr);
        }
        else revert("SFTreasuryCoreParamAdjuster/modify-unrecognized-param");
        emit ModifyParameters(parameter, addr);
    }
    function modifyParameters(address targetContract, bytes4 targetFunction, bytes32 parameter, uint256 val) external isAuthorized {

        FundedFunction storage fundedFunction = whitelistedFundedFunctions[targetContract][targetFunction];
        require(fundedFunction.latestExpectedCalls >= 1, "SFTreasuryCoreParamAdjuster/inexistent-funded-function");
        require(val >= 1, "SFTreasuryCoreParamAdjuster/invalid-value");

        if (parameter == "latestExpectedCalls") {
            dynamicRawTreasuryCapacity = subtract(dynamicRawTreasuryCapacity, multiply(fundedFunction.latestExpectedCalls, fundedFunction.latestMaxReward));
            fundedFunction.latestExpectedCalls = val;
            dynamicRawTreasuryCapacity = addition(dynamicRawTreasuryCapacity, multiply(val, fundedFunction.latestMaxReward));
        }
        else revert("SFTreasuryCoreParamAdjuster/modify-unrecognized-param");
        emit ModifyParameters(targetContract, targetFunction, parameter, val);
    }

    function addRewardAdjuster(address adjuster) external isAuthorized {

        require(rewardAdjusters[adjuster] == 0, "SFTreasuryCoreParamAdjuster/adjuster-already-added");
        rewardAdjusters[adjuster] = 1;
        emit AddRewardAdjuster(adjuster);
    }
    function removeRewardAdjuster(address adjuster) external isAuthorized {

        require(rewardAdjusters[adjuster] == 1, "SFTreasuryCoreParamAdjuster/adjuster-not-added");
        rewardAdjusters[adjuster] = 0;
        emit RemoveRewardAdjuster(adjuster);
    }

    function addFundedFunction(address targetContract, bytes4 targetFunction, uint256 latestExpectedCalls) external isAuthorized {

        FundedFunction storage fundedFunction = whitelistedFundedFunctions[targetContract][targetFunction];
        require(fundedFunction.latestExpectedCalls == 0, "SFTreasuryCoreParamAdjuster/existent-funded-function");

        require(latestExpectedCalls >= 1, "SFTreasuryCoreParamAdjuster/invalid-expected-calls");
        fundedFunction.latestExpectedCalls = latestExpectedCalls;

        emit AddFundedFunction(targetContract, targetFunction, latestExpectedCalls);
    }
    function removeFundedFunction(address targetContract, bytes4 targetFunction) external isAuthorized {

        FundedFunction memory fundedFunction = whitelistedFundedFunctions[targetContract][targetFunction];
        require(fundedFunction.latestExpectedCalls >= 1, "SFTreasuryCoreParamAdjuster/inexistent-funded-function");

        dynamicRawTreasuryCapacity = subtract(
          dynamicRawTreasuryCapacity,
          multiply(fundedFunction.latestExpectedCalls, fundedFunction.latestMaxReward)
        );

        delete(whitelistedFundedFunctions[targetContract][targetFunction]);

        emit RemoveFundedFunction(targetContract, targetFunction);
    }

    function adjustMaxReward(address targetContract, bytes4 targetFunction, uint256 newMaxReward) external {

        require(rewardAdjusters[msg.sender] == 1, "SFTreasuryCoreParamAdjuster/invalid-caller");
        require(newMaxReward >= 1, "SFTreasuryCoreParamAdjuster/invalid-value");

        FundedFunction storage fundedFunction = whitelistedFundedFunctions[targetContract][targetFunction];
        require(fundedFunction.latestExpectedCalls >= 1, "SFTreasuryCoreParamAdjuster/inexistent-funded-function");

        dynamicRawTreasuryCapacity = subtract(dynamicRawTreasuryCapacity, multiply(fundedFunction.latestExpectedCalls, fundedFunction.latestMaxReward));
        fundedFunction.latestMaxReward = newMaxReward;
        dynamicRawTreasuryCapacity = addition(dynamicRawTreasuryCapacity, multiply(fundedFunction.latestExpectedCalls, newMaxReward));

        emit AdjustMaxReward(targetContract, targetFunction, newMaxReward, dynamicRawTreasuryCapacity);
    }

    function setNewTreasuryParameters() external {

        require(subtract(now, lastUpdateTime) >= updateDelay, "SFTreasuryCoreParamAdjuster/wait-more");
        lastUpdateTime = now;

        uint256 newMaxTreasuryCapacity = multiply(treasuryCapacityMultiplier, dynamicRawTreasuryCapacity) / HUNDRED;
        newMaxTreasuryCapacity         = multiply(newMaxTreasuryCapacity, RAY);
        newMaxTreasuryCapacity         = (newMaxTreasuryCapacity < minTreasuryCapacity) ? minTreasuryCapacity : newMaxTreasuryCapacity;

        uint256 newMinTreasuryCapacity = multiply(minimumFundsMultiplier, newMaxTreasuryCapacity) / HUNDRED;
        newMinTreasuryCapacity         = (newMinTreasuryCapacity < minMinimumFunds) ? minMinimumFunds : newMinTreasuryCapacity;

        uint256 newPullFundsMinThreshold = multiply(pullFundsMinThresholdMultiplier, newMaxTreasuryCapacity) / HUNDRED;
        newPullFundsMinThreshold         = (newPullFundsMinThreshold < minPullFundsThreshold) ? minPullFundsThreshold : newPullFundsMinThreshold;

        treasury.modifyParameters("treasuryCapacity", newMaxTreasuryCapacity);
        treasury.modifyParameters("minimumFundsRequired", newMinTreasuryCapacity);
        treasury.modifyParameters("pullFundsMinThreshold", newPullFundsMinThreshold);

        emit UpdateTreasuryParameters(newPullFundsMinThreshold, newMinTreasuryCapacity, newMaxTreasuryCapacity);
    }
}