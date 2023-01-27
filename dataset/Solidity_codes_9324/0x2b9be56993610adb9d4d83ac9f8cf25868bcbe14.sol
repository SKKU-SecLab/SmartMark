
pragma solidity 0.6.7;

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

abstract contract OracleLike {
    function getResultWithValidity() virtual external view returns (uint256, bool);
}

abstract contract PIDCalculator {
    function computeRate(uint256, uint256, uint256) virtual external returns (uint256);
    function rt(uint256, uint256, uint256) virtual external view returns (uint256);
    function pscl() virtual external view returns (uint256);
    function tlv() virtual external view returns (uint256);
}

contract PIRateSetter is GebMath {

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

        require(authorizedAccounts[msg.sender] == 1, "PIRateSetter/account-not-authorized");
        _;
    }

    uint256 public lastUpdateTime;                  // [timestamp]
    uint256 public updateRateDelay;                 // [seconds]
    uint256 public defaultLeak;                     // [0 or 1]

    OracleLike                public orcl;
    OracleRelayerLike         public oracleRelayer;
    SetterRelayer             public setterRelayer;
    PIDCalculator             public pidCalculator;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(
      bytes32 parameter,
      address addr
    );
    event ModifyParameters(
      bytes32 parameter,
      uint256 val
    );
    event UpdateRedemptionRate(
        uint marketPrice,
        uint redemptionPrice,
        uint redemptionRate
    );
    event FailUpdateRedemptionRate(
        uint marketPrice,
        uint redemptionPrice,
        uint redemptionRate,
        bytes reason
    );

    constructor(
      address oracleRelayer_,
      address setterRelayer_,
      address orcl_,
      address pidCalculator_,
      uint256 updateRateDelay_
    ) public {
        require(oracleRelayer_ != address(0), "PIRateSetter/null-oracle-relayer");
        require(setterRelayer_ != address(0), "PIRateSetter/null-setter-relayer");
        require(orcl_ != address(0), "PIRateSetter/null-orcl");
        require(pidCalculator_ != address(0), "PIRateSetter/null-calculator");

        authorizedAccounts[msg.sender] = 1;
        defaultLeak                    = 1;

        oracleRelayer    = OracleRelayerLike(oracleRelayer_);
        setterRelayer    = SetterRelayer(setterRelayer_);
        orcl             = OracleLike(orcl_);
        pidCalculator    = PIDCalculator(pidCalculator_);

        updateRateDelay  = updateRateDelay_;

        emit AddAuthorization(msg.sender);
        emit ModifyParameters("orcl", orcl_);
        emit ModifyParameters("oracleRelayer", oracleRelayer_);
        emit ModifyParameters("setterRelayer", setterRelayer_);
        emit ModifyParameters("pidCalculator", pidCalculator_);
        emit ModifyParameters("updateRateDelay", updateRateDelay_);
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    function modifyParameters(bytes32 parameter, address addr) external isAuthorized {

        require(addr != address(0), "PIRateSetter/null-addr");
        if (parameter == "orcl") orcl = OracleLike(addr);
        else if (parameter == "oracleRelayer") oracleRelayer = OracleRelayerLike(addr);
        else if (parameter == "setterRelayer") setterRelayer = SetterRelayer(addr);
        else if (parameter == "pidCalculator") {
          pidCalculator = PIDCalculator(addr);
        }
        else revert("PIRateSetter/modify-unrecognized-param");
        emit ModifyParameters(
          parameter,
          addr
        );
    }
    function modifyParameters(bytes32 parameter, uint256 val) external isAuthorized {

        if (parameter == "updateRateDelay") {
          require(val > 0, "PIRateSetter/null-update-delay");
          updateRateDelay = val;
        }
        else if (parameter == "defaultLeak") {
          require(val <= 1, "PIRateSetter/invalid-default-leak");
          defaultLeak = val;
        }
        else revert("PIRateSetter/modify-unrecognized-param");
        emit ModifyParameters(
          parameter,
          val
        );
    }

    function updateRate(address feeReceiver) external {

        require(feeReceiver != address(0), "PIRateSetter/null-fee-receiver");
        require(either(subtract(now, lastUpdateTime) >= updateRateDelay, lastUpdateTime == 0), "PIRateSetter/wait-more");
        (uint256 marketPrice, bool hasValidValue) = orcl.getResultWithValidity();
        require(hasValidValue, "PIRateSetter/invalid-oracle-value");
        require(marketPrice > 0, "PIRateSetter/null-price");
        uint redemptionPrice = oracleRelayer.redemptionPrice();
        uint256 iapcr      = (defaultLeak == 1) ? RAY : rpower(pidCalculator.pscl(), pidCalculator.tlv(), RAY);
        uint256 calculated = pidCalculator.computeRate(
            marketPrice,
            redemptionPrice,
            iapcr
        );
        lastUpdateTime = now;
        try setterRelayer.relayRate(calculated, feeReceiver) {
          emit UpdateRedemptionRate(
            ray(marketPrice),
            redemptionPrice,
            calculated
          );
        }
        catch(bytes memory revertReason) {
          emit FailUpdateRedemptionRate(
            ray(marketPrice),
            redemptionPrice,
            calculated,
            revertReason
          );
        }
    }

    function getMarketPrice() external view returns (uint256) {

        (uint256 marketPrice, ) = orcl.getResultWithValidity();
        return marketPrice;
    }
    function getRedemptionAndMarketPrices() external returns (uint256 marketPrice, uint256 redemptionPrice) {

        (marketPrice, ) = orcl.getResultWithValidity();
        redemptionPrice = oracleRelayer.redemptionPrice();
    }
}


