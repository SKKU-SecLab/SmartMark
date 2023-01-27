
pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
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

}// MIT

pragma solidity >=0.6.2 <0.8.0;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// AGPL-3.0-or-later

pragma solidity =0.6.12;

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
}// AGPL-3.0-or-later

pragma solidity =0.6.12;

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
}// AGPL-3.0-or-later

pragma solidity =0.6.12;

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
}// AGPL-3.0-or-later

pragma solidity =0.6.12;


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
}// AGPL-3.0-or-later

pragma solidity =0.6.12;

interface IDigitalReserve {
    function strategyTokenCount() external view returns (uint256);

    function strategyTokens(uint8 index) external view returns (address, uint8);

    function withdrawalFee() external view returns (uint8, uint8);

    function priceDecimals() external view returns (uint8);

    function totalTokenStored() external view returns (uint256[] memory);

    function getUserVaultInDrc(address user, uint8 percentage) external view returns (uint256, uint256, uint256);

    function depositPriceImpact(uint256 drcAmount) external view returns (uint256);

    function getProofOfDepositPrice() external view returns (uint256);

    function depositDrc(uint256 drcAmount, uint32 deadline) external;

    function withdrawDrc(uint256 drcAmount, uint32 deadline) external;

    function withdrawPercentage(uint8 percentage, uint32 deadline) external;

    event StrategyChange(
        address[] oldTokens, 
        uint8[] oldPercentage, 
        address[] newTokens, 
        uint8[] newPercentage, 
        uint256[] tokensStored
    );
    
    event Rebalance(
        address[] strategyTokens, 
        uint8[] tokenPercentage, 
        uint256[] tokensStored
    );
    
    event Deposit(
        address indexed user, 
        uint256 amount, 
        uint256 podMinted, 
        uint256 podTotalSupply, 
        uint256[] tokensStored
    );
    
    event Withdraw(
        address indexed user, 
        uint256 amount, 
        uint256 fees, 
        uint256 podBurned, 
        uint256 podTotalSupply, 
        uint256[] tokensStored
    );
}// AGPL-3.0-or-later

pragma solidity =0.6.12;



