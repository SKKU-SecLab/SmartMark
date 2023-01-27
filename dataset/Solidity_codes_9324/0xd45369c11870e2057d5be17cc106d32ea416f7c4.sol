


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



abstract contract AssetHelpers {
    IWETH private immutable _weth;

    address private constant _ETH = address(0);

    constructor(IWETH weth) {
        _weth = weth;
    }

    function _WETH() internal view returns (IWETH) {
        return _weth;
    }

    function _isETH(IAsset asset) internal pure returns (bool) {
        return address(asset) == _ETH;
    }

    function _translateToIERC20(IAsset asset) internal view returns (IERC20) {
        return _isETH(asset) ? _WETH() : _asIERC20(asset);
    }

    function _translateToIERC20(IAsset[] memory assets) internal view returns (IERC20[] memory) {
        IERC20[] memory tokens = new IERC20[](assets.length);
        for (uint256 i = 0; i < assets.length; ++i) {
            tokens[i] = _translateToIERC20(assets[i]);
        }
        return tokens;
    }

    function _asIERC20(IAsset asset) internal pure returns (IERC20) {
        return IERC20(address(asset));
    }
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


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        _require(address(this).balance >= amount, Errors.ADDRESS_INSUFFICIENT_BALANCE);

        (bool success, ) = recipient.call{ value: amount }("");
        _require(success, Errors.ADDRESS_CANNOT_SEND_VALUE);
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        (bool success, bytes memory returndata) = target.call(data);
        return verifyCallResult(success, returndata);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata);
    }

    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                _revert(Errors.LOW_LEVEL_CALL_FAILED);
            }
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



interface IBalancerRelayer {

    function getLibrary() external view returns (address);


