

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

interface IMapleLiquidityPosition is IExternalPosition {

    enum Actions {
        Lend,
        LendAndStake,
        IntendToRedeem,
        Redeem,
        Stake,
        Unstake,
        UnstakeAndRedeem,
        ClaimInterest,
        ClaimRewards
    }
}// GPL-3.0


pragma solidity 0.6.12;

abstract contract MapleLiquidityPositionDataDecoder {
    function __decodeClaimInterestActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address pool_)
    {
        return abi.decode(_actionArgs, (address));
    }

    function __decodeClaimRewardsActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address rewardsContract_)
    {
        return abi.decode(_actionArgs, (address));
    }

    function __decodeLendActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address pool_, uint256 liquidityAssetAmount_)
    {
        return abi.decode(_actionArgs, (address, uint256));
    }

    function __decodeLendAndStakeActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            address pool_,
            address rewardsContract_,
            uint256 liquidityAssetAmount_
        )
    {
        return abi.decode(_actionArgs, (address, address, uint256));
    }

    function __decodeIntendToRedeemActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address pool_)
    {
        return abi.decode(_actionArgs, (address));
    }

    function __decodeRedeemActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address pool_, uint256 liquidityAssetAmount_)
    {
        return abi.decode(_actionArgs, (address, uint256));
    }

    function __decodeStakeActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            address rewardsContract_,
            address pool_,
            uint256 poolTokenAmount_
        )
    {
        return abi.decode(_actionArgs, (address, address, uint256));
    }

    function __decodeUnstakeActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (address rewardsContract_, uint256 poolTokenAmount_)
    {
        return abi.decode(_actionArgs, (address, uint256));
    }

    function __decodeUnstakeAndRedeemActionArgs(bytes memory _actionArgs)
        internal
        pure
        returns (
            address pool_,
            address rewardsContract_,
            uint256 poolTokenAmount_
        )
    {
        return abi.decode(_actionArgs, (address, address, uint256));
    }
}// GPL-3.0


pragma solidity 0.6.12;

interface IMaplePool {

    function deposit(uint256) external;


    function increaseCustodyAllowance(address, uint256) external;


    function intendToWithdraw() external;


    function liquidityAsset() external view returns (address);


    function recognizableLossesOf(address) external returns (uint256);


    function withdraw(uint256) external;


    function withdrawFunds() external;


    function withdrawableFundsOf(address) external returns (uint256);

}// GPL-3.0


pragma solidity 0.6.12;

interface IMaplePoolFactory {

    function isPool(address) external view returns (bool);

}// GPL-3.0


pragma solidity 0.6.12;

interface IMapleMplRewardsFactory {

    function isMplRewards(address) external view returns (bool);

}// GPL-3.0



pragma solidity 0.6.12;

contract MapleLiquidityPositionParser is
    MapleLiquidityPositionDataDecoder,
    IExternalPositionParser
{

    address private immutable MAPLE_POOL_FACTORY;
    address private immutable MAPLE_MPL_REWARDS_FACTORY;

    constructor(address _maplePoolFactory, address _mapleMplRewardsFactory) public {
        MAPLE_POOL_FACTORY = _maplePoolFactory;
        MAPLE_MPL_REWARDS_FACTORY = _mapleMplRewardsFactory;
    }

    function parseAssetsForAction(
        address,
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

        __validateActionData(_actionId, _encodedActionArgs);

        if (_actionId == uint256(IMapleLiquidityPosition.Actions.Lend)) {
            (address pool, uint256 liquidityAssetAmount) = __decodeLendActionArgs(
                _encodedActionArgs
            );

            assetsToTransfer_ = new address[](1);
            amountsToTransfer_ = new uint256[](1);

            assetsToTransfer_[0] = IMaplePool(pool).liquidityAsset();
            amountsToTransfer_[0] = liquidityAssetAmount;
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.LendAndStake)) {
            (address pool, , uint256 liquidityAssetAmount) = __decodeLendAndStakeActionArgs(
                _encodedActionArgs
            );

            assetsToTransfer_ = new address[](1);
            amountsToTransfer_ = new uint256[](1);

            assetsToTransfer_[0] = IMaplePool(pool).liquidityAsset();
            amountsToTransfer_[0] = liquidityAssetAmount;
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.Redeem)) {
            (address pool, ) = __decodeRedeemActionArgs(_encodedActionArgs);

            assetsToReceive_ = new address[](1);
            assetsToReceive_[0] = IMaplePool(pool).liquidityAsset();
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.UnstakeAndRedeem)) {
            (address pool, , ) = __decodeUnstakeAndRedeemActionArgs(_encodedActionArgs);

            assetsToReceive_ = new address[](1);
            assetsToReceive_[0] = IMaplePool(pool).liquidityAsset();
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.ClaimInterest)) {
            address pool = __decodeClaimInterestActionArgs(_encodedActionArgs);

            assetsToReceive_ = new address[](1);
            assetsToReceive_[0] = IMaplePool(pool).liquidityAsset();
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


    function __validateActionData(uint256 _actionId, bytes memory _actionArgs) private view {

        if (_actionId == uint256(IMapleLiquidityPosition.Actions.Lend)) {
            (address pool, ) = __decodeLendActionArgs(_actionArgs);

            __validatePool(pool);
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.LendAndStake)) {
            (address pool, address rewardsContract, ) = __decodeLendAndStakeActionArgs(
                _actionArgs
            );

            __validatePool(pool);
            __validateRewardsContract(rewardsContract);
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.IntendToRedeem)) {
            address pool = __decodeIntendToRedeemActionArgs(_actionArgs);

            __validatePool(pool);
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.Redeem)) {
            (address pool, ) = __decodeRedeemActionArgs(_actionArgs);

            __validatePool(pool);
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.Stake)) {
            (address rewardsContract, address pool, ) = __decodeStakeActionArgs(_actionArgs);

            __validatePool(pool);
            __validateRewardsContract(rewardsContract);
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.Unstake)) {
            (address rewardsContract, ) = __decodeUnstakeActionArgs(_actionArgs);

            __validateRewardsContract(rewardsContract);
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.UnstakeAndRedeem)) {
            (address pool, address rewardsContract, ) = __decodeUnstakeAndRedeemActionArgs(
                _actionArgs
            );

            __validatePool(pool);
            __validateRewardsContract(rewardsContract);
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.ClaimInterest)) {
            address pool = __decodeClaimInterestActionArgs(_actionArgs);

            __validatePool(pool);
        } else if (_actionId == uint256(IMapleLiquidityPosition.Actions.ClaimRewards)) {
            address rewardsContract = __decodeClaimRewardsActionArgs(_actionArgs);

            __validateRewardsContract(rewardsContract);
        }
    }

    function __validatePool(address _pool) private view {

        require(
            IMaplePoolFactory(MAPLE_POOL_FACTORY).isPool(_pool),
            "__validatePool: Invalid pool"
        );
    }

    function __validateRewardsContract(address _rewardsContract) private view {

        require(
            IMapleMplRewardsFactory(MAPLE_MPL_REWARDS_FACTORY).isMplRewards(_rewardsContract),
            "__validateRewardsContract: Invalid rewards contract"
        );
    }
}