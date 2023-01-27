

pragma solidity 0.8.0;
pragma abicoder v2;


interface MassetStructs {

    struct BassetPersonal {
        address addr;
        address integrator;
        bool hasTxFee; // takes a byte in storage
        BassetStatus status;
    }

    struct BassetData {
        uint128 ratio;
        uint128 vaultBalance;
    }

    enum BassetStatus {
        Default,
        Normal,
        BrokenBelowPeg,
        BrokenAbovePeg,
        Blacklisted,
        Liquidating,
        Liquidated,
        Failed
    }

    struct BasketState {
        bool undergoingRecol;
        bool failed;
    }

    struct InvariantConfig {
        uint256 a;
        WeightLimits limits;
    }

    struct WeightLimits {
        uint128 min;
        uint128 max;
    }

    struct AmpData {
        uint64 initialA;
        uint64 targetA;
        uint64 rampStartTime;
        uint64 rampEndTime;
    }
}

library SafeCast {

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}

struct Basket {
    Basset[] bassets;
    uint8 maxBassets;
    bool undergoingRecol;
    bool failed;
    uint256 collateralisationRatio;

}

interface IBasketManager {

    function getBassetIntegrator(address _bAsset)
        external
        view
        returns (address integrator);


    function getBasket()
        external
        view
        returns (Basket memory b);

}

struct Basset {
    address addr;
    BassetStatus status;
    bool isTransferFeeCharged;
    uint256 ratio;
    uint256 maxWeight;
    uint256 vaultBalance;
}

enum BassetStatus {
    Default,
    Normal,
    BrokenBelowPeg,
    BrokenAbovePeg,
    Blacklisted,
    Liquidating,
    Liquidated,
    Failed
}

library Migrator {


    function upgrade(
        IBasketManager basketManager,
        MassetStructs.BassetPersonal[] storage bAssetPersonal,
        MassetStructs.BassetData[] storage bAssetData,
        mapping(address => uint8) storage bAssetIndexes
    ) external {

        Basket memory importedBasket = basketManager.getBasket();

        uint256 len = importedBasket.bassets.length;
        uint256[] memory scaledVaultBalances = new uint[](len);
        uint256 maxScaledVaultBalance;
        for (uint8 i = 0; i < len; i++) {
            Basset memory bAsset = importedBasket.bassets[i];
            address bAssetAddress = bAsset.addr;
            bAssetIndexes[bAssetAddress] = i;

            address integratorAddress = basketManager.getBassetIntegrator(bAssetAddress);
            bAssetPersonal.push(
                MassetStructs.BassetPersonal({
                    addr: bAssetAddress,
                    integrator: integratorAddress,
                    hasTxFee: false,
                    status: MassetStructs.BassetStatus.Normal
                })
            );

            uint128 ratio = SafeCast.toUint128(bAsset.ratio);
            uint128 vaultBalance = SafeCast.toUint128(bAsset.vaultBalance);
            bAssetData.push(
                MassetStructs.BassetData({ ratio: ratio, vaultBalance: vaultBalance })
            );

            uint128 scaledVaultBalance = (vaultBalance * ratio) / 1e8;
            scaledVaultBalances[i] = scaledVaultBalance;
            maxScaledVaultBalance += scaledVaultBalance;
        }

        uint256 maxWeight = 2501;
        if(len == 3){
            maxWeight = 3334;
        } else if (len != 4){
            revert("Invalid length");
        }
        maxScaledVaultBalance = maxScaledVaultBalance * 2501 / 10000;
        for (uint8 i = 0; i < len; i++) {
            require(scaledVaultBalances[i] < maxScaledVaultBalance, "imbalanced");
        }
    }
}