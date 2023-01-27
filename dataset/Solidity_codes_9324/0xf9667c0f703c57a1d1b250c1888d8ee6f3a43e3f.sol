
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Centaurify is Context, IERC20, IERC20Metadata, Ownable {

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private _isExcludedFromFee;

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    address constant UNISWAPV2ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant _marketingWalletAddress = 0x0000000000000000000000000000000000000000;
    address public constant _operationalWalletAddress = 0x0000000000000000000000000000000000000000;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public _operatingFeeBalance;
    uint256 public _liquidityFeeBalance;

    string private constant _name = "Centaurify";
    string private constant _symbol = "CENT";
    uint8 private constant _decimals = 9;

    uint256 public _taxFee = 0;
    uint256 private _previousTaxFee = _taxFee;

    uint256 public _liquidityFee = 2;
    uint256 private _previousLiquidityFee = _liquidityFee;

    uint256 public _transactionBurn = 2;
    uint256 private _previousTransactionBurn = _transactionBurn;

    uint256 public _marketingFee = 2;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _operatingFee = 1;
    uint256 private _previousOperatingFee = _operatingFee;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 private constant numTokensSellToAddToLiquidity = 1000 * 10**9;

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiquidity
    );
    event FeeInEthUpdated(bool status);
    event ExcludedFromReward(address userAccount);
    event IncludedInReward(address userAccount);
    event ExcludedFromFee(address userAccount);
    event IncludedInFee(address UserAccount);
    event TaxFeePercentUpdated(uint256 newTaxFeePercent);
    event LiquidityFeePercentUpdated(uint256 newLiquidityFeePercent);
    event BurnPercentUpdated(uint256 newBurnPercent);
    event MarketingFeePercentUpdated(uint256 newMarketingFeePercent);
    event VestingAddressUpdated(address vestingContractAddress);
    event ExternalTokenTransfered(address externalAddress,address toAddress, uint amount);
    event LiquidityAddedFromSwap(uint amountToken,uint amountEth,uint liquidity);
    event EthFromContractTransferred(uint amount);

    modifier lockTheSwap {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    uint256 _amount_burnt = 0;
    bool public _feeInETH = true;

    address public vesting_address;

    constructor() {
        _rOwned[_msgSender()] = _rTotal;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(UNISWAPV2ROUTER);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function name() external view virtual override returns (string memory) {

        return _name;
    }

    function symbol() external view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _tTotal - _amount_burnt;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function burn(uint256 amount) external virtual returns (bool) {

        _burn(_msgSender(), amount);
        return true;
    }

    function setFeeInETH(bool feeInETH) external virtual onlyOwner() {

        _feeInETH = feeInETH;
        emit FeeInEthUpdated(_feeInETH);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        bool takeFee = true;
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }
        _swapAndLiquify(sender);

        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _rOwned[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _rOwned[account] = accountBalance - amount;
        }
        _tTotal -= amount;

        emit Transfer(account, address(0), amount);
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


    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount / currentRate;
    }

    function isExcludedFromReward(address account) external view returns (bool) {

        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {

        return _tFeeTotal;
    }

    function excludeFromReward(address account) external onlyOwner() {

        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
        emit ExcludedFromReward(account);
    }

    function includeInReward(address account) external onlyOwner() {

        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                emit IncludedInReward(account);
                break;
            }
        }
    }

    function excludeFromFee(address account) external onlyOwner {

        _isExcludedFromFee[account] = true;
        emit ExcludedFromFee(account);
    }

    function includeInFee(address account) external onlyOwner {

        _isExcludedFromFee[account] = false;
        emit IncludedInFee(account);
    }

    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {

        _taxFee = taxFee;
        emit TaxFeePercentUpdated(_taxFee);
    }

    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {

        _liquidityFee = liquidityFee;
        emit LiquidityFeePercentUpdated(_liquidityFee);
    }

    function setBurnPercent(uint256 transactionBurn) external onlyOwner() {

        _transactionBurn = transactionBurn;
        emit BurnPercentUpdated(_transactionBurn);
    }

    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner() {

        _marketingFee = marketingFee;
        emit MarketingFeePercentUpdated(_marketingFee);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    receive() external payable {}

    function _takeFee(uint256 rFee, uint256 tFee) internal {

        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _takeLiquidity(uint256 tLiquidity) internal {

        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _liquidityFeeBalance += tLiquidity;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
    }

    function _takeMarketingFee(uint256 tMarketingFee) internal {

        uint256 currentRate =  _getRate();
        uint256 rMarketingFee = tMarketingFee * currentRate;
        _rOwned[_marketingWalletAddress] = _rOwned[_marketingWalletAddress] + rMarketingFee;
        if(_isExcluded[_marketingWalletAddress])
            _tOwned[_marketingWalletAddress] = _tOwned[_marketingWalletAddress] + tMarketingFee;
    }

    function _takeOperatingFee(uint256 tOperatingFee) internal {

        uint256 currentRate =  _getRate();

        if(_feeInETH == true) {
            uint256 rOperatingFeeEth = (tOperatingFee * 25 / 10**2) / 10**2 * currentRate;
            uint256 tOperatingFeeEth = (tOperatingFee * 25 / 10**2) / 10**2;
            _rOwned[address(this)] = _rOwned[address(this)] + rOperatingFeeEth;
            _operatingFeeBalance += tOperatingFeeEth;
            if(_isExcluded[address(this)])
                _tOwned[address(this)] = _tOwned[address(this)] + tOperatingFeeEth;

            uint256 rOperatingFeeToken = (tOperatingFee * 75 / 10**2) / 10**2 * currentRate;
            uint256 tOperatingFeeToken = (tOperatingFee * 75 / 10**2) / 10**2;
            _rOwned[_operationalWalletAddress] = _rOwned[_operationalWalletAddress] + rOperatingFeeToken;
            if(_isExcluded[_operationalWalletAddress])
                _tOwned[_operationalWalletAddress] = _tOwned[_operationalWalletAddress] + tOperatingFeeToken;
        } else {
            uint256 rOperatingFee = tOperatingFee * currentRate;
            _rOwned[_operationalWalletAddress] = _rOwned[_operationalWalletAddress] + rOperatingFee;
            if(_isExcluded[_operationalWalletAddress])
                _tOwned[_operationalWalletAddress] = _tOwned[_operationalWalletAddress] + tOperatingFee;
        }
    }

    function _getTValues(uint256 amount) internal view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        uint256 tAmount = amount;
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tBurn = calculateTransactionBurn(tAmount);
        uint256 tMarketingFee = calculateMarketingFee(tAmount);
        uint256 tOperatingFee = calculateOperatingFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tLiquidity - tBurn - tMarketingFee - tOperatingFee;
        return (tTransferAmount, tFee, tLiquidity, tBurn, tMarketingFee, tOperatingFee);
    }

    function _getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tBurn, uint256 tMarketingFee, uint256 tOperatingFee, uint256 currentRate) internal pure returns (uint256, uint256, uint256) {

        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rBurn = tBurn * currentRate;
        uint256 rMarketingFee = tMarketingFee * currentRate;
        uint256 rOperatingFee = tOperatingFee * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rLiquidity - rBurn - rMarketingFee - rOperatingFee;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() internal view returns(uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() internal view returns(uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function calculateTaxFee(uint256 _amount) internal view returns (uint256) {

        return _amount * _taxFee / 10**2;
    }

    function calculateLiquidityFee(uint256 _amount) internal view returns (uint256) {

        return _amount * _liquidityFee / 10**2;
    }

    function calculateTransactionBurn(uint256 _amount) internal view returns (uint256) {

        return _amount * _transactionBurn / 10**2;
    }

    function calculateMarketingFee(uint256 _amount) internal view returns (uint256) {

        return _amount * _marketingFee / 10**2;
    }

    function calculateOperatingFee(uint256 _amount) internal view returns (uint256) {

        return _amount * _operatingFee / 10**2;
    }

    function removeAllFee() internal {

        if(_taxFee == 0 && _liquidityFee == 0 && _transactionBurn == 0 && _marketingFee == 0 && _operatingFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousTransactionBurn = _transactionBurn;
        _previousMarketingFee = _marketingFee;
        _previousOperatingFee = _operatingFee;

        _taxFee = 0;
        _liquidityFee = 0;
        _transactionBurn = 0;
        _marketingFee = 0;
        _operatingFee = 0;
    }

    function restoreAllFee() internal {

        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _transactionBurn = _previousTransactionBurn;
        _marketingFee = _previousMarketingFee;
        _operatingFee = _previousOperatingFee;
    }

    function isExcludedFromFee(address account) external view returns(bool) {

        return _isExcludedFromFee[account];
    }

    function _swapAndLiquify(address from) internal {

        if (
            _liquidityFeeBalance >= numTokensSellToAddToLiquidity &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            uint256 fee = _liquidityFeeBalance;
            _liquidityFeeBalance = 0;
            swapAndLiquify(fee);
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) internal lockTheSwap {

        uint256 LPtokenBalance = contractTokenBalance;
        uint256 half = LPtokenBalance / 2;
        uint256 otherHalf = LPtokenBalance - half;

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half, address(this)); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        uint256 newBalance = address(this).balance - initialBalance;

        addLiquidity(otherHalf, newBalance);

        if(_feeInETH == true) transferToFeeWallet();

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount, address swapAddress) internal {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            swapAddress,
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        (uint amountToken, uint amountETH, uint liquidity) = uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
        emit LiquidityAddedFromSwap(amountToken,amountETH,liquidity);
    }

    function transferToFeeWallet() internal {

        swapTokensForEth(_operatingFeeBalance, _operationalWalletAddress);
        _operatingFeeBalance = 0;
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) internal {

        if(!takeFee)
            removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) internal {

        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tBurn, uint256 tMarketingFee, uint256 tOperatingFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tBurn, tMarketingFee, tOperatingFee, _getRate());
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeFee(rFee, tFee);
        if(tBurn > 0) {
            _amount_burnt += tBurn;
            emit Transfer(sender, address(0), tBurn);
        }
        _takeMarketingFee(tMarketingFee);
        _takeOperatingFee(tOperatingFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) internal {

        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tBurn, uint256 tMarketingFee, uint256 tOperatingFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tBurn, tMarketingFee, tOperatingFee, _getRate());
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeFee(rFee, tFee);
        if(tBurn > 0) {
            _amount_burnt += tBurn;
            emit Transfer(sender, address(0), tBurn);
        }
        _takeMarketingFee(tMarketingFee);
        _takeOperatingFee(tOperatingFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(address sender, address recipient, uint256 tAmount) internal {

        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tBurn, uint256 tMarketingFee, uint256 tOperatingFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tBurn, tMarketingFee, tOperatingFee, _getRate());
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeFee(rFee, tFee);
        if(tBurn > 0) {
            _amount_burnt += tBurn;
            emit Transfer(sender, address(0), tBurn);
        }
        _takeMarketingFee(tMarketingFee);
        _takeOperatingFee(tOperatingFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) internal {

        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tBurn, uint256 tMarketingFee, uint256 tOperatingFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tBurn, tMarketingFee, tOperatingFee, _getRate());
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeFee(rFee, tFee);
        if(tBurn > 0) {
            _amount_burnt += tBurn;
            emit Transfer(sender, address(0), tBurn);
        }
        _takeMarketingFee(tMarketingFee);
        _takeOperatingFee(tOperatingFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function setVestingAddress(address account) external virtual onlyOwner() returns (bool){

        require(account != address(0), "ERC20: Vesting address cant be zero address");
        vesting_address = account;
        return true;
    }

    function getBalance() public view returns (uint256) {

        return address(this).balance;
    }

    function withdrawEthFromContract(uint256 amount) public onlyOwner {

        require(amount <= getBalance());
        address payable _owner = payable(owner());
        _owner.transfer(amount);
        emit EthFromContractTransferred(amount);
    }

    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {

        require(_tokenContract != address(0), "Address cant be zero address");
        IERC20 tokenContract = IERC20(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
        emit ExternalTokenTransfered(_tokenContract,msg.sender, _amount);
    }
}