
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// GPL-3.0
pragma solidity 0.8.4;


struct StrategyParams {
    uint256 activation;
    uint256 debtRatio;
    uint256 minDebtPerHarvest;
    uint256 maxDebtPerHarvest;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
}

interface VaultAPI {

    function decimals() external view returns (uint256);


    function token() external view returns (address);


    function vaultAdapter() external view returns (address);


    function strategies(address _strategy) external view returns (StrategyParams memory);


    function creditAvailable() external view returns (uint256);


    function debtOutstanding() external view returns (uint256);


    function expectedReturn() external view returns (uint256);


    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external returns (uint256);


    function revokeStrategy() external;


    function governance() external view returns (address);

}

interface StrategyAPI {

    function name() external view returns (string memory);


    function vault() external view returns (address);


    function want() external view returns (address);


    function keeper() external view returns (address);


    function isActive() external view returns (bool);


    function estimatedTotalAssets() external view returns (uint256);


    function expectedReturn() external view returns (uint256);


    function tendTrigger(uint256 callCost) external view returns (bool);


    function tend() external;


    function harvestTrigger(uint256 callCost) external view returns (bool);


    function harvest() external;


    event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);
}

abstract contract BaseStrategy {
    using SafeERC20 for IERC20;

    VaultAPI public vault;
    address public rewards;
    address public keeper;

    IERC20 public want;

    event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);
    event UpdatedKeeper(address newKeeper);
    event UpdatedRewards(address rewards);
    event UpdatedMinReportDelay(uint256 delay);
    event UpdatedMaxReportDelay(uint256 delay);
    event UpdatedProfitFactor(uint256 profitFactor);
    event UpdatedDebtThreshold(uint256 debtThreshold);
    event EmergencyExitEnabled();

    uint256 public minReportDelay;

    uint256 public maxReportDelay;

    uint256 public profitFactor;

    uint256 public debtThreshold;

    bool public emergencyExit;

    modifier onlyAuthorized() {
        require(msg.sender == keeper || msg.sender == owner(), "!authorized");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner(), "!authorized");
        _;
    }

    constructor(address _vault) {
        _initialize(_vault, msg.sender, msg.sender);
    }

    function name() external view virtual returns (string memory);

    function _initialize(
        address _vault,
        address _rewards,
        address _keeper
    ) internal {
        require(address(want) == address(0), "Strategy already initialized");

        vault = VaultAPI(_vault);
        want = IERC20(vault.token());
        want.safeApprove(_vault, type(uint256).max); // Give Vault unlimited access (might save gas)
        rewards = _rewards;
        keeper = _keeper;

        minReportDelay = 0;
        maxReportDelay = 86400;
        profitFactor = 100;
        debtThreshold = 0;
    }

    function setKeeper(address _keeper) external onlyOwner {
        require(_keeper != address(0));
        keeper = _keeper;
        emit UpdatedKeeper(_keeper);
    }

    function setMinReportDelay(uint256 _delay) external onlyAuthorized {
        minReportDelay = _delay;
        emit UpdatedMinReportDelay(_delay);
    }

    function setMaxReportDelay(uint256 _delay) external onlyAuthorized {
        maxReportDelay = _delay;
        emit UpdatedMaxReportDelay(_delay);
    }

    function setProfitFactor(uint256 _profitFactor) external onlyAuthorized {
        profitFactor = _profitFactor;
        emit UpdatedProfitFactor(_profitFactor);
    }

    function setDebtThreshold(uint256 _debtThreshold) external onlyAuthorized {
        debtThreshold = _debtThreshold;
        emit UpdatedDebtThreshold(_debtThreshold);
    }

    function owner() internal view returns (address) {
        return vault.governance();
    }

    function estimatedTotalAssets() public view virtual returns (uint256);

    function isActive() public view returns (bool) {
        return vault.strategies(address(this)).debtRatio > 0 || estimatedTotalAssets() > 0;
    }

    function prepareReturn(uint256 _debtOutstanding)
        internal
        virtual
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        );

    function adjustPosition(uint256 _debtOutstanding) internal virtual;

    function liquidatePosition(uint256 _amountNeeded)
        internal
        virtual
        returns (uint256 _liquidatedAmount, uint256 _loss);

    function tendTrigger(uint256 callCost) public view virtual returns (bool);

    function tend() external onlyAuthorized {
        adjustPosition(vault.debtOutstanding());
    }

    function harvestTrigger(uint256 callCost) public view virtual returns (bool) {
        StrategyParams memory params = vault.strategies(address(this));

        if (params.activation == 0) return false;

        if (block.timestamp - params.lastReport < minReportDelay) return false;

        if (block.timestamp - params.lastReport >= maxReportDelay) return true;

        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > debtThreshold) return true;

        uint256 total = estimatedTotalAssets();
        if (total + debtThreshold < params.totalDebt) return true;

        uint256 profit = 0;
        if (total > params.totalDebt) profit = total - params.totalDebt; // We've earned a profit!

        uint256 credit = vault.creditAvailable();
        return (profitFactor * callCost < credit + profit);
    }

    function harvest() external {
        require(msg.sender == vault.vaultAdapter(), "harvest: Call from vault");
        uint256 profit = 0;
        uint256 loss = 0;
        uint256 debtOutstanding = vault.debtOutstanding();
        uint256 debtPayment = 0;
        if (emergencyExit) {
            uint256 totalAssets = estimatedTotalAssets();
            (debtPayment, loss) = liquidatePosition(totalAssets > debtOutstanding ? totalAssets : debtOutstanding);
            if (debtPayment > debtOutstanding) {
                profit = debtPayment - debtOutstanding;
                debtPayment = debtOutstanding;
            }
        } else {
            (profit, loss, debtPayment) = prepareReturn(debtOutstanding);
        }
        debtOutstanding = vault.report(profit, loss, debtPayment);

        adjustPosition(debtOutstanding);

        emit Harvested(profit, loss, debtPayment, debtOutstanding);
    }

    function withdraw(uint256 _amountNeeded) external returns (uint256 _loss) {
        require(msg.sender == address(vault), "!vault");
        uint256 amountFreed;
        (amountFreed, _loss) = liquidatePosition(_amountNeeded);
        want.safeTransfer(msg.sender, amountFreed);
    }

    function prepareMigration(address _newStrategy) internal virtual;

    function migrate(address _newStrategy) external {
        require(msg.sender == address(vault));
        require(BaseStrategy(_newStrategy).vault() == vault);
        prepareMigration(_newStrategy);
        want.safeTransfer(_newStrategy, want.balanceOf(address(this)));
    }

    function setEmergencyExit() external onlyAuthorized {
        emergencyExit = true;
        vault.revokeStrategy();

        emit EmergencyExitEnabled();
    }

    function protectedTokens() internal view virtual returns (address[] memory);

    function sweep(address _token) external onlyOwner {
        require(_token != address(want), "!want");
        require(_token != address(vault), "!shares");

        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20(_token).safeTransfer(owner(), IERC20(_token).balanceOf(address(this)));
    }
}// AGPLv3
pragma solidity 0.8.4;

