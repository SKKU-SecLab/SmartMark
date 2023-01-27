
pragma solidity ^0.5.5;
pragma experimental ABIEncoderV2;

contract SafeMath {


    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(
            c / a == b,
            "UINT256_OVERFLOW"
        );
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        require(
            b <= a,
            "UINT256_UNDERFLOW"
        );
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {

        uint256 c = a + b;
        require(
            c >= a,
            "UINT256_OVERFLOW"
        );
        return c;
    }

    function max64(uint64 a, uint64 b)
        internal
        pure
        returns (uint256)
    {

        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b)
        internal
        pure
        returns (uint256)
    {

        return a < b ? a : b;
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

contract LibMath is
    SafeMath
{

    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256 partialAmount)
    {

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorFloor(
                numerator,
                denominator,
                target
            ),
            "ROUNDING_ERROR"
        );
        
        partialAmount = safeDiv(
            safeMul(numerator, target),
            denominator
        );
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

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorCeil(
                numerator,
                denominator,
                target
            ),
            "ROUNDING_ERROR"
        );
        
        partialAmount = safeDiv(
            safeAdd(
                safeMul(numerator, target),
                safeSub(denominator, 1)
            ),
            denominator
        );
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

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = safeDiv(
            safeMul(numerator, target),
            denominator
        );
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

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = safeDiv(
            safeAdd(
                safeMul(numerator, target),
                safeSub(denominator, 1)
            ),
            denominator
        );
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

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );
        
        if (target == 0 || numerator == 0) {
            return false;
        }
        
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = safeMul(1000, remainder) >= safeMul(numerator, target);
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

        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );
        
        if (target == 0 || numerator == 0) {
            return false;
        }
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = safeSub(denominator, remainder) % denominator;
        isError = safeMul(1000, remainder) >= safeMul(numerator, target);
        return isError;
    }
}


contract IExchangeCore {


    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        external;


    function fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);


    function cancelOrder(LibOrder.Order memory order)
        public;


    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo);

}

contract IMatchOrders {


    function matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);

}

contract ISignatureValidator {


    function preSign(
        bytes32 hash,
        address signerAddress,
        bytes calldata signature
    )
        external;

    
    function setSignatureValidatorApproval(
        address validatorAddress,
        bool approval
    )
        external;


    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);

}

contract ITransactions {


    function executeTransaction(
        uint256 salt,
        address signerAddress,
        bytes calldata data,
        bytes calldata signature
    )
        external;

}

contract IAssetProxyDispatcher {


    function registerAssetProxy(address assetProxy)
        external;


    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address);

}





contract LibFillResults is
    SafeMath
{

    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    struct MatchedFillResults {
        FillResults left;                    // Amounts filled and fees paid of left order.
        FillResults right;                   // Amounts filled and fees paid of right order.
        uint256 leftMakerAssetSpreadAmount;  // Spread between price of left and right order, denominated in the left order's makerAsset, paid to taker.
    }

    function addFillResults(FillResults memory totalFillResults, FillResults memory singleFillResults)
        internal
        pure
    {

        totalFillResults.makerAssetFilledAmount = safeAdd(totalFillResults.makerAssetFilledAmount, singleFillResults.makerAssetFilledAmount);
        totalFillResults.takerAssetFilledAmount = safeAdd(totalFillResults.takerAssetFilledAmount, singleFillResults.takerAssetFilledAmount);
        totalFillResults.makerFeePaid = safeAdd(totalFillResults.makerFeePaid, singleFillResults.makerFeePaid);
        totalFillResults.takerFeePaid = safeAdd(totalFillResults.takerFeePaid, singleFillResults.takerFeePaid);
    }
}


contract IWrapperFunctions {


    function fillOrKillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);


    function fillOrderNoThrow(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);


    function batchFillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);


    function batchFillOrKillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);


    function batchFillOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);


    function marketSellOrders(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);


    function marketSellOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);


    function marketBuyOrders(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);


    function marketBuyOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);


    function batchCancelOrders(LibOrder.Order[] memory orders)
        public;


    function getOrdersInfo(LibOrder.Order[] memory orders)
        public
        view
        returns (LibOrder.OrderInfo[] memory);

}


contract IExchange is
    IExchangeCore,
    IMatchOrders,
    ISignatureValidator,
    ITransactions,
    IAssetProxyDispatcher,
    IWrapperFunctions
{}


contract LibAssetProxyIds {



    bytes4 constant public ERC20_PROXY_ID = 0xf47261b0;

    bytes4 constant public ERC721_PROXY_ID = 0x02571792;

    bytes4 constant public ERC1155_PROXY_ID = 0xa7cb5fb7;

    bytes4 constant public MULTI_ASSET_PROXY_ID = 0x94cfcdd7;

    bytes4 constant public STATIC_CALL_PROXY_ID = 0xc339d10a;
}


