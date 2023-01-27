
pragma solidity ^0.5.9;
pragma experimental ABIEncoderV2;




interface IUniswapExchange {


    function ethToTokenTransferInput(
        uint256 minTokensBought,
        uint256 deadline,
        address recipient
    )
        external
        payable
        returns (uint256 tokensBought);


    function tokenToEthSwapInput(
        uint256 tokensSold,
        uint256 minEthBought,
        uint256 deadline
    )
        external
        returns (uint256 ethBought);


    function tokenToTokenTransferInput(
        uint256 tokensSold,
        uint256 minTokensBought,
        uint256 minEthBought,
        uint256 deadline,
        address recipient,
        address toTokenAddress
    )
        external
        returns (uint256 tokensBought);

}

interface IUniswapExchangeFactory {


    function getExchange(address tokenAddress)
        external
        view
        returns (address);

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


contract DeploymentConstants {

    address constant private WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant private KYBER_NETWORK_PROXY_ADDRESS = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    address constant private UNISWAP_EXCHANGE_FACTORY_ADDRESS = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address constant private UNISWAP_V2_ROUTER_01_ADDRESS = 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a;
    address constant private ETH2DAI_ADDRESS = 0x794e6e91555438aFc3ccF1c5076A74F42133d08D;
    address constant private ERC20_BRIDGE_PROXY_ADDRESS = 0x8ED95d1746bf1E4dAb58d8ED4724f1Ef95B20Db0;
    address constant private DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant private CHAI_ADDRESS = 0x06AF07097C9Eeb7fD685c692751D5C66dB49c215;
    address constant private DEV_UTILS_ADDRESS = 0x74134CF88b21383713E096a5ecF59e297dc7f547;
    address constant internal KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant private DYDX_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address constant private GST_ADDRESS = 0x0000000000b3F879cb30FE243b4Dfee438691c04;
    address constant private GST_COLLECTOR_ADDRESS = 0x000000D3b08566BE75A6DB803C03C85C0c1c5B96;

    function _getKyberNetworkProxyAddress()
        internal
        view
        returns (address kyberAddress)
    {

        return KYBER_NETWORK_PROXY_ADDRESS;
    }

    function _getWethAddress()
        internal
        view
        returns (address wethAddress)
    {

        return WETH_ADDRESS;
    }

    function _getUniswapExchangeFactoryAddress()
        internal
        view
        returns (address uniswapAddress)
    {

        return UNISWAP_EXCHANGE_FACTORY_ADDRESS;
    }

    function _getUniswapV2Router01Address()
        internal
        view
        returns (address uniswapRouterAddress)
    {

        return UNISWAP_V2_ROUTER_01_ADDRESS;
    }

    function _getEth2DaiAddress()
        internal
        view
        returns (address eth2daiAddress)
    {

        return ETH2DAI_ADDRESS;
    }

    function _getERC20BridgeProxyAddress()
        internal
        view
        returns (address erc20BridgeProxyAddress)
    {

        return ERC20_BRIDGE_PROXY_ADDRESS;
    }

    function _getDaiAddress()
        internal
        view
        returns (address daiAddress)
    {

        return DAI_ADDRESS;
    }

    function _getChaiAddress()
        internal
        view
        returns (address chaiAddress)
    {

        return CHAI_ADDRESS;
    }

    function _getDevUtilsAddress()
        internal
        view
        returns (address devUtils)
    {

        return DEV_UTILS_ADDRESS;
    }

    function _getDydxAddress()
        internal
        view
        returns (address dydxAddress)
    {

        return DYDX_ADDRESS;
    }

    function _getGstAddress()
        internal
        view
        returns (address gst)
    {

        return GST_ADDRESS;
    }

    function _getGstCollectorAddress()
        internal
        view
        returns (address collector)
    {

        return GST_COLLECTOR_ADDRESS;
    }
}


interface IDevUtils {


