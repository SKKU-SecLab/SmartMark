
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



interface IPoolSwapStructs {

    struct SwapRequest {
        IVault.SwapKind kind;
        IERC20 tokenIn;
        IERC20 tokenOut;
        uint256 amount;
        bytes32 poolId;
        uint256 lastChangeBlock;
        address from;
        address to;
        bytes userData;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IBasePool is IPoolSwapStructs {

    function onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256[] memory amountsIn, uint256[] memory dueProtocolFeeAmounts);


    function onExitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256[] memory amountsOut, uint256[] memory dueProtocolFeeAmounts);


    function getPoolId() external view returns (bytes32);

}// GPL-3.0-or-later



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
    uint256 internal constant UNHANDLED_BY_INVESTMENT_POOL = 339;
    uint256 internal constant UNHANDLED_BY_PHANTOM_POOL = 340;
    uint256 internal constant TOKEN_DOES_NOT_HAVE_RATE_PROVIDER = 341;
    uint256 internal constant INVALID_INITIALIZATION = 342;

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



library LogExpMath {


    int256 constant ONE_18 = 1e18;

    int256 constant ONE_20 = 1e20;
    int256 constant ONE_36 = 1e36;

    int256 constant MAX_NATURAL_EXPONENT = 130e18;
    int256 constant MIN_NATURAL_EXPONENT = -41e18;

    int256 constant LN_36_LOWER_BOUND = ONE_18 - 1e17;
    int256 constant LN_36_UPPER_BOUND = ONE_18 + 1e17;

    uint256 constant MILD_EXPONENT_BOUND = 2**254 / uint256(ONE_20);

    int256 constant x0 = 128000000000000000000; // 2ˆ7
    int256 constant a0 = 38877084059945950922200000000000000000000000000000000000; // eˆ(x0) (no decimals)
    int256 constant x1 = 64000000000000000000; // 2ˆ6
    int256 constant a1 = 6235149080811616882910000000; // eˆ(x1) (no decimals)

    int256 constant x2 = 3200000000000000000000; // 2ˆ5
    int256 constant a2 = 7896296018268069516100000000000000; // eˆ(x2)
    int256 constant x3 = 1600000000000000000000; // 2ˆ4
    int256 constant a3 = 888611052050787263676000000; // eˆ(x3)
    int256 constant x4 = 800000000000000000000; // 2ˆ3
    int256 constant a4 = 298095798704172827474000; // eˆ(x4)
    int256 constant x5 = 400000000000000000000; // 2ˆ2
    int256 constant a5 = 5459815003314423907810; // eˆ(x5)
    int256 constant x6 = 200000000000000000000; // 2ˆ1
    int256 constant a6 = 738905609893065022723; // eˆ(x6)
    int256 constant x7 = 100000000000000000000; // 2ˆ0
    int256 constant a7 = 271828182845904523536; // eˆ(x7)
    int256 constant x8 = 50000000000000000000; // 2ˆ-1
    int256 constant a8 = 164872127070012814685; // eˆ(x8)
    int256 constant x9 = 25000000000000000000; // 2ˆ-2
    int256 constant a9 = 128402541668774148407; // eˆ(x9)
    int256 constant x10 = 12500000000000000000; // 2ˆ-3
    int256 constant a10 = 113314845306682631683; // eˆ(x10)
    int256 constant x11 = 6250000000000000000; // 2ˆ-4
    int256 constant a11 = 106449445891785942956; // eˆ(x11)

    function pow(uint256 x, uint256 y) internal pure returns (uint256) {

        if (y == 0) {
            return uint256(ONE_18);
        }

        if (x == 0) {
            return 0;
        }


        _require(x < 2**255, Errors.X_OUT_OF_BOUNDS);
        int256 x_int256 = int256(x);


        _require(y < MILD_EXPONENT_BOUND, Errors.Y_OUT_OF_BOUNDS);
        int256 y_int256 = int256(y);

        int256 logx_times_y;
        if (LN_36_LOWER_BOUND < x_int256 && x_int256 < LN_36_UPPER_BOUND) {
            int256 ln_36_x = _ln_36(x_int256);

            logx_times_y = ((ln_36_x / ONE_18) * y_int256 + ((ln_36_x % ONE_18) * y_int256) / ONE_18);
        } else {
            logx_times_y = _ln(x_int256) * y_int256;
        }
        logx_times_y /= ONE_18;

        _require(
            MIN_NATURAL_EXPONENT <= logx_times_y && logx_times_y <= MAX_NATURAL_EXPONENT,
            Errors.PRODUCT_OUT_OF_BOUNDS
        );

        return uint256(exp(logx_times_y));
    }

    function exp(int256 x) internal pure returns (int256) {

        _require(x >= MIN_NATURAL_EXPONENT && x <= MAX_NATURAL_EXPONENT, Errors.INVALID_EXPONENT);

        if (x < 0) {
            return ((ONE_18 * ONE_18) / exp(-x));
        }




        int256 firstAN;
        if (x >= x0) {
            x -= x0;
            firstAN = a0;
        } else if (x >= x1) {
            x -= x1;
            firstAN = a1;
        } else {
            firstAN = 1; // One with no decimal places
        }

        x *= 100;

        int256 product = ONE_20;

        if (x >= x2) {
            x -= x2;
            product = (product * a2) / ONE_20;
        }
        if (x >= x3) {
            x -= x3;
            product = (product * a3) / ONE_20;
        }
        if (x >= x4) {
            x -= x4;
            product = (product * a4) / ONE_20;
        }
        if (x >= x5) {
            x -= x5;
            product = (product * a5) / ONE_20;
        }
        if (x >= x6) {
            x -= x6;
            product = (product * a6) / ONE_20;
        }
        if (x >= x7) {
            x -= x7;
            product = (product * a7) / ONE_20;
        }
        if (x >= x8) {
            x -= x8;
            product = (product * a8) / ONE_20;
        }
        if (x >= x9) {
            x -= x9;
            product = (product * a9) / ONE_20;
        }



        int256 seriesSum = ONE_20; // The initial one in the sum, with 20 decimal places.
        int256 term; // Each term in the sum, where the nth term is (x^n / n!).

        term = x;
        seriesSum += term;


        term = ((term * x) / ONE_20) / 2;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 3;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 4;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 5;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 6;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 7;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 8;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 9;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 10;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 11;
        seriesSum += term;

        term = ((term * x) / ONE_20) / 12;
        seriesSum += term;



        return (((product * seriesSum) / ONE_20) * firstAN) / 100;
    }

    function log(int256 arg, int256 base) internal pure returns (int256) {



        int256 logBase;
        if (LN_36_LOWER_BOUND < base && base < LN_36_UPPER_BOUND) {
            logBase = _ln_36(base);
        } else {
            logBase = _ln(base) * ONE_18;
        }

        int256 logArg;
        if (LN_36_LOWER_BOUND < arg && arg < LN_36_UPPER_BOUND) {
            logArg = _ln_36(arg);
        } else {
            logArg = _ln(arg) * ONE_18;
        }

        return (logArg * ONE_18) / logBase;
    }

    function ln(int256 a) internal pure returns (int256) {

        _require(a > 0, Errors.OUT_OF_BOUNDS);
        if (LN_36_LOWER_BOUND < a && a < LN_36_UPPER_BOUND) {
            return _ln_36(a) / ONE_18;
        } else {
            return _ln(a);
        }
    }

    function _ln(int256 a) private pure returns (int256) {

        if (a < ONE_18) {
            return (-_ln((ONE_18 * ONE_18) / a));
        }



        int256 sum = 0;
        if (a >= a0 * ONE_18) {
            a /= a0; // Integer, not fixed point division
            sum += x0;
        }

        if (a >= a1 * ONE_18) {
            a /= a1; // Integer, not fixed point division
            sum += x1;
        }

        sum *= 100;
        a *= 100;


        if (a >= a2) {
            a = (a * ONE_20) / a2;
            sum += x2;
        }

        if (a >= a3) {
            a = (a * ONE_20) / a3;
            sum += x3;
        }

        if (a >= a4) {
            a = (a * ONE_20) / a4;
            sum += x4;
        }

        if (a >= a5) {
            a = (a * ONE_20) / a5;
            sum += x5;
        }

        if (a >= a6) {
            a = (a * ONE_20) / a6;
            sum += x6;
        }

        if (a >= a7) {
            a = (a * ONE_20) / a7;
            sum += x7;
        }

        if (a >= a8) {
            a = (a * ONE_20) / a8;
            sum += x8;
        }

        if (a >= a9) {
            a = (a * ONE_20) / a9;
            sum += x9;
        }

        if (a >= a10) {
            a = (a * ONE_20) / a10;
            sum += x10;
        }

        if (a >= a11) {
            a = (a * ONE_20) / a11;
            sum += x11;
        }


        int256 z = ((a - ONE_20) * ONE_20) / (a + ONE_20);
        int256 z_squared = (z * z) / ONE_20;

        int256 num = z;

        int256 seriesSum = num;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 3;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 5;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 7;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 9;

        num = (num * z_squared) / ONE_20;
        seriesSum += num / 11;


        seriesSum *= 2;


        return (sum + seriesSum) / 100;
    }

    function _ln_36(int256 x) private pure returns (int256) {


        x *= ONE_18;


        int256 z = ((x - ONE_36) * ONE_36) / (x + ONE_36);
        int256 z_squared = (z * z) / ONE_36;

        int256 num = z;

        int256 seriesSum = num;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 3;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 5;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 7;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 9;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 11;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 13;

        num = (num * z_squared) / ONE_36;
        seriesSum += num / 15;


        return seriesSum * 2;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



library FixedPoint {

    uint256 internal constant ONE = 1e18; // 18 decimal places
    uint256 internal constant MAX_POW_RELATIVE_ERROR = 10000; // 10^(-14)

    uint256 internal constant MIN_POW_BASE_FREE_EXPONENT = 0.7e18;

    function add(uint256 a, uint256 b) internal pure returns (uint256) {


        uint256 c = a + b;
        _require(c >= a, Errors.ADD_OVERFLOW);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {


        _require(b <= a, Errors.SUB_OVERFLOW);
        uint256 c = a - b;
        return c;
    }

    function mulDown(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 product = a * b;
        _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

        return product / ONE;
    }

    function mulUp(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 product = a * b;
        _require(a == 0 || product / a == b, Errors.MUL_OVERFLOW);

        if (product == 0) {
            return 0;
        } else {

            return ((product - 1) / ONE) + 1;
        }
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            uint256 aInflated = a * ONE;
            _require(aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow

            return aInflated / b;
        }
    }

    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            uint256 aInflated = a * ONE;
            _require(aInflated / a == ONE, Errors.DIV_INTERNAL); // mul overflow


            return ((aInflated - 1) / b) + 1;
        }
    }

    function powDown(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 raw = LogExpMath.pow(x, y);
        uint256 maxError = add(mulUp(raw, MAX_POW_RELATIVE_ERROR), 1);

        if (raw < maxError) {
            return 0;
        } else {
            return sub(raw, maxError);
        }
    }

    function powUp(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 raw = LogExpMath.pow(x, y);
        uint256 maxError = add(mulUp(raw, MAX_POW_RELATIVE_ERROR), 1);

        return add(raw, maxError);
    }

    function complement(uint256 x) internal pure returns (uint256) {

        return (x < ONE) ? (ONE - x) : 0;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



library InputHelpers {

    function ensureInputLengthMatch(uint256 a, uint256 b) internal pure {

        _require(a == b, Errors.INPUT_LENGTH_MISMATCH);
    }

    function ensureInputLengthMatch(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure {

        _require(a == b && b == c, Errors.INPUT_LENGTH_MISMATCH);
    }

    function ensureArrayIsSorted(IERC20[] memory array) internal pure {

        address[] memory addressArray;
        assembly {
            addressArray := array
        }
        ensureArrayIsSorted(addressArray);
    }

    function ensureArrayIsSorted(address[] memory array) internal pure {

        if (array.length < 2) {
            return;
        }

        address previous = array[0];
        for (uint256 i = 1; i < array.length; ++i) {
            address current = array[i];
            _require(previous < current, Errors.UNSORTED_ARRAY);
            previous = current;
        }
    }
}// MIT

pragma solidity ^0.7.0;


library Math {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        _require(c >= a, Errors.ADD_OVERFLOW);
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        _require((b >= 0 && c >= a) || (b < 0 && c < a), Errors.ADD_OVERFLOW);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b <= a, Errors.SUB_OVERFLOW);
        uint256 c = a - b;
        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        _require((b >= 0 && c <= a) || (b < 0 && c > a), Errors.SUB_OVERFLOW);
        return c;
    }

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;
        _require(a == 0 || c / a == b, Errors.MUL_OVERFLOW);
        return c;
    }

    function div(
        uint256 a,
        uint256 b,
        bool roundUp
    ) internal pure returns (uint256) {

        return roundUp ? divUp(a, b) : divDown(a, b);
    }

    function divDown(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);
        return a / b;
    }

    function divUp(uint256 a, uint256 b) internal pure returns (uint256) {

        _require(b != 0, Errors.ZERO_DIVISION);

        if (a == 0) {
            return 0;
        } else {
            return 1 + (a - 1) / b;
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract TemporarilyPausable is ITemporarilyPausable {

    uint256 private constant _MAX_PAUSE_WINDOW_DURATION = 90 days;
    uint256 private constant _MAX_BUFFER_PERIOD_DURATION = 30 days;

    uint256 private immutable _pauseWindowEndTime;
    uint256 private immutable _bufferPeriodEndTime;

    bool private _paused;

    constructor(uint256 pauseWindowDuration, uint256 bufferPeriodDuration) {
        _require(pauseWindowDuration <= _MAX_PAUSE_WINDOW_DURATION, Errors.MAX_PAUSE_WINDOW_DURATION);
        _require(bufferPeriodDuration <= _MAX_BUFFER_PERIOD_DURATION, Errors.MAX_BUFFER_PERIOD_DURATION);

        uint256 pauseWindowEndTime = block.timestamp + pauseWindowDuration;

        _pauseWindowEndTime = pauseWindowEndTime;
        _bufferPeriodEndTime = pauseWindowEndTime + bufferPeriodDuration;
    }

    modifier whenNotPaused() {
        _ensureNotPaused();
        _;
    }

    function getPausedState()
        external
        view
        override
        returns (
            bool paused,
            uint256 pauseWindowEndTime,
            uint256 bufferPeriodEndTime
        )
    {
        paused = !_isNotPaused();
        pauseWindowEndTime = _getPauseWindowEndTime();
        bufferPeriodEndTime = _getBufferPeriodEndTime();
    }

    function _setPaused(bool paused) internal {
        if (paused) {
            _require(block.timestamp < _getPauseWindowEndTime(), Errors.PAUSE_WINDOW_EXPIRED);
        } else {
            _require(block.timestamp < _getBufferPeriodEndTime(), Errors.BUFFER_PERIOD_EXPIRED);
        }

        _paused = paused;
        emit PausedStateChanged(paused);
    }

    function _ensureNotPaused() internal view {
        _require(_isNotPaused(), Errors.PAUSED);
    }

    function _isNotPaused() internal view returns (bool) {
        return block.timestamp > _getBufferPeriodEndTime() || !_paused;
    }


    function _getPauseWindowEndTime() private view returns (uint256) {
        return _pauseWindowEndTime;
    }

    function _getBufferPeriodEndTime() private view returns (uint256) {
        return _bufferPeriodEndTime;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

library WordCodec {

    uint256 private constant _MASK_1 = 2**(1) - 1;
    uint256 private constant _MASK_5 = 2**(5) - 1;
    uint256 private constant _MASK_7 = 2**(7) - 1;
    uint256 private constant _MASK_10 = 2**(10) - 1;
    uint256 private constant _MASK_16 = 2**(16) - 1;
    uint256 private constant _MASK_22 = 2**(22) - 1;
    uint256 private constant _MASK_31 = 2**(31) - 1;
    uint256 private constant _MASK_32 = 2**(32) - 1;
    uint256 private constant _MASK_53 = 2**(53) - 1;
    uint256 private constant _MASK_64 = 2**(64) - 1;
    uint256 private constant _MASK_128 = 2**(128) - 1;
    uint256 private constant _MASK_192 = 2**(192) - 1;

    int256 private constant _MAX_INT_22 = 2**(21) - 1;
    int256 private constant _MAX_INT_53 = 2**(52) - 1;


    function insertBool(
        bytes32 word,
        bool value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_1 << offset));
        return clearedWord | bytes32(uint256(value ? 1 : 0) << offset);
    }


    function insertUint5(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_5 << offset));
        return clearedWord | bytes32(value << offset);
    }

    function insertUint7(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_7 << offset));
        return clearedWord | bytes32(value << offset);
    }

    function insertUint10(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_10 << offset));
        return clearedWord | bytes32(value << offset);
    }

    function insertUint16(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_16 << offset));
        return clearedWord | bytes32(value << offset);
    }

    function insertUint31(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_31 << offset));
        return clearedWord | bytes32(value << offset);
    }

    function insertUint32(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_32 << offset));
        return clearedWord | bytes32(value << offset);
    }

    function insertUint64(
        bytes32 word,
        uint256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_64 << offset));
        return clearedWord | bytes32(value << offset);
    }


    function insertInt22(
        bytes32 word,
        int256 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_22 << offset));
        return clearedWord | bytes32((uint256(value) & _MASK_22) << offset);
    }


    function insertBits192(
        bytes32 word,
        bytes32 value,
        uint256 offset
    ) internal pure returns (bytes32) {

        bytes32 clearedWord = bytes32(uint256(word) & ~(_MASK_192 << offset));
        return clearedWord | bytes32((uint256(value) & _MASK_192) << offset);
    }



    function encodeUint(uint256 value, uint256 offset) internal pure returns (bytes32) {

        return bytes32(value << offset);
    }


    function encodeInt22(int256 value, uint256 offset) internal pure returns (bytes32) {

        return bytes32((uint256(value) & _MASK_22) << offset);
    }

    function encodeInt53(int256 value, uint256 offset) internal pure returns (bytes32) {

        return bytes32((uint256(value) & _MASK_53) << offset);
    }


    function decodeBool(bytes32 word, uint256 offset) internal pure returns (bool) {

        return (uint256(word >> offset) & _MASK_1) == 1;
    }


    function decodeUint5(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_5;
    }

    function decodeUint7(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_7;
    }

    function decodeUint10(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_10;
    }

    function decodeUint16(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_16;
    }

    function decodeUint31(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_31;
    }

    function decodeUint32(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_32;
    }

    function decodeUint64(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_64;
    }

    function decodeUint128(bytes32 word, uint256 offset) internal pure returns (uint256) {

        return uint256(word >> offset) & _MASK_128;
    }


    function decodeInt22(bytes32 word, uint256 offset) internal pure returns (int256) {

        int256 value = int256(uint256(word >> offset) & _MASK_22);
        return value > _MAX_INT_22 ? (value | int256(~_MASK_22)) : value;
    }

    function decodeInt53(bytes32 word, uint256 offset) internal pure returns (int256) {

        int256 value = int256(uint256(word >> offset) & _MASK_53);

        return value > _MAX_INT_53 ? (value | int256(~_MASK_53)) : value;
    }
}// MIT