contract LibAssetData is
    LibAssetProxyIds
{

    uint256 constant internal _MAX_UINT256 = uint256(-1);

    bytes4 constant internal _ERC20_BALANCE_OF_SELECTOR = 0x70a08231;
    bytes4 constant internal _ERC20_ALLOWANCE_SELECTOR = 0xdd62ed3e;

    bytes4 constant internal _ERC721_OWNER_OF_SELECTOR = 0x6352211e;
    bytes4 constant internal _ERC721_IS_APPROVED_FOR_ALL_SELECTOR = 0xe985e9c5;
    bytes4 constant internal _ERC721_GET_APPROVED_SELECTOR = 0x081812fc;

    bytes4 constant internal _ERC1155_BALANCE_OF_SELECTOR = 0x00fdd58e;
    bytes4 constant internal _ERC1155_IS_APPROVED_FOR_ALL_SELECTOR = 0xe985e9c5;

    bytes4 constant internal _ASSET_PROXY_TRANSFER_FROM_SELECTOR = 0xa85e59e4;

    using LibBytes for bytes;

    IExchange internal _EXCHANGE;
    address internal _ERC20_PROXY_ADDRESS;
    address internal _ERC721_PROXY_ADDRESS;
    address internal _ERC1155_PROXY_ADDRESS;
    address internal _STATIC_CALL_PROXY_ADDRESS;

    constructor (address _exchange)
        public
    {
        _EXCHANGE = IExchange(_exchange);
        _ERC20_PROXY_ADDRESS = _EXCHANGE.getAssetProxy(ERC20_PROXY_ID);
        _ERC721_PROXY_ADDRESS = _EXCHANGE.getAssetProxy(ERC721_PROXY_ID);
        _ERC1155_PROXY_ADDRESS = _EXCHANGE.getAssetProxy(ERC1155_PROXY_ID);
        _STATIC_CALL_PROXY_ADDRESS = _EXCHANGE.getAssetProxy(STATIC_CALL_PROXY_ID);
    }

    function getBalance(address ownerAddress, bytes memory assetData)
        public
        view
        returns (uint256 balance)
    {

        bytes4 assetProxyId = assetData.readBytes4(0);

        if (assetProxyId == ERC20_PROXY_ID) {
            address tokenAddress = assetData.readAddress(16);

            bytes memory balanceOfData = abi.encodeWithSelector(_ERC20_BALANCE_OF_SELECTOR, ownerAddress);

            (bool success, bytes memory returnData) = tokenAddress.staticcall(balanceOfData);
            balance = success && returnData.length == 32 ? returnData.readUint256(0) : 0;
        } else if (assetProxyId == ERC721_PROXY_ID) {
            (, address tokenAddress, uint256 tokenId) = decodeERC721AssetData(assetData);

            balance = getERC721TokenOwner(tokenAddress, tokenId) == ownerAddress ? 1 : 0;
        } else if (assetProxyId == ERC1155_PROXY_ID) {
            (, address tokenAddress, uint256[] memory tokenIds, uint256[] memory tokenValues,) = decodeERC1155AssetData(assetData);

            uint256 length = tokenIds.length;
            for (uint256 i = 0; i != length; i++) {
                bytes memory balanceOfData = abi.encodeWithSelector(
                    _ERC1155_BALANCE_OF_SELECTOR,
                    ownerAddress,
                    tokenIds[i]
                );

                (bool success, bytes memory returnData) = tokenAddress.staticcall(balanceOfData);
                uint256 totalBalance = success && returnData.length == 32 ? returnData.readUint256(0) : 0;

                uint256 scaledBalance = totalBalance / tokenValues[i];
                if (scaledBalance < balance || balance == 0) {
                    balance = scaledBalance;
                }
            }
        } else if (assetProxyId == STATIC_CALL_PROXY_ID) {
            bytes memory transferFromData = abi.encodeWithSelector(
                _ASSET_PROXY_TRANSFER_FROM_SELECTOR,
                assetData,
                address(0),  // `from` address is not used
                address(0),  // `to` address is not used
                0            // `amount` is not used
            );

            (bool success,) = _STATIC_CALL_PROXY_ADDRESS.staticcall(transferFromData);

            balance = success ? _MAX_UINT256 : 0;
        } else if (assetProxyId == MULTI_ASSET_PROXY_ID) {
            (, uint256[] memory assetAmounts, bytes[] memory nestedAssetData) = decodeMultiAssetData(assetData);

            uint256 length = nestedAssetData.length;
            for (uint256 i = 0; i != length; i++) {
                uint256 totalBalance = getBalance(ownerAddress, nestedAssetData[i]);

                uint256 scaledBalance = totalBalance / assetAmounts[i];
                if (scaledBalance < balance || balance == 0) {
                    balance = scaledBalance;
                }
            }
        } 

        return balance;
    }

    function getBatchBalances(address ownerAddress, bytes[] memory assetData)
        public
        view
        returns (uint256[] memory balances)
    {

        uint256 length = assetData.length;
        balances = new uint256[](length);
        for (uint256 i = 0; i != length; i++) {
            balances[i] = getBalance(ownerAddress, assetData[i]);
        }
        return balances;
    }

    function getAssetProxyAllowance(address ownerAddress, bytes memory assetData)
        public
        view
        returns (uint256 allowance)
    {

        bytes4 assetProxyId = assetData.readBytes4(0);

        if (assetProxyId == MULTI_ASSET_PROXY_ID) {
            (, uint256[] memory amounts, bytes[] memory nestedAssetData) = decodeMultiAssetData(assetData);

            uint256 length = nestedAssetData.length;
            for (uint256 i = 0; i != length; i++) {
                uint256 totalAllowance = getAssetProxyAllowance(ownerAddress, nestedAssetData[i]);

                uint256 scaledAllowance = totalAllowance / amounts[i];
                if (scaledAllowance < allowance || allowance == 0) {
                    allowance = scaledAllowance;
                }
            }
            return allowance;
        }

        if (assetProxyId == ERC20_PROXY_ID) {
            address tokenAddress = assetData.readAddress(16);

            bytes memory allowanceData = abi.encodeWithSelector(
                _ERC20_ALLOWANCE_SELECTOR,
                ownerAddress,
                _ERC20_PROXY_ADDRESS
            );

            (bool success, bytes memory returnData) = tokenAddress.staticcall(allowanceData);
            allowance = success && returnData.length == 32 ? returnData.readUint256(0) : 0;
        } else if (assetProxyId == ERC721_PROXY_ID) {
            (, address tokenAddress, uint256 tokenId) = decodeERC721AssetData(assetData);

            bytes memory isApprovedForAllData = abi.encodeWithSelector(
                _ERC721_IS_APPROVED_FOR_ALL_SELECTOR,
                ownerAddress,
                _ERC721_PROXY_ADDRESS
            );

            (bool success, bytes memory returnData) = tokenAddress.staticcall(isApprovedForAllData);

            if (!success || returnData.length != 32 || returnData.readUint256(0) != 1) {
                bytes memory getApprovedData = abi.encodeWithSelector(_ERC721_GET_APPROVED_SELECTOR, tokenId);
                (success, returnData) = tokenAddress.staticcall(getApprovedData);

                allowance = success && returnData.length == 32 && returnData.readAddress(12) == _ERC721_PROXY_ADDRESS ? 1 : 0;
            } else {
                allowance = _MAX_UINT256;
            }
        } else if (assetProxyId == ERC1155_PROXY_ID) {
            (, address tokenAddress, , , ) = decodeERC1155AssetData(assetData);

            bytes memory isApprovedForAllData = abi.encodeWithSelector(
                _ERC1155_IS_APPROVED_FOR_ALL_SELECTOR,
                ownerAddress,
                _ERC1155_PROXY_ADDRESS
            );

            (bool success, bytes memory returnData) = tokenAddress.staticcall(isApprovedForAllData);
            allowance = success && returnData.length == 32 && returnData.readUint256(0) == 1 ? _MAX_UINT256 : 0;
        } else if (assetProxyId == STATIC_CALL_PROXY_ID) {
            allowance = _MAX_UINT256;
        }

        return allowance;
    }

    function getBatchAssetProxyAllowances(address ownerAddress, bytes[] memory assetData)
        public
        view
        returns (uint256[] memory allowances)
    {

        uint256 length = assetData.length;
        allowances = new uint256[](length);
        for (uint256 i = 0; i != length; i++) {
            allowances[i] = getAssetProxyAllowance(ownerAddress, assetData[i]);
        }
        return allowances;
    }

    function getBalanceAndAssetProxyAllowance(address ownerAddress, bytes memory assetData)
        public
        view
        returns (uint256 balance, uint256 allowance)
    {

        balance = getBalance(ownerAddress, assetData);
        allowance = getAssetProxyAllowance(ownerAddress, assetData);
        return (balance, allowance);
    }

    function getBatchBalancesAndAssetProxyAllowances(address ownerAddress, bytes[] memory assetData)
        public
        view
        returns (uint256[] memory balances, uint256[] memory allowances)
    {

        balances = getBatchBalances(ownerAddress, assetData);
        allowances = getBatchAssetProxyAllowances(ownerAddress, assetData);
        return (balances, allowances);
    }

    function encodeERC20AssetData(address tokenAddress)
        public
        pure
        returns (bytes memory assetData)
    {

        assetData = abi.encodeWithSelector(ERC20_PROXY_ID, tokenAddress);
        return assetData;
    }

    function decodeERC20AssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress
        )
    {

        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == ERC20_PROXY_ID,
            "WRONG_PROXY_ID"
        );

        tokenAddress = assetData.readAddress(16);
        return (assetProxyId, tokenAddress);
    }

    function encodeERC721AssetData(address tokenAddress, uint256 tokenId)
        public
        pure
        returns (bytes memory assetData)
    {

        assetData = abi.encodeWithSelector(
            ERC721_PROXY_ID,
            tokenAddress,
            tokenId
        );
        return assetData;
    }

    function decodeERC721AssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress,
            uint256 tokenId
        )
    {

        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == ERC721_PROXY_ID,
            "WRONG_PROXY_ID"
        );

        tokenAddress = assetData.readAddress(16);
        tokenId = assetData.readUint256(36);
        return (assetProxyId, tokenAddress, tokenId);
    }

    function encodeERC1155AssetData(
        address tokenAddress,
        uint256[] memory tokenIds,
        uint256[] memory tokenValues,
        bytes memory callbackData
    )
        public
        pure
        returns (bytes memory assetData)
    {

        assetData = abi.encodeWithSelector(
            ERC1155_PROXY_ID,
            tokenAddress,
            tokenIds,
            tokenValues,
            callbackData
        );
        return assetData;
    }

    function decodeERC1155AssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            address tokenAddress,
            uint256[] memory tokenIds,
            uint256[] memory tokenValues,
            bytes memory callbackData
        )
    {

        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == ERC1155_PROXY_ID,
            "WRONG_PROXY_ID"
        );

        assembly {
            assetData := add(assetData, 36)
            tokenAddress := mload(assetData)
            tokenIds := add(assetData, mload(add(assetData, 32)))
            tokenValues := add(assetData, mload(add(assetData, 64)))
            callbackData := add(assetData, mload(add(assetData, 96)))
        }

        return (
            assetProxyId,
            tokenAddress,
            tokenIds,
            tokenValues,
            callbackData
        );
    }

    function encodeMultiAssetData(uint256[] memory amounts, bytes[] memory nestedAssetData)
        public
        pure
        returns (bytes memory assetData)
    {

        assetData = abi.encodeWithSelector(
            MULTI_ASSET_PROXY_ID,
            amounts,
            nestedAssetData
        );
        return assetData;
    }

    function decodeMultiAssetData(bytes memory assetData)
        public
        pure
        returns (
            bytes4 assetProxyId,
            uint256[] memory amounts,
            bytes[] memory nestedAssetData
        )
    {

        assetProxyId = assetData.readBytes4(0);

        require(
            assetProxyId == MULTI_ASSET_PROXY_ID,
            "WRONG_PROXY_ID"
        );

        (amounts, nestedAssetData) = abi.decode(
            assetData.slice(4, assetData.length),
            (uint256[], bytes[])
        );
    }

    function getERC721TokenOwner(address tokenAddress, uint256 tokenId)
        public
        view
        returns (address ownerAddress)
    {

        bytes memory ownerOfCalldata = abi.encodeWithSelector(
            _ERC721_OWNER_OF_SELECTOR,
            tokenId
        );

        (bool success, bytes memory returnData) = tokenAddress.staticcall(ownerOfCalldata);

        ownerAddress = (success && returnData.length == 32) ? returnData.readAddress(12) : address(0);
        return ownerAddress;
    }
}


