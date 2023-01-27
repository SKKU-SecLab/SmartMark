
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMathUpgradeable {

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

library SafeERC20Upgradeable {

    using SafeMathUpgradeable for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
    
}

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
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

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
}

contract PausableUpgradeable is Initializable, ContextUpgradeable {

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

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
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
}

contract SettAccessControl is Initializable {

    address public governance;
    address public strategist;
    address public keeper;

    function _onlyGovernance() internal view {

        require(msg.sender == governance, "onlyGovernance");
    }

    function _onlyGovernanceOrStrategist() internal view {

        require(msg.sender == strategist || msg.sender == governance, "onlyGovernanceOrStrategist");
    }

    function _onlyAuthorizedActors() internal view {

        require(msg.sender == keeper || msg.sender == governance, "onlyAuthorizedActors");
    }


    function setStrategist(address _strategist) external {

        _onlyGovernance();
        strategist = _strategist;
    }

    function setKeeper(address _keeper) external {

        _onlyGovernance();
        keeper = _keeper;
    }

    function setGovernance(address _governance) public {

        _onlyGovernance();
        governance = _governance;
    }

    uint256[50] private __gap;
}

library MathUpgradeable {

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

interface IController {

    function withdraw(address, uint256) external;


    function withdrawAll(address) external;


    function strategies(address) external view returns (address);


    function approvedStrategies(address, address) external view returns (address);


    function balanceOf(address) external view returns (uint256);


    function earn(address, uint256) external;


    function approveStrategy(address, address) external;


    function setStrategy(address, address) external;


    function setVault(address, address) external;


    function want(address) external view returns (address);


    function rewards() external view returns (address);


    function vaults(address) external view returns (address);

}

interface IStrategy {

    function want() external view returns (address);


    function deposit() external;


    function withdrawOther(address) external returns (uint256 balance);


    function withdraw(uint256) external;


    function withdrawAll() external returns (uint256);


    function balanceOf() external view returns (uint256);

    function balanceOfPool() external view returns (uint256);

    function balanceOfWant() external view returns (uint256);


    function getName() external pure returns (string memory);


    function setStrategist(address _strategist) external;


    function setWithdrawalFee(uint256 _withdrawalFee) external;


    function setPerformanceFeeStrategist(uint256 _performanceFeeStrategist) external;


    function setPerformanceFeeGovernance(uint256 _performanceFeeGovernance) external;


    function setGovernance(address _governance) external;


    function setController(address _controller) external;


    function controller() external returns (address);


    function governance() external returns (address);


    function tend() external;


    function harvest() external;

}

abstract contract BaseStrategy is PausableUpgradeable, SettAccessControl {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    event Withdraw(uint256 amount);
    event WithdrawAll(uint256 balance);
    event WithdrawOther(address token, uint256 amount);
    event SetStrategist(address strategist);
    event SetGovernance(address governance);
    event SetController(address controller);
    event SetWithdrawalFee(uint256 withdrawalFee);
    event SetPerformanceFeeStrategist(uint256 performanceFeeStrategist);
    event SetPerformanceFeeGovernance(uint256 performanceFeeGovernance);
    event Harvest(uint256 harvested, uint256 indexed blockNumber);
    event Tend(uint256 tended);

    address public want; // Want: Curve.fi renBTC/wBTC (crvRenWBTC) LP token

    uint256 public performanceFeeGovernance;
    uint256 public performanceFeeStrategist;
    uint256 public withdrawalFee;

    uint256 public constant MAX_FEE = 10000;

    address public controller;
    address public guardian;

    uint256 public withdrawalMaxDeviationThreshold;

    function __BaseStrategy_init(
        address _governance,
        address _strategist,
        address _controller,
        address _keeper,
        address _guardian
    ) public initializer whenNotPaused {
        __Pausable_init();
        governance = _governance;
        strategist = _strategist;
        keeper = _keeper;
        controller = _controller;
        guardian = _guardian;
        withdrawalMaxDeviationThreshold = 50;
    }


    function _onlyController() internal view {
        require(msg.sender == controller, "onlyController");
    }

    function _onlyAuthorizedActorsOrController() internal view {
        require(msg.sender == keeper || msg.sender == governance || msg.sender == controller, "onlyAuthorizedActorsOrController");
    }

    function _onlyAuthorizedPausers() internal view {
        require(msg.sender == guardian || msg.sender == governance, "onlyPausers");
    }

    function baseStrategyVersion() public view returns (string memory) {
        return "1.2";
    }

    function balanceOfWant() public view returns (uint256) {
        return IERC20Upgradeable(want).balanceOf(address(this));
    }

    function balanceOf() public virtual view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    function isTendable() public virtual view returns (bool) {
        return false;
    }

    function isProtectedToken(address token) public view returns (bool) {
        address[] memory protectedTokens = getProtectedTokens();
        for (uint256 i = 0; i < protectedTokens.length; i++) {
            if (token == protectedTokens[i]) {
                return true;
            }
        }
        return false;
    }


    function setGuardian(address _guardian) external {
        _onlyGovernance();
        guardian = _guardian;
    }

    function setWithdrawalFee(uint256 _withdrawalFee) external {
        _onlyGovernance();
        require(_withdrawalFee <= MAX_FEE, "base-strategy/excessive-withdrawal-fee");
        withdrawalFee = _withdrawalFee;
    }

    function setPerformanceFeeStrategist(uint256 _performanceFeeStrategist) external {
        _onlyGovernance();
        require(_performanceFeeStrategist <= MAX_FEE, "base-strategy/excessive-strategist-performance-fee");
        performanceFeeStrategist = _performanceFeeStrategist;
    }

    function setPerformanceFeeGovernance(uint256 _performanceFeeGovernance) external {
        _onlyGovernance();
        require(_performanceFeeGovernance <= MAX_FEE, "base-strategy/excessive-governance-performance-fee");
        performanceFeeGovernance = _performanceFeeGovernance;
    }

    function setController(address _controller) external {
        _onlyGovernance();
        controller = _controller;
    }

    function setWithdrawalMaxDeviationThreshold(uint256 _threshold) external {
        _onlyGovernance();
        require(_threshold <= MAX_FEE, "base-strategy/excessive-max-deviation-threshold");
        withdrawalMaxDeviationThreshold = _threshold;
    }

    function deposit() public virtual whenNotPaused {
        _onlyAuthorizedActorsOrController();
        uint256 _want = IERC20Upgradeable(want).balanceOf(address(this));
        if (_want > 0) {
            _deposit(_want);
        }
        _postDeposit();
    }


    function withdrawAll() external virtual whenNotPaused returns (uint256 balance) {
        _onlyController();

        _withdrawAll();

        _transferToVault(IERC20Upgradeable(want).balanceOf(address(this)));
    }

    function withdraw(uint256 _amount) external virtual whenNotPaused {
        _onlyController();

        _withdrawSome(_amount);
        uint256 _postWithdraw = IERC20Upgradeable(want).balanceOf(address(this));

        if (_postWithdraw < _amount) {
            uint256 diff = _diff(_amount, _postWithdraw);

            require(diff <= _amount.mul(withdrawalMaxDeviationThreshold).div(MAX_FEE), "base-strategy/withdraw-exceed-max-deviation-threshold");
        }

        uint256 _toWithdraw = MathUpgradeable.min(_postWithdraw, _amount);

        uint256 _fee = _processWithdrawalFee(_toWithdraw);

        _transferToVault(_toWithdraw.sub(_fee));
    }

    function withdrawOther(address _asset) external virtual whenNotPaused returns (uint256 balance) {
        _onlyController();
        _onlyNotProtectedTokens(_asset);

        balance = IERC20Upgradeable(_asset).balanceOf(address(this));
        IERC20Upgradeable(_asset).safeTransfer(controller, balance);
    }


    function pause() external {
        _onlyAuthorizedPausers();
        _pause();
    }

    function unpause() external {
        _onlyGovernance();
        _unpause();
    }


    function _processWithdrawalFee(uint256 _amount) internal returns (uint256) {
        if (withdrawalFee == 0) {
            return 0;
        }

        uint256 fee = _amount.mul(withdrawalFee).div(MAX_FEE);
        IERC20Upgradeable(want).safeTransfer(IController(controller).rewards(), fee);
        return fee;
    }

    function _processFee(
        address token,
        uint256 amount,
        uint256 feeBps,
        address recipient
    ) internal returns (uint256) {
        if (feeBps == 0) {
            return 0;
        }
        uint256 fee = amount.mul(feeBps).div(MAX_FEE);
        IERC20Upgradeable(token).safeTransfer(recipient, fee);
        return fee;
    }

    function _transferToVault(uint256 _amount) internal {
        address _vault = IController(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20Upgradeable(want).safeTransfer(_vault, _amount);
    }

    function _diff(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "diff/expected-higher-number-in-first-position");
        return a.sub(b);
    }


    function _deposit(uint256 _want) internal virtual;

    function _postDeposit() internal virtual {
    }

    function _onlyNotProtectedTokens(address _asset) internal virtual;

    function getProtectedTokens() public virtual view returns (address[] memory) {
        return new address[](0);
    }

    function _withdrawAll() internal virtual;

    function _withdrawSome(uint256 _amount) internal virtual returns (uint256);


    function getName() external virtual pure returns (string memory);

    function balanceOfPool() public virtual view returns (uint256);

    uint256[49] private __gap;
}

contract BaseSwapper {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    function _safeApproveHelper(
        address token,
        address recipient,
        uint256 amount
    ) internal {

        IERC20Upgradeable(token).safeApprove(recipient, 0);
        IERC20Upgradeable(token).safeApprove(recipient, amount);
    }
}

interface IUniswapRouterV2 {

    function factory() external view returns (address);

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


    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


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

}

interface IUniswapV2Factory {

    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);


    function allPairs(uint256) external view returns (address pair);


    function allPairsLength() external view returns (uint256);


    function feeTo() external view returns (address);


    function feeToSetter() external view returns (address);


    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

}

