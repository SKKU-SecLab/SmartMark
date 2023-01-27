

pragma solidity 0.6.12;

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

contract ValueVaultMaster {

    address public governance;

    address public bank;
    address public minorPool;
    address public profitSharer;

    address public govToken; // VALUE
    address public yfv; // When harvesting, convert some parts to YFV for govVault
    address public usdc; // we only used USDC to estimate APY

    address public govVault; // YFV -> VALUE, vUSD, vETH and 6.7% profit from Value Vaults
    address public insuranceFund = 0xb7b2Ea8A1198368f950834875047aA7294A2bDAa; // set to Governance Multisig at start
    address public performanceReward = 0x7Be4D5A99c903C437EC77A20CB6d0688cBB73c7f; // set to deploy wallet at start

    uint256 public constant FEE_DENOMINATOR = 10000;
    uint256 public govVaultProfitShareFee = 670; // 6.7% | VIP-1 (https://yfv.finance/vip-vote/vip_1)
    uint256 public gasFee = 50; // 0.5% at start and can be set by governance decision

    uint256 public minStakeTimeToClaimVaultReward = 24 hours;

    mapping(address => bool) public isVault;
    mapping(uint256 => address) public vaultByKey;

    mapping(address => bool) public isStrategy;
    mapping(uint256 => address) public strategyByKey;
    mapping(address => uint256) public strategyQuota;

    constructor(address _govToken, address _yfv, address _usdc) public {
        govToken = _govToken;
        yfv = _yfv;
        usdc = _usdc;
        governance = tx.origin;
    }

    function setGovernance(address _governance) external {

        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setBank(address _bank) external {

        require(msg.sender == governance, "!governance");
        require(bank == address(0));
        bank = _bank;
    }

    function setMinorPool(address _minorPool) external {

        require(msg.sender == governance, "!governance");
        minorPool = _minorPool;
    }

    function setProfitSharer(address _profitSharer) external {

        require(msg.sender == governance, "!governance");
        profitSharer = _profitSharer;
    }

    function setGovToken(address _govToken) external {

        require(msg.sender == governance, "!governance");
        govToken = _govToken;
    }

    function addVault(uint256 _key, address _vault) external {

        require(msg.sender == governance, "!governance");
        require(vaultByKey[_key] == address(0), "vault: key is taken");

        isVault[_vault] = true;
        vaultByKey[_key] = _vault;
    }

    function addStrategy(uint256 _key, address _strategy) external {

        require(msg.sender == governance, "!governance");
        isStrategy[_strategy] = true;
        strategyByKey[_key] = _strategy;
    }

    function setStrategyQuota(address _strategy, uint256 _quota) external {

        require(msg.sender == governance, "!governance");
        strategyQuota[_strategy] = _quota;
    }

    function removeStrategy(uint256 _key) external {

        require(msg.sender == governance, "!governance");
        isStrategy[strategyByKey[_key]] = false;
        delete strategyByKey[_key];
    }

    function setGovVault(address _govVault) public {

        require(msg.sender == governance, "!governance");
        govVault = _govVault;
    }

    function setInsuranceFund(address _insuranceFund) public {

        require(msg.sender == governance, "!governance");
        insuranceFund = _insuranceFund;
    }

    function setPerformanceReward(address _performanceReward) public{

        require(msg.sender == governance, "!governance");
        performanceReward = _performanceReward;
    }

    function setGovVaultProfitShareFee(uint256 _govVaultProfitShareFee) public {

        require(msg.sender == governance, "!governance");
        govVaultProfitShareFee = _govVaultProfitShareFee;
    }

    function setGasFee(uint256 _gasFee) public {

        require(msg.sender == governance, "!governance");
        gasFee = _gasFee;
    }

    function setMinStakeTimeToClaimVaultReward(uint256 _minStakeTimeToClaimVaultReward) public {

        require(msg.sender == governance, "!governance");
        minStakeTimeToClaimVaultReward = _minStakeTimeToClaimVaultReward;
    }

    function governanceRecoverUnsupported(IERC20x _token, uint256 amount, address to) external {

        require(msg.sender == governance, "!governance");
        _token.transfer(to, amount);
    }
}

interface IERC20x {

    function transfer(address recipient, uint256 amount) external returns (bool);

}

interface IStrategyV2p1 {

    function approve(IERC20 _token) external;


    function approveForSpender(IERC20 _token, address spender) external;


    function deposit(address _vault, uint256 _amount) external; // IStrategy

    function deposit(uint256 _poolId, uint256 _amount) external; // IStrategyV2


    function claim(address _vault) external; // IStrategy

    function claim(uint256 _poolId) external; // IStrategyV2


    function harvest(uint256 _bankPoolId) external; // IStrategy

    function harvest(uint256 _bankPoolId, uint256 _poolId) external; // IStrategyV2


    function withdraw(address _vault, uint256 _amount) external; // IStrategy

    function withdraw(uint256 _poolId, uint256 _amount) external; // IStrategyV2


    function poolQuota(uint256 _poolId) external view returns (uint256);


    function forwardToAnotherStrategy(address _dest, uint256 _amount) external returns (uint256);

    function switchBetweenPoolsByGov(uint256 _sourcePoolId, uint256 _destPoolId, uint256 _amount) external; // IStrategyV2p1


    function getLpToken() external view returns(address);


    function getTargetToken(address _vault) external view returns(address); // IStrategy

    function getTargetToken(uint256 _poolId) external view returns(address); // IStrategyV2


    function balanceOf(address _vault) external view returns (uint256); // IStrategy

    function balanceOf(uint256 _poolId) external view returns (uint256); // IStrategyV2


    function pendingReward(address _vault) external view returns (uint256); // IStrategy

    function pendingReward(uint256 _poolId) external view returns (uint256); // IStrategyV2


    function expectedAPY(address _vault) external view returns (uint256); // IStrategy

    function expectedAPY(uint256 _poolId, uint256 _lpTokenUsdcPrice) external view returns (uint256); // IStrategyV2


    function governanceRescueToken(IERC20 _token) external returns (uint256);

}

interface IOneSplit {

    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 destToken,
        uint256 amount,
        uint256 parts,
        uint256 flags // See constants in IOneSplit.sol
    ) external view returns(
        uint256 returnAmount,
        uint256[] memory distribution
    );

}