    function getOrderRelevantState(LibOrder.Order calldata order, bytes calldata signature)
        external
        view
        returns (
            LibOrder.OrderInfo memory orderInfo,
            uint256 fillableTakerAssetAmount,
            bool isValidSignature
        );

}


interface IERC20BridgeSampler {


    struct FakeBuyOptions {
        uint256 targetSlippageBps;
        uint256 maxIterations;
    }

    function batchCall(bytes[] calldata callDatas)
        external
        view
        returns (bytes[] memory callResults);


    function getOrderFillableTakerAssetAmounts(
        LibOrder.Order[] calldata orders,
        bytes[] calldata orderSignatures
    )
        external
        view
        returns (uint256[] memory orderFillableTakerAssetAmounts);


    function getOrderFillableMakerAssetAmounts(
        LibOrder.Order[] calldata orders,
        bytes[] calldata orderSignatures
    )
        external
        view
        returns (uint256[] memory orderFillableMakerAssetAmounts);


    function sampleSellsFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);


    function sampleBuysFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256[] calldata makerTokenAmounts,
        FakeBuyOptions calldata opts
    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);


    function sampleSellsFromEth2Dai(
        address takerToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);


    function sampleSellsFromUniswap(
        address takerToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);


    function sampleBuysFromUniswap(
        address takerToken,
        address makerToken,
        uint256[] calldata makerTokenAmounts
    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);


    function sampleBuysFromEth2Dai(
        address takerToken,
        address makerToken,
        uint256[] calldata makerTokenAmounts
    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);


    function sampleSellsFromCurve(
        address curveAddress,
        int128 fromTokenIdx,
        int128 toTokenIdx,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);


    function sampleBuysFromCurve(
        address curveAddress,
        int128 fromTokenIdx,
        int128 toTokenIdx,
        uint256[] calldata makerTokenAmounts
    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);


    function sampleSellsFromLiquidityProviderRegistry(
        address registryAddress,
        address takerToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);


    function sampleSellsFromMultiBridge(
        address multibridge,
        address takerToken,
        address intermediateToken,
        address makerToken,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);


    function sampleBuysFromLiquidityProviderRegistry(
        address registryAddress,
        address takerToken,
        address makerToken,
        uint256[] calldata makerTokenAmounts,
        FakeBuyOptions calldata opts

    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);


    function getLiquidityProviderFromRegistry(
        address registryAddress,
        address takerToken,
        address makerToken
    )
        external
        view
        returns (address providerAddress);


    function sampleSellsFromUniswapV2(
        address[] calldata path,
        uint256[] calldata takerTokenAmounts
    )
        external
        view
        returns (uint256[] memory makerTokenAmounts);


    function sampleBuysFromUniswapV2(
        address[] calldata path,
        uint256[] calldata makerTokenAmounts
    )
        external
        view
        returns (uint256[] memory takerTokenAmounts);

}


interface IEth2Dai {


    function getBuyAmount(
        address buyToken,
        address payToken,
        uint256 payAmount
    )
        external
        view
        returns (uint256 buyAmount);


    function getPayAmount(
        address payToken,
        address buyToken,
        uint256 buyAmount
    )
        external
        view
        returns (uint256 payAmount);

}


interface IKyberNetwork {


    function searchBestRate(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        bool usePermissionless
    )
        external
        view
        returns (address reserve, uint256 expectedRate);

}


interface IKyberNetworkProxy {


    function kyberNetworkContract() external view returns (address);


    function getExpectedRate(
        address fromToken,
        address toToken,
        uint256 fromAmount
    )
        external
        view
        returns (uint256 expectedRate, uint256 slippageRate);

}


interface IUniswapExchangeQuotes {


    function getEthToTokenInputPrice(
        uint256 ethSold
    )
        external
        view
        returns (uint256 tokensBought);


    function getEthToTokenOutputPrice(
        uint256 tokensBought
    )
        external
        view
        returns (uint256 ethSold);


    function getTokenToEthInputPrice(
        uint256 tokensSold
    )
        external
        view
        returns (uint256 ethBought);


