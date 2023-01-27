
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
}// MIT

pragma solidity ^0.8.0;


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
        emit Transfer(address(0), account, amount);
    }
    function burn(uint256 amount) external virtual{

        _burn(msg.sender,amount);
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

}pragma solidity ^0.8.0;



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

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.8.0;

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0,"Negative number is not allowed");
    return b;
  }
}// MIT


pragma solidity ^0.8.0;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256),"multplitiy error");
        require((b == 0) || (c / b == a),"multiplity error mul");
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256,"SafeMath error div");

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a),"SafeMath error sub");
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a),"SafeMath error add");
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256,"SafeMath error abs");
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0,"SafeMath toUint error");
        return uint256(a);
    }
}// MIT

pragma solidity ^0.8.0;


interface IDividendPayingToken {
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
}// MIT

pragma solidity ^0.8.0;


interface IDividendPayingTokenOptional {
  function withdrawableDividendOf(address _owner) external view returns(uint256);

  function withdrawnDividendOf(address _owner) external view returns(uint256);

  function accumulativeDividendOf(address _owner) external view returns(uint256);
}// MIT

pragma solidity ^0.8.0;


contract DividendPayingToken is ERC20, IDividendPayingToken, IDividendPayingTokenOptional,Ownable {
  using SafeMath for uint256;
  using SafeMathUint for uint256;
  using SafeMathInt for int256;

  uint256 constant internal magnitude = 2**128;
  uint256 internal magnifiedDividendPerShare;
  uint256 internal lastAmount;
  uint256 public totalDividendsDistributed;
  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;

  

  constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol){
  }

  receive() external payable {
    distributeDividends();
  }

  function distributeDividends() public override payable {
    require(totalSupply() > 0,"dividened totalsupply error");
    if (msg.value > 0) {
       uint256 _magnifiedShare = magnifiedDividendPerShare.add(
        (msg.value).mul(magnitude) / totalSupply());
      magnifiedDividendPerShare = _magnifiedShare;
      emit DividendsDistributed(msg.sender, msg.value);
      uint256 _totalDistributed = totalDividendsDistributed.add(msg.value);
      totalDividendsDistributed = _totalDistributed;
    }
  }

  function withdrawDividend() public virtual override {
    _withdrawDividendOfUser(payable(msg.sender));
  }

  function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
    uint256 _withdrawableDividend = withdrawableDividendOf(user);
    if (_withdrawableDividend > 0) {
      uint256 _withdrawnAmount = withdrawnDividends[user].add(_withdrawableDividend);
      (bool success,) = user.call{value: _withdrawableDividend, gas:3000}("");
      if(!success) {
        return 0;
      }
      withdrawnDividends[user] = _withdrawnAmount;
      return _withdrawableDividend;
    }
    return 0;
  }
  
  function dividendOf(address _owner) public view override returns(uint256) {
    uint256 _dividend = withdrawableDividendOf(_owner);
    return _dividend;
  }

  function withdrawableDividendOf(address _owner) public view override returns(uint256) {
    uint256 _withdrawable = accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    return _withdrawable;
  }

  function withdrawnDividendOf(address _owner) public view override returns(uint256) {
    uint256 _withdrawn = withdrawnDividends[_owner];
    return _withdrawn;
  }

  function accumulativeDividendOf(address _owner) public view override returns(uint256) {
    uint256 _accumulative = magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
      .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
    return _accumulative;
  }

  function _transfer(address,address,uint256) internal virtual override {
    require(false,"transfer inallowed");
  }


  function _mint(address account, uint256 value) internal override {
    super._mint(account, value);
    int256 _correction = magnifiedDividendCorrections[account]
      .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    magnifiedDividendCorrections[account] = _correction;
  }

  function _burn(address account, uint256 value) internal override {
    super._burn(account, value);
    int256 _correction = magnifiedDividendCorrections[account]
      .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    magnifiedDividendCorrections[account] = _correction;
  }

  function burn(uint256) external virtual override{
    require(false,"burning unallowed");  
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
}// MIT
pragma solidity ^0.8.0;

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
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

pragma solidity ^0.8.0;
interface ITracker{
    function claimWait() external view returns(uint256);
    function owner() external view returns (address);
    function isExcludedFromDividends(address account) external view returns(bool);
    function totalDividendsDistributed() external view returns(uint256);
    function withdrawableDividendOf(address account) external view returns(uint256);
    function getLastProcessedIndex() external view returns(uint256);
    function getNumberOfTokenHolders() external view returns(uint256);
    function getAccount(address _account)
        external view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable);
    function getAccountAtIndex(uint256 _index)
        external view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable);
    function excludeFromDividends(address account, bool exclude) external;
    function updateClaimWait(uint256 newClaimWait) external;
    function updateMinimumForDividends(uint256 amount) external;
    function setBalance(address payable account, uint256 newBalance) external;
    function process(uint256 gas) external returns (uint256, uint256, uint256);
    function processAccount(address payable account) external;
}// MIT
pragma solidity ^0.8.0;


