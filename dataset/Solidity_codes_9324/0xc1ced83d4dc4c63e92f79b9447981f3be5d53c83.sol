

pragma solidity 0.8.0;




interface IAccessControl {

    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

}


interface IBPool {


    function MAX_IN_RATIO() external view returns (uint);


    function getCurrentTokens() external view returns (address[] memory tokens);


    function getDenormalizedWeight(address token) external view returns (uint);


    function getTotalDenormalizedWeight() external view returns (uint);


    function getBalance(address token) external view returns (uint);


    function getSwapFee() external view returns (uint);


    function calcPoolOutGivenSingleIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountIn,
        uint swapFee
    ) external pure returns (uint poolAmountOut);


}


interface IBancorFormula {

    function purchaseTargetAmount(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveWeight,
        uint256 _amount
    ) external view returns (uint256);


    function saleTargetAmount(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveWeight,
        uint256 _amount
    ) external view returns (uint256);


    function crossReserveTargetAmount(
        uint256 _sourceReserveBalance,
        uint32 _sourceReserveWeight,
        uint256 _targetReserveBalance,
        uint32 _targetReserveWeight,
        uint256 _amount
    ) external view returns (uint256);


    function fundCost(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _amount
    ) external view returns (uint256);


    function fundSupplyAmount(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _amount
    ) external view returns (uint256);


    function liquidateReserveAmount(
        uint256 _supply,
        uint256 _reserveBalance,
        uint32 _reserveRatio,
        uint256 _amount
    ) external view returns (uint256);


    function balancedWeights(
        uint256 _primaryReserveStakedBalance,
        uint256 _primaryReserveBalance,
        uint256 _secondaryReserveBalance,
        uint256 _reserveRateNumerator,
        uint256 _reserveRateDenominator
    ) external view returns (uint32, uint32);

}


interface IChainLinkFeed
{


    function latestAnswer() external view returns (int256);


}


interface ISmartPool {

    function isPublicSwap() external view returns (bool);

    function isFinalized() external view returns (bool);

    function isBound(address t) external view returns (bool);

    function getNumTokens() external view returns (uint);

    function getCurrentTokens() external view returns (address[] memory tokens);

    function getFinalTokens() external view returns (address[] memory tokens);

    function getDenormalizedWeight(address token) external view returns (uint);

    function getTotalDenormalizedWeight() external view returns (uint);

    function getNormalizedWeight(address token) external view returns (uint);

    function getBalance(address token) external view returns (uint);

    function getSwapFee() external view returns (uint);

    function getController() external view returns (address);


    function setSwapFee(uint swapFee) external;

    function setController(address manager) external;

    function setPublicSwap(bool public_) external;

    function finalize() external;

    function bind(address token, uint balance, uint denorm) external;

    function rebind(address token, uint balance, uint denorm) external;

    function unbind(address token) external;

    function gulp(address token) external;


    function getSpotPrice(address tokenIn, address tokenOut) external view returns (uint spotPrice);

    function getSpotPriceSansFee(address tokenIn, address tokenOut) external view returns (uint spotPrice);


    function joinPool(uint poolAmountOut, uint[] calldata maxAmountsIn) external;

    function exitPool(uint poolAmountIn, uint[] calldata minAmountsOut) external;


