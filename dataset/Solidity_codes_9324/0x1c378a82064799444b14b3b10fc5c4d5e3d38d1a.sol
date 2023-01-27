

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

interface IERC20Token {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);


    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

}



pragma solidity 0.6.12;

interface IWhitelist {

    function isWhitelisted(address _address) external view returns (bool);

}



pragma solidity 0.6.12;





interface IConverter is IOwned {

    function converterType() external pure returns (uint16);

    function anchor() external view returns (IConverterAnchor);

    function isActive() external view returns (bool);


    function targetAmountAndFee(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount) external view returns (uint256, uint256);

    function convert(IERC20Token _sourceToken,
                     IERC20Token _targetToken,
                     uint256 _amount,
                     address _trader,
                     address payable _beneficiary) external payable returns (uint256);


    function conversionWhitelist() external view returns (IWhitelist);

    function conversionFee() external view returns (uint32);

    function maxConversionFee() external view returns (uint32);

    function reserveBalance(IERC20Token _reserveToken) external view returns (uint256);

    receive() external payable;

    function transferAnchorOwnership(address _newOwner) external;

    function acceptAnchorOwnership() external;

    function setConversionFee(uint32 _conversionFee) external;

    function setConversionWhitelist(IWhitelist _whitelist) external;

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) external;

    function withdrawETH(address payable _to) external;

    function addReserve(IERC20Token _token, uint32 _ratio) external;


    function token() external view returns (IConverterAnchor);

    function transferTokenOwnership(address _newOwner) external;

    function acceptTokenOwnership() external;

    function connectors(IERC20Token _address) external view returns (uint256, uint32, bool, bool, bool);

    function getConnectorBalance(IERC20Token _connectorToken) external view returns (uint256);

    function connectorTokens(uint256 _index) external view returns (IERC20Token);

    function connectorTokenCount() external view returns (uint16);

}



pragma solidity 0.6.12;

interface IConverterUpgrader {

    function upgrade(bytes32 _version) external;

    function upgrade(uint16 _version) external;

}



pragma solidity 0.6.12;

interface IBancorFormula {

    function purchaseTargetAmount(uint256 _supply,
                                  uint256 _reserveBalance,
                                  uint32 _reserveWeight,
                                  uint256 _amount)
                                  external view returns (uint256);


    function saleTargetAmount(uint256 _supply,
                              uint256 _reserveBalance,
                              uint32 _reserveWeight,
                              uint256 _amount)
                              external view returns (uint256);


    function crossReserveTargetAmount(uint256 _sourceReserveBalance,
                                      uint32 _sourceReserveWeight,
                                      uint256 _targetReserveBalance,
                                      uint32 _targetReserveWeight,
                                      uint256 _amount)
                                      external view returns (uint256);


    function fundCost(uint256 _supply,
                      uint256 _reserveBalance,
                      uint32 _reserveRatio,
                      uint256 _amount)
                      external view returns (uint256);


    function fundSupplyAmount(uint256 _supply,
                              uint256 _reserveBalance,
                              uint32 _reserveRatio,
                              uint256 _amount)
                              external view returns (uint256);


    function liquidateReserveAmount(uint256 _supply,
                                    uint256 _reserveBalance,
                                    uint32 _reserveRatio,
                                    uint256 _amount)
                                    external view returns (uint256);


    function balancedWeights(uint256 _primaryReserveStakedBalance,
                             uint256 _primaryReserveBalance,
                             uint256 _secondaryReserveBalance,
                             uint256 _reserveRateNumerator,
                             uint256 _reserveRateDenominator)
                             external view returns (uint32, uint32);

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

