pragma solidity ^0.8.7;

interface AggregatorInterface {

  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  function getRoundData(uint80 _roundId)
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


}

interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{

}


interface AggregatorProxy is AggregatorV2V3Interface {

    function phaseId() external view returns (uint16);

    function phaseAggregators(uint16 phaseId) external view returns (AggregatorV2V3Interface);

}pragma solidity ^0.8.7;


library ChainlinkRoundIdCalc {

    uint256 constant private PHASE_OFFSET = 64;

    function next(AggregatorProxy proxy, uint256 roundId) internal view returns (uint80)
    {

        (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(roundId);

        if (proxy.getAnswer(addPhase(phaseId, aggregatorRoundId+1)) != 0) {
            aggregatorRoundId++;
        }
        else if (phaseId < proxy.phaseId()) {
            phaseId++;
            aggregatorRoundId = 1;
        }
        return addPhase(phaseId, aggregatorRoundId);
    }

    function prev(AggregatorProxy proxy, uint256 roundId) internal view returns (uint80)
    {

        (uint16 phaseId, uint64 aggregatorRoundId) = parseIds(roundId);

        if (aggregatorRoundId > 1) {
            aggregatorRoundId--;
        }
        else if (phaseId > 1) {
            phaseId--;
            aggregatorRoundId = uint64(proxy.phaseAggregators(phaseId).latestRound());
        }
        return addPhase(phaseId, aggregatorRoundId);
    }
    
    function addPhase(uint16 _phase, uint64 _originalId) internal pure returns (uint80)
    {

        return uint80(uint256(_phase) << PHASE_OFFSET | _originalId);
    }

    function parseIds(uint256 _roundId) internal pure returns (uint16, uint64)
    {

        uint16 phaseId = uint16(_roundId >> PHASE_OFFSET);
        uint64 aggregatorRoundId = uint64(_roundId);

        return (phaseId, aggregatorRoundId);
    }

}// MIT
pragma solidity ^0.8.7;


contract ChainLinkPricer {

    using ChainlinkRoundIdCalc for AggregatorProxy;



    function next(address pricer, uint256 roundId) public view returns (uint80) {

        return AggregatorProxy(pricer).next(roundId);
    }

    function prev(address pricer, uint256 roundId) public view returns (uint80) {

        return AggregatorProxy(pricer).prev(roundId);
    }

    function addPhase(uint16 _phase, uint64 _originalId) public pure returns (uint80) {

        return ChainlinkRoundIdCalc.addPhase(_phase, _originalId);
    }

    function parseIds(uint256 roundId) public pure returns (uint16, uint64) {

        return ChainlinkRoundIdCalc.parseIds(roundId);
    }

    function getLatestPrice(address pricer) public view returns (int) {

        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = AggregatorProxy(pricer).latestRoundData();
        return price;
    }

    function getLatestRoundId(address pricer) public view returns (uint80) {

        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = AggregatorProxy(pricer).latestRoundData();
        return roundID;
    }

    function getHistoricalPrice(address pricer, uint80 roundId) public view returns (int256) {

        (
            uint80 id, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = AggregatorProxy(pricer).getRoundData(roundId);
        require(timeStamp > 0, "Round not complete");
        return price;
    }

    function getHistoricalRoundData(address pricer, uint80 roundId) public view returns  (uint80, int, uint, uint, uint80) {

       return AggregatorProxy(pricer).getRoundData(roundId);
    }

    function getLatestRoundData(address pricer) public view returns (uint80, int, uint, uint, uint80) {

        return AggregatorProxy(pricer).latestRoundData();
    }
}