interface IUniswapRouter {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


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

}

interface IValueLiquidPool {

    function swapExactAmountIn(address, uint, address, uint, uint) external returns (uint, uint);

    function swapExactAmountOut(address, uint, address, uint, uint) external returns (uint, uint);

    function calcInGivenOut(uint, uint, uint, uint, uint, uint) external pure returns (uint);

    function calcOutGivenIn(uint, uint, uint, uint, uint, uint) external pure returns (uint);

    function getDenormalizedWeight(address) external view returns (uint);

    function getBalance(address) external view returns (uint);

    function swapFee() external view returns (uint);

}

interface IStakingRewards {

    function lastTimeRewardApplicable() external view returns (uint256);

    function rewardPerToken() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function earned(address account) external view returns (uint256);

    function getRewardForDuration() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);


    function stake(uint256 amount) external; // Goff, DokiDoki

    function stake(uint256 amount, string memory affCode) external; // dego.finance

    function withdraw(uint256 amount) external;

    function getReward() external;

    function exit() external;


    function getRewardsAmount(address account) external view returns(uint256);

    function claim(uint amount) external;

}

interface ISushiPool {

    function deposit(uint256 _poolId, uint256 _amount) external;

    function claim(uint256 _poolId) external;

    function withdraw(uint256 _poolId, uint256 _amount) external;

    function emergencyWithdraw(uint256 _poolId) external;

}

interface IProfitSharer {

    function shareProfit() external returns (uint256);

}

interface IValueVaultBank {

    function make_profit(uint256 _poolId, uint256 _amount) external;

}

