


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

interface IVault is ISignaturesValidator, ITemporarilyPausable {



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

interface IAuthentication {

    function getActionId(bytes4 selector) external view returns (bytes32);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IAuthorizerAdaptor is IAuthentication {

    function getVault() external view returns (IVault);


    function getAuthorizer() external view returns (IAuthorizer);


    function performAction(address target, bytes calldata data) external payable returns (bytes memory);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;



interface IVotingEscrow {

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




interface ICurrentAuthorizer is IAuthorizer {

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;

}

contract veBALDeploymentCoordinator is ReentrancyGuard {

    IBalancerTokenAdmin private immutable _balancerTokenAdmin;

    IVault private immutable _vault;
    IAuthorizerAdaptor private immutable _authorizerAdaptor;
    IBalancerToken private immutable _balancerToken;
    IBalancerMinter private immutable _balancerMinter;
    IGaugeController private immutable _gaugeController;
    IGaugeAdder private immutable _gaugeAdder;
    ILiquidityGaugeFactory private immutable _ethereumGaugeFactory;
    ILiquidityGaugeFactory private immutable _singleRecipientGaugeFactory;
    IBALTokenHolderFactory private immutable _balTokenHolderFactory;

    address public lmCommitteeMultisig = 0xc38c5f97B34E175FFd35407fc91a937300E33860;

    address public veBALGaugeRecipient = 0xd2EB7Bd802A7CA68d9AcD209bEc4E664A9abDD7b;
    address public polygonGaugeRecipient = 0xd2EB7Bd802A7CA68d9AcD209bEc4E664A9abDD7b;
    address public arbitrumGaugeRecipient = 0xd2EB7Bd802A7CA68d9AcD209bEc4E664A9abDD7b;

    enum DeploymentStage { PENDING, FIRST_STAGE_DONE, SECOND_STAGE_DONE, THIRD_STAGE_DONE }

    uint256 public firstStageActivationTime;
    uint256 public secondStageActivationTime;
    uint256 public thirdStageActivationTime;

    DeploymentStage private _currentDeploymentStage;
    uint256 private immutable _activationScheduledTime;
    uint256 private immutable _thirdStageDelay;

    uint256 public constant LM_COMMITTEE_WEIGHT = 10e16; // 10%
    uint256 public constant VEBAL_WEIGHT = 10e16; // 10%
    uint256 public constant ETHEREUM_WEIGHT = 56e16; // 56%
    uint256 public constant POLYGON_WEIGHT = 17e16; // 17%
    uint256 public constant ARBITRUM_WEIGHT = 7e16; // 7%

    constructor(
        IBalancerMinter balancerMinter,
        IAuthorizerAdaptor authorizerAdaptor,
        IGaugeAdder gaugeAdder,
        ILiquidityGaugeFactory ethereumGaugeFactory,
        ILiquidityGaugeFactory singleRecipientGaugeFactory,
        IBALTokenHolderFactory balTokenHolderFactory,
        uint256 activationScheduledTime,
        uint256 thirdStageDelay
    ) {
        _currentDeploymentStage = DeploymentStage.PENDING;

        IBalancerTokenAdmin balancerTokenAdmin = balancerMinter.getBalancerTokenAdmin();

        _balancerTokenAdmin = balancerTokenAdmin;
        _vault = balancerTokenAdmin.getVault();
        _authorizerAdaptor = authorizerAdaptor;
        _balancerToken = balancerTokenAdmin.getBalancerToken();
        _balancerMinter = balancerMinter;
        _gaugeController = IGaugeController(balancerMinter.getGaugeController());
        _gaugeAdder = gaugeAdder;
        _ethereumGaugeFactory = ethereumGaugeFactory;
        _singleRecipientGaugeFactory = singleRecipientGaugeFactory;
        _balTokenHolderFactory = balTokenHolderFactory;

        _activationScheduledTime = activationScheduledTime;
        _thirdStageDelay = thirdStageDelay;
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

    function getBalancerTokenAdmin() external view returns (IBalancerTokenAdmin) {

        return _balancerTokenAdmin;
    }

    function getBalancerMinter() external view returns (IBalancerMinter) {

        return _balancerMinter;
    }

    function getGaugeController() external view returns (IGaugeController) {

        return _gaugeController;
    }

    function getCurrentDeploymentStage() external view returns (DeploymentStage) {

        return _currentDeploymentStage;
    }

    function getActivationScheduledTime() external view returns (uint256) {

        return _activationScheduledTime;
    }

    function getThirdStageDelay() external view returns (uint256) {

        return _thirdStageDelay;
    }

    function performFirstStage() external nonReentrant {

        require(block.timestamp >= _activationScheduledTime, "Not ready for activation");
        require(_currentDeploymentStage == DeploymentStage.PENDING, "First step already performed");

        ICurrentAuthorizer authorizer = getAuthorizer();
        require(_balancerToken.hasRole(_balancerToken.DEFAULT_ADMIN_ROLE(), address(this)), "Not BAL admin");
        require(authorizer.canPerform(bytes32(0), address(this), address(0)), "Not Authorizer admin");

        IAuthorizerAdaptor authorizerAdaptor = getAuthorizerAdaptor();
        require(
            _gaugeController.voting_escrow().admin() == authorizerAdaptor,
            "VotingEscrow not owned by AuthorizerAdaptor"
        );
        require(_gaugeController.admin() == authorizerAdaptor, "GaugeController not owned by AuthorizerAdaptor");

        require(_gaugeController.n_gauge_types() == 0, "Gauge types already set");

        _balancerToken.grantRole(_balancerToken.DEFAULT_ADMIN_ROLE(), address(_balancerTokenAdmin));
        authorizer.grantRole(_balancerTokenAdmin.getActionId(IBalancerTokenAdmin.activate.selector), address(this));
        _balancerTokenAdmin.activate();

        authorizer.grantRole(
            _balancerTokenAdmin.getActionId(IBalancerTokenAdmin.mint.selector),
            address(_balancerMinter)
        );

        {
            authorizer.grantRole(authorizerAdaptor.getActionId(IGaugeController.add_type.selector), address(this));

            _addGaugeType("Liquidity Mining Committee");
            _addGaugeType("veBAL");
            _addGaugeType("Ethereum");
            _addGaugeType("Polygon");
            _addGaugeType("Arbitrum");

            authorizer.revokeRole(authorizerAdaptor.getActionId(IGaugeController.add_type.selector), address(this));
        }


        authorizer.grantRole(authorizerAdaptor.getActionId(IGaugeController.add_gauge.selector), address(_gaugeAdder));

        {
            authorizer.grantRole(authorizerAdaptor.getActionId(IGaugeController.add_gauge.selector), address(this));

            _createSingleRecipientGauge(
                IGaugeAdder.GaugeType.LiquidityMiningCommittee,
                "Liquidity Mining Committee BAL Holder",
                lmCommitteeMultisig
            );

            _createSingleRecipientGauge(
                IGaugeAdder.GaugeType.veBAL,
                "Temporary veBAL Liquidity Mining BAL Holder",
                veBALGaugeRecipient
            );

            _createSingleRecipientGauge(
                IGaugeAdder.GaugeType.Polygon,
                "Temporary Polygon Liquidity Mining BAL Holder",
                polygonGaugeRecipient
            );
            _createSingleRecipientGauge(
                IGaugeAdder.GaugeType.Arbitrum,
                "Temporary Arbitrum Liquidity Mining BAL Holder",
                arbitrumGaugeRecipient
            );

            authorizer.revokeRole(authorizerAdaptor.getActionId(IGaugeController.add_gauge.selector), address(this));
        }

        authorizer.grantRole(
            authorizerAdaptor.getActionId(IStakingLiquidityGauge.add_reward.selector),
            lmCommitteeMultisig
        );

        authorizer.grantRole(
            authorizerAdaptor.getActionId(IStakingLiquidityGauge.set_reward_distributor.selector),
            lmCommitteeMultisig
        );

        firstStageActivationTime = block.timestamp;
        _currentDeploymentStage = DeploymentStage.FIRST_STAGE_DONE;
    }

    function performSecondStage() external nonReentrant {

        require(_currentDeploymentStage == DeploymentStage.FIRST_STAGE_DONE, "Not ready for second stage");

        ICurrentAuthorizer authorizer = getAuthorizer();


        address payable[32] memory initialPools = [
            0x06Df3b2bbB68adc8B0e302443692037ED9f91b42,
            0x072f14B85ADd63488DDaD88f855Fda4A99d6aC9B,
            0x0b09deA16768f0799065C475bE02919503cB2a35,
            0x186084fF790C65088BA694Df11758faE4943EE9E,
            0x1E19CF2D73a72Ef1332C882F20534B6519Be0276,
            0x27C9f71cC31464B906E0006d4FcBC8900F48f15f,
            0x32296969Ef14EB0c6d29669C550D4a0449130230,
            0x350196326AEAA9b98f1903fb5e8fc2686f85318C,
            0x3e5FA9518eA95c3E533EB377C001702A9AaCAA32,
            0x4bd6D86dEBdB9F5413e631Ad386c4427DC9D01B2,
            0x51735bdFBFE3fC13dEa8DC6502E2E95898942961,
            0x5d66FfF62c17D841935b60df5F07f6CF79Bd0F47,
            0x5f7FA48d765053F8dD85E052843e12D23e3D7BC5,
            0x702605F43471183158938C1a3e5f5A359d7b31ba,
            0x7B50775383d3D6f0215A8F290f2C9e2eEBBEceb2,
            0x7Edde0CB05ED19e03A9a47CD5E53fC57FDe1c80c,
            0x8f4205e1604133d1875a3E771AE7e4F2b0865639,
            0x90291319F1D4eA3ad4dB0Dd8fe9E12BAF749E845,
            0x96646936b91d6B9D7D0c47C496AfBF3D6ec7B6f8,
            0x96bA9025311e2f47B840A1f68ED57A3DF1EA8747,
            0xa02E4b3d18D4E6B8d18Ac421fBc3dfFF8933c40a,
            0xA6F548DF93de924d73be7D25dC02554c6bD66dB5,
            0xBaeEC99c90E3420Ec6c1e7A769d2A856d2898e4D,
            0xBF96189Eee9357a95C7719f4F5047F76bdE804E5,
            0xe2469f47aB58cf9CF59F9822e3C5De4950a41C49,
            0xE99481DC77691d8E2456E5f3F61C1810adFC1503,
            0xeC60a5FeF79a92c741Cb74FdD6bfC340C0279B01,
            0xEdf085f65b4F6c155e13155502Ef925c9a756003,
            0xEFAa1604e82e1B3AF8430b90192c1B9e8197e377,
            0xF4C0DD9B82DA36C07605df83c8a416F11724d88b,
            0xf5aAf7Ee8C39B651CEBF5f1F50C10631E78e0ef9,
            0xFeadd389a5c427952D8fdb8057D6C8ba1156cC56
        ];

        {
            authorizer.grantRole(_gaugeAdder.getActionId(IGaugeAdder.addGaugeFactory.selector), address(this));

            _gaugeAdder.addGaugeFactory(_ethereumGaugeFactory, IGaugeAdder.GaugeType.Ethereum);

            authorizer.revokeRole(_gaugeAdder.getActionId(IGaugeAdder.addGaugeFactory.selector), address(this));
        }

        {
            authorizer.grantRole(_gaugeAdder.getActionId(IGaugeAdder.addEthereumGauge.selector), address(this));

            uint256 poolsLength = initialPools.length;
            for (uint256 i = 0; i < poolsLength; i++) {
                ILiquidityGauge gauge = ILiquidityGauge(_ethereumGaugeFactory.create(initialPools[i]));
                _gaugeAdder.addEthereumGauge(IStakingLiquidityGauge(address(gauge)));
            }

            authorizer.revokeRole(_gaugeAdder.getActionId(IGaugeAdder.addEthereumGauge.selector), address(this));
        }

        secondStageActivationTime = block.timestamp;
        _currentDeploymentStage = DeploymentStage.SECOND_STAGE_DONE;
    }

    function performThirdStage() external nonReentrant {

        require(_currentDeploymentStage == DeploymentStage.SECOND_STAGE_DONE, "Not ready for third stage");
        require(
            block.timestamp >= (secondStageActivationTime + _thirdStageDelay),
            "Delay from second stage not yet elapsed"
        );

        IAuthorizerAdaptor authorizerAdaptor = getAuthorizerAdaptor();
        ICurrentAuthorizer authorizer = getAuthorizer();
        authorizer.grantRole(
            authorizerAdaptor.getActionId(IGaugeController.change_type_weight.selector),
            address(this)
        );

        _setGaugeTypeWeight(IGaugeAdder.GaugeType.LiquidityMiningCommittee, LM_COMMITTEE_WEIGHT);
        _setGaugeTypeWeight(IGaugeAdder.GaugeType.veBAL, VEBAL_WEIGHT);
        _setGaugeTypeWeight(IGaugeAdder.GaugeType.Ethereum, ETHEREUM_WEIGHT);
        _setGaugeTypeWeight(IGaugeAdder.GaugeType.Polygon, POLYGON_WEIGHT);
        _setGaugeTypeWeight(IGaugeAdder.GaugeType.Arbitrum, ARBITRUM_WEIGHT);

        authorizer.revokeRole(
            authorizerAdaptor.getActionId(IGaugeController.change_type_weight.selector),
            address(this)
        );

        authorizer.revokeRole(authorizer.DEFAULT_ADMIN_ROLE(), address(this));

        thirdStageActivationTime = block.timestamp;
        _currentDeploymentStage = DeploymentStage.THIRD_STAGE_DONE;
    }

    function _addGauge(ILiquidityGauge gauge, IGaugeAdder.GaugeType gaugeType) private {

        getAuthorizerAdaptor().performAction(
            address(_gaugeController),
            abi.encodeWithSelector(IGaugeController.add_gauge.selector, gauge, gaugeType)
        );
    }

    function _addGaugeType(string memory name) private {

        getAuthorizerAdaptor().performAction(
            address(_gaugeController),
            abi.encodeWithSelector(IGaugeController.add_type.selector, name, 0)
        );
    }

    function _setGaugeTypeWeight(IGaugeAdder.GaugeType typeId, uint256 weight) private {

        getAuthorizerAdaptor().performAction(
            address(_gaugeController),
            abi.encodeWithSelector(IGaugeController.change_type_weight.selector, int128(typeId), weight)
        );
    }

    function _createSingleRecipientGauge(
        IGaugeAdder.GaugeType gaugeType,
        string memory name,
        address recipient
    ) private {

        IBALTokenHolder holder = _balTokenHolderFactory.create(name);
        ILiquidityGauge gauge = ILiquidityGauge(_singleRecipientGaugeFactory.create(address(holder)));
        _addGauge(gauge, gaugeType);
        getAuthorizer().grantRole(holder.getActionId(IBALTokenHolder.withdrawFunds.selector), recipient);
    }
}