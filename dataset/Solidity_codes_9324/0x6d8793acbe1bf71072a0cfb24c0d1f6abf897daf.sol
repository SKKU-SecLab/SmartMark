
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


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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

    uint256[45] private __gap;
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

}// UNLICENSED
pragma solidity 0.8.10;
interface IBooster {

    function deposit(uint256 _pid, uint256 _amount, bool _stake) external;

    function depositAll(uint256 _pid, bool _stake) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function withdrawAll(uint256 _pid) external;

    function poolInfo(uint256 _pid) external view returns (address lpToken, address, address, address, address, bool);

    function earmarkRewards(uint256 _pid) external;

}// UNLICENSED
pragma solidity 0.8.10;

interface IBaseRewardPool {

    function balanceOf(address account) external view returns(uint256 amount);

    function pid() external view returns (uint256 _pid);

    function stakingToken() external view returns (address _stakingToken);

    function extraRewardsLength() external view returns (uint256 _length);

    function rewardToken() external view returns(address _rewardToken);

    function extraRewards() external view returns(address[] memory _extraRewards);

    function getReward() external;

    function stake(uint256 _amount) external;

    function stakeAll() external;

    function withdraw(uint256 amount, bool claim) external;

    function withdrawAll(bool claim) external;

    function withdrawAndUnwrap(uint256 amount, bool claim) external;

    function withdrawAllAndUnwrap(bool claim) external;

}// UNLICENSED
pragma solidity 0.8.10;

interface IMainRegistry {

    function get_pool_from_lp_token(address lp_token)
        external
        view
        returns (address);


    function get_underlying_coins(address pool)
        external
        view
        returns (address[8] memory);

}// UNLICENSED
pragma solidity 0.8.10;