    function getTokenToEthOutputPrice(
        uint256 ethBought
    )
        external
        view
        returns (uint256 tokensSold);

}


interface ICurve {


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 sellAmount,
        uint256 minBuyAmount,
        uint256 deadline
    )
        external;


    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 sellAmount,
        uint256 minBuyAmount
    )
        external;


    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 sellAmount
    )
        external
        returns (uint256 dy);


    function get_dx_underlying(
        int128 i,
        int128 j,
        uint256 buyAmount
    )
        external
        returns (uint256 dx);


    function underlying_coins(
        int128 i
    )
        external
        returns (address tokenAddress);

}


interface ILiquidityProvider {


    function bridgeTransferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 amount,
        bytes calldata bridgeData
    )
        external
        returns (bytes4 success);


    function getSellQuote(
        address takerToken,
        address makerToken,
        uint256 sellAmount
    )
        external
        view
        returns (uint256 makerTokenAmount);


    function getBuyQuote(
        address takerToken,
        address makerToken,
        uint256 buyAmount
    )
        external
        view
        returns (uint256 takerTokenAmount);

}


interface ILiquidityProviderRegistry {


    function getLiquidityProviderForMarket(
        address takerToken,
        address makerToken
    )
        external
        view
        returns (address providerAddress);

}


interface IUniswapV2Router01 {


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}


interface IMultiBridge {


    function bridgeTransferFrom(
        address tokenAddress,
        address from,
        address to,
        uint256 amount,
        bytes calldata bridgeData
    )
        external
        returns (bytes4 success);


    function getSellQuote(
        address takerToken,
        address intermediateToken,
        address makerToken,
        uint256 sellAmount
    )
        external
        view
        returns (uint256 makerTokenAmount);

}

