
pragma solidity ^0.5.9;
pragma experimental ABIEncoderV2;



interface IAssetData {


    function ERC20Token(address tokenAddress)
        external;


    function ERC721Token(
        address tokenAddress,
        uint256 tokenId
    )
        external;


    function ERC1155Assets(
        address tokenAddress,
        uint256[] calldata tokenIds,
        uint256[] calldata values,
        bytes calldata callbackData
    )
        external;


    function MultiAsset(
        uint256[] calldata values,
        bytes[] calldata nestedAssetData
    )
        external;


    function StaticCall(
        address staticCallTargetAddress,
        bytes calldata staticCallData,
        bytes32 expectedReturnDataHash
    )
        external;


    function ERC20Bridge(
        address tokenAddress,
        address bridgeAddress,
        bytes calldata bridgeData
    )
        external;

}



library LibEIP712 {


    bytes32 constant internal _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    function hashEIP712Domain(
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract
    )
        internal
        pure
        returns (bytes32 result)
    {

        bytes32 schemaHash = _EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH;


        assembly {
            let nameHash := keccak256(add(name, 32), mload(name))
            let versionHash := keccak256(add(version, 32), mload(version))

            let memPtr := mload(64)

            mstore(memPtr, schemaHash)
            mstore(add(memPtr, 32), nameHash)
            mstore(add(memPtr, 64), versionHash)
            mstore(add(memPtr, 96), chainId)
            mstore(add(memPtr, 128), verifyingContract)

            result := keccak256(memPtr, 160)
        }
        return result;
    }

    function hashEIP712Message(bytes32 eip712DomainHash, bytes32 hashStruct)
        internal
        pure
        returns (bytes32 result)
    {


        assembly {
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)  // EIP191 header
            mstore(add(memPtr, 2), eip712DomainHash)                                            // EIP712 domain hash
            mstore(add(memPtr, 34), hashStruct)                                                 // Hash of struct

            result := keccak256(memPtr, 66)
        }
        return result;
    }
}

library LibOrder {


    using LibOrder for Order;

    bytes32 constant internal _EIP712_ORDER_SCHEMA_HASH =
        0xf80322eb8376aafb64eadf8f0d7623f22130fd9491a221e902b713cb984a7534;

    enum OrderStatus {
        INVALID,                     // Default value
        INVALID_MAKER_ASSET_AMOUNT,  // Order does not have a valid maker asset amount
        INVALID_TAKER_ASSET_AMOUNT,  // Order does not have a valid taker asset amount
        FILLABLE,                    // Order is fillable
        EXPIRED,                     // Order has already expired
        FULLY_FILLED,                // Order is fully filled
        CANCELLED                    // Order has been cancelled
    }

    struct Order {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Fee paid to feeRecipient by maker when order is filled.
        uint256 takerFee;               // Fee paid to feeRecipient by taker when order is filled.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The leading bytes4 references the id of the asset proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The leading bytes4 references the id of the asset proxy.
        bytes makerFeeAssetData;        // Encoded data that can be decoded by a specified proxy contract when transferring makerFeeAsset. The leading bytes4 references the id of the asset proxy.
        bytes takerFeeAssetData;        // Encoded data that can be decoded by a specified proxy contract when transferring takerFeeAsset. The leading bytes4 references the id of the asset proxy.
    }

    struct OrderInfo {
        OrderStatus orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 typed data hash of the order (see LibOrder.getTypedDataHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }

    function getTypedDataHash(Order memory order, bytes32 eip712ExchangeDomainHash)
        internal
        pure
        returns (bytes32 orderHash)
    {

        orderHash = LibEIP712.hashEIP712Message(
            eip712ExchangeDomainHash,
            order.getStructHash()
        );
        return orderHash;
    }

    function getStructHash(Order memory order)
        internal
        pure
        returns (bytes32 result)
    {

        bytes32 schemaHash = _EIP712_ORDER_SCHEMA_HASH;
        bytes memory makerAssetData = order.makerAssetData;
        bytes memory takerAssetData = order.takerAssetData;
        bytes memory makerFeeAssetData = order.makerFeeAssetData;
        bytes memory takerFeeAssetData = order.takerFeeAssetData;


        assembly {
            if lt(order, 32) {
                invalid()
            }

            let pos1 := sub(order, 32)
            let pos2 := add(order, 320)
            let pos3 := add(order, 352)
            let pos4 := add(order, 384)
            let pos5 := add(order, 416)

            let temp1 := mload(pos1)
            let temp2 := mload(pos2)
            let temp3 := mload(pos3)
            let temp4 := mload(pos4)
            let temp5 := mload(pos5)

            mstore(pos1, schemaHash)
            mstore(pos2, keccak256(add(makerAssetData, 32), mload(makerAssetData)))        // store hash of makerAssetData
            mstore(pos3, keccak256(add(takerAssetData, 32), mload(takerAssetData)))        // store hash of takerAssetData
            mstore(pos4, keccak256(add(makerFeeAssetData, 32), mload(makerFeeAssetData)))  // store hash of makerFeeAssetData
            mstore(pos5, keccak256(add(takerFeeAssetData, 32), mload(takerFeeAssetData)))  // store hash of takerFeeAssetData
            result := keccak256(pos1, 480)

            mstore(pos1, temp1)
            mstore(pos2, temp2)
            mstore(pos3, temp3)
            mstore(pos4, temp4)
            mstore(pos5, temp5)
        }
        return result;
    }
}



library LibRichErrors {


    bytes4 internal constant STANDARD_ERROR_SELECTOR =
        0x08c379a0;

    function StandardError(
        string memory message
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            STANDARD_ERROR_SELECTOR,
            bytes(message)
        );
    }

    function rrevert(bytes memory errorData)
        internal
        pure
    {

        assembly {
            revert(add(errorData, 0x20), mload(errorData))
        }
    }
}

library LibSafeMathRichErrors {


    bytes4 internal constant UINT256_BINOP_ERROR_SELECTOR =
        0xe946c1bb;

    bytes4 internal constant UINT256_DOWNCAST_ERROR_SELECTOR =
        0xc996af7b;

    enum BinOpErrorCodes {
        ADDITION_OVERFLOW,
        MULTIPLICATION_OVERFLOW,
        SUBTRACTION_UNDERFLOW,
        DIVISION_BY_ZERO
    }

    enum DowncastErrorCodes {
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT32,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT64,
        VALUE_TOO_LARGE_TO_DOWNCAST_TO_UINT96
    }

    function Uint256BinOpError(
        BinOpErrorCodes errorCode,
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UINT256_BINOP_ERROR_SELECTOR,
            errorCode,
            a,
            b
        );
    }

    function Uint256DowncastError(
        DowncastErrorCodes errorCode,
        uint256 a
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UINT256_DOWNCAST_ERROR_SELECTOR,
            errorCode,
            a
        );
    }
}

library LibSafeMath {


    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        if (c / a != b) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.MULTIPLICATION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (b == 0) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.DIVISION_BY_ZERO,
                a,
                b
            ));
        }
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (b > a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.SUBTRACTION_UNDERFLOW,
                a,
                b
            ));
        }
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 c = a + b;
        if (c < a) {
            LibRichErrors.rrevert(LibSafeMathRichErrors.Uint256BinOpError(
                LibSafeMathRichErrors.BinOpErrorCodes.ADDITION_OVERFLOW,
                a,
                b
            ));
        }
        return c;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
    }
}

library LibMathRichErrors {


    bytes internal constant DIVISION_BY_ZERO_ERROR =
        hex"a791837c";

    bytes4 internal constant ROUNDING_ERROR_SELECTOR =
        0x339f3de2;

    function DivisionByZeroError()
        internal
        pure
        returns (bytes memory)
    {

        return DIVISION_BY_ZERO_ERROR;
    }

    function RoundingError(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            ROUNDING_ERROR_SELECTOR,
            numerator,
            denominator,
            target
        );
    }
}

