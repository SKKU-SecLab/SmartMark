

pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;


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

library LibEIP712 {

    string internal constant DOMAIN_NAME = "Mai Protocol";

    bytes32 private constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked("EIP712Domain(string name)"));

    bytes32 private constant DOMAIN_SEPARATOR = keccak256(
        abi.encodePacked(EIP712_DOMAIN_TYPEHASH, keccak256(bytes(DOMAIN_NAME)))
    );

    function hashEIP712Message(bytes32 eip712hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, eip712hash));
    }
}

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            return (address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

library LibSignature {

    enum SignatureMethod {ETH_SIGN, EIP712}

    struct OrderSignature {
        bytes32 config;
        bytes32 r;
        bytes32 s;
    }

    function isValidSignature(OrderSignature memory signature, bytes32 hash, address signerAddress)
        internal
        pure
        returns (bool)
    {

        uint8 method = uint8(signature.config[1]);
        address recovered;
        uint8 v = uint8(signature.config[0]);

        if (method == uint8(SignatureMethod.ETH_SIGN)) {
            recovered = recover(
                keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)),
                v,
                signature.r,
                signature.s
            );
        } else if (method == uint8(SignatureMethod.EIP712)) {
            recovered = recover(hash, v, signature.r, signature.s);
        } else {
            revert("invalid sign method");
        }

        return signerAddress == recovered;
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            revert("ECDSA: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECDSA: invalid signature 'v' value");
        }

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }
}

library LibMathSigned {

    int256 private constant _WAD = 10 ** 18;
    int256 private constant _INT256_MIN = -2 ** 255;

    uint8 private constant FIXED_DIGITS = 18;
    int256 private constant FIXED_1 = 10 ** 18;
    int256 private constant FIXED_E = 2718281828459045235;
    uint8 private constant LONGER_DIGITS = 36;
    int256 private constant LONGER_FIXED_LOG_E_1_5 = 405465108108164381978013115464349137;
    int256 private constant LONGER_FIXED_1 = 10 ** 36;
    int256 private constant LONGER_FIXED_LOG_E_10 = 2302585092994045684017991454684364208;


    function WAD() internal pure returns (int256) {

        return _WAD;
    }

    function neg(int256 a) internal pure returns (int256) {

        return sub(int256(0), a);
    }

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }
        require(!(a == -1 && b == _INT256_MIN), "wmultiplication overflow");

        int256 c = a * b;
        require(c / a == b, "wmultiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "wdivision by zero");
        require(!(b == -1 && a == _INT256_MIN), "wdivision overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "addition overflow");

        return c;
    }

    function wmul(int256 x, int256 y) internal pure returns (int256 z) {

        z = roundHalfUp(mul(x, y), _WAD) / _WAD;
    }

    function wdiv(int256 x, int256 y) internal pure returns (int256 z) {

        if (y < 0) {
            y = -y;
            x = -x;
        }
        z = roundHalfUp(mul(x, _WAD), y) / y;
    }

    function wfrac(int256 x, int256 y, int256 z) internal pure returns (int256 r) {

        int256 t = mul(x, y);
        if (z < 0) {
            z = neg(z);
            t = neg(t);
        }
        r = roundHalfUp(t, z) / z;
    }

    function min(int256 x, int256 y) internal pure returns (int256) {

        return x <= y ? x : y;
    }

    function max(int256 x, int256 y) internal pure returns (int256) {

        return x >= y ? x : y;
    }

    function toUint256(int256 x) internal pure returns (uint256) {

        require(x >= 0, "int overflow");
        return uint256(x);
    }

    function wpowi(int256 x, int256 n) internal pure returns (int256 z) {

        require(n >= 0, "wpowi only supports n >= 0");
        z = n % 2 != 0 ? x : _WAD;

        for (n /= 2; n != 0; n /= 2) {
            x = wmul(x, x);

            if (n % 2 != 0) {
                z = wmul(z, x);
            }
        }
    }

    function roundHalfUp(int256 x, int256 y) internal pure returns (int256) {

        require(y > 0, "roundHalfUp only supports y > 0");
        if (x >= 0) {
            return add(x, y / 2);
        }
        return sub(x, y / 2);
    }

    function wln(int256 x) internal pure returns (int256) {

        require(x > 0, "logE of negative number");
        require(x <= 10000000000000000000000000000000000000000, "logE only accepts v <= 1e22 * 1e18"); // in order to prevent using safe-math
        int256 r = 0;
        uint8 extraDigits = LONGER_DIGITS - FIXED_DIGITS;
        int256 t = int256(uint256(10)**uint256(extraDigits));

        while (x <= FIXED_1 / 10) {
            x = x * 10;
            r -= LONGER_FIXED_LOG_E_10;
        }
        while (x >= 10 * FIXED_1) {
            x = x / 10;
            r += LONGER_FIXED_LOG_E_10;
        }
        while (x < FIXED_1) {
            x = wmul(x, FIXED_E);
            r -= LONGER_FIXED_1;
        }
        while (x > FIXED_E) {
            x = wdiv(x, FIXED_E);
            r += LONGER_FIXED_1;
        }
        if (x == FIXED_1) {
            return roundHalfUp(r, t) / t;
        }
        if (x == FIXED_E) {
            return FIXED_1 + roundHalfUp(r, t) / t;
        }
        x *= t;

        r = r + LONGER_FIXED_LOG_E_1_5;
        int256 a1_5 = (3 * LONGER_FIXED_1) / 2;
        int256 m = (LONGER_FIXED_1 * (x - a1_5)) / (x + a1_5);
        r = r + 2 * m;
        int256 m2 = (m * m) / LONGER_FIXED_1;
        uint8 i = 3;
        while (true) {
            m = (m * m2) / LONGER_FIXED_1;
            r = r + (2 * m) / int256(i);
            i += 2;
            if (i >= 3 + 2 * FIXED_DIGITS) {
                break;
            }
        }
        return roundHalfUp(r, t) / t;
    }

    function logBase(int256 base, int256 x) internal pure returns (int256) {

        return wdiv(wln(x), wln(base));
    }

    function ceil(int256 x, int256 m) internal pure returns (int256) {

        require(x >= 0, "ceil need x >= 0");
        require(m > 0, "ceil need m > 0");
        return (sub(add(x, m), 1) / m) * m;
    }
}