abstract contract StabilityFeeTreasuryLike {
    function getAllowance(address) virtual external view returns (uint, uint);
    function systemCoin() virtual external view returns (address);
    function pullFunds(address, address, uint) virtual external;
    function setTotalAllowance(address, uint256) external virtual;
    function setPerBlockAllowance(address, uint256) external virtual;
}

contract IncreasingTreasuryReimbursement is GebMath {

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

        require(authorizedAccounts[msg.sender] == 1, "IncreasingTreasuryReimbursement/account-not-authorized");
        _;
    }

    uint256 public baseUpdateCallerReward;          // [wad]
    uint256 public maxUpdateCallerReward;           // [wad]
    uint256 public maxRewardIncreaseDelay;          // [seconds]
    uint256 public perSecondCallerRewardIncrease;   // [ray]

    StabilityFeeTreasuryLike  public treasury;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(
      bytes32 parameter,
      address addr
    );
    event ModifyParameters(
      bytes32 parameter,
      uint256 val
    );
    event FailRewardCaller(bytes revertReason, address feeReceiver, uint256 amount);

    constructor(
      address treasury_,
      uint256 baseUpdateCallerReward_,
      uint256 maxUpdateCallerReward_,
      uint256 perSecondCallerRewardIncrease_
    ) public {
        if (address(treasury_) != address(0)) {
          require(StabilityFeeTreasuryLike(treasury_).systemCoin() != address(0), "IncreasingTreasuryReimbursement/treasury-coin-not-set");
        }
        require(maxUpdateCallerReward_ >= baseUpdateCallerReward_, "IncreasingTreasuryReimbursement/invalid-max-caller-reward");
        require(perSecondCallerRewardIncrease_ >= RAY, "IncreasingTreasuryReimbursement/invalid-per-second-reward-increase");
        authorizedAccounts[msg.sender] = 1;

        treasury                        = StabilityFeeTreasuryLike(treasury_);
        baseUpdateCallerReward          = baseUpdateCallerReward_;
        maxUpdateCallerReward           = maxUpdateCallerReward_;
        perSecondCallerRewardIncrease   = perSecondCallerRewardIncrease_;
        maxRewardIncreaseDelay          = uint(-1);

        emit AddAuthorization(msg.sender);
        emit ModifyParameters("treasury", treasury_);
        emit ModifyParameters("baseUpdateCallerReward", baseUpdateCallerReward);
        emit ModifyParameters("maxUpdateCallerReward", maxUpdateCallerReward);
        emit ModifyParameters("perSecondCallerRewardIncrease", perSecondCallerRewardIncrease);
    }

    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
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