contract OrderValidationUtils is
    LibAssetData,
    LibMath
{

    using LibBytes for bytes;

    bytes internal _ZRX_ASSET_DATA;

    constructor (address _exchange, bytes memory _zrxAssetData)
        public
        LibAssetData(_exchange)
    {
        _ZRX_ASSET_DATA = _zrxAssetData;
    }

    function getOrderRelevantState(LibOrder.Order memory order, bytes memory signature)
        public
        view
        returns (
            LibOrder.OrderInfo memory orderInfo,
            uint256 fillableTakerAssetAmount,
            bool isValidSignature
        )
    {

        orderInfo = _EXCHANGE.getOrderInfo(order);

        address makerAddress = order.makerAddress;
        isValidSignature = _EXCHANGE.isValidSignature(
            orderInfo.orderHash,
            makerAddress,
            signature
        );

        uint256 transferableMakerAssetAmount = getTransferableAssetAmount(makerAddress, order.makerAssetData);

        uint256 takerAssetAmount = order.takerAssetAmount;
        uint256 makerFee = order.makerFee;
        bytes memory zrxAssetData = _ZRX_ASSET_DATA;
    
        uint256 transferableTakerAssetAmount;
        if (order.makerAssetData.equals(zrxAssetData)) {
            transferableTakerAssetAmount = getPartialAmountFloor(
                transferableMakerAssetAmount,
                safeAdd(order.makerAssetAmount, makerFee),
                takerAssetAmount
            );
        } else {
            uint256 transferableMakerFeeAssetAmount = getTransferableAssetAmount(makerAddress, zrxAssetData);

            if (makerFee == 0) {
                transferableTakerAssetAmount = getPartialAmountFloor(
                    transferableMakerAssetAmount,
                    order.makerAssetAmount,
                    takerAssetAmount
                );

            } else {
                uint256 transferableMakerToTakerAmount = getPartialAmountFloor(
                    transferableMakerAssetAmount,
                    order.makerAssetAmount,
                    takerAssetAmount
                );
                uint256 transferableMakerFeeToTakerAmount = getPartialAmountFloor(
                    transferableMakerFeeAssetAmount,
                    makerFee,
                    takerAssetAmount
                );
                transferableTakerAssetAmount = min256(transferableMakerToTakerAmount, transferableMakerFeeToTakerAmount);
            }
        }

        fillableTakerAssetAmount = min256(
            safeSub(takerAssetAmount, orderInfo.orderTakerAssetFilledAmount),
            transferableTakerAssetAmount
        );

        return (orderInfo, fillableTakerAssetAmount, isValidSignature);
    }

    function getOrderRelevantStates(LibOrder.Order[] memory orders, bytes[] memory signatures)
        public
        view
        returns (
            LibOrder.OrderInfo[] memory ordersInfo,
            uint256[] memory fillableTakerAssetAmounts,
            bool[] memory isValidSignature
        )
    {

        uint256 length = orders.length;
        ordersInfo = new LibOrder.OrderInfo[](length);
        fillableTakerAssetAmounts = new uint256[](length);
        isValidSignature = new bool[](length);

        for (uint256 i = 0; i != length; i++) {
            (ordersInfo[i], fillableTakerAssetAmounts[i], isValidSignature[i]) = getOrderRelevantState(
                orders[i],
                signatures[i]
            );
        }

        return (ordersInfo, fillableTakerAssetAmounts, isValidSignature);
    }

    function getTransferableAssetAmount(address ownerAddress, bytes memory assetData)
        public
        view
        returns (uint256 transferableAssetAmount)
    {

        (uint256 balance, uint256 allowance) = getBalanceAndAssetProxyAllowance(ownerAddress, assetData);
        transferableAssetAmount = min256(balance, allowance);
        return transferableAssetAmount;
    }
}

