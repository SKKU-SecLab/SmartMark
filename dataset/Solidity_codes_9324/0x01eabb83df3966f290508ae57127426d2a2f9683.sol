

pragma solidity =0.6.7;


contract GebMath {

    uint256 public constant RAY = 10 ** 27;
    uint256 public constant WAD = 10 ** 18;

    function ray(uint x) public pure returns (uint z) {

        z = multiply(x, 10 ** 9);
    }
    function rad(uint x) public pure returns (uint z) {

        z = multiply(x, 10 ** 27);
    }
    function minimum(uint x, uint y) public pure returns (uint z) {

        z = (x <= y) ? x : y;
    }
    function addition(uint x, uint y) public pure returns (uint z) {

        z = x + y;
        require(z >= x, "uint-uint-add-overflow");
    }
    function subtract(uint x, uint y) public pure returns (uint z) {

        z = x - y;
        require(z <= x, "uint-uint-sub-underflow");
    }
    function multiply(uint x, uint y) public pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "uint-uint-mul-overflow");
    }
    function rmultiply(uint x, uint y) public pure returns (uint z) {

        z = multiply(x, y) / RAY;
    }
    function rdivide(uint x, uint y) public pure returns (uint z) {

        z = multiply(x, RAY) / y;
    }
    function wdivide(uint x, uint y) public pure returns (uint z) {

        z = multiply(x, WAD) / y;
    }
    function wmultiply(uint x, uint y) public pure returns (uint z) {

        z = multiply(x, y) / WAD;
    }
    function rpower(uint x, uint n, uint base) public pure returns (uint z) {

        assembly {
            switch x case 0 {switch n case 0 {z := base} default {z := 0}}
            default {
                switch mod(n, 2) case 0 { z := base } default { z := x }
                let half := div(base, 2)  // for rounding.
                for { n := div(n, 2) } n { n := div(n,2) } {
                    let xx := mul(x, x)
                    if iszero(eq(div(xx, x), x)) { revert(0,0) }
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) { revert(0,0) }
                    x := div(xxRound, base)
                    if mod(n,2) {
                        let zx := mul(z, x)
                        if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) { revert(0,0) }
                        z := div(zxRound, base)
                    }
                }
            }
        }
    }
}



abstract contract StabilityFeeTreasuryLike_2 {
    function getAllowance(address) virtual external view returns (uint, uint);
    function systemCoin() virtual external view returns (address);
    function pullFunds(address, address, uint) virtual external;
}

contract NoSetupNoAuthIncreasingTreasuryReimbursement is GebMath {

    uint256 public baseUpdateCallerReward;          // [wad]
    uint256 public maxUpdateCallerReward;           // [wad]
    uint256 public maxRewardIncreaseDelay;          // [seconds]
    uint256 public perSecondCallerRewardIncrease;   // [ray]

    StabilityFeeTreasuryLike_2  public treasury;

    event ModifyParameters(
      bytes32 parameter,
      address addr
    );
    event ModifyParameters(
      bytes32 parameter,
      uint256 val
    );
    event FailRewardCaller(bytes revertReason, address feeReceiver, uint256 amount);

    constructor() public {
        maxRewardIncreaseDelay = uint(-1);
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }
    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }

    function treasuryAllowance() public view returns (uint256) {

        (uint total, uint perBlock) = treasury.getAllowance(address(this));
        return minimum(total, perBlock);
    }
    function getCallerReward(uint256 timeOfLastUpdate, uint256 defaultDelayBetweenCalls) public view returns (uint256) {

        bool nullRewards = (baseUpdateCallerReward == 0 && maxUpdateCallerReward == 0);
        if (either(timeOfLastUpdate >= now, nullRewards)) return 0;

        uint256 timeElapsed = (timeOfLastUpdate == 0) ? defaultDelayBetweenCalls : subtract(now, timeOfLastUpdate);
        if (either(timeElapsed < defaultDelayBetweenCalls, baseUpdateCallerReward == 0)) {
            return 0;
        }

        uint256 adjustedTime      = subtract(timeElapsed, defaultDelayBetweenCalls);
        uint256 maxPossibleReward = minimum(maxUpdateCallerReward, treasuryAllowance() / RAY);
        if (adjustedTime > maxRewardIncreaseDelay) {
            return maxPossibleReward;
        }

        uint256 calculatedReward = baseUpdateCallerReward;
        if (adjustedTime > 0) {
            calculatedReward = rmultiply(rpower(perSecondCallerRewardIncrease, adjustedTime, RAY), calculatedReward);
        }

        if (calculatedReward > maxPossibleReward) {
            calculatedReward = maxPossibleReward;
        }
        return calculatedReward;
    }
    function rewardCaller(address proposedFeeReceiver, uint256 reward) internal {

        if (address(treasury) == proposedFeeReceiver) return;
        if (either(address(treasury) == address(0), reward == 0)) return;

        address finalFeeReceiver = (proposedFeeReceiver == address(0)) ? msg.sender : proposedFeeReceiver;
        try treasury.pullFunds(finalFeeReceiver, treasury.systemCoin(), reward) {}
        catch(bytes memory revertReason) {
            emit FailRewardCaller(revertReason, finalFeeReceiver, reward);
        }
    }
}



