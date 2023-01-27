
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

    function ensureArrayIsSorted(IAsset[] memory array) internal pure {

        address[] memory addressArray;
        assembly {
            addressArray := array
        }
        ensureArrayIsSorted(addressArray);
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
pragma experimental ABIEncoderV2;



contract ProtocolFeesCollector is Authentication, ReentrancyGuard {

    using SafeERC20 for IERC20;

    uint256 private constant _MAX_PROTOCOL_SWAP_FEE_PERCENTAGE = 50e16; // 50%
    uint256 private constant _MAX_PROTOCOL_FLASH_LOAN_FEE_PERCENTAGE = 1e16; // 1%

    IVault public immutable vault;


    uint256 private _swapFeePercentage;

    uint256 private _flashLoanFeePercentage;

    event SwapFeePercentageChanged(uint256 newSwapFeePercentage);
    event FlashLoanFeePercentageChanged(uint256 newFlashLoanFeePercentage);

    constructor(IVault _vault)
        Authentication(bytes32(uint256(address(this))))
    {
        vault = _vault;
    }

    function withdrawCollectedFees(
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        address recipient
    ) external nonReentrant authenticate {

        InputHelpers.ensureInputLengthMatch(tokens.length, amounts.length);

        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20 token = tokens[i];
            uint256 amount = amounts[i];
            token.safeTransfer(recipient, amount);
        }
    }

    function setSwapFeePercentage(uint256 newSwapFeePercentage) external authenticate {

        _require(newSwapFeePercentage <= _MAX_PROTOCOL_SWAP_FEE_PERCENTAGE, Errors.SWAP_FEE_PERCENTAGE_TOO_HIGH);
        _swapFeePercentage = newSwapFeePercentage;
        emit SwapFeePercentageChanged(newSwapFeePercentage);
    }

    function setFlashLoanFeePercentage(uint256 newFlashLoanFeePercentage) external authenticate {

        _require(
            newFlashLoanFeePercentage <= _MAX_PROTOCOL_FLASH_LOAN_FEE_PERCENTAGE,
            Errors.FLASH_LOAN_FEE_PERCENTAGE_TOO_HIGH
        );
        _flashLoanFeePercentage = newFlashLoanFeePercentage;
        emit FlashLoanFeePercentageChanged(newFlashLoanFeePercentage);
    }

    function getSwapFeePercentage() external view returns (uint256) {

        return _swapFeePercentage;
    }

    function getFlashLoanFeePercentage() external view returns (uint256) {

        return _flashLoanFeePercentage;
    }

    function getCollectedFeeAmounts(IERC20[] memory tokens) external view returns (uint256[] memory feeAmounts) {

        feeAmounts = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; ++i) {
            feeAmounts[i] = tokens[i].balanceOf(address(this));
        }
    }

    function getAuthorizer() external view returns (IAuthorizer) {

        return _getAuthorizer();
    }

    function _canPerform(bytes32 actionId, address account) internal view override returns (bool) {

        return _getAuthorizer().canPerform(actionId, account, address(this));
    }

    function _getAuthorizer() internal view returns (IAuthorizer) {

        return vault.getAuthorizer();
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


    function getProtocolFeesCollector() external view returns (ProtocolFeesCollector);


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

}// GPL-3.0-or-later



pragma solidity ^0.7.0;


abstract contract BasePoolFactory {
    IVault private immutable _vault;
    mapping(address => bool) private _isPoolFromFactory;

    event PoolCreated(address indexed pool);

    constructor(IVault vault) {
        _vault = vault;
    }

    function getVault() public view returns (IVault) {
        return _vault;
    }

    function isPoolFromFactory(address pool) external view returns (bool) {
        return _isPoolFromFactory[pool];
    }

    function _register(address pool) internal {
        _isPoolFromFactory[pool] = true;
        emit PoolCreated(pool);
    }
}// Apache-2.0
pragma solidity >=0.7.0;

