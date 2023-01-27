

pragma solidity ^0.8.9;

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

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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

contract Ownable is Context {

    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

    function geUnlockTime() public view returns (uint256) {

        return _lockTime;
    }

    function lock(uint256 time) public virtual onlyOwner {

        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {

        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
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

interface IUniswapV2Pair {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(address indexed sender, uint256 amount0In, uint256 amount1In, uint256 amount0Out, uint256 amount1Out, address indexed to);
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);


    function factory() external view returns (address);


    function token0() external view returns (address);


    function token1() external view returns (address);


    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );


    function price0CumulativeLast() external view returns (uint256);


    function price1CumulativeLast() external view returns (uint256);


    function kLast() external view returns (uint256);


    function mint(address to) external returns (uint256 liquidity);


    function burn(address to) external returns (uint256 amount0, uint256 amount1);


    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;


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

contract BigCoin is Context, IERC20, Ownable {

    using Address for address;

    address bridge;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public automatedMarketMakerPairs;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    struct BuyFee {
        uint256 autoLp;
        uint256 burn;
        uint256 marketing;
        uint256 tax;
        uint256 team;
    }

    struct SellFee {
        uint256 autoLp;
        uint256 burn;
        uint256 marketing;
        uint256 tax;
        uint256 team;
    }

    BuyFee public buyFee;
    SellFee public sellFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 1000000000 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 public gasForProcessing = 500000;

    string private constant _name = "BridgeTestToken";
    string private constant _symbol = "BTT";
    uint8 private constant _decimals = 9;

    uint256 public _taxFee;
    uint256 public _liquidityFee;
    uint256 public _burnFee;
    uint256 public _marketingFee;
    uint256 public _teamFee;

    address payable public marketingWallet;
    address public burnWallet;
    address public liquidityWallet;
    address public teamWallet;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public isTradingEnabled;

    uint256 private numTokensSellToAddToLiquidity = 8000 * 10**9;

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SetAutomatedMarketMakerPair(address pair);
    event RemoveAutomatedMarketMakerPair(address pair);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event SwapAndDistribute(uint256 forMarketing, uint256 forLiquidity, uint256 forBurn, uint256 forTeam);
    event SwapETHForTokens(uint256 amountIn, address[] path);
    event WithdrawalBNB(address account, uint256 amount);
    event Withdrawal(address account, uint256 amount);

    modifier lockTheSwap() {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(address payable _marketingWallet, address payable _teamWallet) {
        _rOwned[_msgSender()] = _rTotal;

        marketingWallet = _marketingWallet;
        burnWallet = address(0xdead);
        liquidityWallet = owner();
        teamWallet = _teamWallet;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;

        _isExcludedFromFee[address(uniswapV2Router)] = true;

        buyFee.autoLp = 1;
        buyFee.burn = 1;
        buyFee.marketing = 2;
        buyFee.tax = 1;
        buyFee.team = 1;

        sellFee.autoLp = 1;
        sellFee.burn = 2;
        sellFee.marketing = 4;
        sellFee.tax = 3;
        sellFee.team = 3;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function setAutomatedMarketMakerPair(address pair) public onlyOwner {

        automatedMarketMakerPairs[pair] = true;

        emit SetAutomatedMarketMakerPair(pair);
    }

    function removeAutomatedMarketMakerPair(address pair) public onlyOwner {

        automatedMarketMakerPairs[pair] = false;

        emit RemoveAutomatedMarketMakerPair(pair);
    }

    function name() external pure returns (string memory) {

        return _name;
    }

    function symbol() external pure returns (string memory) {

        return _symbol;
    }

    function decimals() external pure returns (uint8) {

        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {

        return _tTotal;
    }

    function balanceCheck(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), balanceCheck(_allowances[sender][_msgSender()], amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {

        _approve(_msgSender(), spender, balanceCheck(_allowances[_msgSender()][spender], subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function isExcludedFromReward(address account) external view returns (bool) {

        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {

        return _tFeeTotal;
    }

    function deliver(uint256 tAmount) external {

        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee) external view returns (uint256) {

        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function excludeFromReward(address account) public onlyOwner {

        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {

        require(_isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) private {

        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tMarketing, uint256 tBurn) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, tMarketing, tBurn, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tMarketing = calculateMarketingFee(tAmount);
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tTeam = calculateTeamFee(tAmount);
        uint256 tTransferAmount = tAmount - (tFee + tLiquidity);
        tTransferAmount = tTransferAmount - (tMarketing + tBurn + tTeam);
        return (tTransferAmount, tFee, tLiquidity, tMarketing, tBurn);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 tMarketing,
        uint256 tBurn,
        uint256 currentRate
    )
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rMarketing = tMarketing * currentRate;
        uint256 rBurn = tBurn * currentRate;
        uint256 tTeam = calculateTeamFee(tAmount);
        uint256 rTeam = tTeam * currentRate;
        uint256 rTransferAmount = rAmount - (rFee + rLiquidity + rMarketing + rBurn + rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < (_rTotal / _tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {

        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
    }

    function _takeTeam(uint256 tTeam) private {

        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rTeam;
        if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)] + tTeam;
    }

    function _takeMarketingAndBurn(uint256 tMarketing, uint256 tBurn) private {

        uint256 currentRate = _getRate();
        uint256 rMarketing = tMarketing * currentRate;
        uint256 rBurn = tBurn * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + (rBurn + rMarketing);
        if (_isExcluded[address(this)]) _tOwned[address(this)] = _tOwned[address(this)] + (tMarketing + tBurn);
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {

        return (_amount * _taxFee) / 10**2;
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {

        return (_amount * _liquidityFee) / 10**2;
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {

        return (_amount * _burnFee) / 10**2;
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {

        return (_amount * _marketingFee) / 10**2;
    }

    function calculateTeamFee(uint256 _amount) private view returns (uint256) {

        return (_amount * _teamFee) / 10**2;
    }

    function restoreAllFee() private {

        _taxFee = 0;
        _liquidityFee = 0;
        _marketingFee = 0;
        _burnFee = 0;
        _teamFee = 0;
    }

    function setBuyFee() private {

        _taxFee = buyFee.tax;
        _liquidityFee = buyFee.autoLp;
        _marketingFee = buyFee.marketing;
        _burnFee = buyFee.burn;
        _teamFee = buyFee.team;
    }

    function setSellFee() private {

        _taxFee = sellFee.tax;
        _liquidityFee = sellFee.autoLp;
        _marketingFee = sellFee.marketing;
        _burnFee = sellFee.burn;
        _teamFee = sellFee.team;
    }

    function enableTrading() external onlyOwner {

        isTradingEnabled = true;
    }

    function isExcludedFromFee(address account) external view returns (bool) {

        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance && !inSwapAndLiquify && !automatedMarketMakerPairs[from] && swapAndLiquifyEnabled && from != liquidityWallet && to != liquidityWallet) {
            contractTokenBalance = numTokensSellToAddToLiquidity;

            swapAndDistribute(contractTokenBalance);
        }

        _tokenTransfer(from, to, amount);
    }

    function swapAndDistribute(uint256 contractTokenBalance) private lockTheSwap {

        uint256 total = buyFee.marketing + sellFee.marketing + buyFee.autoLp + sellFee.autoLp + buyFee.burn + sellFee.burn + buyFee.team + sellFee.team;

        uint256 forLiquidity = (contractTokenBalance * (buyFee.autoLp + sellFee.autoLp)) / total;
        swapAndLiquify(forLiquidity);

        uint256 forBurn = (contractTokenBalance * (buyFee.burn + sellFee.burn)) / total;
        sendToBurn(forBurn);

        uint256 forMarketing = (contractTokenBalance * (buyFee.marketing + sellFee.marketing)) / total;
        sendToMarketing(forMarketing);

        uint256 forTeam = (contractTokenBalance * (buyFee.team + sellFee.team)) / total;
        sendToTeam(forTeam);

        emit SwapAndDistribute(forMarketing, forLiquidity, forBurn, forTeam);
    }

    function sendToBurn(uint256 tBurn) private {

        uint256 currentRate = _getRate();
        uint256 rBurn = tBurn * currentRate;
        _rOwned[burnWallet] = _rOwned[burnWallet] + rBurn;
        _rOwned[address(this)] = _rOwned[address(this)] - rBurn;
        if (_isExcluded[burnWallet]) _tOwned[burnWallet] = _tOwned[burnWallet] + tBurn;
    }

    function sendToTeam(uint256 tTeam) private {

        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam * currentRate;
        _rOwned[teamWallet] = _rOwned[teamWallet] + rTeam;
        _rOwned[address(this)] = _rOwned[address(this)] - rTeam;
        if (_isExcluded[teamWallet]) _tOwned[teamWallet] = _tOwned[teamWallet] + tTeam;
    }

    function sendToMarketing(uint256 tMarketing) private {

        uint256 currentRate = _getRate();
        uint256 rMarketing = tMarketing * currentRate;
        _rOwned[marketingWallet] = _rOwned[marketingWallet] + rMarketing;
        _rOwned[address(this)] = _rOwned[address(this)] - rMarketing;
        if (_isExcluded[marketingWallet]) _tOwned[marketingWallet] = _tOwned[marketingWallet] + tMarketing;
    }

    function swapAndLiquify(uint256 tokens) private {

        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        swapTokensForETH(half);

        uint256 newBalance = address(this).balance - initialBalance;

        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForETH(uint256 tokenAmount) private {

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount, 0, path, address(this), block.timestamp);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(address(this), tokenAmount, 0, 0, liquidityWallet, block.timestamp);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {

        if (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {
            require(isTradingEnabled, "Trading is disabled");

            if (automatedMarketMakerPairs[sender] == true) {
                setBuyFee();
            } else if (automatedMarketMakerPairs[recipient] == true) {
                setSellFee();
            }
        }

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeMarketingAndBurn(calculateMarketingFee(tAmount), calculateBurnFee(tAmount));
        _takeTeam(calculateTeamFee(tAmount));
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeMarketingAndBurn(calculateMarketingFee(tAmount), calculateBurnFee(tAmount));
        _takeTeam(calculateTeamFee(tAmount));
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeMarketingAndBurn(calculateMarketingFee(tAmount), calculateBurnFee(tAmount));
        _takeTeam(calculateTeamFee(tAmount));
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _takeMarketingAndBurn(calculateMarketingFee(tAmount), calculateBurnFee(tAmount));
        _takeTeam(calculateTeamFee(tAmount));
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function excludeFromFee(address account) external onlyOwner {

        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) external onlyOwner {

        _isExcludedFromFee[account] = false;
    }

    function setMarketingWallet(address payable newWallet) external onlyOwner {

        marketingWallet = newWallet;
    }

    function setBurnWallet(address payable newWallet) external onlyOwner {

        burnWallet = newWallet;
    }

    function setTeamWallet(address payable newWallet) external onlyOwner {

        teamWallet = newWallet;
    }

    function setBuyFees(
        uint256 _lp,
        uint256 _marketing,
        uint256 _burn,
        uint256 _tax,
        uint256 _team
    ) external onlyOwner {

        buyFee.autoLp = _lp;
        buyFee.marketing = _marketing;
        buyFee.burn = _burn;
        buyFee.tax = _tax;
        buyFee.team = _team;
    }

    function setSellFees(
        uint256 _lp,
        uint256 _marketing,
        uint256 _burn,
        uint256 _tax,
        uint256 _team
    ) external onlyOwner {

        sellFee.autoLp = _lp;
        sellFee.marketing = _marketing;
        sellFee.burn = _burn;
        sellFee.tax = _tax;
        sellFee.team = _team;
    }

    function setRouterAddress(address newRouter) external onlyOwner {

        IUniswapV2Router02 _newUniswapRouter = IUniswapV2Router02(newRouter);
        uniswapV2Pair = IUniswapV2Factory(_newUniswapRouter.factory()).createPair(address(this), _newUniswapRouter.WETH());
        uniswapV2Router = _newUniswapRouter;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setSwapTokens(uint256 amount) external onlyOwner {

        numTokensSellToAddToLiquidity = amount;
    }

    function updateGasForProcessing(uint256 newValue) external onlyOwner {

        require(newValue >= 200000 && newValue <= 500000, "gasForProcessing must be between 200,000 and 500,000");
        require(newValue != gasForProcessing, "Cannot update gasForProcessing to same value");

        gasForProcessing = newValue;
    }

    function updateLiquidityWallet(address payable newLiquidityWallet) external onlyOwner {

        require(newLiquidityWallet != liquidityWallet, "The liquidity wallet is already this address");
        liquidityWallet = newLiquidityWallet;
    }

    function _transferOwnership(address payable newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        liquidityWallet = address(newOwner);
        transferOwnership(newOwner);
    }

    function withdrawBNB(address payable account, uint256 amount) external onlyOwner {

        require(amount <= (address(this)).balance, "incufficient funds");
        account.transfer(amount);
        emit WithdrawalBNB(account, amount);
    }

    function withdraw(address account, uint256 tAmount) external onlyOwner {

        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        require(rAmount <= _rOwned[address(this)], "incufficient funds");
        _rOwned[account] = _rOwned[account] + rAmount;
        _rOwned[address(this)] = _rOwned[address(this)] - rAmount;
        if (_isExcluded[account]) _tOwned[account] = _tOwned[account] + tAmount;
        emit Withdrawal(account, tAmount);
    }

    modifier OnlyBridge() {

        require(msg.sender == bridge, "Only bridge can perform this action");
        _;
    }

    function setBridge(address _bridge) external onlyOwner {

        bridge = _bridge;
    }

    function mint(address account, uint256 tAmount) external OnlyBridge {

        require(account != address(0), "mint to the zero address");
        uint256 currentRate = _getRate();
        _tTotal += tAmount;
        uint256 rAmount = tAmount * currentRate;
        _rOwned[account] = _rOwned[account] + rAmount;
        emit Transfer(address(0), account, tAmount);
    }

    function burn(address account, uint256 tAmount) external OnlyBridge {

        require(account != address(0), "burn to the zero address");
        uint256 currentRate = _getRate();
        _tTotal -= tAmount;
        uint256 rAmount = tAmount * currentRate;
        _rOwned[account] = _rOwned[account] - rAmount;
        _rOwned[burnWallet] = _rOwned[burnWallet] + rAmount;
        emit Transfer(account, burnWallet, tAmount);
    }
}