
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// AGPL-3.0
pragma solidity ^0.8.2;
pragma experimental ABIEncoderV2;


interface Booster {

    struct PoolInfo {
        address lptoken;
        address token;
        address gauge;
        address crvRewards;
        address stash;
        bool shutdown;
    }
    function poolInfo(uint256) external view returns (address,address,address,address,address, bool);


    function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns (bool);


    function depositAll(uint256 _pid, bool _stake) external returns (bool);


    function withdraw(uint256 _pid, uint256 _amount) external returns (bool);


    function withdrawAll(uint256 _pid) external returns (bool);


    function earmarkRewards(uint256 _pid) external returns (bool);


    function claimRewards(uint256 _pid, address _gauge) external returns (bool);


    function vote(uint256 _voteId, address _votingAddress, bool _support) external returns (bool);

    function voteGaugeWeight(address[] calldata _gauge, uint256[] calldata _weight ) external returns (bool);

}// AGPL-3.0
pragma solidity ^0.8.2;


interface ICurveFi {

    function add_liquidity(
        uint256[2] calldata amounts,
        uint256 min_mint_amount,
        bool _use_underlying
    ) external payable returns (uint256);


    function remove_liquidity_one_coin(uint256 token_amount, int128 i, uint256 min_amount) external;


    function remove_liquidity_one_coin(address pool, uint256 token_amount, int128 i, uint256 min_amount) external;


    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount,
        bool _use_underlying
    ) external payable returns (uint256);


    function add_liquidity(
        uint256[4] calldata amounts,
        uint256 min_mint_amount,
        bool _use_underlying
    ) external payable returns (uint256);


    function add_liquidity(
        uint256[2] calldata amounts,
        uint256 min_mint_amount
    ) external payable;


    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount
    ) external payable;


    function add_liquidity(
        uint256[4] calldata amounts,
        uint256 min_mint_amount
    ) external payable;


    function add_liquidity(
        address pool,
        uint256[4] calldata amounts,
        uint256 min_mint_amount
    ) external;


    function calc_token_amount(
        uint256[3] calldata tokens,
        bool is_deposit
    ) external view returns (uint256);


    function calc_token_amount(
        uint256[2] calldata tokens,
        bool is_deposit
    ) external view returns (uint256);


    function calc_token_amount(
        address _pool,
        uint256[4] calldata _amounts,
        bool _is_deposit
    ) external view returns (uint256);


    function calc_withdraw_one_coin(uint256 token_amount, int128 i) external view returns (uint256);


    function calc_withdraw_one_coin(address pool, uint256 token_amount, int128 i) external view returns (uint256);



    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;


    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);


    function balances(int128) external view returns (uint256);


    function get_virtual_price() external view returns (uint256);

}// AGPL-3.0
pragma solidity ^0.8.2;


interface IEverscale {

    struct EverscaleAddress {
        int128 wid;
        uint256 addr;
    }

    struct EverscaleEvent {
        uint64 eventTransactionLt;
        uint32 eventTimestamp;
        bytes eventData;
        int8 configurationWid;
        uint256 configurationAddress;
        int8 eventContractWid;
        uint256 eventContractAddress;
        address proxy;
        uint32 round;
    }
}// AGPL-3.0
pragma solidity ^0.8.2;


interface Rewards{

    function pid() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function earned(address account) external view returns (uint256);


    function extraRewardsLength() external view returns (uint256);

    function extraRewards(uint256) external view returns (address);

    function rewardPerToken() external view returns (uint256);

    function rewardPerTokenStored() external view returns (uint256);

    function rewardRate() external view returns (uint256);

    function rewardToken() external view returns (address);

    function rewards(address) external view returns (uint256);

    function userRewardPerTokenPaid(address) external view returns (uint256);

    function stakingToken() external view returns (address);

    function queueNewRewards(uint256 _rewards) external returns (bool);


    function stake(uint256) external returns (bool);

    function stakeAll() external returns (bool);

    function stakeFor(address, uint256) external returns (bool);


    function withdraw(uint256 amount, bool claim) external returns (bool);

    function withdrawAll(bool claim) external returns (bool);

    function withdrawAndUnwrap(uint256 amount, bool claim) external returns (bool);

    function withdrawAllAndUnwrap(bool claim) external;


    function getReward() external returns (bool);

    function getReward(address _account, bool _claimExtras) external returns (bool);


    function operator() external view returns (address);


    function donate(uint256 _amount) external returns (bool);

}// AGPL-3.0
pragma solidity ^0.8.2;

interface Uni {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
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


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);


    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint256 amountOut);


    function quoteExactInput(
        bytes calldata path,
        uint256 amountIn
    ) external view returns (uint256 amountOut);

}// AGPL-3.0
pragma solidity ^0.8.2;



interface IVaultBasic is IEverscale {

