
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


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

contract DeploymentConstants {

    address constant private WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant private KYBER_NETWORK_PROXY_ADDRESS = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
    address constant private UNISWAP_EXCHANGE_FACTORY_ADDRESS = 0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95;
    address constant private ETH2DAI_ADDRESS = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e;
    address constant private ERC20_BRIDGE_PROXY_ADDRESS = 0x8ED95d1746bf1E4dAb58d8ED4724f1Ef95B20Db0;
    address constant private DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant private CHAI_ADDRESS = 0x06AF07097C9Eeb7fD685c692751D5C66dB49c215;
    address constant private DEV_UTILS_ADDRESS = 0xcCc2431a7335F21d9268bA62F0B32B0f2EFC463f;
    address constant internal KYBER_ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant private DYDX_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;

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


contract ERC20Token is
    IERC20Token
{

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    uint256 internal _totalSupply;

    function transfer(address _to, uint256 _value)
        external
        returns (bool)
    {

        require(
            balances[msg.sender] >= _value,
            "ERC20_INSUFFICIENT_BALANCE"
        );
        require(
            balances[_to] + _value >= balances[_to],
            "UINT256_OVERFLOW"
        );

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(
            msg.sender,
            _to,
            _value
        );

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        external
        returns (bool)
    {

        require(
            balances[_from] >= _value,
            "ERC20_INSUFFICIENT_BALANCE"
        );
        require(
            allowed[_from][msg.sender] >= _value,
            "ERC20_INSUFFICIENT_ALLOWANCE"
        );
        require(
            balances[_to] + _value >= balances[_to],
            "UINT256_OVERFLOW"
        );

        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;

        emit Transfer(
            _from,
            _to,
            _value
        );

        return true;
    }

    function approve(address _spender, uint256 _value)
        external
        returns (bool)
    {

        allowed[msg.sender][_spender] = _value;
        emit Approval(
            msg.sender,
            _spender,
            _value
        );
        return true;
    }

    function totalSupply()
        external
        view
        returns (uint256)
    {

        return _totalSupply;
    }

    function balanceOf(address _owner)
        external
        view
        returns (uint256)
    {

        return balances[_owner];
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256)
    {

        return allowed[_owner][_spender];
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


contract LendingPoolAddressesProvider {

    function getLendingPool() external returns (address);

}

contract LendingPool {

    function deposit(address reserve, uint256 amount, uint16 referralCode) external payable;

    function setUserUseReserveAsCollateral(address reserve, bool useAsCollateral) external;

    function borrow(address reserve, uint256 amount, uint256 interestRateMode, uint16 referralCode) external;

}
contract Comptroller {

    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);

}

contract CErc20 {

  function mint(uint) external returns (uint);

  function borrow(uint borrowAmount) external returns (uint);

}

contract CEth {

  function mint() external payable;

}

contract SwapSimulator is
    DeploymentConstants
{

    using LibSafeMath for uint256;

    address constant private PROTOCOL_FEE_COLLECTOR = 0xa26e80e7Dea86279c6d778D702Cc413E6CFfA777;

    address constant private COMPOUND_ETH = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
    address constant private COMPOUND_COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    address constant private AAVE_ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant private AAVE_ADDRESS_PROVIDER = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8;

    struct SwapResults {
        uint256 makerAssetAmountBefore;
        uint256 takerAssetAmountBefore;
        uint256 makerAssetAmountAfter;
        uint256 takerAssetAmountAfter;
        uint256 gasUsed;
        uint256 protocolFeePaid;
    }

    address public exchange;

    function () external payable {
    }

    function batchCall(bytes[] calldata callDatas)
        external
        payable
        returns (bytes[] memory callResults)
    {

        callResults = new bytes[](callDatas.length);
        for (uint256 i = 0; i != callDatas.length; ++i) {
            (bool didSucceed, bytes memory resultData) =
                address(this).call.value(address(this).balance)(callDatas[i]);
            if (!didSucceed) {
                _revertWithData(resultData);
            }
            callResults[i] = resultData;
        }
    }

    function supplyAndBorrowFromCompound(address payable cTokenContract, uint256 amount)
        public
        payable
    {

        CEth(COMPOUND_ETH).mint.value(address(this).balance/2)();
        address[] memory markets = new address[](2);
        markets[0] = COMPOUND_ETH;
        markets[1] = cTokenContract;
        uint256[] memory results = Comptroller(COMPOUND_COMPTROLLER).enterMarkets(markets);
        require(results[0] == 0 && results[1] == 0, "Enter Market Failed");
        (bool didSucceed, bytes memory resultData) =
            cTokenContract.call(abi.encodeWithSelector(CErc20(0).borrow.selector, amount));
        if (!didSucceed) {
            _revertWithData(resultData);
        }
    }

    function supplyAndBorrowFromAave(address payable tokenContract, uint256 amount)
        public
        payable
    {

        LendingPool lendingPool = LendingPool(LendingPoolAddressesProvider(AAVE_ADDRESS_PROVIDER).getLendingPool());
        lendingPool.deposit.value(address(this).balance/2)(AAVE_ETH, address(this).balance/2, 0);
        lendingPool.setUserUseReserveAsCollateral(AAVE_ETH, true);
        lendingPool.borrow(tokenContract, amount, 2, 0);
    }

    function collectTakerToken(address takerToken)
        public
    {

        LibERC20Token.transferFrom(
            takerToken,
            msg.sender,
            address(this),
            ERC20Token(takerToken).balanceOf(msg.sender)
        );
    }

    function getTokenBalance(address token)
        public
        view
        returns (uint256 balance)
    {

        if (token == address(0)) {
            balance = address(this).balance;
        } else {
            balance = ERC20Token(token).balanceOf(address(this));
        }
    }

    function executeSwap(
        address spender,
        address makerToken,
        address takerToken,
        address payable target,
        bytes memory txData
    )
        public
        payable
        returns (SwapResults memory results)
    {

        (results,) = _swap(
            spender,
            makerToken,
            takerToken,
            target,
            txData
        );
    }

    function _swap(
        address spender,
        address makerToken,
        address takerToken,
        address payable target,
        bytes memory txData
    )
        private
        returns (SwapResults memory results, bytes memory callResult)
    {

        results.makerAssetAmountBefore = getTokenBalance(makerToken);
        results.takerAssetAmountBefore = getTokenBalance(takerToken);
        if (takerToken != address(0)) {
            LibERC20Token.approve(takerToken, spender, uint256(-1));
        }
        uint256 protocolFeeBalanceBefore = _protocolFeeCollectorBalance();
        (results.gasUsed, callResult) = _callSwapper(target, txData);
        results.protocolFeePaid = _protocolFeeCollectorBalance() - protocolFeeBalanceBefore;
        _unwrapWETH();
        results.makerAssetAmountAfter = getTokenBalance(makerToken);
        results.takerAssetAmountAfter = getTokenBalance(takerToken);
    }

    function _unwrapWETH()
        private
    {

        uint256 wethBalance =
            IEtherToken(_getWethAddress()).balanceOf(address(this));
        if (wethBalance != 0) {
            IEtherToken(_getWethAddress()).withdraw(wethBalance);
        }
    }

    function _protocolFeeCollectorBalance()
        private
        view
        returns (uint256 balance)
    {

        balance = IEtherToken(_getWethAddress()).balanceOf(PROTOCOL_FEE_COLLECTOR);
        balance += PROTOCOL_FEE_COLLECTOR.balance;
        return balance;
    }

    function _revertWithData(bytes memory data)
        private
        pure
    {

        assembly { revert(add(data, 0x20), mload(data)) }
    }

    function _callSwapper(address target, bytes memory txData)
        private
        returns (uint256 gasUsed, bytes memory resultData)
    {

        bool success;
        gasUsed = gasleft();
        (success, resultData) = target.call.value(address(this).balance)(txData);
        gasUsed = gasUsed - gasleft();
        if (!success) {
            _revertWithData(resultData);
        }
    }
}