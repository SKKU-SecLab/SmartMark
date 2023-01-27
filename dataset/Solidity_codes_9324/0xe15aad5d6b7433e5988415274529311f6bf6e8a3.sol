
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

contract IMasset is MassetStructs {


    function collectInterest() external returns (uint256 massetMinted, uint256 newTotalSupply);


    function mint(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetMinted);

    function mintTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);

    function mintMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantity, address _recipient)
        external returns (uint256 massetMinted);


    function swap( address _input, address _output, uint256 _quantity, address _recipient)
        external returns (uint256 output);

    function getSwapOutput( address _input, address _output, uint256 _quantity)
        external view returns (bool, string memory, uint256 output);


    function redeem(address _basset, uint256 _bassetQuantity)
        external returns (uint256 massetRedeemed);

    function redeemTo(address _basset, uint256 _bassetQuantity, address _recipient)
        external returns (uint256 massetRedeemed);

    function redeemMulti(address[] calldata _bAssets, uint256[] calldata _bassetQuantities, address _recipient)
        external returns (uint256 massetRedeemed);

    function redeemMasset(uint256 _mAssetQuantity, address _recipient) external;


    function upgradeForgeValidator(address _newForgeValidator) external;


    function setSwapFee(uint256 _swapFee) external;


    function getBasketManager() external view returns(address);

    function forgeValidator() external view returns (address);

    function totalSupply() external view returns (uint256);

    function swapFee() external view returns (uint256);

}

contract IBasketManager is MassetStructs {


    function increaseVaultBalance(
        uint8 _bAsset,
        address _integrator,
        uint256 _increaseAmount) external;

    function increaseVaultBalances(
        uint8[] calldata _bAsset,
        address[] calldata _integrator,
        uint256[] calldata _increaseAmount) external;

    function decreaseVaultBalance(
        uint8 _bAsset,
        address _integrator,
        uint256 _decreaseAmount) external;

    function decreaseVaultBalances(
        uint8[] calldata _bAsset,
        address[] calldata _integrator,
        uint256[] calldata _decreaseAmount) external;

    function collectInterest() external
        returns (uint256 interestCollected, uint256[] memory gains);


    function addBasset(
        address _basset,
        address _integration,
        bool _isTransferFeeCharged) external returns (uint8 index);

    function setBasketWeights(address[] calldata _bassets, uint256[] calldata _weights) external;

    function setTransferFeesFlag(address _bAsset, bool _flag) external;


    function getBasket() external view returns (Basket memory b);

    function prepareForgeBasset(address _token, uint256 _amt, bool _mint) external
        returns (bool isValid, BassetDetails memory bInfo);

    function prepareSwapBassets(address _input, address _output, bool _isMint) external view
        returns (bool, string memory, BassetDetails memory, BassetDetails memory);

    function prepareForgeBassets(address[] calldata _bAssets, uint256[] calldata _amts, bool _mint) external
        returns (ForgePropsMulti memory props);

    function prepareRedeemMulti() external view
        returns (RedeemPropsMulti memory props);

    function getBasset(address _token) external view
        returns (Basset memory bAsset);

    function getBassets() external view
        returns (Basset[] memory bAssets, uint256 len);

    function paused() external view returns (bool);


    function handlePegLoss(address _basset, bool _belowPeg) external returns (bool actioned);

    function negateIsolation(address _basset) external;

}

interface ISavingsContract {


    function depositInterest(uint256 _amount) external;


    function depositSavings(uint256 _amount) external returns (uint256 creditsIssued);

    function redeem(uint256 _amount) external returns (uint256 massetReturned);


    function exchangeRate() external view returns (uint256);

    function creditBalances(address) external view returns (uint256);

}

interface IMStableHelper {


    function suggestMintAsset(
        address _mAsset
    )
        external
        view
        returns (
            bool,
            string memory,
            address
        );


