


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

contract ConverterVersion {

    uint16 public constant version = 46;
}



pragma solidity 0.6.12;

interface IOwned {

    function owner() external view returns (address);


    function transferOwnership(address _newOwner) external;


    function acceptOwnership() external;

}



pragma solidity 0.6.12;


interface IConverterAnchor is IOwned {


}



pragma solidity 0.6.12;




interface IConverter is IOwned {

    function converterType() external pure returns (uint16);


    function anchor() external view returns (IConverterAnchor);


    function isActive() external view returns (bool);


    function targetAmountAndFee(
        IERC20 _sourceToken,
        IERC20 _targetToken,
        uint256 _amount
    ) external view returns (uint256, uint256);


    function convert(
        IERC20 _sourceToken,
        IERC20 _targetToken,
        uint256 _amount,
        address _trader,
        address payable _beneficiary
    ) external payable returns (uint256);


    function conversionFee() external view returns (uint32);


    function maxConversionFee() external view returns (uint32);


    function reserveBalance(IERC20 _reserveToken) external view returns (uint256);


    receive() external payable;

    function transferAnchorOwnership(address _newOwner) external;


    function acceptAnchorOwnership() external;


    function setConversionFee(uint32 _conversionFee) external;


    function addReserve(IERC20 _token, uint32 _weight) external;


    function transferReservesOnUpgrade(address _newConverter) external;


    function onUpgradeComplete() external;


    function token() external view returns (IConverterAnchor);


    function transferTokenOwnership(address _newOwner) external;


    function acceptTokenOwnership() external;


    function connectors(IERC20 _address)
        external
        view
        returns (
            uint256,
            uint32,
            bool,
            bool,
            bool
        );


    function getConnectorBalance(IERC20 _connectorToken) external view returns (uint256);


    function connectorTokens(uint256 _index) external view returns (IERC20);


    function connectorTokenCount() external view returns (uint16);


    event Activation(uint16 indexed _type, IConverterAnchor indexed _anchor, bool indexed _activated);

    event Conversion(
        IERC20 indexed _fromToken,
        IERC20 indexed _toToken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionFee
    );

    event TokenRateUpdate(IERC20 indexed _token1, IERC20 indexed _token2, uint256 _rateN, uint256 _rateD);

    event ConversionFeeUpdate(uint32 _prevFee, uint32 _newFee);
}



pragma solidity 0.6.12;

interface IConverterUpgrader {

    function upgrade(bytes32 _version) external;


    function upgrade(uint16 _version) external;

}



pragma solidity 0.6.12;



interface ITokenHolder is IOwned {

    receive() external payable;

    function withdrawTokens(
        IERC20 token,
        address payable to,
        uint256 amount
    ) external;


    function withdrawTokensMultiple(
        IERC20[] calldata tokens,
        address payable to,
        uint256[] calldata amounts
    ) external;

}



pragma solidity 0.6.12;


interface INetworkSettings {

    function networkFeeParams() external view returns (ITokenHolder, uint32);


    function networkFeeWallet() external view returns (ITokenHolder);


    function networkFee() external view returns (uint32);

}



pragma solidity 0.6.12;




interface IDSToken is IConverterAnchor, IERC20 {

    function issue(address _to, uint256 _amount) external;