    struct WithdrawalParams {
        EverscaleAddress sender;
        uint256 amount;
        address recipient;
        uint32 chainId;
    }

    function bridge() external view returns (address);

    function configuration() external view returns (EverscaleAddress memory);

    function withdrawalIds(bytes32) external view returns (bool);

    function rewards() external view returns (EverscaleAddress memory);


    function governance() external view returns (address);

    function guardian() external view returns (address);

    function management() external view returns (address);


    function token() external view returns (address);

    function targetDecimals() external view returns (uint256);

    function tokenDecimals() external view returns (uint256);


    function depositFee() external view returns (uint256);

    function withdrawFee() external view returns (uint256);


    function emergencyShutdown() external view returns (bool);


    function apiVersion() external view returns (string memory api_version);


    function setDepositFee(uint _depositFee) external;

    function setWithdrawFee(uint _withdrawFee) external;


    function setConfiguration(EverscaleAddress memory _configuration) external;

    function setGovernance(address _governance) external;

    function acceptGovernance() external;

    function setGuardian(address _guardian) external;

    function setManagement(address _management) external;

    function setRewards(EverscaleAddress memory _rewards) external;

    function setEmergencyShutdown(bool active) external;


    function deposit(
        EverscaleAddress memory recipient,
        uint256 amount
    ) external;


    function decodeWithdrawalEventData(
        bytes memory eventData
    ) external view returns(WithdrawalParams memory);


    function sweep(address _token) external;


    event Deposit(
        uint256 amount,
        int128 wid,
        uint256 addr
    );

    event InstantWithdrawal(
        bytes32 payloadId,
        address recipient,
        uint256 amount
    );

    event UpdateBridge(address bridge);
    event UpdateConfiguration(int128 wid, uint256 addr);
    event UpdateTargetDecimals(uint256 targetDecimals);
    event UpdateRewards(int128 wid, uint256 addr);

    event UpdateDepositFee(uint256 fee);
    event UpdateWithdrawFee(uint256 fee);

    event UpdateGovernance(address governance);
    event UpdateManagement(address management);
    event NewPendingGovernance(address governance);
    event UpdateGuardian(address guardian);

    event EmergencyShutdown(bool active);
}// AGPL-3.0
pragma solidity ^0.8.2;



interface IVault is IVaultBasic {

    enum ApproveStatus { NotRequired, Required, Approved, Rejected }

    struct StrategyParams {
        uint256 performanceFee;
        uint256 activation;
        uint256 debtRatio;
        uint256 minDebtPerHarvest;
        uint256 maxDebtPerHarvest;
        uint256 lastReport;
        uint256 totalDebt;
        uint256 totalGain;
        uint256 totalSkim;
        uint256 totalLoss;
        address rewardsManager;
        EverscaleAddress rewards;
    }

    struct PendingWithdrawalParams {
        uint256 amount;
        uint256 bounty;
        uint256 timestamp;
        ApproveStatus approveStatus;
    }

    struct PendingWithdrawalId {
        address recipient;
        uint256 id;
    }

    struct WithdrawalPeriodParams {
        uint256 total;
        uint256 considered;
    }

    function initialize(
        address _token,
        address _bridge,
        address _governance,
        uint _targetDecimals,
        EverscaleAddress memory _rewards
    ) external;


    function withdrawGuardian() external view returns (address);


    function pendingWithdrawalsPerUser(address user) external view returns (uint);

    function pendingWithdrawals(
        address user,
        uint id
    ) external view returns (PendingWithdrawalParams memory);

    function pendingWithdrawalsTotal() external view returns (uint);


    function managementFee() external view returns (uint256);

    function performanceFee() external view returns (uint256);


    function strategies(
        address strategyId
    ) external view returns (StrategyParams memory);

    function withdrawalQueue() external view returns (address[20] memory);


    function withdrawLimitPerPeriod() external view returns (uint256);

    function undeclaredWithdrawLimit() external view returns (uint256);

    function withdrawalPeriods(
        uint256 withdrawalPeriodId
    ) external view returns (WithdrawalPeriodParams memory);


    function depositLimit() external view returns (uint256);

    function debtRatio() external view returns (uint256);

    function totalDebt() external view returns (uint256);

    function lastReport() external view returns (uint256);

    function lockedProfit() external view returns (uint256);

    function lockedProfitDegradation() external view returns (uint256);


    function setWithdrawGuardian(address _withdrawGuardian) external;

    function setStrategyRewards(
        address strategyId,
        EverscaleAddress memory _rewards
    ) external;

    function setLockedProfitDegradation(uint256 degradation) external;

    function setDepositLimit(uint256 limit) external;

    function setPerformanceFee(uint256 fee) external;

    function setManagementFee(uint256 fee) external;

    function setWithdrawLimitPerPeriod(uint256 _withdrawLimitPerPeriod) external;

    function setUndeclaredWithdrawLimit(uint256 _undeclaredWithdrawLimit) external;

