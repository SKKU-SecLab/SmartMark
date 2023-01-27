pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;


library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65) {
            return (address(0));
        }

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;



library LibOrder {

    using SafeMath for uint256;

    uint256 public constant ODDS_PRECISION = 10**20;

    struct Order {
        bytes32 marketHash;
        address baseToken;
        uint256 totalBetSize;
        uint256 percentageOdds;
        uint256 expiry;
        uint256 salt;
        address maker;
        address executor;
        bool isMakerBettingOutcomeOne;
    }

    struct FillObject {
        Order[] orders;
        bytes[] makerSigs;
        uint256[] takerAmounts;
        uint256 fillSalt;
    }

    struct FillDetails {
        string action;
        string market;
        string betting;
        string stake;
        string odds;
        string returning;
        FillObject fills;
    }

    function getParamValidity(Order memory order)
        internal
        view
        returns (string memory)
    {

        if (order.totalBetSize == 0) {return "TOTAL_BET_SIZE_ZERO";}
        if (order.percentageOdds == 0 || order.percentageOdds >= ODDS_PRECISION) {return "INVALID_PERCENTAGE_ODDS";}
        if (order.expiry < now) {return "ORDER_EXPIRED";}
        if (order.baseToken == address(0)) {return "BASE_TOKEN";}
        return "OK";
    }

    function checkSignature(Order memory order, bytes memory makerSig)
        internal
        pure
        returns (bool)
    {

        bytes32 orderHash = getOrderHash(order);
        return ECDSA.recover(ECDSA.toEthSignedMessageHash(orderHash), makerSig) == order.maker;
    }

    function assertValidParams(Order memory order) internal view {

        require(
            order.totalBetSize > 0,
            "TOTAL_BET_SIZE_ZERO"
        );
        require(
            order.percentageOdds > 0 && order.percentageOdds < ODDS_PRECISION,
            "INVALID_PERCENTAGE_ODDS"
        );
        require(order.baseToken != address(0), "INVALID_BASE_TOKEN");
        require(order.expiry > now, "ORDER_EXPIRED");
    }

    function assertValidAsTaker(Order memory order, address taker, bytes memory makerSig) internal view {

        assertValidParams(order);
        require(
            checkSignature(order, makerSig),
            "SIGNATURE_MISMATCH"
        );
        require(order.maker != taker, "TAKER_NOT_MAKER");
    }

    function assertValidAsMaker(Order memory order, address sender) internal view {

        assertValidParams(order);
        require(order.maker == sender, "CALLER_NOT_MAKER");
    }

    function getOrderHash(Order memory order) internal pure returns (bytes32) {

        return keccak256(
            abi.encodePacked(
                order.marketHash,
                order.baseToken,
                order.totalBetSize,
                order.percentageOdds,
                order.expiry,
                order.salt,
                order.maker,
                order.executor,
                order.isMakerBettingOutcomeOne
            )
        );
    }

    function getOddsPrecision() internal pure returns (uint256) {

        return ODDS_PRECISION;
    }
}pragma solidity 0.5.16;