    function getMaxSwap(
        address _mAsset,
        address _input,
        address _output
    )
        external
        view
        returns (
            bool,
            string memory,
            uint256,
            uint256
        );



    function suggestRedeemAsset(
        address _mAsset
    )
        external
        view
        returns (
            bool,
            string memory,
            address
        );


    function getRedeemValidity(
        address _mAsset,
        uint256 _mAssetQuantity,
        address _outputBasset
    )
        external
        view
        returns (
            bool,
            string memory,
            uint256 output,
            uint256 bassetQuantityArg
        );


    function getSaveBalance(
        ISavingsContract _save,
        address _user
    )
        external
        view
        returns (
            uint256
        );


    function getSaveRedeemInput(
        ISavingsContract _save,
        uint256 _amount
    )
        external
        view
        returns (
            uint256
        );

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

contract MStableHelper is IMStableHelper, MassetStructs {


    using StableMath for uint256;
    using SafeMath for uint256;



    function suggestMintAsset(
        address _mAsset
    )
        external
        view
        returns (
            bool,
            string memory,
            address
        )
    {

        require(_mAsset != address(0), "Invalid mAsset");
        IBasketManager basketManager = IBasketManager(
            IMasset(_mAsset).getBasketManager()
        );
        Basket memory basket = basketManager.getBasket();
        uint256 totalSupply = IMasset(_mAsset).totalSupply();

        uint256 len = basket.bassets.length;
        uint256[] memory maxWeightDelta = new uint256[](len);
        for(uint256 i = 0; i < len; i++){
            Basset memory bAsset = basket.bassets[i];
            uint256 scaledBasset = bAsset.vaultBalance.mulRatioTruncate(bAsset.ratio);
            uint256 weight = scaledBasset.divPrecisely(totalSupply);
            maxWeightDelta[i] = weight > bAsset.maxWeight ? 0 : bAsset.maxWeight.sub(weight);
            if(bAsset.status != BassetStatus.Normal){
                return (false, "No assets available", address(0));
            }
        }
        uint256 idealMaxWeight = 0;
        address selected = address(0);
        for(uint256 j = 0; j < len; j++){
            uint256 bAssetDelta = maxWeightDelta[j];
            if(bAssetDelta >= 1e17){
                if(selected == address(0) || bAssetDelta < idealMaxWeight){
                    idealMaxWeight = bAssetDelta;
                    selected = basket.bassets[j].addr;
                }
            }
        }
        if(selected == address(0)){
            return (false, "No assets available", address(0));
        }
        return (true, "", selected);
    }


    function getMaxSwap(
        address _mAsset,
        address _input,
        address _output
    )
        external
        view
        returns (
            bool,
            string memory,
            uint256,
            uint256
        )
    {

        Data memory data = _getData(_mAsset, _input, _output);
        if(!data.isValid) {
          return (false, data.reason, 0, 0);
        }
        uint256 inputMaxWeightUnits = data.totalSupply.mulTruncate(data.input.maxWeight);
        uint256 inputVaultBalanceScaled = data.input.vaultBalance.mulRatioTruncate(
            data.input.ratio
        );
        if (data.isMint) {
            uint256 num = inputMaxWeightUnits.sub(inputVaultBalanceScaled);
            uint256 den = StableMath.getFullScale().sub(data.input.maxWeight);
            uint256 maxMintScaled = den > 0 ? num.divPrecisely(den) : num;
            uint256 maxMint = maxMintScaled.divRatioPrecisely(data.input.ratio);
            maxMintScaled = maxMint.mulRatioTruncate(data.input.ratio);
            return (true, "", maxMint, maxMintScaled);
        } else {
            uint256 maxInputScaled = inputMaxWeightUnits.sub(inputVaultBalanceScaled);
            uint256 outputMaxWeight = data.totalSupply.mulTruncate(data.output.maxWeight);
            uint256 outputVaultBalanceScaled = data.output.vaultBalance.mulRatioTruncate(data.output.ratio);
            uint256 clampedMax = maxInputScaled > outputVaultBalanceScaled ? outputVaultBalanceScaled : maxInputScaled;
            bool applyFee = outputVaultBalanceScaled < outputMaxWeight;
            uint256 maxInputUnits = clampedMax.divRatioPrecisely(data.input.ratio);
            uint256 outputUnitsIncFee = maxInputUnits.mulRatioTruncate(data.input.ratio).divRatioPrecisely(data.output.ratio);

            uint256 fee = applyFee ? data.mAsset.swapFee() : 0;
            uint256 outputFee = outputUnitsIncFee.mulTruncate(fee);
            return (true, "", maxInputUnits, outputUnitsIncFee.sub(outputFee));
        }
    }

    function suggestRedeemAsset(
        address _mAsset
    )
        external
        view
        returns (
            bool,
            string memory,
            address
        )
    {

        require(_mAsset != address(0), "Invalid mAsset");
        IBasketManager basketManager = IBasketManager(
            IMasset(_mAsset).getBasketManager()
        );
        Basket memory basket = basketManager.getBasket();
        uint256 totalSupply = IMasset(_mAsset).totalSupply();

        uint256 len = basket.bassets.length;
        uint256 overweightCount = 0;
        uint256[] memory maxWeightDelta = new uint256[](len);
        
        for(uint256 i = 0; i < len; i++){
            Basset memory bAsset = basket.bassets[i];
            uint256 scaledBasset = bAsset.vaultBalance.mulRatioTruncate(bAsset.ratio);
            uint256 weight = scaledBasset.divPrecisely(totalSupply);
            if(weight > bAsset.maxWeight) {
                overweightCount++;
            }
            maxWeightDelta[i] = weight > bAsset.maxWeight ? uint256(-1) : bAsset.maxWeight.sub(weight);
            if(bAsset.status != BassetStatus.Normal){
                return (false, "No assets available", address(0));
            }
        }

        if(overweightCount > 1) {
            return (false, "No assets available", address(0));
        } else if(overweightCount == 1){
            for(uint256 j = 0; j < len; j++){
                if(maxWeightDelta[j] == uint256(-1)){
                    return (true, "", basket.bassets[j].addr);
                }
            }
        }
        uint256 lowestDelta = uint256(-1);
        address selected = address(0);
        for(uint256 k = 0; k < len; k++){
            if(maxWeightDelta[k] < lowestDelta) {
                selected = basket.bassets[k].addr;
                lowestDelta = maxWeightDelta[k];
            }
        }
        return (true, "", selected);
    }

    function getRedeemValidity(
        address _mAsset,
        uint256 _mAssetQuantity,
        address _outputBasset
    )
        external
        view
        returns (
            bool,
            string memory,
            uint256 output,
            uint256 bassetQuantityArg
        )
    {

        IBasketManager basketManager = IBasketManager(
            IMasset(_mAsset).getBasketManager()
        );
        Basset memory bAsset = basketManager.getBasset(_outputBasset);
        uint256 bAssetQuantity = _mAssetQuantity.divRatioPrecisely(
            bAsset.ratio
        );

        address[] memory bAssets = new address[](1);
        uint256[] memory quantities = new uint256[](1);
        bAssets[0] = _outputBasset;
        quantities[0] = bAssetQuantity;
        (
            bool valid,
            string memory reason,
            uint256 bAssetOutput
        ) = _getRedeemValidity(_mAsset, bAssets, quantities);
        return (valid, reason, bAssetOutput, bAssetQuantity);
    }



    function getSaveBalance(
        ISavingsContract _save,
        address _user
    )
        external
        view
        returns (
            uint256
        )
    {

        require(address(_save) != address(0), "Invalid contract");
        require(_user != address(0), "Invalid user");

        uint256 credits = _save.creditBalances(_user);
        uint256 rate = _save.exchangeRate();
        require(rate > 0, "Invalid rate");

        return credits.mulTruncate(rate);
    }

    function getSaveRedeemInput(
        ISavingsContract _save,
        uint256 _mAssetUnits
    )
        external
        view
        returns (
            uint256
        )
    {

        require(address(_save) != address(0), "Invalid contract");

        uint256 rate = _save.exchangeRate();
        require(rate > 0, "Invalid rate");

        uint256 credits = _mAssetUnits.divPrecisely(rate);

        return credits + 1;
    }



    struct Data {
        bool isValid;
        string reason;
        IMasset mAsset;
        IBasketManager basketManager;
        bool isMint;
        uint256 totalSupply;
        Basset input;
        Basset output;
    }

    function _getData(address _mAsset, address _input, address _output) internal view returns (Data memory) {

        bool isMint = _output == _mAsset;
        IMasset mAsset = IMasset(_mAsset);
        IBasketManager basketManager = IBasketManager(
            mAsset.getBasketManager()
        );
        (bool isValid, string memory reason, ) = mAsset
            .getSwapOutput(_input, _output, 1);
        uint256 totalSupply = mAsset.totalSupply();
        Basset memory input = basketManager.getBasset(_input);
        Basset memory output = !isMint ? basketManager.getBasset(_output) : Basset({
            addr: _output,
            ratio: StableMath.getRatioScale(),
            maxWeight: 0,
            vaultBalance: 0,
            status: BassetStatus.Normal,
            isTransferFeeCharged: false
        });
        return Data({
            isValid: isValid,
            reason: reason,
            mAsset: mAsset,
            basketManager: basketManager,
            isMint: isMint,
            totalSupply: totalSupply,
            input: input,
            output: output
        });
    }


    function _getRedeemValidity(
        address _mAsset,
        address[] memory _bAssets,
        uint256[] memory _bAssetQuantities
    )
        internal
        view
        returns (
            bool,
            string memory,
            uint256 output
        )
    {

        uint256 bAssetCount = _bAssetQuantities.length;
        require(
            bAssetCount == 1 && bAssetCount == _bAssets.length,
            "Input array mismatch"
        );

        IMasset mAsset = IMasset(_mAsset);
        IBasketManager basketManager = IBasketManager(
            mAsset.getBasketManager()
        );

        Basket memory basket = basketManager.getBasket();

        if (basket.undergoingRecol || basketManager.paused()) {
            return (false, "Invalid basket state", 0);
        }

        (
            bool redemptionValid,
            string memory reason,
            bool applyFee
        ) = _validateRedeem(
            mAsset,
            _bAssetQuantities,
            _bAssets[0],
            basket.failed,
            mAsset.totalSupply(),
            basket.bassets
        );
        if (!redemptionValid) {
            return (false, reason, 0);
        }
        uint256 fee = applyFee ? mAsset.swapFee() : 0;
        uint256 feeAmount = _bAssetQuantities[0].mulTruncate(fee);
        uint256 outputMinusFee = _bAssetQuantities[0].sub(feeAmount);
        return (true, "", outputMinusFee);
    }


    function _validateRedeem(
        IMasset mAsset,
        uint256[] memory quantities,
        address bAsset,
        bool failed,
        uint256 supply,
        Basset[] memory allBassets
    )
        internal
        view
        returns (
            bool,
            string memory,
            bool
        )
    {

        IForgeValidator forgeValidator = IForgeValidator(
            mAsset.forgeValidator()
        );
        uint8[] memory bAssetIndexes = new uint8[](1);
        for (uint8 i = 0; i < uint8(allBassets.length); i++) {
            if (allBassets[i].addr == bAsset) {
                bAssetIndexes[0] = i;
                break;
            }
        }
        return
            forgeValidator.validateRedemption(
                failed,
                supply,
                allBassets,
                bAssetIndexes,
                quantities
            );
    }

}