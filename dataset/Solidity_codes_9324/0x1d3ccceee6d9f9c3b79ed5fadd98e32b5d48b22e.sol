

pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


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


contract P1TraderConstants {

    bytes32 constant internal TRADER_FLAG_ORDERS = bytes32(uint256(1));
    bytes32 constant internal TRADER_FLAG_LIQUIDATION = bytes32(uint256(2));
    bytes32 constant internal TRADER_FLAG_DELEVERAGING = bytes32(uint256(4));
}


library BaseMath {

    using SafeMath for uint256;

    uint256 constant internal BASE = 10 ** 18;

    function base()
        internal
        pure
        returns (uint256)
    {

        return BASE;
    }

    function baseMul(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {

        return value.mul(baseValue).div(BASE);
    }

    function baseDivMul(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {

        return value.div(BASE).mul(baseValue);
    }

    function baseMulRoundUp(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {

        if (value == 0 || baseValue == 0) {
            return 0;
        }
        return value.mul(baseValue).sub(1).div(BASE).add(1);
    }

    function baseDiv(
        uint256 value,
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {

        return value.mul(BASE).div(baseValue);
    }

    function baseReciprocal(
        uint256 baseValue
    )
        internal
        pure
        returns (uint256)
    {

        return baseDiv(BASE, baseValue);
    }
}


library TypedSignature {



    bytes32 constant private FILE = "TypedSignature";

    bytes constant private PREPEND_DEC = "\x19Ethereum Signed Message:\n32";

    bytes constant private PREPEND_HEX = "\x19Ethereum Signed Message:\n\x20";

    uint256 constant private NUM_SIGNATURE_BYTES = 66;


    enum SignatureType {
        NoPrepend,   // No string was prepended.
        Decimal,     // PREPEND_DEC was prepended.
        Hexadecimal, // PREPEND_HEX was prepended.
        Invalid      // Not a valid type. Used for bound-checking.
    }


    struct Signature {
        bytes32 r;
        bytes32 s;
        bytes2 vType;
    }


    function recover(
        bytes32 hash,
        Signature memory signature
    )
        internal
        pure
        returns (address)
    {

        SignatureType sigType = SignatureType(uint8(bytes1(signature.vType << 8)));

        bytes32 signedHash;
        if (sigType == SignatureType.NoPrepend) {
            signedHash = hash;
        } else if (sigType == SignatureType.Decimal) {
            signedHash = keccak256(abi.encodePacked(PREPEND_DEC, hash));
        } else {
            assert(sigType == SignatureType.Hexadecimal);
            signedHash = keccak256(abi.encodePacked(PREPEND_HEX, hash));
        }

        return ecrecover(
            signedHash,
            uint8(bytes1(signature.vType)),
            signature.r,
            signature.s
        );
    }
}


library Storage {


    function load(
        bytes32 slot
    )
        internal
        view
        returns (bytes32)
    {

        bytes32 result;
        assembly {
            result := sload(slot)
        }
        return result;
    }

    function store(
        bytes32 slot,
        bytes32 value
    )
        internal
    {

        assembly {
            sstore(slot, value)
        }
    }
}


contract Adminable {

    bytes32 internal constant ADMIN_SLOT =
    0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    modifier onlyAdmin() {

        require(
            msg.sender == getAdmin(),
            "Adminable: caller is not admin"
        );
        _;
    }

    function getAdmin()
        public
        view
        returns (address)
    {

        return address(uint160(uint256(Storage.load(ADMIN_SLOT))));
    }
}


contract ReentrancyGuard {

    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = uint256(int256(-1));

    uint256 private _STATUS_;

    constructor () internal {
        _STATUS_ = NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_STATUS_ != ENTERED, "ReentrancyGuard: reentrant call");
        _STATUS_ = ENTERED;
        _;
        _STATUS_ = NOT_ENTERED;
    }
}


library P1Types {


    struct Index {
        uint32 timestamp;
        bool isPositive;
        uint128 value;
    }

    struct Balance {
        bool marginIsPositive;
        bool positionIsPositive;
        uint120 margin;
        uint120 position;
    }

    struct Context {
        uint256 price;
        uint256 minCollateral;
        Index index;
    }

    struct TradeResult {
        uint256 marginAmount;
        uint256 positionAmount;
        bool isBuy; // From taker's perspective.
        bytes32 traderFlags;
    }
}


contract P1Storage is
    Adminable,
    ReentrancyGuard
{

    mapping(address => P1Types.Balance) internal _BALANCES_;
    mapping(address => P1Types.Index) internal _LOCAL_INDEXES_;

    mapping(address => bool) internal _GLOBAL_OPERATORS_;
    mapping(address => mapping(address => bool)) internal _LOCAL_OPERATORS_;

    address internal _TOKEN_;
    address internal _ORACLE_;
    address internal _FUNDER_;

    P1Types.Index internal _GLOBAL_INDEX_;
    uint256 internal _MIN_COLLATERAL_;

    bool internal _FINAL_SETTLEMENT_ENABLED_;
    uint256 internal _FINAL_SETTLEMENT_PRICE_;
}


interface I_P1Oracle {


    function getPrice()
        external
        view
        returns (uint256);

}


contract P1Getters is
    P1Storage
{


    function getAccountBalance(
        address account
    )
        external
        view
        returns (P1Types.Balance memory)
    {

        return _BALANCES_[account];
    }

    function getAccountIndex(
        address account
    )
        external
        view
        returns (P1Types.Index memory)
    {

        return _LOCAL_INDEXES_[account];
    }

    function getIsLocalOperator(
        address account,
        address operator
    )
        external
        view
        returns (bool)
    {

        return _LOCAL_OPERATORS_[account][operator];
    }


    function getIsGlobalOperator(
        address operator
    )
        external
        view
        returns (bool)
    {

        return _GLOBAL_OPERATORS_[operator];
    }

    function getTokenContract()
        external
        view
        returns (address)
    {

        return _TOKEN_;
    }

    function getOracleContract()
        external
        view
        returns (address)
    {

        return _ORACLE_;
    }

    function getFunderContract()
        external
        view
        returns (address)
    {

        return _FUNDER_;
    }

    function getGlobalIndex()
        external
        view
        returns (P1Types.Index memory)
    {

        return _GLOBAL_INDEX_;
    }

    function getMinCollateral()
        external
        view
        returns (uint256)
    {

        return _MIN_COLLATERAL_;
    }

    function getFinalSettlementEnabled()
        external
        view
        returns (bool)
    {

        return _FINAL_SETTLEMENT_ENABLED_;
    }


    function getOraclePrice()
        external
        view
        returns (uint256)
    {

        require(
            _GLOBAL_OPERATORS_[msg.sender],
            "Oracle price requester not global operator"
        );
        return I_P1Oracle(_ORACLE_).getPrice();
    }


    function hasAccountPermissions(
        address account,
        address operator
    )
        public
        view
        returns (bool)
    {

        return account == operator
            || _GLOBAL_OPERATORS_[operator]
            || _LOCAL_OPERATORS_[account][operator];
    }
}


contract P1InverseOrders is
    P1TraderConstants
{

    using BaseMath for uint256;
    using SafeMath for uint256;


    bytes2 constant private EIP191_HEADER = 0x1901;

    string constant private EIP712_DOMAIN_NAME = "P1InverseOrders";

    string constant private EIP712_DOMAIN_VERSION = "1.0";

    bytes32 constant private EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "uint256 chainId,",
        "address verifyingContract",
        ")"
    ));

    bytes32 constant private EIP712_ORDER_STRUCT_SCHEMA_HASH = keccak256(abi.encodePacked(
        "Order(",
        "bytes32 flags,",
        "uint256 amount,",
        "uint256 limitPrice,",
        "uint256 triggerPrice,",
        "uint256 limitFee,",
        "address maker,",
        "address taker,",
        "uint256 expiration",
        ")"
    ));

    bytes32 constant FLAG_MASK_NULL = bytes32(uint256(0));
    bytes32 constant FLAG_MASK_IS_BUY = bytes32(uint256(1));
    bytes32 constant FLAG_MASK_IS_DECREASE_ONLY = bytes32(uint256(1 << 1));
    bytes32 constant FLAG_MASK_IS_NEGATIVE_LIMIT_FEE = bytes32(uint256(1 << 2));


    enum OrderStatus {
        Open,
        Approved,
        Canceled
    }


    struct Order {
        bytes32 flags;
        uint256 amount;
        uint256 limitPrice;
        uint256 triggerPrice;
        uint256 limitFee;
        address maker;
        address taker;
        uint256 expiration;
    }

    struct Fill {
        uint256 amount;
        uint256 price;
        uint256 fee;
        bool isNegativeFee;
    }

    struct TradeData {
        Order order;
        Fill fill;
        TypedSignature.Signature signature;
    }

    struct OrderQueryOutput {
        OrderStatus status;
        uint256 filledAmount;
    }


    event LogOrderCanceled(
        address indexed maker,
        bytes32 orderHash
    );

    event LogOrderApproved(
        address indexed maker,
        bytes32 orderHash
    );

    event LogOrderFilled(
        bytes32 orderHash,
        bytes32 flags,
        uint256 triggerPrice,
        Fill fill
    );


    address public _PERPETUAL_V1_;

    bytes32 public _EIP712_DOMAIN_HASH_;


    mapping (bytes32 => uint256) public _FILLED_AMOUNT_;

    mapping (bytes32 => OrderStatus) public _STATUS_;


    constructor (
        address perpetualV1,
        uint256 chainId
    )
        public
    {
        _PERPETUAL_V1_ = perpetualV1;

        _EIP712_DOMAIN_HASH_ = keccak256(abi.encode(
            EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
            keccak256(bytes(EIP712_DOMAIN_NAME)),
            keccak256(bytes(EIP712_DOMAIN_VERSION)),
            chainId,
            address(this)
        ));
    }


    function trade(
        address sender,
        address maker,
        address taker,
        uint256 price,
        bytes calldata data,
        bytes32 /* traderFlags */
    )
        external
        returns (P1Types.TradeResult memory)
    {

        address perpetual = _PERPETUAL_V1_;

        require(
            msg.sender == perpetual,
            "msg.sender must be PerpetualV1"
        );

        if (taker != sender) {
            require(
                P1Getters(perpetual).hasAccountPermissions(taker, sender),
                "Sender does not have permissions for the taker"
            );
        }

        TradeData memory tradeData = abi.decode(data, (TradeData));
        bytes32 orderHash = _getOrderHash(tradeData.order);

        _verifyOrderStateAndSignature(
            tradeData,
            orderHash
        );
        _verifyOrderRequest(
            tradeData,
            maker,
            taker,
            perpetual,
            price
        );

        uint256 oldFilledAmount = _FILLED_AMOUNT_[orderHash];
        uint256 newFilledAmount = oldFilledAmount.add(tradeData.fill.amount);
        require(
            newFilledAmount <= tradeData.order.amount,
            "Cannot overfill order"
        );
        _FILLED_AMOUNT_[orderHash] = newFilledAmount;

        emit LogOrderFilled(
            orderHash,
            tradeData.order.flags,
            tradeData.order.triggerPrice,
            tradeData.fill
        );

        bool isBuyOrder = _isBuy(tradeData.order);

        uint256 feeFactor = (isBuyOrder == tradeData.fill.isNegativeFee)
            ? BaseMath.base().add(tradeData.fill.fee)
            : BaseMath.base().sub(tradeData.fill.fee);
        uint256 marginAmount = tradeData.fill.amount.mul(feeFactor).div(tradeData.fill.price);

        return P1Types.TradeResult({
            marginAmount: marginAmount,
            positionAmount: tradeData.fill.amount,
            isBuy: isBuyOrder,
            traderFlags: TRADER_FLAG_ORDERS
        });
    }

    function approveOrder(
        Order calldata order
    )
        external
    {

        require(
            msg.sender == order.maker,
            "Order cannot be approved by non-maker"
        );
        bytes32 orderHash = _getOrderHash(order);
        require(
            _STATUS_[orderHash] != OrderStatus.Canceled,
            "Canceled order cannot be approved"
        );
        _STATUS_[orderHash] = OrderStatus.Approved;
        emit LogOrderApproved(msg.sender, orderHash);
    }

    function cancelOrder(
        Order calldata order
    )
        external
    {

        require(
            msg.sender == order.maker,
            "Order cannot be canceled by non-maker"
        );
        bytes32 orderHash = _getOrderHash(order);
        _STATUS_[orderHash] = OrderStatus.Canceled;
        emit LogOrderCanceled(msg.sender, orderHash);
    }


    function getOrdersStatus(
        bytes32[] calldata orderHashes
    )
        external
        view
        returns (OrderQueryOutput[] memory)
    {

        OrderQueryOutput[] memory result = new OrderQueryOutput[](orderHashes.length);
        for (uint256 i = 0; i < orderHashes.length; i++) {
            bytes32 orderHash = orderHashes[i];
            result[i] = OrderQueryOutput({
                status: _STATUS_[orderHash],
                filledAmount: _FILLED_AMOUNT_[orderHash]
            });
        }
        return result;
    }


    function _verifyOrderStateAndSignature(
        TradeData memory tradeData,
        bytes32 orderHash
    )
        private
        view
    {

        OrderStatus orderStatus = _STATUS_[orderHash];

        if (orderStatus == OrderStatus.Open) {
            require(
                tradeData.order.maker == TypedSignature.recover(orderHash, tradeData.signature),
                "Order has an invalid signature"
            );
        } else {
            require(
                orderStatus != OrderStatus.Canceled,
                "Order was already canceled"
            );
            assert(orderStatus == OrderStatus.Approved);
        }
    }

    function _verifyOrderRequest(
        TradeData memory tradeData,
        address maker,
        address taker,
        address perpetual,
        uint256 price
    )
        private
        view
    {

        require(
            tradeData.order.maker == maker,
            "Order maker does not match maker"
        );
        require(
            tradeData.order.taker == taker || tradeData.order.taker == address(0),
            "Order taker does not match taker"
        );
        require(
            tradeData.order.expiration >= block.timestamp || tradeData.order.expiration == 0,
            "Order has expired"
        );

        bool isBuyOrder = _isBuy(tradeData.order);
        bool validPrice = isBuyOrder
            ? tradeData.fill.price <= tradeData.order.limitPrice
            : tradeData.fill.price >= tradeData.order.limitPrice;
        require(
            validPrice,
            "Fill price is invalid"
        );

        bool validFee = _isNegativeLimitFee(tradeData.order)
            ? tradeData.fill.isNegativeFee && tradeData.fill.fee >= tradeData.order.limitFee
            : tradeData.fill.isNegativeFee || tradeData.fill.fee <= tradeData.order.limitFee;
        require(
            validFee,
            "Fill fee is invalid"
        );

        uint256 invertedOraclePrice = price.baseReciprocal();
        if (tradeData.order.triggerPrice != 0) {
            bool validTriggerPrice = isBuyOrder
                ? tradeData.order.triggerPrice <= invertedOraclePrice
                : tradeData.order.triggerPrice >= invertedOraclePrice;
            require(
                validTriggerPrice,
                "Trigger price has not been reached"
            );
        }

        if (_isDecreaseOnly(tradeData.order)) {
            P1Types.Balance memory balance = P1Getters(perpetual).getAccountBalance(maker);
            require(
                isBuyOrder == balance.positionIsPositive
                && tradeData.fill.amount <= balance.position,
                "Fill does not decrease position"
            );
        }
    }

    function _getOrderHash(
        Order memory order
    )
        private
        view
        returns (bytes32)
    {

        bytes32 structHash = keccak256(abi.encode(
            EIP712_ORDER_STRUCT_SCHEMA_HASH,
            order
        ));

        return keccak256(abi.encodePacked(
            EIP191_HEADER,
            _EIP712_DOMAIN_HASH_,
            structHash
        ));
    }

    function _isBuy(
        Order memory order
    )
        private
        pure
        returns (bool)
    {

        return (order.flags & FLAG_MASK_IS_BUY) != FLAG_MASK_NULL;
    }

    function _isDecreaseOnly(
        Order memory order
    )
        private
        pure
        returns (bool)
    {

        return (order.flags & FLAG_MASK_IS_DECREASE_ONLY) != FLAG_MASK_NULL;
    }

    function _isNegativeLimitFee(
        Order memory order
    )
        private
        pure
        returns (bool)
    {

        return (order.flags & FLAG_MASK_IS_NEGATIVE_LIMIT_FEE) != FLAG_MASK_NULL;
    }
}