library LibMathUnsigned {

    uint256 private constant _WAD = 10**18;
    uint256 private constant _POSITIVE_INT256_MAX = 2**255 - 1;

    function WAD() internal pure returns (uint256) {

        return _WAD;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "Unaddition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "Unsubtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "Unmultiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "Undivision by zero");
        uint256 c = a / b;

        return c;
    }

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), _WAD / 2) / _WAD;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, _WAD), y / 2) / y;
    }

    function wfrac(uint256 x, uint256 y, uint256 z) internal pure returns (uint256 r) {

        r = mul(x, y) / z;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {

        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256) {

        return x >= y ? x : y;
    }

    function toInt256(uint256 x) internal pure returns (int256) {

        require(x <= _POSITIVE_INT256_MAX, "uint256 overflow");
        return int256(x);
    }

    function mod(uint256 x, uint256 m) internal pure returns (uint256) {

        require(m != 0, "mod by zero");
        return x % m;
    }

    function ceil(uint256 x, uint256 m) internal pure returns (uint256) {

        require(m > 0, "ceil need m > 0");
        return (sub(add(x, m), 1) / m) * m;
    }
}

library LibTypes {

    enum Side {FLAT, SHORT, LONG}

    enum Status {NORMAL, EMERGENCY, SETTLED}

    function counterSide(Side side) internal pure returns (Side) {

        if (side == Side.LONG) {
            return Side.SHORT;
        } else if (side == Side.SHORT) {
            return Side.LONG;
        }
        return side;
    }

    struct PerpGovernanceConfig {
        uint256 initialMarginRate;
        uint256 maintenanceMarginRate;
        uint256 liquidationPenaltyRate;
        uint256 penaltyFundRate;
        int256 takerDevFeeRate;
        int256 makerDevFeeRate;
        uint256 lotSize;
        uint256 tradingLotSize;
    }

    struct MarginAccount {
        LibTypes.Side side;
        uint256 size;
        uint256 entryValue;
        int256 entrySocialLoss;
        int256 entryFundingLoss;
        int256 cashBalance;
    }

    struct AMMGovernanceConfig {
        uint256 poolFeeRate;
        uint256 poolDevFeeRate;
        int256 emaAlpha;
        uint256 updatePremiumPrize;
        int256 markPremiumLimit;
        int256 fundingDampener;
    }

    struct FundingState {
        uint256 lastFundingTime;
        int256 lastPremium;
        int256 lastEMAPremium;
        uint256 lastIndexPrice;
        int256 accumulatedFundingPerContract;
    }
}

