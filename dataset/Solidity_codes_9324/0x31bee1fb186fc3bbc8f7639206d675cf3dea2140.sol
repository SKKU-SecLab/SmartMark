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

}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// Apache-2.0
pragma solidity 0.8.10;

interface IIdleCDOStrategy {

  function strategyToken() external view returns(address);

  function token() external view returns(address);

  function tokenDecimals() external view returns(uint256);

  function oneToken() external view returns(uint256);

  function redeemRewards(bytes calldata _extraData) external returns(uint256[] memory);

  function pullStkAAVE() external returns(uint256);

  function price() external view returns(uint256);

  function getRewardTokens() external view returns(address[] memory);

  function deposit(uint256 _amount) external returns(uint256);

  function redeem(uint256 _amount) external returns(uint256);

  function redeemUnderlying(uint256 _amount) external returns(uint256);

  function getApr() external view returns(uint256);

}// Apache-2.0
pragma solidity 0.8.10;


interface IERC20Detailed is IERC20Upgradeable {

  function name() external view returns(string memory);

  function symbol() external view returns(string memory);

  function decimals() external view returns(uint256);

}// Apache-2.0
pragma solidity 0.8.10;

interface IIdleCDOTrancheRewards {

  function stake(uint256 _amount) external;

  function stakeFor(address _user, uint256 _amount) external;

  function unstake(uint256 _amount) external;

  function depositReward(address _reward, uint256 _amount) external;

}// Apache-2.0
pragma solidity 0.8.10;

interface IStakedAave {

  function COOLDOWN_SECONDS() external view returns (uint256);

  function UNSTAKE_WINDOW() external view returns (uint256);

  function redeem(address to, uint256 amount) external;

  function transfer(address to, uint256 amount) external returns (bool);

  function cooldown() external;

  function balanceOf(address) external view returns (uint256);

  function stakersCooldowns(address) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}//Apache 2.0
pragma solidity 0.8.10;


abstract contract GuardedLaunchUpgradable is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {
  using SafeERC20Upgradeable for IERC20Upgradeable;


  uint256 public limit;
  address public governanceRecoveryFund;

  function __GuardedLaunch_init(uint256 _limit, address _governanceRecoveryFund, address _owner) internal {
    require(_governanceRecoveryFund != address(0), '0');
    require(_owner != address(0), '0');
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    limit = _limit;
    governanceRecoveryFund = _governanceRecoveryFund;
    transferOwnership(_owner);
  }

  function _guarded(uint256 _amount) internal view {
    uint256 _limit = limit;
    if (_limit == 0) {
      return;
    }
    require(getContractValue() + _amount <= _limit, '2');
  }

  function _checkOnlyOwner() internal view {
    require(owner() == msg.sender, '6');
  }

  function getContractValue() public virtual view returns (uint256);

  function _setLimit(uint256 _limit) external {
    _checkOnlyOwner();
    limit = _limit;
  }

  function transferToken(address _token, uint256 _value) external {
    _checkOnlyOwner();
    IERC20Upgradeable(_token).safeTransfer(governanceRecoveryFund, _value);
  }
}// MIT

pragma solidity ^0.8.0;

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


contract ERC20 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
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

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT
pragma solidity 0.8.10;


contract IdleCDOTranche is ERC20 {
  address public minter;

  constructor(
    string memory _name, // eg. IdleDAI
    string memory _symbol // eg. IDLEDAI
  ) ERC20(_name, _symbol) {
    minter = msg.sender;
  }

  function mint(address account, uint256 amount) external {
    require(msg.sender == minter, 'TRANCHE:!AUTH');
    _mint(account, amount);
  }

  function burn(address account, uint256 amount) external {
    require(msg.sender == minter, 'TRANCHE:!AUTH');
    _burn(account, amount);
  }
}// Apache-2.0
pragma solidity 0.8.10;


