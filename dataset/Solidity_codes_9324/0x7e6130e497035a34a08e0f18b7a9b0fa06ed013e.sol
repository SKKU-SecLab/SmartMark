
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

interface IDerivativePriceFeed {
    function calcUnderlyingValues(address, uint256)
        external
        returns (address[] memory, uint256[] memory);

    function isSupportedAsset(address) external view returns (bool);
}// GPL-3.0


pragma solidity 0.6.12;

interface ICurveAddressProvider {
    function get_address(uint256) external view returns (address);

    function get_registry() external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;

interface ICurveLiquidityPool {
    function coins(int128) external view returns (address);

    function coins(uint256) external view returns (address);

    function get_virtual_price() external view returns (uint256);

    function underlying_coins(int128) external view returns (address);

    function underlying_coins(uint256) external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;

interface ICurvePoolOwner {
    function withdraw_admin_fees(address) external;
}// GPL-3.0


pragma solidity 0.6.12;

interface ICurveRegistryMain {
    function get_gauges(address) external view returns (address[10] memory, int128[10] memory);

    function get_lp_token(address) external view returns (address);
}// GPL-3.0


pragma solidity 0.6.12;

interface ICurveRegistryMetapoolFactory {
    function get_gauge(address) external view returns (address);

    function get_n_coins(address) external view returns (uint256);
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
pragma experimental ABIEncoderV2;


contract CurvePriceFeed is IDerivativePriceFeed, FundDeployerOwnerMixin {
    using SafeMath for uint256;

    event CurvePoolOwnerSet(address poolOwner);

    event DerivativeAdded(address indexed derivative, address indexed pool);

    event DerivativeRemoved(address indexed derivative);

    event InvariantProxyAssetForPoolSet(address indexed pool, address indexed invariantProxyAsset);

    event PoolRemoved(address indexed pool);

    event ValidatedVirtualPriceForPoolUpdated(address indexed pool, uint256 virtualPrice);

    uint256 private constant ADDRESS_PROVIDER_METAPOOL_FACTORY_ID = 3;
    uint256 private constant VIRTUAL_PRICE_DEVIATION_DIVISOR = 10000;
    uint256 private constant VIRTUAL_PRICE_UNIT = 10**18;

    ICurveAddressProvider private immutable ADDRESS_PROVIDER_CONTRACT;
    uint256 private immutable VIRTUAL_PRICE_DEVIATION_THRESHOLD;

    struct PoolInfo {
        address invariantProxyAsset; // 20 bytes
        uint8 invariantProxyAssetDecimals; // 1 byte
        uint88 lastValidatedVirtualPrice; // 11 bytes (could safely be 8-10 bytes)
    }

    address private curvePoolOwner;

    mapping(address => address) private derivativeToPool;
    mapping(address => PoolInfo) private poolToPoolInfo;

    mapping(address => address) private poolToLpToken;

    constructor(
        address _fundDeployer,
        address _addressProvider,
        address _poolOwner,
        uint256 _virtualPriceDeviationThreshold
    ) public FundDeployerOwnerMixin(_fundDeployer) {
        ADDRESS_PROVIDER_CONTRACT = ICurveAddressProvider(_addressProvider);
        VIRTUAL_PRICE_DEVIATION_THRESHOLD = _virtualPriceDeviationThreshold;

        __setCurvePoolOwner(_poolOwner);
    }

    function calcUnderlyingValues(address _derivative, uint256 _derivativeAmount)
        external
        override
        returns (address[] memory underlyings_, uint256[] memory underlyingAmounts_)
    {
        address pool = getPoolForDerivative(_derivative);
        require(pool != address(0), "calcUnderlyingValues: _derivative is not supported");

        PoolInfo memory poolInfo = getPoolInfo(pool);

        uint256 virtualPrice = ICurveLiquidityPool(pool).get_virtual_price();

        if (
            poolInfo.lastValidatedVirtualPrice > 0 &&
            __virtualPriceDiffExceedsThreshold(
                virtualPrice,
                uint256(poolInfo.lastValidatedVirtualPrice)
            )
        ) {
            __updateValidatedVirtualPrice(pool, virtualPrice);
        }

        underlyings_ = new address[](1);
        underlyings_[0] = poolInfo.invariantProxyAsset;

        underlyingAmounts_ = new uint256[](1);
        if (poolInfo.invariantProxyAssetDecimals == 18) {
            underlyingAmounts_[0] = _derivativeAmount.mul(virtualPrice).div(VIRTUAL_PRICE_UNIT);
        } else {
            underlyingAmounts_[0] = _derivativeAmount
                .mul(virtualPrice)
                .mul(10**uint256(poolInfo.invariantProxyAssetDecimals))
                .div(VIRTUAL_PRICE_UNIT)
                .div(VIRTUAL_PRICE_UNIT);
        }

        return (underlyings_, underlyingAmounts_);
    }

    function isSupportedAsset(address _asset) external view override returns (bool isSupported_) {
        return getPoolForDerivative(_asset) != address(0);
    }



    function addGaugeTokens(address[] calldata _gaugeTokens, address[] calldata _pools)
        external
        onlyFundDeployerOwner
    {
        ICurveRegistryMain registryContract = __getRegistryMainContract();
        ICurveRegistryMetapoolFactory factoryContract = __getRegistryMetapoolFactoryContract();

        for (uint256 i; i < _gaugeTokens.length; i++) {
            if (factoryContract.get_gauge(_pools[i]) != _gaugeTokens[i]) {
                __validateGaugeMainRegistry(_gaugeTokens[i], _pools[i], registryContract);
            }
        }

        __addGaugeTokens(_gaugeTokens, _pools);
    }

    function addGaugeTokensWithoutValidation(
        address[] calldata _gaugeTokens,
        address[] calldata _pools
    ) external onlyFundDeployerOwner {
        __addGaugeTokens(_gaugeTokens, _pools);
    }

    function addPools(
        address[] calldata _pools,
        address[] calldata _invariantProxyAssets,
        bool[] calldata _reentrantVirtualPrices,
        address[] calldata _lpTokens,
        address[] calldata _gaugeTokens
    ) external onlyFundDeployerOwner {
        ICurveRegistryMain registryContract = __getRegistryMainContract();
        ICurveRegistryMetapoolFactory factoryContract = __getRegistryMetapoolFactoryContract();

        for (uint256 i; i < _pools.length; i++) {
            if (_lpTokens[i] == registryContract.get_lp_token(_pools[i])) {

                if (_gaugeTokens[i] != address(0)) {
                    __validateGaugeMainRegistry(_gaugeTokens[i], _pools[i], registryContract);
                }
            } else if (_lpTokens[i] == _pools[i] && factoryContract.get_n_coins(_pools[i]) > 0) {

                if (_gaugeTokens[i] != address(0)) {
                    __validateGaugeMetapoolFactoryRegistry(
                        _gaugeTokens[i],
                        _pools[i],
                        factoryContract
                    );
                }
            } else {
                revert("addPools: Invalid inputs");
            }
        }

        __addPools(
            _pools,
            _invariantProxyAssets,
            _reentrantVirtualPrices,
            _lpTokens,
            _gaugeTokens
        );
    }

    function addPoolsWithoutValidation(
        address[] calldata _pools,
        address[] calldata _invariantProxyAssets,
        bool[] calldata _reentrantVirtualPrices,
        address[] calldata _lpTokens,
        address[] calldata _gaugeTokens
    ) external onlyFundDeployerOwner {
        __addPools(
            _pools,
            _invariantProxyAssets,
            _reentrantVirtualPrices,
            _lpTokens,
            _gaugeTokens
        );
    }

    function removeDerivatives(address[] calldata _derivatives) external onlyFundDeployerOwner {
        for (uint256 i; i < _derivatives.length; i++) {
            delete derivativeToPool[_derivatives[i]];

            emit DerivativeRemoved(_derivatives[i]);
        }
    }

    function removePools(address[] calldata _pools) external onlyFundDeployerOwner {
        for (uint256 i; i < _pools.length; i++) {
            delete poolToPoolInfo[_pools[i]];
            delete poolToLpToken[_pools[i]];

            emit PoolRemoved(_pools[i]);
        }
    }

    function setCurvePoolOwner(address _nextPoolOwner) external onlyFundDeployerOwner {
        __setCurvePoolOwner(_nextPoolOwner);
    }

    function updatePoolInfo(
        address[] calldata _pools,
        address[] calldata _invariantProxyAssets,
        bool[] calldata _reentrantVirtualPrices
    ) external onlyFundDeployerOwner {
        require(
            _pools.length == _invariantProxyAssets.length &&
                _pools.length == _reentrantVirtualPrices.length,
            "updatePoolInfo: Unequal arrays"
        );

        for (uint256 i; i < _pools.length; i++) {
            __setPoolInfo(_pools[i], _invariantProxyAssets[i], _reentrantVirtualPrices[i]);
        }
    }


    function __addDerivative(address _derivative, address _pool) private {
        require(
            getPoolForDerivative(_derivative) == address(0),
            "__addDerivative: Already exists"
        );

        require(ERC20(_derivative).decimals() == 18, "__addDerivative: Not 18-decimal");

        derivativeToPool[_derivative] = _pool;

        emit DerivativeAdded(_derivative, _pool);
    }

    function __addGaugeTokens(address[] calldata _gaugeTokens, address[] calldata _pools) private {
        require(_gaugeTokens.length == _pools.length, "__addGaugeTokens: Unequal arrays");

        for (uint256 i; i < _gaugeTokens.length; i++) {
            require(
                getLpTokenForPool(_pools[i]) != address(0),
                "__addGaugeTokens: Pool not registered"
            );

            __addDerivative(_gaugeTokens[i], _pools[i]);
        }
    }

    function __addPools(
        address[] calldata _pools,
        address[] calldata _invariantProxyAssets,
        bool[] calldata _reentrantVirtualPrices,
        address[] calldata _lpTokens,
        address[] calldata _gaugeTokens
    ) private {
        require(
            _pools.length == _invariantProxyAssets.length &&
                _pools.length == _reentrantVirtualPrices.length &&
                _pools.length == _lpTokens.length &&
                _pools.length == _gaugeTokens.length,
            "__addPools: Unequal arrays"
        );

        for (uint256 i; i < _pools.length; i++) {
            require(_lpTokens[i] != address(0), "__addPools: Empty lpToken");

            require(getLpTokenForPool(_pools[i]) == address(0), "__addPools: Already registered");
            __validatePoolCompatibility(_pools[i]);

            __setPoolInfo(_pools[i], _invariantProxyAssets[i], _reentrantVirtualPrices[i]);
            poolToLpToken[_pools[i]] = _lpTokens[i];

            __addDerivative(_lpTokens[i], _pools[i]);
            if (_gaugeTokens[i] != address(0)) {
                __addDerivative(_gaugeTokens[i], _pools[i]);
            }
        }
    }

    function __getRegistryMainContract() private view returns (ICurveRegistryMain contract_) {
        return ICurveRegistryMain(ADDRESS_PROVIDER_CONTRACT.get_registry());
    }

    function __getRegistryMetapoolFactoryContract()
        private
        view
        returns (ICurveRegistryMetapoolFactory contract_)
    {
        return
            ICurveRegistryMetapoolFactory(
                ADDRESS_PROVIDER_CONTRACT.get_address(ADDRESS_PROVIDER_METAPOOL_FACTORY_ID)
            );
    }

    function __makeNonReentrantPoolCall(address _pool) private {
        ICurvePoolOwner(getCurvePoolOwner()).withdraw_admin_fees(_pool);
    }

    function __setCurvePoolOwner(address _nextPoolOwner) private {
        curvePoolOwner = _nextPoolOwner;

        emit CurvePoolOwnerSet(_nextPoolOwner);
    }

    function __setPoolInfo(
        address _pool,
        address _invariantProxyAsset,
        bool _reentrantVirtualPrice
    ) private {
        uint256 lastValidatedVirtualPrice;
        if (_reentrantVirtualPrice) {
            __makeNonReentrantPoolCall(_pool);

            lastValidatedVirtualPrice = ICurveLiquidityPool(_pool).get_virtual_price();

            emit ValidatedVirtualPriceForPoolUpdated(_pool, lastValidatedVirtualPrice);
        }

        poolToPoolInfo[_pool] = PoolInfo({
            invariantProxyAsset: _invariantProxyAsset,
            invariantProxyAssetDecimals: ERC20(_invariantProxyAsset).decimals(),
            lastValidatedVirtualPrice: uint88(lastValidatedVirtualPrice)
        });

        emit InvariantProxyAssetForPoolSet(_pool, _invariantProxyAsset);
    }

    function __updateValidatedVirtualPrice(address _pool, uint256 _virtualPrice) private {
        __makeNonReentrantPoolCall(_pool);

        poolToPoolInfo[_pool].lastValidatedVirtualPrice = uint88(_virtualPrice);

        emit ValidatedVirtualPriceForPoolUpdated(_pool, _virtualPrice);
    }

    function __validateGaugeMainRegistry(
        address _gauge,
        address _pool,
        ICurveRegistryMain _mainRegistryContract
    ) private view {
        (address[10] memory gauges, ) = _mainRegistryContract.get_gauges(_pool);
        for (uint256 i; i < gauges.length; i++) {
            if (_gauge == gauges[i]) {
                return;
            }
        }

        revert("__validateGaugeMainRegistry: Invalid gauge");
    }

    function __validateGaugeMetapoolFactoryRegistry(
        address _gauge,
        address _pool,
        ICurveRegistryMetapoolFactory _metapoolFactoryRegistryContract
    ) private view {
        require(
            _gauge == _metapoolFactoryRegistryContract.get_gauge(_pool),
            "__validateGaugeMetapoolFactoryRegistry: Invalid gauge"
        );
    }

    function __validatePoolCompatibility(address _pool) private view {
        require(
            ICurveLiquidityPool(_pool).get_virtual_price() > 0,
            "__validatePoolCompatibility: Incompatible"
        );
    }

    function __virtualPriceDiffExceedsThreshold(
        uint256 _currentVirtualPrice,
        uint256 _lastValidatedVirtualPrice
    ) private view returns (bool exceedsThreshold_) {
        uint256 absDiff;
        if (_currentVirtualPrice > _lastValidatedVirtualPrice) {
            absDiff = _currentVirtualPrice.sub(_lastValidatedVirtualPrice);
        } else {
            absDiff = _lastValidatedVirtualPrice.sub(_currentVirtualPrice);
        }

        return
            absDiff >
            _lastValidatedVirtualPrice.mul(VIRTUAL_PRICE_DEVIATION_THRESHOLD).div(
                VIRTUAL_PRICE_DEVIATION_DIVISOR
            );
    }


    function getCurvePoolOwner() public view returns (address poolOwner_) {
        return curvePoolOwner;
    }

    function getLpTokenForPool(address _pool) public view returns (address lpToken_) {
        return poolToLpToken[_pool];
    }

    function getPoolInfo(address _pool) public view returns (PoolInfo memory poolInfo_) {
        return poolToPoolInfo[_pool];
    }

    function getPoolForDerivative(address _derivative) public view returns (address pool_) {
        return derivativeToPool[_derivative];
    }
}