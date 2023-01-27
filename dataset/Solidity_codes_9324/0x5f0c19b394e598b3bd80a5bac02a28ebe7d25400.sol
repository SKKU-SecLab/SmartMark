
pragma solidity 0.6.6;


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

contract ContextUpgradeSafe is Initializable {


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

contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {

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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

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
}

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

        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract IMlp {
    function makeOffer(address _token, uint _amount, uint _unlockDate, uint _endDate, uint _slippageTolerancePpm, uint _maxPriceVariationPpm) external virtual returns (uint offerId);

    function takeOffer(uint _pendingOfferId, uint _amount, uint _deadline) external virtual returns (uint activeOfferId);

    function cancelOffer(uint _offerId) external virtual;

    function release(uint256 _offerId, uint256 amount0Min, uint256 amount1Min, uint256 slippage, uint256 _deadline) external virtual;
}

abstract contract IFeesController {
    function feesTo() public view virtual returns (address);
    function setFeesTo(address) public virtual;

    function feesPpm() public view virtual returns (uint);
    function setFeesPpm(uint) public virtual;
}

abstract contract IRewardManager {
    function add(uint256 _allocPoint, address _newMlp) public virtual;
    function notifyDeposit(address _account, uint256 _amount) public virtual;
    function notifyWithdraw(address _account, uint256 _amount) public virtual;
    function getPoolSupply(address pool) public view virtual returns(uint);
    function getUserAmount(address pool, address user) public view virtual returns(uint);
}

contract Mlp is IMlp, Initializable, OwnableUpgradeSafe {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint256 constant private RATIO_MULTIPLIER = 1_000_000_000_000_000_000;
    uint256 constant public FULL_SLIPPAGE = 1000;
    uint256 constant public MAX_SLIPPAGE_TOLERANCE = 75;

    uint256 public endDate;
    address public submitter;
    uint256 public exceedingLiquidity;
    uint256 public bonusToken0;
    uint256 public reward0Rate;
    uint256 public reward0PerTokenStored;
    uint256 public bonusToken1;
    uint256 public reward1Rate;
    uint256 public reward1PerTokenStored;
    uint256 public lastUpdateTime;
    uint256 public pendingOfferCount;
    uint256 public activeOfferCount;

    IRewardManager public rewardManager;
    IUniswapV2Pair public uniswapPair;
    IFeesController public feesController;
    IUniswapV2Router02 public uniswapRouter;

    IUniswapV2Pair public safetyPair0;
    bool public isFirstTokenInSafetyPair0;
    IUniswapV2Pair public safetyPair1;
    bool public isFirstTokenInSafetyPair1;

    bool public doCheckSafetyPools;

    mapping(address => uint256) public userReward0PerTokenPaid;
    mapping(address => uint256) public userRewards0;
    mapping(address => uint256) public userReward1PerTokenPaid;
    mapping(address => uint256) public userRewards1;
    mapping(address => uint256) public directStakeBalances;
    mapping(uint256 => PendingOffer) public getPendingOffer;
    mapping(uint256 => ActiveOffer) public getActiveOffer;

    enum OfferStatus {PENDING, TAKEN, CANCELED}

    event OfferMade(uint256 id);
    event OfferTaken(uint256 pendingOfferId, uint256 activeOfferId);
    event OfferCanceled(uint256 id);
    event OfferReleased(uint256 offerId);
    event PayReward(uint256 amount0, uint256 amount1);

    struct PendingOffer {
        address owner;
        address token;
        uint256 amount;
        uint256 unlockDate;
        uint256 endDate;
        OfferStatus status;
        uint256 slippageTolerancePpm;
        uint256 maxPriceVariationPpm;
    }

    struct ActiveOffer {
        address user0;
        uint256 originalAmount0;
        address user1;
        uint256 originalAmount1;
        uint256 unlockDate;
        uint256 liquidity;
        bool released;
        uint256 maxPriceVariationPpm;
    }

    function initialize (
        address _feesController,
        address _uniswapPair,
        address _submitter,
        uint256 _endDate,
        address _uniswapRouter,
        address _rewardManager,
        uint256 _bonusTokenAmount0,
        uint256 _bonusTokenAmount1,
        address _safetyPair0,
        address _safetyPair1,
        bool _isFirstTokenInPair0,
        bool _isFirstTokenInPair1
    ) public initializer {
        OwnableUpgradeSafe.__Ownable_init();
        feesController = IFeesController(_feesController);
        uniswapPair = IUniswapV2Pair(_uniswapPair);
        endDate = _endDate;
        submitter = _submitter;
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        rewardManager = IRewardManager(_rewardManager);

        uint256 remainingTime = _endDate.sub(block.timestamp);
        bonusToken0 = _bonusTokenAmount0;
        reward0Rate = _bonusTokenAmount0 / remainingTime;
        bonusToken1 = _bonusTokenAmount1;
        reward1Rate = _bonusTokenAmount1 / remainingTime;
        lastUpdateTime = block.timestamp;

        safetyPair0 = IUniswapV2Pair(_safetyPair0);
        isFirstTokenInSafetyPair0 = _isFirstTokenInPair0;
        safetyPair1 = IUniswapV2Pair(_safetyPair1);
        isFirstTokenInSafetyPair1 = _isFirstTokenInPair1;

        doCheckSafetyPools = true;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, endDate);
    }

    function reward0PerToken() public view returns (uint256) {

        uint256 totalSupply = rewardManager.getPoolSupply(address(this));
        if (totalSupply == 0) {
            return reward0PerTokenStored;
        }
        return
            reward0PerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(reward0Rate)
                    .mul(1e18) / totalSupply
            );
    }

    function reward1PerToken() public view returns (uint256) {

        uint256 totalSupply = rewardManager.getPoolSupply(address(this));
        if (totalSupply == 0) {
            return reward1PerTokenStored;
        }
        return
            reward1PerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(reward1Rate)
                    .mul(1e18) / totalSupply
            );
    }

    function rewardEarned(address account)
        public
        view
        returns (uint256 reward0Earned, uint256 reward1Earned)
    {

        uint256 balance = rewardManager.getUserAmount(address(this), account);
        reward0Earned = (balance.mul(
            reward0PerToken().sub(userReward0PerTokenPaid[account])
        ) / 1e18)
            .add(userRewards0[account]);
        reward1Earned = (balance.mul(
            reward1PerToken().sub(userReward1PerTokenPaid[account])
        ) / 1e18)
            .add(userRewards1[account]);
    }

    function updateRewards(address account) internal {

        reward0PerTokenStored = reward0PerToken();
        reward1PerTokenStored = reward1PerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            (uint256 earned0, uint256 earned1) = rewardEarned(account);
            userRewards0[account] = earned0;
            userRewards1[account] = earned1;
            userReward0PerTokenPaid[account] = reward0PerTokenStored;
            userReward1PerTokenPaid[account] = reward1PerTokenStored;
        }
    }

    function payRewards(address account) public {

        updateRewards(account);
        (uint256 reward0, uint256 reward1) = rewardEarned(account);
        if (reward0 > 0) {
            userRewards0[account] = 0;
            IERC20(uniswapPair.token0()).safeTransfer(account, reward0);
        }
        if (reward1 > 0) {
            userRewards1[account] = 0;
            IERC20(uniswapPair.token1()).safeTransfer(account, reward1);
        }
        if (reward0 > 0 || reward1 > 0) {
            emit PayReward(reward0, reward1);
        }
    }

    function _notifyDeposit(address account, uint256 amount) internal {

        updateRewards(account);
        rewardManager.notifyDeposit(account, amount);
    }

    function _notifyWithdraw(address account, uint256 amount) internal {

        updateRewards(account);
        rewardManager.notifyWithdraw(account, amount);
    }

    function makeOffer(
        address _token,
        uint256 _amount,
        uint256 _unlockDate,
        uint256 _endDate,
        uint256 _slippageTolerancePpm,
        uint256 _maxPriceVariationPpm
    ) external override returns (uint256 offerId) {

        require(_amount > 0);
        require(_endDate > now);
        require(_endDate <= _unlockDate);
        offerId = pendingOfferCount;
        pendingOfferCount++;
        getPendingOffer[offerId] = PendingOffer(
            msg.sender,
            _token,
            _amount,
            _unlockDate,
            _endDate,
            OfferStatus.PENDING,
            _slippageTolerancePpm,
            _maxPriceVariationPpm
        );
        IERC20 token;
        if (_token == address(uniswapPair.token0())) {
            token = IERC20(uniswapPair.token0());
        } else if (_token == address(uniswapPair.token1())) {
            token = IERC20(uniswapPair.token1());
        } else {
            require(false, "unknown token");
        }

        token.safeTransferFrom(msg.sender, address(this), _amount);
        emit OfferMade(offerId);
    }

    struct ProviderInfo {
        address user;
        uint256 amount;
        IERC20 token;
    }

    struct OfferInfo {
        uint256 deadline;
        uint256 slippageTolerancePpm;
    }

    function takeOffer(
        uint256 _pendingOfferId,
        uint256 _amount,
        uint256 _deadline
    ) external override returns (uint256 activeOfferId) {

        PendingOffer storage pendingOffer = getPendingOffer[_pendingOfferId];
        require(pendingOffer.status == OfferStatus.PENDING);
        require(pendingOffer.endDate > now);
        pendingOffer.status = OfferStatus.TAKEN;

        ProviderInfo memory provider0;
        ProviderInfo memory provider1;
        {
            if (pendingOffer.token == uniswapPair.token0()) {
                provider0 = ProviderInfo(
                    pendingOffer.owner,
                    pendingOffer.amount,
                    IERC20(uniswapPair.token0())
                );
                provider1 = ProviderInfo(
                    msg.sender,
                    _amount,
                    IERC20(uniswapPair.token1())
                );

                provider1.token.safeTransferFrom(
                    provider1.user,
                    address(this),
                    provider1.amount
                );
            } else {
                provider0 = ProviderInfo(
                    msg.sender,
                    _amount,
                    IERC20(uniswapPair.token0())
                );
                provider1 = ProviderInfo(
                    pendingOffer.owner,
                    pendingOffer.amount,
                    IERC20(uniswapPair.token1())
                );

                provider0.token.safeTransferFrom(
                    provider0.user,
                    address(this),
                    provider0.amount
                );
            }
        }

        uint256 feesAmount0 =
            provider0.amount.mul(feesController.feesPpm()) / 1000;
        uint256 feesAmount1 =
            provider1.amount.mul(feesController.feesPpm()) / 1000;

        provider0.amount = provider0.amount.sub(feesAmount0);
        provider1.amount = provider1.amount.sub(feesAmount1);

        provider0.token.safeTransfer(feesController.feesTo(), feesAmount0);
        provider1.token.safeTransfer(feesController.feesTo(), feesAmount1);

        uint256 spentAmount0;
        uint256 spentAmount1;
        uint256 liquidity;
        uint256[] memory returnedValues = new uint256[](3);

        {
            returnedValues = _provideLiquidity(
                provider0,
                provider1,
                OfferInfo(_deadline, pendingOffer.slippageTolerancePpm)
            );
            liquidity = returnedValues[0];
            spentAmount0 = returnedValues[1];
            spentAmount1 = returnedValues[2];
        }

        _notifyDeposit(provider0.user, liquidity / 2);
        _notifyDeposit(provider1.user, liquidity / 2);

        if (liquidity % 2 != 0) {
            exceedingLiquidity = exceedingLiquidity.add(1);
        }

        activeOfferId = activeOfferCount;
        activeOfferCount++;

        getActiveOffer[activeOfferId] = ActiveOffer(
            provider0.user,
            spentAmount0,
            provider1.user,
            spentAmount1,
            pendingOffer.unlockDate,
            liquidity,
            false,
            pendingOffer.maxPriceVariationPpm
        );

        emit OfferTaken(_pendingOfferId, activeOfferId);

        return activeOfferId;
    }

    function _provideLiquidity(
        ProviderInfo memory _provider0,
        ProviderInfo memory _provider1,
        OfferInfo memory _info
    ) internal returns (uint256[] memory) {

        _provider0.token.safeApprove(address(uniswapRouter), 0);
        _provider1.token.safeApprove(address(uniswapRouter), 0);

        _provider0.token.safeApprove(address(uniswapRouter), _provider0.amount);
        _provider1.token.safeApprove(address(uniswapRouter), _provider1.amount);

        uint256 amountMin0 =
            _provider0.amount.sub(
                _provider0.amount.mul(_info.slippageTolerancePpm) / 1000
            );
        uint256 amountMin1 =
            _provider1.amount.sub(
                _provider1.amount.mul(_info.slippageTolerancePpm) / 1000
            );

        uint256 spentAmount0;
        uint256 spentAmount1;
        uint256 liquidity;
        {
            (spentAmount0, spentAmount1, liquidity) = uniswapRouter
                .addLiquidity(
                address(_provider0.token),
                address(_provider1.token),
                _provider0.amount,
                _provider1.amount,
                amountMin0,
                amountMin1,
                address(this),
                _info.deadline
            );
        }
        if (spentAmount0 < _provider0.amount) {
            _provider0.token.safeTransfer(
                _provider0.user,
                _provider0.amount - spentAmount0
            );
        }
        if (spentAmount1 < _provider1.amount) {
            _provider1.token.safeTransfer(
                _provider1.user,
                _provider1.amount - spentAmount1
            );
        }
        uint256[] memory liq = new uint256[](3);
        liq[0] = liquidity;
        liq[1] = spentAmount0;
        liq[2] = spentAmount1;
        return (liq);
    }

    function cancelOffer(uint256 _offerId) external override {

        PendingOffer storage pendingOffer = getPendingOffer[_offerId];
        require(pendingOffer.status == OfferStatus.PENDING);
        pendingOffer.status = OfferStatus.CANCELED;
        IERC20(pendingOffer.token).safeTransfer(
            pendingOffer.owner,
            pendingOffer.amount
        );
        emit OfferCanceled(_offerId);
    }

    function release(uint256 _offerId, uint256 amount0Min, uint256 amount1Min, uint256 slippageTolerance, uint256 _deadline) external override {

        ActiveOffer storage offer = getActiveOffer[_offerId];

        require(
            msg.sender == offer.user0 || msg.sender == offer.user1,
            "unauthorized"
        );
        require(now > offer.unlockDate, "locked");
        require(!offer.released, "already released");
        require(slippageTolerance <= MAX_SLIPPAGE_TOLERANCE, "release: SLIPPAGE_TOO_BIG");

        if (doCheckSafetyPools) {
            uint256 totalSlippage = _getPriceSlippage();
            require(totalSlippage <= slippageTolerance, "release: BAD_SLIPPAGE_RATIO");
        }

        offer.released = true;

        IERC20 token0 = IERC20(uniswapPair.token0());
        IERC20 token1 = IERC20(uniswapPair.token1());

        IERC20(address(uniswapPair)).safeApprove(address(uniswapRouter), 0);

        IERC20(address(uniswapPair)).safeApprove(
            address(uniswapRouter),
            offer.liquidity
        );
        (uint256 amount0, uint256 amount1) =
            uniswapRouter.removeLiquidity(
                address(token0),
                address(token1),
                offer.liquidity,
                amount0Min,
                amount1Min,
                address(this),
                _deadline
            );

        _notifyWithdraw(offer.user0, offer.liquidity / 2);
        _notifyWithdraw(offer.user1, offer.liquidity / 2);

        if (
            _getPriceVariation(offer.originalAmount0, amount0) >
            offer.maxPriceVariationPpm
        ) {
            if (amount0 > offer.originalAmount0) {
                uint256 toSwap = amount0.sub(offer.originalAmount0);
                address[] memory path = new address[](2);
                path[0] = uniswapPair.token0();
                path[1] = uniswapPair.token1();
                token0.safeApprove(address(uniswapRouter), 0);
                token0.safeApprove(address(uniswapRouter), toSwap);

                uint256[] memory newAmounts =
                    uniswapRouter.swapExactTokensForTokens(
                        toSwap,
                        0,
                        path,
                        address(this),
                        _deadline
                    );
                amount0 = amount0.sub(toSwap);
                amount1 = amount1.add(newAmounts[1]);
            }
        }
        if (
            _getPriceVariation(offer.originalAmount1, amount1) >
            offer.maxPriceVariationPpm
        ) {
            if (amount1 > offer.originalAmount1) {
                uint256 toSwap = amount1.sub(offer.originalAmount1);
                address[] memory path = new address[](2);
                path[0] = uniswapPair.token1();
                path[1] = uniswapPair.token0();
                token1.safeApprove(address(uniswapRouter), 0);
                token1.safeApprove(address(uniswapRouter), toSwap);
                uint256[] memory newAmounts =
                    uniswapRouter.swapExactTokensForTokens(
                        toSwap,
                        0,
                        path,
                        address(this),
                        _deadline
                    );
                amount1 = amount1.sub(toSwap);
                amount0 = amount0.add(newAmounts[1]);
            }
        }

        token0.safeTransfer(offer.user0, amount0);
        payRewards(offer.user0);
        token1.safeTransfer(offer.user1, amount1);
        payRewards(offer.user1);

        emit OfferReleased(_offerId);
    }

    function setDoCheckSafetyPools(bool _doCheckSafetyPools) external onlyOwner {

        doCheckSafetyPools = _doCheckSafetyPools;
    }

    function _getPriceSlippage() private view returns (uint256) {


        uint256 safetyRatio0 = _calculateSafetyPairRatio(safetyPair0, isFirstTokenInSafetyPair0);
        uint256 safetyRatio1 = _calculateSafetyPairRatio(safetyPair1, isFirstTokenInSafetyPair1);

        uint256 safetyRatio = safetyRatio0.mul(RATIO_MULTIPLIER) / safetyRatio1;
        uint256 mlpTokensRatio = _calculateMlpPairRatio();

        uint256 totalSlippage = _getAbsoluteSubstraction(safetyRatio, mlpTokensRatio).mul(FULL_SLIPPAGE) / safetyRatio;

        return totalSlippage;
    }

    function _getAbsoluteSubstraction(uint256 x, uint256 y) private pure returns (uint256) {

        if (x > y) {
            return x - y;
        } else {
            return y - x;
        }
    }

    function _calculateSafetyPairRatio(IUniswapV2Pair safetyPair, bool isFirstTokenInPair) private view returns(uint256) {

        uint112 mlpTokenReserve;
        uint112 safetyTokenReserve;

        if (isFirstTokenInPair) {
            (mlpTokenReserve, safetyTokenReserve,) = safetyPair.getReserves();
        } else {
            (safetyTokenReserve, mlpTokenReserve,) = safetyPair.getReserves();
        }

        return (uint256(mlpTokenReserve)).mul(RATIO_MULTIPLIER) / (uint256(safetyTokenReserve));
    }

    function _calculateMlpPairRatio() private view returns(uint256) {

        (uint112 reserve0, uint112 reserve1,) = uniswapPair.getReserves();

        return (uint256(reserve0)).mul(RATIO_MULTIPLIER) / (uint256(reserve1));
    }

    function _getPriceVariation(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 sub;
        if (a > b) {
            sub = a.sub(b);
            return sub.mul(1000) / a;
        } else {
            sub = b.sub(a);
            return sub.mul(1000) / b;
        }
    }

    function directStake(uint256 _amount) external {

        require(_amount > 0, "cannot stake 0");
        IERC20(address(uniswapPair)).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        uint256 feesAmount = _amount.mul(feesController.feesPpm()) / 1000;

        uint256 stakeAmount = _amount.sub(feesAmount);

        IERC20(address(uniswapPair)).safeTransfer(feesController.feesTo(), feesAmount);

        _notifyDeposit(msg.sender, stakeAmount);
        directStakeBalances[msg.sender] = directStakeBalances[msg.sender].add(
            stakeAmount
        );
    }

    function directWithdraw(uint256 _amount) external {

        require(_amount > 0, "cannot withdraw 0");
        _notifyWithdraw(msg.sender, _amount);
        directStakeBalances[msg.sender] = directStakeBalances[msg.sender].sub(
            _amount
        );
        IERC20(address(uniswapPair)).safeTransfer(msg.sender, _amount);
    }

    function transferExceedingLiquidity() external {

        require(exceedingLiquidity != 0);
        IERC20(address(uniswapPair)).safeTransfer(
            feesController.feesTo(),
            exceedingLiquidity
        );
        exceedingLiquidity = 0;
    }
}