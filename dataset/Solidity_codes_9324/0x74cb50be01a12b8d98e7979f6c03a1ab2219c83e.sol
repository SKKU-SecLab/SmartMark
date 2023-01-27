

pragma solidity 0.6.12;

interface IExternalPosition {

    function getDebtAssets() external returns (address[] memory, uint256[] memory);


    function getManagedAssets() external returns (address[] memory, uint256[] memory);


    function init(bytes memory) external;


    function receiveCallFromVault(bytes memory) external;

}// GPL-3.0


pragma solidity 0.6.12;

interface IExternalPositionParser {

    function parseAssetsForAction(
        address _externalPosition,
        uint256 _actionId,
        bytes memory _encodedActionArgs
    )
        external
        returns (
            address[] memory assetsToTransfer_,
            uint256[] memory amountsToTransfer_,
            address[] memory assetsToReceive_
        );


    function parseInitArgs(address _vaultProxy, bytes memory _initializationData)
        external
        returns (bytes memory initArgs_);

}// GPL-3.0



pragma solidity 0.6.12;

interface ILiquityDebtPosition is IExternalPosition {

    enum Actions {OpenTrove, AddCollateral, RemoveCollateral, Borrow, RepayBorrow, CloseTrove}
}// GPL-3.0


pragma solidity 0.6.12;

abstract contract LiquityDebtPositionDataDecoder {
    function __decodeAddCollateralActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            uint256 collateralAmount_,
            address upperHint_,
            address lowerHint_
        )
    {
        return abi.decode(_actionArgs, (uint256, address, address));
    }

    function __decodeBorrowActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            uint256 maxFeePercentage_,
            uint256 lusdAmount_,
            address upperHint_,
            address lowerHint_
        )
    {
        return abi.decode(_actionArgs, (uint256, uint256, address, address));
    }

    function __decodeCloseTroveActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (uint256 lusdAmount_)
    {
        return abi.decode(_actionArgs, (uint256));
    }

    function __decodeOpenTroveArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            uint256 maxFeePercentage_,
            uint256 collateralAmount_,
            uint256 lusdAmount_,
            address upperHint_,
            address lowerHint_
        )
    {
        return abi.decode(_actionArgs, (uint256, uint256, uint256, address, address));
    }

    function __decodeRemoveCollateralActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            uint256 collateralAmount_,
            address upperHint_,
            address lowerHint_
        )
    {
        return abi.decode(_actionArgs, (uint256, address, address));
    }

    function __decodeRepayBorrowActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            uint256 lusdAmount_,
            address upperHint_,
            address lowerHint_
        )
    {
        return abi.decode(_actionArgs, (uint256, address, address));
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface ILiquityTroveManager {

    function getTroveColl(address) external view returns (uint256);


    function getTroveDebt(address) external view returns (uint256);

}// GPL-3.0



pragma solidity 0.6.12;

contract LiquityDebtPositionParser is IExternalPositionParser, LiquityDebtPositionDataDecoder {

    address private immutable LIQUITY_TROVE_MANAGER;
    address private immutable LUSD_TOKEN;
    address private immutable WETH_TOKEN;

    constructor(
        address _liquityTroveManager,
        address _lusdToken,
        address _wethToken
    ) public {
        LIQUITY_TROVE_MANAGER = _liquityTroveManager;
        LUSD_TOKEN = _lusdToken;
        WETH_TOKEN = _wethToken;
    }

    function parseAssetsForAction(
        address _externalPosition,
        uint256 _actionId,
        bytes memory _encodedActionArgs
    )
        external
        override
        returns (
            address[] memory assetsToTransfer_,
            uint256[] memory amountsToTransfer_,
            address[] memory assetsToReceive_
        )
    {

        if (_actionId == uint256(ILiquityDebtPosition.Actions.OpenTrove)) {
            (, uint256 collateralAmount, , , ) = __decodeOpenTroveArgs(_encodedActionArgs);

            assetsToTransfer_ = new address[](1);
            amountsToTransfer_ = new uint256[](1);
            assetsToTransfer_[0] = WETH_TOKEN;
            amountsToTransfer_[0] = collateralAmount;
            assetsToReceive_ = new address[](1);
            assetsToReceive_[0] = LUSD_TOKEN;
        }
        if (_actionId == uint256(ILiquityDebtPosition.Actions.AddCollateral)) {
            (uint256 collateralAmount, , ) = __decodeAddCollateralActionArgs(_encodedActionArgs);

            assetsToTransfer_ = new address[](1);
            amountsToTransfer_ = new uint256[](1);
            assetsToTransfer_[0] = WETH_TOKEN;
            amountsToTransfer_[0] = collateralAmount;
        }
        if (_actionId == uint256(ILiquityDebtPosition.Actions.RemoveCollateral)) {
            assetsToReceive_ = new address[](1);
            assetsToReceive_[0] = WETH_TOKEN;
        } else if (_actionId == uint256(ILiquityDebtPosition.Actions.RepayBorrow)) {
            (uint256 lusdAmount, , ) = __decodeRepayBorrowActionArgs(_encodedActionArgs);
            assetsToTransfer_ = new address[](1);
            amountsToTransfer_ = new uint256[](1);
            assetsToTransfer_[0] = LUSD_TOKEN;
            amountsToTransfer_[0] = lusdAmount;
        } else if (_actionId == uint256(ILiquityDebtPosition.Actions.Borrow)) {
            assetsToReceive_ = new address[](1);
            assetsToReceive_[0] = LUSD_TOKEN;
        } else if (_actionId == uint256(ILiquityDebtPosition.Actions.CloseTrove)) {
            uint256 lusdAmount = ILiquityTroveManager(LIQUITY_TROVE_MANAGER).getTroveDebt(
                _externalPosition
            );

            assetsToTransfer_ = new address[](1);
            assetsToReceive_ = new address[](1);
            amountsToTransfer_ = new uint256[](1);

            assetsToTransfer_[0] = LUSD_TOKEN;
            amountsToTransfer_[0] = lusdAmount;
            assetsToReceive_[0] = WETH_TOKEN;
        }

        return (assetsToTransfer_, amountsToTransfer_, assetsToReceive_);
    }

    function parseInitArgs(address, bytes memory)
        external
        override
        returns (bytes memory initArgs_)
    {

        return "";
    }
}