    function swapExactAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        address tokenOut,
        uint minAmountOut,
        uint maxPrice
    ) external returns (uint tokenAmountOut, uint spotPriceAfter);


    function swapExactAmountOut(
        address tokenIn,
        uint maxAmountIn,
        address tokenOut,
        uint tokenAmountOut,
        uint maxPrice
    ) external returns (uint tokenAmountIn, uint spotPriceAfter);


    function joinswapExternAmountIn(
        address tokenIn,
        uint tokenAmountIn,
        uint minPoolAmountOut
    ) external returns (uint poolAmountOut);


    function joinswapPoolAmountOut(
        address tokenIn,
        uint poolAmountOut,
        uint maxAmountIn
    ) external returns (uint tokenAmountIn);


    function exitswapPoolAmountIn(
        address tokenOut,
        uint poolAmountIn,
        uint minAmountOut
    ) external returns (uint tokenAmountOut);


    function exitswapExternAmountOut(
        address tokenOut,
        uint tokenAmountOut,
        uint maxPoolAmountIn
    ) external returns (uint poolAmountIn);


    function totalSupply() external view returns (uint);

    function balanceOf(address whom) external view returns (uint);

    function allowance(address src, address dst) external view returns (uint);


    function approve(address dst, uint amt) external returns (bool);

    function transfer(address dst, uint amt) external returns (bool);

    function transferFrom(
        address src, address dst, uint amt
    ) external returns (bool);


    function calcSpotPrice(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint swapFee
    ) external pure returns (uint spotPrice);


    function calcOutGivenIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountIn,
        uint swapFee
    ) external pure returns (uint tokenAmountOut);


    function calcInGivenOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint tokenAmountOut,
        uint swapFee
    ) external pure returns (uint tokenAmountIn);


    function calcPoolOutGivenSingleIn(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountIn,
        uint swapFee
    ) external pure returns (uint poolAmountOut);


    function calcSingleInGivenPoolOut(
        uint tokenBalanceIn,
        uint tokenWeightIn,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountOut,
        uint swapFee
    ) external pure returns (uint tokenAmountIn);



    function calcSingleOutGivenPoolIn(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint poolAmountIn,
        uint swapFee
    ) external pure returns (uint tokenAmountOut);


    function calcPoolInGivenSingleOut(
        uint tokenBalanceOut,
        uint tokenWeightOut,
        uint poolSupply,
        uint totalWeight,
        uint tokenAmountOut,
        uint swapFee
    ) external pure returns (uint poolAmountIn);


}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


contract GasPrice {


    IChainLinkFeed public constant ChainLinkFeed = IChainLinkFeed(0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C);

    modifier validGasPrice()
    {

        require(tx.gasprice <= maxGasPrice()); // dev: incorrect gas price
        _;
    }

    function maxGasPrice()
    public
    view
    returns (uint256 fastGas)
    {

        return fastGas = uint256(ChainLinkFeed.latestAnswer());
    }
}


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