contract Authorizable {


    address public owner;
    mapping(address => bool) public authorized;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "Sender not owner");
        _;
    }

    modifier onlyAuthorized() {

        require(isAuthorized(msg.sender), "Sender not Authorized");
        _;
    }

    function isAuthorized(address who) public view returns (bool) {

        return authorized[who];
    }

    function authorize(address who) external onlyOwner {

        _authorize(who);
    }

    function deauthorize(address who) external onlyOwner {

        authorized[who] = false;
    }

    function setOwner(address who) public onlyOwner {

        owner = who;
    }

    function _authorize(address who) internal {

        authorized[who] = true;
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

        _require(account != address(0), Errors.ERC20_MINT_TO_ZERO_ADDRESS);

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

        _require(owner != address(0), Errors.ERC20_APPROVE_FROM_ZERO_ADDRESS);
        _require(spender != address(0), Errors.ERC20_APPROVE_TO_ZERO_ADDRESS);

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

}// Apache-2.0
pragma solidity >=0.7.0;


interface IERC20Decimals is IERC20 {
    function decimals() external view returns (uint8);
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


interface IMinimalSwapInfoPool is IBasePool {
    function onSwap(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut
    ) external returns (uint256 amount);
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
}// GPL-3.0-or-later



pragma solidity ^0.7.0;


contract BalancerPoolToken is IERC20, IERC20Permit, EIP712 {
    using Math for uint256;


    uint8 private constant _DECIMALS = 18;

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowance;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    mapping(address => uint256) private _nonces;

    bytes32 private immutable _PERMIT_TYPE_HASH = keccak256(
        "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );


    constructor(string memory tokenName, string memory tokenSymbol) EIP712(tokenName, "1") {
        _name = tokenName;
        _symbol = tokenSymbol;
    }


    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowance[owner][spender];
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balance[account];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _setAllowance(msg.sender, spender, amount);

        return true;
    }

    function increaseApproval(address spender, uint256 amount) external returns (bool) {
        _setAllowance(msg.sender, spender, _allowance[msg.sender][spender].add(amount));

        return true;
    }

    function decreaseApproval(address spender, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowance[msg.sender][spender];

        if (amount >= currentAllowance) {
            _setAllowance(msg.sender, spender, 0);
        } else {
            _setAllowance(msg.sender, spender, currentAllowance.sub(amount));
        }

        return true;
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _move(msg.sender, recipient, amount);

        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        uint256 currentAllowance = _allowance[sender][msg.sender];
        _require(msg.sender == sender || currentAllowance >= amount, Errors.INSUFFICIENT_ALLOWANCE);

        _move(sender, recipient, amount);

        if (msg.sender != sender && currentAllowance != uint256(-1)) {
            _setAllowance(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

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

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPE_HASH, owner, spender, value, nonce, deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ecrecover(hash, v, r, s);
        _require((signer != address(0)) && (signer == owner), Errors.INVALID_SIGNATURE);

        _nonces[owner] = nonce + 1;
        _setAllowance(owner, spender, value);
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function nonces(address owner) external view override returns (uint256) {
        return _nonces[owner];
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }


    function _mintPoolTokens(address recipient, uint256 amount) internal {
        _balance[recipient] = _balance[recipient].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), recipient, amount);
    }

    function _burnPoolTokens(address sender, uint256 amount) internal {
        uint256 currentBalance = _balance[sender];
        _require(currentBalance >= amount, Errors.INSUFFICIENT_BALANCE);

        _balance[sender] = currentBalance - amount;
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(sender, address(0), amount);
    }

    function _move(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 currentBalance = _balance[sender];
        _require(currentBalance >= amount, Errors.INSUFFICIENT_BALANCE);
        _require(recipient != address(0), Errors.ERC20_TRANSFER_TO_ZERO_ADDRESS);

        _balance[sender] = currentBalance - amount;
        _balance[recipient] = _balance[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }


    function _setAllowance(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}// Apache-2.0
pragma solidity ^0.7.0;



contract ConvergentCurvePool is IMinimalSwapInfoPool, BalancerPoolToken {
    using LogExpMath for uint256;
    using FixedPoint for uint256;

    IERC20 public immutable underlying;
    uint8 public immutable underlyingDecimals;
    IERC20 public immutable bond;
    uint8 public immutable bondDecimals;
    uint256 public immutable expiration;
    uint256 public immutable unitSeconds;
    IVault private immutable _vault;
    bytes32 private immutable _poolId;

    uint120 public feesUnderlying;
    uint120 public feesBond;
    bool public paused;
    uint128 public governanceFeesUnderlying;
    uint128 public governanceFeesBond;
    mapping(address => bool) public pausers;
    address public immutable governance;
    uint256 public immutable percentFee;
    uint256 public immutable percentFeeGov;

    uint256 internal immutable baseIndex;
    uint256 internal immutable bondIndex;

    uint256 public constant FEE_BOUND = 3e17;


    event FeeCollection(
        uint256 collectedBase,
        uint256 collectedBond,
        uint256 remainingBase,
        uint256 remainingBond
    );

    constructor(
        IERC20 _underlying,
        IERC20 _bond,
        uint256 _expiration,
        uint256 _unitSeconds,
        IVault vault,
        uint256 _percentFee,
        uint256 _percentFeeGov,
        address _governance,
        string memory name,
        string memory symbol,
        address _pauser
    ) BalancerPoolToken(name, symbol) {
        require(_expiration - block.timestamp < _unitSeconds);
        bytes32 poolId = vault.registerPool(
            IVault.PoolSpecialization.TWO_TOKEN
        );

        IERC20[] memory tokens = new IERC20[](2);
        if (_underlying < _bond) {
            tokens[0] = _underlying;
            tokens[1] = _bond;
        } else {
            tokens[0] = _bond;
            tokens[1] = _underlying;
        }

        pausers[_pauser] = true;

        vault.registerTokens(poolId, tokens, new address[](2));

        _vault = vault;
        _poolId = poolId;
        percentFee = _percentFee;
        require(_percentFeeGov < FEE_BOUND, "Fee too high");
        percentFeeGov = _percentFeeGov;
        underlying = _underlying;
        underlyingDecimals = IERC20Decimals(address(_underlying)).decimals();
        bond = _bond;
        bondDecimals = IERC20Decimals(address(_bond)).decimals();
        expiration = _expiration;
        unitSeconds = _unitSeconds;
        governance = _governance;
        bool underlyingFirst = _underlying < _bond;
        baseIndex = underlyingFirst ? 0 : 1;
        bondIndex = underlyingFirst ? 1 : 0;
    }


    function getVault() external view returns (IVault) {
        return _vault;
    }

    function getPoolId() external view returns (bytes32) {
        return _poolId;
    }


    function onSwap(
        SwapRequest memory swapRequest,
        uint256 currentBalanceTokenIn,
        uint256 currentBalanceTokenOut
    ) public override notPaused returns (uint256) {
        require(msg.sender == address(_vault), "Non Vault caller");
        uint256 amount;
        bool isOutputSwap = swapRequest.kind == IVault.SwapKind.GIVEN_IN;
        if (isOutputSwap) {
            amount = _tokenToFixed(swapRequest.amount, swapRequest.tokenIn);
        } else {
            amount = _tokenToFixed(swapRequest.amount, swapRequest.tokenOut);
        }
        currentBalanceTokenIn = _tokenToFixed(
            currentBalanceTokenIn,
            swapRequest.tokenIn
        );
        currentBalanceTokenOut = _tokenToFixed(
            currentBalanceTokenOut,
            swapRequest.tokenOut
        );

        (uint256 tokenInReserve, uint256 tokenOutReserve) = _adjustedReserve(
            currentBalanceTokenIn,
            swapRequest.tokenIn,
            currentBalanceTokenOut,
            swapRequest.tokenOut
        );

        if (isOutputSwap) {
            uint256 quote = solveTradeInvariant(
                amount,
                tokenInReserve,
                tokenOutReserve,
                isOutputSwap
            );
            quote = _assignTradeFee(amount, quote, swapRequest.tokenOut, false);
            return _fixedToToken(quote, swapRequest.tokenOut);
        } else {
            uint256 quote = solveTradeInvariant(
                amount,
                tokenOutReserve,
                tokenInReserve,
                isOutputSwap
            );
            quote = _assignTradeFee(quote, amount, swapRequest.tokenOut, true);
            return _fixedToToken(quote, swapRequest.tokenIn);
        }
    }

    function onJoinPool(
        bytes32 poolId,
        address, // sender
        address recipient,
        uint256[] memory currentBalances,
        uint256,
        uint256 protocolSwapFee,
        bytes calldata userData
    )
        external
        override
        notPaused
        returns (
            uint256[] memory amountsIn,
            uint256[] memory dueProtocolFeeAmounts
        )
    {
        require(msg.sender == address(_vault), "Non Vault caller");
        require(poolId == _poolId, "Wrong pool id");
        uint256[] memory maxAmountsIn = abi.decode(userData, (uint256[]));
        require(
            currentBalances.length == 2 && maxAmountsIn.length == 2,
            "Invalid format"
        );
        require(
            recipient != governance,
            "Governance address LP would be locked"
        );
        _normalizeSortedArray(currentBalances);
        _normalizeSortedArray(maxAmountsIn);

        dueProtocolFeeAmounts = _feeAccounting(
            currentBalances,
            protocolSwapFee
        );

        amountsIn = _mintLP(
            maxAmountsIn[baseIndex],
            maxAmountsIn[bondIndex],
            currentBalances,
            recipient
        );

        _denormalizeSortedArray(amountsIn);
        _denormalizeSortedArray(dueProtocolFeeAmounts);
    }

    function onExitPool(
        bytes32 poolId,
        address sender,
        address,
        uint256[] memory currentBalances,
        uint256,
        uint256 protocolSwapFee,
        bytes calldata userData
    )
        external
        override
        returns (
            uint256[] memory amountsOut,
            uint256[] memory dueProtocolFeeAmounts
        )
    {
        require(msg.sender == address(_vault), "Non Vault caller");
        require(poolId == _poolId, "Wrong pool id");
        uint256 lpOut = abi.decode(userData, (uint256));

        _normalizeSortedArray(currentBalances);

        dueProtocolFeeAmounts = _feeAccounting(
            currentBalances,
            protocolSwapFee
        );

        if (sender == governance) {
            amountsOut = new uint256[](2);
            amountsOut[baseIndex] = uint256(governanceFeesUnderlying);
            amountsOut[bondIndex] = uint256(governanceFeesBond);
            governanceFeesUnderlying = 0;
            governanceFeesBond = 0;
        } else {
            amountsOut = _burnLP(lpOut, currentBalances, sender);
        }

        _denormalizeSortedArray(amountsOut);
        _denormalizeSortedArray(dueProtocolFeeAmounts);
        return (amountsOut, dueProtocolFeeAmounts);
    }

    function _getSortedBalances(uint256[] memory currentBalances)
        internal
        view
        returns (uint256 underlyingBalance, uint256 bondBalance)
    {
        return (currentBalances[baseIndex], currentBalances[bondIndex]);
    }

    function _normalizeSortedArray(uint256[] memory data) internal view {
        data[baseIndex] = _normalize(data[baseIndex], underlyingDecimals, 18);
        data[bondIndex] = _normalize(data[bondIndex], bondDecimals, 18);
    }

    function _denormalizeSortedArray(uint256[] memory data) internal view {
        data[baseIndex] = _normalize(data[baseIndex], 18, underlyingDecimals);
        data[bondIndex] = _normalize(data[bondIndex], 18, bondDecimals);
    }


    modifier notPaused() {
        require(!paused, "Paused");
        _;
    }

    function pause(bool pauseStatus) external {
        require(pausers[msg.sender], "Sender not Authorized");
        paused = pauseStatus;
    }

    function setPauser(address who, bool status) external {
        require(msg.sender == governance, "Sender not Owner");
        pausers[who] = status;
    }


    function solveTradeInvariant(
        uint256 amountX,
        uint256 reserveX,
        uint256 reserveY,
        bool out
    ) public view returns (uint256) {
        uint256 a = _getYieldExponent();
        uint256 xBeforePowA = LogExpMath.pow(reserveX, a);
        uint256 yBeforePowA = LogExpMath.pow(reserveY, a);
        uint256 xAfterPowA = out
            ? LogExpMath.pow(reserveX + amountX, a)
            : LogExpMath.pow(reserveX.sub(amountX), a);
        uint256 yAfter = (xBeforePowA + yBeforePowA).sub(xAfterPowA);
        yAfter = LogExpMath.pow(yAfter, uint256(FixedPoint.ONE).divDown(a));
        return out ? reserveY.sub(yAfter) : yAfter.sub(reserveY);
    }

    function _assignTradeFee(
        uint256 amountIn,
        uint256 amountOut,
        IERC20 outputToken,
        bool isInputTrade
    ) internal returns (uint256) {
        if (isInputTrade) {
            if (outputToken == bond) {
                uint256 impliedYieldFee = percentFee.mulDown(
                    amountOut.sub(amountIn)
                );
                feesUnderlying += uint120(impliedYieldFee);
                return amountIn.add(impliedYieldFee);
            } else {
                uint256 impliedYieldFee = percentFee.mulDown(
                    amountIn.sub(amountOut)
                );
                feesBond += uint120(impliedYieldFee);
                return amountIn.add(impliedYieldFee);
            }
        } else {
            if (outputToken == bond) {
                uint256 impliedYieldFee = percentFee.mulDown(
                    amountOut.sub(amountIn)
                );
                feesBond += uint120(impliedYieldFee);
                return amountOut.sub(impliedYieldFee);
            } else {
                uint256 impliedYieldFee = percentFee.mulDown(
                    amountIn.sub(amountOut)
                );
                feesUnderlying += uint120(impliedYieldFee);
                return amountOut.sub(impliedYieldFee);
            }
        }
    }

    function _mintLP(
        uint256 inputUnderlying,
        uint256 inputBond,
        uint256[] memory currentBalances,
        address recipient
    ) internal returns (uint256[] memory amountsIn) {
        amountsIn = new uint256[](2);
        (uint256 reserveUnderlying, uint256 reserveBond) = _getSortedBalances(
            currentBalances
        );

        uint256 localTotalSupply = totalSupply();
        if (localTotalSupply == 0) {
            _mintPoolTokens(recipient, inputUnderlying);
            amountsIn[baseIndex] = inputUnderlying;
            amountsIn[bondIndex] = 0;
            return (amountsIn);
        }
        uint256 underlyingPerBond = reserveUnderlying.divDown(reserveBond);
        uint256 neededUnderlying = underlyingPerBond.mulDown(inputBond);

        if (neededUnderlying > inputUnderlying) {
            uint256 mintAmount = (inputUnderlying.mulDown(localTotalSupply))
                .divDown(reserveUnderlying);
            _mintPoolTokens(recipient, mintAmount);
            amountsIn[baseIndex] = inputUnderlying;
            amountsIn[bondIndex] = inputUnderlying.divDown(underlyingPerBond);
        } else {
            uint256 mintAmount = (neededUnderlying.mulDown(localTotalSupply))
                .divDown(reserveUnderlying);
            _mintPoolTokens(recipient, mintAmount);
            amountsIn[baseIndex] = neededUnderlying;
            amountsIn[bondIndex] = inputBond;
        }
    }

    function _burnLP(
        uint256 lpOut,
        uint256[] memory currentBalances,
        address source
    ) internal returns (uint256[] memory amountsReleased) {
        uint256 localTotalSupply = totalSupply();
        _burnPoolTokens(source, lpOut);
        amountsReleased = new uint256[](2);
        amountsReleased[baseIndex] = (currentBalances[baseIndex].mulDown(lpOut))
            .divDown(localTotalSupply);
        amountsReleased[bondIndex] = (currentBalances[bondIndex].mulDown(lpOut))
            .divDown(localTotalSupply);
    }

    function _getYieldExponent() internal view virtual returns (uint256) {
        uint256 timeTillExpiry = block.timestamp < expiration
            ? expiration - block.timestamp
            : 0;
        timeTillExpiry *= 1e18;
        timeTillExpiry = timeTillExpiry.divDown(unitSeconds * 1e18);
        uint256 result = uint256(FixedPoint.ONE).sub(timeTillExpiry);
        require(result != 0);
        return result;
    }

    function _adjustedReserve(
        uint256 reserveTokenIn,
        IERC20 tokenIn,
        uint256 reserveTokenOut,
        IERC20 tokenOut
    ) internal view returns (uint256, uint256) {
        if (tokenIn == underlying && tokenOut == bond) {
            return (reserveTokenIn, reserveTokenOut + totalSupply());
        } else if (tokenIn == bond && tokenOut == underlying) {
            return (reserveTokenIn + totalSupply(), reserveTokenOut);
        }
        revert("Token request doesn't match stored");
    }

    function _feeAccounting(
        uint256[] memory currentBalances,
        uint256 balancerFee
    ) internal returns (uint256[] memory dueProtocolFees) {
        uint256 localFeeUnderlying = uint256(feesUnderlying);
        uint256 localFeeBond = uint256(feesBond);
        dueProtocolFees = new uint256[](2);
        dueProtocolFees[baseIndex] = localFeeUnderlying.mulDown(balancerFee);
        dueProtocolFees[bondIndex] = localFeeBond.mulDown(balancerFee);
        uint256 govFeeBase = localFeeUnderlying.mulDown(percentFeeGov);
        uint256 govFeeBond = localFeeBond.mulDown(percentFeeGov);
        governanceFeesUnderlying += uint128(govFeeBase);
        governanceFeesBond += uint128(govFeeBond);
        currentBalances[baseIndex] = currentBalances[baseIndex]
            .sub(dueProtocolFees[baseIndex])
            .sub(governanceFeesUnderlying);
        currentBalances[bondIndex] = currentBalances[bondIndex]
            .sub(dueProtocolFees[bondIndex])
            .sub(governanceFeesBond);
        feesUnderlying = uint120(0);
        feesBond = uint120(0);
    }

    function _tokenToFixed(uint256 amount, IERC20 token)
        internal
        view
        returns (uint256)
    {
        if (token == underlying) {
            return _normalize(amount, underlyingDecimals, 18);
        } else if (token == bond) {
            return _normalize(amount, bondDecimals, 18);
        }
        revert("Called with non pool token");
    }

    function _fixedToToken(uint256 amount, IERC20 token)
        internal
        view
        returns (uint256)
    {
        if (token == underlying) {
            return _normalize(amount, 18, underlyingDecimals);
        } else if (token == bond) {
            return _normalize(amount, 18, bondDecimals);
        }
        revert("Called with non pool token");
    }

    function _normalize(
        uint256 amount,
        uint8 decimalsBefore,
        uint8 decimalsAfter
    ) internal pure returns (uint256) {
        if (decimalsBefore > decimalsAfter) {
            amount = amount / 10**(decimalsBefore - decimalsAfter);
        } else if (decimalsBefore < decimalsAfter) {
            amount = amount * 10**(decimalsAfter - decimalsBefore);
        }
        return amount;
    }
}// Apache-2.0
pragma solidity ^0.7.0;


contract ConvergentPoolFactory is BasePoolFactory, Authorizable {

    uint256 public percentFeeGov;
    address public governance;

    event CCPoolCreated(address indexed pool, address indexed bondToken);

    constructor(IVault _vault, address _governance)
        BasePoolFactory(_vault)
        Authorizable()
    {
        _authorize(_governance);
        setOwner(_governance);
        governance = _governance;
    }

    function create(
        address _underlying,
        address _bond,
        uint256 _expiration,
        uint256 _unitSeconds,
        uint256 _percentFee,
        string memory _name,
        string memory _symbol,
        address _pauser
    ) external returns (address) {
        address pool = address(
            new ConvergentCurvePool(
                IERC20(_underlying),
                IERC20(_bond),
                _expiration,
                _unitSeconds,
                getVault(),
                _percentFee,
                percentFeeGov,
                governance,
                _name,
                _symbol,
                _pauser
            )
        );
        _register(pool);
        emit CCPoolCreated(pool, _bond);
        return pool;
    }

    function setGovFee(uint256 newFee) external onlyAuthorized {
        require(newFee < 3e17, "New fee higher than 30%");
        percentFeeGov = newFee;
    }

    function setGov(address newGov) external onlyOwner {
        governance = newGov;
    }
}