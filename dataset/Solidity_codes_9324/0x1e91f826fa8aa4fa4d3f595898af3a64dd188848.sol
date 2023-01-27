
pragma solidity 0.8.0;
pragma abicoder v2;


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

interface IBasicToken {

    function decimals() external view returns (uint8);

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

        uint256 newAllowance = token.allowance(address(this), spender) - value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
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

library Manager {

    using SafeERC20 for IERC20;
    using StableMath for uint256;

    event BassetsMigrated(address[] bAssets, address newIntegrator);
    event TransferFeeEnabled(address indexed bAsset, bool enabled);
    event BassetAdded(address indexed bAsset, address integrator);
    event BassetStatusChanged(address indexed bAsset, MassetStructs.BassetStatus status);
    event BasketStatusChanged();
    event StartRampA(uint256 currentA, uint256 targetA, uint256 startTime, uint256 rampEndTime);
    event StopRampA(uint256 currentA, uint256 time);

    uint256 private constant MIN_RAMP_TIME = 1 days;
    uint256 private constant MAX_A = 1e6;

    function addBasset(
        MassetStructs.BassetPersonal[] storage _bAssetPersonal,
        MassetStructs.BassetData[] storage _bAssetData,
        mapping(address => uint8) storage _bAssetIndexes,
        uint8 _maxBassets,
        address _bAsset,
        address _integration,
        uint256 _mm,
        bool _hasTxFee
    ) external {

        require(_bAsset != address(0), "bAsset address must be valid");
        uint8 bAssetCount = uint8(_bAssetPersonal.length);
        require(bAssetCount < _maxBassets, "Max bAssets in Basket");

        uint8 idx = _bAssetIndexes[_bAsset];
        require(
            bAssetCount == 0 || _bAssetPersonal[idx].addr != _bAsset,
            "bAsset already exists in Basket"
        );

        if (_integration != address(0)) {
            IPlatformIntegration(_integration).checkBalance(_bAsset);
        }

        uint256 bAssetDecimals = IBasicToken(_bAsset).decimals();
        require(
            bAssetDecimals >= 4 && bAssetDecimals <= 18,
            "Token must have sufficient decimal places"
        );

        uint256 delta = uint256(18) - bAssetDecimals;
        uint256 ratio = _mm * (10**delta);

        _bAssetIndexes[_bAsset] = bAssetCount;

        _bAssetPersonal.push(
            MassetStructs.BassetPersonal({
                addr: _bAsset,
                integrator: _integration,
                hasTxFee: _hasTxFee,
                status: MassetStructs.BassetStatus.Normal
            })
        );
        _bAssetData.push(
            MassetStructs.BassetData({ ratio: SafeCast.toUint128(ratio), vaultBalance: 0 })
        );

        emit BassetAdded(_bAsset, _integration);
    }

    function collectPlatformInterest(
        MassetStructs.BassetPersonal[] memory _bAssetPersonal,
        MassetStructs.BassetData[] storage _bAssetData,
        IInvariantValidator _forgeValidator,
        MassetStructs.InvariantConfig memory _config
    ) external returns (uint256 mintAmount, uint256[] memory rawGains) {

        MassetStructs.BassetData[] memory bAssetData_ = _bAssetData;
        uint256 count = bAssetData_.length;
        uint8[] memory indices = new uint8[](count);
        rawGains = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            indices[i] = uint8(i);
            MassetStructs.BassetPersonal memory bPersonal = _bAssetPersonal[i];
            MassetStructs.BassetData memory bData = bAssetData_[i];
            if (bPersonal.integrator == address(0)) continue;
            uint256 lending =
                IPlatformIntegration(bPersonal.integrator).checkBalance(bPersonal.addr);
            uint256 cache = 0;
            if (!bPersonal.hasTxFee) {
                cache = IERC20(bPersonal.addr).balanceOf(bPersonal.integrator);
            }
            uint256 balance = lending + cache;
            uint256 oldVaultBalance = bData.vaultBalance;
            if (
                balance > oldVaultBalance && bPersonal.status == MassetStructs.BassetStatus.Normal
            ) {
                _bAssetData[i].vaultBalance = SafeCast.toUint128(balance);
                uint256 interestDelta = balance - oldVaultBalance;
                rawGains[i] = interestDelta;
            } else {
                rawGains[i] = 0;
            }
        }
        mintAmount = _forgeValidator.computeMintMulti(bAssetData_, indices, rawGains, _config);
    }