contract UniswapSwapper is BaseSwapper {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    address internal constant uniswap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap router
    address internal constant sushiswap = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F; // Sushiswap router

    function _swapExactTokensForTokens(
        address router,
        address startToken,
        uint256 balance,
        address[] memory path
    ) internal {

        _safeApproveHelper(startToken, router, balance);
        IUniswapRouterV2(router).swapExactTokensForTokens(balance, 0, path, address(this), now);
    }

    function _swapExactETHForTokens(
        address router,
        uint256 balance,
        address[] memory path
    ) internal {

        IUniswapRouterV2(uniswap).swapExactETHForTokens{value: balance}(0, path, address(this), now);
    }

    function _swapExactTokensForETH(
        address router,
        address startToken,
        uint256 balance,
        address[] memory path
    ) internal {

        _safeApproveHelper(startToken, router, balance);
        IUniswapRouterV2(router).swapExactTokensForETH(balance, 0, path, address(this), now);
    }

    function _getPair(
        address router,
        address token0,
        address token1
    ) internal view returns (address) {

        address factory = IUniswapRouterV2(router).factory();
        return IUniswapV2Factory(factory).getPair(token0, token1);
    }

    function _addMaxLiquidity(
        address router,
        address token0,
        address token1
    ) internal {

        uint256 _token0Balance = IERC20Upgradeable(token0).balanceOf(address(this));
        uint256 _token1Balance = IERC20Upgradeable(token1).balanceOf(address(this));

        _safeApproveHelper(token0, router, _token0Balance);
        _safeApproveHelper(token1, router, _token1Balance);

        IUniswapRouterV2(router).addLiquidity(token0, token1, _token0Balance, _token1Balance, 0, 0, address(this), block.timestamp);
    }

    function _addMaxLiquidityEth(address router, address token0) internal {

        uint256 _token0Balance = IERC20Upgradeable(token0).balanceOf(address(this));
        uint256 _ethBalance = address(this).balance;

        _safeApproveHelper(token0, router, _token0Balance);
        IUniswapRouterV2(router).addLiquidityETH{value: address(this).balance}(token0, _token0Balance, 0, 0, address(this), block.timestamp);
    }
}

