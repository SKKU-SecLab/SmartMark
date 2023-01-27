
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPosition {
    function getDebtAssets() external returns (address[] memory, uint256[] memory);

    function getManagedAssets() external returns (address[] memory, uint256[] memory);

    function init(bytes memory) external;

    function receiveCallFromVault(bytes memory) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface IFundDeployer {
    function getOwner() external view returns (address);

    function hasReconfigurationRequest(address) external view returns (bool);

    function isAllowedBuySharesOnBehalfCaller(address) external view returns (bool);

    function isAllowedVaultCall(
        address,
        bytes4,
        bytes32
    ) external view returns (bool);
}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPositionParser {
    function parseAssetsForAction(
        address _externalPosition,
        uint256 _actionId,
        bytes memory _encodedActionArgs
    )
        external
        returns (
            address[] memory assetsToTransfer_,
            uint256[] memory amountsToTransfer_,
            address[] memory assetsToReceive_
        );

    function parseInitArgs(address _vaultProxy, bytes memory _initializationData)
        external
        returns (bytes memory initArgs_);
}// GPL-3.0


pragma solidity 0.6.12;

abstract contract AaveDebtPositionDataDecoder {
    function __decodeAddCollateralActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address[] memory aTokens_, uint256[] memory amounts_)
    {
        return abi.decode(_actionArgs, (address[], uint256[]));
    }

    function __decodeBorrowActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address[] memory tokens_, uint256[] memory amounts_)
    {
        return abi.decode(_actionArgs, (address[], uint256[]));
    }

    function __decodeClaimRewardsActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address[] memory assets_)
    {
        return abi.decode(_actionArgs, (address[]));
    }

    function __decodeRemoveCollateralActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address[] memory aTokens_, uint256[] memory amounts_)
    {
        return abi.decode(_actionArgs, (address[], uint256[]));
    }

    function __decodeRepayBorrowActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address[] memory tokens_, uint256[] memory amounts_)
    {
        return abi.decode(_actionArgs, (address[], uint256[]));
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract FundDeployerOwnerMixin {
    address internal immutable FUND_DEPLOYER;

    modifier onlyFundDeployerOwner() {
        require(
            msg.sender == getOwner(),
            "onlyFundDeployerOwner: Only the FundDeployer owner can call this function"
        );
        _;
    }

    constructor(address _fundDeployer) public {
        FUND_DEPLOYER = _fundDeployer;
    }

    function getOwner() public view returns (address owner_) {
        return IFundDeployer(FUND_DEPLOYER).getOwner();
    }


    function getFundDeployer() public view returns (address fundDeployer_) {
        return FUND_DEPLOYER;
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract MathHelpers {
    using SafeMath for uint256;

    function __calcRelativeQuantity(
        uint256 _quantity1,
        uint256 _quantity2,
        uint256 _relativeQuantity1
    ) internal pure returns (uint256 relativeQuantity2_) {
        return _relativeQuantity1.mul(_quantity2).div(_quantity1);
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


abstract contract AggregatedDerivativePriceFeedMixin {
    event DerivativeAdded(address indexed derivative, address priceFeed);

    event DerivativeRemoved(address indexed derivative);

    mapping(address => address) private derivativeToPriceFeed;

    function __calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        internal
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        address derivativePriceFeed = getPriceFeedForDerivative(_derivative);
        require(
            derivativePriceFeed != address(0),
            "calcUnderlyingValues: _derivative is not supported"
        );

        return
            IDerivativePriceFeed(derivativePriceFeed).calcUnderlyingValues(
                _derivative,
                _derivativeAmount
            );
    }


    function __addDerivatives(address[] memory _derivatives, address[] memory _priceFeeds)
        internal
    {
        require(
            _derivatives.length == _priceFeeds.length,
            "__addDerivatives: Unequal _derivatives and _priceFeeds array lengths"
        );

        for (uint256 i = 0; i < _derivatives.length; i++) {
            require(
                getPriceFeedForDerivative(_derivatives[i]) == address(0),
                "__addDerivatives: Already added"
            );

            __validateDerivativePriceFeed(_derivatives[i], _priceFeeds[i]);

            derivativeToPriceFeed[_derivatives[i]] = _priceFeeds[i];

            emit DerivativeAdded(_derivatives[i], _priceFeeds[i]);
        }
    }

    function __removeDerivatives(address[] memory _derivatives) internal {
        for (uint256 i = 0; i < _derivatives.length; i++) {
            require(
                getPriceFeedForDerivative(_derivatives[i]) != address(0),
                "removeDerivatives: Derivative not yet added"
            );

            delete derivativeToPriceFeed[_derivatives[i]];

            emit DerivativeRemoved(_derivatives[i]);
        }
    }


    function __validateDerivativePriceFeed(address _derivative, address _priceFeed) private view {
        require(
            IDerivativePriceFeed(_priceFeed).isSupportedAsset(_derivative),
            "__validateDerivativePriceFeed: Unsupported derivative"
        );
    }


    function getPriceFeedForDerivative(address _derivative)
        public
        view
        returns (address priceFeed_)
    {
        return derivativeToPriceFeed[_derivative];
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IChainlinkAggregator {
    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        );
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract ChainlinkPriceFeedMixin {
    using SafeMath for uint256;

    event EthUsdAggregatorSet(address prevEthUsdAggregator, address nextEthUsdAggregator);

    event PrimitiveAdded(
        address indexed primitive,
        address aggregator,
        RateAsset rateAsset,
        uint256 unit
    );

    event PrimitiveRemoved(address indexed primitive);

    enum RateAsset {ETH, USD}

    struct AggregatorInfo {
        address aggregator;
        RateAsset rateAsset;
    }

    uint256 private constant ETH_UNIT = 10**18;

    uint256 private immutable STALE_RATE_THRESHOLD;
    address private immutable WETH_TOKEN;

    address private ethUsdAggregator;
    mapping(address => AggregatorInfo) private primitiveToAggregatorInfo;
    mapping(address => uint256) private primitiveToUnit;

    constructor(address _wethToken, uint256 _staleRateThreshold) public {
        STALE_RATE_THRESHOLD = _staleRateThreshold;
        WETH_TOKEN = _wethToken;
    }


    function __calcCanonicalValue(
        address _baseAsset,
        uint256 _baseAssetAmount,
        address _quoteAsset
    ) internal view returns (uint256 quoteAssetAmount_) {

        int256 baseAssetRate = __getLatestRateData(_baseAsset);
        require(baseAssetRate > 0, "__calcCanonicalValue: Invalid base asset rate");

        int256 quoteAssetRate = __getLatestRateData(_quoteAsset);
        require(quoteAssetRate > 0, "__calcCanonicalValue: Invalid quote asset rate");

        return
            __calcConversionAmount(
                _baseAsset,
                _baseAssetAmount,
                uint256(baseAssetRate),
                _quoteAsset,
                uint256(quoteAssetRate)
            );
    }

    function __setEthUsdAggregator(address _nextEthUsdAggregator) internal {
        address prevEthUsdAggregator = getEthUsdAggregator();
        require(
            _nextEthUsdAggregator != prevEthUsdAggregator,
            "__setEthUsdAggregator: Value already set"
        );

        __validateAggregator(_nextEthUsdAggregator);

        ethUsdAggregator = _nextEthUsdAggregator;

        emit EthUsdAggregatorSet(prevEthUsdAggregator, _nextEthUsdAggregator);
    }


    function __calcConversionAmount(
        address _baseAsset,
        uint256 _baseAssetAmount,
        uint256 _baseAssetRate,
        address _quoteAsset,
        uint256 _quoteAssetRate
    ) private view returns (uint256 quoteAssetAmount_) {
        RateAsset baseAssetRateAsset = getRateAssetForPrimitive(_baseAsset);
        RateAsset quoteAssetRateAsset = getRateAssetForPrimitive(_quoteAsset);
        uint256 baseAssetUnit = getUnitForPrimitive(_baseAsset);
        uint256 quoteAssetUnit = getUnitForPrimitive(_quoteAsset);

        if (baseAssetRateAsset == quoteAssetRateAsset) {
            return
                __calcConversionAmountSameRateAsset(
                    _baseAssetAmount,
                    baseAssetUnit,
                    _baseAssetRate,
                    quoteAssetUnit,
                    _quoteAssetRate
                );
        }

        (, int256 ethPerUsdRate, , uint256 ethPerUsdRateLastUpdatedAt, ) = IChainlinkAggregator(
            getEthUsdAggregator()
        )
            .latestRoundData();
        require(ethPerUsdRate > 0, "__calcConversionAmount: Bad ethUsd rate");
        __validateRateIsNotStale(ethPerUsdRateLastUpdatedAt);

        if (baseAssetRateAsset == RateAsset.ETH) {
            return
                __calcConversionAmountEthRateAssetToUsdRateAsset(
                    _baseAssetAmount,
                    baseAssetUnit,
                    _baseAssetRate,
                    quoteAssetUnit,
                    _quoteAssetRate,
                    uint256(ethPerUsdRate)
                );
        }

        return
            __calcConversionAmountUsdRateAssetToEthRateAsset(
                _baseAssetAmount,
                baseAssetUnit,
                _baseAssetRate,
                quoteAssetUnit,
                _quoteAssetRate,
                uint256(ethPerUsdRate)
            );
    }

    function __calcConversionAmountEthRateAssetToUsdRateAsset(
        uint256 _baseAssetAmount,
        uint256 _baseAssetUnit,
        uint256 _baseAssetRate,
        uint256 _quoteAssetUnit,
        uint256 _quoteAssetRate,
        uint256 _ethPerUsdRate
    ) private pure returns (uint256 quoteAssetAmount_) {
        uint256 intermediateStep = _baseAssetAmount.mul(_baseAssetRate).mul(_ethPerUsdRate).div(
            ETH_UNIT
        );

        return intermediateStep.mul(_quoteAssetUnit).div(_baseAssetUnit).div(_quoteAssetRate);
    }

    function __calcConversionAmountSameRateAsset(
        uint256 _baseAssetAmount,
        uint256 _baseAssetUnit,
        uint256 _baseAssetRate,
        uint256 _quoteAssetUnit,
        uint256 _quoteAssetRate
    ) private pure returns (uint256 quoteAssetAmount_) {
        return
            _baseAssetAmount.mul(_baseAssetRate).mul(_quoteAssetUnit).div(
                _baseAssetUnit.mul(_quoteAssetRate)
            );
    }

    function __calcConversionAmountUsdRateAssetToEthRateAsset(
        uint256 _baseAssetAmount,
        uint256 _baseAssetUnit,
        uint256 _baseAssetRate,
        uint256 _quoteAssetUnit,
        uint256 _quoteAssetRate,
        uint256 _ethPerUsdRate
    ) private pure returns (uint256 quoteAssetAmount_) {
        uint256 intermediateStep = _baseAssetAmount.mul(_baseAssetRate).mul(_quoteAssetUnit).div(
            _ethPerUsdRate
        );

        return intermediateStep.mul(ETH_UNIT).div(_baseAssetUnit).div(_quoteAssetRate);
    }

    function __getLatestRateData(address _primitive) private view returns (int256 rate_) {
        if (_primitive == getWethToken()) {
            return int256(ETH_UNIT);
        }

        address aggregator = getAggregatorForPrimitive(_primitive);
        require(aggregator != address(0), "__getLatestRateData: Primitive does not exist");

        uint256 rateUpdatedAt;
        (, rate_, , rateUpdatedAt, ) = IChainlinkAggregator(aggregator).latestRoundData();
        __validateRateIsNotStale(rateUpdatedAt);

        return rate_;
    }

    function __validateRateIsNotStale(uint256 _latestUpdatedAt) private view {
        require(
            _latestUpdatedAt >= block.timestamp.sub(getStaleRateThreshold()),
            "__validateRateIsNotStale: Stale rate detected"
        );
    }


    function __addPrimitives(
        address[] calldata _primitives,
        address[] calldata _aggregators,
        RateAsset[] calldata _rateAssets
    ) internal {
        require(
            _primitives.length == _aggregators.length,
            "__addPrimitives: Unequal _primitives and _aggregators array lengths"
        );
        require(
            _primitives.length == _rateAssets.length,
            "__addPrimitives: Unequal _primitives and _rateAssets array lengths"
        );

        for (uint256 i; i < _primitives.length; i++) {
            require(
                getAggregatorForPrimitive(_primitives[i]) == address(0),
                "__addPrimitives: Value already set"
            );

            __validateAggregator(_aggregators[i]);

            primitiveToAggregatorInfo[_primitives[i]] = AggregatorInfo({
                aggregator: _aggregators[i],
                rateAsset: _rateAssets[i]
            });

            uint256 unit = 10**uint256(ERC20(_primitives[i]).decimals());
            primitiveToUnit[_primitives[i]] = unit;

            emit PrimitiveAdded(_primitives[i], _aggregators[i], _rateAssets[i], unit);
        }
    }

    function __removePrimitives(address[] calldata _primitives) internal {
        for (uint256 i; i < _primitives.length; i++) {
            require(
                getAggregatorForPrimitive(_primitives[i]) != address(0),
                "__removePrimitives: Primitive not yet added"
            );

            delete primitiveToAggregatorInfo[_primitives[i]];
            delete primitiveToUnit[_primitives[i]];

            emit PrimitiveRemoved(_primitives[i]);
        }
    }


    function __validateAggregator(address _aggregator) private view {
        (, int256 answer, , uint256 updatedAt, ) = IChainlinkAggregator(_aggregator)
            .latestRoundData();
        require(answer > 0, "__validateAggregator: No rate detected");
        __validateRateIsNotStale(updatedAt);
    }


    function getAggregatorForPrimitive(address _primitive)
        public
        view
        returns (address aggregator_)
    {
        return primitiveToAggregatorInfo[_primitive].aggregator;
    }

    function getEthUsdAggregator() public view returns (address ethUsdAggregator_) {
        return ethUsdAggregator;
    }

    function getRateAssetForPrimitive(address _primitive)
        public
        view
        returns (RateAsset rateAsset_)
    {
        if (_primitive == getWethToken()) {
            return RateAsset.ETH;
        }

        return primitiveToAggregatorInfo[_primitive].rateAsset;
    }

    function getStaleRateThreshold() public view returns (uint256 staleRateThreshold_) {
        return STALE_RATE_THRESHOLD;
    }

    function getUnitForPrimitive(address _primitive) public view returns (uint256 unit_) {
        if (_primitive == getWethToken()) {
            return ETH_UNIT;
        }

        return primitiveToUnit[_primitive];
    }

    function getWethToken() public view returns (address wethToken_) {
        return WETH_TOKEN;
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IValueInterpreter {
    function calcCanonicalAssetValue(
        address,
        uint256,
        address
    ) external returns (uint256);

    function calcCanonicalAssetsTotalValue(
        address[] calldata,
        uint256[] calldata,
        address
    ) external returns (uint256);

    function isSupportedAsset(address) external view returns (bool);

    function isSupportedDerivativeAsset(address) external view returns (bool);

    function isSupportedPrimitiveAsset(address) external view returns (bool);
}// GPL-3.0


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract ValueInterpreter is
    IValueInterpreter,
    FundDeployerOwnerMixin,
    AggregatedDerivativePriceFeedMixin,
    ChainlinkPriceFeedMixin,
    MathHelpers
{
    using SafeMath for uint256;

    uint256 private constant MIN_INVERSE_RATE_AMOUNT = 10000;

    constructor(
        address _fundDeployer,
        address _wethToken,
        uint256 _chainlinkStaleRateThreshold
    )
        public
        FundDeployerOwnerMixin(_fundDeployer)
        ChainlinkPriceFeedMixin(_wethToken, _chainlinkStaleRateThreshold)
    {}


    function calcCanonicalAssetsTotalValue(
        address[] memory _baseAssets,
        uint256[] memory _amounts,
        address _quoteAsset
    ) external override returns (uint256 value_) {
        require(
            _baseAssets.length == _amounts.length,
            "calcCanonicalAssetsTotalValue: Arrays unequal lengths"
        );
        require(
            isSupportedPrimitiveAsset(_quoteAsset),
            "calcCanonicalAssetsTotalValue: Unsupported _quoteAsset"
        );

        for (uint256 i; i < _baseAssets.length; i++) {
            uint256 assetValue = __calcAssetValue(_baseAssets[i], _amounts[i], _quoteAsset);
            value_ = value_.add(assetValue);
        }

        return value_;
    }


    function calcCanonicalAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) external override returns (uint256 value_) {
        if (_baseAsset == _quoteAsset || _amount == 0) {
            return _amount;
        }

        if (isSupportedPrimitiveAsset(_quoteAsset)) {
            return __calcAssetValue(_baseAsset, _amount, _quoteAsset);
        } else if (
            isSupportedDerivativeAsset(_quoteAsset) && isSupportedPrimitiveAsset(_baseAsset)
        ) {
            return __calcPrimitiveToDerivativeValue(_baseAsset, _amount, _quoteAsset);
        }

        revert("calcCanonicalAssetValue: Unsupported conversion");
    }

    function isSupportedAsset(address _asset) public view override returns (bool isSupported_) {
        return isSupportedPrimitiveAsset(_asset) || isSupportedDerivativeAsset(_asset);
    }


    function __calcAssetValue(
        address _baseAsset,
        uint256 _amount,
        address _quoteAsset
    ) private returns (uint256 value_) {
        if (_baseAsset == _quoteAsset || _amount == 0) {
            return _amount;
        }

        if (isSupportedPrimitiveAsset(_baseAsset)) {
            return __calcCanonicalValue(_baseAsset, _amount, _quoteAsset);
        }

        address derivativePriceFeed = getPriceFeedForDerivative(_baseAsset);
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
    ) private returns (uint256 value_) {
        (address[] memory underlyings, uint256[] memory underlyingAmounts) = IDerivativePriceFeed(
            _derivativePriceFeed
        )
            .calcUnderlyingValues(_derivative, _amount);

        require(underlyings.length > 0, "__calcDerivativeValue: No underlyings");
        require(
            underlyings.length == underlyingAmounts.length,
            "__calcDerivativeValue: Arrays unequal lengths"
        );

        for (uint256 i = 0; i < underlyings.length; i++) {
            uint256 underlyingValue = __calcAssetValue(
                underlyings[i],
                underlyingAmounts[i],
                _quoteAsset
            );

            value_ = value_.add(underlyingValue);
        }
    }

    function __calcPrimitiveToDerivativeValue(
        address _primitiveBaseAsset,
        uint256 _primitiveBaseAssetAmount,
        address _derivativeQuoteAsset
    ) private returns (uint256 value_) {
        uint256 derivativeUnit = 10**uint256(ERC20(_derivativeQuoteAsset).decimals());

        address derivativePriceFeed = getPriceFeedForDerivative(_derivativeQuoteAsset);
        uint256 primitiveAmountForDerivativeUnit = __calcDerivativeValue(
            derivativePriceFeed,
            _derivativeQuoteAsset,
            derivativeUnit,
            _primitiveBaseAsset
        );
        require(
            primitiveAmountForDerivativeUnit > MIN_INVERSE_RATE_AMOUNT,
            "__calcPrimitiveToDerivativeValue: Insufficient rate"
        );

        return
            __calcRelativeQuantity(
                primitiveAmountForDerivativeUnit.add(1),
                derivativeUnit,
                _primitiveBaseAssetAmount
            );
    }


    function addPrimitives(
        address[] calldata _primitives,
        address[] calldata _aggregators,
        RateAsset[] calldata _rateAssets
    ) external onlyFundDeployerOwner {
        __addPrimitives(_primitives, _aggregators, _rateAssets);
    }

    function removePrimitives(address[] calldata _primitives) external onlyFundDeployerOwner {
        __removePrimitives(_primitives);
    }

    function setEthUsdAggregator(address _nextEthUsdAggregator) external onlyFundDeployerOwner {
        __setEthUsdAggregator(_nextEthUsdAggregator);
    }

    function updatePrimitives(
        address[] calldata _primitives,
        address[] calldata _aggregators,
        RateAsset[] calldata _rateAssets
    ) external onlyFundDeployerOwner {
        __removePrimitives(_primitives);
        __addPrimitives(_primitives, _aggregators, _rateAssets);
    }


    function isSupportedPrimitiveAsset(address _asset)
        public
        view
        override
        returns (bool isSupported_)
    {
        return _asset == getWethToken() || getAggregatorForPrimitive(_asset) != address(0);
    }


    function addDerivatives(address[] calldata _derivatives, address[] calldata _priceFeeds)
        external
        onlyFundDeployerOwner
    {
        __addDerivatives(_derivatives, _priceFeeds);
    }

    function removeDerivatives(address[] calldata _derivatives) external onlyFundDeployerOwner {
        __removeDerivatives(_derivatives);
    }

    function updateDerivatives(address[] calldata _derivatives, address[] calldata _priceFeeds)
        external
        onlyFundDeployerOwner
    {
        __removeDerivatives(_derivatives);
        __addDerivatives(_derivatives, _priceFeeds);
    }


    function isSupportedDerivativeAsset(address _asset)
        public
        view
        override
        returns (bool isSupported_)
    {
        return getPriceFeedForDerivative(_asset) != address(0);
    }
}// GPL-3.0



pragma solidity 0.6.12;

interface IAaveDebtPosition is IExternalPosition {
    enum Actions {AddCollateral, RemoveCollateral, Borrow, RepayBorrow, ClaimRewards}

    function getDebtTokenForBorrowedAsset(address) external view returns (address);
}// GPL-3.0



pragma solidity 0.6.12;

contract AaveDebtPositionParser is IExternalPositionParser, AaveDebtPositionDataDecoder {
    address private immutable VALUE_INTERPRETER;

    constructor(address _valueInterpreter) public {
        VALUE_INTERPRETER = _valueInterpreter;
    }

    function parseAssetsForAction(
        address _externalPosition,
        uint256 _actionId,
        bytes memory _encodedActionArgs
    )
        external
        override
        returns (
            address[] memory assetsToTransfer_,
            uint256[] memory amountsToTransfer_,
            address[] memory assetsToReceive_
        )
    {
        if (_actionId == uint256(IAaveDebtPosition.Actions.AddCollateral)) {
            (assetsToTransfer_, amountsToTransfer_) = __decodeAddCollateralActionArgs(
                _encodedActionArgs
            );
            __validateSupportedAssets(assetsToTransfer_);
        } else if (_actionId == uint256(IAaveDebtPosition.Actions.Borrow)) {
            (assetsToReceive_, ) = __decodeBorrowActionArgs(_encodedActionArgs);
            __validateSupportedAssets(assetsToReceive_);
        } else if (_actionId == uint256(IAaveDebtPosition.Actions.RemoveCollateral)) {
            (assetsToReceive_, ) = __decodeRemoveCollateralActionArgs(_encodedActionArgs);
        } else if (_actionId == uint256(IAaveDebtPosition.Actions.RepayBorrow)) {
            (assetsToTransfer_, amountsToTransfer_) = __decodeRepayBorrowActionArgs(
                _encodedActionArgs
            );

            for (uint256 i; i < assetsToTransfer_.length; i++) {
                if (amountsToTransfer_[i] == type(uint256).max) {
                    address debtToken = IAaveDebtPosition(_externalPosition)
                        .getDebtTokenForBorrowedAsset(assetsToTransfer_[i]);
                    amountsToTransfer_[i] = ERC20(debtToken).balanceOf(_externalPosition);
                }
            }
        }


        return (assetsToTransfer_, amountsToTransfer_, assetsToReceive_);
    }

    function parseInitArgs(address, bytes memory) external override returns (bytes memory) {}

    function __validateSupportedAssets(address[] memory _assets) private view {
        for (uint256 i; i < _assets.length; i++) {
            require(
                IValueInterpreter(VALUE_INTERPRETER).isSupportedAsset(_assets[i]),
                "__validateSupportedAssets: Unsupported asset"
            );
        }
    }
}