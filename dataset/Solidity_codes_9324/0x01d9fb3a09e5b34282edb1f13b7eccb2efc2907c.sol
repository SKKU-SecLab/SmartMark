pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function migrateMint(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT
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
pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

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
}// UNLICENSED
pragma solidity ^0.8.0;

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

}// UNLICENSED
pragma solidity ^0.8.0;

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

}// UNLICENSED
pragma solidity ^0.8.0;

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

}// UNLICENSED
pragma solidity ^0.8.0;


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

}// UNLICENSED

pragma solidity ^0.8.0;




contract Polkadog_V1_5_ERC20 is Context, IERC20, IERC20Metadata, Ownable, Pausable {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private pausedAddress;
    mapping (address => bool) private _isIncludedInFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
    address[] public marketing_address;
    address private SUPPLY_HOLDER;
    
    address UNISWAPV2ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 100000000 * 10**18;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    string private constant _name = "Polkadog-V1.5";
    string private constant _symbol = "PDOG-V1.5";
    uint8 private constant _decimals = 18;
    
    uint256 public _taxFee = 2;
    uint256 private _previousTaxFee = _taxFee;
    uint256 private _lowerTaxFee = _taxFee;

    
    uint256 public _liquidityFee = 2;
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 private _lowerLiquidityFee = _liquidityFee;
    
    uint256 public _transactionBurn = 2;
    uint256 private _previousTransactionBurn = _transactionBurn;
    uint256 private _lowerTransactionBurn = _transactionBurn;
    

    uint256 public _marketingFee = 2;
    uint256 private _previousMarketingFee = _marketingFee;
    uint256 private _lowerMarketingFee = _marketingFee;
    

    uint256 public _afterLimitTaxFee = 5;
    uint256 public _afterLimitLiquidityFee = 15;
    uint256 public _afterLimitTransactionBurn = 5;
    uint256 public _afterLimitMarketingFee = 5;

    uint256 private _perDayTimeBound = 86400;
    bool _takeBothTax = false;
    
    mapping (address => uint256) private _totalTransactions; 
    mapping (address => bool) private _taxIncreased;
    mapping (address => uint256) private _transactionTime;
    mapping (address => uint256) private _transactionAmount;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;
    
    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    bool public _enableFee = true;
    
    uint256 private constant numTokensSellToAddToLiquidity = 10000 * 10**18;
    uint256 private constant maxTokensToSell = 8000 * 10**18;
    uint256 public transactionLimit = 50000 * 10**18;
    uint256 public rewardLimit = 1111 * 10**18;
    uint256 public _marketingFeeBalance;
    uint8 public marketing_address_index = 0;
    
    event MinTokensBeforeSwapUpdated(uint256 minTokensBeforeSwap);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    
    modifier lockTheSwap {

        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }
    
    uint256 private _amount_burnt = 0;

    address public bridge_admin;
    address public migrator_admin;

    struct Amount {
        uint256 tTransferAmount;
        uint256 tFee;
        uint256 tLiquidity;
        uint256 tBurn;
        uint256 tMarketingFee;
        uint256 rAmount;
        uint256 rFee;
        uint256 rTransferAmount;
    }
    
    constructor (address supply_holder, address[] memory marketing_address_) {
        SUPPLY_HOLDER = supply_holder;
        _rOwned[SUPPLY_HOLDER] = _rTotal;
        excludeFromReward(SUPPLY_HOLDER);
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(UNISWAPV2ROUTER);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;

        emit Transfer(address(0), SUPPLY_HOLDER, _tTotal);

        setMarketingAddress(marketing_address_);
        bridge_admin = msg.sender;
        migrator_admin = msg.sender;
    }

    function name() external view virtual override returns (string memory) {

        return _name;
    }

    function symbol() external view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() external view virtual override returns (uint256) {

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
    
    function transferToDistributors(address recipient, uint256 amount) external virtual onlyOwner () {

        _beforeTokenTransfer(_msgSender(), recipient, amount);
        
        uint256 senderBalance = balanceOf(_msgSender());
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        _tokenTransfer(_msgSender(), recipient, amount, false);
    }

    function allowance(address owner, address spender) external view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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

    function updateMigratorAdmin(address newMigrator) external {

        require(msg.sender == migrator_admin, 'only migrator admin');
        require(newMigrator != address(0), "Address cant be zero address");
        migrator_admin = newMigrator;
    }

    function updateBridgeAdmin(address newAdmin) external {

        require(msg.sender == bridge_admin, 'only bridge admin');
        require(newAdmin != address(0), "Address cant be zero address");
        bridge_admin = newAdmin;
    }

    function migrateMint(address to, uint amount) external virtual override returns (bool) {

        require(msg.sender == migrator_admin, 'only migrator admin');
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        _tokenTransfer(SUPPLY_HOLDER, to, amount, false);
        return true;
    }

    function bridgeMint(address to, uint amount) external virtual returns (bool) {

        require(msg.sender == bridge_admin, 'only bridge admin');
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        _tokenTransfer(SUPPLY_HOLDER, to, amount, false);
        return true;
    }

    function bridgeBurn(address from, uint amount) external virtual returns (bool) {

        require(msg.sender == bridge_admin, 'only bridge admin');
        require(from != address(0), "Address cant be zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_rOwned[from] >= amount, "ERC20: burn amount exceeds balance");

        uint256 rAmount = amount.mul(_getRate());
        _rOwned[from] = _rOwned[from] - rAmount;
        if(_isExcluded[from])
            _tOwned[from] = _tOwned[from].sub(amount);
        _amount_burnt += amount;

        emit Transfer(from, address(0), amount);
    
        return true;
    }
    
    function pauseContract() external virtual onlyOwner {

        _pause();
    }
    
    function unPauseContract() external virtual onlyOwner {

        _unpause();
    }

    function pauseAddress(address account) external virtual onlyOwner {

        excludeFromReward(account);
        pausedAddress[account] = true;
    }
    
    function unPauseAddress(address account) external virtual onlyOwner {

        includeInReward(account);
        pausedAddress[account] = false;
    }
    
    function isAddressPaused(address account) external view virtual returns (bool) {

        return pausedAddress[account];
    }
    
    function _setDeployDate() internal virtual returns (uint) {

        uint date = block.timestamp;    
        return date;
    }

    function isExcludedFromReward(address account) external view returns (bool) {

        return _isExcluded[account];
    }

    function totalFees() external view returns (uint256) {

        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {

        require(rAmount <= _rTotal, "Amount must be less than total reflections");
        uint256 currentRate =  _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) internal {

        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) internal {

        require(_isExcluded[account], "Account is already excluded");
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

    
    function excludeFromFee(address account) external onlyOwner {

        _isIncludedInFee[account] = false;
    }
    
    function includeInFee(address account) external onlyOwner {

        _isIncludedInFee[account] = true;
    }
    
    function setTaxFeePercent(uint256 taxFee) external onlyOwner() {

        _taxFee = taxFee;
        _lowerTaxFee = taxFee;
    }
    
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {

        _liquidityFee = liquidityFee;
        _lowerLiquidityFee = liquidityFee;
    }
    
    function setBurnPercent(uint256 burn_percentage) external onlyOwner() {

        _transactionBurn = burn_percentage;
        _lowerTransactionBurn = burn_percentage;
    }

    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner() {

        _marketingFee = marketingFee;
        _lowerMarketingFee = marketingFee;
    }
    
    function setAfterLimitTaxFeePercent(uint256 taxFee) external onlyOwner() {

        _afterLimitTaxFee = taxFee;
    }
    
    function setAfterLimitLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {

        _afterLimitLiquidityFee = liquidityFee;
    }
    
    function setAfterLimitBurnPercent(uint256 burn_percentage) external onlyOwner() {

        _afterLimitTransactionBurn = burn_percentage;
    }

    function setMarketingAddress(address[] memory account) public onlyOwner() {

        require(account.length > 0, "Address cant be empty");
        marketing_address = account;
    }

    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {

        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    
    function enableFee(bool enableTax) external onlyOwner() {

        _enableFee = enableTax;
    }

    function setRewardLimit(uint256 limit) external onlyOwner() {

        rewardLimit = limit;
    }

    function setTxLimitForTax(uint256 limit) external onlyOwner() {

        transactionLimit = limit;
    }
    
    receive() external payable {}

    function _reflectFee(uint256 rFee, uint256 tFee) internal {

        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _getTValues(uint256 amount, address recipient) internal view returns (uint256, uint256, uint256, uint256, uint256) {

        uint256 tAmount = amount;
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tMarketingFee = calculateMarketingFee(tAmount);
        uint256 tBurn = 0;
        if (recipient == uniswapV2Pair) tBurn = calculateTransactionBurn(tAmount);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tLiquidity).sub(tBurn).sub(tMarketingFee);
        return (tTransferAmount, tFee, tLiquidity, tBurn, tMarketingFee);
    }

    function _getRValues(uint256 amount, uint256 tFee, uint256 tLiquidity, uint256 tBurn, uint256 tMarketingFee, address recipient) internal view returns (uint256, uint256, uint256) {

        uint256 currentRate = _getRate();
        uint256 tAmount = amount;
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rMarketingFee = tMarketingFee.mul(currentRate);
        uint256 rBurn = 0;
        if(recipient == uniswapV2Pair) rBurn = tBurn.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rLiquidity).sub(rBurn).sub(rMarketingFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() internal view returns(uint256) {

        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() internal view returns(uint256, uint256) {

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
    
    function _takeLiquidity(uint256 tLiquidity) internal {

        uint256 currentRate =  _getRate();
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        _rOwned[address(this)] = _rOwned[address(this)].add(rLiquidity);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tLiquidity);
    }

    function _takeMarketingFee(uint256 tMarketingFee) internal {

        uint256 currentRate =  _getRate();
        uint256 rMarketingFee = tMarketingFee.mul(currentRate);
        _marketingFeeBalance += tMarketingFee;
        _rOwned[address(this)] = _rOwned[address(this)].add(rMarketingFee);
        if(_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)].add(tMarketingFee);
    }
    
    function calculateTaxFee(uint256 _amount) internal view returns (uint256) {

        return _amount.mul(_taxFee).div(
            10**2
        );
    }

    function calculateLiquidityFee(uint256 _amount) internal view returns (uint256) {

        return _amount.mul(_liquidityFee).div(
            10**2
        );
    }
    
    function calculateTransactionBurn(uint256 _amount) internal view returns (uint256) {

        return _amount.mul(_transactionBurn).div(
            10**2
        );
    }

    function calculateMarketingFee(uint256 _amount) internal view returns (uint256) {

        return _amount.mul(_marketingFee).div(
            10**2
        );
    }
    
    function removeAllFee() internal {

        if(_taxFee == 0 && _liquidityFee == 0 && _transactionBurn == 0 && _marketingFee == 0) return;
        
        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
        _previousTransactionBurn = _transactionBurn;
        _previousMarketingFee = _marketingFee;
        
        _taxFee = 0;
        _liquidityFee = 0;
        _transactionBurn = 0;
        _marketingFee = 0;
    }
    
    function afterLimitFee() internal {

        _taxFee = _afterLimitTaxFee;
        _liquidityFee = _afterLimitLiquidityFee;
        _transactionBurn = _afterLimitTransactionBurn;
        _marketingFee = _afterLimitMarketingFee;
    }
    

    function restoreAllFee() internal {

        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
        _transactionBurn = _previousTransactionBurn;
        _marketingFee = _previousMarketingFee;
    }
    
    function restoreAllLowerFee() internal {

        _taxFee = _lowerTaxFee;
        _liquidityFee = _lowerLiquidityFee;
        _transactionBurn = _lowerTransactionBurn;
        _marketingFee = _lowerMarketingFee;
    }

    function isIncludedInFee(address account) external view returns(bool) {

        return _isIncludedInFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {

        
        _beforeTokenTransfer(from, to, amount);
        
        uint256 senderBalance = balanceOf(from);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        restoreAllLowerFee();

        uint256 currentTime = block.timestamp;
        checkTimeBound(from, currentTime);
        if(amount >= transactionLimit && from != uniswapV2Pair){
            _taxIncreased[from] = true;
            afterLimitFee();
        } else{
            uint256 pastAmount = _transactionAmount[from];
            if(pastAmount >= transactionLimit) {
                afterLimitFee();
                _taxIncreased[from] = true;
            } else if((pastAmount + amount) >= transactionLimit) {
                _taxIncreased[from] = true;
                _takeBothTax = true;
            }
        }
        
        bool takeFee;
        
        if(_enableFee && (_isIncludedInFee[from] || _isIncludedInFee[to])){
            takeFee = true;
            _swapAndLiquify(from);
        } else {
            takeFee = false;
        }
        
        _tokenTransfer(from,to,amount,takeFee);

        if(from != uniswapV2Pair) {
            _transactionAmount[from] = _transactionAmount[from].add(amount); 
        }
        if(_taxIncreased[from]){
            restoreAllLowerFee();
        }
        _taxIncreased[from] = false;
        _takeBothTax = false;
       
        updateReward(from);
        updateReward(to);
    }

    function updateReward(address account) internal {

        if(balanceOf(account) >= rewardLimit) {
            if(_isExcluded[account]) includeInReward(account);
        } else {
            if(!_isExcluded[account]) excludeFromReward(account);
        }
    }

    function checkTimeBound(address from, uint256 currentTime) internal {      

        if((currentTime - _transactionTime[from]) > _perDayTimeBound ){
            _transactionTime[from] = currentTime;
            _transactionAmount[from] = 0;
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance, address account) internal lockTheSwap {

        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);

        uint256 initialBalance = address(this).balance;

        swapTokensForEth(half, address(this)); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        uint256 newBalance = address(this).balance.sub(initialBalance);

        addLiquidity(otherHalf, newBalance, account);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount, address swapAddress) internal {

        bool initialFeeState = _enableFee;
        if(initialFeeState) _enableFee = false;

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

        if(initialFeeState) _enableFee = true;
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount, address account) internal {

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            account,
            block.timestamp
        );
    }

    function transferToFeeWallet(address account, uint256 amount) internal {

        _marketingFeeBalance = 0;
        swapTokensForEth(amount, account);
        if(marketing_address_index == marketing_address.length - 1) {
            marketing_address_index = 0;
        } else {
            marketing_address_index += 1;
        }
    }

    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) internal {

        if(!takeFee || (sender != uniswapV2Pair && recipient != uniswapV2Pair))
            removeAllFee();
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }
        
        if(!takeFee)
            restoreAllFee();
    }
    
    function _swapAndLiquify(address from) internal {

        if(_marketingFeeBalance >= maxTokensToSell && from != uniswapV2Pair) {
            transferToFeeWallet(marketing_address[marketing_address_index], _marketingFeeBalance);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        
        bool overMinTokenBalance = contractTokenBalance >= numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            from != uniswapV2Pair &&
            swapAndLiquifyEnabled
        ) {
            contractTokenBalance = numTokensSellToAddToLiquidity;
            swapAndLiquify(contractTokenBalance, owner());
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) internal {


        Amount memory _tAmount;

        if(_takeBothTax) {
            uint256 pastAmount = _transactionAmount[sender];
            uint256 remainingTxLimit = transactionLimit.sub(pastAmount);
            uint256 remainingtAmount = tAmount.sub(remainingTxLimit);

            address receiver = recipient;
            (_tAmount.tTransferAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee) = _getTValues(remainingTxLimit, receiver);
            (_tAmount.rAmount, _tAmount.rTransferAmount, _tAmount.rFee) = _getRValues(remainingTxLimit, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee, receiver);

            afterLimitFee();
            address receiv = recipient;
            (uint256 h_tTransferAmount, uint256 h_tFee, uint256 h_tLiquidity, uint256 h_tBurn, uint256 h_tMarketingFee) = _getTValues(remainingtAmount, receiv);
            (uint256 h_rAmount, uint256 h_rTransferAmount, uint256 h_rFee) = _getRValues(remainingtAmount, h_tFee, h_tLiquidity, h_tBurn, h_tMarketingFee, receiv);

            _tAmount.tTransferAmount += h_tTransferAmount;
            _tAmount.tFee += h_tFee;
            _tAmount.tLiquidity += h_tLiquidity;
            _tAmount.tBurn += h_tBurn;
            _tAmount.tMarketingFee += h_tMarketingFee;
            _tAmount.rAmount += h_rAmount;
            _tAmount.rTransferAmount += h_rTransferAmount;
            _tAmount.rFee += h_rFee;
        } else {
            address receiver = recipient;
            (_tAmount.tTransferAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee) = _getTValues(tAmount, receiver);
            (_tAmount.rAmount, _tAmount.rTransferAmount, _tAmount.rFee) = _getRValues(tAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee, receiver);
        }

        _rOwned[sender] = _rOwned[sender].sub(_tAmount.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_tAmount.rTransferAmount);
        _takeLiquidity(_tAmount.tLiquidity);
        _reflectFee(_tAmount.rFee, _tAmount.tFee);
        _takeMarketingFee(_tAmount.tMarketingFee);
        if(_tAmount.tBurn > 0) {
            _amount_burnt += _tAmount.tBurn;
            emit Transfer(sender, address(0), _tAmount.tBurn);
        }
        emit Transfer(sender, recipient, _tAmount.tTransferAmount);
    }
    
    function _transferBothExcluded(address sender, address recipient, uint256 tAmount) internal {

        Amount memory _tAmount;

        if(_takeBothTax) {
            uint256 pastAmount = _transactionAmount[sender];
            uint256 remainingTxLimit = transactionLimit.sub(pastAmount);
            uint256 remainingtAmount = tAmount.sub(remainingTxLimit);

            address receiver = recipient;
            (_tAmount.tTransferAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee) = _getTValues(remainingTxLimit, receiver);
            (_tAmount.rAmount, _tAmount.rTransferAmount, _tAmount.rFee) = _getRValues(remainingTxLimit, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee, receiver);

            afterLimitFee();
            address receiv = recipient;
            (uint256 h_tTransferAmount, uint256 h_tFee, uint256 h_tLiquidity, uint256 h_tBurn, uint256 h_tMarketingFee) = _getTValues(remainingtAmount, receiv);
            (uint256 h_rAmount, uint256 h_rTransferAmount, uint256 h_rFee) = _getRValues(remainingtAmount, h_tFee, h_tLiquidity, h_tBurn, h_tMarketingFee, receiv);

            _tAmount.tTransferAmount += h_tTransferAmount;
            _tAmount.tFee += h_tFee;
            _tAmount.tLiquidity += h_tLiquidity;
            _tAmount.tBurn += h_tBurn;
            _tAmount.tMarketingFee += h_tMarketingFee;
            _tAmount.rAmount += h_rAmount;
            _tAmount.rTransferAmount += h_rTransferAmount;
            _tAmount.rFee += h_rFee;
        } else {
            address receiver = recipient;
            (_tAmount.tTransferAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee) = _getTValues(tAmount, receiver);
            (_tAmount.rAmount, _tAmount.rTransferAmount, _tAmount.rFee) = _getRValues(tAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee, receiver);
        }

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_tAmount.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(_tAmount.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_tAmount.rTransferAmount);        
        _takeLiquidity(_tAmount.tLiquidity);
        _reflectFee(_tAmount.rFee, _tAmount.tFee);
        _takeMarketingFee(_tAmount.tMarketingFee);
        if(_tAmount.tBurn > 0) {
            _amount_burnt += _tAmount.tBurn;
            emit Transfer(sender, address(0), _tAmount.tBurn);
        }
        emit Transfer(sender, recipient, _tAmount.tTransferAmount);
    }
    
    function _transferToExcluded(address sender, address recipient, uint256 tAmount) internal {

        Amount memory _tAmount;

        if(_takeBothTax) {
            uint256 pastAmount = _transactionAmount[sender];
            uint256 remainingTxLimit = transactionLimit.sub(pastAmount);
            uint256 remainingtAmount = tAmount.sub(remainingTxLimit);

            address receiver = recipient;
            (_tAmount.tTransferAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee) = _getTValues(remainingTxLimit, receiver);
            (_tAmount.rAmount, _tAmount.rTransferAmount, _tAmount.rFee) = _getRValues(remainingTxLimit, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee, receiver);

            afterLimitFee();
            address receiv = recipient;
            (uint256 h_tTransferAmount, uint256 h_tFee, uint256 h_tLiquidity, uint256 h_tBurn, uint256 h_tMarketingFee) = _getTValues(remainingtAmount, receiv);
            (uint256 h_rAmount, uint256 h_rTransferAmount, uint256 h_rFee) = _getRValues(remainingtAmount, h_tFee, h_tLiquidity, h_tBurn, h_tMarketingFee, receiv);

            _tAmount.tTransferAmount += h_tTransferAmount;
            _tAmount.tFee += h_tFee;
            _tAmount.tLiquidity += h_tLiquidity;
            _tAmount.tBurn += h_tBurn;
            _tAmount.tMarketingFee += h_tMarketingFee;
            _tAmount.rAmount += h_rAmount;
            _tAmount.rTransferAmount += h_rTransferAmount;
            _tAmount.rFee += h_rFee;
        } else {
            address receiver = recipient;
            (_tAmount.tTransferAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee) = _getTValues(tAmount, receiver);
            (_tAmount.rAmount, _tAmount.rTransferAmount, _tAmount.rFee) = _getRValues(tAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee, receiver);
        }

        _rOwned[sender] = _rOwned[sender].sub(_tAmount.rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(_tAmount.tTransferAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_tAmount.rTransferAmount);           
        _takeLiquidity(_tAmount.tLiquidity);
        _reflectFee(_tAmount.rFee, _tAmount.tFee);
        _takeMarketingFee(_tAmount.tMarketingFee);
        if(_tAmount.tBurn > 0) {
            _amount_burnt += _tAmount.tBurn;
            emit Transfer(sender, address(0), _tAmount.tBurn);
        }
        emit Transfer(sender, recipient, _tAmount.tTransferAmount);
    }

    function _transferFromExcluded(address sender, address recipient, uint256 tAmount) internal {

        Amount memory _tAmount;

        if(_takeBothTax) {
            uint256 pastAmount = _transactionAmount[sender];
            uint256 remainingTxLimit = transactionLimit.sub(pastAmount);
            uint256 remainingtAmount = tAmount.sub(remainingTxLimit);

            address receiver = recipient;
            (_tAmount.tTransferAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee) = _getTValues(remainingTxLimit, receiver);
            (_tAmount.rAmount, _tAmount.rTransferAmount, _tAmount.rFee) = _getRValues(remainingTxLimit, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee, receiver);

            afterLimitFee();
            address receiv = recipient;
            (uint256 h_tTransferAmount, uint256 h_tFee, uint256 h_tLiquidity, uint256 h_tBurn, uint256 h_tMarketingFee) = _getTValues(remainingtAmount, receiv);
            (uint256 h_rAmount, uint256 h_rTransferAmount, uint256 h_rFee) = _getRValues(remainingtAmount, h_tFee, h_tLiquidity, h_tBurn, h_tMarketingFee, receiv);

            _tAmount.tTransferAmount += h_tTransferAmount;
            _tAmount.tFee += h_tFee;
            _tAmount.tLiquidity += h_tLiquidity;
            _tAmount.tBurn += h_tBurn;
            _tAmount.tMarketingFee += h_tMarketingFee;
            _tAmount.rAmount += h_rAmount;
            _tAmount.rTransferAmount += h_rTransferAmount;
            _tAmount.rFee += h_rFee;
        } else {
            address receiver = recipient;
            (_tAmount.tTransferAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee) = _getTValues(tAmount, receiver);
            (_tAmount.rAmount, _tAmount.rTransferAmount, _tAmount.rFee) = _getRValues(tAmount, _tAmount.tFee, _tAmount.tLiquidity, _tAmount.tBurn, _tAmount.tMarketingFee, receiver);
        }

        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(_tAmount.rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(_tAmount.rTransferAmount);   
        _takeLiquidity(_tAmount.tLiquidity);
        _reflectFee(_tAmount.rFee, _tAmount.tFee);
        _takeMarketingFee(_tAmount.tMarketingFee);
        if(_tAmount.tBurn > 0) {
            _amount_burnt += _tAmount.tBurn;
            emit Transfer(sender, address(0), _tAmount.tBurn);
        }
        emit Transfer(sender, recipient, _tAmount.tTransferAmount);
    }
    
    
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(from != SUPPLY_HOLDER, "ERC20: transfer from the supply address");
        require(to != SUPPLY_HOLDER, "ERC20: transfer to the supply address");

        require(!paused(), "ERC20Pausable: token transfer while contract paused");
        require(!pausedAddress[from], "ERC20Pausable: token transfer while from-address paused");
        require(!pausedAddress[to], "ERC20Pausable: token transfer while to-address paused");
    }

    function addLiquidityFromPlatform(uint256 tokenAmount) external virtual {

        require(tokenAmount > 0, "Amount must be greater than zero");
        bool initialFeeState = _enableFee;
        if(initialFeeState) _enableFee = false;

        _approve(msg.sender, address(this), tokenAmount);
        _transfer(msg.sender, address(this), tokenAmount);

        swapAndLiquify(tokenAmount, msg.sender);

        if(initialFeeState) _enableFee = true;
    }

    function removeLiquidityFromPlatform(uint256 liquidity) external virtual {

        require(liquidity > 0, "Amount must be greater than zero");
        bool initialFeeState = _enableFee;
        if(initialFeeState) _enableFee = false;

        bool isTransfered = IUniswapV2Pair(uniswapV2Pair).transferFrom(msg.sender, address(this), liquidity);
        require(isTransfered == true, "UniswapPair: transferFrom failed");

        bool isApproved = IUniswapV2Pair(uniswapV2Pair).approve(UNISWAPV2ROUTER, liquidity);
        require(isApproved == true, "UniswapPair: approve failed");

        uniswapV2Router.removeLiquidity(
            address(this),
            uniswapV2Router.WETH(),
            liquidity,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            msg.sender,
            block.timestamp
        );

        if(initialFeeState) _enableFee = true;
    }
}