interface IUnitVaultParameters {

    function tokenDebtLimit(address asset) external view returns (uint256);

}

interface IUnitVault {

    function calculateFee(
        address asset,
        address user,
        uint256 amount
    ) external view returns (uint256);


    function getTotalDebt(address asset, address user) external view returns (uint256);


    function debts(address asset, address user) external view returns (uint256);


    function collaterals(address asset, address user) external view returns (uint256);


    function tokenDebts(address asset) external view returns (uint256);

}

interface IUnitCDPManager {

    function exit(
        address asset,
        uint256 assetAmount,
        uint256 usdpAmount
    ) external returns (uint256);


    function join(
        address asset,
        uint256 assetAmount,
        uint256 usdpAmount
    ) external;


    function oracleRegistry() external view returns (address);

}

interface IUnitUsdOracle {

    function assetToUsd(address asset, uint256 amount) external view returns (uint256);

}

interface IUnitOracleRegistry {

    function oracleByAsset(address asset) external view returns (address);

}

abstract contract StrategyUnitProtocolMeta is BaseStrategy, UniswapSwapper {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    address public constant cdpMgr01 = 0x0e13ab042eC5AB9Fc6F43979406088B9028F66fA;
    address public constant unitVault = 0xb1cFF81b9305166ff1EFc49A129ad2AfCd7BCf19;
    address public constant unitVaultParameters = 0xB46F8CF42e504Efe8BEf895f848741daA55e9f1D;
    address public constant debtToken = 0x1456688345527bE1f37E9e627DA0837D6f08C925;
    address public constant eth_usd = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
    bool public useUnitUsdOracle = true;

    address public collateral;
    uint256 public collateralDecimal = 1e18;
    address public unitOracle;
    uint256 public collateralPriceDecimal = 1;
    bool public collateralPriceEth = false;

    uint256 public minRatio = 150;
    uint256 public ratioBuff = 200;
    uint256 public constant ratioBuffMax = 10000;
    uint256 public dustMinDebt = 10000;
    uint256 public constant Q112 = 2**112;


    function _onlyCDPInUse() internal view {
        uint256 collateralAmt = getCollateralBalance();
        require(collateralAmt > 0, "!zeroCollateral");

        uint256 debtAmt = getDebtBalance();
        require(debtAmt > 0, "!zeroDebt");
    }


    function getCollateralBalance() public view returns (uint256) {
        return IUnitVault(unitVault).collaterals(collateral, address(this));
    }

    function getDebtBalance() public view returns (uint256) {
        return IUnitVault(unitVault).getTotalDebt(collateral, address(this));
    }

    function getDebtWithoutFee() public view returns (uint256) {
        return IUnitVault(unitVault).debts(collateral, address(this));
    }		
	
    function getDueFee() public view returns (uint256) {
        uint256 totalDebt = getDebtBalance();
        uint256 borrowed = getDebtWithoutFee();
        return totalDebt > borrowed? totalDebt.sub(borrowed) : 0;
    }	

    function debtLimit() public view returns (uint256) {
        return IUnitVaultParameters(unitVaultParameters).tokenDebtLimit(collateral);
    }

    function debtUsed() public view returns (uint256) {
        return IUnitVault(unitVault).tokenDebts(collateral);
    }

    function balanceOfPool() public override view returns (uint256) {
        return getCollateralBalance();
    }

    function collateralValue(uint256 collateralAmt) public view returns (uint256) {
        uint256 collateralPrice = getLatestCollateralPrice();
        return collateralAmt.mul(collateralPrice).mul(1e18).div(collateralDecimal).div(collateralPriceDecimal); // debtToken in 1e18 decimal
    }

    function currentRatio() public view returns (uint256) {
        _onlyCDPInUse();
        uint256 collateralAmt = collateralValue(getCollateralBalance()).mul(100);
        uint256 debtAmt = getDebtBalance();
        return collateralAmt.div(debtAmt);
    }

    function calculateDebtFor(uint256 collateralAmt, bool borrow) public view returns (uint256) {
        uint256 maxDebt = collateralAmt > 0 ? collateralValue(collateralAmt).mul(ratioBuffMax).div(_getBufferedMinRatio(ratioBuffMax)) : 0;

        uint256 debtAmt = getDebtBalance();

        uint256 debt = 0;

        if (borrow && maxDebt >= debtAmt) {
            debt = maxDebt.sub(debtAmt);
        } else if (!borrow && debtAmt >= maxDebt) {
            debt = debtAmt.sub(maxDebt);
        }

        return (debt > 0) ? debt : 0;
    }

    function _getBufferedMinRatio(uint256 _multiplier) internal view returns (uint256) {
        require(ratioBuffMax > 0, "!ratioBufferMax");
        require(minRatio > 0, "!minRatio");
        return minRatio.mul(_multiplier).mul(ratioBuffMax.add(ratioBuff)).div(ratioBuffMax).div(100);
    }

    function borrowableDebt() public view returns (uint256) {
        uint256 collateralAmt = getCollateralBalance();
        return calculateDebtFor(collateralAmt, true);
    }

    function requiredPaidDebt(uint256 _redeemCollateralAmt) public view returns (uint256) {
        uint256 totalCollateral = getCollateralBalance();
        uint256 collateralAmt = _redeemCollateralAmt >= totalCollateral ? 0 : totalCollateral.sub(_redeemCollateralAmt);
        return calculateDebtFor(collateralAmt, false);
    }

    function _depositUSDP(uint256 _usdpAmt) internal virtual;

    function _withdrawUSDP(uint256 _usdpAmt) internal virtual;


    function getLatestCollateralPrice() public view returns (uint256) {
        if (useUnitUsdOracle) {
            address unitOracleRegistry = IUnitCDPManager(cdpMgr01).oracleRegistry();
            address unitUsdOracle = IUnitOracleRegistry(unitOracleRegistry).oracleByAsset(collateral);
            uint256 usdPriceInQ122 = IUnitUsdOracle(unitUsdOracle).assetToUsd(collateral, collateralDecimal);
            return uint256(usdPriceInQ122 / Q112).mul(collateralPriceDecimal).div(1e18); // usd price from unit protocol oracle in 1e18 decimal
        }

        require(unitOracle != address(0), "!_collateralOracle");

        (, int256 price, , , ) = IChainlinkAggregator(unitOracle).latestRoundData();

        if (price > 0) {
            if (collateralPriceEth) {
                (, int256 ethPrice, , , ) = IChainlinkAggregator(eth_usd).latestRoundData(); // eth price from chainlink in 1e8 decimal
                return uint256(price).mul(collateralPriceDecimal).mul(uint256(ethPrice)).div(1e8).div(collateralPriceEth ? 1e18 : 1);
            } else {
                return uint256(price).mul(collateralPriceDecimal).div(1e8);
            }
        } else {
            return 0;
        }
    }


    function setMinRatio(uint256 _minRatio) external {
        _onlyGovernance();
        minRatio = _minRatio;
    }

    function setRatioBuff(uint256 _ratioBuff) external {
        _onlyGovernance();
        ratioBuff = _ratioBuff;
    }

    function setDustMinDebt(uint256 _dustDebt) external {
        _onlyGovernance();
        dustMinDebt = _dustDebt;
    }

    function setUseUnitUsdOracle(bool _useUnitUsdOracle) external {
        _onlyGovernance();
        useUnitUsdOracle = _useUnitUsdOracle;
    }


    function addCollateralAndBorrow(uint256 _collateralAmt, uint256 _usdpAmt) internal {
        require(_usdpAmt.add(debtUsed()) < debtLimit(), "!exceedLimit");
        _safeApproveHelper(collateral, unitVault, _collateralAmt);
        IUnitCDPManager(cdpMgr01).join(collateral, _collateralAmt, _usdpAmt);
    }

    function repayAndRedeemCollateral(uint256 _collateralAmt, uint256 _usdpAmt) internal {
        _safeApproveHelper(debtToken, unitVault, _usdpAmt);
        IUnitCDPManager(cdpMgr01).exit(collateral, _collateralAmt, _usdpAmt);
    }


    function keepMinRatio() external {
        _onlyCDPInUse();
        _onlyAuthorizedActorsOrController();

        uint256 requiredPaidback = requiredPaidDebt(0);
        if (requiredPaidback > 0) {
            _withdrawUSDP(requiredPaidback);

            uint256 _currentDebtVal = IERC20Upgradeable(debtToken).balanceOf(address(this));
            uint256 _actualPaidDebt = _currentDebtVal;
            uint256 _totalDebtWithoutFee = getDebtWithoutFee();
            uint256 _fee = getDebtBalance().sub(_totalDebtWithoutFee);

            require(_actualPaidDebt > _fee, "!notEnoughForFee");
            _actualPaidDebt = _actualPaidDebt.sub(_fee); // unit protocol will charge fee first
            _actualPaidDebt = _capMaxDebtPaid(_actualPaidDebt, _totalDebtWithoutFee);

            require(_currentDebtVal >= _actualPaidDebt.add(_fee), "!notEnoughRepayment");
            repayAndRedeemCollateral(0, _actualPaidDebt);
        }
    }

    function _deposit(uint256 _want) internal override {
        if (_want > 0) {
            uint256 _newDebt = calculateDebtFor(_want.add(getCollateralBalance()), true);
            if (_newDebt > 0) {
                addCollateralAndBorrow(_want, _newDebt);
                uint256 wad = IERC20Upgradeable(debtToken).balanceOf(address(this));
                _depositUSDP(_newDebt > wad ? wad : _newDebt);
            }
        }
    }

    function _capMaxDebtPaid(uint256 _actualPaidDebt, uint256 _totalDebtWithoutFee) internal view returns (uint256) {
        uint256 _maxDebtToRepay = _totalDebtWithoutFee.sub(dustMinDebt);
        return _actualPaidDebt >= _maxDebtToRepay ? _maxDebtToRepay : _actualPaidDebt;
    }

    function _withdrawSome(uint256 _amount) internal override returns (uint256) {
        if (_amount == 0) {
            return _amount;
        }

        uint256 requiredPaidback = requiredPaidDebt(_amount);
        if (requiredPaidback > 0) {
            _withdrawUSDP(requiredPaidback);
        }

        bool _fullWithdraw = _amount >= balanceOfPool();
        uint256 _wantBefore = IERC20Upgradeable(want).balanceOf(address(this));
        if (!_fullWithdraw) {
            uint256 _currentDebtVal = IERC20Upgradeable(debtToken).balanceOf(address(this));
            uint256 _actualPaidDebt = _currentDebtVal;
            uint256 _totalDebtWithoutFee = getDebtWithoutFee();
            uint256 _fee = getDebtBalance().sub(_totalDebtWithoutFee);

            require(_actualPaidDebt > _fee, "!notEnoughForFee");
            _actualPaidDebt = _actualPaidDebt.sub(_fee); // unit protocol will charge fee first
            _actualPaidDebt = _capMaxDebtPaid(_actualPaidDebt, _totalDebtWithoutFee);

            require(_currentDebtVal >= _actualPaidDebt.add(_fee), "!notEnoughRepayment");
            repayAndRedeemCollateral(_amount, _actualPaidDebt);
        } else {
            require(IERC20Upgradeable(debtToken).balanceOf(address(this)) >= getDebtBalance(), "!notEnoughFullRepayment");
            repayAndRedeemCollateral(_amount, getDebtBalance());
            require(getDebtBalance() == 0, "!leftDebt");
            require(getCollateralBalance() == 0, "!leftCollateral");
        }

        uint256 _wantAfter = IERC20Upgradeable(want).balanceOf(address(this));
        return _wantAfter.sub(_wantBefore);
    }

    function _withdrawAll() internal override {
        _withdrawSome(balanceOfPool());
    }
}

