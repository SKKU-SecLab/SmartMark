pragma solidity ^0.8.0;

interface AggregatorInterface {

  function latestAnswer()
    external
    view
    returns (
      int256
    );

  
  function latestTimestamp()
    external
    view
    returns (
      uint256
    );


  function latestRound()
    external
    view
    returns (
      uint256
    );


  function getAnswer(
    uint256 roundId
  )
    external
    view
    returns (
      int256
    );


  function getTimestamp(
    uint256 roundId
  )
    external
    view
    returns (
      uint256
    );


  event AnswerUpdated(
    int256 indexed current,
    uint256 indexed roundId,
    uint256 updatedAt
  );

  event NewRound(
    uint256 indexed roundId,
    address indexed startedBy,
    uint256 startedAt
  );
}// MIT
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


interface AggregatorV2V3Interface is AggregatorInterface, AggregatorV3Interface
{

}// MIT
pragma solidity ^0.8.0;
pragma abicoder v2;


interface FeedRegistryInterface {

  struct Phase {
    uint16 phaseId;
    uint80 startingAggregatorRoundId;
    uint80 endingAggregatorRoundId;
  }

  event FeedProposed(
    address indexed asset,
    address indexed denomination,
    address indexed proposedAggregator,
    address currentAggregator,
    address sender
  );
  event FeedConfirmed(
    address indexed asset,
    address indexed denomination,
    address indexed latestAggregator,
    address previousAggregator,
    uint16 nextPhaseId,
    address sender
  );


  function decimals(
    address base,
    address quote
  )
    external
    view
    returns (
      uint8
    );


  function description(
    address base,
    address quote
  )
    external
    view
    returns (
      string memory
    );


  function version(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256
    );


  function latestRoundData(
    address base,
    address quote
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


  function getRoundData(
    address base,
    address quote,
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



  function latestAnswer(
    address base,
    address quote
  )
    external
    view
    returns (
      int256 answer
    );


  function latestTimestamp(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256 timestamp
    );


  function latestRound(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256 roundId
    );


  function getAnswer(
    address base,
    address quote,
    uint256 roundId
  )
    external
    view
    returns (
      int256 answer
    );


  function getTimestamp(
    address base,
    address quote,
    uint256 roundId
  )
    external
    view
    returns (
      uint256 timestamp
    );



  function getFeed(
    address base,
    address quote
  )
    external
    view
    returns (
      AggregatorV2V3Interface aggregator
    );


  function getPhaseFeed(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      AggregatorV2V3Interface aggregator
    );


  function isFeedEnabled(
    address aggregator
  )
    external
    view
    returns (
      bool
    );


  function getPhase(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      Phase memory phase
    );



  function getRoundFeed(
    address base,
    address quote,
    uint80 roundId
  )
    external
    view
    returns (
      AggregatorV2V3Interface aggregator
    );


  function getPhaseRange(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      uint80 startingRoundId,
      uint80 endingRoundId
    );


  function getPreviousRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external
    view
    returns (
      uint80 previousRoundId
    );


  function getNextRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external
    view
    returns (
      uint80 nextRoundId
    );



  function proposeFeed(
    address base,
    address quote,
    address aggregator
  ) external;


  function confirmFeed(
    address base,
    address quote,
    address aggregator
  ) external;



  function getProposedFeed(
    address base,
    address quote
  )
    external
    view
    returns (
      AggregatorV2V3Interface proposedAggregator
    );


  function proposedGetRoundData(
    address base,
    address quote,
    uint80 roundId
  )
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function proposedLatestRoundData(
    address base,
    address quote
  )
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  function getCurrentPhaseId(
    address base,
    address quote
  )
    external
    view
    returns (
      uint16 currentPhaseId
    );

}// MIT

pragma solidity ^0.8.0;

library Denominations {

  address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  address public constant BTC = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;

  address public constant USD = address(840);
  address public constant GBP = address(826);
  address public constant EUR = address(978);
  address public constant JPY = address(392);
  address public constant KRW = address(410);
  address public constant CNY = address(156);
  address public constant AUD = address(36);
  address public constant CAD = address(124);
  address public constant CHF = address(756);
  address public constant ARS = address(32);
}// MIT

pragma solidity ^0.8.0;

interface IMultipriceOracle {

    function uniV3TwapAssetToAsset(
        address _tokenIn,
        uint256 _amountIn,
        address _tokenOut,
        uint32 _twapPeriod
    ) external view returns (uint256 amountOut);

}// MIT

pragma solidity ^0.8.0;

interface IPriceFeed {

    function getToken() external view returns (address);

    function getPrice() external view returns (uint);

}// MIT

pragma solidity ^0.8.0;


contract UniswapV3PriceFeed is IPriceFeed {

    address public registry;
    address public multiPriceOracle;
    address public token;

    address public constant weth = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    uint public constant amountIn = 1e18;
    uint32 public constant twapPeriod = 1 days;

    constructor(address _registry, address _multiPriceOracle, address _token) {
        registry = _registry;
        multiPriceOracle = _multiPriceOracle;
        token = _token;
    }

    function getToken() external override view returns (address) {

        return token;
    }

    function getPrice() external override view returns (uint) {

        uint tokenEthPrice = IMultipriceOracle(multiPriceOracle).uniV3TwapAssetToAsset(token, amountIn, weth, twapPeriod);
        uint EthUsdPrice = getEthUsdPriceFromChainlink();
        uint price = tokenEthPrice * EthUsdPrice / 1e18;
        require(price > 0, "invalid price");

        return price;
    }

    function getEthUsdPriceFromChainlink() internal view returns (uint) {

        ( , int price, , , ) = FeedRegistryInterface(registry).latestRoundData(Denominations.ETH, Denominations.USD);

        return uint(price) * 10**10;
    }
}