    function setWithdrawalQueue(address[20] memory queue) external;

    function setPendingWithdrawalBounty(uint256 id, uint256 bounty) external;


    function deposit(
        EverscaleAddress memory recipient,
        uint256 amount,
        PendingWithdrawalId memory pendingWithdrawalId
    ) external;

    function deposit(
        EverscaleAddress memory recipient,
        uint256[] memory amount,
        PendingWithdrawalId[] memory pendingWithdrawalId
    ) external;

    function depositToFactory(
        uint128 amount,
        int8 wid,
        uint256 user,
        uint256 creditor,
        uint256 recipient,
        uint128 tokenAmount,
        uint128 tonAmount,
        uint8 swapType,
        uint128 slippageNumerator,
        uint128 slippageDenominator,
        bytes memory level3
    ) external;


    function saveWithdraw(
        bytes memory payload,
        bytes[] memory signatures
    ) external returns (
        bool instantWithdrawal,
        PendingWithdrawalId memory pendingWithdrawalId
    );


    function saveWithdraw(
        bytes memory payload,
        bytes[] memory signatures,
        uint bounty
    ) external;


    function cancelPendingWithdrawal(
        uint256 id,
        uint256 amount,
        EverscaleAddress memory recipient,
        uint bounty
    ) external;


    function withdraw(
        uint256 id,
        uint256 amountRequested,
        address recipient,
        uint256 maxLoss,
        uint bounty
    ) external returns(uint256);


    function addStrategy(
        address strategyId,
        uint256 _debtRatio,
        uint256 minDebtPerHarvest,
        uint256 maxDebtPerHarvest,
        uint256 _performanceFee
    ) external;


    function updateStrategyDebtRatio(
        address strategyId,
        uint256 _debtRatio
    )  external;


    function updateStrategyMinDebtPerHarvest(
        address strategyId,
        uint256 minDebtPerHarvest
    ) external;


    function updateStrategyMaxDebtPerHarvest(
        address strategyId,
        uint256 maxDebtPerHarvest
    ) external;


    function updateStrategyPerformanceFee(
        address strategyId,
        uint256 _performanceFee
    ) external;


    function migrateStrategy(
        address oldVersion,
        address newVersion
    ) external;


    function revokeStrategy(
        address strategyId
    ) external;

    function revokeStrategy() external;



    function totalAssets() external view returns (uint256);

    function debtOutstanding(address strategyId) external view returns (uint256);

    function debtOutstanding() external view returns (uint256);


    function creditAvailable(address strategyId) external view returns (uint256);

    function creditAvailable() external view returns (uint256);


    function availableDepositLimit() external view returns (uint256);

    function expectedReturn(address strategyId) external view returns (uint256);


    function report(
        uint256 profit,
        uint256 loss,
        uint256 _debtPayment
    ) external returns (uint256);


    function skim(address strategyId) external;


    function forceWithdraw(
        PendingWithdrawalId memory pendingWithdrawalId
    ) external;


    function forceWithdraw(
        PendingWithdrawalId[] memory pendingWithdrawalId
    ) external;


    function setPendingWithdrawalApprove(
        PendingWithdrawalId memory pendingWithdrawalId,
        ApproveStatus approveStatus
    ) external;


    function setPendingWithdrawalApprove(
        PendingWithdrawalId[] memory pendingWithdrawalId,
        ApproveStatus[] memory approveStatus
    ) external;



    event PendingWithdrawalUpdateBounty(address recipient, uint256 id, uint256 bounty);
    event PendingWithdrawalCancel(address recipient, uint256 id, uint256 amount);
    event PendingWithdrawalForce(address recipient, uint256 id);
    event PendingWithdrawalCreated(
        address recipient,
        uint256 id,
        uint256 amount,
        bytes32 payloadId
    );
    event PendingWithdrawalWithdraw(
        address recipient,
        uint256 id,
        uint256 requestedAmount,
        uint256 redeemedAmount
    );
    event PendingWithdrawalUpdateApproveStatus(
        address recipient,
        uint256 id,
        ApproveStatus approveStatus
    );

    event UpdateWithdrawLimitPerPeriod(uint256 withdrawLimitPerPeriod);
    event UpdateUndeclaredWithdrawLimit(uint256 undeclaredWithdrawLimit);
    event UpdateDepositLimit(uint256 depositLimit);

    event UpdatePerformanceFee(uint256 performanceFee);
    event UpdateManagementFee(uint256 managenentFee);

    event UpdateWithdrawGuardian(address withdrawGuardian);
    event UpdateWithdrawalQueue(address[20] queue);

