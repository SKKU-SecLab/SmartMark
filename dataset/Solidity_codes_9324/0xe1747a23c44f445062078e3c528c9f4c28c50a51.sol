






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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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




pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}




interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

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




pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}




pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}



pragma solidity ^0.8.0;


contract Token is ERC20, Ownable {

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    
    address public marketingWallet;
    address public devWallet;
    address public stakingWallet;
    address public liquidityWallet;

    uint256 public marketingFee;
    uint256 public devFee;
    uint256 public stakingFee;
    uint256 public liquidityFee;
    uint256 public totalFees;

    bool public noBuyTax;

    uint256 immutable public maxTotalFees;

    uint256 public minAmountToSwap;
    bool private swapping;

    bool canSwapAndLiquify = true;
    bool canBuyBack = true;
    uint256 public buyBackAmount = 10**15;
    address public deadAddress = 0x000000000000000000000000000000000000dEaD;

    mapping (address => bool) public automatedMarketMakerPairs;

    mapping (address => bool) private _isExcludedFromFees;

    mapping (address => bool) private _isExcludedFromFeesAndSwapLiquify;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromFeesAndSwapLiquify(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event MarketingWalletUpdated(address indexed newMarketingWallet, address indexed oldMarketingWallet);
    event DevWalletUpdated(address indexed newDevWalletWallet, address indexed devWalletUpdated);
    event StakingWalletUpdated(address indexed newStakingWallet, address indexed stakingWalletUpdated);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed liquidityWalletUpdated);

    event MarketingFeeUpdated(uint256 indexed newmarketingFee);
    event DevFeeUpdated(uint256 indexed newDevFee);
    event StakingFeeUpdated(uint256 indexed newStakingFee);
    event LiquidityFeeUpdated(uint256 indexed newLiquidityFee);

    event SwapAndLiquify(
    uint256 tokensSwapped,
    uint256 ethReceived,
    uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap {
        swapping = true;
        _;
        swapping = false;
    }

    constructor() ERC20("Eterna", "EHX") {
        marketingFee = 60;
        devFee = 60;
        stakingFee = 60;
        liquidityFee = 70;
        totalFees = marketingFee + devFee + stakingFee + liquidityFee;
        maxTotalFees = totalFees;
        minAmountToSwap = 1_000;

        marketingWallet = 0xe75A8bdd32aCBbF0F8EA0A31954413132Bb0F4F6;
        devWallet = 0xbC95F136E7FCA6FeCd1619c7561a6F4Eef9d5936;
        stakingWallet = 0x7203E6951f7cb4E8089bbD1e556B9E20EB21C3aD;
        liquidityWallet = 0x14F4366c86ec577c3daE0aDb6abeF0c13c4cfb74;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _mint(owner(), 1_000_000_000 * (10**18));

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        excludeFromFees(marketingWallet, true);
        excludeFromFees(devWallet, true);
        excludeFromFees(stakingWallet, true);
        excludeFromFees(address(this), true);



    }

    receive() external payable {
    }

    function updateUniswapV2Router(address newAddress) public onlyOwner {
        require(newAddress != address(uniswapV2Router), "the router already has that address");
        emit UpdateUniswapV2Router(newAddress, address(uniswapV2Router));
        uniswapV2Router = IUniswapV2Router02(newAddress);
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != uniswapV2Pair, "The PancakeSwap pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function excludeFromFeesAndSwapLiquify(address account, bool excluded) public onlyOwner {
        _isExcludedFromFeesAndSwapLiquify[account] = excluded;
        emit ExcludeFromFeesAndSwapLiquify(account, excluded);
    }

    function updateMarketingWallet(address newMarketingWallet) public onlyOwner {
        require(newMarketingWallet != marketingWallet, "the marketing wallet is already this address");
        excludeFromFees(newMarketingWallet, true);
        emit MarketingWalletUpdated(newMarketingWallet, marketingWallet);
        marketingWallet = newMarketingWallet;
    }

    function updateDevWallet(address newDevWallet) public onlyOwner {
        require(newDevWallet != devWallet, ": The dev wallet is already this address");
        excludeFromFees(newDevWallet, true);
        emit LiquidityWalletUpdated(newDevWallet, devWallet);
        devWallet = newDevWallet;
    }

    function updateStakingWallet(address newStakingWallet) public onlyOwner {
        require(newStakingWallet != stakingWallet, ": The liquidity wallet is already this address");
        excludeFromFees(newStakingWallet, true);
        emit LiquidityWalletUpdated(newStakingWallet, stakingWallet);
        stakingWallet = newStakingWallet;
    }

    function updateLiquidityWallet(address newLiquidityWallet) public onlyOwner {
        require(newLiquidityWallet != liquidityWallet, ": The liquidity wallet is already this address");
        excludeFromFees(newLiquidityWallet, true);
        emit LiquidityWalletUpdated(newLiquidityWallet, liquidityWallet);
        liquidityWallet = newLiquidityWallet;
    }

    function updateMarketingFee(uint256 newMarketingFee) public onlyOwner {
        marketingFee = newMarketingFee;
        totalFees = marketingFee + liquidityFee + devFee + stakingFee;
        require(totalFees <= maxTotalFees);
        emit MarketingFeeUpdated(newMarketingFee);
    }

    function updateLiquidityFee(uint256 newLiquidityFee) public onlyOwner {
        liquidityFee = newLiquidityFee;
        totalFees = marketingFee + liquidityFee + devFee + stakingFee;
        require(totalFees <= maxTotalFees);
        emit LiquidityFeeUpdated(newLiquidityFee);
    }

    function updateDevFee(uint256 newDevFee) public onlyOwner {
        devFee = newDevFee;
        totalFees = marketingFee + liquidityFee + devFee + stakingFee;
        require(totalFees <= maxTotalFees);
        emit DevFeeUpdated(newDevFee);
    }

    function updatestakingFee(uint256 newStakingFee) public onlyOwner {
        stakingFee = newStakingFee;
        totalFees = marketingFee + liquidityFee + devFee + stakingFee;
        require(totalFees <= maxTotalFees);
        emit StakingFeeUpdated(newStakingFee);
    }

    function updateCanSwapAndLiquify(bool _canSwapAndLiquify) external onlyOwner {
        canSwapAndLiquify = _canSwapAndLiquify;
    }

    function updateCanBuyBack(bool _canBuyBack) external onlyOwner {
        canBuyBack = _canBuyBack;
    }

    function updateBuyBackAmount(uint256 _buyBackAmount) public onlyOwner {
        buyBackAmount = _buyBackAmount;
    }

    function updateMinAmountToSwap(uint256 _minAmountToSwap) external onlyOwner {
        minAmountToSwap = _minAmountToSwap;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function isExcludedFromFeesAndSwapAndLiquify(address account) public view returns(bool) {
        return _isExcludedFromFeesAndSwapLiquify[account];
    }

    function removeBuyTax(bool _noBuyTax) external onlyOwner {
        noBuyTax = _noBuyTax;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(automatedMarketMakerPairs[from] && noBuyTax) {
            super._transfer(from, to, amount);
            return;
        }

        if(_isExcludedFromFeesAndSwapLiquify[from] || _isExcludedFromFeesAndSwapLiquify[to]) {
            super._transfer(from, to, amount);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= minAmountToSwap;

        if(
            canSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != devWallet &&
            to != devWallet &&
            from != marketingWallet &&
            to != marketingWallet &&
            from != stakingWallet &&
            to != stakingWallet &&
            canSwapAndLiquify
        ) {

            swapping = true;
            
            uint256 tokensForLiquidity = (contractTokenBalance * liquidityFee / 2) / (totalFees);
            
            uint256 tokensForMarketing = (contractTokenBalance * marketingFee) / totalFees;
            uint256 tokensForDev = (contractTokenBalance * devFee) / totalFees;
            uint256 tokensForStaking = (contractTokenBalance * stakingFee) / totalFees;
            super._transfer(address(this), stakingWallet, tokensForStaking);

            uint256 ETHBefore = address(this).balance;
            uint256 tokensToSwap = tokensForLiquidity + tokensForMarketing + tokensForDev;

            swapTokensForEth(tokensToSwap);
            uint256 EthSwapped = address(this).balance - ETHBefore; // How much did we get?

            uint256 swappedFees = totalFees - liquidityFee/2 - stakingFee;
            uint256 hypotheticalEthBalance = (EthSwapped * totalFees) / swappedFees;
            uint256 ethForLiquidity = (hypotheticalEthBalance * liquidityFee / 2) / totalFees;
            uint256 ethForMarketing = hypotheticalEthBalance * marketingFee / totalFees;
            uint256 ethForDev = hypotheticalEthBalance * devFee / totalFees;

            addLiquidity(tokensForLiquidity, ethForLiquidity);

            payable(marketingWallet).transfer(ethForMarketing);
            payable(devWallet).transfer(ethForDev);

            swapping = false;
        }

        if(canBuyBack && address(this).balance > buyBackAmount * 10 && !automatedMarketMakerPairs[from] && !swapping){
                buyBackTokens(buyBackAmount);
        }

        bool takeFee = !swapping;
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
            uint256 fees = amount*totalFees/1000;
            amount = amount - fees;

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            liquidityWallet,
            block.timestamp
        );
        
    }

    function swapTokensForEth(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function buyBackTokens(uint256 amount) private lockTheSwap{
        if (amount > 0) {
            swapETHForTokens(amount);
        }
    }

    function swapETHForTokens(uint256 amount) private {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = address(this);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0, // accept any amount of Tokens
            path,
            deadAddress,
            block.timestamp
        );
    }


}