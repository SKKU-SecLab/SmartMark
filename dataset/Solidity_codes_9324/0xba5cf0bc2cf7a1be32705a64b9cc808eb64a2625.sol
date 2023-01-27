
pragma solidity ^0.8.13;


abstract contract FixinERC1155Spender {

    uint256 constant private ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;

    function _transferERC1155AssetFrom(
        address token,
        address owner,
        address to,
        uint256 tokenId,
        uint256 amount
    )
        internal
    {
        uint256 success;
        assembly {
            let ptr := mload(0x40) // free memory pointer

            mstore(ptr, 0xf242432a00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), and(owner, ADDRESS_MASK))
            mstore(add(ptr, 0x24), and(to, ADDRESS_MASK))
            mstore(add(ptr, 0x44), tokenId)
            mstore(add(ptr, 0x64), amount)
            mstore(add(ptr, 0x84), 0xa0)
            mstore(add(ptr, 0xa4), 0)

            success := call(
                gas(),
                and(token, ADDRESS_MASK),
                0,
                ptr,
                0xc4,
                0,
                0
            )
        }
        require(success != 0, "_transferERC1155/TRANSFER_FAILED");
    }
}// Apache-2.0

pragma solidity ^0.8.13;


library LibStorage {


    uint256 constant STORAGE_ID_PROXY = 1 << 128;
    uint256 constant STORAGE_ID_SIMPLE_FUNCTION_REGISTRY = 2 << 128;
    uint256 constant STORAGE_ID_OWNABLE = 3 << 128;
    uint256 constant STORAGE_ID_COMMON_NFT_ORDERS = 4 << 128;
    uint256 constant STORAGE_ID_ERC721_ORDERS = 5 << 128;
    uint256 constant STORAGE_ID_ERC1155_ORDERS = 6 << 128;
}// Apache-2.0

pragma solidity ^0.8.13;



library LibCommonNftOrdersStorage {


    struct Storage {
        mapping(address => uint256) hashNonces;
    }

    function getStorage() internal pure returns (Storage storage stor) {

        uint256 storageSlot = LibStorage.STORAGE_ID_COMMON_NFT_ORDERS;
        assembly { stor.slot := storageSlot }
    }
}// Apache-2.0

pragma solidity ^0.8.13;



