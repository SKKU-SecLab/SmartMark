
pragma solidity ^0.6.6;


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

contract PriceChainLink {

  address public owner;
	AggregatorV3Interface public priceFeed;

	modifier onlyOwner() {

    require(msg.sender == owner, "Must be owner!");
    _;
  }

  constructor (address _priceFeed) public {
		owner = msg.sender;
		priceFeed = AggregatorV3Interface(_priceFeed);
	}

	function setController(address _priceFeed) public onlyOwner {

		priceFeed = AggregatorV3Interface(_priceFeed);
	}

	function lastPrice() public view returns (uint256 price) {

		(,int answer,,uint timeStamp,) = priceFeed.latestRoundData();
		uint256 decimals = priceFeed.decimals() >= 2 ? uint256(priceFeed.decimals()) - 2 : 0; // -2 to get price with 2 decimals, ex. 357.39
		require(timeStamp > 0, "Round not complete");
		return uint256(answer) / (10 ** decimals);
	}

	function lastUpdatedTime() public view returns (uint updatedTime) {

		(,,,uint timeStamp,) = priceFeed.latestRoundData();
		return timeStamp;
	}
}