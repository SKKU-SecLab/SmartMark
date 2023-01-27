

pragma solidity ^0.8.4;


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



pragma solidity ^0.8.4;

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



pragma solidity ^0.8.4;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}



pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.8.4;


contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }
    
    function _onlyOwner() private view {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
    }

    modifier onlyOwner() {

        _onlyOwner();
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



pragma solidity ^0.8.4;



contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;
    
    mapping(address => mapping(address => uint256)) private _allowances;
    
    uint256 private _totalSupply;
    uint8 private _decimals;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

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

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

}



pragma solidity ^0.8.4;

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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

pragma solidity ^0.8.4;

contract RYOSHI is ERC20, Ownable {
    using Address for address payable;

    IUniswapV2Router02 private uniswapV2Router;
    address public uniswapV2Pair;

    mapping(address => bool) private isExcludedFromFee;
    mapping(address => bool) private isBlacklisted;
    mapping(address => bool) private automatedMarketMakerPairs;
    
    uint8 private liquidityFee = 1;
    uint8 private marketingFee = 2;
    uint8 private burnFee = 2;
    uint8 public totalFees = liquidityFee + marketingFee + burnFee;
    address public marketingWallet = 0x958C4edB417399Bb9440dc2435De7Fbd03b67176;
    
    bool private inSwapAndLiquify;
    bool private swapAndLiquifyEnabled = true;
    
    uint48 private antibotEndTime;
    
    address private constant BURN_WALLET = 0x000000000000000000000000000000000000dEaD;

    uint256 public _maxTxAmount;
    uint256 private numTokensSellToAddToLiquidity;

    string private constant ALREADY_SET = "Already set";
    string private constant ZERO_ADDRESS = "Zero address";
    
    event MinTokensBeforeSwapUpdated (uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated (bool enabled); 
    event AccidentallySentTokenWithdrawn (address token, uint256 amount);
    event AccidentallySentBNBWithdrawn (uint256 amount);
    event ExcludeFromFee (address account, bool isExcluded);
    event UpdateUniswapV2Router (address newAddress, address oldAddress);
    event MarketingWalletUpdated (address oldMarketingWallet, address newMarketingWallet);
    event MaxTxAmountChanged (uint256 oldMaxTxAmount, uint256 newMaxTxAmount);
    event SetAutomatedMarketMakerPair (address pair, bool value);
    event FeesUpdated (uint8 oldMarketingFee, uint8 newMarketingFee, uint8 oldLiquidityFee, uint8 newLiquidityFee, uint8 oldBurnFee, uint8 newBurnFee);
        
    constructor() ERC20 ("RYOSHI TOKEN", "RYOSHI", 9) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Router = _uniswapV2Router;
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        automatedMarketMakerPairs[_uniswapV2Pair] = true;
        uniswapV2Pair = _uniswapV2Pair;
        
        isExcludedFromFee[msg.sender] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromFee[marketingWallet] = true;
        isExcludedFromFee[BURN_WALLET] = true;
        
        _mint (msg.sender, 1 * 10**15 * 10**9);
        _maxTxAmount = 1 * 10**15 * 10**9 / 100;
        numTokensSellToAddToLiquidity = 1 * 10**15 * 10**9 / 10000;
    }

    function setAutomatedMarketMakerPair (address pair, bool value) external onlyOwner {
        require (pair != uniswapV2Pair || value, "Can't remove");
        
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair (pair, value);
    }
    
    function excludeFromFee(address account, bool excluded) external onlyOwner {
        isExcludedFromFee[account] = excluded;
        emit ExcludeFromFee (account, excluded);
    }
    
    function setMarketingWallet(address _marketingWallet) external onlyOwner() {
        require (_marketingWallet != address(0), ZERO_ADDRESS);
        emit MarketingWalletUpdated (marketingWallet, _marketingWallet);
        marketingWallet = _marketingWallet;
    }
    
    function setMaxTxPercent (uint256 maxTxPercent) external onlyOwner() {
        require (maxTxPercent != 0, "Can't set");
        uint256 maxTxAmount = totalSupply() * maxTxPercent / 100;
        emit MaxTxAmountChanged (_maxTxAmount, maxTxAmount);
        _maxTxAmount = maxTxAmount;
    }
    
    function setFees (uint8 newMarketingFee, uint8 newLiquidityFee, uint8 newBurnFee) external onlyOwner {
        uint8 newTotalFees = newMarketingFee + newLiquidityFee + newBurnFee;
        require (newTotalFees <= 25, "must be <= 25%");
        
        emit FeesUpdated (marketingFee, newMarketingFee, liquidityFee, newLiquidityFee, burnFee, newBurnFee);
        
        marketingFee = newMarketingFee;
        liquidityFee = newLiquidityFee;
        burnFee = newBurnFee;
        totalFees = newTotalFees;
    }

    function updateUniswapV2Router (IUniswapV2Router02 newAddress) external onlyOwner {
        require(address(newAddress) != address(uniswapV2Router), ALREADY_SET);
        require(address(newAddress) != address(0), ZERO_ADDRESS);

        emit UpdateUniswapV2Router (address(newAddress), address(uniswapV2Router));
        
        uniswapV2Router = IUniswapV2Router02 (newAddress);
        
        address _uniswapV2Pair = IUniswapV2Factory (newAddress.factory()).createPair (address(this), newAddress.WETH());
        automatedMarketMakerPairs[_uniswapV2Pair] =  true;
        uniswapV2Pair = _uniswapV2Pair;
    }

    function blacklistAddress (address account, bool blacklist) external onlyOwner {
        require (isBlacklisted[account] != blacklist, ALREADY_SET);
        require (account != uniswapV2Pair, "Can't blacklist");
        isBlacklisted[account] = blacklist;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    receive() external payable {}


    function _getValues(address sender, uint256 amount) private returns (uint256 transferAmount) {
    }

    function withdrawOtherTokens (address _token) external onlyOwner {
        require (_token != address(this), "Can't withdraw");
        require (_token != address(0), ZERO_ADDRESS);
        IERC20 token = IERC20(_token);
        uint256 tokenBalance = token.balanceOf (address(this));

        if (tokenBalance > 0) {
            token.transfer (owner(), tokenBalance);
            emit AccidentallySentTokenWithdrawn (_token, tokenBalance);
        }
    }
    
    function withdrawExcessBNB() external onlyOwner {
        uint256 contractBNBBalance = address(this).balance;
        
        if (contractBNBBalance > 0)
            payable(owner()).sendValue(contractBNBBalance);
        
        emit AccidentallySentBNBWithdrawn (contractBNBBalance);
    }

    function _transfer (address sender, address recipient, uint256 amount) internal override  {
        require (sender != address(0) && recipient != address(0), ZERO_ADDRESS);
        require (!isBlacklisted[sender] && !isBlacklisted[recipient], "Blacklisted");
        address theOwner = owner();

        if (amount == 0)
            super._transfer (sender, recipient, 0);

        if (sender != theOwner && recipient != theOwner && sender != address(this))
            require(amount <= _maxTxAmount, "> maxTxAmount");
        else if (sender == theOwner && automatedMarketMakerPairs[recipient] && antibotEndTime == 0)
            antibotEndTime = uint48(block.timestamp + 12);

        if (balanceOf(address(this)) >= numTokensSellToAddToLiquidity && !inSwapAndLiquify && !automatedMarketMakerPairs[sender] && swapAndLiquifyEnabled) {
            inSwapAndLiquify = true;
            uint256 _marketingFee = marketingFee;
            uint256 marketingTokensToSwap = numTokensSellToAddToLiquidity * _marketingFee / (_marketingFee + liquidityFee);
            uint256 liquidityTokens = (numTokensSellToAddToLiquidity - marketingTokensToSwap) / 2;
            swapTokensForEth (numTokensSellToAddToLiquidity - liquidityTokens);
            addLiquidity (liquidityTokens, address(this).balance);

            if (address(this).balance > 0)
                payable(marketingWallet).sendValue (address(this).balance);
            
            inSwapAndLiquify = false;
        }
        
        if (!(isExcludedFromFee[sender] || isExcludedFromFee[recipient])) {
            uint256 feeDenominator = block.timestamp > antibotEndTime ? 100 : totalFees + 1;
            uint256 burnFeeAmount = (amount * burnFee) / feeDenominator;
            super._transfer (sender, BURN_WALLET, burnFeeAmount);
            uint256 otherFeeAmount = (amount * (liquidityFee + marketingFee)) / feeDenominator;
            super._transfer (sender, address(this), otherFeeAmount);
            amount -= (burnFeeAmount + otherFeeAmount);
        }
            
        super._transfer (sender, recipient, amount);
    }

    function swapTokensForEth (uint256 tokenAmount) private {
        IUniswapV2Router02 _uniswapV2Router = uniswapV2Router;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _uniswapV2Router.WETH();

        _approve(address(this), address(_uniswapV2Router), tokenAmount);
        uint256[] memory amounts = _uniswapV2Router.getAmountsOut (tokenAmount, path);

        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            amounts[1] * 95 / 100, // allow 5% slippage
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity (uint256 tokenAmount, uint256 ethAmount) private {
        if (tokenAmount > 0) {
            IUniswapV2Router02 _uniswapV2Router = uniswapV2Router;
            _approve(address(this), address(_uniswapV2Router), tokenAmount);

            _uniswapV2Router.addLiquidityETH{value: ethAmount}(
                address(this),
                tokenAmount,
                0, // slippage is unavoidable
                0, // slippage is unavoidable
                owner(),
                block.timestamp
            );
        }
    }
}