abstract contract OracleRelayerLike {
    function redemptionPrice() virtual external returns (uint256);
    function modifyParameters(bytes32,uint256) virtual external;
}

contract SetterRelayer is IncreasingTreasuryReimbursement {

    event RelayRate(address setter, uint256 redemptionRate);

    uint256           public lastUpdateTime;                      // [timestamp]
    uint256           public relayDelay;                          // [seconds]
    address           public setter;
    OracleRelayerLike public oracleRelayer;

    constructor(
      address oracleRelayer_,
      address treasury_,
      uint256 baseUpdateCallerReward_,
      uint256 maxUpdateCallerReward_,
      uint256 perSecondCallerRewardIncrease_,
      uint256 relayDelay_
    ) public IncreasingTreasuryReimbursement(treasury_, baseUpdateCallerReward_, maxUpdateCallerReward_, perSecondCallerRewardIncrease_) {
        relayDelay    = relayDelay_;
        oracleRelayer = OracleRelayerLike(oracleRelayer_);

        emit ModifyParameters("relayDelay", relayDelay_);
    }

    function modifyParameters(bytes32 parameter, address addr) external isAuthorized {

        require(addr != address(0), "SetterRelayer/null-addr");
        if (parameter == "setter") {
          setter = addr;
        }
        else if (parameter == "treasury") {
          require(StabilityFeeTreasuryLike(addr).systemCoin() != address(0), "SetterRelayer/treasury-coin-not-set");
          treasury = StabilityFeeTreasuryLike(addr);
        }
        else revert("SetterRelayer/modify-unrecognized-param");
        emit ModifyParameters(
          parameter,
          addr
        );
    }
    function modifyParameters(bytes32 parameter, uint256 val) external isAuthorized {

        if (parameter == "baseUpdateCallerReward") {
          require(val <= maxUpdateCallerReward, "SetterRelayer/invalid-base-caller-reward");
          baseUpdateCallerReward = val;
        }
        else if (parameter == "maxUpdateCallerReward") {
          require(val >= baseUpdateCallerReward, "SetterRelayer/invalid-max-caller-reward");
          maxUpdateCallerReward = val;
        }
        else if (parameter == "perSecondCallerRewardIncrease") {
          require(val >= RAY, "SetterRelayer/invalid-caller-reward-increase");
          perSecondCallerRewardIncrease = val;
        }
        else if (parameter == "maxRewardIncreaseDelay") {
          require(val > 0, "SetterRelayer/invalid-max-increase-delay");
          maxRewardIncreaseDelay = val;
        }
        else if (parameter == "relayDelay") {
          relayDelay = val;
        }
        else revert("SetterRelayer/modify-unrecognized-param");
        emit ModifyParameters(
          parameter,
          val
        );
    }

    function relayRate(uint256 redemptionRate, address feeReceiver) external {

        require(setter == msg.sender, "SetterRelayer/invalid-caller");
        require(feeReceiver != address(0), "SetterRelayer/null-fee-receiver");
        require(feeReceiver != setter, "SetterRelayer/setter-cannot-receive-fees");
        require(either(subtract(now, lastUpdateTime) >= relayDelay, lastUpdateTime == 0), "SetterRelayer/wait-more");
        uint256 callerReward = getCallerReward(lastUpdateTime, relayDelay);
        lastUpdateTime = now;
        oracleRelayer.redemptionPrice();
        oracleRelayer.modifyParameters("redemptionRate", redemptionRate);
        emit RelayRate(setter, redemptionRate);
        rewardCaller(feeReceiver, callerReward);
    }
}


