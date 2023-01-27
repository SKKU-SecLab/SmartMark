pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;


interface CErc20 {

    function underlying() external view returns (address);

}

contract SymbolConfiguration {

    address public constant cUsdcAnchorKey = address(1);
    address public constant cUsdtAnchorKey = address(1);
    address public constant cDaiAnchorKey = address(2);

    uint constant oneDollar = 1e6;

    address public immutable cRepAnchorKey;
    address public immutable cWbtcAnchorKey;
    address public immutable cBatAnchorKey;
    address public immutable cZrxAnchorKey;

    uint public constant saiAnchorPrice = 5285551943761727;
    uint public constant ethAnchorPrice = 1e18;

    struct CTokens {
        address cEthAddress;
        address cUsdcAddress;
        address cDaiAddress;
        address cRepAddress;
        address cWbtcAddress;
        address cBatAddress;
        address cZrxAddress;
        address cSaiAddress;
        address cUsdtAddress;
    }

    enum PriceSource {ANCHOR, FIXED_USD, REPORTER}
    enum AnchorSource {ANCHOR, FIXED_USD, FIXED_ETH}

    struct CTokenMetadata {
        address cTokenAddress;
        address anchorOracleKey;
        string openOracleKey;
        uint baseUnit;
        PriceSource priceSource;
        AnchorSource anchorSource;
        uint fixedAnchorPrice;
        uint fixedReporterPrice;
    }

    bytes32 constant symbolEth = keccak256(abi.encodePacked("ETH"));
    bytes32 constant symbolUsdc = keccak256(abi.encodePacked("USDC"));
    bytes32 constant symbolDai = keccak256(abi.encodePacked("DAI"));
    bytes32 constant symbolRep = keccak256(abi.encodePacked("REP"));
    bytes32 constant symbolWbtc = keccak256(abi.encodePacked("BTC"));
    bytes32 constant symbolBat = keccak256(abi.encodePacked("BAT"));
    bytes32 constant symbolZrx = keccak256(abi.encodePacked("ZRX"));
    bytes32 constant symbolSai = keccak256(abi.encodePacked("SAI"));
    bytes32 constant symbolUsdt = keccak256(abi.encodePacked("USDT"));

    address public immutable cEthAddress;
    address public immutable cUsdcAddress;
    address public immutable cDaiAddress;
    address public immutable cRepAddress;
    address public immutable cWbtcAddress;
    address public immutable cBatAddress;
    address public immutable cZrxAddress;
    address public immutable cSaiAddress;
    address public immutable cUsdtAddress;

    constructor(CTokens memory tokens_) public {
        cEthAddress = tokens_.cEthAddress;
        cUsdcAddress = tokens_.cUsdcAddress;
        cDaiAddress = tokens_.cDaiAddress;
        cRepAddress = tokens_.cRepAddress;
        cWbtcAddress = tokens_.cWbtcAddress;
        cBatAddress = tokens_.cBatAddress;
        cZrxAddress = tokens_.cZrxAddress;
        cSaiAddress = tokens_.cSaiAddress;
        cUsdtAddress = tokens_.cUsdtAddress;

        cRepAnchorKey = CErc20(tokens_.cRepAddress).underlying();
        cWbtcAnchorKey = CErc20(tokens_.cWbtcAddress).underlying();
        cBatAnchorKey = CErc20(tokens_.cBatAddress).underlying();
        cZrxAnchorKey = CErc20(tokens_.cZrxAddress).underlying();
    }

    function getCTokenConfig(string memory symbol) public view returns (CTokenMetadata memory) {

        address cToken = getCTokenAddress(symbol);
        return getCTokenConfig(cToken);
    }

    function getCTokenConfig(address cToken) public view returns(CTokenMetadata memory) {

        if (cToken == cEthAddress) {
            return CTokenMetadata({
                        openOracleKey: "ETH",
                        anchorOracleKey: address(0),
                        baseUnit: 1e18,
                        cTokenAddress: cEthAddress,
                        priceSource: PriceSource.REPORTER,
                        anchorSource: AnchorSource.FIXED_ETH,
                        fixedReporterPrice: 0,
                        fixedAnchorPrice: 1e18
                        });
        }

        if (cToken == cUsdcAddress) {
            return CTokenMetadata({
                        openOracleKey: "USDC",
                        anchorOracleKey: cUsdcAnchorKey,
                        baseUnit: 1e6,
                        cTokenAddress: cUsdcAddress,
                        priceSource: PriceSource.FIXED_USD,
                        anchorSource: AnchorSource.FIXED_USD,
                        fixedReporterPrice: oneDollar,
                        fixedAnchorPrice: oneDollar
                        });
        }

        if (cToken == cDaiAddress) {
            return CTokenMetadata({
                        openOracleKey: "DAI",
                        anchorOracleKey: cDaiAnchorKey,
                        baseUnit: 1e18,
                        cTokenAddress: cDaiAddress,
                        priceSource: PriceSource.REPORTER,
                        anchorSource: AnchorSource.ANCHOR,
                        fixedReporterPrice: 0,
                        fixedAnchorPrice: 0
                        });
        }

        if (cToken == cRepAddress) {
            return CTokenMetadata({
                        openOracleKey: "REP",
                        anchorOracleKey: cRepAnchorKey,
                        baseUnit: 1e18,
                        cTokenAddress: cRepAddress,
                        priceSource: PriceSource.REPORTER,
                        anchorSource: AnchorSource.ANCHOR,
                        fixedReporterPrice: 0,
                        fixedAnchorPrice: 0
                        });
        }

        if (cToken == cWbtcAddress) {
            return CTokenMetadata({
                        openOracleKey: "BTC",
                        anchorOracleKey: cWbtcAnchorKey,
                        baseUnit: 1e8,
                        cTokenAddress: cWbtcAddress,
                        priceSource: PriceSource.REPORTER,
                        anchorSource: AnchorSource.ANCHOR,
                        fixedReporterPrice: 0,
                        fixedAnchorPrice: 0
                        });
        }

        if (cToken == cBatAddress) {
            return CTokenMetadata({
                        openOracleKey: "BAT",
                        anchorOracleKey: cBatAnchorKey,
                        baseUnit: 1e18,
                        cTokenAddress: cBatAddress,
                        priceSource: PriceSource.REPORTER,
                        anchorSource: AnchorSource.ANCHOR,
                        fixedReporterPrice: 0,
                        fixedAnchorPrice: 0
                        });
        }

        if (cToken == cZrxAddress){
            return CTokenMetadata({
                        openOracleKey: "ZRX",
                        anchorOracleKey: cZrxAnchorKey,
                        baseUnit: 1e18,
                        cTokenAddress: cZrxAddress,
                        priceSource: PriceSource.REPORTER,
                        anchorSource: AnchorSource.ANCHOR,
                        fixedReporterPrice: 0,
                        fixedAnchorPrice: 0
                        });
        }

        if (cToken == cSaiAddress){
            return CTokenMetadata({
                        openOracleKey: "SAI",
                        anchorOracleKey: address(0),
                        baseUnit: 1e18,
                        cTokenAddress: cSaiAddress,
                        priceSource: PriceSource.ANCHOR,
                        anchorSource: AnchorSource.FIXED_ETH,
                        fixedAnchorPrice: saiAnchorPrice,
                        fixedReporterPrice: 0
                        });
        }

        if (cToken == cUsdtAddress){
            return CTokenMetadata({
                        openOracleKey: "USDT",
                        anchorOracleKey: cUsdtAnchorKey,
                        baseUnit: 1e6,
                        cTokenAddress: cUsdtAddress,
                        priceSource: PriceSource.FIXED_USD,
                        anchorSource: AnchorSource.FIXED_USD,
                        fixedReporterPrice: oneDollar,
                        fixedAnchorPrice: oneDollar
                        });
        }

        return CTokenMetadata({
                    openOracleKey: "UNCONFIGURED",
                    anchorOracleKey: address(0),
                    baseUnit: 0,
                    cTokenAddress: address(0),
                    priceSource: PriceSource.FIXED_USD,
                    anchorSource: AnchorSource.FIXED_USD,
                    fixedReporterPrice: 0,
                    fixedAnchorPrice: 0
                    });
    }

    function getCTokenAddress(string memory symbol) public view returns (address) {

        bytes32 symbolHash = keccak256(abi.encodePacked(symbol));
        if (symbolHash == symbolEth) return cEthAddress;
        if (symbolHash == symbolUsdc) return cUsdcAddress;
        if (symbolHash == symbolDai) return cDaiAddress;
        if (symbolHash == symbolRep) return cRepAddress;
        if (symbolHash == symbolWbtc) return cWbtcAddress;
        if (symbolHash == symbolBat) return cBatAddress;
        if (symbolHash == symbolZrx) return cZrxAddress;
        if (symbolHash == symbolSai) return cSaiAddress;
        if (symbolHash == symbolUsdt) return cUsdtAddress;
        return address(0);
    }
}pragma solidity ^0.6.6;

