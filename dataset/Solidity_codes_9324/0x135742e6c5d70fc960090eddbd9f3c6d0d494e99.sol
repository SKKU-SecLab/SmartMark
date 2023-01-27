


pragma solidity ^0.6.0;

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

contract Utils {

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

    modifier notThis(address _address) {

        _notThis(_address);
        _;
    }

    function _notThis(address _address) internal view {

        require(_address != address(this), "ERR_ADDRESS_IS_SELF");
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
    bytes32 internal constant CHAINLINK_ORACLE_WHITELIST = "ChainlinkOracleWhitelist";

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

library SafeMath {

    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {

        uint256 z = _x + _y;
        require(z >= _x, "ERR_OVERFLOW");
        return z;
    }

    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_x >= _y, "ERR_UNDERFLOW");
        return _x - _y;
    }

    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {

        if (_x == 0) return 0;

        uint256 z = _x * _y;
        require(z / _x == _y, "ERR_OVERFLOW");
        return z;
    }

    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_y > 0, "ERR_DIVIDE_BY_ZERO");
        uint256 c = _x / _y;
        return c;
    }
}



pragma solidity 0.6.12;


library Math {

    using SafeMath for uint256;

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

        uint256 x = _num / 2 + 1;
        uint256 y = (x + _num / x) / 2;
        while (x > y) {
            x = y;
            y = (x + _num / x) / 2;
        }
        return x * x == _num ? x : x + 1;
    }

    function reducedRatio(
        uint256 _n,
        uint256 _d,
        uint256 _max
    ) internal pure returns (uint256, uint256) {

        if (_n > _max || _d > _max) return normalizedRatio(_n, _d, _max);
        return (_n, _d);
    }

    function normalizedRatio(
        uint256 _a,
        uint256 _b,
        uint256 _scale
    ) internal pure returns (uint256, uint256) {

        if (_a == _b) return (_scale / 2, _scale / 2);
        if (_a < _b) return accurateRatio(_a, _b, _scale);
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
            _a /= c;
            _b /= c;
        }
        uint256 x = roundDiv(_a * _scale, _a.add(_b));
        uint256 y = _scale - x;
        return (x, y);
    }

    function roundDiv(uint256 _n, uint256 _d) internal pure returns (uint256) {

        return _n / _d + (_n % _d) / (_d - _d / 2);
    }

    function geometricMean(uint256[] memory _values) internal pure returns (uint256) {

        uint256 numOfDigits = 0;
        uint256 length = _values.length;
        for (uint256 i = 0; i < length; i++) numOfDigits += decimalLength(_values[i]);
        return uint256(10)**(roundDivUnsafe(numOfDigits, length) - 1);
    }

    function decimalLength(uint256 _x) internal pure returns (uint256) {

        uint256 y = 0;
        for (uint256 x = _x; x > 0; x /= 10) y++;
        return y;
    }

    function roundDivUnsafe(uint256 _n, uint256 _d) internal pure returns (uint256) {

        return (_n + _d / 2) / _d;
    }
}



pragma solidity 0.6.12;

interface IERC20Token {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address _owner) external view returns (uint256);


    function allowance(address _owner, address _spender) external view returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool);


    function approve(address _spender, uint256 _value) external returns (bool);

}



pragma solidity 0.6.12;


