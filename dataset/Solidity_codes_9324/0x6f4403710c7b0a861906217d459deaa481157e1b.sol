
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

        return functionCallWithValue(target, data, 0, errorMessage);
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;


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
}pragma solidity >=0.5.0;

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

}pragma solidity >=0.6.2;

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

}pragma solidity >=0.6.2;


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

}/**

 /$$   /$$                              /$$$$$$                           /$$     /$$                           
| $$  | $$                             |_  $$_/                          |  $$   /$$/                           
| $$  | $$  /$$$$$$   /$$$$$$   /$$$$$$  | $$   /$$$$$$$  /$$   /$$       \  $$ /$$//$$$$$$   /$$$$$$   /$$$$$$ 
| $$$$$$$$ |____  $$ /$$__  $$ /$$__  $$ | $$  | $$__  $$| $$  | $$        \  $$$$//$$__  $$ |____  $$ /$$__  $$
| $$__  $$  /$$$$$$$| $$  \ $$| $$  \ $$ | $$  | $$  \ $$| $$  | $$         \  $$/| $$$$$$$$  /$$$$$$$| $$  \__/
| $$  | $$ /$$__  $$| $$  | $$| $$  | $$ | $$  | $$  | $$| $$  | $$          | $$ | $$_____/ /$$__  $$| $$      
| $$  | $$|  $$$$$$$| $$$$$$$/| $$$$$$$//$$$$$$| $$  | $$|  $$$$$$/          | $$ |  $$$$$$$|  $$$$$$$| $$      
|__/  |__/ \_______/| $$____/ | $$____/|______/|__/  |__/ \______/           |__/  \_______/ \_______/|__/      
                    | $$      | $$                                                                              
                    | $$      | $$                                                                              
                    |__/      |__/                                                                           

Twitter: https://twitter.com/Happinuyear2022
Telegram: https://t.me/happinuyear
Website: https://www.happinuyear.com

- Tokenomics: 80% burn (Every day, new random burn, from 1 to 10% of the remaining supply) | 10% use for liquidity | 10% use for presale
- Ownership will be transferred to the dead address after the audit
- 6% of the fee will be used to automatically add liquidity to the liquidityLockAddress. Liquidity will be sent to deadAdress to create a deflation mechanism that will reduce supply and increase liquidity by time.
- 3% fee sent to marketingAddress will be used to promote the project 100% transparency with the DAO.
- 3% fee sent to nftAddress will be used to buy NFT chosen by the DAO and share them randomly with token holders.
*/

pragma solidity ^0.8.3;