    function destroy(address _from, uint256 _amount) external;

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


contract Utils {

    uint32 internal constant PPM_RESOLUTION = 1000000;
    IERC20 internal constant NATIVE_TOKEN_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

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

interface IContractRegistry {

    function addressOf(bytes32 _contractName) external view returns (address);

}



pragma solidity 0.6.12;




contract ContractRegistryClient is Owned, Utils {

    bytes32 internal constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 internal constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 internal constant BANCOR_FORMULA = "BancorFormula";
    bytes32 internal constant CONVERTER_FACTORY = "ConverterFactory";
    bytes32 internal constant CONVERSION_PATH_FINDER = "ConversionPathFinder";
    bytes32 internal constant CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 internal constant CONVERTER_REGISTRY = "BancorConverterRegistry";
    bytes32 internal constant CONVERTER_REGISTRY_DATA = "BancorConverterRegistryData";
    bytes32 internal constant BNT_TOKEN = "BNTToken";
    bytes32 internal constant BANCOR_X = "BancorX";
    bytes32 internal constant BANCOR_X_UPGRADER = "BancorXUpgrader";
    bytes32 internal constant LIQUIDITY_PROTECTION = "LiquidityProtection";
    bytes32 internal constant NETWORK_SETTINGS = "NetworkSettings";

    IContractRegistry public registry; // address of the current contract-registry
    IContractRegistry public prevRegistry; // address of the previous contract-registry
    bool public onlyOwnerCanUpdateRegistry; // only an owner can update the contract-registry

    modifier only(bytes32 _contractName) {

        _only(_contractName);
        _;
    }

    function _only(bytes32 _contractName) internal view {

        require(msg.sender == addressOf(_contractName), "ERR_ACCESS_DENIED");
    }

    constructor(IContractRegistry _registry) internal validAddress(address(_registry)) {
        registry = IContractRegistry(_registry);
        prevRegistry = IContractRegistry(_registry);
    }

    function updateRegistry() public {

        require(msg.sender == owner || !onlyOwnerCanUpdateRegistry, "ERR_ACCESS_DENIED");

        IContractRegistry newRegistry = IContractRegistry(addressOf(CONTRACT_REGISTRY));

        require(newRegistry != registry && address(newRegistry) != address(0), "ERR_INVALID_REGISTRY");

        require(newRegistry.addressOf(CONTRACT_REGISTRY) != address(0), "ERR_INVALID_REGISTRY");

        prevRegistry = registry;

        registry = newRegistry;
    }

    function restoreRegistry() public ownerOnly {

        registry = prevRegistry;
    }

    function restrictRegistryUpdate(bool _onlyOwnerCanUpdateRegistry) public ownerOnly {

        onlyOwnerCanUpdateRegistry = _onlyOwnerCanUpdateRegistry;
    }

    function addressOf(bytes32 _contractName) internal view returns (address) {

        return registry.addressOf(_contractName);
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

contract Time {

    function time() internal view virtual returns (uint256) {

        return block.timestamp;
    }
}



pragma solidity 0.6.12;













contract StandardPoolConverter is ConverterVersion, IConverter, ContractRegistryClient, ReentrancyGuard, Time {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using MathEx for *;

    uint256 private constant MAX_UINT128 = 2**128 - 1;
    uint256 private constant MAX_UINT112 = 2**112 - 1;
    uint256 private constant MAX_UINT32 = 2**32 - 1;
    uint256 private constant AVERAGE_RATE_PERIOD = 10 minutes;

    uint256 private __reserveBalances;
    uint256 private _reserveBalancesProduct;
    IERC20[] private __reserveTokens;
    mapping(IERC20 => uint256) private __reserveIds;

    IConverterAnchor public override anchor; // converter anchor contract
    uint32 public override maxConversionFee; // maximum conversion fee, represented in ppm, 0...1000000
    uint32 public override conversionFee; // current conversion fee, represented in ppm, 0...maxConversionFee

    uint256 public averageRateInfo;

    event LiquidityAdded(
        address indexed _provider,
        IERC20 indexed _reserveToken,
        uint256 _amount,
        uint256 _newBalance,
        uint256 _newSupply
    );

    event LiquidityRemoved(
        address indexed _provider,
        IERC20 indexed _reserveToken,
        uint256 _amount,
        uint256 _newBalance,
        uint256 _newSupply
    );

    constructor(
        IConverterAnchor _anchor,
        IContractRegistry _registry,
        uint32 _maxConversionFee
    ) public ContractRegistryClient(_registry) validAddress(address(_anchor)) validConversionFee(_maxConversionFee) {
        anchor = _anchor;
        maxConversionFee = _maxConversionFee;
    }

    modifier active() {

        _active();
        _;
    }

    function _active() internal view {

        require(isActive(), "ERR_INACTIVE");
    }

    modifier inactive() {

        _inactive();
        _;
    }

    function _inactive() internal view {

        require(!isActive(), "ERR_ACTIVE");
    }

    modifier validReserve(IERC20 _address) {

        _validReserve(_address);
        _;
    }

    function _validReserve(IERC20 _address) internal view {

        require(__reserveIds[_address] != 0, "ERR_INVALID_RESERVE");
    }

    modifier validConversionFee(uint32 _conversionFee) {

        _validConversionFee(_conversionFee);
        _;
    }

    function _validConversionFee(uint32 _conversionFee) internal pure {

        require(_conversionFee <= PPM_RESOLUTION, "ERR_INVALID_CONVERSION_FEE");
    }

    modifier validReserveWeight(uint32 _weight) {

        _validReserveWeight(_weight);
        _;
    }

    function _validReserveWeight(uint32 _weight) internal pure {

        require(_weight == PPM_RESOLUTION / 2, "ERR_INVALID_RESERVE_WEIGHT");
    }

    function converterType() public pure virtual override returns (uint16) {

        return 3;
    }

    receive() external payable override(IConverter) validReserve(NATIVE_TOKEN_ADDRESS) {}

    function isV28OrHigher() public pure returns (bool) {

        return true;
    }

    function isActive() public view virtual override returns (bool) {

        return anchor.owner() == address(this);
    }

    function transferAnchorOwnership(address _newOwner) public override ownerOnly only(CONVERTER_UPGRADER) {

        anchor.transferOwnership(_newOwner);
    }

    function acceptAnchorOwnership() public virtual override ownerOnly {

        require(reserveTokenCount() == 2, "ERR_INVALID_RESERVE_COUNT");
        anchor.acceptOwnership();
        syncReserveBalances(0);
        emit Activation(converterType(), anchor, true);
    }

    function setConversionFee(uint32 _conversionFee) public override ownerOnly {

        require(_conversionFee <= maxConversionFee, "ERR_INVALID_CONVERSION_FEE");
        emit ConversionFeeUpdate(conversionFee, _conversionFee);
        conversionFee = _conversionFee;
    }

    function transferReservesOnUpgrade(address _newConverter)
        external
        override
        protected
        ownerOnly
        only(CONVERTER_UPGRADER)
    {

        uint256 reserveCount = __reserveTokens.length;
        for (uint256 i = 0; i < reserveCount; ++i) {
            IERC20 reserveToken = __reserveTokens[i];

            uint256 amount;
            if (reserveToken == NATIVE_TOKEN_ADDRESS) {
                amount = address(this).balance;
            } else {
                amount = reserveToken.balanceOf(address(this));
            }

            safeTransfer(reserveToken, _newConverter, amount);

            syncReserveBalance(reserveToken);
        }
    }

    function upgrade() public ownerOnly {

        IConverterUpgrader converterUpgrader = IConverterUpgrader(addressOf(CONVERTER_UPGRADER));

        emit Activation(converterType(), anchor, false);

        transferOwnership(address(converterUpgrader));
        converterUpgrader.upgrade(version);
        acceptOwnership();
    }

    function onUpgradeComplete()
        external
        override
        protected
        ownerOnly
        only(CONVERTER_UPGRADER)
    {

        (uint256 reserveBalance0, uint256 reserveBalance1) = reserveBalances(1, 2);
        _reserveBalancesProduct = reserveBalance0 * reserveBalance1;
    }

    function reserveTokenCount() public view returns (uint16) {

        return uint16(__reserveTokens.length);
    }

    function reserveTokens() public view returns (IERC20[] memory) {

        return __reserveTokens;
    }

    function addReserve(IERC20 _token, uint32 _weight)
        public
        virtual
        override
        ownerOnly
        inactive
        validExternalAddress(address(_token))
        validReserveWeight(_weight)
    {

        require(address(_token) != address(anchor) && __reserveIds[_token] == 0, "ERR_INVALID_RESERVE");
        require(reserveTokenCount() < 2, "ERR_INVALID_RESERVE_COUNT");

        __reserveTokens.push(_token);
        __reserveIds[_token] = __reserveTokens.length;
    }

    function reserveWeight(IERC20 _reserveToken) public view validReserve(_reserveToken) returns (uint32) {

        return PPM_RESOLUTION / 2;
    }

    function reserveBalance(IERC20 _reserveToken) public view override returns (uint256) {

        uint256 reserveId = __reserveIds[_reserveToken];
        require(reserveId != 0, "ERR_INVALID_RESERVE");
        return reserveBalance(reserveId);
    }

    function reserveBalances() public view returns (uint256, uint256) {

        return reserveBalances(1, 2);
    }

    function syncReserveBalances() external {

        syncReserveBalances(0);
    }

    function processNetworkFees() external protected {

        (uint256 reserveBalance0, uint256 reserveBalance1) = processNetworkFees(0);
        _reserveBalancesProduct = reserveBalance0 * reserveBalance1;
    }

    function processNetworkFees(uint256 _value) internal returns (uint256, uint256) {

        syncReserveBalances(_value);
        (uint256 reserveBalance0, uint256 reserveBalance1) = reserveBalances(1, 2);
        (ITokenHolder wallet, uint256 fee0, uint256 fee1) = networkWalletAndFees(reserveBalance0, reserveBalance1);
        reserveBalance0 -= fee0;
        reserveBalance1 -= fee1;
        setReserveBalances(1, 2, reserveBalance0, reserveBalance1);
        safeTransfer(__reserveTokens[0], address(wallet), fee0);
        safeTransfer(__reserveTokens[1], address(wallet), fee1);
        return (reserveBalance0, reserveBalance1);
    }

    function baseReserveBalances(IERC20[] memory _reserveTokens) internal view returns (uint256[2] memory) {

        uint256 reserveId0 = __reserveIds[_reserveTokens[0]];
        uint256 reserveId1 = __reserveIds[_reserveTokens[1]];
        (uint256 reserveBalance0, uint256 reserveBalance1) = reserveBalances(reserveId0, reserveId1);
        (, uint256 fee0, uint256 fee1) = networkWalletAndFees(reserveBalance0, reserveBalance1);
        return [reserveBalance0 - fee0, reserveBalance1 - fee1];
    }

    function convert(
        IERC20 _sourceToken,
        IERC20 _targetToken,
        uint256 _amount,
        address _trader,
        address payable _beneficiary
    ) public payable override protected only(BANCOR_NETWORK) returns (uint256) {

        require(_sourceToken != _targetToken, "ERR_SAME_SOURCE_TARGET");

        return doConvert(_sourceToken, _targetToken, _amount, _trader, _beneficiary);
    }

    function calculateFee(uint256 _targetAmount) internal view returns (uint256) {

        return _targetAmount.mul(conversionFee) / PPM_RESOLUTION;
    }

    function calculateFeeInv(uint256 _targetAmount) internal view returns (uint256) {

        return _targetAmount.mul(conversionFee).div(PPM_RESOLUTION - conversionFee);
    }

    function reserveBalance(uint256 _reserveId) internal view returns (uint256) {

        return decodeReserveBalance(__reserveBalances, _reserveId);
    }

    function reserveBalances(uint256 _sourceId, uint256 _targetId) internal view returns (uint256, uint256) {

        require((_sourceId == 1 && _targetId == 2) || (_sourceId == 2 && _targetId == 1), "ERR_INVALID_RESERVES");
        return decodeReserveBalances(__reserveBalances, _sourceId, _targetId);
    }

    function setReserveBalance(uint256 _reserveId, uint256 _reserveBalance) internal {

        require(_reserveBalance <= MAX_UINT128, "ERR_RESERVE_BALANCE_OVERFLOW");
        uint256 otherBalance = decodeReserveBalance(__reserveBalances, 3 - _reserveId);
        __reserveBalances = encodeReserveBalances(_reserveBalance, _reserveId, otherBalance, 3 - _reserveId);
    }

    function setReserveBalances(
        uint256 _sourceId,
        uint256 _targetId,
        uint256 _sourceBalance,
        uint256 _targetBalance
    ) internal {

        require(_sourceBalance <= MAX_UINT128 && _targetBalance <= MAX_UINT128, "ERR_RESERVE_BALANCE_OVERFLOW");
        __reserveBalances = encodeReserveBalances(_sourceBalance, _sourceId, _targetBalance, _targetId);
    }

    function syncReserveBalance(IERC20 _reserveToken) internal {

        uint256 reserveId = __reserveIds[_reserveToken];
        uint256 balance =
            _reserveToken == NATIVE_TOKEN_ADDRESS ? address(this).balance : _reserveToken.balanceOf(address(this));
        setReserveBalance(reserveId, balance);
    }

    function syncReserveBalances(uint256 _value) internal {

        IERC20 _reserveToken0 = __reserveTokens[0];
        IERC20 _reserveToken1 = __reserveTokens[1];
        uint256 balance0 =
            _reserveToken0 == NATIVE_TOKEN_ADDRESS
                ? address(this).balance - _value
                : _reserveToken0.balanceOf(address(this));
        uint256 balance1 =
            _reserveToken1 == NATIVE_TOKEN_ADDRESS
                ? address(this).balance - _value
                : _reserveToken1.balanceOf(address(this));
        setReserveBalances(1, 2, balance0, balance1);
    }

    function dispatchConversionEvent(
        IERC20 _sourceToken,
        IERC20 _targetToken,
        address _trader,
        uint256 _amount,
        uint256 _returnAmount,
        uint256 _feeAmount
    ) internal {

        emit Conversion(_sourceToken, _targetToken, _trader, _amount, _returnAmount, int256(_feeAmount));
    }

    function targetAmountAndFee(
        IERC20 _sourceToken,
        IERC20 _targetToken,
        uint256 _amount
    ) public view virtual override active returns (uint256, uint256) {

        uint256 sourceId = __reserveIds[_sourceToken];
        uint256 targetId = __reserveIds[_targetToken];

        (uint256 sourceBalance, uint256 targetBalance) = reserveBalances(sourceId, targetId);

        return targetAmountAndFee(_sourceToken, _targetToken, sourceBalance, targetBalance, _amount);
    }

    function targetAmountAndFee(
        IERC20, /* _sourceToken */
        IERC20, /* _targetToken */
        uint256 _sourceBalance,
        uint256 _targetBalance,
        uint256 _amount
    ) internal view virtual returns (uint256, uint256) {

        uint256 amount = crossReserveTargetAmount(_sourceBalance, _targetBalance, _amount);

        uint256 fee = calculateFee(amount);

        return (amount - fee, fee);
    }

    function sourceAmountAndFee(
        IERC20 _sourceToken,
        IERC20 _targetToken,
        uint256 _amount
    ) public view virtual active returns (uint256, uint256) {

        uint256 sourceId = __reserveIds[_sourceToken];
        uint256 targetId = __reserveIds[_targetToken];

        (uint256 sourceBalance, uint256 targetBalance) = reserveBalances(sourceId, targetId);

        uint256 fee = calculateFeeInv(_amount);

        uint256 amount = crossReserveSourceAmount(sourceBalance, targetBalance, _amount.add(fee));

        return (amount, fee);
    }

    function doConvert(
        IERC20 _sourceToken,
        IERC20 _targetToken,
        uint256 _amount,
        address _trader,
        address payable _beneficiary
    ) internal returns (uint256) {

        updateRecentAverageRate();

        uint256 sourceId = __reserveIds[_sourceToken];
        uint256 targetId = __reserveIds[_targetToken];

        (uint256 sourceBalance, uint256 targetBalance) = reserveBalances(sourceId, targetId);

        (uint256 amount, uint256 fee) =
            targetAmountAndFee(_sourceToken, _targetToken, sourceBalance, targetBalance, _amount);

        require(amount != 0, "ERR_ZERO_TARGET_AMOUNT");

        assert(amount < targetBalance);

        uint256 actualSourceBalance;
        if (_sourceToken == NATIVE_TOKEN_ADDRESS) {
            actualSourceBalance = address(this).balance;
            require(msg.value == _amount, "ERR_ETH_AMOUNT_MISMATCH");
        } else {
            actualSourceBalance = _sourceToken.balanceOf(address(this));
            require(msg.value == 0 && actualSourceBalance.sub(sourceBalance) >= _amount, "ERR_INVALID_AMOUNT");
        }

        setReserveBalances(sourceId, targetId, actualSourceBalance, targetBalance - amount);

        safeTransfer(_targetToken, _beneficiary, amount);

        dispatchConversionEvent(_sourceToken, _targetToken, _trader, _amount, amount, fee);

        dispatchTokenRateUpdateEvents(_sourceToken, _targetToken, actualSourceBalance, targetBalance - amount);

        return amount;
    }

    function recentAverageRate(IERC20 _token) external view validReserve(_token) returns (uint256, uint256) {

        uint256 rate = calcRecentAverageRate(averageRateInfo);

        uint256 rateN = decodeAverageRateN(rate);
        uint256 rateD = decodeAverageRateD(rate);

        if (_token == __reserveTokens[0]) {
            return (rateN, rateD);
        }

        return (rateD, rateN);
    }

    function updateRecentAverageRate() internal {

        uint256 averageRateInfo1 = averageRateInfo;
        uint256 averageRateInfo2 = calcRecentAverageRate(averageRateInfo1);
        if (averageRateInfo1 != averageRateInfo2) {
            averageRateInfo = averageRateInfo2;
        }
    }

    function calcRecentAverageRate(uint256 _averageRateInfo) internal view returns (uint256) {

        uint256 prevAverageRateT = decodeAverageRateT(_averageRateInfo);
        uint256 prevAverageRateN = decodeAverageRateN(_averageRateInfo);
        uint256 prevAverageRateD = decodeAverageRateD(_averageRateInfo);

        uint256 currentTime = time();
        uint256 timeElapsed = currentTime - prevAverageRateT;

        if (timeElapsed == 0) {
            return _averageRateInfo;
        }

        (uint256 currentRateD, uint256 currentRateN) = reserveBalances();

        if (timeElapsed >= AVERAGE_RATE_PERIOD || prevAverageRateT == 0) {
            (currentRateN, currentRateD) = MathEx.reducedRatio(currentRateN, currentRateD, MAX_UINT112);
            return encodeAverageRateInfo(currentTime, currentRateN, currentRateD);
        }

        uint256 x = prevAverageRateD.mul(currentRateN);
        uint256 y = prevAverageRateN.mul(currentRateD);

        uint256 newRateN = y.mul(AVERAGE_RATE_PERIOD - timeElapsed).add(x.mul(timeElapsed));
        uint256 newRateD = prevAverageRateD.mul(currentRateD).mul(AVERAGE_RATE_PERIOD);

        (newRateN, newRateD) = MathEx.reducedRatio(newRateN, newRateD, MAX_UINT112);
        return encodeAverageRateInfo(currentTime, newRateN, newRateD);
    }

    function addLiquidity(
        IERC20[] memory _reserveTokens,
        uint256[] memory _reserveAmounts,
        uint256 _minReturn
    ) public payable protected active returns (uint256) {

        verifyLiquidityInput(_reserveTokens, _reserveAmounts, _minReturn);

        for (uint256 i = 0; i < 2; i++) {
            if (_reserveTokens[i] == NATIVE_TOKEN_ADDRESS) {
                require(_reserveAmounts[i] == msg.value, "ERR_ETH_AMOUNT_MISMATCH");
            }
        }

        if (msg.value > 0) {
            require(__reserveIds[NATIVE_TOKEN_ADDRESS] != 0, "ERR_NO_ETH_RESERVE");
        }

        IDSToken poolToken = IDSToken(address(anchor));

        uint256 totalSupply = poolToken.totalSupply();

        uint256[2] memory prevReserveBalances;
        uint256[2] memory newReserveBalances;

        (prevReserveBalances[0], prevReserveBalances[1]) = processNetworkFees(msg.value);

        uint256 amount;
        uint256[2] memory reserveAmounts;

        if (totalSupply == 0) {
            amount = MathEx.geometricMean(_reserveAmounts);
            reserveAmounts[0] = _reserveAmounts[0];
            reserveAmounts[1] = _reserveAmounts[1];
        } else {
            (amount, reserveAmounts) = addLiquidityAmounts(
                _reserveTokens,
                _reserveAmounts,
                prevReserveBalances,
                totalSupply
            );
        }

        uint256 newPoolTokenSupply = totalSupply.add(amount);
        for (uint256 i = 0; i < 2; i++) {
            IERC20 reserveToken = _reserveTokens[i];
            uint256 reserveAmount = reserveAmounts[i];
            require(reserveAmount > 0, "ERR_ZERO_TARGET_AMOUNT");
            assert(reserveAmount <= _reserveAmounts[i]);

            if (reserveToken != NATIVE_TOKEN_ADDRESS) {
                reserveToken.safeTransferFrom(msg.sender, address(this), reserveAmount);
            } else if (_reserveAmounts[i] > reserveAmount) {
                msg.sender.transfer(_reserveAmounts[i] - reserveAmount);
            }

            newReserveBalances[i] = prevReserveBalances[i].add(reserveAmount);

            emit LiquidityAdded(msg.sender, reserveToken, reserveAmount, newReserveBalances[i], newPoolTokenSupply);

            emit TokenRateUpdate(poolToken, reserveToken, newReserveBalances[i], newPoolTokenSupply);
        }

        setReserveBalances(1, 2, newReserveBalances[0], newReserveBalances[1]);

        _reserveBalancesProduct = newReserveBalances[0] * newReserveBalances[1];

        require(amount >= _minReturn, "ERR_RETURN_TOO_LOW");

        poolToken.issue(msg.sender, amount);

        return amount;
    }

    function addLiquidityAmounts(
        IERC20[] memory, /* _reserveTokens */
        uint256[] memory _reserveAmounts,
        uint256[2] memory _reserveBalances,
        uint256 _totalSupply
    ) internal view virtual returns (uint256, uint256[2] memory) {

        this;

        uint256 index =
            _reserveAmounts[0].mul(_reserveBalances[1]) < _reserveAmounts[1].mul(_reserveBalances[0]) ? 0 : 1;
        uint256 amount = fundSupplyAmount(_totalSupply, _reserveBalances[index], _reserveAmounts[index]);

        uint256[2] memory reserveAmounts =
            [fundCost(_totalSupply, _reserveBalances[0], amount), fundCost(_totalSupply, _reserveBalances[1], amount)];

        return (amount, reserveAmounts);
    }

    function removeLiquidity(
        uint256 _amount,
        IERC20[] memory _reserveTokens,
        uint256[] memory _reserveMinReturnAmounts
    ) public protected active returns (uint256[] memory) {

        bool inputRearranged = verifyLiquidityInput(_reserveTokens, _reserveMinReturnAmounts, _amount);

        IDSToken poolToken = IDSToken(address(anchor));

        uint256 totalSupply = poolToken.totalSupply();

        poolToken.destroy(msg.sender, _amount);

        uint256 newPoolTokenSupply = totalSupply.sub(_amount);

        uint256[2] memory prevReserveBalances;
        uint256[2] memory newReserveBalances;

        (prevReserveBalances[0], prevReserveBalances[1]) = processNetworkFees(0);

        uint256[] memory reserveAmounts = removeLiquidityReserveAmounts(_amount, totalSupply, prevReserveBalances);

        for (uint256 i = 0; i < 2; i++) {
            IERC20 reserveToken = _reserveTokens[i];
            uint256 reserveAmount = reserveAmounts[i];
            require(reserveAmount >= _reserveMinReturnAmounts[i], "ERR_ZERO_TARGET_AMOUNT");

            newReserveBalances[i] = prevReserveBalances[i].sub(reserveAmount);

            safeTransfer(reserveToken, msg.sender, reserveAmount);

            emit LiquidityRemoved(msg.sender, reserveToken, reserveAmount, newReserveBalances[i], newPoolTokenSupply);

            emit TokenRateUpdate(poolToken, reserveToken, newReserveBalances[i], newPoolTokenSupply);
        }

        setReserveBalances(1, 2, newReserveBalances[0], newReserveBalances[1]);

        _reserveBalancesProduct = newReserveBalances[0] * newReserveBalances[1];

        if (inputRearranged) {
            uint256 tempReserveAmount = reserveAmounts[0];
            reserveAmounts[0] = reserveAmounts[1];
            reserveAmounts[1] = tempReserveAmount;
        }

        return reserveAmounts;
    }

    function addLiquidityCost(
        IERC20[] memory _reserveTokens,
        uint256 _reserveTokenIndex,
        uint256 _reserveAmount
    ) public view returns (uint256[] memory) {

        uint256 totalSupply = IDSToken(address(anchor)).totalSupply();
        uint256[2] memory baseBalances = baseReserveBalances(_reserveTokens);
        uint256 amount = fundSupplyAmount(totalSupply, baseBalances[_reserveTokenIndex], _reserveAmount);

        uint256[] memory reserveAmounts = new uint256[](2);
        reserveAmounts[0] = fundCost(totalSupply, baseBalances[0], amount);
        reserveAmounts[1] = fundCost(totalSupply, baseBalances[1], amount);
        return reserveAmounts;
    }

    function addLiquidityReturn(IERC20[] memory _reserveTokens, uint256[] memory _reserveAmounts)
        public
        view
        returns (uint256)
    {

        uint256 totalSupply = IDSToken(address(anchor)).totalSupply();
        uint256[2] memory baseBalances = baseReserveBalances(_reserveTokens);
        (uint256 amount, ) = addLiquidityAmounts(_reserveTokens, _reserveAmounts, baseBalances, totalSupply);
        return amount;
    }

    function removeLiquidityReturn(uint256 _amount, IERC20[] memory _reserveTokens)
        public
        view
        returns (uint256[] memory)
    {

        uint256 totalSupply = IDSToken(address(anchor)).totalSupply();
        uint256[2] memory baseBalances = baseReserveBalances(_reserveTokens);
        return removeLiquidityReserveAmounts(_amount, totalSupply, baseBalances);
    }

    function verifyLiquidityInput(
        IERC20[] memory _reserveTokens,
        uint256[] memory _reserveAmounts,
        uint256 _amount
    ) private view returns (bool) {

        require(validReserveAmounts(_reserveAmounts) && _amount > 0, "ERR_ZERO_AMOUNT");

        uint256 reserve0Id = __reserveIds[_reserveTokens[0]];
        uint256 reserve1Id = __reserveIds[_reserveTokens[1]];

        if (reserve0Id == 2 && reserve1Id == 1) {
            IERC20 tempReserveToken = _reserveTokens[0];
            _reserveTokens[0] = _reserveTokens[1];
            _reserveTokens[1] = tempReserveToken;
            uint256 tempReserveAmount = _reserveAmounts[0];
            _reserveAmounts[0] = _reserveAmounts[1];
            _reserveAmounts[1] = tempReserveAmount;
            return true;
        }

        require(reserve0Id == 1 && reserve1Id == 2, "ERR_INVALID_RESERVE");
        return false;
    }

    function validReserveAmounts(uint256[] memory _reserveAmounts) internal pure virtual returns (bool) {

        return _reserveAmounts[0] > 0 && _reserveAmounts[1] > 0;
    }

    function removeLiquidityReserveAmounts(
        uint256 _amount,
        uint256 _totalSupply,
        uint256[2] memory _reserveBalances
    ) private pure returns (uint256[] memory) {

        uint256[] memory reserveAmounts = new uint256[](2);
        reserveAmounts[0] = liquidateReserveAmount(_totalSupply, _reserveBalances[0], _amount);
        reserveAmounts[1] = liquidateReserveAmount(_totalSupply, _reserveBalances[1], _amount);
        return reserveAmounts;
    }

    function dispatchTokenRateUpdateEvents(
        IERC20 _sourceToken,
        IERC20 _targetToken,
        uint256 _sourceBalance,
        uint256 _targetBalance
    ) private {

        IDSToken poolToken = IDSToken(address(anchor));

        uint256 poolTokenSupply = poolToken.totalSupply();

        emit TokenRateUpdate(_sourceToken, _targetToken, _targetBalance, _sourceBalance);

        emit TokenRateUpdate(poolToken, _sourceToken, _sourceBalance, poolTokenSupply);
        emit TokenRateUpdate(poolToken, _targetToken, _targetBalance, poolTokenSupply);
    }

    function encodeReserveBalance(uint256 _balance, uint256 _id) private pure returns (uint256) {

        assert(_balance <= MAX_UINT128 && (_id == 1 || _id == 2));
        return _balance << ((_id - 1) * 128);
    }

    function decodeReserveBalance(uint256 _balances, uint256 _id) private pure returns (uint256) {

        assert(_id == 1 || _id == 2);
        return (_balances >> ((_id - 1) * 128)) & MAX_UINT128;
    }

    function encodeReserveBalances(
        uint256 _balance0,
        uint256 _id0,
        uint256 _balance1,
        uint256 _id1
    ) private pure returns (uint256) {

        return encodeReserveBalance(_balance0, _id0) | encodeReserveBalance(_balance1, _id1);
    }

    function decodeReserveBalances(
        uint256 _balances,
        uint256 _id0,
        uint256 _id1
    ) private pure returns (uint256, uint256) {

        return (decodeReserveBalance(_balances, _id0), decodeReserveBalance(_balances, _id1));
    }

    function encodeAverageRateInfo(
        uint256 _averageRateT,
        uint256 _averageRateN,
        uint256 _averageRateD
    ) private pure returns (uint256) {

        assert(_averageRateT <= MAX_UINT32 && _averageRateN <= MAX_UINT112 && _averageRateD <= MAX_UINT112);
        return (_averageRateT << 224) | (_averageRateN << 112) | _averageRateD;
    }

    function decodeAverageRateT(uint256 _averageRateInfo) private pure returns (uint256) {

        return _averageRateInfo >> 224;
    }

    function decodeAverageRateN(uint256 _averageRateInfo) private pure returns (uint256) {

        return (_averageRateInfo >> 112) & MAX_UINT112;
    }

    function decodeAverageRateD(uint256 _averageRateInfo) private pure returns (uint256) {

        return _averageRateInfo & MAX_UINT112;
    }

    function floorSqrt(uint256 x) private pure returns (uint256) {

        return x > 0 ? MathEx.floorSqrt(x) : 0;
    }

    function crossReserveTargetAmount(
        uint256 _sourceReserveBalance,
        uint256 _targetReserveBalance,
        uint256 _amount
    ) private pure returns (uint256) {

        require(_sourceReserveBalance > 0 && _targetReserveBalance > 0, "ERR_INVALID_RESERVE_BALANCE");

        return _targetReserveBalance.mul(_amount) / _sourceReserveBalance.add(_amount);
    }

    function crossReserveSourceAmount(
        uint256 _sourceReserveBalance,
        uint256 _targetReserveBalance,
        uint256 _amount
    ) private pure returns (uint256) {

        require(_sourceReserveBalance > 0, "ERR_INVALID_RESERVE_BALANCE");
        require(_amount < _targetReserveBalance, "ERR_INVALID_AMOUNT");

        if (_amount == 0) {
            return 0;
        }

        return (_sourceReserveBalance.mul(_amount) - 1) / (_targetReserveBalance - _amount) + 1;
    }

    function fundCost(
        uint256 _supply,
        uint256 _reserveBalance,
        uint256 _amount
    ) private pure returns (uint256) {

        require(_supply > 0, "ERR_INVALID_SUPPLY");
        require(_reserveBalance > 0, "ERR_INVALID_RESERVE_BALANCE");

        if (_amount == 0) {
            return 0;
        }

        return (_amount.mul(_reserveBalance) - 1) / _supply + 1;
    }

    function fundSupplyAmount(
        uint256 _supply,
        uint256 _reserveBalance,
        uint256 _amount
    ) private pure returns (uint256) {

        require(_supply > 0, "ERR_INVALID_SUPPLY");
        require(_reserveBalance > 0, "ERR_INVALID_RESERVE_BALANCE");

        if (_amount == 0) {
            return 0;
        }

        return _amount.mul(_supply) / _reserveBalance;
    }

    function liquidateReserveAmount(
        uint256 _supply,
        uint256 _reserveBalance,
        uint256 _amount
    ) private pure returns (uint256) {

        require(_supply > 0, "ERR_INVALID_SUPPLY");
        require(_reserveBalance > 0, "ERR_INVALID_RESERVE_BALANCE");
        require(_amount <= _supply, "ERR_INVALID_AMOUNT");

        if (_amount == 0) {
            return 0;
        }

        if (_amount == _supply) {
            return _reserveBalance;
        }

        return _amount.mul(_reserveBalance) / _supply;
    }

    function networkWalletAndFees(uint256 reserveBalance0, uint256 reserveBalance1)
        private
        view
        returns (
            ITokenHolder,
            uint256,
            uint256
        )
    {

        uint256 prevPoint = floorSqrt(_reserveBalancesProduct);
        uint256 currPoint = floorSqrt(reserveBalance0 * reserveBalance1);

        if (prevPoint >= currPoint) {
            return (ITokenHolder(address(0)), 0, 0);
        }

        (ITokenHolder networkFeeWallet, uint32 networkFee) =
            INetworkSettings(addressOf(NETWORK_SETTINGS)).networkFeeParams();
        uint256 n = (currPoint - prevPoint) * networkFee;
        uint256 d = currPoint * PPM_RESOLUTION;
        return (networkFeeWallet, reserveBalance0.mul(n).div(d), reserveBalance1.mul(n).div(d));
    }

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 amount
    ) private {

        if (amount == 0) {
            return;
        }

        if (token == NATIVE_TOKEN_ADDRESS) {
            payable(to).transfer(amount);
        } else {
            token.safeTransfer(to, amount);
        }
    }

    function token() public view override returns (IConverterAnchor) {

        return anchor;
    }

    function transferTokenOwnership(address _newOwner) public override ownerOnly {

        transferAnchorOwnership(_newOwner);
    }

    function acceptTokenOwnership() public override ownerOnly {

        acceptAnchorOwnership();
    }

    function connectors(IERC20 _address)
        public
        view
        override
        returns (
            uint256,
            uint32,
            bool,
            bool,
            bool
        )
    {

        uint256 reserveId = __reserveIds[_address];
        if (reserveId != 0) {
            return (reserveBalance(reserveId), PPM_RESOLUTION / 2, false, false, true);
        }
        return (0, 0, false, false, false);
    }

    function connectorTokens(uint256 _index) public view override returns (IERC20) {

        return __reserveTokens[_index];
    }

    function connectorTokenCount() public view override returns (uint16) {

        return reserveTokenCount();
    }

    function getConnectorBalance(IERC20 _connectorToken) public view override returns (uint256) {

        return reserveBalance(_connectorToken);
    }

    function getReturn(
        IERC20 _sourceToken,
        IERC20 _targetToken,
        uint256 _amount
    ) public view returns (uint256, uint256) {

        return targetAmountAndFee(_sourceToken, _targetToken, _amount);
    }
}