library LibMath {


    using LibSafeMath for uint256;

    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        if (isRoundingErrorFloor(
                numerator,
                denominator,
                target
        )) {
            LibRichErrors.rrevert(LibMathRichErrors.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        if (isRoundingErrorCeil(
                numerator,
                denominator,
                target
        )) {
            LibRichErrors.rrevert(LibMathRichErrors.RoundingError(
                numerator,
                denominator,
                target
            ));
        }

        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        partialAmount = numerator.safeMul(target).safeDiv(denominator);
        return partialAmount;
    }

    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        partialAmount = numerator.safeMul(target)
            .safeAdd(denominator.safeSub(1))
            .safeDiv(denominator);

        return partialAmount;
    }

    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {

        if (denominator == 0) {
            LibRichErrors.rrevert(LibMathRichErrors.DivisionByZeroError());
        }

        if (target == 0 || numerator == 0) {
            return false;
        }

        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }

    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (bool isError)
    {

        if (denominator == 0) {
            LibRichErrors.rrevert(LibMathRichErrors.DivisionByZeroError());
        }

        if (target == 0 || numerator == 0) {
            return false;
        }
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = denominator.safeSub(remainder) % denominator;
        isError = remainder.safeMul(1000) >= numerator.safeMul(target);
        return isError;
    }
}




library LibBytesRichErrors {


    enum InvalidByteOperationErrorCodes {
        FromLessThanOrEqualsToRequired,
        ToLessThanOrEqualsLengthRequired,
        LengthGreaterThanZeroRequired,
        LengthGreaterThanOrEqualsFourRequired,
        LengthGreaterThanOrEqualsTwentyRequired,
        LengthGreaterThanOrEqualsThirtyTwoRequired,
        LengthGreaterThanOrEqualsNestedBytesLengthRequired,
        DestinationLengthGreaterThanOrEqualSourceLengthRequired
    }

    bytes4 internal constant INVALID_BYTE_OPERATION_ERROR_SELECTOR =
        0x28006595;

    function InvalidByteOperationError(
        InvalidByteOperationErrorCodes errorCode,
        uint256 offset,
        uint256 required
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INVALID_BYTE_OPERATION_ERROR_SELECTOR,
            errorCode,
            offset,
            required
        );
    }
}

library LibBytes {


    using LibBytes for bytes;

    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }

    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {

        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {

        if (length < 32) {
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            if (source == dest) {
                return;
            }

            if (source > dest) {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let last := mload(sEnd)

                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    let first := mload(source)

                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                    mstore(dest, first)
                }
            }
        }
    }

    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        if (from > to) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.FromLessThanOrEqualsToRequired,
                from,
                to
            ));
        }
        if (to > b.length) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.ToLessThanOrEqualsLengthRequired,
                to,
                b.length
            ));
        }

        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        if (b.length == 0) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanZeroRequired,
                b.length,
                0
            ));
        }

        result = b[b.length - 1];

        assembly {
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        index += 20;

        assembly {
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        if (b.length < index + 20) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsTwentyRequired,
                b.length,
                index + 20 // 20 is length of address
            ));
        }

        index += 20;

        assembly {

            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )

            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            mstore(add(b, index), xor(input, neighbors))
        }
    }

    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        index += 32;

        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        if (b.length < index + 32) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsThirtyTwoRequired,
                b.length,
                index + 32
            ));
        }

        index += 32;

        assembly {
            mstore(add(b, index), input)
        }
    }

    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        if (b.length < index + 4) {
            LibRichErrors.rrevert(LibBytesRichErrors.InvalidByteOperationError(
                LibBytesRichErrors.InvalidByteOperationErrorCodes.LengthGreaterThanOrEqualsFourRequired,
                b.length,
                index + 4
            ));
        }

        index += 32;

        assembly {
            result := mload(add(b, index))
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    function writeLength(bytes memory b, uint256 length)
        internal
        pure
    {
        assembly {
            mstore(b, length)
        }
    }
}



contract IERC20Token {


    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    function transfer(address _to, uint256 _value)
        external
        returns (bool);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool);


    function approve(address _spender, uint256 _value)
        external
        returns (bool);


    function totalSupply()
        external
        view
        returns (uint256);


    function balanceOf(address _owner)
        external
        view
        returns (uint256);


    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);

}

library LibERC20Token {

    bytes constant private DECIMALS_CALL_DATA = hex"313ce567";

    function approve(
        address token,
        address spender,
        uint256 allowance
    )
        internal
    {

        bytes memory callData = abi.encodeWithSelector(
            IERC20Token(0).approve.selector,
            spender,
            allowance
        );
        _callWithOptionalBooleanResult(token, callData);
    }

    function approveIfBelow(
        address token,
        address spender,
        uint256 amount
    )
        internal
    {

        if (IERC20Token(token).allowance(address(this), spender) < amount) {
            approve(token, spender, uint256(-1));
        }
    }

    function transfer(
        address token,
        address to,
        uint256 amount
    )
        internal
    {

        bytes memory callData = abi.encodeWithSelector(
            IERC20Token(0).transfer.selector,
            to,
            amount
        );
        _callWithOptionalBooleanResult(token, callData);
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        internal
    {

        bytes memory callData = abi.encodeWithSelector(
            IERC20Token(0).transferFrom.selector,
            from,
            to,
            amount
        );
        _callWithOptionalBooleanResult(token, callData);
    }

    function decimals(address token)
        internal
        view
        returns (uint8 tokenDecimals)
    {

        tokenDecimals = 18;
        (bool didSucceed, bytes memory resultData) = token.staticcall(DECIMALS_CALL_DATA);
        if (didSucceed && resultData.length == 32) {
            tokenDecimals = uint8(LibBytes.readUint256(resultData, 0));
        }
    }

    function allowance(address token, address owner, address spender)
        internal
        view
        returns (uint256 allowance_)
    {

        (bool didSucceed, bytes memory resultData) = token.staticcall(
            abi.encodeWithSelector(
                IERC20Token(0).allowance.selector,
                owner,
                spender
            )
        );
        if (didSucceed && resultData.length == 32) {
            allowance_ = LibBytes.readUint256(resultData, 0);
        }
    }

    function balanceOf(address token, address owner)
        internal
        view
        returns (uint256 balance)
    {

        (bool didSucceed, bytes memory resultData) = token.staticcall(
            abi.encodeWithSelector(
                IERC20Token(0).balanceOf.selector,
                owner
            )
        );
        if (didSucceed && resultData.length == 32) {
            balance = LibBytes.readUint256(resultData, 0);
        }
    }

    function _callWithOptionalBooleanResult(
        address target,
        bytes memory callData
    )
        private
    {

        (bool didSucceed, bytes memory resultData) = target.call(callData);
        if (didSucceed) {
            if (resultData.length == 0) {
                return;
            }
            if (resultData.length == 32) {
                uint256 result = LibBytes.readUint256(resultData, 0);
                if (result == 1) {
                    return;
                }
            }
        }
        LibRichErrors.rrevert(resultData);
    }
}


contract IERC721Token {


    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    )
        external;


    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external;


    function approve(address _approved, uint256 _tokenId)
        external;


    function setApprovalForAll(address _operator, bool _approved)
        external;


    function balanceOf(address _owner)
        external
        view
        returns (uint256);


    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public;


    function ownerOf(uint256 _tokenId)
        public
        view
        returns (address);


    function getApproved(uint256 _tokenId)
        public
        view
        returns (address);


    function isApprovedForAll(address _owner, address _operator)
        public
        view
        returns (bool);

}


interface IERC1155 {


    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    event URI(
        string value,
        uint256 indexed id
    );

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external;


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function balanceOf(address owner, uint256 id) external view returns (uint256);


    function balanceOfBatch(
        address[] calldata owners,
        uint256[] calldata ids
    )
        external
        view
        returns (uint256[] memory balances_);

}


library LibAssetDataTransferRichErrors {


    bytes4 internal constant UNSUPPORTED_ASSET_PROXY_ERROR_SELECTOR =
        0x7996a271;

    bytes4 internal constant ERC721_AMOUNT_MUST_EQUAL_ONE_ERROR_SELECTOR =
        0xbaffa474;

    function UnsupportedAssetProxyError(
        bytes4 proxyId
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UNSUPPORTED_ASSET_PROXY_ERROR_SELECTOR,
            proxyId
        );
    }

    function Erc721AmountMustEqualOneError(
        uint256 amount
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            ERC721_AMOUNT_MUST_EQUAL_ONE_ERROR_SELECTOR,
            amount
        );
    }
}