library LibOrder {

    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;

    bytes32 public constant EIP712_ORDER_TYPE = keccak256(
        abi.encodePacked(
            "Order(address trader,address broker,address perpetual,uint256 amount,uint256 price,bytes32 data)"
        )
    );

    int256 public constant FEE_RATE_BASE = 10 ** 5;

    struct Order {
        address trader;
        address broker;
        address perpetual;
        uint256 amount;
        uint256 price;
        bytes32 data;
    }

    struct OrderParam {
        address trader;
        uint256 amount;
        uint256 price;
        bytes32 data;
        LibSignature.OrderSignature signature;
    }

    function getOrderHash(
        OrderParam memory orderParam,
        address perpetual,
        address broker
    ) internal pure returns (bytes32 orderHash) {

        Order memory order = getOrder(orderParam, perpetual, broker);
        orderHash = LibEIP712.hashEIP712Message(hashOrder(order));
    }

    function getOrderHash(Order memory order) internal pure returns (bytes32 orderHash) {

        orderHash = LibEIP712.hashEIP712Message(hashOrder(order));
    }

    function getOrder(
        OrderParam memory orderParam,
        address perpetual,
        address broker
    ) internal pure returns (LibOrder.Order memory order) {

        order.trader = orderParam.trader;
        order.broker = broker;
        order.perpetual = perpetual;
        order.amount = orderParam.amount;
        order.price = orderParam.price;
        order.data = orderParam.data;
    }

    function hashOrder(Order memory order) internal pure returns (bytes32 result) {

        bytes32 orderType = EIP712_ORDER_TYPE;
        assembly {
            let start := sub(order, 32)
            let tmp := mload(start)
            mstore(start, orderType)
            result := keccak256(start, 224)
            mstore(start, tmp)
        }
    }


    function orderVersion(OrderParam memory orderParam) internal pure returns (uint256) {

        return uint256(uint8(bytes1(orderParam.data)));
    }

    function expiredAt(OrderParam memory orderParam) internal pure returns (uint256) {

        return uint256(uint40(bytes5(orderParam.data << (8 * 3))));
    }

    function isSell(OrderParam memory orderParam) internal pure returns (bool) {

        bool sell = uint8(orderParam.data[1]) == 1;
        return isInversed(orderParam) ? !sell : sell;
    }

    function getPrice(OrderParam memory orderParam) internal pure returns (uint256) {

        return isInversed(orderParam) ? LibMathUnsigned.WAD().wdiv(orderParam.price) : orderParam.price;
    }

    function isMarketOrder(OrderParam memory orderParam) internal pure returns (bool) {

        return uint8(orderParam.data[2]) > 0;
    }

    function isMarketBuy(OrderParam memory orderParam) internal pure returns (bool) {

        return !isSell(orderParam) && isMarketOrder(orderParam);
    }

    function isMakerOnly(OrderParam memory orderParam) internal pure returns (bool) {

        return uint8(orderParam.data[22]) > 0;
    }

    function isInversed(OrderParam memory orderParam) internal pure returns (bool) {

        return uint8(orderParam.data[23]) > 0;
    }

    function side(OrderParam memory orderParam) internal pure returns (LibTypes.Side) {

        return isSell(orderParam) ? LibTypes.Side.SHORT : LibTypes.Side.LONG;
    }

    function makerFeeRate(OrderParam memory orderParam) internal pure returns (int256) {

        return int256(int16(bytes2(orderParam.data << (8 * 8)))).mul(LibMathSigned.WAD()).div(FEE_RATE_BASE);
    }

    function takerFeeRate(OrderParam memory orderParam) internal pure returns (int256) {

        return int256(int16(bytes2(orderParam.data << (8 * 10)))).mul(LibMathSigned.WAD()).div(FEE_RATE_BASE);
    }

    function chainId(OrderParam memory orderParam) internal pure returns (uint256) {

        return uint256(uint64(bytes8(orderParam.data << (8 * 24))));
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
}

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IPerpetual {

    function devAddress() external view returns (address);


    function getMarginAccount(address trader) external view returns (LibTypes.MarginAccount memory);


    function getGovernance() external view returns (LibTypes.PerpGovernanceConfig memory);


    function status() external view returns (LibTypes.Status);


    function paused() external view returns (bool);


    function withdrawDisabled() external view returns (bool);


    function settlementPrice() external view returns (uint256);


    function globalConfig() external view returns (address);


    function collateral() external view returns (address);


    function amm() external view returns (IAMM);


    function totalSize(LibTypes.Side side) external view returns (uint256);


    function markPrice() external returns (uint256);


    function socialLossPerContract(LibTypes.Side side) external view returns (int256);


    function availableMargin(address trader) external returns (int256);


    function positionMargin(address trader) external view returns (uint256);


    function maintenanceMargin(address trader) external view returns (uint256);


    function isSafe(address trader) external returns (bool);


    function isSafeWithPrice(address trader, uint256 currentMarkPrice) external returns (bool);


    function isIMSafe(address trader) external returns (bool);


    function isIMSafeWithPrice(address trader, uint256 currentMarkPrice) external returns (bool);


    function tradePosition(
        address taker,
        address maker,
        LibTypes.Side side,
        uint256 price,
        uint256 amount
    ) external returns (uint256, uint256);


    function transferCashBalance(
        address from,
        address to,
        uint256 amount
    ) external;


    function depositFor(address trader, uint256 amount) external payable;


    function withdrawFor(address payable trader, uint256 amount) external;


    function liquidate(address trader, uint256 amount) external returns (uint256, uint256);


    function insuranceFundBalance() external view returns (int256);


    function beginGlobalSettlement(uint256 price) external;


    function endGlobalSettlement() external;


    function isValidLotSize(uint256 amount) external view returns (bool);


    function isValidTradingLotSize(uint256 amount) external view returns (bool);

}

interface IAMM {

    function shareTokenAddress() external view returns (address);


    function indexPrice() external view returns (uint256 price, uint256 timestamp);


    function positionSize() external returns (uint256);


    function lastFundingState() external view returns (LibTypes.FundingState memory);


    function currentFundingRate() external returns (int256);


    function currentFundingState() external returns (LibTypes.FundingState memory);


    function lastFundingRate() external view returns (int256);


    function getGovernance() external view returns (LibTypes.AMMGovernanceConfig memory);


    function perpetualProxy() external view returns (IPerpetual);


    function currentMarkPrice() external returns (uint256);


    function currentAvailableMargin() external returns (uint256);


    function currentPremiumRate() external returns (int256);


    function currentFairPrice() external returns (uint256);


    function currentPremium() external returns (int256);


    function currentAccumulatedFundingPerContract() external returns (int256);


    function updateIndex() external;


    function createPool(uint256 amount) external;


    function settleShare(uint256 shareAmount) external;


    function buy(uint256 amount, uint256 limitPrice, uint256 deadline) external returns (uint256);


    function sell(uint256 amount, uint256 limitPrice, uint256 deadline) external returns (uint256);


    function buyFromWhitelisted(address trader, uint256 amount, uint256 limitPrice, uint256 deadline)
        external
        returns (uint256);


    function sellFromWhitelisted(address trader, uint256 amount, uint256 limitPrice, uint256 deadline)
        external
        returns (uint256);


    function buyFrom(address trader, uint256 amount, uint256 limitPrice, uint256 deadline) external returns (uint256);


    function sellFrom(address trader, uint256 amount, uint256 limitPrice, uint256 deadline) external returns (uint256);


    function depositAndBuy(
        uint256 depositAmount,
        uint256 tradeAmount,
        uint256 limitPrice,
        uint256 deadline
    ) external payable;


    function depositAndSell(
        uint256 depositAmount,
        uint256 tradeAmount,
        uint256 limitPrice,
        uint256 deadline
    ) external payable;


    function buyAndWithdraw(
        uint256 tradeAmount,
        uint256 limitPrice,
        uint256 deadline,
        uint256 withdrawAmount
    ) external;


    function sellAndWithdraw(
        uint256 tradeAmount,
        uint256 limitPrice,
        uint256 deadline,
        uint256 withdrawAmount
    ) external;


    function depositAndAddLiquidity(uint256 depositAmount, uint256 amount) external payable;

}

interface IGlobalConfig {


    function owner() external view returns (address);


    function isOwner() external view returns (bool);


    function renounceOwnership() external;


    function transferOwnership(address newOwner) external;


    function brokers(address broker) external view returns (bool);

    
    function pauseControllers(address broker) external view returns (bool);


    function withdrawControllers(address broker) external view returns (bool);


    function addBroker() external;


    function removeBroker() external;


    function isComponent(address component) external view returns (bool);


    function addComponent(address perpetual, address component) external;


    function removeComponent(address perpetual, address component) external;


    function addPauseController(address controller) external;


    function removePauseController(address controller) external;


    function addWithdrawController(address controller) external;


    function removeWithdrawControllers(address controller) external;

}

contract PerpetualStorage {

    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;

    bool public paused = false;
    bool public withdrawDisabled = false;

    IGlobalConfig public globalConfig;
    IAMM public amm;
    IERC20 public collateral;
    address public devAddress;
    LibTypes.Status public status;
    uint256 public settlementPrice;
    LibTypes.PerpGovernanceConfig internal governance;
    int256 public insuranceFundBalance;
    uint256[3] internal totalSizes;
    int256[3] internal socialLossPerContracts;
    int256 internal scaler;
    mapping (address => LibTypes.MarginAccount) internal marginAccounts;

    event SocialLoss(LibTypes.Side side, int256 newVal);

    function socialLossPerContract(LibTypes.Side side) public view returns (int256) {

        return socialLossPerContracts[uint256(side)];
    }

    function totalSize(LibTypes.Side side) public view returns (uint256) {

        return totalSizes[uint256(side)];
    }

    function getGovernance() public view returns (LibTypes.PerpGovernanceConfig memory) {

        return governance;
    }

    function getMarginAccount(address trader) public view returns (LibTypes.MarginAccount memory) {

        return marginAccounts[trader];
    }
}

contract PerpetualGovernance is PerpetualStorage {


    event UpdateGovernanceParameter(bytes32 indexed key, int256 value);
    event UpdateGovernanceAddress(bytes32 indexed key, address value);

    constructor(address _globalConfig) public {
        require(_globalConfig != address(0), "invalid global config");
        globalConfig = IGlobalConfig(_globalConfig);
    }

    modifier ammRequired() {

        require(address(amm) != address(0), "no automated market maker");
        _;
    }

    modifier onlyOwner() {

        require(globalConfig.owner() == msg.sender, "not owner");
        _;
    }

    modifier onlyAuthorized() {

        require(globalConfig.isComponent(msg.sender), "unauthorized caller");
        _;
    }

    modifier onlyNotPaused () {

        require(!paused, "system paused");
        _;
    }

    function setGovernanceParameter(bytes32 key, int256 value) public onlyOwner {

        if (key == "initialMarginRate") {
            governance.initialMarginRate = value.toUint256();
            require(governance.initialMarginRate > 0, "require im > 0");
            require(governance.initialMarginRate < 10**18, "require im < 1");
            require(governance.maintenanceMarginRate < governance.initialMarginRate, "require mm < im");
        } else if (key == "maintenanceMarginRate") {
            governance.maintenanceMarginRate = value.toUint256();
            require(governance.maintenanceMarginRate > 0, "require mm > 0");
            require(governance.maintenanceMarginRate < governance.initialMarginRate, "require mm < im");
            require(governance.liquidationPenaltyRate < governance.maintenanceMarginRate, "require lpr < mm");
            require(governance.penaltyFundRate < governance.maintenanceMarginRate, "require pfr < mm");
        } else if (key == "liquidationPenaltyRate") {
            governance.liquidationPenaltyRate = value.toUint256();
            require(governance.liquidationPenaltyRate < governance.maintenanceMarginRate, "require lpr < mm");
        } else if (key == "penaltyFundRate") {
            governance.penaltyFundRate = value.toUint256();
            require(governance.penaltyFundRate < governance.maintenanceMarginRate, "require pfr < mm");
        } else if (key == "takerDevFeeRate") {
            governance.takerDevFeeRate = value;
        } else if (key == "makerDevFeeRate") {
            governance.makerDevFeeRate = value;
        } else if (key == "lotSize") {
            require(
                governance.tradingLotSize == 0 || governance.tradingLotSize.mod(value.toUint256()) == 0,
                "require tls % ls == 0"
            );
            governance.lotSize = value.toUint256();
        } else if (key == "tradingLotSize") {
            require(governance.lotSize == 0 || value.toUint256().mod(governance.lotSize) == 0, "require tls % ls == 0");
            governance.tradingLotSize = value.toUint256();
        } else if (key == "longSocialLossPerContracts") {
            require(status == LibTypes.Status.EMERGENCY, "wrong perpetual status");
            socialLossPerContracts[uint256(LibTypes.Side.LONG)] = value;
        } else if (key == "shortSocialLossPerContracts") {
            require(status == LibTypes.Status.EMERGENCY, "wrong perpetual status");
            socialLossPerContracts[uint256(LibTypes.Side.SHORT)] = value;
        } else {
            revert("key not exists");
        }
        emit UpdateGovernanceParameter(key, value);
    }

    function setGovernanceAddress(bytes32 key, address value) public onlyOwner {

        require(value != address(0), "invalid address");
        if (key == "dev") {
            devAddress = value;
        } else if (key == "amm") {
            amm = IAMM(value);
        } else if (key == "globalConfig") {
            globalConfig = IGlobalConfig(value);
        } else {
            revert("key not exists");
        }
        emit UpdateGovernanceAddress(key, value);
    }

    function isValidLotSize(uint256 amount) public view returns (bool) {

        return amount > 0 && amount.mod(governance.lotSize) == 0;
    }

    function isValidTradingLotSize(uint256 amount) public view returns (bool) {

        return amount > 0 && amount.mod(governance.tradingLotSize) == 0;
    }
}

contract Collateral is PerpetualGovernance {

    using LibMathSigned for int256;
    using SafeERC20 for IERC20;

    uint256 private constant MAX_DECIMALS = 18;

    event Deposit(address indexed trader, int256 wadAmount, int256 balance);
    event Withdraw(address indexed trader, int256 wadAmount, int256 balance);

    constructor(address _globalConfig, address _collateral, uint256 _decimals)
        public
        PerpetualGovernance(_globalConfig)
    {
        require(_decimals <= MAX_DECIMALS, "decimals out of range");
        require(_collateral != address(0) || _decimals == 18, "invalid decimals");

        collateral = IERC20(_collateral);
        scaler = int256(10**(MAX_DECIMALS - _decimals));
    }


    function isTokenizedCollateral() internal view returns (bool) {

        return address(collateral) != address(0);
    }

    function deposit(address trader, uint256 rawAmount) internal {

        int256 wadAmount = pullCollateral(trader, rawAmount);
        marginAccounts[trader].cashBalance = marginAccounts[trader].cashBalance.add(wadAmount);
        emit Deposit(trader, wadAmount, marginAccounts[trader].cashBalance);
    }

    function withdraw(address payable trader, uint256 rawAmount) internal {

        require(rawAmount > 0, "amount must be greater than 0");
        int256 wadAmount = toWad(rawAmount);
        require(wadAmount <= marginAccounts[trader].cashBalance, "insufficient balance");
        marginAccounts[trader].cashBalance = marginAccounts[trader].cashBalance.sub(wadAmount);
        pushCollateral(trader, rawAmount);

        emit Withdraw(trader, wadAmount, marginAccounts[trader].cashBalance);
    }

    function pullCollateral(address trader, uint256 rawAmount) internal returns (int256 wadAmount) {

        require(rawAmount > 0, "amount must be greater than 0");
        if (isTokenizedCollateral()) {
            collateral.safeTransferFrom(trader, address(this), rawAmount);
        }
        wadAmount = toWad(rawAmount);
    }

    function pushCollateral(address payable trader, uint256 rawAmount) internal returns (int256 wadAmount) {

        if (isTokenizedCollateral()) {
            collateral.safeTransfer(trader, rawAmount);
        } else {
            Address.sendValue(trader, rawAmount);
        }
        return toWad(rawAmount);
    }

    function toWad(uint256 rawAmount) internal view returns (int256) {

        return rawAmount.toInt256().mul(scaler);
    }

    function toCollateral(int256 amount) internal view returns (uint256) {

        return amount.div(scaler).toUint256();
    }
}

contract MarginAccount is Collateral {

    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;
    using LibTypes for LibTypes.Side;

    event UpdatePositionAccount(
        address indexed trader,
        LibTypes.MarginAccount account,
        uint256 perpetualTotalSize,
        uint256 price
    );
    event UpdateInsuranceFund(int256 newVal);
    event Transfer(address indexed from, address indexed to, int256 wadAmount, int256 balanceFrom, int256 balanceTo);
    event InternalUpdateBalance(address indexed trader, int256 wadAmount, int256 balance);

    constructor(address _globalConfig, address _collateral, uint256 _collateralDecimals)
        public
        Collateral(_globalConfig, _collateral, _collateralDecimals)
    {}

    function calculateLiquidateAmount(address trader, uint256 liquidationPrice) public returns (uint256) {

        if (marginAccounts[trader].size == 0) {
            return 0;
        }
        LibTypes.MarginAccount memory account = marginAccounts[trader];
        int256 liquidationAmount = account.cashBalance.add(account.entrySocialLoss);
        liquidationAmount = liquidationAmount
            .sub(marginWithPrice(trader, liquidationPrice).toInt256())
            .sub(socialLossPerContract(account.side).wmul(account.size.toInt256()));
        int256 tmp = account.entryValue.toInt256()
            .sub(account.entryFundingLoss)
            .add(amm.currentAccumulatedFundingPerContract().wmul(account.size.toInt256()))
            .sub(account.size.wmul(liquidationPrice).toInt256());
        if (account.side == LibTypes.Side.LONG) {
            liquidationAmount = liquidationAmount.sub(tmp);
        } else if (account.side == LibTypes.Side.SHORT) {
            liquidationAmount = liquidationAmount.add(tmp);
        } else {
            return 0;
        }
        int256 denominator = governance.liquidationPenaltyRate
            .add(governance.penaltyFundRate).toInt256()
            .sub(governance.initialMarginRate.toInt256())
            .wmul(liquidationPrice.toInt256());
        liquidationAmount = liquidationAmount.wdiv(denominator);
        liquidationAmount = liquidationAmount.max(0);
        liquidationAmount = liquidationAmount.min(account.size.toInt256());
        return liquidationAmount.toUint256();
    }

    function calculatePnl(LibTypes.MarginAccount memory account, uint256 tradePrice, uint256 amount)
        internal
        returns (int256)
    {

        if (account.size == 0) {
            return 0;
        }
        int256 p1 = tradePrice.wmul(amount).toInt256();
        int256 p2;
        if (amount == account.size) {
            p2 = account.entryValue.toInt256();
        } else {
            p2 = account.entryValue.wfrac(amount, account.size).toInt256();
        }
        int256 profit = account.side == LibTypes.Side.LONG ? p1.sub(p2) : p2.sub(p1);
        if (profit != 0) {
            profit = profit.sub(1);
        }
        int256 loss1 = socialLossWithAmount(account, amount);
        int256 loss2 = fundingLossWithAmount(account, amount);
        return profit.sub(loss1).sub(loss2);
    }

    function marginBalanceWithPrice(address trader, uint256 markPrice) internal returns (int256) {

        return marginAccounts[trader].cashBalance.add(pnlWithPrice(trader, markPrice));
    }

    function marginWithPrice(address trader, uint256 markPrice) internal view returns (uint256) {

        return marginAccounts[trader].size.wmul(markPrice).wmul(governance.initialMarginRate);
    }

    function maintenanceMarginWithPrice(address trader, uint256 markPrice) internal view returns (uint256) {

        return marginAccounts[trader].size.wmul(markPrice).wmul(governance.maintenanceMarginRate);
    }

    function availableMarginWithPrice(address trader, uint256 markPrice) internal returns (int256) {

        int256 marginBalance = marginBalanceWithPrice(trader, markPrice);
        int256 margin = marginWithPrice(trader, markPrice).toInt256();
        return marginBalance.sub(margin);
    }


    function pnlWithPrice(address trader, uint256 markPrice) internal returns (int256) {

        LibTypes.MarginAccount memory account = marginAccounts[trader];
        return calculatePnl(account, markPrice, account.size);
    }

    function increaseTotalSize(LibTypes.Side side, uint256 amount) internal {

        totalSizes[uint256(side)] = totalSizes[uint256(side)].add(amount);
    }

    function decreaseTotalSize(LibTypes.Side side, uint256 amount) internal {

        totalSizes[uint256(side)] = totalSizes[uint256(side)].sub(amount);
    }

    function socialLoss(LibTypes.MarginAccount memory account) internal view returns (int256) {

        return socialLossWithAmount(account, account.size);
    }

    function socialLossWithAmount(LibTypes.MarginAccount memory account, uint256 amount)
        internal
        view
        returns (int256)
    {

        if (amount == 0) {
            return 0;
        }
        int256 loss = socialLossPerContract(account.side).wmul(amount.toInt256());
        if (amount == account.size) {
            loss = loss.sub(account.entrySocialLoss);
        } else {
            loss = loss.sub(account.entrySocialLoss.wfrac(amount.toInt256(), account.size.toInt256()));
            if (loss != 0) {
                loss = loss.add(1);
            }
        }
        return loss;
    }

    function fundingLoss(LibTypes.MarginAccount memory account) internal returns (int256) {

        return fundingLossWithAmount(account, account.size);
    }

    function fundingLossWithAmount(LibTypes.MarginAccount memory account, uint256 amount) internal returns (int256) {

        if (amount == 0) {
            return 0;
        }
        int256 loss = amm.currentAccumulatedFundingPerContract().wmul(amount.toInt256());
        if (amount == account.size) {
            loss = loss.sub(account.entryFundingLoss);
        } else {
            loss = loss.sub(account.entryFundingLoss.wfrac(amount.toInt256(), account.size.toInt256()));
        }
        if (account.side == LibTypes.Side.SHORT) {
            loss = loss.neg();
        }
        if (loss != 0 && amount != account.size) {
            loss = loss.add(1);
        }
        return loss;
    }

    function remargin(address trader, uint256 markPrice) internal {

        LibTypes.MarginAccount storage account = marginAccounts[trader];
        if (account.size == 0) {
            return;
        }
        int256 rpnl = calculatePnl(account, markPrice, account.size);
        account.cashBalance = account.cashBalance.add(rpnl);
        account.entryValue = markPrice.wmul(account.size);
        account.entrySocialLoss = socialLossPerContract(account.side).wmul(account.size.toInt256());
        account.entryFundingLoss = amm.currentAccumulatedFundingPerContract().wmul(account.size.toInt256());
        emit UpdatePositionAccount(trader, account, totalSize(account.side), markPrice);
    }

    function open(LibTypes.MarginAccount memory account, LibTypes.Side side, uint256 price, uint256 amount) internal {

        require(amount > 0, "open: invald amount");
        if (account.size == 0) {
            account.side = side;
        }
        account.size = account.size.add(amount);
        account.entryValue = account.entryValue.add(price.wmul(amount));
        account.entrySocialLoss = account.entrySocialLoss.add(socialLossPerContract(side).wmul(amount.toInt256()));
        account.entryFundingLoss = account.entryFundingLoss.add(
            amm.currentAccumulatedFundingPerContract().wmul(amount.toInt256())
        );
        increaseTotalSize(side, amount);
    }

    function close(LibTypes.MarginAccount memory account, uint256 price, uint256 amount) internal returns (int256) {

        int256 rpnl = calculatePnl(account, price, amount);
        account.cashBalance = account.cashBalance.add(rpnl);
        account.entrySocialLoss = account.entrySocialLoss.wmul(account.size.sub(amount).toInt256()).wdiv(
            account.size.toInt256()
        );
        account.entryFundingLoss = account.entryFundingLoss.wmul(account.size.sub(amount).toInt256()).wdiv(
            account.size.toInt256()
        );
        account.entryValue = account.entryValue.wmul(account.size.sub(amount)).wdiv(account.size);
        account.size = account.size.sub(amount);
        decreaseTotalSize(account.side, amount);
        if (account.size == 0) {
            account.side = LibTypes.Side.FLAT;
        }
        return rpnl;
    }

    function trade(address trader, LibTypes.Side side, uint256 price, uint256 amount) internal returns (uint256) {

        uint256 opened = amount;
        uint256 closed;
        LibTypes.MarginAccount memory account = marginAccounts[trader];
        LibTypes.Side originalSide = account.side;
        if (account.size > 0 && account.side != side) {
            closed = account.size.min(amount);
            close(account, price, closed);
            opened = opened.sub(closed);
        }
        if (opened > 0) {
            open(account, side, price, opened);
        }
        marginAccounts[trader] = account;
        emit UpdatePositionAccount(trader, account, totalSize(originalSide), price);
        return opened;
    }

    function liquidate(address liquidator, address trader, uint256 liquidationPrice, uint256 liquidationAmount)
        internal
        returns (uint256)
    {

        LibTypes.MarginAccount memory account = marginAccounts[trader];
        require(liquidationAmount <= account.size, "exceeded liquidation amount");

        LibTypes.Side liquidationSide = account.side;
        uint256 liquidationValue = liquidationPrice.wmul(liquidationAmount);
        int256 penaltyToLiquidator = governance.liquidationPenaltyRate.wmul(liquidationValue).toInt256();
        int256 penaltyToFund = governance.penaltyFundRate.wmul(liquidationValue).toInt256();

        trade(trader, liquidationSide.counterSide(), liquidationPrice, liquidationAmount);
        uint256 opened = trade(liquidator, liquidationSide, liquidationPrice, liquidationAmount);

        updateCashBalance(trader, penaltyToLiquidator.add(penaltyToFund).neg());
        updateCashBalance(liquidator, penaltyToLiquidator);
        insuranceFundBalance = insuranceFundBalance.add(penaltyToFund);

        int256 liquidationLoss = ensurePositiveBalance(trader).toInt256();
        if (insuranceFundBalance >= liquidationLoss) {
            insuranceFundBalance = insuranceFundBalance.sub(liquidationLoss);
        } else {
            int256 newSocialLoss = liquidationLoss.sub(insuranceFundBalance);
            insuranceFundBalance = 0;
            handleSocialLoss(liquidationSide.counterSide(), newSocialLoss);
        }
        require(insuranceFundBalance >= 0, "negtive insurance fund");

        emit UpdateInsuranceFund(insuranceFundBalance);
        return opened;
    }

    function handleSocialLoss(LibTypes.Side side, int256 loss) internal {

        require(side != LibTypes.Side.FLAT, "side can't be flat");
        require(totalSize(side) > 0, "size cannot be 0");
        require(loss >= 0, "loss must be positive");

        int256 newSocialLoss = loss.wdiv(totalSize(side).toInt256());
        int256 newLossPerContract = socialLossPerContracts[uint256(side)].add(newSocialLoss);
        socialLossPerContracts[uint256(side)] = newLossPerContract;

        emit SocialLoss(side, newLossPerContract);
    }

    function updateCashBalance(address trader, int256 wadAmount) internal {

        if (wadAmount == 0) {
            return;
        }
        marginAccounts[trader].cashBalance = marginAccounts[trader].cashBalance.add(wadAmount);
        emit InternalUpdateBalance(trader, wadAmount, marginAccounts[trader].cashBalance);
    }

    function ensurePositiveBalance(address trader) internal returns (uint256 loss) {

        if (marginAccounts[trader].cashBalance < 0) {
            loss = marginAccounts[trader].cashBalance.neg().toUint256();
            marginAccounts[trader].cashBalance = 0;
        }
    }

    function transferBalance(address from, address to, int256 wadAmount) internal {

        if (wadAmount == 0) {
            return;
        }
        require(wadAmount > 0, "amount must be greater than 0");
        marginAccounts[from].cashBalance = marginAccounts[from].cashBalance.sub(wadAmount); // may be negative balance
        marginAccounts[to].cashBalance = marginAccounts[to].cashBalance.add(wadAmount);
        emit Transfer(from, to, wadAmount, marginAccounts[from].cashBalance, marginAccounts[to].cashBalance);
    }
}

contract Perpetual is MarginAccount, ReentrancyGuard {

    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;
    using LibOrder for LibTypes.Side;

    uint256 public totalAccounts;
    address[] public accountList;
    mapping(address => bool) private accountCreated;

    event CreatePerpetual();
    event Paused(address indexed caller);
    event Unpaused(address indexed caller);
    event DisableWithdraw(address indexed caller);
    event EnableWithdraw(address indexed caller);
    event CreateAccount(uint256 indexed id, address indexed trader);
    event Trade(address indexed trader, LibTypes.Side side, uint256 price, uint256 amount);
    event Liquidate(address indexed keeper, address indexed trader, uint256 price, uint256 amount);
    event EnterEmergencyStatus(uint256 price);
    event EnterSettledStatus(uint256 price);

    constructor(
        address _globalConfig,
        address _devAddress,
        address _collateral,
        uint256 _collateralDecimals
    )
        public
        MarginAccount(_globalConfig, _collateral, _collateralDecimals)
    {
        devAddress = _devAddress;
        emit CreatePerpetual();
    }

    function() external payable {
        revert("fallback function disabled");
    }

    function pause() external {

        require(
            globalConfig.pauseControllers(msg.sender) || globalConfig.owner() == msg.sender,
            "unauthorized caller"
        );
        require(!paused, "already paused");
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external {

        require(
            globalConfig.pauseControllers(msg.sender) || globalConfig.owner() == msg.sender,
            "unauthorized caller"
        );
        require(paused, "not paused");
        paused = false;
        emit Unpaused(msg.sender);
    }

    function disableWithdraw() external {

        require(
            globalConfig.withdrawControllers(msg.sender) || globalConfig.owner() == msg.sender,
            "unauthorized caller"
        );
        require(!withdrawDisabled, "already disabled");
        withdrawDisabled = true;
        emit DisableWithdraw(msg.sender);
    }

    function enableWithdraw() external {

        require(
            globalConfig.withdrawControllers(msg.sender) || globalConfig.owner() == msg.sender,
            "unauthorized caller"
        );
        require(withdrawDisabled, "not disabled");
        withdrawDisabled = false;
        emit EnableWithdraw(msg.sender);
    }

    function increaseCashBalance(address trader, uint256 amount) external onlyOwner {

        require(status == LibTypes.Status.EMERGENCY, "wrong perpetual status");
        updateCashBalance(trader, amount.toInt256());
    }

    function decreaseCashBalance(address trader, uint256 amount) external onlyOwner {

        require(status == LibTypes.Status.EMERGENCY, "wrong perpetual status");
        updateCashBalance(trader, amount.toInt256().neg());
    }

    function beginGlobalSettlement(uint256 price) external onlyOwner {

        require(status != LibTypes.Status.SETTLED, "wrong perpetual status");
        status = LibTypes.Status.EMERGENCY;

        settlementPrice = price;
        emit EnterEmergencyStatus(price);
    }

    function endGlobalSettlement() external onlyOwner {

        require(status == LibTypes.Status.EMERGENCY, "wrong perpetual status");
        status = LibTypes.Status.SETTLED;

        address ammTrader = address(amm.perpetualProxy());
        settleImplementation(ammTrader);
        emit EnterSettledStatus(settlementPrice);
    }

    function depositToInsuranceFund(uint256 rawAmount) external payable nonReentrant {

        checkDepositingParameter(rawAmount);

        require(rawAmount > 0, "amount must be greater than 0");
        int256 wadAmount = pullCollateral(msg.sender, rawAmount);
        insuranceFundBalance = insuranceFundBalance.add(wadAmount);
        require(insuranceFundBalance >= 0, "negtive insurance fund");

        emit UpdateInsuranceFund(insuranceFundBalance);
    }

    function withdrawFromInsuranceFund(uint256 rawAmount) external onlyOwner nonReentrant {

        require(rawAmount > 0, "amount must be greater than 0");
        require(insuranceFundBalance > 0, "insufficient funds");

        int256 wadAmount = toWad(rawAmount);
        require(wadAmount <= insuranceFundBalance, "insufficient funds");
        insuranceFundBalance = insuranceFundBalance.sub(wadAmount);
        pushCollateral(msg.sender, rawAmount);
        require(insuranceFundBalance >= 0, "negtive insurance fund");

        emit UpdateInsuranceFund(insuranceFundBalance);
    }


    function deposit(uint256 rawAmount) external payable {

        depositImplementation(msg.sender, rawAmount);
    }

    function withdraw(uint256 rawAmount) external {

        withdrawImplementation(msg.sender, rawAmount);
    }

    function settle() external nonReentrant
    {

        address payable trader = msg.sender;
        settleImplementation(trader);
        int256 wadAmount = marginAccounts[trader].cashBalance;
        if (wadAmount <= 0) {
            return;
        }
        uint256 rawAmount = toCollateral(wadAmount);
        Collateral.withdraw(trader, rawAmount);
    }

    function depositFor(address trader, uint256 rawAmount)
        external
        payable
        onlyAuthorized
    {

        depositImplementation(trader, rawAmount);
    }

    function withdrawFor(address payable trader, uint256 rawAmount)
        external
        onlyAuthorized
    {

        withdrawImplementation(trader, rawAmount);
    }

    function markPrice() public ammRequired returns (uint256) {

        return status == LibTypes.Status.NORMAL ? amm.currentMarkPrice() : settlementPrice;
    }

    function positionMargin(address trader) public returns (uint256) {

        return MarginAccount.marginWithPrice(trader, markPrice());
    }

    function maintenanceMargin(address trader) public returns (uint256) {

        return MarginAccount.maintenanceMarginWithPrice(trader, markPrice());
    }

    function marginBalance(address trader) public returns (int256) {

        return MarginAccount.marginBalanceWithPrice(trader, markPrice());
    }

    function pnl(address trader) public returns (int256) {

        return MarginAccount.pnlWithPrice(trader, markPrice());
    }

    function availableMargin(address trader) public returns (int256) {

        return MarginAccount.availableMarginWithPrice(trader, markPrice());
    }

    function isSafe(address trader) public returns (bool) {

        uint256 currentMarkPrice = markPrice();
        return isSafeWithPrice(trader, currentMarkPrice);
    }

    function isSafeWithPrice(address trader, uint256 currentMarkPrice) public returns (bool) {

        return
            MarginAccount.marginBalanceWithPrice(trader, currentMarkPrice) >=
            MarginAccount.maintenanceMarginWithPrice(trader, currentMarkPrice).toInt256();
    }

    function isBankrupt(address trader) public returns (bool) {

        return marginBalanceWithPrice(trader, markPrice()) < 0;
    }

    function isIMSafe(address trader) public returns (bool) {

        uint256 currentMarkPrice = markPrice();
        return isIMSafeWithPrice(trader, currentMarkPrice);
    }

    function isIMSafeWithPrice(address trader, uint256 currentMarkPrice) public returns (bool) {

        return availableMarginWithPrice(trader, currentMarkPrice) >= 0;
    }

    function liquidate(
        address trader,
        uint256 maxAmount
    )
        public
        onlyNotPaused
        returns (uint256, uint256)
    {

        require(msg.sender != trader, "self liquidate");
        require(isValidLotSize(maxAmount), "amount must be divisible by lotSize");
        require(status != LibTypes.Status.SETTLED, "wrong perpetual status");
        require(!isSafe(trader), "safe account");

        uint256 liquidationPrice = markPrice();
        require(liquidationPrice > 0, "price must be greater than 0");

        uint256 liquidationAmount = calculateLiquidateAmount(trader, liquidationPrice);
        uint256 totalPositionSize = marginAccounts[trader].size;
        uint256 liquidatableAmount = totalPositionSize.sub(totalPositionSize.mod(governance.lotSize));
        liquidationAmount = liquidationAmount.ceil(governance.lotSize).min(maxAmount).min(liquidatableAmount);
        require(liquidationAmount > 0, "nothing to liquidate");

        uint256 opened = MarginAccount.liquidate(msg.sender, trader, liquidationPrice, liquidationAmount);
        if (opened > 0) {
            require(availableMarginWithPrice(msg.sender, liquidationPrice) >= 0, "liquidator margin");
        } else {
            require(isSafe(msg.sender), "liquidator unsafe");
        }
        emit Liquidate(msg.sender, trader, liquidationPrice, liquidationAmount);
        return (liquidationPrice, liquidationAmount);
    }

    function tradePosition(
        address taker,
        address maker,
        LibTypes.Side side,
        uint256 price,
        uint256 amount
    )
        public
        onlyNotPaused
        onlyAuthorized
        returns (uint256 takerOpened, uint256 makerOpened)
    {

        require(status != LibTypes.Status.EMERGENCY, "wrong perpetual status");
        require(side == LibTypes.Side.LONG || side == LibTypes.Side.SHORT, "side must be long or short");
        require(isValidLotSize(amount), "amount must be divisible by lotSize");

        takerOpened = MarginAccount.trade(taker, side, price, amount);
        makerOpened = MarginAccount.trade(maker, side.counterSide(), price, amount);
        require(totalSize(LibTypes.Side.LONG) == totalSize(LibTypes.Side.SHORT), "imbalanced total size");

        emit Trade(taker, side, price, amount);
        emit Trade(maker, side.counterSide(), price, amount);
    }

    function transferCashBalance(
        address from,
        address to,
        uint256 amount
    )
        public
        onlyNotPaused
        onlyAuthorized
    {

        require(status != LibTypes.Status.EMERGENCY, "wrong perpetual status");
        MarginAccount.transferBalance(from, to, amount.toInt256());
    }

    function registerNewTrader(address trader) internal {

        emit CreateAccount(totalAccounts, trader);
        accountList.push(trader);
        totalAccounts++;
        accountCreated[trader] = true;
    }

    function checkDepositingParameter(uint256 rawAmount) internal view {

        bool isToken = isTokenizedCollateral();
        require((isToken && msg.value == 0) || (!isToken && msg.value == rawAmount), "incorrect sent value");
    }

    function depositImplementation(address trader, uint256 rawAmount) internal onlyNotPaused nonReentrant {

        checkDepositingParameter(rawAmount);
        require(rawAmount > 0, "amount must be greater than 0");
        require(trader != address(0), "cannot deposit to 0 address");

        Collateral.deposit(trader, rawAmount);
        if (!accountCreated[trader]) {
            registerNewTrader(trader);
        }
    }

    function withdrawImplementation(address payable trader, uint256 rawAmount) internal onlyNotPaused nonReentrant {

        require(!withdrawDisabled, "withdraw disabled");
        require(status == LibTypes.Status.NORMAL, "wrong perpetual status");
        require(rawAmount > 0, "amount must be greater than 0");
        require(trader != address(0), "cannot withdraw to 0 address");

        uint256 currentMarkPrice = markPrice();
        require(isSafeWithPrice(trader, currentMarkPrice), "unsafe before withdraw");

        remargin(trader, currentMarkPrice);
        Collateral.withdraw(trader, rawAmount);

        require(isSafeWithPrice(trader, currentMarkPrice), "unsafe after withdraw");
        require(availableMarginWithPrice(trader, currentMarkPrice) >= 0, "withdraw margin");
    }

    function settleImplementation(address trader) internal onlyNotPaused {

        require(status == LibTypes.Status.SETTLED, "wrong perpetual status");
        uint256 currentMarkPrice = markPrice();
        LibTypes.MarginAccount memory account = marginAccounts[trader];
        if (account.size == 0) {
            return;
        }
        LibTypes.Side originalSide = account.side;
        close(account, currentMarkPrice, account.size);
        marginAccounts[trader] = account;
        emit UpdatePositionAccount(trader, account, totalSize(originalSide), currentMarkPrice);
    }
}