contract IdleCDOStorage {
  uint256 public constant FULL_ALLOC = 100000;
  uint256 public constant MAX_FEE = 20000;
  uint256 public constant ONE_TRANCHE_TOKEN = 10**18;
  bytes32 internal _lastCallerBlock;
  uint256 internal latestHarvestBlock;
  address public weth;
  address[] public incentiveTokens;
  address public token;
  address public guardian;
  uint256 public oneToken;
  address public rebalancer;
  IUniswapV2Router02 internal uniswapRouterV2;

  bool public allowAAWithdraw;
  bool public allowBBWithdraw;
  bool public revertIfTooLow;
  bool public skipDefaultCheck;

  address public strategy;
  address public strategyToken;
  address public AATranche;
  address public BBTranche;
  address public AAStaking;
  address public BBStaking;

  uint256 public trancheAPRSplitRatio; //
  uint256 public trancheIdealWeightRatio;
  uint256 public priceAA;
  uint256 public priceBB;
  uint256 public lastNAVAA;
  uint256 public lastNAVBB;
  uint256 public lastStrategyPrice;
  uint256 public unclaimedFees;
  uint256 public unlentPerc;

  uint256 public fee;
  address public feeReceiver;

  uint256 public idealRange;
  uint256 public releaseBlocksPeriod;
  uint256 internal harvestedRewards;
  address internal constant stkAave = address(0x4da27a545c0c5B758a6BA100e3a049001de870f5);
  address internal constant AAVE = address(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);
  bool internal isStkAAVEActive;
  address public referral;
  uint256 public feeSplit;
}// UNLICENSED
pragma solidity 0.8.10;