abstract contract DSValueLike_1 {
    function getResultWithValidity() virtual external view returns (uint256, bool);
}
abstract contract FSMWrapperLike_1 {
    function renumerateCaller(address) virtual external;
}

contract DSM {

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

        require(authorizedAccounts[msg.sender] == 1, "DSM/account-not-authorized");
        _;
    }

    uint256 public stopped;
    modifier stoppable { require(stopped == 0, "DSM/is-stopped"); _; }


    address public priceSource;
    uint16  public updateDelay = ONE_HOUR;      // [seconds]
    uint64  public lastUpdateTime;              // [timestamp]
    uint256 public newPriceDeviation;           // [wad]

    uint16  constant ONE_HOUR = uint16(3600);   // [seconds]

    struct Feed {
        uint128 value;
        uint128 isValid;
    }

    Feed currentFeed;
    Feed nextFeed;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(bytes32 parameter, uint256 val);
    event ModifyParameters(bytes32 parameter, address val);
    event Start();
    event Stop();
    event ChangePriceSource(address priceSource);
    event ChangeDeviation(uint deviation);
    event ChangeDelay(uint16 delay);
    event RestartValue();
    event UpdateResult(uint256 newMedian, uint256 lastUpdateTime);

    constructor (address priceSource_, uint256 deviation) public {
        require(deviation > 0 && deviation < WAD, "DSM/invalid-deviation");

        authorizedAccounts[msg.sender] = 1;

        priceSource       = priceSource_;
        newPriceDeviation = deviation;

        if (priceSource != address(0)) {
          (uint256 priceFeedValue, bool hasValidValue) = getPriceSourceUpdate();
          if (hasValidValue) {
            nextFeed = Feed(uint128(uint(priceFeedValue)), 1);
            currentFeed = nextFeed;
            lastUpdateTime = latestUpdateTime(currentTime());
            emit UpdateResult(uint(currentFeed.value), lastUpdateTime);
          }
        }

        emit AddAuthorization(msg.sender);
        emit ChangePriceSource(priceSource);
        emit ChangeDeviation(deviation);
    }

    uint256 private constant WAD = 10 ** 18;

    function add(uint64 x, uint64 y) internal pure returns (uint64 z) {

        z = x + y;
        require(z >= x);
    }
    function sub(uint x, uint y) private pure returns (uint z) {

        z = x - y;
        require(z <= x, "uint-uint-sub-underflow");
    }
    function mul(uint x, uint y) private pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "uint-uint-mul-overflow");
    }
    function wmul(uint x, uint y) private pure returns (uint z) {

        z = mul(x, y) / WAD;
    }

    function stop() external isAuthorized {

        stopped = 1;
        emit Stop();
    }
    function start() external isAuthorized {

        stopped = 0;
        emit Start();
    }

    function changePriceSource(address priceSource_) external isAuthorized {

        priceSource = priceSource_;
        emit ChangePriceSource(priceSource);
    }

    function currentTime() internal view returns (uint) {

        return block.timestamp;
    }

    function latestUpdateTime(uint timestamp) internal view returns (uint64) {

        require(updateDelay != 0, "DSM/update-delay-is-zero");
        return uint64(timestamp - (timestamp % updateDelay));
    }

    function changeNextPriceDeviation(uint deviation) external isAuthorized {

        require(deviation > 0 && deviation < WAD, "DSM/invalid-deviation");
        newPriceDeviation = deviation;
        emit ChangeDeviation(deviation);
    }

    function changeDelay(uint16 delay) external isAuthorized {

        require(delay > 0, "DSM/delay-is-zero");
        updateDelay = delay;
        emit ChangeDelay(updateDelay);
    }

    function restartValue() external isAuthorized {

        currentFeed = nextFeed = Feed(0, 0);
        stopped = 1;
        emit RestartValue();
    }

    function passedDelay() public view returns (bool ok) {

        return currentTime() >= uint(add(lastUpdateTime, uint64(updateDelay)));
    }

    function updateResult() virtual external stoppable {

        require(passedDelay(), "DSM/not-passed");
        (uint256 priceFeedValue, bool hasValidValue) = getPriceSourceUpdate();
        if (hasValidValue) {
            currentFeed.isValid = nextFeed.isValid;
            currentFeed.value   = getNextBoundedPrice();
            nextFeed            = Feed(uint128(priceFeedValue), 1);
            lastUpdateTime      = latestUpdateTime(currentTime());
            emit UpdateResult(uint(currentFeed.value), lastUpdateTime);
        }
    }

    function getPriceSourceUpdate() internal view returns (uint256, bool) {

        try DSValueLike_1(priceSource).getResultWithValidity() returns (uint256 priceFeedValue, bool hasValidValue) {
          return (priceFeedValue, hasValidValue);
        }
        catch(bytes memory) {
          return (0, false);
        }
    }

    function getNextBoundedPrice() public view returns (uint128 boundedPrice) {

        boundedPrice = nextFeed.value;
        if (currentFeed.value == 0) return boundedPrice;

        uint128 lowerBound = uint128(wmul(uint(currentFeed.value), newPriceDeviation));
        uint128 upperBound = uint128(wmul(uint(currentFeed.value), sub(mul(uint(2), WAD), newPriceDeviation)));

        if (nextFeed.value < lowerBound) {
          boundedPrice = lowerBound;
        } else if (nextFeed.value > upperBound) {
          boundedPrice = upperBound;
        }
    }

    function getNextPriceLowerBound() public view returns (uint128) {

        return uint128(wmul(uint(currentFeed.value), newPriceDeviation));
    }

    function getNextPriceUpperBound() public view returns (uint128) {

        return uint128(wmul(uint(currentFeed.value), sub(mul(uint(2), WAD), newPriceDeviation)));
    }

    function getResultWithValidity() external view returns (uint256, bool) {

        return (uint(currentFeed.value), currentFeed.isValid == 1);
    }
    function getNextResultWithValidity() external view returns (uint256, bool) {

        return (nextFeed.value, nextFeed.isValid == 1);
    }
    function read() external view returns (uint256) {

        require(currentFeed.isValid == 1, "DSM/no-current-value");
        return currentFeed.value;
    }
}