contract SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function multiply(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function divide(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function subtract(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function addition(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}


contract SafeMath {

    function addition(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function subtract(uint256 a, uint256 b) internal pure returns (uint256) {

        return subtract(a, b, "SafeMath: subtraction overflow");
    }

    function subtract(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function multiply(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function divide(uint256 a, uint256 b) internal pure returns (uint256) {

        return divide(a, b, "SafeMath: division by zero");
    }

    function divide(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

contract PRawPerSecondCalculator is SafeMath, SignedSafeMath {

    mapping (address => uint) public authorities;
    function addAuthority(address account) external isAuthority { authorities[account] = 1; }

    function removeAuthority(address account) external isAuthority { authorities[account] = 0; }

    modifier isAuthority {

        require(authorities[msg.sender] == 1, "PRawPerSecondCalculator/not-an-authority");
        _;
    }

    mapping (address => uint) public readers;
    function addReader(address account) external isAuthority { readers[account] = 1; }

    function removeReader(address account) external isAuthority { readers[account] = 0; }

    modifier isReader {

        require(either(allReaderToggle == 1, readers[msg.sender] == 1), "PRawPerSecondCalculator/not-a-reader");
        _;
    }

    int256  public Kp;                               // [EIGHTEEN_DECIMAL_NUMBER]

    uint256 public   allReaderToggle;
    uint256 internal noiseBarrier;                   // [EIGHTEEN_DECIMAL_NUMBER]
    uint256 internal defaultRedemptionRate;          // [TWENTY_SEVEN_DECIMAL_NUMBER]
    uint256 internal feedbackOutputUpperBound;       // [TWENTY_SEVEN_DECIMAL_NUMBER]
    int256  internal feedbackOutputLowerBound;       // [TWENTY_SEVEN_DECIMAL_NUMBER]
    uint256 internal periodSize;                     // [seconds]

    uint256 internal lastUpdateTime;                       // [timestamp]
    uint256 constant internal defaultGlobalTimeline = 1;

    address public seedProposer;

    uint256 internal constant NEGATIVE_RATE_LIMIT         = TWENTY_SEVEN_DECIMAL_NUMBER - 1;
    uint256 internal constant TWENTY_SEVEN_DECIMAL_NUMBER = 10 ** 27;
    uint256 internal constant EIGHTEEN_DECIMAL_NUMBER     = 10 ** 18;

    constructor(
        int256 Kp_,
        uint256 periodSize_,
        uint256 noiseBarrier_,
        uint256 feedbackOutputUpperBound_,
        int256  feedbackOutputLowerBound_
    ) public {
        defaultRedemptionRate      = TWENTY_SEVEN_DECIMAL_NUMBER;

        require(both(feedbackOutputUpperBound_ < subtract(subtract(uint(-1), defaultRedemptionRate), 1), feedbackOutputUpperBound_ > 0), "PRawPerSecondCalculator/invalid-foub");
        require(both(feedbackOutputLowerBound_ < 0, feedbackOutputLowerBound_ >= -int(NEGATIVE_RATE_LIMIT)), "PRawPerSecondCalculator/invalid-folb");
        require(periodSize_ > 0, "PRawPerSecondCalculator/invalid-ips");
        require(both(noiseBarrier_ > 0, noiseBarrier_ <= EIGHTEEN_DECIMAL_NUMBER), "PRawPerSecondCalculator/invalid-nb");
        require(both(Kp_ >= -int(EIGHTEEN_DECIMAL_NUMBER), Kp_ <= int(EIGHTEEN_DECIMAL_NUMBER)), "PRawPerSecondCalculator/invalid-sg");

        authorities[msg.sender]   = 1;
        readers[msg.sender]       = 1;

        feedbackOutputUpperBound  = feedbackOutputUpperBound_;
        feedbackOutputLowerBound  = feedbackOutputLowerBound_;
        periodSize                = periodSize_;
        Kp                        = Kp_;
        noiseBarrier              = noiseBarrier_;
    }

    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }
    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    function modifyParameters(bytes32 parameter, address addr) external isAuthority {

        if (parameter == "seedProposer") {
          readers[seedProposer] = 0;
          seedProposer = addr;
          readers[seedProposer] = 1;
        }
        else revert("PRawPerSecondCalculator/modify-unrecognized-param");
    }
    function modifyParameters(bytes32 parameter, uint256 val) external isAuthority {

        if (parameter == "nb") {
          require(both(val > 0, val <= EIGHTEEN_DECIMAL_NUMBER), "PRawPerSecondCalculator/invalid-nb");
          noiseBarrier = val;
        }
        else if (parameter == "ps") {
          require(val > 0, "PRawPerSecondCalculator/null-ps");
          periodSize = val;
        }
        else if (parameter == "foub") {
          require(both(val < subtract(subtract(uint(-1), defaultRedemptionRate), 1), val > 0), "PRawPerSecondCalculator/invalid-foub");
          feedbackOutputUpperBound = val;
        }
        else if (parameter == "allReaderToggle") {
          allReaderToggle = val;
        }
        else revert("PRawPerSecondCalculator/modify-unrecognized-param");
    }
    function modifyParameters(bytes32 parameter, int256 val) external isAuthority {

        if (parameter == "folb") {
          require(both(val < 0, val >= -int(NEGATIVE_RATE_LIMIT)), "PRawPerSecondCalculator/invalid-folb");
          feedbackOutputLowerBound = val;
        }
        else if (parameter == "sg") {
          require(both(val >= -int(EIGHTEEN_DECIMAL_NUMBER), val <= int(EIGHTEEN_DECIMAL_NUMBER)), "PRawPerSecondCalculator/invalid-sg");
          Kp = val;
        }
        else revert("PRawPerSecondCalculator/modify-unrecognized-param");
    }

    function absolute(int x) internal pure returns (uint z) {

        z = (x < 0) ? uint(-x) : uint(x);
    }

    function getBoundedRedemptionRate(int pOutput) public isReader view returns (uint256, uint256) {

        int  boundedPOutput = pOutput;
        uint newRedemptionRate;

        if (pOutput < feedbackOutputLowerBound) {
          boundedPOutput = feedbackOutputLowerBound;
        } else if (pOutput > int(feedbackOutputUpperBound)) {
          boundedPOutput = int(feedbackOutputUpperBound);
        }

        bool negativeOutputExceedsHundred = (boundedPOutput < 0 && -boundedPOutput >= int(defaultRedemptionRate));

        if (negativeOutputExceedsHundred) {
          newRedemptionRate = NEGATIVE_RATE_LIMIT;
        } else {
          if (boundedPOutput < 0 && boundedPOutput <= -int(NEGATIVE_RATE_LIMIT)) {
            newRedemptionRate = uint(addition(int(defaultRedemptionRate), -int(NEGATIVE_RATE_LIMIT)));
          } else {
            newRedemptionRate = uint(addition(int(defaultRedemptionRate), boundedPOutput));
          }
        }

        return (newRedemptionRate, defaultGlobalTimeline);
    }
    function breaksNoiseBarrier(uint proportionalResult, uint redemptionPrice) public isReader view returns (bool) {

        uint deltaNoise = subtract(multiply(uint(2), EIGHTEEN_DECIMAL_NUMBER), noiseBarrier);
        return proportionalResult >= subtract(divide(multiply(redemptionPrice, deltaNoise), EIGHTEEN_DECIMAL_NUMBER), redemptionPrice);
    }

    function computeRate(
      uint marketPrice,
      uint redemptionPrice,
      uint
    ) external returns (uint256) {

        require(seedProposer == msg.sender, "PRawPerSecondCalculator/invalid-msg-sender");
        require(subtract(now, lastUpdateTime) >= periodSize || lastUpdateTime == 0, "PRawPerSecondCalculator/wait-more");
        int256 proportionalTerm = subtract(int(redemptionPrice), multiply(int(marketPrice), int(10**9)));
        lastUpdateTime = now;
        proportionalTerm = multiply(proportionalTerm, int(Kp)) / int(EIGHTEEN_DECIMAL_NUMBER);
        if (
          breaksNoiseBarrier(absolute(proportionalTerm), redemptionPrice) &&
          proportionalTerm != 0
        ) {
          (uint newRedemptionRate, ) = getBoundedRedemptionRate(proportionalTerm);
          return newRedemptionRate;
        } else {
          return TWENTY_SEVEN_DECIMAL_NUMBER;
        }
    }
    function getNextRedemptionRate(uint marketPrice, uint redemptionPrice, uint)
      public isReader view returns (uint256, int256, uint256) {

        int256 rawProportionalTerm = subtract(int(redemptionPrice), multiply(int(marketPrice), int(10**9)));
        int256 gainProportionalTerm = multiply(rawProportionalTerm, int(Kp)) / int(EIGHTEEN_DECIMAL_NUMBER);
        if (
          breaksNoiseBarrier(absolute(gainProportionalTerm), redemptionPrice) &&
          gainProportionalTerm != 0
        ) {
          (uint newRedemptionRate, uint rateTimeline) = getBoundedRedemptionRate(gainProportionalTerm);
          return (newRedemptionRate, rawProportionalTerm, rateTimeline);
        } else {
          return (TWENTY_SEVEN_DECIMAL_NUMBER, rawProportionalTerm, defaultGlobalTimeline);
        }
    }

    function rt(uint marketPrice, uint redemptionPrice, uint) external isReader view returns (uint256) {

        (, , uint rateTimeline) = getNextRedemptionRate(marketPrice, redemptionPrice, 0);
        return rateTimeline;
    }
    function sg() external isReader view returns (int256) {

        return Kp;
    }
    function nb() external isReader view returns (uint256) {

        return noiseBarrier;
    }
    function drr() external isReader view returns (uint256) {

        return defaultRedemptionRate;
    }
    function foub() external isReader view returns (uint256) {

        return feedbackOutputUpperBound;
    }
    function folb() external isReader view returns (int256) {

        return feedbackOutputLowerBound;
    }
    function ps() external isReader view returns (uint256) {

        return periodSize;
    }
    function pscl() external isReader view returns (uint256) {

        return TWENTY_SEVEN_DECIMAL_NUMBER;
    }
    function lut() external isReader view returns (uint256) {

        return lastUpdateTime;
    }
    function dgt() external isReader view returns (uint256) {

        return defaultGlobalTimeline;
    }
    function adat() external isReader view returns (uint256) {

        uint elapsed = subtract(now, lastUpdateTime);
        if (elapsed < periodSize) {
          return 0;
        }
        return subtract(elapsed, periodSize);
    }
    function tlv() external isReader view returns (uint256) {

        uint elapsed = (lastUpdateTime == 0) ? 0 : subtract(now, lastUpdateTime);
        return elapsed;
    }
}


abstract contract OldRateSetterLike is PIRateSetter {
    function treasury() public virtual returns (address);
}

abstract contract Setter {
    function addAuthorization(address) external virtual;
    function removeAuthorization(address) external virtual;
    function modifyParameters(bytes32,bytes32,address) external virtual;
}

contract DeployPIRateSetter {

    uint constant RAY = 10 ** 27;

    function execute(address oldRateSetter) public returns (address, address, address) {

        OldRateSetterLike oldSetter       = OldRateSetterLike(oldRateSetter);
        StabilityFeeTreasuryLike treasury = StabilityFeeTreasuryLike(oldSetter.treasury());

        PRawPerSecondCalculator calculator = new PRawPerSecondCalculator(
            5 * 10**8,       // sg
            21600,           // periodSize
            10**18,          // noiseBarrier
            10**45,          // feedbackUpperBound
            -int((10**27)-1) // feedbackLowerBound
        );

        SetterRelayer relayer = new SetterRelayer(
            address(oldSetter.oracleRelayer()),
            address(oldSetter.treasury()),
            0.0001 ether,  // baseUpdateCallerReward
            0.0001 ether,  // maxUpdateCallerReward
            1 * RAY,       // perSecondCallerRewardIncrease
            21600          // relayDelay
        );

        relayer.modifyParameters("maxRewardIncreaseDelay", 10800);

        PIRateSetter rateSetter = new PIRateSetter(
            address(oldSetter.oracleRelayer()),
            address(relayer),
            address(oldSetter.orcl()),
            address(calculator),
            21600 // updateRateDelay
        );

        rateSetter.modifyParameters("defaultLeak", 1);

        treasury.setTotalAllowance(address(oldSetter), 0);
        treasury.setPerBlockAllowance(address(oldSetter), 0);

        treasury.setTotalAllowance(address(relayer), uint(-1));
        treasury.setPerBlockAllowance(address(relayer), 0.0001 ether * RAY);

        calculator.modifyParameters("seedProposer", address(rateSetter));
        relayer.modifyParameters("setter", address(rateSetter));

        return (address(calculator), address(rateSetter), address(relayer));
    }
}