library LibAssetDataTransfer {


    using LibBytes for bytes;
    using LibSafeMath for uint256;
    using LibAssetDataTransfer for bytes;

    function transferFrom(
        bytes memory assetData,
        address from,
        address to,
        uint256 amount
    )
        internal
    {

        if (amount == 0) {
            return;
        }

        bytes4 proxyId = assetData.readBytes4(0);

        if (
            proxyId == IAssetData(address(0)).ERC20Token.selector ||
            proxyId == IAssetData(address(0)).ERC20Bridge.selector
        ) {
            assetData.transferERC20Token(
                from,
                to,
                amount
            );
        } else if (proxyId == IAssetData(address(0)).ERC721Token.selector) {
            assetData.transferERC721Token(
                from,
                to,
                amount
            );
        } else if (proxyId == IAssetData(address(0)).ERC1155Assets.selector) {
            assetData.transferERC1155Assets(
                from,
                to,
                amount
            );
        } else if (proxyId == IAssetData(address(0)).MultiAsset.selector) {
            assetData.transferMultiAsset(
                from,
                to,
                amount
            );
        } else if (proxyId != IAssetData(address(0)).StaticCall.selector) {
            LibRichErrors.rrevert(LibAssetDataTransferRichErrors.UnsupportedAssetProxyError(
                proxyId
            ));
        }
    }

    function transferIn(
        bytes memory assetData,
        uint256 amount
    )
        internal
    {

        assetData.transferFrom(
            msg.sender,
            address(this),
            amount
        );
    }

    function transferOut(
        bytes memory assetData,
        uint256 amount
    )
        internal
    {

        assetData.transferFrom(
            address(this),
            msg.sender,
            amount
        );
    }

    function transferERC20Token(
        bytes memory assetData,
        address from,
        address to,
        uint256 amount
    )
        internal
    {

        address token = assetData.readAddress(16);
        if (from == address(this)) {
            LibERC20Token.transfer(
                token,
                to,
                amount
            );
        } else {
            LibERC20Token.transferFrom(
                token,
                from,
                to,
                amount
            );
        }
    }

    function transferERC721Token(
        bytes memory assetData,
        address from,
        address to,
        uint256 amount
    )
        internal
    {

        if (amount != 1) {
            LibRichErrors.rrevert(LibAssetDataTransferRichErrors.Erc721AmountMustEqualOneError(
                amount
            ));
        }
        address token = assetData.readAddress(16);
        uint256 tokenId = assetData.readUint256(36);

        IERC721Token(token).transferFrom(
            from,
            to,
            tokenId
        );
    }

    function transferERC1155Assets(
        bytes memory assetData,
        address from,
        address to,
        uint256 amount
    )
        internal
    {

        (
            address token,
            uint256[] memory ids,
            uint256[] memory values,
            bytes memory data
        ) = abi.decode(
            assetData.slice(4, assetData.length),
            (address, uint256[], uint256[], bytes)
        );

        uint256 length = values.length;
        uint256[] memory scaledValues = new uint256[](length);
        for (uint256 i = 0; i != length; i++) {
            scaledValues[i] = values[i].safeMul(amount);
        }

        IERC1155(token).safeBatchTransferFrom(
            from,
            to,
            ids,
            scaledValues,
            data
        );
    }

    function transferMultiAsset(
        bytes memory assetData,
        address from,
        address to,
        uint256 amount
    )
        internal
    {

        (uint256[] memory nestedAmounts, bytes[] memory nestedAssetData) = abi.decode(
            assetData.slice(4, assetData.length),
            (uint256[], bytes[])
        );

        uint256 numNestedAssets = nestedAssetData.length;
        for (uint256 i = 0; i != numNestedAssets; i++) {
            transferFrom(
                nestedAssetData[i],
                from,
                to,
                amount.safeMul(nestedAmounts[i])
            );
        }
    }
}



contract IEtherToken is
    IERC20Token
{

    function deposit()
        public
        payable;


    function withdraw(uint256 amount)
        public;

}




