
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity ^0.6.0;

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

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.6.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// GPL-3.0


pragma solidity 0.6.12;

interface IDispatcher {
    function cancelMigration(address _vaultProxy, bool _bypassFailure) external;

    function claimOwnership() external;

    function deployVaultProxy(
        address _vaultLib,
        address _owner,
        address _vaultAccessor,
        string calldata _fundName
    ) external returns (address vaultProxy_);

    function executeMigration(address _vaultProxy, bool _bypassFailure) external;

    function getCurrentFundDeployer() external view returns (address currentFundDeployer_);

    function getFundDeployerForVaultProxy(address _vaultProxy)
        external
        view
        returns (address fundDeployer_);

    function getMigrationRequestDetailsForVaultProxy(address _vaultProxy)
        external
        view
        returns (
            address nextFundDeployer_,
            address nextVaultAccessor_,
            address nextVaultLib_,
            uint256 executableTimestamp_
        );

    function getMigrationTimelock() external view returns (uint256 migrationTimelock_);

    function getNominatedOwner() external view returns (address nominatedOwner_);

    function getOwner() external view returns (address owner_);

    function getSharesTokenSymbol() external view returns (string memory sharesTokenSymbol_);

    function getTimelockRemainingForMigrationRequest(address _vaultProxy)
        external
        view
        returns (uint256 secondsRemaining_);

    function hasExecutableMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasExecutableRequest_);

    function hasMigrationRequest(address _vaultProxy)
        external
        view
        returns (bool hasMigrationRequest_);

    function removeNominatedOwner() external;

    function setCurrentFundDeployer(address _nextFundDeployer) external;

    function setMigrationTimelock(uint256 _nextTimelock) external;

    function setNominatedOwner(address _nextNominatedOwner) external;

    function setSharesTokenSymbol(string calldata _nextSymbol) external;

    function signalMigration(
        address _vaultProxy,
        address _nextVaultAccessor,
        address _nextVaultLib,
        bool _bypassFailure
    ) external;
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

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        );

    function kLast() external view returns (uint256);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint256);
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

    function __calcNormalizedRate(
        uint256 _baseAssetDecimals,
        uint256 _baseAssetAmount,
        uint256 _quoteAssetDecimals,
        uint256 _quoteAssetAmount
    ) internal pure returns (uint256 normalizedRate_) {
        return
            _quoteAssetAmount.mul(10**_baseAssetDecimals.add(18)).div(
                _baseAssetAmount.mul(10**_quoteAssetDecimals)
            );
    }
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract DispatcherOwnerMixin {
    address internal immutable DISPATCHER;

    modifier onlyDispatcherOwner() {
        require(
            msg.sender == getOwner(),
            "onlyDispatcherOwner: Only the Dispatcher owner can call this function"
        );
        _;
    }

    constructor(address _dispatcher) public {
        DISPATCHER = _dispatcher;
    }

    function getOwner() public view returns (address owner_) {
        return IDispatcher(DISPATCHER).getOwner();
    }


    function getDispatcher() external view returns (address dispatcher_) {
        return DISPATCHER;
    }
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
}// GPL-3.0


pragma solidity 0.6.12;

interface IUniswapV2Factory {
    function feeTo() external view returns (address);

