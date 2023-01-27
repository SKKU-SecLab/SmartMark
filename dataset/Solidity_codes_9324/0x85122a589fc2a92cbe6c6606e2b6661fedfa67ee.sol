

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
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


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}


contract Ownable {
    address public _owner;
    event onOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit onOwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

contract SHIBNAKI is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    uint256 public feeDevelopment = 40;
    uint256 public feeSustainability = 40;
    uint256 public feeLiquidity = 20;

    mapping (address => bool) public isExcludedFromFees;
    mapping (address => bool) public isExcludedFromMax;
    mapping (address => bool) public isInBlacklist;
    mapping (address => bool) public isInWhitelist;
    mapping (address => bool) public isrouterother;

    uint256 private _totalSupply = 1000000000000 * (10**18);
    uint256 private maxBuyLimit = 1000000000 * (10**18);
    string private _name = "SHIBNAKI";
    string private _symbol = "SHAKI";
    uint256 public maxWallet = _totalSupply.div(10000).mul(75);

    uint256 public _tokenThresholdToSwap = _totalSupply / 10000;
    bool inSwapAndLiquify;
    bool swapping;
    bool public swapAndSendFeesEnabled = true;
    bool public CEX = false;
    bool public addliq = true;
    bool public trading = false;
    bool public limitsEnabled = true;

    address public walletSustainability;
    address public walletDevelopment;
    address public walletLiquidity;
    address public DAOcontrol;

    mapping(address => uint256) private _holderLastTransferTimestamp; // to hold last Transfers temporarily during launch
    bool public transferDelayEnabled = true;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor (address _walletSustainability, address _walletDevelopment, address _DAOcontrol, address _walletLiquidity) ERC20(_name, _symbol) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        walletSustainability = _walletSustainability;
        walletDevelopment = _walletDevelopment;
        walletLiquidity = _walletLiquidity;
        DAOcontrol = _DAOcontrol;

        excludeFromFee(owner());
        excludeFromFee(address(this));
        excludeFromMax(owner());
        excludeFromMax(address(this));

        _mint(owner(), _totalSupply);
    }

    receive() external payable {}

    function updateWalletSustainability(address _walletSustainability) external {
        require(_msgSender() == DAOcontrol);
        walletSustainability = _walletSustainability;
    }

    function updateWalletDevelopment(address _walletDevelopment) external {
        require(_msgSender() == DAOcontrol);
        walletDevelopment = _walletDevelopment;
    }

    function updateWalletLiquidity(address _walletLiquidity) external {
        require(_msgSender() == DAOcontrol);
        walletLiquidity = _walletLiquidity;
    }
    function updateDAOcontrol(address _DAOcontrol) external {
        require(_msgSender() == DAOcontrol);
        DAOcontrol = _DAOcontrol;
    }

    function excludeFromFee(address account) public {
        require(_msgSender() == DAOcontrol);
        isExcludedFromFees[account] = true;
    }

    function excludeFromMax(address account) public {
        require(_msgSender() == DAOcontrol);
        isExcludedFromMax[account] = true;
    }

    function includeInMax(address account) public {
        require(_msgSender() == DAOcontrol);
        isExcludedFromMax[account] = false;
    }
    
    function includeInFee(address account) public {
        require(_msgSender() == DAOcontrol);
        isExcludedFromFees[account] = false;
    }

    function setSwapAndSendFeesEnabled(bool _enabled) public {
        require(_msgSender() == DAOcontrol);
        swapAndSendFeesEnabled = _enabled;
    }

    function setLimitsEnabled(bool _enabled) public{
        require(_msgSender() == DAOcontrol);
        limitsEnabled = _enabled;
    }

    function setTradingEnabled(bool _enabled) public {
        require(_msgSender() == DAOcontrol);
        trading = _enabled;
    }

    function setTransferDelay(bool _enabled) public {
        require(_msgSender() == DAOcontrol);
        transferDelayEnabled = _enabled;
    }
    function setThresoldToSwap(uint256 amount) public {
        require(_msgSender() == DAOcontrol);
        _tokenThresholdToSwap = amount;
    }
    function setMaxBuyLimit(uint256 percentage) public {
        require(_msgSender() == DAOcontrol);
        maxBuyLimit = _totalSupply.div(10**4).mul(percentage);
    }
    function setMaxWallet(uint256 percentage) public {
        require(_msgSender() == DAOcontrol);
        require(percentage >= 75);
        maxWallet = _totalSupply.div(10000).mul(percentage);
    }
    function setFeesPercent(uint256 devFee, uint256 sustainabilityFee, uint256 liquidityFee) public {
        require(_msgSender() == DAOcontrol);
        feeDevelopment = devFee;
        feeSustainability  = sustainabilityFee;
        feeLiquidity = liquidityFee;
        require(devFee + sustainabilityFee + liquidityFee <= 990, "Check fee limit");
    }

    function setBlacklistWallet(address account, bool blacklisted) external {
        require(!CEX);
        require(!isInWhitelist[account]);
        require(_msgSender() == DAOcontrol);
        isInBlacklist[account] = blacklisted;
    }

    function setCEXWhitelistWallet(address account) external {
        require(_msgSender() == DAOcontrol);
        isInWhitelist[account] = true;
        isExcludedFromMax[account] = true;
    }

    function setRouterOther(address account, bool enabled) external {
        require(_msgSender() == DAOcontrol);
        isrouterother[account] = enabled;
    }

    function AddToCEX (bool enabled) external {
        require(_msgSender() == DAOcontrol);
        CEX = enabled;
    }  

    function Addliq (bool enabled) external {
        require(_msgSender() == DAOcontrol);
        addliq = enabled;
    } 

    function manualswap() external lockTheSwap {
        require(_msgSender() == DAOcontrol);
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }

    function manualswapcustom(uint256 percentage) external lockTheSwap {
        require(_msgSender() == DAOcontrol);
        uint256 contractBalance = balanceOf(address(this));
        uint256 swapbalance = contractBalance.div(10**5).mul(percentage);
        swapTokensForEth(swapbalance);
    }

    function manualsend() external {
        require(_msgSender() == DAOcontrol);
        uint256 amount = address(this).balance;

        uint256 ethDevelopment = amount.mul(feeDevelopment).div(feeDevelopment.add(feeSustainability).add(feeLiquidity));
        uint256 ethSustainability = amount.mul(feeSustainability).div(feeDevelopment.add(feeSustainability).add(feeLiquidity));
        uint256 ethLiquidity = amount.sub(ethDevelopment).sub(ethSustainability);

        if(ethDevelopment > 0)
            payable(walletDevelopment).transfer(ethDevelopment);
        if(ethSustainability > 0)
            payable(walletSustainability).transfer(ethSustainability);
        if(ethLiquidity > 0)
            payable(walletLiquidity).transfer(ethLiquidity);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(isInBlacklist[from] == false, "You're in blacklist");
        
        if(limitsEnabled){
        if(!isExcludedFromMax[to] && !isExcludedFromFees[to] && from != owner() && to != owner() && to != uniswapV2Pair && !isrouterother[to]){
        require(amount <= maxBuyLimit,"Over the Max buy");
        require(amount.add(balanceOf(to)) <= maxWallet);
        }
        if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !inSwapAndLiquify
            ){

                if(!trading){
                    require(isExcludedFromFees[from] || isExcludedFromFees[to], "Trading is not active.");
                }

            
                if (transferDelayEnabled){
                    if (to != owner() && to != address(uniswapV2Router) && to != address(uniswapV2Pair)){
                        require(_holderLastTransferTimestamp[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                        _holderLastTransferTimestamp[tx.origin] = block.number;
                    }
                }
            }
        }
        bool overMinTokenBalance = balanceOf(address(this)) >= _tokenThresholdToSwap;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndSendFeesEnabled
        ) {
            swapAndSendFees();
        }
    
        bool takeFee = true;
        if(isExcludedFromFees[from] || isExcludedFromFees[to] || (from != uniswapV2Pair && to != uniswapV2Pair && !isrouterother[from] && !isrouterother[to])) {
            takeFee = false;
        }

        uint256 finalTransferAmount = amount;
        if(takeFee) {
            uint256 totalFeesPercent = feeDevelopment.add(feeSustainability).add(feeLiquidity);
        	uint256 fees = amount.mul(totalFeesPercent).div(1000);
        	finalTransferAmount = amount.sub(fees);
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, finalTransferAmount);
    }

    function swapAndSendFees() private lockTheSwap {

        swapTokensForEth(balanceOf(address(this)));
        uint256 amount = address(this).balance;

        uint256 ethDevelopment = amount.mul(feeDevelopment).div(feeDevelopment.add(feeSustainability).add(feeLiquidity));
        uint256 ethSustainability = amount.mul(feeSustainability).div(feeDevelopment.add(feeSustainability).add(feeLiquidity));
        uint256 ethLiquidity = amount.sub(ethDevelopment).sub(ethSustainability);

        if(ethDevelopment > 0)
            payable(walletDevelopment).transfer(ethDevelopment);
        if(ethSustainability > 0)
            payable(walletSustainability).transfer(ethSustainability);
        if(ethLiquidity > 0)
            payable(walletLiquidity).transfer(ethLiquidity);
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

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
}