interface IERC20Detailed {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// AGPLv3
pragma solidity 0.8.4;

interface ICurve3Pool {

    function coins(uint256 i) external view returns (address);


    function get_virtual_price() external view returns (uint256);


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);


    function calc_token_amount(uint256[3] calldata inAmounts, bool deposit) external view returns (uint256);


    function balances(uint256 i) external view returns (uint256);

}

interface ICurve3Deposit {

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function add_liquidity(uint256[3] calldata uamounts, uint256 min_mint_amount) external;


    function remove_liquidity(uint256 amount, uint256[3] calldata min_uamounts) external;


    function remove_liquidity_imbalance(uint256[3] calldata amounts, uint256 max_burn_amount) external;


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_uamount
    ) external;


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

}

interface ICurveMetaPool {

    function coins(uint256 i) external view returns (address);


    function get_virtual_price() external view returns (uint256);


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);


    function calc_token_amount(uint256[2] calldata inAmounts, bool deposit) external view returns (uint256);


    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function add_liquidity(uint256[2] calldata uamounts, uint256 min_mint_amount) external;


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_uamount
    ) external;

}

interface ICurveZap {

    function add_liquidity(uint256[4] calldata uamounts, uint256 min_mint_amount) external;


    function remove_liquidity(uint256 amount, uint256[4] calldata min_uamounts) external;


