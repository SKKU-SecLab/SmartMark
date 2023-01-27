
pragma solidity ^0.6.3;


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

contract PriceConsumerV3 {

    constructor() public {}

    function getLatestMarketPrice(address aggregatorAddr) public view returns (int) {

        require(aggregatorAddr != address(0), "Incorrect address");
        AggregatorV3Interface priceFeed = AggregatorV3Interface(aggregatorAddr);
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }

    function priceOfBatch(address[] memory _aggregators) public view returns (int[] memory) {

        require(_aggregators.length > 0, "Should contain more than one aggregator address");
        int[] memory batchPrices = new int[](_aggregators.length);
        for (uint256 i = 0; i < _aggregators.length; i++) {
            AggregatorV3Interface priceFeed = AggregatorV3Interface(_aggregators[i]);
            (
                uint80 roundID, 
                int price,
                uint startedAt,
                uint timeStamp,
                uint80 answeredInRound
            ) = priceFeed.latestRoundData();
            batchPrices[i] = price;
        }
        return batchPrices;
    }
}