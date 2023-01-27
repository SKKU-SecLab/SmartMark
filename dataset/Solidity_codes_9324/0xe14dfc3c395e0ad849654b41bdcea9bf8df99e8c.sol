


pragma solidity 0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initOwner) {
        _setOwner(initOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: The caller is not the owner!");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: Use the renounceOwnership method to set the zero address as the owner!");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV3PoolImmutables {

    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function fee() external view returns (uint24);


    function tickSpacing() external view returns (int24);


    function maxLiquidityPerTick() external view returns (uint128);

}

interface IUniswapV3PoolState {

    function slot0()
    external
    view
    returns (
        uint160 sqrtPriceX96,
        int24 tick,
        uint16 observationIndex,
        uint16 observationCardinality,
        uint16 observationCardinalityNext,
        uint8 feeProtocol,
        bool unlocked
    );


    function feeGrowthGlobal0X128() external view returns (uint256);


    function feeGrowthGlobal1X128() external view returns (uint256);


    function protocolFees() external view returns (uint128 token0, uint128 token1);


    function liquidity() external view returns (uint128);


    function ticks(int24 tick)
    external
    view
    returns (
        uint128 liquidityGross,
        int128 liquidityNet,
        uint256 feeGrowthOutside0X128,
        uint256 feeGrowthOutside1X128,
        int56 tickCumulativeOutside,
        uint160 secondsPerLiquidityOutsideX128,
        uint32 secondsOutside,
        bool initialized
    );


    function positions(bytes32 key)
    external
    view
    returns (
        uint128 _liquidity,
        uint256 feeGrowthInside0LastX128,
        uint256 feeGrowthInside1LastX128,
        uint128 tokensOwed0,
        uint128 tokensOwed1
    );


    function observations(uint256 index)
    external
    view
    returns (
        uint32 blockTimestamp,
        int56 tickCumulative,
        uint160 secondsPerLiquidityCumulativeX128,
        bool initialized
    );

}

interface IUniswapV3PoolDerivedState {

    function observe(uint32[] calldata secondsAgos)
    external
    view
    returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);


    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
    external
    view
    returns (
        int56 tickCumulativeInside,
        uint160 secondsPerLiquidityInsideX128,
        uint32 secondsInside
    );

}

interface IUniswapV3PoolActions {

    function initialize(uint160 sqrtPriceX96) external;


    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);


    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);


    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);


    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);


    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;


    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;

}

interface IUniswapV3PoolOwnerActions {

    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;


    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

}

interface IUniswapV3PoolEvents {

    event Initialize(uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}

interface IUniswapV3Pool is
IUniswapV3PoolImmutables,
IUniswapV3PoolState,
IUniswapV3PoolDerivedState,
IUniswapV3PoolActions,
IUniswapV3PoolOwnerActions,
IUniswapV3PoolEvents
{


}

interface IUniswapV3Router {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactInputSingle(
        IUniswapV3Router.ExactInputSingleParams memory params
    ) external returns (uint256 amountOut);


    function exactInput(
        IUniswapV3Router.ExactInputParams memory params
    ) external returns (uint256 amountOut);


    function exactOutputSingle(
        IUniswapV3Router.ExactOutputSingleParams memory params
    ) external returns (uint256 amountIn);


