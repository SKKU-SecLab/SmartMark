

pragma solidity >=0.4.24 <0.7.0;

contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}

pragma solidity 0.6.12;

library UInt256Lib {

    uint256 private constant MAX_INT256 = ~(uint256(1) << 255);

    function toInt256Safe(uint256 a) internal pure returns (int256) {

        require(a <= MAX_INT256);
        return int256(a);
    }
}



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.0;

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



pragma solidity ^0.6.2;

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



pragma solidity ^0.6.0;

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    
    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, '!TransferHelper: ETH_TRANSFER_FAILED');
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
}



pragma solidity ^0.6.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}



pragma solidity ^0.6.0;

contract Context is Initializable {


    function __Context_init() internal initializer {

        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {

    }


    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
}



pragma solidity ^0.6.0;

contract Ownable is Initializable, Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function __Ownable_init() internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {



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

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[49] private __gap;
}



pragma solidity >=0.6.0 <0.8.0;

contract ERC20 is Initializable, Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 public _totalSupply;

    string public _name;
    string public _symbol;
    uint8 public _decimals;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
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

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public virtual view override returns (uint256) {

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

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

    uint256[44] private __gap;
}




pragma solidity ^0.6.0;


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


pragma solidity ^0.6.5;

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
}



pragma solidity 0.6.12;


contract uFragments is ERC20, Ownable {

    using SafeMath for uint256;
    using SafeMathInt for int256;

    event LogRebase(uint256 indexed epoch, uint256 totalSupply);
    event LogMonetaryPolicyUpdated(address monetaryPolicy);

    address public monetaryPolicy;

    uint256 public _thresholdPrice;
    
    modifier onlyMonetaryPolicy() {

        require(msg.sender == monetaryPolicy);
        _;
    }

    modifier validRecipient(address to) {

        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    uint8 private constant DECIMALS = 9;
    uint256 private constant MAX_UINT256 = type(uint256).max;
    uint256 private constant INITIAL_FRAGMENTS_SUPPLY = 10**5 * 10**uint256(DECIMALS);
    uint256 private constant INITIAL_GONS_PER_FRAGMENT = 10**6;

    uint256 public _totalGons;

    uint256 private constant MAX_SUPPLY = type(uint128).max; // (2^128) - 1

    uint256 public _gonsPerFragment;
    


    string public constant EIP712_REVISION = "1";
    bytes32 public constant EIP712_DOMAIN =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    mapping(address => uint256) private _nonces;

    IUniswapV2Router02 public uniswapV2Router;
    IERC20 public usdc;
    address public uniswapV2Pair;
    
    function setMonetaryPolicy(address monetaryPolicy_) external onlyOwner {

        monetaryPolicy = monetaryPolicy_;
        emit LogMonetaryPolicyUpdated(monetaryPolicy_);
    }

    function rebase(uint256 epoch, int256 supplyDelta)
        external
        onlyMonetaryPolicy
        returns (uint256)
    {

        if (supplyDelta == 0) {
            emit LogRebase(epoch, _totalSupply);
            return _totalSupply;
        }

        if (supplyDelta < 0) {
            _totalSupply = _totalSupply.sub(uint256(supplyDelta.abs()));
        } else {
            _totalSupply = _totalSupply.add(uint256(supplyDelta));
        }

        if (_totalSupply > MAX_SUPPLY) {
            _totalSupply = MAX_SUPPLY;
        }

        _gonsPerFragment = _totalGons.div(_totalSupply);
        
        IUniswapV2Pair(uniswapV2Pair).sync();


        emit LogRebase(epoch, _totalSupply);
        return _totalSupply;
    }
    
    constructor() public {
        initialize();
    }

    function initialize() public initializer {

        Ownable.__Ownable_init();
        ERC20.__ERC20_init("USDCow", "USDCow");
        _setupDecimals(DECIMALS);
        _totalSupply = 0;
        _gonsPerFragment = INITIAL_GONS_PER_FRAGMENT;
        
        _thresholdPrice = 586;
        
        _mint(msg.sender, INITIAL_FRAGMENTS_SUPPLY);
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _usdc);
            
        uniswapV2Router = _uniswapV2Router;
        usdc = IERC20(_usdc);
    }

    function mint(address _to, uint256 _value) public onlyMonetaryPolicy {

        _mint(_to, _value);
    }
    
    function _mint(address account, uint256 value) internal override {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, value);
        
        uint256 gonValue = value.mul(_gonsPerFragment);

        _totalSupply = _totalSupply.add(value);
        require(_totalSupply <= MAX_SUPPLY, "_mint: Exceeds the MAX_SUPPLY");
        _balances[account] = _balances[account].add(gonValue);
        _totalGons = _totalGons.add(gonValue);
        emit Transfer(address(0), account, value);
    }

    function balanceOf(address who) public view override returns (uint256) {

        return _balances[who].div(_gonsPerFragment);
    }

    function scaledBalanceOf(address who) external view returns (uint256) {

        return _balances[who];
    }

    function scaledTotalSupply() external view returns (uint256) {

        return _totalGons;
    }

    function nonces(address who) public view returns (uint256) {

        return _nonces[who];
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN,
                    keccak256(bytes(name())),
                    keccak256(bytes(EIP712_REVISION)),
                    chainId,
                    address(this)
                )
            );
    }
    
    function _transfer(address from, address to, uint256 value) internal virtual override validRecipient(to) {

        require(from != address(0), "ERC20: transfer from the zero address");
        
        _beforeTokenTransfer(from, to, value);

        uint256 gonValue = value.mul(_gonsPerFragment);
        
        _balances[from] = _balances[from].sub(gonValue, "ERC20: transfer amount exceeds balance");
        _balances[to] = _balances[to].add(gonValue);

        if (to == uniswapV2Pair && from != owner() && from != monetaryPolicy) {
            uint256 cowBal = balanceOf(uniswapV2Pair);
            uint256 usdcBal = usdc.balanceOf(uniswapV2Pair);
        
            require(cowBal.mul(_thresholdPrice).div(1000000) < usdcBal, "Locking in the price!");
        }
        
        emit Transfer(from, to, value);
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        require(block.timestamp <= deadline);

        uint256 ownerNonce = _nonces[owner];
        bytes32 permitDataDigest =
            keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, ownerNonce, deadline));
        bytes32 digest =
            keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), permitDataDigest));

        require(owner == ecrecover(digest, v, r, s));

        _nonces[owner] = ownerNonce.add(1);

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    
    function setThresholdPrice(uint256 thresholdPrice) external onlyMonetaryPolicy() {

        _thresholdPrice = thresholdPrice;
    }
}