    function setTransferFeesFlag(
        MassetStructs.BassetPersonal[] storage _bAssetPersonal,
        mapping(address => uint8) storage _bAssetIndexes,
        address _bAsset,
        bool _flag
    ) external {

        uint256 index = _getAssetIndex(_bAssetPersonal, _bAssetIndexes, _bAsset);
        _bAssetPersonal[index].hasTxFee = _flag;

        if (_flag) {
            address integration = _bAssetPersonal[index].integrator;
            if (integration != address(0)) {
                uint256 bal = IERC20(_bAsset).balanceOf(integration);
                if (bal > 0) {
                    IPlatformIntegration(integration).deposit(_bAsset, bal, true);
                }
            }
        }

        emit TransferFeeEnabled(_bAsset, _flag);
    }

    function migrateBassets(
        MassetStructs.BassetPersonal[] storage _bAssetPersonal,
        mapping(address => uint8) storage _bAssetIndexes,
        address[] calldata _bAssets,
        address _newIntegration
    ) external {

        uint256 len = _bAssets.length;
        require(len > 0, "Must migrate some bAssets");

        for (uint256 i = 0; i < len; i++) {
            address bAsset = _bAssets[i];
            uint256 index = _getAssetIndex(_bAssetPersonal, _bAssetIndexes, bAsset);
            require(!_bAssetPersonal[index].hasTxFee, "A bAsset has a transfer fee");

            address oldAddress = _bAssetPersonal[index].integrator;
            require(oldAddress != _newIntegration, "Must transfer to new integrator");
            (uint256 cache, uint256 lendingBal) = (0, 0);
            if (oldAddress == address(0)) {
                cache = IERC20(bAsset).balanceOf(address(this));
            } else {
                IPlatformIntegration oldIntegration = IPlatformIntegration(oldAddress);
                cache = IERC20(bAsset).balanceOf(address(oldIntegration));
                lendingBal = oldIntegration.checkBalance(bAsset);
                if (lendingBal > 0) {
                    oldIntegration.withdraw(address(this), bAsset, lendingBal, false);
                }
                if (cache > 0) {
                    oldIntegration.withdrawRaw(address(this), bAsset, cache);
                }
            }
            uint256 sum = lendingBal + cache;

            _bAssetPersonal[index].integrator = _newIntegration;

            IERC20(bAsset).safeTransfer(_newIntegration, sum);
            IPlatformIntegration newIntegration = IPlatformIntegration(_newIntegration);
            if (lendingBal > 0) {
                newIntegration.deposit(bAsset, lendingBal, false);
            }
            uint256 newLendingBal = newIntegration.checkBalance(bAsset);
            uint256 newCache = IERC20(bAsset).balanceOf(address(newIntegration));
            uint256 upperMargin = 10001e14;
            uint256 lowerMargin = 9999e14;

            require(
                newLendingBal >= lendingBal.mulTruncate(lowerMargin) &&
                    newLendingBal <= lendingBal.mulTruncate(upperMargin),
                "Must transfer full amount"
            );
            require(
                newCache >= cache.mulTruncate(lowerMargin) &&
                    newCache <= cache.mulTruncate(upperMargin),
                "Must transfer full amount"
            );
        }

        emit BassetsMigrated(_bAssets, _newIntegration);
    }

