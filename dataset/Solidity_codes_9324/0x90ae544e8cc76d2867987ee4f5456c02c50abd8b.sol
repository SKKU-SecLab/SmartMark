
pragma solidity 0.8.2;
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


library FeederManager {

    using SafeERC20 for IERC20;
    using StableMath for uint256;

    event BassetsMigrated(address[] bAssets, address newIntegrator);
    event StartRampA(uint256 currentA, uint256 targetA, uint256 startTime, uint256 rampEndTime);
    event StopRampA(uint256 currentA, uint256 time);

    uint256 private constant MIN_RAMP_TIME = 1 days;
    uint256 private constant MAX_A = 1e6;

    function calculatePlatformInterest(
        BassetPersonal[] memory _bAssetPersonal,
        BassetData[] storage _bAssetData
    ) external returns (uint8[] memory idxs, uint256[] memory rawGains) {

        BassetData[] memory bAssetData_ = _bAssetData;
        uint256 count = bAssetData_.length;
        idxs = new uint8[](count);
        rawGains = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            idxs[i] = uint8(i);
            BassetPersonal memory bPersonal = _bAssetPersonal[i];
            BassetData memory bData = bAssetData_[i];
            if (bPersonal.integrator == address(0)) continue;
            uint256 lending =
                IPlatformIntegration(bPersonal.integrator).checkBalance(bPersonal.addr);
            uint256 cache = 0;
            if (!bPersonal.hasTxFee) {
                cache = IERC20(bPersonal.addr).balanceOf(bPersonal.integrator);
            }
            uint256 balance = lending + cache;
            uint256 oldVaultBalance = bData.vaultBalance;
            if (balance > oldVaultBalance && bPersonal.status == BassetStatus.Normal) {
                _bAssetData[i].vaultBalance = SafeCast.toUint128(balance);
                uint256 interestDelta = balance - oldVaultBalance;
                rawGains[i] = interestDelta;
            } else {
                rawGains[i] = 0;
            }
        }
    }

    function migrateBassets(
        BassetPersonal[] storage _bAssetPersonal,
        address[] calldata _bAssets,
        address _newIntegration
    ) external {

        uint256 len = _bAssets.length;
        require(len > 0, "Must migrate some bAssets");

        for (uint256 i = 0; i < len; i++) {
            address bAsset = _bAssets[i];
            uint256 index = _getAssetIndex(_bAssetPersonal, bAsset);
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

    function _getAssetIndex(BassetPersonal[] storage _bAssetPersonal, address _asset)
        internal
        view
        returns (uint8 idx)
    {

        uint256 len = _bAssetPersonal.length;
        for (uint8 i = 0; i < len; i++) {
            if (_bAssetPersonal[i].addr == _asset) return i;
        }
        revert("Invalid asset");
    }

    function startRampA(
        AmpData storage _ampData,
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

    function stopRampA(AmpData storage _ampData, uint256 _currentA) external {

        require(block.timestamp < _ampData.rampEndTime, "Amplification not changing");

        _ampData.initialA = SafeCast.toUint64(_currentA);
        _ampData.targetA = SafeCast.toUint64(_currentA);
        _ampData.rampStartTime = SafeCast.toUint64(block.timestamp);
        _ampData.rampEndTime = SafeCast.toUint64(block.timestamp);

        emit StopRampA(_currentA, block.timestamp);
    }
}