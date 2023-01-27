
    


pragma solidity ^0.4.24;

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath.mul Error");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath.div Error"); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath.sub Error");
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath.add Error");

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "SafeMath.mod Error");
    return a % b;
  }
}




library SafeDecimalMath {

    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {

        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(uint x, uint y, uint precisionUnit) private pure returns (uint) {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(uint x, uint y, uint precisionUnit) private pure returns (uint) {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }
}




contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}




contract SelfDestructible is Owned {

    uint public initiationTime;
    bool public selfDestructInitiated;
    address public selfDestructBeneficiary;
    uint public constant SELFDESTRUCT_DELAY = 4 weeks;

    constructor(address _owner) public Owned(_owner) {
        require(_owner != address(0), "Owner must not be zero");
        selfDestructBeneficiary = _owner;
        emit SelfDestructBeneficiaryUpdated(_owner);
    }

    function setSelfDestructBeneficiary(address _beneficiary) external onlyOwner {

        require(_beneficiary != address(0), "Beneficiary must not be zero");
        selfDestructBeneficiary = _beneficiary;
        emit SelfDestructBeneficiaryUpdated(_beneficiary);
    }

    function initiateSelfDestruct() external onlyOwner {

        initiationTime = now;
        selfDestructInitiated = true;
        emit SelfDestructInitiated(SELFDESTRUCT_DELAY);
    }

    function terminateSelfDestruct() external onlyOwner {

        initiationTime = 0;
        selfDestructInitiated = false;
        emit SelfDestructTerminated();
    }

    function selfDestruct() external onlyOwner {

        require(selfDestructInitiated, "Self Destruct not yet initiated");
        require(initiationTime + SELFDESTRUCT_DELAY < now, "Self destruct delay not met");
        address beneficiary = selfDestructBeneficiary;
        emit SelfDestructed(beneficiary);
        selfdestruct(beneficiary);
    }

    event SelfDestructTerminated();
    event SelfDestructed(address beneficiary);
    event SelfDestructInitiated(uint selfDestructDelay);
    event SelfDestructBeneficiaryUpdated(address newBeneficiary);
}


interface AggregatorInterface {

  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy);
}