contract IdleCDO is PausableUpgradeable, GuardedLaunchUpgradable, IdleCDOStorage {
  using SafeERC20Upgradeable for IERC20Detailed;


  constructor() {
    token = address(1);
  }


  function initialize(
    uint256 _limit, address _guardedToken, address _governanceFund, address _owner, // GuardedLaunch args
    address _rebalancer,
    address _strategy,
    uint256 _trancheAPRSplitRatio, // for AA tranches, so eg 10000 means 10% interest to AA and 90% BB
    uint256 _trancheIdealWeightRatio, // for AA tranches, so eg 10000 means 10% of tranches are AA and 90% BB
    address[] memory _incentiveTokens
  ) external initializer {
    uint256 _idealRange = FULL_ALLOC / 10;
    require(token == address(0), '1');
    require(_rebalancer != address(0) && _strategy != address(0) && _guardedToken != address(0), "0");
    require( _trancheAPRSplitRatio <= FULL_ALLOC, '7');
    require(_trancheIdealWeightRatio <= (FULL_ALLOC - _idealRange), '7');
    require(_trancheIdealWeightRatio >= _idealRange, '5');
    PausableUpgradeable.__Pausable_init();
    GuardedLaunchUpgradable.__GuardedLaunch_init(_limit, _governanceFund, _owner);
    address _strategyToken = IIdleCDOStrategy(_strategy).strategyToken();
    string memory _symbol = IERC20Detailed(_strategyToken).symbol();
    AATranche = address(new IdleCDOTranche(_concat(string("IdleCDO AA Tranche - "), _symbol), _concat(string("AA_"), _symbol)));
    BBTranche = address(new IdleCDOTranche(_concat(string("IdleCDO BB Tranche - "), _symbol), _concat(string("BB_"), _symbol)));
    token = _guardedToken;
    strategy = _strategy;
    strategyToken = _strategyToken;
    rebalancer = _rebalancer;
    trancheAPRSplitRatio = _trancheAPRSplitRatio;
    trancheIdealWeightRatio = _trancheIdealWeightRatio;
    idealRange = _idealRange; // trancheIdealWeightRatio ± 10%
    uint256 _oneToken = 10**(IERC20Detailed(_guardedToken).decimals());
    oneToken = _oneToken;
    uniswapRouterV2 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    incentiveTokens = _incentiveTokens;
    priceAA = _oneToken;
    priceBB = _oneToken;
    unlentPerc = 2000; // 2%
    releaseBlocksPeriod = 1500; // about 1/4 of a day
    allowAAWithdraw = true;
    allowBBWithdraw = true;
    revertIfTooLow = true;
    _allowUnlimitedSpend(_guardedToken, _strategy);
    _allowUnlimitedSpend(strategyToken, _strategy);
    lastStrategyPrice = _strategyPrice();
    fee = 10000; // 10% performance fee
    feeReceiver = address(0xFb3bD022D5DAcF95eE28a6B07825D4Ff9C5b3814); // treasury multisig
    guardian = _owner;
    isStkAAVEActive = true;
  }


  function depositAA(uint256 _amount) external returns (uint256) {
    return _deposit(_amount, AATranche);
  }

  function depositBB(uint256 _amount) external returns (uint256) {
    return _deposit(_amount, BBTranche);
  }

  function withdrawAA(uint256 _amount) external returns (uint256) {
    require(!paused() || allowAAWithdraw, '3');
    return _withdraw(_amount, AATranche);
  }

  function withdrawBB(uint256 _amount) external returns (uint256) {
    require(!paused() || allowBBWithdraw, '3');
    return _withdraw(_amount, BBTranche);
  }


  function tranchePrice(address _tranche) external view returns (uint256) {
    return _tranchePrice(_tranche);
  }

  function getContractValue() public override view returns (uint256) {
    address _strategyToken = strategyToken;
    uint256 strategyTokenDecimals = IERC20Detailed(_strategyToken).decimals();
    return (_contractTokenBalance(_strategyToken) * _strategyPrice() / (10**(strategyTokenDecimals))) +
            _contractTokenBalance(token) -
            _lockedRewards() -
            unclaimedFees;
  }

  function getIdealApr(address _tranche) external view returns (uint256) {
    return _getApr(_tranche, trancheIdealWeightRatio);
  }

  function getApr(address _tranche) external view returns (uint256) {
    return _getApr(_tranche, getCurrentAARatio());
  }

  function getCurrentAARatio() public view returns (uint256) {
    uint256 AABal = _virtualBalance(AATranche);
    uint256 contractVal = AABal + _virtualBalance(BBTranche);
    if (contractVal == 0) {
      return 0;
    }
    return AABal * FULL_ALLOC / contractVal;
  }

  function virtualPrice(address _tranche) public view returns (uint256 _virtualPrice) {
    uint256 _lastNAVAA = lastNAVAA;
    uint256 _lastNAVBB = lastNAVBB;

    (_virtualPrice, ) = _virtualPricesAux(
      _tranche,
      getContractValue(), // nav
      _lastNAVAA + _lastNAVBB, // lastNAV
      _tranche == AATranche ? _lastNAVAA : _lastNAVBB, // lastTrancheNAV
      trancheAPRSplitRatio
    );
  }

  function getIncentiveTokens() external view returns (address[] memory) {
    return incentiveTokens;
  }


  function _deposit(uint256 _amount, address _tranche) internal whenNotPaused returns (uint256 _minted) {
    if (_amount == 0) {
      return _minted;
    }
    _guarded(_amount);
    _updateCallerBlock();
    _checkDefault();
    _updateAccounting();
    IERC20Detailed(token).safeTransferFrom(msg.sender, address(this), _amount);
    _minted = _mintShares(_amount, msg.sender, _tranche);
  }

  function _updateAccounting() internal {
    uint256 _lastNAVAA = lastNAVAA;
    uint256 _lastNAVBB = lastNAVBB;
    uint256 _lastNAV = _lastNAVAA + _lastNAVBB;
    uint256 nav = getContractValue();
    uint256 _aprSplitRatio = trancheAPRSplitRatio;

    if (nav > _lastNAV) {
      unclaimedFees += (nav - _lastNAV) * fee / FULL_ALLOC;
    }

    (uint256 _priceAA, uint256 _totalAAGain) = _virtualPricesAux(AATranche, nav, _lastNAV, _lastNAVAA, _aprSplitRatio);
    (uint256 _priceBB, uint256 _totalBBGain) = _virtualPricesAux(BBTranche, nav, _lastNAV, _lastNAVBB, _aprSplitRatio);

    lastNAVAA += _totalAAGain;
    lastNAVBB += _totalBBGain;
    priceAA = _priceAA;
    priceBB = _priceBB;
  }

  function _virtualBalance(address _tranche) internal view returns (uint256) {
    return IdleCDOTranche(_tranche).totalSupply() * virtualPrice(_tranche) / ONE_TRANCHE_TOKEN;
  }

  function _virtualPricesAux(
    address _tranche,
    uint256 _nav,
    uint256 _lastNAV,
    uint256 _lastTrancheNAV,
    uint256 _trancheAPRSplitRatio
  ) internal view returns (uint256 _virtualPrice, uint256 _totalTrancheGain) {
    if (_nav <= _lastNAV) {
      return (_tranchePrice(_tranche), 0);
    }

    uint256 trancheSupply = IdleCDOTranche(_tranche).totalSupply();
    if (_lastNAV == 0 || trancheSupply == 0) {
      return (oneToken, 0);
    }

    uint256 totalGain = _nav - _lastNAV;
    totalGain -= totalGain * fee / FULL_ALLOC;

    address _AATranche = AATranche;
    bool _isAATranche = _tranche == _AATranche;
    if (IdleCDOTranche(_isAATranche ? BBTranche : _AATranche).totalSupply() == 0) {
      _totalTrancheGain = totalGain;
    } else {
      uint256 totalBBGain = totalGain * (FULL_ALLOC - _trancheAPRSplitRatio) / FULL_ALLOC;
      _totalTrancheGain = _isAATranche ? (totalGain - totalBBGain) : totalBBGain;
    }
    _virtualPrice = (_lastTrancheNAV + _totalTrancheGain) * ONE_TRANCHE_TOKEN / trancheSupply;
  }

  function _mintShares(uint256 _amount, address _to, address _tranche) internal returns (uint256 _minted) {
    _minted = _amount * ONE_TRANCHE_TOKEN / _tranchePrice(_tranche);
    IdleCDOTranche(_tranche).mint(_to, _minted);
    if (_tranche == AATranche) {
      lastNAVAA += _amount;
    } else {
      lastNAVBB += _amount;
    }
  }

  function _depositFees() internal {
    uint256 _amount = unclaimedFees;
    if (_amount > 0) {
      address stakingRewards = AAStaking;
      bool isStakingRewardsActive = stakingRewards != address(0);
      address _feeReceiver = feeReceiver;
      address _referral = referral;
      uint256 _referralAmount;
      if (_referral != address(0)) {
        _referralAmount = _amount * feeSplit / FULL_ALLOC;
        _mintShares(_referralAmount, _referral, AATranche);
      }

      uint256 _minted = _mintShares(_amount - _referralAmount,
        isStakingRewardsActive ? address(this) : _feeReceiver,
        AATranche
      );
      unclaimedFees = 0;

      if (isStakingRewardsActive) {
        IIdleCDOTrancheRewards(stakingRewards).stakeFor(_feeReceiver, _minted);
      }
    }
  }

  function _withdraw(uint256 _amount, address _tranche) internal nonReentrant returns (uint256 toRedeem) {
    _checkSameTx();
    _checkDefault();
    _updateAccounting();
    if (_amount == 0) {
      _amount = IERC20Detailed(_tranche).balanceOf(msg.sender);
    }
    require(_amount > 0, '0');
    address _token = token;
    uint256 balanceUnderlying = _contractTokenBalance(_token);
    toRedeem = _amount * _tranchePrice(_tranche) / ONE_TRANCHE_TOKEN;
    if (toRedeem > balanceUnderlying) {
      toRedeem = _liquidate(toRedeem - balanceUnderlying, revertIfTooLow) + balanceUnderlying;
    }
    IdleCDOTranche(_tranche).burn(msg.sender, _amount);
    IERC20Detailed(_token).safeTransfer(msg.sender, toRedeem);

    if (_tranche == AATranche) {
      lastNAVAA -= toRedeem;
    } else {
      lastNAVBB -= toRedeem;
    }
  }

  function _checkDefault() internal {
    uint256 currPrice = _strategyPrice();
    if (!skipDefaultCheck) {
      require(lastStrategyPrice <= currPrice, "4");
    }
    lastStrategyPrice = currPrice;
  }

  function _strategyPrice() internal view returns (uint256) {
    return IIdleCDOStrategy(strategy).price();
  }

  function _liquidate(uint256 _amount, bool _revertIfNeeded) internal returns (uint256 _redeemedTokens) {
    _redeemedTokens = IIdleCDOStrategy(strategy).redeemUnderlying(_amount);
    if (_revertIfNeeded) {
      require(_redeemedTokens + 100 >= _amount, '5');
    }
    if (_redeemedTokens > _amount) {
      _redeemedTokens = _amount;
    }
  }

  function _updateIncentives() internal {
    uint256 _trancheIdealWeightRatio = trancheIdealWeightRatio;
    uint256 _trancheAPRSplitRatio = trancheAPRSplitRatio;
    uint256 _idealRange = idealRange;
    address _BBStaking = BBStaking;
    address _AAStaking = AAStaking;
    bool _isBBStakingActive = _BBStaking != address(0);
    bool _isAAStakingActive = _AAStaking != address(0);

    uint256 currAARatio;
    if (_isBBStakingActive && _isAAStakingActive) {
      currAARatio = getCurrentAARatio();
    }

    if (_isBBStakingActive && (!_isAAStakingActive || (currAARatio > (_trancheIdealWeightRatio + _idealRange)))) {
      return _depositIncentiveToken(_BBStaking, FULL_ALLOC);
    }
    if (_isAAStakingActive && (!_isBBStakingActive || (currAARatio < (_trancheIdealWeightRatio - _idealRange)))) {
      return _depositIncentiveToken(_AAStaking, FULL_ALLOC);
    }

    if (_isAAStakingActive) {
      _depositIncentiveToken(_AAStaking, _trancheAPRSplitRatio);
    }

    if (_isBBStakingActive) {
      _depositIncentiveToken(_BBStaking, FULL_ALLOC);
    }
  }

  function _depositIncentiveToken(address _stakingContract, uint256 _ratio) internal {
    address[] memory _incentiveTokens = incentiveTokens;
    for (uint256 i = 0; i < _incentiveTokens.length; i++) {
      address _incentiveToken = _incentiveTokens[i];
      uint256 _reward = _contractTokenBalance(_incentiveToken) * _ratio / FULL_ALLOC;
      if (_reward > 0) {
        IIdleCDOTrancheRewards(_stakingContract).depositReward(_incentiveToken, _reward);
      }
    }
  }

  function _sellReward(address _rewardToken, address[] memory _path, uint256 _amount, uint256 _minAmount)
    internal
    returns (uint256, uint256) {
    if (_amount == 0) {
      _amount = _contractTokenBalance(_rewardToken);
    }
    if (_amount == 0) {
      return (0, 0);
    }

    IUniswapV2Router02 _uniRouter = uniswapRouterV2;
    IERC20Detailed(_rewardToken).safeIncreaseAllowance(address(_uniRouter), _amount);
    uint256[] memory _amounts = _uniRouter.swapExactTokensForTokens(
      _amount,
      _minAmount,
      _path,
      address(this),
      block.timestamp + 1
    );
    return (_amounts[0], _amounts[_amounts.length - 1]);
  }

  function _sellAllRewards(IIdleCDOStrategy _strategy, uint256[] memory _sellAmounts, uint256[] memory _minAmount, bool[] memory _skipReward)
    internal
    returns (uint256[] memory _soldAmounts, uint256[] memory _swappedAmounts, uint256 _totSold) {
    address[] memory _incentiveTokens = incentiveTokens;
    address[] memory _rewards = _strategy.getRewardTokens();
    address _rewardToken;
    address[] memory _path = new address[](3);
    _path[1] = weth;
    _path[2] = token;
    _soldAmounts = new uint256[](_rewards.length);
    _swappedAmounts = new uint256[](_rewards.length);
    for (uint256 i = 0; i < _rewards.length; i++) {
      _rewardToken = _rewards[i];
      if (_skipReward[i] || _includesAddress(_incentiveTokens, _rewardToken)) { continue; }
      if (_rewardToken == stkAave) {
        _rewardToken = AAVE;
      }
      _path[0] = _rewardToken;
      (_soldAmounts[i], _swappedAmounts[i]) = _sellReward(_rewardToken, _path, _sellAmounts[i], _minAmount[i]);
      _totSold += _swappedAmounts[i];
    }
  }

  function _tranchePrice(address _tranche) internal view returns (uint256) {
    if (IdleCDOTranche(_tranche).totalSupply() == 0) {
      return oneToken;
    }
    return _tranche == AATranche ? priceAA : priceBB;
  }

  function _getApr(address _tranche, uint256 _AATrancheSplitRatio) internal view returns (uint256) {
    uint256 stratApr = IIdleCDOStrategy(strategy).getApr();
    uint256 _trancheAPRSplitRatio = trancheAPRSplitRatio;
    bool isAATranche = _tranche == AATranche;
    if (_AATrancheSplitRatio == 0) {
      return isAATranche ? 0 : stratApr;
    }
    return isAATranche ?
      stratApr * _trancheAPRSplitRatio / _AATrancheSplitRatio :
      stratApr * (FULL_ALLOC - _trancheAPRSplitRatio) / (FULL_ALLOC - _AATrancheSplitRatio);
  }

  function _lockedRewards() internal view returns (uint256 _locked) {
    uint256 _releaseBlocksPeriod = releaseBlocksPeriod;
    uint256 _blocksSinceLastHarvest = block.number - latestHarvestBlock;
    uint256 _harvestedRewards = harvestedRewards;

    if (_harvestedRewards > 1 && _blocksSinceLastHarvest < _releaseBlocksPeriod) {
      _locked = _harvestedRewards * (_releaseBlocksPeriod - _blocksSinceLastHarvest) / _releaseBlocksPeriod;
    }
  }

  function _claimStkAave() internal {
    if (!isStkAAVEActive) {
      return;
    }

    IStakedAave _stkAave = IStakedAave(stkAave);
    uint256 _stakersCooldown = _stkAave.stakersCooldowns(address(this));
    if (_stakersCooldown > 0) {
      uint256 _cooldownEnd = _stakersCooldown + _stkAave.COOLDOWN_SECONDS();
      if (_cooldownEnd < block.timestamp) {
        if (block.timestamp - _cooldownEnd <= _stkAave.UNSTAKE_WINDOW()) {
          _stkAave.redeem(address(this), type(uint256).max);
        }
      } else {
        return;
      }
    }

    IIdleCDOStrategy(strategy).pullStkAAVE();

    if (_stkAave.balanceOf(address(this)) > 0) {
      _stkAave.cooldown();
    }
  }


  function harvest(
    bool[] calldata _skipFlags,
    bool[] calldata _skipReward,
    uint256[] calldata _minAmount,
    uint256[] calldata _sellAmounts,
    bytes calldata _extraData
  ) external
    returns (uint256[][] memory _res) {
    _checkOnlyOwnerOrRebalancer();
    _res = new uint256[][](3);
    IIdleCDOStrategy _strategy = IIdleCDOStrategy(strategy);
    if (!_skipFlags[3]) {
      uint256 _totSold;

      if (!_skipFlags[0]) {
        _res[2] = _strategy.redeemRewards(_extraData);
        _claimStkAave();
        (_res[0], _res[1], _totSold) = _sellAllRewards(_strategy, _sellAmounts, _minAmount, _skipReward);
      }
      latestHarvestBlock = block.number;
      harvestedRewards = _totSold == 0 ? 1 : _totSold;

      _updateAccounting();

      if (!_skipFlags[2]) {
        _depositFees();
      }

      if (!_skipFlags[1]) {
        _updateIncentives();
      }
    }

    uint256 underlyingBal = _contractTokenBalance(token);
    uint256 idealUnlent = getContractValue() * unlentPerc / FULL_ALLOC;
    if (underlyingBal > idealUnlent) {
      _strategy.deposit(underlyingBal - idealUnlent);
    }
  }

  function liquidate(uint256 _amount, bool _revertIfNeeded) external returns (uint256) {
    _checkOnlyOwnerOrRebalancer();
    return _liquidate(_amount, _revertIfNeeded);
  }


  function setAllowAAWithdraw(bool _allowed) external {
    _checkOnlyOwner();
    allowAAWithdraw = _allowed;
  }

  function setAllowBBWithdraw(bool _allowed) external {
    _checkOnlyOwner();
    allowBBWithdraw = _allowed;
  }

  function setSkipDefaultCheck(bool _allowed) external {
    _checkOnlyOwner();
    skipDefaultCheck = _allowed;
  }

  function setRevertIfTooLow(bool _allowed) external {
    _checkOnlyOwner();
    revertIfTooLow = _allowed;
  }

  function setStrategy(address _strategy, address[] memory _incentiveTokens) external {
    _checkOnlyOwner();

    require(_strategy != address(0), '0');
    IERC20Detailed _token = IERC20Detailed(token);
    address _currStrategy = strategy;
    _removeAllowance(address(_token), _currStrategy);
    _removeAllowance(strategyToken, _currStrategy);
    strategy = _strategy;
    incentiveTokens = _incentiveTokens;
    address _newStrategyToken = IIdleCDOStrategy(_strategy).strategyToken();
    strategyToken = _newStrategyToken;
    _allowUnlimitedSpend(address(_token), _strategy);
    _allowUnlimitedSpend(_newStrategyToken, _strategy);
    lastStrategyPrice = _strategyPrice();
  }

  function setRebalancer(address _rebalancer) external {
    _checkOnlyOwner();
    require((rebalancer = _rebalancer) != address(0), '0');
  }

  function setFeeReceiver(address _feeReceiver) external {
    _checkOnlyOwner();
    require((feeReceiver = _feeReceiver) != address(0), '0');
  }

  function setReferral(address _referral) external {
    _checkOnlyOwner();
    referral = _referral;
  }

  function setGuardian(address _guardian) external {
    _checkOnlyOwner();
    require((guardian = _guardian) != address(0), '0');
  }

  function setFee(uint256 _fee) external {
    _checkOnlyOwner();
    require((fee = _fee) <= MAX_FEE, '7');
  }

  function setFeeSplit(uint256 _feeSplit) external {
    _checkOnlyOwner();
    require((feeSplit = _feeSplit) <= FULL_ALLOC, '8');
  }

  function setUnlentPerc(uint256 _unlentPerc) external {
    _checkOnlyOwner();
    require((unlentPerc = _unlentPerc) <= FULL_ALLOC, '7');
  }

  function setReleaseBlocksPeriod(uint256 _releaseBlocksPeriod) external {
    _checkOnlyOwner();
    releaseBlocksPeriod = _releaseBlocksPeriod;
  }

  function setIsStkAAVEActive(bool _isStkAAVEActive) external {
    _checkOnlyOwner();
    isStkAAVEActive = _isStkAAVEActive;
  }

  function setIdealRange(uint256 _idealRange) external {
    _checkOnlyOwner();
    require((idealRange = _idealRange) <= FULL_ALLOC, '7');
  }

  function setTrancheAPRSplitRatio(uint256 _trancheAPRSplitRatio) external {
    _checkOnlyOwner();
    require((trancheAPRSplitRatio = _trancheAPRSplitRatio) <= FULL_ALLOC, '7');
  }

  function setTrancheIdealWeightRatio(uint256 _trancheIdealWeightRatio) external {
    _checkOnlyOwner();
    require((_trancheIdealWeightRatio) >= idealRange, '5');
    require((trancheIdealWeightRatio = _trancheIdealWeightRatio) <= (FULL_ALLOC - idealRange), '7');
  }

  function setIncentiveTokens(address[] memory _incentiveTokens) external {
    _checkOnlyOwner();
    incentiveTokens = _incentiveTokens;
  }

  function setStakingRewards(address _AAStaking, address _BBStaking) external {
    _checkOnlyOwner();
    address _AATranche = AATranche;
    address _BBTranche = BBTranche;
    address[] memory _incentiveTokens = incentiveTokens;
    address _currAAStaking = AAStaking;
    address _currBBStaking = BBStaking;
    bool _isAAStakingActive = _currAAStaking != address(0);
    bool _isBBStakingActive = _currBBStaking != address(0);
    address _incentiveToken;
    for (uint256 i = 0; i < _incentiveTokens.length; i++) {
      _incentiveToken = _incentiveTokens[i];
      if (_isAAStakingActive) {
        _removeAllowance(_incentiveToken, _currAAStaking);
      }
      if (_isBBStakingActive) {
        _removeAllowance(_incentiveToken, _currBBStaking);
      }
    }
    if (_isAAStakingActive && _AATranche != address(0)) {
      _removeAllowance(_AATranche, _currAAStaking);
    }
    if (_isBBStakingActive && _BBTranche != address(0)) {
      _removeAllowance(_BBTranche, _currBBStaking);
    }

    AAStaking = _AAStaking;
    BBStaking = _BBStaking;

    _isAAStakingActive = _AAStaking != address(0);
    _isBBStakingActive = _BBStaking != address(0);

    for (uint256 i = 0; i < _incentiveTokens.length; i++) {
      _incentiveToken = _incentiveTokens[i];
      if (_isAAStakingActive) {
        _allowUnlimitedSpend(_incentiveToken, _AAStaking);
      }
      if (_isBBStakingActive) {
        _allowUnlimitedSpend(_incentiveToken, _BBStaking);
      }
    }

    if (_isAAStakingActive && _AATranche != address(0)) {
      _allowUnlimitedSpend(_AATranche, _AAStaking);
    }
    if (_isBBStakingActive && _BBTranche != address(0)) {
      _allowUnlimitedSpend(_BBTranche, _BBStaking);
    }
  }

  function emergencyShutdown() external {
    _checkOnlyOwnerOrGuardian();
    _pause();
    allowAAWithdraw = false;
    allowBBWithdraw = false;
    skipDefaultCheck = true;
    revertIfTooLow = true;
  }

  function pause() external  {
    _checkOnlyOwnerOrGuardian();
    _pause();
  }

  function unpause() external {
    _checkOnlyOwnerOrGuardian();
    _unpause();
  }


  function _checkOnlyOwnerOrGuardian() internal view {
    require(msg.sender == guardian || msg.sender == owner(), "6");
  }

  function _checkOnlyOwnerOrRebalancer() internal view {
    require(msg.sender == rebalancer || msg.sender == owner(), "6");
  }

  function _contractTokenBalance(address _token) internal view returns (uint256) {
    return IERC20Detailed(_token).balanceOf(address(this));
  }

  function _removeAllowance(address _token, address _spender) internal {
    IERC20Detailed(_token).safeApprove(_spender, 0);
  }

  function _allowUnlimitedSpend(address _token, address _spender) internal {
    IERC20Detailed(_token).safeIncreaseAllowance(_spender, type(uint256).max);
  }

  function _updateCallerBlock() internal {
    _lastCallerBlock = keccak256(abi.encodePacked(tx.origin, block.number));
  }

  function _checkSameTx() internal view {
    require(keccak256(abi.encodePacked(tx.origin, block.number)) != _lastCallerBlock, "8");
  }

  function _includesAddress(address[] memory _array, address _val) internal pure returns (bool) {
    for (uint256 i = 0; i < _array.length; i++) {
      if (_array[i] == _val) {
        return true;
      }
    }
    return false;
  }

  function _concat(string memory a, string memory b) internal pure returns (string memory) {
    return string(abi.encodePacked(a, b));
  }
}