    function acceptOwnership() override public {

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

    IContractRegistry public registry;      // address of the current contract-registry
    IContractRegistry public prevRegistry;  // address of the previous contract-registry
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

        if (_x == 0)
            return 0;

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


contract TokenHandler {

    bytes4 private constant APPROVE_FUNC_SELECTOR = bytes4(keccak256("approve(address,uint256)"));
    bytes4 private constant TRANSFER_FUNC_SELECTOR = bytes4(keccak256("transfer(address,uint256)"));
    bytes4 private constant TRANSFER_FROM_FUNC_SELECTOR = bytes4(keccak256("transferFrom(address,address,uint256)"));

    function safeApprove(IERC20Token _token, address _spender, uint256 _value) internal {

        (bool success, bytes memory data) = address(_token).call(abi.encodeWithSelector(APPROVE_FUNC_SELECTOR, _spender, _value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ERR_APPROVE_FAILED');
    }

    function safeTransfer(IERC20Token _token, address _to, uint256 _value) internal {

       (bool success, bytes memory data) = address(_token).call(abi.encodeWithSelector(TRANSFER_FUNC_SELECTOR, _to, _value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ERR_TRANSFER_FAILED');
    }

    function safeTransferFrom(IERC20Token _token, address _from, address _to, uint256 _value) internal {

       (bool success, bytes memory data) = address(_token).call(abi.encodeWithSelector(TRANSFER_FROM_FUNC_SELECTOR, _from, _to, _value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ERR_TRANSFER_FROM_FAILED');
    }
}



pragma solidity 0.6.12;



interface ITokenHolder is IOwned {

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) external;

}



pragma solidity 0.6.12;






contract TokenHolder is ITokenHolder, TokenHandler, Owned, Utils {

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        virtual
        override
        ownerOnly
        validAddress(address(_token))
        validAddress(_to)
        notThis(_to)
    {

        safeTransfer(_token, _to, _amount);
    }
}



pragma solidity 0.6.12;


interface IEtherToken is IERC20Token {

    function deposit() external payable;

    function withdraw(uint256 _amount) external;

    function depositTo(address _to) external payable;

    function withdrawTo(address payable _to, uint256 _amount) external;

}



pragma solidity 0.6.12;


interface IBancorX {

    function token() external view returns (IERC20Token);

    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount, uint256 _id) external;

    function getXTransferAmount(uint256 _xTransferId, address _for) external view returns (uint256);

}



pragma solidity 0.6.12;












abstract contract ConverterBase is IConverter, TokenHandler, TokenHolder, ContractRegistryClient, ReentrancyGuard {
    using SafeMath for uint256;

    uint32 internal constant PPM_RESOLUTION = 1000000;
    IERC20Token internal constant ETH_RESERVE_ADDRESS = IERC20Token(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    struct Reserve {
        uint256 balance;    // reserve balance
        uint32 weight;      // reserve weight, represented in ppm, 1-1000000
        bool deprecated1;   // deprecated
        bool deprecated2;   // deprecated
        bool isSet;         // true if the reserve is valid, false otherwise
    }

    uint16 public constant version = 42;

    IConverterAnchor public override anchor;            // converter anchor contract
    IWhitelist public override conversionWhitelist;     // whitelist contract with list of addresses that are allowed to use the converter
    IERC20Token[] public reserveTokens;                 // ERC20 standard token addresses (prior version 17, use 'connectorTokens' instead)
    mapping (IERC20Token => Reserve) public reserves;   // reserve token addresses -> reserve data (prior version 17, use 'connectors' instead)
    uint32 public reserveRatio = 0;                     // ratio between the reserves and the market cap, equal to the total reserve weights
    uint32 public override maxConversionFee = 0;        // maximum conversion fee for the lifetime of the contract,
    uint32 public override conversionFee = 0;           // current conversion fee, represented in ppm, 0...maxConversionFee
    bool public constant conversionsEnabled = true;     // deprecated, backward compatibility

    event Activation(uint16 indexed _type, IConverterAnchor indexed _anchor, bool indexed _activated);

    event Conversion(
        IERC20Token indexed _fromToken,
        IERC20Token indexed _toToken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionFee
    );

    event TokenRateUpdate(
        IERC20Token indexed _token1,
        IERC20Token indexed _token2,
        uint256 _rateN,
        uint256 _rateD
    );

    event ConversionFeeUpdate(uint32 _prevFee, uint32 _newFee);

    constructor(
        IConverterAnchor _anchor,
        IContractRegistry _registry,
        uint32 _maxConversionFee
    )
        validAddress(address(_anchor))
        ContractRegistryClient(_registry)
        internal
        validConversionFee(_maxConversionFee)
    {
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

    modifier validReserve(IERC20Token _address) {
        _validReserve(_address);
        _;
    }

    function _validReserve(IERC20Token _address) internal view {
        require(reserves[_address].isSet, "ERR_INVALID_RESERVE");
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
        require(_weight > 0 && _weight <= PPM_RESOLUTION, "ERR_INVALID_RESERVE_WEIGHT");
    }

    function converterType() public pure virtual override returns (uint16);

    function targetAmountAndFee(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount)
        public
        view
        virtual
        override
        returns (uint256, uint256);

    receive() external override payable {
        require(reserves[ETH_RESERVE_ADDRESS].isSet, "ERR_INVALID_RESERVE"); // require(hasETHReserve(), "ERR_INVALID_RESERVE");
    }

    function withdrawETH(address payable _to)
        public
        override
        protected
        ownerOnly
        validReserve(ETH_RESERVE_ADDRESS)
    {
        address converterUpgrader = addressOf(CONVERTER_UPGRADER);

        require(!isActive() || owner == converterUpgrader, "ERR_ACCESS_DENIED");
        _to.transfer(address(this).balance);

        syncReserveBalance(ETH_RESERVE_ADDRESS);
    }

    function isV28OrHigher() public pure returns (bool) {
        return true;
    }

    function setConversionWhitelist(IWhitelist _whitelist)
        public
        override
        ownerOnly
        notThis(address(_whitelist))
    {
        conversionWhitelist = _whitelist;
    }

    function isActive() public view virtual override returns (bool) {
        return anchor.owner() == address(this);
    }

    function transferAnchorOwnership(address _newOwner)
        public
        override
        ownerOnly
        only(CONVERTER_UPGRADER)
    {
        anchor.transferOwnership(_newOwner);
    }

    function acceptAnchorOwnership() public virtual override ownerOnly {
        require(reserveTokenCount() > 0, "ERR_INVALID_RESERVE_COUNT");
        anchor.acceptOwnership();
        syncReserveBalances();
    }

    function setConversionFee(uint32 _conversionFee) public override ownerOnly {
        require(_conversionFee <= maxConversionFee, "ERR_INVALID_CONVERSION_FEE");
        emit ConversionFeeUpdate(conversionFee, _conversionFee);
        conversionFee = _conversionFee;
    }

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        override(IConverter, TokenHolder)
        protected
        ownerOnly
    {
        address converterUpgrader = addressOf(CONVERTER_UPGRADER);

        require(!reserves[_token].isSet || !isActive() || owner == converterUpgrader, "ERR_ACCESS_DENIED");
        super.withdrawTokens(_token, _to, _amount);

        if (reserves[_token].isSet)
            syncReserveBalance(_token);
    }

    function upgrade() public ownerOnly {
        IConverterUpgrader converterUpgrader = IConverterUpgrader(addressOf(CONVERTER_UPGRADER));

        emit Activation(converterType(), anchor, false);

        transferOwnership(address(converterUpgrader));
        converterUpgrader.upgrade(version);
        acceptOwnership();
    }

    function reserveTokenCount() public view returns (uint16) {
        return uint16(reserveTokens.length);
    }

    function addReserve(IERC20Token _token, uint32 _weight)
        public
        virtual
        override
        ownerOnly
        inactive
        validAddress(address(_token))
        notThis(address(_token))
        validReserveWeight(_weight)
    {
        require(address(_token) != address(anchor) && !reserves[_token].isSet, "ERR_INVALID_RESERVE");
        require(_weight <= PPM_RESOLUTION - reserveRatio, "ERR_INVALID_RESERVE_WEIGHT");
        require(reserveTokenCount() < uint16(-1), "ERR_INVALID_RESERVE_COUNT");

        Reserve storage newReserve = reserves[_token];
        newReserve.balance = 0;
        newReserve.weight = _weight;
        newReserve.isSet = true;
        reserveTokens.push(_token);
        reserveRatio += _weight;
    }

    function reserveWeight(IERC20Token _reserveToken)
        public
        view
        validReserve(_reserveToken)
        returns (uint32)
    {
        return reserves[_reserveToken].weight;
    }

    function reserveBalance(IERC20Token _reserveToken)
        public
        override
        view
        validReserve(_reserveToken)
        returns (uint256)
    {
        return reserves[_reserveToken].balance;
    }

    function hasETHReserve() public view returns (bool) {
        return reserves[ETH_RESERVE_ADDRESS].isSet;
    }

    function convert(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount, address _trader, address payable _beneficiary)
        public
        override
        payable
        protected
        only(BANCOR_NETWORK)
        returns (uint256)
    {
        require(_sourceToken != _targetToken, "ERR_SAME_SOURCE_TARGET");

        require(address(conversionWhitelist) == address(0) ||
                (conversionWhitelist.isWhitelisted(_trader) && conversionWhitelist.isWhitelisted(_beneficiary)),
                "ERR_NOT_WHITELISTED");

        return doConvert(_sourceToken, _targetToken, _amount, _trader, _beneficiary);
    }

    function doConvert(
        IERC20Token _sourceToken,
        IERC20Token _targetToken,
        uint256 _amount,
        address _trader,
        address payable _beneficiary)
        internal
        virtual
        returns (uint256);

    function calculateFee(uint256 _targetAmount) internal view returns (uint256) {
        return _targetAmount.mul(conversionFee).div(PPM_RESOLUTION);
    }

    function syncReserveBalance(IERC20Token _reserveToken) internal validReserve(_reserveToken) {
        if (_reserveToken == ETH_RESERVE_ADDRESS)
            reserves[_reserveToken].balance = address(this).balance;
        else
            reserves[_reserveToken].balance = _reserveToken.balanceOf(address(this));
    }

    function syncReserveBalances() internal {
        uint256 reserveCount = reserveTokens.length;
        for (uint256 i = 0; i < reserveCount; i++)
            syncReserveBalance(reserveTokens[i]);
    }

    function dispatchConversionEvent(
        IERC20Token _sourceToken,
        IERC20Token _targetToken,
        address _trader,
        uint256 _amount,
        uint256 _returnAmount,
        uint256 _feeAmount)
        internal
    {
        assert(_feeAmount < 2 ** 255);
        emit Conversion(_sourceToken, _targetToken, _trader, _amount, _returnAmount, int256(_feeAmount));
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

    function connectors(IERC20Token _address) public view override returns (uint256, uint32, bool, bool, bool) {
        Reserve memory reserve = reserves[_address];
        return(reserve.balance, reserve.weight, false, false, reserve.isSet);
    }

    function connectorTokens(uint256 _index) public view override returns (IERC20Token) {
        return ConverterBase.reserveTokens[_index];
    }

    function connectorTokenCount() public view override returns (uint16) {
        return reserveTokenCount();
    }

    function getConnectorBalance(IERC20Token _connectorToken) public view override returns (uint256) {
        return reserveBalance(_connectorToken);
    }

    function getReturn(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount) public view returns (uint256, uint256) {
        return targetAmountAndFee(_sourceToken, _targetToken, _amount);
    }
}



pragma solidity 0.6.12;


abstract contract LiquidityPoolConverter is ConverterBase {
    event LiquidityAdded(
        address indexed _provider,
        IERC20Token indexed _reserveToken,
        uint256 _amount,
        uint256 _newBalance,
        uint256 _newSupply
    );

    event LiquidityRemoved(
        address indexed _provider,
        IERC20Token indexed _reserveToken,
        uint256 _amount,
        uint256 _newBalance,
        uint256 _newSupply
    );

    constructor(
        IConverterAnchor _anchor,
        IContractRegistry _registry,
        uint32 _maxConversionFee
    )
        ConverterBase(_anchor, _registry, _maxConversionFee)
        internal
    {
    }

    function acceptAnchorOwnership() public virtual override {
        require(reserveTokenCount() > 1, "ERR_INVALID_RESERVE_COUNT");
        super.acceptAnchorOwnership();
    }
}



pragma solidity 0.6.12;




interface IDSToken is IConverterAnchor, IERC20Token {

    function issue(address _to, uint256 _amount) external;

    function destroy(address _from, uint256 _amount) external;

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

    function reducedRatio(uint256 _n, uint256 _d, uint256 _max) internal pure returns (uint256, uint256) {

        if (_n > _max || _d > _max)
            return normalizedRatio(_n, _d, _max);
        return (_n, _d);
    }

    function normalizedRatio(uint256 _a, uint256 _b, uint256 _scale) internal pure returns (uint256, uint256) {

        if (_a == _b)
            return (_scale / 2, _scale / 2);
        if (_a < _b)
            return accurateRatio(_a, _b, _scale);
        (uint256 y, uint256 x) = accurateRatio(_b, _a, _scale);
        return (x, y);
    }

    function accurateRatio(uint256 _a, uint256 _b, uint256 _scale) internal pure returns (uint256, uint256) {

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

        return _n / _d + _n % _d / (_d - _d / 2);
    }

    function geometricMean(uint256[] memory _values) internal pure returns (uint256) {

        uint256 numOfDigits = 0;
        uint256 length = _values.length;
        for (uint256 i = 0; i < length; i++)
            numOfDigits += decimalLength(_values[i]);
        return uint256(10) ** (roundDivUnsafe(numOfDigits, length) - 1);
    }

    function decimalLength(uint256 _x) internal pure returns (uint256) {

        uint256 y = 0;
        for (uint256 x = _x; x > 0; x /= 10)
            y++;
        return y;
    }

    function roundDivUnsafe(uint256 _n, uint256 _d) internal pure returns (uint256) {

        return (_n + _d / 2) / _d;
    }
}



pragma solidity 0.6.12;


struct Fraction {
    uint256 n;  // numerator
    uint256 d;  // denominator
}



pragma solidity 0.6.12;





contract LiquidityPoolV1Converter is LiquidityPoolConverter {

    using Math for *;

    IEtherToken internal etherToken = IEtherToken(0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315);
    uint256 internal constant MAX_RATE_FACTOR_LOWER_BOUND = 1e30;
    
    uint256 private constant AVERAGE_RATE_PERIOD = 10 minutes;

    bool public isStandardPool = false;

    Fraction public prevAverageRate;          // average rate after the previous conversion (1 reserve token 0 in reserve token 1 units)
    uint256 public prevAverageRateUpdateTime; // last time when the previous rate was updated (in seconds)

    event PriceDataUpdate(
        IERC20Token indexed _connectorToken,
        uint256 _tokenSupply,
        uint256 _connectorBalance,
        uint32 _connectorWeight
    );

    constructor(
        IDSToken _token,
        IContractRegistry _registry,
        uint32 _maxConversionFee
    )
        LiquidityPoolConverter(_token, _registry, _maxConversionFee)
        public
    {
    }

    function converterType() public pure override returns (uint16) {

        return 1;
    }

    function acceptAnchorOwnership() public override ownerOnly {

        super.acceptAnchorOwnership();

        emit Activation(converterType(), anchor, true);
    }

    function addReserve(IERC20Token _token, uint32 _weight) public override ownerOnly {

        super.addReserve(_token, _weight);

        isStandardPool =
            reserveTokens.length == 2 &&
            reserves[reserveTokens[0]].weight == PPM_RESOLUTION / 2 &&
            reserves[reserveTokens[1]].weight == PPM_RESOLUTION / 2;
    }

    function targetAmountAndFee(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount)
        public
        view
        override
        active
        validReserve(_sourceToken)
        validReserve(_targetToken)
        returns (uint256, uint256)
    {

        require(_sourceToken != _targetToken, "ERR_SAME_SOURCE_TARGET");

        uint256 amount = IBancorFormula(addressOf(BANCOR_FORMULA)).crossReserveTargetAmount(
            reserveBalance(_sourceToken),
            reserves[_sourceToken].weight,
            reserveBalance(_targetToken),
            reserves[_targetToken].weight,
            _amount
        );

        uint256 fee = calculateFee(amount);
        return (amount - fee, fee);
    }

    function doConvert(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount, address _trader, address payable _beneficiary)
        internal
        override
        returns (uint256)
    {

        if (isStandardPool && prevAverageRateUpdateTime < time()) {
            prevAverageRate = recentAverageRate();
            prevAverageRateUpdateTime = time();
        }

        (uint256 amount, uint256 fee) = targetAmountAndFee(_sourceToken, _targetToken, _amount);

        require(amount != 0, "ERR_ZERO_TARGET_AMOUNT");

        assert(amount < reserveBalance(_targetToken));

        if (_sourceToken == ETH_RESERVE_ADDRESS)
            require(msg.value == _amount, "ERR_ETH_AMOUNT_MISMATCH");
        else
            require(msg.value == 0 && _sourceToken.balanceOf(address(this)).sub(reserveBalance(_sourceToken)) >= _amount, "ERR_INVALID_AMOUNT");

        syncReserveBalance(_sourceToken);
        reserves[_targetToken].balance = reserves[_targetToken].balance.sub(amount);

        if (_targetToken == ETH_RESERVE_ADDRESS)
            _beneficiary.transfer(amount);
        else
            safeTransfer(_targetToken, _beneficiary, amount);

        dispatchConversionEvent(_sourceToken, _targetToken, _trader, _amount, amount, fee);

        dispatchTokenRateUpdateEvents(_sourceToken, _targetToken);

        return amount;
    }

    function recentAverageRate(IERC20Token _token) external view returns (uint256, uint256) {

        require(isStandardPool, "ERR_NON_STANDARD_POOL");

        Fraction memory rate = recentAverageRate();
        if (_token == reserveTokens[0]) {
            return (rate.n, rate.d);
        }

        return (rate.d, rate.n);
    }

    function recentAverageRate() internal view returns (Fraction memory) {

        uint256 timeElapsed = time() - prevAverageRateUpdateTime;

        if (timeElapsed == 0) {
            return prevAverageRate;
        }

        uint256 currentRateN = reserves[reserveTokens[1]].balance;
        uint256 currentRateD = reserves[reserveTokens[0]].balance;

        if (timeElapsed >= AVERAGE_RATE_PERIOD) {
            return Fraction({ n: currentRateN, d: currentRateD });
        }


        Fraction memory prevAverage = prevAverageRate;

        if (prevAverage.n == 0 && prevAverage.d == 0) {
            return Fraction({ n: currentRateN, d: currentRateD });
        }

        uint256 x = prevAverage.d.mul(currentRateN);
        uint256 y = prevAverage.n.mul(currentRateD);

        uint256 newRateN = y.mul(AVERAGE_RATE_PERIOD - timeElapsed).add(x.mul(timeElapsed));
        uint256 newRateD = prevAverage.d.mul(currentRateD).mul(AVERAGE_RATE_PERIOD);

        (newRateN, newRateD) = Math.reducedRatio(newRateN, newRateD, MAX_RATE_FACTOR_LOWER_BOUND);
        return Fraction({ n: newRateN, d: newRateD });
    }

    function addLiquidity(IERC20Token[] memory _reserveTokens, uint256[] memory _reserveAmounts, uint256 _minReturn)
        public
        payable
        protected
        active
        returns (uint256)
    {

        verifyLiquidityInput(_reserveTokens, _reserveAmounts, _minReturn);

        for (uint256 i = 0; i < _reserveTokens.length; i++)
            if (_reserveTokens[i] == ETH_RESERVE_ADDRESS)
                require(_reserveAmounts[i] == msg.value, "ERR_ETH_AMOUNT_MISMATCH");

        if (msg.value > 0) {
            require(reserves[ETH_RESERVE_ADDRESS].isSet, "ERR_NO_ETH_RESERVE");
        }

        uint256 totalSupply = IDSToken(address(anchor)).totalSupply();

        uint256 amount = addLiquidityToPool(_reserveTokens, _reserveAmounts, totalSupply);

        require(amount >= _minReturn, "ERR_RETURN_TOO_LOW");

        IDSToken(address(anchor)).issue(msg.sender, amount);

        return amount;
    }

    function removeLiquidity(uint256 _amount, IERC20Token[] memory _reserveTokens, uint256[] memory _reserveMinReturnAmounts)
        public
        protected
        active
        returns (uint256[] memory)
    {

        verifyLiquidityInput(_reserveTokens, _reserveMinReturnAmounts, _amount);

        uint256 totalSupply = IDSToken(address(anchor)).totalSupply();

        IDSToken(address(anchor)).destroy(msg.sender, _amount);

        return removeLiquidityFromPool(_reserveTokens, _reserveMinReturnAmounts, totalSupply, _amount);
    }

    function fund(uint256 _amount)
        public
        payable
        protected
        returns (uint256)
    {

        syncReserveBalances();
        reserves[ETH_RESERVE_ADDRESS].balance = reserves[ETH_RESERVE_ADDRESS].balance.sub(msg.value);

        uint256 supply = IDSToken(address(anchor)).totalSupply();
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));

        uint256 reserveCount = reserveTokens.length;
        for (uint256 i = 0; i < reserveCount; i++) {
            IERC20Token reserveToken = reserveTokens[i];
            uint256 rsvBalance = reserves[reserveToken].balance;
            uint256 reserveAmount = formula.fundCost(supply, rsvBalance, reserveRatio, _amount);

            if (reserveToken == ETH_RESERVE_ADDRESS) {
                if (msg.value > reserveAmount) {
                    msg.sender.transfer(msg.value - reserveAmount);
                }
                else if (msg.value < reserveAmount) {
                    require(msg.value == 0, "ERR_INVALID_ETH_VALUE");
                    safeTransferFrom(etherToken, msg.sender, address(this), reserveAmount);
                    etherToken.withdraw(reserveAmount);
                }
            }
            else {
                safeTransferFrom(reserveToken, msg.sender, address(this), reserveAmount);
            }

            uint256 newReserveBalance = rsvBalance.add(reserveAmount);
            reserves[reserveToken].balance = newReserveBalance;

            uint256 newPoolTokenSupply = supply.add(_amount);

            emit LiquidityAdded(msg.sender, reserveToken, reserveAmount, newReserveBalance, newPoolTokenSupply);

            dispatchPoolTokenRateUpdateEvent(newPoolTokenSupply, reserveToken, newReserveBalance, reserves[reserveToken].weight);
        }

        IDSToken(address(anchor)).issue(msg.sender, _amount);

        return _amount;
    }

    function liquidate(uint256 _amount)
        public
        protected
        returns (uint256[] memory)
    {

        require(_amount > 0, "ERR_ZERO_AMOUNT");

        uint256 totalSupply = IDSToken(address(anchor)).totalSupply();
        IDSToken(address(anchor)).destroy(msg.sender, _amount);

        uint256[] memory reserveMinReturnAmounts = new uint256[](reserveTokens.length);
        for (uint256 i = 0; i < reserveMinReturnAmounts.length; i++)
            reserveMinReturnAmounts[i] = 1;

        return removeLiquidityFromPool(reserveTokens, reserveMinReturnAmounts, totalSupply, _amount);
    }

    function addLiquidityCost(IERC20Token[] memory _reserveTokens, uint256 _reserveTokenIndex, uint256 _reserveAmount)
        public
        view
        returns (uint256[] memory)
    {

        uint256[] memory reserveAmounts = new uint256[](_reserveTokens.length);

        uint256 totalSupply = IDSToken(address(anchor)).totalSupply();
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        uint256 amount = formula.fundSupplyAmount(totalSupply, reserves[_reserveTokens[_reserveTokenIndex]].balance, reserveRatio, _reserveAmount);

        for (uint256 i = 0; i < reserveAmounts.length; i++)
            reserveAmounts[i] = formula.fundCost(totalSupply, reserves[_reserveTokens[i]].balance, reserveRatio, amount);

        return reserveAmounts;
    }

    function addLiquidityReturn(IERC20Token _reserveToken, uint256 _reserveAmount)
        public
        view
        returns (uint256)
    {

        uint256 totalSupply = IDSToken(address(anchor)).totalSupply();
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        return formula.fundSupplyAmount(totalSupply, reserves[_reserveToken].balance, reserveRatio, _reserveAmount);
    }

    function removeLiquidityReturn(uint256 _amount, IERC20Token[] memory _reserveTokens)
        public
        view
        returns (uint256[] memory)
    {

        uint256 totalSupply = IDSToken(address(anchor)).totalSupply();
        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        return removeLiquidityReserveAmounts(_amount, _reserveTokens, totalSupply, formula);
    }

    function verifyLiquidityInput(IERC20Token[] memory _reserveTokens, uint256[] memory _reserveAmounts, uint256 _amount)
        private
        view
    {

        uint256 i;
        uint256 j;

        uint256 length = reserveTokens.length;
        require(length == _reserveTokens.length, "ERR_INVALID_RESERVE");
        require(length == _reserveAmounts.length, "ERR_INVALID_AMOUNT");

        for (i = 0; i < length; i++) {
            require(reserves[_reserveTokens[i]].isSet, "ERR_INVALID_RESERVE");
            for (j = 0; j < length; j++) {
                if (reserveTokens[i] == _reserveTokens[j])
                    break;
            }
            require(j < length, "ERR_INVALID_RESERVE");
            require(_reserveAmounts[i] > 0, "ERR_INVALID_AMOUNT");
        }

        require(_amount > 0, "ERR_ZERO_AMOUNT");
    }

    function addLiquidityToPool(IERC20Token[] memory _reserveTokens, uint256[] memory _reserveAmounts, uint256 _totalSupply)
        private
        returns (uint256)
    {

        if (_totalSupply == 0)
            return addLiquidityToEmptyPool(_reserveTokens, _reserveAmounts);
        return addLiquidityToNonEmptyPool(_reserveTokens, _reserveAmounts, _totalSupply);
    }

    function addLiquidityToEmptyPool(IERC20Token[] memory _reserveTokens, uint256[] memory _reserveAmounts)
        private
        returns (uint256)
    {

        uint256 amount = Math.geometricMean(_reserveAmounts);

        for (uint256 i = 0; i < _reserveTokens.length; i++) {
            IERC20Token reserveToken = _reserveTokens[i];
            uint256 reserveAmount = _reserveAmounts[i];

            if (reserveToken != ETH_RESERVE_ADDRESS) // ETH has already been transferred as part of the transaction
                safeTransferFrom(reserveToken, msg.sender, address(this), reserveAmount);

            reserves[reserveToken].balance = reserveAmount;

            emit LiquidityAdded(msg.sender, reserveToken, reserveAmount, reserveAmount, amount);

            dispatchPoolTokenRateUpdateEvent(amount, reserveToken, reserveAmount, reserves[reserveToken].weight);
        }

        return amount;
    }

    function addLiquidityToNonEmptyPool(IERC20Token[] memory _reserveTokens, uint256[] memory _reserveAmounts, uint256 _totalSupply)
        private
        returns (uint256)
    {

        syncReserveBalances();
        reserves[ETH_RESERVE_ADDRESS].balance = reserves[ETH_RESERVE_ADDRESS].balance.sub(msg.value);

        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        uint256 amount = getMinShare(formula, _totalSupply, _reserveTokens, _reserveAmounts);
        uint256 newPoolTokenSupply = _totalSupply.add(amount);

        for (uint256 i = 0; i < _reserveTokens.length; i++) {
            IERC20Token reserveToken = _reserveTokens[i];
            uint256 rsvBalance = reserves[reserveToken].balance;
            uint256 reserveAmount = formula.fundCost(_totalSupply, rsvBalance, reserveRatio, amount);
            require(reserveAmount > 0, "ERR_ZERO_TARGET_AMOUNT");
            assert(reserveAmount <= _reserveAmounts[i]);

            if (reserveToken != ETH_RESERVE_ADDRESS) // ETH has already been transferred as part of the transaction
                safeTransferFrom(reserveToken, msg.sender, address(this), reserveAmount);
            else if (_reserveAmounts[i] > reserveAmount) // transfer the extra amount of ETH back to the user
                msg.sender.transfer(_reserveAmounts[i] - reserveAmount);

            uint256 newReserveBalance = rsvBalance.add(reserveAmount);
            reserves[reserveToken].balance = newReserveBalance;

            emit LiquidityAdded(msg.sender, reserveToken, reserveAmount, newReserveBalance, newPoolTokenSupply);

            dispatchPoolTokenRateUpdateEvent(newPoolTokenSupply, reserveToken, newReserveBalance, reserves[reserveToken].weight);
        }

        return amount;
    }

    function removeLiquidityReserveAmounts(uint256 _amount, IERC20Token[] memory _reserveTokens, uint256 _totalSupply, IBancorFormula _formula)
        private
        view
        returns (uint256[] memory)
    {

        uint256[] memory reserveAmounts = new uint256[](_reserveTokens.length);
        for (uint256 i = 0; i < reserveAmounts.length; i++)
            reserveAmounts[i] = _formula.liquidateReserveAmount(_totalSupply, reserves[_reserveTokens[i]].balance, reserveRatio, _amount);
        return reserveAmounts;
    }

    function removeLiquidityFromPool(IERC20Token[] memory _reserveTokens, uint256[] memory _reserveMinReturnAmounts, uint256 _totalSupply, uint256 _amount)
        private
        returns (uint256[] memory)
    {

        syncReserveBalances();

        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        uint256 newPoolTokenSupply = _totalSupply.sub(_amount);
        uint256[] memory reserveAmounts = removeLiquidityReserveAmounts(_amount, _reserveTokens, _totalSupply, formula);

        for (uint256 i = 0; i < _reserveTokens.length; i++) {
            IERC20Token reserveToken = _reserveTokens[i];
            uint256 reserveAmount = reserveAmounts[i];
            require(reserveAmount >= _reserveMinReturnAmounts[i], "ERR_ZERO_TARGET_AMOUNT");

            uint256 newReserveBalance = reserves[reserveToken].balance.sub(reserveAmount);
            reserves[reserveToken].balance = newReserveBalance;

            if (reserveToken == ETH_RESERVE_ADDRESS)
                msg.sender.transfer(reserveAmount);
            else
                safeTransfer(reserveToken, msg.sender, reserveAmount);

            emit LiquidityRemoved(msg.sender, reserveToken, reserveAmount, newReserveBalance, newPoolTokenSupply);

            dispatchPoolTokenRateUpdateEvent(newPoolTokenSupply, reserveToken, newReserveBalance, reserves[reserveToken].weight);
        }

        return reserveAmounts;
    }

    function getMinShare(IBancorFormula formula, uint256 _totalSupply, IERC20Token[] memory _reserveTokens, uint256[] memory _reserveAmounts) private view returns (uint256) {

        uint256 minIndex = 0;
        for (uint256 i = 1; i < _reserveTokens.length; i++) {
            if (_reserveAmounts[i].mul(reserves[_reserveTokens[minIndex]].balance) < _reserveAmounts[minIndex].mul(reserves[_reserveTokens[i]].balance))
                minIndex = i;
        }
        return formula.fundSupplyAmount(_totalSupply, reserves[_reserveTokens[minIndex]].balance, reserveRatio, _reserveAmounts[minIndex]);
    }

    function dispatchTokenRateUpdateEvents(IERC20Token _sourceToken, IERC20Token _targetToken) private {

        uint256 poolTokenSupply = IDSToken(address(anchor)).totalSupply();
        uint256 sourceReserveBalance = reserveBalance(_sourceToken);
        uint256 targetReserveBalance = reserveBalance(_targetToken);
        uint32 sourceReserveWeight = reserves[_sourceToken].weight;
        uint32 targetReserveWeight = reserves[_targetToken].weight;

        uint256 rateN = targetReserveBalance.mul(sourceReserveWeight);
        uint256 rateD = sourceReserveBalance.mul(targetReserveWeight);
        emit TokenRateUpdate(_sourceToken, _targetToken, rateN, rateD);

        dispatchPoolTokenRateUpdateEvent(poolTokenSupply, _sourceToken, sourceReserveBalance, sourceReserveWeight);
        dispatchPoolTokenRateUpdateEvent(poolTokenSupply, _targetToken, targetReserveBalance, targetReserveWeight);

        emit PriceDataUpdate(_sourceToken, poolTokenSupply, sourceReserveBalance, sourceReserveWeight);
        emit PriceDataUpdate(_targetToken, poolTokenSupply, targetReserveBalance, targetReserveWeight);
    }

    function dispatchPoolTokenRateUpdateEvent(uint256 _poolTokenSupply, IERC20Token _reserveToken, uint256 _reserveBalance, uint32 _reserveWeight) private {

        emit TokenRateUpdate(IDSToken(address(anchor)), _reserveToken, _reserveBalance.mul(PPM_RESOLUTION), _poolTokenSupply.mul(_reserveWeight));
    }

    function time() internal view virtual returns (uint256) {

        return now;
    }
}