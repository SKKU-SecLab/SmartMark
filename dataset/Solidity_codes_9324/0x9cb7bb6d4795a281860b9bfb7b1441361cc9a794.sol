

pragma solidity 0.6.6;


interface IERC20 {

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function approve(address _spender, uint256 _value) external returns (bool success);


    function transfer(address _to, uint256 _value) external returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function decimals() external view returns (uint8 digits);


    function totalSupply() external view returns (uint256 supply);

}


abstract contract ERC20 is IERC20 {

}


pragma solidity 0.6.6;


contract PermissionGroupsNoModifiers {

    address public admin;
    address public pendingAdmin;
    mapping(address => bool) internal operators;
    mapping(address => bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;
    uint256 internal constant MAX_GROUP_SIZE = 50;

    event AdminClaimed(address newAdmin, address previousAdmin);
    event AlerterAdded(address newAlerter, bool isAdd);
    event OperatorAdded(address newOperator, bool isAdd);
    event TransferAdminPending(address pendingAdmin);

    constructor(address _admin) public {
        require(_admin != address(0), "admin 0");
        admin = _admin;
    }

    function getOperators() external view returns (address[] memory) {

        return operatorsGroup;
    }

    function getAlerters() external view returns (address[] memory) {

        return alertersGroup;
    }

    function addAlerter(address newAlerter) public {

        onlyAdmin();
        require(!alerters[newAlerter], "alerter exists"); // prevent duplicates.
        require(alertersGroup.length < MAX_GROUP_SIZE, "max alerters");

        emit AlerterAdded(newAlerter, true);
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    function addOperator(address newOperator) public {

        onlyAdmin();
        require(!operators[newOperator], "operator exists"); // prevent duplicates.
        require(operatorsGroup.length < MAX_GROUP_SIZE, "max operators");

        emit OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function claimAdmin() public {

        require(pendingAdmin == msg.sender, "not pending");
        emit AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    function removeAlerter(address alerter) public {

        onlyAdmin();
        require(alerters[alerter], "not alerter");
        delete alerters[alerter];

        for (uint256 i = 0; i < alertersGroup.length; ++i) {
            if (alertersGroup[i] == alerter) {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.pop();
                emit AlerterAdded(alerter, false);
                break;
            }
        }
    }

    function removeOperator(address operator) public {

        onlyAdmin();
        require(operators[operator], "not operator");
        delete operators[operator];

        for (uint256 i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.pop();
                emit OperatorAdded(operator, false);
                break;
            }
        }
    }

    function transferAdmin(address newAdmin) public {

        onlyAdmin();
        require(newAdmin != address(0), "new admin 0");
        emit TransferAdminPending(newAdmin);
        pendingAdmin = newAdmin;
    }

    function transferAdminQuickly(address newAdmin) public {

        onlyAdmin();
        require(newAdmin != address(0), "admin 0");
        emit TransferAdminPending(newAdmin);
        emit AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    function onlyAdmin() internal view {

        require(msg.sender == admin, "only admin");
    }

    function onlyAlerter() internal view {

        require(alerters[msg.sender], "only alerter");
    }

    function onlyOperator() internal view {

        require(operators[msg.sender], "only operator");
    }
}


pragma solidity 0.6.6;




contract WithdrawableNoModifiers is PermissionGroupsNoModifiers {

    constructor(address _admin) public PermissionGroupsNoModifiers(_admin) {}

    event EtherWithdraw(uint256 amount, address sendTo);
    event TokenWithdraw(IERC20 token, uint256 amount, address sendTo);

    function withdrawEther(uint256 amount, address payable sendTo) external {

        onlyAdmin();
        (bool success, ) = sendTo.call{value: amount}("");
        require(success);
        emit EtherWithdraw(amount, sendTo);
    }

    function withdrawToken(
        IERC20 token,
        uint256 amount,
        address sendTo
    ) external {

        onlyAdmin();
        token.transfer(sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }
}


pragma solidity 0.6.6;



contract Utils5 {

    IERC20 internal constant ETH_TOKEN_ADDRESS = IERC20(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens
    uint256 internal constant MAX_RATE = (PRECISION * 10**7); // up to 10M tokens per eth
    uint256 internal constant MAX_DECIMALS = 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 constant BPS = 10000; // Basic Price Steps. 1 step = 0.01%
    uint256 internal constant MAX_ALLOWANCE = uint256(-1); // token.approve inifinite

    mapping(IERC20 => uint256) internal decimals;

    function getUpdateDecimals(IERC20 token) internal returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint256 tokenDecimals = decimals[token];
        if (tokenDecimals == 0) {
            tokenDecimals = token.decimals();
            decimals[token] = tokenDecimals;
        }

        return tokenDecimals;
    }

    function setDecimals(IERC20 token) internal {

        if (decimals[token] != 0) return; //already set

        if (token == ETH_TOKEN_ADDRESS) {
            decimals[token] = ETH_DECIMALS;
        } else {
            decimals[token] = token.decimals();
        }
    }

    function getBalance(IERC20 token, address user) internal view returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) {
            return user.balance;
        } else {
            return token.balanceOf(user);
        }
    }

    function getDecimals(IERC20 token) internal view returns (uint256) {

        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint256 tokenDecimals = decimals[token];
        if (tokenDecimals == 0) return token.decimals();

        return tokenDecimals;
    }

    function calcDestAmount(
        IERC20 src,
        IERC20 dest,
        uint256 srcAmount,
        uint256 rate
    ) internal view returns (uint256) {

        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(
        IERC20 src,
        IERC20 dest,
        uint256 destAmount,
        uint256 rate
    ) internal view returns (uint256) {

        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcDstQty(
        uint256 srcQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {

        require(srcQty <= MAX_QTY, "srcQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(
        uint256 dstQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {

        require(dstQty <= MAX_QTY, "dstQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        uint256 numerator;
        uint256 denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {

        require(srcAmount <= MAX_QTY, "srcAmount > MAX_QTY");
        require(destAmount <= MAX_QTY, "destAmount > MAX_QTY");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return ((destAmount * PRECISION) / ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return ((destAmount * PRECISION * (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    function minOf(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? y : x;
    }
}


pragma solidity 0.6.6;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}


pragma solidity 0.6.6;

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

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }
}


pragma solidity 0.6.6;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity 0.6.6;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity 0.6.6;



interface IKyberNetwork {

    event KyberTrade(
        IERC20 indexed src,
        IERC20 indexed dest,
        uint256 ethWeiValue,
        uint256 networkFeeWei,
        uint256 customPlatformFeeWei,
        bytes32[] t2eIds,
        bytes32[] e2tIds,
        uint256[] t2eSrcAmounts,
        uint256[] e2tSrcAmounts,
        uint256[] t2eRates,
        uint256[] e2tRates
    );

    function tradeWithHintAndFee(
        address payable trader,
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external payable returns (uint256 destAmount);


    function listTokenForReserve(
        address reserve,
        IERC20 token,
        bool add
    ) external;


    function enabled() external view returns (bool);


    function getExpectedRateWithHintAndFee(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 platformFeeBps,
        bytes calldata hint
    )
        external
        view
        returns (
            uint256 expectedRateAfterNetworkFee,
            uint256 expectedRateAfterAllFees
        );


    function getNetworkData()
        external
        view
        returns (
            uint256 negligibleDiffBps,
            uint256 networkFeeBps,
            uint256 expiryTimestamp
        );


    function maxGasPrice() external view returns (uint256);

}


pragma solidity 0.6.6;



interface IKyberReserve {

    function trade(
        IERC20 srcToken,
        uint256 srcAmount,
        IERC20 destToken,
        address payable destAddress,
        uint256 conversionRate,
        bool validate
    ) external payable returns (bool);


    function getConversionRate(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 blockNumber
    ) external view returns (uint256);

}


pragma solidity 0.6.6;



interface IKyberFeeHandler {

    event RewardPaid(address indexed staker, uint256 indexed epoch, IERC20 indexed token, uint256 amount);
    event RebatePaid(address indexed rebateWallet, IERC20 indexed token, uint256 amount);
    event PlatformFeePaid(address indexed platformWallet, IERC20 indexed token, uint256 amount);
    event KncBurned(uint256 kncTWei, IERC20 indexed token, uint256 amount);

    function handleFees(
        IERC20 token,
        address[] calldata eligibleWallets,
        uint256[] calldata rebatePercentages,
        address platformWallet,
        uint256 platformFee,
        uint256 networkFee
    ) external payable;


    function claimReserveRebate(address rebateWallet) external returns (uint256);


    function claimPlatformFee(address platformWallet) external returns (uint256);


    function claimStakerReward(
        address staker,
        uint256 epoch
    ) external returns(uint amount);

}


pragma solidity 0.6.6;

interface IEpochUtils {

    function epochPeriodInSeconds() external view returns (uint256);


    function firstEpochStartTimestamp() external view returns (uint256);


    function getCurrentEpochNumber() external view returns (uint256);


    function getEpochNumber(uint256 timestamp) external view returns (uint256);

}


pragma solidity 0.6.6;



interface IKyberDao is IEpochUtils {

    event Voted(address indexed staker, uint indexed epoch, uint indexed campaignID, uint option);

    function getLatestNetworkFeeDataWithCache()
        external
        returns (uint256 feeInBps, uint256 expiryTimestamp);


    function getLatestBRRDataWithCache()
        external
        returns (
            uint256 burnInBps,
            uint256 rewardInBps,
            uint256 rebateInBps,
            uint256 epoch,
            uint256 expiryTimestamp
        );


    function handleWithdrawal(address staker, uint256 penaltyAmount) external;


    function vote(uint256 campaignID, uint256 option) external;


    function getLatestNetworkFeeData()
        external
        view
        returns (uint256 feeInBps, uint256 expiryTimestamp);


    function shouldBurnRewardForEpoch(uint256 epoch) external view returns (bool);


    function getPastEpochRewardPercentageInPrecision(address staker, uint256 epoch)
        external
        view
        returns (uint256);


    function getCurrentEpochRewardPercentageInPrecision(address staker)
        external
        view
        returns (uint256);

}


pragma solidity 0.6.6;



interface IKyberNetworkProxy {


    event ExecuteTrade(
        address indexed trader,
        IERC20 src,
        IERC20 dest,
        address destAddress,
        uint256 actualSrcAmount,
        uint256 actualDestAmount,
        address platformWallet,
        uint256 platformFeeBps
    );

    function tradeWithHint(
        ERC20 src,
        uint256 srcAmount,
        ERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable walletId,
        bytes calldata hint
    ) external payable returns (uint256);


    function tradeWithHintAndFee(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external payable returns (uint256 destAmount);


    function trade(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet
    ) external payable returns (uint256);


    function getExpectedRate(
        ERC20 src,
        ERC20 dest,
        uint256 srcQty
    ) external view returns (uint256 expectedRate, uint256 worstRate);


    function getExpectedRateAfterFee(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external view returns (uint256 expectedRate);

}


pragma solidity 0.6.6;




interface IKyberStorage {

    enum ReserveType {NONE, FPR, APR, BRIDGE, UTILITY, CUSTOM, ORDERBOOK, LAST}

    function addKyberProxy(address kyberProxy, uint256 maxApprovedProxies)
        external;


    function removeKyberProxy(address kyberProxy) external;


    function setContracts(address _kyberFeeHandler, address _kyberMatchingEngine) external;


    function setKyberDaoContract(address _kyberDao) external;


    function getReserveId(address reserve) external view returns (bytes32 reserveId);


    function getReserveIdsFromAddresses(address[] calldata reserveAddresses)
        external
        view
        returns (bytes32[] memory reserveIds);


    function getReserveAddressesFromIds(bytes32[] calldata reserveIds)
        external
        view
        returns (address[] memory reserveAddresses);


    function getReserveIdsPerTokenSrc(IERC20 token)
        external
        view
        returns (bytes32[] memory reserveIds);


    function getReserveAddressesPerTokenSrc(IERC20 token, uint256 startIndex, uint256 endIndex)
        external
        view
        returns (address[] memory reserveAddresses);


    function getReserveIdsPerTokenDest(IERC20 token)
        external
        view
        returns (bytes32[] memory reserveIds);


    function getReserveAddressesByReserveId(bytes32 reserveId)
        external
        view
        returns (address[] memory reserveAddresses);


    function getRebateWalletsFromIds(bytes32[] calldata reserveIds)
        external
        view
        returns (address[] memory rebateWallets);


    function getKyberProxies() external view returns (IKyberNetworkProxy[] memory);


    function getReserveDetailsByAddress(address reserve)
        external
        view
        returns (
            bytes32 reserveId,
            address rebateWallet,
            ReserveType resType,
            bool isFeeAccountedFlag,
            bool isEntitledRebateFlag
        );


    function getReserveDetailsById(bytes32 reserveId)
        external
        view
        returns (
            address reserveAddress,
            address rebateWallet,
            ReserveType resType,
            bool isFeeAccountedFlag,
            bool isEntitledRebateFlag
        );


    function getFeeAccountedData(bytes32[] calldata reserveIds)
        external
        view
        returns (bool[] memory feeAccountedArr);


    function getEntitledRebateData(bytes32[] calldata reserveIds)
        external
        view
        returns (bool[] memory entitledRebateArr);


    function getReservesData(bytes32[] calldata reserveIds, IERC20 src, IERC20 dest)
        external
        view
        returns (
            bool areAllReservesListed,
            bool[] memory feeAccountedArr,
            bool[] memory entitledRebateArr,
            IKyberReserve[] memory reserveAddresses);


    function isKyberProxyAdded() external view returns (bool);

}


pragma solidity 0.6.6;





interface IKyberMatchingEngine {

    enum ProcessWithRate {NotRequired, Required}

    function setNegligibleRateDiffBps(uint256 _negligibleRateDiffBps) external;


    function setKyberStorage(IKyberStorage _kyberStorage) external;


    function getNegligibleRateDiffBps() external view returns (uint256);


    function getTradingReserves(
        IERC20 src,
        IERC20 dest,
        bool isTokenToToken,
        bytes calldata hint
    )
        external
        view
        returns (
            bytes32[] memory reserveIds,
            uint256[] memory splitValuesBps,
            ProcessWithRate processWithRate
        );


    function doMatch(
        IERC20 src,
        IERC20 dest,
        uint256[] calldata srcAmounts,
        uint256[] calldata feesAccountedDestBps,
        uint256[] calldata rates
    ) external view returns (uint256[] memory reserveIndexes);

}


pragma solidity 0.6.6;



interface IGasHelper {

    function freeGas(
        address platformWallet,
        IERC20 src,
        IERC20 dest,
        uint256 tradeWei,
        bytes32[] calldata t2eReserveIds,
        bytes32[] calldata e2tReserveIds
    ) external;

}


pragma solidity 0.6.6;













contract KyberNetwork is WithdrawableNoModifiers, Utils5, IKyberNetwork, ReentrancyGuard {

    using SafeERC20 for IERC20;

    struct NetworkFeeData {
        uint64 expiryTimestamp;
        uint16 feeBps;
    }

    struct ReservesData {
        IKyberReserve[] addresses;
        bytes32[] ids;
        uint256[] rates;
        bool[] isFeeAccountedFlags;
        bool[] isEntitledRebateFlags;
        uint256[] splitsBps;
        uint256[] srcAmounts;
        uint256 decimals;
    }

    struct TradeData {
        TradeInput input;
        ReservesData tokenToEth;
        ReservesData ethToToken;
        uint256 tradeWei;
        uint256 networkFeeWei;
        uint256 platformFeeWei;
        uint256 networkFeeBps;
        uint256 numEntitledRebateReserves;
        uint256 feeAccountedBps; // what part of this trade is fee paying. for token -> token - up to 200%
    }

    struct TradeInput {
        address payable trader;
        IERC20 src;
        uint256 srcAmount;
        IERC20 dest;
        address payable destAddress;
        uint256 maxDestAmount;
        uint256 minConversionRate;
        address platformWallet;
        uint256 platformFeeBps;
    }

    uint256 internal constant PERM_HINT_GET_RATE = 1 << 255; // for backwards compatibility
    uint256 internal constant DEFAULT_NETWORK_FEE_BPS = 25; // till we read value from kyberDao
    uint256 internal constant MAX_APPROVED_PROXIES = 2; // limit number of proxies that can trade here

    IKyberFeeHandler internal kyberFeeHandler;
    IKyberDao internal kyberDao;
    IKyberMatchingEngine internal kyberMatchingEngine;
    IKyberStorage internal kyberStorage;
    IGasHelper internal gasHelper;

    NetworkFeeData internal networkFeeData; // data is feeBps and expiry timestamp
    uint256 internal maxGasPriceValue = 50 * 1000 * 1000 * 1000; // 50 gwei
    bool internal isEnabled = false; // is network enabled

    mapping(address => bool) internal kyberProxyContracts;

    event EtherReceival(address indexed sender, uint256 amount);
    event KyberFeeHandlerUpdated(IKyberFeeHandler newKyberFeeHandler);
    event KyberMatchingEngineUpdated(IKyberMatchingEngine newKyberMatchingEngine);
    event GasHelperUpdated(IGasHelper newGasHelper);
    event KyberDaoUpdated(IKyberDao newKyberDao);
    event KyberNetworkParamsSet(uint256 maxGasPrice, uint256 negligibleRateDiffBps);
    event KyberNetworkSetEnable(bool isEnabled);
    event KyberProxyAdded(address kyberProxy);
    event KyberProxyRemoved(address kyberProxy);

    event ListedReservesForToken(
        IERC20 indexed token,
        address[] reserves,
        bool add
    );

    constructor(address _admin, IKyberStorage _kyberStorage)
        public
        WithdrawableNoModifiers(_admin)
    {
        updateNetworkFee(now, DEFAULT_NETWORK_FEE_BPS);
        kyberStorage = _kyberStorage;
    }

    receive() external payable {
        emit EtherReceival(msg.sender, msg.value);
    }

    function tradeWithHint(
        address payable trader,
        ERC20 src,
        uint256 srcAmount,
        ERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable walletId,
        bytes calldata hint
    ) external payable returns (uint256 destAmount) {

        TradeData memory tradeData = initTradeInput({
            trader: trader,
            src: src,
            dest: dest,
            srcAmount: srcAmount,
            destAddress: destAddress,
            maxDestAmount: maxDestAmount,
            minConversionRate: minConversionRate,
            platformWallet: walletId,
            platformFeeBps: 0
        });

        return trade(tradeData, hint);
    }

    function tradeWithHintAndFee(
        address payable trader,
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external payable override returns (uint256 destAmount) {

        TradeData memory tradeData = initTradeInput({
            trader: trader,
            src: src,
            dest: dest,
            srcAmount: srcAmount,
            destAddress: destAddress,
            maxDestAmount: maxDestAmount,
            minConversionRate: minConversionRate,
            platformWallet: platformWallet,
            platformFeeBps: platformFeeBps
        });

        return trade(tradeData, hint);
    }

    function listTokenForReserve(
        address reserve,
        IERC20 token,
        bool add
    ) external override {

        require(msg.sender == address(kyberStorage), "only kyberStorage");

        if (add) {
            token.safeApprove(reserve, MAX_ALLOWANCE);
            setDecimals(token);
        } else {
            token.safeApprove(reserve, 0);
        }
    }

    function listReservesForToken(
        IERC20 token,
        uint256 startIndex,
        uint256 endIndex,
        bool add
    ) external {

        onlyOperator();

        if (startIndex > endIndex) {
            return;
        }

        address[] memory reserves = kyberStorage.getReserveAddressesPerTokenSrc(
            token, startIndex, endIndex
        );

        if (reserves.length == 0) {
            return;
        }

        for(uint i = 0; i < reserves.length; i++) {
            if (add) {
                token.safeApprove(reserves[i], MAX_ALLOWANCE);
                setDecimals(token);
            } else {
                token.safeApprove(reserves[i], 0);
            }
        }

        emit ListedReservesForToken(token, reserves, add);
    }

    function setContracts(
        IKyberFeeHandler _kyberFeeHandler,
        IKyberMatchingEngine _kyberMatchingEngine,
        IGasHelper _gasHelper
    ) external virtual {

        onlyAdmin();

        if (kyberFeeHandler != _kyberFeeHandler) {
            kyberFeeHandler = _kyberFeeHandler;
            emit KyberFeeHandlerUpdated(_kyberFeeHandler);
        }

        if (kyberMatchingEngine != _kyberMatchingEngine) {
            kyberMatchingEngine = _kyberMatchingEngine;
            emit KyberMatchingEngineUpdated(_kyberMatchingEngine);
        }

        if ((_gasHelper != IGasHelper(0)) && (_gasHelper != gasHelper)) {
            gasHelper = _gasHelper;
            emit GasHelperUpdated(_gasHelper);
        }

        kyberStorage.setContracts(address(_kyberFeeHandler), address(_kyberMatchingEngine));
        require(_kyberFeeHandler != IKyberFeeHandler(0));
        require(_kyberMatchingEngine != IKyberMatchingEngine(0));
    }

    function setKyberDaoContract(IKyberDao _kyberDao) external {

        onlyAdmin();
        if (kyberDao != _kyberDao) {
            kyberDao = _kyberDao;
            kyberStorage.setKyberDaoContract(address(_kyberDao));
            emit KyberDaoUpdated(_kyberDao);
        }
    }

    function setParams(uint256 _maxGasPrice, uint256 _negligibleRateDiffBps) external {

        onlyAdmin();
        maxGasPriceValue = _maxGasPrice;
        kyberMatchingEngine.setNegligibleRateDiffBps(_negligibleRateDiffBps);
        emit KyberNetworkParamsSet(maxGasPriceValue, _negligibleRateDiffBps);
    }

    function setEnable(bool enable) external {

        onlyAdmin();

        if (enable) {
            require(kyberFeeHandler != IKyberFeeHandler(0));
            require(kyberMatchingEngine != IKyberMatchingEngine(0));
            require(kyberStorage.isKyberProxyAdded());
        }

        isEnabled = enable;

        emit KyberNetworkSetEnable(isEnabled);
    }

    function addKyberProxy(address kyberProxy) external virtual {

        onlyAdmin();
        kyberStorage.addKyberProxy(kyberProxy, MAX_APPROVED_PROXIES);
        require(kyberProxy != address(0));
        require(!kyberProxyContracts[kyberProxy]);

        kyberProxyContracts[kyberProxy] = true;

        emit KyberProxyAdded(kyberProxy);
    }

    function removeKyberProxy(address kyberProxy) external virtual {

        onlyAdmin();

        kyberStorage.removeKyberProxy(kyberProxy);

        require(kyberProxyContracts[kyberProxy]);

        kyberProxyContracts[kyberProxy] = false;

        emit KyberProxyRemoved(kyberProxy);
    }

    function getExpectedRateWithHintAndFee(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 platformFeeBps,
        bytes calldata hint
    )
        external
        view
        override
        returns (
            uint256 rateWithNetworkFee,
            uint256 rateWithAllFees
        )
    {

        if (src == dest) return (0, 0);

        TradeData memory tradeData = initTradeInput({
            trader: payable(address(0)),
            src: src,
            dest: dest,
            srcAmount: (srcQty == 0) ? 1 : srcQty,
            destAddress: payable(address(0)),
            maxDestAmount: 2**255,
            minConversionRate: 0,
            platformWallet: payable(address(0)),
            platformFeeBps: platformFeeBps
        });

        tradeData.networkFeeBps = getNetworkFee();

        uint256 destAmount;
        (destAmount, rateWithNetworkFee) = calcRatesAndAmounts(tradeData, hint);

        rateWithAllFees = calcRateFromQty(
            tradeData.input.srcAmount,
            destAmount,
            tradeData.tokenToEth.decimals,
            tradeData.ethToToken.decimals
        );
    }

    function getExpectedRate(
        ERC20 src,
        ERC20 dest,
        uint256 srcQty
    ) external view returns (uint256 expectedRate, uint256 worstRate) {

        if (src == dest) return (0, 0);
        uint256 qty = srcQty & ~PERM_HINT_GET_RATE;

        TradeData memory tradeData = initTradeInput({
            trader: payable(address(0)),
            src: src,
            dest: dest,
            srcAmount: (qty == 0) ? 1 : qty,
            destAddress: payable(address(0)),
            maxDestAmount: 2**255,
            minConversionRate: 0,
            platformWallet: payable(address(0)),
            platformFeeBps: 0
        });

        tradeData.networkFeeBps = getNetworkFee();

        (, expectedRate) = calcRatesAndAmounts(tradeData, "");

        worstRate = (expectedRate * 97) / 100; // backward compatible formula
    }

    function getNetworkData()
        external
        view
        override
        returns (
            uint256 negligibleDiffBps,
            uint256 networkFeeBps,
            uint256 expiryTimestamp
        )
    {

        (networkFeeBps, expiryTimestamp) = readNetworkFeeData();
        negligibleDiffBps = kyberMatchingEngine.getNegligibleRateDiffBps();
        return (negligibleDiffBps, networkFeeBps, expiryTimestamp);
    }

    function getContracts()
        external
        view
        returns (
            IKyberFeeHandler kyberFeeHandlerAddress,
            IKyberDao kyberDaoAddress,
            IKyberMatchingEngine kyberMatchingEngineAddress,
            IKyberStorage kyberStorageAddress,
            IGasHelper gasHelperAddress,
            IKyberNetworkProxy[] memory kyberProxyAddresses
        )
    {

        return (
            kyberFeeHandler,
            kyberDao,
            kyberMatchingEngine,
            kyberStorage,
            gasHelper,
            kyberStorage.getKyberProxies()
        );
    }

    function maxGasPrice() external view override returns (uint256) {

        return maxGasPriceValue;
    }

    function enabled() external view override returns (bool) {

        return isEnabled;
    }

    function getAndUpdateNetworkFee() public returns (uint256 networkFeeBps) {

        uint256 expiryTimestamp;

        (networkFeeBps, expiryTimestamp) = readNetworkFeeData();

        if (expiryTimestamp < now && kyberDao != IKyberDao(0)) {
            (networkFeeBps, expiryTimestamp) = kyberDao.getLatestNetworkFeeDataWithCache();
            updateNetworkFee(expiryTimestamp, networkFeeBps);
        }
    }

    function handleFees(TradeData memory tradeData) internal {

        uint256 sentFee = tradeData.networkFeeWei + tradeData.platformFeeWei;
        if (sentFee == 0)
            return;

        (
            address[] memory rebateWallets,
            uint256[] memory rebatePercentBps
        ) = calculateRebates(tradeData);

        kyberFeeHandler.handleFees{value: sentFee}(
            ETH_TOKEN_ADDRESS,
            rebateWallets,
            rebatePercentBps,
            tradeData.input.platformWallet,
            tradeData.platformFeeWei,
            tradeData.networkFeeWei
        );
    }

    function updateNetworkFee(uint256 expiryTimestamp, uint256 feeBps) internal {

        require(expiryTimestamp < 2**64, "expiry overflow");
        require(feeBps < BPS / 2, "fees exceed BPS");

        networkFeeData.expiryTimestamp = uint64(expiryTimestamp);
        networkFeeData.feeBps = uint16(feeBps);
    }

    function doReserveTrades(
        IERC20 src,
        IERC20 dest,
        address payable destAddress,
        ReservesData memory reservesData,
        uint256 expectedDestAmount,
        uint256 srcDecimals,
        uint256 destDecimals
    ) internal virtual {


        if (src == dest) {
            if (destAddress != (address(this))) {
                (bool success, ) = destAddress.call{value: expectedDestAmount}("");
                require(success, "send dest qty failed");
            }
            return;
        }

        tradeAndVerifyNetworkBalance(
            reservesData,
            src,
            dest,
            srcDecimals,
            destDecimals
        );

        if (destAddress != address(this)) {
            dest.safeTransfer(destAddress, expectedDestAmount);
        }
    }

    function tradeAndVerifyNetworkBalance(
        ReservesData memory reservesData,
        IERC20 src,
        IERC20 dest,
        uint256 srcDecimals,
        uint256 destDecimals
    ) internal
    {

        uint256 srcBalanceBefore = (src == ETH_TOKEN_ADDRESS) ? 0 : getBalance(src, address(this));
        uint256 destBalanceBefore = getBalance(dest, address(this));

        for(uint256 i = 0; i < reservesData.addresses.length; i++) {
            uint256 callValue = (src == ETH_TOKEN_ADDRESS) ? reservesData.srcAmounts[i] : 0;
            require(
                reservesData.addresses[i].trade{value: callValue}(
                    src,
                    reservesData.srcAmounts[i],
                    dest,
                    address(this),
                    reservesData.rates[i],
                    true
                ),
                "reserve trade failed"
            );

            uint256 balanceAfter;
            if (src != ETH_TOKEN_ADDRESS) {
                balanceAfter = getBalance(src, address(this));
                if (srcBalanceBefore >= balanceAfter && srcBalanceBefore - balanceAfter > reservesData.srcAmounts[i]) {
                    revert("reserve takes high amount");
                }
                srcBalanceBefore = balanceAfter;
            }

            uint256 expectedDestAmount = calcDstQty(
                reservesData.srcAmounts[i],
                srcDecimals,
                destDecimals,
                reservesData.rates[i]
            );
            balanceAfter = getBalance(dest, address(this));
            if (balanceAfter < destBalanceBefore || balanceAfter - destBalanceBefore < expectedDestAmount) {
                revert("reserve returns low amount");
            }
            destBalanceBefore = balanceAfter;
        }
    }

    function trade(TradeData memory tradeData, bytes memory hint)
        internal
        virtual
        nonReentrant
        returns (uint256 destAmount)
    {

        tradeData.networkFeeBps = getAndUpdateNetworkFee();

        validateTradeInput(tradeData.input);

        uint256 rateWithNetworkFee;
        (destAmount, rateWithNetworkFee) = calcRatesAndAmounts(tradeData, hint);

        require(rateWithNetworkFee > 0, "trade invalid, if hint involved, try parseHint API");
        require(rateWithNetworkFee < MAX_RATE, "rate > MAX_RATE");
        require(rateWithNetworkFee >= tradeData.input.minConversionRate, "rate < min rate");

        uint256 actualSrcAmount;

        if (destAmount > tradeData.input.maxDestAmount) {
            destAmount = tradeData.input.maxDestAmount;
            actualSrcAmount = calcTradeSrcAmountFromDest(tradeData);
        } else {
            actualSrcAmount = tradeData.input.srcAmount;
        }

        doReserveTrades(
            tradeData.input.src,
            ETH_TOKEN_ADDRESS,
            address(this),
            tradeData.tokenToEth,
            tradeData.tradeWei,
            tradeData.tokenToEth.decimals,
            ETH_DECIMALS
        );

        doReserveTrades(
            ETH_TOKEN_ADDRESS,
            tradeData.input.dest,
            tradeData.input.destAddress,
            tradeData.ethToToken,
            destAmount,
            ETH_DECIMALS,
            tradeData.ethToToken.decimals
        );

        handleChange(
            tradeData.input.src,
            tradeData.input.srcAmount,
            actualSrcAmount,
            tradeData.input.trader
        );

        handleFees(tradeData);

        emit KyberTrade({
            src: tradeData.input.src,
            dest: tradeData.input.dest,
            ethWeiValue: tradeData.tradeWei,
            networkFeeWei: tradeData.networkFeeWei,
            customPlatformFeeWei: tradeData.platformFeeWei,
            t2eIds: tradeData.tokenToEth.ids,
            e2tIds: tradeData.ethToToken.ids,
            t2eSrcAmounts: tradeData.tokenToEth.srcAmounts,
            e2tSrcAmounts: tradeData.ethToToken.srcAmounts,
            t2eRates: tradeData.tokenToEth.rates,
            e2tRates: tradeData.ethToToken.rates
        });

        if (gasHelper != IGasHelper(0)) {
            (bool success, ) = address(gasHelper).call(
                abi.encodeWithSignature(
                    "freeGas(address,address,address,uint256,bytes32[],bytes32[])",
                    tradeData.input.platformWallet,
                    tradeData.input.src,
                    tradeData.input.dest,
                    tradeData.tradeWei,
                    tradeData.tokenToEth.ids,
                    tradeData.ethToToken.ids
                )
            );
            success;
        }

        return (destAmount);
    }

    function handleChange(
        IERC20 src,
        uint256 srcAmount,
        uint256 requiredSrcAmount,
        address payable trader
    ) internal {

        if (requiredSrcAmount < srcAmount) {
            if (src == ETH_TOKEN_ADDRESS) {
                (bool success, ) = trader.call{value: (srcAmount - requiredSrcAmount)}("");
                require(success, "Send change failed");
            } else {
                src.safeTransfer(trader, (srcAmount - requiredSrcAmount));
            }
        }
    }

    function initTradeInput(
        address payable trader,
        IERC20 src,
        IERC20 dest,
        uint256 srcAmount,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps
    ) internal view returns (TradeData memory tradeData) {

        tradeData.input.trader = trader;
        tradeData.input.src = src;
        tradeData.input.srcAmount = srcAmount;
        tradeData.input.dest = dest;
        tradeData.input.destAddress = destAddress;
        tradeData.input.maxDestAmount = maxDestAmount;
        tradeData.input.minConversionRate = minConversionRate;
        tradeData.input.platformWallet = platformWallet;
        tradeData.input.platformFeeBps = platformFeeBps;

        tradeData.tokenToEth.decimals = getDecimals(src);
        tradeData.ethToToken.decimals = getDecimals(dest);
    }

    function calcRatesAndAmounts(TradeData memory tradeData, bytes memory hint)
        internal
        view
        returns (uint256 destAmount, uint256 rateWithNetworkFee)
    {

        validateFeeInput(tradeData.input, tradeData.networkFeeBps);

        tradeData.tradeWei = calcDestQtyAndMatchReserves(
            tradeData.input.src,
            ETH_TOKEN_ADDRESS,
            tradeData.input.srcAmount,
            tradeData,
            tradeData.tokenToEth,
            hint
        );

        require(tradeData.tradeWei <= MAX_QTY, "Trade wei > MAX_QTY");
        if (tradeData.tradeWei == 0) {
            return (0, 0);
        }

        tradeData.platformFeeWei = (tradeData.tradeWei * tradeData.input.platformFeeBps) / BPS;
        tradeData.networkFeeWei =
            (((tradeData.tradeWei * tradeData.networkFeeBps) / BPS) * tradeData.feeAccountedBps) /
            BPS;

        assert(tradeData.tradeWei >= (tradeData.networkFeeWei + tradeData.platformFeeWei));

        uint256 actualSrcWei = tradeData.tradeWei -
            tradeData.networkFeeWei -
            tradeData.platformFeeWei;

        destAmount = calcDestQtyAndMatchReserves(
            ETH_TOKEN_ADDRESS,
            tradeData.input.dest,
            actualSrcWei,
            tradeData,
            tradeData.ethToToken,
            hint
        );

        tradeData.networkFeeWei =
            (((tradeData.tradeWei * tradeData.networkFeeBps) / BPS) * tradeData.feeAccountedBps) /
            BPS;

        rateWithNetworkFee = calcRateFromQty(
            tradeData.input.srcAmount * (BPS - tradeData.input.platformFeeBps) / BPS,
            destAmount,
            tradeData.tokenToEth.decimals,
            tradeData.ethToToken.decimals
        );
    }

    function calcDestQtyAndMatchReserves(
        IERC20 src,
        IERC20 dest,
        uint256 srcAmount,
        TradeData memory tradeData,
        ReservesData memory reservesData,
        bytes memory hint
    ) internal view returns (uint256 destAmount) {

        if (src == dest) {
            return srcAmount;
        }

        IKyberMatchingEngine.ProcessWithRate processWithRate;

        (reservesData.ids, reservesData.splitsBps, processWithRate) =
            kyberMatchingEngine.getTradingReserves(
            src,
            dest,
            (tradeData.input.src != ETH_TOKEN_ADDRESS) && (tradeData.input.dest != ETH_TOKEN_ADDRESS),
            hint
        );
        bool areAllReservesListed;
        (areAllReservesListed, reservesData.isFeeAccountedFlags, reservesData.isEntitledRebateFlags, reservesData.addresses)
            = kyberStorage.getReservesData(reservesData.ids, src, dest);

        if(!areAllReservesListed) {
            return 0;
        }

        require(reservesData.ids.length == reservesData.splitsBps.length, "bad split array");
        require(reservesData.ids.length == reservesData.isFeeAccountedFlags.length, "bad fee array");
        require(reservesData.ids.length == reservesData.isEntitledRebateFlags.length, "bad rebate array");
        require(reservesData.ids.length == reservesData.addresses.length, "bad addresses array");

        uint256[] memory feesAccountedDestBps = calcSrcAmountsAndGetRates(
            reservesData,
            src,
            dest,
            srcAmount,
            tradeData
        );

        if (processWithRate == IKyberMatchingEngine.ProcessWithRate.Required) {
            uint256[] memory selectedIndexes = kyberMatchingEngine.doMatch(
                src,
                dest,
                reservesData.srcAmounts,
                feesAccountedDestBps,
                reservesData.rates
            );

            updateReservesList(reservesData, selectedIndexes);
        }

        destAmount = validateTradeCalcDestQtyAndFeeData(src, reservesData, tradeData);
    }

    function calcSrcAmountsAndGetRates(
        ReservesData memory reservesData,
        IERC20 src,
        IERC20 dest,
        uint256 srcAmount,
        TradeData memory tradeData
    ) internal view returns (uint256[] memory feesAccountedDestBps) {

        uint256 numReserves = reservesData.ids.length;
        uint256 srcAmountAfterFee;
        uint256 destAmountFeeBps;

        if (src == ETH_TOKEN_ADDRESS) {
            srcAmountAfterFee = srcAmount - 
                (tradeData.tradeWei * tradeData.networkFeeBps / BPS);
        } else { 
            srcAmountAfterFee = srcAmount;
            destAmountFeeBps = tradeData.networkFeeBps;
        }

        reservesData.srcAmounts = new uint256[](numReserves);
        reservesData.rates = new uint256[](numReserves);
        feesAccountedDestBps = new uint256[](numReserves);

        for (uint256 i = 0; i < numReserves; i++) {
            require(
                reservesData.splitsBps[i] > 0 && reservesData.splitsBps[i] <= BPS,
                "invalid split bps"
            );

            if (reservesData.isFeeAccountedFlags[i]) {
                reservesData.srcAmounts[i] = srcAmountAfterFee * reservesData.splitsBps[i] / BPS;
                feesAccountedDestBps[i] = destAmountFeeBps;
            } else {
                reservesData.srcAmounts[i] = (srcAmount * reservesData.splitsBps[i]) / BPS;
            }

            reservesData.rates[i] = reservesData.addresses[i].getConversionRate(
                src,
                dest,
                reservesData.srcAmounts[i],
                block.number
            );
        }
    }

    function calculateRebates(TradeData memory tradeData)
        internal
        view
        returns (address[] memory rebateWallets, uint256[] memory rebatePercentBps)
    {

        rebateWallets = new address[](tradeData.numEntitledRebateReserves);
        rebatePercentBps = new uint256[](tradeData.numEntitledRebateReserves);
        if (tradeData.numEntitledRebateReserves == 0) {
            return (rebateWallets, rebatePercentBps);
        }

        uint256 index;
        bytes32[] memory rebateReserveIds = new bytes32[](tradeData.numEntitledRebateReserves);

        index = createRebateEntitledList(
            rebateReserveIds,
            rebatePercentBps,
            tradeData.tokenToEth,
            index,
            tradeData.feeAccountedBps
        );

        createRebateEntitledList(
            rebateReserveIds,
            rebatePercentBps,
            tradeData.ethToToken,
            index,
            tradeData.feeAccountedBps
        );

        rebateWallets = kyberStorage.getRebateWalletsFromIds(rebateReserveIds);
    }

    function createRebateEntitledList(
        bytes32[] memory rebateReserveIds,
        uint256[] memory rebatePercentBps,
        ReservesData memory reservesData,
        uint256 index,
        uint256 feeAccountedBps
    ) internal pure returns (uint256) {

        uint256 _index = index;

        for (uint256 i = 0; i < reservesData.isEntitledRebateFlags.length; i++) {
            if (reservesData.isEntitledRebateFlags[i]) {
                rebateReserveIds[_index] = reservesData.ids[i];
                rebatePercentBps[_index] = (reservesData.splitsBps[i] * BPS) / feeAccountedBps;
                _index++;
            }
        }
        return _index;
    }

    function validateTradeInput(TradeInput memory input) internal view
    {

        require(isEnabled, "network disabled");
        require(kyberProxyContracts[msg.sender], "bad sender");
        require(tx.gasprice <= maxGasPriceValue, "gas price");
        require(input.srcAmount <= MAX_QTY, "srcAmt > MAX_QTY");
        require(input.srcAmount != 0, "0 srcAmt");
        require(input.destAddress != address(0), "dest add 0");
        require(input.src != input.dest, "src = dest");

        if (input.src == ETH_TOKEN_ADDRESS) {
            require(msg.value == input.srcAmount); // kyberProxy issues message here
        } else {
            require(msg.value == 0); // kyberProxy issues message here
            require(input.src.balanceOf(address(this)) >= input.srcAmount, "no tokens");
        }
    }

    function getNetworkFee() internal view returns (uint256 networkFeeBps) {

        uint256 expiryTimestamp;
        (networkFeeBps, expiryTimestamp) = readNetworkFeeData();

        if (expiryTimestamp < now && kyberDao != IKyberDao(0)) {
            (networkFeeBps, expiryTimestamp) = kyberDao.getLatestNetworkFeeData();
        }
    }

    function readNetworkFeeData() internal view returns (uint256 feeBps, uint256 expiryTimestamp) {

        feeBps = uint256(networkFeeData.feeBps);
        expiryTimestamp = uint256(networkFeeData.expiryTimestamp);
    }

    function validateFeeInput(TradeInput memory input, uint256 networkFeeBps) internal pure {

        require(input.platformFeeBps < BPS, "platformFee high");
        require(input.platformFeeBps + networkFeeBps + networkFeeBps < BPS, "fees high");
    }

    function updateReservesList(ReservesData memory reservesData, uint256[] memory selectedIndexes)
        internal
        pure
    {

        uint256 numReserves = selectedIndexes.length;

        require(numReserves <= reservesData.addresses.length, "doMatch: too many reserves");

        IKyberReserve[] memory reserveAddresses = new IKyberReserve[](numReserves);
        bytes32[] memory reserveIds = new bytes32[](numReserves);
        uint256[] memory splitsBps = new uint256[](numReserves);
        bool[] memory isFeeAccountedFlags = new bool[](numReserves);
        bool[] memory isEntitledRebateFlags = new bool[](numReserves);
        uint256[] memory srcAmounts = new uint256[](numReserves);
        uint256[] memory rates = new uint256[](numReserves);

        for (uint256 i = 0; i < numReserves; i++) {
            reserveAddresses[i] = reservesData.addresses[selectedIndexes[i]];
            reserveIds[i] = reservesData.ids[selectedIndexes[i]];
            splitsBps[i] = reservesData.splitsBps[selectedIndexes[i]];
            isFeeAccountedFlags[i] = reservesData.isFeeAccountedFlags[selectedIndexes[i]];
            isEntitledRebateFlags[i] = reservesData.isEntitledRebateFlags[selectedIndexes[i]];
            srcAmounts[i] = reservesData.srcAmounts[selectedIndexes[i]];
            rates[i] = reservesData.rates[selectedIndexes[i]];
        }

        reservesData.addresses = reserveAddresses;
        reservesData.ids = reserveIds;
        reservesData.splitsBps = splitsBps;
        reservesData.isFeeAccountedFlags = isFeeAccountedFlags;
        reservesData.isEntitledRebateFlags = isEntitledRebateFlags;
        reservesData.rates = rates;
        reservesData.srcAmounts = srcAmounts;
    }

    function validateTradeCalcDestQtyAndFeeData(
        IERC20 src,
        ReservesData memory reservesData,
        TradeData memory tradeData
    ) internal pure returns (uint256 totalDestAmount) {

        uint256 totalBps;
        uint256 srcDecimals = (src == ETH_TOKEN_ADDRESS) ? ETH_DECIMALS : reservesData.decimals;
        uint256 destDecimals = (src == ETH_TOKEN_ADDRESS) ? reservesData.decimals : ETH_DECIMALS;
        
        for (uint256 i = 0; i < reservesData.addresses.length; i++) {
            if (i > 0 && (uint256(reservesData.ids[i]) <= uint256(reservesData.ids[i - 1]))) {
                return 0; // ids are not in increasing order
            }
            totalBps += reservesData.splitsBps[i];

            uint256 destAmount = calcDstQty(
                reservesData.srcAmounts[i],
                srcDecimals,
                destDecimals,
                reservesData.rates[i]
            );
            if (destAmount == 0) {
                return 0;
            }
            totalDestAmount += destAmount;

            if (reservesData.isFeeAccountedFlags[i]) {
                tradeData.feeAccountedBps += reservesData.splitsBps[i];

                if (reservesData.isEntitledRebateFlags[i]) {
                    tradeData.numEntitledRebateReserves++;
                }
            }
        }

        if (totalBps != BPS) {
            return 0;
        }
    }

    function calcTradeSrcAmountFromDest(TradeData memory tradeData)
        internal
        pure
        virtual
        returns (uint256 actualSrcAmount)
    {

        uint256 weiAfterDeductingFees;
        if (tradeData.input.dest != ETH_TOKEN_ADDRESS) {
            weiAfterDeductingFees = calcTradeSrcAmount(
                tradeData.tradeWei - tradeData.platformFeeWei - tradeData.networkFeeWei,
                ETH_DECIMALS,
                tradeData.ethToToken.decimals,
                tradeData.input.maxDestAmount,
                tradeData.ethToToken
            );
        } else {
            weiAfterDeductingFees = tradeData.input.maxDestAmount;
        }

        uint256 newTradeWei =
            (weiAfterDeductingFees * BPS * BPS) /
            ((BPS * BPS) -
                (tradeData.networkFeeBps *
                tradeData.feeAccountedBps +
                tradeData.input.platformFeeBps *
                BPS));
        tradeData.tradeWei = minOf(newTradeWei, tradeData.tradeWei);
        tradeData.networkFeeWei =
            (((tradeData.tradeWei * tradeData.networkFeeBps) / BPS) * tradeData.feeAccountedBps) /
            BPS;
        tradeData.platformFeeWei = (tradeData.tradeWei * tradeData.input.platformFeeBps) / BPS;

        if (tradeData.input.src != ETH_TOKEN_ADDRESS) {
            actualSrcAmount = calcTradeSrcAmount(
                tradeData.input.srcAmount,
                tradeData.tokenToEth.decimals,
                ETH_DECIMALS,
                tradeData.tradeWei,
                tradeData.tokenToEth
            );
        } else {
            actualSrcAmount = tradeData.tradeWei;
        }

        assert(actualSrcAmount <= tradeData.input.srcAmount);
    }

    function calcTradeSrcAmount(
        uint256 srcAmount,
        uint256 srcDecimals,
        uint256 destDecimals,
        uint256 destAmount,
        ReservesData memory reservesData
    ) internal pure returns (uint256 newSrcAmount) {

        uint256 totalWeightedDestAmount;
        for (uint256 i = 0; i < reservesData.srcAmounts.length; i++) {
            totalWeightedDestAmount += reservesData.srcAmounts[i] * reservesData.rates[i];
        }

        uint256[] memory newSrcAmounts = new uint256[](reservesData.srcAmounts.length);
        uint256 destAmountSoFar;
        uint256 currentSrcAmount;
        uint256 destAmountSplit;

        for (uint256 i = 0; i < reservesData.srcAmounts.length; i++) {
            currentSrcAmount = reservesData.srcAmounts[i];
            require(destAmount * currentSrcAmount * reservesData.rates[i] / destAmount == 
                    currentSrcAmount * reservesData.rates[i], 
                "multiplication overflow");
            destAmountSplit = i == (reservesData.srcAmounts.length - 1)
                ? (destAmount - destAmountSoFar)
                : (destAmount * currentSrcAmount * reservesData.rates[i]) /
                    totalWeightedDestAmount;
            destAmountSoFar += destAmountSplit;

            newSrcAmounts[i] = calcSrcQty(
                destAmountSplit,
                srcDecimals,
                destDecimals,
                reservesData.rates[i]
            );
            if (newSrcAmounts[i] > currentSrcAmount) {
                return srcAmount;
            }

            newSrcAmount += newSrcAmounts[i];
        }
        reservesData.srcAmounts = newSrcAmounts;
    }
}