contract LibExchangeSelectors {


    bytes4 constant internal ALLOWED_VALIDATORS_SELECTOR = 0x7b8e3514;
    bytes4 constant internal ALLOWED_VALIDATORS_SELECTOR_GENERATOR = bytes4(keccak256("allowedValidators(address,address)"));

    bytes4 constant internal ASSET_PROXIES_SELECTOR = 0x3fd3c997;
    bytes4 constant internal ASSET_PROXIES_SELECTOR_GENERATOR = bytes4(keccak256("assetProxies(bytes4)"));

    bytes4 constant internal BATCH_CANCEL_ORDERS_SELECTOR = 0x4ac14782;
    bytes4 constant internal BATCH_CANCEL_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("batchCancelOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[])"));

    bytes4 constant internal BATCH_FILL_OR_KILL_ORDERS_SELECTOR = 0x4d0ae546;
    bytes4 constant internal BATCH_FILL_OR_KILL_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("batchFillOrKillOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256[],bytes[])"));

    bytes4 constant internal BATCH_FILL_ORDERS_SELECTOR = 0x297bb70b;
    bytes4 constant internal BATCH_FILL_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("batchFillOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256[],bytes[])"));

    bytes4 constant internal BATCH_FILL_ORDERS_NO_THROW_SELECTOR = 0x50dde190;
    bytes4 constant internal BATCH_FILL_ORDERS_NO_THROW_SELECTOR_GENERATOR = bytes4(keccak256("batchFillOrdersNoThrow((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256[],bytes[])"));

    bytes4 constant internal CANCEL_ORDER_SELECTOR = 0xd46b02c3;
    bytes4 constant internal CANCEL_ORDER_SELECTOR_GENERATOR = bytes4(keccak256("cancelOrder((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes))"));

    bytes4 constant internal CANCEL_ORDERS_UP_TO_SELECTOR = 0x4f9559b1;
    bytes4 constant internal CANCEL_ORDERS_UP_TO_SELECTOR_GENERATOR = bytes4(keccak256("cancelOrdersUpTo(uint256)"));

    bytes4 constant internal CANCELLED_SELECTOR = 0x2ac12622;
    bytes4 constant internal CANCELLED_SELECTOR_GENERATOR = bytes4(keccak256("cancelled(bytes32)"));

    bytes4 constant internal CURRENT_CONTEXT_ADDRESS_SELECTOR = 0xeea086ba;
    bytes4 constant internal CURRENT_CONTEXT_ADDRESS_SELECTOR_GENERATOR = bytes4(keccak256("currentContextAddress()"));

    bytes4 constant internal EXECUTE_TRANSACTION_SELECTOR = 0xbfc8bfce;
    bytes4 constant internal EXECUTE_TRANSACTION_SELECTOR_GENERATOR = bytes4(keccak256("executeTransaction(uint256,address,bytes,bytes)"));

    bytes4 constant internal FILL_OR_KILL_ORDER_SELECTOR = 0x64a3bc15;
    bytes4 constant internal FILL_OR_KILL_ORDER_SELECTOR_GENERATOR = bytes4(keccak256("fillOrKillOrder((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),uint256,bytes)"));

    bytes4 constant internal FILL_ORDER_SELECTOR = 0xb4be83d5;
    bytes4 constant internal FILL_ORDER_SELECTOR_GENERATOR = bytes4(keccak256("fillOrder((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),uint256,bytes)"));

    bytes4 constant internal FILL_ORDER_NO_THROW_SELECTOR = 0x3e228bae;
    bytes4 constant internal FILL_ORDER_NO_THROW_SELECTOR_GENERATOR = bytes4(keccak256("fillOrderNoThrow((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),uint256,bytes)"));

    bytes4 constant internal FILLED_SELECTOR = 0x288cdc91;
    bytes4 constant internal FILLED_SELECTOR_GENERATOR = bytes4(keccak256("filled(bytes32)"));

    bytes4 constant internal GET_ASSET_PROXY_SELECTOR = 0x60704108;
    bytes4 constant internal GET_ASSET_PROXY_SELECTOR_GENERATOR = bytes4(keccak256("getAssetProxy(bytes4)"));

    bytes4 constant internal GET_ORDER_INFO_SELECTOR = 0xc75e0a81;
    bytes4 constant internal GET_ORDER_INFO_SELECTOR_GENERATOR = bytes4(keccak256("getOrderInfo((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes))"));

    bytes4 constant internal GET_ORDERS_INFO_SELECTOR = 0x7e9d74dc;
    bytes4 constant internal GET_ORDERS_INFO_SELECTOR_GENERATOR = bytes4(keccak256("getOrdersInfo((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[])"));

    bytes4 constant internal IS_VALID_SIGNATURE_SELECTOR = 0x93634702;
    bytes4 constant internal IS_VALID_SIGNATURE_SELECTOR_GENERATOR = bytes4(keccak256("isValidSignature(bytes32,address,bytes)"));

    bytes4 constant internal MARKET_BUY_ORDERS_SELECTOR = 0xe5fa431b;
    bytes4 constant internal MARKET_BUY_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("marketBuyOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256,bytes[])"));

    bytes4 constant internal MARKET_BUY_ORDERS_NO_THROW_SELECTOR = 0xa3e20380;
    bytes4 constant internal MARKET_BUY_ORDERS_NO_THROW_SELECTOR_GENERATOR = bytes4(keccak256("marketBuyOrdersNoThrow((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256,bytes[])"));

    bytes4 constant internal MARKET_SELL_ORDERS_SELECTOR = 0x7e1d9808;
    bytes4 constant internal MARKET_SELL_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("marketSellOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256,bytes[])"));

    bytes4 constant internal MARKET_SELL_ORDERS_NO_THROW_SELECTOR = 0xdd1c7d18;
    bytes4 constant internal MARKET_SELL_ORDERS_NO_THROW_SELECTOR_GENERATOR = bytes4(keccak256("marketSellOrdersNoThrow((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256,bytes[])"));

    bytes4 constant internal MATCH_ORDERS_SELECTOR = 0x3c28d861;
    bytes4 constant internal MATCH_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("matchOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),(address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),bytes,bytes)"));

    bytes4 constant internal ORDER_EPOCH_SELECTOR = 0xd9bfa73e;
    bytes4 constant internal ORDER_EPOCH_SELECTOR_GENERATOR = bytes4(keccak256("orderEpoch(address,address)"));

    bytes4 constant internal OWNER_SELECTOR = 0x8da5cb5b;
    bytes4 constant internal OWNER_SELECTOR_GENERATOR = bytes4(keccak256("owner()"));

    bytes4 constant internal PRE_SIGN_SELECTOR = 0x3683ef8e;
    bytes4 constant internal PRE_SIGN_SELECTOR_GENERATOR = bytes4(keccak256("preSign(bytes32,address,bytes)"));

    bytes4 constant internal PRE_SIGNED_SELECTOR = 0x82c174d0;
    bytes4 constant internal PRE_SIGNED_SELECTOR_GENERATOR = bytes4(keccak256("preSigned(bytes32,address)"));

    bytes4 constant internal REGISTER_ASSET_PROXY_SELECTOR = 0xc585bb93;
    bytes4 constant internal REGISTER_ASSET_PROXY_SELECTOR_GENERATOR = bytes4(keccak256("registerAssetProxy(address)"));

    bytes4 constant internal SET_SIGNATURE_VALIDATOR_APPROVAL_SELECTOR = 0x77fcce68;
    bytes4 constant internal SET_SIGNATURE_VALIDATOR_APPROVAL_SELECTOR_GENERATOR = bytes4(keccak256("setSignatureValidatorApproval(address,bool)"));

    bytes4 constant internal TRANSACTIONS_SELECTOR = 0x642f2eaf;
    bytes4 constant internal TRANSACTIONS_SELECTOR_GENERATOR = bytes4(keccak256("transactions(bytes32)"));

    bytes4 constant internal TRANSFER_OWNERSHIP_SELECTOR = 0xf2fde38b;
    bytes4 constant internal TRANSFER_OWNERSHIP_SELECTOR_GENERATOR = bytes4(keccak256("transferOwnership(address)"));
}