interface IChainlinkAggregator {

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );


    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

}

interface IBaseRewardsPool {

    function balanceOf(address _account) external view returns (uint256);


    function withdraw(uint256 _amount, bool _claim) external returns (bool);


    function withdrawAndUnwrap(uint256 _amount, bool _claim) external returns (bool);


    function getReward() external returns (bool);


    function stake(uint256 _amount) external returns (bool);


    function stakeFor(address _account, uint256 _amount) external returns (bool);


    function getReward(address _account, bool _claimExtras) external returns (bool);


    function rewards(address _account) external view returns (uint256);


    function earned(address _account) external view returns (uint256);


    function stakingToken() external view returns (address);

}

interface IBooster {

    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }

    function poolInfo(uint256 _pid) external view returns (PoolInfo memory);


    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);


    function depositAll(uint256 _pid, bool _stake) external returns (bool);


    function withdraw(uint256 _pid, uint256 _amount) external returns (bool);


    function withdrawAll(uint256 _pid) external returns (bool);

}

interface ICvxMinter {

    function reductionPerCliff() external view returns (uint256);

    function totalCliffs() external view returns (uint256);

    function maxSupply() external view returns (uint256);

}

interface ICurveExchange {

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function get_dy(
        int128,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function calc_token_amount(uint256[2] calldata amounts, bool deposit) external view returns (uint256 amount);


    function add_liquidity(uint256[2] calldata amounts, uint256 min_mint_amount) external;


    function remove_liquidity(uint256 _amount, uint256[2] calldata min_amounts) external;


    function remove_liquidity_imbalance(uint256[2] calldata amounts, uint256 max_burn_amount) external;


    function remove_liquidity_one_coin(
        uint256 _token_amounts,
        int128 i,
        uint256 min_amount
    ) external;

}

interface ICurveFi {

