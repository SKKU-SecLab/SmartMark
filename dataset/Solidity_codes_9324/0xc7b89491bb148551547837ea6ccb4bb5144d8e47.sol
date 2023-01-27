

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


     function mint(address from, uint256 value) external;

     function burn(address from, uint256 value) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



pragma solidity ^0.8.0;

library SafeMath {

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }
}



pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        address addr = msg.sender;
        address payable Sender = payable(addr);
        return Sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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


pragma solidity ^0.8.0;


contract ePING is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping(address => bool) public adminAddresses;
    address[] private _excluded;
    bool public isWalletTransferFeeEnabled = false;
    bool public isContractTransferFeeEnabled = true;

    string private constant _name = "ePING";
    string private constant _symbol = "ePING";
    uint8 private constant _decimals = 9;

    uint256 private constant MAX = 16 * 10**36 * 10**_decimals;
    uint256 private  _tTotal = 1 * 10**0 * 10**_decimals;
    
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tRfiTotal;
    uint256 public numOfHODLers;
    uint256 private _tDevelopmentTotal;
    uint256 private _tResearchTotal;
    
    struct feeRatesStruct {
      uint8 rfi;
      uint8 liquidity;
      uint8 research;
      uint8 dev;
    }

    feeRatesStruct public feeRates = feeRatesStruct(
     {rfi: 2,
      liquidity: 6,
      research: 1,
      dev: 1}); //32 bytes - perfect, as it should be

    struct valuesFromGetValues{
      uint256 rAmount;
      uint256 rTransferAmount;
      uint256 rRfi;
      uint256 tTransferAmount;
      uint256 tRfi;
      uint256 tLiquidity;
      uint256 tResearch;
      uint256 tDev;
    }

    address public researchWallet;
    address public devWallet;
    mapping (address => bool) public isPresaleWallet;//exclude presaleWallet from max transaction limit, so that public can claim tokens.
    
    IUniswapV2Router02 public  PancakeSwapV2Router;
    address public  pancakeswapV2Pair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    uint256 public _maxTxAmount = 4 * 10**9  * 10**_decimals;  
    uint256 public numTokensSellToAddToLiquidity = 4 * 10**6 * 10**_decimals;   //0.1%

    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiquidity);
    event BalanceWithdrawn(address withdrawer, uint256 amount);
    event LiquidityAdded(uint256 tokenAmount, uint256 bnbAmount);
    event MaxTxAmountChanged(uint256 oldValue, uint256 newValue);
    event SwapAndLiquifyStatus(string status);
    event WalletsChanged();
    event FeesChanged();
    event tokensBurned(uint256 amount, string message);
    event Mint(uint256 amount, address mintAddress);
    event Burn(uint256 amount, address burnAddress);


    modifier lockTheSwap {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        IUniswapV2Router02 _PancakeSwapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        pancakeswapV2Pair = IUniswapV2Factory(_PancakeSwapV2Router.factory()).createPair(address(this), _PancakeSwapV2Router.WETH()); //only utility is to have the pair at hand, on bscscan...
        PancakeSwapV2Router = _PancakeSwapV2Router;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }
    function toggleWalletTransferTax() external onlyOwner {

        isWalletTransferFeeEnabled = !isWalletTransferFeeEnabled;
    }

    function toggleContractTransferTax() external onlyOwner {

        isContractTransferFeeEnabled = !isContractTransferFeeEnabled;
    }

    function name() public pure returns (string memory) {

        return _name;
    }
    function symbol() public pure returns (string memory) {

        return _symbol;
    }
    function decimals() public pure returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        _transfer(_msgSender(), recipient,amount, isWalletTransferFeeEnabled);
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

       if (sender.isContract()) {
            _transfer(sender, recipient, amount, isContractTransferFeeEnabled);
        } else {
            _transfer(sender, recipient, amount, isWalletTransferFeeEnabled);
        }
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

    function isExcludedFromReward(address account) public view returns (bool) {

        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {

        return _tRfiTotal;
    }

  

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi) public view returns(uint256) {

        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rTransferAmount;
        }
    }


    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromRFI(address account) public onlyOwner() {

        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInRFI(address account) external onlyOwner() {

        require(_isExcluded[account], "Account is not excluded");
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

    function excludeFromFeeAndRfi(address account) public onlyOwner {

        excludeFromFee(account);
        excludeFromRFI(account);
    }

    function excludeFromFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns(bool) {

        return _isExcludedFromFee[account];
    }

    function setRfiRatesPercents(uint8 _rfi, uint8 _lp, uint8 _research, uint8 _dev) public onlyOwner {

      feeRates.rfi = _rfi;
      feeRates.liquidity = _lp;
      feeRates.research = _research;
      feeRates.dev = _dev;
      emit FeesChanged();
    }

    function setWallets(address _research, address _dev) public onlyOwner {

      researchWallet = _research;
      devWallet = _dev;
      _isExcludedFromFee[_research] = true;
      _isExcludedFromFee[_dev] = true;
      emit WalletsChanged();
    }

    function setPresaleWallet(address _presaleWallet) public onlyOwner {

      _isExcludedFromFee[_presaleWallet] = true;
      isPresaleWallet[_presaleWallet]=true;
    }

   function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner {

        uint256 _previoiusAmount = _maxTxAmount;
        _maxTxAmount = _tTotal.mul(maxTxPercent).div(100);
        emit MaxTxAmountChanged(_previoiusAmount, _maxTxAmount);
    }
    
    function setMaxTxAmount(uint256 maxTxAmount) external onlyOwner {

        _maxTxAmount = maxTxAmount;
    }

    function setThreshholdForLP(uint256 threshold) external onlyOwner {

      numTokensSellToAddToLiquidity = threshold * 10**_decimals;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    receive() external payable {}

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {

        _rTotal = _rTotal.sub(rRfi);
        _tRfiTotal = _tRfiTotal.add(tRfi);
    }

    function _getValues(uint256 tAmount, bool takeFee) private view returns (valuesFromGetValues memory to_return) {

        to_return = _getTValues(tAmount, takeFee);
        (to_return.rAmount, to_return.rTransferAmount, to_return.rRfi) = _getRValues(to_return, tAmount, takeFee, _getRate());

        return to_return;

    }

    function _getTValues(uint256 tAmount, bool takeFee) private view returns (valuesFromGetValues memory s) {


        if(!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }

        s.tRfi = tAmount.mul(feeRates.rfi).div(100);
        s.tLiquidity = tAmount.mul(feeRates.liquidity).div(100);
        s.tResearch = tAmount.mul(feeRates.research).div(100);
        s.tDev = tAmount.mul(feeRates.dev).div(100);

        s.tTransferAmount = tAmount.sub(s.tRfi).sub(s.tLiquidity).sub(s.tResearch).sub(s.tDev);

        return s;
    }

    function _getRValues(valuesFromGetValues memory s, uint256 tAmount, bool takeFee, uint256 currentRate) private pure returns (uint256 rAmount, uint256 rTransferAmount, uint256 rRfi) {


        rAmount = tAmount.mul(currentRate); //wondering how rfi works ? This is the trick

        if(!takeFee) {
          return(rAmount, rAmount, 0);
        }

        rRfi = s.tRfi.mul(currentRate);
        uint256 rLiquidity = s.tLiquidity.mul(currentRate);
        uint256 rResearch = s.tResearch.mul(currentRate);
        uint256 rDev = s.tDev.mul(currentRate);

        rTransferAmount = rAmount.sub(rRfi).sub(rLiquidity).sub(rResearch).sub(rDev);

        return (rAmount, rTransferAmount, rRfi);
    }

    function _getRate() private view returns(uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns(uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {

        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }


    function _approve(address owner, address spender, uint256 amount) private {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    

    function _transfer(address from, address to, uint256 amount , bool takeFee) private {

        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(from),"Insuf balance, check balance at SafeSale.finance if you have token lock");
        if((from != owner() && to != owner()) && ( !isPresaleWallet[from] &&  !isPresaleWallet[to]))  
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

        uint256 contractTokenBalance = balanceOf(address(this));

        if(contractTokenBalance >= _maxTxAmount) {
            contractTokenBalance = _maxTxAmount;
        }

        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (overMinTokenBalance && !inSwapAndLiquify && from != pancakeswapV2Pair && swapAndLiquifyEnabled) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance);
        }
        bool shouldTakeFeeForTransfer = takeFee &&
            !(_isExcludedFromFee[from] || _isExcludedFromFee[to]);

        _tokenTransfer(from, to, amount, shouldTakeFeeForTransfer);
    }


    function _tokenTransfer(address sender, address recipient, uint256 tAmount, bool takeFee) private {

        if (_rOwned[recipient] == 0) {numOfHODLers++;}
        valuesFromGetValues memory s = _getValues(tAmount, takeFee);

        if (_isExcluded[sender] && !_isExcluded[recipient]) {  //from excluded
                _tOwned[sender] = _tOwned[sender].sub(tAmount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) { //to excluded
                _tOwned[recipient] = _tOwned[recipient].add(s.tTransferAmount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) { //both excluded
                _tOwned[sender] = _tOwned[sender].sub(tAmount);
                _tOwned[recipient] = _tOwned[recipient].add(s.tTransferAmount);
        }

        _rOwned[sender] = _rOwned[sender].sub(s.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(s.rTransferAmount);

        _takeLiquidity(s.tLiquidity);
        _reflectRfi(s.rRfi, s.tRfi);
        reflectDevandResearchFee(s.tDev,s.tResearch);

        emit Transfer(sender, recipient, s.tTransferAmount);
    }


    function reflectDevandResearchFee(uint256 tDev, uint256 tResearch) private {

        uint256 currentRate =  _getRate();
        uint256 rDevelopent =  tDev.mul(currentRate);
        uint256 rResearch =  tResearch.mul(currentRate);
        _tDevelopmentTotal = _tDevelopmentTotal.add(tDev);
        _rOwned[devWallet] = _rOwned[devWallet].add(rDevelopent);
        _tResearchTotal = _tResearchTotal.add(tResearch);
        _rOwned[researchWallet] = _rOwned[researchWallet].add(rResearch);
    }


    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {

        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        if(swapTokensForBNB(half)) { //enough liquidity ? If not, no swapLiq
          uint256 newBalance = address(this).balance.sub(initialBalance);
          addLiquidity(otherHalf, newBalance);
          emit SwapAndLiquify(half, newBalance, otherHalf);
        }
    }

    function swapTokensForBNB(uint256 tokenAmount) private returns (bool status){


        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = PancakeSwapV2Router.WETH();

        if(allowance(address(this), address(PancakeSwapV2Router)) < tokenAmount) {
          _approve(address(this), address(PancakeSwapV2Router), ~uint256(0));
        }

        try PancakeSwapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,0,path,address(this),block.timestamp) {
          emit SwapAndLiquifyStatus("Success");
          return true;
        }
        catch {
          emit SwapAndLiquifyStatus("Failed");
          return false;
        }

    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {

        PancakeSwapV2Router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
        emit LiquidityAdded(tokenAmount, bnbAmount);
    }

    function totalDevelopmentFee() public view returns (uint256) {

        return _tDevelopmentTotal;
    }
    
    function totalResearchFee() public view returns (uint256) {

        return _tResearchTotal;
    }
    
    function adminConfig(address adminAddress , bool isAdmin) external onlyOwner {

        adminAddresses[adminAddress] = isAdmin;
    }

    modifier onlyAdmin() {

        require(adminAddresses[_msgSender()], "Caller is not an admin.");
        _;
    }

    function _mint(address recipient, uint256 amount) private {

        require(amount > 0, "Transfer amount must be greater than zero");
        require(_tTotal + amount <= 4 * 10**9 * 10**_decimals, "Total supply cannot exceed 4B");
        
        uint256 _rTransferAmount = (amount.mul(_rTotal)).div(_tTotal);
        
        _tTotal = _tTotal.add(amount);
        _rTotal = _rTotal.add(_rTransferAmount);

        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient].add(amount);
        }

        _rOwned[recipient] = _rOwned[recipient].add(_rTransferAmount);

        emit Transfer(address(0), recipient, amount);
    }

    function _burn(address senderAddress, uint256 amount) private {

        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= balanceOf(senderAddress), "Insufficient balance");
        require(_tTotal - amount >= 0, "Total supply cannot be below 0");

        uint256 _rTransferAmount = (amount.mul(_rTotal)).div(_tTotal);
        
        _tTotal = _tTotal.sub(amount);
        _rTotal = _rTotal.sub(_rTransferAmount);

        if (_isExcluded[senderAddress]) {
            _tOwned[senderAddress] = _tOwned[senderAddress].sub(amount);
        }

        _rOwned[senderAddress] = _rOwned[senderAddress].sub(_rTransferAmount);

        emit Transfer(senderAddress, address(0), amount);
    }

    function mint(address recipient, uint256 value)
        external
        override
        onlyAdmin
    {

        _mint(recipient, value);
        emit Mint(value, recipient);
    }

    function burn(address fromAddress, uint256 value) external override onlyAdmin {

        _burn(fromAddress, value);
        emit Burn(value, fromAddress);
    }
    
    
    function withdrawStuckTokens(IERC20 token, address to) external onlyOwner {

        uint256 balance = token.balanceOf(address(this));
        token.transfer(to, balance);
    }

    function withdrawLeftoverETH(address payable receipient) external onlyOwner {

        receipient.transfer(address(this).balance);
    }
    
}