    function exactOutput(
        IUniswapV3Router.ExactOutputParams memory params
    ) external returns (uint256 amountIn);

}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

contract Avara is Context, IERC20, IERC20Metadata, Ownable {


    mapping(address => uint256) private _rewardOwned;
    mapping(address => uint256) private _tokenOwned;
    mapping(address => bool)    private _isExcludedFromFee;
    mapping(address => bool)    private _isExcluded;
    mapping(address => mapping(address => uint256)) private _allowances;

    address[] private _excluded;
    address public _devWallet;

    uint256 private _bitDuelServiceFeeTotal;
    uint256 private _developerFeeTotal;
    uint256 private _eventFeeTotal;
    uint256 private _feeTotal;
    uint256 private _marketingFeeTotal;

    string private constant _name = "AVARA";
    string private constant _symbol = "AVR";
    uint8 private constant _decimals = 9;

    uint256 public constant _maxTotalFee = 2000;

    uint256 private constant _uint256MaxValue = ~uint256(0);
    uint256 private constant _totalSupply = 500000000 * 10 ** uint256(_decimals);
    uint256 private _rewardSupply = (_uint256MaxValue - (_uint256MaxValue % _totalSupply));

    uint256 public _eventFee = 20;
    uint256 public _marketingFee = 40;
    uint256 public _developerFee = 40;
    uint256 public _bitDuelServiceFee = 100;

    uint256 public _sellPressureReductor = 1000;
    uint8 public _sellPressureReductorDecimals = 2;

    uint256 public _maxTxAmount = 250000000 * 10 ** uint256(_decimals);
    bool public _rewardEnabled = true;

    mapping(address => uint256) private _playerPool;
    address public _playerPoolWallet;

    string private constant _pong = "PONG";


    IUniswapV3Pool public _uniswapV3Pool;
    IUniswapV3Router public _uniswapV3Router;

    event BitDuelServiceFeeChanged(uint256 oldFee, uint256 newFee);
    event DeveloperFeeChanged(uint256 oldFee, uint256 newFee);
    event DevWalletChanged(address oldAddress, address newAddress);
    event EventFeeChanged(uint256 oldFee, uint256 newFee);
    event FallBack(address sender, uint value);
    event MarketingFeeChanged(uint256 oldFee, uint256 newFee);
    event MaxTransactionAmountChanged(uint256 oldAmount, uint256 newAmount);
    event PlayerPoolChanged(address oldAddress, address newAddress);
    event Received(address sender, uint value);
    event RewardEnabledStateChanged(bool oldState, bool newState);
    event SellPressureReductorChanged(uint256 oldReductor, uint256 newReductor);
    event SellPressureReductorDecimalsChanged(uint8 oldDecimals, uint8 newDecimals);
    event UniswapPoolChanged(address oldAddress, address newAddress);
    event UniswapRouterChanged(address oldAddress, address newAddress);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        emit FallBack(msg.sender, msg.value);
    }


    constructor (address cOwner, address devWallet, address playerPoolWallet) Ownable(cOwner) {
        require(cOwner != address(0), "Cannot give the zero address as the cOwner parameter.");
        require(devWallet != address(0), "Cannot give the zero address as the devWallet parameter.");
        require(playerPoolWallet != address(0), "Cannot give the zero address as the playerPoolWallet parameter.");

        _devWallet = devWallet;
        _playerPoolWallet = playerPoolWallet;

        _rewardOwned[cOwner] = _rewardSupply;
        _uniswapV3Router = IUniswapV3Router(0xE592427A0AEce92De3Edee1F18E0157C05861564);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_devWallet] = true;