contract HappInuYear is Context, IERC20, Ownable {

    using SafeMath for uint256;
    using SafeMath for uint8;
    using Address for address;

    address payable public marketingAddress = payable(0xfe727321BEbec92B515bC1F0F77FC1cBC47Eee9E);
    address payable public nftAddress = payable(0xd4F12167ED3DB5569C510783282dbD6256F44FD5);
    address payable public liquidityLockAddress = payable(0x000000000000000000000000000000000000dEaD);
    address public constant uniSwapRouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isSniper;
    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 2022 * 10**6 * 10**9;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "HappInuYear";
    string private constant _symbol = "HIY";

    uint8 private constant _decimals = 9;
    uint8 public taxFee;
    uint8 private _previousTaxFee = taxFee;
    uint8 public totalFee = 12;
    uint8 private _previousTotalFee = totalFee;
    uint8 public marketingFee = 3;
    uint8 public nftFee = 3;
    uint8 public highPriceImpactMultiplicator = 1;

    bool public swapAndLiquifyEnabled = false;
    bool public feesAfterHighPriceImpactEnabled = false;
    bool inSwapAndLiquify;

    uint256 public maxTxAmount = 20 * 10**6 * 10**9;
    uint256 private minimumTokensBeforeSwap = 1 * 10**6 * 10**9;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    event FeesAfterHighPriceImpactEnabledUpdated(bool enabled);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event UniswapV2PairUpdated(address pairAddress);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event SwapTokensForETH(uint256 amountIn, address[] path);

    modifier lockTheSwap() {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        _rOwned[_msgSender()] = _rTotal;
        uniswapV2Router = IUniswapV2Router02(uniSwapRouterAddress);

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[nftAddress] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function totalSupply() public pure override returns (uint256) {

        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    function totalFees() public view returns (uint256) {

        return _tFeeTotal;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {

        return minimumTokensBeforeSwap;
    }

    function tokenFromReflection(uint256 rAmount) public view returns (uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function isBlockedSniper(address account) public view returns (bool) {

        return _isSniper[account];
    }

    function blockSniper(address account) external onlyOwner {

        require(!_isSniper[account], "Account is already blacklisted");
        _isSniper[account] = true;
    }

    function amnestySniper(address account) external onlyOwner {

        require(_isSniper[account], "Account is not blacklisted");
        _isSniper[account] = false;
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
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!_isSniper[to], "You have no power here!");
        require(!_isSniper[from], "You have no power here!");

        if (from != owner() && to != owner() && from != address(this)) {
            require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        }

        if (
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled &&
            to == uniswapV2Pair &&
            balanceOf(address(this)) >= minimumTokensBeforeSwap
        ) {
            swapAndLiquify(minimumTokensBeforeSwap);
        }

        bool takeFee = !(_isExcludedFromFee[from] || _isExcludedFromFee[to]);
        if (!takeFee) removeAllFee();
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(amount, to);
        _rOwned[from] = _rOwned[from].sub(rAmount);
        _rOwned[to] = _rOwned[to].add(rTransferAmount);
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(from, to, tTransferAmount);
        if (!takeFee) restoreAllFee();
    }

    function swapAndLiquify(uint256 tokenAmount) private lockTheSwap {

        uint256 liquidityDivisor = totalFee.sub(marketingFee).sub(nftFee).div(2);
        uint256 tokenForLiquify = tokenAmount.mul(liquidityDivisor).div(totalFee);
        uint256 tokenForSwap = tokenAmount.sub(tokenForLiquify);
        uint256 initialBalance = address(this).balance;
        swapTokensForEth(tokenForSwap);

        uint256 transferredBalance = address(this).balance.sub(initialBalance);
        uint256 balanceForLiquidity = transferredBalance.mul(liquidityDivisor).div(totalFee.sub(liquidityDivisor));
        addLiquidity(tokenForLiquify, balanceForLiquidity);

        uint256 leftoverBalance = address(this).balance;
        uint256 halfAmount = leftoverBalance.div(2);
        transferToAddressETH(marketingAddress, halfAmount);
        transferToAddressETH(nftAddress, leftoverBalance.sub(halfAmount));

        emit SwapAndLiquify(tokenForSwap, balanceForLiquidity, tokenForLiquify);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {

        require(tokenAmount <= balanceOf(address(this)), "Not enough HIY in contract balance");
        require(ethAmount <= address(this).balance, "Not enough ETH in contract balance");
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            liquidityLockAddress,
            block.timestamp
        );
    }

    function swapTokensForEth(uint256 tokenAmount) private {

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

        emit SwapTokensForETH(tokenAmount, path);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {

        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getValues(uint256 tAmount, address recipient)
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

        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount, recipient);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tLiquidity, _getRate());
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tLiquidity);
    }

    function _getTValues(uint256 tAmount, address recipient)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        uint256 tFee = tAmount.mul(taxFee).div(10**2);
        uint256 tLiquidity = calculateFinalFee(tAmount, recipient);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _priceImpact(uint256 transferAmount) private view returns (uint256) {

        (uint256 reserves0, uint256 reserves1, ) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        (uint256 reserveA, uint256 reserveB) = address(this) == IUniswapV2Pair(uniswapV2Pair).token0()
            ? (reserves0, reserves1)
            : (reserves1, reserves0);
        if (reserveA == 0 || reserveB == 0) {
            return 0;
        }
        uint256 exactQuote = transferAmount.mul(reserveB).div(reserveA);
        uint256 outputAmount = IUniswapV2Router02(uniSwapRouterAddress).getAmountOut(
            transferAmount,
            reserveA,
            reserveB
        );
        return exactQuote.sub(outputAmount).mul(10**2).div(exactQuote);
    }

    function _calculateHighPriceImpactFee(uint256 priceImpact) private view returns (uint256) {

        uint256 tax = 0;
        if (priceImpact >= 1 && priceImpact < 2) {
            tax = 2;
        } else if (priceImpact >= 2 && priceImpact < 3) {
            tax = 3;
        } else if (priceImpact >= 3 && priceImpact < 4) {
            tax = 4;
        } else if (priceImpact >= 4) {
            tax = 5;
        }
        return tax.mul(highPriceImpactMultiplicator);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {

        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {

        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
    }

    function calculateFinalFee(uint256 _amount, address recipient) private view returns (uint256) {

        if (!swapAndLiquifyEnabled) {
            return 0;
        }
        if (feesAfterHighPriceImpactEnabled && recipient == uniswapV2Pair && totalFee > 0) {
            uint256 priceImpact = _priceImpact(_amount);
            uint256 highPriceImpactFee = _calculateHighPriceImpactFee(priceImpact);
            uint256 finalFee = totalFee.add(highPriceImpactFee);
            return _amount.mul(finalFee).div(10**2);
        }
        return _amount.mul(totalFee).div(10**2);
    }

    function removeAllFee() private {

        if (taxFee == 0 && totalFee == 0) return;
        _previousTaxFee = taxFee;
        _previousTotalFee = totalFee;
        taxFee = 0;
        totalFee = 0;
    }

    function restoreAllFee() private {

        taxFee = _previousTaxFee;
        totalFee = _previousTotalFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {

        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {

        _isExcludedFromFee[account] = false;
    }

    function setTaxFeePercent(uint8 fee) external onlyOwner {

        require(fee <= 5, "fee too high");
        taxFee = fee;
    }

    function setTotalFeePercent(uint8 fee) external onlyOwner {

        require(fee <= 10, "fee too high");
        totalFee = fee;
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {

        maxTxAmount = amount;
    }

    function setMarketingFee(uint8 fee) external onlyOwner {

        require(fee <= 3, "fee too high");
        marketingFee = fee;
    }

    function setNftFee(uint8 fee) external onlyOwner {

        require(fee <= 3, "fee too high");
        nftFee = fee;
    }

    function setHighPriceImpactMultiplicator(uint8 multiplicator) external onlyOwner {

        require(multiplicator <= 10, "multiplicator too high");
        highPriceImpactMultiplicator = multiplicator;
    }

    function setMinimumTokensBeforeSwap(uint256 _minimumTokensBeforeSwap) external onlyOwner {

        minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
    }

    function setMarketingAddress(address _marketingAddress) external onlyOwner {

        marketingAddress = payable(_marketingAddress);
    }

    function setNftAddress(address _nftAddress) external onlyOwner {

        nftAddress = payable(_nftAddress);
    }

    function setLiquidityLockAddress(address _liquidityLockAddress) external onlyOwner {

        liquidityLockAddress = payable(_liquidityLockAddress);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setFeesAfterHighPriceImpactEnabled(bool _enabled) public onlyOwner {

        feesAfterHighPriceImpactEnabled = _enabled;
        emit FeesAfterHighPriceImpactEnabledUpdated(_enabled);
    }

    function setUniswapV2Pair(address _uniswapV2Pair) public onlyOwner {

        uniswapV2Pair = _uniswapV2Pair;
        emit UniswapV2PairUpdated(_uniswapV2Pair);
    }

    function prepareForPreSale() external onlyOwner {

        swapAndLiquifyEnabled = false;
        feesAfterHighPriceImpactEnabled = false;
    }

    function beforeLiquidityAdded() external onlyOwner {

        swapAndLiquifyEnabled = true;
    }

    function afterLiquidityAdded(address _uniswapV2Pair) external onlyOwner {

        setUniswapV2Pair(_uniswapV2Pair);
        swapAndLiquifyEnabled = true;
        feesAfterHighPriceImpactEnabled = true;
    }

    function transferToAddressETH(address payable recipient, uint256 amount) private {

        recipient.transfer(amount);
    }

    receive() external payable {}
}