contract ArrayFinance is ERC20, ReentrancyGuard, Initializable, GasPrice {

    address private DAO_MULTISIG_ADDR = address(0xB60eF661cEdC835836896191EDB87CC025EFd0B7);
    address private DEV_MULTISIG_ADDR = address(0x3c25c256E609f524bf8b35De7a517d5e883Ff81C);
    uint256 private PRECISION = 10 ** 18;

    uint256 private STARTING_ARRAY_MINTED = 10000 * PRECISION;

    uint32 private reserveRatio = 435000;

    uint256 private devPctToken = 10 * 10 ** 16;
    uint256 private daoPctToken = 20 * 10 ** 16;

    uint256 public maxSupply = 100000 * PRECISION;

    IAccessControl public roles;
    IBancorFormula private bancorFormula = IBancorFormula(0xA049894d5dcaD406b7C827D6dc6A0B58CA4AE73a);
    ISmartPool public arraySmartPool = ISmartPool(0xA800cDa5f3416A6Fb64eF93D84D6298a685D190d);
    IBPool public arrayBalancerPool = IBPool(0x02e1300A7E6c3211c65317176Cf1795f9bb1DaAb);

    IERC20 private dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 private usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 private weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    IERC20 private wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    IERC20 private renbtc = IERC20(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D);

    event Buy(
        address from,
        address token,
        uint256 amount,
        uint256 amountLPTokenDeposited,
        uint256 amountArrayMinted
    );

    event Sell(
        address from,
        uint256 amountArray,
        uint256 amountReturnedLP
    );

    modifier onlyDEV() {
        require(roles.hasRole(keccak256('DEVELOPER'), msg.sender));
        _;
    }

    modifier onlyDAOMSIG() {
        require(roles.hasRole(keccak256('DAO_MULTISIG'), msg.sender));
        _;
    }

    modifier onlyDEVMSIG() {
        require(roles.hasRole(keccak256('DEV_MULTISIG'), msg.sender));
        _;
    }

    constructor(address _roles)
    ERC20("Array Finance", "ARRAY")
    {
        roles = IAccessControl(_roles);
    }

    function initialize()
    public
    initializer
    onlyDAOMSIG
    {
        uint256 amount = arraySmartPool.balanceOf(DAO_MULTISIG_ADDR);
        require(arraySmartPool.transferFrom(DAO_MULTISIG_ADDR, address(this), amount), "Transfer failed");
        _mint(DAO_MULTISIG_ADDR, STARTING_ARRAY_MINTED);

    }


    function buy(IERC20 token, uint256 amount, uint256 slippage)
    public
    nonReentrant
    validGasPrice
    returns (uint256 returnAmount)
    {
        require(slippage < 50, "slippage too high");
        require(isTokenInLP(address(token)), 'token not in lp');
        require(amount > 0, 'amount is 0');
        require(token.allowance(msg.sender, address(this)) >= amount, 'user allowance < amount');
        require(token.balanceOf(msg.sender) >= amount, 'user balance < amount');

        uint256 max_in_balance = (arrayBalancerPool.getBalance(address(token)) / 2);
        require(amount <= max_in_balance, 'ratio in too high');

        uint256 amountTokenForDao = amount * daoPctToken / PRECISION;
        uint256 amountTokenForDev = amount * devPctToken / PRECISION;

        uint256 amountTokenAfterFees = amount - amountTokenForDao - amountTokenForDev;
        require(
            token.approve(address(arraySmartPool), amountTokenAfterFees),
            "token approve for contract to balancer pool failed"
        );

        uint256 amountLPReturned = _calculateLPTokensGivenERC20Tokens(address(token), amountTokenAfterFees);
        uint256 amountArrayToMint = _calculateArrayGivenLPTokenAmount(amountLPReturned);

        require(amountArrayToMint + totalSupply() <= maxSupply, 'minted array > total supply');

        require(token.transferFrom(msg.sender, address(this), amount), 'transfer from user to contract failed');
        require(token.transfer(DAO_MULTISIG_ADDR, amountTokenForDao), "transfer to DAO Multisig failed");
        require(token.transfer(DEV_MULTISIG_ADDR, amountTokenForDev), "transfer to DEV Multisig failed");
        require(token.balanceOf(address(this)) >= amountTokenAfterFees, 'contract did not receive the right amount of tokens');

        uint256 minLpTokenAmount = amountLPReturned * slippage * 10 ** 16 / PRECISION;
        uint256 lpTokenReceived = arraySmartPool.joinswapExternAmountIn(address(token), amountTokenAfterFees, minLpTokenAmount);

        _mint(msg.sender, amountArrayToMint);

        emit Buy(msg.sender, address(token), amount, lpTokenReceived, amountArrayToMint);
        return returnAmount = amountArrayToMint;
    }


    function sell(uint256 amountArray)
    public
    nonReentrant
    validGasPrice
    returns (uint256 amountReturnedLP)
    {
        amountReturnedLP = _sell(amountArray);
    }

    function sell(bool max)
    public
    nonReentrant
    returns (uint256 amountReturnedLP)
    {
        require(max, 'sell function not called correctly');

        uint256 amountArray = balanceOf(msg.sender);
        amountReturnedLP = _sell(amountArray);
    }

    function _sell(uint256 amountArray)
    internal
    returns (uint256 amountReturnedLP)
    {

        require(amountArray <= balanceOf(msg.sender), 'user balance < amount');

        amountReturnedLP = calculateLPtokensGivenArrayTokens(amountArray);

        _burn(msg.sender, amountArray);

        require(arraySmartPool.transfer(msg.sender, amountReturnedLP), 'transfer of lp token to user failed');

        emit Sell(msg.sender, amountArray, amountReturnedLP);
    }

    function calculateArrayMintedFromToken(address token, uint256 amount)
    public
    view
    returns (uint256 expectedAmountArrayToMint)
    {
        require(isTokenInLP(token), 'token not in balancer LP');

        uint256 amountTokenForDao = amount * daoPctToken / PRECISION;
        uint256 amountTokenForDev = amount * devPctToken / PRECISION;

        uint256 amountTokenAfterFees = amount - amountTokenForDao - amountTokenForDev;

        expectedAmountArrayToMint = _calculateArrayMintedFromToken(token, amountTokenAfterFees);
    }

    function _calculateArrayMintedFromToken(address token, uint256 amount)
    private
    view
    returns (uint256 expectedAmountArrayToMint)
    {
        uint256 amountLPReturned = _calculateLPTokensGivenERC20Tokens(token, amount);
        expectedAmountArrayToMint = _calculateArrayGivenLPTokenAmount(amountLPReturned);
    }


    function calculateLPtokensGivenArrayTokens(uint256 amount)
    public
    view
    returns (uint256 amountLPToken)
    {

        return amountLPToken = bancorFormula.saleTargetAmount(
            totalSupply(),
            arraySmartPool.totalSupply(),
            reserveRatio,
            amount
        );

    }

    function _calculateLPTokensGivenERC20Tokens(address token, uint256 amount)
    private
    view
    returns (uint256 amountLPToken)
    {

        uint256 balance = arrayBalancerPool.getBalance(token);
        uint256 weight = arrayBalancerPool.getDenormalizedWeight(token);
        uint256 totalWeight = arrayBalancerPool.getTotalDenormalizedWeight();
        uint256 fee = arrayBalancerPool.getSwapFee();
        uint256 supply = arraySmartPool.totalSupply();

        return arrayBalancerPool.calcPoolOutGivenSingleIn(balance, weight, supply, totalWeight, amount, fee);
    }

    function _calculateArrayGivenLPTokenAmount(uint256 amount)
    private
    view
    returns (uint256 amountArrayToken)
    {
        return amountArrayToken = bancorFormula.purchaseTargetAmount(
            totalSupply(),
            arraySmartPool.totalSupply(),
            reserveRatio,
            amount
        );
    }

    function lpTotalSupply()
    public
    view
    returns (uint256)
    {
        return arraySmartPool.totalSupply();
    }


    function isTokenInLP(address token)
    internal
    view
    returns (bool)
    {
        address[] memory lpTokens = arrayBalancerPool.getCurrentTokens();
        for (uint256 i = 0; i < lpTokens.length; i++) {
            if (token == lpTokens[i]) {
                return true;
            }
        }
        return false;
    }

    function setDaoPct(uint256 amount)
    public
    onlyDAOMSIG
    returns (bool success) {
        devPctToken = amount;
        success = true;
    }

    function setDevPct(uint256 amount)
    public
    onlyDAOMSIG
    returns (bool success) {
        devPctToken = amount;
        success = true;
    }

    function setMaxSupply(uint256 amount)
    public
    onlyDAOMSIG
    returns (bool success)
    {
        maxSupply = amount;
        success = true;
    }

    function getLPTokenValue()
    public
    view
    returns (uint256[] memory)
    {
        uint256[] memory values = new uint256[](5);
        uint256 supply = lpTotalSupply();

        values[0] = arrayBalancerPool.getBalance(address(dai)) * PRECISION / supply;
        values[1] = arrayBalancerPool.getBalance(address(usdc)) * (10 ** (18 - 6)) * PRECISION / supply;
        values[2] = arrayBalancerPool.getBalance(address(weth)) * PRECISION / supply;
        values[3] = arrayBalancerPool.getBalance(address(wbtc)) * (10 ** (18 - 8)) * PRECISION / supply;
        values[4] = arrayBalancerPool.getBalance(address(renbtc)) * (10 ** (18 - 8)) * PRECISION / supply;


        return values;

    }
}