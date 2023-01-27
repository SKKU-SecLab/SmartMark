

pragma solidity 0.5.15;
pragma experimental ABIEncoderV2;


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

contract Exchange {

    using LibMathSigned for int256;
    using LibMathUnsigned for uint256;
    using LibOrder for LibOrder.Order;
    using LibOrder for LibOrder.OrderParam;
    using LibSignature for LibSignature.OrderSignature;

    uint256 public constant SUPPORTED_ORDER_VERSION = 2;

    IGlobalConfig public globalConfig;

    mapping(bytes32 => uint256) public filled;
    mapping(bytes32 => bool) public cancelled;

    event MatchWithOrders(
        address perpetual,
        LibOrder.OrderParam takerOrderParam,
        LibOrder.OrderParam makerOrderParam,
        uint256 amount
    );
    event MatchWithAMM(address perpetual, LibOrder.OrderParam takerOrderParam, uint256 amount);
    event Cancel(bytes32 indexed orderHash);

    constructor(address _globalConfig) public {
        globalConfig = IGlobalConfig(_globalConfig);
    }

    function matchOrders(
        LibOrder.OrderParam memory takerOrderParam,
        LibOrder.OrderParam[] memory makerOrderParams,
        address _perpetual,
        uint256[] memory amounts
    ) public {

        require(globalConfig.brokers(msg.sender), "unauthorized broker");
        require(amounts.length > 0 && makerOrderParams.length == amounts.length, "no makers to match");
        require(!takerOrderParam.isMakerOnly(), "taker order is maker only");

        IPerpetual perpetual = IPerpetual(_perpetual);
        require(perpetual.status() == LibTypes.Status.NORMAL, "wrong perpetual status");

        uint256 tradingLotSize = perpetual.getGovernance().tradingLotSize;
        bytes32 takerOrderHash = validateOrderParam(perpetual, takerOrderParam);
        uint256 takerFilledAmount = filled[takerOrderHash];
        uint256 takerOpened;

        for (uint256 i = 0; i < makerOrderParams.length; i++) {
            if (amounts[i] == 0) {
                continue;
            }

            require(takerOrderParam.trader != makerOrderParams[i].trader, "self trade");
            require(takerOrderParam.isInversed() == makerOrderParams[i].isInversed(), "invalid inversed pair");
            require(takerOrderParam.isSell() != makerOrderParams[i].isSell(), "side must be long or short");
            require(!makerOrderParams[i].isMarketOrder(), "market order cannot be maker");

            validatePrice(takerOrderParam, makerOrderParams[i]);

            bytes32 makerOrderHash = validateOrderParam(perpetual, makerOrderParams[i]);
            uint256 makerFilledAmount = filled[makerOrderHash];

            require(amounts[i] <= takerOrderParam.amount.sub(takerFilledAmount), "taker overfilled");
            require(amounts[i] <= makerOrderParams[i].amount.sub(makerFilledAmount), "maker overfilled");
            require(amounts[i].mod(tradingLotSize) == 0, "amount must be divisible by tradingLotSize");

            uint256 opened = fillOrder(perpetual, takerOrderParam, makerOrderParams[i], amounts[i]);

            takerOpened = takerOpened.add(opened);
            filled[makerOrderHash] = makerFilledAmount.add(amounts[i]);
            takerFilledAmount = takerFilledAmount.add(amounts[i]);
        }

        if (takerOpened > 0) {
            require(perpetual.isIMSafe(takerOrderParam.trader), "taker initial margin unsafe");
        } else {
            require(perpetual.isSafe(takerOrderParam.trader), "maker unsafe");
        }
        require(perpetual.isSafe(msg.sender), "broker unsafe");

        filled[takerOrderHash] = takerFilledAmount;
    }

    function matchOrderWithAMM(
        LibOrder.OrderParam memory takerOrderParam,
        address _perpetual,
        uint256 amount
    ) public {

        require(globalConfig.brokers(msg.sender), "unauthorized broker");
        require(amount > 0, "amount must be greater than 0");
        require(!takerOrderParam.isMakerOnly(), "taker order is maker only");

        IPerpetual perpetual = IPerpetual(_perpetual);
        IAMM amm = IAMM(perpetual.amm());

        bytes32 takerOrderHash = validateOrderParam(perpetual, takerOrderParam);
        uint256 takerFilledAmount = filled[takerOrderHash];
        require(amount <= takerOrderParam.amount.sub(takerFilledAmount), "taker overfilled");

        uint256 takerOpened;
        uint256 price = takerOrderParam.getPrice();
        uint256 expired = takerOrderParam.expiredAt();
        if (takerOrderParam.isSell()) {
            takerOpened = amm.sellFromWhitelisted(
                takerOrderParam.trader,
                amount,
                price,
                expired
            );
        } else {
            takerOpened = amm.buyFromWhitelisted(takerOrderParam.trader, amount, price, expired);
        }
        filled[takerOrderHash] = filled[takerOrderHash].add(amount);

        emit MatchWithAMM(_perpetual, takerOrderParam, amount);
    }

    function cancelOrder(LibOrder.Order memory order) public {

        require(msg.sender == order.trader || msg.sender == order.broker, "invalid caller");

        bytes32 orderHash = order.getOrderHash();
        cancelled[orderHash] = true;

        emit Cancel(orderHash);
    }

    function getChainId() public pure returns (uint256 id) {

        assembly {
            id := chainid()
        }
    }

    function fillOrder(
        IPerpetual perpetual,
        LibOrder.OrderParam memory takerOrderParam,
        LibOrder.OrderParam memory makerOrderParam,
        uint256 amount
    ) internal returns (uint256) {

        uint256 price = makerOrderParam.getPrice();
        (uint256 takerOpened, uint256 makerOpened) = perpetual.tradePosition(
            takerOrderParam.trader,
            makerOrderParam.trader,
            takerOrderParam.side(),
            price,
            amount
        );

        int256 takerTradingFee = amount.wmul(price).toInt256().wmul(takerOrderParam.takerFeeRate());
        claimTradingFee(perpetual, takerOrderParam.trader, takerTradingFee);
        int256 makerTradingFee = amount.wmul(price).toInt256().wmul(makerOrderParam.makerFeeRate());
        claimTradingFee(perpetual, makerOrderParam.trader, makerTradingFee);

        claimTakerDevFee(perpetual, takerOrderParam.trader, price, takerOpened, amount.sub(takerOpened));
        claimMakerDevFee(perpetual, makerOrderParam.trader, price, makerOpened, amount.sub(makerOpened));
        if (makerOpened > 0) {
            require(perpetual.isIMSafe(makerOrderParam.trader), "maker initial margin unsafe");
        } else {
            require(perpetual.isSafe(makerOrderParam.trader), "maker unsafe");
        }

        emit MatchWithOrders(address(perpetual), takerOrderParam, makerOrderParam, amount);

        return takerOpened;
    }

    function validatePrice(LibOrder.OrderParam memory takerOrderParam, LibOrder.OrderParam memory makerOrderParam)
        internal
        pure
    {

        if (takerOrderParam.isMarketOrder()) {
            return;
        }
        uint256 takerPrice = takerOrderParam.getPrice();
        uint256 makerPrice = makerOrderParam.getPrice();
        require(takerOrderParam.isSell() ? takerPrice <= makerPrice : takerPrice >= makerPrice, "price not match");
    }


    function validateOrderParam(IPerpetual perpetual, LibOrder.OrderParam memory orderParam)
        internal
        view
        returns (bytes32)
    {

        require(orderParam.orderVersion() == SUPPORTED_ORDER_VERSION, "unsupported version");
        require(orderParam.expiredAt() >= block.timestamp, "order expired");
        require(orderParam.chainId() == getChainId(), "unmatched chainid");

        bytes32 orderHash = orderParam.getOrderHash(address(perpetual), msg.sender);
        require(!cancelled[orderHash], "cancelled order");
        require(orderParam.signature.isValidSignature(orderHash, orderParam.trader), "invalid signature");
        require(filled[orderHash] < orderParam.amount, "fullfilled order");

        return orderHash;
    }

    function claimTradingFee(
        IPerpetual perpetual,
        address trader,
        int256 fee
    )
        internal
    {

        if (fee > 0) {
            perpetual.transferCashBalance(trader, msg.sender, fee.toUint256());
        } else if (fee < 0) {
            perpetual.transferCashBalance(msg.sender, trader, fee.neg().toUint256());
        }
    }


    function claimDevFee(
        IPerpetual perpetual,
        address trader,
        uint256 price,
        uint256 openedAmount,
        uint256 closedAmount,
        int256 feeRate
    )
        internal
    {

        if (feeRate == 0) {
            return;
        }
        int256 hard = price.wmul(openedAmount).toInt256().wmul(feeRate);
        int256 soft = price.wmul(closedAmount).toInt256().wmul(feeRate);
        int256 fee = hard.add(soft);
        address devAddress = perpetual.devAddress();
        if (fee > 0) {
            int256 available = perpetual.availableMargin(trader);
            require(available >= hard, "available margin too low for fee");
            fee = fee.min(available);
            perpetual.transferCashBalance(trader, devAddress, fee.toUint256());
        } else if (fee < 0) {
            perpetual.transferCashBalance(devAddress, trader, fee.neg().toUint256());
            require(perpetual.isSafe(devAddress), "dev unsafe");
        }
    }

    function claimTakerDevFee(
        IPerpetual perpetual,
        address trader,
        uint256 price,
        uint256 openedAmount,
        uint256 closedAmount
    )
        internal
    {

        int256 rate = perpetual.getGovernance().takerDevFeeRate;
        claimDevFee(perpetual, trader, price, openedAmount, closedAmount, rate);
    }

    function claimMakerDevFee(
        IPerpetual perpetual,
        address trader,
        uint256 price,
        uint256 openedAmount,
        uint256 closedAmount
    )
        internal
    {

        int256 rate = perpetual.getGovernance().makerDevFeeRate;
        claimDevFee(perpetual, trader, price, openedAmount, closedAmount, rate);
    }
}