    function get_virtual_price() external view returns (uint256 out);


    function add_liquidity(
        uint256[2] calldata amounts,
        uint256 min_mint_amount
    ) external;


    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount
    ) external;


    function add_liquidity(
        uint256[4] calldata amounts,
        uint256 min_mint_amount
    ) external;


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external returns (uint256 out);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external returns (uint256 out);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        uint256 deadline
    ) external;


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy,
        uint256 deadline
    ) external;


    function remove_liquidity(
        uint256 _amount,
        uint256 deadline,
        uint256[2] calldata min_amounts
    ) external;


    function remove_liquidity_imbalance(uint256[2] calldata amounts, uint256 deadline) external;


    function remove_liquidity_imbalance(uint256[3] calldata amounts, uint256 max_burn_amount) external;


    function remove_liquidity(uint256 _amount, uint256[3] calldata amounts) external;


    function remove_liquidity_imbalance(uint256[4] calldata amounts, uint256 max_burn_amount) external;


    function remove_liquidity(uint256 _amount, uint256[4] calldata amounts) external;


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 _min_amount
    ) external;


    function commit_new_parameters(
        int128 amplification,
        int128 new_fee,
        int128 new_admin_fee
    ) external;


    function apply_new_parameters() external;


    function revert_new_parameters() external;


    function commit_transfer_ownership(address _owner) external;


    function apply_transfer_ownership() external;


    function revert_transfer_ownership() external;


    function withdraw_admin_fees() external;


    function coins(int128 arg0) external returns (address out);


    function underlying_coins(int128 arg0) external returns (address out);


    function balances(int128 arg0) external returns (uint256 out);


    function A() external returns (int128 out);


    function fee() external returns (int128 out);


    function admin_fee() external returns (int128 out);


    function owner() external returns (address out);


    function admin_actions_deadline() external returns (uint256 out);


    function transfer_ownership_deadline() external returns (uint256 out);


    function future_A() external returns (int128 out);


    function future_fee() external returns (int128 out);


    function future_admin_fee() external returns (int128 out);


    function future_owner() external returns (address out);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 _i) external view returns (uint256 out);

}

interface ICurveGauge {

    function deposit(uint256 _value) external;


    function deposit(uint256 _value, address addr) external;


    function balanceOf(address arg0) external view returns (uint256);


    function withdraw(uint256 _value) external;


    function withdraw(uint256 _value, bool claim_rewards) external;


    function claim_rewards() external;


    function claim_rewards(address addr) external;


    function claimable_tokens(address addr) external view returns (uint256);


    function claimable_reward(address addr) external view returns (uint256);


