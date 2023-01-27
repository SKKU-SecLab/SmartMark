


pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}




pragma solidity >=0.6.2 <0.8.0;

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




pragma solidity >=0.6.0 <0.8.0;

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



pragma solidity 0.6.12;

interface IClaimable {

    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;


    function acceptOwnership() external;

}



pragma solidity 0.6.12;



interface IMintableToken is IERC20, IClaimable {

    function issue(address to, uint256 amount) external;


    function destroy(address from, uint256 amount) external;

}



pragma solidity 0.6.12;


interface ITokenGovernance {

    function token() external view returns (IMintableToken);


    function mint(address to, uint256 amount) external;


    function burn(uint256 amount) external;

}



pragma solidity 0.6.12;

interface ICheckpointStore {

    function addCheckpoint(address _address) external;


    function addPastCheckpoint(address _address, uint256 _time) external;


    function addPastCheckpoints(address[] calldata _addresses, uint256[] calldata _times) external;


    function checkpoint(address _address) external view returns (uint256);

}



pragma solidity 0.6.12;

library MathEx {

    uint256 private constant MAX_EXP_BIT_LEN = 4;
    uint256 private constant MAX_EXP = 2**MAX_EXP_BIT_LEN - 1;
    uint256 private constant MAX_UINT128 = 2**128 - 1;

    function floorSqrt(uint256 _num) internal pure returns (uint256) {

        uint256 x = _num / 2 + 1;
        uint256 y = (x + _num / x) / 2;
        while (x > y) {
            x = y;
            y = (x + _num / x) / 2;
        }
        return x;
    }

    function ceilSqrt(uint256 _num) internal pure returns (uint256) {

        uint256 x = floorSqrt(_num);
        return x * x == _num ? x : x + 1;
    }

    function poweredRatio(
        uint256 _n,
        uint256 _d,
        uint256 _exp
    ) internal pure returns (uint256, uint256) {

        require(_exp <= MAX_EXP, "ERR_EXP_TOO_LARGE");

        uint256[MAX_EXP_BIT_LEN] memory ns;
        uint256[MAX_EXP_BIT_LEN] memory ds;

        (ns[0], ds[0]) = reducedRatio(_n, _d, MAX_UINT128);
        for (uint256 i = 0; (_exp >> i) > 1; i++) {
            (ns[i + 1], ds[i + 1]) = reducedRatio(ns[i] ** 2, ds[i] ** 2, MAX_UINT128);
        }

        uint256 n = 1;
        uint256 d = 1;

        for (uint256 i = 0; (_exp >> i) > 0; i++) {
            if (((_exp >> i) & 1) > 0) {
                (n, d) = reducedRatio(n * ns[i], d * ds[i], MAX_UINT128);
            }
        }

        return (n, d);
    }

    function reducedRatio(
        uint256 _n,
        uint256 _d,
        uint256 _max
    ) internal pure returns (uint256, uint256) {

        (uint256 n, uint256 d) = (_n, _d);
        if (n > _max || d > _max) {
            (n, d) = normalizedRatio(n, d, _max);
        }
        if (n != d) {
            return (n, d);
        }
        return (1, 1);
    }

    function normalizedRatio(
        uint256 _a,
        uint256 _b,
        uint256 _scale
    ) internal pure returns (uint256, uint256) {

        if (_a <= _b) {
            return accurateRatio(_a, _b, _scale);
        }
        (uint256 y, uint256 x) = accurateRatio(_b, _a, _scale);
        return (x, y);
    }

    function accurateRatio(
        uint256 _a,
        uint256 _b,
        uint256 _scale
    ) internal pure returns (uint256, uint256) {

        uint256 maxVal = uint256(-1) / _scale;
        if (_a > maxVal) {
            uint256 c = _a / (maxVal + 1) + 1;
            _a /= c; // we can now safely compute `_a * _scale`
            _b /= c;
        }
        if (_a != _b) {
            uint256 n = _a * _scale;
            uint256 d = _a + _b; // can overflow
            if (d >= _a) {
                uint256 x = roundDiv(n, d); // we can now safely compute `_scale - x`
                uint256 y = _scale - x;
                return (x, y);
            }
            if (n < _b - (_b - _a) / 2) {
                return (0, _scale); // `_a * _scale < (_a + _b) / 2 < MAX_UINT256 < _a + _b`
            }
            return (1, _scale - 1); // `(_a + _b) / 2 < _a * _scale < MAX_UINT256 < _a + _b`
        }
        return (_scale / 2, _scale / 2); // allow reduction to `(1, 1)` in the calling function
    }

    function roundDiv(uint256 _n, uint256 _d) internal pure returns (uint256) {

        return _n / _d + (_n % _d) / (_d - _d / 2);
    }

    function geometricMean(uint256[] memory _values) internal pure returns (uint256) {

        uint256 numOfDigits = 0;
        uint256 length = _values.length;
        for (uint256 i = 0; i < length; i++) {
            numOfDigits += decimalLength(_values[i]);
        }
        return uint256(10)**(roundDivUnsafe(numOfDigits, length) - 1);
    }

    function decimalLength(uint256 _x) internal pure returns (uint256) {

        uint256 y = 0;
        for (uint256 x = _x; x > 0; x /= 10) {
            y++;
        }
        return y;
    }

    function roundDivUnsafe(uint256 _n, uint256 _d) internal pure returns (uint256) {

        return (_n + _d / 2) / _d;
    }

    function max(uint256 _val1, uint256 _val2) internal pure returns (uint256) {

        return _val1 > _val2 ? _val1 : _val2;
    }
}



pragma solidity 0.6.12;

contract ReentrancyGuard {

    uint256 private constant UNLOCKED = 1;
    uint256 private constant LOCKED = 2;

    uint256 private state = UNLOCKED;

    constructor() internal {}

    modifier protected() {

        _protected();
        state = LOCKED;
        _;
        state = UNLOCKED;
    }

    function _protected() internal view {

        require(state == UNLOCKED, "ERR_REENTRANCY");
    }
}



pragma solidity 0.6.12;


struct Fraction {
    uint256 n; // numerator
    uint256 d; // denominator
}



pragma solidity 0.6.12;

contract Time {

    function time() internal view virtual returns (uint256) {

        return block.timestamp;
    }
}



pragma solidity 0.6.12;