library LibERC1155OrdersStorage {


    struct OrderState {
        uint128 filledAmount;
        uint128 preSigned;
    }

    struct Storage {
        mapping(bytes32 => OrderState) orderState;
        mapping(address => mapping(uint248 => uint256)) orderCancellationByMaker;
    }

    function getStorage() internal pure returns (Storage storage stor) {

        uint256 storageSlot = LibStorage.STORAGE_ID_ERC1155_ORDERS;
        assembly { stor.slot := storageSlot }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// Apache-2.0

pragma solidity ^0.8.13;


interface IPropertyValidator {


    function validateProperty(address tokenAddress, uint256 tokenId, bytes calldata propertyData) external view;

}// Apache-2.0

pragma solidity ^0.8.13;



library LibNFTOrder {


    enum OrderStatus {
        INVALID,
        FILLABLE,
        UNFILLABLE,
        EXPIRED
    }

    struct Property {
        IPropertyValidator propertyValidator;
        bytes propertyData;
    }

    struct Fee {
        address recipient;
        uint256 amount;
        bytes feeData;
    }

    struct NFTSellOrder {
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        address nft;
        uint256 nftId;
    }

    struct NFTBuyOrder {
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        address nft;
        uint256 nftId;
        Property[] nftProperties;
    }

    struct ERC1155SellOrder {
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        address erc1155Token;
        uint256 erc1155TokenId;
        uint128 erc1155TokenAmount;
    }

    struct ERC1155BuyOrder {
        address maker;
        address taker;
        uint256 expiry;
        uint256 nonce;
        IERC20 erc20Token;
        uint256 erc20TokenAmount;
        Fee[] fees;
        address erc1155Token;
        uint256 erc1155TokenId;
        Property[] erc1155TokenProperties;
        uint128 erc1155TokenAmount;
    }

    struct OrderInfo {
        bytes32 orderHash;
        OrderStatus status;
        uint128 orderAmount;
        uint128 remainingAmount;
    }

    uint256 private constant _NFT_SELL_ORDER_TYPE_HASH = 0xed676c7f3e8232a311454799b1cf26e75b4abc90c9bf06c9f7e8e79fcc7fe14d;

    uint256 private constant _NFT_BUY_ORDER_TYPE_HASH = 0xa525d336300f566329800fcbe82fd263226dc27d6c109f060d9a4a364281521c;

    uint256 private constant _ERC_1155_SELL_ORDER_TYPE_HASH = 0x3529b5920cc48ecbceb24e9c51dccb50fefd8db2cf05d36e356aeb1754e19eda;

    uint256 private constant _ERC_1155_BUY_ORDER_TYPE_HASH = 0x1a6eaae1fbed341e0974212ec17f035a9d419cadc3bf5154841cbf7fd605ba48;

    uint256 private constant _FEE_TYPE_HASH = 0xe68c29f1b4e8cce0bbcac76eb1334bdc1dc1f293a517c90e9e532340e1e94115;

    uint256 private constant _PROPERTY_TYPE_HASH = 0x6292cf854241cb36887e639065eca63b3af9f7f70270cebeda4c29b6d3bc65e8;

    bytes32 private constant _EMPTY_ARRAY_KECCAK256 = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    bytes32 private constant _NULL_PROPERTY_STRUCT_HASH = 0x720ee400a9024f6a49768142c339bf09d2dd9056ab52d20fbe7165faba6e142d;

    uint256 private constant ADDRESS_MASK = (1 << 160) - 1;

    function asNFTSellOrder(NFTBuyOrder memory nftBuyOrder) internal pure returns (NFTSellOrder memory order) {

        assembly { order := nftBuyOrder }
    }

    function asNFTSellOrder(ERC1155SellOrder memory erc1155SellOrder) internal pure returns (NFTSellOrder memory order) {

        assembly { order := erc1155SellOrder }
    }

    function asNFTBuyOrder(ERC1155BuyOrder memory erc1155BuyOrder) internal pure returns (NFTBuyOrder memory order) {

        assembly { order := erc1155BuyOrder }
    }

    function asERC1155SellOrder(NFTSellOrder memory nftSellOrder) internal pure returns (ERC1155SellOrder memory order) {

        assembly { order := nftSellOrder }
    }

    function asERC1155BuyOrder(NFTBuyOrder memory nftBuyOrder) internal pure returns (ERC1155BuyOrder memory order) {

        assembly { order := nftBuyOrder }
    }

    function getNFTSellOrderStructHash(NFTSellOrder memory order, uint256 hashNonce) internal pure returns (bytes32 structHash) {

        bytes32 feesHash = _feesHash(order.fees);

        assembly {
            if lt(order, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 192) // order + (32 * 6)
            let hashNoncePos := add(order, 288) // order + (32 * 9)

            let typeHashMemBefore := mload(typeHashPos)
            let feeHashMemBefore := mload(feesHashPos)
            let hashNonceMemBefore := mload(hashNoncePos)

            mstore(typeHashPos, _NFT_SELL_ORDER_TYPE_HASH)
            mstore(feesHashPos, feesHash)
            mstore(hashNoncePos, hashNonce)
            structHash := keccak256(typeHashPos, 352 /* 32 * 11 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feeHashMemBefore)
            mstore(hashNoncePos, hashNonceMemBefore)
        }
        return structHash;
    }

    function getNFTBuyOrderStructHash(NFTBuyOrder memory order, uint256 hashNonce) internal pure returns (bytes32 structHash) {

        bytes32 propertiesHash = _propertiesHash(order.nftProperties);
        bytes32 feesHash = _feesHash(order.fees);

        assembly {
            if lt(order, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 192) // order + (32 * 6)
            let propertiesHashPos := add(order, 288) // order + (32 * 9)
            let hashNoncePos := add(order, 320) // order + (32 * 10)

            let typeHashMemBefore := mload(typeHashPos)
            let feeHashMemBefore := mload(feesHashPos)
            let propertiesHashMemBefore := mload(propertiesHashPos)
            let hashNonceMemBefore := mload(hashNoncePos)

            mstore(typeHashPos, _NFT_BUY_ORDER_TYPE_HASH)
            mstore(feesHashPos, feesHash)
            mstore(propertiesHashPos, propertiesHash)
            mstore(hashNoncePos, hashNonce)
            structHash := keccak256(typeHashPos, 384 /* 32 * 12 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feeHashMemBefore)
            mstore(propertiesHashPos, propertiesHashMemBefore)
            mstore(hashNoncePos, hashNonceMemBefore)
        }
        return structHash;
    }

    function getERC1155SellOrderStructHash(ERC1155SellOrder memory order, uint256 hashNonce) internal pure returns (bytes32 structHash) {

        bytes32 feesHash = _feesHash(order.fees);

        assembly {
            if lt(order, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 192) // order + (32 * 6)
            let hashNoncePos := add(order, 320) // order + (32 * 10)

            let typeHashMemBefore := mload(typeHashPos)
            let feesHashMemBefore := mload(feesHashPos)
            let hashNonceMemBefore := mload(hashNoncePos)

            mstore(typeHashPos, _ERC_1155_SELL_ORDER_TYPE_HASH)
            mstore(feesHashPos, feesHash)
            mstore(hashNoncePos, hashNonce)
            structHash := keccak256(typeHashPos, 384 /* 32 * 12 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feesHashMemBefore)
            mstore(hashNoncePos, hashNonceMemBefore)
        }
        return structHash;
    }

    function getERC1155BuyOrderStructHash(ERC1155BuyOrder memory order, uint256 hashNonce) internal pure returns (bytes32 structHash) {

        bytes32 propertiesHash = _propertiesHash(order.erc1155TokenProperties);
        bytes32 feesHash = _feesHash(order.fees);

        assembly {
            if lt(order, 32) { invalid() } // Don't underflow memory.

            let typeHashPos := sub(order, 32) // order - 32
            let feesHashPos := add(order, 192) // order + (32 * 6)
            let propertiesHashPos := add(order, 288) // order + (32 * 9)
            let hashNoncePos := add(order, 352) // order + (32 * 11)

            let typeHashMemBefore := mload(typeHashPos)
            let feesHashMemBefore := mload(feesHashPos)
            let propertiesHashMemBefore := mload(propertiesHashPos)
            let hashNonceMemBefore := mload(hashNoncePos)

            mstore(typeHashPos, _ERC_1155_BUY_ORDER_TYPE_HASH)
            mstore(feesHashPos, feesHash)
            mstore(propertiesHashPos, propertiesHash)
            mstore(hashNoncePos, hashNonce)
            structHash := keccak256(typeHashPos, 416 /* 32 * 13 */ )

            mstore(typeHashPos, typeHashMemBefore)
            mstore(feesHashPos, feesHashMemBefore)
            mstore(propertiesHashPos, propertiesHashMemBefore)
            mstore(hashNoncePos, hashNonceMemBefore)
        }
        return structHash;
    }

    function _propertiesHash(Property[] memory properties) private pure returns (bytes32 propertiesHash) {

        uint256 numProperties = properties.length;
        if (numProperties == 0) {
            propertiesHash = _EMPTY_ARRAY_KECCAK256;
        } else if (numProperties == 1) {
            Property memory property = properties[0];
            if (address(property.propertyValidator) == address(0) && property.propertyData.length == 0) {
                propertiesHash = _NULL_PROPERTY_STRUCT_HASH;
            } else {
                bytes32 dataHash = keccak256(property.propertyData);
                assembly {
                    let mem := mload(64)
                    mstore(mem, _PROPERTY_TYPE_HASH)
                    mstore(add(mem, 32), and(ADDRESS_MASK, mload(property)))
                    mstore(add(mem, 64), dataHash)
                    mstore(mem, keccak256(mem, 96))
                    propertiesHash := keccak256(mem, 32)
                }
            }
        } else {
            bytes32[] memory propertyStructHashArray = new bytes32[](numProperties);
            for (uint256 i = 0; i < numProperties; i++) {
                propertyStructHashArray[i] = keccak256(abi.encode(
                        _PROPERTY_TYPE_HASH, properties[i].propertyValidator, keccak256(properties[i].propertyData)));
            }
            assembly {
                propertiesHash := keccak256(add(propertyStructHashArray, 32), mul(numProperties, 32))
            }
        }
    }

    function _feesHash(Fee[] memory fees) private pure returns (bytes32 feesHash) {

        uint256 numFees = fees.length;
        if (numFees == 0) {
            feesHash = _EMPTY_ARRAY_KECCAK256;
        } else if (numFees == 1) {
            Fee memory fee = fees[0];
            bytes32 dataHash = keccak256(fee.feeData);
            assembly {
                let mem := mload(64)
                mstore(mem, _FEE_TYPE_HASH)
                mstore(add(mem, 32), and(ADDRESS_MASK, mload(fee)))
                mstore(add(mem, 64), mload(add(fee, 32)))
                mstore(add(mem, 96), dataHash)
                mstore(mem, keccak256(mem, 128))
                feesHash := keccak256(mem, 32)
            }
        } else {
            bytes32[] memory feeStructHashArray = new bytes32[](numFees);
            for (uint256 i = 0; i < numFees; i++) {
                feeStructHashArray[i] = keccak256(abi.encode(_FEE_TYPE_HASH, fees[i].recipient, fees[i].amount, keccak256(fees[i].feeData)));
            }
            assembly {
                feesHash := keccak256(add(feeStructHashArray, 32), mul(numFees, 32))
            }
        }
    }
}// Apache-2.0

pragma solidity ^0.8.13;

library LibSignature {


    enum SignatureType {
        EIP712,
        PRESIGNED
    }

    struct Signature {
        SignatureType signatureType;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
}// Apache-2.0

pragma solidity ^0.8.13;



interface IERC1155OrdersEvent {


    event ERC1155SellOrderFilled(
        address maker,
        address taker,
        IERC20 erc20Token,
        uint256 erc20FillAmount,
        address erc1155Token,
        uint256 erc1155TokenId,
        uint128 erc1155FillAmount,
        bytes32 orderHash
    );

    event ERC1155BuyOrderFilled(
        address maker,
        address taker,
        IERC20 erc20Token,
        uint256 erc20FillAmount,
        address erc1155Token,
        uint256 erc1155TokenId,
        uint128 erc1155FillAmount,
        bytes32 orderHash
    );

    event ERC1155SellOrderPreSigned(
        address maker,
        address taker,
        uint256 expiry,
        uint256 nonce,
        IERC20 erc20Token,
        uint256 erc20TokenAmount,
        LibNFTOrder.Fee[] fees,
        address erc1155Token,
        uint256 erc1155TokenId,
        uint128 erc1155TokenAmount
    );

    event ERC1155BuyOrderPreSigned(
        address maker,
        address taker,
        uint256 expiry,
        uint256 nonce,
        IERC20 erc20Token,
        uint256 erc20TokenAmount,
        LibNFTOrder.Fee[] fees,
        address erc1155Token,
        uint256 erc1155TokenId,
        LibNFTOrder.Property[] erc1155TokenProperties,
        uint128 erc1155TokenAmount
    );

    event ERC1155OrderCancelled(address maker, uint256 nonce);
}// Apache-2.0

pragma solidity ^0.8.13;



interface IERC1155OrdersFeature is IERC1155OrdersEvent {


    function sellERC1155(
        LibNFTOrder.ERC1155BuyOrder calldata buyOrder,
        LibSignature.Signature calldata signature,
        uint256 erc1155TokenId,
        uint128 erc1155SellAmount,
        bool unwrapNativeToken,
        bytes calldata callbackData
    )
        external;


    function buyERC1155(
        LibNFTOrder.ERC1155SellOrder calldata sellOrder,
        LibSignature.Signature calldata signature,
        uint128 erc1155BuyAmount
    )
        external
        payable;


    function buyERC1155Ex(
        LibNFTOrder.ERC1155SellOrder calldata sellOrder,
        LibSignature.Signature calldata signature,
        address taker,
        uint128 erc1155BuyAmount,
        bytes calldata callbackData
    )
        external
        payable;


    function cancelERC1155Order(uint256 orderNonce) external;


    function batchCancelERC1155Orders(uint256[] calldata orderNonces) external;


    function batchBuyERC1155s(
        LibNFTOrder.ERC1155SellOrder[] calldata sellOrders,
        LibSignature.Signature[] calldata signatures,
        uint128[] calldata erc1155TokenAmounts,
        bool revertIfIncomplete
    )
        external
        payable
        returns (bool[] memory successes);


    function batchBuyERC1155sEx(
        LibNFTOrder.ERC1155SellOrder[] calldata sellOrders,
        LibSignature.Signature[] calldata signatures,
        address[] calldata takers,
        uint128[] calldata erc1155TokenAmounts,
        bytes[] calldata callbackData,
        bool revertIfIncomplete
    )
        external
        payable
        returns (bool[] memory successes);


    function onERC1155Received(
        address operator,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes calldata data
    )
        external
        returns (bytes4 success);


    function preSignERC1155SellOrder(LibNFTOrder.ERC1155SellOrder calldata order) external;


    function preSignERC1155BuyOrder(LibNFTOrder.ERC1155BuyOrder calldata order) external;


    function validateERC1155SellOrderSignature(
        LibNFTOrder.ERC1155SellOrder calldata order,
        LibSignature.Signature calldata signature
    )
        external
        view;


    function validateERC1155BuyOrderSignature(
        LibNFTOrder.ERC1155BuyOrder calldata order,
        LibSignature.Signature calldata signature
    )
        external
        view;


    function getERC1155SellOrderInfo(LibNFTOrder.ERC1155SellOrder calldata order)
        external
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo);


    function getERC1155BuyOrderInfo(LibNFTOrder.ERC1155BuyOrder calldata order)
        external
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo);


    function getERC1155SellOrderHash(LibNFTOrder.ERC1155SellOrder calldata order)
        external
        view
        returns (bytes32 orderHash);


    function getERC1155BuyOrderHash(LibNFTOrder.ERC1155BuyOrder calldata order)
        external
        view
        returns (bytes32 orderHash);


    function getERC1155OrderNonceStatusBitVector(address maker, uint248 nonceRange)
        external
        view
        returns (uint256);


    function matchERC1155Orders(
        LibNFTOrder.ERC1155SellOrder calldata sellOrder,
        LibNFTOrder.ERC1155BuyOrder calldata buyOrder,
        LibSignature.Signature calldata sellOrderSignature,
        LibSignature.Signature calldata buyOrderSignature
    )
        external
        returns (uint256 profit);


    function batchMatchERC1155Orders(
        LibNFTOrder.ERC1155SellOrder[] calldata sellOrders,
        LibNFTOrder.ERC1155BuyOrder[] calldata buyOrders,
        LibSignature.Signature[] calldata sellOrderSignatures,
        LibSignature.Signature[] calldata buyOrderSignatures
    )
        external
        returns (uint256[] memory profits, bool[] memory successes);

}// Apache-2.0

pragma solidity ^0.8.13;


abstract contract FixinEIP712 {

    bytes32 private constant DOMAIN = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant NAME = keccak256("ElementEx");
    bytes32 private constant VERSION = keccak256("1.0.0");
    uint256 private immutable CHAIN_ID;

    constructor() {
        uint256 chainId;
        assembly { chainId := chainid() }
        CHAIN_ID = chainId;
    }

    function _getEIP712Hash(bytes32 structHash) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(hex"1901", keccak256(abi.encode(DOMAIN, NAME, VERSION, CHAIN_ID, address(this))), structHash));
    }
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// Apache-2.0