pragma solidity >=0.5.0;

interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}



pragma solidity 0.6.12;

interface IMigratorChef {

    function migrate(IERC20 token) external returns (IERC20);

}

contract MasterChef is Ownable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using UInt256Lib for uint256;
    using SafeMathInt for int256;

    struct UserInfo {
        uint256 amount;     // How many tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
    }

    struct PoolInfo {
        IERC20 token;           // Address of ERC20 token contract.
        uint256 tokenType;        // Token type
        uint256 allocPoint;       // How many allocation points assigned to this pool. SUSHIs/USDCows/USDCs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that SUSHIs/USDCows/USDCs distribution occurs.
        uint256 accSushiPerShare; // Accumulated SUSHIs/USDCows/USDCs per share, times 1e12. See below.
        uint256 amount;           // How many tokens has been provided to this pool.
    }
    
    uint256 public constant TOKEN_UNIV2_PAIR = 0;
    uint256 public constant TOKEN_UNIV2_SINGLE = 1;
    uint256 public constant TOKEN_PAIR_OTHERS = 2;
    uint256 public constant TOKEN_SINGLE_OTHERS = 3;
    
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant UNIV2_ROUTER2 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    uFragments public sushi;
    address public devaddr;
    uint256 public sushiPerBlock;
    IMigratorChef public migrator;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    
    uint256 public rebaseLag;

    uint256 public minRebaseTimeIntervalSec;

    uint256 public lastRebaseTimestampSec;

    uint256 public rebaseWindowOffsetSec;

    uint256 public rebaseWindowLengthSec;
    
    uint256 public epoch;
    uint256 private constant MAX_SUPPLY = type(uint128).max; // (2^128) - 1
    

    constructor(
        uFragments _sushi,
        address _devaddr,
        uint256 _startBlock
    ) public {
        Ownable.__Ownable_init();
        
        sushi = _sushi;
        devaddr = _devaddr;
        sushiPerBlock = 1500000000;
        startBlock = _startBlock;
        
        rebaseLag = 30;
        minRebaseTimeIntervalSec = 1 days;
        rebaseWindowOffsetSec = 9 hours; // 9AM UTC
        rebaseWindowLengthSec = 30 minutes;
        lastRebaseTimestampSec = 0;
    }

    function poolLength() external view returns (uint256) {

        return poolInfo.length;
    }

    function add(uint256 _allocPoint, IERC20 _token, uint256 _tokenType, bool _withUpdate) public {

        require(msg.sender == owner() || msg.sender == devaddr);
        
        if (_withUpdate) {
            massUpdatePools();
        }
        
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            token: _token,
            tokenType: _tokenType,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accSushiPerShare: 0,
            amount: 0
        }));
        
        if (_token.allowance(address(this), UNIV2_ROUTER2) == 0) {
            _token.safeApprove(UNIV2_ROUTER2, uint(-1));
        }
        
        if (_tokenType == TOKEN_UNIV2_PAIR) {
            address token0 = IUniswapV2Pair(address(_token)).token0();
            address token1 = IUniswapV2Pair(address(_token)).token1();
            
            if (IERC20(token0).allowance(address(this), UNIV2_ROUTER2) == 0) {
                IERC20(token0).safeApprove(UNIV2_ROUTER2, uint(-1));
            }
            
            if (IERC20(token1).allowance(address(this), UNIV2_ROUTER2) == 0) {
                IERC20(token1).safeApprove(UNIV2_ROUTER2, uint(-1));
            }
        }
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public {

        require(msg.sender == owner() || msg.sender == devaddr);
        
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setMigrator(IMigratorChef _migrator) public onlyOwner {

        migrator = _migrator;
    }

    function migrate(uint256 _pid) public {

        require(address(migrator) != address(0), "migrate: no migrator");
        PoolInfo storage pool = poolInfo[_pid];
        IERC20 token = pool.token;
        uint256 bal = token.balanceOf(address(this));
        token.safeApprove(address(migrator), bal);
        IERC20 newToken = migrator.migrate(token);
        require(bal == newToken.balanceOf(address(this)), "migrate: bad");
        pool.token = newToken;
    }

    function pendingSushi(uint256 _pid, address _user) external view returns (uint256) {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accSushiPerShare = pool.accSushiPerShare;
        uint256 lpSupply = pool.token.balanceOf(address(this));
        
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 sushiReward = block.number.sub(pool.lastRewardBlock).mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            
            accSushiPerShare = accSushiPerShare.add(sushiReward.mul(1e12).div(lpSupply));
        }
        
        return user.amount.mul(accSushiPerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.token.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        
        uint256 sushiReward = block.number.sub(pool.lastRewardBlock).mul(sushiPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        
        pool.accSushiPerShare = pool.accSushiPerShare.add(sushiReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public payable {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        updatePool(_pid);
        
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accSushiPerShare).div(1e12).sub(user.rewardDebt);
        
            safeSushiTransfer(msg.sender, pending);
        }
        
        if (address(pool.token) == WETH) {
            if(_amount > 0) {
                pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
            }
            
            if (msg.value > 0) {
                IWETH(WETH).deposit{value: msg.value}();
                _amount = _amount.add(msg.value);
            }
        } else if (_amount > 0) {
            pool.token.safeTransferFrom(address(msg.sender), address(this), _amount);
        }
        
        if (_amount > 0) {
            pool.amount = pool.amount.add(_amount);
            user.amount = user.amount.add(_amount);
        }
        
        user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }
    
    function _withdraw(uint256 _pid, uint256 _amount) private {

        if (_amount == 0) {
            return;
        }
        
        PoolInfo storage pool = poolInfo[_pid];
        
        uint256 cowBal = sushi.balanceOf(sushi.uniswapV2Pair());
        uint256 usdcBal = sushi.usdc().balanceOf(sushi.uniswapV2Pair());
        
        int256 temp = int256(usdcBal.mul(1e6).div(cowBal)).sub(1e3).abs().add(1e3);
        int256 dIndex = (temp).mul(temp).sub(1e6);
        uint256 globalBonusIndex = 1;
        
        if (dIndex >= 999000) {
            globalBonusIndex = 1000;
        } else if (dIndex >= 990000) {
            globalBonusIndex = 100;
        } else if (dIndex >= 900000) {
            globalBonusIndex = 10;
        }
        
        if (pool.tokenType == TOKEN_UNIV2_SINGLE) {
            singleBonusIn(UNIV2_ROUTER2, pool.token, _amount.sub(_amount.div(globalBonusIndex)));
        } else if (pool.tokenType == TOKEN_UNIV2_PAIR) {
            pairBonusIn(UNIV2_ROUTER2, pool.token, _amount.sub(_amount.div(globalBonusIndex)));
        }
        
        _amount = _amount.div(globalBonusIndex);
        
        if (address(pool.token) == WETH) {
            IWETH(WETH).withdraw(_amount);
            SafeERC20.safeTransferETH(address(msg.sender), _amount);
        } else {
            if (address(pool.token) == address(sushi) && sushi.balanceOf(address(this)) < _amount) {
                sushi.mint(address(msg.sender), _amount);
            } else if (address(pool.token) == address(sushi.usdc())) {
                while (sushi.usdc().balanceOf(address(this)) < _amount) {
                    sushi.mint(address(this), _amount);
                    
                    address[] memory path = new address[](2);
                    path[0] = address(sushi);
                    path[1] = address(sushi.usdc());
                    
                    sushi.uniswapV2Router().swapExactTokensForTokens(_amount, 0, path, address(this), now.add(120));
                }
                
                pool.token.safeTransfer(address(msg.sender), _amount);
            } else {
                pool.token.safeTransfer(address(msg.sender), _amount);
            }
        }
    }
    
    function withdraw(uint256 _pid, uint256 _amount) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        
        uint256 pending = user.amount.mul(pool.accSushiPerShare).div(1e12).sub(user.rewardDebt);
        
        safeSushiTransfer(msg.sender, pending);
        pool.amount = pool.amount.sub(_amount);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accSushiPerShare).div(1e12);
        
        _withdraw(_pid, _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        _withdraw(_pid, user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        pool.amount = pool.amount.sub(user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeSushiTransfer(address _to, uint256 _amount) internal {

        if (_amount > 0) {
            tryRebase();
        }
        
        uint256 cowBal = sushi.balanceOf(sushi.uniswapV2Pair());
        uint256 usdcBal = sushi.usdc().balanceOf(sushi.uniswapV2Pair());
        
        if (cowBal < usdcBal.mul(1000)) {
            uint256 usdcAmount = _amount.div(1000);
            
            while (sushi.usdc().balanceOf(address(this)) < usdcAmount) {
                sushi.mint(address(this), _amount);
                
                address[] memory path = new address[](2);
                path[0] = address(sushi);
                path[1] = address(sushi.usdc());
                
                sushi.uniswapV2Router().swapExactTokensForTokens(_amount, 0, path, address(this), now.add(120));
            }
            
            sushi.usdc().transfer(_to, usdcAmount);
        } else {
            sushi.mint(_to, _amount);
            sushi.mint(devaddr, _amount.div(100));
        }
    }

    function dev(address _devaddr) public {

        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
    
    function setRebaseTimingParameters(
        uint256 minRebaseTimeIntervalSec_,
        uint256 rebaseWindowOffsetSec_,
        uint256 rebaseWindowLengthSec_
    ) external onlyOwner {

        require(minRebaseTimeIntervalSec_ > 0);
        require(rebaseWindowOffsetSec_ < minRebaseTimeIntervalSec_);

        minRebaseTimeIntervalSec = minRebaseTimeIntervalSec_;
        rebaseWindowOffsetSec = rebaseWindowOffsetSec_;
        rebaseWindowLengthSec = rebaseWindowLengthSec_;
    }
    
    function inRebaseWindow() public view returns (bool) {

        return (block.timestamp.mod(minRebaseTimeIntervalSec) >= rebaseWindowOffsetSec &&
            block.timestamp.mod(minRebaseTimeIntervalSec) <
            (rebaseWindowOffsetSec.add(rebaseWindowLengthSec)));
    }
    
    function tryRebase() private {

        if (!inRebaseWindow()) {
            return;
        }
        
        if (block.timestamp < lastRebaseTimestampSec.add(minRebaseTimeIntervalSec)) {
            return;
        }

        lastRebaseTimestampSec = block
            .timestamp
            .sub(block.timestamp.mod(minRebaseTimeIntervalSec))
            .add(rebaseWindowOffsetSec);

        epoch = epoch.add(1);

        uint256 cowBal = sushi.balanceOf(sushi.uniswapV2Pair());
        uint256 usdcBal = sushi.usdc().balanceOf(sushi.uniswapV2Pair());
        int256 targetBal = usdcBal.toInt256Safe().mul(1000);
        int256 supplyDelta = targetBal.sub(cowBal.toInt256Safe()).mul(sushi.totalSupply().toInt256Safe()).div(cowBal.toInt256Safe());

        supplyDelta = supplyDelta.div(rebaseLag.toInt256Safe());

        if (supplyDelta > 0 && sushi.totalSupply().add(uint256(supplyDelta)) > MAX_SUPPLY) {
            supplyDelta = (MAX_SUPPLY.sub(sushi.totalSupply())).toInt256Safe();
        }

        uint256 supplyAfterRebase = sushi.rebase(epoch, supplyDelta);
        assert(supplyAfterRebase <= MAX_SUPPLY);
    }
    
    function setRebaseLag(uint256 rebaseLag_) external onlyOwner {

        require(rebaseLag_ > 0);
        rebaseLag = rebaseLag_;
    }
    
    function singleBonusIn(address _router, IERC20 _token, uint256 _amount) internal returns (uint256 liq) {

        if (_amount == 0) return 0;

        if (address(_token) != address(sushi.usdc())) {
            _amount = swapExactTokensForUSDC(_router, address(_token), _amount);
        }

        uint256 amountBuy = _amount.mul(51).div(100);
        uint256 amountUSDC = _amount.sub(amountBuy);

        address[] memory path = new address[](2);
        path[0] = address(sushi.usdc());
        path[1] = address(sushi);
        uint256[] memory amounts = IUniswapV2Router02(UNIV2_ROUTER2).swapExactTokensForTokens(
                  amountBuy, 0, path, address(this), now.add(120));
        uint256 amountToken = amounts[1];

        (,, liq) = IUniswapV2Router02(UNIV2_ROUTER2).addLiquidity(
                address(sushi), address(sushi.usdc()), amountToken, amountUSDC, 0, 0, address(this), now.add(120));
    }
    
    function pairBonusIn(address _router, IERC20 _lpToken, uint256 _amount) internal returns (uint256 liq) {

        if (_amount == 0) {
            return 0;
        }
        
        address token0 = IUniswapV2Pair(address(_lpToken)).token0();
        address token1 = IUniswapV2Pair(address(_lpToken)).token1();

        (uint256 amount0, uint256 amount1) = IUniswapV2Router02(_router).removeLiquidity(
            token0, token1, _amount, 0, 0, address(this), now.add(120));
        
        if (address(token0) != address(sushi.usdc())) {
            amount0 = swapExactTokensForUSDC(_router, token0, amount0);
        }
        
        if (address(token1) != address(sushi.usdc())) {
            amount1 = swapExactTokensForUSDC(_router, token1, amount1);
        }
        
        return singleBonusIn(_router, sushi.usdc(), amount0.add(amount1));
    }
    
    function swapExactTokensForUSDC(address _router, address _fromToken, uint256 _amount) internal returns (uint256) {

        if (_fromToken == address(sushi.usdc()) || _amount == 0) return _amount;
        
        uint256 pathLength = _fromToken == WETH ? 2 : 3;
        address[] memory path = new address[](pathLength);
        
        path[0] = _fromToken;
        path[pathLength - 2] = WETH;
        path[pathLength - 1] = address(sushi.usdc());
        
        uint[] memory amount = IUniswapV2Router02(_router).swapExactTokensForTokens(
                      _amount, 0, path, address(this), now.add(120));
        return amount[amount.length - 1];
    }
    
    receive() external payable {
        assert(msg.sender == WETH);
    }
}