contract OpenOracleData {




    function source(bytes memory message, bytes memory signature) public pure returns (address) {

        (bytes32 r, bytes32 s, uint8 v) = abi.decode(signature, (bytes32, bytes32, uint8));
        bytes32 hash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(message)));
        return ecrecover(hash, v, r, s);
    }
}pragma solidity ^0.6.6;


contract OpenOraclePriceData is OpenOracleData {

    event Write(address indexed source, string key, uint64 timestamp, uint64 value);
    event NotWritten(uint64 priorTimestamp, uint256 messageTimestamp, uint256 blockTimestamp);

    struct Datum {
        uint64 timestamp;
        uint64 value;
    }

    mapping(address => mapping(string => Datum)) private data;

    function put(bytes calldata message, bytes calldata signature) external returns (string memory) {

        address source = source(message, signature);

        (string memory kind, uint64 timestamp, string memory key, uint64 value) = abi.decode(message, (string, uint64, string, uint64));
        require(keccak256(abi.encodePacked(kind)) == keccak256(abi.encodePacked("prices")), "Kind of data must be 'prices'");

        Datum storage prior = data[source][key];
        if (timestamp > prior.timestamp && timestamp < block.timestamp + 60 minutes) {
            data[source][key] = Datum(timestamp, value);
            emit Write(source, key, timestamp, value);
        } else {
            emit NotWritten(prior.timestamp, timestamp, block.timestamp);
        }

        return key;
    }

    function get(address source, string calldata key) external view returns (uint64, uint64) {

        Datum storage datum = data[source][key];
        return (datum.timestamp, datum.value);
    }

    function getPrice(address source, string calldata key) external view returns (uint64) {

        return data[source][key].value;
    }
}pragma solidity ^0.6.6;