        emit Transfer(address(0), cOwner, _totalSupply);
    }


    struct Module {
        string moduleName;
        string moduleVersion;
        address moduleAddress;
    }

    Module[] private modules;

    event ModuleAdded(address moduleAddress, string moduleName, string moduleVersion);
    event ModuleRemoved(string moduleName);

    function addModule(string memory moduleName, string memory moduleVersion, address moduleAddress) external onlyOwner {

        Module memory module;
        module.moduleVersion = moduleVersion;
        module.moduleAddress = moduleAddress;
        module.moduleName = moduleName;

        bool added = false;
        for (uint256 i = 0; i < modules.length; i++) {
            if (keccak256(abi.encodePacked(modules[i].moduleName)) == keccak256(abi.encodePacked(moduleName))) {
                modules[i] = module;
                added = true;
            }
        }

        if (!added) {
            modules.push(module);

            emit ModuleAdded(moduleAddress, moduleName, moduleVersion);
        }
    }

    function removeModule(string memory moduleName) external onlyOwner {

        uint256 index;
        bool found = false;
        for (uint256 i = 0; i < modules.length; i++) {
            if (keccak256(abi.encodePacked(modules[i].moduleName)) == keccak256(abi.encodePacked(moduleName))) {
                index = i;
                found = true;
            }
        }

        if (found) {
            modules[index] = modules[modules.length - 1];
            delete modules[modules.length - 1];
            modules.pop();

            emit ModuleRemoved(moduleName);
        }
    }

    function getModule(string memory moduleName) external view returns (bool, Module memory) {

        Module memory result;
        bool found = false;
        for (uint256 i = 0; i < modules.length; i++) {
            if (keccak256(abi.encodePacked(modules[i].moduleName)) == keccak256(abi.encodePacked(moduleName))) {
                result = modules[i];
                found = true;
            }
        }
        return (found, result);
    }

    modifier onlyOwnerOrModule() {

        bool isModule = false;
        for (uint256 i = 0; i < modules.length; i++) {
            if (modules[i].moduleAddress == _msgSender()) {
                isModule = true;
            }
        }

        require(isModule || owner() == _msgSender(), "The caller is not the owner nor an authenticated Avara module!");
        _;
    }


    function ping() external view onlyOwnerOrModule returns (string memory) {

        return _pong;
    }

    function withdraw(uint256 amount) external {

        require(_playerPool[_msgSender()] >= amount, "Invalid amount!");
        _transfer(_playerPoolWallet, _msgSender(), amount);
        _playerPool[_msgSender()] -= amount;
    }

    function balanceInPlayerPool(address playerAddress) external view returns (uint256) {

        return _playerPool[playerAddress];
    }

    function setPlayerBalance(address playerAddress, uint256 balance) external onlyOwnerOrModule {

        _playerPool[playerAddress] = balance;
    }


    struct RewardValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rewardMarketingFee;
        uint256 rewardDeveloperFee;
        uint256 rewardEventFee;
        uint256 rewardBitDuelServiceFee;
    }

    struct TokenValues {
        uint256 tTransferAmount;
        uint256 bitDuelServiceFee;
        uint256 marketingFee;
        uint256 developerFee;
        uint256 eventFee;
    }

    function rewardFromToken(uint256 tAmount, bool deductTransferFee) public view returns (uint256) {

        require(tAmount <= _totalSupply, "The amount must be less than the supply!");

        if (!deductTransferFee) {
            uint256 currentRate = _getRate();
            (TokenValues memory tv) = _getTokenValues(tAmount, address(0));
            (RewardValues memory rv) = _getRewardValues(tAmount, tv, currentRate);

            return rv.rAmount;
        } else {
            uint256 currentRate = _getRate();
            (TokenValues memory tv) = _getTokenValues(tAmount, address(0));
            (RewardValues memory rv) = _getRewardValues(tAmount, tv, currentRate);

            return rv.rTransferAmount;
        }
    }

    function tokenFromReward(uint256 rAmount) public view returns (uint256) {

        require(rAmount <= _rewardSupply, "The amount must be less than the total rewards!");

        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function excludeFromReward(address account) public onlyOwner {

        require(!_isExcluded[account], "The account is already excluded!");

        if (_rewardOwned[account] > 0) {
            _tokenOwned[account] = tokenFromReward(_rewardOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {

        require(_isExcluded[account], "The account is already included!");

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tokenOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function totalFees() public view returns (uint256) {

        return _feeTotal;
    }

    function totalMarketingFees() public view returns (uint256) {

        return _marketingFeeTotal;
    }

    function totalEventFees() public view returns (uint256) {

        return _eventFeeTotal;
    }

    function totalDevelopmentFees() public view returns (uint256) {

        return _developerFeeTotal;
    }

    function totalBitDuelServiceFees() public view returns (uint256) {

        return _bitDuelServiceFeeTotal;
    }

    function excludeFromFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = false;
    }

    function setDevWallet(address devWallet) external onlyOwner {

        require(devWallet != address(0), "Cannot set the zero address as the devWallet.");
        address oldAddress = _devWallet;
        _isExcludedFromFee[oldAddress] = false;
        _devWallet = devWallet;
        _isExcludedFromFee[_devWallet] = true;

        emit DevWalletChanged(oldAddress, _devWallet);
    }

    function setPlayerPoolWallet(address playerPoolWallet) external onlyOwner {

        require(playerPoolWallet != address(0), "Cannot set the zero address as the playerPoolWallet.");
        address oldAddress = _playerPoolWallet;
        _playerPoolWallet = playerPoolWallet;

        emit PlayerPoolChanged(oldAddress, _playerPoolWallet);
    }

    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner {

        require((marketingFee + _developerFee + _eventFee) <= _maxTotalFee, "Too high fees!");
        require((((marketingFee + _developerFee + _eventFee) * _sellPressureReductor) / (10 ** uint256(_sellPressureReductorDecimals))) <= _maxTotalFee, "Too harsh sell pressure reductor!");

        uint256 oldFee = _marketingFee;
        _marketingFee = marketingFee;

        emit MarketingFeeChanged(oldFee, _marketingFee);
    }

    function setDeveloperFeePercent(uint256 developerFee) external onlyOwner {

        require((developerFee + _marketingFee + _eventFee) <= _maxTotalFee, "Too high fees!");
        require((((developerFee + _marketingFee + _eventFee) * _sellPressureReductor) / (10 ** uint256(_sellPressureReductorDecimals))) <= _maxTotalFee, "Too harsh sell pressure reductor!");

        uint256 oldFee = _developerFee;
        _developerFee = developerFee;

        emit DeveloperFeeChanged(oldFee, _developerFee);
    }

    function setBitDuelServiceFeePercent(uint256 bitDuelServiceFee) external onlyOwner {

        require(bitDuelServiceFee <= _maxTotalFee, "Too high fee!");

        uint256 oldFee = _bitDuelServiceFee;
        _bitDuelServiceFee = bitDuelServiceFee;

        emit BitDuelServiceFeeChanged(oldFee, _bitDuelServiceFee);
    }

    function setEventFeePercent(uint256 eventFee) external onlyOwner {

        require((eventFee + _marketingFee + _developerFee) <= _maxTotalFee, "Too high fees!");
        require((((eventFee + _marketingFee + _developerFee) * _sellPressureReductor) / (10 ** uint256(_sellPressureReductorDecimals))) <= _maxTotalFee, "Too harsh sell pressure reductor!");

        uint256 oldFee = _eventFee;
        _eventFee = eventFee;

        emit EventFeeChanged(oldFee, _eventFee);
    }

    function setSellPressureReductor(uint256 reductor) external onlyOwner {

        require((((_eventFee + _marketingFee + _developerFee) * reductor) / (10 ** uint256(_sellPressureReductorDecimals))) <= _maxTotalFee, "Too harsh sell pressure reductor!");

        uint256 oldReductor = _sellPressureReductor;
        _sellPressureReductor = reductor;

        emit SellPressureReductorChanged(oldReductor, _sellPressureReductor);
    }

    function setSellPressureReductorDecimals(uint8 reductorDecimals) external onlyOwner {

        require((((_eventFee + _marketingFee + _developerFee) * _sellPressureReductor) / (10 ** uint256(reductorDecimals))) <= _maxTotalFee, "Too harsh sell pressure reductor!");

        uint8 oldReductorDecimals = _sellPressureReductorDecimals;
        _sellPressureReductorDecimals = reductorDecimals;

        emit SellPressureReductorDecimalsChanged(oldReductorDecimals, _sellPressureReductorDecimals);
    }

    function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {

        uint256 oldAmount = _maxTxAmount;
        _maxTxAmount = (_totalSupply * maxTxPercent) / 100;

        emit MaxTransactionAmountChanged(oldAmount, _maxTxAmount);
    }

    function setRewardEnabled(bool enabled) external onlyOwner {

        bool oldState = _rewardEnabled;
        _rewardEnabled = enabled;

        emit RewardEnabledStateChanged(oldState, _rewardEnabled);
    }

    function isExcludedFromFee(address account) public view returns (bool) {

        return _isExcludedFromFee[account];
    }

    function isExcludedFromReward(address account) public view returns (bool) {

        return _isExcluded[account];
    }

    function setUniswapRouter(address r) external onlyOwner {

        address oldRouter = address(_uniswapV3Router);
        _uniswapV3Router = IUniswapV3Router(r);

        emit UniswapRouterChanged(oldRouter, address(_uniswapV3Router));
    }

    function setUniswapPool(address p) external onlyOwner {

        address oldPool = address(_uniswapV3Pool);
        _uniswapV3Pool = IUniswapV3Pool(p);

        emit UniswapPoolChanged(oldPool, address(_uniswapV3Pool));
    }


    function unstickEth(uint256 amount) external onlyOwner {

        require(address(this).balance >= amount, "Invalid amount!");
        payable(_msgSender()).transfer(amount);
    }

    function unstickTokens(uint256 amount) external onlyOwner {

        require(balanceOf(address(this)) >= amount, "Invalid amount!");
        _transfer(address(this), _msgSender(), amount);
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return _decimals;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (_isExcluded[account]) return _tokenOwned[account];
        return tokenFromReward(_rewardOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {

        if (recipient == _playerPoolWallet) {
            _playerPool[_msgSender()] += _transfer(_msgSender(), recipient, amount);
        } else {
            _transfer(_msgSender(), recipient, amount);
        }
        return true;
    }

    function allowance(address avrOwner, address spender) external view override returns (uint256) {

        return _allowances[avrOwner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        require(amount <= _allowances[sender][_msgSender()], "ERC20: The transfer amount exceeds the allowance.");
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), (_allowances[sender][_msgSender()] - amount));
        return true;
    }


    function _approve(address avrOwner, address spender, uint256 amount) private {

        require(avrOwner != address(0), "ERC20: Cannot approve from the zero address.");
        require(spender != address(0), "ERC20: Cannot approve to the zero address.");

        _allowances[avrOwner][spender] = amount;
        emit Approval(avrOwner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private returns (uint256) {

        require(from != address(0), "ERC20: Cannot transfer from the zero address.");
        require(to != address(0), "ERC20: Cannot transfer to the zero address.");
        require(amount > 0, "The transfer amount must be greater than zero!");

        if (from != owner() && to != owner()) {
            require(amount <= _maxTxAmount, "The transfer amount exceeds the maxTxAmount.");
        }

        bool takeFee = !(_isExcludedFromFee[from] || _isExcludedFromFee[to] || from == _playerPoolWallet);
        return _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount, bool takeFee) private returns (uint256) {

        uint256 previousBitDuelServiceFee = _bitDuelServiceFee;
        uint256 previousDeveloperFee = _developerFee;
        uint256 previousEventFee = _eventFee;
        uint256 previousMarketingFee = _marketingFee;

        if (!takeFee) {
            _bitDuelServiceFee = 0;
            _developerFee = 0;
            _eventFee = 0;
            _marketingFee = 0;
        }

        uint256 transferredAmount;
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            transferredAmount = _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            transferredAmount = _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            transferredAmount = _transferBothExcluded(sender, recipient, amount);
        } else {
            transferredAmount = _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) {
            _bitDuelServiceFee = previousBitDuelServiceFee;
            _developerFee = previousDeveloperFee;
            _eventFee = previousEventFee;
            _marketingFee = previousMarketingFee;
        }

        return transferredAmount;
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private returns (uint256) {

        uint256 currentRate = _getRate();
        (TokenValues memory tv) = _getTokenValues(tAmount, recipient);
        (RewardValues memory rv) = _getRewardValues(tAmount, tv, currentRate);

        _rewardOwned[sender] = _rewardOwned[sender] - rv.rAmount;
        _rewardOwned[recipient] = _rewardOwned[recipient] + rv.rTransferAmount;

        takeTransactionFee(_devWallet, tv, currentRate, recipient);
        if (_rewardEnabled) {
            _rewardFee(rv);
        }
        _countTotalFee(tv);
        emit Transfer(sender, recipient, tv.tTransferAmount);

        return tv.tTransferAmount;
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) private returns (uint256) {

        uint256 currentRate = _getRate();
        (TokenValues memory tv) = _getTokenValues(tAmount, recipient);
        (RewardValues memory rv) = _getRewardValues(tAmount, tv, currentRate);

        _tokenOwned[sender] = _tokenOwned[sender] - tAmount;
        _rewardOwned[sender] = _rewardOwned[sender] - rv.rAmount;
        _tokenOwned[recipient] = _tokenOwned[recipient] + tv.tTransferAmount;
        _rewardOwned[recipient] = _rewardOwned[recipient] + rv.rTransferAmount;

        takeTransactionFee(_devWallet, tv, currentRate, recipient);
        if (_rewardEnabled) {
            _rewardFee(rv);
        }
        _countTotalFee(tv);
        emit Transfer(sender, recipient, tv.tTransferAmount);

        return tv.tTransferAmount;
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) private returns (uint256) {

        uint256 currentRate = _getRate();
        (TokenValues memory tv) = _getTokenValues(tAmount, recipient);
        (RewardValues memory rv) = _getRewardValues(tAmount, tv, currentRate);

        _rewardOwned[sender] = _rewardOwned[sender] - rv.rAmount;
        _tokenOwned[recipient] = _tokenOwned[recipient] + tv.tTransferAmount;
        _rewardOwned[recipient] = _rewardOwned[recipient] + rv.rTransferAmount;

        takeTransactionFee(_devWallet, tv, currentRate, recipient);
        if (_rewardEnabled) {
            _rewardFee(rv);
        }
        _countTotalFee(tv);
        emit Transfer(sender, recipient, tv.tTransferAmount);

        return tv.tTransferAmount;
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) private returns (uint256) {

        uint256 currentRate = _getRate();
        (TokenValues memory tv) = _getTokenValues(tAmount, recipient);
        (RewardValues memory rv) = _getRewardValues(tAmount, tv, currentRate);

        _tokenOwned[sender] = _tokenOwned[sender] - tAmount;
        _rewardOwned[sender] = _rewardOwned[sender] - rv.rAmount;
        _rewardOwned[recipient] = _rewardOwned[recipient] + rv.rTransferAmount;

        takeTransactionFee(_devWallet, tv, currentRate, recipient);
        if (_rewardEnabled) {
            _rewardFee(rv);
        }
        _countTotalFee(tv);
        emit Transfer(sender, recipient, tv.tTransferAmount);

        return tv.tTransferAmount;
    }

    function _rewardFee(RewardValues memory rv) private {

        _rewardSupply = _rewardSupply - rv.rewardMarketingFee - rv.rewardDeveloperFee - rv.rewardEventFee - rv.rewardBitDuelServiceFee;
    }

    function _countTotalFee(TokenValues memory tv) private {

        _marketingFeeTotal = _marketingFeeTotal + tv.marketingFee;
        _developerFeeTotal = _developerFeeTotal + tv.developerFee;
        _eventFeeTotal = _eventFeeTotal + tv.eventFee;
        _bitDuelServiceFeeTotal = _bitDuelServiceFeeTotal + tv.bitDuelServiceFee;
        _feeTotal = _feeTotal + tv.marketingFee + tv.developerFee + tv.eventFee + tv.bitDuelServiceFee;
    }

    function _getTokenValues(uint256 tAmount, address recipient) private view returns (TokenValues memory) {

        TokenValues memory tv;
        uint256 tTransferAmount = tAmount;

        if (recipient == _playerPoolWallet) {
            uint256 bitDuelServiceFee = (tAmount * _bitDuelServiceFee) / 10000;
            tTransferAmount = tTransferAmount - bitDuelServiceFee;

            tv.tTransferAmount = tTransferAmount;
            tv.bitDuelServiceFee = bitDuelServiceFee;

            return (tv);
        }

        uint256 marketingFee = (tAmount * _marketingFee) / 10000;
        uint256 developerFee = (tAmount * _developerFee) / 10000;
        uint256 eventFee = (tAmount * _eventFee) / 10000;

        if (recipient == address(_uniswapV3Pool)) {
            marketingFee = (marketingFee * _sellPressureReductor) / (10 ** uint256(_sellPressureReductorDecimals));
            developerFee = (developerFee * _sellPressureReductor) / (10 ** uint256(_sellPressureReductorDecimals));
            eventFee = (eventFee * _sellPressureReductor) / (10 ** uint256(_sellPressureReductorDecimals));
        }

        tTransferAmount = tTransferAmount - marketingFee - developerFee - eventFee;

        tv.tTransferAmount = tTransferAmount;
        tv.marketingFee = marketingFee;
        tv.developerFee = developerFee;
        tv.eventFee = eventFee;

        return (tv);
    }

    function _getRewardValues(uint256 tAmount, TokenValues memory tv, uint256 currentRate) private pure returns (RewardValues memory) {

        RewardValues memory rv;

        uint256 rAmount = tAmount * currentRate;
        uint256 rewardBitDuelServiceFee = tv.bitDuelServiceFee * currentRate;
        uint256 rewardMarketingFee = tv.marketingFee * currentRate;
        uint256 rewardDeveloperFee = tv.developerFee * currentRate;
        uint256 rewardEventFee = tv.eventFee * currentRate;
        uint256 rTransferAmount = rAmount - rewardMarketingFee - rewardDeveloperFee - rewardEventFee - rewardBitDuelServiceFee;

        rv.rAmount = rAmount;
        rv.rTransferAmount = rTransferAmount;
        rv.rewardBitDuelServiceFee = rewardBitDuelServiceFee;
        rv.rewardMarketingFee = rewardMarketingFee;
        rv.rewardDeveloperFee = rewardDeveloperFee;
        rv.rewardEventFee = rewardEventFee;

        return (rv);
    }

    function _getRate() private view returns (uint256) {

        (uint256 rewardSupply, uint256 tokenSupply) = _getCurrentSupply();
        return rewardSupply / tokenSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {

        uint256 rewardSupply = _rewardSupply;
        uint256 tokenSupply = _totalSupply;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rewardOwned[_excluded[i]] > rewardSupply || _tokenOwned[_excluded[i]] > tokenSupply) return (_rewardSupply, _totalSupply);
            rewardSupply = rewardSupply - _rewardOwned[_excluded[i]];
            tokenSupply = tokenSupply - _tokenOwned[_excluded[i]];
        }
        if (rewardSupply < (_rewardSupply / _totalSupply)) return (_rewardSupply, _totalSupply);
        return (rewardSupply, tokenSupply);
    }

    function takeTransactionFee(address to, TokenValues memory tv, uint256 currentRate, address recipient) private {

        uint256 totalFee = recipient == _playerPoolWallet ? (tv.bitDuelServiceFee) : (tv.marketingFee + tv.developerFee + tv.eventFee);

        if (totalFee <= 0) {return;}

        uint256 rAmount = totalFee * currentRate;
        _rewardOwned[to] = _rewardOwned[to] + rAmount;
        if (_isExcluded[to]) {
            _tokenOwned[to] = _tokenOwned[to] + totalFee;
        }
    }
}