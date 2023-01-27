


pragma solidity ^0.7.0;

interface IAuthentication {

    function getActionId(bytes4 selector) external view returns (bytes32);

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
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IAuthorizer {

    function canPerform(
        bytes32 actionId,
        address account,
        address where
    ) external view returns (bool);

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


interface IFeeDistributor {

    event TokenCheckpointed(IERC20 token, uint256 amount, uint256 lastCheckpointTimestamp);
    event TokensClaimed(address user, IERC20 token, uint256 amount, uint256 userTokenTimeCursor);

    function getVotingEscrow() external view returns (IVotingEscrow);


    function getTimeCursor() external view returns (uint256);


    function getUserTimeCursor(address user) external view returns (uint256);


    function getTokenTimeCursor(IERC20 token) external view returns (uint256);


    function getUserTokenTimeCursor(address user, IERC20 token) external view returns (uint256);


    function getUserBalanceAtTimestamp(address user, uint256 timestamp) external view returns (uint256);


    function getTotalSupplyAtTimestamp(uint256 timestamp) external view returns (uint256);


    function getTokenLastBalance(IERC20 token) external view returns (uint256);


    function getTokensDistributedInWeek(IERC20 token, uint256 timestamp) external view returns (uint256);



    function depositToken(IERC20 token, uint256 amount) external;



    function depositTokens(IERC20[] calldata tokens, uint256[] calldata amounts) external;



    function checkpoint() external;


    function checkpointUser(address user) external;


    function checkpointToken(IERC20 token) external;


    function checkpointTokens(IERC20[] calldata tokens) external;



    function claimToken(address user, IERC20 token) external returns (uint256);


    function claimTokens(address user, IERC20[] calldata tokens) external returns (uint256[] memory);

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

    function abs(int256 a) internal pure returns (uint256) {

        return a > 0 ? uint256(a) : uint256(-a);
    }

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
}// GPL-3.0-or-later



pragma solidity ^0.7.0;




contract FeeDistributor is IFeeDistributor, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IVotingEscrow private immutable _votingEscrow;

    uint256 private immutable _startTime;

    uint256 private _timeCursor;
    mapping(uint256 => uint256) private _veSupplyCache;


    struct TokenState {
        uint64 startTime;
        uint64 timeCursor;
        uint128 cachedBalance;
    }
    mapping(IERC20 => TokenState) private _tokenState;
    mapping(IERC20 => mapping(uint256 => uint256)) private _tokensPerWeek;


    struct UserState {
        uint64 startTime;
        uint64 timeCursor;
        uint128 lastEpochCheckpointed;
    }
    mapping(address => UserState) private _userState;
    mapping(address => mapping(uint256 => uint256)) private _userBalanceAtTimestamp;
    mapping(address => mapping(IERC20 => uint256)) private _userTokenTimeCursor;

    constructor(IVotingEscrow votingEscrow, uint256 startTime) {
        _votingEscrow = votingEscrow;

        startTime = _roundDownTimestamp(startTime);
        uint256 currentWeek = _roundDownTimestamp(block.timestamp);
        require(startTime >= currentWeek, "Cannot start before current week");
        if (startTime == currentWeek) {
            require(votingEscrow.totalSupply(currentWeek) > 0, "Zero total supply results in lost tokens");
        }
        _startTime = startTime;
        _timeCursor = startTime;
    }

    function getVotingEscrow() external view override returns (IVotingEscrow) {

        return _votingEscrow;
    }

    function getTimeCursor() external view override returns (uint256) {

        return _timeCursor;
    }

    function getUserTimeCursor(address user) external view override returns (uint256) {

        return _userState[user].timeCursor;
    }

    function getTokenTimeCursor(IERC20 token) external view override returns (uint256) {

        return _tokenState[token].timeCursor;
    }

    function getUserTokenTimeCursor(address user, IERC20 token) external view override returns (uint256) {

        return _getUserTokenTimeCursor(user, token);
    }

    function getUserBalanceAtTimestamp(address user, uint256 timestamp) external view override returns (uint256) {

        return _userBalanceAtTimestamp[user][timestamp];
    }

    function getTotalSupplyAtTimestamp(uint256 timestamp) external view override returns (uint256) {

        return _veSupplyCache[timestamp];
    }

    function getTokenLastBalance(IERC20 token) external view override returns (uint256) {

        return _tokenState[token].cachedBalance;
    }

    function getTokensDistributedInWeek(IERC20 token, uint256 timestamp) external view override returns (uint256) {

        return _tokensPerWeek[token][timestamp];
    }


    function depositToken(IERC20 token, uint256 amount) external override nonReentrant {

        _checkpointToken(token, false);
        token.safeTransferFrom(msg.sender, address(this), amount);
        _checkpointToken(token, true);
    }

    function depositTokens(IERC20[] calldata tokens, uint256[] calldata amounts) external override nonReentrant {

        InputHelpers.ensureInputLengthMatch(tokens.length, amounts.length);

        uint256 length = tokens.length;
        for (uint256 i = 0; i < length; ++i) {
            _checkpointToken(tokens[i], false);
            tokens[i].safeTransferFrom(msg.sender, address(this), amounts[i]);
            _checkpointToken(tokens[i], true);
        }
    }


    function checkpoint() external override nonReentrant {

        _checkpointTotalSupply();
    }

    function checkpointUser(address user) external override nonReentrant {

        _checkpointUserBalance(user);
    }

    function checkpointToken(IERC20 token) external override nonReentrant {

        _checkpointToken(token, true);
    }

    function checkpointTokens(IERC20[] calldata tokens) external override nonReentrant {

        uint256 tokensLength = tokens.length;
        for (uint256 i = 0; i < tokensLength; ++i) {
            _checkpointToken(tokens[i], true);
        }
    }


    function claimToken(address user, IERC20 token) external override nonReentrant returns (uint256) {

        _checkpointTotalSupply();
        _checkpointToken(token, false);
        _checkpointUserBalance(user);

        uint256 amount = _claimToken(user, token);
        return amount;
    }

    function claimTokens(address user, IERC20[] calldata tokens)
        external
        override
        nonReentrant
        returns (uint256[] memory)
    {

        require(block.timestamp > _startTime, "Fee distribution has not started yet");
        _checkpointTotalSupply();
        _checkpointUserBalance(user);

        uint256 tokensLength = tokens.length;
        uint256[] memory amounts = new uint256[](tokensLength);
        for (uint256 i = 0; i < tokensLength; ++i) {
            _checkpointToken(tokens[i], false);
            amounts[i] = _claimToken(user, tokens[i]);
        }

        return amounts;
    }


    function _claimToken(address user, IERC20 token) internal returns (uint256) {

        TokenState storage tokenState = _tokenState[token];
        uint256 userTimeCursor = _getUserTokenTimeCursor(user, token);
        uint256 currentActiveWeek = _roundDownTimestamp(tokenState.timeCursor);
        mapping(uint256 => uint256) storage tokensPerWeek = _tokensPerWeek[token];
        mapping(uint256 => uint256) storage userBalanceAtTimestamp = _userBalanceAtTimestamp[user];

        uint256 amount;
        for (uint256 i = 0; i < 20; ++i) {
            if (userTimeCursor >= currentActiveWeek) break;

            amount +=
                (tokensPerWeek[userTimeCursor] * userBalanceAtTimestamp[userTimeCursor]) /
                _veSupplyCache[userTimeCursor];
            userTimeCursor += 1 weeks;
        }
        _userTokenTimeCursor[user][token] = userTimeCursor;

        if (amount > 0) {
            tokenState.cachedBalance = uint128(tokenState.cachedBalance - amount);
            token.safeTransfer(user, amount);
            emit TokensClaimed(user, token, amount, userTimeCursor);
        }

        return amount;
    }

    function _checkpointToken(IERC20 token, bool force) internal {

        TokenState storage tokenState = _tokenState[token];
        uint256 lastTokenTime = tokenState.timeCursor;
        uint256 timeSinceLastCheckpoint;
        if (lastTokenTime == 0) {
            lastTokenTime = block.timestamp;
            tokenState.startTime = uint64(_roundDownTimestamp(block.timestamp));

            require(block.timestamp > _startTime, "Fee distribution has not started yet");
        } else {
            timeSinceLastCheckpoint = block.timestamp - lastTokenTime;

            if (!force) {

                bool alreadyCheckpointedThisWeek = _roundDownTimestamp(block.timestamp) ==
                    _roundDownTimestamp(lastTokenTime);
                bool nearingEndOfWeek = _roundUpTimestamp(block.timestamp) - block.timestamp < 1 days;

                if (alreadyCheckpointedThisWeek && !nearingEndOfWeek) {
                    return;
                }
            }
        }

        tokenState.timeCursor = uint64(block.timestamp);

        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 tokensToDistribute = tokenBalance.sub(tokenState.cachedBalance);
        if (tokensToDistribute == 0) return;
        require(tokenBalance <= type(uint128).max, "Maximum token balance exceeded");
        tokenState.cachedBalance = uint128(tokenBalance);

        uint256 thisWeek = _roundDownTimestamp(lastTokenTime);
        uint256 nextWeek = 0;

        mapping(uint256 => uint256) storage tokensPerWeek = _tokensPerWeek[token];
        for (uint256 i = 0; i < 20; ++i) {
            nextWeek = thisWeek + 1 weeks;
            if (block.timestamp < nextWeek) {
                if (timeSinceLastCheckpoint == 0 && block.timestamp == lastTokenTime) {
                    tokensPerWeek[thisWeek] += tokensToDistribute;
                } else {
                    tokensPerWeek[thisWeek] +=
                        (tokensToDistribute * (block.timestamp - lastTokenTime)) /
                        timeSinceLastCheckpoint;
                }
                break;
            } else {
                if (timeSinceLastCheckpoint == 0 && nextWeek == lastTokenTime) {
                    tokensPerWeek[thisWeek] += tokensToDistribute;
                } else {
                    tokensPerWeek[thisWeek] +=
                        (tokensToDistribute * (nextWeek - lastTokenTime)) /
                        timeSinceLastCheckpoint;
                }
            }

            lastTokenTime = nextWeek;
            thisWeek = nextWeek;
        }

        emit TokenCheckpointed(token, tokensToDistribute, lastTokenTime);
    }

    function _checkpointUserBalance(address user) internal {

        uint256 maxUserEpoch = _votingEscrow.user_point_epoch(user);

        if (maxUserEpoch == 0) return;

        UserState storage userState = _userState[user];

        uint256 weekCursor = userState.timeCursor;

        uint256 userEpoch;
        if (weekCursor == 0) {
            userEpoch = _findTimestampUserEpoch(user, _startTime, maxUserEpoch);
        } else {
            if (weekCursor == _roundDownTimestamp(block.timestamp)) {
                return;
            }
            userEpoch = userState.lastEpochCheckpointed;
        }

        if (userEpoch == 0) {
            userEpoch = 1;
        }

        IVotingEscrow.Point memory userPoint = _votingEscrow.user_point_history(user, userEpoch);

        if (weekCursor == 0) {
            weekCursor = Math.max(_startTime, _roundUpTimestamp(userPoint.ts));
            userState.startTime = uint64(weekCursor);
        }

        IVotingEscrow.Point memory oldUserPoint;
        for (uint256 i = 0; i < 50; ++i) {
            if (weekCursor > block.timestamp) {
                break;
            }

            if (weekCursor >= userPoint.ts && userEpoch <= maxUserEpoch) {
                userEpoch += 1;
                oldUserPoint = userPoint;
                if (userEpoch > maxUserEpoch) {
                    userPoint = IVotingEscrow.Point(0, 0, 0, 0);
                } else {
                    userPoint = _votingEscrow.user_point_history(user, userEpoch);
                }
            } else {

                int128 dt = int128(weekCursor - oldUserPoint.ts);
                uint256 userBalance = oldUserPoint.bias > oldUserPoint.slope * dt
                    ? uint256(oldUserPoint.bias - oldUserPoint.slope * dt)
                    : 0;

                if (userBalance == 0 && userEpoch > maxUserEpoch) {
                    weekCursor = _roundUpTimestamp(block.timestamp);
                    break;
                }

                _userBalanceAtTimestamp[user][weekCursor] = userBalance;

                weekCursor += 1 weeks;
            }
        }

        userState.lastEpochCheckpointed = uint64(userEpoch - 1);
        userState.timeCursor = uint64(weekCursor);
    }

    function _checkpointTotalSupply() internal {

        uint256 timeCursor = _timeCursor;
        uint256 weekStart = _roundDownTimestamp(block.timestamp);

        if (timeCursor > weekStart) {
            return;
        }

        _votingEscrow.checkpoint();

        for (uint256 i = 0; i < 20; ++i) {
            if (timeCursor > weekStart) break;

            _veSupplyCache[timeCursor] = _votingEscrow.totalSupply(timeCursor);

            timeCursor += 1 weeks;
        }
        _timeCursor = timeCursor;
    }


    function _getUserTokenTimeCursor(address user, IERC20 token) internal view returns (uint256) {

        uint256 userTimeCursor = _userTokenTimeCursor[user][token];
        if (userTimeCursor > 0) return userTimeCursor;
        return Math.max(_userState[user].startTime, _tokenState[token].startTime);
    }

    function _findTimestampUserEpoch(
        address user,
        uint256 timestamp,
        uint256 maxUserEpoch
    ) internal view returns (uint256) {

        uint256 min = 0;
        uint256 max = maxUserEpoch;

        for (uint256 i = 0; i < 128; ++i) {
            if (min >= max) break;

            uint256 mid = (min + max + 2) / 2;
            IVotingEscrow.Point memory pt = _votingEscrow.user_point_history(user, mid);
            if (pt.ts <= timestamp) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min;
    }

    function _roundDownTimestamp(uint256 timestamp) private pure returns (uint256) {

        return (timestamp / 1 weeks) * 1 weeks;
    }

    function _roundUpTimestamp(uint256 timestamp) private pure returns (uint256) {

        return _roundDownTimestamp(timestamp + 1 weeks - 1);
    }
}