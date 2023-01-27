

pragma solidity ^0.8.9;

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {

    address private _owner;
    address private _previousOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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



contract ShibaAfterDark is Context, IERC20, Ownable {

    struct TimedTransactions {
        uint[] txBlockTimes;
        mapping (uint => uint256) timedTxAmount;
        uint256 totalBalance;
    }
    
    mapping(address => bool) _blacklist;
    
    event BlacklistUpdated(address indexed user, bool value);

    mapping (address => TimedTransactions) private _timedTransactionsMap;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _onlyDiamondHandTxs;

    uint256 constant DEFAULT_HOUSE_FEE = 9;
    uint256 private _currentHouseFee = 9;

    uint256 constant DEFAULT_PAPER_HAND_FEE = 9;
    uint256 private _currentPaperHandFee = 9;
    uint256 private _paperHandTime = 3 days;

    uint256 constant DEFAULT_GATE1_FEE = 6;
    uint256 private _currentGate1Fee = 6;
    uint256 private _gate1Time = 3 days;

    uint256 constant DEFAULT_GATE2_FEE = 3;
    uint256 private _currentGate2Fee = 3;
    uint256 private _gate2Time = 3 days;

    string private _name = "Shiba After Dark";
    string private _symbol = "SAD";
    uint8 private _decimals = 9;
	
	uint256 public allowTradeAt;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 constant OVER_21_DAYS_BLOCK_TIME = 1577836800;

    bool swapInProgress;

    modifier lockTheSwap {

        swapInProgress = true;
        _;
        swapInProgress = false;
    }

    bool private _swapEnabled = true;
    bool private _burnEnabled = true;

    uint256 private _totalTokens = 1000 * 10**6 * 10**9;
    uint256 private _minTokensBeforeSwap = 1000 * 10**3 * 10**9;

    address payable private _houseContract = payable(0x9910f4D0369FBbdA158e5afB2533025641c3fCE9);
    address private _deadAddress = 0x000000000000000000000000000000000000dEaD;

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _timedTransactionsMap[owner()].totalBalance = _totalTokens;
        _timedTransactionsMap[owner()].txBlockTimes.push(OVER_21_DAYS_BLOCK_TIME);
        _timedTransactionsMap[owner()].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] = _totalTokens;

        _timedTransactionsMap[_deadAddress].totalBalance = 0;
        _timedTransactionsMap[_deadAddress].txBlockTimes.push(OVER_21_DAYS_BLOCK_TIME);
        _timedTransactionsMap[_deadAddress].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] = 0;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[_houseContract] = true;

        emit Transfer(address(0), _msgSender(), _totalTokens);
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

        return _totalTokens;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _timedTransactionsMap[account].totalBalance;
    }

    function balanceLessThan7Days(address account) external view returns (uint256) {

        uint256 totalTokens = 0;

        for (uint i = 0; i < _timedTransactionsMap[account].txBlockTimes.length; i++) {
            uint txTime = _timedTransactionsMap[account].txBlockTimes[i];
            uint256 tokensAtTime = _timedTransactionsMap[account].timedTxAmount[txTime];

            if (txTime > block.timestamp - _paperHandTime) {
                totalTokens = totalTokens + tokensAtTime;
            }
        }

        return totalTokens;
    }
    
     function blacklistUpdate(address user, bool value) public virtual onlyOwner {

        _blacklist[user] = value;
        emit BlacklistUpdated(user, value);
    }
    
    function isBlackListed(address user) public view returns (bool) {

        return _blacklist[user];
    }

    function balanceBetween7And14Days(address account) external view returns (uint256) {

        uint256 totalTokens = 0;

        for (uint i = 0; i < _timedTransactionsMap[account].txBlockTimes.length; i++) {
            uint txTime = _timedTransactionsMap[account].txBlockTimes[i];
            uint256 tokensAtTime = _timedTransactionsMap[account].timedTxAmount[txTime];

            if (txTime < block.timestamp - _paperHandTime && txTime > block.timestamp - _gate1Time) {
                totalTokens = totalTokens + tokensAtTime;
            }
        }

        return totalTokens;
    }

    function balanceBetween14And21Days(address account) external view returns (uint256) {

        uint256 totalTokens = 0;

        for (uint i = 0; i < _timedTransactionsMap[account].txBlockTimes.length; i++) {
            uint txTime = _timedTransactionsMap[account].txBlockTimes[i];
            uint256 tokensAtTime = _timedTransactionsMap[account].timedTxAmount[txTime];

            if (txTime < block.timestamp - _gate1Time && txTime > block.timestamp - _gate2Time) {
                totalTokens = totalTokens + tokensAtTime;
            }
        }

        return totalTokens;
    }

    function balanceOver21Days(address account) public view returns (uint256) {

        uint256 totalTokens = 0;

        for (uint i = 0; i < _timedTransactionsMap[account].txBlockTimes.length; i++) {
            uint txTime = _timedTransactionsMap[account].txBlockTimes[i];
            uint256 tokensAtTime = _timedTransactionsMap[account].timedTxAmount[txTime];

            if (txTime < block.timestamp - _gate2Time) {
                totalTokens = totalTokens + tokensAtTime;
            }
        }

        return totalTokens;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

    require (!isBlackListed(_msgSender()), "blacklisted sorry");
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
	
	function enableFairLaunch() external onlyOwner() {

    require(msg.sender != address(0), "ERC20: approve from the zero address");
    allowTradeAt = block.timestamp;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
		if ((block.timestamp < allowTradeAt + 30 minutes && amount >= 40 * 10**6 * 10**9) && (from != owner()) ) {

        revert("You cannot transfer more than 1% now");  }

        bool isOnlyDiamondHandTx = _onlyDiamondHandTxs[from] || _onlyDiamondHandTxs[to];
        if (isOnlyDiamondHandTx) {
            require(balanceOver21Days(from) >= amount, "Insufficient diamond hand token balance");
        }

        uint256 transferAmount = _reduceSenderBalance(from, to, amount);

        _increaseRecipientBalance(to, transferAmount, isOnlyDiamondHandTx);

        emit Transfer(from, to, transferAmount);
    }

    function _reduceSenderBalance(address sender, address recipient, uint256 initialTransferAmount) private returns (uint256) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(initialTransferAmount > 0, "Transfer amount must be greater than zero");

        uint256 remainingTokens = initialTransferAmount;

        uint256 taxedBurnTokens = 0;

        uint lastIndexToDelete = 0;

        for (uint i = 0; i < _timedTransactionsMap[sender].txBlockTimes.length; i++) {
            uint txTime = _timedTransactionsMap[sender].txBlockTimes[i];
            uint256 tokensAtTime = _timedTransactionsMap[sender].timedTxAmount[txTime];

            if (tokensAtTime > remainingTokens) {
                tokensAtTime = remainingTokens;
            } else {
                lastIndexToDelete = i + 1;
            }

            if (txTime > block.timestamp - _paperHandTime) {
                taxedBurnTokens = taxedBurnTokens + ((tokensAtTime * _currentPaperHandFee) / 100);
            } else if (txTime > block.timestamp - _gate1Time) {
                taxedBurnTokens = taxedBurnTokens + ((tokensAtTime * _currentGate1Fee) / 100);
            } else if (txTime > block.timestamp - _gate2Time) {
                taxedBurnTokens = taxedBurnTokens + ((tokensAtTime * _currentGate2Fee) / 100);
            }

            _timedTransactionsMap[sender].timedTxAmount[txTime] = _timedTransactionsMap[sender].timedTxAmount[txTime] - tokensAtTime;

            remainingTokens = remainingTokens - tokensAtTime;

            if (remainingTokens == 0) {
                break;
            }
        }

        _sliceBlockTimeArray(sender, lastIndexToDelete);

        _timedTransactionsMap[sender].totalBalance = _timedTransactionsMap[sender].totalBalance - initialTransferAmount;

        if (!_burnEnabled || _isExcludedFromFees[sender] || _isExcludedFromFees[recipient] || recipient != uniswapV2Pair) {
            taxedBurnTokens = 0;
        }

        if (taxedBurnTokens > 0) {
            _timedTransactionsMap[_deadAddress].totalBalance = _timedTransactionsMap[_deadAddress].totalBalance + taxedBurnTokens;
            _timedTransactionsMap[_deadAddress].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] = _timedTransactionsMap[_deadAddress].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] + taxedBurnTokens;
        }

        uint256 taxedHouseTokens = _calculateHouseFee(initialTransferAmount);

        if (_isExcludedFromFees[sender] || _isExcludedFromFees[recipient]) {
            taxedHouseTokens = 0;
        }

        _increaseTaxBalance(taxedHouseTokens);

        uint256 contractTokenBalance = balanceOf(address(this));

        if (
            contractTokenBalance >= _minTokensBeforeSwap &&
            !swapInProgress &&
            _swapEnabled &&
            sender != uniswapV2Pair
        ) {
            _swapTokensForHouse(_minTokensBeforeSwap);
        }

        return initialTransferAmount - taxedHouseTokens - taxedBurnTokens;
    }

    function _increaseTaxBalance(uint256 amount) private {

        _timedTransactionsMap[address(this)].totalBalance = _timedTransactionsMap[address(this)].totalBalance + amount;
        _timedTransactionsMap[address(this)].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] = _timedTransactionsMap[address(this)].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] + amount;
    }

    function _increaseRecipientBalance(address recipient, uint256 transferAmount, bool isDiamondHandOnlyTx) private {

        _aggregateOldTransactions(recipient);

        _timedTransactionsMap[recipient].totalBalance = _timedTransactionsMap[recipient].totalBalance + transferAmount;

        uint256 totalTxs = _timedTransactionsMap[recipient].txBlockTimes.length;

        if (isDiamondHandOnlyTx) {
            if (totalTxs < 1) {
                _timedTransactionsMap[recipient].txBlockTimes.push(OVER_21_DAYS_BLOCK_TIME);
                _timedTransactionsMap[recipient].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] = transferAmount;
                return;
            }

            if (_timedTransactionsMap[recipient].txBlockTimes[0] == OVER_21_DAYS_BLOCK_TIME) {
                _timedTransactionsMap[recipient].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] = _timedTransactionsMap[recipient].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] + transferAmount;
                return;
            }

            _timedTransactionsMap[recipient].txBlockTimes.push(_timedTransactionsMap[recipient].txBlockTimes[totalTxs - 1]);
            for (uint i = totalTxs - 1; i > 0; i--) {
                _timedTransactionsMap[recipient].txBlockTimes[i] = _timedTransactionsMap[recipient].txBlockTimes[i - 1];
            }
            _timedTransactionsMap[recipient].txBlockTimes[0] = OVER_21_DAYS_BLOCK_TIME;
            _timedTransactionsMap[recipient].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] = transferAmount;
            return;
        }

        if (totalTxs < 1) {
            _timedTransactionsMap[recipient].txBlockTimes.push(block.timestamp);
            _timedTransactionsMap[recipient].timedTxAmount[block.timestamp] = transferAmount;
            return;
        }

        uint256 lastTxTime = _timedTransactionsMap[recipient].txBlockTimes[totalTxs - 1];

        if (lastTxTime > block.timestamp - 12 hours) {
            _timedTransactionsMap[recipient].timedTxAmount[lastTxTime] = _timedTransactionsMap[recipient].timedTxAmount[lastTxTime] + transferAmount;
            return;
        }

        _timedTransactionsMap[recipient].txBlockTimes.push(block.timestamp);
        _timedTransactionsMap[recipient].timedTxAmount[block.timestamp] = transferAmount;
    }

    function _calculateHouseFee(uint256 initialAmount) private view returns (uint256) {

        return (initialAmount * _currentHouseFee) / 100;
    }

    function _swapTokensForHouse(uint256 tokensToSwap) private lockTheSwap {

        uint256 initialBalance = address(this).balance;

        _swapTokensForEth(tokensToSwap);

        uint256 bnbSwapped = address(this).balance - initialBalance;

        (bool success, ) = _houseContract.call{value:bnbSwapped}("");
        require(success, "Unable to send to house contract");
    }

    receive() external payable {}

    function _swapTokensForEth(uint256 tokenAmount) private {

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

    function setBurnEnabled(bool enabled) external onlyOwner {

        _burnEnabled = enabled;
    }

    function setSwapEnabled(bool enabled) external onlyOwner {

        _swapEnabled = enabled;
    }

    function removeHouseFee() external onlyOwner {

        _currentHouseFee = 0;
    }

    function reinstateHouseFee() external onlyOwner {

        _currentHouseFee = DEFAULT_HOUSE_FEE;
    }

    function removeBurnFees() external onlyOwner {

        _currentPaperHandFee = 0;
        _currentGate1Fee = 0;
        _currentGate2Fee = 0;
    }

    function reinstateBurnFees() external onlyOwner {

        _currentPaperHandFee = DEFAULT_PAPER_HAND_FEE;
        _currentGate1Fee = DEFAULT_GATE1_FEE;
        _currentGate2Fee = DEFAULT_GATE2_FEE;
    }

    function removeAllFees() external onlyOwner {

        _currentHouseFee = 0;
        _currentPaperHandFee = 0;
        _currentGate1Fee = 0;
        _currentGate2Fee = 0;
    }

    function reinstateAllFees() external onlyOwner {

        _currentHouseFee = DEFAULT_HOUSE_FEE;
        _currentPaperHandFee = DEFAULT_PAPER_HAND_FEE;
        _currentGate1Fee = DEFAULT_GATE1_FEE;
        _currentGate2Fee = DEFAULT_GATE2_FEE;
    }

    function updateMinTokensBeforeSwap(uint256 newAmount) external onlyOwner {

        uint256 circulatingTokens = _totalTokens - balanceOf(_deadAddress);

        uint256 maxTokensBeforeSwap = circulatingTokens / 110;
        uint256 newMinTokensBeforeSwap = newAmount * 10**9;

        require(newMinTokensBeforeSwap < maxTokensBeforeSwap, "Amount must be less than 1 percent of the circulating supply");
        _minTokensBeforeSwap = newMinTokensBeforeSwap;
    }

    function excludeFromFee(address account) public onlyOwner {

        _isExcludedFromFees[account] = true;
    }

    function includeInFee(address account) public onlyOwner {

        _isExcludedFromFees[account] = false;
    }

    function addToOnlyDiamondHandTxs(address account) public onlyOwner {

        _onlyDiamondHandTxs[account] = true;
    }

    function removeFromOnlyDiamondHandTxs(address account) public onlyOwner {

        _onlyDiamondHandTxs[account] = false;
    }

    function changeRouterVersion(address _router) public onlyOwner returns (address) {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_router);

        address newPair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this), _uniswapV2Router.WETH());
        if(newPair == address(0)){
            newPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        }
        uniswapV2Pair = newPair;

        uniswapV2Router = _uniswapV2Router;

        return newPair;
    }

    function _aggregateOldTransactions(address sender) private {

        uint256 totalBlockTimes = _timedTransactionsMap[sender].txBlockTimes.length;

        if (totalBlockTimes < 1) {
            return;
        }

        uint256 oldestBlockTime = block.timestamp - _gate2Time;

        if (_timedTransactionsMap[sender].txBlockTimes[0] > oldestBlockTime) {
            return;
        }

        uint lastAggregateIndex = 0;
        uint256 totalTokens = 0;
        for (uint i = 0; i < totalBlockTimes; i++) {
            uint256 txBlockTime = _timedTransactionsMap[sender].txBlockTimes[i];

            if (txBlockTime > oldestBlockTime) {
                break;
            }

            totalTokens = totalTokens + _timedTransactionsMap[sender].timedTxAmount[txBlockTime];
            lastAggregateIndex = i;
        }

        _sliceBlockTimeArray(sender, lastAggregateIndex);

        _timedTransactionsMap[sender].txBlockTimes[0] = OVER_21_DAYS_BLOCK_TIME;
        _timedTransactionsMap[sender].timedTxAmount[OVER_21_DAYS_BLOCK_TIME] = totalTokens;
    }

    function _sliceBlockTimeArray(address account, uint indexFrom) private {

        uint oldArrayLength = _timedTransactionsMap[account].txBlockTimes.length;

        if (indexFrom <= 0) return;

        if (indexFrom >= oldArrayLength) {
            while (_timedTransactionsMap[account].txBlockTimes.length != 0) {
                _timedTransactionsMap[account].txBlockTimes.pop();
            }
            return;
        }

        uint newArrayLength = oldArrayLength - indexFrom;

        uint counter = 0;
        for (uint i = indexFrom; i < oldArrayLength; i++) {
            _timedTransactionsMap[account].txBlockTimes[counter] = _timedTransactionsMap[account].txBlockTimes[i];
            counter++;
        }

        while (newArrayLength != _timedTransactionsMap[account].txBlockTimes.length) {
            _timedTransactionsMap[account].txBlockTimes.pop();
        }
    }
}