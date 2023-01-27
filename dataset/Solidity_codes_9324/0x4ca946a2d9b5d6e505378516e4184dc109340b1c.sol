
pragma solidity 0.6.2;
interface HistoricAggregatorInterface {

  function latestAnswer() external returns (int256);

  function latestTimestamp() external returns (uint256);

  function latestRound() external returns (uint256);

  function getAnswer(uint256 roundId) external returns (int256);

  function getTimestamp(uint256 roundId) external returns (uint256);


  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}
interface AggregatorInterface is HistoricAggregatorInterface {

  function decimals() external returns (uint8);

  function getRoundData(uint256 _roundId)
    external
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    );

  function latestRoundData()
    external
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    );

}
contract AggregatorFacade is AggregatorInterface {


  HistoricAggregatorInterface public aggregator;
  uint8 public override decimals;

  constructor(address _aggregator, uint8 _decimals) public {
    aggregator = HistoricAggregatorInterface(_aggregator);
    decimals = _decimals;
  }

  function latestRound()
    external
    virtual
    override
    returns (uint256)
  {

    return aggregator.latestRound();
  }

  function latestAnswer()
    external
    virtual
    override
    returns (int256)
  {

    return aggregator.latestAnswer();
  }

  function latestTimestamp()
    external
    virtual
    override
    returns (uint256)
  {

    return aggregator.latestTimestamp();
  }

  function latestRoundData()
    external
    virtual
    override
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {

    return _getRoundData(aggregator.latestRound());
  }

  function getAnswer(uint256 _roundId)
    external
    virtual
    override
    returns (int256)
  {

    return aggregator.getAnswer(_roundId);
  }

  function getTimestamp(uint256 _roundId)
    external
    virtual
    override
    returns (uint256)
  {

    return aggregator.getTimestamp(_roundId);
  }

  function getRoundData(uint256 _roundId)
    external
    virtual
    override
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {

    return _getRoundData(_roundId);
  }


  function _getRoundData(uint256 _roundId)
    internal
    returns (
      uint256 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint256 answeredInRound
    )
  {

    answer = aggregator.getAnswer(_roundId);
    updatedAt = uint64(aggregator.getTimestamp(_roundId));
    if (updatedAt == 0) {
      answeredInRound = 0;
    } else {
      answeredInRound = _roundId;
    }
    return (_roundId, answer, updatedAt, updatedAt, answeredInRound);
  }

}