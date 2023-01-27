


pragma solidity ^0.7.0;


function _require(bool condition, uint256 errorCode) pure {
    if (!condition) _revert(errorCode);
}

function _revert(uint256 errorCode) pure {
    assembly {

        let units := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let tenths := add(mod(errorCode, 10), 0x30)

        errorCode := div(errorCode, 10)
        let hundreds := add(mod(errorCode, 10), 0x30)


        let revertReason := shl(200, add(0x42414c23000000, add(add(units, shl(8, tenths)), shl(16, hundreds))))


        mstore(0x0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
        mstore(0x04, 0x0000000000000000000000000000000000000000000000000000000000000020)
        mstore(0x24, 7)
        mstore(0x44, revertReason)

        revert(0, 100)
    }
}

library Errors {

    uint256 internal constant ADD_OVERFLOW = 0;
    uint256 internal constant SUB_OVERFLOW = 1;
    uint256 internal constant SUB_UNDERFLOW = 2;
    uint256 internal constant MUL_OVERFLOW = 3;
    uint256 internal constant ZERO_DIVISION = 4;
    uint256 internal constant DIV_INTERNAL = 5;
    uint256 internal constant X_OUT_OF_BOUNDS = 6;
    uint256 internal constant Y_OUT_OF_BOUNDS = 7;
    uint256 internal constant PRODUCT_OUT_OF_BOUNDS = 8;
    uint256 internal constant INVALID_EXPONENT = 9;

    uint256 internal constant OUT_OF_BOUNDS = 100;
    uint256 internal constant UNSORTED_ARRAY = 101;
    uint256 internal constant UNSORTED_TOKENS = 102;
    uint256 internal constant INPUT_LENGTH_MISMATCH = 103;
    uint256 internal constant ZERO_TOKEN = 104;

    uint256 internal constant MIN_TOKENS = 200;
    uint256 internal constant MAX_TOKENS = 201;
    uint256 internal constant MAX_SWAP_FEE_PERCENTAGE = 202;
    uint256 internal constant MIN_SWAP_FEE_PERCENTAGE = 203;
    uint256 internal constant MINIMUM_BPT = 204;
    uint256 internal constant CALLER_NOT_VAULT = 205;
    uint256 internal constant UNINITIALIZED = 206;
    uint256 internal constant BPT_IN_MAX_AMOUNT = 207;
    uint256 internal constant BPT_OUT_MIN_AMOUNT = 208;
    uint256 internal constant EXPIRED_PERMIT = 209;
    uint256 internal constant NOT_TWO_TOKENS = 210;
    uint256 internal constant DISABLED = 211;

    uint256 internal constant MIN_AMP = 300;
    uint256 internal constant MAX_AMP = 301;
    uint256 internal constant MIN_WEIGHT = 302;
    uint256 internal constant MAX_STABLE_TOKENS = 303;
    uint256 internal constant MAX_IN_RATIO = 304;
    uint256 internal constant MAX_OUT_RATIO = 305;
    uint256 internal constant MIN_BPT_IN_FOR_TOKEN_OUT = 306;
    uint256 internal constant MAX_OUT_BPT_FOR_TOKEN_IN = 307;
    uint256 internal constant NORMALIZED_WEIGHT_INVARIANT = 308;
    uint256 internal constant INVALID_TOKEN = 309;
    uint256 internal constant UNHANDLED_JOIN_KIND = 310;
    uint256 internal constant ZERO_INVARIANT = 311;
    uint256 internal constant ORACLE_INVALID_SECONDS_QUERY = 312;
    uint256 internal constant ORACLE_NOT_INITIALIZED = 313;
    uint256 internal constant ORACLE_QUERY_TOO_OLD = 314;
    uint256 internal constant ORACLE_INVALID_INDEX = 315;
    uint256 internal constant ORACLE_BAD_SECS = 316;
    uint256 internal constant AMP_END_TIME_TOO_CLOSE = 317;
    uint256 internal constant AMP_ONGOING_UPDATE = 318;
    uint256 internal constant AMP_RATE_TOO_HIGH = 319;
    uint256 internal constant AMP_NO_ONGOING_UPDATE = 320;
    uint256 internal constant STABLE_INVARIANT_DIDNT_CONVERGE = 321;
    uint256 internal constant STABLE_GET_BALANCE_DIDNT_CONVERGE = 322;
    uint256 internal constant RELAYER_NOT_CONTRACT = 323;
    uint256 internal constant BASE_POOL_RELAYER_NOT_CALLED = 324;
    uint256 internal constant REBALANCING_RELAYER_REENTERED = 325;
    uint256 internal constant GRADUAL_UPDATE_TIME_TRAVEL = 326;
    uint256 internal constant SWAPS_DISABLED = 327;
    uint256 internal constant CALLER_IS_NOT_LBP_OWNER = 328;
    uint256 internal constant PRICE_RATE_OVERFLOW = 329;
    uint256 internal constant INVALID_JOIN_EXIT_KIND_WHILE_SWAPS_DISABLED = 330;
    uint256 internal constant WEIGHT_CHANGE_TOO_FAST = 331;
    uint256 internal constant LOWER_GREATER_THAN_UPPER_TARGET = 332;
    uint256 internal constant UPPER_TARGET_TOO_HIGH = 333;
    uint256 internal constant UNHANDLED_BY_LINEAR_POOL = 334;
    uint256 internal constant OUT_OF_TARGET_RANGE = 335;
    uint256 internal constant UNHANDLED_EXIT_KIND = 336;
    uint256 internal constant UNAUTHORIZED_EXIT = 337;
    uint256 internal constant MAX_MANAGEMENT_SWAP_FEE_PERCENTAGE = 338;
    uint256 internal constant UNHANDLED_BY_MANAGED_POOL = 339;
    uint256 internal constant UNHANDLED_BY_PHANTOM_POOL = 340;
    uint256 internal constant TOKEN_DOES_NOT_HAVE_RATE_PROVIDER = 341;
    uint256 internal constant INVALID_INITIALIZATION = 342;
    uint256 internal constant OUT_OF_NEW_TARGET_RANGE = 343;
    uint256 internal constant UNAUTHORIZED_OPERATION = 344;
    uint256 internal constant UNINITIALIZED_POOL_CONTROLLER = 345;

    uint256 internal constant REENTRANCY = 400;
    uint256 internal constant SENDER_NOT_ALLOWED = 401;
    uint256 internal constant PAUSED = 402;
    uint256 internal constant PAUSE_WINDOW_EXPIRED = 403;
    uint256 internal constant MAX_PAUSE_WINDOW_DURATION = 404;
    uint256 internal constant MAX_BUFFER_PERIOD_DURATION = 405;
    uint256 internal constant INSUFFICIENT_BALANCE = 406;
    uint256 internal constant INSUFFICIENT_ALLOWANCE = 407;
    uint256 internal constant ERC20_TRANSFER_FROM_ZERO_ADDRESS = 408;
    uint256 internal constant ERC20_TRANSFER_TO_ZERO_ADDRESS = 409;
    uint256 internal constant ERC20_MINT_TO_ZERO_ADDRESS = 410;
    uint256 internal constant ERC20_BURN_FROM_ZERO_ADDRESS = 411;
    uint256 internal constant ERC20_APPROVE_FROM_ZERO_ADDRESS = 412;
    uint256 internal constant ERC20_APPROVE_TO_ZERO_ADDRESS = 413;
    uint256 internal constant ERC20_TRANSFER_EXCEEDS_ALLOWANCE = 414;
    uint256 internal constant ERC20_DECREASED_ALLOWANCE_BELOW_ZERO = 415;
    uint256 internal constant ERC20_TRANSFER_EXCEEDS_BALANCE = 416;
    uint256 internal constant ERC20_BURN_EXCEEDS_ALLOWANCE = 417;
    uint256 internal constant SAFE_ERC20_CALL_FAILED = 418;
    uint256 internal constant ADDRESS_INSUFFICIENT_BALANCE = 419;
    uint256 internal constant ADDRESS_CANNOT_SEND_VALUE = 420;
    uint256 internal constant SAFE_CAST_VALUE_CANT_FIT_INT256 = 421;
    uint256 internal constant GRANT_SENDER_NOT_ADMIN = 422;
    uint256 internal constant REVOKE_SENDER_NOT_ADMIN = 423;
    uint256 internal constant RENOUNCE_SENDER_NOT_ALLOWED = 424;
    uint256 internal constant BUFFER_PERIOD_EXPIRED = 425;
    uint256 internal constant CALLER_IS_NOT_OWNER = 426;
    uint256 internal constant NEW_OWNER_IS_ZERO = 427;
    uint256 internal constant CODE_DEPLOYMENT_FAILED = 428;
    uint256 internal constant CALL_TO_NON_CONTRACT = 429;
    uint256 internal constant LOW_LEVEL_CALL_FAILED = 430;
    uint256 internal constant NOT_PAUSED = 431;
    uint256 internal constant ADDRESS_ALREADY_ALLOWLISTED = 432;
    uint256 internal constant ADDRESS_NOT_ALLOWLISTED = 433;
    uint256 internal constant ERC20_BURN_EXCEEDS_BALANCE = 434;

    uint256 internal constant INVALID_POOL_ID = 500;
    uint256 internal constant CALLER_NOT_POOL = 501;
    uint256 internal constant SENDER_NOT_ASSET_MANAGER = 502;
    uint256 internal constant USER_DOESNT_ALLOW_RELAYER = 503;
    uint256 internal constant INVALID_SIGNATURE = 504;
    uint256 internal constant EXIT_BELOW_MIN = 505;
    uint256 internal constant JOIN_ABOVE_MAX = 506;
    uint256 internal constant SWAP_LIMIT = 507;
    uint256 internal constant SWAP_DEADLINE = 508;
    uint256 internal constant CANNOT_SWAP_SAME_TOKEN = 509;
    uint256 internal constant UNKNOWN_AMOUNT_IN_FIRST_SWAP = 510;
    uint256 internal constant MALCONSTRUCTED_MULTIHOP_SWAP = 511;
    uint256 internal constant INTERNAL_BALANCE_OVERFLOW = 512;
    uint256 internal constant INSUFFICIENT_INTERNAL_BALANCE = 513;
    uint256 internal constant INVALID_ETH_INTERNAL_BALANCE = 514;
    uint256 internal constant INVALID_POST_LOAN_BALANCE = 515;
    uint256 internal constant INSUFFICIENT_ETH = 516;
    uint256 internal constant UNALLOCATED_ETH = 517;
    uint256 internal constant ETH_TRANSFER = 518;
    uint256 internal constant CANNOT_USE_ETH_SENTINEL = 519;
    uint256 internal constant TOKENS_MISMATCH = 520;
    uint256 internal constant TOKEN_NOT_REGISTERED = 521;
    uint256 internal constant TOKEN_ALREADY_REGISTERED = 522;
    uint256 internal constant TOKENS_ALREADY_SET = 523;
    uint256 internal constant TOKENS_LENGTH_MUST_BE_2 = 524;
    uint256 internal constant NONZERO_TOKEN_BALANCE = 525;
    uint256 internal constant BALANCE_TOTAL_OVERFLOW = 526;
    uint256 internal constant POOL_NO_TOKENS = 527;
    uint256 internal constant INSUFFICIENT_FLASH_LOAN_BALANCE = 528;

    uint256 internal constant SWAP_FEE_PERCENTAGE_TOO_HIGH = 600;
    uint256 internal constant FLASH_LOAN_FEE_PERCENTAGE_TOO_HIGH = 601;
    uint256 internal constant INSUFFICIENT_FLASH_LOAN_FEE_AMOUNT = 602;
}// MIT


pragma solidity ^0.7.0;


abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _enterNonReentrant();
        _;
        _exitNonReentrant();
    }

    function _enterNonReentrant() private {
        _require(_status != _ENTERED, Errors.REENTRANCY);

        _status = _ENTERED;
    }

    function _exitNonReentrant() private {
        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.7.0;

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
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IAuthentication {

    function getActionId(bytes4 selector) external view returns (bytes32);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface ISignaturesValidator {

    function getDomainSeparator() external view returns (bytes32);


    function getNextNonce(address user) external view returns (uint256);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface ITemporarilyPausable {

    event PausedStateChanged(bool paused);

    function getPausedState()
        external
        view
        returns (
            bool paused,
            uint256 pauseWindowEndTime,
            uint256 bufferPeriodEndTime
        );

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IWETH is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 amount) external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IAsset {

}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IAuthorizer {

    function canPerform(
        bytes32 actionId,
        address account,
        address where
    ) external view returns (bool);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;



interface IFlashLoanRecipient {

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;



interface IProtocolFeesCollector {

    event SwapFeePercentageChanged(uint256 newSwapFeePercentage);
    event FlashLoanFeePercentageChanged(uint256 newFlashLoanFeePercentage);

    function withdrawCollectedFees(
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        address recipient
    ) external;


    function setSwapFeePercentage(uint256 newSwapFeePercentage) external;


    function setFlashLoanFeePercentage(uint256 newFlashLoanFeePercentage) external;


    function getSwapFeePercentage() external view returns (uint256);


    function getFlashLoanFeePercentage() external view returns (uint256);


    function getCollectedFeeAmounts(IERC20[] memory tokens) external view returns (uint256[] memory feeAmounts);


    function getAuthorizer() external view returns (IAuthorizer);


    function vault() external view returns (IVault);

}// GPL-3.0-or-later






pragma solidity ^0.7.0;

interface IVault is ISignaturesValidator, ITemporarilyPausable, IAuthentication {



    function getAuthorizer() external view returns (IAuthorizer);


    function setAuthorizer(IAuthorizer newAuthorizer) external;


    event AuthorizerChanged(IAuthorizer indexed newAuthorizer);


    function hasApprovedRelayer(address user, address relayer) external view returns (bool);


    function setRelayerApproval(
        address sender,
        address relayer,
        bool approved
    ) external;


    event RelayerApprovalChanged(address indexed relayer, address indexed sender, bool approved);


    function getInternalBalance(address user, IERC20[] memory tokens) external view returns (uint256[] memory);


    function manageUserBalance(UserBalanceOp[] memory ops) external payable;


    struct UserBalanceOp {
        UserBalanceOpKind kind;
        IAsset asset;
        uint256 amount;
        address sender;
        address payable recipient;
    }


    enum UserBalanceOpKind { DEPOSIT_INTERNAL, WITHDRAW_INTERNAL, TRANSFER_INTERNAL, TRANSFER_EXTERNAL }

    event InternalBalanceChanged(address indexed user, IERC20 indexed token, int256 delta);

    event ExternalBalanceTransfer(IERC20 indexed token, address indexed sender, address recipient, uint256 amount);


    enum PoolSpecialization { GENERAL, MINIMAL_SWAP_INFO, TWO_TOKEN }

    function registerPool(PoolSpecialization specialization) external returns (bytes32);


    event PoolRegistered(bytes32 indexed poolId, address indexed poolAddress, PoolSpecialization specialization);

    function getPool(bytes32 poolId) external view returns (address, PoolSpecialization);


    function registerTokens(
        bytes32 poolId,
        IERC20[] memory tokens,
        address[] memory assetManagers
    ) external;


    event TokensRegistered(bytes32 indexed poolId, IERC20[] tokens, address[] assetManagers);

    function deregisterTokens(bytes32 poolId, IERC20[] memory tokens) external;


    event TokensDeregistered(bytes32 indexed poolId, IERC20[] tokens);

    function getPoolTokenInfo(bytes32 poolId, IERC20 token)
        external
        view
        returns (
            uint256 cash,
            uint256 managed,
            uint256 lastChangeBlock,
            address assetManager
        );


    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (
            IERC20[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        );


    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external payable;


    struct JoinPoolRequest {
        IAsset[] assets;
        uint256[] maxAmountsIn;
        bytes userData;
        bool fromInternalBalance;
    }

    function exitPool(
        bytes32 poolId,
        address sender,
        address payable recipient,
        ExitPoolRequest memory request
    ) external;


    struct ExitPoolRequest {
        IAsset[] assets;
        uint256[] minAmountsOut;
        bytes userData;
        bool toInternalBalance;
    }

    event PoolBalanceChanged(
        bytes32 indexed poolId,
        address indexed liquidityProvider,
        IERC20[] tokens,
        int256[] deltas,
        uint256[] protocolFeeAmounts
    );

    enum PoolBalanceChangeKind { JOIN, EXIT }


    enum SwapKind { GIVEN_IN, GIVEN_OUT }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256);


    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        IAsset assetIn;
        IAsset assetOut;
        uint256 amount;
        bytes userData;
    }

    function batchSwap(
        SwapKind kind,
        BatchSwapStep[] memory swaps,
        IAsset[] memory assets,
        FundManagement memory funds,
        int256[] memory limits,
        uint256 deadline
    ) external payable returns (int256[] memory);


    struct BatchSwapStep {
        bytes32 poolId;
        uint256 assetInIndex;
        uint256 assetOutIndex;
        uint256 amount;
        bytes userData;
    }

    event Swap(
        bytes32 indexed poolId,
        IERC20 indexed tokenIn,
        IERC20 indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function queryBatchSwap(
        SwapKind kind,
        BatchSwapStep[] memory swaps,
        IAsset[] memory assets,
        FundManagement memory funds
    ) external returns (int256[] memory assetDeltas);



    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;


    event FlashLoan(IFlashLoanRecipient indexed recipient, IERC20 indexed token, uint256 amount, uint256 feeAmount);


    function managePoolBalance(PoolBalanceOp[] memory ops) external;


    struct PoolBalanceOp {
        PoolBalanceOpKind kind;
        bytes32 poolId;
        IERC20 token;
        uint256 amount;
    }

    enum PoolBalanceOpKind { WITHDRAW, DEPOSIT, UPDATE }

    event PoolBalanceManaged(
        bytes32 indexed poolId,
        address indexed assetManager,
        IERC20 indexed token,
        int256 cashDelta,
        int256 managedDelta
    );


    function getProtocolFeesCollector() external view returns (IProtocolFeesCollector);


    function setPaused(bool paused) external;


    function WETH() external view returns (IWETH);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IAuthorizerAdaptor is IAuthentication {

    function getVault() external view returns (IVault);


    function getAuthorizer() external view returns (IAuthorizer);


    function performAction(address target, bytes calldata data) external payable returns (bytes memory);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;



interface IVotingEscrow {

    struct Point {
        int128 bias;
        int128 slope; // - dweight / dt
        uint256 ts;
        uint256 blk; // block
    }

    function epoch() external view returns (uint256);


    function totalSupply(uint256 timestamp) external view returns (uint256);


    function user_point_epoch(address user) external view returns (uint256);


    function point_history(uint256 timestamp) external view returns (Point memory);


    function user_point_history(address user, uint256 timestamp) external view returns (Point memory);


    function checkpoint() external;


    function admin() external view returns (IAuthorizerAdaptor);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;




interface IGaugeController {

    function checkpoint_gauge(address gauge) external;


    function gauge_relative_weight(address gauge, uint256 time) external returns (uint256);


    function voting_escrow() external view returns (IVotingEscrow);


    function token() external view returns (IERC20);


    function add_type(string calldata name, uint256 weight) external;


    function change_type_weight(int128 typeId, uint256 weight) external;


    function add_gauge(address gauge, int128 gaugeType) external;


    function n_gauge_types() external view returns (int128);


    function gauge_types(address gauge) external view returns (int128);


    function admin() external view returns (IAuthorizerAdaptor);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface ILiquidityGauge {

    function integrate_fraction(address user) external view returns (uint256);


    function user_checkpoint(address user) external returns (bool);


    function is_killed() external view returns (bool);


    function killGauge() external;


    function unkillGauge() external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface ILiquidityGaugeFactory {

    function isGaugeFromFactory(address gauge) external view returns (bool);


    function create(address pool) external returns (address);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;




interface IStakingLiquidityGauge is ILiquidityGauge, IERC20 {

    function initialize(address lpToken) external;


    function lp_token() external view returns (IERC20);


    function deposit(uint256 value, address recipient) external;


    function withdraw(uint256 value) external;


    function claim_rewards(address user) external;


    function add_reward(address rewardToken, address distributor) external;


    function set_reward_distributor(address rewardToken, address distributor) external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;



interface IGaugeAdder is IAuthentication {

    enum GaugeType { LiquidityMiningCommittee, veBAL, Ethereum, Polygon, Arbitrum }

    event GaugeFactoryAdded(GaugeType indexed gaugeType, ILiquidityGaugeFactory gaugeFactory);

    function getPoolGauge(IERC20 pool) external view returns (ILiquidityGauge);


    function getFactoryForGaugeType(GaugeType gaugeType, uint256 index) external view returns (address);


    function getFactoryForGaugeTypeCount(GaugeType gaugeType) external view returns (uint256);


    function isGaugeFromValidFactory(address gauge, GaugeType gaugeType) external view returns (bool);


    function addEthereumGauge(IStakingLiquidityGauge gauge) external;


    function addPolygonGauge(address rootGauge) external;


    function addArbitrumGauge(address rootGauge) external;


    function addGaugeFactory(ILiquidityGaugeFactory factory, GaugeType gaugeType) external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IBalancerToken is IERC20 {

    function mint(address to, uint256 amount) external;


    function getRoleMemberCount(bytes32 role) external view returns (uint256);


    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);


    function MINTER_ROLE() external view returns (bytes32);


    function SNAPSHOT_ROLE() external view returns (bytes32);


    function snapshot() external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;



interface IBalancerTokenAdmin is IAuthentication {

    function INITIAL_RATE() external view returns (uint256);


    function RATE_REDUCTION_TIME() external view returns (uint256);


    function RATE_REDUCTION_COEFFICIENT() external view returns (uint256);


    function RATE_DENOMINATOR() external view returns (uint256);



    function getBalancerToken() external view returns (IBalancerToken);


    function getVault() external view returns (IVault);


    function activate() external;


    function rate() external view returns (uint256);


    function startEpochTimeWrite() external returns (uint256);


    function mint(address to, uint256 amount) external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IBALTokenHolder is IAuthentication {

    function getName() external view returns (string memory);


    function withdrawFunds(address recipient, uint256 amount) external;


    function sweepTokens(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface ISingleRecipientGauge is ILiquidityGauge {

    function initialize(address recipient) external;


    function getRecipient() external view returns (address);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;




interface ICurrentAuthorizer is IAuthorizer {

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;

}

contract veBALGaugeFixCoordinator is ReentrancyGuard {

    IVault private immutable _vault;
    IAuthorizerAdaptor private immutable _authorizerAdaptor;
    IGaugeController private immutable _gaugeController;
    IBalancerTokenAdmin private immutable _balancerTokenAdmin;


    uint256 public constant VEBAL_BAL_MINT_AMOUNT = 29000e18; // 2 weeks worth of 10% of emissions
    uint256 public constant ARBITRUM_BAL_MINT_AMOUNT = 20300e18; // 2 weeks worth of 7% of emissions
    uint256 public constant POLYGON_BAL_MINT_AMOUNT = 49300e18; // 2 weeks worth of 17% of emissions


    enum DeploymentStage { PENDING, FIRST_STAGE_DONE }

    DeploymentStage private _currentDeploymentStage;

    constructor(
        IAuthorizerAdaptor authorizerAdaptor,
        IBalancerTokenAdmin balancerTokenAdmin,
        IGaugeController gaugeController
    ) {
        _currentDeploymentStage = DeploymentStage.PENDING;

        IVault vault = authorizerAdaptor.getVault();
        _vault = vault;
        _authorizerAdaptor = authorizerAdaptor;
        _balancerTokenAdmin = balancerTokenAdmin;
        _gaugeController = gaugeController;
    }

    function getVault() public view returns (IVault) {

        return _vault;
    }

    function getAuthorizer() public view returns (ICurrentAuthorizer) {

        return ICurrentAuthorizer(address(getVault().getAuthorizer()));
    }

    function getAuthorizerAdaptor() public view returns (IAuthorizerAdaptor) {

        return _authorizerAdaptor;
    }

    function getCurrentDeploymentStage() external view returns (DeploymentStage) {

        return _currentDeploymentStage;
    }

    function performFirstStage() external nonReentrant {

        require(_currentDeploymentStage == DeploymentStage.PENDING, "First step already performed");

        ICurrentAuthorizer authorizer = getAuthorizer();
        require(authorizer.canPerform(bytes32(0), address(this), address(0)), "Not Authorizer admin");

        _deprecateLMCommittee();

        _setGaugeTypeWeights();

        _mintMissingBAL();

        authorizer.revokeRole(bytes32(0), address(this));

        _currentDeploymentStage = DeploymentStage.FIRST_STAGE_DONE;
    }

    function _deprecateLMCommittee() private {

        ICurrentAuthorizer authorizer = getAuthorizer();


        bytes32 changeTypeWeightRole = _authorizerAdaptor.getActionId(IGaugeController.change_type_weight.selector);
        authorizer.grantRole(changeTypeWeightRole, address(this));

        _setGaugeTypeWeight(IGaugeAdder.GaugeType.LiquidityMiningCommittee, 0);

        authorizer.revokeRole(changeTypeWeightRole, address(this));

        address lmCommitteeGauge = 0x7AA5475b2eA29a9F4a1B9Cf1cB72512D1B4Ab75e;
        require(
            _streq(
                IBALTokenHolder(ISingleRecipientGauge(lmCommitteeGauge).getRecipient()).getName(),
                "Liquidity Mining Committee BAL Holder"
            ),
            "Incorrect gauge"
        );

        bytes32 killGaugeRole = _authorizerAdaptor.getActionId(ILiquidityGauge.killGauge.selector);
        authorizer.grantRole(killGaugeRole, address(this));

        _killGauge(lmCommitteeGauge);

        authorizer.revokeRole(killGaugeRole, address(this));
    }

    function _setGaugeTypeWeights() private {

        ICurrentAuthorizer authorizer = getAuthorizer();
        bytes32 changeTypeWeightRole = _authorizerAdaptor.getActionId(IGaugeController.change_type_weight.selector);

        authorizer.grantRole(changeTypeWeightRole, address(this));

        uint256 equalTypeWeight = 1;
        _setGaugeTypeWeight(IGaugeAdder.GaugeType.veBAL, equalTypeWeight);
        _setGaugeTypeWeight(IGaugeAdder.GaugeType.Ethereum, equalTypeWeight);
        _setGaugeTypeWeight(IGaugeAdder.GaugeType.Polygon, equalTypeWeight);
        _setGaugeTypeWeight(IGaugeAdder.GaugeType.Arbitrum, equalTypeWeight);

        authorizer.revokeRole(changeTypeWeightRole, address(this));
    }

    function _mintMissingBAL() private {

        ICurrentAuthorizer authorizer = getAuthorizer();


        IBALTokenHolder veBALHolder = IBALTokenHolder(0x3C1d00181ff86fbac0c3C52991fBFD11f6491D70);
        require(_streq(veBALHolder.getName(), "Temporary veBAL Liquidity Mining BAL Holder"), "Incorrect holder");

        IBALTokenHolder arbitrumHolder = IBALTokenHolder(0x0C925fcE89a22E36EbD9B3C6E0262234E853d2F6);
        require(_streq(arbitrumHolder.getName(), "Temporary Arbitrum Liquidity Mining BAL Holder"), "Incorrect holder");

        IBALTokenHolder polygonHolder = IBALTokenHolder(0x98087bf6A5CA828a6E09391aCE674DBaBB6a4C56);
        require(_streq(polygonHolder.getName(), "Temporary Polygon Liquidity Mining BAL Holder"), "Incorrect holder");

        bytes32 mintBALRole = _balancerTokenAdmin.getActionId(IBalancerTokenAdmin.mint.selector);

        authorizer.grantRole(mintBALRole, address(this));

        _balancerTokenAdmin.mint(address(veBALHolder), VEBAL_BAL_MINT_AMOUNT);
        _balancerTokenAdmin.mint(address(arbitrumHolder), ARBITRUM_BAL_MINT_AMOUNT);
        _balancerTokenAdmin.mint(address(polygonHolder), POLYGON_BAL_MINT_AMOUNT);

        authorizer.revokeRole(mintBALRole, address(this));
    }

    function _killGauge(address gauge) private {

        getAuthorizerAdaptor().performAction(gauge, abi.encodeWithSelector(ILiquidityGauge.killGauge.selector));
    }

    function _setGaugeTypeWeight(IGaugeAdder.GaugeType typeId, uint256 weight) private {

        getAuthorizerAdaptor().performAction(
            address(_gaugeController),
            abi.encodeWithSelector(IGaugeController.change_type_weight.selector, int128(typeId), weight)
        );
    }

    function _streq(string memory a, string memory b) private pure returns (bool) {

        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}