pragma solidity ^0.8.13;



abstract contract FixinTokenSpender {

    uint256 constant private ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;

    function _transferERC20TokensFrom(IERC20 token, address owner, address to, uint256 amount) internal {
        uint256 success;
        assembly {
            let ptr := mload(0x40) // free memory pointer

            mstore(ptr, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), and(owner, ADDRESS_MASK))
            mstore(add(ptr, 0x24), and(to, ADDRESS_MASK))
            mstore(add(ptr, 0x44), amount)

            success := call(gas(), and(token, ADDRESS_MASK), 0, ptr, 0x64, ptr, 32)

            let rdsize := returndatasize()

            success := and(
                success,                             // call itself succeeded
                or(
                    iszero(rdsize),                  // no return data, or
                    and(
                        iszero(lt(rdsize, 32)),      // at least 32 bytes
                        eq(mload(ptr), 1)            // starts with uint256(1)
                    )
                )
            )
        }
        require(success != 0, "_transferERC20/TRANSFER_FAILED");
    }

    function _transferERC20Tokens(IERC20 token, address to, uint256 amount) internal {
        uint256 success;
        assembly {
            let ptr := mload(0x40) // free memory pointer

            mstore(ptr, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x04), and(to, ADDRESS_MASK))
            mstore(add(ptr, 0x24), amount)

            success := call(gas(), and(token, ADDRESS_MASK), 0, ptr, 0x44, ptr, 32)

            let rdsize := returndatasize()

            success := and(
                success,                             // call itself succeeded
                or(
                    iszero(rdsize),                  // no return data, or
                    and(
                        iszero(lt(rdsize, 32)),      // at least 32 bytes
                        eq(mload(ptr), 1)            // starts with uint256(1)
                    )
                )
            )
        }
        require(success != 0, "_transferERC20/TRANSFER_FAILED");
    }


    function _transferEth(address payable recipient, uint256 amount) internal {
        if (amount > 0) {
            (bool success,) = recipient.call{value: amount}("");
            require(success, "_transferEth/TRANSFER_FAILED");
        }
    }
}// Apache-2.0

pragma solidity ^0.8.13;



interface IEtherToken is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 amount) external;

}// Apache-2.0

pragma solidity ^0.8.13;


interface IFeeRecipient {


    function receiveZeroExFeeCallback(address tokenAddress, uint256 amount, bytes calldata feeData) external returns (bytes4 success);

}// Apache-2.0

pragma solidity ^0.8.13;


interface ITakerCallback {


    function zeroExTakerCallback(bytes32 orderHash, bytes calldata data) external returns (bytes4);

}// Apache-2.0

pragma solidity ^0.8.13;



