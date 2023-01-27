




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



pragma solidity >=0.5.0;

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



pragma solidity >=0.5.0;

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



pragma solidity >=0.6.2;

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



pragma solidity >=0.6.2;

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



pragma solidity ^0.8.2;







contract ExtendedReflections is Context, IERC20, Ownable {


    mapping (address => uint256) private _reflectionBalances;

    mapping (address => uint256) private _tokenBalances;

    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcludedFromReward;
    
    address[] private _excludedFromReward;

    mapping (address => mapping (address => uint256)) private _allowances;

    IUniswapV2Router02 internal _uniswapV2Router;

    address internal _uniswapV2Pair;

    address private constant burnAccount = 0x000000000000000000000000000000000000dEaD;

    address public marketingAddress;

    uint32 private _taxRewardDecimals;

    uint32 private _taxLiquifyDecimals;

    uint32 private _taxMarketingDecimals;

    uint32[] private _taxReward = [0,0,0];

    uint32[] private _taxLiquify = [0,0,0];

    uint32[] private _taxMarketing = [0,0,0];

    uint32 private _decimals;

    uint256 private _totalSupply;

    uint256 private _currentSupply;

    uint256 private _reflectionTotal;

    uint256 private _totalRewarded;

    uint256 private _totalBurnt;

    uint256 private _minTokensBeforeSwap;

    string private _name;
    string private _symbol;

    bool private _inSwapAndLiquify;

    bool private _autoSwapAndLiquifyEnabled;
    bool private _rewardEnabled;
    bool private _marketingRewardEnabled;

    uint256 private _marketingPending;
    
    modifier lockTheSwap {

        require(!_inSwapAndLiquify, "Currently in swap and liquify.");
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    struct ValuesFromAmount {
        uint256 amount;
        uint256 tRewardFee;
        uint256 tLiquifyFee;

        uint256 tMarketingFee;
        uint256 tTransferAmount;
        uint256 rAmount;
        uint256 rRewardFee;
        uint256 rLiquifyFee;

        uint256 rMarketingFee;
        uint256 rTransferAmount;
    }

    event Burn(address from, uint256 amount);
    event AMMPairUpdated(address pair, bool value);
    event TaxRewardUpdate(uint32[] previousTax, uint32 previousDecimals, uint32[] currentTax, uint32 currentDecimal);
    event TaxLiquifyUpdate(uint32[] previousTax, uint32 previousDecimals, uint32[] currentTax, uint32 currentDecimal);
    event TaxMarketingUpdate(uint32[] previousTax, uint32 previousDecimals, uint32[] currentTax, uint32 currentDecimal);
    event MinTokensBeforeSwapUpdated(uint256 previous, uint256 current);
    event MarketingAddressUpdated(address previous, address current);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensAddedToLiquidity
    );
    event ExcludeAccountFromReward(address account);
    event IncludeAccountInReward(address account);
    event ExcludeAccountFromFee(address account);
    event IncludeAccountInFee(address account);
    event EnabledReward();
    event EnabledAutoSwapAndLiquify();
    event EnabledMarketingReward();
    event DisabledReward();
    event DisabledAutoSwapAndLiquify();
    event DisabledMarketingReward();
    event Airdrop(uint256 amount);
    
    constructor (string memory name_, string memory symbol_, uint32 decimals_, uint256 tokenSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = tokenSupply_ * (10 ** decimals_);
        _currentSupply = _totalSupply;
        _reflectionTotal = (~uint256(0) - (~uint256(0) % _totalSupply));

        _reflectionBalances[_msgSender()] = _reflectionTotal;

        excludeAccountFromFee(owner());
        excludeAccountFromFee(address(this));

        excludeAccountFromReward(owner());
        excludeAccountFromReward(burnAccount);
        excludeAccountFromReward(address(this));

        excludeAccountFromLimits(owner());
        excludeAccountFromLimits(address(this));
        excludeAccountFromLimits(burnAccount);
        
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    receive() external payable {}

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint32) {

        return _decimals;
    }

    function uniswapV2Pair() public view virtual returns (address) {

        return _uniswapV2Pair;
    }

    function taxReward(uint32 mode) public view virtual returns (uint32) {

        return _taxReward[mode];
    }

    function taxLiquify(uint32 mode) public view virtual returns (uint32) {

        return _taxLiquify[mode];
    }

    function taxMarketing(uint32 mode) public view virtual returns (uint32) {

        return _taxMarketing[mode];
    }

    function taxRewardDecimals() public view virtual returns (uint32) {

        return _taxRewardDecimals;
    }

    function taxLiquifyDecimals() public view virtual returns (uint32) {

        return _taxLiquifyDecimals;
    }

    function taxMarketingDecimals() public view virtual returns (uint32) {

        return _taxMarketingDecimals;
    }

    function rewardEnabled() public view virtual returns (bool) {

        return _rewardEnabled;
    }

    function autoSwapAndLiquifyEnabled() public view virtual returns (bool) {

        return _autoSwapAndLiquifyEnabled;
    }


    function marketingRewardEnabled() public view virtual returns (bool) {

        return _marketingRewardEnabled;
    }

    function minTokensBeforeSwap() external view virtual returns (uint256) {

        return _minTokensBeforeSwap;
    }

    function totalSupply() external view virtual override returns (uint256) {

        return _totalSupply;
    }

    function currentSupply() external view virtual returns (uint256) {

        return _currentSupply;
    }

    function totalBurnt() external view virtual returns (uint256) {

        return _totalBurnt;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        if (_isExcludedFromReward[account]) return _tokenBalances[account];
        return tokenFromReflection(_reflectionBalances[account]);
    }

    function isExcludedFromReward(address account) external view returns (bool) {

        return _isExcludedFromReward[account];
    }

    function isExcludedFromFee(address account) external view returns (bool) {

        return _isExcludedFromFee[account];
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
        require(_allowances[sender][_msgSender()] >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
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

    function _burn(address account, uint256 amount) internal virtual {

        require(account != burnAccount, "ERC20: burn from the burn address");

        uint256 accountBalance = balanceOf(account);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        uint256 rAmount = _getRAmount(amount);

        if (_isExcludedFromReward[account]) {
            _tokenBalances[account] -= amount;
        } 
        _reflectionBalances[account] -= rAmount;

        _tokenBalances[burnAccount] += amount;
        _reflectionBalances[burnAccount] += rAmount;

        _currentSupply -= amount;

        _totalBurnt += amount;

        emit Burn(account, amount);
        emit Transfer(account, burnAccount, amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(sender) >= amount, "ERC20: transfer amount exceeds balance");
        
        if (sender != owner() && recipient != owner())
            _beforeTokenTransfer(sender);

        bool buying = false;

        if (AMMPairs[sender]) {
            buying = true;
        }

        bool selling = false;

        if (AMMPairs[recipient]) {
            selling = true;

            if (sender == owner() && _listingTime == 0) {
                _listingTime = block.timestamp;
            }
        }

        ValuesFromAmount memory values = _getValues(amount, !(!_isExcludedFromFee[sender] || (buying && !_isExcludedFromFee[recipient])), selling);

        if (buying && !isExcludedFromLimits[recipient]) {
            require(values.tTransferAmount <= maxBuyAmount, "Anti-whale: Buy amount exceeds max limit");
        }
        if (selling && !isExcludedFromLimits[sender]) {
            require(values.tTransferAmount <= maxSellAmount, "Anti-whale: Sell amount exceeds max limit");
        }
        if (!isExcludedFromLimits[recipient]) {
            require(balanceOf(recipient) + values.tTransferAmount <= maxWalletAmount, "Anti-whale: Wallet amount exceeds max limit");
        }

        if (_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferFromExcluded(sender, recipient, values);
        } else if (!_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferToExcluded(sender, recipient, values);
        } else if (!_isExcludedFromReward[sender] && !_isExcludedFromReward[recipient]) {
            _transferStandard(sender, recipient, values);
        } else if (_isExcludedFromReward[sender] && _isExcludedFromReward[recipient]) {
            _transferBothExcluded(sender, recipient, values);
        } else {
            _transferStandard(sender, recipient, values);
        }

        emit Transfer(sender, recipient, values.tTransferAmount);

        if (!_isExcludedFromFee[sender] || (buying && !_isExcludedFromFee[recipient])) {
            _afterTokenTransfer(values);
        }
    }

    function _beforeTokenTransfer(address sender) internal virtual {

        uint256 contractBalance = _tokenBalances[address(this)];

        bool overMinTokensBeforeSwap = contractBalance >= _minTokensBeforeSwap;

        if (overMinTokensBeforeSwap && !AMMPairs[sender]) {
            if (_marketingRewardEnabled && !_inSwapAndLiquify) {
                sendFeeToAddress(marketingAddress, _marketingPending);

                _marketingPending = 0;
            }

            if (_autoSwapAndLiquifyEnabled && !_inSwapAndLiquify) {
                swapAndLiquify(_tokenBalances[address(this)]);
            }
        }
    }

    function _afterTokenTransfer(ValuesFromAmount memory values) internal virtual {

        if (_rewardEnabled) {
            _distributeFee(values.rRewardFee, values.tRewardFee);
        }

        if (_marketingRewardEnabled) {
            _tokenBalances[address(this)] += values.tMarketingFee;
            _reflectionBalances[address(this)] += values.rMarketingFee;

            _marketingPending += values.tMarketingFee;
        }
        
        if (_autoSwapAndLiquifyEnabled) {
            _tokenBalances[address(this)] += values.tLiquifyFee;
            _reflectionBalances[address(this)] += values.rLiquifyFee;
        }
    }

    function _transferStandard(address sender, address recipient, ValuesFromAmount memory values) private {

        _reflectionBalances[sender] = _reflectionBalances[sender] - values.rAmount;
        _reflectionBalances[recipient] = _reflectionBalances[recipient] + values.rTransferAmount;
    }

    function _transferToExcluded(address sender, address recipient, ValuesFromAmount memory values) private {

        _reflectionBalances[sender] = _reflectionBalances[sender] - values.rAmount;
        _tokenBalances[recipient] = _tokenBalances[recipient] + values.tTransferAmount;
        _reflectionBalances[recipient] = _reflectionBalances[recipient] + values.rTransferAmount;
    }

    function _transferFromExcluded(address sender, address recipient, ValuesFromAmount memory values) private {

        _tokenBalances[sender] = _tokenBalances[sender] - values.amount;
        _reflectionBalances[sender] = _reflectionBalances[sender] - values.rAmount;
        _reflectionBalances[recipient] = _reflectionBalances[recipient] + values.rTransferAmount;
    }

    function _transferBothExcluded(address sender, address recipient, ValuesFromAmount memory values) private {

        _tokenBalances[sender] = _tokenBalances[sender] - values.amount;
        _reflectionBalances[sender] = _reflectionBalances[sender] - values.rAmount;
        _tokenBalances[recipient] = _tokenBalances[recipient] + values.tTransferAmount;
        _reflectionBalances[recipient] = _reflectionBalances[recipient] + values.rTransferAmount;
    }
    
    function burn(uint256 amount) public virtual {

        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {

        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }

    function excludeAccountFromReward(address account) public onlyOwner {

        require(!_isExcludedFromReward[account], "Account already excluded from reward");
        if(_reflectionBalances[account] > 0) {
            _tokenBalances[account] = tokenFromReflection(_reflectionBalances[account]);
        }
        _isExcludedFromReward[account] = true;
        _excludedFromReward.push(account);
        
        emit ExcludeAccountFromReward(account);
    }

    function includeAccountInReward(address account) public onlyOwner {

        require(_isExcludedFromReward[account], "Account is already included.");

        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (_excludedFromReward[i] == account) {
                _excludedFromReward[i] = _excludedFromReward[_excludedFromReward.length - 1];
                _tokenBalances[account] = 0;
                _isExcludedFromReward[account] = false;
                _excludedFromReward.pop();
                break;
            }
        }

        emit IncludeAccountInReward(account);
    }

    function excludeAccountFromFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = true;

        emit ExcludeAccountFromFee(account);
    }

    function includeAccountInFee(address account) public onlyOwner {

        require(_isExcludedFromFee[account], "Account is already included.");

        _isExcludedFromFee[account] = false;
        
        emit IncludeAccountInFee(account);
    }

    function airdrop(uint256 amount) public {

        address sender = _msgSender();
        require(balanceOf(sender) >= amount, "The caller must have balance >= amount.");
        ValuesFromAmount memory values = _getValues(amount, false, false);
        if (_isExcludedFromReward[sender]) {
            _tokenBalances[sender] -= values.amount;
        }
        _reflectionBalances[sender] -= values.rAmount;
        
        _reflectionTotal = _reflectionTotal - values.rAmount;
        _totalRewarded += amount;
        emit Airdrop(amount);
    }

    function reflectionFromToken(uint256 amount, bool deductTransferFee, bool selling) internal view returns(uint256) {

        require(amount <= _totalSupply, "Amount must be less than supply");
        ValuesFromAmount memory values = _getValues(amount, deductTransferFee, selling);
        return values.rTransferAmount;
    }

    function tokenFromReflection(uint256 rAmount) internal view returns(uint256) {

        require(rAmount <= _reflectionTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function swapAndLiquify(uint256 contractBalance) private {

        uint256 tokensToSwap = contractBalance / 2;
        uint256 tokensAddToLiquidity = contractBalance - tokensToSwap;

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(address(this), tokensToSwap);

        uint256 ethAddToLiquify = address(this).balance - initialBalance;

        addLiquidity(ethAddToLiquify, tokensAddToLiquidity);

        emit SwapAndLiquify(tokensToSwap, ethAddToLiquify, tokensAddToLiquidity);
    }


    function swapTokensForEth(address recipient, uint256 amount) private lockTheSwap {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), amount);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount, 
            0, 
            path, 
            recipient,
            block.timestamp + 60 * 1000
        );
    }
    
    function addLiquidity(uint256 ethAmount, uint256 tokenAmount) private lockTheSwap {

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this), 
            tokenAmount, 
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            burnAccount, // the LP is sent to burnAccount. 
            block.timestamp + 60 * 1000
        );
    }

    function _distributeFee(uint256 rRewardFee, uint256 tRewardFee) private {

        _reflectionTotal = _reflectionTotal - rRewardFee;
        _totalRewarded += tRewardFee;
    }
    
    function _getValues(uint256 amount, bool deductTransferFee, bool selling) private view returns (ValuesFromAmount memory) {

        ValuesFromAmount memory values;
        values.amount = amount;
        _getTValues(values, deductTransferFee, selling);
        _getRValues(values, deductTransferFee);
        return values;
    }

    function _getTValues(ValuesFromAmount memory values, bool deductTransferFee, bool selling) view private {

        
        if (deductTransferFee) {
            values.tTransferAmount = values.amount;
        } else {
            uint32 index = 0;
            if (selling && _listingTime + highTaxCooldown <= block.timestamp) index=1;
            else if (selling && _listingTime + highTaxCooldown > block.timestamp) index=2;

            values.tRewardFee = _calculateTax(values.amount, _taxReward[index], _taxRewardDecimals);
            values.tLiquifyFee = _calculateTax(values.amount, _taxLiquify[index], _taxLiquifyDecimals);
            values.tMarketingFee = _calculateTax(values.amount, _taxMarketing[index], _taxMarketingDecimals);

            values.tTransferAmount = values.amount - values.tRewardFee - values.tLiquifyFee - values.tMarketingFee;
        }
        
    }

    function _getRValues(ValuesFromAmount memory values, bool deductTransferFee) view private {

        uint256 currentRate = _getRate();

        values.rAmount = values.amount * currentRate;

        if (deductTransferFee) {
            values.rTransferAmount = values.rAmount;
        } else {
            values.rAmount = values.amount * currentRate;

            values.rRewardFee = values.tRewardFee * currentRate;
            values.rLiquifyFee = values.tLiquifyFee * currentRate;
            values.rMarketingFee = values.tMarketingFee * currentRate;

            values.rTransferAmount = values.rAmount - values.rRewardFee - values.rLiquifyFee - values.rMarketingFee;
        }
        
    }

    function _getRAmount(uint256 amount) private view returns (uint256) {

        uint256 currentRate = _getRate();
        return amount * currentRate;
    }

    function _getRate() private view returns(uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {

        uint256 rSupply = _reflectionTotal;
        uint256 tSupply = _totalSupply;      
        for (uint256 i = 0; i < _excludedFromReward.length; i++) {
            if (_reflectionBalances[_excludedFromReward[i]] > rSupply || _tokenBalances[_excludedFromReward[i]] > tSupply) return (_reflectionTotal, _totalSupply);
            rSupply = rSupply - _reflectionBalances[_excludedFromReward[i]];
            tSupply = tSupply - _tokenBalances[_excludedFromReward[i]];
        }
        if (rSupply < _reflectionTotal / _totalSupply) return (_reflectionTotal, _totalSupply);
        return (rSupply, tSupply);
    }

    function _calculateTax(uint256 amount, uint32 tax, uint32 taxDecimals_) private pure returns (uint256) {

        return amount * tax / (10 ** taxDecimals_) / (10 ** 2);
    }


    function enableReward(uint32[] memory taxReward_, uint32 taxRewardDecimals_) public onlyOwner {

        require(!_rewardEnabled, "Reward feature is already enabled.");
        require(taxReward_[0] > 0 || taxReward_[1] > 0 || taxReward_[2] > 0, "Tax must be greater than 0.");
        require(taxRewardDecimals_ + 2  <= decimals(), "Tax decimals must be less than token decimals - 2");

        _rewardEnabled = true;
        setTaxReward(taxReward_, taxRewardDecimals_);

        emit EnabledReward();
    }

    function enableAutoSwapAndLiquify(uint32[] memory taxLiquify_, uint32 taxLiquifyDecimals_, address routerAddress, uint256 minTokensBeforeSwap_) public onlyOwner {

        require(!_autoSwapAndLiquifyEnabled, "Auto swap and liquify feature is already enabled.");
        require(taxLiquify_[0] > 0 || taxLiquify_[1] > 0 || taxLiquify_[2] > 0, "Tax must be greater than 0.");
        require(taxLiquifyDecimals_ + 2  <= decimals(), "Tax decimals must be less than token decimals - 2");

        _minTokensBeforeSwap = minTokensBeforeSwap_;

        initSwap(routerAddress);

        _autoSwapAndLiquifyEnabled = true;
        setTaxLiquify(taxLiquify_, taxLiquifyDecimals_);
        
        emit EnabledAutoSwapAndLiquify();
    }

    function initSwap(address routerAddress) public onlyOwner {

        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(routerAddress);

        _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());

        if (_uniswapV2Pair == address(0)) {
            _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
                .createPair(address(this), uniswapV2Router.WETH());
        }
        
        _uniswapV2Router = uniswapV2Router;

        _setAMMPair(_uniswapV2Pair, true);

        excludeAccountFromLimits(address(uniswapV2Router));
        if (!_isExcludedFromReward[address(uniswapV2Router)])
            excludeAccountFromReward(address(uniswapV2Router));
        excludeAccountFromFee(address(uniswapV2Router));
    }

    function enableMarketingTax(uint32[] memory taxMarketing_, uint32 taxMarketingDecimals_, address marketingAddress_) public onlyOwner {

        require(!_marketingRewardEnabled, "Marketing tax feature is already enabled.");
        require(taxMarketing_[0] > 0 || taxMarketing_[1] > 0 || taxMarketing_[2] > 0, "Tax must be greater than 0.");
        require(taxMarketingDecimals_ + 2  <= decimals(), "Tax decimals must be less than token decimals - 2");

        _marketingRewardEnabled = true;
        setMarketingTax(taxMarketing_, taxMarketingDecimals_);
        setMarketingAddress(marketingAddress_);

        emit EnabledMarketingReward();
    }

    function disableReward() public onlyOwner {

        require(_rewardEnabled, "Reward feature is already disabled.");

        setTaxReward(new uint32[](3), 0);
        _rewardEnabled = false;
        
        emit DisabledReward();
    }

    function disableAutoSwapAndLiquify() public onlyOwner {

        require(_autoSwapAndLiquifyEnabled, "Auto swap and liquify feature is already disabled.");

        setTaxLiquify(new uint32[](3), 0);
        _autoSwapAndLiquifyEnabled = false;
         
        emit DisabledAutoSwapAndLiquify();
    }


    function disableMarketingTax() public onlyOwner {

        require(_marketingRewardEnabled, "Marketing reward feature is already disabled.");

        setMarketingTax(new uint32[](3), 0);
        setMarketingAddress(address(0x0));
        _marketingRewardEnabled = false;
        
        emit DisabledMarketingReward();
    }

    function setMinTokensBeforeSwap(uint256 minTokensBeforeSwap_) public onlyOwner {

        require(minTokensBeforeSwap_ < _currentSupply, "minTokensBeforeSwap must be lower than current supply.");

        uint256 previous = _minTokensBeforeSwap;
        _minTokensBeforeSwap = minTokensBeforeSwap_;

        emit MinTokensBeforeSwapUpdated(previous, _minTokensBeforeSwap);
    }

    function setTaxReward(uint32[] memory taxReward_, uint32 taxRewardDecimals_) public onlyOwner {

        require(_rewardEnabled, "Reward feature must be enabled. Try the EnableReward function.");

        uint32[] memory previousTax = _taxReward;
        uint32 previousDecimals = _taxRewardDecimals;
        _taxReward = taxReward_;
        _taxRewardDecimals = taxRewardDecimals_;

        checkMaxTaxLimit();
        emit TaxRewardUpdate(previousTax, previousDecimals, taxReward_, taxRewardDecimals_);
    }

    function setTaxLiquify(uint32[] memory taxLiquify_, uint32 taxLiquifyDecimals_) public onlyOwner {

        require(_autoSwapAndLiquifyEnabled, "Auto swap and liquify feature must be enabled. Try the EnableAutoSwapAndLiquify function.");

        uint32[] memory previousTax = _taxLiquify;
        uint32 previousDecimals = _taxLiquifyDecimals;
        _taxLiquify = taxLiquify_;
        _taxLiquifyDecimals = taxLiquifyDecimals_;

        checkMaxTaxLimit();
        emit TaxLiquifyUpdate(previousTax, previousDecimals, taxLiquify_, taxLiquifyDecimals_);
    }

    function setMarketingTax(uint32[] memory taxMarketing_, uint32 taxMarketingDecimals_) public onlyOwner {

        require(_marketingRewardEnabled, "Marketing reward feature must be enabled. Try the EnableMarketingTax function.");

        uint32[] memory previousTax = _taxMarketing;
        uint32 previousDecimals = _taxMarketingDecimals;
        _taxMarketing = taxMarketing_;
        _taxMarketingDecimals = taxMarketingDecimals_;

        checkMaxTaxLimit();
        emit TaxMarketingUpdate(previousTax, previousDecimals, taxMarketing_, taxMarketingDecimals_);
    }

    function setMarketingAddress(address marketingAddress_) public onlyOwner {

        address previous = marketingAddress;
        marketingAddress = marketingAddress_;

        if (!_isExcludedFromReward[marketingAddress])
            excludeAccountFromReward(marketingAddress);
        excludeAccountFromLimits(marketingAddress);
        excludeAccountFromFee(marketingAddress);

        emit MarketingAddressUpdated(previous, marketingAddress_);
    }

    function sendFeeToAddress(address _addr, uint256 _tAmount) private {

        swapTokensForEth(_addr, _tAmount);
    }

    function checkMaxTaxLimit() private view {

        uint256 testAmount = 10 ** 18;
        uint256 limit = 25 * 10 ** 16;
        require(_calculateTax(testAmount, _taxReward[0], _taxRewardDecimals)
            + _calculateTax(testAmount, _taxLiquify[0], _taxLiquifyDecimals)
            + _calculateTax(testAmount, _taxMarketing[0], _taxMarketingDecimals) <= limit, "Total tax too high");
        require(_calculateTax(testAmount, _taxReward[1], _taxRewardDecimals)
            + _calculateTax(testAmount, _taxLiquify[1], _taxLiquifyDecimals)
            + _calculateTax(testAmount, _taxMarketing[1], _taxMarketingDecimals) <= limit, "Total tax too high");
        require(_calculateTax(testAmount, _taxReward[2], _taxRewardDecimals)
            + _calculateTax(testAmount, _taxLiquify[2], _taxLiquifyDecimals)
            + _calculateTax(testAmount, _taxMarketing[2], _taxMarketingDecimals) <= limit, "Total tax too high");
    }


    uint256 public maxBuyAmount;
    uint256 public maxSellAmount;
    uint256 public maxWalletAmount;

    uint256 public highTaxCooldown;

    mapping (address => bool) public isExcludedFromLimits;
    mapping (address => bool) public AMMPairs;

    uint256 private _listingTime;

    function setAMMPair(address pair, bool value) public onlyOwner {

        require(pair != _uniswapV2Pair, "The main pair cannot be removed from AMMPairs.");

        _setAMMPair(pair, value);
    }

    function _setAMMPair(address pair, bool value) private {

        AMMPairs[pair] = value;

        if(value) {
            if (!_isExcludedFromReward[pair])
                excludeAccountFromReward(pair);
            excludeAccountFromLimits(pair);
            excludeAccountFromFee(pair);
        }

        emit AMMPairUpdated(pair, value);
    }

    function excludeAccountFromLimits(address account) public onlyOwner {

        isExcludedFromLimits[account] = true;
    }

    function includeAccountInLimits(address account) public onlyOwner {

        isExcludedFromLimits[account] = false;
    }

    function changeMaxBuyAmount(uint256 amount) public onlyOwner {

        maxBuyAmount = amount;
    }

    function changeMaxSellAmount(uint256 amount) public onlyOwner {

        maxSellAmount = amount;
    }

    function changeMaxWalletAmount(uint256 amount) public onlyOwner {

        maxWalletAmount = amount;
    }

    function changeHighTaxCooldown(uint256 newCooldown) public onlyOwner {

        require(highTaxCooldown <= 48 hours, "Cooldown too long.");
        highTaxCooldown = newCooldown;
    }
}