contract ERC20BridgeSampler is
    IERC20BridgeSampler,
    DeploymentConstants
{

    uint256 constant internal DEV_UTILS_CALL_GAS = 500e3; // 500k
    uint256 constant internal KYBER_CALL_GAS = 1500e3; // 1.5m
    uint256 constant internal UNISWAP_CALL_GAS = 150e3; // 150k
    uint256 constant internal UNISWAPV2_CALL_GAS = 150e3; // 150k
    uint256 constant internal ETH2DAI_CALL_GAS = 1000e3; // 1m
    uint256 constant internal CURVE_CALL_GAS = 600e3; // 600k
    uint256 constant internal DEFAULT_CALL_GAS = 400e3; // 400k
    address constant internal KYBER_UNIWAP_RESERVE = 0x31E085Afd48a1d6e51Cc193153d625e8f0514C7F;
    address constant internal KYBER_ETH2DAI_RESERVE = 0x1E158c0e93c30d24e918Ef83d1e0bE23595C3c0f;

    address private _devUtilsAddress;

    constructor(address devUtilsAddress) public {
        _devUtilsAddress = devUtilsAddress;
    }

    function batchCall(bytes[] calldata callDatas)
        external
        view
        returns (bytes[] memory callResults)
    {

        callResults = new bytes[](callDatas.length);
        for (uint256 i = 0; i != callDatas.length; ++i) {
            (bool didSucceed, bytes memory resultData) = address(this).staticcall(callDatas[i]);
            if (!didSucceed) {
                assembly { revert(add(resultData, 0x20), mload(resultData)) }
            }
            callResults[i] = resultData;
        }
    }

    function getOrderFillableTakerAssetAmounts(
        LibOrder.Order[] memory orders,
        bytes[] memory orderSignatures
    )
        public
        view
        returns (uint256[] memory orderFillableTakerAssetAmounts)
    {

        orderFillableTakerAssetAmounts = new uint256[](orders.length);
        address devUtilsAddress = _devUtilsAddress;
        for (uint256 i = 0; i != orders.length; i++) {
            if (orderSignatures[i].length == 0 ||
                orders[i].makerAssetAmount == 0 ||
                orders[i].takerAssetAmount == 0) {
                orderFillableTakerAssetAmounts[i] = 0;
                continue;
            }
            (bool didSucceed, bytes memory resultData) =
                devUtilsAddress
                    .staticcall
                    .gas(DEV_UTILS_CALL_GAS)
                    (abi.encodeWithSelector(
                       IDevUtils(devUtilsAddress).getOrderRelevantState.selector,
                       orders[i],
                       orderSignatures[i]
                    ));
            if (!didSucceed) {
                orderFillableTakerAssetAmounts[i] = 0;
                continue;
            }
            (
                LibOrder.OrderInfo memory orderInfo,
                uint256 fillableTakerAssetAmount,
                bool isValidSignature
            ) = abi.decode(
                resultData,
                (LibOrder.OrderInfo, uint256, bool)
            );
            if (orderInfo.orderStatus != LibOrder.OrderStatus.FILLABLE ||
                !isValidSignature) {
                orderFillableTakerAssetAmounts[i] = 0;
            } else {
                orderFillableTakerAssetAmounts[i] = fillableTakerAssetAmount;
            }
        }
    }

    function getOrderFillableMakerAssetAmounts(
        LibOrder.Order[] memory orders,
        bytes[] memory orderSignatures
    )
        public
        view
        returns (uint256[] memory orderFillableMakerAssetAmounts)
    {

        orderFillableMakerAssetAmounts = getOrderFillableTakerAssetAmounts(
            orders,
            orderSignatures
        );
        for (uint256 i = 0; i < orders.length; ++i) {
            if (orderFillableMakerAssetAmounts[i] != 0) {
                orderFillableMakerAssetAmounts[i] = LibMath.getPartialAmountCeil(
                    orderFillableMakerAssetAmounts[i],
                    orders[i].takerAssetAmount,
                    orders[i].makerAssetAmount
                );
            }
        }
    }

    function sampleSellsFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {

        _assertValidPair(makerToken, takerToken);
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        address wethAddress = _getWethAddress();
        uint256 value;
        address reserve;
        for (uint256 i = 0; i < numSamples; i++) {
            if (takerToken == wethAddress || makerToken == wethAddress) {
                (value, reserve) = _sampleSellFromKyberNetwork(takerToken, makerToken, takerTokenAmounts[i]);
                if (reserve == KYBER_UNIWAP_RESERVE || reserve == KYBER_ETH2DAI_RESERVE) {
                    value = 0;
                }
            } else {
                (value, reserve) = _sampleSellFromKyberNetwork(takerToken, wethAddress, takerTokenAmounts[i]);
                if (value != 0) {
                    address otherReserve;
                    (value, otherReserve) = _sampleSellFromKyberNetwork(wethAddress, makerToken, value);
                    if (reserve == KYBER_UNIWAP_RESERVE && reserve == otherReserve) {
                        value = 0;
                    }
                }
            }
            makerTokenAmounts[i] = value;
        }
    }

    function sampleBuysFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts,
        FakeBuyOptions memory opts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {

        return _sampleApproximateBuysFromSource(
            takerToken,
            makerToken,
            makerTokenAmounts,
            opts,
            this.sampleSellsFromKyberNetwork.selector,
            address(0) // PLP registry address
        );
    }

    function sampleSellsFromEth2Dai(
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {

        _assertValidPair(makerToken, takerToken);
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                _getEth2DaiAddress().staticcall.gas(ETH2DAI_CALL_GAS)(
                    abi.encodeWithSelector(
                        IEth2Dai(0).getBuyAmount.selector,
                        makerToken,
                        takerToken,
                        takerTokenAmounts[i]
                    ));
            uint256 buyAmount = 0;
            if (didSucceed) {
                buyAmount = abi.decode(resultData, (uint256));
            } else{
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    function sampleSellsFromEth2DaiHop(
        address takerToken,
        address makerToken,
        address intermediateToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {

        if (makerToken == intermediateToken || takerToken == intermediateToken) {
            return makerTokenAmounts;
        }
        uint256[] memory intermediateAmounts = sampleSellsFromEth2Dai(takerToken, intermediateToken, takerTokenAmounts);
        makerTokenAmounts = sampleSellsFromEth2Dai(intermediateToken, makerToken, intermediateAmounts);
    }

    function sampleBuysFromEth2Dai(
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {

        _assertValidPair(makerToken, takerToken);
        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                _getEth2DaiAddress().staticcall.gas(ETH2DAI_CALL_GAS)(
                    abi.encodeWithSelector(
                        IEth2Dai(0).getPayAmount.selector,
                        takerToken,
                        makerToken,
                        makerTokenAmounts[i]
                    ));
            uint256 sellAmount = 0;
            if (didSucceed) {
                sellAmount = abi.decode(resultData, (uint256));
            } else {
                break;
            }
            takerTokenAmounts[i] = sellAmount;
        }
    }

    function sampleSellsFromUniswap(
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {

        _assertValidPair(makerToken, takerToken);
        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        IUniswapExchangeQuotes takerTokenExchange = takerToken == _getWethAddress() ?
            IUniswapExchangeQuotes(0) : _getUniswapExchange(takerToken);
        IUniswapExchangeQuotes makerTokenExchange = makerToken == _getWethAddress() ?
            IUniswapExchangeQuotes(0) : _getUniswapExchange(makerToken);
        for (uint256 i = 0; i < numSamples; i++) {
            bool didSucceed = true;
            if (makerToken == _getWethAddress()) {
                (makerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                    address(takerTokenExchange),
                    takerTokenExchange.getTokenToEthInputPrice.selector,
                    takerTokenAmounts[i]
                );
            } else if (takerToken == _getWethAddress()) {
                (makerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                    address(makerTokenExchange),
                    makerTokenExchange.getEthToTokenInputPrice.selector,
                    takerTokenAmounts[i]
                );
            } else {
                uint256 ethBought;
                (ethBought, didSucceed) = _callUniswapExchangePriceFunction(
                    address(takerTokenExchange),
                    takerTokenExchange.getTokenToEthInputPrice.selector,
                    takerTokenAmounts[i]
                );
                if (ethBought != 0) {
                    (makerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                        address(makerTokenExchange),
                        makerTokenExchange.getEthToTokenInputPrice.selector,
                        ethBought
                    );
                } else {
                    makerTokenAmounts[i] = 0;
                }
            }
            if (!didSucceed) {
                break;
            }
        }
    }

    function sampleBuysFromUniswap(
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {

        _assertValidPair(makerToken, takerToken);
        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        IUniswapExchangeQuotes takerTokenExchange = takerToken == _getWethAddress() ?
            IUniswapExchangeQuotes(0) : _getUniswapExchange(takerToken);
        IUniswapExchangeQuotes makerTokenExchange = makerToken == _getWethAddress() ?
            IUniswapExchangeQuotes(0) : _getUniswapExchange(makerToken);
        for (uint256 i = 0; i < numSamples; i++) {
            bool didSucceed = true;
            if (makerToken == _getWethAddress()) {
                (takerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                    address(takerTokenExchange),
                    takerTokenExchange.getTokenToEthOutputPrice.selector,
                    makerTokenAmounts[i]
                );
            } else if (takerToken == _getWethAddress()) {
                (takerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                    address(makerTokenExchange),
                    makerTokenExchange.getEthToTokenOutputPrice.selector,
                    makerTokenAmounts[i]
                );
            } else {
                uint256 ethSold;
                (ethSold, didSucceed) = _callUniswapExchangePriceFunction(
                    address(makerTokenExchange),
                    makerTokenExchange.getEthToTokenOutputPrice.selector,
                    makerTokenAmounts[i]
                );
                if (ethSold != 0) {
                    (takerTokenAmounts[i], didSucceed) = _callUniswapExchangePriceFunction(
                        address(takerTokenExchange),
                        takerTokenExchange.getTokenToEthOutputPrice.selector,
                        ethSold
                    );
                } else {
                    takerTokenAmounts[i] = 0;
                }
            }
            if (!didSucceed) {
                break;
            }
        }
    }

    function sampleSellsFromCurve(
        address curveAddress,
        int128 fromTokenIdx,
        int128 toTokenIdx,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {

        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                curveAddress.staticcall.gas(CURVE_CALL_GAS)(
                    abi.encodeWithSelector(
                        ICurve(0).get_dy_underlying.selector,
                        fromTokenIdx,
                        toTokenIdx,
                        takerTokenAmounts[i]
                    ));
            uint256 buyAmount = 0;
            if (didSucceed) {
                buyAmount = abi.decode(resultData, (uint256));
            } else {
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    function sampleBuysFromCurve(
        address curveAddress,
        int128 fromTokenIdx,
        int128 toTokenIdx,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {

        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                curveAddress.staticcall.gas(CURVE_CALL_GAS)(
                    abi.encodeWithSelector(
                        ICurve(0).get_dx_underlying.selector,
                        fromTokenIdx,
                        toTokenIdx,
                        makerTokenAmounts[i]
                    ));
            uint256 sellAmount = 0;
            if (didSucceed) {
                sellAmount = abi.decode(resultData, (uint256));
            } else {
                break;
            }
            takerTokenAmounts[i] = sellAmount;
        }
    }

    function sampleSellsFromLiquidityProviderRegistry(
        address registryAddress,
        address takerToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {

        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);

        address providerAddress = getLiquidityProviderFromRegistry(
            registryAddress,
            takerToken,
            makerToken
        );
        if (providerAddress == address(0)) {
            return makerTokenAmounts;
        }

        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                providerAddress.staticcall.gas(DEFAULT_CALL_GAS)(
                    abi.encodeWithSelector(
                        ILiquidityProvider(0).getSellQuote.selector,
                        takerToken,
                        makerToken,
                        takerTokenAmounts[i]
                    ));
            uint256 buyAmount = 0;
            if (didSucceed) {
                buyAmount = abi.decode(resultData, (uint256));
            } else {
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    function sampleSellsFromMultiBridge(
        address multibridge,
        address takerToken,
        address intermediateToken,
        address makerToken,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {

        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);

        if (multibridge == address(0)) {
            return makerTokenAmounts;
        }

        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                multibridge.staticcall.gas(DEFAULT_CALL_GAS)(
                    abi.encodeWithSelector(
                        IMultiBridge(0).getSellQuote.selector,
                        takerToken,
                        intermediateToken,
                        makerToken,
                        takerTokenAmounts[i]
                    ));
            uint256 buyAmount = 0;
            if (didSucceed) {
                buyAmount = abi.decode(resultData, (uint256));
            } else {
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    function sampleBuysFromLiquidityProviderRegistry(
        address registryAddress,
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts,
        FakeBuyOptions memory opts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {

        return _sampleApproximateBuysFromSource(
            takerToken,
            makerToken,
            makerTokenAmounts,
            opts,
            this.sampleSellsFromLiquidityProviderRegistry.selector,
            registryAddress
        );
    }

    function getLiquidityProviderFromRegistry(
        address registryAddress,
        address takerToken,
        address makerToken
    )
        public
        view
        returns (address providerAddress)
    {

        bytes memory callData = abi.encodeWithSelector(
            ILiquidityProviderRegistry(0).getLiquidityProviderForMarket.selector,
            takerToken,
            makerToken
        );
        (bool didSucceed, bytes memory returnData) = registryAddress.staticcall(callData);
        if (didSucceed && returnData.length == 32) {
            return LibBytes.readAddress(returnData, 12);
        }
    }

    function sampleSellsFromUniswapV2(
        address[] memory path,
        uint256[] memory takerTokenAmounts
    )
        public
        view
        returns (uint256[] memory makerTokenAmounts)
    {

        uint256 numSamples = takerTokenAmounts.length;
        makerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                _getUniswapV2Router01Address().staticcall.gas(UNISWAPV2_CALL_GAS)(
                    abi.encodeWithSelector(
                        IUniswapV2Router01(0).getAmountsOut.selector,
                        takerTokenAmounts[i],
                        path
                    ));
            uint256 buyAmount = 0;
            if (didSucceed) {
                buyAmount = abi.decode(resultData, (uint256[]))[path.length - 1];
            } else {
                break;
            }
            makerTokenAmounts[i] = buyAmount;
        }
    }

    function sampleBuysFromUniswapV2(
        address[] memory path,
        uint256[] memory makerTokenAmounts
    )
        public
        view
        returns (uint256[] memory takerTokenAmounts)
    {

        uint256 numSamples = makerTokenAmounts.length;
        takerTokenAmounts = new uint256[](numSamples);
        for (uint256 i = 0; i < numSamples; i++) {
            (bool didSucceed, bytes memory resultData) =
                _getUniswapV2Router01Address().staticcall.gas(UNISWAPV2_CALL_GAS)(
                    abi.encodeWithSelector(
                        IUniswapV2Router01(0).getAmountsIn.selector,
                        makerTokenAmounts[i],
                        path
                    ));
            uint256 sellAmount = 0;
            if (didSucceed) {
                sellAmount = abi.decode(resultData, (uint256[]))[0];
            } else {
                break;
            }
            takerTokenAmounts[i] = sellAmount;
        }
    }

    function _getTokenDecimals(address tokenAddress)
        internal
        view
        returns (uint8 decimals)
    {

        return LibERC20Token.decimals(tokenAddress);
    }

    function _callUniswapExchangePriceFunction(
        address uniswapExchangeAddress,
        bytes4 functionSelector,
        uint256 inputAmount
    )
        private
        view
        returns (uint256 outputAmount, bool didSucceed)
    {

        if (uniswapExchangeAddress == address(0)) {
            return (outputAmount, didSucceed);
        }
        bytes memory resultData;
        (didSucceed, resultData) =
            uniswapExchangeAddress.staticcall.gas(UNISWAP_CALL_GAS)(
                abi.encodeWithSelector(
                    functionSelector,
                    inputAmount
                ));
        if (didSucceed) {
            outputAmount = abi.decode(resultData, (uint256));
        }
    }

    function _getUniswapExchange(address tokenAddress)
        private
        view
        returns (IUniswapExchangeQuotes exchange)
    {

        exchange = IUniswapExchangeQuotes(
            address(IUniswapExchangeFactory(_getUniswapExchangeFactoryAddress())
            .getExchange(tokenAddress))
        );
    }

    function _assertValidPair(address makerToken, address takerToken)
        private
        pure
    {

        require(makerToken != takerToken, "ERC20BridgeSampler/INVALID_TOKEN_PAIR");
    }

    function _sampleSellForApproximateBuy(
        address takerToken,
        address makerToken,
        uint256 takerTokenAmount,
        bytes4 selector,
        address plpRegistryAddress
    )
        private
        view
        returns (uint256 makerTokenAmount)
    {

        bytes memory callData;
        uint256[] memory tmpTakerAmounts = new uint256[](1);
        tmpTakerAmounts[0] = takerTokenAmount;
        if (selector == this.sampleSellsFromKyberNetwork.selector) {
            callData = abi.encodeWithSelector(
                this.sampleSellsFromKyberNetwork.selector,
                takerToken,
                makerToken,
                tmpTakerAmounts
            );
        } else {
            callData = abi.encodeWithSelector(
                this.sampleSellsFromLiquidityProviderRegistry.selector,
                plpRegistryAddress,
                takerToken,
                makerToken,
                tmpTakerAmounts
            );
        }
        (bool success, bytes memory resultData) = address(this).staticcall(callData);
        if (!success) {
            return 0;
        }
        makerTokenAmount = abi.decode(resultData, (uint256[]))[0];
    }

    function _sampleApproximateBuysFromSource(
        address takerToken,
        address makerToken,
        uint256[] memory makerTokenAmounts,
        FakeBuyOptions memory opts,
        bytes4 selector,
        address plpRegistryAddress
    )
        private
        view
        returns (uint256[] memory takerTokenAmounts)
    {

        _assertValidPair(makerToken, takerToken);
        if (makerTokenAmounts.length == 0) {
            return takerTokenAmounts;
        }
        uint256 sellAmount;
        uint256 buyAmount;
        uint256 slippageFromTarget;
        takerTokenAmounts = new uint256[](makerTokenAmounts.length);
        sellAmount = _sampleSellForApproximateBuy(
            makerToken,
            takerToken,
            makerTokenAmounts[0],
            selector,
            plpRegistryAddress
        );

        if (sellAmount == 0) {
            return takerTokenAmounts;
        }

        buyAmount = _sampleSellForApproximateBuy(
            takerToken,
            makerToken,
            sellAmount,
            selector,
            plpRegistryAddress
        );
        if (buyAmount == 0) {
            return takerTokenAmounts;
        }

        for (uint256 i = 0; i < makerTokenAmounts.length; i++) {
            for (uint256 iter = 0; iter < opts.maxIterations; iter++) {
                sellAmount = LibMath.getPartialAmountCeil(
                    makerTokenAmounts[i],
                    buyAmount,
                    sellAmount
                );
                sellAmount = LibMath.getPartialAmountCeil(
                    (10000 + opts.targetSlippageBps),
                    10000,
                    sellAmount
                );
                uint256 _buyAmount = _sampleSellForApproximateBuy(
                    takerToken,
                    makerToken,
                    sellAmount,
                    selector,
                    plpRegistryAddress
                );
                if (_buyAmount == 0) {
                    break;
                }
                buyAmount = _buyAmount;
                if (buyAmount >= makerTokenAmounts[i]) {
                    uint256 slippageFromTarget = (buyAmount - makerTokenAmounts[i]) * 10000 /
                                                makerTokenAmounts[i];
                    if (slippageFromTarget <= opts.targetSlippageBps) {
                        break;
                    }
                }
            }
            takerTokenAmounts[i] = LibMath.getPartialAmountCeil(
                makerTokenAmounts[i],
                buyAmount,
                sellAmount
            );
        }
    }

    function _sampleSellFromKyberNetwork(
        address takerToken,
        address makerToken,
        uint256 takerTokenAmount
    )
        private
        view
        returns (uint256 makerTokenAmount, address reserve)
    {

        address _takerToken = takerToken == _getWethAddress() ? KYBER_ETH_ADDRESS : takerToken;
        address _makerToken = makerToken == _getWethAddress() ? KYBER_ETH_ADDRESS : makerToken;
        uint256 takerTokenDecimals = _getTokenDecimals(takerToken);
        uint256 makerTokenDecimals = _getTokenDecimals(makerToken);
        (bool didSucceed, bytes memory resultData) = _getKyberNetworkProxyAddress().staticcall.gas(DEFAULT_CALL_GAS)(
            abi.encodeWithSelector(
                IKyberNetworkProxy(0).kyberNetworkContract.selector
            ));
        if (!didSucceed) {
            return (0, address(0));
        }
        address kyberNetworkContract = abi.decode(resultData, (address));
        (didSucceed, resultData) =
            kyberNetworkContract.staticcall.gas(KYBER_CALL_GAS)(
                abi.encodeWithSelector(
                    IKyberNetwork(0).searchBestRate.selector,
                    _takerToken,
                    _makerToken,
                    takerTokenAmount,
                    false // usePermissionless
                ));
        uint256 rate = 0;
        address reserve;
        if (didSucceed) {
            (reserve, rate) = abi.decode(resultData, (address, uint256));
        } else {
            return (0, address(0));
        }
        makerTokenAmount =
            rate *
            takerTokenAmount *
            10 ** makerTokenDecimals /
            10 ** takerTokenDecimals /
            10 ** 18;

        return (makerTokenAmount, reserve);
    }
}