abstract contract NFTOrders is FixinEIP712, FixinTokenSpender {

    using LibNFTOrder for LibNFTOrder.NFTBuyOrder;

    address constant internal NATIVE_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    IEtherToken internal immutable WETH;
    address internal immutable _implementation;

    bytes4 private constant FEE_CALLBACK_MAGIC_BYTES = IFeeRecipient.receiveZeroExFeeCallback.selector;
    bytes4 private constant TAKER_CALLBACK_MAGIC_BYTES = ITakerCallback.zeroExTakerCallback.selector;

    constructor(IEtherToken weth) {
        require(address(weth) != address(0), "WETH_ADDRESS_ERROR");
        WETH = weth;
        _implementation = address(this);
    }

    struct SellParams {
        uint128 sellAmount;
        uint256 tokenId;
        bool unwrapNativeToken;
        address taker;
        address currentNftOwner;
        bytes takerCallbackData;
    }

    struct BuyParams {
        uint128 buyAmount;
        uint256 ethAvailable;
        address taker;
        bytes takerCallbackData;
    }

    function _sellNFT(
        LibNFTOrder.NFTBuyOrder memory buyOrder,
        LibSignature.Signature memory signature,
        SellParams memory params
    ) internal returns (uint256 erc20FillAmount, bytes32 orderHash) {
        LibNFTOrder.OrderInfo memory orderInfo = _getOrderInfo(buyOrder);
        orderHash = orderInfo.orderHash;

        _validateBuyOrder(buyOrder, signature, orderInfo, params.taker, params.tokenId);

        if (params.sellAmount > orderInfo.remainingAmount) {
            revert("_sellNFT/EXCEEDS_REMAINING_AMOUNT");
        }

        _updateOrderState(buyOrder.asNFTSellOrder(), orderInfo.orderHash, params.sellAmount);

        erc20FillAmount = (params.sellAmount == orderInfo.orderAmount) ?
            buyOrder.erc20TokenAmount : buyOrder.erc20TokenAmount * params.sellAmount / orderInfo.orderAmount;

        if (params.unwrapNativeToken) {
            require(buyOrder.erc20Token == WETH, "_sellNFT/ERC20_TOKEN_MISMATCH_ERROR");

            _transferERC20TokensFrom(WETH, buyOrder.maker, address(this), erc20FillAmount);

            WETH.withdraw(erc20FillAmount);

            _transferEth(payable(params.taker), erc20FillAmount);
        } else {
            _transferERC20TokensFrom(buyOrder.erc20Token, buyOrder.maker, params.taker, erc20FillAmount);
        }

        if (params.takerCallbackData.length > 0) {
            require(params.taker != address(this), "_sellNFT/CANNOT_CALLBACK_SELF");

            bytes4 callbackResult = ITakerCallback(params.taker).zeroExTakerCallback(orderInfo.orderHash, params.takerCallbackData);

            require(callbackResult == TAKER_CALLBACK_MAGIC_BYTES, "_sellNFT/CALLBACK_FAILED");
        }

        _transferNFTAssetFrom(buyOrder.nft, params.currentNftOwner, buyOrder.maker, params.tokenId, params.sellAmount);

        _payFees(buyOrder.asNFTSellOrder(), buyOrder.maker, params.sellAmount, orderInfo.orderAmount, false);
    }

    function _buyNFT(
        LibNFTOrder.NFTSellOrder memory sellOrder,
        LibSignature.Signature memory signature,
        uint128 buyAmount
    ) internal returns (uint256 erc20FillAmount, bytes32 orderHash) {
        LibNFTOrder.OrderInfo memory orderInfo = _getOrderInfo(sellOrder);
        orderHash = orderInfo.orderHash;

        _validateSellOrder(sellOrder, signature, orderInfo, msg.sender);

        if (buyAmount > orderInfo.remainingAmount) {
            revert("_buyNFT/EXCEEDS_REMAINING_AMOUNT");
        }

        _updateOrderState(sellOrder, orderInfo.orderHash, buyAmount);

        erc20FillAmount = (buyAmount == orderInfo.orderAmount) ?
            sellOrder.erc20TokenAmount : _ceilDiv(sellOrder.erc20TokenAmount * buyAmount, orderInfo.orderAmount);

        _transferNFTAssetFrom(sellOrder.nft, sellOrder.maker, msg.sender, sellOrder.nftId, buyAmount);

        if (address(sellOrder.erc20Token) == NATIVE_TOKEN_ADDRESS) {
            _transferEth(payable(sellOrder.maker), erc20FillAmount);

            _payFees(sellOrder, address(this), buyAmount, orderInfo.orderAmount, true);
        } else {
            _transferERC20TokensFrom(sellOrder.erc20Token, msg.sender, sellOrder.maker, erc20FillAmount);

            _payFees(sellOrder, msg.sender, buyAmount, orderInfo.orderAmount, false);
        }
    }

    function _buyNFTEx(
        LibNFTOrder.NFTSellOrder memory sellOrder,
        LibSignature.Signature memory signature,
        BuyParams memory params
    ) internal returns (uint256 erc20FillAmount, bytes32 orderHash) {
        LibNFTOrder.OrderInfo memory orderInfo = _getOrderInfo(sellOrder);
        orderHash = orderInfo.orderHash;

        _validateSellOrder(sellOrder, signature, orderInfo, params.taker);

        if (params.buyAmount > orderInfo.remainingAmount) {
            revert("_buyNFTEx/EXCEEDS_REMAINING_AMOUNT");
        }

        _updateOrderState(sellOrder, orderInfo.orderHash, params.buyAmount);

        if (sellOrder.expiry >> 252 == 1) {
            uint256 count = (sellOrder.expiry >> 64) & 0xffffffff;
            if (count > 0) {
                _resetDutchAuctionTokenAmountAndFees(sellOrder, count);
            }
        }

        erc20FillAmount = (params.buyAmount == orderInfo.orderAmount) ?
            sellOrder.erc20TokenAmount : _ceilDiv(sellOrder.erc20TokenAmount * params.buyAmount, orderInfo.orderAmount);

        _transferNFTAssetFrom(sellOrder.nft, sellOrder.maker, params.taker, sellOrder.nftId, params.buyAmount);

        uint256 ethAvailable = params.ethAvailable;
        if (params.takerCallbackData.length > 0) {
            require(params.taker != address(this), "_buyNFTEx/CANNOT_CALLBACK_SELF");

            uint256 ethBalanceBeforeCallback = address(this).balance;

            bytes4 callbackResult = ITakerCallback(params.taker).zeroExTakerCallback(orderInfo.orderHash, params.takerCallbackData);

            ethAvailable += address(this).balance - ethBalanceBeforeCallback;

            require(callbackResult == TAKER_CALLBACK_MAGIC_BYTES, "_buyNFTEx/CALLBACK_FAILED");
        }

        if (address(sellOrder.erc20Token) == NATIVE_TOKEN_ADDRESS) {
            uint256 totalPaid = erc20FillAmount + _calcTotalFeesPaid(sellOrder.fees, params.buyAmount, orderInfo.orderAmount);
            if (ethAvailable < totalPaid) {
                uint256 withDrawAmount = totalPaid - ethAvailable;
                _transferERC20TokensFrom(WETH, msg.sender, address(this), withDrawAmount);

                WETH.withdraw(withDrawAmount);
            }

            _transferEth(payable(sellOrder.maker), erc20FillAmount);

            _payFees(sellOrder, address(this), params.buyAmount, orderInfo.orderAmount, true);
        } else if (sellOrder.erc20Token == WETH) {
            uint256 totalFeesPaid = _calcTotalFeesPaid(sellOrder.fees, params.buyAmount, orderInfo.orderAmount);
            if (ethAvailable > totalFeesPaid) {
                uint256 depositAmount = ethAvailable - totalFeesPaid;
                if (depositAmount < erc20FillAmount) {
                    _transferERC20TokensFrom(WETH, msg.sender, address(this), (erc20FillAmount - depositAmount));
                } else {
                    depositAmount = erc20FillAmount;
                }

                WETH.deposit{value: depositAmount}();

                _transferERC20Tokens(WETH, sellOrder.maker, erc20FillAmount);

                _payFees(sellOrder, address(this), params.buyAmount, orderInfo.orderAmount, true);
            } else {
                _transferERC20TokensFrom(WETH, msg.sender, sellOrder.maker, erc20FillAmount);

                if (ethAvailable > 0) {
                    if (ethAvailable < totalFeesPaid) {
                        uint256 value = totalFeesPaid - ethAvailable;
                        _transferERC20TokensFrom(WETH, msg.sender, address(this), value);

                        WETH.withdraw(value);
                    }

                    _payFees(sellOrder, address(this), params.buyAmount, orderInfo.orderAmount, true);
                } else {
                    _payFees(sellOrder, msg.sender, params.buyAmount, orderInfo.orderAmount, false);
                }
            }
        } else {
            _transferERC20TokensFrom(sellOrder.erc20Token, msg.sender, sellOrder.maker, erc20FillAmount);

            _payFees(sellOrder, msg.sender, params.buyAmount, orderInfo.orderAmount, false);
        }
    }

    function _validateSellOrder(
        LibNFTOrder.NFTSellOrder memory sellOrder,
        LibSignature.Signature memory signature,
        LibNFTOrder.OrderInfo memory orderInfo,
        address taker
    ) internal view {
        require(sellOrder.taker == address(0) || sellOrder.taker == taker, "_validateOrder/ONLY_TAKER");

        require(orderInfo.status == LibNFTOrder.OrderStatus.FILLABLE, "_validateOrder/ORDER_NOT_FILL");

        _validateOrderSignature(orderInfo.orderHash, signature, sellOrder.maker);
    }

    function _validateBuyOrder(
        LibNFTOrder.NFTBuyOrder memory buyOrder,
        LibSignature.Signature memory signature,
        LibNFTOrder.OrderInfo memory orderInfo,
        address taker,
        uint256 tokenId
    ) internal view {
        require(address(buyOrder.erc20Token) != NATIVE_TOKEN_ADDRESS, "_validateBuyOrder/TOKEN_MISMATCH");

        require(buyOrder.taker == address(0) || buyOrder.taker == taker, "_validateBuyOrder/ONLY_TAKER");

        require(orderInfo.status == LibNFTOrder.OrderStatus.FILLABLE, "_validateOrder/ORDER_NOT_FILL");

        _validateOrderProperties(buyOrder, tokenId);

        _validateOrderSignature(orderInfo.orderHash, signature, buyOrder.maker);
    }

    function _resetDutchAuctionTokenAmountAndFees(LibNFTOrder.NFTSellOrder memory order, uint256 count) internal view {
        require(count <= 100000000, "COUNT_OUT_OF_SIDE");

        uint256 listingTime = (order.expiry >> 32) & 0xffffffff;
        uint256 denominator = ((order.expiry & 0xffffffff) - listingTime) * 100000000;
        uint256 multiplier = (block.timestamp - listingTime) * count;

        uint256 amount = order.erc20TokenAmount;
        order.erc20TokenAmount = amount - amount * multiplier / denominator;

        for (uint256 i = 0; i < order.fees.length; i++) {
            amount = order.fees[i].amount;
            order.fees[i].amount = amount - amount * multiplier / denominator;
        }
    }

    function _resetEnglishAuctionTokenAmountAndFees(
        LibNFTOrder.NFTSellOrder memory sellOrder,
        uint256 buyERC20Amount,
        uint256 fillAmount,
        uint256 orderAmount
    ) internal pure {
        uint256 sellOrderFees = _calcTotalFeesPaid(sellOrder.fees, fillAmount, orderAmount);
        uint256 sellTotalAmount = sellOrderFees + sellOrder.erc20TokenAmount;
        if (buyERC20Amount != sellTotalAmount) {
            uint256 spread = buyERC20Amount - sellTotalAmount;
            uint256 sum;

            if (sellTotalAmount > 0) {
                for (uint256 i = 0; i < sellOrder.fees.length; i++) {
                    uint256 diff = spread * sellOrder.fees[i].amount / sellTotalAmount;
                    sellOrder.fees[i].amount += diff;
                    sum += diff;
                }
            }

            sellOrder.erc20TokenAmount += spread - sum;
        }
    }

    function _ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a + b - 1) / b;
    }

    function _calcTotalFeesPaid(LibNFTOrder.Fee[] memory fees, uint256 fillAmount, uint256 orderAmount) private pure returns (uint256 totalFeesPaid) {
        if (fillAmount == orderAmount) {
            for (uint256 i = 0; i < fees.length; i++) {
                totalFeesPaid += fees[i].amount;
            }
        } else {
            for (uint256 i = 0; i < fees.length; i++) {
                totalFeesPaid += fees[i].amount * fillAmount / orderAmount;
            }
        }
        return totalFeesPaid;
    }

    function _payFees(
        LibNFTOrder.NFTSellOrder memory order,
        address payer,
        uint128 fillAmount,
        uint128 orderAmount,
        bool useNativeToken
    ) internal returns (uint256 totalFeesPaid) {
        for (uint256 i = 0; i < order.fees.length; i++) {
            LibNFTOrder.Fee memory fee = order.fees[i];

            uint256 feeFillAmount = (fillAmount == orderAmount) ? fee.amount : fee.amount * fillAmount / orderAmount;

            if (useNativeToken) {
                _transferEth(payable(fee.recipient), feeFillAmount);
            } else {
                if (feeFillAmount > 0) {
                    _transferERC20TokensFrom(order.erc20Token, payer, fee.recipient, feeFillAmount);
                }
            }

            if (fee.feeData.length > 0) {
                bytes4 callbackResult = IFeeRecipient(fee.recipient).receiveZeroExFeeCallback(
                    useNativeToken ? NATIVE_TOKEN_ADDRESS : address(order.erc20Token),
                    feeFillAmount,
                    fee.feeData
                );

                require(callbackResult == FEE_CALLBACK_MAGIC_BYTES, "_payFees/CALLBACK_FAILED");
            }

            totalFeesPaid += feeFillAmount;
        }
        return totalFeesPaid;
    }

    function _validateOrderProperties(LibNFTOrder.NFTBuyOrder memory order, uint256 tokenId) internal view {
        if (order.nftProperties.length == 0) {
            require(tokenId == order.nftId, "_validateProperties/TOKEN_ID_ERR");
        } else {
            for (uint256 i = 0; i < order.nftProperties.length; i++) {
                LibNFTOrder.Property memory property = order.nftProperties[i];
                if (address(property.propertyValidator) != address(0)) {
                    try property.propertyValidator.validateProperty(order.nft, tokenId, property.propertyData) {
                    } catch (bytes memory /* reason */) {
                        revert("PROPERTY_VALIDATION_FAILED");
                    }
                }
            }
        }
    }

    function _validateOrderSignature(bytes32 orderHash, LibSignature.Signature memory signature, address maker) internal virtual view;

    function _transferNFTAssetFrom(address token, address from, address to, uint256 tokenId, uint256 amount) internal virtual;

    function _updateOrderState(LibNFTOrder.NFTSellOrder memory order, bytes32 orderHash, uint128 fillAmount) internal virtual;

    function _getOrderInfo(LibNFTOrder.NFTSellOrder memory nftSellOrder) internal virtual view returns (LibNFTOrder.OrderInfo memory);

    function _getOrderInfo(LibNFTOrder.NFTBuyOrder memory nftBuyOrder) internal virtual view returns (LibNFTOrder.OrderInfo memory);
}// Apache-2.0