    function getPair(address, address) external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;


abstract contract UniswapV2PoolTokenValueCalculator {
    using SafeMath for uint256;

    uint256 private constant POOL_TOKEN_UNIT = 10**18;


    function __calcTrustedPoolTokenValue(
        address _factory,
        address _pair,
        uint256 _token0TrustedRateAmount,
        uint256 _token1TrustedRateAmount
    ) internal view returns (uint256 token0Amount_, uint256 token1Amount_) {
        (uint256 reserve0, uint256 reserve1) = __calcReservesAfterArbitrage(
            _pair,
            _token0TrustedRateAmount,
            _token1TrustedRateAmount
        );

        return __calcPoolTokenValue(_factory, _pair, reserve0, reserve1);
    }


    function __calcPoolTokenValue(
        address _factory,
        address _pair,
        uint256 _reserve0,
        uint256 _reserve1
    ) private view returns (uint256 token0Amount_, uint256 token1Amount_) {
        IUniswapV2Pair pairContract = IUniswapV2Pair(_pair);
        uint256 totalSupply = pairContract.totalSupply();

        if (IUniswapV2Factory(_factory).feeTo() != address(0)) {
            uint256 kLast = pairContract.kLast();
            if (kLast > 0) {
                uint256 rootK = __uniswapSqrt(_reserve0.mul(_reserve1));
                uint256 rootKLast = __uniswapSqrt(kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply.mul(rootK.sub(rootKLast));
                    uint256 denominator = rootK.mul(5).add(rootKLast);
                    uint256 feeLiquidity = numerator.div(denominator);
                    totalSupply = totalSupply.add(feeLiquidity);
                }
            }
        }
        return (
            _reserve0.mul(POOL_TOKEN_UNIT).div(totalSupply),
            _reserve1.mul(POOL_TOKEN_UNIT).div(totalSupply)
        );
    }

    function __calcProfitMaximizingTrade(
        uint256 _token0TrustedRateAmount,
        uint256 _token1TrustedRateAmount,
        uint256 _reserve0,
        uint256 _reserve1
    ) private pure returns (bool token0ToToken1_, uint256 amountIn_) {
        token0ToToken1_ =
            _reserve0.mul(_token1TrustedRateAmount).div(_reserve1) < _token0TrustedRateAmount;

        uint256 leftSide;
        uint256 rightSide;
        if (token0ToToken1_) {
            leftSide = __uniswapSqrt(
                _reserve0.mul(_reserve1).mul(_token0TrustedRateAmount).mul(1000).div(
                    _token1TrustedRateAmount.mul(997)
                )
            );
            rightSide = _reserve0.mul(1000).div(997);
        } else {
            leftSide = __uniswapSqrt(
                _reserve0.mul(_reserve1).mul(_token1TrustedRateAmount).mul(1000).div(
                    _token0TrustedRateAmount.mul(997)
                )
            );
            rightSide = _reserve1.mul(1000).div(997);
        }

        if (leftSide < rightSide) {
            return (false, 0);
        }

        amountIn_ = leftSide.sub(rightSide);

        return (token0ToToken1_, amountIn_);
    }

    function __calcReservesAfterArbitrage(
        address _pair,
        uint256 _token0TrustedRateAmount,
        uint256 _token1TrustedRateAmount
    ) private view returns (uint256 reserve0_, uint256 reserve1_) {
        (reserve0_, reserve1_, ) = IUniswapV2Pair(_pair).getReserves();


        (bool token0ToToken1, uint256 amountIn) = __calcProfitMaximizingTrade(
            _token0TrustedRateAmount,
            _token1TrustedRateAmount,
            reserve0_,
            reserve1_
        );
        if (amountIn == 0) {
            return (reserve0_, reserve1_);
        }

        if (token0ToToken1) {
            uint256 amountOut = __uniswapV2GetAmountOut(amountIn, reserve0_, reserve1_);
            reserve0_ = reserve0_.add(amountIn);
            reserve1_ = reserve1_.sub(amountOut);
        } else {
            uint256 amountOut = __uniswapV2GetAmountOut(amountIn, reserve1_, reserve0_);
            reserve1_ = reserve1_.add(amountIn);
            reserve0_ = reserve0_.sub(amountOut);
        }

        return (reserve0_, reserve1_);
    }

    function __uniswapSqrt(uint256 _y) private pure returns (uint256 z_) {
        if (_y > 3) {
            z_ = _y;
            uint256 x = _y / 2 + 1;
            while (x < z_) {
                z_ = x;
                x = (_y / x + x) / 2;
            }
        } else if (_y != 0) {
            z_ = 1;
        }

        return z_;
    }

    function __uniswapV2GetAmountOut(
        uint256 _amountIn,
        uint256 _reserveIn,
        uint256 _reserveOut
    ) private pure returns (uint256 amountOut_) {
        uint256 amountInWithFee = _amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(_reserveOut);
        uint256 denominator = _reserveIn.mul(1000).add(amountInWithFee);

        return numerator.div(denominator);
    }
}// GPL-3.0


pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


contract UniswapV2PoolPriceFeed is
    IDerivativePriceFeed,
    DispatcherOwnerMixin,
    MathHelpers,
    UniswapV2PoolTokenValueCalculator
{
    event PoolTokenAdded(address indexed poolToken, address token0, address token1);

    struct PoolTokenInfo {
        address token0;
        address token1;
        uint8 token0Decimals;
        uint8 token1Decimals;
    }

    uint256 private constant POOL_TOKEN_UNIT = 10**18;
    address private immutable DERIVATIVE_PRICE_FEED;
    address private immutable FACTORY;
    address private immutable PRIMITIVE_PRICE_FEED;
    address private immutable VALUE_INTERPRETER;

    mapping(address => PoolTokenInfo) private poolTokenToInfo;

    constructor(
        address _dispatcher,
        address _derivativePriceFeed,
        address _primitivePriceFeed,
        address _valueInterpreter,
        address _factory,
        address[] memory _poolTokens
    ) public DispatcherOwnerMixin(_dispatcher) {
        DERIVATIVE_PRICE_FEED = _derivativePriceFeed;
        FACTORY = _factory;
        PRIMITIVE_PRICE_FEED = _primitivePriceFeed;
        VALUE_INTERPRETER = _valueInterpreter;

        __addPoolTokens(_poolTokens, _derivativePriceFeed, _primitivePriceFeed);
    }

    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        PoolTokenInfo memory poolTokenInfo = poolTokenToInfo[_derivative];

        underlyings_ = new address[](2);
        underlyings_[0] = poolTokenInfo.token0;
        underlyings_[1] = poolTokenInfo.token1;

        (uint256 token0TrustedRateAmount, uint256 token1TrustedRateAmount) = __calcTrustedRate(
            poolTokenInfo.token0,
            poolTokenInfo.token1,
            poolTokenInfo.token0Decimals,
            poolTokenInfo.token1Decimals
        );

        (
            uint256 token0DenormalizedRate,
            uint256 token1DenormalizedRate
        ) = __calcTrustedPoolTokenValue(
            FACTORY,
            _derivative,
            token0TrustedRateAmount,
            token1TrustedRateAmount
        );

        underlyingAmounts_ = new uint256[](2);
        underlyingAmounts_[0] = _derivativeAmount.mul(token0DenormalizedRate).div(POOL_TOKEN_UNIT);
        underlyingAmounts_[1] = _derivativeAmount.mul(token1DenormalizedRate).div(POOL_TOKEN_UNIT);

        return (underlyings_, underlyingAmounts_);
    }

