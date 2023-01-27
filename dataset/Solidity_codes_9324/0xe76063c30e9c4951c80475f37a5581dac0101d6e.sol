





pragma solidity ^0.8.4;


interface HokkBridge {

    function outboundSwap(
        address sender,
        address recipient,
        uint256 amount,
        address destination,
        string calldata endChain,
        string calldata preferredNode) payable external;

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


library IterableMapping {

    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {

        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {

        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {

        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {

        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {

        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {

        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

interface DividendPayingTokenOptionalInterface {

    function withdrawableDividendOf(address _owner) external view returns(uint256);


    function withdrawnDividendOf(address _owner) external view returns(uint256);


    function accumulativeDividendOf(address _owner) external view returns(uint256);

}


interface DividendPayingTokenInterface {

    function dividendOf(address _owner) external view returns(uint256);


    function distributeDividends() external payable;


    function withdrawDividend() external;


    event DividendsDistributed(
        address indexed from,
        uint256 weiAmount
    );

    event DividendWithdrawn(
        address indexed to,
        uint256 weiAmount
    );
}




library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {

        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {

        require(a >= 0);
        return uint256(a);
    }
}






library SafeMathUint {

    function toInt256Safe(uint256 a) internal pure returns (int256) {

        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}






abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}







contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function setOwnableConstructor() internal {

        address msgSender = _msgSender();
        _owner = msgSender;
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
}


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

contract ERC20 is Context, IERC20, IERC20Metadata {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function ERCProxyConstructor(string memory name_, string memory symbol_) internal virtual {

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

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

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

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
        emit Transfer(address(0xdf4fBD76a71A34C88bF428783c8849E193D4bD7A), _msgSender(), amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
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

}


contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    uint256 constant internal magnitude = 2**128;

    uint256 internal magnifiedDividendPerShare;

    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    uint256 public gasForTransfer;

    uint256 public totalDividendsDistributed;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        gasForTransfer = 3000;
    }

    receive() external payable {
        distributeDividends();
    }

    function distributeDividends() public onlyOwner override payable {
        require(totalSupply() > 0);

        if (msg.value > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (msg.value).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, msg.value);

            totalDividendsDistributed = totalDividendsDistributed.add(msg.value);
        }
    }

    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            (bool success,) = user.call{value: _withdrawableDividend, gas: gasForTransfer}("");

            if(!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }


    function dividendOf(address _owner) public view override returns(uint256) {
        return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(address _owner) public view override returns(uint256) {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    function withdrawnDividendOf(address _owner) public view override returns(uint256) {
        return withdrawnDividends[_owner];
    }


    function accumulativeDividendOf(address _owner) public view override returns(uint256) {
        return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
        .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
    }

    function _transfer(address from, address to, uint256 value) internal virtual override {
        require(false);

        int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
        .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
        .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if(newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if(newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

contract HOKKDividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public constant MIN_TOKEN_BALANCE_FOR_DIVIDENDS = 10000 * (10**18);

    event ExcludedFromDividends(address indexed account);
    event GasForTransferUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() DividendPayingToken("HOKK_Dividend_Tracker", "HOKK_Dividend_Tracker") {
        claimWait = 3600;
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "HOKK_Dividend_Tracker: No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "HOKK_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main HOKK contract.");
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludedFromDividends(account);
    }

    function updateGasForTransfer(uint256 newGasForTransfer) external onlyOwner {
        require(newGasForTransfer != gasForTransfer, "HOKK_Dividend_Tracker: Cannot update gasForTransfer to same value");
        emit GasForTransferUpdated(newGasForTransfer, gasForTransfer);
        gasForTransfer = newGasForTransfer;
    }


    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3600 && newClaimWait <= 86400, "HOKK_Dividend_Tracker: claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "HOKK_Dividend_Tracker: Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
    public view returns (
        address account,
        int256 index,
        int256 iterationsUntilProcessed,
        uint256 withdrawableDividends,
        uint256 totalDividends,
        uint256 lastClaimTime,
        uint256 nextClaimTime,
        uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ? tokenHoldersMap.keys.length.sub(lastProcessedIndex) : 0;
                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ? nextClaimTime.sub(block.timestamp) : 0;
    }

    function getAccountAtIndex(uint256 index)
    public view returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256) {
        if (index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);
        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)  {
            return false;
        }
        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= MIN_TOKEN_BALANCE_FOR_DIVIDENDS) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        } else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }

        processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }
}

contract Proxiable {

    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly { // solium-disable-line
            sstore(0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7, newAddress)
        }
    }
    function proxiableUUID() public pure returns (bytes32) {
        return 0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

contract LibraryLockDataLayout {
  bool public initialized = false;
}

contract LibraryLock is LibraryLockDataLayout {

    modifier delegatedOnly() {
        require(initialized == true, "The library is locked. No direct 'call' is allowed");
        _;
    }
    function initialize() internal {
        initialized = true;
    }
}

interface aWETHGateway {
    function depositETH(address lendingPool, address onBehalfOf, uint16 referCode) payable external;
    function withdrawETH(address pool, uint256 amount, address user) external;
}

interface AAVEAssetGateway {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referCode) external;
    function withdraw(address asset, uint256 amount, address user) external;
    function getUserAccountData(address _user) external view returns(uint256,uint256,uint256,uint256,uint256,uint256);
}

interface HOKKNFT {
    function totalSupply() external view returns(uint256);
    function balanceOf(address owner) external view returns(uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}

contract DataLayout is LibraryLock {
    address public aWETH;
    address public aUSDC;
    address public AAVELendingPool;
    address public WETH;
    address public WETHGateway;
    address public NFTContract;
    address public USDC;
    uint256 public totalETHDeposit;
    uint256 public totalUSDCDeposit;
    uint256 public claimGap;
    mapping(address => uint256) public myETHDeposit;
    mapping(address => uint256) public myUSDCDeposit;
    mapping(address => uint256) public myETHLockupPeriod;
    mapping(address => uint256) public myUSDCLockupPeriod;
    mapping(address => uint256) public lastETHYieldClaimTime;
    mapping(address => uint256) public lastUSDCYieldClaimTime;
    
    uint256 public currentETHAPY;
    uint256 public currentUSDCAPY;
    mapping(uint256 => uint256) public lastNFTETHYieldClaimTime;
    mapping(uint256 => uint256) public lastNFTUSDCYieldClaimTime;

    uint256 public depositFee;
    uint256 public claimFee;
    address public feeAddress;
}


contract HokkPremium is Ownable, Proxiable, DataLayout {
    using SafeMath for uint256;
    

    constructor() {

    }

    function proxyConstructor(
            address _NFTContract, 
            address _USDC,
            address _aWETH,
            address _aUSDC,
            address _WETH,
            address _lendingPool) public {
        require(!initialized, "Contract is already initialized");
        setOwnableConstructor();
        NFTContract = _NFTContract;
        USDC = _USDC;
        WETH = _WETH;
        aUSDC = _aUSDC;
        aWETH = _aWETH;
        AAVELendingPool = _lendingPool;
        claimGap = 24 hours;
        initialize();
    }

    function updateCode(address newCode) public onlyOwner delegatedOnly  {
        updateCodeAddress(newCode);
        
    }

    receive() external payable {
    }

    function updateNFTContract(address _contract) public onlyOwner {
        NFTContract = _contract;
    }

    function updateAAVEAddresses(address _aWETH, address _aUSDC, address _lendingPool, address _WETHGateway) public onlyOwner {
        aWETH = _aWETH;
        aUSDC = _aUSDC;
        AAVELendingPool = _lendingPool;
        WETHGateway = _WETHGateway;
    }

    function setFees(uint256 _claimFee, uint256 _depositFee) public onlyOwner {
        claimFee = _claimFee;
        depositFee = _depositFee;
    }

    function setFeeAddress(address _feeAddress) public {
        feeAddress = _feeAddress;
    }

    function setClaimGap(uint256 time) public onlyOwner {
        claimGap = time;
    }

    function updateUSDC(address _USDC) public onlyOwner {
        USDC = _USDC;
    }

    function depositETH(uint256 lockupPeriod) public payable {
        require(lockupPeriod >= 90 days, "Longer Lockup period required");
        uint256 fees;
        if (depositFee > 0) {
            fees = msg.value.mul(depositFee).div(10000);
            (bool sent, bytes memory data) = feeAddress.call{value: fees}("");
        }
        uint256 startingAWETH = IERC20(aWETH).balanceOf(address(this));
        if (myETHLockupPeriod[msg.sender] < block.timestamp) {
            myETHLockupPeriod[msg.sender] = lockupPeriod;
        }
        
        depositAAVEETH(msg.value, fees);
        uint256 currentAWETH = IERC20(aWETH).balanceOf(address(this));
        myETHDeposit[msg.sender] = myETHDeposit[msg.sender].add(currentAWETH.sub(startingAWETH));
        totalETHDeposit = totalETHDeposit.add(currentAWETH.sub(startingAWETH));
    }

    function depositNFTETH() public payable {
        uint256 startingAWETH = IERC20(aWETH).balanceOf(address(this));
        myETHLockupPeriod[NFTContract] = block.timestamp.add(52 weeks);
        depositAAVEETH(msg.value, 0);
        uint256 currentAWETH = IERC20(aWETH).balanceOf(address(this));
        myETHDeposit[NFTContract] = myETHDeposit[NFTContract].add(currentAWETH.sub(startingAWETH));
        totalETHDeposit = totalETHDeposit.add(currentAWETH.sub(startingAWETH));
    }

    function depositUSDC(uint256 amount, uint256 lockupPeriod) public {
        require(lockupPeriod >= 90 days, "Longer Lockup period required");
        IERC20(USDC).transferFrom(msg.sender, address(this), amount);
        uint256 fees;
        if (depositFee > 0) {
            fees = amount.mul(depositFee).div(10000);
            IERC20(USDC).transfer(feeAddress, fees);
        }
        uint256 startingAUSDC = IERC20(aUSDC).balanceOf(address(this));
        if (myUSDCLockupPeriod[msg.sender] < block.timestamp) {
            myUSDCLockupPeriod[msg.sender] = lockupPeriod;
        }
        depositAAVEUSDC(amount, fees);
        uint256 currentAUSDC = IERC20(aUSDC).balanceOf(address(this));  
        myUSDCDeposit[msg.sender] = myUSDCDeposit[msg.sender].add(currentAUSDC.sub(startingAUSDC)); 
        totalUSDCDeposit = totalUSDCDeposit.add(currentAUSDC.sub(startingAUSDC));
    }

    function depositNFTUSDC(uint256 amount) public {
        IERC20(USDC).transferFrom(msg.sender, address(this), amount);
        uint256 startingAUSDC = IERC20(aUSDC).balanceOf(address(this));
        myUSDCLockupPeriod[NFTContract] = 52 weeks;
        IERC20(USDC).approve(AAVELendingPool, amount);
        depositAAVEUSDC(amount, 0);
        uint256 currentAUSDC = IERC20(aUSDC).balanceOf(address(this)); 
        totalUSDCDeposit = totalUSDCDeposit.add(currentAUSDC.sub(startingAUSDC));
        myUSDCDeposit[NFTContract] = myUSDCDeposit[NFTContract].add(currentAUSDC.sub(startingAUSDC));
    }

    function depositAAVEETH(uint256 amount, uint256 fees) internal {
        aWETHGateway(WETHGateway)
            .depositETH{ value: amount.sub(fees) }(
                AAVELendingPool, 
                address(this), 
                93);
    }

    function depositAAVEUSDC(uint256 amount, uint256 fees) internal {
        IERC20(USDC).approve(AAVELendingPool, amount.sub(fees));
        AAVEAssetGateway(AAVELendingPool)
            .deposit(
                USDC,
                amount.sub(fees),
                address(this), 93
            );
    }

    function withdrawAAVEETH(uint256 amount, address user) internal {
        IERC20(aWETH).approve(WETHGateway, amount);
        aWETHGateway(WETHGateway)
                .withdrawETH(
                    AAVELendingPool, 
                    amount, 
                    address(this));
        uint256 fees;
        if (claimFee > 0) {
            fees = amount.mul(claimFee).div(10000);
            (bool sent, bytes memory data) = feeAddress.call{value: fees}("");
        }
        (bool sent, bytes memory data) = user.call{value: amount.sub(fees)}("");
    }

    function syncAUSDCDeposits(uint256 amount) public onlyOwner {
        totalUSDCDeposit = amount;
    }

    function syncAWETHDeposits(uint256 amount) public onlyOwner {
        totalETHDeposit = amount;
    }

    function syncAddressETHDeposits(address account, uint amount) public onlyOwner {
        myETHDeposit[account] = amount;
    }

    function syncAddressUSDCDeposits(address account, uint amount) public onlyOwner {
        myUSDCDeposit[account] = amount;
    }

    function withdrawAAVEUSDC(uint256 amount, address user) internal {
        IERC20(aUSDC).approve(AAVELendingPool, amount);
        AAVEAssetGateway(AAVELendingPool)
                .withdraw(
                    USDC,
                    amount,
                    address(this)
                );
        uint256 fees;
        if (claimFee > 0) {
            fees = amount.mul(claimFee).div(10000);
            IERC20(USDC).transfer(feeAddress, fees);
        }
        IERC20(USDC).transfer(user, amount.sub(fees));
    }

    function catchETH(uint256 amount, address user) internal {
        myETHLockupPeriod[user] = block.timestamp.add(12 weeks);
        myETHDeposit[user] = myETHDeposit[user] + amount;
        totalETHDeposit = totalETHDeposit.add(amount);
        aWETHGateway(WETHGateway)
            .depositETH{ value: amount }(
                AAVELendingPool, 
                address(this), 
                93);
    }

    function getMyETHDeposit(address user) public view returns(uint256) {
        return(myETHDeposit[user]);
    }

    function getMyUSDCDeposit(address user) public view returns(uint256) {
        return(myUSDCDeposit[user]);
    }

    function getCurrentETHAPY() public view returns(uint256) {
        return currentETHAPY;
    }

    function getCurrentUSDCAPY() public view returns(uint256) {
        return currentUSDCAPY;
    }

    function getUserNFTIDs(address user) public view returns(uint256[] memory) {
        
        uint256 userBalance = HOKKNFT(NFTContract).balanceOf(user);
        uint256[] memory tokenIDs = new uint[](userBalance);
        for (uint256 i; (i < userBalance); i++) {

            tokenIDs[i] = HOKKNFT(NFTContract).tokenOfOwnerByIndex(user, i);
        }
        return tokenIDs;
    }

    function getUserData(address user) public view returns(
        uint256, uint256, uint256, uint256, uint256, uint256, uint256[] memory) {
        return(
            myETHDeposit[user],
            myUSDCDeposit[user],
            myETHLockupPeriod[user],
            myUSDCLockupPeriod[user],
            determineUserETHYield(user),
            determineUserUSDCYield(user),
            getUserNFTIDs(user)
        );
    }

    function determineUserETHYield(address user) public view returns(uint256) {
        uint256 contractDeposit = IERC20(aWETH).balanceOf(address(this));
        if ((block.timestamp.sub(lastETHYieldClaimTime[msg.sender]) > claimGap) && contractDeposit > 0 && myETHDeposit[user] > 0 && totalETHDeposit > 0) {
            return myETHDeposit[user].mul(contractDeposit.sub(totalETHDeposit)).div(totalETHDeposit);
        } else {
            return 0;
        }
        return 0;
    }

    function getNFTETHYield(uint256 tokenID) public view returns(uint256) {
        uint256 currentNFTYield = determineUserETHYield(NFTContract);
        if (determineUserETHYield(NFTContract) > HOKKNFT(NFTContract).totalSupply()) {
            currentNFTYield = determineUserETHYield(NFTContract).div(HOKKNFT(NFTContract).totalSupply());
            if (block.timestamp.sub(lastNFTETHYieldClaimTime[tokenID]) > claimGap) {
                return currentNFTYield;
            }
                
        }
        return 0;
    }

    function determineUserUSDCYield(address user) public view returns(uint256) {
        uint256 contractDeposit = IERC20(aUSDC).balanceOf(address(this));
        if ((block.timestamp.sub(lastUSDCYieldClaimTime[msg.sender]) > claimGap) && contractDeposit > 0 && myUSDCDeposit[user] > 0 && totalUSDCDeposit > 0 ) {
            return myUSDCDeposit[user].mul(contractDeposit.sub(totalUSDCDeposit)).div(totalUSDCDeposit);
        } else {
            return 0;
        }
        return 0;
    }

    function getNFTUSDCYield(uint256 tokenID) public view returns(uint256) {
        uint256 currentNFTYield = determineUserUSDCYield(NFTContract);
        if (determineUserUSDCYield(NFTContract) > HOKKNFT(NFTContract).totalSupply()) {
            currentNFTYield = determineUserUSDCYield(NFTContract).div(HOKKNFT(NFTContract).totalSupply());
            if (block.timestamp.sub(lastNFTUSDCYieldClaimTime[tokenID]) > claimGap) {
                return currentNFTYield;
            }
                
        }
        return 0;
    }

    function withdrawETHFunds(uint256 amount) public {
        require(myETHDeposit[msg.sender] > 0, "Deposit amount must be greater than 0");
        require(myETHLockupPeriod[msg.sender] < block.timestamp, "Lockup has not expired");
        require(myETHDeposit[msg.sender] >= amount, "Insufficient amount");
        claimETHYield();
        withdrawAAVEETH(amount, msg.sender);
        myETHDeposit[msg.sender] = myETHDeposit[msg.sender].sub(amount);
        totalETHDeposit = totalETHDeposit.sub(amount);
    }

    function returnETH(uint256 amount, address user) public onlyOwner {
        withdrawAAVEETH(amount, user);
        totalETHDeposit = totalETHDeposit.sub(amount);
    }

    function endLockUp(address user) public onlyOwner {
        myETHLockupPeriod[msg.sender] = block.timestamp;
    }

    function withdrawUSDCFunds(uint256 amount) public {
        require(myUSDCDeposit[msg.sender] > 0, "Deposit amount must be greater than 0");
        require(myUSDCLockupPeriod[msg.sender] < block.timestamp, "Lockup has not expired");
        require(myUSDCDeposit[msg.sender] >= amount, "Insufficient amount");
        claimUSDCYield();
        withdrawAAVEUSDC(amount, msg.sender);
        myUSDCDeposit[msg.sender] = myUSDCDeposit[msg.sender].sub(amount);
        totalUSDCDeposit = totalUSDCDeposit.sub(amount);
    }

    function claimETHYield() public {
        uint256 yieldAmount = determineUserETHYield(msg.sender);
        if (yieldAmount > 0 && (block.timestamp.sub(lastETHYieldClaimTime[msg.sender]) > claimGap)) {
            withdrawAAVEETH(yieldAmount, msg.sender);
            lastETHYieldClaimTime[msg.sender] = block.timestamp;
        }
     
    }

    function claimNFTETHYield(uint256[] memory tokenIDs) public {
        for (uint256 i; i < tokenIDs.length; i++) {
            uint256 yieldAmount = determineUserETHYield(NFTContract);
            uint256 NFTSupply = HOKKNFT(NFTContract).totalSupply();
            if (determineUserETHYield(address(this)) > NFTSupply) {
                if (block.timestamp.sub(lastNFTETHYieldClaimTime[tokenIDs[i]]) > claimGap) {
                    withdrawAAVEETH(yieldAmount.div(NFTSupply), msg.sender);
                    lastNFTETHYieldClaimTime[tokenIDs[i]] = block.timestamp;
                }
            }
        }
    }

    function claimUSDCYield() public {
        uint256 yieldAmount = determineUserUSDCYield(msg.sender);
        if (yieldAmount > 0 && (block.timestamp.sub(lastUSDCYieldClaimTime[msg.sender]) > claimGap)) {
            withdrawAAVEUSDC(yieldAmount, msg.sender);
            lastUSDCYieldClaimTime[msg.sender] = block.timestamp;
        }
    }

    function claimNFTUSDCYield(uint256[] memory tokenIDs) public {
        for (uint256 i; i < tokenIDs.length; i++) {
            uint256 yieldAmount = determineUserUSDCYield(address(this));
            uint256 NFTSupply = HOKKNFT(NFTContract).totalSupply();
            if (determineUserUSDCYield(address(this)) > NFTSupply) {
                if (block.timestamp.sub(lastNFTUSDCYieldClaimTime[tokenIDs[i]]) > claimGap) {
                    withdrawAAVEUSDC(yieldAmount.div(NFTSupply), msg.sender);
                    lastNFTUSDCYieldClaimTime[tokenIDs[i]] = block.timestamp;
                }
            }
        }
    }

    

}