interface AnchorOracle {

    function numBlocksPerPeriod() external view returns (uint); // approximately 1 hour: 60 seconds/minute * 60 minutes/hour * 1 block/15 seconds


    function assetPrices(address asset) external view returns (uint);


    struct Anchor {
        uint period;

        uint priceMantissa;
    }
    function anchors(address asset) external view returns (Anchor memory);

}


contract AnchoredView is SymbolConfiguration {

    mapping(string => uint) public _prices;

    bool public reporterBreaker;

    bool public anchorBreaker;

    address public immutable reporter;

    AnchorOracle public immutable anchor;

    OpenOraclePriceData public immutable priceData;

    uint immutable upperBoundAnchorRatio;

    uint immutable lowerBoundAnchorRatio;

    uint constant blocksInADay = 5760;

    event PriceUpdated(string symbol, uint price);

    event PriceGuarded(string symbol, uint reporter, uint anchor);

    event ReporterInvalidated(address reporter);

    event AnchorCut(address anchor);

    constructor(OpenOraclePriceData data_,
                address reporter_,
                AnchorOracle anchor_,
                uint anchorToleranceMantissa_,
                CTokens memory tokens_) SymbolConfiguration(tokens_) public {
        reporter = reporter_;
        anchor = anchor_;
        priceData = data_;

        require(anchorToleranceMantissa_ < 100e16, "Anchor Tolerance is too high");
        upperBoundAnchorRatio = 100e16 + anchorToleranceMantissa_;
        lowerBoundAnchorRatio = 100e16 - anchorToleranceMantissa_;
    }

    function postPrices(bytes[] calldata messages, bytes[] calldata signatures, string[] calldata symbols) external {

        require(messages.length == signatures.length, "messages and signatures must be 1:1");

        for (uint i = 0; i < messages.length; i++) {
            priceData.put(messages[i], signatures[i]);
        }

        uint usdcPrice = readAnchor(cUsdcAddress);

        for (uint i = 0; i < symbols.length; i++) {
            CTokenMetadata memory tokenConfig = getCTokenConfig(symbols[i]);
            if (tokenConfig.cTokenAddress == address(0)) continue;

            uint reporterPrice = priceData.getPrice(reporter, tokenConfig.openOracleKey);
            uint anchorPrice = getAnchorInUsd(tokenConfig, usdcPrice);
            
            uint anchorRatio = mul(anchorPrice, 100e16) / reporterPrice;
            bool withinAnchor = anchorRatio <= upperBoundAnchorRatio && anchorRatio >= lowerBoundAnchorRatio;

            if (withinAnchor || anchorBreaker) {
                if (_prices[tokenConfig.openOracleKey] != reporterPrice) {
                    _prices[tokenConfig.openOracleKey] = reporterPrice;
                    emit PriceUpdated(tokenConfig.openOracleKey, reporterPrice);
                }
            } else {
                emit PriceGuarded(tokenConfig.openOracleKey, reporterPrice, anchorPrice);
            }
        }
    }
    function prices(string calldata symbol) external view returns (uint) {

        CTokenMetadata memory tokenConfig = getCTokenConfig(symbol);

        if (tokenConfig.priceSource == PriceSource.REPORTER) return _prices[symbol];
        if (tokenConfig.priceSource == PriceSource.FIXED_USD) return tokenConfig.fixedReporterPrice;
        if (tokenConfig.priceSource == PriceSource.ANCHOR) {
            uint usdPerEth = _prices["ETH"];
            require(usdPerEth > 0, "eth price not set, cannot convert eth to dollars");

            uint ethPerToken = readAnchor(tokenConfig);
            return mul(usdPerEth, ethPerToken) / tokenConfig.baseUnit;
        }
    }

    function getAnchorInUsd(address cToken, uint ethPerUsdc) public view returns (uint) {

        CTokenMetadata memory tokenConfig = getCTokenConfig(cToken);
        return getAnchorInUsd(tokenConfig, ethPerUsdc);
    }

    function getAnchorInUsd(CTokenMetadata memory tokenConfig, uint ethPerUsdc) internal view returns (uint) {

        if (tokenConfig.anchorSource == AnchorSource.FIXED_USD) {
            return tokenConfig.fixedAnchorPrice;
        }

        uint ethPerToken = readAnchor(tokenConfig);

        return mul(ethPerToken, tokenConfig.baseUnit) / ethPerUsdc;
    }

    function getUnderlyingPrice(address cToken) public view returns (uint) {

        CTokenMetadata memory tokenConfig = getCTokenConfig(cToken);
        if (reporterBreaker == true) {
            return readAnchor(tokenConfig);
        }

        if (tokenConfig.priceSource == PriceSource.FIXED_USD) {
            uint usdPerToken = tokenConfig.fixedReporterPrice;
            return mul(usdPerToken, 1e30) / tokenConfig.baseUnit;
        }

        if (tokenConfig.priceSource == PriceSource.REPORTER) {
            uint usdPerToken = _prices[tokenConfig.openOracleKey];
            return mul(usdPerToken, 1e30) / tokenConfig.baseUnit;
        }

        if (tokenConfig.priceSource == PriceSource.ANCHOR) {
            uint usdPerEth = _prices["ETH"];
            require(usdPerEth != 0, "no reporter price for usd/eth exists, cannot convert anchor price to usd terms");

            uint ethPerToken = readAnchor(tokenConfig);
            return mul(usdPerEth, ethPerToken) / 1e6;
        }
    }

    function readAnchor(address cToken) public view returns (uint) {

        return readAnchor(getCTokenConfig(cToken));
    }

    function readAnchor(CTokenMetadata memory tokenConfig) internal view returns (uint) {

        if (tokenConfig.anchorSource == AnchorSource.FIXED_ETH) return tokenConfig.fixedAnchorPrice;

        return anchor.assetPrices(tokenConfig.anchorOracleKey);
    }

    function invalidate(bytes memory message, bytes memory signature) public {

        (string memory decoded_message, ) = abi.decode(message, (string, address));
        require(keccak256(abi.encodePacked(decoded_message)) == keccak256(abi.encodePacked("rotate")), "invalid message must be 'rotate'");
        require(priceData.source(message, signature) == reporter, "invalidation message must come from the reporter");

        reporterBreaker = true;
        emit ReporterInvalidated(reporter);
    }


    function cutAnchor() external {

        AnchorOracle.Anchor memory latestUsdcAnchor = anchor.anchors(cUsdcAnchorKey);

        uint usdcAnchorBlockNumber = mul(latestUsdcAnchor.period, anchor.numBlocksPerPeriod());
        uint blocksSinceUpdate = block.number - usdcAnchorBlockNumber;

        if (blocksSinceUpdate > blocksInADay) {
            anchorBreaker = true;
            emit AnchorCut(address(anchor));
        }
    }


    function mul(uint a, uint b) internal pure returns (uint) {

        if (a == 0) return 0;

        uint c = a * b;
        require(c / a == b, "multiplication overflow");

        return c;
    }
}