    function handlePegLoss(
        MassetStructs.BasketState storage _basket,
        MassetStructs.BassetPersonal[] storage _bAssetPersonal,
        mapping(address => uint8) storage _bAssetIndexes,
        address _bAsset,
        bool _belowPeg
    ) external {

        require(!_basket.failed, "Basket must be alive");

        uint256 i = _getAssetIndex(_bAssetPersonal, _bAssetIndexes, _bAsset);

        MassetStructs.BassetStatus newStatus =
            _belowPeg
                ? MassetStructs.BassetStatus.BrokenBelowPeg
                : MassetStructs.BassetStatus.BrokenAbovePeg;
        _bAssetPersonal[i].status = newStatus;

        _basket.undergoingRecol = true;

        emit BassetStatusChanged(_bAsset, newStatus);
    }

    function negateIsolation(
        MassetStructs.BasketState storage _basket,
        MassetStructs.BassetPersonal[] storage _bAssetPersonal,
        mapping(address => uint8) storage _bAssetIndexes,
        address _bAsset
    ) external {

        uint256 i = _getAssetIndex(_bAssetPersonal, _bAssetIndexes, _bAsset);

        _bAssetPersonal[i].status = MassetStructs.BassetStatus.Normal;

        bool undergoingRecol = false;
        for (uint256 j = 0; j < _bAssetPersonal.length; j++) {
            if (_bAssetPersonal[j].status != MassetStructs.BassetStatus.Normal) {
                undergoingRecol = true;
                break;
            }
        }
        _basket.undergoingRecol = undergoingRecol;

        emit BassetStatusChanged(_bAsset, MassetStructs.BassetStatus.Normal);
    }

    function startRampA(
        MassetStructs.AmpData storage _ampData,
        uint256 _targetA,
        uint256 _rampEndTime,
        uint256 _currentA,
        uint256 _precision
    ) external {

        require(
            block.timestamp >= (_ampData.rampStartTime + MIN_RAMP_TIME),
            "Sufficient period of previous ramp has not elapsed"
        );
        require(_rampEndTime >= (block.timestamp + MIN_RAMP_TIME), "Ramp time too short");
        require(_targetA > 0 && _targetA < MAX_A, "A target out of bounds");

        uint256 preciseTargetA = _targetA * _precision;

        if (preciseTargetA > _currentA) {
            require(preciseTargetA <= _currentA * 10, "A target increase too big");
        } else {
            require(preciseTargetA >= _currentA / 10, "A target decrease too big");
        }

        _ampData.initialA = SafeCast.toUint64(_currentA);
        _ampData.targetA = SafeCast.toUint64(preciseTargetA);
        _ampData.rampStartTime = SafeCast.toUint64(block.timestamp);
        _ampData.rampEndTime = SafeCast.toUint64(_rampEndTime);

        emit StartRampA(_currentA, preciseTargetA, block.timestamp, _rampEndTime);
    }

    function stopRampA(MassetStructs.AmpData storage _ampData, uint256 _currentA) external {

        require(block.timestamp < _ampData.rampEndTime, "Amplification not changing");

        _ampData.initialA = SafeCast.toUint64(_currentA);
        _ampData.targetA = SafeCast.toUint64(_currentA);
        _ampData.rampStartTime = SafeCast.toUint64(block.timestamp);
        _ampData.rampEndTime = SafeCast.toUint64(block.timestamp);

        emit StopRampA(_currentA, block.timestamp);
    }

    function _getAssetIndex(
        MassetStructs.BassetPersonal[] storage _bAssetPersonal,
        mapping(address => uint8) storage _bAssetIndexes,
        address _asset
    ) internal view returns (uint8 idx) {

        idx = _bAssetIndexes[_asset];
        require(_bAssetPersonal[idx].addr == _asset, "Invalid asset input");
    }


    function depositTokens(
        MassetStructs.BassetPersonal memory _bAsset,
        uint256 _bAssetRatio,
        uint256 _quantity,
        uint256 _maxCache
    ) external returns (uint256 quantityDeposited) {

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

    function withdrawTokens(
        uint256 _quantity,
        MassetStructs.BassetPersonal memory _personal,
        MassetStructs.BassetData memory _data,
        address _recipient,
        uint256 _maxCache
    ) external {

        if (_quantity == 0) return;

        if (_personal.integrator == address(0)) {
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
}