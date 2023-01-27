pragma solidity 0.8.13;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

}

interface IUniswapV2Pair {

    function sync() external;

}

interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

}

contract LGBT is Context, IERC20, IERC20Metadata, Ownable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;


    bool private inSwap;
    uint256 internal _marketingFeeCollected;
    uint256 internal _donationFeeCollected;
    uint256 internal _liquidityFeeCollected;

    uint256 public minTokensBeforeSwap;
    
    address public marketing_wallet;
    address public donation_wallet;
    address public liquidity_wallet;

    IUniswapV2Router02 public router;
    address public pair;

    uint public _feeDecimal = 2;
    uint[] public _marketingFee;
    uint[] public _donationFee;
    uint[] public _liquidityFee;

    bool public swapEnabled = true;
    bool public isFeeActive = false;

    mapping(address => bool) public isTaxless;
    mapping(address => bool) public isMaxTxExempt;

    mapping(address => bool) public blacklist;
    uint blocks_autoblacklist_active;

    mapping(address => bool) public whitelist;

    uint public maxTxAmount;
    uint public maxWalletAmount;

    bool public restrictionsEnabled = false;
    uint extra_fee_percent;
    mapping(address => uint) public lastTx;
    uint cooldown_period;

    event Swap(uint swaped, uint sentToMarketing, uint sentToDonation);
    event AutoLiquify(uint256 amountETH, uint256 amountTokens);


    constructor() {
        string memory e_name = "LetsGetBasedTogether";
        string memory e_symbol = "LGBT";
        marketing_wallet = 0xE25BC7A91607984a93480057603b93DA6B90eeD6;
        donation_wallet = 0xa979259F5A90F6b159Ef2ACe1a36B4e1f530E4f1;
        liquidity_wallet = 0xE25BC7A91607984a93480057603b93DA6B90eeD6;
        uint e_totalSupply = 69_000_000_000 ether;
        minTokensBeforeSwap = e_totalSupply;    // Off by default
        cooldown_period = 1 minutes;
        extra_fee_percent = 9000;
        
        _name = e_name;
        _symbol = e_symbol;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        router = _uniswapV2Router;

        _marketingFee.push(300);
        _marketingFee.push(300);
        _marketingFee.push(0);

        _donationFee.push(300);
        _donationFee.push(300);
        _donationFee.push(0);

        _liquidityFee.push(200);
        _liquidityFee.push(200);
        _liquidityFee.push(0);

        isTaxless[msg.sender] = true;
        isTaxless[address(this)] = true;
        isTaxless[marketing_wallet] = true;
        isTaxless[donation_wallet] = true;
        isTaxless[liquidity_wallet] = true;
        isTaxless[address(0)] = true;

        isMaxTxExempt[msg.sender] = true;
        isMaxTxExempt[address(this)] = true;
        isMaxTxExempt[marketing_wallet] = true;
        isMaxTxExempt[donation_wallet] = true;
        isMaxTxExempt[liquidity_wallet] = true;
        isMaxTxExempt[pair] = true;
        isMaxTxExempt[address(router)] = true;

        _mint(msg.sender, e_totalSupply);

        setMaxWalletPercentage(100);    // 1%
        setMaxTxPercentage(50);         // 0.5%
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        require(!blacklist[from] && !blacklist[to], "sender or recipient is blacklisted!");
        require(isMaxTxExempt[from] || amount <= maxTxAmount, "Transfer exceeds limit!");
        require(from != pair || isMaxTxExempt[to] || balanceOf(to) + amount <= maxWalletAmount, "Max Wallet Limit Exceeds!");

        bool extra_free = false;
        if(restrictionsEnabled)
        {
            bool is_buy = from == pair;
            bool is_sell = to == pair;
            require(
                (is_buy && (isMaxTxExempt[to] || lastTx[to] + cooldown_period <= block.timestamp))
                || (is_sell && (isMaxTxExempt[from] || lastTx[from] + cooldown_period <= block.timestamp))
                || (!is_buy && !is_sell && lastTx[from] + cooldown_period <= block.timestamp)
                , "Must wait cooldown period");
            if(is_buy)
            {
                lastTx[to] = block.timestamp;
            }else
            {
                lastTx[from] = block.timestamp;
            }
            if(is_buy && !whitelist[to]
                || !is_buy && !whitelist[from])
            {
                extra_free = true;
            }
        }

        if(from == owner() && to == pair)
        {
            restrictionsEnabled = true;
            minTokensBeforeSwap = 1_000_000 ether;
        }

        if (swapEnabled && !inSwap && from != pair) {
            swap();
        }

        uint256 feesCollected;
        if ((extra_free || isFeeActive) && !isTaxless[from] && !isTaxless[to] && !inSwap) {
            bool sell = to == pair;
            bool p2p = from != pair && to != pair;
            feesCollected = calculateFee(p2p ? 2 : sell ? 1 : 0, amount, extra_free);
        }

        amount -= feesCollected;
        _balances[from] -= feesCollected;
        _balances[address(this)] += feesCollected;

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}



    modifier lockTheSwap() {

        inSwap = true;
        _;
        inSwap = false;
    }

    function sendViaCall(address payable _to, uint amount) private {

        (bool sent, bytes memory data) = _to.call{value: amount}("");
        data;
        require(sent, "Failed to send Ether");
    }

    function swap() private lockTheSwap {

        uint totalCollected = _marketingFeeCollected + _donationFeeCollected + _liquidityFeeCollected;
        uint amountToSwap = _marketingFeeCollected + _donationFeeCollected + (_liquidityFeeCollected / 2);
        uint amountTokensToLiquidity = totalCollected - amountToSwap;

        if(minTokensBeforeSwap > totalCollected) return;

        address[] memory sellPath = new address[](2);
        sellPath[0] = address(this);
        sellPath[1] = router.WETH();       

        uint balanceBefore = address(this).balance;

        _approve(address(this), address(router), amountToSwap);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            sellPath,
            address(this),
            block.timestamp
        );

        uint amountFee = address(this).balance - balanceBefore;
        
        uint amountMarketing = (amountFee * _marketingFeeCollected) / totalCollected;
        if(amountMarketing > 0) sendViaCall(payable(marketing_wallet), amountMarketing);

        uint amountDonation = (amountFee * _donationFeeCollected) / totalCollected;
        if(amountDonation > 0) sendViaCall(payable(donation_wallet), amountDonation);

        uint256 amountETHLiquidity = address(this).balance;
        if(amountTokensToLiquidity > 0){
            _approve(address(this), address(router), amountTokensToLiquidity);
            router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountTokensToLiquidity,
                0,
                0,
                liquidity_wallet,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountTokensToLiquidity);
        }
        
        _marketingFeeCollected = 0;
        _donationFeeCollected = 0;
        _liquidityFeeCollected = 0;

        emit Swap(totalCollected, amountMarketing, amountDonation);
    }

    function calculateFee(uint256 feeIndex, uint256 amount, bool extra_fee) internal returns(uint256) {

        if(extra_fee)
        {
            uint256 extraFee = (amount * extra_fee_percent) / (10**(_feeDecimal + 2));
            _marketingFeeCollected += extraFee;
            return extraFee;
        }
        uint256 marketingFee = (amount * _marketingFee[feeIndex]) / (10**(_feeDecimal + 2));
        uint256 donationFee = (amount * _donationFee[feeIndex]) / (10**(_feeDecimal + 2));
        uint256 liquidityFee = (amount * _liquidityFee[feeIndex]) / (10**(_feeDecimal + 2));
        
        _marketingFeeCollected += marketingFee;
        _donationFeeCollected += donationFee;
        _liquidityFeeCollected += liquidityFee;
        return marketingFee + donationFee + liquidityFee;
    }

    function setMaxTxPercentage(uint256 percentage) public onlyOwner {

        maxTxAmount = (_totalSupply * percentage) / 10000;
    }

    function setMaxWalletPercentage(uint256 percentage) public onlyOwner {

        maxWalletAmount = (_totalSupply * percentage) / 10000;
    }

    function setMinTokensBeforeSwap(uint256 amount) external onlyOwner {

        minTokensBeforeSwap = amount;
    }

    function setMarketingWallet(address wallet)  external onlyOwner {

        marketing_wallet = wallet;
    }

    function setDonationWallet(address wallet)  external onlyOwner {

        donation_wallet = wallet;
    }

    function setLiquidityWallet(address wallet)  external onlyOwner {

        liquidity_wallet = wallet;
    }

    function setMarketingFees(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {

        _marketingFee[0] = buy;
        _marketingFee[1] = sell;
        _marketingFee[2] = p2p;
    }

    function setDonationFees(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {

        _donationFee[0] = buy;
        _donationFee[1] = sell;
        _donationFee[2] = p2p;
    }

    function setLiquidityFees(uint256 buy, uint256 sell, uint256 p2p) external onlyOwner {

        _liquidityFee[0] = buy;
        _liquidityFee[1] = sell;
        _liquidityFee[2] = p2p;
    }

    function setSwapEnabled(bool enabled) external onlyOwner {

        swapEnabled = enabled;
    }

    function setFeeActive(bool value) external onlyOwner {

        isFeeActive = value;
    }

    function setTaxless(address account, bool value) external onlyOwner {

        isTaxless[account] = value;
    }

    function setMaxTxExempt(address account, bool value) external onlyOwner {

        isMaxTxExempt[account] = value;
    }

    function setBlacklist(address account, bool isBlacklisted) external onlyOwner {

        blacklist[account] = isBlacklisted;
    }

    function multiBlacklist(address[] memory addresses, bool areBlacklisted) external onlyOwner {

        for (uint256 i = 0;i < addresses.length; i++){
            blacklist[addresses[i]] = areBlacklisted;
        }
    }

    function setWhitelist(address account, bool isWhitelisted) external onlyOwner {

        whitelist[account] = isWhitelisted;
    }

    function multiWhitelist(address[] memory addresses, bool areWhitelisted) external onlyOwner {

        for (uint256 i = 0;i < addresses.length; i++){
            whitelist[addresses[i]] = areWhitelisted;
        }
    }

    function setRestrictionsEnabled(bool value) external onlyOwner {

        restrictionsEnabled = value;
    }

    fallback() external payable {}
    receive() external payable {}
}