library LibFillResults {


    using LibSafeMath for uint256;

    struct BatchMatchedFillResults {
        FillResults[] left;              // Fill results for left orders
        FillResults[] right;             // Fill results for right orders
        uint256 profitInLeftMakerAsset;  // Profit taken from left makers
        uint256 profitInRightMakerAsset; // Profit taken from right makers
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of fees paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of fees paid by taker to feeRecipients(s).
        uint256 protocolFeePaid;         // Total amount of fees paid by taker to the staking contract.
    }

    struct MatchedFillResults {
        FillResults left;                // Amounts filled and fees paid of left order.
        FillResults right;               // Amounts filled and fees paid of right order.
        uint256 profitInLeftMakerAsset;  // Profit taken from the left maker
        uint256 profitInRightMakerAsset; // Profit taken from the right maker
    }

    function calculateFillResults(
        LibOrder.Order memory order,
        uint256 takerAssetFilledAmount,
        uint256 protocolFeeMultiplier,
        uint256 gasPrice
    )
        internal
        pure
        returns (FillResults memory fillResults)
    {

        fillResults.takerAssetFilledAmount = takerAssetFilledAmount;
        fillResults.makerAssetFilledAmount = LibMath.safeGetPartialAmountFloor(
            takerAssetFilledAmount,
            order.takerAssetAmount,
            order.makerAssetAmount
        );
        fillResults.makerFeePaid = LibMath.safeGetPartialAmountFloor(
            takerAssetFilledAmount,
            order.takerAssetAmount,
            order.makerFee
        );
        fillResults.takerFeePaid = LibMath.safeGetPartialAmountFloor(
            takerAssetFilledAmount,
            order.takerAssetAmount,
            order.takerFee
        );

        fillResults.protocolFeePaid = gasPrice.safeMul(protocolFeeMultiplier);

        return fillResults;
    }

    function calculateMatchedFillResults(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        uint256 leftOrderTakerAssetFilledAmount,
        uint256 rightOrderTakerAssetFilledAmount,
        uint256 protocolFeeMultiplier,
        uint256 gasPrice,
        bool shouldMaximallyFillOrders
    )
        internal
        pure
        returns (MatchedFillResults memory matchedFillResults)
    {

        uint256 leftTakerAssetAmountRemaining = leftOrder.takerAssetAmount.safeSub(leftOrderTakerAssetFilledAmount);
        uint256 leftMakerAssetAmountRemaining = LibMath.safeGetPartialAmountFloor(
            leftOrder.makerAssetAmount,
            leftOrder.takerAssetAmount,
            leftTakerAssetAmountRemaining
        );
        uint256 rightTakerAssetAmountRemaining = rightOrder.takerAssetAmount.safeSub(rightOrderTakerAssetFilledAmount);
        uint256 rightMakerAssetAmountRemaining = LibMath.safeGetPartialAmountFloor(
            rightOrder.makerAssetAmount,
            rightOrder.takerAssetAmount,
            rightTakerAssetAmountRemaining
        );

        if (shouldMaximallyFillOrders) {
            matchedFillResults = _calculateMatchedFillResultsWithMaximalFill(
                leftOrder,
                rightOrder,
                leftMakerAssetAmountRemaining,
                leftTakerAssetAmountRemaining,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        } else {
            matchedFillResults = _calculateMatchedFillResults(
                leftOrder,
                rightOrder,
                leftMakerAssetAmountRemaining,
                leftTakerAssetAmountRemaining,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        }

        matchedFillResults.left.makerFeePaid = LibMath.safeGetPartialAmountFloor(
            matchedFillResults.left.makerAssetFilledAmount,
            leftOrder.makerAssetAmount,
            leftOrder.makerFee
        );
        matchedFillResults.left.takerFeePaid = LibMath.safeGetPartialAmountFloor(
            matchedFillResults.left.takerAssetFilledAmount,
            leftOrder.takerAssetAmount,
            leftOrder.takerFee
        );

        matchedFillResults.right.makerFeePaid = LibMath.safeGetPartialAmountFloor(
            matchedFillResults.right.makerAssetFilledAmount,
            rightOrder.makerAssetAmount,
            rightOrder.makerFee
        );
        matchedFillResults.right.takerFeePaid = LibMath.safeGetPartialAmountFloor(
            matchedFillResults.right.takerAssetFilledAmount,
            rightOrder.takerAssetAmount,
            rightOrder.takerFee
        );

        uint256 protocolFee = gasPrice.safeMul(protocolFeeMultiplier);
        matchedFillResults.left.protocolFeePaid = protocolFee;
        matchedFillResults.right.protocolFeePaid = protocolFee;

        return matchedFillResults;
    }

    function addFillResults(
        FillResults memory fillResults1,
        FillResults memory fillResults2
    )
        internal
        pure
        returns (FillResults memory totalFillResults)
    {

        totalFillResults.makerAssetFilledAmount = fillResults1.makerAssetFilledAmount.safeAdd(fillResults2.makerAssetFilledAmount);
        totalFillResults.takerAssetFilledAmount = fillResults1.takerAssetFilledAmount.safeAdd(fillResults2.takerAssetFilledAmount);
        totalFillResults.makerFeePaid = fillResults1.makerFeePaid.safeAdd(fillResults2.makerFeePaid);
        totalFillResults.takerFeePaid = fillResults1.takerFeePaid.safeAdd(fillResults2.takerFeePaid);
        totalFillResults.protocolFeePaid = fillResults1.protocolFeePaid.safeAdd(fillResults2.protocolFeePaid);

        return totalFillResults;
    }

    function _calculateMatchedFillResults(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        uint256 leftMakerAssetAmountRemaining,
        uint256 leftTakerAssetAmountRemaining,
        uint256 rightMakerAssetAmountRemaining,
        uint256 rightTakerAssetAmountRemaining
    )
        private
        pure
        returns (MatchedFillResults memory matchedFillResults)
    {

        if (leftTakerAssetAmountRemaining > rightMakerAssetAmountRemaining) {
            matchedFillResults = _calculateCompleteRightFill(
                leftOrder,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        } else if (leftTakerAssetAmountRemaining < rightMakerAssetAmountRemaining) {
            matchedFillResults.left.makerAssetFilledAmount = leftMakerAssetAmountRemaining;
            matchedFillResults.left.takerAssetFilledAmount = leftTakerAssetAmountRemaining;
            matchedFillResults.right.makerAssetFilledAmount = leftTakerAssetAmountRemaining;
            matchedFillResults.right.takerAssetFilledAmount = LibMath.safeGetPartialAmountCeil(
                rightOrder.takerAssetAmount,
                rightOrder.makerAssetAmount,
                leftTakerAssetAmountRemaining // matchedFillResults.right.makerAssetFilledAmount
            );
        } else {
            matchedFillResults = _calculateCompleteFillBoth(
                leftMakerAssetAmountRemaining,
                leftTakerAssetAmountRemaining,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        }

        matchedFillResults.profitInLeftMakerAsset = matchedFillResults.left.makerAssetFilledAmount.safeSub(
            matchedFillResults.right.takerAssetFilledAmount
        );

        return matchedFillResults;
    }

    function _calculateMatchedFillResultsWithMaximalFill(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        uint256 leftMakerAssetAmountRemaining,
        uint256 leftTakerAssetAmountRemaining,
        uint256 rightMakerAssetAmountRemaining,
        uint256 rightTakerAssetAmountRemaining
    )
        private
        pure
        returns (MatchedFillResults memory matchedFillResults)
    {

        bool doesLeftMakerAssetProfitExist = leftMakerAssetAmountRemaining > rightTakerAssetAmountRemaining;
        bool doesRightMakerAssetProfitExist = rightMakerAssetAmountRemaining > leftTakerAssetAmountRemaining;

        if (leftTakerAssetAmountRemaining > rightMakerAssetAmountRemaining) {
            matchedFillResults = _calculateCompleteRightFill(
                leftOrder,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        } else if (rightTakerAssetAmountRemaining > leftMakerAssetAmountRemaining) {
            matchedFillResults.left.makerAssetFilledAmount = leftMakerAssetAmountRemaining;
            matchedFillResults.left.takerAssetFilledAmount = leftTakerAssetAmountRemaining;
            matchedFillResults.right.makerAssetFilledAmount = LibMath.safeGetPartialAmountFloor(
                rightOrder.makerAssetAmount,
                rightOrder.takerAssetAmount,
                leftMakerAssetAmountRemaining
            );
            matchedFillResults.right.takerAssetFilledAmount = leftMakerAssetAmountRemaining;
        } else {
            matchedFillResults = _calculateCompleteFillBoth(
                leftMakerAssetAmountRemaining,
                leftTakerAssetAmountRemaining,
                rightMakerAssetAmountRemaining,
                rightTakerAssetAmountRemaining
            );
        }

        if (doesLeftMakerAssetProfitExist) {
            matchedFillResults.profitInLeftMakerAsset = matchedFillResults.left.makerAssetFilledAmount.safeSub(
                matchedFillResults.right.takerAssetFilledAmount
            );
        }

        if (doesRightMakerAssetProfitExist) {
            matchedFillResults.profitInRightMakerAsset = matchedFillResults.right.makerAssetFilledAmount.safeSub(
                matchedFillResults.left.takerAssetFilledAmount
            );
        }

        return matchedFillResults;
    }

    function _calculateCompleteFillBoth(
        uint256 leftMakerAssetAmountRemaining,
        uint256 leftTakerAssetAmountRemaining,
        uint256 rightMakerAssetAmountRemaining,
        uint256 rightTakerAssetAmountRemaining
    )
        private
        pure
        returns (MatchedFillResults memory matchedFillResults)
    {

        matchedFillResults.left.makerAssetFilledAmount = leftMakerAssetAmountRemaining;
        matchedFillResults.left.takerAssetFilledAmount = leftTakerAssetAmountRemaining;
        matchedFillResults.right.makerAssetFilledAmount = rightMakerAssetAmountRemaining;
        matchedFillResults.right.takerAssetFilledAmount = rightTakerAssetAmountRemaining;

        return matchedFillResults;
    }

    function _calculateCompleteRightFill(
        LibOrder.Order memory leftOrder,
        uint256 rightMakerAssetAmountRemaining,
        uint256 rightTakerAssetAmountRemaining
    )
        private
        pure
        returns (MatchedFillResults memory matchedFillResults)
    {

        matchedFillResults.right.makerAssetFilledAmount = rightMakerAssetAmountRemaining;
        matchedFillResults.right.takerAssetFilledAmount = rightTakerAssetAmountRemaining;
        matchedFillResults.left.takerAssetFilledAmount = rightMakerAssetAmountRemaining;
        matchedFillResults.left.makerAssetFilledAmount = LibMath.safeGetPartialAmountFloor(
            leftOrder.makerAssetAmount,
            leftOrder.takerAssetAmount,
            rightMakerAssetAmountRemaining
        );

        return matchedFillResults;
    }
}

contract IExchangeCore {


    event Fill(
        address indexed makerAddress,         // Address that created the order.
        address indexed feeRecipientAddress,  // Address that received fees.
        bytes makerAssetData,                 // Encoded data specific to makerAsset.
        bytes takerAssetData,                 // Encoded data specific to takerAsset.
        bytes makerFeeAssetData,              // Encoded data specific to makerFeeAsset.
        bytes takerFeeAssetData,              // Encoded data specific to takerFeeAsset.
        bytes32 indexed orderHash,            // EIP712 hash of order (see LibOrder.getTypedDataHash).
        address takerAddress,                 // Address that filled the order.
        address senderAddress,                // Address that called the Exchange contract (msg.sender).
        uint256 makerAssetFilledAmount,       // Amount of makerAsset sold by maker and bought by taker.
        uint256 takerAssetFilledAmount,       // Amount of takerAsset sold by taker and bought by maker.
        uint256 makerFeePaid,                 // Amount of makerFeeAssetData paid to feeRecipient by maker.
        uint256 takerFeePaid,                 // Amount of takerFeeAssetData paid to feeRecipient by taker.
        uint256 protocolFeePaid               // Amount of eth or weth paid to the staking contract.
    );

    event Cancel(
        address indexed makerAddress,         // Address that created the order.
        address indexed feeRecipientAddress,  // Address that would have recieved fees if order was filled.
        bytes makerAssetData,                 // Encoded data specific to makerAsset.
        bytes takerAssetData,                 // Encoded data specific to takerAsset.
        address senderAddress,                // Address that called the Exchange contract (msg.sender).
        bytes32 indexed orderHash             // EIP712 hash of order (see LibOrder.getTypedDataHash).
    );

    event CancelUpTo(
        address indexed makerAddress,         // Orders cancelled must have been created by this address.
        address indexed orderSenderAddress,   // Orders cancelled must have a `senderAddress` equal to this address.
        uint256 orderEpoch                    // Orders with specified makerAddress and senderAddress with a salt less than this value are considered cancelled.
    );

    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        external
        payable;


    function fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);


    function cancelOrder(LibOrder.Order memory order)
        public
        payable;


    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo);

}


contract IProtocolFees {


    event ProtocolFeeMultiplier(uint256 oldProtocolFeeMultiplier, uint256 updatedProtocolFeeMultiplier);

    event ProtocolFeeCollectorAddress(address oldProtocolFeeCollector, address updatedProtocolFeeCollector);

    function setProtocolFeeMultiplier(uint256 updatedProtocolFeeMultiplier)
        external;


    function setProtocolFeeCollectorAddress(address updatedProtocolFeeCollector)
        external;


    function protocolFeeMultiplier()
        external
        view
        returns (uint256);


    function protocolFeeCollector()
        external
        view
        returns (address);

}


contract IMatchOrders {


    function batchMatchOrders(
        LibOrder.Order[] memory leftOrders,
        LibOrder.Order[] memory rightOrders,
        bytes[] memory leftSignatures,
        bytes[] memory rightSignatures
    )
        public
        payable
        returns (LibFillResults.BatchMatchedFillResults memory batchMatchedFillResults);


    function batchMatchOrdersWithMaximalFill(
        LibOrder.Order[] memory leftOrders,
        LibOrder.Order[] memory rightOrders,
        bytes[] memory leftSignatures,
        bytes[] memory rightSignatures
    )
        public
        payable
        returns (LibFillResults.BatchMatchedFillResults memory batchMatchedFillResults);


    function matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        payable
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);


    function matchOrdersWithMaximalFill(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        payable
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);

}



library LibZeroExTransaction {


    using LibZeroExTransaction for ZeroExTransaction;

    bytes32 constant internal _EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH = 0xec69816980a3a3ca4554410e60253953e9ff375ba4536a98adfa15cc71541508;

    struct ZeroExTransaction {
        uint256 salt;                   // Arbitrary number to ensure uniqueness of transaction hash.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which transaction expires.
        uint256 gasPrice;               // gasPrice that transaction is required to be executed with.
        address signerAddress;          // Address of transaction signer.
        bytes data;                     // AbiV2 encoded calldata.
    }

    function getTypedDataHash(ZeroExTransaction memory transaction, bytes32 eip712ExchangeDomainHash)
        internal
        pure
        returns (bytes32 transactionHash)
    {

        transactionHash = LibEIP712.hashEIP712Message(
            eip712ExchangeDomainHash,
            transaction.getStructHash()
        );
        return transactionHash;
    }

    function getStructHash(ZeroExTransaction memory transaction)
        internal
        pure
        returns (bytes32 result)
    {

        bytes32 schemaHash = _EIP712_ZEROEX_TRANSACTION_SCHEMA_HASH;
        bytes memory data = transaction.data;
        uint256 salt = transaction.salt;
        uint256 expirationTimeSeconds = transaction.expirationTimeSeconds;
        uint256 gasPrice = transaction.gasPrice;
        address signerAddress = transaction.signerAddress;


        assembly {
            let dataHash := keccak256(add(data, 32), mload(data))

            let memPtr := mload(64)

            mstore(memPtr, schemaHash)                                                                // hash of schema
            mstore(add(memPtr, 32), salt)                                                             // salt
            mstore(add(memPtr, 64), expirationTimeSeconds)                                            // expirationTimeSeconds
            mstore(add(memPtr, 96), gasPrice)                                                         // gasPrice
            mstore(add(memPtr, 128), and(signerAddress, 0xffffffffffffffffffffffffffffffffffffffff))  // signerAddress
            mstore(add(memPtr, 160), dataHash)                                                        // hash of data

            result := keccak256(memPtr, 192)
        }
        return result;
    }
}

contract ISignatureValidator {


    enum SignatureType {
        Illegal,                     // 0x00, default value
        Invalid,                     // 0x01
        EIP712,                      // 0x02
        EthSign,                     // 0x03
        Wallet,                      // 0x04
        Validator,                   // 0x05
        PreSigned,                   // 0x06
        EIP1271Wallet,               // 0x07
        NSignatureTypes              // 0x08, number of signature types. Always leave at end.
    }

    event SignatureValidatorApproval(
        address indexed signerAddress,     // Address that approves or disapproves a contract to verify signatures.
        address indexed validatorAddress,  // Address of signature validator contract.
        bool isApproved                    // Approval or disapproval of validator contract.
    );

    function preSign(bytes32 hash)
        external
        payable;


    function setSignatureValidatorApproval(
        address validatorAddress,
        bool approval
    )
        external
        payable;


    function isValidHashSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);


    function isValidOrderSignature(
        LibOrder.Order memory order,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);


    function isValidTransactionSignature(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);


    function _isValidOrderWithHashSignature(
        LibOrder.Order memory order,
        bytes32 orderHash,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid);


    function _isValidTransactionWithHashSignature(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes32 transactionHash,
        bytes memory signature
    )
        internal
        view
        returns (bool isValid);

}


contract ITransactions {


    event TransactionExecution(bytes32 indexed transactionHash);

    function executeTransaction(
        LibZeroExTransaction.ZeroExTransaction memory transaction,
        bytes memory signature
    )
        public
        payable
        returns (bytes memory);


    function batchExecuteTransactions(
        LibZeroExTransaction.ZeroExTransaction[] memory transactions,
        bytes[] memory signatures
    )
        public
        payable
        returns (bytes[] memory);


    function _getCurrentContextAddress()
        internal
        view
        returns (address);

}


contract IAssetProxyDispatcher {


    event AssetProxyRegistered(
        bytes4 id,              // Id of new registered AssetProxy.
        address assetProxy      // Address of new registered AssetProxy.
    );

    function registerAssetProxy(address assetProxy)
        external;


    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address);

}


