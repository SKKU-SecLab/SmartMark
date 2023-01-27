
pragma solidity 0.7.1;





interface RegularIntervalOracleInterface {

  function setPrice(uint256 roundId) external returns (bool);


  function setOptimizedParameters(uint16 lambdaE4) external returns (bool);


  function updateQuantsAddress(address quantsAddress) external returns (bool);


  function getNormalizedTimeStamp(uint256 timestamp)
    external
    view
    returns (uint256);


  function getDecimals() external view returns (uint8);


  function getInterval() external view returns (uint256);


  function getLatestTimestamp() external view returns (uint256);


  function getOldestTimestamp() external view returns (uint256);


  function getVolatility() external view returns (uint256 volE8);


  function getInfo() external view returns (address chainlink, address quants);


  function getPrice() external view returns (uint256);


  function setSequentialPrices(uint256[] calldata roundIds)
    external
    returns (bool);


  function getPriceTimeOf(uint256 unixtime) external view returns (uint256);


  function getVolatilityTimeOf(uint256 unixtime)
    external
    view
    returns (uint256 volE8);


  function getCurrentParameters()
    external
    view
    returns (uint16 lambdaE4, uint16 dataNum);


  function getVolatility(uint64 untilMaturity)
    external
    view
    returns (uint64 volatilityE8);

}





interface AggregatorInterface {

  function latestAnswer() external view returns (int256);


  function latestTimestamp() external view returns (uint256);


  function latestRound() external view returns (uint256);


  function getAnswer(uint256 roundId) external view returns (int256);


  function getTimestamp(uint256 roundId) external view returns (uint256);


  function decimals() external view returns (uint8);


  function latestRoundData()
    external
    view
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    );

}







library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
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









