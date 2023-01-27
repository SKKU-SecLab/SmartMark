

pragma solidity ^0.8.13;

interface IBEP20 {

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
library SafeMath {

    function add(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {

        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {

        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {

        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {

        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

contract Context {

    constructor () { }

    function _msgSender() internal view returns (address) {

        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
       
        _owner = msg.sender ;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender() , "Ownable: caller is not the owner");
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




contract BEP20Detailed {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory tname, string memory tsymbol, uint8 tdecimals) {
        _name = tname;
        _symbol = tsymbol;
        _decimals = tdecimals;
        
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
}



library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeBEP20 {

    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IBEP20 token, address spender, uint value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IBEP20 token, bytes memory data) private {

        require(address(token).isContract(), "SafeBEP20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeBEP20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
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



contract SBAYC is Context, Ownable, IBEP20, BEP20Detailed {

  using SafeBEP20 for IBEP20;
  using Address for address;
  using SafeMath for uint256;
  
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    
    mapping (address => uint) internal _balances;
    mapping (address => mapping (address => uint)) internal _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private AMMs;
    mapping (address => bool) private isTimelockExempt;
    mapping (address => bool) private isExcludedFromMaxTx;
    mapping (address => bool) private isExcludedFromMaxWallet;
    mapping (address => bool) private _isBlacklisted;
  
   
    uint256 internal _totalSupply;

    uint256 public marketingFee = 5;
    uint256 public utilityFee = 5;
    uint256 public teamFee = 2;

    address payable public marketingaddress = payable(0x5Aa12CE89d24c52BaC4560a27153b41e24b01526);
    address payable public utilityAddress = payable(0x14334B527FEBC947B1a496BF9C69d7F11786b018);
    address payable public teamAddress = payable(0x13A49AabB766180C42bc4FfFbbeDCb27dBC37B1b);
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public isTradingEnabled;

    bool public buyCooldownEnabled = true;
    uint8 public cooldownTimerInterval = 30;
    mapping (address => uint) private cooldownTimer;

    uint256 public _maxTxAmount = 10000000 * (10**18);
    uint256 public _maxWalletAmount = 20000000 * (10**18);
    uint256 public numTokensSellToAddToLiquidity = 500000 * 10**18;
  
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived
    );

    
    
    modifier lockTheSwap {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
  
    address public _owner;
  
    constructor () BEP20Detailed("SHIBAYC", "SBAYC", 18) {
      _owner = msg.sender ;
    _totalSupply = 1000000000 * (10**18);
    
	_balances[_owner] = _totalSupply;
	 IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingaddress] = true;
        _isExcludedFromFee[utilityAddress] = true;
        _isExcludedFromFee[teamAddress] = true;

        isTimelockExempt[owner()] = true;
        isTimelockExempt[marketingaddress] = true;
        isTimelockExempt[utilityAddress] = true;
        isTimelockExempt[teamAddress] = true;
        isTimelockExempt[address(this)] = true;

        isExcludedFromMaxTx[owner()] = true;

        isExcludedFromMaxWallet[owner()] = true;
        isExcludedFromMaxWallet[uniswapV2Pair] = true;
        

        AMMs[uniswapV2Pair] = true;


     emit Transfer(address(0), _msgSender(), _totalSupply);
  }
  
    function totalSupply() public view override returns (uint) {

        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {

        return _balances[account];
    }
    function transfer(address recipient, uint amount) public override  returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address towner, address spender) public view override returns (uint) {

        return _allowances[towner][spender];
    }
    function approve(address spender, uint amount) public override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function setMarketingFeePercent(uint256 updatedMarketingFee) external onlyOwner {

        marketingFee = updatedMarketingFee;
        require(marketingFee.add(utilityFee).add(teamFee) <= 15, "Fee is crossing the boundaries");
    }

    
    function setUtilityFeePercent(uint256 updatedUtilityFee) external onlyOwner {

        utilityFee = updatedUtilityFee;
        require(marketingFee.add(utilityFee).add(teamFee) <= 15, "Fee is crossing the boundaries");
    }

    function setTeamFeePercent(uint256 updatedTeamFee) external onlyOwner
    {

        teamFee = updatedTeamFee;
        require(marketingFee.add(utilityFee).add(teamFee) <= 15, "Fee is crossing the boundaries");

    }

    function setMarketingAddress(address payable wallet) external onlyOwner
    {

        marketingaddress = wallet;
    }

    function setUtilityAddress(address payable wallet) external onlyOwner
    {

        utilityAddress = wallet;
    }

    function setTeamAddress(address payable wallet) external onlyOwner
    {

        teamAddress = wallet;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function changeNumTokensSellToAddToLiquidity(uint256 _numTokensSellToAddToLiquidity) external onlyOwner
    {

        numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;
    }
    function excludeFromFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = false;
    }

    function includeInBlacklist(address account) external onlyOwner
    {

        _isBlacklisted[account] = true;
    }

    function excludeFromBlacklist(address account) external onlyOwner
    {

        _isBlacklisted[account] = false;
    }

    function isBlacklisted(address account) external view returns(bool)
    {

        return _isBlacklisted[account];
    }

    function excludeFromAMMs(address account) public onlyOwner
    {

        AMMs[account] = false;
    }

    function includeInAMMs(address account) public onlyOwner
    {

        AMMs[account] = true;
        isExcludedFromMaxWallet[account] = true;
    }

    function enableTrading() external onlyOwner
    {

        isTradingEnabled = true;
    }
    
    function setIsTimelockExempt(address holder, bool exempt) external onlyOwner {

        isTimelockExempt[holder] = exempt;
    }

    function setIsExcludedFromMaxTx(address holder, bool exempt) external onlyOwner
    {

        isExcludedFromMaxTx[holder] = exempt;
    }

    function setIsExcludedFromMaxWallet(address holder, bool exempt) external onlyOwner
    {

        isExcludedFromMaxWallet[holder] = exempt;
    }

    function setMaxTxLimit(uint256 maxTx) external onlyOwner
    {

        require(maxTx >= 100000 * (10**18), "Not Allowed");
        _maxTxAmount = maxTx;
    }

    function setMaxWalletLimit(uint256 maxWallet) external onlyOwner
    {

        require(maxWallet >= 200000 * (10**18), "Not Allowed");
        _maxWalletAmount = maxWallet;
    }
    receive() external payable {}
    function _transfer(address sender, address recipient, uint amount) internal{


        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(!_isBlacklisted[sender], "Sender is blacklisted");
        require(!_isBlacklisted[recipient], "Recipient is blacklisted");

        if(sender != owner())
        {require(isTradingEnabled, " Trading is not enabled yet");}

        if(!isExcludedFromMaxTx[sender])
        {
            require(amount <= _maxTxAmount, "Maximum transaction limit reached!!");
        }
        if(!isExcludedFromMaxWallet[recipient])
        {
            require(balanceOf(recipient) + amount <= _maxWalletAmount, "Maximum wallet limit reached!!");
        }

        if (sender == uniswapV2Pair &&
            buyCooldownEnabled &&
            !isTimelockExempt[recipient]) {
            require(cooldownTimer[recipient] < block.timestamp,"Please wait for 30 seconds between two buys");
            cooldownTimer[recipient] = block.timestamp + cooldownTimerInterval;
        }


         uint256 taxAmount = (amount.mul(marketingFee + utilityFee + teamFee )).div(100);

        uint256 contractTokenBalance = balanceOf(address(this));
        
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            !AMMs[sender] &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;
        
        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
            takeFee = false;
        }
       
        if(!AMMs[recipient] && !AMMs[sender])
        {takeFee = false;}
       
        if(takeFee)
        {
            uint256 TotalSent = amount.sub(taxAmount);
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(TotalSent);
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(sender, recipient, TotalSent);
            emit Transfer(sender, address(this), taxAmount);
        }
        else
        {
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
       
    }

    function totalFee() internal view returns(uint256)
    {

        return marketingFee.add(utilityFee).add(teamFee);
    }

     function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

       
        uint256 initialBalance = address(this).balance;

        swapTokensForEth(contractTokenBalance); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        uint256 newBalance = address(this).balance.sub(initialBalance);

        uint256 marketingShare = newBalance.mul(marketingFee).div(totalFee());
        uint256 utilityShare = newBalance.mul(utilityFee).div(totalFee());
        uint256 teamShare = newBalance.sub(marketingShare.add(utilityShare));

        payable(marketingaddress).transfer(marketingShare);
        payable(utilityAddress).transfer(utilityShare);
        payable(teamAddress).transfer(teamShare);
        
        emit SwapAndLiquify(contractTokenBalance, newBalance);
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

    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {

        require(_interval <= 3600, "Limit reached");
        buyCooldownEnabled = _status;
        cooldownTimerInterval = _interval;
    }

    function _approve(address towner, address spender, uint amount) internal {

        require(towner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }

    function withdrawStuckBNB() external onlyOwner{

        require (address(this).balance > 0, "Can't withdraw negative or zero");
        payable(owner()).transfer(address(this).balance);
    }

    function removeStuckToken(address _address) external onlyOwner {

        require(_address != address(this), "Can't withdraw tokens destined for liquidity");
        require(IBEP20(_address).balanceOf(address(this)) > 0, "Can't withdraw 0");

        IBEP20(_address).transfer(owner(), IBEP20(_address).balanceOf(address(this)));
    }
  
}