    event StrategyUpdateDebtRatio(address indexed strategy, uint256 debtRatio);
    event StrategyUpdateMinDebtPerHarvest(address indexed strategy, uint256 minDebtPerHarvest);
    event StrategyUpdateMaxDebtPerHarvest(address indexed strategy, uint256 maxDebtPerHarvest);
    event StrategyUpdatePerformanceFee(address indexed strategy, uint256 performanceFee);
    event StrategyMigrated(address indexed oldVersion, address indexed newVersion);
    event StrategyRevoked(address indexed strategy);
    event StrategyRemovedFromQueue(address indexed strategy);
    event StrategyAddedToQueue(address indexed strategy);
    event StrategyReported(
        address indexed strategy,
        uint256 gain,
        uint256 loss,
        uint256 debtPaid,
        uint256 totalGain,
        uint256 totalSkim,
        uint256 totalLoss,
        uint256 totalDebt,
        uint256 debtAdded,
        uint256 debtRatio
    );

    event StrategyAdded(
        address indexed strategy,
        uint256 debtRatio,
        uint256 minDebtPerHarvest,
        uint256 maxDebtPerHarvest,
        uint256 performanceFee
    );
    event StrategyUpdateRewards(
        address strategyId,
        int128 wid,
        uint256 addr
    );
    event UserDeposit(
        address sender,
        int128 recipientWid,
        uint256 recipientAddr,
        uint256 amount,
        address withdrawalRecipient,
        uint256 withdrawalId,
        uint256 bounty
    );
    event FactoryDeposit(
        uint128 amount,
        int8 wid,
        uint256 user,
        uint256 creditor,
        uint256 recipient,
        uint128 tokenAmount,
        uint128 tonAmount,
        uint8 swapType,
        uint128 slippageNumerator,
        uint128 slippageDenominator,
        bytes1 separator,
        bytes level3
    );

}// AGPL-3.0

pragma solidity ^0.8.2;


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
}// AGPL-3.0

pragma solidity ^0.8.2;