pragma solidity ^0.7.0;


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        _require(c >= a, Errors.ADD_OVERFLOW);

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, Errors.SUB_OVERFLOW);
    }

    function sub(uint256 a, uint256 b, uint256 errorCode) internal pure returns (uint256) {

        _require(b <= a, errorCode);
        uint256 c = a - b;

        return c;
    }
}// MIT

pragma solidity ^0.7.0;



contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount, Errors.ERC20_TRANSFER_EXCEEDS_ALLOWANCE)
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue, Errors.ERC20_DECREASED_ALLOWANCE_BELOW_ZERO)
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        _require(sender != address(0), Errors.ERC20_TRANSFER_FROM_ZERO_ADDRESS);
        _require(recipient != address(0), Errors.ERC20_TRANSFER_TO_ZERO_ADDRESS);

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, Errors.ERC20_TRANSFER_EXCEEDS_BALANCE);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        _require(account != address(0), Errors.ERC20_BURN_FROM_ZERO_ADDRESS);

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, Errors.ERC20_BURN_EXCEEDS_ALLOWANCE);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IAssetManager {
    event Rebalance(bytes32 poolId);

    function setConfig(bytes32 poolId, bytes calldata config) external;


    function getToken() external view returns (IERC20);

    function getAUM(bytes32 poolId) external view returns (uint256);

    function getPoolBalances(bytes32 poolId) external view returns (uint256 poolCash, uint256 poolManaged);

    function maxInvestableBalance(bytes32 poolId) external view returns (int256);

    function updateBalanceOfPool(bytes32 poolId) external;

    function shouldRebalance(uint256 cash, uint256 managed) external view returns (bool);

    function rebalance(bytes32 poolId, bool force) external;

    function capitalOut(bytes32 poolId, uint256 amount) external;
}// MIT

pragma solidity ^0.7.0;

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}// MIT

pragma solidity ^0.7.0;

abstract contract EIP712 {
    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;


    constructor(string memory name, string memory version) {
        _HASHED_NAME = keccak256(bytes(name));
        _HASHED_VERSION = keccak256(bytes(version));
        _TYPE_HASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    }

    function _domainSeparatorV4() internal view virtual returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION, _getChainId(), address(this)));
    }

    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), structHash));
    }

    function _getChainId() private view returns (uint256 chainId) {
        this;

        assembly {
            chainId := chainid()
        }
    }
}// MIT

pragma solidity ^0.7.0;


abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    mapping(address => uint256) private _nonces;

    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    constructor(string memory name) EIP712(name, "1") {}

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        _require(block.timestamp <= deadline, Errors.EXPIRED_PERMIT);

        uint256 nonce = _nonces[owner];
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, nonce, deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ecrecover(hash, v, r, s);
        _require((signer != address(0)) && (signer == owner), Errors.INVALID_SIGNATURE);

        _nonces[owner] = nonce + 1;
        _approve(owner, spender, value);
    }

    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner];
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract BalancerPoolToken is ERC20, ERC20Permit {
    IVault private immutable _vault;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        IVault vault
    ) ERC20(tokenName, tokenSymbol) ERC20Permit(tokenName) {
        _vault = vault;
    }

    function getVault() public view returns (IVault) {
        return _vault;
    }


    function allowance(address owner, address spender) public view override returns (uint256) {
        if (spender == address(getVault())) {
            return uint256(-1);
        } else {
            return super.allowance(owner, spender);
        }
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 currentAllowance = allowance(sender, msg.sender);
        _require(msg.sender == sender || currentAllowance >= amount, Errors.ERC20_TRANSFER_EXCEEDS_ALLOWANCE);

        _transfer(sender, recipient, amount);

        if (msg.sender != sender && currentAllowance != uint256(-1)) {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public override returns (bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);

        if (amount >= currentAllowance) {
            _approve(msg.sender, spender, 0);
        } else {
            _approve(msg.sender, spender, currentAllowance - amount);
        }

        return true;
    }


    function _mintPoolTokens(address recipient, uint256 amount) internal {
        _mint(recipient, amount);
    }

    function _burnPoolTokens(address sender, uint256 amount) internal {
        _burn(sender, amount);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IAuthentication {
    function getActionId(bytes4 selector) external view returns (bytes32);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract Authentication is IAuthentication {
    bytes32 private immutable _actionIdDisambiguator;

    constructor(bytes32 actionIdDisambiguator) {
        _actionIdDisambiguator = actionIdDisambiguator;
    }

    modifier authenticate() {
        _authenticateCaller();
        _;
    }

    function _authenticateCaller() internal view {
        bytes32 actionId = getActionId(msg.sig);
        _require(_canPerform(actionId, msg.sender), Errors.SENDER_NOT_ALLOWED);
    }

    function getActionId(bytes4 selector) public view override returns (bytes32) {
        return keccak256(abi.encodePacked(_actionIdDisambiguator, selector));
    }

    function _canPerform(bytes32 actionId, address user) internal view virtual returns (bool);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



abstract contract BasePoolAuthorization is Authentication {
    address private immutable _owner;

    address private constant _DELEGATE_OWNER = 0xBA1BA1ba1BA1bA1bA1Ba1BA1ba1BA1bA1ba1ba1B;

    constructor(address owner) {
        _owner = owner;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }

    function getAuthorizer() external view returns (IAuthorizer) {
        return _getAuthorizer();
    }

    function _canPerform(bytes32 actionId, address account) internal view override returns (bool) {
        if ((getOwner() != _DELEGATE_OWNER) && _isOwnerOnlyAction(actionId)) {
            return msg.sender == getOwner();
        } else {
            return _getAuthorizer().canPerform(actionId, account, address(this));
        }
    }

    function _isOwnerOnlyAction(bytes32 actionId) internal view virtual returns (bool);

    function _getAuthorizer() internal view virtual returns (IAuthorizer);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;






abstract contract BasePool is IBasePool, BasePoolAuthorization, BalancerPoolToken, TemporarilyPausable {
    using WordCodec for bytes32;
    using FixedPoint for uint256;

    uint256 private constant _MIN_TOKENS = 2;

    uint256 private constant _MINIMUM_BPT = 1e6;

    uint256 private constant _MIN_SWAP_FEE_PERCENTAGE = 1e12; // 0.0001%
    uint256 private constant _MAX_SWAP_FEE_PERCENTAGE = 1e17; // 10% - this fits in 64 bits

    bytes32 private _miscData;
    uint256 private constant _SWAP_FEE_PERCENTAGE_OFFSET = 192;

    bytes32 private immutable _poolId;

    event SwapFeePercentageChanged(uint256 swapFeePercentage);

    constructor(
        IVault vault,
        IVault.PoolSpecialization specialization,
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        address[] memory assetManagers,
        uint256 swapFeePercentage,
        uint256 pauseWindowDuration,
        uint256 bufferPeriodDuration,
        address owner
    )
        Authentication(bytes32(uint256(msg.sender)))
        BalancerPoolToken(name, symbol, vault)
        BasePoolAuthorization(owner)
        TemporarilyPausable(pauseWindowDuration, bufferPeriodDuration)
    {
        _require(tokens.length >= _MIN_TOKENS, Errors.MIN_TOKENS);
        _require(tokens.length <= _getMaxTokens(), Errors.MAX_TOKENS);

        InputHelpers.ensureArrayIsSorted(tokens);

        _setSwapFeePercentage(swapFeePercentage);

        bytes32 poolId = vault.registerPool(specialization);

        vault.registerTokens(poolId, tokens, assetManagers);

        _poolId = poolId;
    }


    function getPoolId() public view override returns (bytes32) {
        return _poolId;
    }

    function _getTotalTokens() internal view virtual returns (uint256);

    function _getMaxTokens() internal pure virtual returns (uint256);

    function _getMinimumBpt() internal pure virtual returns (uint256) {
        return _MINIMUM_BPT;
    }

    function getSwapFeePercentage() public view returns (uint256) {
        return _miscData.decodeUint64(_SWAP_FEE_PERCENTAGE_OFFSET);
    }

    function setSwapFeePercentage(uint256 swapFeePercentage) external virtual authenticate whenNotPaused {
        _setSwapFeePercentage(swapFeePercentage);
    }

    function _setSwapFeePercentage(uint256 swapFeePercentage) private {
        _require(swapFeePercentage >= _MIN_SWAP_FEE_PERCENTAGE, Errors.MIN_SWAP_FEE_PERCENTAGE);
        _require(swapFeePercentage <= _MAX_SWAP_FEE_PERCENTAGE, Errors.MAX_SWAP_FEE_PERCENTAGE);

        _miscData = _miscData.insertUint64(swapFeePercentage, _SWAP_FEE_PERCENTAGE_OFFSET);
        emit SwapFeePercentageChanged(swapFeePercentage);
    }

    function setAssetManagerPoolConfig(IERC20 token, bytes memory poolConfig)
        public
        virtual
        authenticate
        whenNotPaused
    {
        _setAssetManagerPoolConfig(token, poolConfig);
    }

    function _setAssetManagerPoolConfig(IERC20 token, bytes memory poolConfig) private {
        bytes32 poolId = getPoolId();
        (, , , address assetManager) = getVault().getPoolTokenInfo(poolId, token);

        IAssetManager(assetManager).setConfig(poolId, poolConfig);
    }

    function setPaused(bool paused) external authenticate {
        _setPaused(paused);
    }

    function _isOwnerOnlyAction(bytes32 actionId) internal view virtual override returns (bool) {
        return
            (actionId == getActionId(this.setSwapFeePercentage.selector)) ||
            (actionId == getActionId(this.setAssetManagerPoolConfig.selector));
    }

    function _getMiscData() internal view returns (bytes32) {
        return _miscData;
    }

    function _setMiscData(bytes32 newData) internal {
        _miscData = _miscData.insertBits192(newData, 0);
    }


    modifier onlyVault(bytes32 poolId) {
        _require(msg.sender == address(getVault()), Errors.CALLER_NOT_VAULT);
        _require(poolId == getPoolId(), Errors.INVALID_POOL_ID);
        _;
    }

    function onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) public virtual override onlyVault(poolId) returns (uint256[] memory, uint256[] memory) {
        uint256[] memory scalingFactors = _scalingFactors();

        if (totalSupply() == 0) {
            (uint256 bptAmountOut, uint256[] memory amountsIn) = _onInitializePool(
                poolId,
                sender,
                recipient,
                scalingFactors,
                userData
            );

            _require(bptAmountOut >= _getMinimumBpt(), Errors.MINIMUM_BPT);
            _mintPoolTokens(address(0), _getMinimumBpt());
            _mintPoolTokens(recipient, bptAmountOut - _getMinimumBpt());

            _downscaleUpArray(amountsIn, scalingFactors);

            return (amountsIn, new uint256[](_getTotalTokens()));
        } else {
            _upscaleArray(balances, scalingFactors);
            (uint256 bptAmountOut, uint256[] memory amountsIn, uint256[] memory dueProtocolFeeAmounts) = _onJoinPool(
                poolId,
                sender,
                recipient,
                balances,
                lastChangeBlock,
                protocolSwapFeePercentage,
                scalingFactors,
                userData
            );


            _mintPoolTokens(recipient, bptAmountOut);

            _downscaleUpArray(amountsIn, scalingFactors);
            _downscaleDownArray(dueProtocolFeeAmounts, scalingFactors);

            return (amountsIn, dueProtocolFeeAmounts);
        }
    }

    function onExitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) public virtual override onlyVault(poolId) returns (uint256[] memory, uint256[] memory) {
        uint256[] memory scalingFactors = _scalingFactors();
        _upscaleArray(balances, scalingFactors);

        (uint256 bptAmountIn, uint256[] memory amountsOut, uint256[] memory dueProtocolFeeAmounts) = _onExitPool(
            poolId,
            sender,
            recipient,
            balances,
            lastChangeBlock,
            protocolSwapFeePercentage,
            scalingFactors,
            userData
        );


        _burnPoolTokens(sender, bptAmountIn);

        _downscaleDownArray(amountsOut, scalingFactors);
        _downscaleDownArray(dueProtocolFeeAmounts, scalingFactors);

        return (amountsOut, dueProtocolFeeAmounts);
    }


    function queryJoin(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256 bptOut, uint256[] memory amountsIn) {
        InputHelpers.ensureInputLengthMatch(balances.length, _getTotalTokens());

        _queryAction(
            poolId,
            sender,
            recipient,
            balances,
            lastChangeBlock,
            protocolSwapFeePercentage,
            userData,
            _onJoinPool,
            _downscaleUpArray
        );

        return (bptOut, amountsIn);
    }

    function queryExit(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData
    ) external returns (uint256 bptIn, uint256[] memory amountsOut) {
        InputHelpers.ensureInputLengthMatch(balances.length, _getTotalTokens());

        _queryAction(
            poolId,
            sender,
            recipient,
            balances,
            lastChangeBlock,
            protocolSwapFeePercentage,
            userData,
            _onExitPool,
            _downscaleDownArray
        );

        return (bptIn, amountsOut);
    }


    function _onInitializePool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) internal virtual returns (uint256 bptAmountOut, uint256[] memory amountsIn);

    function _onJoinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        uint256[] memory scalingFactors,
        bytes memory userData
    )
        internal
        virtual
        returns (
            uint256 bptAmountOut,
            uint256[] memory amountsIn,
            uint256[] memory dueProtocolFeeAmounts
        );

    function _onExitPool(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        uint256[] memory scalingFactors,
        bytes memory userData
    )
        internal
        virtual
        returns (
            uint256 bptAmountIn,
            uint256[] memory amountsOut,
            uint256[] memory dueProtocolFeeAmounts
        );


    function _addSwapFeeAmount(uint256 amount) internal view returns (uint256) {
        return amount.divUp(FixedPoint.ONE.sub(getSwapFeePercentage()));
    }

    function _subtractSwapFeeAmount(uint256 amount) internal view returns (uint256) {
        uint256 feeAmount = amount.mulUp(getSwapFeePercentage());
        return amount.sub(feeAmount);
    }


    function _computeScalingFactor(IERC20 token) internal view returns (uint256) {
        if (address(token) == address(this)) {
            return FixedPoint.ONE;
        }

        uint256 tokenDecimals = ERC20(address(token)).decimals();

        uint256 decimalsDifference = Math.sub(18, tokenDecimals);
        return FixedPoint.ONE * 10**decimalsDifference;
    }

    function _scalingFactor(IERC20 token) internal view virtual returns (uint256);

    function _scalingFactors() internal view virtual returns (uint256[] memory);

    function getScalingFactors() external view returns (uint256[] memory) {
        return _scalingFactors();
    }

    function _upscale(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
        return FixedPoint.mulDown(amount, scalingFactor);
    }

    function _upscaleArray(uint256[] memory amounts, uint256[] memory scalingFactors) internal view {
        for (uint256 i = 0; i < _getTotalTokens(); ++i) {
            amounts[i] = FixedPoint.mulDown(amounts[i], scalingFactors[i]);
        }
    }

    function _downscaleDown(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
        return FixedPoint.divDown(amount, scalingFactor);
    }

    function _downscaleDownArray(uint256[] memory amounts, uint256[] memory scalingFactors) internal view {
        for (uint256 i = 0; i < _getTotalTokens(); ++i) {
            amounts[i] = FixedPoint.divDown(amounts[i], scalingFactors[i]);
        }
    }

    function _downscaleUp(uint256 amount, uint256 scalingFactor) internal pure returns (uint256) {
        return FixedPoint.divUp(amount, scalingFactor);
    }

    function _downscaleUpArray(uint256[] memory amounts, uint256[] memory scalingFactors) internal view {
        for (uint256 i = 0; i < _getTotalTokens(); ++i) {
            amounts[i] = FixedPoint.divUp(amounts[i], scalingFactors[i]);
        }
    }

    function _getAuthorizer() internal view override returns (IAuthorizer) {
        return getVault().getAuthorizer();
    }

    function _queryAction(
        bytes32 poolId,
        address sender,
        address recipient,
        uint256[] memory balances,
        uint256 lastChangeBlock,
        uint256 protocolSwapFeePercentage,
        bytes memory userData,
        function(bytes32, address, address, uint256[] memory, uint256, uint256, uint256[] memory, bytes memory)
            internal
            returns (uint256, uint256[] memory, uint256[] memory) _action,
        function(uint256[] memory, uint256[] memory) internal view _downscaleArray
    ) private {

        if (msg.sender != address(this)) {

            (bool success, ) = address(this).call(msg.data);

            assembly {
                switch success
                    case 0 {

                        returndatacopy(0, 0, 0x04)
                        let error := and(mload(0), 0xffffffff00000000000000000000000000000000000000000000000000000000)

                        if eq(eq(error, 0x43adbafb00000000000000000000000000000000000000000000000000000000), 0) {
                            returndatacopy(0, 0, returndatasize())
                            revert(0, returndatasize())
                        }


                        returndatacopy(0, 0x04, 32)

                        mstore(0x20, 64)

                        returndatacopy(0x40, 0x24, sub(returndatasize(), 36))

                        return(0, add(returndatasize(), 28))
                    }
                    default {
                        invalid()
                    }
            }
        } else {
            uint256[] memory scalingFactors = _scalingFactors();
            _upscaleArray(balances, scalingFactors);

            (uint256 bptAmount, uint256[] memory tokenAmounts, ) = _action(
                poolId,
                sender,
                recipient,
                balances,
                lastChangeBlock,
                protocolSwapFeePercentage,
                scalingFactors,
                userData
            );

            _downscaleArray(tokenAmounts, scalingFactors);

            assembly {
                let size := mul(mload(tokenAmounts), 32)

                let start := sub(tokenAmounts, 0x20)
                mstore(start, bptAmount)

                mstore(sub(start, 0x20), 0x0000000000000000000000000000000000000000000000000000000043adbafb)
                start := sub(start, 0x04)

                revert(start, add(size, 68))
            }
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IMinimalSwapInfoPool is IBasePool {
    function onSwap(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut
    ) external returns (uint256 amount);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract BaseMinimalSwapInfoPool is IMinimalSwapInfoPool, BasePool {

    function onSwap(
        SwapRequest memory request,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut
    ) public virtual override onlyVault(request.poolId) returns (uint256) {
        uint256 scalingFactorTokenIn = _scalingFactor(request.tokenIn);
        uint256 scalingFactorTokenOut = _scalingFactor(request.tokenOut);

        if (request.kind == IVault.SwapKind.GIVEN_IN) {
            uint256 amountInMinusSwapFees = _subtractSwapFeeAmount(request.amount);

            uint256 swapFee = request.amount - amountInMinusSwapFees;
            _processSwapFeeAmount(request.tokenIn, _upscale(swapFee, scalingFactorTokenIn));

            request.amount = amountInMinusSwapFees;

            balanceTokenIn = _upscale(balanceTokenIn, scalingFactorTokenIn);
            balanceTokenOut = _upscale(balanceTokenOut, scalingFactorTokenOut);
            request.amount = _upscale(request.amount, scalingFactorTokenIn);

            uint256 amountOut = _onSwapGivenIn(request, balanceTokenIn, balanceTokenOut);

            return _downscaleDown(amountOut, scalingFactorTokenOut);
        } else {
            balanceTokenIn = _upscale(balanceTokenIn, scalingFactorTokenIn);
            balanceTokenOut = _upscale(balanceTokenOut, scalingFactorTokenOut);
            request.amount = _upscale(request.amount, scalingFactorTokenOut);

            uint256 amountIn = _onSwapGivenOut(request, balanceTokenIn, balanceTokenOut);

            amountIn = _downscaleUp(amountIn, scalingFactorTokenIn);

            uint256 amountInPlusSwapFees = _addSwapFeeAmount(amountIn);

            uint256 swapFee = amountInPlusSwapFees - amountIn;
            _processSwapFeeAmount(request.tokenIn, _upscale(swapFee, scalingFactorTokenIn));

            return amountInPlusSwapFees;
        }
    }

    function _onSwapGivenIn(
        SwapRequest memory swapRequest,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut
    ) internal virtual returns (uint256);

    function _onSwapGivenOut(
        SwapRequest memory swapRequest,
        uint256 balanceTokenIn,
        uint256 balanceTokenOut
    ) internal virtual returns (uint256);

    function _processSwapFeeAmount(
        uint256, /*index*/
        uint256 /*amount*/
    ) internal virtual {
    }

    function _processSwapFeeAmount(IERC20 token, uint256 amount) internal {
        _processSwapFeeAmount(_tokenAddressToIndex(token), amount);
    }

    function _processSwapFeeAmounts(uint256[] memory amounts) internal {
        InputHelpers.ensureInputLengthMatch(amounts.length, _getTotalTokens());

        for (uint256 i = 0; i < _getTotalTokens(); ++i) {
            _processSwapFeeAmount(i, amounts[i]);
        }
    }

    function _tokenAddressToIndex(
        IERC20 /*token*/
    ) internal view virtual returns (uint256) {
        return 0;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



library WeightedMath {
    using FixedPoint for uint256;
    uint256 internal constant _MIN_WEIGHT = 0.01e18;
    uint256 internal constant _MAX_WEIGHTED_TOKENS = 100;


    uint256 internal constant _MAX_IN_RATIO = 0.3e18;
    uint256 internal constant _MAX_OUT_RATIO = 0.3e18;

    uint256 internal constant _MAX_INVARIANT_RATIO = 3e18;
    uint256 internal constant _MIN_INVARIANT_RATIO = 0.7e18;


    function _calculateInvariant(uint256[] memory normalizedWeights, uint256[] memory balances)
        internal
        pure
        returns (uint256 invariant)
    {

        invariant = FixedPoint.ONE;
        for (uint256 i = 0; i < normalizedWeights.length; i++) {
            invariant = invariant.mulDown(balances[i].powDown(normalizedWeights[i]));
        }

        _require(invariant > 0, Errors.ZERO_INVARIANT);
    }

    function _calcOutGivenIn(
        uint256 balanceIn,
        uint256 weightIn,
        uint256 balanceOut,
        uint256 weightOut,
        uint256 amountIn
    ) internal pure returns (uint256) {



        _require(amountIn <= balanceIn.mulDown(_MAX_IN_RATIO), Errors.MAX_IN_RATIO);

        uint256 denominator = balanceIn.add(amountIn);
        uint256 base = balanceIn.divUp(denominator);
        uint256 exponent = weightIn.divDown(weightOut);
        uint256 power = base.powUp(exponent);

        return balanceOut.mulDown(power.complement());
    }

    function _calcInGivenOut(
        uint256 balanceIn,
        uint256 weightIn,
        uint256 balanceOut,
        uint256 weightOut,
        uint256 amountOut
    ) internal pure returns (uint256) {



        _require(amountOut <= balanceOut.mulDown(_MAX_OUT_RATIO), Errors.MAX_OUT_RATIO);

        uint256 base = balanceOut.divUp(balanceOut.sub(amountOut));
        uint256 exponent = weightOut.divUp(weightIn);
        uint256 power = base.powUp(exponent);

        uint256 ratio = power.sub(FixedPoint.ONE);

        return balanceIn.mulUp(ratio);
    }

    function _calcBptOutGivenExactTokensIn(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory amountsIn,
        uint256 bptTotalSupply,
        uint256 swapFeePercentage
    ) internal pure returns (uint256, uint256[] memory) {

        uint256[] memory balanceRatiosWithFee = new uint256[](amountsIn.length);

        uint256 invariantRatioWithFees = 0;
        for (uint256 i = 0; i < balances.length; i++) {
            balanceRatiosWithFee[i] = balances[i].add(amountsIn[i]).divDown(balances[i]);
            invariantRatioWithFees = invariantRatioWithFees.add(balanceRatiosWithFee[i].mulDown(normalizedWeights[i]));
        }

        (uint256 invariantRatio, uint256[] memory swapFees) = _computeJoinExactTokensInInvariantRatio(
            balances,
            normalizedWeights,
            amountsIn,
            balanceRatiosWithFee,
            invariantRatioWithFees,
            swapFeePercentage
        );

        uint256 bptOut = (invariantRatio > FixedPoint.ONE)
            ? bptTotalSupply.mulDown(invariantRatio.sub(FixedPoint.ONE))
            : 0;
        return (bptOut, swapFees);
    }

    function _computeJoinExactTokensInInvariantRatio(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory amountsIn,
        uint256[] memory balanceRatiosWithFee,
        uint256 invariantRatioWithFees,
        uint256 swapFeePercentage
    ) private pure returns (uint256 invariantRatio, uint256[] memory swapFees) {
        swapFees = new uint256[](amountsIn.length);
        invariantRatio = FixedPoint.ONE;

        for (uint256 i = 0; i < balances.length; i++) {
            uint256 amountInWithoutFee;

            if (balanceRatiosWithFee[i] > invariantRatioWithFees) {
                uint256 nonTaxableAmount = balances[i].mulDown(invariantRatioWithFees.sub(FixedPoint.ONE));
                uint256 taxableAmount = amountsIn[i].sub(nonTaxableAmount);
                uint256 swapFee = taxableAmount.mulUp(swapFeePercentage);

                amountInWithoutFee = nonTaxableAmount.add(taxableAmount.sub(swapFee));
                swapFees[i] = swapFee;
            } else {
                amountInWithoutFee = amountsIn[i];
            }

            uint256 balanceRatio = balances[i].add(amountInWithoutFee).divDown(balances[i]);

            invariantRatio = invariantRatio.mulDown(balanceRatio.powDown(normalizedWeights[i]));
        }
    }

    function _calcTokenInGivenExactBptOut(
        uint256 balance,
        uint256 normalizedWeight,
        uint256 bptAmountOut,
        uint256 bptTotalSupply,
        uint256 swapFeePercentage
    ) internal pure returns (uint256 amountIn, uint256 swapFee) {


        uint256 invariantRatio = bptTotalSupply.add(bptAmountOut).divUp(bptTotalSupply);
        _require(invariantRatio <= _MAX_INVARIANT_RATIO, Errors.MAX_OUT_BPT_FOR_TOKEN_IN);

        uint256 balanceRatio = invariantRatio.powUp(FixedPoint.ONE.divUp(normalizedWeight));

        uint256 amountInWithoutFee = balance.mulUp(balanceRatio.sub(FixedPoint.ONE));

        uint256 taxablePercentage = normalizedWeight.complement();
        uint256 taxableAmount = amountInWithoutFee.mulUp(taxablePercentage);
        uint256 nonTaxableAmount = amountInWithoutFee.sub(taxableAmount);

        uint256 taxableAmountPlusFees = taxableAmount.divUp(FixedPoint.ONE.sub(swapFeePercentage));

        swapFee = taxableAmountPlusFees - taxableAmount;
        amountIn = nonTaxableAmount.add(taxableAmountPlusFees);
    }

    function _calcAllTokensInGivenExactBptOut(
        uint256[] memory balances,
        uint256 bptAmountOut,
        uint256 totalBPT
    ) internal pure returns (uint256[] memory) {

        uint256 bptRatio = bptAmountOut.divUp(totalBPT);

        uint256[] memory amountsIn = new uint256[](balances.length);
        for (uint256 i = 0; i < balances.length; i++) {
            amountsIn[i] = balances[i].mulUp(bptRatio);
        }

        return amountsIn;
    }

    function _calcBptInGivenExactTokensOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory amountsOut,
        uint256 bptTotalSupply,
        uint256 swapFeePercentage
    ) internal pure returns (uint256, uint256[] memory) {

        uint256[] memory balanceRatiosWithoutFee = new uint256[](amountsOut.length);
        uint256 invariantRatioWithoutFees = 0;
        for (uint256 i = 0; i < balances.length; i++) {
            balanceRatiosWithoutFee[i] = balances[i].sub(amountsOut[i]).divUp(balances[i]);
            invariantRatioWithoutFees = invariantRatioWithoutFees.add(
                balanceRatiosWithoutFee[i].mulUp(normalizedWeights[i])
            );
        }

        (uint256 invariantRatio, uint256[] memory swapFees) = _computeExitExactTokensOutInvariantRatio(
            balances,
            normalizedWeights,
            amountsOut,
            balanceRatiosWithoutFee,
            invariantRatioWithoutFees,
            swapFeePercentage
        );

        uint256 bptIn = bptTotalSupply.mulUp(invariantRatio.complement());
        return (bptIn, swapFees);
    }

    function _computeExitExactTokensOutInvariantRatio(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory amountsOut,
        uint256[] memory balanceRatiosWithoutFee,
        uint256 invariantRatioWithoutFees,
        uint256 swapFeePercentage
    ) private pure returns (uint256 invariantRatio, uint256[] memory swapFees) {
        swapFees = new uint256[](amountsOut.length);
        invariantRatio = FixedPoint.ONE;

        for (uint256 i = 0; i < balances.length; i++) {

            uint256 amountOutWithFee;
            if (invariantRatioWithoutFees > balanceRatiosWithoutFee[i]) {
                uint256 nonTaxableAmount = balances[i].mulDown(invariantRatioWithoutFees.complement());
                uint256 taxableAmount = amountsOut[i].sub(nonTaxableAmount);
                uint256 taxableAmountPlusFees = taxableAmount.divUp(FixedPoint.ONE.sub(swapFeePercentage));

                swapFees[i] = taxableAmountPlusFees - taxableAmount;
                amountOutWithFee = nonTaxableAmount.add(taxableAmountPlusFees);
            } else {
                amountOutWithFee = amountsOut[i];
            }

            uint256 balanceRatio = balances[i].sub(amountOutWithFee).divDown(balances[i]);

            invariantRatio = invariantRatio.mulDown(balanceRatio.powDown(normalizedWeights[i]));
        }
    }

    function _calcTokenOutGivenExactBptIn(
        uint256 balance,
        uint256 normalizedWeight,
        uint256 bptAmountIn,
        uint256 bptTotalSupply,
        uint256 swapFeePercentage
    ) internal pure returns (uint256 amountOut, uint256 swapFee) {


        uint256 invariantRatio = bptTotalSupply.sub(bptAmountIn).divUp(bptTotalSupply);
        _require(invariantRatio >= _MIN_INVARIANT_RATIO, Errors.MIN_BPT_IN_FOR_TOKEN_OUT);

        uint256 balanceRatio = invariantRatio.powUp(FixedPoint.ONE.divDown(normalizedWeight));

        uint256 amountOutWithoutFee = balance.mulDown(balanceRatio.complement());

        uint256 taxablePercentage = normalizedWeight.complement();

        uint256 taxableAmount = amountOutWithoutFee.mulUp(taxablePercentage);
        uint256 nonTaxableAmount = amountOutWithoutFee.sub(taxableAmount);

        swapFee = taxableAmount.mulUp(swapFeePercentage);
        amountOut = nonTaxableAmount.add(taxableAmount.sub(swapFee));
    }

    function _calcTokensOutGivenExactBptIn(
        uint256[] memory balances,
        uint256 bptAmountIn,
        uint256 totalBPT
    ) internal pure returns (uint256[] memory) {


        uint256 bptRatio = bptAmountIn.divDown(totalBPT);

        uint256[] memory amountsOut = new uint256[](balances.length);
        for (uint256 i = 0; i < balances.length; i++) {
            amountsOut[i] = balances[i].mulDown(bptRatio);
        }

        return amountsOut;
    }

    function _calcDueTokenProtocolSwapFeeAmount(
        uint256 balance,
        uint256 normalizedWeight,
        uint256 previousInvariant,
        uint256 currentInvariant,
        uint256 protocolSwapFeePercentage
    ) internal pure returns (uint256) {

        if (currentInvariant <= previousInvariant) {
            return 0;
        }



        uint256 base = previousInvariant.divUp(currentInvariant);
        uint256 exponent = FixedPoint.ONE.divDown(normalizedWeight);

        base = Math.max(base, FixedPoint.MIN_POW_BASE_FREE_EXPONENT);

        uint256 power = base.powUp(exponent);

        uint256 tokenAccruedFees = balance.mulDown(power.complement());
        return tokenAccruedFees.mulDown(protocolSwapFeePercentage);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



library WeightedPoolUserDataHelpers {
    function joinKind(bytes memory self) internal pure returns (BaseWeightedPool.JoinKind) {
        return abi.decode(self, (BaseWeightedPool.JoinKind));
    }

    function exitKind(bytes memory self) internal pure returns (BaseWeightedPool.ExitKind) {
        return abi.decode(self, (BaseWeightedPool.ExitKind));
    }


    function initialAmountsIn(bytes memory self) internal pure returns (uint256[] memory amountsIn) {
        (, amountsIn) = abi.decode(self, (BaseWeightedPool.JoinKind, uint256[]));
    }

    function exactTokensInForBptOut(bytes memory self)
        internal
        pure
        returns (uint256[] memory amountsIn, uint256 minBPTAmountOut)
    {
        (, amountsIn, minBPTAmountOut) = abi.decode(self, (BaseWeightedPool.JoinKind, uint256[], uint256));
    }

    function tokenInForExactBptOut(bytes memory self) internal pure returns (uint256 bptAmountOut, uint256 tokenIndex) {
        (, bptAmountOut, tokenIndex) = abi.decode(self, (BaseWeightedPool.JoinKind, uint256, uint256));
    }

    function allTokensInForExactBptOut(bytes memory self) internal pure returns (uint256 bptAmountOut) {
        (, bptAmountOut) = abi.decode(self, (BaseWeightedPool.JoinKind, uint256));
    }


    function exactBptInForTokenOut(bytes memory self) internal pure returns (uint256 bptAmountIn, uint256 tokenIndex) {
        (, bptAmountIn, tokenIndex) = abi.decode(self, (BaseWeightedPool.ExitKind, uint256, uint256));
    }

    function exactBptInForTokensOut(bytes memory self) internal pure returns (uint256 bptAmountIn) {
        (, bptAmountIn) = abi.decode(self, (BaseWeightedPool.ExitKind, uint256));
    }

    function bptInForExactTokensOut(bytes memory self)
        internal
        pure
        returns (uint256[] memory amountsOut, uint256 maxBPTAmountIn)
    {
        (, amountsOut, maxBPTAmountIn) = abi.decode(self, (BaseWeightedPool.ExitKind, uint256[], uint256));
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;




abstract contract BaseWeightedPool is BaseMinimalSwapInfoPool {
    using FixedPoint for uint256;
    using WeightedPoolUserDataHelpers for bytes;

    uint256 private _lastInvariant;


    enum JoinKind { INIT, EXACT_TOKENS_IN_FOR_BPT_OUT, TOKEN_IN_FOR_EXACT_BPT_OUT, ALL_TOKENS_IN_FOR_EXACT_BPT_OUT }
    enum ExitKind {
        EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
        EXACT_BPT_IN_FOR_TOKENS_OUT,
        BPT_IN_FOR_EXACT_TOKENS_OUT,
        MANAGEMENT_FEE_TOKENS_OUT // for InvestmentPool
    }

    constructor(
        IVault vault,
        string memory name,
        string memory symbol,
        IERC20[] memory tokens,
        address[] memory assetManagers,
        uint256 swapFeePercentage,
        uint256 pauseWindowDuration,
        uint256 bufferPeriodDuration,
        address owner
    )
        BasePool(
            vault,
            tokens.length == 2 ? IVault.PoolSpecialization.TWO_TOKEN : IVault.PoolSpecialization.MINIMAL_SWAP_INFO,
            name,
            symbol,
            tokens,
            assetManagers,
            swapFeePercentage,
            pauseWindowDuration,
            bufferPeriodDuration,
            owner
        )
    {
    }


    function _getNormalizedWeight(IERC20 token) internal view virtual returns (uint256);

    function _getNormalizedWeights() internal view virtual returns (uint256[] memory);

    function _getNormalizedWeightsAndMaxWeightIndex() internal view virtual returns (uint256[] memory, uint256);

    function getLastInvariant() public view virtual returns (uint256) {
        return _lastInvariant;
    }

    function getInvariant() public view returns (uint256) {
        (, uint256[] memory balances, ) = getVault().getPoolTokens(getPoolId());

        _upscaleArray(balances, _scalingFactors());

        (uint256[] memory normalizedWeights, ) = _getNormalizedWeightsAndMaxWeightIndex();
        return WeightedMath._calculateInvariant(normalizedWeights, balances);
    }

    function getNormalizedWeights() external view returns (uint256[] memory) {
        return _getNormalizedWeights();
    }



    function _onSwapGivenIn(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut
    ) internal view virtual override whenNotPaused returns (uint256) {

        return
            WeightedMath._calcOutGivenIn(
                currentBalanceTokenIn,
                _getNormalizedWeight(swapRequest.tokenIn),
                currentBalanceTokenOut,
                _getNormalizedWeight(swapRequest.tokenOut),
                swapRequest.amount
            );
    }

    function _onSwapGivenOut(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut
    ) internal view virtual override whenNotPaused returns (uint256) {

        return
            WeightedMath._calcInGivenOut(
                currentBalanceTokenIn,
                _getNormalizedWeight(swapRequest.tokenIn),
                currentBalanceTokenOut,
                _getNormalizedWeight(swapRequest.tokenOut),
                swapRequest.amount
            );
    }


    function _onInitializePool(
        bytes32,
        address,
        address,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) internal virtual override whenNotPaused returns (uint256, uint256[] memory) {

        JoinKind kind = userData.joinKind();
        _require(kind == JoinKind.INIT, Errors.UNINITIALIZED);

        uint256[] memory amountsIn = userData.initialAmountsIn();
        InputHelpers.ensureInputLengthMatch(_getTotalTokens(), amountsIn.length);
        _upscaleArray(amountsIn, scalingFactors);

        (uint256[] memory normalizedWeights, ) = _getNormalizedWeightsAndMaxWeightIndex();

        uint256 invariantAfterJoin = WeightedMath._calculateInvariant(normalizedWeights, amountsIn);

        uint256 bptAmountOut = Math.mul(invariantAfterJoin, _getTotalTokens());

        _lastInvariant = invariantAfterJoin;

        return (bptAmountOut, amountsIn);
    }


    function _onJoinPool(
        bytes32,
        address,
        address,
        uint256[] memory balances,
        uint256,
        uint256 protocolSwapFeePercentage,
        uint256[] memory scalingFactors,
        bytes memory userData
    )
        internal
        virtual
        override
        whenNotPaused
        returns (
            uint256,
            uint256[] memory,
            uint256[] memory
        )
    {

        (uint256[] memory normalizedWeights, uint256 maxWeightTokenIndex) = _getNormalizedWeightsAndMaxWeightIndex();

        uint256 invariantBeforeJoin = WeightedMath._calculateInvariant(normalizedWeights, balances);

        uint256[] memory dueProtocolFeeAmounts = _getDueProtocolFeeAmounts(
            balances,
            normalizedWeights,
            maxWeightTokenIndex,
            _lastInvariant,
            invariantBeforeJoin,
            protocolSwapFeePercentage
        );

        _mutateAmounts(balances, dueProtocolFeeAmounts, FixedPoint.sub);
        (uint256 bptAmountOut, uint256[] memory amountsIn) = _doJoin(
            balances,
            normalizedWeights,
            scalingFactors,
            userData
        );

        _lastInvariant = _invariantAfterJoin(balances, amountsIn, normalizedWeights);

        return (bptAmountOut, amountsIn, dueProtocolFeeAmounts);
    }

    function _doJoin(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) internal returns (uint256, uint256[] memory) {
        JoinKind kind = userData.joinKind();

        if (kind == JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT) {
            return _joinExactTokensInForBPTOut(balances, normalizedWeights, scalingFactors, userData);
        } else if (kind == JoinKind.TOKEN_IN_FOR_EXACT_BPT_OUT) {
            return _joinTokenInForExactBPTOut(balances, normalizedWeights, userData);
        } else if (kind == JoinKind.ALL_TOKENS_IN_FOR_EXACT_BPT_OUT) {
            return _joinAllTokensInForExactBPTOut(balances, userData);
        } else {
            _revert(Errors.UNHANDLED_JOIN_KIND);
        }
    }

    function _joinExactTokensInForBPTOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) private returns (uint256, uint256[] memory) {
        (uint256[] memory amountsIn, uint256 minBPTAmountOut) = userData.exactTokensInForBptOut();
        InputHelpers.ensureInputLengthMatch(_getTotalTokens(), amountsIn.length);

        _upscaleArray(amountsIn, scalingFactors);

        (uint256 bptAmountOut, uint256[] memory swapFees) = WeightedMath._calcBptOutGivenExactTokensIn(
            balances,
            normalizedWeights,
            amountsIn,
            totalSupply(),
            getSwapFeePercentage()
        );

        _processSwapFeeAmounts(swapFees);

        _require(bptAmountOut >= minBPTAmountOut, Errors.BPT_OUT_MIN_AMOUNT);

        return (bptAmountOut, amountsIn);
    }

    function _joinTokenInForExactBPTOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        bytes memory userData
    ) private returns (uint256, uint256[] memory) {
        (uint256 bptAmountOut, uint256 tokenIndex) = userData.tokenInForExactBptOut();

        _require(tokenIndex < _getTotalTokens(), Errors.OUT_OF_BOUNDS);

        (uint256 amountIn, uint256 swapFee) = WeightedMath._calcTokenInGivenExactBptOut(
            balances[tokenIndex],
            normalizedWeights[tokenIndex],
            bptAmountOut,
            totalSupply(),
            getSwapFeePercentage()
        );

        _processSwapFeeAmount(tokenIndex, swapFee);

        uint256[] memory amountsIn = new uint256[](_getTotalTokens());
        amountsIn[tokenIndex] = amountIn;

        return (bptAmountOut, amountsIn);
    }

    function _joinAllTokensInForExactBPTOut(uint256[] memory balances, bytes memory userData)
        private
        view
        returns (uint256, uint256[] memory)
    {
        uint256 bptAmountOut = userData.allTokensInForExactBptOut();

        uint256[] memory amountsIn = WeightedMath._calcAllTokensInGivenExactBptOut(
            balances,
            bptAmountOut,
            totalSupply()
        );

        return (bptAmountOut, amountsIn);
    }


    function _onExitPool(
        bytes32,
        address,
        address,
        uint256[] memory balances,
        uint256,
        uint256 protocolSwapFeePercentage,
        uint256[] memory scalingFactors,
        bytes memory userData
    )
        internal
        virtual
        override
        returns (
            uint256 bptAmountIn,
            uint256[] memory amountsOut,
            uint256[] memory dueProtocolFeeAmounts
        )
    {
        (uint256[] memory normalizedWeights, uint256 maxWeightTokenIndex) = _getNormalizedWeightsAndMaxWeightIndex();


        if (_isNotPaused()) {
            uint256 invariantBeforeExit = WeightedMath._calculateInvariant(normalizedWeights, balances);
            dueProtocolFeeAmounts = _getDueProtocolFeeAmounts(
                balances,
                normalizedWeights,
                maxWeightTokenIndex,
                _lastInvariant,
                invariantBeforeExit,
                protocolSwapFeePercentage
            );

            _mutateAmounts(balances, dueProtocolFeeAmounts, FixedPoint.sub);
        } else {
            dueProtocolFeeAmounts = new uint256[](_getTotalTokens());
        }

        (bptAmountIn, amountsOut) = _doExit(balances, normalizedWeights, scalingFactors, userData);

        _lastInvariant = _invariantAfterExit(balances, amountsOut, normalizedWeights);

        return (bptAmountIn, amountsOut, dueProtocolFeeAmounts);
    }

    function _doExit(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) internal returns (uint256, uint256[] memory) {
        ExitKind kind = userData.exitKind();

        if (kind == ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT) {
            return _exitExactBPTInForTokenOut(balances, normalizedWeights, userData);
        } else if (kind == ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT) {
            return _exitExactBPTInForTokensOut(balances, userData);
        } else if (kind == ExitKind.BPT_IN_FOR_EXACT_TOKENS_OUT) {
            return _exitBPTInForExactTokensOut(balances, normalizedWeights, scalingFactors, userData);
        } else {
            _revert(Errors.UNHANDLED_EXIT_KIND);
        }
    }

    function _exitExactBPTInForTokenOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        bytes memory userData
    ) private whenNotPaused returns (uint256, uint256[] memory) {

        (uint256 bptAmountIn, uint256 tokenIndex) = userData.exactBptInForTokenOut();

        _require(tokenIndex < _getTotalTokens(), Errors.OUT_OF_BOUNDS);

        (uint256 amountOut, uint256 swapFee) = WeightedMath._calcTokenOutGivenExactBptIn(
            balances[tokenIndex],
            normalizedWeights[tokenIndex],
            bptAmountIn,
            totalSupply(),
            getSwapFeePercentage()
        );

        _processSwapFeeAmount(tokenIndex, swapFee);

        uint256[] memory amountsOut = new uint256[](_getTotalTokens());
        amountsOut[tokenIndex] = amountOut;

        return (bptAmountIn, amountsOut);
    }

    function _exitExactBPTInForTokensOut(uint256[] memory balances, bytes memory userData)
        private
        view
        returns (uint256, uint256[] memory)
    {

        uint256 bptAmountIn = userData.exactBptInForTokensOut();

        uint256[] memory amountsOut = WeightedMath._calcTokensOutGivenExactBptIn(balances, bptAmountIn, totalSupply());
        return (bptAmountIn, amountsOut);
    }

    function _exitBPTInForExactTokensOut(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256[] memory scalingFactors,
        bytes memory userData
    ) private whenNotPaused returns (uint256, uint256[] memory) {

        (uint256[] memory amountsOut, uint256 maxBPTAmountIn) = userData.bptInForExactTokensOut();
        InputHelpers.ensureInputLengthMatch(amountsOut.length, _getTotalTokens());
        _upscaleArray(amountsOut, scalingFactors);

        (uint256 bptAmountIn, uint256[] memory swapFees) = WeightedMath._calcBptInGivenExactTokensOut(
            balances,
            normalizedWeights,
            amountsOut,
            totalSupply(),
            getSwapFeePercentage()
        );
        _require(bptAmountIn <= maxBPTAmountIn, Errors.BPT_IN_MAX_AMOUNT);

        _processSwapFeeAmounts(swapFees);

        return (bptAmountIn, amountsOut);
    }


    function _getDueProtocolFeeAmounts(
        uint256[] memory balances,
        uint256[] memory normalizedWeights,
        uint256 maxWeightTokenIndex,
        uint256 previousInvariant,
        uint256 currentInvariant,
        uint256 protocolSwapFeePercentage
    ) private view returns (uint256[] memory) {
        uint256[] memory dueProtocolFeeAmounts = new uint256[](_getTotalTokens());

        if (protocolSwapFeePercentage == 0) {
            return dueProtocolFeeAmounts;
        }

        dueProtocolFeeAmounts[maxWeightTokenIndex] = WeightedMath._calcDueTokenProtocolSwapFeeAmount(
            balances[maxWeightTokenIndex],
            normalizedWeights[maxWeightTokenIndex],
            previousInvariant,
            currentInvariant,
            protocolSwapFeePercentage
        );

        return dueProtocolFeeAmounts;
    }

    function _invariantAfterJoin(
        uint256[] memory balances,
        uint256[] memory amountsIn,
        uint256[] memory normalizedWeights
    ) private view returns (uint256) {
        _mutateAmounts(balances, amountsIn, FixedPoint.add);
        return WeightedMath._calculateInvariant(normalizedWeights, balances);
    }

    function _invariantAfterExit(
        uint256[] memory balances,
        uint256[] memory amountsOut,
        uint256[] memory normalizedWeights
    ) private view returns (uint256) {
        _mutateAmounts(balances, amountsOut, FixedPoint.sub);
        return WeightedMath._calculateInvariant(normalizedWeights, balances);
    }

    function _mutateAmounts(
        uint256[] memory toMutate,
        uint256[] memory arguments,
        function(uint256, uint256) pure returns (uint256) mutation
    ) private view {
        for (uint256 i = 0; i < _getTotalTokens(); ++i) {
            toMutate[i] = mutation(toMutate[i], arguments[i]);
        }
    }

    function getRate() public view returns (uint256) {
        return Math.mul(getInvariant(), _getTotalTokens()).divDown(totalSupply());
    }
}// MIT


pragma solidity ^0.7.0;


library EnumerableSet {

    struct AddressSet {
        address[] _values;
        mapping(address => uint256) _indexes;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        if (!contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (toDeleteIndex != lastIndex) {
                address lastValue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return set._indexes[value] != 0;
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return set._values.length;
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        _require(set._values.length > index, Errors.OUT_OF_BOUNDS);
        return unchecked_at(set, index);
    }

    function unchecked_at(AddressSet storage set, uint256 index) internal view returns (address) {
        return set._values[index];
    }

    function rawIndexOf(AddressSet storage set, address value) internal view returns (uint256) {
        return set._indexes[value] - 1;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract PoolTokenCache {
    using EnumerableSet for EnumerableSet.AddressSet;

    IVault public immutable vault;

    constructor(IVault _vault) {
        vault = _vault;
    }

    mapping(bytes32 => EnumerableSet.AddressSet) private _poolTokenSets;
    mapping(bytes32 => bool) private _poolTokenSetSaved;

    function savePoolTokenSet(bytes32 poolId) public {
        (IERC20[] memory poolTokens, , ) = vault.getPoolTokens(poolId);

        if (_poolTokenSetSaved[poolId]) {
            uint256 numTokens = _poolTokenSets[poolId].length();

            for (uint256 i = 0; i < numTokens; i++) {
                uint256 lastIndex = numTokens - 1 - i;

                address lastIndexAddress = _poolTokenSets[poolId].unchecked_at(lastIndex);
                _poolTokenSets[poolId].remove(lastIndexAddress);
            }
        } else {
            _poolTokenSetSaved[poolId] = true;
        }

        for (uint256 pt; pt < poolTokens.length; pt++) {
            _poolTokenSets[poolId].add(address(poolTokens[pt]));
        }
    }

    function ensurePoolTokenSetSaved(bytes32 poolId) public {
        if (!_poolTokenSetSaved[poolId]) {
            savePoolTokenSet(poolId);
        }
    }

    modifier withPoolTokenSetSaved(bytes32 poolId) {
        ensurePoolTokenSetSaved(poolId);
        _;
    }

    function _getAssets(bytes32 poolId) internal view returns (IAsset[] memory assets) {
        uint256 numTokens = poolTokensLength(poolId);

        assets = new IAsset[](numTokens);
        for (uint256 pt; pt < numTokens; pt++) {
            assets[pt] = IAsset(_poolTokenSets[poolId].unchecked_at(pt));
        }
    }

    function _poolTokenIndex(bytes32 poolId, address token) internal view returns (uint256) {
        return _poolTokenSets[poolId].rawIndexOf(token);
    }

    function poolHasToken(bytes32 poolId, address token) public view returns (bool) {
        return _poolTokenSets[poolId].contains(token);
    }

    function poolTokensLength(bytes32 poolId) public view returns (uint256) {
        return _poolTokenSets[poolId].length();
    }

    function poolTokenAtIndex(bytes32 poolId, uint256 index) public view returns (address) {
        return _poolTokenSets[poolId].at(index);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IDistributorCallback {
    function distributorCallback(bytes calldata callbackData) external;
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract Exiter is PoolTokenCache, IDistributorCallback {
    constructor(IVault _vault) PoolTokenCache(_vault) {
    }

    struct CallbackParams {
        address[] pools;
        address payable recipient;
    }

    function distributorCallback(bytes calldata callbackData) external override {
        CallbackParams memory params = abi.decode(callbackData, (CallbackParams));

        for (uint256 p; p < params.pools.length; p++) {
            address poolAddress = params.pools[p];

            IBasePool poolContract = IBasePool(poolAddress);
            bytes32 poolId = poolContract.getPoolId();
            ensurePoolTokenSetSaved(poolId);

            IERC20 pool = IERC20(poolAddress);
            _exitPool(pool, poolId, params.recipient);
        }
    }

    function _exitPool(
        IERC20 pool,
        bytes32 poolId,
        address payable recipient
    ) internal {
        IAsset[] memory assets = _getAssets(poolId);
        uint256[] memory minAmountsOut = new uint256[](assets.length);

        uint256 bptAmountIn = pool.balanceOf(address(this));

        bytes memory userData = abi.encode(BaseWeightedPool.ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT, bptAmountIn);
        bool toInternalBalance = false;

        IVault.ExitPoolRequest memory request = IVault.ExitPoolRequest(
            assets,
            minAmountsOut,
            userData,
            toInternalBalance
        );
        vault.exitPool(poolId, address(this), recipient, request);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract MockRewardCallback is IDistributorCallback {
    event CallbackReceived();

    function distributorCallback(bytes calldata) external override {
        emit CallbackReceived();
        return;
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract Reinvestor is PoolTokenCache, IDistributorCallback {
    using EnumerableSet for EnumerableSet.AddressSet;

    constructor(IVault _vault) PoolTokenCache(_vault) {
    }

    function _initializeArrays(bytes32 poolId, IERC20[] memory tokens)
        internal
        view
        returns (uint256[] memory amountsIn, IVault.UserBalanceOp[] memory leftoverOps)
    {
        uint256 joinTokensCount;
        uint256 leftoverTokensCount;
        for (uint256 t; t < tokens.length; t++) {
            if (poolHasToken(poolId, address(tokens[t]))) {
                joinTokensCount++;
            }
        }
        leftoverTokensCount = tokens.length - joinTokensCount;

        amountsIn = new uint256[](poolTokensLength(poolId));

        leftoverOps = new IVault.UserBalanceOp[](leftoverTokensCount);
    }

    function _populateArrays(
        bytes32 poolId,
        address recipient,
        IERC20[] memory tokens,
        uint256[] memory internalBalances,
        uint256[] memory amountsIn,
        IVault.UserBalanceOp[] memory leftoverOps
    ) internal view {
        uint256 leftoverOpsIdx;

        for (uint256 t; t < tokens.length; t++) {
            address token = address(tokens[t]);

            if (poolHasToken(poolId, token)) {
                amountsIn[_poolTokenIndex(poolId, token)] = internalBalances[t];
            } else {
                leftoverOps[leftoverOpsIdx] = IVault.UserBalanceOp({
                    asset: IAsset(token),
                    amount: internalBalances[t], // callbackAmounts have been subtracted
                    sender: address(this),
                    recipient: payable(recipient),
                    kind: IVault.UserBalanceOpKind.WITHDRAW_INTERNAL
                });
                leftoverOpsIdx++;
            }
        }
    }

    struct CallbackParams {
        address payable recipient;
        bytes32 poolId;
        IERC20[] tokens;
    }

    function distributorCallback(bytes calldata callbackData) external override {
        CallbackParams memory params = abi.decode(callbackData, (CallbackParams));

        ensurePoolTokenSetSaved(params.poolId);

        IAsset[] memory assets = _getAssets(params.poolId);

        (uint256[] memory amountsIn, IVault.UserBalanceOp[] memory leftoverOps) = _initializeArrays(
            params.poolId,
            params.tokens
        );

        uint256[] memory internalBalances = vault.getInternalBalance(address(this), params.tokens);
        _populateArrays(params.poolId, params.recipient, params.tokens, internalBalances, amountsIn, leftoverOps);

        _joinPool(params.poolId, params.recipient, assets, amountsIn);
        vault.manageUserBalance(leftoverOps);
    }

    function _joinPool(
        bytes32 poolId,
        address recipient,
        IAsset[] memory assets,
        uint256[] memory amountsIn
    ) internal {
        bytes memory userData = abi.encode(
            BaseWeightedPool.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT,
            amountsIn,
            uint256(0)
        );

        IVault.JoinPoolRequest memory request = IVault.JoinPoolRequest(assets, amountsIn, userData, true);

        vault.joinPool(poolId, address(this), recipient, request);
    }
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



library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(address(token), abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(address(token), abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(address token, bytes memory data) private {
        (bool success, bytes memory returndata) = token.call(data);

        assembly {
            if eq(success, 0) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }

        _require(returndata.length == 0 || abi.decode(returndata, (bool)), Errors.SAFE_ERC20_CALL_FAILED);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IMultiRewards {
    function notifyRewardAmount(
        IERC20 stakingToken,
        IERC20 rewardsToken,
        uint256 reward,
        address rewarder
    ) external;

    function addReward(
        IERC20 pool,
        IERC20 rewardsToken,
        uint256 rewardsDuration
    ) external;

    function allowlistRewarder(
        IERC20 pool,
        IERC20 rewardsToken,
        address rewarder
    ) external;

    function isAllowlistedRewarder(
        IERC20 pool,
        IERC20 rewardsToken,
        address rewarder
    ) external view returns (bool);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract RewardsScheduler {
    using SafeERC20 for IERC20;

    IMultiRewards private immutable _multirewards;

    constructor() {
        _multirewards = IMultiRewards(msg.sender);
    }

    enum RewardStatus { UNINITIALIZED, PENDING, STARTED }

    struct ScheduledReward {
        IERC20 pool;
        IERC20 rewardsToken;
        uint256 startTime;
        address rewarder;
        uint256 amount;
        RewardStatus status;
    }

    event RewardScheduled(
        bytes32 rewardId,
        address indexed rewarder,
        IERC20 indexed pool,
        IERC20 indexed rewardsToken,
        uint256 startTime,
        uint256 amount
    );
    event RewardStarted(
        bytes32 rewardId,
        address indexed rewarder,
        IERC20 indexed pool,
        IERC20 indexed rewardsToken,
        uint256 startTime,
        uint256 amount
    );

    mapping(bytes32 => ScheduledReward) private _rewards;

    function getScheduledRewardInfo(bytes32 rewardId) external view returns (ScheduledReward memory reward) {
        return _rewards[rewardId];
    }

    function startRewards(bytes32[] calldata rewardIds) external {
        for (uint256 r; r < rewardIds.length; r++) {
            bytes32 rewardId = rewardIds[r];
            ScheduledReward memory scheduledReward = _rewards[rewardId];

            require(scheduledReward.status == RewardStatus.PENDING, "Reward cannot be started");
            require(scheduledReward.startTime <= block.timestamp, "Reward start time is in the future");

            _rewards[rewardId].status = RewardStatus.STARTED;

            if (
                scheduledReward.rewardsToken.allowance(address(this), address(_multirewards)) < scheduledReward.amount
            ) {
                scheduledReward.rewardsToken.approve(address(_multirewards), type(uint256).max);
            }
            _multirewards.notifyRewardAmount(
                scheduledReward.pool,
                scheduledReward.rewardsToken,
                scheduledReward.amount,
                scheduledReward.rewarder
            );
            emit RewardStarted(
                rewardId,
                scheduledReward.rewarder,
                scheduledReward.pool,
                scheduledReward.rewardsToken,
                scheduledReward.startTime,
                scheduledReward.amount
            );
        }
    }

    function getRewardId(
        IERC20 pool,
        IERC20 rewardsToken,
        address rewarder,
        uint256 startTime
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(pool, rewardsToken, rewarder, startTime));
    }

    function scheduleReward(
        IERC20 pool,
        IERC20 rewardsToken,
        uint256 amount,
        uint256 startTime
    ) public returns (bytes32 rewardId) {
        rewardId = getRewardId(pool, rewardsToken, msg.sender, startTime);
        require(startTime > block.timestamp, "Reward can only be scheduled for the future");
        require(
            _multirewards.isAllowlistedRewarder(pool, rewardsToken, msg.sender),
            "Only allowlisted rewarders can schedule reward"
        );

        require(_rewards[rewardId].status == RewardStatus.UNINITIALIZED, "Reward has already been scheduled");

        _rewards[rewardId] = ScheduledReward({
            pool: pool,
            rewardsToken: rewardsToken,
            rewarder: msg.sender,
            amount: amount,
            startTime: startTime,
            status: RewardStatus.PENDING
        });

        rewardsToken.safeTransferFrom(msg.sender, address(this), amount);

        emit RewardScheduled(rewardId, msg.sender, pool, rewardsToken, startTime, amount);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IDistributor {
    event RewardPaid(address indexed user, address indexed rewardToken, uint256 amount);
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract MultiRewardsAuthorization is Authentication {
    IVault private immutable _vault;

    mapping(IERC20 => mapping(IERC20 => mapping(address => bool))) private _allowlist;

    event RewarderAllowlisted(address indexed pool, address indexed token, address indexed rewarder);

    constructor(IVault vault) {
        _vault = vault;
    }

    modifier onlyAllowlistedRewarder(IERC20 pool, IERC20 rewardsToken) {
        require(_isAllowlistedRewarder(pool, rewardsToken, msg.sender), "Only accessible by allowlisted rewarders");
        _;
    }

    modifier onlyAllowlisters(IERC20 pool) {
        require(
            _canPerform(getActionId(msg.sig), msg.sender) ||
                msg.sender == address(pool) ||
                isAssetManager(pool, msg.sender),
            "Only accessible by governance, pool or it's asset managers"
        );
        _;
    }

    function getVault() public view returns (IVault) {
        return _vault;
    }

    function getAuthorizer() external view returns (IAuthorizer) {
        return _getAuthorizer();
    }

    function _getAuthorizer() internal view returns (IAuthorizer) {
        return getVault().getAuthorizer();
    }

    function _allowlistRewarder(
        IERC20 pool,
        IERC20 rewardsToken,
        address rewarder
    ) internal {
        _allowlist[pool][rewardsToken][rewarder] = true;
        emit RewarderAllowlisted(address(pool), address(rewardsToken), rewarder);
    }

    function _isAllowlistedRewarder(
        IERC20 pool,
        IERC20 rewardsToken,
        address rewarder
    ) internal view returns (bool) {
        return _allowlist[pool][rewardsToken][rewarder];
    }

    function isAssetManager(IERC20 pool, address rewarder) public view returns (bool) {
        IBasePool poolContract = IBasePool(address(pool));
        bytes32 poolId = poolContract.getPoolId();
        (IERC20[] memory poolTokens, , ) = getVault().getPoolTokens(poolId);

        for (uint256 pt; pt < poolTokens.length; pt++) {
            (, , , address assetManager) = getVault().getPoolTokenInfo(poolId, poolTokens[pt]);
            if (assetManager == rewarder) {
                return true;
            }
        }
        return false;
    }

    function _canPerform(bytes32 actionId, address account) internal view override returns (bool) {
        return _getAuthorizer().canPerform(actionId, account, address(this));
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;








contract MultiRewards is IMultiRewards, IDistributor, ReentrancyGuard, MultiRewardsAuthorization {
    using FixedPoint for uint256;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;


    struct Reward {
        uint256 rewardsDuration;
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }

    mapping(IERC20 => mapping(address => mapping(IERC20 => Reward))) public rewardData;

    mapping(IERC20 => EnumerableSet.AddressSet) private _rewardTokens;

    mapping(IERC20 => mapping(IERC20 => EnumerableSet.AddressSet)) private _rewarders;

    mapping(IERC20 => mapping(address => mapping(address => mapping(IERC20 => uint256)))) public userRewardPerTokenPaid;

    mapping(IERC20 => mapping(address => mapping(IERC20 => uint256))) public unpaidRewards;

    mapping(IERC20 => uint256) private _totalSupply;

    mapping(IERC20 => mapping(address => uint256)) private _balances;

    RewardsScheduler public immutable rewardsScheduler;


    constructor(IVault _vault)
        Authentication(bytes32(uint256(address(this))))
        MultiRewardsAuthorization(_vault)
    {
        rewardsScheduler = new RewardsScheduler();
    }

    function allowlistRewarder(
        IERC20 pool,
        IERC20 rewardsToken,
        address rewarder
    ) external override onlyAllowlisters(pool) {
        _allowlistRewarder(pool, rewardsToken, rewarder);
    }

    function isAllowlistedRewarder(
        IERC20 pool,
        IERC20 rewardsToken,
        address rewarder
    ) public view override returns (bool) {
        return _isAllowlistedRewarder(pool, rewardsToken, rewarder);
    }

    function addReward(
        IERC20 pool,
        IERC20 rewardsToken,
        uint256 rewardsDuration
    ) external override onlyAllowlistedRewarder(pool, rewardsToken) {
        require(rewardsDuration > 0, "reward rate must be nonzero");
        require(rewardData[pool][msg.sender][rewardsToken].rewardsDuration == 0, "Duplicate rewards token");
        _rewardTokens[pool].add(address(rewardsToken));
        _rewarders[pool][rewardsToken].add(msg.sender);
        rewardData[pool][msg.sender][rewardsToken].rewardsDuration = rewardsDuration;
        rewardsToken.approve(address(getVault()), type(uint256).max);
    }


    function totalSupply(IERC20 pool) external view returns (uint256) {
        return _totalSupply[pool];
    }

    function balanceOf(IERC20 pool, address account) external view returns (uint256) {
        return _balances[pool][account];
    }

    function lastTimeRewardApplicable(
        IERC20 pool,
        address rewarder,
        IERC20 rewardsToken
    ) public view returns (uint256) {
        return _lastTimeRewardApplicable(rewardData[pool][rewarder][rewardsToken]);
    }

    function _lastTimeRewardApplicable(Reward storage data) private view returns (uint256) {
        return Math.min(block.timestamp, data.periodFinish);
    }

    function rewardPerToken(
        IERC20 pool,
        address rewarder,
        IERC20 rewardsToken
    ) public view returns (uint256) {
        return _rewardPerToken(pool, rewardData[pool][rewarder][rewardsToken]);
    }

    function _rewardPerToken(IERC20 pool, Reward storage data) private view returns (uint256) {
        if (_totalSupply[pool] == 0) {
            return data.rewardPerTokenStored;
        }
        uint256 unrewardedDuration = _lastTimeRewardApplicable(data) - data.lastUpdateTime;

        return data.rewardPerTokenStored.add(Math.mul(unrewardedDuration, data.rewardRate).divDown(_totalSupply[pool]));
    }

    function unaccountedForUnpaidRewards(
        IERC20 pool,
        address rewarder,
        address account,
        IERC20 rewardsToken
    ) public view returns (uint256) {
        return
            _balances[pool][account].mulDown(
                rewardPerToken(pool, rewarder, rewardsToken).sub(
                    userRewardPerTokenPaid[pool][rewarder][account][rewardsToken]
                )
            );
    }

    function _unaccountedForUnpaidRewards(
        IERC20 pool,
        address rewarder,
        address account,
        IERC20 rewardsToken,
        Reward storage data
    ) private view returns (uint256) {
        return
            _balances[pool][account].mulDown(
                _rewardPerToken(pool, data).sub(userRewardPerTokenPaid[pool][rewarder][account][rewardsToken])
            );
    }

    function totalEarned(
        IERC20 pool,
        address account,
        IERC20 rewardsToken
    ) public view returns (uint256 total) {
        uint256 rewardersLength = _rewarders[pool][rewardsToken].length();
        for (uint256 r; r < rewardersLength; r++) {
            total = total.add(
                unaccountedForUnpaidRewards(pool, _rewarders[pool][rewardsToken].unchecked_at(r), account, rewardsToken)
            );
        }
        total = total.add(unpaidRewards[pool][account][rewardsToken]);
    }

    function stake(IERC20 pool, uint256 amount) external nonReentrant {
        _stakeFor(pool, amount, msg.sender, msg.sender);
    }

    function stakeFor(
        IERC20 pool,
        uint256 amount,
        address receiver
    ) external nonReentrant {
        _stakeFor(pool, amount, msg.sender, receiver);
    }

    function _stakeFor(
        IERC20 pool,
        uint256 amount,
        address account,
        address receiver
    ) internal updateReward(pool, receiver) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply[pool] = _totalSupply[pool].add(amount);
        _balances[pool][receiver] = _balances[pool][receiver].add(amount);
        pool.safeTransferFrom(account, address(this), amount);
        emit Staked(address(pool), receiver, amount);
    }

    function stakeWithPermit(
        IERC20 pool,
        uint256 amount,
        uint256 deadline,
        address account,
        address recipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(account == recipient, "The recipient must match the account in the permit signature");
        IERC20Permit(address(pool)).permit(account, address(this), amount, deadline, v, r, s);
        _stakeFor(pool, amount, account, recipient);
    }

    function unstake(
        IERC20 pool,
        uint256 amount,
        address receiver
    ) public nonReentrant updateReward(pool, msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply[pool] = _totalSupply[pool].sub(amount);
        _balances[pool][msg.sender] = _balances[pool][msg.sender].sub(amount);
        pool.safeTransfer(receiver, amount);
        emit Withdrawn(address(pool), receiver, amount);
    }

    function getReward(IERC20[] calldata pools) external nonReentrant {
        _getReward(pools, msg.sender, false);
    }

    function getRewardAsInternalBalance(IERC20[] calldata pools) external nonReentrant {
        _getReward(pools, msg.sender, true);
    }

    function _rewardOpsCount(IERC20[] calldata pools) internal view returns (uint256 opsCount) {
        for (uint256 p; p < pools.length; p++) {
            IERC20 pool = pools[p];
            uint256 rewardTokensLength = _rewardTokens[pool].length();
            opsCount += rewardTokensLength;
        }
    }

    function _getReward(
        IERC20[] calldata pools,
        address recipient,
        bool asInternalBalance
    ) internal {
        IVault.UserBalanceOpKind kind = asInternalBalance
            ? IVault.UserBalanceOpKind.TRANSFER_INTERNAL
            : IVault.UserBalanceOpKind.WITHDRAW_INTERNAL;

        IVault.UserBalanceOp[] memory ops = new IVault.UserBalanceOp[](_rewardOpsCount(pools));

        uint256 idx;
        for (uint256 p; p < pools.length; p++) {
            IERC20 pool = pools[p];

            uint256 tokensLength = _rewardTokens[pool].length();
            for (uint256 t; t < tokensLength; t++) {
                IERC20 rewardsToken = IERC20(_rewardTokens[pool].unchecked_at(t));

                _updateReward(pool, msg.sender, rewardsToken);
                uint256 reward = unpaidRewards[pool][msg.sender][rewardsToken];

                if (reward > 0) {
                    unpaidRewards[pool][msg.sender][rewardsToken] = 0;

                    emit RewardPaid(msg.sender, address(rewardsToken), reward);
                }

                ops[idx] = IVault.UserBalanceOp({
                    asset: IAsset(address(rewardsToken)),
                    amount: reward,
                    sender: address(this),
                    recipient: payable(recipient),
                    kind: kind
                });
                idx++;
            }
        }
        getVault().manageUserBalance(ops);
    }

    function getRewardWithCallback(
        IERC20[] calldata pools,
        IDistributorCallback callbackContract,
        bytes calldata callbackData
    ) external nonReentrant {
        _getReward(pools, address(callbackContract), true);

        callbackContract.distributorCallback(callbackData);
    }

    function exit(IERC20[] calldata pools) external {
        for (uint256 p; p < pools.length; p++) {
            IERC20 pool = pools[p];
            unstake(pool, _balances[pool][msg.sender], msg.sender);
        }
        _getReward(pools, msg.sender, false);
    }

    function exitWithCallback(
        IERC20[] calldata pools,
        IDistributorCallback callbackContract,
        bytes calldata callbackData
    ) external {
        for (uint256 p; p < pools.length; p++) {
            IERC20 pool = pools[p];
            unstake(pool, _balances[pool][msg.sender], address(callbackContract));
        }
        _getReward(pools, msg.sender, false);
        callbackContract.distributorCallback(callbackData);
    }


    function notifyRewardAmount(
        IERC20 pool,
        IERC20 rewardsToken,
        uint256 reward,
        address rewarder
    ) external override updateReward(pool, address(0)) {
        require(
            msg.sender == rewarder || msg.sender == address(rewardsScheduler),
            "Rewarder must be sender, or rewards scheduler"
        );

        require(_rewarders[pool][rewardsToken].contains(rewarder), "Reward must be configured with addReward");

        rewardsToken.safeTransferFrom(msg.sender, address(this), reward);

        IVault.UserBalanceOp[] memory ops = new IVault.UserBalanceOp[](1);

        ops[0] = IVault.UserBalanceOp({
            asset: IAsset(address(rewardsToken)),
            amount: reward,
            sender: address(this),
            recipient: payable(address(this)),
            kind: IVault.UserBalanceOpKind.DEPOSIT_INTERNAL
        });

        getVault().manageUserBalance(ops);

        Reward storage data = rewardData[pool][rewarder][rewardsToken];

        uint256 periodFinish = data.periodFinish;
        uint256 rewardsDuration = data.rewardsDuration;

        if (block.timestamp >= periodFinish) {
            data.rewardRate = Math.divDown(reward, rewardsDuration);
        } else {
            uint256 remainingTime = periodFinish - block.timestamp; // Checked arithmetic is not required due to the if
            uint256 leftoverRewards = Math.mul(remainingTime, data.rewardRate);
            data.rewardRate = Math.divDown(reward.add(leftoverRewards), rewardsDuration);
        }

        data.lastUpdateTime = block.timestamp;
        data.periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(address(pool), address(rewardsToken), rewarder, reward);
    }

    function setRewardsDuration(
        IERC20 pool,
        IERC20 rewardsToken,
        uint256 rewardsDuration
    ) external onlyAllowlistedRewarder(pool, rewardsToken) {
        require(_rewarders[pool][rewardsToken].contains(msg.sender), "Reward must be configured with addReward");
        require(
            block.timestamp > rewardData[pool][msg.sender][rewardsToken].periodFinish,
            "Reward period still active"
        );
        require(rewardsDuration > 0, "Reward duration must be non-zero");
        rewardData[pool][msg.sender][rewardsToken].rewardsDuration = rewardsDuration;
        emit RewardsDurationUpdated(
            address(pool),
            address(rewardsToken),
            msg.sender,
            rewardData[pool][msg.sender][rewardsToken].rewardsDuration
        );
    }

    function _updateReward(
        IERC20 pool,
        address account,
        IERC20 token
    ) internal {
        uint256 totalUnpaidRewards;

        EnumerableSet.AddressSet storage rewarders = _rewarders[pool][token];
        uint256 rewardersLength = rewarders.length();

        for (uint256 r; r < rewardersLength; r++) {
            address rewarder = rewarders.unchecked_at(r);
            Reward storage data = rewardData[pool][rewarder][token];

            uint256 perToken = _rewardPerToken(pool, data);
            data.rewardPerTokenStored = perToken;

            data.lastUpdateTime = _lastTimeRewardApplicable(data);
            if (account != address(0)) {
                totalUnpaidRewards = totalUnpaidRewards.add(
                    _unaccountedForUnpaidRewards(pool, rewarder, account, token, data)
                );
                userRewardPerTokenPaid[pool][rewarder][account][token] = perToken;
            }
        }

        unpaidRewards[pool][account][token] = totalUnpaidRewards;
    }

    modifier updateReward(IERC20 pool, address account) {
        uint256 rewardTokensLength = _rewardTokens[pool].length();
        for (uint256 t; t < rewardTokensLength; t++) {
            IERC20 rewardToken = IERC20(_rewardTokens[pool].unchecked_at(t));
            _updateReward(pool, account, rewardToken);
        }
        _;
    }


    event Staked(address indexed pool, address indexed account, uint256 amount);
    event Withdrawn(address indexed pool, address indexed account, uint256 amount);
    event RewardAdded(address indexed pool, address indexed token, address indexed rewarder, uint256 amount);
    event RewardsDurationUpdated(
        address indexed pool,
        address indexed token,
        address indexed rewarder,
        uint256 newDuration
    );
}// MIT


pragma solidity ^0.7.0;


abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        _require(owner() == msg.sender, Errors.CALLER_IS_NOT_OWNER);
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        _require(newOwner != address(0), Errors.NEW_OWNER_IS_ZERO);
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity ^0.7.0;

library MerkleProof {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }

        return computedHash == root;
    }
}// GPL-3.0-or-later







pragma solidity ^0.7.0;

contract MerkleRedeem is IDistributor, Ownable {
    using FixedPoint for uint256;
    using SafeERC20 for IERC20;

    IERC20 public immutable rewardToken;

    mapping(uint256 => bytes32) public weekMerkleRoots;
    mapping(uint256 => mapping(address => bool)) public claimed;

    IVault public immutable vault;

    event RewardAdded(address indexed token, uint256 amount);

    constructor(IVault _vault, IERC20 _rewardToken) {
        vault = _vault;
        rewardToken = _rewardToken;
        _rewardToken.approve(address(_vault), type(uint256).max);
    }

    function _disburse(address recipient, uint256 balance) private {
        if (balance > 0) {
            emit RewardPaid(recipient, address(rewardToken), balance);
            rewardToken.safeTransfer(recipient, balance);
        }
    }

    function _disburseToInternalBalance(address recipient, uint256 balance) private {
        if (balance > 0) {
            IVault.UserBalanceOp[] memory ops = new IVault.UserBalanceOp[](1);

            ops[0] = IVault.UserBalanceOp({
                asset: IAsset(address(rewardToken)),
                amount: balance,
                sender: address(this),
                recipient: payable(recipient),
                kind: IVault.UserBalanceOpKind.DEPOSIT_INTERNAL
            });

            emit RewardPaid(recipient, address(rewardToken), balance);
            vault.manageUserBalance(ops);
        }
    }

    function claimWeek(
        address liquidityProvider,
        uint256 week,
        uint256 claimedBalance,
        bytes32[] memory merkleProof
    ) external {
        require(msg.sender == liquidityProvider, "user must claim own balance");
        require(!claimed[week][liquidityProvider], "cannot claim twice");
        require(verifyClaim(liquidityProvider, week, claimedBalance, merkleProof), "Incorrect merkle proof");

        claimed[week][liquidityProvider] = true;
        _disburse(liquidityProvider, claimedBalance);
    }

    struct Claim {
        uint256 week;
        uint256 balance;
        bytes32[] merkleProof;
    }

    function _processClaims(address liquidityProvider, Claim[] memory claims) internal returns (uint256 totalBalance) {
        Claim memory claim;
        for (uint256 i = 0; i < claims.length; i++) {
            claim = claims[i];

            require(!claimed[claim.week][liquidityProvider], "cannot claim twice");
            require(
                verifyClaim(liquidityProvider, claim.week, claim.balance, claim.merkleProof),
                "Incorrect merkle proof"
            );

            totalBalance = totalBalance.add(claim.balance);
            claimed[claim.week][liquidityProvider] = true;
        }
    }

    function claimWeeks(address liquidityProvider, Claim[] memory claims) external {
        require(msg.sender == liquidityProvider, "user must claim own balance");

        uint256 totalBalance = _processClaims(liquidityProvider, claims);
        _disburse(liquidityProvider, totalBalance);
    }

    function claimWeeksToInternalBalance(address liquidityProvider, Claim[] memory claims) external {
        require(msg.sender == liquidityProvider, "user must claim own balance");

        uint256 totalBalance = _processClaims(liquidityProvider, claims);

        _disburseToInternalBalance(liquidityProvider, totalBalance);
    }

    function claimWeeksWithCallback(
        address liquidityProvider,
        IDistributorCallback callbackContract,
        bytes calldata callbackData,
        Claim[] memory claims
    ) external {
        require(msg.sender == liquidityProvider, "user must claim own balance");
        uint256 totalBalance = _processClaims(liquidityProvider, claims);

        _disburseToInternalBalance(address(callbackContract), totalBalance);

        callbackContract.distributorCallback(callbackData);
    }

    function claimStatus(
        address liquidityProvider,
        uint256 begin,
        uint256 end
    ) external view returns (bool[] memory) {
        require(begin <= end, "weeks must be specified in ascending order");
        uint256 size = 1 + end - begin;
        bool[] memory arr = new bool[](size);
        for (uint256 i = 0; i < size; i++) {
            arr[i] = claimed[begin + i][liquidityProvider];
        }
        return arr;
    }

    function merkleRoots(uint256 begin, uint256 end) external view returns (bytes32[] memory) {
        require(begin <= end, "weeks must be specified in ascending order");
        uint256 size = 1 + end - begin;
        bytes32[] memory arr = new bytes32[](size);
        for (uint256 i = 0; i < size; i++) {
            arr[i] = weekMerkleRoots[begin + i];
        }
        return arr;
    }

    function verifyClaim(
        address liquidityProvider,
        uint256 week,
        uint256 claimedBalance,
        bytes32[] memory merkleProof
    ) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(liquidityProvider, claimedBalance));
        return MerkleProof.verify(merkleProof, weekMerkleRoots[week], leaf);
    }

    function seedAllocations(
        uint256 week,
        bytes32 _merkleRoot,
        uint256 amount
    ) external onlyOwner {
        require(weekMerkleRoots[week] == bytes32(0), "cannot rewrite merkle root");
        weekMerkleRoots[week] = _merkleRoot;
        rewardToken.safeTransferFrom(msg.sender, address(this), amount);
        emit RewardAdded(address(rewardToken), amount);
    }
}// GPL-3.0-or-later







pragma solidity ^0.7.0;

contract MerkleOrchard {
    using SafeERC20 for IERC20;

    mapping(bytes32 => uint256) private _nextDistributionId;
    mapping(bytes32 => mapping(uint256 => bytes32)) private _distributionRoot;
    mapping(bytes32 => mapping(address => mapping(uint256 => uint256))) private _claimedBitmap;
    mapping(bytes32 => uint256) private _remainingBalance;

    event DistributionAdded(
        address indexed distributor,
        IERC20 indexed token,
        uint256 distributionId,
        bytes32 merkleRoot,
        uint256 amount
    );
    event DistributionClaimed(
        address indexed distributor,
        IERC20 indexed token,
        uint256 distributionId,
        address indexed claimer,
        address recipient,
        uint256 amount
    );

    IVault private immutable _vault;

    constructor(IVault vault) {
        _vault = vault;
    }

    struct Claim {
        uint256 distributionId;
        uint256 balance;
        address distributor;
        uint256 tokenIndex;
        bytes32[] merkleProof;
    }

    function getVault() public view returns (IVault) {
        return _vault;
    }

    function getDistributionRoot(
        IERC20 token,
        address distributor,
        uint256 distributionId
    ) external view returns (bytes32) {
        bytes32 channelId = _getChannelId(token, distributor);
        return _distributionRoot[channelId][distributionId];
    }

    function getRemainingBalance(IERC20 token, address distributor) external view returns (uint256) {
        bytes32 channelId = _getChannelId(token, distributor);
        return _remainingBalance[channelId];
    }

    function getNextDistributionId(IERC20 token, address distributor) external view returns (uint256) {
        bytes32 channelId = _getChannelId(token, distributor);
        return _nextDistributionId[channelId];
    }

    function isClaimed(
        IERC20 token,
        address distributor,
        uint256 distributionId,
        address claimer
    ) public view returns (bool) {
        (uint256 distributionWordIndex, uint256 distributionBitIndex) = _getIndices(distributionId);

        bytes32 channelId = _getChannelId(token, distributor);
        return (_claimedBitmap[channelId][claimer][distributionWordIndex] & (1 << distributionBitIndex)) != 0;
    }

    function verifyClaim(
        IERC20 token,
        address distributor,
        uint256 distributionId,
        address claimer,
        uint256 claimedBalance,
        bytes32[] memory merkleProof
    ) external view returns (bool) {
        bytes32 channelId = _getChannelId(token, distributor);
        return _verifyClaim(channelId, distributionId, claimer, claimedBalance, merkleProof);
    }


    function claimDistributions(
        address claimer,
        Claim[] memory claims,
        IERC20[] memory tokens
    ) external {
        require(msg.sender == claimer, "user must claim own balance");

        _processClaims(claimer, msg.sender, claims, tokens, false);
    }

    function claimDistributionsToInternalBalance(
        address claimer,
        Claim[] memory claims,
        IERC20[] memory tokens
    ) external {
        require(msg.sender == claimer, "user must claim own balance");

        _processClaims(claimer, msg.sender, claims, tokens, true);
    }

    function claimDistributionsWithCallback(
        address claimer,
        Claim[] memory claims,
        IERC20[] memory tokens,
        IDistributorCallback callbackContract,
        bytes calldata callbackData
    ) external {
        require(msg.sender == claimer, "user must claim own balance");
        _processClaims(claimer, address(callbackContract), claims, tokens, true);
        callbackContract.distributorCallback(callbackData);
    }

    function createDistribution(
        IERC20 token,
        bytes32 merkleRoot,
        uint256 amount,
        uint256 distributionId
    ) external {
        bytes32 channelId = _getChannelId(token, msg.sender);
        require(
            _nextDistributionId[channelId] == distributionId || _nextDistributionId[channelId] == 0,
            "invalid distribution ID"
        );
        token.safeTransferFrom(msg.sender, address(this), amount);

        token.approve(address(getVault()), amount);
        IVault.UserBalanceOp[] memory ops = new IVault.UserBalanceOp[](1);

        ops[0] = IVault.UserBalanceOp({
            asset: IAsset(address(token)),
            amount: amount,
            sender: address(this),
            recipient: payable(address(this)),
            kind: IVault.UserBalanceOpKind.DEPOSIT_INTERNAL
        });

        getVault().manageUserBalance(ops);

        _remainingBalance[channelId] += amount;
        _distributionRoot[channelId][distributionId] = merkleRoot;
        _nextDistributionId[channelId] = distributionId + 1;
        emit DistributionAdded(msg.sender, token, distributionId, merkleRoot, amount);
    }


    function _getChannelId(IERC20 token, address distributor) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(token, distributor));
    }

    function _processClaims(
        address claimer,
        address recipient,
        Claim[] memory claims,
        IERC20[] memory tokens,
        bool asInternalBalance
    ) internal {
        uint256[] memory amounts = new uint256[](tokens.length);


        bytes32 currentChannelId; // Since channel ids are a hash, the initial zero id can be safely considered invalid
        uint256 currentWordIndex;

        uint256 currentBits; // The accumulated claimed bits to set in storage
        uint256 currentClaimAmount; // The accumulated tokens to be claimed from the current channel (not claims set!)

        Claim memory claim;
        for (uint256 i = 0; i < claims.length; i++) {
            claim = claims[i];

            {
                (uint256 distributionWordIndex, uint256 distributionBitIndex) = _getIndices(claim.distributionId);

                if (currentChannelId == _getChannelId(tokens[claim.tokenIndex], claim.distributor)) {
                    if (currentWordIndex == distributionWordIndex) {
                        currentBits |= 1 << distributionBitIndex;
                    } else {
                        _setClaimedBits(currentChannelId, claimer, currentWordIndex, currentBits);

                        currentWordIndex = distributionWordIndex;
                        currentBits = 1 << distributionBitIndex;
                    }

                    currentClaimAmount += claim.balance;
                } else {
                    if (currentChannelId != bytes32(0)) {
                        _setClaimedBits(currentChannelId, claimer, currentWordIndex, currentBits);
                        _deductClaimedBalance(currentChannelId, currentClaimAmount);
                    }

                    currentChannelId = _getChannelId(tokens[claim.tokenIndex], claim.distributor);
                    currentWordIndex = distributionWordIndex;
                    currentBits = 1 << distributionBitIndex;
                    currentClaimAmount = claim.balance;
                }
            }

            if (i == claims.length - 1) {
                _setClaimedBits(currentChannelId, claimer, currentWordIndex, currentBits);
                _deductClaimedBalance(currentChannelId, currentClaimAmount);
            }

            require(
                _verifyClaim(currentChannelId, claim.distributionId, claimer, claim.balance, claim.merkleProof),
                "incorrect merkle proof"
            );

            amounts[claim.tokenIndex] += claim.balance;

            emit DistributionClaimed(
                claim.distributor,
                tokens[claim.tokenIndex],
                claim.distributionId,
                claimer,
                recipient,
                claim.balance
            );
        }

        IVault.UserBalanceOpKind kind = asInternalBalance
            ? IVault.UserBalanceOpKind.TRANSFER_INTERNAL
            : IVault.UserBalanceOpKind.WITHDRAW_INTERNAL;
        IVault.UserBalanceOp[] memory ops = new IVault.UserBalanceOp[](tokens.length);

        for (uint256 i = 0; i < tokens.length; i++) {
            ops[i] = IVault.UserBalanceOp({
                asset: IAsset(address(tokens[i])),
                amount: amounts[i],
                sender: address(this),
                recipient: payable(recipient),
                kind: kind
            });
        }
        getVault().manageUserBalance(ops);
    }

    function _setClaimedBits(
        bytes32 channelId,
        address claimer,
        uint256 wordIndex,
        uint256 newClaimsBitmap
    ) private {
        uint256 currentBitmap = _claimedBitmap[channelId][claimer][wordIndex];

        require((newClaimsBitmap & currentBitmap) == 0, "cannot claim twice");

        _claimedBitmap[channelId][claimer][wordIndex] = currentBitmap | newClaimsBitmap;
    }

    function _deductClaimedBalance(bytes32 channelId, uint256 balanceBeingClaimed) private {
        require(
            _remainingBalance[channelId] >= balanceBeingClaimed,
            "distributor hasn't provided sufficient tokens for claim"
        );
        _remainingBalance[channelId] -= balanceBeingClaimed;
    }

    function _verifyClaim(
        bytes32 channelId,
        uint256 distributionId,
        address claimer,
        uint256 claimedBalance,
        bytes32[] memory merkleProof
    ) internal view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(claimer, claimedBalance));
        return MerkleProof.verify(merkleProof, _distributionRoot[channelId][distributionId], leaf);
    }

    function _getIndices(uint256 distributionId)
        private
        pure
        returns (uint256 distributionWordIndex, uint256 distributionBitIndex)
    {
        distributionWordIndex = distributionId / 256;
        distributionBitIndex = distributionId % 256;
    }
}