    function remove_liquidity_imbalance(uint256[4] calldata amounts, uint256 max_burn_amount) external;


    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_uamount
    ) external;


    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);


    function calc_token_amount(uint256[4] calldata inAmounts, bool deposit) external view returns (uint256);


    function pool() external view returns (address);

}// AGPLv3
pragma solidity 0.8.4;

interface IUni {

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// AGPLv3
pragma solidity 0.8.4;


interface Booster {

    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }

    function poolInfo(uint256)
        external
        view
        returns (
            address,
            address,
            address,
            address,
            address,
            bool
        );


    function deposit(
        uint256 _pid,
        uint256 _amount,
        bool _stake
    ) external returns (bool);

}

interface Rewards {

    function balanceOf(address account) external view returns (uint256);


    function earned(address account) external view returns (uint256);


    function withdrawAndUnwrap(uint256 amount, bool claim) external returns (bool);


    function withdrawAllAndUnwrap(bool claim) external;


    function getReward() external returns (bool);

}

contract StableConvexXPool is BaseStrategy {

    using SafeERC20 for IERC20;

    address public constant BOOSTER = address(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);

    address public constant CVX = address(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    address public constant CRV = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    address public constant CRV_3POOL = address(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);
    IERC20 public constant CRV_3POOL_TOKEN = IERC20(address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490));

    address public constant UNISWAP = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public constant SUSHISWAP = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    int128 public constant CRV3_INDEX = 1;
    uint256 public constant CRV_METAPOOL_LEN = 2;
    uint256 public constant CRV_3POOL_LEN = 3;

    uint256 public constant TO_ETH = 0;
    uint256 public constant TO_WANT = 1;

    int128 public immutable WANT_INDEX;

    address public curve; // meta pool
    IERC20 public lpToken; // meta pool lp token
    uint256 public pId; // convex lp token pid
    address public rewardContract; // convex reward contract for lp token

    uint256 public newPId;
    address public newCurve;
    IERC20 public newLPToken;
    address public newRewardContract;

    address[] public dex;
    uint256 constant totalCliffs = 100;
    uint256 constant maxSupply = 1e8 * 1e18;
    uint256 constant reductionPerCliff = 1e5 * 1e18;

    uint256 public slippageRecover = 3; 
    uint256 public slippage = 10; // how much slippage to we accept

    event LogSetNewPool(uint256 indexed newPId, address newLPToken, address newRewardContract, address newCurve);
    event LogSwitchDex(uint256 indexed id, address newDex);
    event LogSetNewDex(uint256 indexed id, address newDex);
    event LogChangePool(uint256 indexed newPId, address newLPToken, address newRewardContract, address newCurve);
    event LogSetNewSlippageRecover(uint256 slippage);
    event LogSetNewSlippage(uint256 slippage);

    constructor(address _vault, int128 wantIndex) BaseStrategy(_vault) {
        profitFactor = 1000;
        uint8 decimals = IERC20Detailed(address(want)).decimals();
        debtThreshold = 1_00_000 * (uint256(10)**decimals);
        dex = new address[](2);
        _switchDex(0, UNISWAP);
        _switchDex(1, SUSHISWAP);

        require(
            (address(want) == DAI && wantIndex == 0) ||
                (address(want) == USDC && wantIndex == 1) ||
                (address(want) == USDT && wantIndex == 2),
            "want and wantIndex does not match"
        );
        WANT_INDEX = wantIndex;

        want.safeApprove(CRV_3POOL, type(uint256).max);
    }


    function setNewPool(uint256 _newPId, address _newCurve) external onlyAuthorized {

        require(_newPId != pId, "setMetaPool: same id");
        (address lp, , , address reward, , bool shutdown) = Booster(BOOSTER).poolInfo(_newPId);
        require(!shutdown, "setMetaPool: pool is shutdown");
        IERC20 _newLPToken = IERC20(lp);
        newLPToken = _newLPToken;
        newRewardContract = reward;
        newPId = _newPId;
        newCurve = _newCurve;
        if (CRV_3POOL_TOKEN.allowance(address(this), newCurve) == 0) {
            CRV_3POOL_TOKEN.safeApprove(newCurve, type(uint256).max);
        }
        if (_newLPToken.allowance(address(this), BOOSTER) == 0) {
            _newLPToken.safeApprove(BOOSTER, type(uint256).max);
        }

        emit LogSetNewPool(_newPId, lp, reward, _newCurve);
    }

    function setSlippageRecover(uint256 _slippage) external onlyAuthorized {

        slippageRecover = _slippage;
        emit LogSetNewSlippageRecover(_slippage);
    }

    function setSlippage(uint256 _slippage) external onlyAuthorized {

        slippage = _slippage;
        emit LogSetNewSlippage(_slippage);
    }

    function switchDex(uint256 id, address newDex) external onlyAuthorized {

        _switchDex(id, newDex);
        emit LogSetNewDex(id, newDex);
    }

    function _switchDex(uint256 id, address newDex) private {

        dex[id] = newDex;

        IERC20 token;
        if (id == 0) {
            token = IERC20(CRV);
        } else {
            token = IERC20(CVX);
        }

        if (token.allowance(address(this), newDex) == 0) {
            token.approve(newDex, type(uint256).max);
        }
        emit LogSwitchDex(id, newDex);
    }


    function name() external pure override returns (string memory) {

        return "StrategyConvexXPool";
    }

    function estimatedTotalAssets() public view override returns (uint256 estimated) {

        estimated = _estimatedTotalAssets(true);
    }

    function _estimatedTotalAssets(bool includeReward) private view returns (uint256 estimated) {

        if (rewardContract != address(0)) {
            uint256 lpAmount = Rewards(rewardContract).balanceOf(address(this));
            if (lpAmount > 0) {
                uint256 crv3Amount = ICurveMetaPool(curve).calc_withdraw_one_coin(lpAmount, CRV3_INDEX);
                estimated = ICurve3Pool(CRV_3POOL).calc_withdraw_one_coin(crv3Amount, WANT_INDEX);
            }
            if (includeReward) {
                estimated += _claimableBasic(TO_WANT);
            }
        }
        estimated += want.balanceOf(address(this));
    }



    function forceWithdraw() external onlyAuthorized {

        _withdrawAll();
    }


    function _changePool() private {

        uint256 _newPId = newPId;
        address _newCurve = newCurve;
        IERC20 _newLPToken = newLPToken;
        address _newReward = newRewardContract;

        pId = _newPId;
        curve = _newCurve;
        lpToken = _newLPToken;
        rewardContract = _newReward;

        newCurve = address(0);
        newPId = 0;
        newLPToken = IERC20(address(0));
        newRewardContract = address(0);

        emit LogChangePool(_newPId, address(_newLPToken), _newReward, _newCurve);
    }

    function _withdrawAll() private {

        Rewards(rewardContract).withdrawAllAndUnwrap(true);
        _sellBasic();

        uint256 lpAmount = lpToken.balanceOf(address(this));
        ICurveMetaPool _meta = ICurveMetaPool(curve);
        uint256 vp = _meta.get_virtual_price();
        _meta.remove_liquidity_one_coin(lpAmount, CRV3_INDEX, 0);

        uint256 minAmount = (lpAmount * vp) / 1E18;
        minAmount =
            (minAmount - (minAmount * slippage) / 10000) /
            (1E18 / 10**IERC20Detailed(address(want)).decimals());

        lpAmount = CRV_3POOL_TOKEN.balanceOf(address(this));
        ICurve3Deposit(CRV_3POOL).remove_liquidity_one_coin(lpAmount, WANT_INDEX, minAmount);
    }

    function wantToLp(uint256 amount) private view returns (uint256 lpAmount) {

        uint256[CRV_3POOL_LEN] memory amountsCRV3;
        amountsCRV3[uint256(int256(WANT_INDEX))] = amount;

        uint256 crv3Amount = ICurve3Pool(CRV_3POOL).calc_token_amount(amountsCRV3, false);

        uint256[CRV_METAPOOL_LEN] memory amountsMP;
        amountsMP[uint256(int256(CRV3_INDEX))] = crv3Amount;

        lpAmount = ICurveMetaPool(curve).calc_token_amount(amountsMP, false);
    }


    function _sellBasic() private {

        uint256 crv = IERC20(CRV).balanceOf(address(this));
        if (crv > 0) {
            IUni(dex[0]).swapExactTokensForTokens(
                crv,
                uint256(0),
                _getPath(CRV, TO_WANT),
                address(this),
                block.timestamp
            );
        }
        uint256 cvx = IERC20(CVX).balanceOf(address(this));
        if (cvx > 0) {
            IUni(dex[1]).swapExactTokensForTokens(
                cvx,
                uint256(0),
                _getPath(CVX, TO_WANT),
                address(this),
                block.timestamp
            );
        }
    }

    function _claimableBasic(uint256 toIndex) private view returns (uint256) {

        uint256 crv = Rewards(rewardContract).earned(address(this));

        uint256 supply = IERC20(CVX).totalSupply();
        uint256 cvx;

        uint256 cliff = supply / reductionPerCliff;
        if (cliff < totalCliffs) {
            uint256 reduction = totalCliffs - cliff;
            cvx = (crv * reduction) / totalCliffs;

            uint256 amtTillMax = maxSupply - supply;
            if (cvx > amtTillMax) {
                cvx = amtTillMax;
            }
        }

        uint256 crvValue;
        if (crv > 0) {
            uint256[] memory crvSwap = IUni(dex[0]).getAmountsOut(crv, _getPath(CRV, toIndex));
            crvValue = crvSwap[crvSwap.length - 1];
        }

        uint256 cvxValue;
        if (cvx > 0) {
            uint256[] memory cvxSwap = IUni(dex[1]).getAmountsOut(cvx, _getPath(CVX, toIndex));
            cvxValue = cvxSwap[cvxSwap.length - 1];
        }

        return crvValue + cvxValue;
    }


    function adjustPosition(uint256 _debtOutstanding) internal override {

        if (emergencyExit) return;
        uint256 wantBal = want.balanceOf(address(this));
        if (wantBal > 0) {
            uint256[CRV_3POOL_LEN] memory amountsCRV3;
            amountsCRV3[uint256(int256(WANT_INDEX))] = wantBal;

            ICurve3Deposit(CRV_3POOL).add_liquidity(amountsCRV3, 0);

            uint256 crv3Bal = CRV_3POOL_TOKEN.balanceOf(address(this));
            if (crv3Bal > 0) {
                uint256[CRV_METAPOOL_LEN] memory amountsMP;
                amountsMP[uint256(int256(CRV3_INDEX))] = crv3Bal;
                ICurveMetaPool _meta = ICurveMetaPool(curve);

                uint256 vp = _meta.get_virtual_price();
                uint256 minAmount = (wantBal * (1E36 / 10**IERC20Detailed(address(want)).decimals())) / vp;

                minAmount = minAmount - (minAmount * slippage) / 10000;
                _meta.add_liquidity(amountsMP, minAmount);

                uint256 lpBal = lpToken.balanceOf(address(this));
                if (lpBal > 0) {
                    Booster(BOOSTER).deposit(pId, lpBal, true);
                }
            }
        }
    }

    function liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 _liquidatedAmount, uint256 _loss)
    {

        uint256 _wantBal = want.balanceOf(address(this));
        if (_wantBal < _amountNeeded) {
            _liquidatedAmount = _withdrawSome(_amountNeeded - _wantBal);
            _liquidatedAmount = _liquidatedAmount + _wantBal;
            _liquidatedAmount = Math.min(_liquidatedAmount, _amountNeeded);
            if (_liquidatedAmount < _amountNeeded) {
                _loss = _amountNeeded - _liquidatedAmount;
            }
        } else {
            _liquidatedAmount = _amountNeeded;
        }
    }

    function _withdrawSome(uint256 _amount) private returns (uint256) {

        uint256 lpAmount = wantToLp(_amount);
        lpAmount = lpAmount + (lpAmount * slippageRecover) / 10000;
        uint256 poolBal = Rewards(rewardContract).balanceOf(address(this));

        if (poolBal < lpAmount) {
            lpAmount = poolBal;
        }

        if (poolBal == 0) return 0;

        uint256 before = want.balanceOf(address(this));

        Rewards(rewardContract).withdrawAndUnwrap(lpAmount, false);

        lpAmount = lpToken.balanceOf(address(this));
        ICurveMetaPool(curve).remove_liquidity_one_coin(lpAmount, CRV3_INDEX, 0);

        lpAmount = CRV_3POOL_TOKEN.balanceOf(address(this));

        uint256 minAmount = _amount - (_amount * slippage) / 10000;
        ICurve3Deposit(CRV_3POOL).remove_liquidity_one_coin(lpAmount, WANT_INDEX, minAmount);

        return want.balanceOf(address(this)) - before;
    }

    function prepareReturn(uint256 _debtOutstanding)
        internal
        override
        returns (
            uint256 _profit,
            uint256 _loss,
            uint256 _debtPayment
        )
    {

        uint256 total;
        uint256 wantBal;
        uint256 beforeTotal;
        uint256 debt = vault.strategies(address(this)).totalDebt;
        if (curve == address(0)) {
            _changePool();
            return (0, 0, 0);
        } else if (newCurve != address(0)) {
            beforeTotal = _estimatedTotalAssets(true);
            _withdrawAll();
            _changePool();
            wantBal = want.balanceOf(address(this));
            total = wantBal;

            if (beforeTotal < debt) {
                total = Math.max(beforeTotal, total);
            } else if (beforeTotal > debt && total < debt) {
                total = debt;
            }
        } else {
            Rewards(rewardContract).getReward();
            _sellBasic();
            total = _estimatedTotalAssets(false);
            wantBal = want.balanceOf(address(this));
        }
        _debtPayment = _debtOutstanding;
        if (total > debt) {
            _profit = total - debt;
            uint256 amountToFree = _profit + _debtPayment;
            if (amountToFree > 0 && wantBal < amountToFree) {
                _withdrawSome(amountToFree - wantBal);
                total = _estimatedTotalAssets(false);
                wantBal = want.balanceOf(address(this));
                if (total <= debt) {
                    _profit = 0;
                    _loss = debt - total;
                } else {
                    _profit = total - debt;
                }
                amountToFree = _profit + _debtPayment;
                if (wantBal < amountToFree) {
                    if (_profit > wantBal) {
                        _profit = wantBal;
                        _debtPayment = 0;
                    } else {
                        _debtPayment = Math.min(wantBal - _profit, _debtPayment);
                    }
                }
            }
        } else {
            _loss = debt - total;
            uint256 amountToFree = _debtPayment;
            if (amountToFree > 0 && wantBal < amountToFree) {
                _withdrawSome(amountToFree - wantBal);
                wantBal = want.balanceOf(address(this));
                if (wantBal < amountToFree) {
                    _debtPayment = wantBal;
                }
            }
        }
    }

    function tendTrigger(uint256 callCost) public pure override returns (bool) {

        callCost;
        return false;
    }

    function harvestTrigger(uint256 callCost) public view override returns (bool) {

        StrategyParams memory params = vault.strategies(address(this));

        if (params.activation == 0) return false;

        if (block.timestamp - params.lastReport < minReportDelay) return false;

        if (block.timestamp - params.lastReport >= maxReportDelay) return true;

        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > debtThreshold) return true;

        uint256 total = estimatedTotalAssets();
        if (total + debtThreshold < params.totalDebt) return true;

        uint256 profit;
        if (total > params.totalDebt) {
            profit = total - params.totalDebt;
        }

        return (profitFactor * callCost < _wantToETH(profit));
    }


    function _getPath(address from, uint256 toIndex) private view returns (address[] memory path) {

        if (toIndex == TO_ETH) {
            path = new address[](2);
            path[0] = from;
            path[1] = WETH;
        }

        if (toIndex == TO_WANT) {
            path = new address[](3);
            path[0] = from;
            path[1] = WETH;
            path[2] = address(want);
        }
    }

    function prepareMigration(address _newStrategy) internal override {

        _newStrategy;
        _withdrawAll();
    }

    function protectedTokens() internal pure override returns (address[] memory) {

        address[] memory protected = new address[](2);
        protected[0] = CRV;
        protected[1] = CVX;
        return protected;
    }

    function _wantToETH(uint256 wantAmount) private view returns (uint256) {

        if (wantAmount > 0) {
            address[] memory path = new address[](2);
            path[0] = address(want);
            path[1] = WETH;
            uint256[] memory amounts = IUni(dex[0]).getAmountsOut(wantAmount, path);
            return amounts[1];
        }
    }
}