contract IWrapperFunctions {


    function fillOrKillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);


    function batchFillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults[] memory fillResults);


    function batchFillOrKillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults[] memory fillResults);


    function batchFillOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults[] memory fillResults);


    function marketSellOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);


    function marketBuyOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);


    function marketSellOrdersFillOrKill(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);


    function marketBuyOrdersFillOrKill(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        payable
        returns (LibFillResults.FillResults memory fillResults);


    function batchCancelOrders(LibOrder.Order[] memory orders)
        public
        payable;

}


contract ITransferSimulator {


    function simulateDispatchTransferFromCalls(
        bytes[] memory assetData,
        address[] memory fromAddresses,
        address[] memory toAddresses,
        uint256[] memory amounts
    )
        public;

}

contract IExchange is
    IProtocolFees,
    IExchangeCore,
    IMatchOrders,
    ISignatureValidator,
    ITransactions,
    IAssetProxyDispatcher,
    ITransferSimulator,
    IWrapperFunctions
{}



library LibWethUtilsRichErrors {


    bytes4 internal constant UNREGISTERED_ASSET_PROXY_ERROR_SELECTOR =
        0xf3b96b8d;

    bytes4 internal constant INSUFFICIENT_ETH_FOR_FEE_ERROR_SELECTOR =
        0xecf40fd9;

    bytes4 internal constant DEFAULT_FUNCTION_WETH_CONTRACT_ONLY_ERROR_SELECTOR =
        0x08b18698;

    bytes4 internal constant ETH_FEE_LENGTH_MISMATCH_ERROR_SELECTOR =
        0x3ecb6ceb;

    function UnregisteredAssetProxyError()
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(UNREGISTERED_ASSET_PROXY_ERROR_SELECTOR);
    }

    function InsufficientEthForFeeError(
        uint256 ethFeeRequired,
        uint256 ethAvailable
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            INSUFFICIENT_ETH_FOR_FEE_ERROR_SELECTOR,
            ethFeeRequired,
            ethAvailable
        );
    }

    function DefaultFunctionWethContractOnlyError(
        address senderAddress
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            DEFAULT_FUNCTION_WETH_CONTRACT_ONLY_ERROR_SELECTOR,
            senderAddress
        );
    }

    function EthFeeLengthMismatchError(
        uint256 ethFeesLength,
        uint256 feeRecipientsLength
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            ETH_FEE_LENGTH_MISMATCH_ERROR_SELECTOR,
            ethFeesLength,
            feeRecipientsLength
        );
    }
}

