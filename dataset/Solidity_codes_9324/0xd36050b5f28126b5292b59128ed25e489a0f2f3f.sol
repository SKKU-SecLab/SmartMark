
pragma solidity 0.8.0;


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

abstract contract IInvariantValidator is MassetStructs {
    function computeMint(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint256 _rawInput,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);

    function computeMintMulti(
        BassetData[] calldata _bAssets,
        uint8[] calldata _indices,
        uint256[] calldata _rawInputs,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);

    function computeSwap(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint8 _o,
        uint256 _rawInput,
        uint256 _feeRate,
        InvariantConfig memory _config
    ) external view virtual returns (uint256, uint256);

    function computeRedeem(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint256 _mAssetQuantity,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);

    function computeRedeemExact(
        BassetData[] calldata _bAssets,
        uint8[] calldata _indices,
        uint256[] calldata _rawOutputs,
        InvariantConfig memory _config
    ) external view virtual returns (uint256);
}

library Root {

    function sqrt(uint256 x) internal pure returns (uint256 y) {

        if (x == 0) return 0;
        else {
            uint256 xx = x;
            uint256 r = 1;
            if (xx >= 0x100000000000000000000000000000000) {
                xx >>= 128;
                r <<= 64;
            }
            if (xx >= 0x10000000000000000) {
                xx >>= 64;
                r <<= 32;
            }
            if (xx >= 0x100000000) {
                xx >>= 32;
                r <<= 16;
            }
            if (xx >= 0x10000) {
                xx >>= 16;
                r <<= 8;
            }
            if (xx >= 0x100) {
                xx >>= 8;
                r <<= 4;
            }
            if (xx >= 0x10) {
                xx >>= 4;
                r <<= 2;
            }
            if (xx >= 0x8) {
                r <<= 1;
            }
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1;
            r = (r + x / r) >> 1; // Seven iterations should be enough
            uint256 r1 = x / r;
            return uint256(r < r1 ? r : r1);
        }
    }
}

