
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IDerivativePriceFeed {

    function calcUnderlyingValues(address, uint256)
        external
        returns (address[] memory, uint256[] memory);


    function isSupportedAsset(address) external view returns (bool);

}// GPL-3.0


pragma solidity 0.6.12;


interface IAggregatedDerivativePriceFeed is IDerivativePriceFeed {

    function getPriceFeedForDerivative(address) external view returns (address);

}// GPL-3.0


pragma solidity 0.6.12;

interface IPrimitivePriceFeed {

    function calcCanonicalValue(
        address,
        uint256,
        address
    ) external view returns (uint256, bool);


    function calcLiveValue(
        address,
        uint256,
        address
    ) external view returns (uint256, bool);


    function isSupportedAsset(address) external view returns (bool);

}// GPL-3.0


pragma solidity 0.6.12;

interface IValueInterpreter {

    function calcCanonicalAssetValue(
        address,
        uint256,
        address
    ) external returns (uint256, bool);


    function calcCanonicalAssetsTotalValue(
        address[] calldata,
        uint256[] calldata,
        address
    ) external returns (uint256, bool);


    function calcLiveAssetValue(
        address,
        uint256,
        address
    ) external returns (uint256, bool);


    function calcLiveAssetsTotalValue(
        address[] calldata,
        uint256[] calldata,
        address
    ) external returns (uint256, bool);

}// GPL-3.0


pragma solidity 0.6.12;


contract ValueInterpreter is IValueInterpreter {

    using SafeMath for uint256;

    address private immutable AGGREGATED_DERIVATIVE_PRICE_FEED;
    address private immutable PRIMITIVE_PRICE_FEED;

    constructor(address _primitivePriceFeed, address _aggregatedDerivativePriceFeed) public {
        AGGREGATED_DERIVATIVE_PRICE_FEED = _aggregatedDerivativePriceFeed;
        PRIMITIVE_PRICE_FEED = _primitivePriceFeed;
    }


    function calcLiveAssetsTotalValue(
        address[] calldata _baseAssets,
        uint256[] calldata _amounts,
        address _quoteAsset
    ) external override returns (uint256 value_, bool isValid_) {

        return calcCanonicalAssetsTotalValue(_baseAssets, _amounts, _quoteAsset);
    }

    function calcLiveAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) external override returns (uint256 value_, bool isValid_) {

        return calcCanonicalAssetValue(_baseAsset, _amount, _quoteAsset);
    }


    function calcCanonicalAssetsTotalValue(
        address[] memory _baseAssets,
        uint256[] memory _amounts,
        address _quoteAsset
    ) public override returns (uint256 value_, bool isValid_) {

        require(
            _baseAssets.length == _amounts.length,
            "calcCanonicalAssetsTotalValue: Arrays unequal lengths"
        );
        require(
            IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).isSupportedAsset(_quoteAsset),
            "calcCanonicalAssetsTotalValue: Unsupported _quoteAsset"
        );

        isValid_ = true;
        for (uint256 i; i < _baseAssets.length; i++) {
            (uint256 assetValue, bool assetValueIsValid) = __calcAssetValue(
                _baseAssets[i],
                _amounts[i],
                _quoteAsset
            );
            value_ = value_.add(assetValue);
            if (!assetValueIsValid) {
                isValid_ = false;
            }
        }

        return (value_, isValid_);
    }

    function calcCanonicalAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) public override returns (uint256 value_, bool isValid_) {

        if (_baseAsset == _quoteAsset || _amount == 0) {
            return (_amount, true);
        }

        require(
            IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).isSupportedAsset(_quoteAsset),
            "calcCanonicalAssetValue: Unsupported _quoteAsset"
        );

        return __calcAssetValue(_baseAsset, _amount, _quoteAsset);
    }


    function __calcAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) private returns (uint256 value_, bool isValid_) {

        if (_baseAsset == _quoteAsset || _amount == 0) {
            return (_amount, true);
        }

        if (IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).isSupportedAsset(_baseAsset)) {
            return
                IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).calcCanonicalValue(
                    _baseAsset,
                    _amount,
                    _quoteAsset
                );
        }

        address derivativePriceFeed = IAggregatedDerivativePriceFeed(
            AGGREGATED_DERIVATIVE_PRICE_FEED
        )
            .getPriceFeedForDerivative(_baseAsset);
        if (derivativePriceFeed != address(0)) {
            return __calcDerivativeValue(derivativePriceFeed, _baseAsset, _amount, _quoteAsset);
        }

        revert("__calcAssetValue: Unsupported _baseAsset");
    }

    function __calcDerivativeValue(
        address _derivativePriceFeed,
        address _derivative,
        uint256 _amount,
        address _quoteAsset
    ) private returns (uint256 value_, bool isValid_) {

        (address[] memory underlyings, uint256[] memory underlyingAmounts) = IDerivativePriceFeed(
            _derivativePriceFeed
        )
            .calcUnderlyingValues(_derivative, _amount);

        require(underlyings.length > 0, "__calcDerivativeValue: No underlyings");
        require(
            underlyings.length == underlyingAmounts.length,
            "__calcDerivativeValue: Arrays unequal lengths"
        );

        isValid_ = true;
        for (uint256 i = 0; i < underlyings.length; i++) {
            (uint256 underlyingValue, bool underlyingValueIsValid) = __calcAssetValue(
                underlyings[i],
                underlyingAmounts[i],
                _quoteAsset
            );

            if (!underlyingValueIsValid) {
                isValid_ = false;
            }
            value_ = value_.add(underlyingValue);
        }
    }


    function getAggregatedDerivativePriceFeed()
        external
        view
        returns (address aggregatedDerivativePriceFeed_)
    {

        return AGGREGATED_DERIVATIVE_PRICE_FEED;
    }

    function getPrimitivePriceFeed() external view returns (address primitivePriceFeed_) {

        return PRIMITIVE_PRICE_FEED;
    }
}