contract MixinWethUtils {


    uint256 constant internal MAX_UINT256 = uint256(-1);

    IEtherToken internal WETH;
    bytes internal WETH_ASSET_DATA;

    using LibSafeMath for uint256;

    constructor (
        address exchange,
        address weth
    )
        public
    {
        WETH = IEtherToken(weth);
        WETH_ASSET_DATA = abi.encodeWithSelector(
            IAssetData(address(0)).ERC20Token.selector,
            weth
        );

        address proxyAddress = IExchange(exchange).getAssetProxy(IAssetData(address(0)).ERC20Token.selector);
        if (proxyAddress == address(0)) {
            LibRichErrors.rrevert(LibWethUtilsRichErrors.UnregisteredAssetProxyError());
        }
        WETH.approve(proxyAddress, MAX_UINT256);

        address protocolFeeCollector = IExchange(exchange).protocolFeeCollector();
        if (protocolFeeCollector != address(0)) {
            WETH.approve(protocolFeeCollector, MAX_UINT256);
        }
    }

    function ()
        external
        payable
    {
        if (msg.sender != address(WETH)) {
            LibRichErrors.rrevert(LibWethUtilsRichErrors.DefaultFunctionWethContractOnlyError(
                msg.sender
            ));
        }
    }

    function _transferEthFeesAndWrapRemaining(
        uint256[] memory ethFeeAmounts,
        address payable[] memory feeRecipients
    )
        internal
        returns (uint256 ethRemaining)
    {

        uint256 feesLen = ethFeeAmounts.length;
        if (feesLen != feeRecipients.length) {
            LibRichErrors.rrevert(LibWethUtilsRichErrors.EthFeeLengthMismatchError(
                feesLen,
                feeRecipients.length
            ));
        }

        ethRemaining = msg.value;

        for (uint256 i = 0; i != feesLen; i++) {
            uint256 ethFeeAmount = ethFeeAmounts[i];
            if (ethRemaining < ethFeeAmount) {
                LibRichErrors.rrevert(LibWethUtilsRichErrors.InsufficientEthForFeeError(
                    ethFeeAmount,
                    ethRemaining
                ));
            }
            ethRemaining = ethRemaining.safeSub(ethFeeAmount);
            feeRecipients[i].transfer(ethFeeAmount);
        }

        WETH.deposit.value(ethRemaining)();

        return ethRemaining;
    }

    function _unwrapAndTransferEth(
        uint256 transferAmount
    )
        internal
    {

        if (transferAmount > 0) {
            WETH.withdraw(transferAmount);
            msg.sender.transfer(transferAmount);
        }
    }
}



contract IOwnable {


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function transferOwnership(address newOwner)
        public;

}

library LibOwnableRichErrors {


    bytes4 internal constant ONLY_OWNER_ERROR_SELECTOR =
        0x1de45ad1;

    bytes internal constant TRANSFER_OWNER_TO_ZERO_ERROR_BYTES =
        hex"e69edc3e";

    function OnlyOwnerError(
        address sender,
        address owner
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            ONLY_OWNER_ERROR_SELECTOR,
            sender,
            owner
        );
    }

    function TransferOwnerToZeroError()
        internal
        pure
        returns (bytes memory)
    {

        return TRANSFER_OWNER_TO_ZERO_ERROR_BYTES;
    }
}

contract Ownable is
    IOwnable
{

    address public owner;

    constructor ()
        public
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {

        _assertSenderIsOwner();
        _;
    }

    function transferOwnership(address newOwner)
        public
        onlyOwner
    {

        if (newOwner == address(0)) {
            LibRichErrors.rrevert(LibOwnableRichErrors.TransferOwnerToZeroError());
        } else {
            owner = newOwner;
            emit OwnershipTransferred(msg.sender, newOwner);
        }
    }

    function _assertSenderIsOwner()
        internal
        view
    {

        if (msg.sender != owner) {
            LibRichErrors.rrevert(LibOwnableRichErrors.OnlyOwnerError(
                msg.sender,
                owner
            ));
        }
    }
}


library LibForwarderRichErrors {


    bytes4 internal constant UNREGISTERED_ASSET_PROXY_ERROR_SELECTOR =
        0xf3b96b8d;

    bytes4 internal constant COMPLETE_BUY_FAILED_ERROR_SELECTOR =
        0x91353a0c;

    bytes4 internal constant COMPLETE_SELL_FAILED_ERROR_SELECTOR =
        0x450a0219;

    bytes4 internal constant UNSUPPORTED_FEE_ERROR_SELECTOR =
        0x31360af1;

    bytes4 internal constant OVERSPENT_WETH_ERROR_SELECTOR =
        0xcdcbed5d;

    function UnregisteredAssetProxyError()
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(UNREGISTERED_ASSET_PROXY_ERROR_SELECTOR);
    }

    function CompleteBuyFailedError(
        uint256 expectedAssetBuyAmount,
        uint256 actualAssetBuyAmount
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            COMPLETE_BUY_FAILED_ERROR_SELECTOR,
            expectedAssetBuyAmount,
            actualAssetBuyAmount
        );
    }

    function CompleteSellFailedError(
        uint256 expectedAssetSellAmount,
        uint256 actualAssetSellAmount
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            COMPLETE_SELL_FAILED_ERROR_SELECTOR,
            expectedAssetSellAmount,
            actualAssetSellAmount
        );
    }

    function UnsupportedFeeError(
        bytes memory takerFeeAssetData
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            UNSUPPORTED_FEE_ERROR_SELECTOR,
            takerFeeAssetData
        );
    }

    function OverspentWethError(
        uint256 wethSpent,
        uint256 msgValue
    )
        internal
        pure
        returns (bytes memory)
    {

        return abi.encodeWithSelector(
            OVERSPENT_WETH_ERROR_SELECTOR,
            wethSpent,
            msgValue
        );
    }
}