    function integrate_fraction(address arg0) external view returns (uint256);

}

interface ICurveMintr {

    function mint(address) external;


    function minted(address arg0, address arg1) external view returns (uint256);

}

contract StrategyUnitProtocolRenbtc is StrategyUnitProtocolMeta {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address;
    using SafeMathUpgradeable for uint256;

    address public constant renbtc_collateral = 0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D;
    uint256 public constant renbtc_collateral_decimal = 1e8;
    address public constant renbtc_oracle = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;
    uint256 public constant renbtc_price_decimal = 1;
    bool public constant renbtc_price_eth = false;
    bool public harvestToRepay = false;

    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 public constant weth_decimal = 1e18;
    address public constant usdp3crv = 0x7Eb40E450b9655f4B3cC4259BCC731c63ff55ae6;
    address public constant usdp = debtToken;
    address public constant curvePool = 0x42d7025938bEc20B69cBae5A77421082407f053A;
    uint256 public constant usdp_decimal = 1e18;
	
    address public stakingPool = 0xF403C135812408BFbE8713b5A23a04b3D48AAE31;
    uint256 public stakingPoolId = 28;
    address public constant rewardTokenCRV = 0xD533a949740bb3306d119CC777fa900bA034cd52; 
    address public constant rewardTokenCVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address public rewardPool = 0x24DfFd1949F888F91A0c8341Fc98a3F280a782a8;
    
    uint256 public slippageRepayment = 500; // max 5%
    uint256 public slippageProtectionIn = 50; // max 0.5%
    uint256 public slippageProtectionOut = 50; // max 0.5%
    uint256 public keepCRV;
    uint256 public keepCVX;

    event RenBTCStratHarvest(
        uint256 crvHarvested,
        uint256 cvxHarvested,
        uint256 usdpRepaid,
        uint256 wantProcessed,
        uint256 governancePerformanceFee,
        uint256 strategistPerformanceFee
    );

    struct HarvestData {
        uint256 crvHarvested;
        uint256 cvxHarvested;
        uint256 usdpRepaid;
        uint256 wantProcessed;
        uint256 governancePerformanceFee;
        uint256 strategistPerformanceFee;
    }

    function initialize(
        address _governance,
        address _strategist,
        address _controller,
        address _keeper,
        address _guardian,
        address[1] memory _wantConfig,
        uint256[4] memory _feeConfig
    ) public initializer {

        __BaseStrategy_init(_governance, _strategist, _controller, _keeper, _guardian);

        require(_wantConfig[0] == renbtc_collateral, "!want");
        want = _wantConfig[0];
        collateral = renbtc_collateral;
        collateralDecimal = renbtc_collateral_decimal;
        unitOracle = renbtc_oracle;
        collateralPriceDecimal = renbtc_price_decimal;
        collateralPriceEth = renbtc_price_eth;

        performanceFeeGovernance = _feeConfig[0];
        performanceFeeStrategist = _feeConfig[1];
        withdrawalFee = _feeConfig[2];
        keepCRV = _feeConfig[3];
        keepCVX = keepCRV;
		
        minRatio = 150;
        ratioBuff = 200;
        useUnitUsdOracle = true;
        dustMinDebt = 10000;
		
        slippageRepayment = 500;
        slippageProtectionIn = 50;
        slippageProtectionOut = 50;
        stakingPoolId = 28;
    }

    
    function setSlippageRepayment(uint256 _repaymentSlippage) public{

        _onlyGovernance();
        require(_repaymentSlippage < MAX_FEE && _repaymentSlippage > 0, "!_repaymentSlippage");
        slippageRepayment = _repaymentSlippage;
    }

    function setStakingPoolId(uint256 _poolId) public{

        _onlyGovernance();
        stakingPoolId = _poolId;
    }

    function setStakingPool(address _pool) public{

        _onlyGovernance();
        stakingPool = _pool;
    }

    function setRewardPool(address _pool) public{

        _onlyGovernance();
        rewardPool = _pool;
    }

    function setSlippageProtectionIn(uint256 _slippage) external {

        _onlyGovernance();
        require(_slippage < MAX_FEE && _slippage > 0, "!_slippageProtectionIn");
        slippageProtectionIn = _slippage;
    }

    function setSlippageProtectionOut(uint256 _slippage) external {

        _onlyGovernance();
        require(_slippage < MAX_FEE && _slippage > 0, "!_slippageProtectionOut");
        slippageProtectionOut = _slippage;
    }

    function setKeepCRV(uint256 _keepCRV) external {

        _onlyGovernance();
        keepCRV = _keepCRV;
    }

    function setKeepCVX(uint256 _keepCVX) external {

        _onlyGovernance();
        keepCVX = _keepCVX;
    }

    function setHarvestToRepay(bool _repay) public{

        _onlyGovernance();
        harvestToRepay = _repay;
    }


    function harvest() external whenNotPaused returns (HarvestData memory) {

        _onlyAuthorizedActors();

        HarvestData memory harvestData;
        (uint256 _crvRecycled, uint256 _cvxRecycled) = _collectStakingRewards(harvestData);
				
        _convertRewards();
		
        uint256 _wethAmount = IERC20Upgradeable(weth).balanceOf(address(this));
        if (_wethAmount > 0){         
            harvestData.usdpRepaid = _repayDebt(_wethAmount); 
        }
		
        _wethAmount = IERC20Upgradeable(weth).balanceOf(address(this));
        if (_wethAmount > 0 && !harvestToRepay) {
            address[] memory path = new address[](2);
            path[0] = weth;
            path[1] = want;
            _swapExactTokensForTokens(uniswap, weth, _wethAmount, path);
        }

        harvestData.wantProcessed = IERC20Upgradeable(want).balanceOf(address(this));
        uint256 _wantDeposited;
        if (harvestData.wantProcessed > 0 && !harvestToRepay) {
            (harvestData.governancePerformanceFee, harvestData.strategistPerformanceFee) = _processPerformanceFees(harvestData.wantProcessed);

            _wantDeposited = IERC20Upgradeable(want).balanceOf(address(this));

            if (_wantDeposited > 0) {
                _deposit(_wantDeposited);
            }
        }

        emit RenBTCStratHarvest(harvestData.crvHarvested, harvestData.cvxHarvested, harvestData.usdpRepaid, harvestData.wantProcessed, harvestData.governancePerformanceFee, harvestData.strategistPerformanceFee);
        emit Harvest(_wantDeposited, block.number);

        return harvestData;
    }
	
    function _collectStakingRewards(HarvestData memory harvestData) internal returns(uint256, uint256){

        uint256 _before = IERC20Upgradeable(want).balanceOf(address(this));
        uint256 _beforeCrv = IERC20Upgradeable(rewardTokenCRV).balanceOf(address(this));
        uint256 _beforeCvx = IERC20Upgradeable(rewardTokenCVX).balanceOf(address(this));

        IBaseRewardsPool(rewardPool).getReward(address(this), true);
		
        uint256 _afterCrv = IERC20Upgradeable(rewardTokenCRV).balanceOf(address(this));
        uint256 _afterCvx = IERC20Upgradeable(rewardTokenCVX).balanceOf(address(this));

        harvestData.crvHarvested = _afterCrv.sub(_beforeCrv);
        harvestData.cvxHarvested = _afterCvx.sub(_beforeCvx);
        
        uint256 _crv = _afterCrv;
        uint256 _cvx = _afterCvx;

        uint256 _keepCrv = _crv.mul(keepCRV).div(MAX_FEE);
        uint256 _keepCvx = _cvx.mul(keepCVX).div(MAX_FEE);        
        IERC20Upgradeable(rewardTokenCRV).safeTransfer(IController(controller).rewards(), _keepCrv);
        IERC20Upgradeable(rewardTokenCVX).safeTransfer(IController(controller).rewards(), _keepCvx);

        uint256 _crvRecycled = _crv.sub(_keepCrv);
        uint256 _cvxRecycled = _cvx.sub(_keepCvx);
        return (_crvRecycled, _cvxRecycled);
    }
	
    function _repayDebt(uint256 _wethAmount) internal returns(uint256) {

        uint256 _repaidDebt;
        if (harvestToRepay){
            _repaidDebt = _swapRewardsToDebt(_wethAmount);                
        } else {		
            uint256 dueFee = getDueFee();
            if (dueFee > 0){		
                uint256 _swapIn = calcETHSwappedForFeeRepayment(dueFee, _wethAmount);			
                _repaidDebt = _swapRewardsToDebt(_swapIn);
				
                require(IERC20Upgradeable(debtToken).balanceOf(address(this)) >= dueFee, '!notEnoughRepaymentDuringHarvest');
				
                uint256 debtTotalBefore = getDebtBalance();
                repayAndRedeemCollateral(0, dueFee);
                require(getDebtBalance() < debtTotalBefore, '!repayDebtDuringHarvest');
            }			
        }
        return _repaidDebt;
    }
	
    function _convertRewards() internal {		

        uint256 _rewardCRV = IERC20Upgradeable(rewardTokenCRV).balanceOf(address(this));
        uint256 _rewardCVX = IERC20Upgradeable(rewardTokenCVX).balanceOf(address(this));

        if (_rewardCRV > 0) {
            address[] memory _swapPath = new address[](2);
            _swapPath[0] = rewardTokenCRV;
            _swapPath[1] = weth;
            _swapExactTokensForTokens(sushiswap, rewardTokenCRV, _rewardCRV, _swapPath);
        }

        if (_rewardCVX > 0) {
            address[] memory _swapPath = new address[](2);
            _swapPath[0] = rewardTokenCVX;
            _swapPath[1] = weth;
            _swapExactTokensForTokens(sushiswap, rewardTokenCVX, _rewardCVX, _swapPath);
        }
    }
	
    function _swapRewardsToDebt(uint256 _swapIn) internal returns (uint256){

        address[] memory _swapPath = new address[](2);
        _swapPath[0] = weth;
        _swapPath[1] = debtToken;
        uint256 _beforeDebt = IERC20Upgradeable(debtToken).balanceOf(address(this));
        _swapExactTokensForTokens(sushiswap, weth, _swapIn, _swapPath);
        return IERC20Upgradeable(debtToken).balanceOf(address(this)).sub(_beforeDebt);
    }
	
    function calcETHSwappedForFeeRepayment(uint256 _dueFee, uint256 _toSwappedETHBal) public view returns (uint256){

        (,int ethPrice,,,) = IChainlinkAggregator(eth_usd).latestRoundData();// eth price from chainlink in 1e8 decimal
        uint256 toSwapped = _dueFee.mul(weth_decimal).div(usdp_decimal).mul(1e8).div(uint256(ethPrice));
        uint256 _swapIn = toSwapped.mul(MAX_FEE.add(slippageRepayment)).div(MAX_FEE);
        return _swapIn > _toSwappedETHBal ? _toSwappedETHBal : _swapIn;
    }

    function _processPerformanceFees(uint256 _amount) internal returns (uint256 governancePerformanceFee, uint256 strategistPerformanceFee) {

        governancePerformanceFee = _processFee(want, _amount, performanceFeeGovernance, IController(controller).rewards());
        strategistPerformanceFee = _processFee(want, _amount, performanceFeeStrategist, strategist);
    }

    function estimateMinCrvLPFromDeposit(uint256 _usdpAmt) public view returns(uint256){

        uint256 _expectedOut = estimateRequiredUsdp3crv(_usdpAmt);
        _expectedOut = _expectedOut.mul(MAX_FEE.sub(slippageProtectionIn)).div(MAX_FEE);
        return _expectedOut;
    }

    function _depositUSDP(uint256 _usdpAmt) internal override {

        uint256 _maxSlip = estimateMinCrvLPFromDeposit(_usdpAmt);
        if (_usdpAmt > 0 && checkSlip(_usdpAmt, _maxSlip)) {
            _safeApproveHelper(debtToken, curvePool, _usdpAmt);
            uint256[2] memory amounts = [_usdpAmt, 0];
            ICurveFi(curvePool).add_liquidity(amounts, _maxSlip);
        }

        uint256 _usdp3crv = IERC20Upgradeable(usdp3crv).balanceOf(address(this));
        if (_usdp3crv > 0) {
            _safeApproveHelper(usdp3crv, stakingPool, _usdp3crv);
            IBooster(stakingPool).depositAll(stakingPoolId, true);
        }
    }

    function _withdrawUSDP(uint256 _usdpAmt) internal override {

        uint256 _requiredUsdp3crv = estimateRequiredUsdp3crv(_usdpAmt);
        _requiredUsdp3crv = _requiredUsdp3crv.mul(MAX_FEE.add(slippageProtectionOut)).div(MAX_FEE); // try to remove bit more

        uint256 _usdp3crv = IERC20Upgradeable(usdp3crv).balanceOf(address(this));
        uint256 _withdrawFromStaking = _usdp3crv < _requiredUsdp3crv ? _requiredUsdp3crv.sub(_usdp3crv) : 0;

        if (_withdrawFromStaking > 0) {
            uint256 maxInStaking = IBaseRewardsPool(rewardPool).balanceOf(address(this));
            uint256 _toWithdraw = maxInStaking < _withdrawFromStaking ? maxInStaking : _withdrawFromStaking;
            IBaseRewardsPool(rewardPool).withdrawAndUnwrap(_toWithdraw, false);
        }

        _usdp3crv = IERC20Upgradeable(usdp3crv).balanceOf(address(this));
        if (_usdp3crv > 0) {
            _requiredUsdp3crv = _requiredUsdp3crv > _usdp3crv ? _usdp3crv : _requiredUsdp3crv;
            uint256 maxSlippage = _requiredUsdp3crv.mul(MAX_FEE.sub(slippageProtectionOut)).div(MAX_FEE);
            _safeApproveHelper(usdp3crv, curvePool, _requiredUsdp3crv);
            ICurveFi(curvePool).remove_liquidity_one_coin(_requiredUsdp3crv, 0, maxSlippage);
        }
    }


    function virtualPriceToWant() public view returns (uint256) {

        return ICurveFi(curvePool).get_virtual_price();
    }

    function estimateRequiredUsdp3crv(uint256 _usdpAmt) public view returns (uint256) {

        return _usdpAmt.mul(1e18).div(virtualPriceToWant());
    }

    function checkSlip(uint256 _usdpAmt, uint256 _maxSlip) public view returns (bool) {

        uint256[2] memory amounts = [_usdpAmt, 0];
        return ICurveExchange(curvePool).calc_token_amount(amounts, true) >= _maxSlip;
    }	
	
    function balanceOfCrvLPToken() public view returns (uint256){

        uint256 lpAmt = IBaseRewardsPool(rewardPool).balanceOf(address(this));
        return lpAmt.add(IERC20Upgradeable(usdp3crv).balanceOf(address(this)));
    }
	
    function usdpOfPool() public view returns (uint256){

        uint256 lpAmt = balanceOfCrvLPToken();
        return usdp3crvToUsdp(lpAmt);
    }

    function usdp3crvToUsdp(uint256 _usdp3crv) public view returns (uint256) {

        if (_usdp3crv == 0) {
            return 0;
        }
        return virtualPriceToWant().mul(_usdp3crv).div(1e18);
    }

    function _onlyNotProtectedTokens(address _asset) internal override {

        require(usdp3crv != _asset, "!usdp3crv");
        require(debtToken != _asset, "!usdp");
        require(renbtc_collateral != _asset, "!renbtc");
    }

    function getProtectedTokens() public override view returns (address[] memory) {

        address[] memory protectedTokens = new address[](3);
        protectedTokens[0] = renbtc_collateral;
        protectedTokens[1] = debtToken;
        protectedTokens[2] = usdp3crv;
        return protectedTokens;
    }

    function getName() external override pure returns (string memory) {

        return "StrategyUnitProtocolRenbtc";
    }

    function getHarvestable() public view returns (uint256) {

        return IBaseRewardsPool(rewardPool).earned(address(this));
    }
	
    function mintableCVX(uint256 _amount) public view returns (uint256) {

        uint256 _toMint = 0;
        uint256 supply = IERC20Upgradeable(rewardTokenCVX).totalSupply();
        uint256 cliff = supply.div(ICvxMinter(rewardTokenCVX).reductionPerCliff());
        uint256 totalCliffs = ICvxMinter(rewardTokenCVX).totalCliffs();
        if (cliff < totalCliffs){
            uint256 reduction = totalCliffs.sub(cliff);
            _amount = _amount.mul(reduction).div(totalCliffs);
            uint256 amtTillMax = ICvxMinter(rewardTokenCVX).maxSupply().sub(supply);
            if (_amount > amtTillMax){
                _amount = amtTillMax;
            }
            _toMint = _amount;
        }
        return _toMint;
    }

    function getHarvestableCVX() public view returns (uint256) {

        uint256 _crvEarned = getHarvestable();
        return mintableCVX(_crvEarned);
    }
}