contract ExchangeRates is SelfDestructible {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    struct RateAndUpdatedTime {
        uint216 rate;
        uint40 time;
    }

    mapping(bytes32 => mapping(uint => RateAndUpdatedTime)) private _rates;

    address public oracle;

    mapping(bytes32 => AggregatorInterface) public aggregators;

    bytes32[] public aggregatorKeys;

    uint private constant ORACLE_FUTURE_LIMIT = 10 minutes;

    uint public rateStalePeriod = 3 hours;

    struct InversePricing {
        uint entryPoint;
        uint upperLimit;
        uint lowerLimit;
        bool frozen;
    }
    mapping(bytes32 => InversePricing) public inversePricing;
    bytes32[] public invertedKeys;

    mapping(bytes32 => uint) currentRoundForRate;


    constructor(
        address _owner,
        address _oracle,
        bytes32[] _currencyKeys,
        uint[] _newRates
    )
        public
        SelfDestructible(_owner)
    {
        require(_currencyKeys.length == _newRates.length, "Currency key length and rate length must match.");

        oracle = _oracle;

        _setRate("sUSD", SafeDecimalMath.unit(), now);

        internalUpdateRates(_currencyKeys, _newRates, now);
    }


    function setOracle(address _oracle) external onlyOwner {

        oracle = _oracle;
        emit OracleUpdated(oracle);
    }

    function setRateStalePeriod(uint _time) external onlyOwner {

        rateStalePeriod = _time;
        emit RateStalePeriodUpdated(rateStalePeriod);
    }


    function updateRates(bytes32[] currencyKeys, uint[] newRates, uint timeSent) external onlyOracle returns (bool) {

        return internalUpdateRates(currencyKeys, newRates, timeSent);
    }

    function deleteRate(bytes32 currencyKey) external onlyOracle {

        require(getRate(currencyKey) > 0, "Rate is zero");

        delete _rates[currencyKey][currentRoundForRate[currencyKey]];

        currentRoundForRate[currencyKey]--;

        emit RateDeleted(currencyKey);
    }

    function setInversePricing(
        bytes32 currencyKey,
        uint entryPoint,
        uint upperLimit,
        uint lowerLimit,
        bool freeze,
        bool freezeAtUpperLimit
    ) external onlyOwner {

        require(entryPoint > 0, "entryPoint must be above 0");
        require(lowerLimit > 0, "lowerLimit must be above 0");
        require(upperLimit > entryPoint, "upperLimit must be above the entryPoint");
        require(upperLimit < entryPoint.mul(2), "upperLimit must be less than double entryPoint");
        require(lowerLimit < entryPoint, "lowerLimit must be below the entryPoint");

        if (inversePricing[currencyKey].entryPoint <= 0) {
            invertedKeys.push(currencyKey);
        }
        inversePricing[currencyKey].entryPoint = entryPoint;
        inversePricing[currencyKey].upperLimit = upperLimit;
        inversePricing[currencyKey].lowerLimit = lowerLimit;
        inversePricing[currencyKey].frozen = freeze;

        emit InversePriceConfigured(currencyKey, entryPoint, upperLimit, lowerLimit);

        if (freeze) {
            emit InversePriceFrozen(currencyKey);

            _setRate(currencyKey, freezeAtUpperLimit ? upperLimit : lowerLimit, now);
        }
    }

    function removeInversePricing(bytes32 currencyKey) external onlyOwner {

        require(inversePricing[currencyKey].entryPoint > 0, "No inverted price exists");

        inversePricing[currencyKey].entryPoint = 0;
        inversePricing[currencyKey].upperLimit = 0;
        inversePricing[currencyKey].lowerLimit = 0;
        inversePricing[currencyKey].frozen = false;

        bool wasRemoved = removeFromArray(currencyKey, invertedKeys);

        if (wasRemoved) {
            emit InversePriceConfigured(currencyKey, 0, 0, 0);
        }
    }

    function addAggregator(bytes32 currencyKey, address aggregatorAddress) external onlyOwner {

        AggregatorInterface aggregator = AggregatorInterface(aggregatorAddress);
        require(aggregator.latestTimestamp() >= 0, "Given Aggregator is invalid");
        if (aggregators[currencyKey] == address(0)) {
            aggregatorKeys.push(currencyKey);
        }
        aggregators[currencyKey] = aggregator;
        emit AggregatorAdded(currencyKey, aggregator);
    }

    function removeAggregator(bytes32 currencyKey) external onlyOwner {

        address aggregator = aggregators[currencyKey];
        require(aggregator != address(0), "No aggregator exists for key");
        delete aggregators[currencyKey];

        bool wasRemoved = removeFromArray(currencyKey, aggregatorKeys);

        if (wasRemoved) {
            emit AggregatorRemoved(currencyKey, aggregator);
        }
    }

    function getLastRoundIdBeforeElapsedSecs(
        bytes32 currencyKey,
        uint startingRoundId,
        uint startingTimestamp,
        uint timediff
    ) external view returns (uint) {

        uint roundId = startingRoundId;
        uint nextTimestamp = 0;
        while (true) {
            (, nextTimestamp) = getRateAndTimestampAtRound(currencyKey, roundId + 1);
            if (nextTimestamp == 0 || nextTimestamp > startingTimestamp + timediff) {
                return roundId;
            }
            roundId++;
        }
        return roundId;
    }

    function getCurrentRoundId(bytes32 currencyKey) external view returns (uint) {

        if (aggregators[currencyKey] != address(0)) {
            AggregatorInterface aggregator = aggregators[currencyKey];
            return aggregator.latestRound();
        } else {
            return currentRoundForRate[currencyKey];
        }
    }

    function effectiveValueAtRound(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        uint roundIdForSrc,
        uint roundIdForDest
    ) external view rateNotStale(sourceCurrencyKey) rateNotStale(destinationCurrencyKey) returns (uint) {

        if (sourceCurrencyKey == destinationCurrencyKey) return sourceAmount;

        (uint srcRate, ) = getRateAndTimestampAtRound(sourceCurrencyKey, roundIdForSrc);
        (uint destRate, ) = getRateAndTimestampAtRound(destinationCurrencyKey, roundIdForDest);
        return sourceAmount.multiplyDecimalRound(srcRate).divideDecimalRound(destRate);
    }

    function rateAndTimestampAtRound(bytes32 currencyKey, uint roundId) external view returns (uint rate, uint time) {

        return getRateAndTimestampAtRound(currencyKey, roundId);
    }


    function lastRateUpdateTimes(bytes32 currencyKey) public view returns (uint256) {

        return getRateAndUpdatedTime(currencyKey).time;
    }

    function lastRateUpdateTimesForCurrencies(bytes32[] currencyKeys) public view returns (uint[]) {

        uint[] memory lastUpdateTimes = new uint[](currencyKeys.length);

        for (uint i = 0; i < currencyKeys.length; i++) {
            lastUpdateTimes[i] = lastRateUpdateTimes(currencyKeys[i]);
        }

        return lastUpdateTimes;
    }

    function effectiveValue(bytes32 sourceCurrencyKey, uint sourceAmount, bytes32 destinationCurrencyKey)
        public
        view
        rateNotStale(sourceCurrencyKey)
        rateNotStale(destinationCurrencyKey)
        returns (uint)
    {

        if (sourceCurrencyKey == destinationCurrencyKey) return sourceAmount;

        return
            sourceAmount.multiplyDecimalRound(getRate(sourceCurrencyKey)).divideDecimalRound(
                getRate(destinationCurrencyKey)
            );
    }

    function rateForCurrency(bytes32 currencyKey) external view returns (uint) {

        return getRateAndUpdatedTime(currencyKey).rate;
    }

    function ratesForCurrencies(bytes32[] currencyKeys) external view returns (uint[]) {

        uint[] memory _localRates = new uint[](currencyKeys.length);

        for (uint i = 0; i < currencyKeys.length; i++) {
            _localRates[i] = getRate(currencyKeys[i]);
        }

        return _localRates;
    }

    function ratesAndStaleForCurrencies(bytes32[] currencyKeys) external view returns (uint[], bool) {

        uint[] memory _localRates = new uint[](currencyKeys.length);

        bool anyRateStale = false;
        uint period = rateStalePeriod;
        for (uint i = 0; i < currencyKeys.length; i++) {
            RateAndUpdatedTime memory rateAndUpdateTime = getRateAndUpdatedTime(currencyKeys[i]);
            _localRates[i] = uint256(rateAndUpdateTime.rate);
            if (!anyRateStale) {
                anyRateStale = (currencyKeys[i] != "sUSD" && uint256(rateAndUpdateTime.time).add(period) < now);
            }
        }

        return (_localRates, anyRateStale);
    }

    function rateIsStale(bytes32 currencyKey) public view returns (bool) {

        if (currencyKey == "sUSD") return false;

        return lastRateUpdateTimes(currencyKey).add(rateStalePeriod) < now;
    }

    function rateIsFrozen(bytes32 currencyKey) external view returns (bool) {

        return inversePricing[currencyKey].frozen;
    }

    function anyRateIsStale(bytes32[] currencyKeys) external view returns (bool) {

        uint256 i = 0;

        while (i < currencyKeys.length) {
            if (currencyKeys[i] != "sUSD" && lastRateUpdateTimes(currencyKeys[i]).add(rateStalePeriod) < now) {
                return true;
            }
            i += 1;
        }

        return false;
    }


    function _setRate(bytes32 currencyKey, uint256 rate, uint256 time) internal {

        currentRoundForRate[currencyKey]++;

        _rates[currencyKey][currentRoundForRate[currencyKey]] = RateAndUpdatedTime({
            rate: uint216(rate),
            time: uint40(time)
        });
    }

    function internalUpdateRates(bytes32[] currencyKeys, uint[] newRates, uint timeSent) internal returns (bool) {

        require(currencyKeys.length == newRates.length, "Currency key array length must match rates array length.");
        require(timeSent < (now + ORACLE_FUTURE_LIMIT), "Time is too far into the future");

        for (uint i = 0; i < currencyKeys.length; i++) {
            bytes32 currencyKey = currencyKeys[i];

            require(newRates[i] != 0, "Zero is not a valid rate, please call deleteRate instead.");
            require(currencyKey != "sUSD", "Rate of sUSD cannot be updated, it's always UNIT.");

            if (timeSent < lastRateUpdateTimes(currencyKey)) {
                continue;
            }

            newRates[i] = rateOrInverted(currencyKey, newRates[i]);

            _setRate(currencyKey, newRates[i], timeSent);
        }

        emit RatesUpdated(currencyKeys, newRates);

        return true;
    }

    function rateOrInverted(bytes32 currencyKey, uint rate) internal returns (uint) {

        InversePricing storage inverse = inversePricing[currencyKey];
        if (inverse.entryPoint <= 0) {
            return rate;
        }

        uint newInverseRate = getRate(currencyKey);

        if (!inverse.frozen) {
            uint doubleEntryPoint = inverse.entryPoint.mul(2);
            if (doubleEntryPoint <= rate) {
                newInverseRate = 0;
            } else {
                newInverseRate = doubleEntryPoint.sub(rate);
            }

            if (newInverseRate >= inverse.upperLimit) {
                newInverseRate = inverse.upperLimit;
            } else if (newInverseRate <= inverse.lowerLimit) {
                newInverseRate = inverse.lowerLimit;
            }

            if (newInverseRate == inverse.upperLimit || newInverseRate == inverse.lowerLimit) {
                inverse.frozen = true;
                emit InversePriceFrozen(currencyKey);
            }
        }

        return newInverseRate;
    }

    function getRateAndUpdatedTime(bytes32 currencyKey) internal view returns (RateAndUpdatedTime) {

        if (aggregators[currencyKey] != address(0)) {
            return
                RateAndUpdatedTime({
                    rate: uint216(aggregators[currencyKey].latestAnswer() * 1e10),
                    time: uint40(aggregators[currencyKey].latestTimestamp())
                });
        } else {
            return _rates[currencyKey][currentRoundForRate[currencyKey]];
        }
    }

    function removeFromArray(bytes32 entry, bytes32[] storage array) internal returns (bool) {

        for (uint i = 0; i < array.length; i++) {
            if (array[i] == entry) {
                delete array[i];

                array[i] = array[array.length - 1];

                array.length--;

                return true;
            }
        }
        return false;
    }

    function getRateAndTimestampAtRound(bytes32 currencyKey, uint roundId) internal view returns (uint rate, uint time) {

        if (aggregators[currencyKey] != address(0)) {
            AggregatorInterface aggregator = aggregators[currencyKey];
            return (uint(aggregator.getAnswer(roundId) * 1e10), aggregator.getTimestamp(roundId));
        } else {
            RateAndUpdatedTime storage update = _rates[currencyKey][roundId];
            return (update.rate, update.time);
        }
    }

    function getRate(bytes32 currencyKey) internal view returns (uint256) {

        return getRateAndUpdatedTime(currencyKey).rate;
    }


    modifier rateNotStale(bytes32 currencyKey) {

        require(!rateIsStale(currencyKey), "Rate stale or nonexistant currency");
        _;
    }

    modifier onlyOracle {

        require(msg.sender == oracle, "Only the oracle can perform this action");
        _;
    }


    event OracleUpdated(address newOracle);
    event RateStalePeriodUpdated(uint rateStalePeriod);
    event RatesUpdated(bytes32[] currencyKeys, uint[] newRates);
    event RateDeleted(bytes32 currencyKey);
    event InversePriceConfigured(bytes32 currencyKey, uint entryPoint, uint upperLimit, uint lowerLimit);
    event InversePriceFrozen(bytes32 currencyKey);
    event AggregatorAdded(bytes32 currencyKey, address aggregator);
    event AggregatorRemoved(bytes32 currencyKey, address aggregator);
}