contract RegularIntervalOracle is RegularIntervalOracleInterface {

  using SafeCast for uint16;
  using SafeCast for uint32;
  using SafeCast for uint256;
  using SafeMath for uint256;

  struct PriceData {
    uint64 priceE8;
    uint64 ewmaVolatilityE8;
  }

  int256 constant MAX_VALID_ETHPRICE = 10**14;
  uint256 constant ONE_YEAR_IN_SEC = 3600 * 24 * 365;

  AggregatorInterface internal immutable _chainlinkOracle;
  uint256 internal immutable _interval;
  uint8 internal immutable _decimals;
  uint128 internal immutable _timeCorrectionFactor;
  uint128 internal immutable _oldestTimestamp;
  uint16 internal immutable _dataNum;

  address internal _quantsAddress;
  uint256 internal _latestTimestamp;
  mapping(uint256 => PriceData) internal _regularIntervalPriceData;
  uint16 internal lambdaE4;

  event LambdaChanged(uint16 newLambda);
  event QuantsChanged(address newQuantsAddress);


  constructor(
    uint8 decimals,
    uint16 initialLambdaE4,
    uint16 initialDataNum,
    uint32 initialVolE4,
    address quantsAddress,
    address chainlinkOracleAddress,
    uint256 startTimestamp,
    uint256 interval,
    uint256 initialRoundId
  ) {
    _dataNum = initialDataNum;
    lambdaE4 = initialLambdaE4;
    _quantsAddress = quantsAddress;
    _chainlinkOracle = AggregatorInterface(chainlinkOracleAddress);
    _interval = interval;
    _decimals = decimals;
    _timeCorrectionFactor = uint128(startTimestamp % interval);
    initialRoundId = _getValidRoundIDWithAggregator(
      initialRoundId,
      startTimestamp,
      AggregatorInterface(chainlinkOracleAddress)
    );
    int256 priceE8 =
      _getPriceFromChainlinkWithAggregator(
        initialRoundId,
        AggregatorInterface(chainlinkOracleAddress)
      );
    _regularIntervalPriceData[startTimestamp] = PriceData(
      uint256(priceE8).toUint64(),
      uint64(initialVolE4)
    );
    _latestTimestamp = uint128(startTimestamp);
    _oldestTimestamp = uint128(startTimestamp);
    require(initialDataNum > 1, "Error: InitialDataNum should be more than 1");
    require(
      quantsAddress != address(0),
      "Error: Invalid initial quant address"
    );
    require(
      chainlinkOracleAddress != address(0),
      "Error: Invalid chainlink address"
    );
    require(interval != 0, "Error: Interval should be more than 0");
  }


  function setPrice(uint256 roundId) public override returns (bool) {

    _latestTimestamp += _interval;
    require(
      _latestTimestamp <= block.timestamp,
      "Error: This function should be after interval"
    );

    roundId = _getValidRoundID(roundId, _latestTimestamp);
    _setPrice(roundId, _latestTimestamp);
    return true;
  }

  function setSequentialPrices(uint256[] calldata roundIds)
    external
    override
    returns (bool)
  {

    uint256 roundIdsLength = roundIds.length;
    uint256 normalizedCurrentTimestamp =
      getNormalizedTimeStamp(block.timestamp);
    require(
      _latestTimestamp <= normalizedCurrentTimestamp,
      "Error: This function should be after interval"
    );
    if (
      (normalizedCurrentTimestamp - _latestTimestamp) / _interval <
      roundIdsLength ||
      roundIdsLength < 2
    ) {
      return false;
    }

    for (uint256 i = 0; i < roundIdsLength; i++) {
      setPrice(roundIds[i]);
    }
    return true;
  }

  function setOptimizedParameters(uint16 newLambdaE4)
    external
    override
    onlyQuants
    returns (bool)
  {

    require(
      newLambdaE4 > 9000 && newLambdaE4 < 10000,
      "new lambda is out of valid range"
    );
    require(
      (_latestTimestamp - _oldestTimestamp) / _interval > _dataNum,
      "Error: Insufficient number of data registered"
    );
    lambdaE4 = newLambdaE4;
    uint256 oldTimestamp = _latestTimestamp - _dataNum * _interval;
    uint256 pNew = _getPrice(oldTimestamp + _interval);
    uint256 updatedVol = _getVolatility(oldTimestamp);
    for (uint256 i = 0; i < _dataNum - 1; i++) {
      updatedVol = _getEwmaVolatility(oldTimestamp, pNew, updatedVol);
      oldTimestamp += _interval;
      pNew = _getPrice(oldTimestamp + _interval);
    }

    _regularIntervalPriceData[_latestTimestamp].ewmaVolatilityE8 = updatedVol
      .toUint64();
    emit LambdaChanged(newLambdaE4);
    return true;
  }

  function updateQuantsAddress(address quantsAddress)
    external
    override
    onlyQuants
    returns (bool)
  {

    _quantsAddress = quantsAddress;
    require(quantsAddress != address(0), "Error: Invalid new quant address");
    emit QuantsChanged(quantsAddress);
  }


  modifier onlyQuants() {

    require(msg.sender == _quantsAddress, "only quants address can call");
    _;
  }


  function _getPrice(uint256 unixtime) internal view returns (uint256) {

    return _regularIntervalPriceData[unixtime].priceE8;
  }

  function _getVolatility(uint256 unixtime) internal view returns (uint256) {

    return _regularIntervalPriceData[unixtime].ewmaVolatilityE8;
  }

  function _getEwmaVolatility(
    uint256 oldTimestamp,
    uint256 pNew,
    uint256 oldVolE8
  ) internal view returns (uint256 volE8) {

    uint256 pOld = _getPrice(oldTimestamp);
    uint256 rrE8 =
      pNew >= pOld
        ? ((pNew * (10**4)) / pOld - (10**4))**2
        : ((10**4) - (pNew * (10**4)) / pOld)**2;
    uint256 vol_2E16 =
      (oldVolE8**2 * lambdaE4) /
        10**4 +
        (10**4 - lambdaE4) *
        rrE8 *
        (ONE_YEAR_IN_SEC / _interval) *
        10**4;
    volE8 = _sqrt(vol_2E16);
  }

  function _sqrt(uint256 x) internal pure returns (uint256 y) {

    if (x > 3) {
      uint256 z = x / 2 + 1;
      y = x;
      while (z < y) {
        y = z;
        z = (x / z + z) / 2;
      }
    } else if (x != 0) {
      y = 1;
    }
  }

  function _getValidRoundID(uint256 hintID, uint256 targetTimeStamp)
    internal
    view
    returns (uint256 roundID)
  {

    return
      _getValidRoundIDWithAggregator(hintID, targetTimeStamp, _chainlinkOracle);
  }

  function _getValidRoundIDWithAggregator(
    uint256 hintID,
    uint256 targetTimeStamp,
    AggregatorInterface _chainlinkAggregator
  ) internal view returns (uint256 roundID) {

    if (hintID == 0) {
      hintID = _chainlinkAggregator.latestRound();
    }
    uint256 timeStampOfHintID = _chainlinkAggregator.getTimestamp(hintID);
    require(
      timeStampOfHintID >= targetTimeStamp,
      "Hint round or Latest round should be registered after target time"
    );
    require(hintID != 0, "Invalid hint ID");
    for (uint256 index = hintID - 1; index > 0; index--) {
      uint256 timestamp = _chainlinkAggregator.getTimestamp(index);
      if (timestamp != 0 && timestamp <= targetTimeStamp) {
        return index + 1;
      }
    }
    require(false, "No valid round ID found");
  }

  function _setPrice(uint256 roundId, uint256 timeStamp) internal {

    int256 priceE8 = _getPriceFromChainlink(roundId);
    require(priceE8 > 0, "Should return valid price");
    uint256 ewmaVolatilityE8 =
      _getEwmaVolatility(
        timeStamp - _interval,
        uint256(priceE8),
        _getVolatility(timeStamp - _interval)
      );
    _regularIntervalPriceData[timeStamp] = PriceData(
      uint256(priceE8).toUint64(),
      ewmaVolatilityE8.toUint64()
    );
  }

  function _getPriceFromChainlink(uint256 roundId)
    internal
    view
    returns (int256 priceE8)
  {

    return _getPriceFromChainlinkWithAggregator(roundId, _chainlinkOracle);
  }

  function _getPriceFromChainlinkWithAggregator(
    uint256 roundId,
    AggregatorInterface _chainlinkAggregator
  ) internal view returns (int256 priceE8) {

    while (true) {
      priceE8 = _chainlinkAggregator.getAnswer(roundId);
      if (priceE8 > 0 && priceE8 < MAX_VALID_ETHPRICE) {
        break;
      }
      roundId -= 1;
    }
  }


  function getNormalizedTimeStamp(uint256 timestamp)
    public
    view
    override
    returns (uint256)
  {

    return
      ((timestamp.sub(_timeCorrectionFactor)) / _interval) *
      _interval +
      _timeCorrectionFactor;
  }

  function getInfo()
    external
    view
    override
    returns (address chainlink, address quants)
  {

    return (address(_chainlinkOracle), _quantsAddress);
  }

  function getDecimals() external view override returns (uint8) {

    return _decimals;
  }

  function getInterval() external view override returns (uint256) {

    return _interval;
  }

  function getLatestTimestamp() external view override returns (uint256) {

    return _latestTimestamp;
  }

  function getOldestTimestamp() external view override returns (uint256) {

    return _oldestTimestamp;
  }

  function getPrice() external view override returns (uint256) {

    return _getPrice(_latestTimestamp);
  }

  function getCurrentParameters()
    external
    view
    override
    returns (uint16 lambda, uint16 dataNum)
  {

    return (lambdaE4, _dataNum);
  }

  function getPriceTimeOf(uint256 unixtime)
    external
    view
    override
    returns (uint256)
  {

    uint256 normalizedUnixtime = getNormalizedTimeStamp(unixtime);
    return _getPrice(normalizedUnixtime);
  }

  function _getCurrentVolatility() internal view returns (uint256 volE8) {

    uint256 latestRound = _chainlinkOracle.latestRound();
    uint256 latestVolatility = _getVolatility(_latestTimestamp);
    uint256 currentVolatility =
      _getEwmaVolatility(
        _latestTimestamp,
        uint256(_getPriceFromChainlink(latestRound)),
        _getVolatility(_latestTimestamp)
      );
    volE8 = latestVolatility >= currentVolatility
      ? latestVolatility
      : currentVolatility;
  }

  function getVolatility() external view override returns (uint256 volE8) {

    volE8 = _getCurrentVolatility();
  }

  function getVolatility(uint64)
    external
    view
    override
    returns (uint64 volatilityE8)
  {

    uint256 volE8 = _getCurrentVolatility();
    return volE8.toUint64();
  }

  function getVolatilityTimeOf(uint256 unixtime)
    external
    view
    override
    returns (uint256 volE8)
  {

    uint256 normalizedUnixtime = getNormalizedTimeStamp(unixtime);
    return _regularIntervalPriceData[normalizedUnixtime].ewmaVolatilityE8;
  }
}