contract DigitalReserve is IDigitalReserve, ERC20, Ownable {
    using SafeMath for uint256;

    struct StategyToken {
        address tokenAddress;
        uint8 tokenPercentage;
    }

    constructor(
        address _router,
        address _drcAddress,
        string memory _name,
        string memory _symbol
    ) public ERC20(_name, _symbol) {
        drcAddress = _drcAddress;
        uniswapRouter = IUniswapV2Router02(_router);
    }

    StategyToken[] private _strategyTokens;
    uint8 private _feeFraction = 1;
    uint8 private _feeBase = 100;
    uint8 private constant _priceDecimals = 18;

    address private drcAddress;

    bool private depositEnabled = false;

    IUniswapV2Router02 private immutable uniswapRouter;

    function strategyTokenCount() public view override returns (uint256) {
        return _strategyTokens.length;
    }

    function strategyTokens(uint8 index) external view override returns (address, uint8) {
        return (_strategyTokens[index].tokenAddress, _strategyTokens[index].tokenPercentage);
    }

    function withdrawalFee() external view override returns (uint8, uint8) {
        return (_feeFraction, _feeBase);
    }

    function priceDecimals() external view override returns (uint8) {
        return _priceDecimals;
    }

    function totalTokenStored() public view override returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](strategyTokenCount());
        for (uint8 i = 0; i < strategyTokenCount(); i++) {
            amounts[i] = IERC20(_strategyTokens[i].tokenAddress).balanceOf(address(this));
        }
        return amounts;
    }

    function getUserVaultInDrc(
        address user, 
        uint8 percentage
    ) public view override returns (uint256, uint256, uint256) {
        uint256[] memory userStrategyTokens = _getStrategyTokensByPodAmount(balanceOf(user).mul(percentage).div(100));
        uint256 userVaultWorthInEth = _getEthAmountByStrategyTokensAmount(userStrategyTokens, true);
        uint256 userVaultWorthInEthAfterSwap = _getEthAmountByStrategyTokensAmount(userStrategyTokens, false);

        uint256 drcAmountBeforeFees = _getTokenAmountByEthAmount(userVaultWorthInEth, drcAddress, true);

        uint256 fees = userVaultWorthInEthAfterSwap.mul(_feeFraction).div(_feeBase + _feeFraction);
        uint256 drcAmountAfterFees = _getTokenAmountByEthAmount(userVaultWorthInEthAfterSwap.sub(fees), drcAddress, false);

        return (drcAmountBeforeFees, drcAmountAfterFees, fees);
    }

    function getProofOfDepositPrice() public view override returns (uint256) {
        uint256 proofOfDepositPrice = 0;
        if (totalSupply() > 0) {
            proofOfDepositPrice = _getEthAmountByStrategyTokensAmount(totalTokenStored(), true).mul(1e18).div(totalSupply());
        }
        return proofOfDepositPrice;
    }

    function depositPriceImpact(uint256 drcAmount) public view override returns (uint256) {
        uint256 ethWorth = _getEthAmountByTokenAmount(drcAmount, drcAddress, false);
        return _getEthToStrategyTokensPriceImpact(ethWorth);
    }

    function depositDrc(uint256 drcAmount, uint32 deadline) external override {
        require(strategyTokenCount() >= 1, "Strategy hasn't been set.");
        require(depositEnabled, "Deposit is disabled.");
        require(IERC20(drcAddress).allowance(msg.sender, address(this)) >= drcAmount, "Contract is not allowed to spend user's DRC.");
        require(IERC20(drcAddress).balanceOf(msg.sender) >= drcAmount, "Attempted to deposit more than balance.");

        uint256 swapPriceImpact = depositPriceImpact(drcAmount);
        uint256 feeImpact = (_feeFraction * 10000) / (_feeBase + _feeFraction);
        require(swapPriceImpact <= 100 + feeImpact, "Price impact on this swap is larger than 1% plus fee percentage.");

        SafeERC20.safeTransferFrom(IERC20(drcAddress), msg.sender, address(this), drcAmount);

        uint256 currentPodUnitPrice = getProofOfDepositPrice();

        uint256 ethConverted = _convertTokenToEth(drcAmount, drcAddress, deadline);
        _convertEthToStrategyTokens(ethConverted, deadline);

        uint256 podToMint = 0;
        if (totalSupply() == 0) {
            podToMint = drcAmount.mul(1e15);
        } else {
            uint256 vaultTotalInEth = _getEthAmountByStrategyTokensAmount(totalTokenStored(), true);
            uint256 newPodTotal = vaultTotalInEth.mul(1e18).div(currentPodUnitPrice);
            podToMint = newPodTotal.sub(totalSupply());
        }

        _mint(msg.sender, podToMint);

        emit Deposit(msg.sender, drcAmount, podToMint, totalSupply(), totalTokenStored());
    }

    function withdrawDrc(uint256 drcAmount, uint32 deadline) external override {
        require(balanceOf(msg.sender) > 0, "Vault balance is 0");
        
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = drcAddress;

        uint256 ethNeeded = uniswapRouter.getAmountsIn(drcAmount, path)[0];
        uint256 ethNeededPlusFee = ethNeeded.mul(_feeBase + _feeFraction).div(_feeBase);

        uint256[] memory userStrategyTokens = _getStrategyTokensByPodAmount(balanceOf(msg.sender));
        uint256 userVaultWorth = _getEthAmountByStrategyTokensAmount(userStrategyTokens, false);

        require(userVaultWorth >= ethNeededPlusFee, "Attempt to withdraw more than user's holding.");

        uint256 amountFraction = ethNeededPlusFee.mul(1e10).div(userVaultWorth);
        uint256 podToBurn = balanceOf(msg.sender).mul(amountFraction).div(1e10);

        _withdrawProofOfDeposit(podToBurn, deadline);
    }

    function withdrawPercentage(uint8 percentage, uint32 deadline) external override {
        require(balanceOf(msg.sender) > 0, "Vault balance is 0");
        require(percentage <= 100, "Attempt to withdraw more than 100% of the asset");

        uint256 podToBurn = balanceOf(msg.sender).mul(percentage).div(100);
        _withdrawProofOfDeposit(podToBurn, deadline);
    }

    function changeDepositStatus(bool status) external onlyOwner {
        depositEnabled = status;
    }

    function changeFee(uint8 withdrawalFeeFraction_, uint8 withdrawalFeeBase_) external onlyOwner {
        require(withdrawalFeeFraction_ <= withdrawalFeeBase_, "Fee fraction exceeded base.");
        uint8 percentage = (withdrawalFeeFraction_ * 100) / withdrawalFeeBase_;
        require(percentage <= 2, "Attempt to set percentage higher than 2%."); // Requested by community

        _feeFraction = withdrawalFeeFraction_;
        _feeBase = withdrawalFeeBase_;
    }

    function changeStrategy(
        address[] calldata strategyTokens_,
        uint8[] calldata tokenPercentage_,
        uint32 deadline
    ) external onlyOwner {
        require(strategyTokens_.length >= 1, "Setting strategy to 0 tokens.");
        require(strategyTokens_.length <= 5, "Setting strategy to more than 5 tokens.");
        require(strategyTokens_.length == tokenPercentage_.length, "Strategy tokens length doesn't match token percentage length.");

        uint256 totalPercentage = 0;
        for (uint8 i = 0; i < tokenPercentage_.length; i++) {
            totalPercentage = totalPercentage.add(tokenPercentage_[i]);
        }
        require(totalPercentage == 100, "Total token percentage is not 100%.");

        address[] memory oldTokens = new address[](strategyTokenCount());
        uint8[] memory oldPercentage = new uint8[](strategyTokenCount());
        for (uint8 i = 0; i < strategyTokenCount(); i++) {
            oldTokens[i] = _strategyTokens[i].tokenAddress;
            oldPercentage[i] = _strategyTokens[i].tokenPercentage;
        }

        uint256 ethConverted = _convertStrategyTokensToEth(totalTokenStored(), deadline);

        delete _strategyTokens;
        
        for (uint8 i = 0; i < strategyTokens_.length; i++) {
            _strategyTokens.push(StategyToken(strategyTokens_[i], tokenPercentage_[i]));
        }

        _convertEthToStrategyTokens(ethConverted, deadline);

        emit StrategyChange(oldTokens, oldPercentage, strategyTokens_, tokenPercentage_, totalTokenStored());
    }

    function rebalance(uint32 deadline) external onlyOwner {
        require(strategyTokenCount() > 0, "Strategy hasn't been set");

        uint256 totalWorthInEth = 0;
        uint256[] memory tokensWorthInEth = new uint256[](strategyTokenCount());

        for (uint8 i = 0; i < strategyTokenCount(); i++) {
            address currentToken = _strategyTokens[i].tokenAddress;
            uint256 tokenWorth = _getEthAmountByTokenAmount(IERC20(currentToken).balanceOf(address(this)), currentToken, true);
            totalWorthInEth = totalWorthInEth.add(tokenWorth);
            tokensWorthInEth[i] = tokenWorth;
        }

        address[] memory strategyTokensArray = new address[](strategyTokenCount()); // Get percentages for event param
        uint8[] memory percentageArray = new uint8[](strategyTokenCount()); // Get percentages for event param
        uint256 totalInEthToConvert = 0; // Get total token worth in ETH needed to be converted
        uint256 totalEthConverted = 0; // Get total token worth in ETH needed to be converted
        uint256[] memory tokenInEthNeeded = new uint256[](strategyTokenCount()); // Get token worth need to be filled

        for (uint8 i = 0; i < strategyTokenCount(); i++) {
            strategyTokensArray[i] =  _strategyTokens[i].tokenAddress;
            percentageArray[i] = _strategyTokens[i].tokenPercentage;

            uint256 tokenShouldWorth = totalWorthInEth.mul(_strategyTokens[i].tokenPercentage).div(100);

            if (tokensWorthInEth[i] <= tokenShouldWorth) {
                tokenInEthNeeded[i] = tokenShouldWorth.sub(tokensWorthInEth[i]);
                totalInEthToConvert = totalInEthToConvert.add(tokenInEthNeeded[i]);
            } else {
                tokenInEthNeeded[i] = 0;

                uint256 tokenInEthOverflowed = tokensWorthInEth[i].sub(tokenShouldWorth);
                uint256 tokensToConvert = _getTokenAmountByEthAmount(tokenInEthOverflowed, _strategyTokens[i].tokenAddress, true);
                uint256 ethConverted = _convertTokenToEth(tokensToConvert, _strategyTokens[i].tokenAddress, deadline);
                totalEthConverted = totalEthConverted.add(ethConverted);
            }
        }

        if(totalInEthToConvert > 0) {
            for (uint8 i = 0; i < strategyTokenCount(); i++) {
                uint256 ethToConvert = totalEthConverted.mul(tokenInEthNeeded[i]).div(totalInEthToConvert);
                _convertEthToToken(ethToConvert, _strategyTokens[i].tokenAddress, deadline);
            }
        }
        emit Rebalance(strategyTokensArray, percentageArray, totalTokenStored());
    }

    function _withdrawProofOfDeposit(uint256 podToBurn, uint32 deadline) private {
        uint256[] memory strategyTokensToWithdraw = _getStrategyTokensByPodAmount(podToBurn);

        _burn(msg.sender, podToBurn);

        uint256 ethConverted = _convertStrategyTokensToEth(strategyTokensToWithdraw, deadline);
        uint256 fees = ethConverted.mul(_feeFraction).div(_feeBase + _feeFraction);

        uint256 drcAmount = _convertEthToToken(ethConverted.sub(fees), drcAddress, deadline);

        SafeERC20.safeTransfer(IERC20(drcAddress), msg.sender, drcAmount);
        SafeERC20.safeTransfer(IERC20(uniswapRouter.WETH()), owner(), fees);

        emit Withdraw(msg.sender, drcAmount, fees, podToBurn, totalSupply(), totalTokenStored());
    }

    function _getAAmountByBAmount(
        uint256 _amount,
        address _fromAddress,
        address _toAddress,
        bool excludeFees
    ) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = _fromAddress;
        path[1] = _toAddress;

        if (path[0] == path[1] || _amount == 0) {
            return _amount;
        }

        uint256 amountOut = uniswapRouter.getAmountsOut(_amount, path)[1];

        if (excludeFees) {
            return amountOut.mul(1000).div(997);
        } else {
            return amountOut;
        }
    }

    function _getTokenAmountByEthAmount(
        uint256 _amount,
        address _tokenAddress,
        bool excludeFees
    ) private view returns (uint256) {
        return _getAAmountByBAmount(_amount, uniswapRouter.WETH(), _tokenAddress, excludeFees);
    }

    function _getEthAmountByTokenAmount(
        uint256 _amount,
        address _tokenAddress,
        bool excludeFees
    ) private view returns (uint256) {
        return _getAAmountByBAmount(_amount, _tokenAddress, uniswapRouter.WETH(), excludeFees);
    }

    function _getEthAmountByStrategyTokensAmount(
        uint256[] memory strategyTokensBalance_, 
        bool excludeFees
    ) private view returns (uint256) {
        uint256 amountOut = 0;
        address[] memory path = new address[](2);
        path[1] = uniswapRouter.WETH();

        for (uint8 i = 0; i < strategyTokenCount(); i++) {
            address tokenAddress = _strategyTokens[i].tokenAddress;
            path[0] = tokenAddress;
            uint256 tokenAmount = strategyTokensBalance_[i];
            uint256 tokenAmountInEth = _getEthAmountByTokenAmount(tokenAmount, tokenAddress, excludeFees);

            amountOut = amountOut.add(tokenAmountInEth);
        }
        return amountOut;
    }

    function _getStrategyTokensByPodAmount(uint256 _amount) private view returns (uint256[] memory) {
        uint256[] memory strategyTokenAmount = new uint256[](strategyTokenCount());

        uint256 podFraction = 0;
        if(totalSupply() > 0){
            podFraction = _amount.mul(1e10).div(totalSupply());
        }
        for (uint8 i = 0; i < strategyTokenCount(); i++) {
            strategyTokenAmount[i] = IERC20(_strategyTokens[i].tokenAddress).balanceOf(address(this)).mul(podFraction).div(1e10);
        }
        return strategyTokenAmount;
    }

    function _getEthToTokenPriceImpact(uint256 _amount, address _tokenAddress) private view returns (uint256) {
        if(_tokenAddress == uniswapRouter.WETH() || _amount == 0) {
            return 0;
        }
        address factory = uniswapRouter.factory();
        address pair = IUniswapV2Factory(factory).getPair(uniswapRouter.WETH(), _tokenAddress);
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pair).getReserves();
        uint256 reserveEth = 0;
        if(IUniswapV2Pair(pair).token0() == uniswapRouter.WETH()) {
            reserveEth = reserve0;
        } else {
            reserveEth = reserve1;
        }
        return 10000 - reserveEth.mul(10000).div(reserveEth.add(_amount));
    }

    function _getEthToStrategyTokensPriceImpact(uint256 _amount) private view returns (uint256) {
        uint256 priceImpact = 0;
        for (uint8 i = 0; i < strategyTokenCount(); i++) {
            uint8 tokenPercentage = _strategyTokens[i].tokenPercentage;
            uint256 amountToConvert = _amount.mul(tokenPercentage).div(100);
            uint256 tokenSwapPriceImpact = _getEthToTokenPriceImpact(amountToConvert, _strategyTokens[i].tokenAddress);
            priceImpact = priceImpact.add(tokenSwapPriceImpact.mul(tokenPercentage).div(100));
        }
        return priceImpact;
    }

    function _convertTokenToEth(
        uint256 _amount,
        address _tokenAddress,
        uint32 deadline
    ) private returns (uint256) {
        if (_tokenAddress == uniswapRouter.WETH() || _amount == 0) {
            return _amount;
        }
        address[] memory path = new address[](2);
        path[0] = _tokenAddress;
        path[1] = uniswapRouter.WETH();

        SafeERC20.safeApprove(IERC20(path[0]), address(uniswapRouter), _amount);
        
        uint256 amountOut = uniswapRouter.getAmountsOut(_amount, path)[1];
        uint256 amountOutWithFeeTolerance = amountOut.mul(999).div(1000);
        uint256 ethBeforeSwap = IERC20(path[1]).balanceOf(address(this));
        uniswapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(_amount, amountOutWithFeeTolerance, path, address(this), deadline);
        uint256 ethAfterSwap = IERC20(path[1]).balanceOf(address(this));
        return ethAfterSwap - ethBeforeSwap;
    }

    function _convertEthToToken(
        uint256 _amount,
        address _tokenAddress,
        uint32 deadline
    ) private returns (uint256) {
        if (_tokenAddress == uniswapRouter.WETH() || _amount == 0) {
            return _amount;
        }
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = _tokenAddress;
        SafeERC20.safeApprove(IERC20(path[0]), address(uniswapRouter), _amount);
        uint256 amountOut = uniswapRouter.getAmountsOut(_amount, path)[1];
        uniswapRouter.swapExactTokensForTokens(_amount, amountOut, path, address(this), deadline);
        return amountOut;
    }

    function _convertEthToStrategyTokens(
        uint256 amount, 
        uint32 deadline
    ) private returns (uint256[] memory) {
        for (uint8 i = 0; i < strategyTokenCount(); i++) {
            uint256 amountToConvert = amount.mul(_strategyTokens[i].tokenPercentage).div(100);
            _convertEthToToken(amountToConvert, _strategyTokens[i].tokenAddress, deadline);
        }
    }

    function _convertStrategyTokensToEth(
        uint256[] memory amountToConvert, 
        uint32 deadline
    ) private returns (uint256) {
        uint256 ethConverted = 0;
        for (uint8 i = 0; i < strategyTokenCount(); i++) {
            uint256 amountConverted = _convertTokenToEth(amountToConvert[i], _strategyTokens[i].tokenAddress, deadline);
            ethConverted = ethConverted.add(amountConverted);
        }
        return ethConverted;
    }
}