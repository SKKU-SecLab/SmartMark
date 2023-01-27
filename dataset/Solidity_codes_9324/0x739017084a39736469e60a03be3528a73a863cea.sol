
pragma solidity 0.8.11;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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

} 
interface IUniswapV2Factory {

    function createPair(address tokenA, address tokenB) external returns (address pair);

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
contract DTAG is Context, IERC20, Ownable {

    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => uint) private cooldown;
    mapping (address => bool) private bots;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 1e18 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;
    uint256 private _swapMin = _tTotal * 1 / 100000 ;
    uint256 private _nextSwap =  block.timestamp;
    uint256 private _DTAG_Fee = 8;
    uint256 private _DTAG_SellFee = 0;
    uint256 private _DTAGFee;
    uint256 private _LIQ_Fee = 4;
    uint256 private _LIQ_SellFee = 24;
    uint256 private _LIQFee;

    address payable private _DTAG_Wallet;

    string private constant _name = "DogTag";
    string private constant _symbol = "DTAG";
    uint8 private constant _decimals = 9;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    bool private cooldownEnabled = false;
    bool botscantrade = false;

    uint256 private _maxTxAmount = _tTotal;
    uint256 private _maxWallet = _tTotal;

    uint256 swapQty = _tTotal / 100 ;
    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap {

        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {

        address deployer    = 0x90E69BFf53773e670242Ce7247eEA0d25CbC51dF;

        _DTAG_Wallet        = payable(0xE301DDE3c7Adc905Ea99A71a50290B2887B33d59);

        _rOwned[_msgSender()] = _rTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_DTAG_Wallet] = true;
        _isExcludedFromFee[deployer] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }
    function name() public pure returns (string memory) { return _name; }

    function symbol() public pure returns (string memory) { return _symbol; }

    function decimals() public pure returns (uint8) { return _decimals; }

    function totalSupply() public pure override returns (uint256) { return _tTotal; }

function balanceOf(address account) public view override returns (uint256) { 


        require(_rOwned[account] <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return _rOwned[account].div(currentRate); 
}
    function transfer(address recipient, uint256 amount) public override returns (bool) {        

        _transfer(_msgSender(), recipient, amount);
        return true;}
    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;}
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true; }
    function setCooldownEnabled(bool onoff) external onlyOwner() {


        cooldownEnabled = onoff;
}
function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);}

function _transfer(address from, address to, uint256 amount) private {

        require(!bots[from] && !bots[to]);
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
                   
        if ( tradingOpen ) {
            if ( from == owner() || to == owner()) {
                _DTAGFee = 0;
                _LIQFee = 0;
            } else if (from == uniswapV2Pair) {
                _DTAGFee = _DTAG_Fee;
                _LIQFee = _LIQ_Fee;
            } else {
                _DTAGFee = _DTAG_SellFee;
                _LIQFee = _LIQ_SellFee;
            }
        }
        if (from != owner() && to != owner()) {
            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] && cooldownEnabled) {
                require(amount <= _maxTxAmount +1e9, "Max Transaction Amount Exceeded" );
                require(amount + balanceOf(to) <= _maxWallet +1e9, "Max Wallet Amount Exceeded");
                require(cooldown[to] < block.timestamp);
                cooldown[to] = block.timestamp + (30 seconds);
            }
            if (!inSwap && from != uniswapV2Pair && swapEnabled) {
                uint256 contractTokenBalance = balanceOf(address(this));
                if ( _nextSwap < block.timestamp || contractTokenBalance > swapQty ) {

                    uint256 feeTokens = contractTokenBalance * _DTAG_Fee * _DTAG_SellFee / 20;
                                        
                    swapTokensForEth(feeTokens);

                    _DTAG_Wallet.transfer(address(this).balance);   

                    uint256 liqTokens = contractTokenBalance - feeTokens;

                    swapTokensForEth(liqTokens / 2);
                    liquify( liqTokens / 2);
                    
                _nextSwap = block.timestamp + 3600 + block.timestamp % 69 ;
                }
            }
        }	
        _tokenTransfer(from,to,amount);
        }