contract EIP712FillHasher {


    bytes2 constant private EIP191_HEADER = 0x1901;

    string constant private EIP712_DOMAIN_NAME = "SportX";

    string constant private EIP712_DOMAIN_VERSION = "1.0";

    bytes32 constant private EIP712_DOMAIN_SCHEMA_HASH = keccak256(
        abi.encodePacked(
            "EIP712Domain(",
            "string name,",
            "string version,",
            "uint256 chainId,",
            "address verifyingContract",
            ")"
        )
    );

    bytes constant private EIP712_DETAILS_STRING = abi.encodePacked(
        "Details(",
        "string action,",
        "string market,",
        "string betting,",
        "string stake,",
        "string odds,",
        "string returning,",
        "FillObject fills",
        ")"
    );

    bytes constant private EIP712_FILL_OBJECT_STRING = abi.encodePacked(
        "FillObject(",
        "Order[] orders,",
        "bytes[] makerSigs,",
        "uint256[] takerAmounts,",
        "uint256 fillSalt",
        ")"
    );

    bytes constant private EIP712_ORDER_STRING = abi.encodePacked(
        "Order(",
        "bytes32 marketHash,",
        "address baseToken,",
        "uint256 totalBetSize,",
        "uint256 percentageOdds,",
        "uint256 expiry,",
        "uint256 salt,",
        "address maker,",
        "address executor,",
        "bool isMakerBettingOutcomeOne",
        ")"
    );

    bytes32 constant private EIP712_ORDER_HASH = keccak256(
        abi.encodePacked(
            EIP712_ORDER_STRING
        )
    );

    bytes32 constant private EIP712_FILL_OBJECT_HASH = keccak256(
        abi.encodePacked(
            EIP712_FILL_OBJECT_STRING,
            EIP712_ORDER_STRING
        )
    );

    bytes32 constant private EIP712_DETAILS_HASH = keccak256(
        abi.encodePacked(
            EIP712_DETAILS_STRING,
            EIP712_FILL_OBJECT_STRING,
            EIP712_ORDER_STRING
        )
    );

    bytes32 public EIP712_DOMAIN_HASH;

    constructor(uint256 chainId) public {
        EIP712_DOMAIN_HASH = keccak256(
            abi.encode(
                EIP712_DOMAIN_SCHEMA_HASH,
                keccak256(bytes(EIP712_DOMAIN_NAME)),
                keccak256(bytes(EIP712_DOMAIN_VERSION)),
                chainId,
                address(this)
            )
        );
    }

    function getOrderHash(LibOrder.Order memory order)
        public
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encode(
                EIP712_ORDER_HASH,
                order.marketHash,
                order.baseToken,
                order.totalBetSize,
                order.percentageOdds,
                order.expiry,
                order.salt,
                order.maker,
                order.executor,
                order.isMakerBettingOutcomeOne
            )
        );
    }

    function getOrdersArrayHash(LibOrder.Order[] memory orders)
        public
        pure
        returns (bytes32)
    {

        bytes32[] memory ordersBytes = new bytes32[](orders.length);

        for (uint256 i = 0; i < orders.length; i++) {
            ordersBytes[i] = getOrderHash(orders[i]);
        }
        return keccak256(abi.encodePacked(ordersBytes));
    }

    function getMakerSigsArrayHash(bytes[] memory sigs)
        public
        pure
        returns (bytes32)
    {

        bytes32[] memory sigsBytes = new bytes32[](sigs.length);

        for (uint256 i = 0; i < sigs.length; i++) {
            sigsBytes[i] = keccak256(sigs[i]);
        }

        return keccak256(abi.encodePacked(sigsBytes));
    }

    function getFillObjectHash(LibOrder.FillObject memory fillObject)
        public
        pure
        returns (bytes32)
    {

        return keccak256(
            abi.encode(
                EIP712_FILL_OBJECT_HASH,
                getOrdersArrayHash(fillObject.orders),
                getMakerSigsArrayHash(fillObject.makerSigs),
                keccak256(abi.encodePacked(fillObject.takerAmounts)),
                fillObject.fillSalt
            )
        );
    }

    function getDetailsHash(LibOrder.FillDetails memory details)
        public
        view
        returns (bytes32)
    {

        bytes32 structHash = keccak256(
            abi.encode(
                EIP712_DETAILS_HASH,
                keccak256(bytes(details.action)),
                keccak256(bytes(details.market)),
                keccak256(bytes(details.betting)),
                keccak256(bytes(details.stake)),
                keccak256(bytes(details.odds)),
                keccak256(bytes(details.returning)),
                getFillObjectHash(details.fills)
            )
        );
        return keccak256(
            abi.encodePacked(
                EIP191_HEADER,
                EIP712_DOMAIN_HASH,
                structHash
            )
        );
    }

    function getDomainHash()
        public
        view
        returns (bytes32)
    {

        return EIP712_DOMAIN_HASH;
    }
}