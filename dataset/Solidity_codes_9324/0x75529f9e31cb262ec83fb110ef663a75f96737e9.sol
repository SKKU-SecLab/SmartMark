pragma solidity ^0.8.0;

interface AggregatorV3Interface {


  function decimals()
    external
    view
    returns (
      uint8
    );


  function description()
    external
    view
    returns (
      string memory
    );


  function version()
    external
    view
    returns (
      uint256
    );


  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


}// MIT

pragma solidity ^0.8.0;


interface KeeperCompatibleInterface {

    function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

    function performUpkeep(bytes calldata performData) external;

}


contract CacheGoldLockedDataCronKeeper is KeeperCompatibleInterface {

    address private immutable _cacheGoldLockedOracle;
    uint256 private _lockedGold;
    address private immutable _cacheGoldLockedDataAPIConsumer;

    constructor(address cacheGoldLockedOracleParam, address cacheGoldLockedDataAPIConsumerParam) {
      require(cacheGoldLockedOracleParam != address(0)); //Check that it is not the zeroth address
      require(cacheGoldLockedDataAPIConsumerParam != address(0)); //Check that it is not the zeroth address
      _cacheGoldLockedOracle = cacheGoldLockedOracleParam;
      _cacheGoldLockedDataAPIConsumer = cacheGoldLockedDataAPIConsumerParam;
    }

    function checkUpkeep(bytes calldata checkData) external view override returns  (bool upkeepNeeded, bytes memory performData)   {

        
        (bool success, bytes memory callData) = address(_cacheGoldLockedOracle).staticcall(abi.encodeWithSignature("lockedGold()"));
        require(success, "Unable to fetch locked gold oracle data");
        (uint256 lockedGoldInCacheOracle) = abi.decode(callData, (uint256));
        if(lockedGoldInCacheOracle != _lockedGold){
            return(true, abi.encodeWithSignature("requestedLockedData(string)", "grams_locked")); 
        }
        else{
            return (false, checkData);
        }
    }

    function performUpkeep(bytes calldata performData) external override {

        (bool success, bytes memory callData) = address(_cacheGoldLockedOracle).staticcall(abi.encodeWithSignature("lockedGold()"));
        require(success, "Unable to fetch locked gold oracle data");
        (uint256 lockedGoldInCacheOracle) = abi.decode(callData, (uint256));
        _lockedGold = lockedGoldInCacheOracle;

        (bool successPerformData,) = address(_cacheGoldLockedDataAPIConsumer).call(performData);
        require(successPerformData, "Unable to perform upkeep");
    }

    function cacheGoldContractAddress() external view returns(address) {

        return _cacheGoldLockedOracle;
    }

    function cacheGoldLockedDataAPIConsumer() external view returns(address) {

        return _cacheGoldLockedDataAPIConsumer;
    }
}