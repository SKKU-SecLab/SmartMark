
pragma solidity ^0.8.1;

library Address {

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
        return !Address.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

pragma experimental ABIEncoderV2;


interface IBridge is IEverscale {

    struct Round {
        uint32 end;
        uint32 ttl;
        uint32 relays;
        uint32 requiredSignatures;
    }

    function updateMinimumRequiredSignatures(uint32 _minimumRequiredSignatures) external;

    function setConfiguration(EverscaleAddress calldata _roundRelaysConfiguration) external;

    function updateRoundTTL(uint32 _roundTTL) external;


    function isRelay(
        uint32 round,
        address candidate
    ) external view returns (bool);


    function isBanned(
        address candidate
    ) external view returns (bool);


    function isRoundRotten(
        uint32 round
    ) external view returns (bool);


    function verifySignedEverscaleEvent(
        bytes memory payload,
        bytes[] memory signatures
    ) external view returns (uint32);


    function setRoundRelays(
        bytes calldata payload,
        bytes[] calldata signatures
    ) external;


    function forceRoundRelays(
        uint160[] calldata _relays,
        uint32 roundEnd
    ) external;


    function banRelays(
        address[] calldata _relays
    ) external;


    function unbanRelays(
        address[] calldata _relays
    ) external;


    function pause() external;

    function unpause() external;


    function setRoundSubmitter(address _roundSubmitter) external;


    event EmergencyShutdown(bool active);

    event UpdateMinimumRequiredSignatures(uint32 value);
    event UpdateRoundTTL(uint32 value);
    event UpdateRoundRelaysConfiguration(EverscaleAddress configuration);
    event UpdateRoundSubmitter(address _roundSubmitter);

    event NewRound(uint32 indexed round, Round meta);
    event RoundRelay(uint32 indexed round, address indexed relay);
    event BanRelay(address indexed relay, bool status);
}// AGPL-3.0
pragma solidity ^0.8.2;


interface IStrategy {

    function vault() external view returns (address);

    function want() external view returns (address);

    function isActive() external view returns (bool);

    function delegatedAssets() external view returns (uint256);

    function estimatedTotalAssets() external view returns (uint256);

    function withdraw(uint256 _amountNeeded) external returns (uint256 _loss);

    function migrate(address newStrategy) external;

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
        uint256 expectedMinBounty,
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

    function skimFees(bool skim_to_everscale) external;

    function fees() external view returns (uint256);


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





abstract contract VaultStorage is IVault, Initializable, ReentrancyGuard {
    uint256 constant MAX_BPS = 10_000;
    uint256 constant WITHDRAW_PERIOD_DURATION_IN_SECONDS = 60 * 60 * 24; // 24 hours
    uint256 constant SECS_PER_YEAR = 31_556_952; // 365.2425 days

    address public override bridge;
    EverscaleAddress configuration_;

    function configuration()
        external
        view
        override
    returns (EverscaleAddress memory) {
        return configuration_;
    }

    mapping(bytes32 => bool) public override withdrawalIds;
    EverscaleAddress rewards_;

    function rewards()
        external
        view
        override
    returns (EverscaleAddress memory) {
        return rewards_;
    }

    mapping(address => uint) public override pendingWithdrawalsPerUser;
    mapping(address => mapping(uint256 => PendingWithdrawalParams)) pendingWithdrawals_;

    function pendingWithdrawals(
        address user,
        uint256 id
    ) external view override returns (PendingWithdrawalParams memory) {
        return pendingWithdrawals_[user][id];
    }

    uint public override pendingWithdrawalsTotal;

    address public override governance;
    address pendingGovernance;
    address public override guardian;
    address public override withdrawGuardian;
    address public override management;

    address public override token;
    uint256 public override targetDecimals;
    uint256 public override tokenDecimals;

    uint256 public override depositFee;
    uint256 public override withdrawFee;
    uint256 public override managementFee;
    uint256 public override performanceFee;

    mapping(address => StrategyParams) strategies_;

    function strategies(
        address strategyId
    ) external view override returns (StrategyParams memory) {
        return strategies_[strategyId];
    }

    uint256 constant DEGRADATION_COEFFICIENT = 10**18;
    uint256 constant SET_SIZE = 32;
    address[20] withdrawalQueue_;

    function withdrawalQueue() external view override returns (address[20] memory) {
        return withdrawalQueue_;
    }

    bool public override emergencyShutdown;
    uint256 public override withdrawLimitPerPeriod;
    uint256 public override undeclaredWithdrawLimit;
    mapping(uint256 => WithdrawalPeriodParams) withdrawalPeriods_;

    function withdrawalPeriods(
        uint256 withdrawalPeriodId
    ) external view override returns (WithdrawalPeriodParams memory) {
        return withdrawalPeriods_[withdrawalPeriodId];
    }

    uint256 public override depositLimit;
    uint256 public override debtRatio;
    uint256 public override totalDebt;
    uint256 public override lastReport;
    uint256 public override lockedProfit;
    uint256 public override lockedProfitDegradation;

    uint256 public override fees;
}// AGPL-3.0
pragma solidity ^0.8.2;






abstract contract VaultHelpers is VaultStorage {
    modifier onlyGovernance() {
        require(msg.sender == governance);

        _;
    }

    modifier onlyPendingGovernance() {
        require(msg.sender == pendingGovernance);

        _;
    }

    modifier onlyStrategyOrGovernanceOrGuardian(address strategyId) {
        require(msg.sender == strategyId || msg.sender == governance || msg.sender == guardian);

        _;
    }

    modifier onlyGovernanceOrManagement() {
        require(msg.sender == governance || msg.sender == management);

        _;
    }

    modifier onlyGovernanceOrGuardian() {
        require(msg.sender == governance || msg.sender == guardian);

        _;
    }

    modifier onlyGovernanceOrWithdrawGuardian() {
        require(msg.sender == governance || msg.sender == withdrawGuardian);

        _;
    }

    modifier onlyGovernanceOrStrategyRewardsManager(address strategyId) {
        require(msg.sender == governance || msg.sender == strategies_[strategyId].rewardsManager);

        _;
    }

    modifier pendingWithdrawalOpened(
        PendingWithdrawalId memory pendingWithdrawalId
    ) {
        PendingWithdrawalParams memory pendingWithdrawal = _pendingWithdrawal(pendingWithdrawalId);

        require(pendingWithdrawal.amount > 0, "Vault: pending withdrawal closed");

        _;
    }

    modifier pendingWithdrawalApproved(
        PendingWithdrawalId memory pendingWithdrawalId
    ) {
        PendingWithdrawalParams memory pendingWithdrawal = _pendingWithdrawal(pendingWithdrawalId);

        require(
            pendingWithdrawal.approveStatus == ApproveStatus.NotRequired ||
            pendingWithdrawal.approveStatus == ApproveStatus.Approved,
            "Vault: pending withdrawal not approved"
        );

        _;
    }

    modifier strategyExists(address strategyId) {
        StrategyParams memory strategy = _strategy(strategyId);

        require(strategy.activation > 0, "Vault: strategy not exists");

        _;
    }

    modifier strategyNotExists(address strategyId) {
        StrategyParams memory strategy = _strategy(strategyId);

        require(strategy.activation == 0, "Vault: strategy exists");

        _;
    }

    modifier respectDepositLimit(uint amount) {
        require(
            _totalAssets() + amount <= depositLimit,
            "Vault: respect the deposit limit"
        );

        _;
    }

    modifier onlyEmergencyDisabled() {
        require(!emergencyShutdown, "Vault: emergency mode enabled");

        _;
    }

    modifier withdrawalNotSeenBefore(bytes memory payload) {
        bytes32 withdrawalId = keccak256(payload);

        require(!withdrawalIds[withdrawalId], "Vault: withdraw payload already seen");

        _;

        withdrawalIds[withdrawalId] = true;
    }

    function decodeWithdrawalEventData(
        bytes memory eventData
    ) public view override returns(WithdrawalParams memory) {
        (
            int8 sender_wid,
            uint256 sender_addr,
            uint128 amount,
            uint160 recipient,
            uint32 chainId
        ) = abi.decode(
            eventData,
            (int8, uint256, uint128, uint160, uint32)
        );

        return WithdrawalParams({
            sender: EverscaleAddress(sender_wid, sender_addr),
            amount: convertFromTargetDecimals(amount),
            recipient: address(recipient),
            chainId: chainId
        });
    }

    function _vaultTokenBalance() internal view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function _debtRatioReduce(
        uint256 amount
    ) internal {
        debtRatio -= amount;
    }

    function _debtRatioIncrease(
        uint256 amount
    ) internal {
        debtRatio += amount;
    }

    function _totalAssets() internal view returns (uint256) {
        return _vaultTokenBalance() + totalDebt;
    }

    function _calculateLockedProfit() internal view returns (uint256) {
        uint256 lockedFundsRatio = (block.timestamp - lastReport) * lockedProfitDegradation;

        if (lockedFundsRatio < DEGRADATION_COEFFICIENT) {
            uint256 _lockedProfit = lockedProfit;

            return _lockedProfit - (lockedFundsRatio * _lockedProfit / DEGRADATION_COEFFICIENT);
        } else {
            return 0;
        }
    }

    function convertFromTargetDecimals(
        uint256 amount
    ) public view returns (uint256) {
        if (targetDecimals == tokenDecimals) {
            return amount;
        } else if (targetDecimals > tokenDecimals) {
            return amount / 10 ** (targetDecimals - tokenDecimals);
        } else {
            return amount * 10 ** (tokenDecimals - targetDecimals);
        }
    }

    function convertToTargetDecimals(
        uint256 amount
    ) public view returns (uint256) {
        if (targetDecimals == tokenDecimals) {
            return amount;
        } else if (targetDecimals > tokenDecimals) {
            return amount * 10 ** (targetDecimals - tokenDecimals);
        } else {
            return amount / 10 ** (tokenDecimals - targetDecimals);
        }
    }

    function _calculateMovementFee(
        uint256 amount,
        uint256 fee
    ) internal pure returns (uint256) {
        if (fee == 0) return 0;

        return amount * fee / MAX_BPS;
    }

    function _strategy(
        address strategyId
    ) internal view returns (StrategyParams memory) {
        return strategies_[strategyId];
    }

    function _strategyCreate(
        address strategyId,
        StrategyParams memory strategyParams
    ) internal {
        strategies_[strategyId] = strategyParams;
    }

    function _strategyRewardsUpdate(
        address strategyId,
        EverscaleAddress memory _rewards
    ) internal {
        strategies_[strategyId].rewards = _rewards;
    }

    function _strategyDebtRatioUpdate(
        address strategyId,
        uint256 debtRatio
    ) internal {
        strategies_[strategyId].debtRatio = debtRatio;
    }

    function _strategyLastReportUpdate(
        address strategyId
    ) internal {
        strategies_[strategyId].lastReport = block.timestamp;
        lastReport = block.timestamp;
    }

    function _strategyTotalDebtReduce(
        address strategyId,
        uint256 debtPayment
    ) internal {
        strategies_[strategyId].totalDebt -= debtPayment;
        totalDebt -= debtPayment;
    }

    function _strategyTotalDebtIncrease(
        address strategyId,
        uint256 credit
    ) internal {
        strategies_[strategyId].totalDebt += credit;
        totalDebt += credit;
    }

    function _strategyDebtOutstanding(
        address strategyId
    ) internal view returns (uint256) {
        StrategyParams memory strategy = _strategy(strategyId);

        if (debtRatio == 0) return strategy.totalDebt;

        uint256 strategy_debtLimit = strategy.debtRatio * _totalAssets() / MAX_BPS;

        if (emergencyShutdown) {
            return strategy.totalDebt;
        } else if (strategy.totalDebt <= strategy_debtLimit) {
            return 0;
        } else {
            return strategy.totalDebt - strategy_debtLimit;
        }
    }

    function _strategyCreditAvailable(
        address strategyId
    ) internal view returns (uint256) {
        if (emergencyShutdown) return 0;

        uint256 vault_totalAssets = _totalAssets();

        if (pendingWithdrawalsTotal >= vault_totalAssets) return 0;

        uint256 vault_debtLimit = debtRatio * vault_totalAssets / MAX_BPS;
        uint256 vault_totalDebt = totalDebt;

        StrategyParams memory strategy = _strategy(strategyId);

        uint256 strategy_debtLimit = strategy.debtRatio * vault_totalAssets / MAX_BPS;

        if (strategy_debtLimit <= strategy.totalDebt || vault_debtLimit <= vault_totalDebt) return 0;

        uint256 available = strategy_debtLimit - strategy.totalDebt;

        available = Math.min(available, vault_debtLimit - vault_totalDebt);

        available = Math.min(available, IERC20(token).balanceOf(address(this)));

        if (available < strategy.minDebtPerHarvest) {
            return 0;
        } else {
            return Math.min(available, strategy.maxDebtPerHarvest);
        }
    }

    function _strategyTotalGainIncrease(
        address strategyId,
        uint256 amount
    ) internal {
        strategies_[strategyId].totalGain += amount;
    }

    function _strategyExpectedReturn(
        address strategyId
    ) internal view returns (uint256) {
        StrategyParams memory strategy = _strategy(strategyId);

        uint256 timeSinceLastHarvest = block.timestamp - strategy.lastReport;
        uint256 totalHarvestTime = strategy.lastReport - strategy.activation;

        if (timeSinceLastHarvest > 0 && totalHarvestTime > 0 && IStrategy(strategyId).isActive()) {
            return strategy.totalGain * timeSinceLastHarvest / totalHarvestTime;
        } else {
            return 0;
        }
    }

    function _strategyDebtRatioReduce(
        address strategyId,
        uint256 amount
    ) internal {
        strategies_[strategyId].debtRatio -= amount;
        debtRatio -= amount;
    }

    function _strategyRevoke(
        address strategyId
    ) internal {
        _strategyDebtRatioReduce(strategyId, strategies_[strategyId].debtRatio);
    }

    function _strategyMinDebtPerHarvestUpdate(
        address strategyId,
        uint256 minDebtPerHarvest
    ) internal {
        strategies_[strategyId].minDebtPerHarvest = minDebtPerHarvest;
    }

    function _strategyMaxDebtPerHarvestUpdate(
        address strategyId,
        uint256 maxDebtPerHarvest
    ) internal {
        strategies_[strategyId].maxDebtPerHarvest = maxDebtPerHarvest;
    }


    function _strategyReportLoss(
        address strategyId,
        uint256 loss
    ) internal {
        StrategyParams memory strategy = _strategy(strategyId);

        uint256 totalDebt = strategy.totalDebt;

        require(loss <= totalDebt);

        if (debtRatio != 0) { // if vault with single strategy that is set to EmergencyOne
            uint256 ratio_change = Math.min(
                loss * debtRatio / totalDebt,
                strategy.debtRatio
            );

            _strategyDebtRatioReduce(strategyId, ratio_change);
        }

        strategies_[strategyId].totalLoss += loss;

        _strategyTotalDebtReduce(strategyId, loss);
    }

    function _pendingWithdrawal(
        PendingWithdrawalId memory pendingWithdrawalId
    ) internal view returns (PendingWithdrawalParams memory) {
        return pendingWithdrawals_[pendingWithdrawalId.recipient][pendingWithdrawalId.id];
    }

    function _pendingWithdrawalCreate(
        address recipient,
        uint256 amount,
        uint256 timestamp
    ) internal returns (uint256 pendingWithdrawalId) {
        pendingWithdrawalId = pendingWithdrawalsPerUser[recipient];
        pendingWithdrawalsPerUser[recipient]++;

        pendingWithdrawals_[recipient][pendingWithdrawalId] = PendingWithdrawalParams({
            amount: amount,
            timestamp: timestamp,
            bounty: 0,
            approveStatus: ApproveStatus.NotRequired
        });

        pendingWithdrawalsTotal += amount;

        return pendingWithdrawalId;
    }

    function _pendingWithdrawalBountyUpdate(
        PendingWithdrawalId memory pendingWithdrawalId,
        uint bounty
    ) internal {
        pendingWithdrawals_[pendingWithdrawalId.recipient][pendingWithdrawalId.id].bounty = bounty;

        emit PendingWithdrawalUpdateBounty(pendingWithdrawalId.recipient, pendingWithdrawalId.id, bounty);
    }

    function _pendingWithdrawalAmountReduce(
        PendingWithdrawalId memory pendingWithdrawalId,
        uint amount
    ) internal {
        pendingWithdrawals_[pendingWithdrawalId.recipient][pendingWithdrawalId.id].amount -= amount;
        pendingWithdrawalsTotal -= amount;
    }

    function _pendingWithdrawalApproveStatusUpdate(
        PendingWithdrawalId memory pendingWithdrawalId,
        ApproveStatus approveStatus
    ) internal {
        pendingWithdrawals_[pendingWithdrawalId.recipient][pendingWithdrawalId.id].approveStatus = approveStatus;

        emit PendingWithdrawalUpdateApproveStatus(
            pendingWithdrawalId.recipient,
            pendingWithdrawalId.id,
            approveStatus
        );
    }


    function _withdrawalPeriodDeriveId(
        uint256 timestamp
    ) internal pure returns (uint256) {
        return timestamp / WITHDRAW_PERIOD_DURATION_IN_SECONDS;
    }

    function _withdrawalPeriod(
        uint256 timestamp
    ) internal view returns (WithdrawalPeriodParams memory) {
        return withdrawalPeriods_[_withdrawalPeriodDeriveId(timestamp)];
    }

    function _withdrawalPeriodIncreaseTotalByTimestamp(
        uint256 timestamp,
        uint256 amount
    ) internal {
        uint withdrawalPeriodId = _withdrawalPeriodDeriveId(timestamp);

        withdrawalPeriods_[withdrawalPeriodId].total += amount;
    }

    function _withdrawalPeriodIncreaseConsideredByTimestamp(
        uint256 timestamp,
        uint256 amount
    ) internal {
        uint withdrawalPeriodId = _withdrawalPeriodDeriveId(timestamp);

        withdrawalPeriods_[withdrawalPeriodId].considered += amount;
    }

    function _withdrawalPeriodCheckLimitsPassed(
        uint amount,
        WithdrawalPeriodParams memory withdrawalPeriod
    ) internal view returns (bool) {
        return  amount < undeclaredWithdrawLimit &&
        amount + withdrawalPeriod.total - withdrawalPeriod.considered < withdrawLimitPerPeriod;
    }

    function _getChainID() internal view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}// AGPL-3.0
pragma solidity ^0.8.2;






string constant API_VERSION = '0.1.8';

contract Vault is IVault, VaultHelpers {

    using SafeERC20 for IERC20;

    function initialize(
        address _token,
        address _bridge,
        address _governance,
        uint _targetDecimals,
        EverscaleAddress memory _rewards
    ) external override initializer {

        bridge = _bridge;
        emit UpdateBridge(bridge);

        governance = _governance;
        emit UpdateGovernance(governance);

        rewards_ = _rewards;
        emit UpdateRewards(rewards_.wid, rewards_.addr);

        performanceFee = 0;
        emit UpdatePerformanceFee(0);

        managementFee = 0;
        emit UpdateManagementFee(0);

        withdrawFee = 0;
        emit UpdateWithdrawFee(0);

        depositFee = 0;
        emit UpdateDepositFee(0);

        token = _token;
        tokenDecimals = IERC20Metadata(token).decimals();
        targetDecimals = _targetDecimals;
    }

    function apiVersion()
        external
        override
        pure
        returns (string memory api_version)
    {

        return API_VERSION;
    }

    function setDepositFee(
        uint _depositFee
    ) external override onlyGovernanceOrManagement {

        require(_depositFee <= MAX_BPS / 2);

        depositFee = _depositFee;

        emit UpdateDepositFee(depositFee);
    }

    function setWithdrawFee(
        uint _withdrawFee
    ) external override onlyGovernanceOrManagement {

        require(_withdrawFee <= MAX_BPS / 2);

        withdrawFee = _withdrawFee;

        emit UpdateWithdrawFee(withdrawFee);
    }

    function setConfiguration(
        EverscaleAddress memory _configuration
    ) external override onlyGovernance {

        configuration_ = _configuration;

        emit UpdateConfiguration(configuration_.wid, configuration_.addr);
    }

    function setGovernance(
        address _governance
    ) external override onlyGovernance {

        pendingGovernance = _governance;

        emit NewPendingGovernance(pendingGovernance);
    }

    function acceptGovernance()
        external
        override
        onlyPendingGovernance
    {

        governance = pendingGovernance;

        emit UpdateGovernance(governance);
    }

    function setManagement(
        address _management
    )
        external
        override
        onlyGovernance
    {

        management = _management;

        emit UpdateManagement(management);
    }

    function setGuardian(
        address _guardian
    ) external override onlyGovernanceOrGuardian {

        guardian = _guardian;

        emit UpdateGuardian(guardian);
    }

    function setWithdrawGuardian(
        address _withdrawGuardian
    ) external override onlyGovernanceOrWithdrawGuardian {

        withdrawGuardian = _withdrawGuardian;

        emit UpdateWithdrawGuardian(withdrawGuardian);
    }

    function setStrategyRewards(
        address strategyId,
        EverscaleAddress memory _rewards
    )
        external
        override
        onlyGovernanceOrStrategyRewardsManager(strategyId)
        strategyExists(strategyId)
    {

        _strategyRewardsUpdate(strategyId, _rewards);

        emit StrategyUpdateRewards(strategyId, _rewards.wid, _rewards.addr);
    }

    function setRewards(
        EverscaleAddress memory _rewards
    ) external override onlyGovernance {

        rewards_ = _rewards;

        emit UpdateRewards(rewards_.wid, rewards_.addr);
    }

    function setLockedProfitDegradation(
        uint256 degradation
    ) external override onlyGovernance {

        require(degradation <= DEGRADATION_COEFFICIENT);

        lockedProfitDegradation = degradation;
    }

    function setDepositLimit(
        uint256 limit
    ) external override onlyGovernance {

        depositLimit = limit;

        emit UpdateDepositLimit(depositLimit);
    }

    function setPerformanceFee(
        uint256 fee
    ) external override onlyGovernance {

        require(fee <= MAX_BPS / 2);

        performanceFee = fee;

        emit UpdatePerformanceFee(performanceFee);
    }

    function setManagementFee(
        uint256 fee
    ) external override onlyGovernance {

        require(fee <= MAX_BPS);

        managementFee = fee;

        emit UpdateManagementFee(managementFee);
    }

    function setWithdrawLimitPerPeriod(
        uint256 _withdrawLimitPerPeriod
    ) external override onlyGovernance {

        withdrawLimitPerPeriod = _withdrawLimitPerPeriod;

        emit UpdateWithdrawLimitPerPeriod(withdrawLimitPerPeriod);
    }

    function setUndeclaredWithdrawLimit(
        uint256 _undeclaredWithdrawLimit
    ) external override onlyGovernance {

        undeclaredWithdrawLimit = _undeclaredWithdrawLimit;

        emit UpdateUndeclaredWithdrawLimit(undeclaredWithdrawLimit);
    }

    function setEmergencyShutdown(
        bool active
    ) external override {

        if (active) {
            require(msg.sender == guardian || msg.sender == governance);
        } else {
            require(msg.sender == governance);
        }

        emergencyShutdown = active;

        emit EmergencyShutdown(active);
    }

    function setWithdrawalQueue(
        address[20] memory queue
    ) external override onlyGovernanceOrManagement {

        withdrawalQueue_ = queue;

        emit UpdateWithdrawalQueue(withdrawalQueue_);
    }

    function setPendingWithdrawalBounty(
        uint256 id,
        uint256 bounty
    )
        public
        override
        pendingWithdrawalOpened(PendingWithdrawalId(msg.sender, id))
    {

        PendingWithdrawalParams memory pendingWithdrawal = _pendingWithdrawal(PendingWithdrawalId(msg.sender, id));

        require(bounty <= pendingWithdrawal.amount);

        _pendingWithdrawalBountyUpdate(PendingWithdrawalId(msg.sender, id), bounty);
    }

    function totalAssets() external view override returns (uint256) {

        return _totalAssets();
    }

    function deposit(
        EverscaleAddress memory recipient,
        uint256 amount
    )
        public
        override
        onlyEmergencyDisabled
        respectDepositLimit(amount)
        nonReentrant
    {

        IERC20(token).safeTransferFrom(
            msg.sender,
            address(this),
            amount
        );

        uint256 fee = _calculateMovementFee(amount, depositFee);

        _transferToEverscale(recipient, amount - fee);

        if (fee > 0) fees += fee;

        emit UserDeposit(msg.sender, recipient.wid, recipient.addr, amount, address(0), 0, 0);
    }

    function deposit(
        EverscaleAddress memory recipient,
        uint256 amount,
        uint256 expectedMinBounty,
        PendingWithdrawalId[] memory pendingWithdrawalIds
    ) external override {

        uint amountLeft = amount;
        uint amountPlusBounty = amount;

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        for (uint i = 0; i < pendingWithdrawalIds.length; i++) {
            PendingWithdrawalId memory pendingWithdrawalId = pendingWithdrawalIds[i];
            PendingWithdrawalParams memory pendingWithdrawal = _pendingWithdrawal(pendingWithdrawalId);

            require(pendingWithdrawal.amount > 0);
            require(
                pendingWithdrawal.approveStatus == ApproveStatus.NotRequired ||
                pendingWithdrawal.approveStatus == ApproveStatus.Approved
            );

            amountLeft -= pendingWithdrawal.amount;
            amountPlusBounty += pendingWithdrawal.bounty;

            _pendingWithdrawalAmountReduce(
                pendingWithdrawalId,
                pendingWithdrawal.amount
            );

            IERC20(token).safeTransfer(
                pendingWithdrawalId.recipient,
                pendingWithdrawal.amount - pendingWithdrawal.bounty
            );

            emit UserDeposit(
                msg.sender,
                recipient.wid,
                recipient.addr,
                pendingWithdrawal.amount,
                pendingWithdrawalId.recipient,
                pendingWithdrawalId.id,
                pendingWithdrawal.bounty
            );
        }

        require(amountPlusBounty - amount >= expectedMinBounty);

        uint256 fee = _calculateMovementFee(amountPlusBounty, depositFee);

        _transferToEverscale(recipient, amountPlusBounty - fee);

        if (amountLeft > 0) {
            emit UserDeposit(msg.sender, recipient.wid, recipient.addr, amountLeft, address(0), 0, 0);
        }

        if (fee > 0) fees += fee;
    }

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
    )
        external
        override
        onlyEmergencyDisabled
        respectDepositLimit(amount)
    {

        require(
            tokenAmount <= amount &&
            swapType < 2 &&
            user != 0 &&
            recipient != 0 &&
            creditor != 0 &&
            slippageNumerator < slippageDenominator
        );

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        uint256 fee = _calculateMovementFee(amount, depositFee);

        if (fee > 0) fees += fee;

        emit FactoryDeposit(
            uint128(convertToTargetDecimals(amount - fee)),
            wid,
            user,
            creditor,
            recipient,
            tokenAmount,
            tonAmount,
            swapType,
            slippageNumerator,
            slippageDenominator,
            0x07,
            level3
        );
    }

    function saveWithdraw(
        bytes memory payload,
        bytes[] memory signatures
    )
        public
        override
        onlyEmergencyDisabled
        withdrawalNotSeenBefore(payload)
        returns (bool instantWithdrawal, PendingWithdrawalId memory pendingWithdrawalId)
    {

        require(
            IBridge(bridge).verifySignedEverscaleEvent(payload, signatures) == 0,
            "Vault: signatures verification failed"
        );

        (EverscaleEvent memory _event) = abi.decode(payload, (EverscaleEvent));

        require(
            _event.configurationWid == configuration_.wid &&
            _event.configurationAddress == configuration_.addr
        );

        bytes32 payloadId = keccak256(payload);

        WithdrawalParams memory withdrawal = decodeWithdrawalEventData(_event.eventData);

        require(withdrawal.chainId == _getChainID());

        uint256 fee = _calculateMovementFee(withdrawal.amount, withdrawFee);

        if (fee > 0) fees += fee;

        WithdrawalPeriodParams memory withdrawalPeriod = _withdrawalPeriod(_event.eventTimestamp);
        _withdrawalPeriodIncreaseTotalByTimestamp(_event.eventTimestamp, withdrawal.amount);

        bool withdrawalLimitsPassed = _withdrawalPeriodCheckLimitsPassed(withdrawal.amount, withdrawalPeriod);

        if (withdrawal.amount <= _vaultTokenBalance() && withdrawalLimitsPassed) {
            IERC20(token).safeTransfer(withdrawal.recipient, withdrawal.amount - fee);

            emit InstantWithdrawal(payloadId, withdrawal.recipient, withdrawal.amount - fee);

            return (true, PendingWithdrawalId(address(0), 0));
        }

        uint256 id = _pendingWithdrawalCreate(
            withdrawal.recipient,
            withdrawal.amount - fee,
            _event.eventTimestamp
        );

        emit PendingWithdrawalCreated(withdrawal.recipient, id, withdrawal.amount - fee, payloadId);

        pendingWithdrawalId = PendingWithdrawalId(withdrawal.recipient, id);

        if (!withdrawalLimitsPassed) {
            _pendingWithdrawalApproveStatusUpdate(pendingWithdrawalId, ApproveStatus.Required);
        }

        return (false, pendingWithdrawalId);
    }

    function saveWithdraw(
        bytes memory payload,
        bytes[] memory signatures,
        uint bounty
    )
        external
        override
    {

        (
            bool instantWithdraw,
            PendingWithdrawalId memory pendingWithdrawalId
        ) = saveWithdraw(payload, signatures);

        if (!instantWithdraw && msg.sender == pendingWithdrawalId.recipient) {
            PendingWithdrawalParams memory pendingWithdrawal = _pendingWithdrawal(pendingWithdrawalId);
            require(bounty <= pendingWithdrawal.amount);

            _pendingWithdrawalBountyUpdate(pendingWithdrawalId, bounty);
        }
    }

    function cancelPendingWithdrawal(
        uint256 id,
        uint256 amount,
        EverscaleAddress memory recipient,
        uint bounty
    )
        external
        override
        onlyEmergencyDisabled
        pendingWithdrawalApproved(PendingWithdrawalId(msg.sender, id))
        pendingWithdrawalOpened(PendingWithdrawalId(msg.sender, id))
    {

        PendingWithdrawalId memory pendingWithdrawalId = PendingWithdrawalId(msg.sender, id);
        PendingWithdrawalParams memory pendingWithdrawal = _pendingWithdrawal(pendingWithdrawalId);

        require(amount > 0 && amount <= pendingWithdrawal.amount);

        _transferToEverscale(recipient, amount);

        _pendingWithdrawalAmountReduce(pendingWithdrawalId, amount);

        emit PendingWithdrawalCancel(msg.sender, id, amount);

        setPendingWithdrawalBounty(id, bounty);
    }

    function withdraw(
        uint256 id,
        uint256 amountRequested,
        address recipient,
        uint256 maxLoss,
        uint256 bounty
    )
        external
        override
        onlyEmergencyDisabled
        pendingWithdrawalOpened(PendingWithdrawalId(msg.sender, id))
        pendingWithdrawalApproved(PendingWithdrawalId(msg.sender, id))
        returns(uint256 amountAdjusted)
    {

        PendingWithdrawalId memory pendingWithdrawalId = PendingWithdrawalId(msg.sender, id);
        PendingWithdrawalParams memory pendingWithdrawal = _pendingWithdrawal(pendingWithdrawalId);

        require(
            amountRequested > 0 &&
            amountRequested <= pendingWithdrawal.amount &&
            bounty <= pendingWithdrawal.amount - amountRequested
        );

        _pendingWithdrawalBountyUpdate(pendingWithdrawalId, bounty);

        amountAdjusted = amountRequested;

        if (amountAdjusted > _vaultTokenBalance()) {
            uint256 totalLoss = 0;

            for (uint i = 0; i < withdrawalQueue_.length; i++) {
                address strategyId = withdrawalQueue_[i];

                if (strategyId == address(0)) break;

                uint256 vaultBalance = _vaultTokenBalance();
                uint256 amountNeeded = amountAdjusted - vaultBalance;

                amountNeeded = Math.min(
                    amountNeeded,
                    _strategy(strategyId).totalDebt
                );

                if (amountNeeded == 0) continue;

                uint256 loss = IStrategy(strategyId).withdraw(amountNeeded);
                uint256 withdrawn = _vaultTokenBalance() - vaultBalance;

                if (loss > 0) {
                    amountAdjusted -= loss;
                    totalLoss += loss;
                    _strategyReportLoss(strategyId, loss);
                }

                _strategyTotalDebtReduce(strategyId, withdrawn);
            }

            require(_vaultTokenBalance() >= amountAdjusted);

            require(totalLoss <= maxLoss * (amountAdjusted + totalLoss) / MAX_BPS);
        }

        IERC20(token).safeTransfer(recipient, amountAdjusted);

        _pendingWithdrawalAmountReduce(pendingWithdrawalId, amountRequested);

        emit PendingWithdrawalWithdraw(
            pendingWithdrawalId.recipient,
            pendingWithdrawalId.id,
            amountRequested,
            amountAdjusted
        );

        return amountAdjusted;
    }

    function addStrategy(
        address strategyId,
        uint256 _debtRatio,
        uint256 minDebtPerHarvest,
        uint256 maxDebtPerHarvest,
        uint256 _performanceFee
    )
        external
        override
        onlyGovernance
        onlyEmergencyDisabled
        strategyNotExists(strategyId)
    {

        require(strategyId != address(0));

        require(IStrategy(strategyId).vault() == address(this));
        require(IStrategy(strategyId).want() == token);

        require(debtRatio + _debtRatio <= MAX_BPS);
        require(minDebtPerHarvest <= maxDebtPerHarvest);
        require(_performanceFee <= MAX_BPS / 2);

        _strategyCreate(strategyId, StrategyParams({
            performanceFee: _performanceFee,
            activation: block.timestamp,
            debtRatio: _debtRatio,
            minDebtPerHarvest: minDebtPerHarvest,
            maxDebtPerHarvest: maxDebtPerHarvest,
            lastReport: block.timestamp,
            totalDebt: 0,
            totalGain: 0,
            totalSkim: 0,
            totalLoss: 0,
            rewardsManager: address(0),
            rewards: rewards_
        }));

        emit StrategyAdded(strategyId, _debtRatio, minDebtPerHarvest, maxDebtPerHarvest, _performanceFee);

        _debtRatioIncrease(_debtRatio);
    }

    function updateStrategyDebtRatio(
        address strategyId,
        uint256 _debtRatio
    )
        external
        override
        onlyGovernanceOrManagement
        strategyExists(strategyId)
    {

        StrategyParams memory strategy = _strategy(strategyId);

        _debtRatioReduce(strategy.debtRatio);
        _strategyDebtRatioUpdate(strategyId, _debtRatio);
        _debtRatioIncrease(debtRatio);

        require(debtRatio <= MAX_BPS);

        emit StrategyUpdateDebtRatio(strategyId, _debtRatio);
    }

    function updateStrategyMinDebtPerHarvest(
        address strategyId,
        uint256 minDebtPerHarvest
    )
        external
        override
        onlyGovernanceOrManagement
        strategyExists(strategyId)
    {

        StrategyParams memory strategy = _strategy(strategyId);

        require(strategy.maxDebtPerHarvest >= minDebtPerHarvest);

        _strategyMinDebtPerHarvestUpdate(strategyId, minDebtPerHarvest);

        emit StrategyUpdateMinDebtPerHarvest(strategyId, minDebtPerHarvest);
    }

    function updateStrategyMaxDebtPerHarvest(
        address strategyId,
        uint256 maxDebtPerHarvest
    )
        external
        override
        onlyGovernanceOrManagement
        strategyExists(strategyId)
    {

        StrategyParams memory strategy = _strategy(strategyId);

        require(strategy.minDebtPerHarvest <= maxDebtPerHarvest);

        _strategyMaxDebtPerHarvestUpdate(strategyId, maxDebtPerHarvest);

        emit StrategyUpdateMaxDebtPerHarvest(strategyId, maxDebtPerHarvest);
    }

    function updateStrategyPerformanceFee(
        address strategyId,
        uint256 _performanceFee
    )
        external
        override
        onlyGovernance
        strategyExists(strategyId)
    {

        require(_performanceFee <= MAX_BPS / 2);

        performanceFee = _performanceFee;

        emit StrategyUpdatePerformanceFee(strategyId, _performanceFee);
    }

    function migrateStrategy(
        address oldVersion,
        address newVersion
    )
        external
        override
        onlyGovernance
        strategyExists(oldVersion)
        strategyNotExists(newVersion)
    {


    }

    function revokeStrategy(
        address strategyId
    )
        external
        override
        onlyStrategyOrGovernanceOrGuardian(strategyId)
    {

        _strategyRevoke(strategyId);

        emit StrategyRevoked(strategyId);
    }

    function revokeStrategy()
        external
        override
        onlyStrategyOrGovernanceOrGuardian(msg.sender)
    {

        _strategyRevoke(msg.sender);

        emit StrategyRevoked(msg.sender);
    }

    function debtOutstanding(
        address strategyId
    )
        external
        view
        override
        returns (uint256)
    {

        return _strategyDebtOutstanding(strategyId);
    }

    function debtOutstanding()
        external
        view
        override
        returns (uint256)
    {

        return _strategyDebtOutstanding(msg.sender);
    }

    function creditAvailable(
        address strategyId
    )
        external
        view
        override
        returns (uint256)
    {

        return _strategyCreditAvailable(strategyId);
    }

    function creditAvailable()
        external
        view
        override
        returns (uint256)
    {

        return _strategyCreditAvailable(msg.sender);
    }


    function availableDepositLimit()
        external
        view
        override
        returns (uint256)
    {

        if (depositLimit > _totalAssets()) {
            return depositLimit - _totalAssets();
        }

        return 0;
    }

    function expectedReturn(
        address strategyId
    )
        external
        override
        view
        returns (uint256)
    {

        return _strategyExpectedReturn(strategyId);
    }

    function _assessFees(
        address strategyId,
        uint256 gain
    ) internal returns (uint256) {

        StrategyParams memory strategy = _strategy(strategyId);

        if (strategy.activation == block.timestamp) return 0;

        uint256 duration = block.timestamp - strategy.lastReport;
        require(duration > 0); // Can't call twice within the same block

        if (gain == 0) return 0; // The fees are not charged if there hasn't been any gains reported

        uint256 management_fee = (
            strategy.totalDebt - IStrategy(strategyId).delegatedAssets()
        ) * duration * managementFee / MAX_BPS / SECS_PER_YEAR;

        uint256 strategist_fee = (gain * strategy.performanceFee) / MAX_BPS;

        uint256 performance_fee = (gain * performanceFee) / MAX_BPS;

        uint256 total_fee = management_fee + strategist_fee + performance_fee;

        if (total_fee > gain) {
            strategist_fee = strategist_fee * gain / total_fee;
            performance_fee = performance_fee * gain / total_fee;
            management_fee = management_fee * gain / total_fee;

            total_fee = gain;
        }

        if (strategist_fee > 0) { // Strategy rewards are paid instantly
            _transferToEverscale(strategy.rewards, strategist_fee);
        }

        if (performance_fee + management_fee > 0) {
            fees += performance_fee + management_fee;
        }

        return total_fee;
    }

    function report(
        uint256 gain,
        uint256 loss,
        uint256 _debtPayment
    )
        external
        override
        strategyExists(msg.sender)
        returns (uint256)
    {

        if (loss > 0) _strategyReportLoss(msg.sender, loss);

        uint256 totalFees = _assessFees(msg.sender, gain);

        _strategyTotalGainIncrease(msg.sender, gain);

        uint256 credit = _strategyCreditAvailable(msg.sender);

        uint256 debt = _strategyDebtOutstanding(msg.sender);
        uint256 debtPayment = Math.min(_debtPayment, debt);

        if (debtPayment > 0) {
            _strategyTotalDebtReduce(msg.sender, debtPayment);

            debt -= debtPayment;
        }

        if (credit > 0) {
            _strategyTotalDebtIncrease(msg.sender, credit);
        }

        uint256 totalAvailable = gain + debtPayment;

        if (totalAvailable < credit) { // credit surplus, give to Strategy
            IERC20(token).safeTransfer(msg.sender, credit - totalAvailable);
        } else if (totalAvailable > credit) { // credit deficit, take from Strategy
            IERC20(token).safeTransferFrom(msg.sender, address(this), totalAvailable - credit);
        } else {
        }

        uint256 lockedProfitBeforeLoss = _calculateLockedProfit() + gain - totalFees;

        if (lockedProfitBeforeLoss > loss) {
            lockedProfit = lockedProfitBeforeLoss - loss;
        } else {
            lockedProfit = 0;
        }

        _strategyLastReportUpdate(msg.sender);

        StrategyParams memory strategy = _strategy(msg.sender);

        emit StrategyReported(
            msg.sender,
            gain,
            loss,
            debtPayment,
            strategy.totalGain,
            strategy.totalSkim,
            strategy.totalLoss,
            strategy.totalDebt,
            credit,
            strategy.debtRatio
        );

        if (strategy.debtRatio == 0 || emergencyShutdown) {
            return IStrategy(msg.sender).estimatedTotalAssets();
        } else {
            return debt;
        }
    }

    function skim(
        address strategyId
    )
        external
        override
        onlyGovernanceOrManagement
        strategyExists(strategyId)
    {

        uint amount = strategies_[strategyId].totalGain - strategies_[strategyId].totalSkim;

        require(amount > 0);

        strategies_[strategyId].totalSkim += amount;

        _transferToEverscale(rewards_, amount);
    }

    function skimFees(
        bool skim_to_everscale
    ) external override onlyGovernanceOrManagement {

        require(fees > 0);

        if (skim_to_everscale) {
            _transferToEverscale(rewards_, fees);
        } else {
            IERC20(token).safeTransfer(governance, fees);
        }

        fees = 0;
    }

    function sweep(
        address _token
    ) external override onlyGovernance {

        require(token != _token);

        uint256 amount = IERC20(_token).balanceOf(address(this));

        IERC20(_token).safeTransfer(governance, amount);
    }

    function forceWithdraw(
        PendingWithdrawalId memory pendingWithdrawalId
    )
        public
        override
        onlyEmergencyDisabled
        pendingWithdrawalOpened(pendingWithdrawalId)
        pendingWithdrawalApproved(pendingWithdrawalId)
    {

        PendingWithdrawalParams memory pendingWithdrawal = _pendingWithdrawal(pendingWithdrawalId);

        IERC20(token).safeTransfer(pendingWithdrawalId.recipient, pendingWithdrawal.amount);

        _pendingWithdrawalAmountReduce(pendingWithdrawalId, pendingWithdrawal.amount);

        emit PendingWithdrawalForce(pendingWithdrawalId.recipient, pendingWithdrawalId.id);
    }

    function forceWithdraw(
        PendingWithdrawalId[] memory pendingWithdrawalId
    ) external override {

        for (uint i = 0; i < pendingWithdrawalId.length; i++) {
            forceWithdraw(pendingWithdrawalId[i]);
        }
    }

    function setPendingWithdrawalApprove(
        PendingWithdrawalId memory pendingWithdrawalId,
        ApproveStatus approveStatus
    )
        public
        override
        onlyGovernanceOrWithdrawGuardian
        pendingWithdrawalOpened(pendingWithdrawalId)
    {

        PendingWithdrawalParams memory pendingWithdrawal = _pendingWithdrawal(pendingWithdrawalId);

        require(pendingWithdrawal.approveStatus == ApproveStatus.Required);

        require(
            approveStatus == ApproveStatus.Approved ||
            approveStatus == ApproveStatus.Rejected
        );

        _pendingWithdrawalApproveStatusUpdate(pendingWithdrawalId, approveStatus);

        if (approveStatus == ApproveStatus.Approved && pendingWithdrawal.amount <= _vaultTokenBalance()) {
            _pendingWithdrawalAmountReduce(pendingWithdrawalId, pendingWithdrawal.amount);

            IERC20(token).safeTransfer(
                pendingWithdrawalId.recipient,
                pendingWithdrawal.amount
            );

            emit PendingWithdrawalWithdraw(
                pendingWithdrawalId.recipient,
                pendingWithdrawalId.id,
                pendingWithdrawal.amount,
                pendingWithdrawal.amount
            );
        }

        _withdrawalPeriodIncreaseConsideredByTimestamp(
            pendingWithdrawal.timestamp,
            pendingWithdrawal.amount
        );
    }

    function setPendingWithdrawalApprove(
        PendingWithdrawalId[] memory pendingWithdrawalId,
        ApproveStatus[] memory approveStatus
    ) external override {

        require(pendingWithdrawalId.length == approveStatus.length);

        for (uint i = 0; i < pendingWithdrawalId.length; i++) {
            setPendingWithdrawalApprove(pendingWithdrawalId[i], approveStatus[i]);
        }
    }

    function _transferToEverscale(
        EverscaleAddress memory recipient,
        uint256 _amount
    ) internal {

        uint256 amount = convertToTargetDecimals(_amount);

        emit Deposit(amount, recipient.wid, recipient.addr);
    }
}