contract LibEIP712 {


    string constant internal EIP191_HEADER = "\x19\x01";

    string constant internal EIP712_DOMAIN_NAME = "0x Protocol";

    string constant internal EIP712_DOMAIN_VERSION = "2";

    bytes32 constant internal EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "address verifyingContract",
        ")"
    ));

    bytes32 public EIP712_DOMAIN_HASH;

    constructor ()
        public
    {
        EIP712_DOMAIN_HASH = keccak256(abi.encodePacked(
            EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
            keccak256(bytes(EIP712_DOMAIN_NAME)),
            keccak256(bytes(EIP712_DOMAIN_VERSION)),
            uint256(address(this))
        ));
    }

    function hashEIP712Message(bytes32 hashStruct)
        internal
        view
        returns (bytes32 result)
    {

        bytes32 eip712DomainHash = EIP712_DOMAIN_HASH;


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


contract LibOrder is
    LibEIP712
{

    bytes32 constant internal EIP712_ORDER_SCHEMA_HASH = keccak256(abi.encodePacked(
        "Order(",
        "address makerAddress,",
        "address takerAddress,",
        "address feeRecipientAddress,",
        "address senderAddress,",
        "uint256 makerAssetAmount,",
        "uint256 takerAssetAmount,",
        "uint256 makerFee,",
        "uint256 takerFee,",
        "uint256 expirationTimeSeconds,",
        "uint256 salt,",
        "bytes makerAssetData,",
        "bytes takerAssetData",
        ")"
    ));

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
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.          
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.     
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
    }

    struct OrderInfo {
        uint8 orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 hash of the order (see LibOrder.getOrderHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }

    function getOrderHash(Order memory order)
        internal
        view
        returns (bytes32 orderHash)
    {

        orderHash = hashEIP712Message(hashOrder(order));
        return orderHash;
    }

    function hashOrder(Order memory order)
        internal
        pure
        returns (bytes32 result)
    {

        bytes32 schemaHash = EIP712_ORDER_SCHEMA_HASH;
        bytes32 makerAssetDataHash = keccak256(order.makerAssetData);
        bytes32 takerAssetDataHash = keccak256(order.takerAssetData);


        assembly {
            let pos1 := sub(order, 32)
            let pos2 := add(order, 320)
            let pos3 := add(order, 352)

            let temp1 := mload(pos1)
            let temp2 := mload(pos2)
            let temp3 := mload(pos3)
            
            mstore(pos1, schemaHash)
            mstore(pos2, makerAssetDataHash)
            mstore(pos3, takerAssetDataHash)
            result := keccak256(pos1, 416)
            
            mstore(pos1, temp1)
            mstore(pos2, temp2)
            mstore(pos3, temp3)
        }
        return result;
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
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
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
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
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
        require(
            b.length > 0,
            "GREATER_THAN_ZERO_LENGTH_REQUIRED"
        );

        result = b[b.length - 1];

        assembly {
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    function popLast20Bytes(bytes memory b)
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= 20,
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        result = readAddress(b, b.length - 20);

        assembly {
            let newLen := sub(mload(b), 20)
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
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

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
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

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
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

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
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

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
        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );

        index += 32;

        assembly {
            result := mload(add(b, index))
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    function readBytesWithLength(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes memory result)
    {
        uint256 nestedBytesLength = readUint256(b, index);
        index += 32;

        require(
            b.length >= index + nestedBytesLength,
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );
        
        assembly {
            result := add(b, index)
        }
        return result;
    }

    function writeBytesWithLength(
        bytes memory b,
        uint256 index,
        bytes memory input
    )
        internal
        pure
    {
        require(
            b.length >= index + 32 + input.length,  // 32 bytes to store length
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );

        memCopy(
            b.contentAddress() + index,
            input.rawAddress(), // includes length of <input>
            input.length + 32   // +32 bytes to store <input> length
        );
    }

    function deepCopyBytes(
        bytes memory dest,
        bytes memory source
    )
        internal
        pure
    {
        uint256 sourceLen = source.length;
        require(
            dest.length >= sourceLen,
            "GREATER_OR_EQUAL_TO_SOURCE_BYTES_LENGTH_REQUIRED"
        );
        memCopy(
            dest.contentAddress(),
            source.contentAddress(),
            sourceLen
        );
    }
}


contract LibTransactionDecoder is
    LibExchangeSelectors
{

    using LibBytes for bytes;

    function decodeZeroExTransactionData(bytes memory transactionData)
        public
        pure
        returns(
            string memory functionName,
            LibOrder.Order[] memory orders,
            uint256[] memory takerAssetFillAmounts,
            bytes[] memory signatures
        )
    {

        bytes4 functionSelector = transactionData.readBytes4(0);

        if (functionSelector == BATCH_CANCEL_ORDERS_SELECTOR) {
            functionName = "batchCancelOrders";
        } else if (functionSelector == BATCH_FILL_ORDERS_SELECTOR) {
            functionName = "batchFillOrders";
        } else if (functionSelector == BATCH_FILL_ORDERS_NO_THROW_SELECTOR) {
            functionName = "batchFillOrdersNoThrow";
        } else if (functionSelector == BATCH_FILL_OR_KILL_ORDERS_SELECTOR) {
            functionName = "batchFillOrKillOrders";
        } else if (functionSelector == CANCEL_ORDER_SELECTOR) {
            functionName = "cancelOrder";
        } else if (functionSelector == FILL_ORDER_SELECTOR) {
            functionName = "fillOrder";
        } else if (functionSelector == FILL_ORDER_NO_THROW_SELECTOR) {
            functionName = "fillOrderNoThrow";
        } else if (functionSelector == FILL_OR_KILL_ORDER_SELECTOR) {
            functionName = "fillOrKillOrder";
        } else if (functionSelector == MARKET_BUY_ORDERS_SELECTOR) {
            functionName = "marketBuyOrders";
        } else if (functionSelector == MARKET_BUY_ORDERS_NO_THROW_SELECTOR) {
            functionName = "marketBuyOrdersNoThrow";
        } else if (functionSelector == MARKET_SELL_ORDERS_SELECTOR) {
            functionName = "marketSellOrders";
        } else if (functionSelector == MARKET_SELL_ORDERS_NO_THROW_SELECTOR) {
            functionName = "marketSellOrdersNoThrow";
        } else if (functionSelector == MATCH_ORDERS_SELECTOR) {
            functionName = "matchOrders";
        } else if (
            functionSelector == CANCEL_ORDERS_UP_TO_SELECTOR ||
            functionSelector == EXECUTE_TRANSACTION_SELECTOR
        ) {
            revert("UNIMPLEMENTED");
        } else {
            revert("UNKNOWN_FUNCTION_SELECTOR");
        }

        if (functionSelector == BATCH_CANCEL_ORDERS_SELECTOR) {
            orders = abi.decode(transactionData.slice(4, transactionData.length), (LibOrder.Order[]));
            takerAssetFillAmounts = new uint256[](0);
            signatures = new bytes[](0);
        } else if (
            functionSelector == BATCH_FILL_OR_KILL_ORDERS_SELECTOR ||
            functionSelector == BATCH_FILL_ORDERS_NO_THROW_SELECTOR ||
            functionSelector == BATCH_FILL_ORDERS_SELECTOR
        ) {
            (orders, takerAssetFillAmounts, signatures) = _makeReturnValuesForBatchFill(transactionData);
        } else if (functionSelector == CANCEL_ORDER_SELECTOR) {
            orders = new LibOrder.Order[](1);
            orders[0] = abi.decode(transactionData.slice(4, transactionData.length), (LibOrder.Order));
            takerAssetFillAmounts = new uint256[](0);
            signatures = new bytes[](0);
        } else if (
            functionSelector == FILL_OR_KILL_ORDER_SELECTOR ||
            functionSelector == FILL_ORDER_SELECTOR ||
            functionSelector == FILL_ORDER_NO_THROW_SELECTOR
        ) {
            (orders, takerAssetFillAmounts, signatures) = _makeReturnValuesForSingleOrderFill(transactionData);
        } else if (
            functionSelector == MARKET_BUY_ORDERS_SELECTOR ||
            functionSelector == MARKET_BUY_ORDERS_NO_THROW_SELECTOR ||
            functionSelector == MARKET_SELL_ORDERS_SELECTOR ||
            functionSelector == MARKET_SELL_ORDERS_NO_THROW_SELECTOR
        ) {
            (orders, takerAssetFillAmounts, signatures) = _makeReturnValuesForMarketFill(transactionData);
        } else if (functionSelector == MATCH_ORDERS_SELECTOR) {
            (
                LibOrder.Order memory leftOrder,
                LibOrder.Order memory rightOrder,
                bytes memory leftSignature,
                bytes memory rightSignature
            ) = abi.decode(
                transactionData.slice(4, transactionData.length),
                (LibOrder.Order, LibOrder.Order, bytes, bytes)
            );

            orders = new LibOrder.Order[](2);
            orders[0] = leftOrder;
            orders[1] = rightOrder;

            takerAssetFillAmounts = new uint256[](2);
            takerAssetFillAmounts[0] = leftOrder.takerAssetAmount;
            takerAssetFillAmounts[1] = rightOrder.takerAssetAmount;

            signatures = new bytes[](2);
            signatures[0] = leftSignature;
            signatures[1] = rightSignature;
        }
    }

    function _makeReturnValuesForSingleOrderFill(bytes memory transactionData)
        private
        pure
        returns(
            LibOrder.Order[] memory orders,
            uint256[] memory takerAssetFillAmounts,
            bytes[] memory signatures
        )
    {

        orders = new LibOrder.Order[](1);
        takerAssetFillAmounts = new uint256[](1);
        signatures = new bytes[](1);
        (orders[0], takerAssetFillAmounts[0], signatures[0]) = abi.decode(
            transactionData.slice(4, transactionData.length),
            (LibOrder.Order, uint256, bytes)
        );
    }

    function _makeReturnValuesForBatchFill(bytes memory transactionData)
        private
        pure
        returns(
            LibOrder.Order[] memory orders,
            uint256[] memory takerAssetFillAmounts,
            bytes[] memory signatures
        )
    {

        (orders, takerAssetFillAmounts, signatures) = abi.decode(
            transactionData.slice(4, transactionData.length),
            (LibOrder.Order[], uint256[], bytes[])
        );
    }

    function _makeReturnValuesForMarketFill(bytes memory transactionData)
        private
        pure
        returns(
            LibOrder.Order[] memory orders,
            uint256[] memory takerAssetFillAmounts,
            bytes[] memory signatures
        )
    {

        takerAssetFillAmounts = new uint256[](1);
        (orders, takerAssetFillAmounts[0], signatures) = abi.decode(
            transactionData.slice(4, transactionData.length),
            (LibOrder.Order[], uint256, bytes[])
        );
    }
}

contract EthBalanceChecker {


    function getEthBalances(address[] memory addresses)
        public
        view
        returns (uint256[] memory)
    {

        uint256[] memory balances = new uint256[](addresses.length);
        for (uint256 i = 0; i != addresses.length; i++) {
            balances[i] = addresses[i].balance;
        }
        return balances;
    }

}

contract DevUtils is
    OrderValidationUtils,
    LibTransactionDecoder,
    EthBalanceChecker
{

    constructor (address _exchange, bytes memory _zrxAssetData)
        public
        OrderValidationUtils(_exchange, _zrxAssetData)
    {}
}