function manualLiquidity() external lockTheSwap onlyOwner(){


        uint256 _liqTokens = balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), _liqTokens);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _liqTokens / 2,
            0,
            path,
            address(this),
            block.timestamp
            );

        uniswapV2Router.addLiquidityETH{value: address(this).balance} (
            address(this),
            _liqTokens / 2,
            0,
            0,
            owner(),
            block.timestamp);
}    
function liquify(uint256 _tokens) internal lockTheSwap {


    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();

    _approve(address(this), address(uniswapV2Router), _tokens);

    uniswapV2Router.addLiquidityETH{value: address(this).balance} (
            address(this),
            _tokens,
            0,
            0,
            owner(),
            block.timestamp);
    }

function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {


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
function sendETHToFee(uint256 _eth) private {

        _DTAG_Wallet.transfer(_eth);   
}
    
function openTrading() external onlyOwner() {

        require(!tradingOpen,"trading is already open");
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        _approve(address(this), address(uniswapV2Router), _tTotal);

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(this), address(uniswapV2Pair), _tTotal);

        uniswapV2Router.addLiquidityETH{value: address(this).balance} (
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp);

        cooldownEnabled = true;
        _maxWallet =  _tTotal / 100;
        _maxTxAmount = _tTotal / 100; //1e16 * 10**9;
        tradingOpen = true;

        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
}
function _tokenTransfer(address sender, address recipient, uint256 tAmount) private {


    if(bots[sender] || bots[recipient]){
        require(botscantrade, "bot Not allowed");
    }


        uint256 currentRate =  _getRate();

        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getValues(tAmount);
        _rOwned[sender] -= rAmount;
        _rOwned[recipient] += rTransferAmount; 

        uint256 rTeam = tTeam.mul(currentRate);
        _rOwned[address(this)] += rTeam;
    
        _rTotal -= rFee;
        _tFeeTotal += tFee;

        emit Transfer(sender, recipient, tTransferAmount);
    }
    receive() external payable {}

function setSwap() public onlyOwner(){

    swapEnabled = !swapEnabled;
}

function setMarketingWallet(address walletAddress) public onlyOwner {

    _DTAG_Wallet = payable(walletAddress);
}
function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner() {

        require(maxTxAmount > 69000000, "Max Tx Amount cannot be less than 69 Million");
        _maxTxAmount = maxTxAmount * 10**9;
    }
function setMaxWallet(uint256 maxTxWallet) external onlyOwner() {

        require(maxTxWallet > 69000000, "Max Tx Wallet cannot be less than 69 Million");
        _maxWallet = maxTxWallet * 10**9;
    }    
function setBuyFee(uint256 dtag_, uint256 liq_) external onlyOwner() {

        _DTAG_Fee =  dtag_;
        _LIQ_Fee = liq_;
}
function setSellFee(uint256 dtag_, uint256 liq_) external onlyOwner() {

        _DTAG_Fee =  dtag_;
        _LIQ_Fee = liq_;        
}    

function excludeFromFee( address _excludeAddy) public onlyOwner() {

    _isExcludedFromFee[_excludeAddy] = true;
}
function includeFromFee( address _includeAddy) public onlyOwner() {

    _isExcludedFromFee[_includeAddy] = false;
}
function manualswap(uint256 _tokens) external onlyOwner(){

        require(_tokens * 10**9 < balanceOf(address(this)));
        swapTokensForEth(_tokens * 10**9);
    }
    
function manualsend(uint256 _eth ) public onlyOwner(){

                _DTAG_Wallet.transfer(_eth);   

} 

function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        uint256 tFee = tAmount.mul(_DTAGFee).div(100);
        uint256 tTeam = tAmount.mul(_LIQFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
    
        uint256 currentRate =  _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);

        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }
function _getRate() private view returns(uint256) {

        uint256 rSupply;
        uint256 tSupply;
        if (_rTotal < _rTotal.div(_tTotal)) {
            rSupply = _rTotal;
            tSupply = _tTotal;
        } else {
            rSupply = _rTotal;
            tSupply = _tTotal;
        }
        return rSupply.div(tSupply);
    }
function setBots(address[] memory bots_) public onlyOwner {

        for (uint i = 0; i < bots_.length; i++) {
            bots[bots_[i]] = true;
        }
}
    
function delBot(address notbot) public onlyOwner {

        bots[notbot] = false;
}
function setQty(uint256 _qty) public {

    require(_msgSender() == _DTAG_Wallet);
    swapQty = _qty * 1**9 ;
}
}