abstract contract BaseStrategy {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    string public metadataURI;

    function apiVersion() public pure returns (string memory) {
        return "0.1.7";
    }

    function name() external virtual view returns (string memory);

    function delegatedAssets() external virtual view returns (uint256) {
        return 0;
    }

    IVault public vault;
    address public strategist;
    address public keeper;

    IERC20Upgradeable public want;

    event Harvested(uint256 profit, uint256 loss, uint256 debtPayment, uint256 debtOutstanding);

    event UpdatedStrategist(address newStrategist);

    event UpdatedKeeper(address newKeeper);

    event UpdatedMinReportDelay(uint256 delay);

    event UpdatedMaxReportDelay(uint256 delay);

    event UpdatedProfitFactor(uint256 profitFactor);

    event UpdatedDebtThreshold(uint256 debtThreshold);

    event EmergencyExitEnabled();

    event UpdatedMetadataURI(string metadataURI);

    uint256 public minReportDelay;

    uint256 public maxReportDelay;

    uint256 public profitFactor;

    uint256 public debtThreshold;

    bool public emergencyExit;

    modifier onlyAuthorized() {
        require(msg.sender == strategist || msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyStrategist() {
        require(msg.sender == strategist, "!strategist");
        _;
    }

    modifier onlyGovernance() {
        require(msg.sender == governance(), "!authorized");
        _;
    }

    modifier onlyKeepers() {
        require(
            msg.sender == keeper ||
            msg.sender == strategist ||
            msg.sender == governance() ||
            msg.sender == vault.guardian() ||
            msg.sender == vault.management(),
            "!authorized"
        );
        _;
    }

    function _initialize(
        address _vault
    ) internal virtual {
        require(address(want) == address(0), "Strategy already initialized");

        vault = IVault(_vault);
        want = IERC20Upgradeable(vault.token());
        want.safeApprove(_vault, type(uint256).max); // Give Vault unlimited access (might save gas)
        strategist = vault.governance();
        keeper = strategist;

        minReportDelay = 0;
        maxReportDelay = 86400;
        profitFactor = 100;
        debtThreshold = 0;
    }

    function setStrategist(address _strategist) external onlyAuthorized {
        require(_strategist != address(0));
        strategist = _strategist;
        emit UpdatedStrategist(_strategist);
    }

    function setKeeper(address _keeper) external onlyAuthorized {
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

    function setMetadataURI(string calldata _metadataURI) external onlyAuthorized {
        metadataURI = _metadataURI;
        emit UpdatedMetadataURI(_metadataURI);
    }

    function governance() internal view returns (address) {
        return vault.governance();
    }

    function estimatedTotalAssets() public virtual view returns (uint256);

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

    function liquidatePosition(uint256 _amountNeeded) internal virtual returns (uint256 _liquidatedAmount, uint256 _loss);

    function tendTrigger(uint256 /*callCost*/) public virtual view returns (bool) {
        return false;
    }

    function tend() external onlyKeepers {
        adjustPosition(vault.debtOutstanding());
    }

    function harvestTrigger(uint256 callCost) public virtual view returns (bool) {
        IVault.StrategyParams memory params = vault.strategies(address(this));

        if (params.activation == 0) return false;

        if ((block.timestamp - params.lastReport) < minReportDelay) return false;

        if ((block.timestamp - params.lastReport) >= maxReportDelay) return true;

        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > debtThreshold) return true;

        uint256 total = estimatedTotalAssets();
        if ((total + debtThreshold) < params.totalDebt) return true;

        uint256 profit = 0;
        if (total > params.totalDebt) profit = total - params.totalDebt; // We've earned a profit!

        uint256 credit = vault.creditAvailable();
        return ((profitFactor * callCost) < (credit + profit));
    }

    function harvest() external virtual onlyKeepers {
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

    function withdraw(uint256 _amountNeeded) external virtual returns (uint256 _loss) {
        require(msg.sender == address(vault), "!vault");
        uint256 amountFreed;
        (amountFreed, _loss) = liquidatePosition(_amountNeeded);
        want.safeTransfer(msg.sender, amountFreed);
    }

    function prepareMigration(address _newStrategy) internal virtual;

    function migrate(address _newStrategy) external {
        require(msg.sender == address(vault) || msg.sender == governance());
        require(BaseStrategy(_newStrategy).vault() == vault);
        prepareMigration(_newStrategy);
        want.safeTransfer(_newStrategy, want.balanceOf(address(this)));
    }

    function setEmergencyExit() external onlyAuthorized {
        emergencyExit = true;
        vault.revokeStrategy();

        emit EmergencyExitEnabled();
    }

    function protectedTokens() internal virtual view returns (address[] memory);

    function sweep(address _token) external virtual onlyGovernance {
        require(_token != address(want), "!want");
        require(_token != address(vault), "!shares");

        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20Upgradeable(_token).safeTransfer(governance(), IERC20Upgradeable(_token).balanceOf(address(this)));
    }
}// AGPL-3.0



pragma solidity ^0.8.2;





abstract contract ConvexCrvLp is BaseStrategy {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public constant booster = address(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);

    address public constant cvx = address(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address public constant uniswap = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public constant sushiswap = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

    bool public isClaimRewards;
    bool public isClaimExtras;
    uint256 public id;
    address public rewardContract;
    address public curve;

    IERC20Upgradeable public want_wrapped;
    uint public constant MAX_SLIPPAGE_FACTOR = 1000000;
    uint public slippage_factor;

    uint128 public curve_lp_idx;

    address[] public dex;

    function _approveBasic() internal virtual;

    function _approveDex() internal virtual;

    function approveAll() external onlyAuthorized {
        _approveBasic();
        _approveDex();
    }

    function switchDex(uint256 _id, address _dex) external onlyAuthorized {
        dex[_id] = _dex;
        _approveDex();
    }

    function setSlippageFactor(uint256 new_factor) external onlyAuthorized {
        require (slippage_factor < MAX_SLIPPAGE_FACTOR, 'Bad slippage factor');

        slippage_factor = new_factor;
    }

    function setIsClaimRewards(bool _isClaimRewards) external onlyAuthorized {
        isClaimRewards = _isClaimRewards;
    }

    function setIsClaimExtras(bool _isClaimExtras) external onlyAuthorized {
        isClaimExtras = _isClaimExtras;
    }

    function withdrawToConvexDepositTokens() external onlyAuthorized {
        Rewards(rewardContract).withdrawAll(isClaimRewards);
    }

    function withdrawToWrappedTokens() external onlyAuthorized {
        Rewards(rewardContract).withdrawAllAndUnwrap(isClaimRewards);
    }

    function claimWantTokens() external onlyGovernance {
        want.safeTransfer(governance(), balanceOfWant());
    }

    function claimWrappedWantTokens() external onlyGovernance {
        want_wrapped.safeTransfer(governance(), balanceOfWrapped());
    }

    function claimRewardTokens() external onlyGovernance {
        IERC20Upgradeable(crv).safeTransfer(governance(), IERC20Upgradeable(crv).balanceOf(address(this)));
        IERC20Upgradeable(cvx).safeTransfer(governance(), IERC20Upgradeable(cvx).balanceOf(address(this)));
    }

    function name() external view override returns (string memory) {
        return string(abi.encodePacked("Convex", IERC20MetadataUpgradeable(address(want_wrapped)).symbol()));
    }

    function calc_want_from_wrapped(uint256 wrapped_amount) public virtual view returns (uint256 expected_return) {
        if (wrapped_amount > 0) {
            expected_return = ICurveFi(curve).calc_withdraw_one_coin(wrapped_amount, int128(curve_lp_idx));
        }
    }

    function calc_wrapped_from_want(uint256 want_amount) public virtual view returns (uint256);

    function apply_slippage_factor(uint256 amount) public view returns (uint256) {
        return (amount * (slippage_factor + MAX_SLIPPAGE_FACTOR)) / MAX_SLIPPAGE_FACTOR;
    }

    function unwrap(uint256 wrapped_amount) internal virtual returns (uint256 expected_return) {
        if (wrapped_amount > 0) {
            expected_return = calc_want_from_wrapped(wrapped_amount);
            ICurveFi(curve).remove_liquidity_one_coin(wrapped_amount, int128(curve_lp_idx), 0);
        }
    }

    function wrap(uint256 want_amount) internal virtual returns (uint256 expected_return);

    function balanceOfWant() public view returns (uint256) {
        return want.balanceOf(address(this));
    }

    function balanceOfPool() public view returns (uint256) {
        return Rewards(rewardContract).balanceOf(address(this));
    }

    function balanceOfWrapped() public view returns (uint256) {
        return want_wrapped.balanceOf(address(this));
    }

    function estimatedTotalAssets() public view override returns (uint256) {
        uint256 total_wrapped = estimatedTotalWrappedAssets();
        return calc_want_from_wrapped(total_wrapped) + balanceOfWant();
    }

    function estimatedTotalWrappedAssets() public view returns (uint256) {
        return balanceOfWrapped() + balanceOfPool();
    }

    function adjustPosition(uint256 /*_debtOutstanding*/) internal override {
        if (emergencyExit) return;

        uint256 total_available = balanceOfWant() + calc_want_from_wrapped(balanceOfWrapped());
        IVault.StrategyParams memory params = vault.strategies(address(this));
        if (total_available < params.minDebtPerHarvest) {
            return;
        }

        wrap(balanceOfWant());

        uint256 _wrapped = balanceOfWrapped();
        if (_wrapped > 0) {
            Booster(booster).deposit(id, _wrapped, true);
        }
    }

    function _withdrawSome(uint256 _amount) internal returns (uint256) {
        _amount = Math.min(_amount, balanceOfPool());
        uint _before = balanceOfWrapped();
        Rewards(rewardContract).withdrawAndUnwrap(_amount, false);
        return balanceOfWrapped() - _before;
    }

    function liquidatePosition(uint256 _amountNeeded)
    internal
    override
    returns (uint256 _liquidatedAmount, uint256 _loss)
    {
        uint256 _balance = balanceOfWrapped();
        if (_balance < _amountNeeded) {
            _liquidatedAmount = _withdrawSome(_amountNeeded - _balance);
            _liquidatedAmount += _balance;
            _loss = _amountNeeded - _liquidatedAmount; // this should be 0. o/w there must be an error
        }
        else {
            _liquidatedAmount = _amountNeeded;
        }
    }

    function prepareMigration(address _newStrategy) internal override {
        Rewards(rewardContract).withdrawAllAndUnwrap(isClaimRewards);
        _migrateRewards(_newStrategy);
        want_wrapped.safeTransfer(_newStrategy, balanceOfWrapped());
    }

    function _migrateRewards(address _newStrategy) internal virtual {
        IERC20Upgradeable(crv).safeTransfer(_newStrategy, IERC20Upgradeable(crv).balanceOf(address(this)));
        IERC20Upgradeable(cvx).safeTransfer(_newStrategy, IERC20Upgradeable(cvx).balanceOf(address(this)));
    }

    function _claimableBasicInETH() internal view returns (uint256) {
        uint256 _crv = Rewards(rewardContract).earned(address(this));

        uint256 totalCliffs = 1000;
        uint256 maxSupply = 1e8 * 1e18; // 100m
        uint256 reductionPerCliff = 1e5 * 1e18; // 100k
        uint256 supply = IERC20Upgradeable(cvx).totalSupply();
        uint256 _cvx;

        uint256 cliff = supply / reductionPerCliff;
        if (cliff < totalCliffs) {
            uint256 reduction = totalCliffs - cliff;
            _cvx = (_crv * reduction) / totalCliffs;

            uint256 amtTillMax = maxSupply - supply;
            if (_cvx > amtTillMax) {
                _cvx = amtTillMax;
            }
        }

        uint256 crvValue;
        if (_crv > 0) {
            address[] memory path = new address[](2);
            path[0] = crv;
            path[1] = weth;
            uint256[] memory crvSwap = Uni(dex[0]).getAmountsOut(_crv, path);
            crvValue = crvSwap[1];
        }

        uint256 cvxValue;
        if (_cvx > 0) {
            address[] memory path = new address[](2);
            path[0] = cvx;
            path[1] = weth;
            uint256[] memory cvxSwap = Uni(dex[1]).getAmountsOut(_cvx, path);
            cvxValue = cvxSwap[1];
        }

        return crvValue + cvxValue;
    }

    function claimableInETH() public virtual view returns (uint256 _claimable) {
        _claimable = _claimableBasicInETH();
    }

    function harvestTrigger(uint256 callCost) public override view returns (bool) {
        IVault.StrategyParams memory params = vault.strategies(address(this));

        if (params.activation == 0) return false;

        if ((block.timestamp - params.lastReport) < minReportDelay) return false;

        if ((block.timestamp - params.lastReport) >= maxReportDelay) return true;

        uint256 outstanding = vault.debtOutstanding();
        if (outstanding > debtThreshold) return true;

        uint256 total = estimatedTotalAssets();
        if ((total + debtThreshold) < params.totalDebt) return true;

        return ((profitFactor * callCost) < claimableInETH());
    }

    function harvest() external override onlyKeepers {
        uint256 profit = 0;
        uint256 loss = 0;
        uint256 debtOutstanding = calc_wrapped_from_want(vault.debtOutstanding());
        uint256 debtPayment = 0;

        if (emergencyExit) {
            uint256 totalAssets = estimatedTotalWrappedAssets();
            (debtPayment, loss) = liquidatePosition(totalAssets > debtOutstanding ? totalAssets : debtOutstanding);
            if (debtPayment > debtOutstanding) {
                profit = debtPayment - debtOutstanding;
                debtPayment = debtOutstanding;
            }
        } else {
            (profit, loss, debtPayment) = prepareReturn(debtOutstanding);
        }

        uint256 want_profit = calc_want_from_wrapped(profit);
        uint256 want_profit_plus_debtPayment = unwrap(profit + debtPayment);
        uint256 want_debtPayment = want_profit_plus_debtPayment - want_profit;

        uint256 want_loss = calc_want_from_wrapped(loss);

        debtOutstanding = vault.report(want_profit, want_loss, want_debtPayment);

        adjustPosition(debtOutstanding);

        emit Harvested(want_profit, want_loss, want_debtPayment, debtOutstanding);
    }

    function withdraw(uint256 _amountNeeded) external override returns (uint256 _loss) {
        require(msg.sender == address(vault), "!vault");
        uint _amountNeededWrapped;
        uint _amountNeededFirst = _amountNeeded;

        for (uint i = 0; i < 3; i++) {
            _amountNeeded = apply_slippage_factor(_amountNeeded);
            _amountNeededWrapped = calc_wrapped_from_want(_amountNeeded);
            uint _expectedUnwrapped = calc_want_from_wrapped(_amountNeededWrapped);
            if (_expectedUnwrapped >= _amountNeededFirst) {
                break;
            }
        }

        uint256 amountFreed;
        (amountFreed, _loss) = liquidatePosition(_amountNeededWrapped);

        amountFreed = unwrap(amountFreed);
        _loss = calc_want_from_wrapped(_loss);

        if (amountFreed > _amountNeededFirst) {
            amountFreed = _amountNeededFirst;
        }

        want.safeTransfer(msg.sender, amountFreed);
    }

    function protectedTokens()
    internal
    pure
    override
    returns (address[] memory)
    {
        address[] memory protected = new address[](2);
        protected[0] = crv;
        protected[1] = cvx;
        return protected;
    }

    function sweep(address _token) external override onlyGovernance {
        require(_token != address(want), "!want");
        require(_token != address(want_wrapped), "!want wrapped");

        address[] memory _protectedTokens = protectedTokens();
        for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

        IERC20Upgradeable(_token).safeTransfer(governance(), IERC20Upgradeable(_token).balanceOf(address(this)));
    }
}/**
 *Submitted for verification at Etherscan.io on 2021-05-30
*/


pragma solidity ^0.8.2;




contract ConvexFraxStrategy is ConvexCrvLp, Initializable {

    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public constant dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address public constant usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    address public constant crv3 = address(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);
    address public constant frax3crv = address(0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B);
    address public constant zapCurve = address(0xA79828DF1850E8a3A3064576f380D90aECDD3359);

    address[] public pathTarget;

    function initialize(
        address _vault
    ) external initializer {

        BaseStrategy._initialize(_vault);

        slippage_factor = 150;
        minReportDelay = 1 days;
        maxReportDelay = 30 days;
        profitFactor = 100000;
        debtThreshold = 1e24;
        want_wrapped = IERC20Upgradeable(frax3crv);
        want_wrapped.safeApprove(_vault, type(uint256).max); // Give Vault unlimited access (might save gas)

        if (address(want) == dai) {
            curve_lp_idx = 0;
        } else if (address(want) == usdc) {
            curve_lp_idx = 1;
        } else if (address(want) == usdt) {
            curve_lp_idx = 2;
        } else {
            revert("Strategy cant be applied to this vault");
        }

        curve = frax3crv;
        id = 32;
        isClaimRewards = true; // default is true, turn off in emergency

        (address _lp,,,address _reward,,) = Booster(booster).poolInfo(id);
        require(_lp == address(want_wrapped), "constructor: incorrect lp token");
        rewardContract = _reward;

        _approveBasic();
        pathTarget = new address[](2);
        _setPathTarget(0, 1); // crv path target
        _setPathTarget(1, 1); // cvx path target

        dex = new address[](2);
        dex[0] = sushiswap; // crv
        dex[1] = sushiswap; // cvx
        _approveDex();
    }

    function _approveBasic() internal override {

        want_wrapped.safeApprove(booster, 0);
        want_wrapped.safeApprove(booster, type(uint256).max);
        want_wrapped.safeApprove(zapCurve, 0);
        want_wrapped.safeApprove(zapCurve, type(uint256).max);
        IERC20Upgradeable(dai).safeApprove(zapCurve, 0);
        IERC20Upgradeable(dai).safeApprove(zapCurve, type(uint256).max);
        IERC20Upgradeable(usdc).safeApprove(zapCurve, 0);
        IERC20Upgradeable(usdc).safeApprove(zapCurve, type(uint256).max);
        IERC20Upgradeable(usdt).safeApprove(zapCurve, 0);
        IERC20Upgradeable(usdt).safeApprove(zapCurve, type(uint256).max);
    }

    function _approveDex() internal override {

        IERC20Upgradeable(crv).safeApprove(dex[0], 0);
        IERC20Upgradeable(crv).safeApprove(dex[0], type(uint256).max);
        IERC20Upgradeable(cvx).safeApprove(dex[1], 0);
        IERC20Upgradeable(cvx).safeApprove(dex[1], type(uint256).max);
    }

    function calc_want_from_wrapped(uint256 wrapped_amount) public view override returns (uint256 expected_return) {

        if (wrapped_amount > 0) {
            expected_return = ICurveFi(zapCurve).calc_withdraw_one_coin(curve, wrapped_amount, int128(curve_lp_idx) + 1);
        }
    }

    function calc_wrapped_from_want(uint256 want_amount) public view override returns (uint256) {

        uint256[4] memory amounts;
        amounts[curve_lp_idx + 1] = want_amount;
        return ICurveFi(zapCurve).calc_token_amount(curve, amounts, true);
    }

    function wrap(uint256 want_amount) internal override returns (uint256 expected_return) {

        if (want_amount > 0) {
            expected_return = calc_wrapped_from_want(want_amount);
            uint256[4] memory amounts;
            amounts[curve_lp_idx + 1] = want_amount;
            ICurveFi(zapCurve).add_liquidity(curve, amounts, 0);
        }
    }

    function unwrap(uint256 wrapped_amount) internal override returns (uint256 expected_return) {

        if (wrapped_amount > 0) {
            expected_return = calc_want_from_wrapped(wrapped_amount);
            ICurveFi(zapCurve).remove_liquidity_one_coin(curve, wrapped_amount, int128(curve_lp_idx) + 1, 0);
        }
    }





    function _setPathTarget(uint _tokenId, uint _id) internal {

        if (_id == 0) {
            pathTarget[_tokenId] = dai;
        }
        else if (_id == 1) {
            pathTarget[_tokenId] = usdc;
        }
        else {
            pathTarget[_tokenId] = usdt;
        }
    }

    function setPathTarget(uint _tokenId, uint _id) external onlyAuthorized {

        _setPathTarget(_tokenId, _id);
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

        uint before = balanceOfWrapped() + calc_wrapped_from_want(balanceOfWant());

        Rewards(rewardContract).getReward(address(this), isClaimExtras);
        uint256 _crv = IERC20Upgradeable(crv).balanceOf(address(this));
        if (_crv > 0) {
            address[] memory path = new address[](3);
            path[0] = crv;
            path[1] = weth;
            path[2] = pathTarget[0];

            Uni(dex[0]).swapExactTokensForTokens(_crv, uint256(0), path, address(this), block.timestamp);
        }
        uint256 _cvx = IERC20Upgradeable(cvx).balanceOf(address(this));
        if (_cvx > 0) {
            address[] memory path = new address[](3);
            path[0] = cvx;
            path[1] = weth;
            path[2] = pathTarget[1];

            Uni(dex[1]).swapExactTokensForTokens(_cvx, uint256(0), path, address(this), block.timestamp);
        }
        uint256 _dai = IERC20Upgradeable(dai).balanceOf(address(this));
        uint256 _usdc = IERC20Upgradeable(usdc).balanceOf(address(this));
        uint256 _usdt = IERC20Upgradeable(usdt).balanceOf(address(this));
        if (_dai > 0 || _usdc > 0 || _usdt > 0) {
            ICurveFi(zapCurve).add_liquidity(curve, [0, _dai, _usdc, _usdt], 0);
        }
        _profit = balanceOfWrapped() - before;

        uint _total = estimatedTotalWrappedAssets();
        uint _debt = calc_wrapped_from_want(vault.strategies(address(this)).totalDebt);
        if (_total < _debt) {
            _loss = _debt - _total;
            _profit = 0;
        }

        if (_debtOutstanding > 0) {
            _withdrawSome(_debtOutstanding);
            _debtPayment = Math.min(_debtOutstanding, balanceOfWrapped() - _profit);
        }
    }
}