contract Dawn is ERC20, Ownable {
    using SafeMath for uint256;
    uint256 public constant BASE = 10**18;
    uint256 public constant MAX_BUY_TX_AMOUNT = 500_000 * BASE; //0.5%
    uint256 public constant REWARDS_FEE = 7;
    uint256 public constant DEV_FEE = 7;
    uint256 public constant PENALTY_FEE = 15;
    uint256 public constant TOTAL_FEES = REWARDS_FEE + DEV_FEE;
    uint256 public accumulatedPenalty;
    uint256 public buyLimitTimestamp; // buy limit for the first 5 minutes after trading activation
    uint256 public sellTaxPenaltyTimestamp; // sell extra fee of 15%
    uint256 public gasForProcessing = 150_000; // processing auto-claiming dividends
    uint256 public liquidateTokensAtAmount = 10_000 * BASE; //0.01
    ITracker public dividendTracker;
    IUniswapV2Router02 public uniswapV2Router;

    address public uniswapV2Pair;
    address public constant DEAD_ADDRESS =
        0x000000000000000000000000000000000000dEaD;
    address public devAddress;

    bool private liquidating;
    bool public tradingEnabled; // whether the token can already be traded
    bool public isAutoProcessing;

    mapping(address => bool) private _isExcludedFromFees;

    mapping(address => bool) public canTransferBeforeTradingIsEnabled;

    mapping(address => bool) public automatedMarketMakerPairs;

    mapping(address => bool) public isBlacklisted;

    mapping(address => uint256) public buyCooldown;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event DevWalletUpdated(
        address indexed newDevWallet,
        address indexed oldDevWallet
    );

    event GasForProcessingUpdated(
        uint256 indexed newValue,
        uint256 indexed oldValue
    );

    event ExcludeFromFees(address indexed account, bool exclude);

    event UpdateDividendTracker(
        address indexed newAddress,
        address indexed oldAddress
    );

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor(address _devAddress) ERC20("The Dawn Story", "DAWN") {
        excludeFromFees(owner(), true);
        excludeFromFees(_devAddress, true);
        excludeFromFees(address(this), true);
        devAddress = _devAddress;
        canTransferBeforeTradingIsEnabled[owner()] = true;
        _mint(owner(), 100_000_000 * BASE); //100%

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
    }

    receive() external payable {}

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function isExcludedFromDividends(address account)
        public
        view
        returns (bool)
    {
        return dividendTracker.isExcludedFromDividends(account);
    }

    function withdrawableDividendOf(address account)
        external
        view
        returns (uint256)
    {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function hasDividends(address account) external view returns (bool) {
        (, int256 index, , , , , , ) = dividendTracker.getAccount(account);
        return (index > -1);
    }

    function getAccountDividendsInfo(address account)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external
        view
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccountAtIndex(index);
    }

    function activate() public onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        buyLimitTimestamp = (block.timestamp).add(300);
        sellTaxPenaltyTimestamp = (block.timestamp).add(86400);
    }

    function addTransferBeforeTrading(address account) external onlyOwner {
        require(account != address(0), "Sets the zero address");
        canTransferBeforeTradingIsEnabled[account] = true;
    }

    function blackList(address _user) external onlyOwner {
        require(!isBlacklisted[_user], "user already blacklisted");
        isBlacklisted[_user] = true;
    }

    function excludeDividendsPairOnce() external onlyOwner {
        require(
            !automatedMarketMakerPairs[uniswapV2Pair],
            "uniswap pair has been set!"
        );
        _setAutomatedMarketMakerPair(uniswapV2Pair, true);
    }

    function removeFromBlacklist(address _user) external onlyOwner {
        require(isBlacklisted[_user], "user already whitelisted");
        isBlacklisted[_user] = false;
    }

    function excludeFromFees(address account, bool exclude) public onlyOwner {
        require(
            _isExcludedFromFees[account] != exclude,
            "Already has been assigned!"
        );
        _isExcludedFromFees[account] = exclude;
        emit ExcludeFromFees(account, exclude);
    }

    function excludeFromDividends(address account, bool exclude)
        public
        onlyOwner
    {
        dividendTracker.excludeFromDividends(account, exclude);
    }

    function setAutomatedMarketMakerPair(address pair, bool value)
        public
        onlyOwner
    {
        require(pair != uniswapV2Pair, "JoeTrader pair is irremovable!");
        _setAutomatedMarketMakerPair(pair, value);
    }

    function updateDividendTracker(address newAddress) public onlyOwner {
        require(
            newAddress != address(dividendTracker),
            "Tracker already has been set!"
        );
        ITracker newDividendTracker = ITracker(payable(newAddress));
        require(
            newDividendTracker.owner() == address(this),
            "Tracker must be owned by token"
        );
        newDividendTracker.excludeFromDividends(
            address(newDividendTracker),
            true
        );
        newDividendTracker.excludeFromDividends(address(this), true);
        newDividendTracker.excludeFromDividends(owner(), true);
        newDividendTracker.excludeFromDividends(DEAD_ADDRESS, true);
        newDividendTracker.excludeFromDividends(address(devAddress), true);
        emit UpdateDividendTracker(newAddress, address(dividendTracker));
        dividendTracker = newDividendTracker;
    }

    function updateGasForProcessing(uint256 newValue) external onlyOwner {
        require(newValue != gasForProcessing, "Value has been assigned!");
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function updateMinimumForDividends(uint256 amount) external onlyOwner {
        dividendTracker.updateMinimumForDividends(amount);
    }

    function updateDevWallet(address newDevWallet) external onlyOwner {
        require(newDevWallet != devAddress, "Dev wallet has been assigned!");
        excludeFromFees(newDevWallet, true);
        emit DevWalletUpdated(newDevWallet, devAddress);
        devAddress = newDevWallet;
    }

    function updateAmountToLiquidateAt(uint256 liquidateAmount)
        external
        onlyOwner
    {
        require(
            (liquidateAmount >= 10_000 * BASE) && //0.01%-0.1%
                (100_000 * BASE >= liquidateAmount),
            "should be 100M <= value <= 1B"
        );
        require(
            liquidateAmount != liquidateTokensAtAmount,
            "value already assigned!"
        );
        liquidateTokensAtAmount = liquidateAmount;
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            tx.origin
        );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender));
    }

    function switchAutoProcessing(bool enabled) external onlyOwner {
        require(enabled != isAutoProcessing, "already has been set!");
        isAutoProcessing = enabled;
    }

    function sendEth(address account, uint256 amount) private {
        (bool success, ) = account.call{value: amount}("");
    }

    function swapAndSend(uint256 tokens) private {
        swapTokensForETH(tokens);

        uint256 dividends = address(this).balance;
        uint256 devTokens = dividends.mul(DEV_FEE).div(TOTAL_FEES);
        if (accumulatedPenalty > 0) {
            devTokens += dividends.mul(accumulatedPenalty).div(tokens);
            accumulatedPenalty = 0;
        }
        sendEth(devAddress, devTokens);
        uint256 rewardTokens = address(this).balance;
        sendEth(address(dividendTracker), rewardTokens);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of eth
            path,
            address(this),
            block.timestamp
        );
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(
            automatedMarketMakerPairs[pair] != value,
            "AMM pair has been assigned!"
        );
        automatedMarketMakerPairs[pair] = value;
        if (value) dividendTracker.excludeFromDividends(pair, value);
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            !isBlacklisted[from] && !isBlacklisted[to],
            "from or to is blacklisted"
        );

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        bool tradingIsEnabled = tradingEnabled;
        bool areMeet = !liquidating && tradingIsEnabled;
        bool hasContracts = isContract(from) || isContract(to);
        if (!tradingIsEnabled) {
            require(
                canTransferBeforeTradingIsEnabled[from],
                "Trading is not enabled"
            );
        }

        if (hasContracts) {
            if (areMeet) {
                if (
                    automatedMarketMakerPairs[from] && // buys only by detecting transfer from automated market maker pair
                    to != address(uniswapV2Router) && //router -> pair is removing liquidity which shouldn't have max
                    !_isExcludedFromFees[to] //no max for those excluded from fees)
                ) {
                    if (buyLimitTimestamp >= block.timestamp)
                        require(
                            amount <= MAX_BUY_TX_AMOUNT,
                            "exceeds MAX_BUY_TX_AMOUNT"
                        );
                    require(
                        buyCooldown[to] <= block.timestamp,
                        "under cooldown period"
                    );
                    buyCooldown[to] = (block.timestamp).add(30);
                }

                uint256 contractTokenBalance = balanceOf(address(this));

                bool canSwap = contractTokenBalance >= liquidateTokensAtAmount;

                if (canSwap && !automatedMarketMakerPairs[from]) {
                    liquidating = true;

                    swapAndSend(contractTokenBalance);

                    liquidating = false;
                }
            }

            bool takeFee = tradingIsEnabled && !liquidating;

            if (
                _isExcludedFromFees[from] ||
                _isExcludedFromFees[to] ||
                (automatedMarketMakerPairs[from] && // third condition is for liquidity removing
                    to == address(uniswapV2Router))
            ) {
                takeFee = false;
            }

            if (takeFee) {
                uint256 fees;
                if (block.timestamp < sellTaxPenaltyTimestamp && automatedMarketMakerPairs[to]) {
                    fees = amount.mul(TOTAL_FEES.add(PENALTY_FEE)).div(100);
                    accumulatedPenalty += amount.mul(PENALTY_FEE).div(100);
                } else {
                    fees = amount.mul(TOTAL_FEES).div(100);
                }
                amount = amount.sub(fees);
                super._transfer(from, address(this), fees);
            }
        }
        super._transfer(from, to, amount);

        uint256 fromBalance = balanceOf(from);
        uint256 toBalance = balanceOf(to);

        dividendTracker.setBalance(payable(from), fromBalance);
        dividendTracker.setBalance(payable(to), toBalance);

        if (!liquidating && isAutoProcessing && hasContracts) {
            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    tx.origin
                );
            } catch {}
        }
    }
}
pragma solidity ^0.8.0;
contract DawnDividendTracker is DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public constant BASE = 10**18;
    uint256 public lastProcessedIndex;
    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    mapping (address => bool) public isExcludedFromDividends;
    mapping (address => uint256) public lastClaimTimes;

    event ExcludeFromDividends(address indexed account, bool exclude);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event Claim(address indexed account, uint256 amount);

    constructor() DividendPayingToken("Dawn Dividends","DAWN_D"){
    	claimWait = 3600;
        minimumTokenBalanceForDividends = 860 * BASE; // 0.00088%
    }
    function withdrawDividend() public pure override{
        require(false, "disabled, use 'claim' function");
    }
    function getLastProcessedIndex() external view returns(uint256) {
    	return lastProcessedIndex;
    }
    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }
    function getAccount(address account) external view returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256) {
            return _getAccount(account);
    }
    function _getAccount(address _account)
        private view returns (
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

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
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
    	if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return _getAccount(account);
    }

    function excludeFromDividends(address account, bool exclude) external onlyOwner {
    	require(isExcludedFromDividends[account] != exclude,"already has been set!");
    	isExcludedFromDividends[account] = exclude;
        uint256 bal = IERC20(owner()).balanceOf(account);
        if(exclude){
            _setBalance(account, 0);
    	    tokenHoldersMap.remove(account);
        }else{
            _setBalance(account, bal);
    		tokenHoldersMap.set(account, bal);
        }

    	emit ExcludeFromDividends(account,exclude);
    }
    function updateMinimumForDividends(uint256 amount) external onlyOwner{
        require((amount >= 100 * BASE) && (100000 * BASE >= amount),"should be 1M <= amount <= 10B");
        require(amount != minimumTokenBalanceForDividends,"value already assigned!");
        minimumTokenBalanceForDividends = amount;
    }
    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 1800 && newClaimWait <= 86400, "must be updated 1 to 24 hours");
        require(newClaimWait != claimWait, "same claimWait value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }
    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
    	if(isExcludedFromDividends[account]) {
    		return;
    	}
    	if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
    		tokenHoldersMap.set(account, newBalance);
    	}
    	else {
            _setBalance(account, 0);
    		tokenHoldersMap.remove(account);
    	}

    	_processAccount(account);
    }

    function processAccount(address payable account) external onlyOwner{
    	uint256 amount = _withdrawDividendOfUser(account);
        emit Claim(account,amount);
    }

    function _processAccount(address payable account) private returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

    	if(amount > 0) {
    		lastClaimTimes[account] = block.timestamp;
    		return true;
    	}

    	return false;
    }

    function process(uint256 gas) external returns (uint256, uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

    	if(numberOfTokenHolders == 0) {
    		return (0, 0, lastProcessedIndex);
    	}

    	uint256 _lastProcessedIndex = lastProcessedIndex;

    	uint256 gasUsed = 0;

    	uint256 gasLeft = gasleft();

    	uint256 iterations = 0;
    	uint256 claims = 0;

    	while(gasUsed < gas && iterations < numberOfTokenHolders) {
    		_lastProcessedIndex++;

    		if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
    			_lastProcessedIndex = 0;
    		}

    		address account = tokenHoldersMap.keys[_lastProcessedIndex];

    		if(canAutoClaim(lastClaimTimes[account])) {
    			if(_processAccount(payable(account))) {
    				claims++;
    			}
    		}

    		iterations++;

    		uint256 newGasLeft = gasleft();

    		if(gasLeft > newGasLeft) {
    			gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
    		}

    		gasLeft = newGasLeft;
    	}

    	lastProcessedIndex = _lastProcessedIndex;

    	return (iterations, claims, lastProcessedIndex);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
    	if(lastClaimTime > block.timestamp)  {
    		return false;
    	}

    	return block.timestamp.sub(lastClaimTime) >= claimWait;
    }
}
