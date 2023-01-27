

pragma solidity >=0.7.2;
pragma experimental ABIEncoderV2;


library ProtocolAdapterTypes {

    enum OptionType {Invalid, Put, Call}

    enum PurchaseMethod {Invalid, Contract, ZeroEx}

    struct OptionTerms {
        address underlying;
        address strikeAsset;
        address collateralAsset;
        uint256 expiry;
        uint256 strikePrice;
        ProtocolAdapterTypes.OptionType optionType;
        address paymentToken;
    }

    struct ZeroExOrder {
        address exchangeAddress;
        address buyTokenAddress;
        address sellTokenAddress;
        address allowanceTarget;
        uint256 protocolFee;
        uint256 makerAssetAmount;
        uint256 takerAssetAmount;
        bytes swapData;
    }
}

interface IProtocolAdapter {

    event Purchased(
        address indexed caller,
        string indexed protocolName,
        address indexed underlying,
        uint256 amount,
        uint256 optionID
    );

    event Exercised(
        address indexed caller,
        address indexed options,
        uint256 indexed optionID,
        uint256 amount,
        uint256 exerciseProfit
    );

    function protocolName() external pure returns (string memory);


    function nonFungible() external pure returns (bool);


    function purchaseMethod()
        external
        pure
        returns (ProtocolAdapterTypes.PurchaseMethod);


    function optionsExist(ProtocolAdapterTypes.OptionTerms calldata optionTerms)
        external
        view
        returns (bool);


    function getOptionsAddress(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms
    ) external view returns (address);


    function premium(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        uint256 purchaseAmount
    ) external view returns (uint256 cost);


    function exerciseProfit(
        address options,
        uint256 optionID,
        uint256 amount
    ) external view returns (uint256 profit);


    function canExercise(
        address options,
        uint256 optionID,
        uint256 amount
    ) external view returns (bool);


    function purchase(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        uint256 amount,
        uint256 maxCost
    ) external payable returns (uint256 optionID);


    function exercise(
        address options,
        uint256 optionID,
        uint256 amount,
        address recipient
    ) external payable;


    function createShort(
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        uint256 amount
    ) external returns (uint256);


    function closeShort() external returns (uint256);

}