contract Utils {

    uint32 internal constant PPM_RESOLUTION = 1000000;

    modifier greaterThanZero(uint256 _value) {

        _greaterThanZero(_value);
        _;
    }

    function _greaterThanZero(uint256 _value) internal pure {

        require(_value > 0, "ERR_ZERO_VALUE");
    }

    modifier validAddress(address _address) {

        _validAddress(_address);
        _;
    }

    function _validAddress(address _address) internal pure {

        require(_address != address(0), "ERR_INVALID_ADDRESS");
    }

    modifier validPortion(uint32 _portion) {

        _validPortion(_portion);
        _;
    }

    function _validPortion(uint32 _portion) internal pure {

        require(_portion > 0 && _portion <= PPM_RESOLUTION, "ERR_INVALID_PORTION");
    }

    modifier validExternalAddress(address _address) {

        _validExternalAddress(_address);
        _;
    }

    function _validExternalAddress(address _address) internal view {

        require(_address != address(0) && _address != address(this), "ERR_INVALID_EXTERNAL_ADDRESS");
    }

    modifier validFee(uint32 fee) {

        _validFee(fee);
        _;
    }

    function _validFee(uint32 fee) internal pure {

        require(fee <= PPM_RESOLUTION, "ERR_INVALID_FEE");
    }
}



pragma solidity 0.6.12;

interface IOwned {

    function owner() external view returns (address);


    function transferOwnership(address _newOwner) external;


    function acceptOwnership() external;

}



pragma solidity 0.6.12;


