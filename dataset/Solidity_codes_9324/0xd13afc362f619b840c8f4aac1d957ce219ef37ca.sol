


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


    function smart_wallet_checker() external view returns (address);


    function commit_smart_wallet_checker(address newSmartWalletChecker) external;


    function apply_smart_wallet_checker() external;

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

    function getGaugeController() external view returns (IGaugeController);


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


interface IBalancerMinter {

    event Minted(address indexed recipient, address gauge, uint256 minted);

    function getBalancerToken() external view returns (IERC20);


    function getBalancerTokenAdmin() external view returns (IBalancerTokenAdmin);


    function getGaugeController() external view returns (IGaugeController);


    function mint(address gauge) external returns (uint256);


    function mintMany(address[] calldata gauges) external returns (uint256);


    function mintFor(address gauge, address user) external returns (uint256);


    function mintManyFor(address[] calldata gauges, address user) external returns (uint256);


    function minted(address user, address gauge) external view returns (uint256);


    function getMinterApproval(address minter, address user) external view returns (bool);


    function setMinterApproval(address minter, bool approval) external;


    function setMinterApprovalWithSignature(
        address minter,
        bool approval,
        address user,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;



    function allowed_to_mint_for(address minter, address user) external view returns (bool);


    function mint_many(address[8] calldata gauges) external;


    function mint_for(address gauge, address user) external;


    function toggle_approve_mint(address minter) external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IBALTokenHolder is IAuthentication {

    function withdrawFunds(address recipient, uint256 amount) external;


    function sweepTokens(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IBALTokenHolderFactory {

    function getBalancerToken() external view returns (IBalancerToken);


    function getVault() external view returns (IVault);


    function isHolderFromFactory(address holder) external view returns (bool);


    function create(string memory name) external returns (IBALTokenHolder);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface ISingleRecipientGaugeFactory is ILiquidityGaugeFactory {

    function getRecipientGauge(address recipient) external view returns (ILiquidityGauge);


    function getGaugeRecipient(address gauge) external view returns (address);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IStakelessGauge is ILiquidityGauge {

    function checkpoint() external payable returns (bool);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;




interface ICurrentAuthorizer is IAuthorizer {

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;

}

contract veBALL2GaugeSetupCoordinator is ReentrancyGuard {

    IVault private immutable _vault;
    IAuthorizerAdaptor private immutable _authorizerAdaptor;
    IVotingEscrow private immutable _votingEscrow;
    IGaugeController private immutable _gaugeController;
    IGaugeAdder private immutable _gaugeAdder;
    ILiquidityGaugeFactory private immutable _ethereumGaugeFactory;
    ISingleRecipientGaugeFactory private immutable _polygonGaugeFactory;
    ISingleRecipientGaugeFactory private immutable _arbitrumGaugeFactory;

    address public immutable GAUGE_CHECKPOINTER_MULTISIG = 0x02f35dA6A02017154367Bc4d47bb6c7D06C7533B;

    enum DeploymentStage { PENDING, FIRST_STAGE_DONE, SECOND_STAGE_DONE }

    uint256 public firstStageActivationTime;
    uint256 public secondStageActivationTime;

    DeploymentStage private _currentDeploymentStage;

    constructor(
        IAuthorizerAdaptor authorizerAdaptor,
        IVotingEscrow votingEscrow,
        IGaugeAdder gaugeAdder,
        ILiquidityGaugeFactory ethereumGaugeFactory,
        ISingleRecipientGaugeFactory polygonGaugeFactory,
        ISingleRecipientGaugeFactory arbitrumGaugeFactory
    ) {
        _currentDeploymentStage = DeploymentStage.PENDING;

        IVault vault = authorizerAdaptor.getVault();
        _vault = vault;
        _authorizerAdaptor = authorizerAdaptor;
        _votingEscrow = votingEscrow;
        _gaugeController = gaugeAdder.getGaugeController();
        _gaugeAdder = gaugeAdder;
        _ethereumGaugeFactory = ethereumGaugeFactory;
        _polygonGaugeFactory = polygonGaugeFactory;
        _arbitrumGaugeFactory = arbitrumGaugeFactory;
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

        _addGaugeCheckpointerMultisig();

        _addNewEthereumGauges();

        _addNewArbitrumGauges();


        firstStageActivationTime = block.timestamp;
        _currentDeploymentStage = DeploymentStage.FIRST_STAGE_DONE;
    }

    function performSecondStage() external nonReentrant {

        require(_currentDeploymentStage == DeploymentStage.FIRST_STAGE_DONE, "Not ready for second stage");

        ICurrentAuthorizer authorizer = getAuthorizer();
        require(authorizer.canPerform(bytes32(0), address(this), address(0)), "Not Authorizer admin");

        _addNewPolygonGauges();

        _deprecateOldGauges();

        authorizer.revokeRole(bytes32(0), address(this));

        secondStageActivationTime = block.timestamp;
        _currentDeploymentStage = DeploymentStage.SECOND_STAGE_DONE;
    }

    function _addGaugeCheckpointerMultisig() private {

        ICurrentAuthorizer authorizer = getAuthorizer();
        bytes32 checkpointGaugeRole = _authorizerAdaptor.getActionId(IStakelessGauge.checkpoint.selector);
        authorizer.grantRole(checkpointGaugeRole, GAUGE_CHECKPOINTER_MULTISIG);
    }

    function _addNewEthereumGauges() private {

        address payable[3] memory newGauges = [
            0xa57453737849A4029325dfAb3F6034656644E104, // 80HAUS-20WETH
            0xA6468eca7633246Dcb24E5599681767D27d1F978, // 50COW-50GNO
            0x158772F59Fe0d3b75805fC11139b46CBc89F70e5 // 50COW-50WETH
        ];

        ICurrentAuthorizer authorizer = getAuthorizer();
        bytes32 addEthereumGaugeRole = _gaugeAdder.getActionId(IGaugeAdder.addEthereumGauge.selector);

        authorizer.grantRole(addEthereumGaugeRole, address(this));

        uint256 gaugesLength = newGauges.length;
        for (uint256 i = 0; i < gaugesLength; i++) {
            _gaugeAdder.addEthereumGauge(IStakingLiquidityGauge(newGauges[i]));
        }

        authorizer.revokeRole(addEthereumGaugeRole, address(this));
    }

    function _addNewPolygonGauges() private {

        address payable[19] memory initialRecipients = [
            0x0FC855f77cE75Bb6a5d650D0c4cC92E460c03E25, // 0x0297e37f1873d2dab4487aa67cd56b58e2f27875
            0x4b878e9727B9E91fDaE37CdD85949f4367220187, // 0x03cd191f589d12b0582a99808cf19851e468e6b5
            0x66750473cE1dECBa4ef2576a47fd5FF7BF07C4e2, // 0x06df3b2bbb68adc8b0e302443692037ed9f91b42
            0x2Ac595007563df473449005883F1F2BA3036eBeF, // 0x0d34e5dd4d8f043557145598e4e2dc286b35fd4f
            0x3b4D173601F8b36024cD49F7C5859D263385AF34, // 0x10f21c9bd8128a29aa785ab2de0d044dcdd79436
            0xDe2F58c43CB222725A96236272c7749E4Abf1a25, // 0x186084ff790c65088ba694df11758fae4943ee9e
            0x73CF9C065bFB9ABf76d94787324CfC4F751ac097, // 0x36128d5436d2d70cab39c9af9cce146c38554ff0
            0x2845E95D2a4eFcd14Cf5D77B9Ba732788b96267f, // 0x5a6ae1fd70d04ba4a279fc219dfabc53825cb01d
            0xb061F502d84f00d1B26568888A8f741cBE352C23, // 0x614b5038611729ed49e0ded154d8a5d3af9d1d9e
            0xD65F35e750d5FFB63a3B6C7B4e5D4afe4CA5550D, // 0x7c9cf12d783821d5c63d8e9427af5c44bad92445
            0x25a526ADb6925a9f40141567C06430D368232FEE, // 0x805ca3ccc61cc231851dee2da6aabff0a7714aa7
            0x0fD7e9171b4dC9D89E157c2cc9A424Cd9C40a034, // 0xaf5e0b5425de1f5a630a8cb5aa9d97b8141c908d
            0xbc9F244cf5a774785E726A9157aFe3725d93249B, // 0xb204bf10bc3a5435017d3db247f56da601dfe08a
            0x2CCc518B7B6177C2d44771d6b249F85a5A0cC1D4, // 0xc31a37105b94ab4efca1954a14f059af11fcd9bb
            0x64AFDb69C22971B2ed289020f78a47E070cFadba, // 0xce66904b68f1f070332cbc631de7ee98b650b499
            0x6F4d27730d5253148d82283E3aD93eae9264DaA3, // 0xcf354603a9aebd2ff9f33e1b04246d8ea204ae95
            0x6812162860fAC498fB6f03339D39d23b5a264152, // 0xdb1db6e248d7bb4175f6e5a382d0a03fe3dcc813
            0x5EA9C37A3eCf0c82900FbbFd064FE29A427c41AB, // 0xea4e073c8ac859f2994c07e627178719c8002dc0
            0xA95E0B91A3F522dDE42D5b6a4e430e0BFAD0F2F5 // 0xfeadd389a5c427952d8fdb8057d6c8ba1156cc56
        ];

        ICurrentAuthorizer authorizer = getAuthorizer();

        bytes32 addGaugeFactoryRole = _gaugeAdder.getActionId(IGaugeAdder.addGaugeFactory.selector);
        bytes32 addPolygonGaugeRole = _gaugeAdder.getActionId(IGaugeAdder.addPolygonGauge.selector);

        authorizer.grantRole(addGaugeFactoryRole, address(this));
        _gaugeAdder.addGaugeFactory(_polygonGaugeFactory, IGaugeAdder.GaugeType.Polygon);
        authorizer.revokeRole(addGaugeFactoryRole, address(this));

        authorizer.grantRole(addPolygonGaugeRole, address(this));

        uint256 initialRecipientsLength = initialRecipients.length;
        for (uint256 i = 0; i < initialRecipientsLength; i++) {
            address gauge = _deployGauge(_polygonGaugeFactory, initialRecipients[i]);
            _gaugeAdder.addPolygonGauge(gauge);
        }

        authorizer.revokeRole(addPolygonGaugeRole, address(this));
    }

    function _addNewArbitrumGauges() private {

        address payable[14] memory initialRecipients = [
            0xD84d832F47C22Cf5413aE4FE2bd9D220FE6E3Dc6, // 0x0510ccf9eb3ab03c1508d3b9769e8ee2cfd6fdcf
            0x7B50775383d3D6f0215A8F290f2C9e2eEBBEceb2, // 0x0adeb25cb5920d4f7447af4a0428072edc2cee22
            0x7C1028Bcde7Ca03EcF6DaAA9cBfA06E931913EaD, // 0x1533a3278f3f9141d5f820a184ea4b017fce2382
            0xa57eaBc36A47dae5F11051c8339385cF95E77235, // 0x1779900c7707885720d39aa741f4086886307e9e
            0x37A6FC079cad790E556BaeddA879358e076EF1B3, // 0x4a3a22a3e7fee0ffbb66f1c28bfac50f75546fc7
            0xB556A02642A0f7be8c79932EFBC915F6e0485147, // 0x5a5884fc31948d59df2aeccca143de900d49e1a3
            0x4B1137789FF06406a72bAce67Cd15Cf6786844cC, // 0x64541216bafffeec8ea535bb71fbc927831d0595
            0xBd65449BabF09Be544d68fc7CCF0CEbe298fb214, // 0x651e00ffd5ecfa7f3d4f33d62ede0a97cf62ede2
            0x2246211E715b6567a8F7138180EF61a79678ef46, // 0xb28670b3e7ad27bd41fb5938136bf9e9cba90d65
            0xf2Bbfa122D41fFcF7056441578D108E3c40a7E99, // 0xb340b6b1a34019853cb05b2de6ee8ffd0b89a008
            0xf081862BF62C24E3C708BdBeda24ABE6B55E42f7, // 0xb5b77f1ad2b520df01612399258e7787af63025d
            0x28Cc04DcD85C4b40c6Dad463c628e98728ae9496, // 0xc2f082d33b5b8ef3a7e3de30da54efd3114512ac
            0xDC467DB6AbdA75E62F4809f3a4934ae3aca1C380, // 0xc61ff48f94d801c1ceface0289085197b5ec44f0
            0xd5Cd8328D93bf4bEf9824Fd288F32C8f0da1c551 // 0xcc65a812ce382ab909a11e434dbf75b34f1cc59d
        ];

        ICurrentAuthorizer authorizer = getAuthorizer();

        bytes32 addGaugeFactoryRole = _gaugeAdder.getActionId(IGaugeAdder.addGaugeFactory.selector);
        bytes32 addArbitrumGaugeRole = _gaugeAdder.getActionId(IGaugeAdder.addArbitrumGauge.selector);

        authorizer.grantRole(addGaugeFactoryRole, address(this));
        _gaugeAdder.addGaugeFactory(_arbitrumGaugeFactory, IGaugeAdder.GaugeType.Arbitrum);
        authorizer.revokeRole(addGaugeFactoryRole, address(this));

        authorizer.grantRole(addArbitrumGaugeRole, address(this));

        uint256 initialRecipientsLength = initialRecipients.length;
        for (uint256 i = 0; i < initialRecipientsLength; i++) {
            address gauge = _deployGauge(_arbitrumGaugeFactory, initialRecipients[i]);
            _gaugeAdder.addArbitrumGauge(gauge);
        }

        authorizer.revokeRole(addArbitrumGaugeRole, address(this));
    }

    function _deprecateOldGauges() private {

        address payable[2] memory deprecatedGauges = [
            0x9fb8312CEdFB9b35364FF06311B429a2f4Cdf422, // Temporary Polygon gauge
            0x3F829a8303455CB36B7Bcf3D1bdc18D5F6946aeA // Temporary Arbitrum gauge
        ];

        ICurrentAuthorizer authorizer = getAuthorizer();

        bytes32 killGaugeRole = _authorizerAdaptor.getActionId(ILiquidityGauge.killGauge.selector);

        authorizer.grantRole(killGaugeRole, address(this));

        uint256 deprecatedGaugesLength = deprecatedGauges.length;
        for (uint256 i = 0; i < deprecatedGaugesLength; i++) {
            _killGauge(deprecatedGauges[i]);
        }

        authorizer.revokeRole(killGaugeRole, address(this));
    }

    function _deployGauge(ISingleRecipientGaugeFactory factory, address recipient) private returns (address gauge) {

        gauge = address(factory.getRecipientGauge(recipient));
        if (gauge == address(0)) {
            gauge = factory.create(recipient);
        }
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
}