contract TokenHandler {

    bytes4 private constant APPROVE_FUNC_SELECTOR = bytes4(keccak256("approve(address,uint256)"));
    bytes4 private constant TRANSFER_FUNC_SELECTOR = bytes4(keccak256("transfer(address,uint256)"));
    bytes4 private constant TRANSFER_FROM_FUNC_SELECTOR = bytes4(keccak256("transferFrom(address,address,uint256)"));

    function safeApprove(
        IERC20Token _token,
        address _spender,
        uint256 _value
    ) internal {

        (bool success, bytes memory data) = address(_token).call(
            abi.encodeWithSelector(APPROVE_FUNC_SELECTOR, _spender, _value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "ERR_APPROVE_FAILED");
    }

    function safeTransfer(
        IERC20Token _token,
        address _to,
        uint256 _value
    ) internal {

        (bool success, bytes memory data) = address(_token).call(
            abi.encodeWithSelector(TRANSFER_FUNC_SELECTOR, _to, _value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "ERR_TRANSFER_FAILED");
    }

    function safeTransferFrom(
        IERC20Token _token,
        address _from,
        address _to,
        uint256 _value
    ) internal {

        (bool success, bytes memory data) = address(_token).call(
            abi.encodeWithSelector(TRANSFER_FROM_FUNC_SELECTOR, _from, _to, _value)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "ERR_TRANSFER_FROM_FAILED");
    }
}



pragma solidity 0.6.12;


struct Fraction {
    uint256 n; // numerator
    uint256 d; // denominator
}



pragma solidity 0.6.12;


interface IConverterAnchor is IOwned {


}



pragma solidity 0.6.12;




interface IDSToken is IConverterAnchor, IERC20Token {

    function issue(address _to, uint256 _amount) external;


    function destroy(address _from, uint256 _amount) external;

}



pragma solidity 0.6.12;





interface ILiquidityProtectionStore is IOwned {

    function addPoolToWhitelist(IConverterAnchor _anchor) external;


    function removePoolFromWhitelist(IConverterAnchor _anchor) external;


    function isPoolWhitelisted(IConverterAnchor _anchor) external view returns (bool);


    function withdrawTokens(
        IERC20Token _token,
        address _to,
        uint256 _amount
    ) external;


    function protectedLiquidity(uint256 _id)
        external
        view
        returns (
            address,
            IDSToken,
            IERC20Token,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );


    function addProtectedLiquidity(
        address _provider,
        IDSToken _poolToken,
        IERC20Token _reserveToken,
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


    function systemBalance(IERC20Token _poolToken) external view returns (uint256);


    function incSystemBalance(IERC20Token _poolToken, uint256 _poolAmount) external;


    function decSystemBalance(IERC20Token _poolToken, uint256 _poolAmount) external;

}



pragma solidity 0.6.12;




interface IConverter is IOwned {

    function converterType() external pure returns (uint16);


    function anchor() external view returns (IConverterAnchor);


    function isActive() external view returns (bool);


    function targetAmountAndFee(
        IERC20Token _sourceToken,
        IERC20Token _targetToken,
        uint256 _amount
    ) external view returns (uint256, uint256);


    function convert(
        IERC20Token _sourceToken,
        IERC20Token _targetToken,
        uint256 _amount,
        address _trader,
        address payable _beneficiary
    ) external payable returns (uint256);


    function conversionFee() external view returns (uint32);


    function maxConversionFee() external view returns (uint32);


    function reserveBalance(IERC20Token _reserveToken) external view returns (uint256);


    receive() external payable;

    function transferAnchorOwnership(address _newOwner) external;


    function acceptAnchorOwnership() external;


    function setConversionFee(uint32 _conversionFee) external;


    function withdrawTokens(
        IERC20Token _token,
        address _to,
        uint256 _amount
    ) external;


    function withdrawETH(address payable _to) external;


    function addReserve(IERC20Token _token, uint32 _ratio) external;


    function token() external view returns (IConverterAnchor);


    function transferTokenOwnership(address _newOwner) external;


    function acceptTokenOwnership() external;


    function connectors(IERC20Token _address)
        external
        view
        returns (
            uint256,
            uint32,
            bool,
            bool,
            bool
        );


    function getConnectorBalance(IERC20Token _connectorToken) external view returns (uint256);


    function connectorTokens(uint256 _index) external view returns (IERC20Token);


    function connectorTokenCount() external view returns (uint16);

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


    function getConvertibleToken(uint256 _index) external view returns (IERC20Token);


    function isConvertibleToken(address _value) external view returns (bool);


    function getConvertibleTokenAnchorCount(IERC20Token _convertibleToken) external view returns (uint256);


    function getConvertibleTokenAnchors(IERC20Token _convertibleToken) external view returns (address[] memory);


    function getConvertibleTokenAnchor(IERC20Token _convertibleToken, uint256 _index)
        external
        view
        returns (IConverterAnchor);


    function isConvertibleTokenAnchor(IERC20Token _convertibleToken, address _value) external view returns (bool);

}



pragma solidity 0.6.12;















interface ILiquidityPoolV1Converter is IConverter {

    function addLiquidity(
        IERC20Token[] memory _reserveTokens,
        uint256[] memory _reserveAmounts,
        uint256 _minReturn
    ) external payable;


    function removeLiquidity(
        uint256 _amount,
        IERC20Token[] memory _reserveTokens,
        uint256[] memory _reserveMinReturnAmounts
    ) external;


    function recentAverageRate(IERC20Token _reserveToken) external view returns (uint256, uint256);

}

contract LiquidityProtection is TokenHandler, ContractRegistryClient, ReentrancyGuard {

    using SafeMath for uint256;
    using Math for *;

    struct ProtectedLiquidity {
        address provider; // liquidity provider
        IDSToken poolToken; // pool token address
        IERC20Token reserveToken; // reserve token address
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

    struct PoolIndex {
        bool isValid;
        uint256 value;
    }

    IERC20Token internal constant ETH_RESERVE_ADDRESS = IERC20Token(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint32 internal constant PPM_RESOLUTION = 1000000;
    uint256 internal constant MAX_UINT128 = 2**128 - 1;

    address public whitelistAdmin;

    IConverterAnchor[] private _highTierPools;
    mapping(IConverterAnchor => PoolIndex) private highTierPoolIndices;

    ILiquidityProtectionStore public immutable store;
    IERC20Token public immutable networkToken;
    ITokenGovernance public immutable networkTokenGovernance;
    IERC20Token public immutable govToken;
    ITokenGovernance public immutable govTokenGovernance;

    uint256 public maxSystemNetworkTokenAmount = 1000000e18;
    uint32 public maxSystemNetworkTokenRatio = 500000; // PPM units

    uint256 public minProtectionDelay = 30 days;

    uint256 public maxProtectionDelay = 100 days;

    uint256 public minNetworkCompensation = 1e16;

    uint256 public lockDuration = 24 hours;

    uint32 public averageRateMaxDeviation = 5000; // PPM units

    bool private updatingLiquidity = false;

    event WhitelistAdminUpdated(address indexed _prevWhitelistAdmin, address indexed _newWhitelistAdmin);

    event SystemNetworkTokenLimitsUpdated(
        uint256 _prevMaxSystemNetworkTokenAmount,
        uint256 _newMaxSystemNetworkTokenAmount,
        uint256 _prevMaxSystemNetworkTokenRatio,
        uint256 _newMaxSystemNetworkTokenRatio
    );

    event ProtectionDelaysUpdated(
        uint256 _prevMinProtectionDelay,
        uint256 _newMinProtectionDelay,
        uint256 _prevMaxProtectionDelay,
        uint256 _newMaxProtectionDelay
    );

    event MinNetworkCompensationUpdated(uint256 _prevMinNetworkCompensation, uint256 _newMinNetworkCompensation);

    event LockDurationUpdated(uint256 _prevLockDuration, uint256 _newLockDuration);

    event AverageRateMaxDeviationUpdated(uint32 _prevAverageRateMaxDeviation, uint32 _newAverageRateMaxDeviation);

    constructor(
        ILiquidityProtectionStore _store,
        ITokenGovernance _networkTokenGovernance,
        ITokenGovernance _govTokenGovernance,
        IContractRegistry _registry
    )
        public
        ContractRegistryClient(_registry)
        validAddress(address(_store))
        validAddress(address(_networkTokenGovernance))
        validAddress(address(_govTokenGovernance))
        validAddress(address(_registry))
        notThis(address(_store))
        notThis(address(_networkTokenGovernance))
        notThis(address(_govTokenGovernance))
        notThis(address(_registry))
    {
        whitelistAdmin = msg.sender;
        store = _store;

        networkTokenGovernance = _networkTokenGovernance;
        networkToken = IERC20Token(address(_networkTokenGovernance.token()));
        govTokenGovernance = _govTokenGovernance;
        govToken = IERC20Token(address(_govTokenGovernance.token()));
    }

    modifier updatingLiquidityOnly() {

        _updatingLiquidityOnly();
        _;
    }

    function _updatingLiquidityOnly() internal view {

        require(updatingLiquidity, "ERR_NOT_UPDATING_LIQUIDITY");
    }

    modifier validPortion(uint32 _portion) {

        _validPortion(_portion);
        _;
    }

    function _validPortion(uint32 _portion) internal pure {

        require(_portion > 0 && _portion <= PPM_RESOLUTION, "ERR_INVALID_PORTION");
    }

    modifier poolSupported(IConverterAnchor _poolAnchor) {

        _poolSupported(_poolAnchor);
        _;
    }

    function _poolSupported(IConverterAnchor _poolAnchor) internal view {

        require(isPoolSupported(_poolAnchor), "ERR_POOL_NOT_SUPPORTED");
    }

    modifier poolWhitelisted(IConverterAnchor _poolAnchor) {

        _poolWhitelisted(_poolAnchor);
        _;
    }

    function _poolWhitelisted(IConverterAnchor _poolAnchor) internal view {

        require(store.isPoolWhitelisted(_poolAnchor), "ERR_POOL_NOT_WHITELISTED");
    }

    receive() external payable updatingLiquidityOnly() {}

    function transferStoreOwnership(address _newOwner) external {

        transferOwnership(store, _newOwner);
    }

    function acceptStoreOwnership() external {

        acceptOwnership(store);
    }

    function setWhitelistAdmin(address _whitelistAdmin) external ownerOnly validAddress(_whitelistAdmin) {

        emit WhitelistAdminUpdated(whitelistAdmin, _whitelistAdmin);

        whitelistAdmin = _whitelistAdmin;
    }

    function setSystemNetworkTokenLimits(uint256 _maxSystemNetworkTokenAmount, uint32 _maxSystemNetworkTokenRatio)
        external
        ownerOnly
        validPortion(_maxSystemNetworkTokenRatio)
    {

        emit SystemNetworkTokenLimitsUpdated(
            maxSystemNetworkTokenAmount,
            _maxSystemNetworkTokenAmount,
            maxSystemNetworkTokenRatio,
            _maxSystemNetworkTokenRatio
        );

        maxSystemNetworkTokenAmount = _maxSystemNetworkTokenAmount;
        maxSystemNetworkTokenRatio = _maxSystemNetworkTokenRatio;
    }

    function setProtectionDelays(uint256 _minProtectionDelay, uint256 _maxProtectionDelay) external ownerOnly {

        require(_minProtectionDelay < _maxProtectionDelay, "ERR_INVALID_PROTECTION_DELAY");

        emit ProtectionDelaysUpdated(minProtectionDelay, _minProtectionDelay, maxProtectionDelay, _maxProtectionDelay);

        minProtectionDelay = _minProtectionDelay;
        maxProtectionDelay = _maxProtectionDelay;
    }

    function setMinNetworkCompensation(uint256 _minCompensation) external ownerOnly {

        emit MinNetworkCompensationUpdated(minNetworkCompensation, _minCompensation);

        minNetworkCompensation = _minCompensation;
    }

    function setLockDuration(uint256 _lockDuration) external ownerOnly {

        emit LockDurationUpdated(lockDuration, _lockDuration);

        lockDuration = _lockDuration;
    }

    function setAverageRateMaxDeviation(uint32 _averageRateMaxDeviation)
        external
        ownerOnly
        validPortion(_averageRateMaxDeviation)
    {

        emit AverageRateMaxDeviationUpdated(averageRateMaxDeviation, _averageRateMaxDeviation);

        averageRateMaxDeviation = _averageRateMaxDeviation;
    }

    function whitelistPool(IConverterAnchor _poolAnchor, bool _add) external poolSupported(_poolAnchor) {

        require(msg.sender == whitelistAdmin || msg.sender == owner, "ERR_ACCESS_DENIED");

        if (_add) store.addPoolToWhitelist(_poolAnchor);
        else store.removePoolFromWhitelist(_poolAnchor);
    }

    function addHighTierPool(IConverterAnchor _poolAnchor)
        external
        ownerOnly
        validAddress(address(_poolAnchor))
        notThis(address(_poolAnchor))
    {

        PoolIndex storage poolIndex = highTierPoolIndices[_poolAnchor];
        require(!poolIndex.isValid, "ERR_POOL_ALREADY_EXISTS");

        poolIndex.value = _highTierPools.length;
        _highTierPools.push(_poolAnchor);
        poolIndex.isValid = true;
    }

    function removeHighTierPool(IConverterAnchor _poolAnchor)
        external
        ownerOnly
        validAddress(address(_poolAnchor))
        notThis(address(_poolAnchor))
    {

        PoolIndex storage poolIndex = highTierPoolIndices[_poolAnchor];
        require(poolIndex.isValid, "ERR_POOL_DOES_NOT_EXIST");

        uint256 index = poolIndex.value;
        uint256 length = _highTierPools.length;
        assert(length > 0);

        uint256 lastIndex = length - 1;
        if (index < lastIndex) {
            IConverterAnchor lastAnchor = _highTierPools[lastIndex];
            highTierPoolIndices[lastAnchor].value = index;
            _highTierPools[index] = lastAnchor;
        }

        _highTierPools.pop();
        delete highTierPoolIndices[_poolAnchor];
    }

    function highTierPools() external view returns (IConverterAnchor[] memory) {

        return _highTierPools;
    }

    function isHighTierPool(IConverterAnchor _poolAnchor) public view returns (bool) {

        return highTierPoolIndices[_poolAnchor].isValid;
    }

    function isPoolSupported(IConverterAnchor _poolAnchor) public view returns (bool) {

        IERC20Token networkTokenLocal = networkToken;

        IConverterRegistry converterRegistry = IConverterRegistry(addressOf(CONVERTER_REGISTRY));
        require(converterRegistry.isAnchor(address(_poolAnchor)), "ERR_INVALID_ANCHOR");

        IConverter converter = IConverter(payable(_poolAnchor.owner()));

        if (converter.connectorTokenCount() != 2) {
            return false;
        }

        IERC20Token reserve0Token = converter.connectorTokens(0);
        IERC20Token reserve1Token = converter.connectorTokens(1);
        if (reserve0Token != networkTokenLocal && reserve1Token != networkTokenLocal) {
            return false;
        }

        if (
            converterReserveWeight(converter, reserve0Token) != PPM_RESOLUTION / 2 ||
            converterReserveWeight(converter, reserve1Token) != PPM_RESOLUTION / 2
        ) {
            return false;
        }

        return true;
    }

    function protectLiquidity(IConverterAnchor _poolAnchor, uint256 _amount)
        external
        protected
        poolSupported(_poolAnchor)
        poolWhitelisted(_poolAnchor)
        greaterThanZero(_amount)
    {

        IConverter converter = IConverter(payable(_poolAnchor.owner()));

        IERC20Token networkTokenLocal = networkToken;

        IDSToken poolToken = IDSToken(address(_poolAnchor));
        protectLiquidity(poolToken, converter, networkTokenLocal, 0, _amount / 2);
        protectLiquidity(poolToken, converter, networkTokenLocal, 1, _amount - _amount / 2);

        safeTransferFrom(poolToken, msg.sender, address(store), _amount);
    }

    function unprotectLiquidity(uint256 _id1, uint256 _id2) external protected {

        require(_id1 != _id2, "ERR_SAME_ID");

        ProtectedLiquidity memory liquidity1 = protectedLiquidity(_id1, msg.sender);
        ProtectedLiquidity memory liquidity2 = protectedLiquidity(_id2, msg.sender);

        IERC20Token networkTokenLocal = networkToken;

        require(
            liquidity1.poolToken == liquidity2.poolToken &&
                liquidity1.reserveToken != liquidity2.reserveToken &&
                (liquidity1.reserveToken == networkTokenLocal || liquidity2.reserveToken == networkTokenLocal) &&
                liquidity1.timestamp == liquidity2.timestamp &&
                liquidity1.poolAmount <= liquidity2.poolAmount.add(1) &&
                liquidity2.poolAmount <= liquidity1.poolAmount.add(1),
            "ERR_PROTECTIONS_MISMATCH"
        );

        uint256 amount = liquidity1.reserveToken == networkTokenLocal ? liquidity1.reserveAmount : liquidity2.reserveAmount;
        safeTransferFrom(govToken, msg.sender, address(this), amount);
        govTokenGovernance.burn(amount);

        store.removeProtectedLiquidity(_id1);
        store.removeProtectedLiquidity(_id2);

        store.withdrawTokens(liquidity1.poolToken, msg.sender, liquidity1.poolAmount.add(liquidity2.poolAmount));
    }

    function addLiquidity(IConverterAnchor _poolAnchor, IERC20Token _reserveToken, uint256 _amount)
        external
        payable
        protected
        poolSupported(_poolAnchor)
        poolWhitelisted(_poolAnchor)
        greaterThanZero(_amount)
        returns (uint256)
    {

        IERC20Token networkTokenLocal = networkToken;

        if (_reserveToken == networkTokenLocal) {
            require(msg.value == 0, "ERR_ETH_AMOUNT_MISMATCH");
            return addNetworkTokenLiquidity(_poolAnchor, networkTokenLocal, _amount);
        }

        uint256 val = _reserveToken == ETH_RESERVE_ADDRESS ? _amount : 0;
        require(msg.value == val, "ERR_ETH_AMOUNT_MISMATCH");
        return addBaseTokenLiquidity(_poolAnchor, _reserveToken, networkTokenLocal, _amount);
    }

    function addNetworkTokenLiquidity(IConverterAnchor _poolAnchor, IERC20Token _networkToken, uint256 _amount) internal returns (uint256) {

        IDSToken poolToken = IDSToken(address(_poolAnchor));

        Fraction memory poolRate = poolTokenRate(poolToken, _networkToken);

        uint256 poolTokenAmount = _amount.mul(poolRate.d).div(poolRate.n);

        store.decSystemBalance(poolToken, poolTokenAmount);

        uint256 id = addProtectedLiquidity(msg.sender, poolToken, _networkToken, poolTokenAmount, _amount);

        safeTransferFrom(_networkToken, msg.sender, address(this), _amount);
        networkTokenGovernance.burn(_amount);

        govTokenGovernance.mint(msg.sender, _amount);

        return id;
    }

    function addBaseTokenLiquidity(
        IConverterAnchor _poolAnchor,
        IERC20Token _baseToken,
        IERC20Token _networkToken,
        uint256 _amount
    ) internal returns (uint256) {

        IDSToken poolToken = IDSToken(address(_poolAnchor));

        ILiquidityPoolV1Converter converter = ILiquidityPoolV1Converter(payable(_poolAnchor.owner()));
        (uint256 reserveBalanceBase, uint256 reserveBalanceNetwork) = converterReserveBalances(
            converter,
            _baseToken,
            _networkToken
        );

        uint256 networkLiquidityAmount = _amount.mul(reserveBalanceNetwork).div(reserveBalanceBase);

        Fraction memory poolRate = poolTokenRate(poolToken, _networkToken);
        uint256 newSystemBalance = store.systemBalance(poolToken);
        newSystemBalance = (newSystemBalance.mul(poolRate.n / 2).div(poolRate.d)).add(networkLiquidityAmount);

        require(newSystemBalance <= maxSystemNetworkTokenAmount, "ERR_MAX_AMOUNT_REACHED");

        if (!isHighTierPool(_poolAnchor)) {
            require(
                newSystemBalance.mul(PPM_RESOLUTION) <=
                    reserveBalanceNetwork.add(networkLiquidityAmount).mul(maxSystemNetworkTokenRatio),
                "ERR_MAX_RATIO_REACHED"
            );
        }

        networkTokenGovernance.mint(address(this), networkLiquidityAmount);

        ensureAllowance(_networkToken, address(converter), networkLiquidityAmount);
        if (_baseToken != ETH_RESERVE_ADDRESS) {
            safeTransferFrom(_baseToken, msg.sender, address(this), _amount);
            ensureAllowance(_baseToken, address(converter), _amount);
        }

        addLiquidity(converter, _baseToken, _networkToken, _amount, networkLiquidityAmount, msg.value);

        uint256 poolTokenAmount = poolToken.balanceOf(address(this));
        safeTransfer(poolToken, address(store), poolTokenAmount);

        store.incSystemBalance(poolToken, poolTokenAmount - poolTokenAmount / 2); // account for rounding errors
        return addProtectedLiquidity(msg.sender, poolToken, _baseToken, poolTokenAmount / 2, _amount);
    }

    function transferLiquidity(uint256 _id, address _newProvider)
        external
        protected
        validAddress(_newProvider)
        notThis(_newProvider)
        returns (uint256)
    {

        ProtectedLiquidity memory liquidity = protectedLiquidity(_id, msg.sender);

        store.removeProtectedLiquidity(_id);

        return
            store.addProtectedLiquidity(
                _newProvider,
                liquidity.poolToken,
                liquidity.reserveToken,
                liquidity.poolAmount,
                liquidity.reserveAmount,
                liquidity.reserveRateN,
                liquidity.reserveRateD,
                liquidity.timestamp
            );
    }

    function removeLiquidityReturn(
        uint256 _id,
        uint32 _portion,
        uint256 _removeTimestamp
    )
        external
        view
        validPortion(_portion)
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        ProtectedLiquidity memory liquidity = protectedLiquidity(_id);

        require(liquidity.provider != address(0), "ERR_INVALID_ID");
        require(_removeTimestamp >= liquidity.timestamp, "ERR_INVALID_TIMESTAMP");

        if (_portion != PPM_RESOLUTION) {
            liquidity.poolAmount = liquidity.poolAmount.mul(_portion) / PPM_RESOLUTION;
            liquidity.reserveAmount = liquidity.reserveAmount.mul(_portion) / PPM_RESOLUTION;
        }

        PackedRates memory packedRates = packRates(
            liquidity.poolToken,
            liquidity.reserveToken,
            liquidity.reserveRateN,
            liquidity.reserveRateD
        );

        uint256 targetAmount = removeLiquidityTargetAmount(
            liquidity.poolToken,
            liquidity.reserveToken,
            liquidity.poolAmount,
            liquidity.reserveAmount,
            packedRates,
            liquidity.timestamp,
            _removeTimestamp
        );

        if (liquidity.reserveToken == networkToken) {
            return (targetAmount, targetAmount, 0);
        }


        Fraction memory poolRate = poolTokenRate(liquidity.poolToken, liquidity.reserveToken);
        uint256 poolAmount = targetAmount.mul(poolRate.d).div(poolRate.n / 2);

        uint256 availableBalance = store.systemBalance(liquidity.poolToken).add(liquidity.poolAmount);
        poolAmount = poolAmount > availableBalance ? availableBalance : poolAmount;

        uint256 baseAmount = poolAmount.mul(poolRate.n / 2).div(poolRate.d);
        uint256 networkAmount = getNetworkCompensation(targetAmount, baseAmount, packedRates);

        return (targetAmount, baseAmount, networkAmount);
    }

    function removeLiquidity(uint256 _id, uint32 _portion) external validPortion(_portion) protected {

        ProtectedLiquidity memory liquidity = protectedLiquidity(_id, msg.sender);

        IERC20Token networkTokenLocal = networkToken;

        _poolWhitelisted(liquidity.poolToken);

        if (_portion == PPM_RESOLUTION) {
            store.removeProtectedLiquidity(_id);
        } else {
            uint256 fullPoolAmount = liquidity.poolAmount;
            uint256 fullReserveAmount = liquidity.reserveAmount;
            liquidity.poolAmount = liquidity.poolAmount.mul(_portion) / PPM_RESOLUTION;
            liquidity.reserveAmount = liquidity.reserveAmount.mul(_portion) / PPM_RESOLUTION;

            store.updateProtectedLiquidityAmounts(
                _id,
                fullPoolAmount - liquidity.poolAmount,
                fullReserveAmount - liquidity.reserveAmount
            );
        }

        store.incSystemBalance(liquidity.poolToken, liquidity.poolAmount);

        if (liquidity.reserveToken == networkTokenLocal) {
            safeTransferFrom(govToken, msg.sender, address(this), liquidity.reserveAmount);
            govTokenGovernance.burn(liquidity.reserveAmount);
        }

        PackedRates memory packedRates = packRates(
            liquidity.poolToken,
            liquidity.reserveToken,
            liquidity.reserveRateN,
            liquidity.reserveRateD
        );

        uint256 targetAmount = removeLiquidityTargetAmount(
            liquidity.poolToken,
            liquidity.reserveToken,
            liquidity.poolAmount,
            liquidity.reserveAmount,
            packedRates,
            liquidity.timestamp,
            time()
        );

        if (liquidity.reserveToken == networkTokenLocal) {
            networkTokenGovernance.mint(address(store), targetAmount);
            lockTokens(msg.sender, targetAmount);
            return;
        }


        Fraction memory poolRate = poolTokenRate(liquidity.poolToken, liquidity.reserveToken);
        uint256 poolAmount = targetAmount.mul(poolRate.d).div(poolRate.n / 2);

        uint256 systemBalance = store.systemBalance(liquidity.poolToken);
        poolAmount = poolAmount > systemBalance ? systemBalance : poolAmount;

        store.decSystemBalance(liquidity.poolToken, poolAmount);
        store.withdrawTokens(liquidity.poolToken, address(this), poolAmount);

        removeLiquidity(liquidity.poolToken, poolAmount, liquidity.reserveToken, networkTokenLocal);

        uint256 baseBalance;
        if (liquidity.reserveToken == ETH_RESERVE_ADDRESS) {
            baseBalance = address(this).balance;
            msg.sender.transfer(baseBalance);
        } else {
            baseBalance = liquidity.reserveToken.balanceOf(address(this));
            safeTransfer(liquidity.reserveToken, msg.sender, baseBalance);
        }

        uint256 delta = getNetworkCompensation(targetAmount, baseBalance, packedRates);
        if (delta > 0) {
            uint256 networkBalance = networkTokenLocal.balanceOf(address(this));
            if (networkBalance < delta) {
                networkTokenGovernance.mint(address(this), delta - networkBalance);
            }

            safeTransfer(networkTokenLocal, address(store), delta);
            lockTokens(msg.sender, delta);
        }

        uint256 networkBalance = networkTokenLocal.balanceOf(address(this));
        if (networkBalance > 0) {
            networkTokenGovernance.burn(networkBalance);
        }
    }

    function removeLiquidityTargetAmount(
        IDSToken _poolToken,
        IERC20Token _reserveToken,
        uint256 _poolAmount,
        uint256 _reserveAmount,
        PackedRates memory _packedRates,
        uint256 _addTimestamp,
        uint256 _removeTimestamp
    ) internal view returns (uint256) {

        Fraction memory addSpotRate = Fraction({ n: _packedRates.addSpotRateN, d: _packedRates.addSpotRateD });
        Fraction memory removeSpotRate = Fraction({ n: _packedRates.removeSpotRateN, d: _packedRates.removeSpotRateD });
        Fraction memory removeAverageRate = Fraction({
            n: _packedRates.removeAverageRateN,
            d: _packedRates.removeAverageRateD
        });

        uint256 total = protectedAmountPlusFee(_poolToken, _reserveToken, _poolAmount, addSpotRate, removeSpotRate);
        if (total < _reserveAmount) {
            total = _reserveAmount;
        }

        Fraction memory loss = impLoss(addSpotRate, removeAverageRate);

        Fraction memory level = protectionLevel(_addTimestamp, _removeTimestamp);

        return compensationAmount(_reserveAmount, total, loss, level);
    }

    function claimBalance(uint256 _startIndex, uint256 _endIndex) external protected {

        (uint256[] memory amounts, uint256[] memory expirationTimes) = store.lockedBalanceRange(
            msg.sender,
            _startIndex,
            _endIndex
        );

        uint256 totalAmount = 0;
        uint256 length = amounts.length;
        assert(length == expirationTimes.length);

        for (uint256 i = length; i > 0; i--) {
            uint256 index = i - 1;
            if (expirationTimes[index] > time()) {
                continue;
            }

            store.removeLockedBalance(msg.sender, _startIndex + index);
            totalAmount = totalAmount.add(amounts[index]);
        }

        if (totalAmount > 0) {
            store.withdrawTokens(networkToken, msg.sender, totalAmount);
        }
    }

    function poolROI(
        IDSToken _poolToken,
        IERC20Token _reserveToken,
        uint256 _reserveAmount,
        uint256 _poolRateN,
        uint256 _poolRateD,
        uint256 _reserveRateN,
        uint256 _reserveRateD
    ) external view returns (uint256) {

        uint256 poolAmount = _reserveAmount.mul(_poolRateD).div(_poolRateN);

        PackedRates memory packedRates = packRates(_poolToken, _reserveToken, _reserveRateN, _reserveRateD);

        uint256 protectedReturn = removeLiquidityTargetAmount(
            _poolToken,
            _reserveToken,
            poolAmount,
            _reserveAmount,
            packedRates,
            time().sub(maxProtectionDelay),
            time()
        );

        return protectedReturn.mul(PPM_RESOLUTION).div(_reserveAmount);
    }

    function protectLiquidity(
        IDSToken _poolAnchor,
        IConverter _converter,
        IERC20Token _networkToken,
        uint256 _reserveIndex,
        uint256 _poolAmount
    ) internal {

        IERC20Token reserveToken = _converter.connectorTokens(_reserveIndex);

        IDSToken poolToken = IDSToken(address(_poolAnchor));
        Fraction memory poolRate = poolTokenRate(poolToken, reserveToken);

        uint256 reserveAmount = _poolAmount.mul(poolRate.n).div(poolRate.d);

        addProtectedLiquidity(msg.sender, poolToken, reserveToken, _poolAmount, reserveAmount);

        if (reserveToken == _networkToken) {
            govTokenGovernance.mint(msg.sender, reserveAmount);
        }
    }

    function addProtectedLiquidity(
        address _provider,
        IDSToken _poolToken,
        IERC20Token _reserveToken,
        uint256 _poolAmount,
        uint256 _reserveAmount
    ) internal returns (uint256) {

        Fraction memory rate = reserveTokenAverageRate(_poolToken, _reserveToken);
        return
            store.addProtectedLiquidity(
                _provider,
                _poolToken,
                _reserveToken,
                _poolAmount,
                _reserveAmount,
                rate.n,
                rate.d,
                time()
            );
    }

    function lockTokens(address _provider, uint256 _amount) internal {

        uint256 expirationTime = time().add(lockDuration);
        store.addLockedBalance(_provider, _amount, expirationTime);
    }

    function poolTokenRate(IDSToken _poolToken, IERC20Token _reserveToken) internal view returns (Fraction memory) {

        uint256 poolTokenSupply = _poolToken.totalSupply();

        IConverter converter = IConverter(payable(_poolToken.owner()));
        uint256 reserveBalance = converter.getConnectorBalance(_reserveToken);

        return Fraction({ n: reserveBalance.mul(2), d: poolTokenSupply });
    }

    function reserveTokenAverageRate(IDSToken _poolToken, IERC20Token _reserveToken)
        internal
        view
        returns (Fraction memory)
    {

        (, , uint256 averageRateN, uint256 averageRateD) = reserveTokenRates(_poolToken, _reserveToken);
        return Fraction(averageRateN, averageRateD);
    }

    function reserveTokenRates(IDSToken _poolToken, IERC20Token _reserveToken)
        internal
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {

        ILiquidityPoolV1Converter converter = ILiquidityPoolV1Converter(payable(_poolToken.owner()));

        IERC20Token otherReserve = converter.connectorTokens(0);
        if (otherReserve == _reserveToken) {
            otherReserve = converter.connectorTokens(1);
        }

        (uint256 spotRateN, uint256 spotRateD) = converterReserveBalances(converter, otherReserve, _reserveToken);
        (uint256 averageRateN, uint256 averageRateD) = converter.recentAverageRate(_reserveToken);

        require(
            averageRateInRange(spotRateN, spotRateD, averageRateN, averageRateD, averageRateMaxDeviation),
            "ERR_INVALID_RATE"
        );

        return (spotRateN, spotRateD, averageRateN, averageRateD);
    }

    function packRates(
        IDSToken _poolToken,
        IERC20Token _reserveToken,
        uint256 _addSpotRateN,
        uint256 _addSpotRateD
    ) internal view returns (PackedRates memory) {

        (
            uint256 removeSpotRateN,
            uint256 removeSpotRateD,
            uint256 removeAverageRateN,
            uint256 removeAverageRateD
        ) = reserveTokenRates(_poolToken, _reserveToken);

        require(
            (_addSpotRateN <= MAX_UINT128 && _addSpotRateD <= MAX_UINT128) &&
                (removeSpotRateN <= MAX_UINT128 && removeSpotRateD <= MAX_UINT128) &&
                (removeAverageRateN <= MAX_UINT128 && removeAverageRateD <= MAX_UINT128),
            "ERR_INVALID_RATE"
        );

        return
            PackedRates({
                addSpotRateN: uint128(_addSpotRateN),
                addSpotRateD: uint128(_addSpotRateD),
                removeSpotRateN: uint128(removeSpotRateN),
                removeSpotRateD: uint128(removeSpotRateD),
                removeAverageRateN: uint128(removeAverageRateN),
                removeAverageRateD: uint128(removeAverageRateD)
            });
    }

    function averageRateInRange(
        uint256 _spotRateN,
        uint256 _spotRateD,
        uint256 _averageRateN,
        uint256 _averageRateD,
        uint32 _maxDeviation
    ) internal pure returns (bool) {

        uint256 min = _spotRateN.mul(_averageRateD).mul(PPM_RESOLUTION - _maxDeviation).mul(
            PPM_RESOLUTION - _maxDeviation
        );
        uint256 mid = _spotRateD.mul(_averageRateN).mul(PPM_RESOLUTION - _maxDeviation).mul(PPM_RESOLUTION);
        uint256 max = _spotRateN.mul(_averageRateD).mul(PPM_RESOLUTION).mul(PPM_RESOLUTION);
        return min <= mid && mid <= max;
    }

    function addLiquidity(
        ILiquidityPoolV1Converter _converter,
        IERC20Token _reserveToken1,
        IERC20Token _reserveToken2,
        uint256 _reserveAmount1,
        uint256 _reserveAmount2,
        uint256 _value
    ) internal {

        IERC20Token[] memory reserveTokens = new IERC20Token[](2);
        uint256[] memory amounts = new uint256[](2);
        reserveTokens[0] = _reserveToken1;
        reserveTokens[1] = _reserveToken2;
        amounts[0] = _reserveAmount1;
        amounts[1] = _reserveAmount2;

        updatingLiquidity = true;
        _converter.addLiquidity{ value: _value }(reserveTokens, amounts, 1);
        updatingLiquidity = false;
    }

    function removeLiquidity(
        IDSToken _poolToken,
        uint256 _poolAmount,
        IERC20Token _reserveToken1,
        IERC20Token _reserveToken2
    ) internal {

        ILiquidityPoolV1Converter converter = ILiquidityPoolV1Converter(payable(_poolToken.owner()));

        IERC20Token[] memory reserveTokens = new IERC20Token[](2);
        uint256[] memory minReturns = new uint256[](2);
        reserveTokens[0] = _reserveToken1;
        reserveTokens[1] = _reserveToken2;
        minReturns[0] = 1;
        minReturns[1] = 1;

        updatingLiquidity = true;
        converter.removeLiquidity(_poolAmount, reserveTokens, minReturns);
        updatingLiquidity = false;
    }

    function protectedLiquidity(uint256 _id) internal view returns (ProtectedLiquidity memory) {

        ProtectedLiquidity memory liquidity;
        (
            liquidity.provider,
            liquidity.poolToken,
            liquidity.reserveToken,
            liquidity.poolAmount,
            liquidity.reserveAmount,
            liquidity.reserveRateN,
            liquidity.reserveRateD,
            liquidity.timestamp
        ) = store.protectedLiquidity(_id);

        return liquidity;
    }

    function protectedLiquidity(uint256 _id, address _provider) internal view returns (ProtectedLiquidity memory) {

        ProtectedLiquidity memory liquidity = protectedLiquidity(_id);
        require(liquidity.provider == _provider, "ERR_ACCESS_DENIED");
        return liquidity;
    }

    function protectedAmountPlusFee(
        IDSToken _poolToken,
        IERC20Token _reserveToken,
        uint256 _poolAmount,
        Fraction memory _addRate,
        Fraction memory _removeRate
    ) internal view returns (uint256) {

        Fraction memory poolRate = poolTokenRate(_poolToken, _reserveToken);
        uint256 n = Math.ceilSqrt(_addRate.d.mul(_removeRate.n)).mul(poolRate.n);
        uint256 d = Math.floorSqrt(_addRate.n.mul(_removeRate.d)).mul(poolRate.d);

        uint256 x = n * _poolAmount;
        if (x / n == _poolAmount) {
            return x / d;
        }

        (uint256 hi, uint256 lo) = n > _poolAmount ? (n, _poolAmount) : (_poolAmount, n);
        (uint256 p, uint256 q) = Math.reducedRatio(hi, d, uint256(-1) / lo);
        return (p * lo) / q;
    }

    function impLoss(Fraction memory _prevRate, Fraction memory _newRate) internal pure returns (Fraction memory) {

        uint256 ratioN = _newRate.n.mul(_prevRate.d);
        uint256 ratioD = _newRate.d.mul(_prevRate.n);

        uint256 prod = ratioN * ratioD;
        uint256 root = prod / ratioN == ratioD ? Math.floorSqrt(prod) : Math.floorSqrt(ratioN) * Math.floorSqrt(ratioD);
        uint256 sum = ratioN.add(ratioD);
        return Fraction({ n: sum.sub(root.mul(2)), d: sum });
    }

    function protectionLevel(uint256 _addTimestamp, uint256 _removeTimestamp) internal view returns (Fraction memory) {

        uint256 timeElapsed = _removeTimestamp.sub(_addTimestamp);
        if (timeElapsed < minProtectionDelay) {
            return Fraction({ n: 0, d: 1 });
        }

        if (timeElapsed >= maxProtectionDelay) {
            return Fraction({ n: 1, d: 1 });
        }

        return Fraction({ n: timeElapsed, d: maxProtectionDelay });
    }

    function compensationAmount(
        uint256 _amount,
        uint256 _total,
        Fraction memory _loss,
        Fraction memory _level
    ) internal pure returns (uint256) {

        (uint256 lossN, uint256 lossD) = Math.reducedRatio(_loss.n, _loss.d, MAX_UINT128);
        return _total.mul(lossD.sub(lossN)).div(lossD).add(_amount.mul(lossN.mul(_level.n)).div(lossD.mul(_level.d)));
    }

    function getNetworkCompensation(
        uint256 _targetAmount,
        uint256 _baseAmount,
        PackedRates memory _packedRates
    ) internal view returns (uint256) {

        if (_targetAmount <= _baseAmount) {
            return 0;
        }

        uint256 delta = (_targetAmount - _baseAmount).mul(_packedRates.removeAverageRateN).div(
            _packedRates.removeAverageRateD
        );

        if (delta >= _minNetworkCompensation()) {
            return delta;
        }

        return 0;
    }

    function transferOwnership(IOwned _owned, address _newOwner) internal ownerOnly {

        _owned.transferOwnership(_newOwner);
    }

    function acceptOwnership(IOwned _owned) internal ownerOnly {

        _owned.acceptOwnership();
    }

    function ensureAllowance(
        IERC20Token _token,
        address _spender,
        uint256 _value
    ) private {

        uint256 allowance = _token.allowance(address(this), _spender);
        if (allowance < _value) {
            if (allowance > 0) safeApprove(_token, _spender, 0);
            safeApprove(_token, _spender, _value);
        }
    }

    function converterReserveBalances(
        IConverter _converter,
        IERC20Token _reserveToken1,
        IERC20Token _reserveToken2
    ) private view returns (uint256, uint256) {

        return (_converter.getConnectorBalance(_reserveToken1), _converter.getConnectorBalance(_reserveToken2));
    }

    function converterReserveWeight(IConverter _converter, IERC20Token _reserveToken) private view returns (uint32) {

        (, uint32 weight, , , ) = _converter.connectors(_reserveToken);
        return weight;
    }

    function _minNetworkCompensation() internal view virtual returns (uint256) {

        return minNetworkCompensation;
    }

    function time() internal view virtual returns (uint256) {

        return block.timestamp;
    }
}