pragma solidity ^0.8.13;



contract ERC1155OrdersFeature is
    IERC1155OrdersFeature,
    FixinERC1155Spender,
    NFTOrders
{

    using LibNFTOrder for LibNFTOrder.ERC1155SellOrder;
    using LibNFTOrder for LibNFTOrder.ERC1155BuyOrder;
    using LibNFTOrder for LibNFTOrder.NFTSellOrder;
    using LibNFTOrder for LibNFTOrder.NFTBuyOrder;

    bytes4 private constant ERC1155_RECEIVED_MAGIC_BYTES = this.onERC1155Received.selector;

    constructor(IEtherToken weth) NFTOrders(weth) {
    }

    function sellERC1155(
        LibNFTOrder.ERC1155BuyOrder memory buyOrder,
        LibSignature.Signature memory signature,
        uint256 erc1155TokenId,
        uint128 erc1155SellAmount,
        bool unwrapNativeToken,
        bytes memory callbackData
    ) public override {

        _sellERC1155(
            buyOrder,
            signature,
            SellParams(
                erc1155SellAmount,
                erc1155TokenId,
                unwrapNativeToken,
                msg.sender, // taker
                msg.sender, // owner
                callbackData
            )
        );
    }

    function buyERC1155(
        LibNFTOrder.ERC1155SellOrder memory sellOrder,
        LibSignature.Signature memory signature,
        uint128 erc1155BuyAmount
    ) public override payable {

        uint256 ethBalanceBefore = address(this).balance - msg.value;

        _buyERC1155(sellOrder, signature, erc1155BuyAmount);

        if (address(this).balance != ethBalanceBefore) {
            _transferEth(payable(msg.sender), address(this).balance - ethBalanceBefore);
        }
    }

    function buyERC1155Ex(
        LibNFTOrder.ERC1155SellOrder memory sellOrder,
        LibSignature.Signature memory signature,
        address taker,
        uint128 erc1155BuyAmount,
        bytes memory callbackData
    ) public override payable {

        uint256 ethBalanceBefore = address(this).balance - msg.value;

        _buyERC1155Ex(
            sellOrder,
            signature,
            BuyParams(
                erc1155BuyAmount,
                msg.value,
                taker,
                callbackData
            )
        );

        if (address(this).balance != ethBalanceBefore) {
            _transferEth(payable(msg.sender), address(this).balance - ethBalanceBefore);
        }
    }

    function cancelERC1155Order(uint256 orderNonce) public override {

        uint256 flag = 1 << (orderNonce & 255);
        LibERC1155OrdersStorage.getStorage().orderCancellationByMaker
            [msg.sender][uint248(orderNonce >> 8)] |= flag;

        emit ERC1155OrderCancelled(msg.sender, orderNonce);
    }

    function batchCancelERC1155Orders(uint256[] calldata orderNonces) external override {

        for (uint256 i = 0; i < orderNonces.length; i++) {
            cancelERC1155Order(orderNonces[i]);
        }
    }

    function batchBuyERC1155s(
        LibNFTOrder.ERC1155SellOrder[] memory sellOrders,
        LibSignature.Signature[] memory signatures,
        uint128[] calldata erc1155FillAmounts,
        bool revertIfIncomplete
    )
        public
        override
        payable
        returns (bool[] memory successes)
    {

        uint256 length = sellOrders.length;
        require(
            length == signatures.length &&
            length == erc1155FillAmounts.length,
            "ERC1155OrdersFeature::batchBuyERC1155s/ARRAY_LENGTH_MISMATCH"
        );
        successes = new bool[](length);

        uint256 ethBalanceBefore = address(this).balance - msg.value;
        if (revertIfIncomplete) {
            for (uint256 i = 0; i < length; i++) {
                _buyERC1155(sellOrders[i], signatures[i], erc1155FillAmounts[i]);
                successes[i] = true;
            }
        } else {
            for (uint256 i = 0; i < length; i++) {
                (successes[i], ) = _implementation.delegatecall(
                    abi.encodeWithSelector(
                        this.buyERC1155FromProxy.selector,
                        sellOrders[i],
                        signatures[i],
                        erc1155FillAmounts[i]
                    )
                );
            }
        }

       _transferEth(payable(msg.sender), address(this).balance - ethBalanceBefore);
    }

    function batchBuyERC1155sEx(
        LibNFTOrder.ERC1155SellOrder[] memory sellOrders,
        LibSignature.Signature[] memory signatures,
        address[] calldata takers,
        uint128[] calldata erc1155FillAmounts,
        bytes[] memory callbackData,
        bool revertIfIncomplete
    )
        public
        override
        payable
        returns (bool[] memory successes)
    {

        uint256 length = sellOrders.length;
        require(
            length == signatures.length &&
            length == takers.length &&
            length == erc1155FillAmounts.length &&
            length == callbackData.length,
            "ARRAY_LENGTH_MISMATCH"
        );
        successes = new bool[](length);

        uint256 ethBalanceBefore = address(this).balance - msg.value;
        if (revertIfIncomplete) {
            for (uint256 i = 0; i < length; i++) {
                _buyERC1155Ex(
                    sellOrders[i],
                    signatures[i],
                    BuyParams(
                        erc1155FillAmounts[i],
                        address(this).balance - ethBalanceBefore, // Remaining ETH available
                        takers[i],
                        callbackData[i]
                    )
                );
                successes[i] = true;
            }
        } else {
            for (uint256 i = 0; i < length; i++) {
                (successes[i], ) = _implementation.delegatecall(
                    abi.encodeWithSelector(
                        this.buyERC1155ExFromProxy.selector,
                        sellOrders[i],
                        signatures[i],
                        BuyParams(
                            erc1155FillAmounts[i],
                            address(this).balance - ethBalanceBefore, // Remaining ETH available
                            takers[i],
                            callbackData[i]
                        )
                    )
                );
            }
        }

       _transferEth(payable(msg.sender), address(this).balance - ethBalanceBefore);
    }

    function buyERC1155FromProxy(
        LibNFTOrder.ERC1155SellOrder memory sellOrder,
        LibSignature.Signature memory signature,
        uint128 buyAmount
    )
        external
        payable
    {

        require(_implementation != address(this), "MUST_CALL_FROM_PROXY");
        _buyERC1155(sellOrder, signature, buyAmount);
    }

    function buyERC1155ExFromProxy(
        LibNFTOrder.ERC1155SellOrder memory sellOrder,
        LibSignature.Signature memory signature,
        BuyParams memory params
    )
        external
        payable
    {

        require(_implementation != address(this), "MUST_CALL_FROM_PROXY");
        _buyERC1155Ex(sellOrder, signature, params);
    }

    function onERC1155Received(
        address operator,
        address /* from */,
        uint256 tokenId,
        uint256 value,
        bytes calldata data
    )
        external
        override
        returns (bytes4 success)
    {

        (
            LibNFTOrder.ERC1155BuyOrder memory buyOrder,
            LibSignature.Signature memory signature,
            bool unwrapNativeToken
        ) = abi.decode(
            data,
            (LibNFTOrder.ERC1155BuyOrder, LibSignature.Signature, bool)
        );

        if (msg.sender != buyOrder.erc1155Token) {
            revert("ERC1155_TOKEN_MISMATCH");
        }
        require(value <= type(uint128).max);

        _sellERC1155(
            buyOrder,
            signature,
            SellParams(
                uint128(value),
                tokenId,
                unwrapNativeToken,
                operator,       // taker
                address(this),  // owner (we hold the NFT currently)
                new bytes(0)    // No taker callback
            )
        );

        return ERC1155_RECEIVED_MAGIC_BYTES;
    }

    function preSignERC1155SellOrder(LibNFTOrder.ERC1155SellOrder memory order) public override {

        require(order.maker == msg.sender, "ONLY_MAKER");

        uint256 hashNonce = LibCommonNftOrdersStorage.getStorage().hashNonces[order.maker];
        require(hashNonce < type(uint128).max);

        bytes32 orderHash = getERC1155SellOrderHash(order);
        LibERC1155OrdersStorage.getStorage().orderState[orderHash].preSigned = uint128(hashNonce + 1);

        emit ERC1155SellOrderPreSigned(
            order.maker,
            order.taker,
            order.expiry,
            order.nonce,
            order.erc20Token,
            order.erc20TokenAmount,
            order.fees,
            order.erc1155Token,
            order.erc1155TokenId,
            order.erc1155TokenAmount
        );
    }

    function preSignERC1155BuyOrder(LibNFTOrder.ERC1155BuyOrder memory order) public override {

        require(order.maker == msg.sender, "ONLY_MAKER");

        uint256 hashNonce = LibCommonNftOrdersStorage.getStorage().hashNonces[order.maker];
        require(hashNonce < type(uint128).max, "HASH_NONCE_OUTSIDE");

        bytes32 orderHash = getERC1155BuyOrderHash(order);
        LibERC1155OrdersStorage.getStorage().orderState[orderHash].preSigned = uint128(hashNonce + 1);

        emit ERC1155BuyOrderPreSigned(
            order.maker,
            order.taker,
            order.expiry,
            order.nonce,
            order.erc20Token,
            order.erc20TokenAmount,
            order.fees,
            order.erc1155Token,
            order.erc1155TokenId,
            order.erc1155TokenProperties,
            order.erc1155TokenAmount
        );
    }

    function _sellERC1155(
        LibNFTOrder.ERC1155BuyOrder memory buyOrder,
        LibSignature.Signature memory signature,
        SellParams memory params
    ) private {

        (uint256 erc20FillAmount, bytes32 orderHash) = _sellNFT(
            buyOrder.asNFTBuyOrder(),
            signature,
            params
        );

        emit ERC1155BuyOrderFilled(
            buyOrder.maker,
            params.taker,
            buyOrder.erc20Token,
            erc20FillAmount,
            buyOrder.erc1155Token,
            params.tokenId,
            params.sellAmount,
            orderHash
        );
    }

    function _buyERC1155(
        LibNFTOrder.ERC1155SellOrder memory sellOrder,
        LibSignature.Signature memory signature,
        uint128 buyAmount
    ) internal {

        (uint256 erc20FillAmount, bytes32 orderHash) = _buyNFT(
            sellOrder.asNFTSellOrder(),
            signature,
            buyAmount
        );

        emit ERC1155SellOrderFilled(
            sellOrder.maker,
            msg.sender,
            sellOrder.erc20Token,
            erc20FillAmount,
            sellOrder.erc1155Token,
            sellOrder.erc1155TokenId,
            buyAmount,
            orderHash
        );
    }

    function _buyERC1155Ex(
        LibNFTOrder.ERC1155SellOrder memory sellOrder,
        LibSignature.Signature memory signature,
        BuyParams memory params
    ) internal {

        if (params.taker == address(0)) {
            params.taker = msg.sender;
        } else {
            require(params.taker != address(this), "_buy1155Ex/TAKER_CANNOT_SELF");
        }
        (uint256 erc20FillAmount, bytes32 orderHash) = _buyNFTEx(
            sellOrder.asNFTSellOrder(),
            signature,
            params
        );

        emit ERC1155SellOrderFilled(
            sellOrder.maker,
            params.taker,
            sellOrder.erc20Token,
            erc20FillAmount,
            sellOrder.erc1155Token,
            sellOrder.erc1155TokenId,
            params.buyAmount,
            orderHash
        );
    }

    function validateERC1155SellOrderSignature(
        LibNFTOrder.ERC1155SellOrder memory order,
        LibSignature.Signature memory signature
    ) public override view {

        bytes32 orderHash = getERC1155SellOrderHash(order);
        _validateOrderSignature(orderHash, signature, order.maker);
    }

    function validateERC1155BuyOrderSignature(
        LibNFTOrder.ERC1155BuyOrder memory order,
        LibSignature.Signature memory signature
    ) public override view {

        bytes32 orderHash = getERC1155BuyOrderHash(order);
        _validateOrderSignature(orderHash, signature, order.maker);
    }

    function _validateOrderSignature(
        bytes32 orderHash,
        LibSignature.Signature memory signature,
        address maker
    ) internal override view {

        if (signature.signatureType == LibSignature.SignatureType.PRESIGNED) {
            require(
                LibERC1155OrdersStorage.getStorage().orderState[orderHash].preSigned ==
                LibCommonNftOrdersStorage.getStorage().hashNonces[maker] + 1,
                "PRESIGNED_INVALID_SIGNER"
            );
        } else {
            require(
                maker != address(0) &&
                maker == ecrecover(orderHash, signature.v, signature.r, signature.s),
                "INVALID_SIGNER_ERROR"
            );
        }
    }

    function _transferNFTAssetFrom(
        address token,
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    ) internal override {

        _transferERC1155AssetFrom(token, from, to, tokenId, amount);
    }

    function _updateOrderState(
        LibNFTOrder.NFTSellOrder memory /* order */,
        bytes32 orderHash,
        uint128 fillAmount
    ) internal override {

        LibERC1155OrdersStorage.Storage storage stor = LibERC1155OrdersStorage.getStorage();
        uint128 filledAmount = stor.orderState[orderHash].filledAmount;
        require(filledAmount + fillAmount > filledAmount);
        stor.orderState[orderHash].filledAmount = filledAmount + fillAmount;
    }

    function getERC1155SellOrderInfo(LibNFTOrder.ERC1155SellOrder memory order)
        public
        override
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo)
    {

        orderInfo.orderAmount = order.erc1155TokenAmount;
        orderInfo.orderHash = getERC1155SellOrderHash(order);

        if (order.expiry & 0xffffffff00000000 > 0) {
            if ((order.expiry >> 32) & 0xffffffff > block.timestamp) {
                orderInfo.status = LibNFTOrder.OrderStatus.INVALID;
                return orderInfo;
            }
        }

        if (order.expiry & 0xffffffff <= block.timestamp) {
            orderInfo.status = LibNFTOrder.OrderStatus.EXPIRED;
            return orderInfo;
        }

        {
            LibERC1155OrdersStorage.Storage storage stor =
                LibERC1155OrdersStorage.getStorage();

            LibERC1155OrdersStorage.OrderState storage orderState =
                stor.orderState[orderInfo.orderHash];
            orderInfo.remainingAmount = order.erc1155TokenAmount - orderState.filledAmount;

            uint256 orderCancellationBitVector =
                stor.orderCancellationByMaker[order.maker][uint248(order.nonce >> 8)];
            uint256 flag = 1 << (order.nonce & 255);

            if (orderInfo.remainingAmount == 0 ||
                orderCancellationBitVector & flag != 0)
            {
                orderInfo.status = LibNFTOrder.OrderStatus.UNFILLABLE;
                return orderInfo;
            }
        }

        orderInfo.status = LibNFTOrder.OrderStatus.FILLABLE;
        return orderInfo;
    }

    function getERC1155BuyOrderInfo(LibNFTOrder.ERC1155BuyOrder memory order)
        public
        override
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo)
    {

        orderInfo.orderAmount = order.erc1155TokenAmount;
        orderInfo.orderHash = getERC1155BuyOrderHash(order);

        if (order.erc1155TokenId != 0 && order.erc1155TokenProperties.length > 0) {
            orderInfo.status = LibNFTOrder.OrderStatus.INVALID;
            return orderInfo;
        }

        if (address(order.erc20Token) == NATIVE_TOKEN_ADDRESS) {
            orderInfo.status = LibNFTOrder.OrderStatus.INVALID;
            return orderInfo;
        }

        if (order.expiry & 0xffffffff00000000 > 0) {
            if ((order.expiry >> 32) & 0xffffffff > block.timestamp) {
                orderInfo.status = LibNFTOrder.OrderStatus.INVALID;
                return orderInfo;
            }
        }

        if (order.expiry & 0xffffffff <= block.timestamp) {
            orderInfo.status = LibNFTOrder.OrderStatus.EXPIRED;
            return orderInfo;
        }

        {
            LibERC1155OrdersStorage.Storage storage stor =
                LibERC1155OrdersStorage.getStorage();

            LibERC1155OrdersStorage.OrderState storage orderState =
                stor.orderState[orderInfo.orderHash];
            orderInfo.remainingAmount = order.erc1155TokenAmount - orderState.filledAmount;

            uint256 orderCancellationBitVector =
                stor.orderCancellationByMaker[order.maker][uint248(order.nonce >> 8)];
            uint256 flag = 1 << (order.nonce & 255);

            if (orderInfo.remainingAmount == 0 ||
                orderCancellationBitVector & flag != 0)
            {
                orderInfo.status = LibNFTOrder.OrderStatus.UNFILLABLE;
                return orderInfo;
            }
        }

        orderInfo.status = LibNFTOrder.OrderStatus.FILLABLE;
        return orderInfo;
    }

    function getERC1155SellOrderHash(LibNFTOrder.ERC1155SellOrder memory order)
        public
        override
        view
        returns (bytes32 orderHash)
    {

        return _getEIP712Hash(
            LibNFTOrder.getERC1155SellOrderStructHash(
                order, LibCommonNftOrdersStorage.getStorage().hashNonces[order.maker]
            )
        );
    }

    function getERC1155BuyOrderHash(LibNFTOrder.ERC1155BuyOrder memory order)
        public
        override
        view
        returns (bytes32 orderHash)
    {

        return _getEIP712Hash(
            LibNFTOrder.getERC1155BuyOrderStructHash(
                order, LibCommonNftOrdersStorage.getStorage().hashNonces[order.maker]
            )
        );
    }

    function getERC1155OrderNonceStatusBitVector(address maker, uint248 nonceRange)
        external
        override
        view
        returns (uint256)
    {

        return LibERC1155OrdersStorage.getStorage().orderCancellationByMaker[maker][nonceRange];
    }

    function _getOrderInfo(LibNFTOrder.NFTSellOrder memory nftSellOrder)
        internal
        override
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo)
    {

        return getERC1155SellOrderInfo(nftSellOrder.asERC1155SellOrder());
    }

    function _getOrderInfo(LibNFTOrder.NFTBuyOrder memory nftBuyOrder)
        internal
        override
        view
        returns (LibNFTOrder.OrderInfo memory orderInfo)
    {

        return getERC1155BuyOrderInfo(nftBuyOrder.asERC1155BuyOrder());
    }

    function matchERC1155Orders(
        LibNFTOrder.ERC1155SellOrder memory sellOrder,
        LibNFTOrder.ERC1155BuyOrder memory buyOrder,
        LibSignature.Signature memory sellOrderSignature,
        LibSignature.Signature memory buyOrderSignature
    )
        public
        override
        returns (uint256 profit)
    {

        if (sellOrder.erc1155Token != buyOrder.erc1155Token) {
            revert("ERC1155_TOKEN_MISMATCH_ERROR");
        }

        LibNFTOrder.NFTSellOrder memory sellNFTOrder = sellOrder.asNFTSellOrder();
        LibNFTOrder.NFTBuyOrder memory buyNFTOrder = buyOrder.asNFTBuyOrder();
        LibNFTOrder.OrderInfo memory sellOrderInfo = getERC1155SellOrderInfo(sellOrder);
        LibNFTOrder.OrderInfo memory buyOrderInfo = getERC1155BuyOrderInfo(buyOrder);

        bool isEnglishAuction = (sellOrder.expiry >> 252 == 2);
        if (isEnglishAuction) {
            require(
                sellOrderInfo.orderAmount == sellOrderInfo.remainingAmount &&
                sellOrderInfo.orderAmount == buyOrderInfo.orderAmount &&
                sellOrderInfo.orderAmount == buyOrderInfo.remainingAmount,
                "UNMATCH_ORDER_AMOUNT"
            );
        }

        _validateSellOrder(
            sellNFTOrder,
            sellOrderSignature,
            sellOrderInfo,
            buyOrder.maker
        );
        _validateBuyOrder(
            buyNFTOrder,
            buyOrderSignature,
            buyOrderInfo,
            sellOrder.maker,
            sellOrder.erc1155TokenId
        );

        uint128 erc1155FillAmount = sellOrderInfo.remainingAmount < buyOrderInfo.remainingAmount ?
            sellOrderInfo.remainingAmount :
            buyOrderInfo.remainingAmount;
        if (erc1155FillAmount != sellOrderInfo.orderAmount) {
            sellOrder.erc20TokenAmount = _ceilDiv(
                sellOrder.erc20TokenAmount * erc1155FillAmount,
                sellOrderInfo.orderAmount
            );
        }
        if (erc1155FillAmount != buyOrderInfo.orderAmount) {
            buyOrder.erc20TokenAmount =
                buyOrder.erc20TokenAmount * erc1155FillAmount / buyOrderInfo.orderAmount;
        }
        if (isEnglishAuction) {
            _resetEnglishAuctionTokenAmountAndFees(
                sellNFTOrder,
                buyOrder.erc20TokenAmount,
                erc1155FillAmount,
                sellOrderInfo.orderAmount
            );
        }

        _updateOrderState(sellNFTOrder, sellOrderInfo.orderHash, erc1155FillAmount);
        _updateOrderState(buyNFTOrder.asNFTSellOrder(), buyOrderInfo.orderHash, erc1155FillAmount);

        uint256 spread = buyOrder.erc20TokenAmount - sellOrder.erc20TokenAmount;

        _transferERC1155AssetFrom(
            sellOrder.erc1155Token,
            sellOrder.maker,
            buyOrder.maker,
            sellOrder.erc1155TokenId,
            erc1155FillAmount
        );

        if (
            address(sellOrder.erc20Token) == NATIVE_TOKEN_ADDRESS &&
            buyOrder.erc20Token == WETH
        ) {

            _transferERC20TokensFrom(
                WETH,
                buyOrder.maker,
                address(this),
                buyOrder.erc20TokenAmount
            );
            WETH.withdraw(buyOrder.erc20TokenAmount);

            _transferEth(payable(sellOrder.maker), sellOrder.erc20TokenAmount);

            _payFees(
                buyNFTOrder.asNFTSellOrder(),
                buyOrder.maker, // payer
                erc1155FillAmount,
                buyOrderInfo.orderAmount,
                false           // useNativeToken
            );

            uint256 sellOrderFees = _payFees(
                sellNFTOrder,
                address(this), // payer
                erc1155FillAmount,
                sellOrderInfo.orderAmount,
                true           // useNativeToken
            );

            profit = spread - sellOrderFees;
            if (profit > 0) {
               _transferEth(payable(msg.sender), profit);
            }
        } else {
            if (sellOrder.erc20Token != buyOrder.erc20Token) {
                revert("ERC20_TOKEN_MISMATCH");
            }

            _transferERC20TokensFrom(
                buyOrder.erc20Token,
                buyOrder.maker,
                sellOrder.maker,
                sellOrder.erc20TokenAmount
            );

            _payFees(
                buyNFTOrder.asNFTSellOrder(),
                buyOrder.maker, // payer
                erc1155FillAmount,
                buyOrderInfo.orderAmount,
                false           // useNativeToken
            );

            uint256 sellOrderFees = _payFees(
                sellNFTOrder,
                buyOrder.maker, // payer
                erc1155FillAmount,
                sellOrderInfo.orderAmount,
                false           // useNativeToken
            );

            profit = spread - sellOrderFees;
            if (profit > 0) {
                _transferERC20TokensFrom(
                    buyOrder.erc20Token,
                    buyOrder.maker,
                    msg.sender,
                    profit
                );
            }
        }

        _emitEventSellOrderFilled(
            sellOrder,
            buyOrder.maker, // taker
            erc1155FillAmount,
            sellOrderInfo.orderHash
        );

        _emitEventBuyOrderFilled(
            buyOrder,
            sellOrder.maker, // taker
            sellOrder.erc1155TokenId,
            erc1155FillAmount,
            buyOrderInfo.orderHash
        );
    }

    function _emitEventSellOrderFilled(
        LibNFTOrder.ERC1155SellOrder memory sellOrder,
        address taker,
        uint128 erc1155FillAmount,
        bytes32 orderHash
    ) private {

        emit ERC1155SellOrderFilled(
            sellOrder.maker,
            taker,
            sellOrder.erc20Token,
            sellOrder.erc20TokenAmount,
            sellOrder.erc1155Token,
            sellOrder.erc1155TokenId,
            erc1155FillAmount,
            orderHash
        );
    }

    function _emitEventBuyOrderFilled(
        LibNFTOrder.ERC1155BuyOrder memory buyOrder,
        address taker,
        uint256 erc1155TokenId,
        uint128 erc1155FillAmount,
        bytes32 orderHash
    ) private {

        emit ERC1155BuyOrderFilled(
            buyOrder.maker,
            taker,
            buyOrder.erc20Token,
            buyOrder.erc20TokenAmount,
            buyOrder.erc1155Token,
            erc1155TokenId,
            erc1155FillAmount,
            orderHash
        );
    }

    function batchMatchERC1155Orders(
        LibNFTOrder.ERC1155SellOrder[] memory sellOrders,
        LibNFTOrder.ERC1155BuyOrder[] memory buyOrders,
        LibSignature.Signature[] memory sellOrderSignatures,
        LibSignature.Signature[] memory buyOrderSignatures
    )
        public
        override
        returns (uint256[] memory profits, bool[] memory successes)
    {

        require(
            sellOrders.length == buyOrders.length &&
            sellOrderSignatures.length == buyOrderSignatures.length &&
            sellOrders.length == sellOrderSignatures.length
        );
        profits = new uint256[](sellOrders.length);
        successes = new bool[](sellOrders.length);

        for (uint256 i = 0; i < sellOrders.length; i++) {
            bytes memory returnData;
            (successes[i], returnData) = _implementation.delegatecall(
                abi.encodeWithSelector(
                    this.matchERC1155Orders.selector,
                    sellOrders[i],
                    buyOrders[i],
                    sellOrderSignatures[i],
                    buyOrderSignatures[i]
                )
            );
            if (successes[i]) {
                (uint256 profit) = abi.decode(returnData, (uint256));
                profits[i] = profit;
            }
        }
    }
}