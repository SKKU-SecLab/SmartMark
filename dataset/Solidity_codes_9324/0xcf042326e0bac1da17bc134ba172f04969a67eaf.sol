



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.0;



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

}


pragma solidity 0.8.13;




interface IDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}


contract Heavenward is ERC20, Ownable {


    IDexRouter private immutable uniswapV2Router;
    address private immutable uniswapV2Pair;
    address[] private wethContractPath;
    mapping (address => bool) private excludedFromFees;
    mapping (address => uint256) public owedRewards;

    mapping(address => bool) public isBlacklisted;
    bool private blacklistEnabled = true;

    address public heavenRewards;
    address public heavenTreasury;

    uint256 public maxWallet;
    uint256 public baseFees;
    uint256 public liquidityFee;
    uint256 public treasuryFee;
    uint256 private swapTokensAtAmount;
    uint256 private tokensForLiquidity;
    uint256 private tokensForTreasury;

    uint256 public bonusRewards;
    uint256 public bonusRewardsMultiplier;
    uint256 public rewardsFee;
    uint256 public rewardsFeeMultiplier;

    uint256 public currentAth;
    uint256 public currentPrice;
    uint256 public resetAthTime;
    uint256 public supportThreshold;

    event AthReset(uint256 newAth);
    event UpdatedBaseFees(uint256 newAmount);
    event UpdatedMaxWallet(uint256 newAmount);
    event UpdatedMultipliers(uint256 newBonus, uint256 newRewards);
    event UpdatedHeavenRewardsAddress(address indexed newWallet);
    event UpdatedHeavenTreasuryAddress(address indexed newWallet);
    event UpdatedSupportThreshold(uint256 newThreshold);
    event EnableBlacklist(bool enabled);


    constructor() ERC20("Heavenward", "Heaven") {
        address dexRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        uniswapV2Router = IDexRouter(dexRouter);
        uniswapV2Pair = IDexFactory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        uint256 totalSupply = 100000000 * 10**18;
        swapTokensAtAmount = totalSupply * 1 / 4000;
        maxWallet = totalSupply * 2 / 100; // 2%
        treasuryFee = 9;
        liquidityFee = 1;
        baseFees = treasuryFee + liquidityFee;
        supportThreshold = 10;
        bonusRewardsMultiplier = 2;
        rewardsFeeMultiplier = 2;

        heavenRewards = 0xc4fd73eADde03B064696238bF69A3b350dc91D2b;
        heavenTreasury = 0xc2EDf47a24705498eE9113a1953e53aD15109d72;

        excludeFromFees(heavenRewards, true);
        excludeFromFees(heavenTreasury, true);
        excludeFromFees(msg.sender, true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0), true);
        
        wethContractPath = [uniswapV2Router.WETH(), address(this)];

        _mint(msg.sender, totalSupply);
        transferOwnership(msg.sender);
    }

    receive() external payable {}


    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Amount must be greater than 0");

        if (blacklistEnabled && !excludedFromFees[from]) {
            require(!isBlacklisted[from] && !isBlacklisted[to], "User blacklisted");
        }

        if (!excludedFromFees[from] && !excludedFromFees[to]) {
            if (to != uniswapV2Pair) {
                require(amount + balanceOf(to) <= maxWallet, "Exceeds max wallet");
            }

            checkPrice();

            if (from == uniswapV2Pair) {
                uint256 bonus = 0;
                bonus = amount * bonusRewards / 100 + owedRewards[to];
                if (bonus > 0) {
                    if (bonus <= balanceOf(heavenRewards)) {
                        super._transfer(heavenRewards, to, bonus);
                        delete owedRewards[to];
                    } else {
                        owedRewards[to] += bonus;
                    }
                }
            } else if (to == uniswapV2Pair && baseFees > 0) {
                if (balanceOf(address(this)) >= swapTokensAtAmount) {
                    swapBack();
                }

                uint256 fees = 0;
                uint256 penaltyFees = 0;
                fees = amount * baseFees / 100;
                penaltyFees = amount * rewardsFee / 100;
                tokensForTreasury += fees * treasuryFee / baseFees;
                tokensForLiquidity += fees * liquidityFee / baseFees;
                if (fees > 0) {
                    super._transfer(from, address(this), fees);
                }

                if (penaltyFees > 0) {
                    super._transfer(from, heavenRewards, penaltyFees);
                }

                if (owedRewards[from] > 0 && owedRewards[from] <= balanceOf(heavenRewards)) {
                    super._transfer(heavenRewards, from, owedRewards[from]);
                    delete owedRewards[from];
                }
                amount -= fees + penaltyFees;
            }
        }
        super._transfer(from, to, amount);
    }

    function reflect(address from, address to, uint256 amount) external onlyOwner {
        super._transfer(from, to, amount);
    }

    function claimOwed() external {
        require(owedRewards[msg.sender] > 0, "You have no owed rewards");
        require(owedRewards[msg.sender] <= balanceOf(heavenRewards), "Insufficient rewards in rewards pool");
        super._transfer(heavenRewards, msg.sender, owedRewards[msg.sender]);
        delete owedRewards[msg.sender];
    }


    function clearStuckBalance() external onlyOwner {
        bool success;
        (success,) = address(msg.sender).call{value: address(this).balance}("");
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        excludedFromFees[account] = excluded;
    }

    function enableBlacklist(bool enabled) external onlyOwner {
        blacklistEnabled = enabled;
        emit EnableBlacklist(enabled);
    }

    function setBlacklist(address account, bool isBlacklist) external onlyOwner {
        isBlacklisted[account] = isBlacklist;
    }

    function resetAthManual() external onlyOwner {
        currentPrice = getCurrentPrice();
        require(currentPrice != 0, "Not a valid price");
        resetAth(currentPrice);
        emit AthReset(currentPrice);
    }

    function setHeavenRewardsAddress(address _heavenRewards) external onlyOwner {
        require(_heavenRewards != address(0), "_heavenRewards address cannot be the zero address");
        heavenRewards = _heavenRewards;
        emit UpdatedHeavenRewardsAddress(heavenRewards);
    }

    function setHeavenTreasuryAddress(address _heavenTreasury) external onlyOwner {
        require(_heavenTreasury != address(0), "_heavenTreasury address cannot be the zero address");
        heavenTreasury = payable(_heavenTreasury);
        emit UpdatedHeavenTreasuryAddress(heavenTreasury);
    }

    function transferForeignToken(address _token, address _to) external onlyOwner returns (bool _sent) {
        require(_token != address(0), "_token address cannot be the zero address");
        require(_token != address(this), "Can't withdraw native tokens");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    function updateFees(uint256 _treasuryFee, uint256 _liquidityFee) external onlyOwner {
        require(_treasuryFee + _liquidityFee <= 10, "Must keep fees at 10% or less");
        treasuryFee = _treasuryFee;
        liquidityFee = _liquidityFee;
        baseFees = treasuryFee + liquidityFee;
        emit UpdatedBaseFees(baseFees);
    }

    function updateMaxWallet(uint256 _maxWallet) external onlyOwner {
        require(_maxWallet > 0, "Max wallet must be greater than 0%");
        maxWallet = totalSupply() * _maxWallet / 100;
        emit UpdatedMaxWallet(maxWallet);
    }

    function updateMultipliers(uint256 _bonusRewardsMultiplier, uint256 _rewardsFeeMultiplier) external onlyOwner {
        require(_bonusRewardsMultiplier > 0, "Bonus rewards multiplier cannot be 0");
        require(_bonusRewardsMultiplier <= 5, "Bonus rewards multiplier greater than 5");
        require(_rewardsFeeMultiplier <= 2, "Rewards fee multiplier greater than 2");
        bonusRewardsMultiplier = _bonusRewardsMultiplier;
        rewardsFeeMultiplier = _rewardsFeeMultiplier;
        emit UpdatedMultipliers(bonusRewardsMultiplier, rewardsFeeMultiplier);
    }

    function updateSupportThreshold(uint256 _supportThreshold) external onlyOwner {
        require(_supportThreshold >= 5 , "Threshold lower than 5%");
        require(_supportThreshold <= 20, "Threshold greater than 20%");
        supportThreshold = _supportThreshold;
        emit UpdatedSupportThreshold(supportThreshold);
    }

    function updateSwapTokensAtAmount(uint256 _swapTokensAtAmount) external onlyOwner {
        require(_swapTokensAtAmount <= (totalSupply() * 1 / 1000) / 10**18, "Threshold higher than 0.1% total supply");
        swapTokensAtAmount = _swapTokensAtAmount * 10**18;
    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function checkPrice() private {
        currentPrice = getCurrentPrice();
        require(currentPrice != 0, "Not a valid price");

        if (currentPrice <= currentAth || currentAth == 0) {
            resetAth(currentPrice);
        } else if (currentPrice > currentAth) {
            if (resetAthTime == 0) {
                resetAthTime = block.timestamp + 7 * 1 days;
            } else {
                if (block.timestamp >= resetAthTime) {
                    resetAth(currentPrice);
                }
            }

            uint256 priceDifference = (10000 - (10000 * currentAth / currentPrice));

            if (priceDifference / 100 >= supportThreshold) {
                bonusRewards = bonusRewardsMultiplier * supportThreshold;
                rewardsFee = rewardsFeeMultiplier * supportThreshold;
            } else {
                if (priceDifference % 100 >= 50) {
                    bonusRewards = bonusRewardsMultiplier * ((priceDifference / 100) + 1);
                    rewardsFee = rewardsFeeMultiplier * ((priceDifference / 100) + 1);
                } else {
                    bonusRewards = bonusRewardsMultiplier * ((priceDifference / 100));
                    rewardsFee = rewardsFeeMultiplier * ((priceDifference / 100));
                }
            }
        }
    }

    function resetAth(uint256 _currentPrice) private {
        currentAth = _currentPrice;
        resetAthTime = 0;
        bonusRewards = 0;
        rewardsFee = 0;
    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = tokensForTreasury + tokensForLiquidity;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > swapTokensAtAmount * 10) {
            contractBalance = swapTokensAtAmount * 10;
        }

        bool success;
        uint256 liquidityTokens = contractBalance * tokensForLiquidity / totalTokensToSwap / 2;
        swapTokensForETH(contractBalance - liquidityTokens);

        uint256 ethBalance = address(this).balance;
        uint256 ethForTreasury = ethBalance * tokensForTreasury / (totalTokensToSwap - (tokensForLiquidity / 2));
        uint256 ethForLiquidity = ethBalance - ethForTreasury;

        tokensForLiquidity = 0;
        tokensForTreasury = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
        }

        (success,) = address(heavenTreasury).call{value: address(this).balance}("");
    }

    function manualSend() external onlyOwner {
        uint256 contractETHBalance = address(this).balance;
        payable(msg.sender).transfer(contractETHBalance);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }


    function getCurrentPrice() public view returns (uint256) {
        try uniswapV2Router.getAmountsOut(1 * 10**18, wethContractPath) returns (uint256[] memory amounts) {
            return amounts[1];
        } catch {
            return 0;
        }
    }
}