contract SelfFundedDSM is DSM, NoSetupNoAuthIncreasingTreasuryReimbursement {

    constructor (address priceSource_, uint256 deviation) public DSM(priceSource_, deviation) {}

    function modifyParameters(bytes32 parameter, uint256 val) external isAuthorized {

        if (parameter == "baseUpdateCallerReward") {
          require(val < maxUpdateCallerReward, "SelfFundedDSM/invalid-base-caller-reward");
          baseUpdateCallerReward = val;
        }
        else if (parameter == "maxUpdateCallerReward") {
          require(val >= baseUpdateCallerReward, "SelfFundedDSM/invalid-max-reward");
          maxUpdateCallerReward = val;
        }
        else if (parameter == "perSecondCallerRewardIncrease") {
          require(val >= RAY, "SelfFundedDSM/invalid-reward-increase");
          perSecondCallerRewardIncrease = val;
        }
        else if (parameter == "maxRewardIncreaseDelay") {
          require(val > 0, "SelfFundedDSM/invalid-max-increase-delay");
          maxRewardIncreaseDelay = val;
        }
        else revert("SelfFundedDSM/modify-unrecognized-param");
        emit ModifyParameters(parameter, val);
    }
    function modifyParameters(bytes32 parameter, address val) external isAuthorized {

        if (parameter == "treasury") {
          require(val != address(0), "SelfFundedDSM/invalid-treasury");
          treasury = StabilityFeeTreasuryLike_2(val);
        }
        else revert("SelfFundedDSM/modify-unrecognized-param");
        emit ModifyParameters(parameter, val);
    }

    function updateResult() override external stoppable {

        require(passedDelay(), "SelfFundedDSM/not-passed");
        (uint256 priceFeedValue, bool hasValidValue) = getPriceSourceUpdate();
        if (hasValidValue) {
            uint256 callerReward = getCallerReward(lastUpdateTime, updateDelay);
            currentFeed.isValid = nextFeed.isValid;
            currentFeed.value   = getNextBoundedPrice();
            nextFeed            = Feed(uint128(priceFeedValue), 1);
            lastUpdateTime      = latestUpdateTime(currentTime());
            emit UpdateResult(uint(currentFeed.value), lastUpdateTime);
            rewardCaller(msg.sender, callerReward);
        }
    }
}

contract ExternallyFundedDSM is DSM {

    FSMWrapperLike_1 public fsmWrapper;

    event FailRenumerateCaller(address wrapper, address caller);

    constructor (address priceSource_, uint256 deviation) public DSM(priceSource_, deviation) {}

    function modifyParameters(bytes32 parameter, address val) external isAuthorized {

        if (parameter == "fsmWrapper") {
          require(val != address(0), "ExternallyFundedDSM/invalid-fsm-wrapper");
          fsmWrapper = FSMWrapperLike_1(val);
        }
        else revert("ExternallyFundedDSM/modify-unrecognized-param");
        emit ModifyParameters(parameter, val);
    }

    function updateResult() override external stoppable {

        require(passedDelay(), "ExternallyFundedDSM/not-passed");
        require(address(fsmWrapper) != address(0), "ExternallyFundedDSM/null-wrapper");
        (uint256 priceFeedValue, bool hasValidValue) = getPriceSourceUpdate();
        if (hasValidValue) {
            currentFeed.isValid = nextFeed.isValid;
            currentFeed.value   = getNextBoundedPrice();
            nextFeed            = Feed(uint128(priceFeedValue), 1);
            lastUpdateTime      = latestUpdateTime(currentTime());
            emit UpdateResult(uint(currentFeed.value), lastUpdateTime);
            try fsmWrapper.renumerateCaller(msg.sender) {}
            catch(bytes memory revertReason) {
              emit FailRenumerateCaller(address(fsmWrapper), msg.sender);
            }
        }
    }
}