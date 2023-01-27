

pragma solidity ^0.5.0;

interface IAaveOracle {

    function getAssetPrice(address _asset) external view returns (uint256);

    function prophecies(address _asset) external view returns (uint64, uint96, uint96);

    function submitProphecy(address _asset, uint96 _sybilProphecy, uint96 _oracleProphecy) external;

    function isSybilWhitelisted(address _sybil) external view returns (bool);

}


pragma solidity ^0.5.0;

interface IChainlinkAggregator {

  function latestAnswer() external view returns (int256);

}


pragma solidity ^0.5.0;



contract AaveOracle is IAaveOracle {

    struct TimestampedProphecy {
        uint64 timestamp;
        uint96 sybilProphecy;
        uint96 oracleProphecy;
    }

    event ProphecySubmitted(
        address indexed _sybil,
        address indexed _asset,
        uint96 _sybilProphecy,
        uint96 _oracleProphecy
    );

    event SybilWhitelisted(address sybil);

    address constant public USD_ETH_CHAINLINK_AGGREGATOR = address(0x59b826c214aBa7125bFA52970d97736c105Cc375);

    address constant public MOCK_USD = address(0x10F7Fc1F91Ba351f9C629c5947AD69bD03C05b96);

    mapping(address => TimestampedProphecy) public prophecies;

    mapping(address => bool) private sybils;

    modifier onlySybil {

        require(isSybilWhitelisted(msg.sender), "INVALID_SYBIL");
        _;
    }

    constructor(address[] memory _sybils) public {
        internalWhitelistSybils(_sybils);
    }

    function internalWhitelistSybils(address[] memory _sybils) internal {

        for (uint256 i = 0; i < _sybils.length; i++) {
            sybils[_sybils[i]] = true;
            emit SybilWhitelisted(_sybils[i]);
        }
    }

    function submitProphecy(address _asset, uint96 _sybilProphecy, uint96 _oracleProphecy) external onlySybil {

        prophecies[_asset] = TimestampedProphecy(uint64(block.timestamp), _sybilProphecy, _oracleProphecy);
        emit ProphecySubmitted(msg.sender, _asset, _sybilProphecy, _oracleProphecy);
    }

    function getAssetPrice(address _asset) external view returns (uint256) {

        if (_asset == address(MOCK_USD)) {
            return getUsdPriceFromChainlink();
        } else {
            return uint256(prophecies[_asset].oracleProphecy);
        }
    }

    function getProphecy(address _asset) external view returns (uint64, uint96, uint96) {

        if (_asset == address(MOCK_USD)) {
            uint256 _price = getUsdPriceFromChainlink();
            return (uint64(block.timestamp), uint96(_price), uint96(_price));
        } else {
            TimestampedProphecy memory _prophecy = prophecies[_asset];
            return (_prophecy.timestamp, _prophecy.sybilProphecy, _prophecy.oracleProphecy);
        }
    }

    function isSybilWhitelisted(address _sybil) public view returns (bool) {

        return sybils[_sybil];
    }

    function getUsdPriceFromChainlink() internal view returns (uint256) {

        return uint256(1e8 * 1e18 / IChainlinkAggregator(USD_ETH_CHAINLINK_AGGREGATOR).latestAnswer());
    }

}