library ProtocolAdapter {

    function delegateOptionsExist(
        IProtocolAdapter adapter,
        ProtocolAdapterTypes.OptionTerms calldata optionTerms
    ) external view returns (bool) {

        (bool success, bytes memory result) =
            address(adapter).staticcall(
                abi.encodeWithSignature(
                    "optionsExist((address,address,address,uint256,uint256,uint8,address))",
                    optionTerms
                )
            );
        revertWhenFail(success, result);
        return abi.decode(result, (bool));
    }

    function delegateGetOptionsAddress(
        IProtocolAdapter adapter,
        ProtocolAdapterTypes.OptionTerms calldata optionTerms
    ) external view returns (address) {

        (bool success, bytes memory result) =
            address(adapter).staticcall(
                abi.encodeWithSignature(
                    "getOptionsAddress((address,address,address,uint256,uint256,uint8,address))",
                    optionTerms
                )
            );
        revertWhenFail(success, result);
        return abi.decode(result, (address));
    }

    function delegatePremium(
        IProtocolAdapter adapter,
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        uint256 purchaseAmount
    ) external view returns (uint256) {

        (bool success, bytes memory result) =
            address(adapter).staticcall(
                abi.encodeWithSignature(
                    "premium((address,address,address,uint256,uint256,uint8,address),uint256)",
                    optionTerms,
                    purchaseAmount
                )
            );
        revertWhenFail(success, result);
        return abi.decode(result, (uint256));
    }

    function delegateExerciseProfit(
        IProtocolAdapter adapter,
        address options,
        uint256 optionID,
        uint256 amount
    ) external view returns (uint256) {

        (bool success, bytes memory result) =
            address(adapter).staticcall(
                abi.encodeWithSignature(
                    "exerciseProfit(address,uint256,uint256)",
                    options,
                    optionID,
                    amount
                )
            );
        revertWhenFail(success, result);
        return abi.decode(result, (uint256));
    }

    function delegatePurchase(
        IProtocolAdapter adapter,
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        uint256 purchaseAmount,
        uint256 maxCost
    ) external returns (uint256) {

        (bool success, bytes memory result) =
            address(adapter).delegatecall(
                abi.encodeWithSignature(
                    "purchase((address,address,address,uint256,uint256,uint8,address),uint256,uint256)",
                    optionTerms,
                    purchaseAmount,
                    maxCost
                )
            );
        revertWhenFail(success, result);
        return abi.decode(result, (uint256));
    }

    function delegatePurchaseWithZeroEx(
        IProtocolAdapter adapter,
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        ProtocolAdapterTypes.ZeroExOrder calldata zeroExOrder
    ) external {

        (bool success, bytes memory result) =
            address(adapter).delegatecall(
                abi.encodeWithSignature(
                    "purchaseWithZeroEx((address,address,address,uint256,uint256,uint8,address),(address,address,address,address,uint256,uint256,uint256,bytes))",
                    optionTerms,
                    zeroExOrder
                )
            );
        revertWhenFail(success, result);
    }

    function delegateExercise(
        IProtocolAdapter adapter,
        address options,
        uint256 optionID,
        uint256 amount,
        address recipient
    ) external {

        (bool success, bytes memory result) =
            address(adapter).delegatecall(
                abi.encodeWithSignature(
                    "exercise(address,uint256,uint256,address)",
                    options,
                    optionID,
                    amount,
                    recipient
                )
            );
        revertWhenFail(success, result);
    }

    function delegateClaimRewards(
        IProtocolAdapter adapter,
        address rewardsAddress,
        uint256[] calldata optionIDs
    ) external returns (uint256) {

        (bool success, bytes memory result) =
            address(adapter).delegatecall(
                abi.encodeWithSignature(
                    "claimRewards(address,uint256[])",
                    rewardsAddress,
                    optionIDs
                )
            );
        revertWhenFail(success, result);
        return abi.decode(result, (uint256));
    }

    function delegateRewardsClaimable(
        IProtocolAdapter adapter,
        address rewardsAddress,
        uint256[] calldata optionIDs
    ) external view returns (uint256) {

        (bool success, bytes memory result) =
            address(adapter).staticcall(
                abi.encodeWithSignature(
                    "rewardsClaimable(address,uint256[])",
                    rewardsAddress,
                    optionIDs
                )
            );
        revertWhenFail(success, result);
        return abi.decode(result, (uint256));
    }

    function delegateCreateShort(
        IProtocolAdapter adapter,
        ProtocolAdapterTypes.OptionTerms calldata optionTerms,
        uint256 amount
    ) external returns (uint256) {

        (bool success, bytes memory result) =
            address(adapter).delegatecall(
                abi.encodeWithSignature(
                    "createShort((address,address,address,uint256,uint256,uint8,address),uint256)",
                    optionTerms,
                    amount
                )
            );
        revertWhenFail(success, result);
        return abi.decode(result, (uint256));
    }

    function delegateCloseShort(IProtocolAdapter adapter)
        external
        returns (uint256)
    {

        (bool success, bytes memory result) =
            address(adapter).delegatecall(
                abi.encodeWithSignature("closeShort()")
            );
        require(success, getRevertMsg(result));
        return abi.decode(result, (uint256));
    }

    function revertWhenFail(bool success, bytes memory returnData)
        private
        pure
    {

        if (success) return;
        revert(getRevertMsg(returnData));
    }

    function getRevertMsg(bytes memory _returnData)
        private
        pure
        returns (string memory)
    {

        if (_returnData.length < 68) return "ProtocolAdapter: reverted";

        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string)); // All that remains is the revert string
    }
}