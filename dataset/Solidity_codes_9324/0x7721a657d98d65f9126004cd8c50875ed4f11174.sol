

pragma solidity ^0.8.0;

interface IERC20Like {

    function symbol() external view returns (string memory);

    function balanceOf(address) external view returns (uint);

    function decimals() external view returns (uint8);

    function transfer(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function totalSupply() external view returns (uint256);

}

interface ICoreMetadataOracleReader {


    struct Quote {
        uint256 price;
        uint32 updateTS;
    }


    function getAssets() external view returns (address[] memory);


    function hasAsset(address asset) external view returns (bool);


    function quoteAssets(address[] calldata assets) external view returns (Quote[] memory quotes);

}


interface IOracleUsd {

    function assetToUsd(address asset, uint256 amount) external view returns (uint256);

}


contract UnitMetadataOracle is IOracleUsd {

    ICoreMetadataOracleReader public immutable metadataOracle;
    uint256 public immutable maxPriceAgeSeconds;

    constructor(address metadataOracle_, uint256 maxPriceAgeSeconds_) {
        metadataOracle = ICoreMetadataOracleReader(metadataOracle_);
        maxPriceAgeSeconds = maxPriceAgeSeconds_;
    }

    function assetToUsd(address asset, uint256 amount) external view override returns (uint256 result) {

        address[] memory input = new address[](1);
        input[0] = asset;
        ICoreMetadataOracleReader.Quote memory quote = metadataOracle.quoteAssets(input)[0];
        require(block.timestamp - quote.updateTS <= maxPriceAgeSeconds, 'STALE_PRICE');

        uint256 decimals = uint256(IERC20Like(asset).decimals());
        require(decimals < 256);
        int256 scaleDecimals = 18 - int256(decimals);

        result = quote.price * amount;
        if (scaleDecimals > 0)
            result *= uint256(10) ** uint256(scaleDecimals);
        else if (scaleDecimals < 0)
            result /= uint256(10) ** uint256(-scaleDecimals);
    }
}