abstract contract ConvexBaseStrategy is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC20Upgradeable,
    IIdleCDOStrategy
{
    using SafeERC20Upgradeable for IERC20Detailed;

    uint256 public ONE_CURVE_LP_TOKEN;
    uint256 public poolID;
    address public curveLpToken;
    address public curveDeposit;
    address public depositor;
    uint256 public depositPosition;
    address public rewardPool;
    uint256 public curveLpDecimals;
    address public constant MAIN_REGISTRY = address(0x90E00ACe148ca3b23Ac1bC8C240C2a7Dd9c2d7f5);
    address public constant BOOSTER =
        address(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
    address public constant WETH =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant ETH = 
        address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    address public whitelistedCDO;

    address[] public convexRewards;
    address[] public weth2DepositPath;
    address public weth2DepositRouter;
    mapping(address => address[]) public reward2WethPath;
    mapping(address => address) public rewardRouter;

    uint256 public totalLpTokensStaked;
    uint256 public totalLpTokensLocked;
    uint256 public releaseBlocksPeriod;
    uint256 public latestHarvestBlock;


    uint256 public BLOCKS_PER_YEAR;
    uint256 public latestPriceIncrease;
    uint256 public latestHarvestInterval;


    modifier onlyWhitelistedCDO() {
        require(msg.sender == whitelistedCDO, "Not whitelisted CDO");

        _;
    }

    constructor() {
        curveLpToken = address(1);
    }


    struct CurveArgs {
        address deposit;
        address depositor;
        uint256 depositPosition;
    }

    struct Reward {
        address reward;
        address router;
        address[] path;
    }

    struct Weth2Deposit {
        address router;
        address[] path;
    }

    function initialize(
        uint256 _poolID,
        address _owner,
        uint256 _releasePeriod,
        CurveArgs memory _curveArgs,
        Reward[] memory _rewards,
        Weth2Deposit memory _weth2Deposit
    ) public initializer {
        require(curveLpToken == address(0), "Initialized");
        require(_curveArgs.depositPosition < _curveUnderlyingsSize(), "Deposit token position invalid");

        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

        (address _crvLp, , , address _rewardPool, , bool shutdown) = IBooster(BOOSTER).poolInfo(_poolID);
        curveLpToken = _crvLp;

        address _deposit = _curveArgs.deposit == WETH ? ETH : _curveArgs.deposit;

        require(!shutdown, "Convex Pool is not active");
        require(_deposit == _curveUnderlyingCoins(_crvLp, _curveArgs.depositPosition), "Deposit token invalid");

        ERC20Upgradeable.__ERC20_init(
            string(abi.encodePacked("Idle ", IERC20Detailed(_crvLp).name(), " Convex Strategy")),
            string(abi.encodePacked("idleCvx", IERC20Detailed(_crvLp).symbol()))
        );

        poolID = _poolID;
        rewardPool = _rewardPool;
        curveLpDecimals = IERC20Detailed(_crvLp).decimals();
        ONE_CURVE_LP_TOKEN = 10**(curveLpDecimals);
        curveDeposit = _curveArgs.deposit;
        depositor = _curveArgs.depositor;
        depositPosition = _curveArgs.depositPosition;
        releaseBlocksPeriod = _releasePeriod;
        setBlocksPerYear(2465437); // given that blocks are mined at a 13.15s/block rate

        IERC20Detailed(_crvLp).approve(BOOSTER, type(uint256).max);

        for (uint256 i = 0; i < _rewards.length; i++) {
            addReward(_rewards[i].reward, _rewards[i].router, _rewards[i].path);
        }

        if (_curveArgs.deposit != WETH) setWeth2Deposit(_weth2Deposit.router, _weth2Deposit.path);

        transferOwnership(_owner);
    }


    function strategyToken() external view override returns (address) {
        return address(this);
    }

    function oneToken() external view override returns (uint256) {
        return ONE_CURVE_LP_TOKEN;
    }

    function token() external view override returns (address) {
        return curveLpToken;
    }

    function tokenDecimals() external view override returns (uint256) {
        return curveLpDecimals;
    }

    function decimals() public view override returns (uint8) {
        return uint8(curveLpDecimals); // should be safe
    }


    function deposit(uint256 _amount)
        external
        override
        onlyWhitelistedCDO
        returns (uint256 minted)
    {
        if (_amount > 0) {
            IERC20Detailed(curveLpToken).safeTransferFrom(msg.sender, address(this), _amount);
            minted = _depositAndMint(msg.sender, _amount, price());
        }
    }

    function redeem(uint256 _amount) external onlyWhitelistedCDO override returns (uint256 redeemed) {
        if(_amount > 0) {
            redeemed = _redeem(msg.sender, _amount, price());
        }
    }

    function redeemUnderlying(uint256 _amount)
        external
        override
        onlyWhitelistedCDO
        returns (uint256 redeemed)
    {
        if (_amount > 0) {
            uint256 _cachedPrice = price();
            uint256 _shares = (_amount * ONE_CURVE_LP_TOKEN) / _cachedPrice;
            redeemed = _redeem(msg.sender, _shares, _cachedPrice);
        }
    }

    function redeemRewards(bytes calldata _extraData)
        external
        override
        onlyWhitelistedCDO
        returns (uint256[] memory _balances)
    {
        address[] memory _convexRewards = convexRewards;
        _balances = new uint256[](_convexRewards.length + 2); 
        uint256[] memory _minAmountsWETH = new uint256[](_convexRewards.length);
        bool[] memory _skipSell = new bool[](_convexRewards.length);
        uint256 _minDepositToken;
        uint256 _minLpToken;
        (_minAmountsWETH, _skipSell, _minDepositToken, _minLpToken) = abi.decode(_extraData, (uint256[], bool[], uint256, uint256));

        IBaseRewardPool(rewardPool).getReward();

        address _reward;
        IERC20Detailed _rewardToken;
        uint256 _rewardBalance;
        IUniswapV2Router02 _router;

        for (uint256 i = 0; i < _convexRewards.length; i++) {
            if (_skipSell[i]) continue;

            _reward = _convexRewards[i];

            _rewardToken = IERC20Detailed(_reward);
            _rewardBalance = _rewardToken.balanceOf(address(this));

            if (_rewardBalance == 0) continue;

            _router = IUniswapV2Router02(
                rewardRouter[_reward]
            );

            _rewardToken.safeApprove(address(_router), 0);
            _rewardToken.safeApprove(address(_router), _rewardBalance);

            address[] memory _reward2WethPath = reward2WethPath[_reward];
            uint256[] memory _res = new uint256[](_reward2WethPath.length);
            _res = _router.swapExactTokensForTokens(
                _rewardBalance,
                _minAmountsWETH[i],
                _reward2WethPath,
                address(this),
                block.timestamp
            );
            _balances[i] = _res[_res.length - 1];
        }

        if (curveDeposit != WETH) {
            IERC20Detailed _weth = IERC20Detailed(WETH);
            IUniswapV2Router02 _wethRouter = IUniswapV2Router02(
                weth2DepositRouter
            );

            uint256 _wethBalance = _weth.balanceOf(address(this));
            _weth.safeApprove(address(_wethRouter), 0);
            _weth.safeApprove(address(_wethRouter), _wethBalance);

            address[] memory _weth2DepositPath = weth2DepositPath;
            uint256[] memory _res = new uint256[](_weth2DepositPath.length);
            _res = _wethRouter.swapExactTokensForTokens(
                _wethBalance,
                _minDepositToken,
                _weth2DepositPath,
                address(this),
                block.timestamp
            );
            _balances[_convexRewards.length] = _res[_res.length - 1];
        }

        IERC20Detailed _curveLpToken = IERC20Detailed(curveLpToken);
        uint256 _curveLpBalanceBefore = _curveLpToken.balanceOf(address(this));
        _depositInCurve(_minLpToken);
        uint256 _curveLpBalanceAfter = _curveLpToken.balanceOf(address(this));
        uint256 _gainedLpTokens = (_curveLpBalanceAfter - _curveLpBalanceBefore);

        _balances[_convexRewards.length + 1] = _gainedLpTokens;
        
        if (_curveLpBalanceAfter > 0) {
            _stakeConvex(_curveLpBalanceAfter);

            latestHarvestInterval = (block.number - latestHarvestBlock);
            latestHarvestBlock = block.number;
            totalLpTokensLocked = _gainedLpTokens;
            
            latestPriceIncrease = (_gainedLpTokens * ONE_CURVE_LP_TOKEN) / totalSupply();
        }
    }


    function price() public view override returns (uint256 _price) {
        uint256 _totalSupply = totalSupply();

        if (_totalSupply == 0) {
            _price = ONE_CURVE_LP_TOKEN;
        } else {
            _price =
                ((totalLpTokensStaked - _lockedLpTokens()) *
                    ONE_CURVE_LP_TOKEN) /
                _totalSupply;
        }
    }

    function getApr() external view override returns (uint256) {
        return latestPriceIncrease * (BLOCKS_PER_YEAR / latestHarvestInterval) * 100;
    }

    function getRewardTokens()
        external
        view
        override
        returns (address[] memory rewardTokens) {}


    function pullStkAAVE() external pure override returns (uint256) {
        return 0;
    }

    function transferToken(
        address _token,
        uint256 value,
        address _to
    ) external onlyOwner nonReentrant {
        IERC20Detailed(_token).safeTransfer(_to, value);
    }

    function setBlocksPerYear(uint256 blocksPerYear) public onlyOwner {
        require(blocksPerYear != 0, "Blocks per year cannot be zero");
        BLOCKS_PER_YEAR = blocksPerYear;
    }

    function setRouterForReward(address _reward, address _newRouter)
        external
        onlyOwner
    {
        require(_newRouter != address(0), "Router is address zero");
        rewardRouter[_reward] = _newRouter;
    }

    function setPathForReward(address _reward, address[] memory _newPath)
        external
        onlyOwner
    {
        _validPath(_newPath, WETH);
        reward2WethPath[_reward] = _newPath;
    }

    function setWeth2Deposit(address _router, address[] memory _path)
        public
        onlyOwner
    {
        address _curveDeposit = curveDeposit;

        require(_curveDeposit != WETH, "Deposit asset is WETH");

        _validPath(_path, _curveDeposit);
        weth2DepositRouter = _router;
        weth2DepositPath = _path;
    }

    function addReward(
        address _reward,
        address _router,
        address[] memory _path
    ) public onlyOwner {
        _validPath(_path, WETH);

        convexRewards.push(_reward);
        rewardRouter[_reward] = _router;
        reward2WethPath[_reward] = _path;
    }

    function removeReward(address _reward) external onlyOwner {
        address[] memory _newConvexRewards = new address[](
            convexRewards.length - 1
        );

        uint256 currentI = 0;
        for (uint256 i = 0; i < convexRewards.length; i++) {
            if (convexRewards[i] == _reward) continue;
            _newConvexRewards[currentI] = convexRewards[i];
            currentI += 1;
        }

        convexRewards = _newConvexRewards;

        delete rewardRouter[_reward];
        delete reward2WethPath[_reward];
    }

    function setWhitelistedCDO(address _cdo) external onlyOwner {
        require(_cdo != address(0), "IS_0");
        whitelistedCDO = _cdo;
    }


    function _curveUnderlyingsSize() internal pure virtual returns (uint256);

    function _depositInCurve(uint256 _minLpTokens) internal virtual;

    function _curvePool(address _curveLpToken) internal view virtual returns (address) {
        return IMainRegistry(MAIN_REGISTRY).get_pool_from_lp_token(_curveLpToken);
    }

    function _curveUnderlyingCoins(address _curveLpToken, uint256 _position) internal view virtual returns (address) {
        address[8] memory _coins = IMainRegistry(MAIN_REGISTRY).get_underlying_coins(_curvePool(_curveLpToken));
        return _coins[_position];
    }

    function _stakeConvex(uint256 _lpTokens) internal {
        totalLpTokensStaked += _lpTokens;
        IBooster(BOOSTER).depositAll(poolID, true);
    }

    function _depositAndMint(
        address _account,
        uint256 _lpTokens,
        uint256 _price
    ) internal returns (uint256 minted) {
        _stakeConvex(_lpTokens);

        minted = (_lpTokens * ONE_CURVE_LP_TOKEN) / _price;
        _mint(_account, minted);
    }

    function _redeem(
        address _account,
        uint256 _shares,
        uint256 _price
    ) internal returns (uint256 redeemed) {
        redeemed = (_shares * _price) / ONE_CURVE_LP_TOKEN;
        totalLpTokensStaked -= redeemed;

        IERC20Detailed _curveLpToken = IERC20Detailed(curveLpToken);

        _burn(_account, _shares);

        IBaseRewardPool(rewardPool).withdraw(redeemed, false);
        IBooster(BOOSTER).withdraw(poolID, redeemed);

        _curveLpToken.safeTransfer(_account, redeemed);
    }

    function _lockedLpTokens() internal view returns (uint256 _locked) {
        uint256 _releaseBlocksPeriod = releaseBlocksPeriod;
        uint256 _blocksSinceLastHarvest = block.number - latestHarvestBlock;
        uint256 _totalLockedLpTokens = totalLpTokensLocked;

        if (_totalLockedLpTokens > 0 && _blocksSinceLastHarvest < _releaseBlocksPeriod) {
            _locked = _totalLockedLpTokens * (_releaseBlocksPeriod - _blocksSinceLastHarvest) / _releaseBlocksPeriod;
        }
    }

    function _validPath(address[] memory _path, address _out) internal pure {
        require(_path.length >= 2, "Path length less than 2");
        require(_path[_path.length - 1] == _out, "Last asset should be WETH");
    }
}// UNLICENSED
pragma solidity 0.8.10;

interface ICurveDeposit_2token {

    function get_virtual_price() external view returns (uint256);


    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount)
        external
        payable;


    function remove_liquidity_imbalance(
        uint256[2] calldata amounts,
        uint256 max_burn_amount
    ) external;


    function remove_liquidity(uint256 _amount, uint256[2] calldata amounts)
        external;


    function exchange(
        int128 from,
        int128 to,
        uint256 _from_amount,
        uint256 _min_to_amount
    ) external payable;


    function calc_token_amount(uint256[2] calldata amounts, bool deposit)
        external
        view
        returns (uint256);

}// based on https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code