contract Ryuzaki is ExtendedReflections {


    uint256 private _tokenSupply = 777_777_777_777_777_777;

    uint32[] private _taxReward = [2,2,2];
    uint32[] private _taxLiquify = [5,5,5];
    uint32[] private _taxMarketing = [3,5,18];

    uint256 private _highTaxCooldown = 4 hours;

    uint32 private _taxDecimals = 0;
    uint32 private _decimals = 9;

    uint256 private _minTokensBeforeSwap = 7_000_000_000_000 * (10 ** _decimals);

    uint256 private _maxBuyAmount = 2_777_777_777_777_777 * (10 ** _decimals);
    uint256 private _maxSellAmount = 2_000_000_000_000_000 * (10 ** _decimals);
    uint256 private _maxWalletAmount = 7_777_777_777_777_777 * (10 ** _decimals);


    address private _routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    constructor (address _marketingAddress) ExtendedReflections( "RyuzakiToken", "Ryuzaki", _decimals, _tokenSupply) {
        enableReward(_taxReward, _taxDecimals);
        enableMarketingTax(_taxMarketing, _taxDecimals, _marketingAddress);
        enableAutoSwapAndLiquify(_taxLiquify, _taxDecimals, _routerAddress, _minTokensBeforeSwap);

        changeMaxBuyAmount(_maxBuyAmount);
        changeMaxSellAmount(_maxSellAmount);
        changeMaxWalletAmount(_maxWalletAmount);
        changeHighTaxCooldown(_highTaxCooldown);
    }
}