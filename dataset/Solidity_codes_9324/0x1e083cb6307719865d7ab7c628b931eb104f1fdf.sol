
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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {
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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
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
    uint256[49] private __gap;
}interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(
    address indexed sender,
    uint256 amount0,
    uint256 amount1,
    address indexed to
  );
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}interface IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}interface IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}//Unlicense
pragma solidity =0.7.6;


contract Staking is OwnableUpgradeable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct PoolInfo {
    IERC20 stakeToken;
    bool isNativePool;
    uint256 rewardPerBlock;
    uint256 lastRewardBlock;
    uint256 accTokenPerShare;
    uint256 depositedAmount;
    uint256 rewardsAmount;
    uint256 lockupDuration;
    uint256 depositLimit;
  }

  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
    uint256 pendingRewards;
    uint256 lastClaim;
  }

  IUniswapV2Router02 public uniswapV2Router;
  IERC20 public rewardToken;
  address public devAddress;
  uint256 public nativeEarlyWithdrawlDevFee;
  uint256 public nativeEarlyWithdrawlLpFee;
  uint256 public nativeRegularWithdrawlDevFee;
  uint256 public nativeRegularWithdrawlLpFee;
  uint256 public lpEarlyWithdrawlFee;
  uint256 public lpRegularWithdrawlFee;
  uint256 public nonNativeDepositDevFee;
  uint256 public nonNativeDepositLpFee;
  uint256 public kawaLpPoolId;
  uint256 public xkawaLpPoolId;
  uint256 public freeTaxDuration;

  PoolInfo[] public pools;
  mapping(address => mapping(uint256 => UserInfo)) public userInfo;
  mapping(uint256 => address[]) private userList;

  mapping(address => uint256) public tokenPrices;
  uint256 public ethPrice;
  uint256 public kawaLpPricePerKawa;

  event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
  event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
  event Claim(address indexed user, uint256 indexed pid, uint256 amount);

  function initialize() public initializer {
    uniswapV2Router = IUniswapV2Router02(
      0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    devAddress = address(0x93837577c98E01CFde883c23F64a0f608A70B90F);
    nativeEarlyWithdrawlDevFee = 3;
    nativeEarlyWithdrawlLpFee = 2;
    nativeRegularWithdrawlDevFee = 2;
    nativeRegularWithdrawlLpFee = 1;
    lpEarlyWithdrawlFee = 3;
    lpRegularWithdrawlFee = 1;
    nonNativeDepositDevFee = 3;
    nonNativeDepositLpFee = 1;
    kawaLpPoolId = 2;
    xkawaLpPoolId = 3;
    freeTaxDuration = 180 * 24 * 60 * 60 * 1000; // 180 days

    __Ownable_init();
  }

  receive() external payable {}


  function updateUniswapV2Router(address newAddress) external onlyOwner {
    require(
      newAddress != address(uniswapV2Router),
      'The router already has that address'
    );
    uniswapV2Router = IUniswapV2Router02(newAddress);
  }

  function setRewardToken(address _rewardToken) external onlyOwner {
    rewardToken = IERC20(_rewardToken);
  }

  function setDevAddress(address _devAddress) external onlyOwner {
    devAddress = _devAddress;
  }

  function setNativeEarlyWithdrawlDevFee(uint256 _fee) external onlyOwner {
    nativeEarlyWithdrawlDevFee = _fee;
  }

  function setNativeEarlyWithdrawlLpFee(uint256 _fee) external onlyOwner {
    nativeEarlyWithdrawlLpFee = _fee;
  }

  function setNativeRegularWithdrawlDevFee(uint256 _fee) external onlyOwner {
    nativeRegularWithdrawlDevFee = _fee;
  }

  function setNativeRegularWithdrawlLpFee(uint256 _fee) external onlyOwner {
    nativeRegularWithdrawlLpFee = _fee;
  }

  function setLpEarlyWithdrawlFee(uint256 _fee) external onlyOwner {
    lpEarlyWithdrawlFee = _fee;
  }

  function setLpRegularWithdrawlFee(uint256 _fee) external onlyOwner {
    lpRegularWithdrawlFee = _fee;
  }

  function setNonNativeDepositDevFee(uint256 _fee) external onlyOwner {
    nonNativeDepositDevFee = _fee;
  }

  function setNonNativeDepositLpFee(uint256 _fee) external onlyOwner {
    nonNativeDepositLpFee = _fee;
  }

  function setKawaLpPoolId(uint256 pid) external onlyOwner {
    kawaLpPoolId = pid;
  }

  function setXkawaLpPoolId(uint256 pid) external onlyOwner {
    xkawaLpPoolId = pid;
  }

  function setFreeTaxDuration(uint256 _duration) external onlyOwner {
    freeTaxDuration = _duration;
  }

  function setEthPrice(uint256 value) external onlyOwner {
    ethPrice = value;
  }

  function setTokenPrice(address _token, uint256 value) external onlyOwner {
    tokenPrices[_token] = value;
  }

  function setKawaLpPrice(uint256 value) external onlyOwner {
    kawaLpPricePerKawa = value;
  }

  function addPool(
    address _stakeToken,
    bool _isNativePool,
    uint256 _rewardPerBlock,
    uint256 _lockupDuration,
    uint256 _depositLimit
  ) external onlyOwner {
    pools.push(
      PoolInfo({
        stakeToken: IERC20(_stakeToken),
        isNativePool: _isNativePool,
        rewardPerBlock: _rewardPerBlock,
        lastRewardBlock: block.number,
        accTokenPerShare: 0,
        depositedAmount: 0,
        rewardsAmount: 0,
        lockupDuration: _lockupDuration,
        depositLimit: _depositLimit
      })
    );
  }

  function updatePool(
    uint256 pid,
    address _stakeToken,
    bool _isNativePool,
    uint256 _rewardPerBlock,
    uint256 _lockupDuration,
    uint256 _depositLimit
  ) external onlyOwner {
    require(pid >= 0 && pid < pools.length, 'invalid pool id');
    PoolInfo storage pool = pools[pid];
    pool.stakeToken = IERC20(_stakeToken);
    pool.isNativePool = _isNativePool;
    pool.rewardPerBlock = _rewardPerBlock;
    pool.lockupDuration = _lockupDuration;
    pool.depositLimit = _depositLimit;
  }

  function emergencyWithdraw(address _token, uint256 _amount)
    external
    onlyOwner
  {
    uint256 _bal = IERC20(_token).balanceOf(address(this));
    if (_amount > _bal) _amount = _bal;

    IERC20(_token).safeTransfer(_msgSender(), _amount);
  }


  function deposit(uint256 pid, uint256 amount) external payable {
    _deposit(pid, amount, true);
  }

  function withdraw(uint256 pid, uint256 amount) external {
    _withdraw(pid, amount);
  }

  function withdrawAll(uint256 pid) external {
    UserInfo storage user = userInfo[msg.sender][pid];
    _withdraw(pid, user.amount);
  }

  function claim(uint256 pid) external {
    _claim(pid, true);
  }

  function claimAll() external {
    for (uint256 pid = 0; pid < pools.length; pid++) {
      UserInfo storage user = userInfo[msg.sender][pid];
      if (user.amount > 0 || user.pendingRewards > 0) {
        _claim(pid, true);
      }
    }
  }

  function claimAndRestake(uint256 pid) external {
    uint256 amount = _claim(pid, false);
    _deposit(1, amount, false);
  }

  function claimAndRestakeAll() external {
    for (uint256 pid = 0; pid < pools.length; pid++) {
      UserInfo storage user = userInfo[msg.sender][pid];
      if (user.amount > 0 || user.pendingRewards > 0) {
        uint256 amount = _claim(pid, false);
        _deposit(1, amount, false);
      }
    }
  }


  function _deposit(
    uint256 pid,
    uint256 amount,
    bool hasTransfer
  ) private {
    require(amount > 0, 'invalid deposit amount');

    PoolInfo storage pool = pools[pid];
    UserInfo storage user = userInfo[msg.sender][pid];
    require(
      poolActionAvailable(pid, user.amount.add(amount), msg.sender),
      'Action not available'
    );
    if (hasTransfer) {
      require(
        msg.value >= getPoolDepositEthAmount(pid, amount),
        'Eth fee is not enough'
      );
    }

    require(
      user.amount.add(amount) <= pool.depositLimit,
      'exceeds deposit limit'
    );

    _updatePool(pid);

    if (user.amount > 0) {
      uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(
        user.rewardDebt
      );
      if (pending > 0) {
        user.pendingRewards = user.pendingRewards.add(pending);
      }
    } else {
      userList[pid].push(msg.sender);
    }

    if (amount > 0) {
      if (hasTransfer) {
        pool.stakeToken.safeTransferFrom(
          address(msg.sender),
          address(this),
          amount
        );
      }
      user.amount = user.amount.add(amount);
      pool.depositedAmount = pool.depositedAmount.add(amount);
    }
    user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
    user.lastClaim = block.timestamp;
    emit Deposit(msg.sender, pid, amount);

    uint256 totalFeePercent = nonNativeDepositDevFee
      .add(nonNativeDepositLpFee)
      .add(nonNativeDepositLpFee);
    if (!pool.isNativePool && totalFeePercent > 0) {
      uint256 amountETH = address(this).balance;
      if (amountETH > 0) {
        uint256 lpETH = amountETH.mul(nonNativeDepositLpFee).div(
          totalFeePercent
        );
        uint256 devETH = amountETH.sub(lpETH).sub(lpETH);
        sendEthToAddress(devAddress, devETH);
        distributeETHToLpStakers(kawaLpPoolId, lpETH);
        distributeETHToLpStakers(xkawaLpPoolId, lpETH);
      }
    }
  }

  function _withdraw(uint256 pid, uint256 amount) private {
    PoolInfo storage pool = pools[pid];
    UserInfo storage user = userInfo[msg.sender][pid];

    require(user.amount >= amount, 'Withdrawing more than you have!');
    require(
      poolActionAvailable(pid, user.amount, msg.sender),
      'Action not available'
    );

    bool isRegularWithdrawl = (block.timestamp >
      user.lastClaim + pool.lockupDuration);

    _updatePool(pid);

    uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(
      user.rewardDebt
    );
    if (pending > 0) {
      user.pendingRewards = user.pendingRewards.add(pending);
    }

    uint256 lpFee = 0;
    uint256 devFee = 0;
    if (pool.isNativePool && !isTaxFree(pid, msg.sender)) {
      if (pid == kawaLpPoolId || pid == xkawaLpPoolId) {
        if (isRegularWithdrawl) {
          devFee = amount.mul(lpRegularWithdrawlFee).div(100);
        } else {
          devFee = amount.mul(lpEarlyWithdrawlFee).div(100);
        }
      } else if (isRegularWithdrawl) {
        lpFee = amount.mul(nativeRegularWithdrawlLpFee).div(100);
        devFee = amount.mul(nativeRegularWithdrawlDevFee).div(100);
      } else {
        lpFee = amount.mul(nativeEarlyWithdrawlLpFee).div(100);
        devFee = amount.mul(nativeEarlyWithdrawlDevFee).div(100);
      }
    }
    uint256 withdrawAmount = amount.sub(lpFee).sub(lpFee).sub(devFee);

    if (amount > 0) {
      pool.stakeToken.safeTransfer(address(msg.sender), withdrawAmount);
      user.amount = user.amount.sub(amount);
      pool.depositedAmount = pool.depositedAmount.sub(amount);
    }

    if (user.amount == 0) {
      removeFromUserList(pid, msg.sender);
    }

    user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
    user.lastClaim = block.timestamp;
    emit Withdraw(msg.sender, pid, amount);

    if (pool.isNativePool && !isTaxFree(pid, msg.sender)) {
      if (pid == kawaLpPoolId || pid == xkawaLpPoolId) {
        if (devFee > 0) {
          distributeTokensToStakers(pid, devFee);
        }
      } else if (isRegularWithdrawl) {
        if (devFee > 0) {
          distributeTokensToStakers(pid, devFee);
        }
        if (lpFee > 0) {
          swapTokensForEth(pool.stakeToken, lpFee.add(lpFee));
          uint256 amountETH = address(this).balance;
          uint256 lpETH = amountETH.div(2);
          distributeETHToLpStakers(kawaLpPoolId, lpETH);
          distributeETHToLpStakers(xkawaLpPoolId, lpETH);
        }
      } else {
        uint256 feeAmount = devFee.add(lpFee).add(lpFee);
        uint256 totalFeePercent = nativeRegularWithdrawlDevFee
          .add(nativeRegularWithdrawlLpFee)
          .add(nativeRegularWithdrawlLpFee);
        if (feeAmount > 0) {
          swapTokensForEth(pool.stakeToken, feeAmount);
          uint256 amountETH = address(this).balance;
          uint256 lpETH = amountETH.mul(nativeRegularWithdrawlLpFee).div(
            totalFeePercent
          );
          uint256 devETH = amountETH.sub(lpETH).sub(lpETH);
          if (devETH > 0) {
            sendEthToAddress(devAddress, devETH);
          }
          if (lpETH > 0) {
            distributeETHToLpStakers(kawaLpPoolId, lpETH);
            distributeETHToLpStakers(xkawaLpPoolId, lpETH);
          }
        }
      }
    }
  }

  function _claim(uint256 pid, bool hasTransfer) private returns (uint256) {
    PoolInfo storage pool = pools[pid];
    UserInfo storage user = userInfo[msg.sender][pid];

    require(
      poolActionAvailable(pid, user.amount, msg.sender),
      'Action not available'
    );

    _updatePool(pid);

    uint256 pending = user.amount.mul(pool.accTokenPerShare).div(1e12).sub(
      user.rewardDebt
    );
    uint256 claimedAmount = 0;
    if (pending > 0 || user.pendingRewards > 0) {
      user.pendingRewards = user.pendingRewards.add(pending);
      claimedAmount = safeRewardTokenTransfer(
        pid,
        msg.sender,
        user.pendingRewards,
        hasTransfer
      );
      emit Claim(msg.sender, pid, claimedAmount);
      user.pendingRewards = user.pendingRewards.sub(claimedAmount);
      pool.rewardsAmount = pool.rewardsAmount.sub(claimedAmount);
    }
    user.rewardDebt = user.amount.mul(pool.accTokenPerShare).div(1e12);
    return claimedAmount;
  }

  function _updatePool(uint256 pid) private {
    PoolInfo storage pool = pools[pid];

    if (block.number <= pool.lastRewardBlock) {
      return;
    }
    uint256 depositedAmount = pool.depositedAmount;
    if (pool.depositedAmount == 0) {
      pool.lastRewardBlock = block.number;
      return;
    }
    uint256 multiplier = block.number.sub(pool.lastRewardBlock);
    uint256 tokenReward = multiplier.mul(pool.rewardPerBlock);
    pool.rewardsAmount = pool.rewardsAmount.add(tokenReward);
    pool.accTokenPerShare = pool.accTokenPerShare.add(
      tokenReward.mul(1e12).div(depositedAmount)
    );
    pool.lastRewardBlock = block.number;
  }

  function safeRewardTokenTransfer(
    uint256 pid,
    address to,
    uint256 amount,
    bool hasTransfer
  ) private returns (uint256) {
    PoolInfo storage pool = pools[pid];
    uint256 _bal = rewardToken.balanceOf(address(this));
    if (amount > pool.rewardsAmount) amount = pool.rewardsAmount;
    if (amount > _bal) amount = _bal;
    if (hasTransfer) {
      rewardToken.safeTransfer(to, amount);
    }
    return amount;
  }

  function removeFromUserList(uint256 pid, address _addr) private {
    for (uint256 i = 0; i < userList[pid].length; i++) {
      if (userList[pid][i] == _addr) {
        userList[pid][i] = userList[pid][userList[pid].length - 1];
        userList[pid].pop();
        return;
      }
    }
  }

  function swapTokensForEth(IERC20 token, uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(token);
    path[1] = uniswapV2Router.WETH();

    token.safeApprove(address(uniswapV2Router), tokenAmount);

    uniswapV2Router.swapExactTokensForETH(
      tokenAmount,
      0, // accept any amount of ETH
      path,
      address(this),
      block.timestamp
    );
  }

  function distributeTokensToStakers(uint256 pid, uint256 tokenAmount) private {
    PoolInfo storage pool = pools[pid];
    for (uint256 i = 0; i < userList[pid].length; i++) {
      address userAddress = userList[pid][i];
      uint256 amount = tokenAmount.mul(userInfo[userAddress][pid].amount).div(
        pool.depositedAmount
      );
      userInfo[userAddress][pid].amount = userInfo[userAddress][pid].amount.add(
        amount
      );
      pool.depositedAmount = pool.depositedAmount.add(amount);
    }
  }

  function distributeETHToLpStakers(uint256 pid, uint256 amountETH) private {
    PoolInfo storage pool = pools[pid];
    for (uint256 i = 0; i < userList[pid].length; i++) {
      address userAddress = userList[pid][i];
      uint256 amount = amountETH.mul(userInfo[userAddress][pid].amount).div(
        pool.depositedAmount
      );
      sendEthToAddress(userAddress, amount);
    }
  }

  function sendEthToAddress(address _addr, uint256 amountETH) private {
    payable(_addr).call{value: amountETH}('');
  }

  function isTaxFree(uint256 pid, address _user) private view returns (bool) {
    UserInfo storage user = userInfo[_user][pid];
    if (user.amount > 0) {
      uint256 diff = block.timestamp.sub(user.lastClaim);
      if (diff > freeTaxDuration) {
        return true;
      }
    }
    return false;
  }


  function pendingRewards(uint256 pid, address _user)
    external
    view
    returns (uint256)
  {
    PoolInfo storage pool = pools[pid];
    UserInfo storage user = userInfo[_user][pid];
    uint256 accTokenPerShare = pool.accTokenPerShare;
    uint256 depositedAmount = pool.depositedAmount;
    if (block.number > pool.lastRewardBlock && depositedAmount != 0) {
      uint256 multiplier = block.number.sub(pool.lastRewardBlock);
      uint256 tokenReward = multiplier.mul(pool.rewardPerBlock);
      accTokenPerShare = accTokenPerShare.add(
        tokenReward.mul(1e12).div(depositedAmount)
      );
    }
    return
      user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt).add(
        user.pendingRewards
      );
  }

  function getPoolCount() external view returns (uint256) {
    return pools.length;
  }

  function getPoolDepositEthAmount(uint256 pid, uint256 amount)
    public
    view
    returns (uint256)
  {
    PoolInfo storage pool = pools[pid];

    if (pool.isNativePool) {
      return 0;
    }

    uint256 totalFee = nonNativeDepositDevFee.add(nonNativeDepositLpFee).add(
      nonNativeDepositLpFee
    );
    uint256 ethValue = tokenPrices[address(pool.stakeToken)]
      .mul(amount)
      .mul(totalFee)
      .div(10**20);
    return ethValue;
  }

  function poolActionAvailable(
    uint256 pid,
    uint256 amount,
    address user
  ) public view returns (bool) {
    PoolInfo storage pool = pools[pid];

    if (pool.isNativePool) {
      return true;
    }

    uint256 maxAmount = getMaximumAvailableAmount(pid, user);
    return amount <= maxAmount;
  }

  function getMaximumAvailableAmount(uint256 pid, address user)
    public
    view
    returns (uint256)
  {
    PoolInfo storage pool = pools[pid];

    if (pool.isNativePool) {
      return 0;
    }

    uint256 decimals = ERC20(address(pool.stakeToken)).decimals();
    uint256 kawaBalance = pools[0].stakeToken.balanceOf(user).add(
      userInfo[user][0].amount
    );
    uint256 lpBalance = pools[kawaLpPoolId].stakeToken.balanceOf(user).add(
      userInfo[user][kawaLpPoolId].amount
    );
    uint256 defaultTokenAmount = (5000 * (10**18) * (10**decimals))
      .div(ethPrice)
      .div(tokenPrices[address(pool.stakeToken)]);

    if (
      kawaBalance >= 100 * (10**6) * (10**18) ||
      lpBalance >= 100 * (10**6) * kawaLpPricePerKawa
    ) {
      return defaultTokenAmount.mul(5000);
    }

    if (
      kawaBalance >= 250 * (10**6) * (10**18) ||
      lpBalance >= 250 * (10**6) * kawaLpPricePerKawa
    ) {
      return defaultTokenAmount.mul(8000);
    }

    if (
      kawaBalance >= 600 * (10**6) * (10**18) ||
      lpBalance >= 600 * (10**6) * kawaLpPricePerKawa
    ) {
      return defaultTokenAmount.mul(13000);
    }

    if (
      kawaBalance >= 1000 * (10**6) * (10**18) ||
      lpBalance >= 1000 * (10**6) * kawaLpPricePerKawa
    ) {
      return defaultTokenAmount.mul(20000);
    }

    return 0;
  }
}