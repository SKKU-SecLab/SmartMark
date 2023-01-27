

pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}


contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library Require {



    uint256 constant ASCII_ZERO = 48; // '0'
    uint256 constant ASCII_RELATIVE_ZERO = 87; // 'a' - 10
    uint256 constant ASCII_LOWER_EX = 120; // 'x'
    bytes2 constant COLON = 0x3a20; // ': '
    bytes2 constant COMMA = 0x2c20; // ', '
    bytes2 constant LPAREN = 0x203c; // ' <'
    byte constant RPAREN = 0x3e; // '>'
    uint256 constant FOUR_BIT_MASK = 0xf;


    function that(
        bool must,
        bytes32 file,
        bytes32 reason
    )
        internal
        pure
    {

        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason)
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        uint256 payloadA
    )
        internal
        pure
    {

        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        uint256 payloadA,
        uint256 payloadB
    )
        internal
        pure
    {

        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA
    )
        internal
        pure
    {

        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        uint256 payloadB
    )
        internal
        pure
    {

        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        address payloadA,
        uint256 payloadB,
        uint256 payloadC
    )
        internal
        pure
    {

        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bytes32 payloadA
    )
        internal
        pure
    {

        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        RPAREN
                    )
                )
            );
        }
    }

    function that(
        bool must,
        bytes32 file,
        bytes32 reason,
        bytes32 payloadA,
        uint256 payloadB,
        uint256 payloadC
    )
        internal
        pure
    {

        if (!must) {
            revert(
                string(
                    abi.encodePacked(
                        stringifyTruncated(file),
                        COLON,
                        stringifyTruncated(reason),
                        LPAREN,
                        stringify(payloadA),
                        COMMA,
                        stringify(payloadB),
                        COMMA,
                        stringify(payloadC),
                        RPAREN
                    )
                )
            );
        }
    }


    function stringifyTruncated(
        bytes32 input
    )
        private
        pure
        returns (bytes memory)
    {

        bytes memory result = abi.encodePacked(input);

        for (uint256 i = 32; i > 0; ) {
            i--;

            if (result[i] != 0) {
                uint256 length = i + 1;

                assembly {
                    mstore(result, length) // r.length = length;
                }

                return result;
            }
        }

        return new bytes(0);
    }

    function stringify(
        uint256 input
    )
        private
        pure
        returns (bytes memory)
    {

        if (input == 0) {
            return "0";
        }

        uint256 j = input;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(length);

        j = input;
        for (uint256 i = length; i > 0; ) {
            i--;

            bstr[i] = byte(uint8(ASCII_ZERO + (j % 10)));

            j /= 10;
        }

        return bstr;
    }

    function stringify(
        address input
    )
        private
        pure
        returns (bytes memory)
    {

        uint256 z = uint256(input);

        bytes memory result = new bytes(42);

        result[0] = byte(uint8(ASCII_ZERO));
        result[1] = byte(uint8(ASCII_LOWER_EX));

        for (uint256 i = 0; i < 20; i++) {
            uint256 shift = i * 2;

            result[41 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;

            result[40 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;
        }

        return result;
    }

    function stringify(
        bytes32 input
    )
        private
        pure
        returns (bytes memory)
    {

        uint256 z = uint256(input);

        bytes memory result = new bytes(66);

        result[0] = byte(uint8(ASCII_ZERO));
        result[1] = byte(uint8(ASCII_LOWER_EX));

        for (uint256 i = 0; i < 32; i++) {
            uint256 shift = i * 2;

            result[65 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;

            result[64 - shift] = char(z & FOUR_BIT_MASK);
            z = z >> 4;
        }

        return result;
    }

    function char(
        uint256 input
    )
        private
        pure
        returns (byte)
    {

        if (input < 10) {
            return byte(uint8(input + ASCII_ZERO));
        }

        return byte(uint8(input + ASCII_RELATIVE_ZERO));
    }
}


library Math {

    using SafeMath for uint256;


    bytes32 constant FILE = "Math";


    function getPartial(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {

        return target.mul(numerator).div(denominator);
    }

    function getPartialRoundUp(
        uint256 target,
        uint256 numerator,
        uint256 denominator
    )
        internal
        pure
        returns (uint256)
    {

        if (target == 0 || numerator == 0) {
            return SafeMath.div(0, denominator);
        }
        return target.mul(numerator).sub(1).div(denominator).add(1);
    }

    function to128(
        uint256 number
    )
        internal
        pure
        returns (uint128)
    {

        uint128 result = uint128(number);
        Require.that(
            result == number,
            FILE,
            "Unsafe cast to uint128"
        );
        return result;
    }

    function to96(
        uint256 number
    )
        internal
        pure
        returns (uint96)
    {

        uint96 result = uint96(number);
        Require.that(
            result == number,
            FILE,
            "Unsafe cast to uint96"
        );
        return result;
    }

    function to32(
        uint256 number
    )
        internal
        pure
        returns (uint32)
    {

        uint32 result = uint32(number);
        Require.that(
            result == number,
            FILE,
            "Unsafe cast to uint32"
        );
        return result;
    }

    function min(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
    }

    function max(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {

        return a > b ? a : b;
    }
}


library Monetary {


    struct Price {
        uint256 value;
    }

    struct Value {
        uint256 value;
    }
}


library Types {

    using Math for uint256;


    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par  // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }


    struct TotalPar {
        uint128 borrow;
        uint128 supply;
    }

    struct Par {
        bool sign; // true if positive
        uint128 value;
    }

    function zeroPar()
        internal
        pure
        returns (Par memory)
    {

        return Par({
            sign: false,
            value: 0
        });
    }

    function sub(
        Par memory a,
        Par memory b
    )
        internal
        pure
        returns (Par memory)
    {

        return add(a, negative(b));
    }

    function add(
        Par memory a,
        Par memory b
    )
        internal
        pure
        returns (Par memory)
    {

        Par memory result;
        if (a.sign == b.sign) {
            result.sign = a.sign;
            result.value = SafeMath.add(a.value, b.value).to128();
        } else {
            if (a.value >= b.value) {
                result.sign = a.sign;
                result.value = SafeMath.sub(a.value, b.value).to128();
            } else {
                result.sign = b.sign;
                result.value = SafeMath.sub(b.value, a.value).to128();
            }
        }
        return result;
    }

    function equals(
        Par memory a,
        Par memory b
    )
        internal
        pure
        returns (bool)
    {

        if (a.value == b.value) {
            if (a.value == 0) {
                return true;
            }
            return a.sign == b.sign;
        }
        return false;
    }

    function negative(
        Par memory a
    )
        internal
        pure
        returns (Par memory)
    {

        return Par({
            sign: !a.sign,
            value: a.value
        });
    }

    function isNegative(
        Par memory a
    )
        internal
        pure
        returns (bool)
    {

        return !a.sign && a.value > 0;
    }

    function isPositive(
        Par memory a
    )
        internal
        pure
        returns (bool)
    {

        return a.sign && a.value > 0;
    }

    function isZero(
        Par memory a
    )
        internal
        pure
        returns (bool)
    {

        return a.value == 0;
    }


    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }

    function zeroWei()
        internal
        pure
        returns (Wei memory)
    {

        return Wei({
            sign: false,
            value: 0
        });
    }

    function sub(
        Wei memory a,
        Wei memory b
    )
        internal
        pure
        returns (Wei memory)
    {

        return add(a, negative(b));
    }

    function add(
        Wei memory a,
        Wei memory b
    )
        internal
        pure
        returns (Wei memory)
    {

        Wei memory result;
        if (a.sign == b.sign) {
            result.sign = a.sign;
            result.value = SafeMath.add(a.value, b.value);
        } else {
            if (a.value >= b.value) {
                result.sign = a.sign;
                result.value = SafeMath.sub(a.value, b.value);
            } else {
                result.sign = b.sign;
                result.value = SafeMath.sub(b.value, a.value);
            }
        }
        return result;
    }

    function equals(
        Wei memory a,
        Wei memory b
    )
        internal
        pure
        returns (bool)
    {

        if (a.value == b.value) {
            if (a.value == 0) {
                return true;
            }
            return a.sign == b.sign;
        }
        return false;
    }

    function negative(
        Wei memory a
    )
        internal
        pure
        returns (Wei memory)
    {

        return Wei({
            sign: !a.sign,
            value: a.value
        });
    }

    function isNegative(
        Wei memory a
    )
        internal
        pure
        returns (bool)
    {

        return !a.sign && a.value > 0;
    }

    function isPositive(
        Wei memory a
    )
        internal
        pure
        returns (bool)
    {

        return a.sign && a.value > 0;
    }

    function isZero(
        Wei memory a
    )
        internal
        pure
        returns (bool)
    {

        return a.value == 0;
    }
}


library Account {


    enum Status {
        Normal,
        Liquid,
        Vapor
    }


    struct Info {
        address owner;  // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }

    struct Storage {
        mapping (uint256 => Types.Par) balances; // Mapping from marketId to principal
        Status status;
    }


    function equals(
        Info memory a,
        Info memory b
    )
        internal
        pure
        returns (bool)
    {

        return a.owner == b.owner && a.number == b.number;
    }
}


contract IAutoTrader {



    function getTradeCost(
        uint256 inputMarketId,
        uint256 outputMarketId,
        Account.Info memory makerAccount,
        Account.Info memory takerAccount,
        Types.Par memory oldInputPar,
        Types.Par memory newInputPar,
        Types.Wei memory inputWei,
        bytes memory data
    )
        public
        returns (Types.AssetAmount memory);

}


contract ICallee {



    function callFunction(
        address sender,
        Account.Info memory accountInfo,
        bytes memory data
    )
        public;

}


contract SoloMargin {



    function getAccountWei(
        Account.Info memory account,
        uint256 marketId
    )
        public
        view
        returns (Types.Wei memory);


    function getMarketPrice(
        uint256 marketId
    )
        public
        view
        returns (Monetary.Price memory);


}


contract OnlySolo {



    bytes32 constant FILE = "OnlySolo";


    SoloMargin public SOLO_MARGIN;


    constructor (
        address soloMargin
    )
        public
    {
        SOLO_MARGIN = SoloMargin(soloMargin);
    }


    modifier onlySolo(address from) {

        Require.that(
            from == address(SOLO_MARGIN),
            FILE,
            "Only Solo can call function",
            from
        );
        _;
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


    function recover(
        bytes32 hash,
        bytes memory signatureWithType
    )
        internal
        pure
        returns (address)
    {

        Require.that(
            signatureWithType.length == NUM_SIGNATURE_BYTES,
            FILE,
            "Invalid signature length"
        );

        bytes32 r;
        bytes32 s;
        uint8 v;
        uint8 rawSigType;

        assembly {
            r := mload(add(signatureWithType, 0x20))
            s := mload(add(signatureWithType, 0x40))
            let lastSlot := mload(add(signatureWithType, 0x60))
            v := byte(0, lastSlot)
            rawSigType := byte(1, lastSlot)
        }

        Require.that(
            rawSigType < uint8(SignatureType.Invalid),
            FILE,
            "Invalid signature type"
        );

        SignatureType sigType = SignatureType(rawSigType);

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
            v,
            r,
            s
        );
    }
}


contract CanonicalOrders is
    Ownable,
    OnlySolo,
    IAutoTrader,
    ICallee
{

    using Math for uint256;
    using SafeMath for uint256;
    using Types for Types.Par;
    using Types for Types.Wei;


    bytes32 constant private FILE = "CanonicalOrders";

    bytes2 constant private EIP191_HEADER = 0x1901;

    string constant private EIP712_DOMAIN_NAME = "CanonicalOrders";

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
        "CanonicalOrder(",
        "bytes32 flags,",
        "uint256 baseMarket,",
        "uint256 quoteMarket,",
        "uint256 amount,",
        "uint256 limitPrice,",
        "uint256 triggerPrice,",
        "uint256 limitFee,",
        "address makerAccountOwner,",
        "uint256 makerAccountNumber,",
        "uint256 expiration",
        ")"
    ));

    uint256 constant private NUM_ORDER_AND_FILL_BYTES = 416;

    uint256 constant private NUM_SIGNATURE_BYTES = 66;

    uint256 constant private PRICE_BASE = 10 ** 18;

    bytes32 constant private IS_BUY_FLAG = bytes32(uint256(1));
    bytes32 constant private IS_DECREASE_ONLY_FLAG = bytes32(uint256(1 << 1));
    bytes32 constant private IS_NEGATIVE_FEE_FLAG = bytes32(uint256(1 << 2));


    enum OrderStatus {
        Null,
        Approved,
        Canceled
    }

    enum CallFunctionType {
        Approve,
        Cancel,
        SetFillArgs
    }


    struct Order {
        bytes32 flags; // salt, negativeFee, decreaseOnly, isBuy
        uint256 baseMarket;
        uint256 quoteMarket;
        uint256 amount;
        uint256 limitPrice;
        uint256 triggerPrice;
        uint256 limitFee;
        address makerAccountOwner;
        uint256 makerAccountNumber;
        uint256 expiration;
    }

    struct FillArgs {
        uint256 price;
        uint128 fee;
        bool isNegativeFee;
    }

    struct OrderInfo {
        Order order;
        FillArgs fill;
        bytes32 orderHash;
    }

    struct OrderQueryOutput {
        OrderStatus orderStatus;
        uint256 filledAmount;
    }


    event LogContractStatusSet(
        bool operational
    );

    event LogTakerSet(
        address taker
    );

    event LogCanonicalOrderCanceled(
        bytes32 indexed orderHash,
        address indexed canceler,
        uint256 baseMarket,
        uint256 quoteMarket
    );

    event LogCanonicalOrderApproved(
        bytes32 indexed orderHash,
        address indexed approver,
        uint256 baseMarket,
        uint256 quoteMarket
    );

    event LogCanonicalOrderFilled(
        bytes32 indexed orderHash,
        address indexed orderMaker,
        uint256 fillAmount,
        uint256 totalFilledAmount,
        bool isBuy,
        FillArgs fill
    );


    bytes32 public EIP712_DOMAIN_HASH;


    bool public g_isOperational;

    mapping (bytes32 => uint256) public g_filledAmount;

    mapping (bytes32 => OrderStatus) public g_status;

    FillArgs public g_fillArgs;

    address public g_taker;


    constructor (
        address soloMargin,
        address taker,
        uint256 chainId
    )
        public
        OnlySolo(soloMargin)
    {
        g_isOperational = true;
        g_taker = taker;

        EIP712_DOMAIN_HASH = keccak256(abi.encode(
            EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
            keccak256(bytes(EIP712_DOMAIN_NAME)),
            keccak256(bytes(EIP712_DOMAIN_VERSION)),
            chainId,
            address(this)
        ));
    }


    function shutDown()
        external
        onlyOwner
    {

        g_isOperational = false;
        emit LogContractStatusSet(false);
    }

    function startUp()
        external
        onlyOwner
    {

        g_isOperational = true;
        emit LogContractStatusSet(true);
    }

    function setTakerAddress(
        address taker
    )
        external
        onlyOwner
    {

        g_taker = taker;
        emit LogTakerSet(taker);
    }


    function cancelOrder(
        Order memory order
    )
        public
    {

        cancelOrderInternal(msg.sender, order);
    }

    function approveOrder(
        Order memory order
    )
        public
    {

        approveOrderInternal(msg.sender, order);
    }


    function getTradeCost(
        uint256 inputMarketId,
        uint256 outputMarketId,
        Account.Info memory makerAccount,
        Account.Info memory takerAccount,
        Types.Par memory oldInputPar,
        Types.Par memory newInputPar,
        Types.Wei memory inputWei,
        bytes memory data
    )
        public
        onlySolo(msg.sender)
        returns (Types.AssetAmount memory)
    {

        Require.that(
            g_isOperational,
            FILE,
            "Contract is not operational"
        );

        OrderInfo memory orderInfo = getOrderInfo(data);

        verifySignature(orderInfo, data);

        verifyOrderInfo(
            orderInfo,
            makerAccount,
            takerAccount,
            inputMarketId,
            outputMarketId,
            inputWei
        );

        Types.AssetAmount memory assetAmount = getOutputAssetAmount(
            inputMarketId,
            outputMarketId,
            inputWei,
            orderInfo
        );

        if (isDecreaseOnly(orderInfo.order)) {
            verifyDecreaseOnly(
                oldInputPar,
                newInputPar,
                assetAmount,
                makerAccount,
                outputMarketId
            );
        }

        return assetAmount;
    }

    function callFunction(
        address /* sender */,
        Account.Info memory accountInfo,
        bytes memory data
    )
        public
        onlySolo(msg.sender)
    {

        CallFunctionType cft = abi.decode(data, (CallFunctionType));

        if (cft == CallFunctionType.SetFillArgs) {
            FillArgs memory fillArgs;
            (cft, fillArgs) = abi.decode(data, (CallFunctionType, FillArgs));
            g_fillArgs = fillArgs;
        } else {
            Order memory order;
            (cft, order) = abi.decode(data, (CallFunctionType, Order));
            if (cft == CallFunctionType.Approve) {
                approveOrderInternal(accountInfo.owner, order);
            } else {
                assert(cft == CallFunctionType.Cancel);
                cancelOrderInternal(accountInfo.owner, order);
            }
        }
    }


    function getOrderStates(
        bytes32[] memory orderHashes
    )
        public
        view
        returns(OrderQueryOutput[] memory)
    {

        uint256 numOrders = orderHashes.length;
        OrderQueryOutput[] memory output = new OrderQueryOutput[](numOrders);

        for (uint256 i = 0; i < numOrders; i++) {
            bytes32 orderHash = orderHashes[i];
            output[i] = OrderQueryOutput({
                orderStatus: g_status[orderHash],
                filledAmount: g_filledAmount[orderHash]
            });
        }
        return output;
    }


    function cancelOrderInternal(
        address canceler,
        Order memory order
    )
        private
    {

        Require.that(
            canceler == order.makerAccountOwner,
            FILE,
            "Canceler must be maker"
        );
        bytes32 orderHash = getOrderHash(order);
        g_status[orderHash] = OrderStatus.Canceled;
        emit LogCanonicalOrderCanceled(
            orderHash,
            canceler,
            order.baseMarket,
            order.quoteMarket
        );
    }

    function approveOrderInternal(
        address approver,
        Order memory order
    )
        private
    {

        Require.that(
            approver == order.makerAccountOwner,
            FILE,
            "Approver must be maker"
        );
        bytes32 orderHash = getOrderHash(order);
        Require.that(
            g_status[orderHash] != OrderStatus.Canceled,
            FILE,
            "Cannot approve canceled order",
            orderHash
        );
        g_status[orderHash] = OrderStatus.Approved;
        emit LogCanonicalOrderApproved(
            orderHash,
            approver,
            order.baseMarket,
            order.quoteMarket
        );
    }


    function getOrderInfo(
        bytes memory data
    )
        private
        returns (OrderInfo memory)
    {

        Require.that(
            (
                data.length == NUM_ORDER_AND_FILL_BYTES ||
                data.length == NUM_ORDER_AND_FILL_BYTES + NUM_SIGNATURE_BYTES
            ),
            FILE,
            "Cannot parse order from data"
        );

        OrderInfo memory orderInfo;
        (
            orderInfo.order,
            orderInfo.fill
        ) = abi.decode(data, (Order, FillArgs));

        if (orderInfo.fill.price == 0) {
            orderInfo.fill = g_fillArgs;
            g_fillArgs = FillArgs({
                price: 0,
                fee: 0,
                isNegativeFee: false
            });
        }
        Require.that(
            orderInfo.fill.price != 0,
            FILE,
            "FillArgs loaded price is zero"
        );

        orderInfo.orderHash = getOrderHash(orderInfo.order);

        return orderInfo;
    }

    function verifySignature(
        OrderInfo memory orderInfo,
        bytes memory data
    )
        private
        view
    {

        OrderStatus orderStatus = g_status[orderInfo.orderHash];

        if (orderStatus == OrderStatus.Null) {
            bytes memory signature = parseSignature(data);
            address signer = TypedSignature.recover(orderInfo.orderHash, signature);
            Require.that(
                orderInfo.order.makerAccountOwner == signer,
                FILE,
                "Order invalid signature",
                orderInfo.orderHash
            );
        } else {
            Require.that(
                orderStatus != OrderStatus.Canceled,
                FILE,
                "Order canceled",
                orderInfo.orderHash
            );
            assert(orderStatus == OrderStatus.Approved);
        }
    }

    function verifyOrderInfo(
        OrderInfo memory orderInfo,
        Account.Info memory makerAccount,
        Account.Info memory takerAccount,
        uint256 inputMarketId,
        uint256 outputMarketId,
        Types.Wei memory inputWei
    )
        private
        view
    {

        FillArgs memory fill = orderInfo.fill;
        bool validPrice = isBuy(orderInfo.order)
            ? fill.price <= orderInfo.order.limitPrice
            : fill.price >= orderInfo.order.limitPrice;
        Require.that(
            validPrice,
            FILE,
            "Fill invalid price"
        );

        bool validFee = isNegativeLimitFee(orderInfo.order)
            ? (fill.fee >= orderInfo.order.limitFee) && fill.isNegativeFee
            : (fill.fee <= orderInfo.order.limitFee) || fill.isNegativeFee;
        Require.that(
            validFee,
            FILE,
            "Fill invalid fee"
        );

        if (orderInfo.order.triggerPrice > 0) {
            uint256 currentPrice = getCurrentPrice(
                orderInfo.order.baseMarket,
                orderInfo.order.quoteMarket
            );
            Require.that(
                isBuy(orderInfo.order)
                    ? currentPrice >= orderInfo.order.triggerPrice
                    : currentPrice <= orderInfo.order.triggerPrice,
                FILE,
                "Order triggerPrice not triggered",
                currentPrice
            );
        }

        Require.that(
            orderInfo.order.expiration == 0 || orderInfo.order.expiration >= block.timestamp,
            FILE,
            "Order expired",
            orderInfo.orderHash
        );

        Require.that(
            makerAccount.owner == orderInfo.order.makerAccountOwner &&
            makerAccount.number == orderInfo.order.makerAccountNumber,
            FILE,
            "Order maker account mismatch",
            orderInfo.orderHash
        );

        Require.that(
            takerAccount.owner == g_taker,
            FILE,
            "Order taker mismatch",
            orderInfo.orderHash
        );

        Require.that(
            (
                orderInfo.order.baseMarket == outputMarketId &&
                orderInfo.order.quoteMarket == inputMarketId
            ) || (
                orderInfo.order.quoteMarket == outputMarketId &&
                orderInfo.order.baseMarket == inputMarketId
            ),
            FILE,
            "Market mismatch",
            orderInfo.orderHash
        );

        Require.that(
            !inputWei.isZero(),
            FILE,
            "InputWei is zero",
            orderInfo.orderHash
        );

        Require.that(
            inputWei.sign ==
                ((orderInfo.order.baseMarket == inputMarketId) == isBuy(orderInfo.order)),
            FILE,
            "InputWei sign mismatch",
            orderInfo.orderHash
        );
    }

    function verifyDecreaseOnly(
        Types.Par memory oldInputPar,
        Types.Par memory newInputPar,
        Types.AssetAmount memory assetAmount,
        Account.Info memory makerAccount,
        uint256 outputMarketId
    )
        private
        view
    {

        Require.that(
            newInputPar.isZero()
            || (newInputPar.value <= oldInputPar.value && newInputPar.sign == oldInputPar.sign),
            FILE,
            "inputMarket not decreased"
        );

        Types.Wei memory oldOutputWei = SOLO_MARGIN.getAccountWei(makerAccount, outputMarketId);
        Require.that(
            assetAmount.value == 0
            || (assetAmount.value <= oldOutputWei.value && assetAmount.sign != oldOutputWei.sign),
            FILE,
            "outputMarket not decreased"
        );
    }

    function getOutputAssetAmount(
        uint256 inputMarketId,
        uint256 outputMarketId,
        Types.Wei memory inputWei,
        OrderInfo memory orderInfo
    )
        private
        returns (Types.AssetAmount memory)
    {

        uint256 fee = orderInfo.fill.price.getPartial(orderInfo.fill.fee, PRICE_BASE);
        uint256 adjustedPrice = (isBuy(orderInfo.order) == orderInfo.fill.isNegativeFee)
            ? orderInfo.fill.price.sub(fee)
            : orderInfo.fill.price.add(fee);

        uint256 outputAmount;
        uint256 fillAmount;
        if (orderInfo.order.quoteMarket == inputMarketId) {
            outputAmount = inputWei.value.getPartial(PRICE_BASE, adjustedPrice);
            fillAmount = outputAmount;
        } else {
            assert(orderInfo.order.quoteMarket == outputMarketId);
            outputAmount = inputWei.value.getPartial(adjustedPrice, PRICE_BASE);
            fillAmount = inputWei.value;
        }

        updateFilledAmount(orderInfo, fillAmount);

        return Types.AssetAmount({
            sign: !inputWei.sign,
            denomination: Types.AssetDenomination.Wei,
            ref: Types.AssetReference.Delta,
            value: outputAmount
        });
    }

    function updateFilledAmount(
        OrderInfo memory orderInfo,
        uint256 fillAmount
    )
        private
    {

        uint256 oldFilledAmount = g_filledAmount[orderInfo.orderHash];
        uint256 totalFilledAmount = oldFilledAmount.add(fillAmount);
        Require.that(
            totalFilledAmount <= orderInfo.order.amount,
            FILE,
            "Cannot overfill order",
            orderInfo.orderHash,
            oldFilledAmount,
            fillAmount
        );

        g_filledAmount[orderInfo.orderHash] = totalFilledAmount;

        emit LogCanonicalOrderFilled(
            orderInfo.orderHash,
            orderInfo.order.makerAccountOwner,
            fillAmount,
            totalFilledAmount,
            isBuy(orderInfo.order),
            orderInfo.fill
        );
    }

    function getCurrentPrice(
        uint256 baseMarket,
        uint256 quoteMarket
    )
        private
        view
        returns (uint256)
    {

        Monetary.Price memory basePrice = SOLO_MARGIN.getMarketPrice(baseMarket);
        Monetary.Price memory quotePrice = SOLO_MARGIN.getMarketPrice(quoteMarket);
        return basePrice.value.mul(PRICE_BASE).div(quotePrice.value);
    }


    function getOrderHash(
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
            EIP712_DOMAIN_HASH,
            structHash
        ));
    }

    function parseSignature(
        bytes memory data
    )
        private
        pure
        returns (bytes memory)
    {

        Require.that(
            data.length == NUM_ORDER_AND_FILL_BYTES + NUM_SIGNATURE_BYTES,
            FILE,
            "Cannot parse signature from data"
        );

        bytes memory signature = new bytes(NUM_SIGNATURE_BYTES);

        uint256 sigOffset = NUM_ORDER_AND_FILL_BYTES;
        assembly {
            let sigStart := add(data, sigOffset)
            mstore(add(signature, 0x020), mload(add(sigStart, 0x20)))
            mstore(add(signature, 0x040), mload(add(sigStart, 0x40)))
            mstore(add(signature, 0x042), mload(add(sigStart, 0x42)))
        }

        return signature;
    }

    function isBuy(
        Order memory order
    )
        private
        pure
        returns (bool)
    {

        return (order.flags & IS_BUY_FLAG) != bytes32(0);
    }

    function isDecreaseOnly(
        Order memory order
    )
        private
        pure
        returns (bool)
    {

        return (order.flags & IS_DECREASE_ONLY_FLAG) != bytes32(0);
    }

    function isNegativeLimitFee(
        Order memory order
    )
        private
        pure
        returns (bool)
    {

        return (order.flags & IS_NEGATIVE_FEE_FLAG) != bytes32(0);
    }
}