contract WETHMultiPoolStrategy is IStrategyV2p1 {

    using SafeMath for uint256;

    address public strategist;
    address public governance;

    uint256 public constant FEE_DENOMINATOR = 10000;

    IOneSplit public onesplit = IOneSplit(0x50FDA034C0Ce7a8f7EFDAebDA7Aa7cA21CC1267e);
    IUniswapRouter public unirouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    ValueVaultMaster public valueVaultMaster;
    IERC20 public lpToken; // WETH

    mapping(address => mapping(address => address[])) public uniswapPaths; // [input -> output] => uniswap_path
    mapping(address => mapping(address => address)) public liquidPools; // [input -> output] => value_liquid_pool (valueliquid.io)

    struct PoolInfo {
        address vault;
        IERC20 targetToken;
        address targetPool;
        uint256 targetPoolId; // poolId in soda/chicken pool (no use for IStakingRewards pool eg. golff.finance)
        uint256 minHarvestForTakeProfit;
        uint8 poolType; // 0: IStakingRewards, 1: ISushiPool, 2: ISodaPool, 3: Dego.Finance, 4: DokiDoki.Finance
        uint256 poolQuota; // set 0 to disable quota (no limit)
        uint256 balance;
    }

    mapping(uint256 => PoolInfo) public poolMap; // poolIndex -> poolInfo
    uint256 public totalBalance;

    bool public aggressiveMode; // will try to stake all lpTokens available (be forwarded from bank or from another strategies)

    uint8[] public poolPreferredIds; // sorted by preference

    constructor(ValueVaultMaster _valueVaultMaster,
        IERC20 _lpToken,
        bool _aggressiveMode) public {
        valueVaultMaster = _valueVaultMaster;
        lpToken = _lpToken;
        aggressiveMode = _aggressiveMode;
        governance = tx.origin;
        strategist = tx.origin;
        lpToken.approve(valueVaultMaster.bank(), type(uint256).max);
        lpToken.approve(address(unirouter), type(uint256).max);
    }

    function setPoolInfo(uint256 _poolId, address _vault, IERC20 _targetToken, address _targetPool, uint256 _targetPoolId, uint256 _minHarvestForTakeProfit, uint8 _poolType, uint256 _poolQuota) external {

        require(msg.sender == governance, "!governance");
        poolMap[_poolId].vault = _vault;
        poolMap[_poolId].targetToken = _targetToken;
        poolMap[_poolId].targetPool = _targetPool;
        poolMap[_poolId].targetPoolId = _targetPoolId;
        poolMap[_poolId].minHarvestForTakeProfit = _minHarvestForTakeProfit;
        poolMap[_poolId].poolType = _poolType;
        poolMap[_poolId].poolQuota = _poolQuota;
        _targetToken.approve(address(unirouter), type(uint256).max);
        lpToken.approve(_vault, type(uint256).max);
        lpToken.approve(address(_targetPool), type(uint256).max);
    }

    function approve(IERC20 _token) external override {

        require(msg.sender == governance, "!governance");
        _token.approve(valueVaultMaster.bank(), type(uint256).max);
        _token.approve(address(unirouter), type(uint256).max);
    }

    function approveForSpender(IERC20 _token, address spender) external override {

        require(msg.sender == governance, "!governance");
        _token.approve(spender, type(uint256).max);
    }

    function setGovernance(address _governance) external {

        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setStrategist(address _strategist) external {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        strategist = _strategist;
    }

    function setPoolPreferredIds(uint8[] memory _poolPreferredIds) public {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        delete poolPreferredIds;
        for (uint8 i = 0; i < _poolPreferredIds.length; ++i) {
            poolPreferredIds.push(_poolPreferredIds[i]);
        }
    }

    function setMinHarvestForTakeProfit(uint256 _poolId, uint256 _minHarvestForTakeProfit) external {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        poolMap[_poolId].minHarvestForTakeProfit = _minHarvestForTakeProfit;
    }

    function setPoolQuota(uint256 _poolId, uint256 _poolQuota) external {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        poolMap[_poolId].poolQuota = _poolQuota;
    }

    function setPoolBalance(uint256 _poolId, uint256 _balance) external {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        poolMap[_poolId].balance = _balance;
    }

    function setTotalBalance(uint256 _totalBalance) external {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        totalBalance = _totalBalance;
    }

    function setAggressiveMode(bool _aggressiveMode) external {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        aggressiveMode = _aggressiveMode;
    }

    function setOnesplit(IOneSplit _onesplit) external {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        onesplit = _onesplit;
    }

    function setUnirouter(IUniswapRouter _unirouter) external {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        unirouter = _unirouter;
    }

    function deposit(address _vault, uint256 _amount) public override {

        require(valueVaultMaster.isVault(msg.sender), "sender not vault");
        require(poolPreferredIds.length > 0, "no pool");
        for (uint256 i = 0; i < poolPreferredIds.length; ++i) {
            uint256 _pid = poolPreferredIds[i];
            if (poolMap[_pid].vault == _vault) {
                uint256 _quota = poolMap[_pid].poolQuota;
                if (_quota == 0 || balanceOf(_pid) < _quota) {
                    _deposit(_pid, _amount);
                    return;
                }
            }
        }
        revert("Exceeded pool quota");
    }

    function deposit(uint256 _poolId, uint256 _amount) public override {

        require(poolMap[_poolId].vault == msg.sender, "sender not vault");
        _deposit(_poolId, _amount);
    }

    function _deposit(uint256 _poolId, uint256 _amount) internal {

        PoolInfo storage pool = poolMap[_poolId];
        if (aggressiveMode) {
            _amount = lpToken.balanceOf(address(this));
        }
        if (pool.poolType == 0 || pool.poolType == 4) {
            IStakingRewards(pool.targetPool).stake(_amount);
        } else if (pool.poolType == 3) {
            IStakingRewards(pool.targetPool).stake(_amount, string("valuedefidev02"));
        } else {
            ISushiPool(pool.targetPool).deposit(pool.targetPoolId, _amount);
        }
        pool.balance = pool.balance.add(_amount);
        totalBalance = totalBalance.add(_amount);
    }

    function claim(address _vault) external override {

        require(valueVaultMaster.isVault(_vault), "not vault");
        require(poolPreferredIds.length > 0, "no pool");
        for (uint256 i = 0; i < poolPreferredIds.length; ++i) {
            uint256 _pid = poolPreferredIds[i];
            if (poolMap[_pid].vault == _vault) {
                _claim(_pid);
            }
        }
    }

    function claim(uint256 _poolId) external override {

        require(poolMap[_poolId].vault == msg.sender, "sender not vault");
        _claim(_poolId);
    }

    function _claim(uint256 _poolId) internal {

        PoolInfo storage pool = poolMap[_poolId];
        if (pool.poolType == 0 || pool.poolType == 3) {
            IStakingRewards(pool.targetPool).getReward();
        } else if (pool.poolType == 4) {
            IStakingRewards(pool.targetPool).claim(IStakingRewards(pool.targetPool).getRewardsAmount(address(this)));
        } else if (pool.poolType == 1) {
            ISushiPool(pool.targetPool).deposit(pool.targetPoolId, 0);
        } else {
            ISushiPool(pool.targetPool).claim(pool.targetPoolId);
        }
    }

    function withdraw(address _vault, uint256 _amount) external override {

        require(valueVaultMaster.isVault(msg.sender), "sender not vault");
        require(poolPreferredIds.length > 0, "no pool");
        for (uint256 i = poolPreferredIds.length; i >= 1; --i) {
            uint256 _pid = poolPreferredIds[i - 1];
            if (poolMap[_pid].vault == _vault) {
                uint256 _bal = poolMap[_pid].balance;
                if (_bal > 0) {
                    _withdraw(_pid, (_bal > _amount) ? _amount : _bal);
                    uint256 strategyBal = lpToken.balanceOf(address(this));
                    lpToken.transfer(valueVaultMaster.bank(), strategyBal);
                    if (strategyBal >= _amount) break;
                    if (strategyBal > 0) _amount = _amount - strategyBal;
                }
            }
        }
    }

    function withdraw(uint256 _poolId, uint256 _amount) external override {

        require(poolMap[_poolId].vault == msg.sender, "sender not vault");
        if (lpToken.balanceOf(address(this)) >= _amount) return; // has enough balance, no need to withdraw from pool
        _withdraw(_poolId, _amount);
    }

    function _withdraw(uint256 _poolId, uint256 _amount) internal {

        PoolInfo storage pool = poolMap[_poolId];
        if (pool.poolType == 0 || pool.poolType == 3 || pool.poolType == 4) {
            IStakingRewards(pool.targetPool).withdraw(_amount);
        } else {
            ISushiPool(pool.targetPool).withdraw(pool.targetPoolId, _amount);
        }
        if (pool.balance < _amount) {
            _amount = pool.balance;
        }
        pool.balance = pool.balance - _amount;
        if (totalBalance >= _amount) totalBalance = totalBalance - _amount;
    }

    function depositByGov(address pool, uint8 _poolType, uint256 _targetPoolId, uint256 _amount) external {

        require(msg.sender == governance, "!governance");
        if (_poolType == 0 || _poolType == 4) {
            IStakingRewards(pool).stake(_amount);
        } else if (_poolType == 3) {
            IStakingRewards(pool).stake(_amount, string("valuedefidev02"));
        } else {
            ISushiPool(pool).deposit(_targetPoolId, _amount);
        }
    }

    function claimByGov(address pool, uint8 _poolType, uint256 _targetPoolId) external {

        require(msg.sender == governance, "!governance");
        if (_poolType == 0 || _poolType == 3) {
            IStakingRewards(pool).getReward();
        } else if (_poolType == 4) {
            IStakingRewards(pool).claim(IStakingRewards(pool).getRewardsAmount(address(this)));
        } else if (_poolType == 1) {
            ISushiPool(pool).deposit(_targetPoolId, 0);
        } else {
            ISushiPool(pool).claim(_targetPoolId);
        }
    }

    function withdrawByGov(address pool, uint8 _poolType, uint256 _targetPoolId, uint256 _amount) external {

        require(msg.sender == governance, "!governance");
        if (_poolType == 0 || _poolType == 3 || _poolType == 4) {
            IStakingRewards(pool).withdraw(_amount);
        } else {
            ISushiPool(pool).withdraw(_targetPoolId, _amount);
        }
    }

    function emergencyWithdrawByGov(address pool, uint256 _targetPoolId) external {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        ISushiPool(pool).emergencyWithdraw(_targetPoolId);
    }

    function switchBetweenPoolsByGov(uint256 _sourcePoolId, uint256 _destPoolId, uint256 _amount) external override {

        require(msg.sender == governance, "!governance");
        _withdraw(_sourcePoolId, _amount);
        _deposit(_destPoolId, _amount);
    }

    function poolQuota(uint256 _poolId) external override view returns (uint256) {

        return poolMap[_poolId].poolQuota;
    }

    function forwardToAnotherStrategy(address _dest, uint256 _amount) external override returns (uint256 sent) {

        require(valueVaultMaster.isVault(msg.sender), "not vault");
        require(valueVaultMaster.isStrategy(_dest), "not strategy");
        require(IStrategyV2p1(_dest).getLpToken() == address(lpToken), "!lpToken");
        uint256 lpTokenBal = lpToken.balanceOf(address(this));
        sent = (_amount < lpTokenBal) ? _amount : lpTokenBal;
        lpToken.transfer(_dest, sent);
    }

    function setUnirouterPath(address _input, address _output, address [] memory _path) public {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        uniswapPaths[_input][_output] = _path;
    }

    function setLiquidPool(address _input, address _output, address _pool) public {

        require(msg.sender == governance || msg.sender == strategist, "!governance && !strategist");
        liquidPools[_input][_output] = _pool;
        IERC20(_input).approve(_pool, type(uint256).max);
    }

    function _swapTokens(address _input, address _output, uint256 _amount) internal {

        address _pool = liquidPools[_input][_output];
        if (_pool != address(0)) { // use ValueLiquid
            IValueLiquidPool(_pool).swapExactAmountIn(_input, _amount, _output, 1, type(uint256).max);
        } else { // use Uniswap
            address[] memory path = uniswapPaths[_input][_output];
            if (path.length == 0) {
                path = new address[](2);
                path[0] = _input;
                path[1] = _output;
            }
            unirouter.swapExactTokensForTokens(_amount, 1, path, address(this), now.add(1800));
        }
    }

    function harvest(uint256 _bankPoolId) external override {

        address _vault = msg.sender;
        require(valueVaultMaster.isVault(_vault), "!vault"); // additional protection so we don't burn the funds
        require(poolPreferredIds.length > 0, "no pool");
        for (uint256 i = 0; i < poolPreferredIds.length; ++i) {
            uint256 _pid = poolPreferredIds[i];
            if (poolMap[_pid].vault == _vault) {
                _harvest(_bankPoolId, _pid);
            }
        }
    }

    function harvest(uint256 _bankPoolId, uint256 _poolId) external override {

        require(valueVaultMaster.isVault(msg.sender), "!vault"); // additional protection so we don't burn the funds
        _harvest(_bankPoolId, _poolId);
    }

    function _harvest(uint256 _bankPoolId, uint256 _poolId) internal {

        PoolInfo storage pool = poolMap[_poolId];
        _claim(_poolId);

        IERC20 targetToken = pool.targetToken;
        uint256 targetTokenBal = targetToken.balanceOf(address(this));

        if (targetTokenBal < pool.minHarvestForTakeProfit) return;

        _swapTokens(address(targetToken), address(lpToken), targetTokenBal);
        uint256 wethBal = lpToken.balanceOf(address(this));

        if (wethBal > 0) {
            address profitSharer = valueVaultMaster.profitSharer();
            address performanceReward = valueVaultMaster.performanceReward();
            address bank = valueVaultMaster.bank();

            if (valueVaultMaster.govVaultProfitShareFee() > 0 && profitSharer != address(0)) {
                address _govToken = valueVaultMaster.yfv();
                uint256 _govVaultProfitShareFee = wethBal.mul(valueVaultMaster.govVaultProfitShareFee()).div(FEE_DENOMINATOR);
                _swapTokens(address(lpToken), _govToken, _govVaultProfitShareFee);
                IERC20(_govToken).transfer(profitSharer, IERC20(_govToken).balanceOf(address(this)));
                IProfitSharer(profitSharer).shareProfit();
            }

            if (valueVaultMaster.gasFee() > 0 && performanceReward != address(0)) {
                uint256 _gasFee = wethBal.mul(valueVaultMaster.gasFee()).div(FEE_DENOMINATOR);
                lpToken.transfer(performanceReward, _gasFee);
            }

            uint256 balanceLeft = lpToken.balanceOf(address(this));
            if (lpToken.allowance(address(this), bank) < balanceLeft) {
                lpToken.approve(bank, 0);
                lpToken.approve(bank, balanceLeft);
            }
            IValueVaultBank(bank).make_profit(_bankPoolId, balanceLeft);
        }
    }

    function getLpToken() external view override returns(address) {

        return address(lpToken);
    }

    function getTargetToken(address) external override view returns(address) {

        return address(poolMap[0].targetToken);
    }

    function getTargetToken(uint256 _poolId) external override view returns(address) {

        return address(poolMap[_poolId].targetToken);
    }

    function balanceOf(address _vault) public override view returns (uint256 _balanceOfVault) {

        _balanceOfVault = 0;
        for (uint256 i = 0; i < poolPreferredIds.length; ++i) {
            uint256 _pid = poolPreferredIds[i];
            if (poolMap[_pid].vault == _vault) {
                _balanceOfVault = _balanceOfVault.add(poolMap[_pid].balance);
            }
        }
    }

    function balanceOf(uint256 _poolId) public override view returns (uint256) {

        return poolMap[_poolId].balance;
    }

    function pendingReward(address) public override view returns (uint256) {

        return pendingReward(0);
    }

    function pendingReward(uint256 _poolId) public override view returns (uint256) {

        if (poolMap[_poolId].poolType != 0) return 0; // do not support other pool types
        return IStakingRewards(poolMap[_poolId].targetPool).earned(address(this));
    }

    function expectedAPY(address) public override view returns (uint256) {

        return expectedAPY(0, 0);
    }

    function expectedAPY(uint256 _poolId, uint256) public override view returns (uint256) {

        if (poolMap[_poolId].poolType != 0) return 0; // do not support other pool types
        IStakingRewards targetPool = IStakingRewards(poolMap[_poolId].targetPool);
        uint256 totalSupply = targetPool.totalSupply();
        if (totalSupply == 0) return 0;
        uint256 investAmt = poolMap[_poolId].balance;
        uint256 oneHourReward = targetPool.rewardRate().mul(3600);
        uint256 returnAmt = oneHourReward.mul(investAmt).div(totalSupply);
        IERC20 usdc = IERC20(valueVaultMaster.usdc());
        (uint256 investInUSDC, ) = onesplit.getExpectedReturn(lpToken, usdc, investAmt, 10, 0);
        (uint256 returnInUSDC, ) = onesplit.getExpectedReturn(poolMap[_poolId].targetToken, usdc, returnAmt, 10, 0);
        return returnInUSDC.mul(8760).mul(FEE_DENOMINATOR).div(investInUSDC); // 100 -> 1%
    }

    event ExecuteTransaction(address indexed target, uint value, string signature, bytes data);

    function executeTransaction(address target, uint value, string memory signature, bytes memory data) public returns (bytes memory) {

        require(msg.sender == governance, "!governance");

        bytes memory callData;

        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "WETHMultiPoolStrategy::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(target, value, signature, data);

        return returnData;
    }

    function governanceRescueToken(IERC20 _token) external override returns (uint256 balance) {

        address bank = valueVaultMaster.bank();
        require(bank == msg.sender, "sender not bank");

        balance = _token.balanceOf(address(this));
        _token.transfer(bank, balance);
    }
}