pragma solidity 0.8.10;

interface IWETH9 {

    function balanceOf(address target) external view returns (uint256);

    function deposit() external payable ;

    function withdraw(uint wad) external ;

    function totalSupply() external view returns (uint) ;

    function approve(address guy, uint wad) external returns (bool) ;

    function transfer(address dst, uint wad) external returns (bool) ;

    function transferFrom(address src, address dst, uint wad) external returns (bool);


}// UNLICENSED
pragma solidity 0.8.10;


contract ConvexStrategyETH is ConvexBaseStrategy {

    using SafeERC20Upgradeable for IERC20Detailed;

    uint256 public constant CURVE_UNDERLYINGS_SIZE = 2;

    function _curveUnderlyingsSize() internal pure override returns(uint256) {

        return CURVE_UNDERLYINGS_SIZE;
    }

    function _depositInCurve(uint256 _minLpTokens) internal override {

        IWETH9 _weth = IWETH9(WETH);
        uint256 _balance = _weth.balanceOf(address(this));
        
        _weth.withdraw(_balance);

        uint256[2] memory _depositArray;
        _depositArray[depositPosition] = _balance;
        ICurveDeposit_2token(_curvePool(curveLpToken)).add_liquidity{value: _balance}(_depositArray, _minLpTokens);
    }

    receive() external payable {}
}