contract Owned is IOwned {

    address public override owner;
    address public newOwner;

    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier ownerOnly {

        _ownerOnly();
        _;
    }

    function _ownerOnly() internal view {

        require(msg.sender == owner, "ERR_ACCESS_DENIED");
    }

    function transferOwnership(address _newOwner) public override ownerOnly {

        require(_newOwner != owner, "ERR_SAME_OWNER");
        newOwner = _newOwner;
    }

    function acceptOwnership() public override {

        require(msg.sender == newOwner, "ERR_ACCESS_DENIED");
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



pragma solidity 0.6.12;


interface IConverterAnchor is IOwned {


}



pragma solidity 0.6.12;




interface IDSToken is IConverterAnchor, IERC20 {

    function issue(address _to, uint256 _amount) external;


    function destroy(address _from, uint256 _amount) external;

}



pragma solidity 0.6.12;

interface IReserveToken {


}




pragma solidity >=0.6.0 <0.8.0;




library SafeERC20 {

    using SafeMath for uint256;
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

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}



pragma solidity 0.6.12;


library SafeERC20Ex {

    using SafeERC20 for IERC20;

    function ensureApprove(
        IERC20 token,
        address spender,
        uint256 amount
    ) internal {

        if (amount == 0) {
            return;
        }

        uint256 allowance = token.allowance(address(this), spender);
        if (allowance >= amount) {
            return;
        }

        if (allowance > 0) {
            token.safeApprove(spender, 0);
        }
        token.safeApprove(spender, amount);
    }
}



pragma solidity 0.6.12;




library ReserveToken {

    using SafeERC20 for IERC20;
    using SafeERC20Ex for IERC20;

    IReserveToken public constant NATIVE_TOKEN_ADDRESS = IReserveToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    function isNativeToken(IReserveToken reserveToken) internal pure returns (bool) {

        return reserveToken == NATIVE_TOKEN_ADDRESS;
    }

    function balanceOf(IReserveToken reserveToken, address account) internal view returns (uint256) {

        if (isNativeToken(reserveToken)) {
            return account.balance;
        }

        return toIERC20(reserveToken).balanceOf(account);
    }

    function safeTransfer(
        IReserveToken reserveToken,
        address to,
        uint256 amount
    ) internal {

        if (amount == 0) {
            return;
        }

        if (isNativeToken(reserveToken)) {
            payable(to).transfer(amount);
        } else {
            toIERC20(reserveToken).safeTransfer(to, amount);
        }
    }

    function safeTransferFrom(
        IReserveToken reserveToken,
        address from,
        address to,
        uint256 amount
    ) internal {

        if (amount == 0 || isNativeToken(reserveToken)) {
            return;
        }

        toIERC20(reserveToken).safeTransferFrom(from, to, amount);
    }

    function ensureApprove(
        IReserveToken reserveToken,
        address spender,
        uint256 amount
    ) internal {

        if (isNativeToken(reserveToken)) {
            return;
        }

        toIERC20(reserveToken).ensureApprove(spender, amount);
    }

    function toIERC20(IReserveToken reserveToken) private pure returns (IERC20) {

        return IERC20(address(reserveToken));
    }
}



pragma solidity 0.6.12;





interface IConverter is IOwned {

    function converterType() external pure returns (uint16);


    function anchor() external view returns (IConverterAnchor);


    function isActive() external view returns (bool);


    function targetAmountAndFee(
        IReserveToken _sourceToken,
        IReserveToken _targetToken,
        uint256 _amount
    ) external view returns (uint256, uint256);


    function convert(
        IReserveToken _sourceToken,
        IReserveToken _targetToken,
        uint256 _amount,
        address _trader,
        address payable _beneficiary
    ) external payable returns (uint256);


    function conversionFee() external view returns (uint32);


    function maxConversionFee() external view returns (uint32);


    function reserveBalance(IReserveToken _reserveToken) external view returns (uint256);


    receive() external payable;

    function transferAnchorOwnership(address _newOwner) external;


    function acceptAnchorOwnership() external;


    function setConversionFee(uint32 _conversionFee) external;


    function addReserve(IReserveToken _token, uint32 _weight) external;


    function transferReservesOnUpgrade(address _newConverter) external;


    function onUpgradeComplete() external;


    function token() external view returns (IConverterAnchor);


    function transferTokenOwnership(address _newOwner) external;


    function acceptTokenOwnership() external;


    function connectors(IReserveToken _address)
        external
        view
        returns (
            uint256,
            uint32,
            bool,
            bool,
            bool
        );


    function getConnectorBalance(IReserveToken _connectorToken) external view returns (uint256);


    function connectorTokens(uint256 _index) external view returns (IReserveToken);


    function connectorTokenCount() external view returns (uint16);


    event Activation(uint16 indexed _type, IConverterAnchor indexed _anchor, bool indexed _activated);

    event Conversion(
        IReserveToken indexed _fromToken,
        IReserveToken indexed _toToken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionFee
    );

    event TokenRateUpdate(address indexed _token1, address indexed _token2, uint256 _rateN, uint256 _rateD);

    event ConversionFeeUpdate(uint32 _prevFee, uint32 _newFee);
}



pragma solidity 0.6.12;



interface IConverterRegistry {

    function getAnchorCount() external view returns (uint256);


    function getAnchors() external view returns (address[] memory);


    function getAnchor(uint256 _index) external view returns (IConverterAnchor);


    function isAnchor(address _value) external view returns (bool);


    function getLiquidityPoolCount() external view returns (uint256);


    function getLiquidityPools() external view returns (address[] memory);


    function getLiquidityPool(uint256 _index) external view returns (IConverterAnchor);


    function isLiquidityPool(address _value) external view returns (bool);


    function getConvertibleTokenCount() external view returns (uint256);


    function getConvertibleTokens() external view returns (address[] memory);


    function getConvertibleToken(uint256 _index) external view returns (IReserveToken);


    function isConvertibleToken(address _value) external view returns (bool);


    function getConvertibleTokenAnchorCount(IReserveToken _convertibleToken) external view returns (uint256);


    function getConvertibleTokenAnchors(IReserveToken _convertibleToken) external view returns (address[] memory);


    function getConvertibleTokenAnchor(IReserveToken _convertibleToken, uint256 _index)
        external
        view
        returns (IConverterAnchor);


    function isConvertibleTokenAnchor(IReserveToken _convertibleToken, address _value) external view returns (bool);


    function getLiquidityPoolByConfig(
        uint16 _type,
        IReserveToken[] memory _reserveTokens,
        uint32[] memory _reserveWeights
    ) external view returns (IConverterAnchor);

}



pragma solidity 0.6.12;





interface ILiquidityProtectionStore is IOwned {

    function withdrawTokens(
        IReserveToken _token,
        address _to,
        uint256 _amount
    ) external;


    function protectedLiquidity(uint256 _id)
        external
        view
        returns (
            address,
            IDSToken,
            IReserveToken,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );


    function addProtectedLiquidity(
        address _provider,
        IDSToken _poolToken,
        IReserveToken _reserveToken,
        uint256 _poolAmount,
        uint256 _reserveAmount,
        uint256 _reserveRateN,
        uint256 _reserveRateD,
        uint256 _timestamp
    ) external returns (uint256);


    function updateProtectedLiquidityAmounts(
        uint256 _id,
        uint256 _poolNewAmount,
        uint256 _reserveNewAmount
    ) external;


    function removeProtectedLiquidity(uint256 _id) external;


    function lockedBalance(address _provider, uint256 _index) external view returns (uint256, uint256);


    function lockedBalanceRange(
        address _provider,
        uint256 _startIndex,
        uint256 _endIndex
    ) external view returns (uint256[] memory, uint256[] memory);


    function addLockedBalance(
        address _provider,
        uint256 _reserveAmount,
        uint256 _expirationTime
    ) external returns (uint256);


    function removeLockedBalance(address _provider, uint256 _index) external;


    function systemBalance(IReserveToken _poolToken) external view returns (uint256);


    function incSystemBalance(IReserveToken _poolToken, uint256 _poolAmount) external;


    function decSystemBalance(IReserveToken _poolToken, uint256 _poolAmount) external;

}



pragma solidity 0.6.12;




interface ILiquidityProtectionStats {

    function increaseTotalAmounts(
        address provider,
        IDSToken poolToken,
        IReserveToken reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount
    ) external;


    function decreaseTotalAmounts(
        address provider,
        IDSToken poolToken,
        IReserveToken reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount
    ) external;


    function addProviderPool(address provider, IDSToken poolToken) external returns (bool);


    function removeProviderPool(address provider, IDSToken poolToken) external returns (bool);


    function totalPoolAmount(IDSToken poolToken) external view returns (uint256);


    function totalReserveAmount(IDSToken poolToken, IReserveToken reserveToken) external view returns (uint256);


    function totalProviderAmount(
        address provider,
        IDSToken poolToken,
        IReserveToken reserveToken
    ) external view returns (uint256);


    function providerPools(address provider) external view returns (IDSToken[] memory);

}



pragma solidity 0.6.12;



interface ILiquidityProtectionEventsSubscriber {

    function onAddingLiquidity(
        address provider,
        IConverterAnchor poolAnchor,
        IReserveToken reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount
    ) external;


    function onRemovingLiquidity(
        uint256 id,
        address provider,
        IConverterAnchor poolAnchor,
        IReserveToken reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount
    ) external;

}



pragma solidity 0.6.12;




interface ILiquidityProtectionSettings {

    function isPoolWhitelisted(IConverterAnchor poolAnchor) external view returns (bool);


    function poolWhitelist() external view returns (address[] memory);


    function subscribers() external view returns (address[] memory);


    function isPoolSupported(IConverterAnchor poolAnchor) external view returns (bool);


    function minNetworkTokenLiquidityForMinting() external view returns (uint256);


    function defaultNetworkTokenMintingLimit() external view returns (uint256);


    function networkTokenMintingLimits(IConverterAnchor poolAnchor) external view returns (uint256);


    function addLiquidityDisabled(IConverterAnchor poolAnchor, IReserveToken reserveToken) external view returns (bool);


    function minProtectionDelay() external view returns (uint256);


    function maxProtectionDelay() external view returns (uint256);


    function minNetworkCompensation() external view returns (uint256);


    function lockDuration() external view returns (uint256);


    function averageRateMaxDeviation() external view returns (uint32);

}



pragma solidity 0.6.12;



interface ILiquidityProtectionSystemStore {

    function systemBalance(IERC20 poolToken) external view returns (uint256);


    function incSystemBalance(IERC20 poolToken, uint256 poolAmount) external;


    function decSystemBalance(IERC20 poolToken, uint256 poolAmount) external;


    function networkTokensMinted(IConverterAnchor poolAnchor) external view returns (uint256);


    function incNetworkTokensMinted(IConverterAnchor poolAnchor, uint256 amount) external;


    function decNetworkTokensMinted(IConverterAnchor poolAnchor, uint256 amount) external;

}



pragma solidity 0.6.12;



interface ITokenHolder is IOwned {

    receive() external payable;

    function withdrawTokens(
        IReserveToken reserveToken,
        address payable to,
        uint256 amount
    ) external;


    function withdrawTokensMultiple(
        IReserveToken[] calldata reserveTokens,
        address payable to,
        uint256[] calldata amounts
    ) external;

}



pragma solidity 0.6.12;








interface ILiquidityProtection {

    function store() external view returns (ILiquidityProtectionStore);


    function stats() external view returns (ILiquidityProtectionStats);


    function settings() external view returns (ILiquidityProtectionSettings);


    function systemStore() external view returns (ILiquidityProtectionSystemStore);


    function wallet() external view returns (ITokenHolder);


    function addLiquidityFor(
        address owner,
        IConverterAnchor poolAnchor,
        IReserveToken reserveToken,
        uint256 amount
    ) external payable returns (uint256);


    function addLiquidity(
        IConverterAnchor poolAnchor,
        IReserveToken reserveToken,
        uint256 amount
    ) external payable returns (uint256);


    function removeLiquidity(uint256 id, uint32 portion) external;

}



pragma solidity 0.6.12;

















interface ILiquidityPoolConverter is IConverter {

    function addLiquidity(
        IReserveToken[] memory reserveTokens,
        uint256[] memory reserveAmounts,
        uint256 _minReturn
    ) external payable;


    function removeLiquidity(
        uint256 amount,
        IReserveToken[] memory reserveTokens,
        uint256[] memory _reserveMinReturnAmounts
    ) external;


    function recentAverageRate(IReserveToken reserveToken) external view returns (uint256, uint256);

}

contract LiquidityProtection is ILiquidityProtection, Utils, Owned, ReentrancyGuard, Time {

    using SafeMath for uint256;
    using ReserveToken for IReserveToken;
    using SafeERC20 for IERC20;
    using SafeERC20 for IDSToken;
    using SafeERC20Ex for IERC20;
    using MathEx for *;

    struct Position {
        address provider; // liquidity provider
        IDSToken poolToken; // pool token address
        IReserveToken reserveToken; // reserve token address
        uint256 poolAmount; // pool token amount
        uint256 reserveAmount; // reserve token amount
        uint256 reserveRateN; // rate of 1 protected reserve token in units of the other reserve token (numerator)
        uint256 reserveRateD; // rate of 1 protected reserve token in units of the other reserve token (denominator)
        uint256 timestamp; // timestamp
    }

    struct PackedRates {
        uint128 addSpotRateN; // spot rate of 1 A in units of B when liquidity was added (numerator)
        uint128 addSpotRateD; // spot rate of 1 A in units of B when liquidity was added (denominator)
        uint128 removeSpotRateN; // spot rate of 1 A in units of B when liquidity is removed (numerator)
        uint128 removeSpotRateD; // spot rate of 1 A in units of B when liquidity is removed (denominator)
        uint128 removeAverageRateN; // average rate of 1 A in units of B when liquidity is removed (numerator)
        uint128 removeAverageRateD; // average rate of 1 A in units of B when liquidity is removed (denominator)
    }

    uint256 internal constant MAX_UINT128 = 2**128 - 1;
    uint256 internal constant MAX_UINT256 = uint256(-1);
    uint8 private constant FUNC_SELECTOR_LENGTH = 4;

    ILiquidityProtectionSettings private immutable _settings;
    ILiquidityProtectionStore private immutable _store;
    ILiquidityProtectionStats private immutable _stats;
    ILiquidityProtectionSystemStore private immutable _systemStore;
    ITokenHolder private immutable _wallet;
    IERC20 private immutable _networkToken;
    ITokenGovernance private immutable _networkTokenGovernance;
    IERC20 private immutable _govToken;
    ITokenGovernance private immutable _govTokenGovernance;
    ICheckpointStore private immutable _lastRemoveCheckpointStore;

    constructor(
        ILiquidityProtectionSettings settings,
        ILiquidityProtectionStore store,
        ILiquidityProtectionStats stats,
        ILiquidityProtectionSystemStore systemStore,
        ITokenHolder wallet,
        ITokenGovernance networkTokenGovernance,
        ITokenGovernance govTokenGovernance,
        ICheckpointStore lastRemoveCheckpointStore
    )
        public
        validAddress(address(settings))
        validAddress(address(store))
        validAddress(address(stats))
        validAddress(address(systemStore))
        validAddress(address(wallet))
        validAddress(address(lastRemoveCheckpointStore))
    {
        _settings = settings;
        _store = store;
        _stats = stats;
        _systemStore = systemStore;
        _wallet = wallet;
        _networkTokenGovernance = networkTokenGovernance;
        _govTokenGovernance = govTokenGovernance;
        _lastRemoveCheckpointStore = lastRemoveCheckpointStore;

        _networkToken = networkTokenGovernance.token();
        _govToken = govTokenGovernance.token();
    }

    modifier poolSupportedAndWhitelisted(IConverterAnchor poolAnchor) {

        _poolSupported(poolAnchor);
        _poolWhitelisted(poolAnchor);

        _;
    }

    modifier addLiquidityEnabled(IConverterAnchor poolAnchor, IReserveToken reserveToken) {

        _addLiquidityEnabled(poolAnchor, reserveToken);

        _;
    }

    function _poolSupported(IConverterAnchor poolAnchor) internal view {

        require(_settings.isPoolSupported(poolAnchor), "ERR_POOL_NOT_SUPPORTED");
    }

    function _poolWhitelisted(IConverterAnchor poolAnchor) internal view {

        require(_settings.isPoolWhitelisted(poolAnchor), "ERR_POOL_NOT_WHITELISTED");
    }

    function _addLiquidityEnabled(IConverterAnchor poolAnchor, IReserveToken reserveToken) internal view {

        require(!_settings.addLiquidityDisabled(poolAnchor, reserveToken), "ERR_ADD_LIQUIDITY_DISABLED");
    }

    function verifyEthAmount(uint256 value) internal view {

        require(msg.value == value, "ERR_ETH_AMOUNT_MISMATCH");
    }

    function store() external view override returns (ILiquidityProtectionStore) {

        return _store;
    }

    function stats() external view override returns (ILiquidityProtectionStats) {

        return _stats;
    }

    function settings() external view override returns (ILiquidityProtectionSettings) {

        return _settings;
    }

    function systemStore() external view override returns (ILiquidityProtectionSystemStore) {

        return _systemStore;
    }

    function wallet() external view override returns (ITokenHolder) {

        return _wallet;
    }

    receive() external payable {}

    function transferStoreOwnership(address newOwner) external ownerOnly {

        _store.transferOwnership(newOwner);
    }

    function acceptStoreOwnership() external ownerOnly {

        _store.acceptOwnership();
    }

    function transferWalletOwnership(address newOwner) external ownerOnly {

        _wallet.transferOwnership(newOwner);
    }

    function acceptWalletOwnership() external ownerOnly {

        _wallet.acceptOwnership();
    }

    function addLiquidityFor(
        address owner,
        IConverterAnchor poolAnchor,
        IReserveToken reserveToken,
        uint256 amount
    )
        external
        payable
        override
        protected
        validAddress(owner)
        poolSupportedAndWhitelisted(poolAnchor)
        addLiquidityEnabled(poolAnchor, reserveToken)
        greaterThanZero(amount)
        returns (uint256)
    {

        return addLiquidity(owner, poolAnchor, reserveToken, amount);
    }

    function addLiquidity(
        IConverterAnchor poolAnchor,
        IReserveToken reserveToken,
        uint256 amount
    )
        external
        payable
        override
        protected
        poolSupportedAndWhitelisted(poolAnchor)
        addLiquidityEnabled(poolAnchor, reserveToken)
        greaterThanZero(amount)
        returns (uint256)
    {

        return addLiquidity(msg.sender, poolAnchor, reserveToken, amount);
    }

    function addLiquidity(
        address owner,
        IConverterAnchor poolAnchor,
        IReserveToken reserveToken,
        uint256 amount
    ) private returns (uint256) {

        if (isNetworkToken(reserveToken)) {
            verifyEthAmount(0);
            return addNetworkTokenLiquidity(owner, poolAnchor, amount);
        }

        verifyEthAmount(reserveToken.isNativeToken() ? amount : 0);
        return addBaseTokenLiquidity(owner, poolAnchor, reserveToken, amount);
    }

    function addNetworkTokenLiquidity(
        address owner,
        IConverterAnchor poolAnchor,
        uint256 amount
    ) internal returns (uint256) {

        IDSToken poolToken = IDSToken(address(poolAnchor));
        IReserveToken networkToken = IReserveToken(address(_networkToken));

        Fraction memory poolRate = poolTokenRate(poolToken, networkToken);

        uint256 poolTokenAmount = amount.mul(poolRate.d).div(poolRate.n);

        _systemStore.decSystemBalance(poolToken, poolTokenAmount);

        uint256 id = addPosition(owner, poolToken, networkToken, poolTokenAmount, amount, time());

        _networkToken.safeTransferFrom(msg.sender, address(this), amount);
        burnNetworkTokens(poolAnchor, amount);

        _govTokenGovernance.mint(owner, amount);

        return id;
    }

    function addBaseTokenLiquidity(
        address owner,
        IConverterAnchor poolAnchor,
        IReserveToken baseToken,
        uint256 amount
    ) internal returns (uint256) {

        IDSToken poolToken = IDSToken(address(poolAnchor));
        IReserveToken networkToken = IReserveToken(address(_networkToken));

        ILiquidityPoolConverter converter = ILiquidityPoolConverter(payable(ownedBy(poolAnchor)));
        (uint256 reserveBalanceBase, uint256 reserveBalanceNetwork) =
            converterReserveBalances(converter, baseToken, networkToken);

        require(reserveBalanceNetwork >= _settings.minNetworkTokenLiquidityForMinting(), "ERR_NOT_ENOUGH_LIQUIDITY");

        uint256 newNetworkLiquidityAmount = amount.mul(reserveBalanceNetwork).div(reserveBalanceBase);

        uint256 mintingLimit = _settings.networkTokenMintingLimits(poolAnchor);
        if (mintingLimit == 0) {
            mintingLimit = _settings.defaultNetworkTokenMintingLimit();
        }

        uint256 newNetworkTokensMinted = _systemStore.networkTokensMinted(poolAnchor).add(newNetworkLiquidityAmount);
        require(newNetworkTokensMinted <= mintingLimit, "ERR_MAX_AMOUNT_REACHED");

        mintNetworkTokens(address(this), poolAnchor, newNetworkLiquidityAmount);

        networkToken.ensureApprove(address(converter), newNetworkLiquidityAmount);

        if (!baseToken.isNativeToken()) {
            baseToken.safeTransferFrom(msg.sender, address(this), amount);
            baseToken.ensureApprove(address(converter), amount);
        }

        addLiquidity(converter, baseToken, networkToken, amount, newNetworkLiquidityAmount, msg.value);

        uint256 poolTokenAmount = poolToken.balanceOf(address(this));
        poolToken.safeTransfer(address(_wallet), poolTokenAmount);

        _systemStore.incSystemBalance(poolToken, poolTokenAmount - poolTokenAmount / 2); // account for rounding errors

        return addPosition(owner, poolToken, baseToken, poolTokenAmount / 2, amount, time());
    }

    function poolAvailableSpace(IConverterAnchor poolAnchor)
        external
        view
        poolSupportedAndWhitelisted(poolAnchor)
        returns (uint256, uint256)
    {

        return (baseTokenAvailableSpace(poolAnchor), networkTokenAvailableSpace(poolAnchor));
    }

    function baseTokenAvailableSpace(IConverterAnchor poolAnchor) internal view returns (uint256) {

        ILiquidityPoolConverter converter = ILiquidityPoolConverter(payable(ownedBy(poolAnchor)));

        IReserveToken networkToken = IReserveToken(address(_networkToken));
        IReserveToken baseToken = converterOtherReserve(converter, networkToken);

        (uint256 reserveBalanceBase, uint256 reserveBalanceNetwork) =
            converterReserveBalances(converter, baseToken, networkToken);

        uint256 mintingLimit = _settings.networkTokenMintingLimits(poolAnchor);
        if (mintingLimit == 0) {
            mintingLimit = _settings.defaultNetworkTokenMintingLimit();
        }

        uint256 networkTokensMinted = _systemStore.networkTokensMinted(poolAnchor);

        uint256 networkTokensCanBeMinted = MathEx.max(mintingLimit, networkTokensMinted) - networkTokensMinted;

        return networkTokensCanBeMinted.mul(reserveBalanceBase).div(reserveBalanceNetwork);
    }

    function networkTokenAvailableSpace(IConverterAnchor poolAnchor) internal view returns (uint256) {

        IDSToken poolToken = IDSToken(address(poolAnchor));
        IReserveToken networkToken = IReserveToken(address(_networkToken));

        Fraction memory poolRate = poolTokenRate(poolToken, networkToken);

        return _systemStore.systemBalance(poolToken).mul(poolRate.n).add(poolRate.n).sub(1).div(poolRate.d);
    }

    function removeLiquidityReturn(
        uint256 id,
        uint32 portion,
        uint256 removeTimestamp
    )
        external
        view
        validPortion(portion)
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        Position memory pos = position(id);

        require(pos.provider != address(0), "ERR_INVALID_ID");
        require(removeTimestamp >= pos.timestamp, "ERR_INVALID_TIMESTAMP");

        if (portion != PPM_RESOLUTION) {
            pos.poolAmount = pos.poolAmount.mul(portion) / PPM_RESOLUTION;
            pos.reserveAmount = pos.reserveAmount.mul(portion) / PPM_RESOLUTION;
        }

        PackedRates memory packedRates = packRates(pos.poolToken, pos.reserveToken, pos.reserveRateN, pos.reserveRateD);

        uint256 targetAmount =
            removeLiquidityTargetAmount(
                pos.poolToken,
                pos.reserveToken,
                pos.poolAmount,
                pos.reserveAmount,
                packedRates,
                pos.timestamp,
                removeTimestamp
            );

        if (isNetworkToken(pos.reserveToken)) {
            return (targetAmount, targetAmount, 0);
        }


        Fraction memory poolRate = poolTokenRate(pos.poolToken, pos.reserveToken);
        uint256 poolAmount = targetAmount.mul(poolRate.d).div(poolRate.n / 2);

        uint256 availableBalance = _systemStore.systemBalance(pos.poolToken).add(pos.poolAmount);
        poolAmount = poolAmount > availableBalance ? availableBalance : poolAmount;

        uint256 baseAmount = poolAmount.mul(poolRate.n / 2).div(poolRate.d);
        uint256 networkAmount = networkCompensation(targetAmount, baseAmount, packedRates);

        return (targetAmount, baseAmount, networkAmount);
    }

    function removeLiquidity(uint256 id, uint32 portion) external override protected validPortion(portion) {

        removeLiquidity(msg.sender, id, portion);
    }

    function removeLiquidity(
        address payable provider,
        uint256 id,
        uint32 portion
    ) internal {

        Position memory removedPos = removePosition(provider, id, portion);

        _systemStore.incSystemBalance(removedPos.poolToken, removedPos.poolAmount);

        if (isNetworkToken(removedPos.reserveToken)) {
            _govToken.safeTransferFrom(provider, address(this), removedPos.reserveAmount);
            _govTokenGovernance.burn(removedPos.reserveAmount);
        }

        PackedRates memory packedRates =
            packRates(removedPos.poolToken, removedPos.reserveToken, removedPos.reserveRateN, removedPos.reserveRateD);

        verifyRateDeviation(
            packedRates.removeSpotRateN,
            packedRates.removeSpotRateD,
            packedRates.removeAverageRateN,
            packedRates.removeAverageRateD
        );

        uint256 targetAmount =
            removeLiquidityTargetAmount(
                removedPos.poolToken,
                removedPos.reserveToken,
                removedPos.poolAmount,
                removedPos.reserveAmount,
                packedRates,
                removedPos.timestamp,
                time()
            );

        if (isNetworkToken(removedPos.reserveToken)) {
            mintNetworkTokens(address(_wallet), removedPos.poolToken, targetAmount);
            lockTokens(provider, targetAmount);

            return;
        }


        Fraction memory poolRate = poolTokenRate(removedPos.poolToken, removedPos.reserveToken);
        uint256 poolAmount = targetAmount.mul(poolRate.d).div(poolRate.n / 2);

        uint256 systemBalance = _systemStore.systemBalance(removedPos.poolToken);
        poolAmount = poolAmount > systemBalance ? systemBalance : poolAmount;

        IReserveToken poolToken = IReserveToken(address(removedPos.poolToken));
        _systemStore.decSystemBalance(removedPos.poolToken, poolAmount);
        _wallet.withdrawTokens(poolToken, address(this), poolAmount);

        removeLiquidity(
            removedPos.poolToken,
            poolAmount,
            removedPos.reserveToken,
            IReserveToken(address(_networkToken))
        );

        uint256 baseBalance = removedPos.reserveToken.balanceOf(address(this));
        removedPos.reserveToken.safeTransfer(provider, baseBalance);

        uint256 delta = networkCompensation(targetAmount, baseBalance, packedRates);
        if (delta > 0) {
            uint256 networkBalance = _networkToken.balanceOf(address(this));
            if (networkBalance < delta) {
                _networkTokenGovernance.mint(address(this), delta - networkBalance);
            }

            _networkToken.safeTransfer(address(_wallet), delta);
            lockTokens(provider, delta);
        }

        uint256 networkBalance = _networkToken.balanceOf(address(this));
        if (networkBalance > 0) {
            burnNetworkTokens(removedPos.poolToken, networkBalance);
        }
    }

    function removeLiquidityTargetAmount(
        IDSToken poolToken,
        IReserveToken reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount,
        PackedRates memory packedRates,
        uint256 addTimestamp,
        uint256 removeTimestamp
    ) internal view returns (uint256) {

        Fraction memory poolRate = poolTokenRate(poolToken, reserveToken);

        Fraction memory addSpotRate = Fraction({ n: packedRates.addSpotRateN, d: packedRates.addSpotRateD });
        Fraction memory removeSpotRate = Fraction({ n: packedRates.removeSpotRateN, d: packedRates.removeSpotRateD });
        Fraction memory removeAverageRate =
            Fraction({ n: packedRates.removeAverageRateN, d: packedRates.removeAverageRateD });

        uint256 total = protectedAmountPlusFee(poolAmount, poolRate, addSpotRate, removeSpotRate);

        Fraction memory loss = impLoss(addSpotRate, removeAverageRate);

        Fraction memory level = protectionLevel(addTimestamp, removeTimestamp);

        return compensationAmount(reserveAmount, MathEx.max(reserveAmount, total), loss, level);
    }

    function transferPosition(uint256 id, address newProvider)
        external
        protected
        validAddress(newProvider)
        returns (uint256)
    {

        return transferPosition(msg.sender, id, newProvider);
    }

    function transferPositionAndCall(
        uint256 id,
        address newProvider,
        address target,
        bytes memory data
    ) external protected validAddress(newProvider) validAddress(target) returns (uint256) {

        require(data.length >= FUNC_SELECTOR_LENGTH, "ERR_INVALID_CALL_DATA");

        uint256 newId = transferPosition(msg.sender, id, newProvider);

        Address.functionCall(target, data, "ERR_CALL_FAILED");

        return newId;
    }

    function transferPosition(
        address provider,
        uint256 id,
        address newProvider
    ) internal returns (uint256) {

        Position memory removedPos = removePosition(provider, id, PPM_RESOLUTION);

        return
            addPosition(
                newProvider,
                removedPos.poolToken,
                removedPos.reserveToken,
                removedPos.poolAmount,
                removedPos.reserveAmount,
                removedPos.timestamp
            );
    }

    function claimBalance(uint256 startIndex, uint256 endIndex) external protected {

        (uint256[] memory amounts, uint256[] memory expirationTimes) =
            _store.lockedBalanceRange(msg.sender, startIndex, endIndex);

        uint256 totalAmount = 0;
        uint256 length = amounts.length;
        assert(length == expirationTimes.length);

        for (uint256 i = length; i > 0; i--) {
            uint256 index = i - 1;
            if (expirationTimes[index] > time()) {
                continue;
            }

            _store.removeLockedBalance(msg.sender, startIndex + index);
            totalAmount = totalAmount.add(amounts[index]);
        }

        if (totalAmount > 0) {
            _wallet.withdrawTokens(IReserveToken(address(_networkToken)), msg.sender, totalAmount);
        }
    }

    function poolROI(
        IDSToken poolToken,
        IReserveToken reserveToken,
        uint256 reserveAmount,
        uint256 poolRateN,
        uint256 poolRateD,
        uint256 reserveRateN,
        uint256 reserveRateD
    ) external view returns (uint256) {

        uint256 poolAmount = reserveAmount.mul(poolRateD).div(poolRateN);

        PackedRates memory packedRates = packRates(poolToken, reserveToken, reserveRateN, reserveRateD);

        uint256 protectedReturn =
            removeLiquidityTargetAmount(
                poolToken,
                reserveToken,
                poolAmount,
                reserveAmount,
                packedRates,
                time().sub(_settings.maxProtectionDelay()),
                time()
            );

        return protectedReturn.mul(PPM_RESOLUTION).div(reserveAmount);
    }

    function addPosition(
        address provider,
        IDSToken poolToken,
        IReserveToken reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount,
        uint256 timestamp
    ) internal returns (uint256) {

        (Fraction memory spotRate, Fraction memory averageRate) = reserveTokenRates(poolToken, reserveToken);
        verifyRateDeviation(spotRate.n, spotRate.d, averageRate.n, averageRate.d);

        notifyEventSubscribersOnAddingLiquidity(provider, poolToken, reserveToken, poolAmount, reserveAmount);

        _stats.increaseTotalAmounts(provider, poolToken, reserveToken, poolAmount, reserveAmount);
        _stats.addProviderPool(provider, poolToken);

        return
            _store.addProtectedLiquidity(
                provider,
                poolToken,
                reserveToken,
                poolAmount,
                reserveAmount,
                spotRate.n,
                spotRate.d,
                timestamp
            );
    }

    function removePosition(
        address provider,
        uint256 id,
        uint32 portion
    ) private returns (Position memory) {

        Position memory pos = providerPosition(id, provider);

        _poolWhitelisted(pos.poolToken);

        require(pos.timestamp < time(), "ERR_TOO_EARLY");

        if (portion == PPM_RESOLUTION) {
            notifyEventSubscribersOnRemovingLiquidity(
                id,
                pos.provider,
                pos.poolToken,
                pos.reserveToken,
                pos.poolAmount,
                pos.reserveAmount
            );

            _store.removeProtectedLiquidity(id);
        } else {
            uint256 fullPoolAmount = pos.poolAmount;
            uint256 fullReserveAmount = pos.reserveAmount;
            pos.poolAmount = pos.poolAmount.mul(portion) / PPM_RESOLUTION;
            pos.reserveAmount = pos.reserveAmount.mul(portion) / PPM_RESOLUTION;

            notifyEventSubscribersOnRemovingLiquidity(
                id,
                pos.provider,
                pos.poolToken,
                pos.reserveToken,
                pos.poolAmount,
                pos.reserveAmount
            );

            _store.updateProtectedLiquidityAmounts(
                id,
                fullPoolAmount - pos.poolAmount,
                fullReserveAmount - pos.reserveAmount
            );
        }

        _stats.decreaseTotalAmounts(pos.provider, pos.poolToken, pos.reserveToken, pos.poolAmount, pos.reserveAmount);

        _lastRemoveCheckpointStore.addCheckpoint(provider);

        return pos;
    }

    function lockTokens(address provider, uint256 amount) internal {

        uint256 expirationTime = time().add(_settings.lockDuration());
        _store.addLockedBalance(provider, amount, expirationTime);
    }

    function poolTokenRate(IDSToken poolToken, IReserveToken reserveToken)
        internal
        view
        virtual
        returns (Fraction memory)
    {

        uint256 poolTokenSupply = poolToken.totalSupply();

        IConverter converter = IConverter(payable(ownedBy(poolToken)));
        uint256 reserveBalance = converter.getConnectorBalance(reserveToken);

        return Fraction({ n: reserveBalance.mul(2), d: poolTokenSupply });
    }

    function reserveTokenRates(IDSToken poolToken, IReserveToken reserveToken)
        internal
        view
        returns (Fraction memory, Fraction memory)
    {

        ILiquidityPoolConverter converter = ILiquidityPoolConverter(payable(ownedBy(poolToken)));
        IReserveToken otherReserve = converterOtherReserve(converter, reserveToken);

        (uint256 spotRateN, uint256 spotRateD) = converterReserveBalances(converter, otherReserve, reserveToken);
        (uint256 averageRateN, uint256 averageRateD) = converter.recentAverageRate(reserveToken);

        return (Fraction({ n: spotRateN, d: spotRateD }), Fraction({ n: averageRateN, d: averageRateD }));
    }

    function packRates(
        IDSToken poolToken,
        IReserveToken reserveToken,
        uint256 addSpotRateN,
        uint256 addSpotRateD
    ) internal view returns (PackedRates memory) {

        (Fraction memory removeSpotRate, Fraction memory removeAverageRate) =
            reserveTokenRates(poolToken, reserveToken);

        assert(
            addSpotRateN <= MAX_UINT128 &&
                addSpotRateD <= MAX_UINT128 &&
                removeSpotRate.n <= MAX_UINT128 &&
                removeSpotRate.d <= MAX_UINT128 &&
                removeAverageRate.n <= MAX_UINT128 &&
                removeAverageRate.d <= MAX_UINT128
        );

        return
            PackedRates({
                addSpotRateN: uint128(addSpotRateN),
                addSpotRateD: uint128(addSpotRateD),
                removeSpotRateN: uint128(removeSpotRate.n),
                removeSpotRateD: uint128(removeSpotRate.d),
                removeAverageRateN: uint128(removeAverageRate.n),
                removeAverageRateD: uint128(removeAverageRate.d)
            });
    }

    function verifyRateDeviation(
        uint256 spotRateN,
        uint256 spotRateD,
        uint256 averageRateN,
        uint256 averageRateD
    ) internal view {

        uint256 ppmDelta = PPM_RESOLUTION - _settings.averageRateMaxDeviation();
        uint256 min = spotRateN.mul(averageRateD).mul(ppmDelta).mul(ppmDelta);
        uint256 mid = spotRateD.mul(averageRateN).mul(ppmDelta).mul(PPM_RESOLUTION);
        uint256 max = spotRateN.mul(averageRateD).mul(PPM_RESOLUTION).mul(PPM_RESOLUTION);
        require(min <= mid && mid <= max, "ERR_INVALID_RATE");
    }

    function addLiquidity(
        ILiquidityPoolConverter converter,
        IReserveToken reserveToken1,
        IReserveToken reserveToken2,
        uint256 reserveAmount1,
        uint256 reserveAmount2,
        uint256 value
    ) internal {

        IReserveToken[] memory reserveTokens = new IReserveToken[](2);
        uint256[] memory amounts = new uint256[](2);
        reserveTokens[0] = reserveToken1;
        reserveTokens[1] = reserveToken2;
        amounts[0] = reserveAmount1;
        amounts[1] = reserveAmount2;
        converter.addLiquidity{ value: value }(reserveTokens, amounts, 1);
    }

    function removeLiquidity(
        IDSToken poolToken,
        uint256 poolAmount,
        IReserveToken reserveToken1,
        IReserveToken reserveToken2
    ) internal {

        ILiquidityPoolConverter converter = ILiquidityPoolConverter(payable(ownedBy(poolToken)));

        IReserveToken[] memory reserveTokens = new IReserveToken[](2);
        uint256[] memory minReturns = new uint256[](2);
        reserveTokens[0] = reserveToken1;
        reserveTokens[1] = reserveToken2;
        minReturns[0] = 1;
        minReturns[1] = 1;
        converter.removeLiquidity(poolAmount, reserveTokens, minReturns);
    }

    function position(uint256 id) internal view returns (Position memory) {

        Position memory pos;
        (
            pos.provider,
            pos.poolToken,
            pos.reserveToken,
            pos.poolAmount,
            pos.reserveAmount,
            pos.reserveRateN,
            pos.reserveRateD,
            pos.timestamp
        ) = _store.protectedLiquidity(id);

        return pos;
    }

    function providerPosition(uint256 id, address provider) internal view returns (Position memory) {

        Position memory pos = position(id);
        require(pos.provider == provider, "ERR_ACCESS_DENIED");

        return pos;
    }

    function protectedAmountPlusFee(
        uint256 poolAmount,
        Fraction memory poolRate,
        Fraction memory addRate,
        Fraction memory removeRate
    ) internal pure returns (uint256) {

        uint256 n = MathEx.ceilSqrt(addRate.d.mul(removeRate.n)).mul(poolRate.n);
        uint256 d = MathEx.floorSqrt(addRate.n.mul(removeRate.d)).mul(poolRate.d);

        uint256 x = n * poolAmount;
        if (x / n == poolAmount) {
            return x / d;
        }

        (uint256 hi, uint256 lo) = n > poolAmount ? (n, poolAmount) : (poolAmount, n);
        (uint256 p, uint256 q) = MathEx.reducedRatio(hi, d, MAX_UINT256 / lo);
        uint256 min = (hi / d).mul(lo);

        if (q > 0) {
            return MathEx.max(min, (p * lo) / q);
        }
        return min;
    }

    function impLoss(Fraction memory prevRate, Fraction memory newRate) internal pure returns (Fraction memory) {

        uint256 ratioN = newRate.n.mul(prevRate.d);
        uint256 ratioD = newRate.d.mul(prevRate.n);

        uint256 prod = ratioN * ratioD;
        uint256 root =
            prod / ratioN == ratioD ? MathEx.floorSqrt(prod) : MathEx.floorSqrt(ratioN) * MathEx.floorSqrt(ratioD);
        uint256 sum = ratioN.add(ratioD);

        if (sum % 2 == 0) {
            sum /= 2;
            return Fraction({ n: sum - root, d: sum });
        }
        return Fraction({ n: sum - root * 2, d: sum });
    }

    function protectionLevel(uint256 addTimestamp, uint256 removeTimestamp) internal view returns (Fraction memory) {

        uint256 timeElapsed = removeTimestamp.sub(addTimestamp);
        uint256 minProtectionDelay = _settings.minProtectionDelay();
        uint256 maxProtectionDelay = _settings.maxProtectionDelay();
        if (timeElapsed < minProtectionDelay) {
            return Fraction({ n: 0, d: 1 });
        }

        if (timeElapsed >= maxProtectionDelay) {
            return Fraction({ n: 1, d: 1 });
        }

        return Fraction({ n: timeElapsed, d: maxProtectionDelay });
    }

    function compensationAmount(
        uint256 amount,
        uint256 total,
        Fraction memory loss,
        Fraction memory level
    ) internal pure returns (uint256) {

        uint256 levelN = level.n.mul(amount);
        uint256 levelD = level.d;
        uint256 maxVal = MathEx.max(MathEx.max(levelN, levelD), total);
        (uint256 lossN, uint256 lossD) = MathEx.reducedRatio(loss.n, loss.d, MAX_UINT256 / maxVal);
        return total.mul(lossD.sub(lossN)).div(lossD).add(lossN.mul(levelN).div(lossD.mul(levelD)));
    }

    function networkCompensation(
        uint256 targetAmount,
        uint256 baseAmount,
        PackedRates memory packedRates
    ) internal view returns (uint256) {

        if (targetAmount <= baseAmount) {
            return 0;
        }

        uint256 delta =
            (targetAmount - baseAmount).mul(packedRates.removeAverageRateN).div(packedRates.removeAverageRateD);

        if (delta >= _settings.minNetworkCompensation()) {
            return delta;
        }

        return 0;
    }

    function mintNetworkTokens(
        address owner,
        IConverterAnchor poolAnchor,
        uint256 amount
    ) private {

        _systemStore.incNetworkTokensMinted(poolAnchor, amount);
        _networkTokenGovernance.mint(owner, amount);
    }

    function burnNetworkTokens(IConverterAnchor poolAnchor, uint256 amount) private {

        _systemStore.decNetworkTokensMinted(poolAnchor, amount);
        _networkTokenGovernance.burn(amount);
    }

    function notifyEventSubscribersOnAddingLiquidity(
        address provider,
        IDSToken poolToken,
        IReserveToken reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount
    ) private {

        address[] memory subscribers = _settings.subscribers();
        uint256 length = subscribers.length;
        for (uint256 i = 0; i < length; i++) {
            ILiquidityProtectionEventsSubscriber(subscribers[i]).onAddingLiquidity(
                provider,
                poolToken,
                reserveToken,
                poolAmount,
                reserveAmount
            );
        }
    }

    function notifyEventSubscribersOnRemovingLiquidity(
        uint256 id,
        address provider,
        IDSToken poolToken,
        IReserveToken reserveToken,
        uint256 poolAmount,
        uint256 reserveAmount
    ) private {

        address[] memory subscribers = _settings.subscribers();
        uint256 length = subscribers.length;
        for (uint256 i = 0; i < length; i++) {
            ILiquidityProtectionEventsSubscriber(subscribers[i]).onRemovingLiquidity(
                id,
                provider,
                poolToken,
                reserveToken,
                poolAmount,
                reserveAmount
            );
        }
    }

    function converterReserveBalances(
        IConverter converter,
        IReserveToken reserveToken1,
        IReserveToken reserveToken2
    ) private view returns (uint256, uint256) {

        return (converter.getConnectorBalance(reserveToken1), converter.getConnectorBalance(reserveToken2));
    }

    function converterOtherReserve(IConverter converter, IReserveToken thisReserve)
        private
        view
        returns (IReserveToken)
    {

        IReserveToken otherReserve = converter.connectorTokens(0);
        return otherReserve != thisReserve ? otherReserve : converter.connectorTokens(1);
    }

    function ownedBy(IOwned owned) private view returns (address) {

        return owned.owner();
    }

    function isNetworkToken(IReserveToken reserveToken) private view returns (bool) {

        return address(reserveToken) == address(_networkToken);
    }
}