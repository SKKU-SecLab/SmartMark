
pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


interface MassetStructs {


    struct Basket {

        Basset[] bassets;

        uint8 maxBassets;

        bool undergoingRecol;

        bool failed;
        uint256 collateralisationRatio;

    }

    struct Basset {

        address addr;

        BassetStatus status; // takes uint8 datatype (1 byte) in storage

        bool isTransferFeeCharged; // takes a byte in storage

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

    struct BassetDetails {
        Basset bAsset;
        address integrator;
        uint8 index;
    }

    struct ForgePropsMulti {
        bool isValid; // Flag to signify that forge bAssets have passed validity check
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }

    struct RedeemPropsMulti {
        uint256 colRatio;
        Basset[] bAssets;
        address[] integrators;
        uint8[] indexes;
    }
}

contract IForgeValidator is MassetStructs {

    function validateMint(uint256 _totalVault, Basset calldata _basset, uint256 _bAssetQuantity)
        external pure returns (bool, string memory);

    function validateMintMulti(uint256 _totalVault, Basset[] calldata _bassets, uint256[] calldata _bAssetQuantities)
        external pure returns (bool, string memory);

    function validateSwap(uint256 _totalVault, Basset calldata _inputBasset, Basset calldata _outputBasset, uint256 _quantity)
        external pure returns (bool, string memory, uint256, bool);

    function validateRedemption(
        bool basketIsFailed,
        uint256 _totalVault,
        Basset[] calldata _allBassets,
        uint8[] calldata _indices,
        uint256[] calldata _bassetQuantities) external pure returns (bool, string memory, bool);

    function calculateRedemptionMulti(
        uint256 _mAssetQuantity,
        Basset[] calldata _allBassets) external pure returns (bool, string memory, uint256[] memory);

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

library StableMath {


    using SafeMath for uint256;

    uint256 private constant FULL_SCALE = 1e18;

    uint256 private constant RATIO_SCALE = 1e8;

    function getFullScale() internal pure returns (uint256) {

        return FULL_SCALE;
    }

    function getRatioScale() internal pure returns (uint256) {

        return RATIO_SCALE;
    }

    function scaleInteger(uint256 x)
        internal
        pure
        returns (uint256)
    {

        return x.mul(FULL_SCALE);
    }


    function mulTruncate(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(uint256 x, uint256 y, uint256 scale)
        internal
        pure
        returns (uint256)
    {

        uint256 z = x.mul(y);
        return z.div(scale);
    }

    function mulTruncateCeil(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 scaled = x.mul(y);
        uint256 ceil = scaled.add(FULL_SCALE.sub(1));
        return ceil.div(FULL_SCALE);
    }

    function divPrecisely(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        uint256 z = x.mul(FULL_SCALE);
        return z.div(y);
    }



    function mulRatioTruncate(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {

        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    function mulRatioTruncateCeil(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256)
    {

        uint256 scaled = x.mul(ratio);
        uint256 ceil = scaled.add(RATIO_SCALE.sub(1));
        return ceil.div(RATIO_SCALE);
    }


    function divRatioPrecisely(uint256 x, uint256 ratio)
        internal
        pure
        returns (uint256 c)
    {

        uint256 y = x.mul(RATIO_SCALE);
        return y.div(ratio);
    }


    function min(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return x > y ? y : x;
    }

    function max(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {

        return x > y ? x : y;
    }

    function clamp(uint256 x, uint256 upperBound)
        internal
        pure
        returns (uint256)
    {

        return x > upperBound ? upperBound : x;
    }
}

contract ForgeValidator is IForgeValidator {


    using SafeMath for uint256;
    using StableMath for uint256;


    function validateMint(
        uint256 _totalVault,
        Basset calldata _bAsset,
        uint256 _bAssetQuantity
    )
        external
        pure
        returns (bool isValid, string memory reason)
    {

        if(
            _bAsset.status == BassetStatus.BrokenBelowPeg ||
            _bAsset.status == BassetStatus.Liquidating ||
            _bAsset.status == BassetStatus.Blacklisted
        ) {
            return (false, "bAsset not allowed in mint");
        }

        uint256 mintAmountInMasset = _bAssetQuantity.mulRatioTruncate(_bAsset.ratio);
        uint256 newBalanceInMasset = _bAsset.vaultBalance.mulRatioTruncate(_bAsset.ratio).add(mintAmountInMasset);
        uint256 maxWeightInUnits = (_totalVault.add(mintAmountInMasset)).mulTruncate(_bAsset.maxWeight);

        if(newBalanceInMasset > maxWeightInUnits) {
            return (false, "bAssets used in mint cannot exceed their max weight");
        }

        return (true, "");
    }

    function validateMintMulti(
        uint256 _totalVault,
        Basset[] calldata _bAssets,
        uint256[] calldata _bAssetQuantities
    )
        external
        pure
        returns (bool isValid, string memory reason)
    {

        uint256 bAssetCount = _bAssets.length;
        if(bAssetCount != _bAssetQuantities.length) return (false, "Input length should be equal");

        uint256[] memory newBalances = new uint256[](bAssetCount);
        uint256 newTotalVault = _totalVault;

        for(uint256 j = 0; j < bAssetCount; j++){
            Basset memory b = _bAssets[j];
            BassetStatus bAssetStatus = b.status;

            if(
                bAssetStatus == BassetStatus.BrokenBelowPeg ||
                bAssetStatus == BassetStatus.Liquidating ||
                bAssetStatus == BassetStatus.Blacklisted
            ) {
                return (false, "bAsset not allowed in mint");
            }

            uint256 mintAmountInMasset = _bAssetQuantities[j].mulRatioTruncate(b.ratio);
            newBalances[j] = b.vaultBalance.mulRatioTruncate(b.ratio).add(mintAmountInMasset);

            newTotalVault = newTotalVault.add(mintAmountInMasset);
        }

        for(uint256 k = 0; k < bAssetCount; k++){
            uint256 maxWeightInUnits = newTotalVault.mulTruncate(_bAssets[k].maxWeight);

            if(newBalances[k] > maxWeightInUnits) {
                return (false, "bAssets used in mint cannot exceed their max weight");
            }
        }

        return (true, "");
    }


    function validateSwap(
        uint256 _totalVault,
        Basset calldata _inputBasset,
        Basset calldata _outputBasset,
        uint256 _quantity
    )
        external
        pure
        returns (bool isValid, string memory reason, uint256 output, bool applySwapFee)
    {

        if(_inputBasset.status != BassetStatus.Normal || _outputBasset.status != BassetStatus.Normal) {
            return (false, "bAsset not allowed in swap", 0, false);
        }

        uint256 inputAmountInMasset = _quantity.mulRatioTruncate(_inputBasset.ratio);

        uint256 outputAmount = inputAmountInMasset.divRatioPrecisely(_outputBasset.ratio);
        if(outputAmount > _outputBasset.vaultBalance) {
            return (false, "Not enough liquidity", 0, false);
        }

        applySwapFee = true;
        uint256 outputBalanceMasset = _outputBasset.vaultBalance.mulRatioTruncate(_outputBasset.ratio);
        uint256 outputMaxWeightUnits = _totalVault.mulTruncate(_outputBasset.maxWeight);
        if(outputBalanceMasset > outputMaxWeightUnits) {
            applySwapFee = false;
        }

        uint256 newInputBalanceInMasset = _inputBasset.vaultBalance.mulRatioTruncate(_inputBasset.ratio).add(inputAmountInMasset);
        uint256 inputMaxWeightInUnits = _totalVault.mulTruncate(_inputBasset.maxWeight);
        if(newInputBalanceInMasset > inputMaxWeightInUnits) {
            return (false, "Input must remain below max weighting", 0, false);
        }

        return (true, "", outputAmount, applySwapFee);
    }



    function validateRedemption(
        bool _basketIsFailed,
        uint256 _totalVault,
        Basset[] calldata _allBassets,
        uint8[] calldata _indices,
        uint256[] calldata _bAssetQuantities
    )
        external
        pure
        returns (bool, string memory, bool)
    {

        uint256 idxCount = _indices.length;
        if(idxCount != _bAssetQuantities.length) return (false, "Input arrays must have equal length", false);

        BasketStateResponse memory data = _getBasketState(_totalVault, _allBassets);
        if(!data.isValid) return (false, data.reason, false);

        if(
            _basketIsFailed ||
            data.atLeastOneBroken ||
            (data.overWeightCount == 0 && data.atLeastOneBreached)
        ) {
            return (false, "Must redeem proportionately", false);
        } else if (data.overWeightCount > idxCount) {
            return (false, "Redemption must contain all overweight bAssets", false);
        }

        uint256 newTotalVault = _totalVault;

        for(uint256 i = 0; i < idxCount; i++){
            uint8 idx = _indices[i];
            if(idx >= _allBassets.length) return (false, "Basset does not exist", false);

            Basset memory bAsset = _allBassets[idx];
            uint256 quantity = _bAssetQuantities[i];
            if(quantity > bAsset.vaultBalance) return (false, "Cannot redeem more bAssets than are in the vault", false);

            uint256 ratioedRedemptionAmount = quantity.mulRatioTruncate(bAsset.ratio);
            data.ratioedBassetVaults[idx] = data.ratioedBassetVaults[idx].sub(ratioedRedemptionAmount);

            newTotalVault = newTotalVault.sub(ratioedRedemptionAmount);
        }

        bool atLeastOneBecameOverweight =
            _getOverweightBassetsAfter(newTotalVault, _allBassets, data.ratioedBassetVaults, data.isOverWeight);

        bool applySwapFee = true;
        if(data.overWeightCount > 0) {
            for(uint256 j = 0; j < idxCount; j++) {
                if(!data.isOverWeight[_indices[j]]) return (false, "Must redeem overweight bAssets", false);
            }
            applySwapFee = false;
        }
        if(atLeastOneBecameOverweight) return (false, "bAssets must remain below max weight", false);

        return (true, "", applySwapFee);
    }

    function calculateRedemptionMulti(
        uint256 _mAssetQuantity,
        Basset[] calldata _allBassets
    )
        external
        pure
        returns (bool, string memory, uint256[] memory)
    {

        uint256 len = _allBassets.length;
        uint256[] memory redeemQuantities = new uint256[](len);
        uint256[] memory ratioedBassetVaults = new uint256[](len);
        uint256 totalBassetVault = 0;
        for(uint256 i = 0; i < len; i++) {
            if(_allBassets[i].status == BassetStatus.Blacklisted) {
                return (false, "Basket contains blacklisted bAsset", redeemQuantities);
            } else if(_allBassets[i].status == BassetStatus.Liquidating) {
                return (false, "Basket contains liquidating bAsset", redeemQuantities);
            }
            uint256 ratioedBasset = _allBassets[i].vaultBalance.mulRatioTruncate(_allBassets[i].ratio);
            ratioedBassetVaults[i] = ratioedBasset;
            totalBassetVault = totalBassetVault.add(ratioedBasset);
        }
        if(totalBassetVault == 0) return (false, "Nothing in the basket to redeem", redeemQuantities);
        if(_mAssetQuantity > totalBassetVault) return (false, "Not enough liquidity", redeemQuantities);
        for(uint256 i = 0; i < len; i++) {
            uint256 percentageOfVault = ratioedBassetVaults[i].divPrecisely(totalBassetVault);
            uint256 ratioedProportionalBasset = _mAssetQuantity.mulTruncate(percentageOfVault);
            redeemQuantities[i] = ratioedProportionalBasset.divRatioPrecisely(_allBassets[i].ratio);
        }
        return (true, "", redeemQuantities);
    }


    struct BasketStateResponse {
        bool isValid;
        string reason;
        bool atLeastOneBroken;
        bool atLeastOneBreached;
        uint256 overWeightCount;
        bool[] isOverWeight;
        uint256[] ratioedBassetVaults;
    }

    function _getBasketState(uint256 _total, Basset[] memory _bAssets)
        private
        pure
        returns (BasketStateResponse memory response)
    {

        uint256 len = _bAssets.length;
        response = BasketStateResponse({
            isValid: true,
            reason: "",
            atLeastOneBroken: false,
            atLeastOneBreached: false,
            overWeightCount: 0,
            isOverWeight: new bool[](len),
            ratioedBassetVaults: new uint256[](len)
        });

        uint256 onePercentOfTotal = _total.mulTruncate(1e16);
        uint256 weightBreachThreshold = StableMath.min(onePercentOfTotal, 5e22);

        for(uint256 i = 0; i < len; i++) {
            BassetStatus status = _bAssets[i].status;
            if(status == BassetStatus.Blacklisted) {
                response.isValid = false;
                response.reason = "Basket contains blacklisted bAsset";
                return response;
            } else if(
                status == BassetStatus.Liquidating ||
                status == BassetStatus.BrokenBelowPeg ||
                status == BassetStatus.BrokenAbovePeg
            ) {
                response.atLeastOneBroken = true;
            }

            uint256 ratioedBasset = _bAssets[i].vaultBalance.mulRatioTruncate(_bAssets[i].ratio);
            response.ratioedBassetVaults[i] = ratioedBasset;
            uint256 maxWeightInUnits = _total.mulTruncate(_bAssets[i].maxWeight);

            bool bAssetOverWeight = ratioedBasset > maxWeightInUnits;
            if(bAssetOverWeight){
                response.isOverWeight[i] = true;
                response.overWeightCount += 1;
            }

            if(!bAssetOverWeight) {
                uint256 lowerBound = weightBreachThreshold > maxWeightInUnits ? 0 : maxWeightInUnits.sub(weightBreachThreshold);
                bool isInBound = ratioedBasset > lowerBound && ratioedBasset <= maxWeightInUnits;
                response.atLeastOneBreached = response.atLeastOneBreached || isInBound;
            }
        }
    }

    function _getOverweightBassetsAfter(
        uint256 _newTotal,
        Basset[] memory _bAssets,
        uint256[] memory _ratioedBassetVaultsAfter,
        bool[] memory _previouslyOverWeight
    )
        private
        pure
        returns (bool atLeastOneBecameOverweight)
    {

        uint256 len = _ratioedBassetVaultsAfter.length;

        for(uint256 i = 0; i < len; i++) {
            uint256 maxWeightInUnits = _newTotal.mulTruncate(_bAssets[i].maxWeight);

            bool isOverweight = _ratioedBassetVaultsAfter[i] > maxWeightInUnits;
            bool becameOverweight = !_previouslyOverWeight[i] && isOverweight;
            atLeastOneBecameOverweight = atLeastOneBecameOverweight || becameOverweight;
        }
    }
}