    function getVault() external view returns (IVault);


    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract IBaseRelayerLibrary is AssetHelpers {
    constructor(IWETH weth) AssetHelpers(weth) {
    }

    function getVault() public view virtual returns (IVault);

    function approveVault(IERC20 token, uint256 amount) public virtual;

    function _pullToken(
        address sender,
        IERC20 token,
        uint256 amount
    ) internal virtual;

    function _pullTokens(
        address sender,
        IERC20[] memory tokens,
        uint256[] memory amounts
    ) internal virtual;

    function _isChainedReference(uint256 amount) internal pure virtual returns (bool);

    function _setChainedReferenceValue(uint256 ref, uint256 value) internal virtual;

    function _getChainedReferenceValue(uint256 ref) internal virtual returns (uint256);
}// MIT

pragma solidity ^0.7.0;

interface IERC20PermitDAI {

    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// GPL-3.0-or-later



pragma solidity ^0.7.0;



abstract contract VaultPermit is IBaseRelayerLibrary {
    function vaultPermit(
        IERC20Permit token,
        address owner,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        token.permit(owner, address(getVault()), value, deadline, v, r, s);
    }

    function vaultPermitDAI(
        IERC20PermitDAI token,
        address holder,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public payable {
        token.permit(holder, address(getVault()), nonce, expiry, allowed, v, r, s);
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



interface IstETH is IERC20 {

    function submit(address referral) external payable returns (uint256);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;




interface IwstETH is IERC20 {

    function stETH() external returns (IstETH);


    function wrap(uint256 _stETHAmount) external returns (uint256);


    function unwrap(uint256 _wstETHAmount) external returns (uint256);


    function getWstETHByStETH(uint256 _stETHAmount) external view returns (uint256);


    function getStETHByWstETH(uint256 _wstETHAmount) external view returns (uint256);


    function stEthPerToken() external view returns (uint256);


    function tokensPerStEth() external view returns (uint256);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;




abstract contract LidoWrapping is IBaseRelayerLibrary {
    using Address for address payable;

    IstETH private immutable _stETH;
    IwstETH private immutable _wstETH;

    constructor(IERC20 wstETH) {
        _stETH = wstETH != IERC20(0) ? IwstETH(address(wstETH)).stETH() : IstETH(0);
        _wstETH = IwstETH(address(wstETH));
    }

    function wrapStETH(
        address sender,
        address recipient,
        uint256 amount,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        if (sender != address(this)) {
            require(sender == msg.sender, "Incorrect sender");
            _pullToken(sender, _stETH, amount);
        }

        _stETH.approve(address(_wstETH), amount);
        uint256 result = IwstETH(_wstETH).wrap(amount);

        if (recipient != address(this)) {
            _wstETH.transfer(recipient, result);
        }

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }
    }

    function unwrapWstETH(
        address sender,
        address recipient,
        uint256 amount,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        if (sender != address(this)) {
            require(sender == msg.sender, "Incorrect sender");
            _pullToken(sender, _wstETH, amount);
        }

        uint256 result = _wstETH.unwrap(amount);

        if (recipient != address(this)) {
            _stETH.transfer(recipient, result);
        }

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }
    }

    function stakeETH(
        address recipient,
        uint256 amount,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        uint256 result = _stETH.submit{ value: amount }(address(this));

        if (recipient != address(this)) {
            _stETH.transfer(recipient, result);
        }

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }
    }

    function stakeETHAndWrap(
        address recipient,
        uint256 amount,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        uint256 result = _wstETH.getWstETHByStETH(amount);

        payable(address(_wstETH)).sendValue(amount);

        if (recipient != address(this)) {
            _wstETH.transfer(recipient, result);
        }

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

interface IButtonWrapper {


    function mint(uint256 amount) external returns (uint256);


    function mintFor(address to, uint256 amount) external returns (uint256);


    function burn(uint256 amount) external returns (uint256);


    function burnTo(address to, uint256 amount) external returns (uint256);


    function burnAll() external returns (uint256);


    function burnAllTo(address to) external returns (uint256);


    function deposit(uint256 uAmount) external returns (uint256);


    function depositFor(address to, uint256 uAmount) external returns (uint256);


    function withdraw(uint256 uAmount) external returns (uint256);


    function withdrawTo(address to, uint256 uAmount) external returns (uint256);


    function withdrawAll() external returns (uint256);


    function withdrawAllTo(address to) external returns (uint256);



    function underlying() external view returns (address);


    function totalUnderlying() external view returns (uint256);


    function balanceOfUnderlying(address who) external view returns (uint256);


    function underlyingToWrapper(uint256 uAmount) external view returns (uint256);


    function wrapperToUnderlying(uint256 amount) external view returns (uint256);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;



interface IUnbuttonToken is IButtonWrapper, IERC20 {

}// GPL-3.0-or-later



pragma solidity ^0.7.0;



abstract contract UnbuttonWrapping is IBaseRelayerLibrary {
    using Address for address payable;

    function wrapUnbuttonToken(
        IUnbuttonToken wrapperToken,
        address sender,
        address recipient,
        uint256 uAmount,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(uAmount)) {
            uAmount = _getChainedReferenceValue(uAmount);
        }

        IERC20 underlyingToken = IERC20(wrapperToken.underlying());

        if (sender != address(this)) {
            require(sender == msg.sender, "Incorrect sender");
            _pullToken(sender, underlyingToken, uAmount);
        }

        underlyingToken.approve(address(wrapperToken), uAmount);
        uint256 mintAmount = wrapperToken.depositFor(recipient, uAmount);

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, mintAmount);
        }
    }

    function unwrapUnbuttonToken(
        IUnbuttonToken wrapperToken,
        address sender,
        address recipient,
        uint256 amount,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        if (sender != address(this)) {
            require(sender == msg.sender, "Incorrect sender");
            _pullToken(sender, wrapperToken, amount);
        }

        uint256 withdrawnUAmount = wrapperToken.burnTo(recipient, amount);

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, withdrawnUAmount);
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract BalancerRelayer is IBalancerRelayer, ReentrancyGuard {

    using Address for address payable;
    using Address for address;

    IVault private immutable _vault;
    address private immutable _library;

    constructor(IVault vault, address libraryAddress) {
        _vault = vault;
        _library = libraryAddress;
    }

    receive() external payable {
        _require(msg.sender == address(_vault), Errors.ETH_TRANSFER);
    }

    function getVault() external view override returns (IVault) {

        return _vault;
    }

    function getLibrary() external view override returns (address) {

        return _library;
    }

    function multicall(bytes[] calldata data) external payable override nonReentrant returns (bytes[] memory results) {

        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = _library.functionDelegateCall(data[i]);
        }

        _refundETH();
    }

    function _refundETH() private {

        uint256 remainingEth = address(this).balance;
        if (remainingEth > 0) {
            msg.sender.sendValue(remainingEth);
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract BaseRelayerLibrary is IBaseRelayerLibrary {

    using Address for address;

    IVault private immutable _vault;
    IBalancerRelayer private immutable _entrypoint;

    constructor(IVault vault) IBaseRelayerLibrary(vault.WETH()) {
        _vault = vault;
        _entrypoint = new BalancerRelayer(vault, address(this));
    }

    function getVault() public view override returns (IVault) {

        return _vault;
    }

    function getEntrypoint() public view returns (IBalancerRelayer) {

        return _entrypoint;
    }

    function setRelayerApproval(
        address relayer,
        bool approved,
        bytes calldata authorisation
    ) external payable {

        require(relayer == address(this) || !approved, "Relayer can only approve itself");
        bytes memory data = abi.encodePacked(
            abi.encodeWithSelector(_vault.setRelayerApproval.selector, msg.sender, relayer, approved),
            authorisation
        );

        address(_vault).functionCall(data);
    }

    function approveVault(IERC20 token, uint256 amount) public override {

        token.approve(address(getVault()), amount);
    }

    function _pullToken(
        address sender,
        IERC20 token,
        uint256 amount
    ) internal override {

        if (amount == 0) return;
        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = token;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        _pullTokens(sender, tokens, amounts);
    }

    function _pullTokens(
        address sender,
        IERC20[] memory tokens,
        uint256[] memory amounts
    ) internal override {

        IVault.UserBalanceOp[] memory ops = new IVault.UserBalanceOp[](tokens.length);
        for (uint256 i; i < tokens.length; i++) {
            ops[i] = IVault.UserBalanceOp({
                asset: IAsset(address(tokens[i])),
                amount: amounts[i],
                sender: sender,
                recipient: payable(address(this)),
                kind: IVault.UserBalanceOpKind.TRANSFER_EXTERNAL
            });
        }

        getVault().manageUserBalance(ops);
    }

    function _isChainedReference(uint256 amount) internal pure override returns (bool) {

        return
            (amount & 0xffff000000000000000000000000000000000000000000000000000000000000) ==
            0xba10000000000000000000000000000000000000000000000000000000000000;
    }

    function _setChainedReferenceValue(uint256 ref, uint256 value) internal override {

        bytes32 slot = _getTempStorageSlot(ref);

        assembly {
            sstore(slot, value)
        }
    }

    function _getChainedReferenceValue(uint256 ref) internal override returns (uint256 value) {

        bytes32 slot = _getTempStorageSlot(ref);

        assembly {
            value := sload(slot)
            sstore(slot, 0)
        }
    }

    bytes32 private immutable _TEMP_STORAGE_SUFFIX = keccak256("balancer.base-relayer-library");

    function _getTempStorageSlot(uint256 ref) private view returns (bytes32) {


        return bytes32(uint256(keccak256(abi.encodePacked(ref, _TEMP_STORAGE_SUFFIX))) - 1);
    }
}// GPL-3.0-or-later
pragma solidity ^0.7.0;



interface IStaticATokenLM is IERC20 {

    struct SignatureParams {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function deposit(
        address recipient,
        uint256 amount,
        uint16 referralCode,
        bool fromUnderlying
    ) external returns (uint256);


    function withdraw(
        address recipient,
        uint256 amount,
        bool toUnderlying
    ) external returns (uint256, uint256);


    function withdrawDynamicAmount(
        address recipient,
        uint256 amount,
        bool toUnderlying
    ) external returns (uint256, uint256);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function metaDeposit(
        address depositor,
        address recipient,
        uint256 value,
        uint16 referralCode,
        bool fromUnderlying,
        uint256 deadline,
        SignatureParams calldata sigParams
    ) external returns (uint256);


    function metaWithdraw(
        address owner,
        address recipient,
        uint256 staticAmount,
        uint256 dynamicAmount,
        bool toUnderlying,
        uint256 deadline,
        SignatureParams calldata sigParams
    ) external returns (uint256, uint256);


    function dynamicBalanceOf(address account) external view returns (uint256);


    function staticToDynamicAmount(uint256 amount) external view returns (uint256);


    function dynamicToStaticAmount(uint256 amount) external view returns (uint256);


    function rate() external view returns (uint256);


    function getDomainSeparator() external view returns (bytes32);


    function collectAndUpdateRewards() external;


    function claimRewardsOnBehalf(
        address onBehalfOf,
        address receiver,
        bool forceUpdate
    ) external;


    function claimRewards(address receiver, bool forceUpdate) external;


    function claimRewardsToSelf(bool forceUpdate) external;


    function getTotalClaimableRewards() external view returns (uint256);


    function getClaimableRewards(address user) external view returns (uint256);


    function getUnclaimedRewards(address user) external view returns (uint256);


    function getAccRewardsPerToken() external view returns (uint256);


    function getLifetimeRewardsClaimed() external view returns (uint256);


    function getLifetimeRewards() external view returns (uint256);


    function getLastRewardBlock() external view returns (uint256);


    function LENDING_POOL() external returns (address);


    function INCENTIVES_CONTROLLER() external returns (address);


    function ATOKEN() external returns (IERC20);


    function ASSET() external returns (IERC20);


    function REWARD_TOKEN() external returns (IERC20);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;




abstract contract AaveWrapping is IBaseRelayerLibrary {
    using Address for address payable;

    function wrapAaveDynamicToken(
        IStaticATokenLM staticToken,
        address sender,
        address recipient,
        uint256 amount,
        bool fromUnderlying,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        IERC20 dynamicToken = fromUnderlying ? staticToken.ASSET() : staticToken.ATOKEN();

        if (sender != address(this)) {
            require(sender == msg.sender, "Incorrect sender");
            _pullToken(sender, dynamicToken, amount);
        }

        dynamicToken.approve(address(staticToken), amount);
        uint256 result = staticToken.deposit(recipient, amount, 0, fromUnderlying);

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }
    }

    function unwrapAaveStaticToken(
        IStaticATokenLM staticToken,
        address sender,
        address recipient,
        uint256 amount,
        bool toUnderlying,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        if (sender != address(this)) {
            require(sender == msg.sender, "Incorrect sender");
            _pullToken(sender, staticToken, amount);
        }

        (, uint256 result) = staticToken.withdraw(recipient, amount, toUnderlying);

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


interface IERC4626 is IERC20 {

    event Deposit(address indexed sender, address indexed receiver, uint256 assets, uint256 shares);

    event Withdraw(address indexed sender, address indexed receiver, uint256 assets, uint256 shares);

    function deposit(uint256 assets, address receiver) external returns (uint256);


    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256);


    function asset() external view returns (address);


    function totalAssets() external view returns (uint256);

}// GPL-3.0-or-later



pragma solidity ^0.7.0;




abstract contract ERC4626Wrapping is IBaseRelayerLibrary {
    using Address for address payable;

    function wrapERC4626(
        IERC4626 wrappedToken,
        address sender,
        address recipient,
        uint256 amount,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        IERC20 underlying = IERC20(wrappedToken.asset());

        if (sender != address(this)) {
            require(sender == msg.sender, "Incorrect sender");
            _pullToken(sender, underlying, amount);
        }

        underlying.approve(address(wrappedToken), amount);
        uint256 result = wrappedToken.deposit(amount, recipient);

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }
    }

    function unwrapERC4626(
        IERC4626 wrappedToken,
        address sender,
        address recipient,
        uint256 amount,
        uint256 outputReference
    ) external payable {
        if (_isChainedReference(amount)) {
            amount = _getChainedReferenceValue(amount);
        }

        if (sender != address(this)) {
            require(sender == msg.sender, "Incorrect sender");
            _pullToken(sender, wrappedToken, amount);
        }

        uint256 result = wrappedToken.redeem(amount, recipient, address(this));

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;

library VaultHelpers {

    function toPoolAddress(bytes32 poolId) internal pure returns (address) {

        return address(uint256(poolId) >> (12 * 8));
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


library WeightedPoolUserData {

    enum JoinKind { INIT, EXACT_TOKENS_IN_FOR_BPT_OUT, TOKEN_IN_FOR_EXACT_BPT_OUT, ALL_TOKENS_IN_FOR_EXACT_BPT_OUT }
    enum ExitKind {
        EXACT_BPT_IN_FOR_ONE_TOKEN_OUT,
        EXACT_BPT_IN_FOR_TOKENS_OUT,
        BPT_IN_FOR_EXACT_TOKENS_OUT,
        MANAGEMENT_FEE_TOKENS_OUT // for ManagedPool
    }

    function joinKind(bytes memory self) internal pure returns (JoinKind) {

        return abi.decode(self, (JoinKind));
    }

    function exitKind(bytes memory self) internal pure returns (ExitKind) {

        return abi.decode(self, (ExitKind));
    }


    function initialAmountsIn(bytes memory self) internal pure returns (uint256[] memory amountsIn) {

        (, amountsIn) = abi.decode(self, (JoinKind, uint256[]));
    }

    function exactTokensInForBptOut(bytes memory self)
        internal
        pure
        returns (uint256[] memory amountsIn, uint256 minBPTAmountOut)
    {

        (, amountsIn, minBPTAmountOut) = abi.decode(self, (JoinKind, uint256[], uint256));
    }

    function tokenInForExactBptOut(bytes memory self) internal pure returns (uint256 bptAmountOut, uint256 tokenIndex) {

        (, bptAmountOut, tokenIndex) = abi.decode(self, (JoinKind, uint256, uint256));
    }

    function allTokensInForExactBptOut(bytes memory self) internal pure returns (uint256 bptAmountOut) {

        (, bptAmountOut) = abi.decode(self, (JoinKind, uint256));
    }


    function exactBptInForTokenOut(bytes memory self) internal pure returns (uint256 bptAmountIn, uint256 tokenIndex) {

        (, bptAmountIn, tokenIndex) = abi.decode(self, (ExitKind, uint256, uint256));
    }

    function exactBptInForTokensOut(bytes memory self) internal pure returns (uint256 bptAmountIn) {

        (, bptAmountIn) = abi.decode(self, (ExitKind, uint256));
    }

    function bptInForExactTokensOut(bytes memory self)
        internal
        pure
        returns (uint256[] memory amountsOut, uint256 maxBPTAmountIn)
    {

        (, amountsOut, maxBPTAmountIn) = abi.decode(self, (ExitKind, uint256[], uint256));
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;





abstract contract VaultActions is IBaseRelayerLibrary {
    using Math for uint256;

    struct OutputReference {
        uint256 index;
        uint256 key;
    }

    function swap(
        IVault.SingleSwap memory singleSwap,
        IVault.FundManagement calldata funds,
        uint256 limit,
        uint256 deadline,
        uint256 value,
        uint256 outputReference
    ) external payable returns (uint256) {
        require(funds.sender == msg.sender || funds.sender == address(this), "Incorrect sender");

        if (_isChainedReference(singleSwap.amount)) {
            singleSwap.amount = _getChainedReferenceValue(singleSwap.amount);
        }

        uint256 result = getVault().swap{ value: value }(singleSwap, funds, limit, deadline);

        if (_isChainedReference(outputReference)) {
            _setChainedReferenceValue(outputReference, result);
        }

        return result;
    }

    function batchSwap(
        IVault.SwapKind kind,
        IVault.BatchSwapStep[] memory swaps,
        IAsset[] calldata assets,
        IVault.FundManagement calldata funds,
        int256[] calldata limits,
        uint256 deadline,
        uint256 value,
        OutputReference[] calldata outputReferences
    ) external payable returns (int256[] memory) {
        require(funds.sender == msg.sender || funds.sender == address(this), "Incorrect sender");

        for (uint256 i = 0; i < swaps.length; ++i) {
            uint256 amount = swaps[i].amount;
            if (_isChainedReference(amount)) {
                swaps[i].amount = _getChainedReferenceValue(amount);
            }
        }

        int256[] memory results = getVault().batchSwap{ value: value }(kind, swaps, assets, funds, limits, deadline);

        for (uint256 i = 0; i < outputReferences.length; ++i) {
            require(_isChainedReference(outputReferences[i].key), "invalid chained reference");

            _setChainedReferenceValue(outputReferences[i].key, Math.abs(results[outputReferences[i].index]));
        }

        return results;
    }

    function manageUserBalance(IVault.UserBalanceOp[] calldata ops, uint256 value) external payable {
        for (uint256 i = 0; i < ops.length; i++) {
            require(ops[i].sender == msg.sender || ops[i].sender == address(this), "Incorrect sender");
        }
        getVault().manageUserBalance{ value: value }(ops);
    }

    enum PoolKind { WEIGHTED }

    function joinPool(
        bytes32 poolId,
        PoolKind kind,
        address sender,
        address recipient,
        IVault.JoinPoolRequest memory request,
        uint256 value,
        uint256 outputReference
    ) external payable {
        require(sender == msg.sender || sender == address(this), "Incorrect sender");

        IERC20 bpt = IERC20(VaultHelpers.toPoolAddress(poolId));
        uint256 maybeInitialRecipientBPT = _isChainedReference(outputReference) ? bpt.balanceOf(recipient) : 0;

        request.userData = _doJoinPoolChainedReferenceReplacements(kind, request.userData);

        getVault().joinPool{ value: value }(poolId, sender, recipient, request);

        if (_isChainedReference(outputReference)) {
            uint256 finalRecipientBPT = bpt.balanceOf(recipient);
            _setChainedReferenceValue(outputReference, finalRecipientBPT.sub(maybeInitialRecipientBPT));
        }
    }

    function _doJoinPoolChainedReferenceReplacements(PoolKind kind, bytes memory userData)
        private
        returns (bytes memory)
    {
        if (kind == PoolKind.WEIGHTED) {
            return _doWeightedJoinChainedReferenceReplacements(userData);
        } else {
            _revert(Errors.UNHANDLED_JOIN_KIND);
        }
    }

    function _doWeightedJoinChainedReferenceReplacements(bytes memory userData) private returns (bytes memory) {
        WeightedPoolUserData.JoinKind kind = WeightedPoolUserData.joinKind(userData);

        if (kind == WeightedPoolUserData.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT) {
            return _doWeightedExactTokensInForBPTOutReplacements(userData);
        } else {
            return userData;
        }
    }

    function _doWeightedExactTokensInForBPTOutReplacements(bytes memory userData) private returns (bytes memory) {
        (uint256[] memory amountsIn, uint256 minBPTAmountOut) = WeightedPoolUserData.exactTokensInForBptOut(userData);

        bool replacedAmounts = false;
        for (uint256 i = 0; i < amountsIn.length; ++i) {
            uint256 amount = amountsIn[i];
            if (_isChainedReference(amount)) {
                amountsIn[i] = _getChainedReferenceValue(amount);
                replacedAmounts = true;
            }
        }

        return
            replacedAmounts
                ? abi.encode(WeightedPoolUserData.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT, amountsIn, minBPTAmountOut)
                : userData;
    }

    function exitPool(
        bytes32 poolId,
        PoolKind kind,
        address sender,
        address payable recipient,
        IVault.ExitPoolRequest memory request,
        OutputReference[] calldata outputReferences
    ) external payable {
        require(sender == msg.sender || sender == address(this), "Incorrect sender");

        IERC20[] memory trackedTokens = new IERC20[](outputReferences.length);

        uint256[] memory initialRecipientBalances = new uint256[](outputReferences.length);
        for (uint256 i = 0; i < outputReferences.length; i++) {
            require(_isChainedReference(outputReferences[i].key), "invalid chained reference");

            IAsset asset = request.assets[outputReferences[i].index];
            if (request.toInternalBalance) {
                trackedTokens[i] = _asIERC20(asset);
            } else {
                initialRecipientBalances[i] = _isETH(asset) ? recipient.balance : _asIERC20(asset).balanceOf(recipient);
            }
        }
        if (request.toInternalBalance) {
            initialRecipientBalances = getVault().getInternalBalance(recipient, trackedTokens);
        }

        request.userData = _doExitPoolChainedReferenceReplacements(kind, request.userData);
        getVault().exitPool(poolId, sender, recipient, request);

        uint256[] memory finalRecipientTokenBalances = new uint256[](outputReferences.length);
        if (request.toInternalBalance) {
            finalRecipientTokenBalances = getVault().getInternalBalance(recipient, trackedTokens);
        } else {
            for (uint256 i = 0; i < outputReferences.length; i++) {
                IAsset asset = request.assets[outputReferences[i].index];
                finalRecipientTokenBalances[i] = _isETH(asset)
                    ? recipient.balance
                    : _asIERC20(asset).balanceOf(recipient);
            }
        }

        for (uint256 i = 0; i < outputReferences.length; i++) {
            _setChainedReferenceValue(
                outputReferences[i].key,
                finalRecipientTokenBalances[i].sub(initialRecipientBalances[i])
            );
        }
    }

    function _doExitPoolChainedReferenceReplacements(PoolKind kind, bytes memory userData)
        private
        returns (bytes memory)
    {
        if (kind == PoolKind.WEIGHTED) {
            return _doWeightedExitChainedReferenceReplacements(userData);
        } else {
            _revert(Errors.UNHANDLED_EXIT_KIND);
        }
    }

    function _doWeightedExitChainedReferenceReplacements(bytes memory userData) private returns (bytes memory) {
        WeightedPoolUserData.ExitKind kind = WeightedPoolUserData.exitKind(userData);

        if (kind == WeightedPoolUserData.ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT) {
            return _doWeightedExactBptInForOneTokenOutReplacements(userData);
        } else if (kind == WeightedPoolUserData.ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT) {
            return _doWeightedExactBptInForTokensOutReplacements(userData);
        } else {
            return userData;
        }
    }

    function _doWeightedExactBptInForOneTokenOutReplacements(bytes memory userData) private returns (bytes memory) {
        (uint256 bptAmountIn, uint256 tokenIndex) = WeightedPoolUserData.exactBptInForTokenOut(userData);

        if (_isChainedReference(bptAmountIn)) {
            bptAmountIn = _getChainedReferenceValue(bptAmountIn);
            return abi.encode(WeightedPoolUserData.ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT, bptAmountIn, tokenIndex);
        } else {
            return userData;
        }
    }

    function _doWeightedExactBptInForTokensOutReplacements(bytes memory userData) private returns (bytes memory) {
        uint256 bptAmountIn = WeightedPoolUserData.exactBptInForTokensOut(userData);

        if (_isChainedReference(bptAmountIn)) {
            bptAmountIn = _getChainedReferenceValue(bptAmountIn);
            return abi.encode(WeightedPoolUserData.ExitKind.EXACT_BPT_IN_FOR_TOKENS_OUT, bptAmountIn);
        } else {
            return userData;
        }
    }
}// GPL-3.0-or-later



pragma solidity ^0.7.0;



contract BatchRelayerLibrary is
    BaseRelayerLibrary,
    AaveWrapping,
    LidoWrapping,
    VaultActions,
    VaultPermit,
    ERC4626Wrapping,
    UnbuttonWrapping
{

    constructor(IVault vault, IERC20 wstETH) BaseRelayerLibrary(vault) LidoWrapping(wstETH) {
    }
}