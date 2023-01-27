


pragma solidity ^0.8.14;

interface ERC20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!YOU ARE NOT THE OWNER"); _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}

interface IDEXFactory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

}

interface IDEXRouter {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);


    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

contract InugamiWorld is ERC20, Ownable {

    mapping(address => bool) public _blacklisted;
    mapping(address => bool) private _whitelisted;
    mapping(address => bool) public _automatedMarketMakers;
    mapping(address => bool) private _isLimitless;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string constant _name = "Inugami World";
    string constant _symbol = "GAMI";
    uint8 constant _decimals = 18;
    uint256 private _totalSupply = 128_000_000 * 10 ** _decimals;

    uint256 public maxBuyPercentage;
    uint256 public maxSellPercentage;
    uint256 public maxWalletPercentage;

    uint256 private maxBuyAmount;
    uint256 private maxSellAmount;
    uint256 private maxWalletAmount;

    address[] private sniperList;
    uint256 tokenTax;
    uint256 transferFee;

    struct BuyFee {
        uint256 liquidityFee;
        uint256 devOpsFee;
        uint256 marketingFee;
        uint256 total;
    }

    struct SellFee {
        uint256 liquidityFee;
        uint256 devOpsFee;
        uint256 marketingFee;
        uint256 total;
    }

    BuyFee public buyFee;
    SellFee public sellFee;

    address public _exchangeRouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;

    address public devOpsReceiver = 0x342539d911766CB783315E2B8b41b014DD02bC0D;
    address public marketingReceiver = 0x2a0b4a880AeC4073546985E020f0eC91AdA6c4C3;
    address public rewardPoolAddress = 0x8fF0369C82d3A4C57Ac0467Db81655C64B9e8955;

    IDEXRouter public router;
    address public pair;

    bool public antiSniperMode = true;
    bool private _addingLP;
    bool private inSwap;
    bool private _initialDistributionFinished;

    bool public swapEnabled = true;
    uint256 private swapThreshold = _totalSupply / 1000;
    
    modifier swapping() {

        inSwap = true;
        _;
        inSwap = false;
    }

    event Deposit(address indexed from, address indexed to, uint256 value);

    constructor() Ownable(msg.sender) {
        router = IDEXRouter(_exchangeRouterAddress);
        pair = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        _allowances[address(this)][address(router)] = type(uint256).max;
        _automatedMarketMakers[pair]=true;
        
        buyFee.liquidityFee = 20;
        buyFee.devOpsFee = 20;
        buyFee.marketingFee = 40;

        buyFee.total = buyFee.liquidityFee + buyFee.devOpsFee + buyFee.marketingFee;

        sellFee.liquidityFee = 20;
        sellFee.devOpsFee = 20;
        sellFee.marketingFee = 40;

        sellFee.total = sellFee.liquidityFee + sellFee.devOpsFee + sellFee.marketingFee;

        maxBuyPercentage = 10; maxBuyAmount = _totalSupply / 1000 * maxBuyPercentage;
        maxSellPercentage = 10; maxSellAmount = _totalSupply / 1000 * maxSellPercentage;

        maxWalletPercentage = 20; maxWalletAmount = _totalSupply / 1000 * maxWalletPercentage;

        _isLimitless[owner] = _isLimitless[address(this)] = true;
        _isLimitless[devOpsReceiver] = _isLimitless[devOpsReceiver] = true;
        _isLimitless[marketingReceiver] = _isLimitless[marketingReceiver] = true;
        _isLimitless[rewardPoolAddress] = _isLimitless[rewardPoolAddress] = true;

        _balances[owner] = _totalSupply;
        emit Transfer(address(0x0), owner, _totalSupply);
    }

    function setRewardPool(address address_) external onlyOwner {

        rewardPoolAddress = address_;
    }

    function deposit(uint256 amount_) external {

        _transfer(msg.sender, rewardPoolAddress, amount_);

        emit Deposit(msg.sender, rewardPoolAddress, amount_);
    }

    function ownerSetLimits(uint256 _maxBuyPercentage, uint256 _maxSellPercentage, uint256 _maxWalletPercentage) external onlyOwner {

        maxBuyAmount = _totalSupply / 1000 * _maxBuyPercentage;
        maxSellAmount = _totalSupply / 1000 * _maxSellPercentage;
        maxWalletAmount = _totalSupply / 1000 * _maxWalletPercentage;
    }

    function ownerSetInitialDistributionFinished() external onlyOwner {

        _initialDistributionFinished = true;
    }

    function ownerSetLimitlessAddress(address _addr, bool _status) external onlyOwner {

        _isLimitless[_addr] = _status;
    }

    function ownerSetSwapBackSettings(bool _enabled, uint256 _percentageBase1000) external onlyOwner {

        swapEnabled = _enabled;
        swapThreshold = _totalSupply / 1000 * _percentageBase1000;
    }
    
    function ownerUpdateBuyFees (uint256 _liquidityFee, uint256 _devOpsFee, uint256 _marketingFee) external onlyOwner {
        buyFee.liquidityFee = _liquidityFee;
        buyFee.devOpsFee = _devOpsFee;
        buyFee.marketingFee = _marketingFee;
        buyFee.total = buyFee.liquidityFee + buyFee.devOpsFee + buyFee.marketingFee;
    }
    
    function ownerUpdateSellFees (uint256 _liquidityFee, uint256 _devOpsFee, uint256 _marketingFee) external onlyOwner {
        sellFee.liquidityFee = _liquidityFee;
        sellFee.devOpsFee = _devOpsFee;
        sellFee.marketingFee = _marketingFee;
        sellFee.total = sellFee.liquidityFee + sellFee.devOpsFee + sellFee.marketingFee;
    }
    
    function ownerUpdateTransferFee (uint256 _transferFee) external onlyOwner {
        transferFee = _transferFee;
    }

    function ownerSetReceivers (address _devOps, address _marketing) external onlyOwner {
        devOpsReceiver = _devOps;
        marketingReceiver = _marketing;
    }

    function ownerAirDropWallets(address[] memory airdropWallets, uint256[] memory amounts) external onlyOwner{

        require(airdropWallets.length < 100, "Can only airdrop 100 wallets per txn due to gas limits");
        for(uint256 i = 0; i < airdropWallets.length; i++){
            address wallet = airdropWallets[i];
            uint256 amount = (amounts[i] * 10**_decimals);
            _transfer(msg.sender, wallet, amount);
        }
    }

    function reverseSniper(address sniper) external onlyOwner {

        _blacklisted[sniper] = false;
    }

    function addNewMarketMaker(address newAMM) external onlyOwner {

        _automatedMarketMakers[newAMM] = true;
        _isLimitless[newAMM] = true;
    }

    function controlAntiSniperMode(bool value) external onlyOwner {

        antiSniperMode = value;
    }

    function clearStuckBalance() external onlyOwner {

        uint256 contractETHBalance = address(this).balance;
        payable(owner).transfer(contractETHBalance);
    }

    function clearStuckToken(address _token) public onlyOwner {

        uint256 _contractBalance = ERC20(_token).balanceOf(address(this));
        payable(devOpsReceiver).transfer(_contractBalance);
    }

    function getCirculatingSupply() public view returns (uint256) {

        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    function showSniperList() public view returns(address[] memory){

        return sniperList;
    }

    function showSniperListLength() public view returns(uint256){

        return sniperList.length;
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {

        return accuracy * (balanceOf(pair) * (2)) / (getCirculatingSupply());
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {

        return getLiquidityBacking(accuracy) > target;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {

        require(sender != address(0) && recipient != address(0), "Cannot be address(0)");
        bool isBuy = _automatedMarketMakers[sender];
        bool isSell = _automatedMarketMakers[recipient];
        bool isExcluded = _isLimitless[sender] || _isLimitless[recipient] || _addingLP;

        if (isExcluded) {
            _transferExcluded(sender, recipient, amount);
        } else {
            require(_initialDistributionFinished);
            if (antiSniperMode) {
                _punishSnipers(sender, recipient, amount);
            } else if (isBuy) {
                _buyTokens(sender, recipient, amount);
            } else if (isSell) {
                if (shouldSwapBack()) {
                    swapBack();
                }
                _sellTokens(sender, recipient, amount);
            } else {
                require(!_blacklisted[sender] && !_blacklisted[recipient]);
                require(balanceOf(recipient) + amount <= maxWalletAmount);
                _P2PTransfer(sender, recipient, amount);
            }
        }
    }

    function _punishSnipers(address sender, address recipient, uint256 amount) private {

        require(!_blacklisted[recipient]);
        require(amount <= maxBuyAmount, "Buy exceeds limit");
        tokenTax = amount * 90 / 100;
        _blacklisted[recipient] = true;
        sniperList.push(address(recipient));
        _transferIncluded(sender, recipient, amount, tokenTax);
    }

    function _buyTokens(address sender, address recipient, uint256 amount) private {

        require(!_blacklisted[recipient]);
        require(amount <= maxBuyAmount, "Buy exceeds limit");
        if (!_whitelisted[recipient]) {
            tokenTax = amount*buyFee.total / 1000;
        } else {
            tokenTax = 0;
        }
        _transferIncluded(sender, recipient, amount, tokenTax);
    }

    function _sellTokens(address sender, address recipient, uint256 amount) private {

        require(!_blacklisted[sender]);
        require(amount <= maxSellAmount);
        if (!_whitelisted[sender]) {
            tokenTax = amount*sellFee.total / 1000;
        } else {
            tokenTax = 0;
        }
        _transferIncluded(sender, recipient, amount, tokenTax);
    }

    function _P2PTransfer(address sender, address recipient, uint256 amount) private {

        tokenTax = amount * transferFee / 1000;
        if (tokenTax > 0) {
            _transferIncluded(sender, recipient, amount, tokenTax);
        } else {
            _transferExcluded(sender, recipient, amount);
        }
    }

    function _transferExcluded(address sender, address recipient, uint256 amount) private {

        _updateBalance(sender, _balances[sender] - amount);
        _updateBalance(recipient, _balances[recipient] + amount);
        emit Transfer(sender, recipient, amount);
    }

    function _transferIncluded(address sender, address recipient, uint256 amount, uint256 taxAmount) private {

        uint256 newAmount = amount - tokenTax;
        _updateBalance(sender, _balances[sender] - amount);
        _updateBalance(address(this), _balances[address(this)] + taxAmount);
        _updateBalance(recipient, _balances[recipient] + newAmount);
        emit Transfer(sender, recipient, newAmount);
        emit Transfer(sender, address(this), taxAmount);
    }

    function _updateBalance(address account, uint256 newBalance) private {

        _balances[account] = newBalance;
    }

    function shouldSwapBack() private view returns (bool) {

        return
            !inSwap &&
            swapEnabled &&
            _balances[address(this)] >= swapThreshold;
    }   

    function swapBack() private swapping {

        uint256 toSwap = balanceOf(address(this));

        uint256 totalLPTokens = toSwap * (sellFee.liquidityFee + buyFee.liquidityFee) / (sellFee.total + buyFee.total);
        uint256 tokensLeft = toSwap - totalLPTokens;
        uint256 LPTokens = totalLPTokens / 2;
        uint256 LPETHTokens = totalLPTokens - LPTokens;
        toSwap = tokensLeft + LPETHTokens;
        uint256 oldETH = address(this).balance;
        _swapTokensForETH(toSwap);
        uint256 newETH = address(this).balance - oldETH;
        uint256 LPETH = (newETH * LPETHTokens) / toSwap;
        _addLiquidity(LPTokens, LPETH);
        uint256 remainingETH = address(this).balance - oldETH;
        _distributeETH(remainingETH);
    }

    function _distributeETH(uint256 remainingETH) private {

        uint256 marketingFee = (buyFee.marketingFee + sellFee.marketingFee);
        uint256 devOpsFee = (buyFee.devOpsFee + sellFee.devOpsFee);
        uint256 totalFee = (marketingFee + devOpsFee);

        uint256 amountETHmarketing = remainingETH * (marketingFee) / (totalFee);
        uint256 amountETHdevOps = remainingETH * (devOpsFee) / (totalFee);

        if (amountETHdevOps > 0) {
            (bool devOpsSuccess, /* bytes memory data */) = payable(devOpsReceiver).call{ value: amountETHdevOps, gas: 30000 }("");
            require(devOpsSuccess, "Receiver rejected ETH transfer");
        }
        
        if (amountETHmarketing > 0) {
            (bool marketingSuccess, /* bytes memory data */) = payable(marketingReceiver).call{ value: amountETHmarketing, gas: 30000 }("");
            require(marketingSuccess, "Receiver rejected ETH transfer");
        }
    }

    function _swapTokensForETH(uint256 amount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 amountTokens,uint256 amountETH) private {

        _addingLP = true;
        router.addLiquidityETH{ value: amountETH }(
            address(this),
            amountTokens,
            0,
            0,
            devOpsReceiver,
            block.timestamp
        );
        _addingLP = false;
    }

    receive() external payable { }

    function totalSupply() external view override returns (uint256) { return _totalSupply; }

    function decimals() external pure override returns (uint8) { return _decimals; }

    function symbol() external pure override returns (string memory) { return _symbol; }

    function name() external pure override returns (string memory) { return _name; }

    function getOwner() external view override returns (address) { return owner; }

    function balanceOf(address account) public view override returns (uint256) { return _balances[account];}

    function allowance(address holder, address spender) external view override returns (uint256) { return _allowances[holder][spender];}


    function approve(address spender, uint256 amount) public override returns (bool) {

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        uint256 allowance_ = _allowances[sender][msg.sender];
        require(allowance_ >= amount);
        
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        _transfer(sender, recipient, amount);
        return true;
    }
}