    function isSupportedAsset(address _asset) public view override returns (bool isSupported_) {
        return poolTokenToInfo[_asset].token0 != address(0);
    }


    function __calcTrustedRate(
        address _token0,
        address _token1,
        uint256 _token0Decimals,
        uint256 _token1Decimals
    ) private returns (uint256 token0RateAmount_, uint256 token1RateAmount_) {
        bool rateIsValid;
        if (IPrimitivePriceFeed(PRIMITIVE_PRICE_FEED).isSupportedAsset(_token0)) {
            token1RateAmount_ = 10**_token1Decimals;
            (token0RateAmount_, rateIsValid) = ValueInterpreter(VALUE_INTERPRETER)
                .calcCanonicalAssetValue(_token1, token1RateAmount_, _token0);
        } else {
            token0RateAmount_ = 10**_token0Decimals;
            (token1RateAmount_, rateIsValid) = ValueInterpreter(VALUE_INTERPRETER)
                .calcCanonicalAssetValue(_token0, token0RateAmount_, _token1);
        }

        require(rateIsValid, "__calcTrustedRate: Invalid rate");

        return (token0RateAmount_, token1RateAmount_);
    }


    function addPoolTokens(address[] calldata _poolTokens) external onlyDispatcherOwner {
        require(_poolTokens.length > 0, "addPoolTokens: Empty _poolTokens");

        __addPoolTokens(_poolTokens, DERIVATIVE_PRICE_FEED, PRIMITIVE_PRICE_FEED);
    }

    function __addPoolTokens(
        address[] memory _poolTokens,
        address _derivativePriceFeed,
        address _primitivePriceFeed
    ) private {
        for (uint256 i; i < _poolTokens.length; i++) {
            require(_poolTokens[i] != address(0), "__addPoolTokens: Empty poolToken");
            require(
                poolTokenToInfo[_poolTokens[i]].token0 == address(0),
                "__addPoolTokens: Value already set"
            );

            IUniswapV2Pair uniswapV2Pair = IUniswapV2Pair(_poolTokens[i]);
            address token0 = uniswapV2Pair.token0();
            address token1 = uniswapV2Pair.token1();

            require(
                __poolTokenIsSupportable(
                    _derivativePriceFeed,
                    _primitivePriceFeed,
                    token0,
                    token1
                ),
                "__addPoolTokens: Unsupported pool token"
            );

            poolTokenToInfo[_poolTokens[i]] = PoolTokenInfo({
                token0: token0,
                token1: token1,
                token0Decimals: ERC20(token0).decimals(),
                token1Decimals: ERC20(token1).decimals()
            });

            emit PoolTokenAdded(_poolTokens[i], token0, token1);
        }
    }

    function __poolTokenIsSupportable(
        address _derivativePriceFeed,
        address _primitivePriceFeed,
        address _token0,
        address _token1
    ) private view returns (bool isSupportable_) {
        IDerivativePriceFeed derivativePriceFeedContract = IDerivativePriceFeed(
            _derivativePriceFeed
        );
        IPrimitivePriceFeed primitivePriceFeedContract = IPrimitivePriceFeed(_primitivePriceFeed);

        if (primitivePriceFeedContract.isSupportedAsset(_token0)) {
            if (
                primitivePriceFeedContract.isSupportedAsset(_token1) ||
                derivativePriceFeedContract.isSupportedAsset(_token1)
            ) {
                return true;
            }
        } else if (
            derivativePriceFeedContract.isSupportedAsset(_token0) &&
            primitivePriceFeedContract.isSupportedAsset(_token1)
        ) {
            return true;
        }

        return false;
    }


    function getDerivativePriceFeed() external view returns (address derivativePriceFeed_) {
        return DERIVATIVE_PRICE_FEED;
    }

    function getFactory() external view returns (address factory_) {
        return FACTORY;
    }

    function getPoolTokenInfo(address _poolToken)
        external
        view
        returns (PoolTokenInfo memory poolTokenInfo_)
    {
        return poolTokenToInfo[_poolToken];
    }

    function getPoolTokenUnderlyings(address _poolToken)
        external
        view
        returns (address token0_, address token1_)
    {
        return (poolTokenToInfo[_poolToken].token0, poolTokenToInfo[_poolToken].token1);
    }

    function getPrimitivePriceFeed() external view returns (address primitivePriceFeed_) {
        return PRIMITIVE_PRICE_FEED;
    }

    function getValueInterpreter() external view returns (address valueInterpreter_) {
        return VALUE_INTERPRETER;
    }
}