contract InvariantValidator is IInvariantValidator {

    uint256 internal constant A_PRECISION = 100;

    uint256 public immutable startTime;
    uint256 public immutable startingCap;
    uint256 public immutable capFactor;

    constructor(uint256 _startingCap, uint256 _capFactor) {
        startTime = block.timestamp;
        startingCap = _startingCap;
        capFactor = _capFactor;
    }


    function computeMint(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint256 _rawInput,
        InvariantConfig memory _config
    ) external view override returns (uint256 mintAmount) {

        (uint256[] memory x, uint256 sum) = _getReserves(_bAssets);
        uint256 k0 = _invariant(x, sum, _config.a);
        uint256 scaledInput = (_rawInput * _bAssets[_i].ratio) / 1e8;

        x[_i] += scaledInput;
        sum += scaledInput;
        require(_inBounds(x, sum, _config.limits), "Exceeds weight limits");
        mintAmount = _computeMintOutput(x, sum, k0, _config.a);
    }

    function computeMintMulti(
        BassetData[] calldata _bAssets,
        uint8[] calldata _indices,
        uint256[] calldata _rawInputs,
        InvariantConfig memory _config
    ) external view override returns (uint256 mintAmount) {

        (uint256[] memory x, uint256 sum) = _getReserves(_bAssets);
        uint256 k0 = _invariant(x, sum, _config.a);

        uint256 len = _indices.length;
        uint8 idx;
        uint256 scaledInput;
        for (uint256 i = 0; i < len; i++) {
            idx = _indices[i];
            scaledInput = (_rawInputs[i] * _bAssets[idx].ratio) / 1e8;
            x[idx] += scaledInput;
            sum += scaledInput;
        }
        require(_inBounds(x, sum, _config.limits), "Exceeds weight limits");
        mintAmount = _computeMintOutput(x, sum, k0, _config.a);
    }

    function computeSwap(
        BassetData[] calldata _bAssets,
        uint8 _i,
        uint8 _o,
        uint256 _rawInput,
        uint256 _feeRate,
        InvariantConfig memory _config
    ) external view override returns (uint256 bAssetOutputQuantity, uint256 scaledSwapFee) {

        (uint256[] memory x, uint256 sum) = _getReserves(_bAssets);
        uint256 k0 = _invariant(x, sum, _config.a);
        uint256 scaledInput = (_rawInput * _bAssets[_i].ratio) / 1e8;
        x[_i] += scaledInput;
        sum += scaledInput;
        uint256 k1 = _invariant(x, sum, _config.a);
        scaledSwapFee = ((k1 - k0) * _feeRate) / 1e18;
        uint256 newOutputReserve = _solveInvariant(x, _config.a, _o, k0 + scaledSwapFee);
        uint256 output = x[_o] - newOutputReserve - 1;
        bAssetOutputQuantity = (output * 1e8) / _bAssets[_o].ratio;
        x[_o] -= output;
        sum -= output;
        require(_inBounds(x, sum, _config.limits), "Exceeds weight limits");
    }

    function computeRedeem(
        BassetData[] calldata _bAssets,
        uint8 _o,
        uint256 _netMassetQuantity,
        InvariantConfig memory _config
    ) external view override returns (uint256 rawOutputUnits) {

        (uint256[] memory x, uint256 sum) = _getReserves(_bAssets);
        uint256 k0 = _invariant(x, sum, _config.a);
        uint256 newOutputReserve = _solveInvariant(x, _config.a, _o, k0 - _netMassetQuantity);
        uint256 output = x[_o] - newOutputReserve - 1;
        rawOutputUnits = (output * 1e8) / _bAssets[_o].ratio;
        x[_o] -= output;
        sum -= output;
        require(_inBounds(x, sum, _config.limits), "Exceeds weight limits");
    }

    function computeRedeemExact(
        BassetData[] calldata _bAssets,
        uint8[] calldata _indices,
        uint256[] calldata _rawOutputs,
        InvariantConfig memory _config
    ) external view override returns (uint256 totalmAssets) {

        (uint256[] memory x, uint256 sum) = _getReserves(_bAssets);
        uint256 k0 = _invariant(x, sum, _config.a);
        uint256 len = _indices.length;
        uint256 ratioed;
        for (uint256 i = 0; i < len; i++) {
            ratioed = (_rawOutputs[i] * _bAssets[_indices[i]].ratio) / 1e8;
            x[_indices[i]] -= ratioed;
            sum -= ratioed;
        }
        require(_inBounds(x, sum, _config.limits), "Exceeds weight limits");
        uint256 k1 = _invariant(x, sum, _config.a);
        totalmAssets = k0 - k1;
    }


    function _computeMintOutput(
        uint256[] memory _x,
        uint256 _sum,
        uint256 _k,
        uint256 _a
    ) internal view returns (uint256 mintAmount) {

        uint256 kFinal = _invariant(_x, _sum, _a);
        uint256 weeksSinceLaunch = ((block.timestamp - startTime) * 1e18) / 604800;
        if (weeksSinceLaunch < 7e18) {
            uint256 maxK = startingCap + ((capFactor * (weeksSinceLaunch**2)) / 1e36);
            require(kFinal <= maxK, "Cannot exceed TVL cap");
        }
        mintAmount = kFinal - _k;
    }

    function _getReserves(BassetData[] memory _bAssets)
        internal
        pure
        returns (uint256[] memory x, uint256 sum)
    {

        uint256 len = _bAssets.length;
        x = new uint256[](len);
        uint256 r;
        for (uint256 i = 0; i < len; i++) {
            BassetData memory bAsset = _bAssets[i];
            r = (bAsset.vaultBalance * bAsset.ratio) / 1e8;
            x[i] = r;
            sum += r;
        }
    }

    function _inBounds(
        uint256[] memory _x,
        uint256 _sum,
        WeightLimits memory _limits
    ) internal pure returns (bool inBounds) {

        uint256 len = _x.length;
        inBounds = true;
        uint256 w;
        for (uint256 i = 0; i < len; i++) {
            w = (_x[i] * 1e18) / _sum;
            if (w > _limits.max || w < _limits.min) return false;
        }
    }


    function _invariant(
        uint256[] memory _x,
        uint256 _sum,
        uint256 _a
    ) internal pure returns (uint256 k) {

        uint256 len = _x.length;

        if (_sum == 0) return 0;

        uint256 nA = _a * len;
        uint256 kPrev;
        k = _sum;

        for (uint256 i = 0; i < 256; i++) {
            uint256 kP = k;
            for (uint256 j = 0; j < len; j++) {
                kP = (kP * k) / (_x[j] * len);
            }
            kPrev = k;
            k =
                (((nA * _sum) / A_PRECISION + (kP * len)) * k) /
                (((nA - A_PRECISION) * k) / A_PRECISION + ((len + 1) * kP));
            if (_hasConverged(k, kPrev)) {
                return k;
            }
        }

        revert("Invariant did not converge");
    }

    function _hasConverged(uint256 _k, uint256 _kPrev) internal pure returns (bool) {

        if (_kPrev > _k) {
            return (_kPrev - _k) <= 1;
        } else {
            return (_k - _kPrev) <= 1;
        }
    }

    function _solveInvariant(
        uint256[] memory _x,
        uint256 _a,
        uint8 _idx,
        uint256 _targetK
    ) internal pure returns (uint256 y) {

        uint256 len = _x.length;
        require(_idx >= 0 && _idx < len, "Invalid index");

        (uint256 sum_, uint256 nA, uint256 kP) = (0, _a * len, _targetK);

        for (uint256 i = 0; i < len; i++) {
            if (i != _idx) {
                sum_ += _x[i];
                kP = (kP * _targetK) / (_x[i] * len);
            }
        }

        uint256 c = (((kP * _targetK) * A_PRECISION) / nA) / len;
        uint256 g = (_targetK * (nA - A_PRECISION)) / nA;
        uint256 b = 0;

        if (g > sum_) {
            b = g - sum_;
            y = (Root.sqrt((b**2) + (4 * c)) + b) / 2 + 1;
        } else {
            b = sum_ - g;
            y = (Root.sqrt((b**2) + (4 * c)) - b) / 2 + 1;
        }

        if (y < 1e8) revert("Invalid solution");
    }
}