contract IExchangeV2 {


    struct Order {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    struct OrderInfo {
        uint8 orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 typed data hash of the order (see LibOrder.getTypedDataHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }

    function fillOrder(
        Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (FillResults memory fillResults);


    function getOrderInfo(Order memory order)
        public
        returns (OrderInfo memory orderInfo);

}

contract MixinExchangeWrapper {


    bytes4 constant public EXCHANGE_V2_ORDER_ID = 0x770501f8;
    bytes4 constant internal ERC20_BRIDGE_PROXY_ID = 0xdc1600f3;

    IExchange internal EXCHANGE;
    IExchangeV2 internal EXCHANGE_V2;

    using LibBytes for bytes;
    using LibAssetDataTransfer for bytes;
    using LibSafeMath for uint256;

    constructor (
        address _exchange,
        address _exchangeV2
    )
        public
    {
        EXCHANGE = IExchange(_exchange);
        EXCHANGE_V2 = IExchangeV2(_exchangeV2);
    }

    struct SellFillResults {
        uint256 wethSpentAmount;
        uint256 makerAssetAcquiredAmount;
        uint256 protocolFeePaid;
    }

    function _fillOrderNoThrow(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        internal
        returns (LibFillResults.FillResults memory fillResults)
    {

        if (_isV2Order(order)) {
            return _fillV2OrderNoThrow(
                order,
                takerAssetFillAmount,
                signature
            );
        }

        return _fillV3OrderNoThrow(
            order,
            takerAssetFillAmount,
            signature
        );
    }

    function _marketSellSingleOrder(
        LibOrder.Order memory order,
        bytes memory signature,
        uint256 remainingTakerAssetFillAmount
    )
        internal
        returns (SellFillResults memory sellFillResults)
    {

        bytes4 makerAssetProxyId = order.makerAssetData.readBytes4(0);
        address tokenAddress;
        uint256 balanceBefore;
        if (makerAssetProxyId == ERC20_BRIDGE_PROXY_ID) {
            tokenAddress = order.makerAssetData.readAddress(16);
            balanceBefore = IERC20Token(tokenAddress).balanceOf(address(this));
        }
        if (
            order.takerFee == 0 ||
            _areUnderlyingAssetsEqual(order.takerFeeAssetData, order.makerAssetData)
        ) {
            LibFillResults.FillResults memory singleFillResults = _fillOrderNoThrow(
                order,
                remainingTakerAssetFillAmount,
                signature
            );

            sellFillResults.wethSpentAmount = singleFillResults.takerAssetFilledAmount;
            sellFillResults.protocolFeePaid = singleFillResults.protocolFeePaid;

            sellFillResults.makerAssetAcquiredAmount = singleFillResults.makerAssetFilledAmount
                .safeSub(singleFillResults.takerFeePaid);

        } else if (_areUnderlyingAssetsEqual(order.takerFeeAssetData, order.takerAssetData)) {

            uint256 takerAssetFillAmount = LibMath.getPartialAmountCeil(
                order.takerAssetAmount,
                order.takerAssetAmount.safeAdd(order.takerFee),
                remainingTakerAssetFillAmount
            );

            LibFillResults.FillResults memory singleFillResults = _fillOrderNoThrow(
                order,
                takerAssetFillAmount,
                signature
            );

            sellFillResults.wethSpentAmount = singleFillResults.takerAssetFilledAmount
                .safeAdd(singleFillResults.takerFeePaid);
            sellFillResults.makerAssetAcquiredAmount = singleFillResults.makerAssetFilledAmount;
            sellFillResults.protocolFeePaid = singleFillResults.protocolFeePaid;

        } else {
            LibRichErrors.rrevert(LibForwarderRichErrors.UnsupportedFeeError(order.takerFeeAssetData));
        }

        if (makerAssetProxyId == ERC20_BRIDGE_PROXY_ID) {
            uint256 balanceAfter = IERC20Token(tokenAddress).balanceOf(address(this));
            sellFillResults.makerAssetAcquiredAmount = LibSafeMath.max256(
                balanceAfter.safeSub(balanceBefore),
                sellFillResults.makerAssetAcquiredAmount
            );
        }

        order.makerAssetData.transferOut(sellFillResults.makerAssetAcquiredAmount);
        return sellFillResults;
    }

    function _marketSellNoThrow(
        LibOrder.Order[] memory orders,
        uint256 wethSellAmount,
        bytes[] memory signatures
    )
        internal
        returns (
            uint256 totalWethSpentAmount,
            uint256 totalMakerAssetAcquiredAmount
        )
    {

        uint256 protocolFee = tx.gasprice.safeMul(EXCHANGE.protocolFeeMultiplier());

        for (uint256 i = 0; i != orders.length; i++) {
            if (orders[i].makerAssetAmount == 0 || orders[i].takerAssetAmount == 0) {
                continue;
            }

            uint256 remainingTakerAssetFillAmount = wethSellAmount
                .safeSub(totalWethSpentAmount);
            uint256 currentProtocolFee = _isV2Order(orders[i]) ? 0 : protocolFee;
            if (remainingTakerAssetFillAmount > currentProtocolFee) {
                remainingTakerAssetFillAmount = remainingTakerAssetFillAmount.safeSub(currentProtocolFee);
            } else {
                break;
            }

            SellFillResults memory sellFillResults = _marketSellSingleOrder(
                orders[i],
                signatures[i],
                remainingTakerAssetFillAmount
            );

            totalWethSpentAmount = totalWethSpentAmount
                .safeAdd(sellFillResults.wethSpentAmount)
                .safeAdd(sellFillResults.protocolFeePaid);
            totalMakerAssetAcquiredAmount = totalMakerAssetAcquiredAmount
                .safeAdd(sellFillResults.makerAssetAcquiredAmount);

            if (totalWethSpentAmount >= wethSellAmount) {
                break;
            }
        }
    }

    function _marketSellExactAmountNoThrow(
        LibOrder.Order[] memory orders,
        uint256 wethSellAmount,
        bytes[] memory signatures
    )
        internal
        returns (
            uint256 totalWethSpentAmount,
            uint256 totalMakerAssetAcquiredAmount
        )
    {

        uint256 totalProtocolFeePaid;

        for (uint256 i = 0; i != orders.length; i++) {
            if (orders[i].makerAssetAmount == 0 || orders[i].takerAssetAmount == 0) {
                continue;
            }

            uint256 remainingTakerAssetFillAmount = wethSellAmount
                .safeSub(totalWethSpentAmount);

            SellFillResults memory sellFillResults = _marketSellSingleOrder(
                orders[i],
                signatures[i],
                remainingTakerAssetFillAmount
            );

            totalWethSpentAmount = totalWethSpentAmount
                .safeAdd(sellFillResults.wethSpentAmount);
            totalMakerAssetAcquiredAmount = totalMakerAssetAcquiredAmount
                .safeAdd(sellFillResults.makerAssetAcquiredAmount);
            totalProtocolFeePaid = totalProtocolFeePaid.safeAdd(sellFillResults.protocolFeePaid);

            if (totalWethSpentAmount >= wethSellAmount) {
                break;
            }
        }
        totalWethSpentAmount = totalWethSpentAmount.safeAdd(totalProtocolFeePaid);
    }

    function _marketBuySingleOrder(
        LibOrder.Order memory order,
        bytes memory signature,
        uint256 remainingMakerAssetFillAmount
    )
        internal
        returns (
            uint256 wethSpentAmount,
            uint256 makerAssetAcquiredAmount
        )
    {

        if (
            order.takerFee == 0 ||
            _areUnderlyingAssetsEqual(order.takerFeeAssetData, order.takerAssetData)
        ) {
            uint256 remainingTakerAssetFillAmount = LibMath.getPartialAmountCeil(
                order.takerAssetAmount,
                order.makerAssetAmount,
                remainingMakerAssetFillAmount
            );

            LibFillResults.FillResults memory singleFillResults = _fillOrderNoThrow(
                order,
                remainingTakerAssetFillAmount,
                signature
            );

            wethSpentAmount = singleFillResults.takerAssetFilledAmount
                .safeAdd(singleFillResults.takerFeePaid)
                .safeAdd(singleFillResults.protocolFeePaid);

            makerAssetAcquiredAmount = singleFillResults.makerAssetFilledAmount;

        } else if (_areUnderlyingAssetsEqual(order.takerFeeAssetData, order.makerAssetData)) {
            uint256 remainingTakerAssetFillAmount = LibMath.getPartialAmountCeil(
                order.takerAssetAmount,
                order.makerAssetAmount.safeSub(order.takerFee),
                remainingMakerAssetFillAmount
            );

            LibFillResults.FillResults memory singleFillResults = _fillOrderNoThrow(
                order,
                remainingTakerAssetFillAmount,
                signature
            );

            wethSpentAmount = singleFillResults.takerAssetFilledAmount
                .safeAdd(singleFillResults.protocolFeePaid);

            makerAssetAcquiredAmount = singleFillResults.makerAssetFilledAmount
                .safeSub(singleFillResults.takerFeePaid);

        } else {
            LibRichErrors.rrevert(LibForwarderRichErrors.UnsupportedFeeError(order.takerFeeAssetData));
        }

        return (wethSpentAmount, makerAssetAcquiredAmount);
    }

    function _marketBuyFillOrKill(
        LibOrder.Order[] memory orders,
        uint256 makerAssetBuyAmount,
        bytes[] memory signatures
    )
        internal
        returns (
            uint256 totalWethSpentAmount,
            uint256 totalMakerAssetAcquiredAmount
        )
    {

        uint256 ordersLength = orders.length;
        for (uint256 i = 0; i != ordersLength; i++) {
            if (orders[i].makerAssetAmount == 0 || orders[i].takerAssetAmount == 0) {
                continue;
            }

            uint256 remainingMakerAssetFillAmount = makerAssetBuyAmount
                .safeSub(totalMakerAssetAcquiredAmount);

            bytes4 makerAssetProxyId = orders[i].makerAssetData.readBytes4(0);
            address tokenAddress;
            uint256 balanceBefore;
            if (makerAssetProxyId == ERC20_BRIDGE_PROXY_ID) {
                tokenAddress = orders[i].makerAssetData.readAddress(16);
                balanceBefore = IERC20Token(tokenAddress).balanceOf(address(this));
            }

            (
                uint256 wethSpentAmount,
                uint256 makerAssetAcquiredAmount
            ) = _marketBuySingleOrder(
                orders[i],
                signatures[i],
                remainingMakerAssetFillAmount
            );

            if (makerAssetProxyId == ERC20_BRIDGE_PROXY_ID) {
                uint256 balanceAfter = IERC20Token(tokenAddress).balanceOf(address(this));
                makerAssetAcquiredAmount = LibSafeMath.max256(
                    balanceAfter.safeSub(balanceBefore),
                    makerAssetAcquiredAmount
                );
            }

            orders[i].makerAssetData.transferOut(makerAssetAcquiredAmount);

            totalWethSpentAmount = totalWethSpentAmount
                .safeAdd(wethSpentAmount);
            totalMakerAssetAcquiredAmount = totalMakerAssetAcquiredAmount
                .safeAdd(makerAssetAcquiredAmount);

            if (totalMakerAssetAcquiredAmount >= makerAssetBuyAmount) {
                break;
            }
        }

        if (totalMakerAssetAcquiredAmount < makerAssetBuyAmount) {
            LibRichErrors.rrevert(LibForwarderRichErrors.CompleteBuyFailedError(
                makerAssetBuyAmount,
                totalMakerAssetAcquiredAmount
            ));
        }
    }

    function _fillV2OrderNoThrow(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        internal
        returns (LibFillResults.FillResults memory fillResults)
    {

        IExchangeV2.Order memory v2Order = IExchangeV2.Order({
            makerAddress: order.makerAddress,
            takerAddress: order.takerAddress,
            feeRecipientAddress: order.feeRecipientAddress,
            senderAddress: order.senderAddress,
            makerAssetAmount: order.makerAssetAmount,
            takerAssetAmount: order.takerAssetAmount,
            makerFee: 0,
            takerFee: 0,
            expirationTimeSeconds: order.expirationTimeSeconds,
            salt: order.salt,
            makerAssetData: order.makerAssetData,
            takerAssetData: order.takerAssetData
        });

        bytes memory fillOrderCalldata = abi.encodeWithSelector(
            IExchangeV2(address(0)).fillOrder.selector,
            v2Order,
            takerAssetFillAmount,
            signature
        );

        address exchange = address(EXCHANGE_V2);
        (bool didSucceed, bytes memory returnData) = exchange.call(fillOrderCalldata);
        if (didSucceed) {
            assert(returnData.length == 128);
            (fillResults.makerAssetFilledAmount, fillResults.takerAssetFilledAmount) = abi.decode(returnData, (uint256, uint256));
        }

        return fillResults;
    }

    function _fillV3OrderNoThrow(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        internal
        returns (LibFillResults.FillResults memory fillResults)
    {

        bytes memory fillOrderCalldata = abi.encodeWithSelector(
            IExchange(address(0)).fillOrder.selector,
            order,
            takerAssetFillAmount,
            signature
        );

        address exchange = address(EXCHANGE);
        (bool didSucceed, bytes memory returnData) = exchange.call(fillOrderCalldata);
        if (didSucceed) {
            assert(returnData.length == 160);
            fillResults = abi.decode(returnData, (LibFillResults.FillResults));
        }

        return fillResults;
    }

    function _areUnderlyingAssetsEqual(
        bytes memory assetData1,
        bytes memory assetData2
    )
        internal
        pure
        returns (bool)
    {

        bytes4 assetProxyId1 = assetData1.readBytes4(0);
        bytes4 assetProxyId2 = assetData2.readBytes4(0);
        bytes4 erc20ProxyId = IAssetData(address(0)).ERC20Token.selector;
        bytes4 erc20BridgeProxyId = IAssetData(address(0)).ERC20Bridge.selector;

        if (
            (assetProxyId1 == erc20ProxyId || assetProxyId1 == erc20BridgeProxyId) &&
            (assetProxyId2 == erc20ProxyId || assetProxyId2 == erc20BridgeProxyId)
        ) {
            address token1 = assetData1.readAddress(16);
            address token2 = assetData2.readAddress(16);
            return (token1 == token2);
        } else {
            return assetData1.equals(assetData2);
        }
    }

    function _isV2Order(LibOrder.Order memory order)
        internal
        pure
        returns (bool)
    {

        return order.makerFeeAssetData.length > 3 && order.makerFeeAssetData.readBytes4(0) == EXCHANGE_V2_ORDER_ID;
    }
}


contract MixinReceiver {


    bytes4 constant public ERC1155_RECEIVED       = 0xf23a6e61;
    bytes4 constant public ERC1155_BATCH_RECEIVED = 0xbc197c81;

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns (bytes4)
    {

        return ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns (bytes4)
    {

        return ERC1155_BATCH_RECEIVED;
    }
}

contract IForwarder {


    function withdrawAsset(
        bytes calldata assetData,
        uint256 amount
    )
        external;


    function approveMakerAssetProxy(
        bytes calldata assetData
    )
        external;


    function marketSellOrdersWithEth(
        LibOrder.Order[] memory orders,
        bytes[] memory signatures,
        uint256[] memory ethFeeAmounts,
        address payable[] memory feeRecipients
    )
        public
        payable
        returns (
            uint256 wethSpentAmount,
            uint256 makerAssetAcquiredAmount
        );


    function marketBuyOrdersWithEth(
        LibOrder.Order[] memory orders,
        uint256 makerAssetBuyAmount,
        bytes[] memory signatures,
        uint256[] memory ethFeeAmounts,
        address payable[] memory feeRecipients
    )
        public
        payable
        returns (
            uint256 wethSpentAmount,
            uint256 makerAssetAcquiredAmount
        );

}

contract Forwarder is
    IForwarder,
    Ownable,
    MixinWethUtils,
    MixinExchangeWrapper,
    MixinReceiver
{

    using LibBytes for bytes;
    using LibAssetDataTransfer for bytes;
    using LibSafeMath for uint256;

    constructor (
        address _exchange,
        address _exchangeV2,
        address _weth
    )
        public
        Ownable()
        MixinWethUtils(
            _exchange,
            _weth
        )
        MixinExchangeWrapper(
            _exchange,
            _exchangeV2
        )
    {} // solhint-disable-line no-empty-blocks

    function withdrawAsset(
        bytes calldata assetData,
        uint256 amount
    )
        external
        onlyOwner
    {

        assetData.transferOut(amount);
    }

    function approveMakerAssetProxy(bytes calldata assetData)
        external
    {

        bytes4 proxyId = assetData.readBytes4(0);
        bytes4 erc20ProxyId = IAssetData(address(0)).ERC20Token.selector;

        if (proxyId == erc20ProxyId) {
            address proxyAddress = EXCHANGE.getAssetProxy(erc20ProxyId);
            if (proxyAddress == address(0)) {
                LibRichErrors.rrevert(LibForwarderRichErrors.UnregisteredAssetProxyError());
            }
            address token = assetData.readAddress(16);
            LibERC20Token.approve(token, proxyAddress, MAX_UINT256);
        }
    }

    function marketSellOrdersWithEth(
        LibOrder.Order[] memory orders,
        bytes[] memory signatures,
        uint256[] memory ethFeeAmounts,
        address payable[] memory feeRecipients
    )
        public
        payable
        returns (
            uint256 wethSpentAmount,
            uint256 makerAssetAcquiredAmount
        )
    {

        uint256 wethRemaining = _transferEthFeesAndWrapRemaining(
            ethFeeAmounts,
            feeRecipients
        );
        (
            wethSpentAmount,
            makerAssetAcquiredAmount
        ) = _marketSellNoThrow(
            orders,
            wethRemaining,
            signatures
        );

        if (wethSpentAmount > wethRemaining) {
            LibRichErrors.rrevert(LibForwarderRichErrors.OverspentWethError(
                wethSpentAmount,
                msg.value
            ));
        }

        wethRemaining = wethRemaining.safeSub(wethSpentAmount);

        _unwrapAndTransferEth(wethRemaining);
    }

    function marketSellAmountWithEth(
        LibOrder.Order[] memory orders,
        uint256 ethSellAmount,
        bytes[] memory signatures,
        uint256[] memory ethFeeAmounts,
        address payable[] memory feeRecipients
    )
        public
        payable
        returns (
            uint256 wethSpentAmount,
            uint256 makerAssetAcquiredAmount
        )
    {

        if (ethSellAmount > msg.value) {
            LibRichErrors.rrevert(LibForwarderRichErrors.CompleteSellFailedError(
                ethSellAmount,
                msg.value
            ));
        }
        uint256 wethRemaining = _transferEthFeesAndWrapRemaining(
            ethFeeAmounts,
            feeRecipients
        );
        if (wethRemaining < ethSellAmount) {
            LibRichErrors.rrevert(LibForwarderRichErrors.OverspentWethError(
                wethRemaining,
                ethSellAmount
            ));
        }
        (
            wethSpentAmount,
            makerAssetAcquiredAmount
        ) = _marketSellExactAmountNoThrow(
            orders,
            ethSellAmount,
            signatures
        );
        if (wethSpentAmount < ethSellAmount) {
            LibRichErrors.rrevert(LibForwarderRichErrors.CompleteSellFailedError(
                ethSellAmount,
                wethSpentAmount
            ));
        }

        wethRemaining = wethRemaining.safeSub(wethSpentAmount);

        _unwrapAndTransferEth(wethRemaining);
    }

    function marketBuyOrdersWithEth(
        LibOrder.Order[] memory orders,
        uint256 makerAssetBuyAmount,
        bytes[] memory signatures,
        uint256[] memory ethFeeAmounts,
        address payable[] memory feeRecipients
    )
        public
        payable
        returns (
            uint256 wethSpentAmount,
            uint256 makerAssetAcquiredAmount
        )
    {

        uint256 wethRemaining = _transferEthFeesAndWrapRemaining(
            ethFeeAmounts,
            feeRecipients
        );

        (
            wethSpentAmount,
            makerAssetAcquiredAmount
        ) = _marketBuyFillOrKill(
            orders,
            makerAssetBuyAmount,
            signatures
        );

        if (wethSpentAmount > wethRemaining) {
            LibRichErrors.rrevert(LibForwarderRichErrors.OverspentWethError(
                wethSpentAmount,
                msg.value
            ));
        }

        wethRemaining = wethRemaining.safeSub(wethSpentAmount);

        _unwrapAndTransferEth(wethRemaining);
    }
}