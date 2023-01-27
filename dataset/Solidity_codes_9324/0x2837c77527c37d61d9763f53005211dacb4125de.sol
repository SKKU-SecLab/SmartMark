
pragma solidity 0.8.2;


interface IPlatformIntegration {

    function deposit(
        address _bAsset,
        uint256 _amount,
        bool isTokenFeeCharged
    ) external returns (uint256 quantityDeposited);


    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        bool _hasTxFee
    ) external;


    function withdraw(
        address _receiver,
        address _bAsset,
        uint256 _amount,
        uint256 _totalAmount,
        bool _hasTxFee
    ) external;


    function withdrawRaw(
        address _receiver,
        address _bAsset,
        uint256 _amount
    ) external;


    function checkBalance(address _bAsset) external returns (uint256 balance);


    function bAssetToPToken(address _bAsset) external returns (address pToken);

}

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

abstract contract IMasset {
    function mint(
        address _input,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function mintMulti(
        address[] calldata _inputs,
        uint256[] calldata _inputQuantities,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 mintOutput);

    function getMintOutput(address _input, uint256 _inputQuantity)
        external
        view
        virtual
        returns (uint256 mintOutput);

    function getMintMultiOutput(address[] calldata _inputs, uint256[] calldata _inputQuantities)
        external
        view
        virtual
        returns (uint256 mintOutput);

    function swap(
        address _input,
        address _output,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 swapOutput);

    function getSwapOutput(
        address _input,
        address _output,
        uint256 _inputQuantity
    ) external view virtual returns (uint256 swapOutput);

    function redeem(
        address _output,
        uint256 _mAssetQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external virtual returns (uint256 outputQuantity);

    function redeemMasset(
        uint256 _mAssetQuantity,
        uint256[] calldata _minOutputQuantities,
        address _recipient
    ) external virtual returns (uint256[] memory outputQuantities);

    function redeemExactBassets(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities,
        uint256 _maxMassetQuantity,
        address _recipient
    ) external virtual returns (uint256 mAssetRedeemed);

    function getRedeemOutput(address _output, uint256 _mAssetQuantity)
        external
        view
        virtual
        returns (uint256 bAssetOutput);

    function getRedeemExactBassetsOutput(
        address[] calldata _outputs,
        uint256[] calldata _outputQuantities
    ) external view virtual returns (uint256 mAssetAmount);

    function getBasket() external view virtual returns (bool, bool);

    function getBasset(address _token)
        external
        view
        virtual
        returns (BassetPersonal memory personal, BassetData memory data);

    function getBassets()
        external
        view
        virtual
        returns (BassetPersonal[] memory personal, BassetData[] memory data);

    function bAssetIndexes(address) external view virtual returns (uint8);

    function collectInterest() external virtual returns (uint256 swapFeesGained, uint256 newSupply);

    function collectPlatformInterest()
        external
        virtual
        returns (uint256 mintAmount, uint256 newSupply);

    function setCacheSize(uint256 _cacheSize) external virtual;

    function upgradeForgeValidator(address _newForgeValidator) external virtual;

    function setFees(uint256 _swapFee, uint256 _redemptionFee) external virtual;

    function setTransferFeesFlag(address _bAsset, bool _flag) external virtual;

    function migrateBassets(address[] calldata _bAssets, address _newIntegration) external virtual;
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

struct FeederConfig {
    uint256 supply;
    uint256 a;
    WeightLimits limits;
}

struct AmpData {
    uint64 initialA;
    uint64 targetA;
    uint64 rampStartTime;
    uint64 rampEndTime;
}

struct FeederData {
    uint256 swapFee;
    uint256 redemptionFee;
    uint256 govFee;
    uint256 pendingFees;
    uint256 cacheSize;
    BassetPersonal[] bAssetPersonal;
    BassetData[] bAssetData;
    AmpData ampData;
    WeightLimits weightLimits;
}

struct AssetData {
    uint8 idx;
    uint256 amt;
    BassetPersonal personal;
}

struct Asset {
    uint8 idx;
    address addr;
    bool exists;
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

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {

    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

library MassetHelpers {

    using SafeERC20 for IERC20;

    function transferReturnBalance(
        address _sender,
        address _recipient,
        address _bAsset,
        uint256 _qty
    ) internal returns (uint256 receivedQty, uint256 recipientBalance) {

        uint256 balBefore = IERC20(_bAsset).balanceOf(_recipient);
        IERC20(_bAsset).safeTransferFrom(_sender, _recipient, _qty);
        recipientBalance = IERC20(_bAsset).balanceOf(_recipient);
        receivedQty = recipientBalance - balBefore;
    }

    function safeInfiniteApprove(address _asset, address _spender) internal {

        IERC20(_asset).safeApprove(_spender, 0);
        IERC20(_asset).safeApprove(_spender, 2**256 - 1);
    }
}

library StableMath {

    uint256 private constant FULL_SCALE = 1e18;

    uint256 private constant RATIO_SCALE = 1e8;

    function getFullScale() internal pure returns (uint256) {

        return FULL_SCALE;
    }

    function getRatioScale() internal pure returns (uint256) {

        return RATIO_SCALE;
    }

    function scaleInteger(uint256 x) internal pure returns (uint256) {

        return x * FULL_SCALE;
    }


    function mulTruncate(uint256 x, uint256 y) internal pure returns (uint256) {

        return mulTruncateScale(x, y, FULL_SCALE);
    }

    function mulTruncateScale(
        uint256 x,
        uint256 y,
        uint256 scale
    ) internal pure returns (uint256) {

        return (x * y) / scale;
    }

    function mulTruncateCeil(uint256 x, uint256 y) internal pure returns (uint256) {

        uint256 scaled = x * y;
        uint256 ceil = scaled + FULL_SCALE - 1;
        return ceil / FULL_SCALE;
    }

    function divPrecisely(uint256 x, uint256 y) internal pure returns (uint256) {

        return (x * FULL_SCALE) / y;
    }


    function mulRatioTruncate(uint256 x, uint256 ratio) internal pure returns (uint256 c) {

        return mulTruncateScale(x, ratio, RATIO_SCALE);
    }

    function mulRatioTruncateCeil(uint256 x, uint256 ratio) internal pure returns (uint256) {

        uint256 scaled = x * ratio;
        uint256 ceil = scaled + RATIO_SCALE - 1;
        return ceil / RATIO_SCALE;
    }

    function divRatioPrecisely(uint256 x, uint256 ratio) internal pure returns (uint256 c) {

        return (x * RATIO_SCALE) / ratio;
    }


    function min(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? y : x;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256) {

        return x > y ? x : y;
    }

    function clamp(uint256 x, uint256 upperBound) internal pure returns (uint256) {

        return x > upperBound ? upperBound : x;
    }
}

library FeederLogic {

    using StableMath for uint256;
    using SafeERC20 for IERC20;

    uint256 internal constant A_PRECISION = 100;


    function mint(
        FeederData storage _data,
        FeederConfig calldata _config,
        Asset calldata _input,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity
    ) external returns (uint256 mintOutput) {

        BassetData[] memory cachedBassetData = _data.bAssetData;
        AssetData memory inputData =
            _transferIn(_data, _config, cachedBassetData, _input, _inputQuantity);
        mintOutput = computeMint(cachedBassetData, inputData.idx, inputData.amt, _config);
        require(mintOutput >= _minOutputQuantity, "Mint quantity < min qty");
    }

    function mintMulti(
        FeederData storage _data,
        FeederConfig calldata _config,
        uint8[] calldata _indices,
        uint256[] calldata _inputQuantities,
        uint256 _minOutputQuantity
    ) external returns (uint256 mintOutput) {

        uint256 len = _indices.length;
        uint256[] memory quantitiesDeposited = new uint256[](len);
        BassetData[] memory allBassets = _data.bAssetData;
        uint256 maxCache = _getCacheDetails(_data, _config.supply);
        for (uint256 i = 0; i < len; i++) {
            if (_inputQuantities[i] > 0) {
                uint8 idx = _indices[i];
                BassetData memory bData = allBassets[idx];
                quantitiesDeposited[i] = _depositTokens(
                    _data.bAssetPersonal[idx],
                    bData.ratio,
                    _inputQuantities[i],
                    maxCache
                );

                _data.bAssetData[idx].vaultBalance =
                    bData.vaultBalance +
                    SafeCast.toUint128(quantitiesDeposited[i]);
            }
        }
        mintOutput = computeMintMulti(allBassets, _indices, quantitiesDeposited, _config);
        require(mintOutput >= _minOutputQuantity, "Mint quantity < min qty");
        require(mintOutput > 0, "Zero mAsset quantity");
    }


    function swap(
        FeederData storage _data,
        FeederConfig calldata _config,
        Asset calldata _input,
        Asset calldata _output,
        uint256 _inputQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external returns (uint256 swapOutput, uint256 localFee) {

        BassetData[] memory cachedBassetData = _data.bAssetData;

        AssetData memory inputData =
            _transferIn(_data, _config, cachedBassetData, _input, _inputQuantity);
        if (_output.exists) {
            (swapOutput, localFee) = _swapLocal(
                _data,
                _config,
                cachedBassetData,
                inputData,
                _output,
                _minOutputQuantity,
                _recipient
            );
        }
        else {
            address mAsset = _data.bAssetPersonal[0].addr;
            (swapOutput, localFee) = _swapLocal(
                _data,
                _config,
                cachedBassetData,
                inputData,
                Asset(0, mAsset, true),
                0,
                address(this)
            );
            swapOutput = IMasset(mAsset).redeem(
                _output.addr,
                swapOutput,
                _minOutputQuantity,
                _recipient
            );
        }
    }


    function redeem(
        FeederData storage _data,
        FeederConfig calldata _config,
        Asset calldata _output,
        uint256 _fpTokenQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) external returns (uint256 outputQuantity, uint256 localFee) {

        if (_output.exists) {
            (outputQuantity, localFee) = _redeemLocal(
                _data,
                _config,
                _output,
                _fpTokenQuantity,
                _minOutputQuantity,
                _recipient
            );
        } else {
            address mAsset = _data.bAssetPersonal[0].addr;
            (outputQuantity, localFee) = _redeemLocal(
                _data,
                _config,
                Asset(0, mAsset, true),
                _fpTokenQuantity,
                0,
                address(this)
            );
            outputQuantity = IMasset(mAsset).redeem(
                _output.addr,
                outputQuantity,
                _minOutputQuantity,
                _recipient
            );
        }
    }

    function redeemProportionately(
        FeederData storage _data,
        FeederConfig calldata _config,
        uint256 _inputQuantity,
        uint256[] calldata _minOutputQuantities,
        address _recipient
    )
        external
        returns (
            uint256 scaledFee,
            address[] memory outputs,
            uint256[] memory outputQuantities
        )
    {

        scaledFee = _inputQuantity.mulTruncate(_data.redemptionFee);
        uint256 maxCache = _getCacheDetails(_data, _config.supply - _inputQuantity);

        BassetData[] memory allBassets = _data.bAssetData;
        uint256 len = allBassets.length;
        outputs = new address[](len);
        outputQuantities = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            uint256 amountOut =
                (allBassets[i].vaultBalance * (_inputQuantity - scaledFee)) / _config.supply;
            require(amountOut > 1, "Output == 0");
            amountOut -= 1;
            require(amountOut >= _minOutputQuantities[i], "bAsset qty < min qty");
            (outputQuantities[i], outputs[i]) = (amountOut, _data.bAssetPersonal[i].addr);
            _withdrawTokens(
                amountOut,
                _data.bAssetPersonal[i],
                allBassets[i],
                _recipient,
                maxCache
            );
            _data.bAssetData[i].vaultBalance =
                allBassets[i].vaultBalance -
                SafeCast.toUint128(amountOut);
        }
    }

    function redeemExactBassets(
        FeederData storage _data,
        FeederConfig memory _config,
        uint8[] calldata _indices,
        uint256[] calldata _outputQuantities,
        uint256 _maxInputQuantity,
        address _recipient
    ) external returns (uint256 fpTokenQuantity, uint256 localFee) {

        BassetData[] memory allBassets = _data.bAssetData;

        uint256 fpTokenRequired =
            computeRedeemExact(allBassets, _indices, _outputQuantities, _config);
        fpTokenQuantity = fpTokenRequired.divPrecisely(1e18 - _data.redemptionFee);
        localFee = fpTokenQuantity - fpTokenRequired;
        require(fpTokenQuantity > 0, "Must redeem some mAssets");
        fpTokenQuantity += 1;
        require(fpTokenQuantity <= _maxInputQuantity, "Redeem mAsset qty > max quantity");

        uint256 maxCache = _getCacheDetails(_data, _config.supply - fpTokenQuantity);
        for (uint256 i = 0; i < _outputQuantities.length; i++) {
            _withdrawTokens(
                _outputQuantities[i],
                _data.bAssetPersonal[_indices[i]],
                allBassets[_indices[i]],
                _recipient,
                maxCache
            );
            _data.bAssetData[_indices[i]].vaultBalance =
                allBassets[_indices[i]].vaultBalance -
                SafeCast.toUint128(_outputQuantities[i]);
        }
    }


    function _transferIn(
        FeederData storage _data,
        FeederConfig memory _config,
        BassetData[] memory _cachedBassetData,
        Asset memory _input,
        uint256 _inputQuantity
    ) internal returns (AssetData memory inputData) {

        if (_input.exists) {
            BassetPersonal memory personal = _data.bAssetPersonal[_input.idx];
            uint256 amt =
                _depositTokens(
                    personal,
                    _cachedBassetData[_input.idx].ratio,
                    _inputQuantity,
                    _getCacheDetails(_data, _config.supply)
                );
            inputData = AssetData(_input.idx, amt, personal);
        }
        else {
            inputData = _mpMint(
                _data,
                _input,
                _inputQuantity,
                _getCacheDetails(_data, _config.supply)
            );
            require(inputData.amt > 0, "Must mint something from mp");
        }
        _data.bAssetData[inputData.idx].vaultBalance =
            _cachedBassetData[inputData.idx].vaultBalance +
            SafeCast.toUint128(inputData.amt);
    }

    function _mpMint(
        FeederData storage _data,
        Asset memory _input,
        uint256 _inputQuantity,
        uint256 _maxCache
    ) internal returns (AssetData memory mAssetData) {

        mAssetData = AssetData(0, 0, _data.bAssetPersonal[0]);
        IERC20(_input.addr).safeTransferFrom(msg.sender, address(this), _inputQuantity);

        address integrator =
            mAssetData.personal.integrator == address(0)
                ? address(this)
                : mAssetData.personal.integrator;

        uint256 balBefore = IERC20(mAssetData.personal.addr).balanceOf(integrator);
        IMasset(mAssetData.personal.addr).mint(_input.addr, _inputQuantity, 0, integrator);
        uint256 balAfter = IERC20(mAssetData.personal.addr).balanceOf(integrator);
        mAssetData.amt = balAfter - balBefore;

        if (integrator != address(this)) {
            if (balAfter > _maxCache) {
                uint256 delta = balAfter - (_maxCache / 2);
                IPlatformIntegration(integrator).deposit(mAssetData.personal.addr, delta, false);
            }
        }
    }

    function _swapLocal(
        FeederData storage _data,
        FeederConfig memory _config,
        BassetData[] memory _cachedBassetData,
        AssetData memory _inputData,
        Asset memory _output,
        uint256 _minOutputQuantity,
        address _recipient
    ) internal returns (uint256 swapOutput, uint256 scaledFee) {

        (swapOutput, scaledFee) = computeSwap(
            _cachedBassetData,
            _inputData.idx,
            _output.idx,
            _inputData.amt,
            _output.idx == 0 ? 0 : _data.swapFee,
            _config
        );
        require(swapOutput >= _minOutputQuantity, "Output qty < minimum qty");
        require(swapOutput > 0, "Zero output quantity");
        _withdrawTokens(
            swapOutput,
            _data.bAssetPersonal[_output.idx],
            _cachedBassetData[_output.idx],
            _recipient,
            _getCacheDetails(_data, _config.supply)
        );
        _data.bAssetData[_output.idx].vaultBalance =
            _cachedBassetData[_output.idx].vaultBalance -
            SafeCast.toUint128(swapOutput);
    }

    function _redeemLocal(
        FeederData storage _data,
        FeederConfig memory _config,
        Asset memory _output,
        uint256 _fpTokenQuantity,
        uint256 _minOutputQuantity,
        address _recipient
    ) internal returns (uint256 outputQuantity, uint256 scaledFee) {

        BassetData[] memory allBassets = _data.bAssetData;
        scaledFee = _fpTokenQuantity.mulTruncate(_data.redemptionFee);
        outputQuantity = computeRedeem(
            allBassets,
            _output.idx,
            _fpTokenQuantity - scaledFee,
            _config
        );
        require(outputQuantity >= _minOutputQuantity, "bAsset qty < min qty");
        require(outputQuantity > 0, "Output == 0");

        _withdrawTokens(
            outputQuantity,
            _data.bAssetPersonal[_output.idx],
            allBassets[_output.idx],
            _recipient,
            _getCacheDetails(_data, _config.supply - _fpTokenQuantity)
        );
        _data.bAssetData[_output.idx].vaultBalance =
            allBassets[_output.idx].vaultBalance -
            SafeCast.toUint128(outputQuantity);
    }

    function _depositTokens(
        BassetPersonal memory _bAsset,
        uint256 _bAssetRatio,
        uint256 _quantity,
        uint256 _maxCache
    ) internal returns (uint256 quantityDeposited) {

        if (_bAsset.integrator == address(0)) {
            (uint256 received, ) =
                MassetHelpers.transferReturnBalance(
                    msg.sender,
                    address(this),
                    _bAsset.addr,
                    _quantity
                );
            return received;
        }

        uint256 cacheBal;
        (quantityDeposited, cacheBal) = MassetHelpers.transferReturnBalance(
            msg.sender,
            _bAsset.integrator,
            _bAsset.addr,
            _quantity
        );

        if (_bAsset.hasTxFee) {
            uint256 deposited =
                IPlatformIntegration(_bAsset.integrator).deposit(
                    _bAsset.addr,
                    quantityDeposited,
                    true
                );

            return StableMath.min(deposited, quantityDeposited);
        }
        require(quantityDeposited == _quantity, "Asset not fully transferred");

        uint256 relativeMaxCache = _maxCache.divRatioPrecisely(_bAssetRatio);

        if (cacheBal > relativeMaxCache) {
            uint256 delta = cacheBal - (relativeMaxCache / 2);
            IPlatformIntegration(_bAsset.integrator).deposit(_bAsset.addr, delta, false);
        }
    }

    function _withdrawTokens(
        uint256 _quantity,
        BassetPersonal memory _personal,
        BassetData memory _data,
        address _recipient,
        uint256 _maxCache
    ) internal {

        if (_quantity == 0) return;

        if (_personal.integrator == address(0)) {
            if (_recipient == address(this)) return;
            IERC20(_personal.addr).safeTransfer(_recipient, _quantity);
        }
        else if (_personal.hasTxFee) {
            IPlatformIntegration(_personal.integrator).withdraw(
                _recipient,
                _personal.addr,
                _quantity,
                _quantity,
                true
            );
        }
        else {
            uint256 cacheBal = IERC20(_personal.addr).balanceOf(_personal.integrator);
            if (cacheBal >= _quantity) {
                IPlatformIntegration(_personal.integrator).withdrawRaw(
                    _recipient,
                    _personal.addr,
                    _quantity
                );
            }
            else {
                uint256 relativeMidCache = _maxCache.divRatioPrecisely(_data.ratio) / 2;
                uint256 totalWithdrawal =
                    StableMath.min(
                        relativeMidCache + _quantity - cacheBal,
                        _data.vaultBalance - SafeCast.toUint128(cacheBal)
                    );

                IPlatformIntegration(_personal.integrator).withdraw(
                    _recipient,
                    _personal.addr,
                    _quantity,
                    totalWithdrawal,
                    false
                );
            }
        }
    }

    function _getCacheDetails(FeederData storage _data, uint256 _supply)
        internal
        view
        returns (uint256 maxCache)
    {

        maxCache = (_supply * _data.cacheSize) / 1e18;
    }


    function computeMint(
        BassetData[] memory _bAssets,
        uint8 _i,
        uint256 _rawInput,
        FeederConfig memory _config
    ) public pure returns (uint256 mintAmount) {

        (uint256[] memory x, uint256 sum) = _getReserves(_bAssets);
        uint256 k0 = _invariant(x, sum, _config.a);
        uint256 scaledInput = (_rawInput * _bAssets[_i].ratio) / 1e8;
        require(scaledInput > 1e6, "Must add > 1e6 units");
        x[_i] += scaledInput;
        sum += scaledInput;
        require(_inBounds(x, sum, _config.limits), "Exceeds weight limits");
        mintAmount = _computeMintOutput(x, sum, k0, _config);
    }

    function computeMintMulti(
        BassetData[] memory _bAssets,
        uint8[] memory _indices,
        uint256[] memory _rawInputs,
        FeederConfig memory _config
    ) public pure returns (uint256 mintAmount) {

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
        mintAmount = _computeMintOutput(x, sum, k0, _config);
    }

    function computeSwap(
        BassetData[] memory _bAssets,
        uint8 _i,
        uint8 _o,
        uint256 _rawInput,
        uint256 _feeRate,
        FeederConfig memory _config
    ) public pure returns (uint256 bAssetOutputQuantity, uint256 scaledSwapFee) {

        (uint256[] memory x, uint256 sum) = _getReserves(_bAssets);
        uint256 k0 = _invariant(x, sum, _config.a);
        uint256 scaledInput = (_rawInput * _bAssets[_i].ratio) / 1e8;
        require(scaledInput > 1e6, "Must add > 1e6 units");
        x[_i] += scaledInput;
        sum += scaledInput;
        uint256 k1 = _invariant(x, sum, _config.a);
        scaledSwapFee = ((k1 - k0) * _feeRate) / 1e18;
        uint256 newOutputReserve = _solveInvariant(x, _config.a, _o, k0 + scaledSwapFee);
        scaledSwapFee = (scaledSwapFee * _config.supply) / k0;
        uint256 output = x[_o] - newOutputReserve - 1;
        bAssetOutputQuantity = (output * 1e8) / _bAssets[_o].ratio;
        x[_o] -= output;
        sum -= output;
        require(_inBounds(x, sum, _config.limits), "Exceeds weight limits");
    }

    function computeRedeem(
        BassetData[] memory _bAssets,
        uint8 _o,
        uint256 _netRedeemInput,
        FeederConfig memory _config
    ) public pure returns (uint256 rawOutputUnits) {

        require(_netRedeemInput > 1e6, "Must redeem > 1e6 units");
        (uint256[] memory x, uint256 sum) = _getReserves(_bAssets);
        uint256 k0 = _invariant(x, sum, _config.a);
        uint256 kFinal = (k0 * (_config.supply - _netRedeemInput)) / _config.supply + 1;
        uint256 newOutputReserve = _solveInvariant(x, _config.a, _o, kFinal);
        uint256 output = x[_o] - newOutputReserve - 1;
        rawOutputUnits = (output * 1e8) / _bAssets[_o].ratio;
        x[_o] -= output;
        sum -= output;
        require(_inBounds(x, sum, _config.limits), "Exceeds weight limits");
    }

    function computeRedeemExact(
        BassetData[] memory _bAssets,
        uint8[] memory _indices,
        uint256[] memory _rawOutputs,
        FeederConfig memory _config
    ) public pure returns (uint256 redeemInput) {

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
        redeemInput = (_config.supply * (k0 - k1)) / k0;
        require(redeemInput > 1e6, "Must redeem > 1e6 units");
    }

    function computePrice(BassetData[] memory _bAssets, FeederConfig memory _config)
        public
        pure
        returns (uint256 price, uint256 k)
    {

        (uint256[] memory x, uint256 sum) = _getReserves(_bAssets);
        k = _invariant(x, sum, _config.a);
        price = (1e18 * k) / _config.supply;
    }


    function _computeMintOutput(
        uint256[] memory _x,
        uint256 _sum,
        uint256 _k,
        FeederConfig memory _config
    ) internal pure returns (uint256 mintAmount) {

        uint256 kFinal = _invariant(_x, _sum, _config.a);
        if (_config.supply == 0) {
            mintAmount = kFinal - _k;
        } else {
            mintAmount = (_config.supply * (kFinal - _k)) / _k;
        }
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

        if (_sum == 0) return 0;

        uint256 var1 = _x[0] * _x[1];
        uint256 var2 = (_a * var1) / (_x[0] + _x[1]) / A_PRECISION;
        k = 2 * (Root.sqrt((var2**2) + (((_a + A_PRECISION) * var1) / A_PRECISION)) - var2) + 1;
    }

    function _solveInvariant(
        uint256[] memory _x,
        uint256 _a,
        uint8 _idx,
        uint256 _targetK
    ) internal pure returns (uint256 y) {

        require(_idx == 0 || _idx == 1, "Invalid index");

        uint256 x = _idx == 0 ? _x[1] : _x[0];
        uint256 var1 = _a + A_PRECISION;
        uint256 var2 = ((_targetK**2) * A_PRECISION) / var1;
        uint256 tmp = var2 / (4 * x) + ((_targetK * _a) / var1);
        uint256 var3 = tmp >= x ? tmp - x : x - tmp;
        y = ((Root.sqrt((var3**2) + var2) + tmp - x) / 2) + 1;
    }
}