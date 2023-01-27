
pragma solidity 0.4.26;


contract ContractIds {

    bytes32 public constant CONTRACT_FEATURES = "ContractFeatures";
    bytes32 public constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 public constant NON_STANDARD_TOKEN_REGISTRY = "NonStandardTokenRegistry";

    bytes32 public constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 public constant BANCOR_FORMULA = "BancorFormula";
    bytes32 public constant BANCOR_GAS_PRICE_LIMIT = "BancorGasPriceLimit";
    bytes32 public constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 public constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";

    bytes32 public constant BNT_TOKEN = "BNTToken";
    bytes32 public constant BNT_CONVERTER = "BNTConverter";

    bytes32 public constant BANCOR_X = "BancorX";
    bytes32 public constant BANCOR_X_UPGRADER = "BancorXUpgrader";
}


contract Utils {

    constructor() public {
    }

    modifier greaterThanZero(uint256 _amount) {

        require(_amount > 0);
        _;
    }

    modifier validAddress(address _address) {

        require(_address != address(0));
        _;
    }

    modifier notThis(address _address) {

        require(_address != address(this));
        _;
    }

}


contract IOwned {

    function owner() public view returns (address) {}


    function transferOwnership(address _newOwner) public;

    function acceptOwnership() public;

}


contract Owned is IOwned {

    address public owner;
    address public newOwner;

    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier ownerOnly {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public ownerOnly {

        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


contract BancorConverterRegistry is Owned, Utils {

    mapping (address => bool) private tokensRegistered;         // token address -> registered or not
    mapping (address => address[]) private tokensToConverters;  // token address -> converter addresses
    mapping (address => address) private convertersToTokens;    // converter address -> token address
    address[] public tokens;                                    // list of all token addresses

    event ConverterAddition(address indexed _token, address _address);

    event ConverterRemoval(address indexed _token, address _address);

    constructor() public {
    }

    function tokenCount() public view returns (uint256) {

        return tokens.length;
    }

    function converterCount(address _token) public view returns (uint256) {

        return tokensToConverters[_token].length;
    }

    function converterAddress(address _token, uint32 _index) public view returns (address) {

        if (_index >= tokensToConverters[_token].length)
            return address(0);

        return tokensToConverters[_token][_index];
    }

    function tokenAddress(address _converter) public view returns (address) {

        return convertersToTokens[_converter];
    }

    function registerConverter(address _token, address _converter)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_converter)
    {

        require(convertersToTokens[_converter] == address(0));

        if (!tokensRegistered[_token]) {
            tokens.push(_token);
            tokensRegistered[_token] = true;
        }

        tokensToConverters[_token].push(_converter);
        convertersToTokens[_converter] = _token;

        emit ConverterAddition(_token, _converter);
    }

    function unregisterConverter(address _token, uint32 _index)
        public
        ownerOnly
        validAddress(_token)
    {

        require(_index < tokensToConverters[_token].length);

        address converter = tokensToConverters[_token][_index];

        for (uint32 i = _index + 1; i < tokensToConverters[_token].length; i++) {
            tokensToConverters[_token][i - 1] = tokensToConverters[_token][i];
        }

        tokensToConverters[_token].length--;
        
        delete convertersToTokens[converter];

        emit ConverterRemoval(_token, converter);
    }
}


contract IERC20Token {

    function name() public view returns (string) {}

    function symbol() public view returns (string) {}
    function decimals() public view returns (uint8) {}

    function totalSupply() public view returns (uint256) {}
    function balanceOf(address _owner) public view returns (uint256) { _owner; }

    function allowance(address _owner, address _spender) public view returns (uint256) { _owner; _spender; }


    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

}


contract IWhitelist {

    function isWhitelisted(address _address) public view returns (bool);

}


contract IBancorConverter {

    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256, uint256);

    function convert2(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256);

    function quickConvert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public payable returns (uint256);

    function conversionWhitelist() public view returns (IWhitelist) {}

    function conversionFee() public view returns (uint32) {}
    function reserves(address _address) public view returns (uint256, uint32, bool, bool, bool) { _address; }

    function getReserveBalance(IERC20Token _reserveToken) public view returns (uint256);

    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);

    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);

    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);

    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool);

    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);

}


contract IBancorConverterUpgrader {

    function upgrade(bytes32 _version) public;

    function upgrade(uint16 _version) public;

}


contract IBancorFormula {

    function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _depositAmount) public view returns (uint256);

    function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _sellAmount) public view returns (uint256);

    function calculateCrossReserveReturn(uint256 _fromReserveBalance, uint32 _fromReserveRatio, uint256 _toReserveBalance, uint32 _toReserveRatio, uint256 _amount) public view returns (uint256);

    function calculateCrossConnectorReturn(uint256 _fromConnectorBalance, uint32 _fromConnectorWeight, uint256 _toConnectorBalance, uint32 _toConnectorWeight, uint256 _amount) public view returns (uint256);

}


contract IBancorNetwork {

    function convert2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public payable returns (uint256);


    function claimAndConvert2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public returns (uint256);


    function convertFor2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public payable returns (uint256);


    function claimAndConvertFor2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public returns (uint256);


    function convertForPrioritized4(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256[] memory _signature,
        address _affiliateAccount,
        uint256 _affiliateFee
    ) public payable returns (uint256);


    function convert(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) public payable returns (uint256);


    function claimAndConvert(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn
    ) public returns (uint256);


    function convertFor(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) public payable returns (uint256);


    function claimAndConvertFor(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for
    ) public returns (uint256);


    function convertForPrioritized3(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _customVal,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);


    function convertForPrioritized2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);


    function convertForPrioritized(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint256 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);

}


contract FeatureIds {

    uint256 public constant CONVERTER_CONVERSION_WHITELIST = 1 << 0;
}


contract Managed is Owned {

    address public manager;
    address public newManager;

    event ManagerUpdate(address indexed _prevManager, address indexed _newManager);

    constructor() public {
        manager = msg.sender;
    }

    modifier managerOnly {

        assert(msg.sender == manager);
        _;
    }

    modifier ownerOrManagerOnly {

        require(msg.sender == owner || msg.sender == manager);
        _;
    }

    function transferManagement(address _newManager) public ownerOrManagerOnly {

        require(_newManager != manager);
        newManager = _newManager;
    }

    function acceptManagement() public {

        require(msg.sender == newManager);
        emit ManagerUpdate(manager, newManager);
        manager = newManager;
        newManager = address(0);
    }
}


library SafeMath {

    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {

        uint256 z = _x + _y;
        require(z >= _x);
        return z;
    }

    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_x >= _y);
        return _x - _y;
    }

    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {

        if (_x == 0)
            return 0;

        uint256 z = _x * _y;
        require(z / _x == _y);
        return z;
    }

    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_y > 0);
        uint256 c = _x / _y;

        return c;
    }
}


contract IContractRegistry {

    function addressOf(bytes32 _contractName) public view returns (address);


    function getAddress(bytes32 _contractName) public view returns (address);

}


contract IContractFeatures {

    function isSupported(address _contract, uint256 _features) public view returns (bool);

    function enableFeatures(uint256 _features, bool _enable) public;

}


contract IAddressList {

    mapping (address => bool) public listedAddresses;
}


contract ISmartTokenController {

    function claimTokens(address _from, uint256 _amount) public;

}


contract ISmartToken is IOwned, IERC20Token {

    function disableTransfers(bool _disable) public;

    function issue(address _to, uint256 _amount) public;

    function destroy(address _from, uint256 _amount) public;

}


contract ITokenHolder is IOwned {

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;

}


contract INonStandardERC20 {

    function name() public view returns (string) {}

    function symbol() public view returns (string) {}
    function decimals() public view returns (uint8) {}

    function totalSupply() public view returns (uint256) {}
    function balanceOf(address _owner) public view returns (uint256) { _owner; }

    function allowance(address _owner, address _spender) public view returns (uint256) { _owner; _spender; }


    function transfer(address _to, uint256 _value) public;

    function transferFrom(address _from, address _to, uint256 _value) public;

    function approve(address _spender, uint256 _value) public;

}


contract TokenHolder is ITokenHolder, Owned, Utils {

    constructor() public {
    }

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {

        INonStandardERC20(_token).transfer(_to, _amount);
    }
}


contract SmartTokenController is ISmartTokenController, TokenHolder {

    ISmartToken public token;   // Smart Token contract
    address public bancorX;     // BancorX contract

    constructor(ISmartToken _token)
        public
        validAddress(_token)
    {
        token = _token;
    }

    modifier active() {

        require(token.owner() == address(this));
        _;
    }

    modifier inactive() {

        require(token.owner() != address(this));
        _;
    }

    function transferTokenOwnership(address _newOwner) public ownerOnly {

        token.transferOwnership(_newOwner);
    }

    function acceptTokenOwnership() public ownerOnly {

        token.acceptOwnership();
    }

    function disableTokenTransfers(bool _disable) public ownerOnly {

        token.disableTransfers(_disable);
    }

    function withdrawFromToken(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {

        ITokenHolder(token).withdrawTokens(_token, _to, _amount);
    }

    function claimTokens(address _from, uint256 _amount) public {

        require(msg.sender == bancorX);

        token.destroy(_from, _amount);
        token.issue(msg.sender, _amount);
    }

    function setBancorX(address _bancorX) public ownerOnly {

        bancorX = _bancorX;
    }
}


contract IEtherToken is ITokenHolder, IERC20Token {

    function deposit() public payable;

    function withdraw(uint256 _amount) public;

    function withdrawTo(address _to, uint256 _amount) public;

}


contract IBancorX {

    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount, uint256 _id) public;

    function getXTransferAmount(uint256 _xTransferId, address _for) public view returns (uint256);

}


contract BancorConverter is IBancorConverter, SmartTokenController, Managed, ContractIds, FeatureIds {

    using SafeMath for uint256;

    
    uint32 private constant RATIO_RESOLUTION = 1000000;
    uint64 private constant CONVERSION_FEE_RESOLUTION = 1000000;

    struct Reserve {
        uint256 virtualBalance;         // reserve virtual balance
        uint32 ratio;                   // reserve ratio, represented in ppm, 1-1000000
        bool isVirtualBalanceEnabled;   // true if virtual balance is enabled, false if not
        bool isSaleEnabled;             // is sale of the reserve token enabled, can be set by the owner
        bool isSet;                     // used to tell if the mapping element is defined
    }

    uint16 public version = 17;
    string public converterType = 'bancor';

    bool public allowRegistryUpdate = true;             // allows the owner to prevent/allow the registry to be updated
    IContractRegistry public prevRegistry;              // address of previous registry as security mechanism
    IContractRegistry public registry;                  // contract registry contract
    IWhitelist public conversionWhitelist;              // whitelist contract with list of addresses that are allowed to use the converter
    IERC20Token[] public reserveTokens;                 // ERC20 standard token addresses (prior version 17, use 'connectorTokens' instead)
    mapping (address => Reserve) public reserves;       // reserve token addresses -> reserve data (prior version 17, use 'connectors' instead)
    uint32 private totalReserveRatio = 0;               // used to efficiently prevent increasing the total reserve ratio above 100%
    uint32 public maxConversionFee = 0;                 // maximum conversion fee for the lifetime of the contract,
    uint32 public conversionFee = 0;                    // current conversion fee, represented in ppm, 0...maxConversionFee
    bool public conversionsEnabled = true;              // true if token conversions is enabled, false if not

    event Conversion(
        address indexed _fromToken,
        address indexed _toToken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionFee
    );

    event PriceDataUpdate(
        address indexed _connectorToken,
        uint256 _tokenSupply,
        uint256 _connectorBalance,
        uint32 _connectorWeight
    );

    event ConversionFeeUpdate(uint32 _prevFee, uint32 _newFee);

    event ConversionsEnable(bool _conversionsEnabled);

    constructor(
        ISmartToken _token,
        IContractRegistry _registry,
        uint32 _maxConversionFee,
        IERC20Token _reserveToken,
        uint32 _reserveRatio
    )
        public
        SmartTokenController(_token)
        validAddress(_registry)
        validConversionFee(_maxConversionFee)
    {
        registry = _registry;
        prevRegistry = _registry;
        IContractFeatures features = IContractFeatures(registry.addressOf(ContractIds.CONTRACT_FEATURES));

        if (features != address(0))
            features.enableFeatures(FeatureIds.CONVERTER_CONVERSION_WHITELIST, true);

        maxConversionFee = _maxConversionFee;

        if (_reserveToken != address(0))
            addReserve(_reserveToken, _reserveRatio, false);
    }

    modifier validReserve(IERC20Token _address) {

        require(reserves[_address].isSet);
        _;
    }

    modifier validConversionFee(uint32 _conversionFee) {

        require(_conversionFee >= 0 && _conversionFee <= CONVERSION_FEE_RESOLUTION);
        _;
    }

    modifier validReserveRatio(uint32 _ratio) {

        require(_ratio > 0 && _ratio <= RATIO_RESOLUTION);
        _;
    }

    modifier fullTotalRatioOnly() {

        require(totalReserveRatio == RATIO_RESOLUTION);
        _;
    }

    modifier conversionsAllowed {

        assert(conversionsEnabled);
        _;
    }

    modifier bancorNetworkOnly {

        IBancorNetwork bancorNetwork = IBancorNetwork(registry.addressOf(ContractIds.BANCOR_NETWORK));
        require(msg.sender == address(bancorNetwork));
        _;
    }

    modifier converterUpgraderOnly {

        address converterUpgrader = registry.addressOf(ContractIds.BANCOR_CONVERTER_UPGRADER);
        require(owner == converterUpgrader);
        _;
    }

    function updateRegistry() public {

        require(allowRegistryUpdate || msg.sender == owner);

        address newRegistry = registry.addressOf(ContractIds.CONTRACT_REGISTRY);

        require(newRegistry != address(registry) && newRegistry != address(0));

        prevRegistry = registry;
        registry = IContractRegistry(newRegistry);
    }

    function restoreRegistry() public ownerOrManagerOnly {

        registry = prevRegistry;

        allowRegistryUpdate = false;
    }

    function disableRegistryUpdate(bool _disable) public ownerOrManagerOnly {

        allowRegistryUpdate = !_disable;
    }

    function reserveTokenCount() public view returns (uint16) {

        return uint16(reserveTokens.length);
    }

    function setConversionWhitelist(IWhitelist _whitelist)
        public
        ownerOnly
        notThis(_whitelist)
    {

        conversionWhitelist = _whitelist;
    }

    function disableConversions(bool _disable) public ownerOrManagerOnly {

        if (conversionsEnabled == _disable) {
            conversionsEnabled = !_disable;
            emit ConversionsEnable(conversionsEnabled);
        }
    }

    function transferTokenOwnership(address _newOwner)
        public
        ownerOnly
        converterUpgraderOnly
    {

        super.transferTokenOwnership(_newOwner);
    }

    function setConversionFee(uint32 _conversionFee)
        public
        ownerOrManagerOnly
    {

        require(_conversionFee >= 0 && _conversionFee <= maxConversionFee);
        emit ConversionFeeUpdate(conversionFee, _conversionFee);
        conversionFee = _conversionFee;
    }

    function getFinalAmount(uint256 _amount, uint8 _magnitude) public view returns (uint256) {

        return _amount.mul((CONVERSION_FEE_RESOLUTION - conversionFee) ** _magnitude).div(CONVERSION_FEE_RESOLUTION ** _magnitude);
    }

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public {

        address converterUpgrader = registry.addressOf(ContractIds.BANCOR_CONVERTER_UPGRADER);

        require(!reserves[_token].isSet || token.owner() != address(this) || owner == converterUpgrader);
        super.withdrawTokens(_token, _to, _amount);
    }

    function upgrade() public ownerOnly {

        IBancorConverterUpgrader converterUpgrader = IBancorConverterUpgrader(registry.addressOf(ContractIds.BANCOR_CONVERTER_UPGRADER));

        transferOwnership(converterUpgrader);
        converterUpgrader.upgrade(version);
        acceptOwnership();
    }

    function addReserve(IERC20Token _token, uint32 _ratio, bool _enableVirtualBalance)
        public
        ownerOnly
        inactive
        validAddress(_token)
        notThis(_token)
        validReserveRatio(_ratio)
    {

        require(_token != token && !reserves[_token].isSet && totalReserveRatio + _ratio <= RATIO_RESOLUTION); // validate input

        reserves[_token].virtualBalance = 0;
        reserves[_token].ratio = _ratio;
        reserves[_token].isVirtualBalanceEnabled = _enableVirtualBalance;
        reserves[_token].isSaleEnabled = true;
        reserves[_token].isSet = true;
        reserveTokens.push(_token);
        totalReserveRatio += _ratio;
    }

    function updateReserve(IERC20Token _reserveToken, uint32 _ratio, bool _enableVirtualBalance, uint256 _virtualBalance)
        public
        ownerOnly
        validReserve(_reserveToken)
        validReserveRatio(_ratio)
    {

        Reserve storage reserve = reserves[_reserveToken];
        require(totalReserveRatio - reserve.ratio + _ratio <= RATIO_RESOLUTION); // validate input

        totalReserveRatio = totalReserveRatio - reserve.ratio + _ratio;
        reserve.ratio = _ratio;
        reserve.isVirtualBalanceEnabled = _enableVirtualBalance;
        reserve.virtualBalance = _virtualBalance;
    }

    function disableReserveSale(IERC20Token _reserveToken, bool _disable)
        public
        ownerOnly
        validReserve(_reserveToken)
    {

        reserves[_reserveToken].isSaleEnabled = !_disable;
    }

    function getReserveBalance(IERC20Token _reserveToken)
        public
        view
        validReserve(_reserveToken)
        returns (uint256)
    {

        Reserve storage reserve = reserves[_reserveToken];
        return reserve.isVirtualBalanceEnabled ? reserve.virtualBalance : _reserveToken.balanceOf(this);
    }

    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256, uint256) {

        require(_fromToken != _toToken); // validate input

        if (_toToken == token)
            return getPurchaseReturn(_fromToken, _amount);
        else if (_fromToken == token)
            return getSaleReturn(_toToken, _amount);

        return getCrossReserveReturn(_fromToken, _toToken, _amount);
    }

    function getPurchaseReturn(IERC20Token _reserveToken, uint256 _depositAmount)
        public
        view
        active
        validReserve(_reserveToken)
        returns (uint256, uint256)
    {

        Reserve storage reserve = reserves[_reserveToken];
        require(reserve.isSaleEnabled); // validate input

        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = getReserveBalance(_reserveToken);
        IBancorFormula formula = IBancorFormula(registry.addressOf(ContractIds.BANCOR_FORMULA));
        uint256 amount = formula.calculatePurchaseReturn(tokenSupply, reserveBalance, reserve.ratio, _depositAmount);
        uint256 finalAmount = getFinalAmount(amount, 1);

        return (finalAmount, amount - finalAmount);
    }

    function getSaleReturn(IERC20Token _reserveToken, uint256 _sellAmount)
        public
        view
        active
        validReserve(_reserveToken)
        returns (uint256, uint256)
    {

        Reserve storage reserve = reserves[_reserveToken];
        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = getReserveBalance(_reserveToken);
        IBancorFormula formula = IBancorFormula(registry.addressOf(ContractIds.BANCOR_FORMULA));
        uint256 amount = formula.calculateSaleReturn(tokenSupply, reserveBalance, reserve.ratio, _sellAmount);
        uint256 finalAmount = getFinalAmount(amount, 1);

        return (finalAmount, amount - finalAmount);
    }

    function getCrossReserveReturn(IERC20Token _fromReserveToken, IERC20Token _toReserveToken, uint256 _sellAmount)
        public
        view
        active
        validReserve(_fromReserveToken)
        validReserve(_toReserveToken)
        returns (uint256, uint256)
    {

        Reserve storage fromReserve = reserves[_fromReserveToken];
        Reserve storage toReserve = reserves[_toReserveToken];
        require(fromReserve.isSaleEnabled); // validate input

        IBancorFormula formula = IBancorFormula(registry.addressOf(ContractIds.BANCOR_FORMULA));
        uint256 amount = formula.calculateCrossReserveReturn(
            getReserveBalance(_fromReserveToken), 
            fromReserve.ratio, 
            getReserveBalance(_toReserveToken), 
            toReserve.ratio, 
            _sellAmount);
        uint256 finalAmount = getFinalAmount(amount, 2);

        return (finalAmount, amount - finalAmount);
    }

    function convertInternal(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn)
        public
        bancorNetworkOnly
        conversionsAllowed
        greaterThanZero(_minReturn)
        returns (uint256)
    {

        require(_fromToken != _toToken); // validate input

        if (_toToken == token)
            return buy(_fromToken, _amount, _minReturn);
        else if (_fromToken == token)
            return sell(_toToken, _amount, _minReturn);

        uint256 amount;
        uint256 feeAmount;

        (amount, feeAmount) = getCrossReserveReturn(_fromToken, _toToken, _amount);
        require(amount != 0 && amount >= _minReturn);

        Reserve storage fromReserve = reserves[_fromToken];
        if (fromReserve.isVirtualBalanceEnabled)
            fromReserve.virtualBalance = fromReserve.virtualBalance.add(_amount);

        Reserve storage toReserve = reserves[_toToken];
        if (toReserve.isVirtualBalanceEnabled)
            toReserve.virtualBalance = toReserve.virtualBalance.sub(amount);

        uint256 toReserveBalance = getReserveBalance(_toToken);
        assert(amount < toReserveBalance);

        ensureTransferFrom(_fromToken, msg.sender, this, _amount);
        ensureTransfer(_toToken, msg.sender, amount);

        dispatchConversionEvent(_fromToken, _toToken, _amount, amount, feeAmount);

        emit PriceDataUpdate(_fromToken, token.totalSupply(), getReserveBalance(_fromToken), fromReserve.ratio);
        emit PriceDataUpdate(_toToken, token.totalSupply(), getReserveBalance(_toToken), toReserve.ratio);
        return amount;
    }

    function buy(IERC20Token _reserveToken, uint256 _depositAmount, uint256 _minReturn) internal returns (uint256) {

        uint256 amount;
        uint256 feeAmount;
        (amount, feeAmount) = getPurchaseReturn(_reserveToken, _depositAmount);
        require(amount != 0 && amount >= _minReturn);

        Reserve storage reserve = reserves[_reserveToken];
        if (reserve.isVirtualBalanceEnabled)
            reserve.virtualBalance = reserve.virtualBalance.add(_depositAmount);

        ensureTransferFrom(_reserveToken, msg.sender, this, _depositAmount);
        token.issue(msg.sender, amount);

        dispatchConversionEvent(_reserveToken, token, _depositAmount, amount, feeAmount);

        emit PriceDataUpdate(_reserveToken, token.totalSupply(), getReserveBalance(_reserveToken), reserve.ratio);
        return amount;
    }

    function sell(IERC20Token _reserveToken, uint256 _sellAmount, uint256 _minReturn) internal returns (uint256) {

        require(_sellAmount <= token.balanceOf(msg.sender)); // validate input
        uint256 amount;
        uint256 feeAmount;
        (amount, feeAmount) = getSaleReturn(_reserveToken, _sellAmount);
        require(amount != 0 && amount >= _minReturn);

        uint256 tokenSupply = token.totalSupply();
        uint256 reserveBalance = getReserveBalance(_reserveToken);
        assert(amount < reserveBalance || (amount == reserveBalance && _sellAmount == tokenSupply));

        Reserve storage reserve = reserves[_reserveToken];
        if (reserve.isVirtualBalanceEnabled)
            reserve.virtualBalance = reserve.virtualBalance.sub(amount);

        token.destroy(msg.sender, _sellAmount);
        ensureTransfer(_reserveToken, msg.sender, amount);

        dispatchConversionEvent(token, _reserveToken, _sellAmount, amount, feeAmount);

        emit PriceDataUpdate(_reserveToken, token.totalSupply(), getReserveBalance(_reserveToken), reserve.ratio);
        return amount;
    }

    function convert2(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256) {

        IERC20Token[] memory path = new IERC20Token[](3);
        (path[0], path[1], path[2]) = (_fromToken, token, _toToken);
        return quickConvert2(path, _amount, _minReturn, _affiliateAccount, _affiliateFee);
    }

    function quickConvert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee)
        public
        payable
        returns (uint256)
    {

        return quickConvertPrioritized2(_path, _amount, _minReturn, getSignature(0x0, 0x0, 0x0, 0x0, 0x0), _affiliateAccount, _affiliateFee);
    }

    function quickConvertPrioritized2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, uint256[] memory _signature, address _affiliateAccount, uint256 _affiliateFee)
        public
        payable
        returns (uint256)
    {

        require(_signature.length == 0 || _signature[0] == _amount);

        IBancorNetwork bancorNetwork = IBancorNetwork(registry.addressOf(ContractIds.BANCOR_NETWORK));

        if (msg.value == 0) {
            if (_path[0] == token) {
                token.destroy(msg.sender, _amount); // destroy _amount tokens from the caller's balance in the smart token
                token.issue(bancorNetwork, _amount); // issue _amount new tokens to the BancorNetwork contract
            } else {
                ensureTransferFrom(_path[0], msg.sender, bancorNetwork, _amount);
            }
        }

        return bancorNetwork.convertForPrioritized4.value(msg.value)(_path, _amount, _minReturn, msg.sender, _signature, _affiliateAccount, _affiliateFee);
    }

    function completeXConversion2(
        IERC20Token[] _path,
        uint256 _minReturn,
        uint256 _conversionId,
        uint256[] memory _signature
    )
        public
        returns (uint256)
    {

        require(_signature.length == 0 || _signature[0] == _conversionId);

        IBancorX bancorX = IBancorX(registry.addressOf(ContractIds.BANCOR_X));
        IBancorNetwork bancorNetwork = IBancorNetwork(registry.addressOf(ContractIds.BANCOR_NETWORK));

        require(_path[0] == registry.addressOf(ContractIds.BNT_TOKEN));

        uint256 amount = bancorX.getXTransferAmount(_conversionId, msg.sender);

        token.destroy(msg.sender, amount);
        token.issue(bancorNetwork, amount);

        return bancorNetwork.convertForPrioritized4(_path, amount, _minReturn, msg.sender, _signature, address(0), 0);
    }

    function ensureTransfer(IERC20Token _token, address _to, uint256 _amount) private {

        IAddressList addressList = IAddressList(registry.addressOf(ContractIds.NON_STANDARD_TOKEN_REGISTRY));

        if (addressList.listedAddresses(_token)) {
            uint256 prevBalance = _token.balanceOf(_to);
            INonStandardERC20(_token).transfer(_to, _amount);
            uint256 postBalance = _token.balanceOf(_to);
            assert(postBalance > prevBalance);
        } else {
            assert(_token.transfer(_to, _amount));
        }
    }

    function ensureTransferFrom(IERC20Token _token, address _from, address _to, uint256 _amount) private {

        IAddressList addressList = IAddressList(registry.addressOf(ContractIds.NON_STANDARD_TOKEN_REGISTRY));

        if (addressList.listedAddresses(_token)) {
            uint256 prevBalance = _token.balanceOf(_to);
            INonStandardERC20(_token).transferFrom(_from, _to, _amount);
            uint256 postBalance = _token.balanceOf(_to);
            assert(postBalance > prevBalance);
        } else {
            assert(_token.transferFrom(_from, _to, _amount));
        }
    }

    function fund(uint256 _amount)
        public
        fullTotalRatioOnly
        conversionsAllowed
    {

        uint256 supply = token.totalSupply();

        IERC20Token reserveToken;
        uint256 reserveBalance;
        uint256 reserveAmount;
        for (uint16 i = 0; i < reserveTokens.length; i++) {
            reserveToken = reserveTokens[i];
            reserveBalance = getReserveBalance(reserveToken);
            reserveAmount = _amount.mul(reserveBalance).sub(1).div(supply).add(1);

            Reserve storage reserve = reserves[reserveToken];
            if (reserve.isVirtualBalanceEnabled)
                reserve.virtualBalance = reserve.virtualBalance.add(reserveAmount);

            ensureTransferFrom(reserveToken, msg.sender, this, reserveAmount);

            emit PriceDataUpdate(reserveToken, supply + _amount, reserveBalance + reserveAmount, reserve.ratio);
        }

        token.issue(msg.sender, _amount);
    }

    function liquidate(uint256 _amount) public fullTotalRatioOnly {

        uint256 supply = token.totalSupply();

        token.destroy(msg.sender, _amount);

        IERC20Token reserveToken;
        uint256 reserveBalance;
        uint256 reserveAmount;
        for (uint16 i = 0; i < reserveTokens.length; i++) {
            reserveToken = reserveTokens[i];
            reserveBalance = getReserveBalance(reserveToken);
            reserveAmount = _amount.mul(reserveBalance).div(supply);

            Reserve storage reserve = reserves[reserveToken];
            if (reserve.isVirtualBalanceEnabled)
                reserve.virtualBalance = reserve.virtualBalance.sub(reserveAmount);

            ensureTransfer(reserveToken, msg.sender, reserveAmount);

            emit PriceDataUpdate(reserveToken, supply - _amount, reserveBalance - reserveAmount, reserve.ratio);
        }
    }

    function dispatchConversionEvent(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _returnAmount, uint256 _feeAmount) private {

        assert(_feeAmount < 2 ** 255);
        emit Conversion(_fromToken, _toToken, msg.sender, _amount, _returnAmount, int256(_feeAmount));
    }

    function getSignature(
        uint256 _customVal,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (uint256[] memory) {

        if (_v == 0x0 && _r == 0x0 && _s == 0x0)
            return new uint256[](0);
        uint256[] memory signature = new uint256[](5);
        signature[0] = _customVal;
        signature[1] = _block;
        signature[2] = uint256(_v);
        signature[3] = uint256(_r);
        signature[4] = uint256(_s);
        return signature;
    }

    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256) {

        return convertInternal(_fromToken, _toToken, _amount, _minReturn);
    }

    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256) {

        return convert2(_fromToken, _toToken, _amount, _minReturn, address(0), 0);
    }

    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256) {

        return quickConvert2(_path, _amount, _minReturn, address(0), 0);
    }

    function quickConvertPrioritized(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, uint256 _block, uint8 _v, bytes32 _r, bytes32 _s) public payable returns (uint256) {

        return quickConvertPrioritized2(_path, _amount, _minReturn, getSignature(_amount, _block, _v, _r, _s), address(0), 0);
    }

    function completeXConversion(IERC20Token[] _path, uint256 _minReturn, uint256 _conversionId, uint256 _block, uint8 _v, bytes32 _r, bytes32 _s) public returns (uint256) {

        return completeXConversion2(_path, _minReturn, _conversionId, getSignature(_conversionId, _block, _v, _r, _s));
    }

    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool) {

        Reserve storage reserve = reserves[_address];
        return(reserve.virtualBalance, reserve.ratio, reserve.isVirtualBalanceEnabled, reserve.isSaleEnabled, reserve.isSet);
    }

    function connectorTokens(uint256 _index) public view returns (IERC20Token) {

        return BancorConverter.reserveTokens[_index];
    }

    function connectorTokenCount() public view returns (uint16) {

        return reserveTokenCount();
    }

    function addConnector(IERC20Token _token, uint32 _weight, bool _enableVirtualBalance) public {

        addReserve(_token, _weight, _enableVirtualBalance);
    }

    function updateConnector(IERC20Token _connectorToken, uint32 _weight, bool _enableVirtualBalance, uint256 _virtualBalance) public {

        updateReserve(_connectorToken, _weight, _enableVirtualBalance, _virtualBalance);
    }

    function disableConnectorSale(IERC20Token _connectorToken, bool _disable) public {

        disableReserveSale(_connectorToken, _disable);
    }

    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256) {

        return getReserveBalance(_connectorToken);
    }

    function getCrossConnectorReturn(IERC20Token _fromConnectorToken, IERC20Token _toConnectorToken, uint256 _sellAmount) public view returns (uint256, uint256) {

        return getCrossReserveReturn(_fromConnectorToken, _toConnectorToken, _sellAmount);
    }
}


contract BancorNetworkPathFinder is ContractIds, Utils {

    IContractRegistry public contractRegistry;
    address public anchorToken;

    constructor(IContractRegistry _contractRegistry) public validAddress(_contractRegistry) {
        contractRegistry = _contractRegistry;
        anchorToken = contractRegistry.addressOf(BNT_TOKEN);
    }

    function updateAnchorToken() external {

        address bntToken = contractRegistry.addressOf(BNT_TOKEN);
        require(anchorToken != bntToken);
        anchorToken = bntToken;
    }

    function get(address _sourceToken, address _targetToken, BancorConverterRegistry[] memory _converterRegistries) public view returns (address[] memory) {

        assert(anchorToken == contractRegistry.addressOf(BNT_TOKEN));
        address[] memory sourcePath = getPath(_sourceToken, _converterRegistries);
        address[] memory targetPath = getPath(_targetToken, _converterRegistries);
        return getShortestPath(sourcePath, targetPath);
    }

    function getPath(address _token, BancorConverterRegistry[] memory _converterRegistries) private view returns (address[] memory) {

        if (_token == anchorToken) {
            address[] memory initialPath = new address[](1);
            initialPath[0] = _token;
            return initialPath;
        }

        uint256 tokenCount;
        uint256 i;
        address token;
        address[] memory path;

        for (uint256 n = 0; n < _converterRegistries.length; n++) {
            uint256 converterCount = _converterRegistries[n].converterCount(_token);
            if (converterCount > 0) {
                BancorConverter converter = BancorConverter(_converterRegistries[n].converterAddress(_token, uint32(converterCount - 1)));
                tokenCount = getTokenCount(converter, CONNECTOR_TOKEN_COUNT);
                for (i = 0; i < tokenCount; i++) {
                    token = converter.connectorTokens(i);
                    if (token != _token) {
                        path = getPath(token, _converterRegistries);
                        if (path.length > 0)
                            return getNewPath(path, _token, converter);
                    }
                }
                tokenCount = getTokenCount(converter, RESERVE_TOKEN_COUNT);
                for (i = 0; i < tokenCount; i++) {
                    token = converter.reserveTokens(i);
                    if (token != _token) {
                        path = getPath(token, _converterRegistries);
                        if (path.length > 0)
                            return getNewPath(path, _token, converter);
                    }
                }
            }
        }

        return new address[](0);
    }

    bytes4 private constant CONNECTOR_TOKEN_COUNT = bytes4(uint256(keccak256("connectorTokenCount()") >> (256 - 4 * 8)));
    bytes4 private constant RESERVE_TOKEN_COUNT   = bytes4(uint256(keccak256("reserveTokenCount()"  ) >> (256 - 4 * 8)));

    function getTokenCount(address _dest, bytes4 _funcSelector) private view returns (uint256) {

        uint256[1] memory ret;
        bytes memory data = abi.encodeWithSelector(_funcSelector);

        assembly {
            pop(staticcall(
                gas,           // gas remaining
                _dest,         // destination address
                add(data, 32), // input buffer (starts after the first 32 bytes in the `data` array)
                mload(data),   // input length (loaded from the first 32 bytes in the `data` array)
                ret,           // output buffer
                32             // output length
            ))
        }

        return ret[0];
    }

    function getNewPath(address[] memory _path, address _token, BancorConverter _converter) private view returns (address[] memory) {

        address[] memory newPath = new address[](2 + _path.length);
        newPath[0] = _token;
        newPath[1] = _converter.token();
        for (uint256 k = 0; k < _path.length; k++)
            newPath[2 + k] = _path[k];
        return newPath;
    }

    function getShortestPath(address[] memory _sourcePath, address[] memory _targetPath) private pure returns (address[] memory) {

        uint256 i = _sourcePath.length;
        uint256 j = _targetPath.length;
        while (i > 0 && j > 0 && _sourcePath[i - 1] == _targetPath[j - 1]) {
            i--;
            j--;
        }

        address[] memory path = new address[](i + j + 1);
        for (uint256 m = 0; m <= i; m++)
            path[m] = _sourcePath[m];
        for (uint256 n = j; n > 0; n--)
            path[path.length - n] = _targetPath[n - 1];
        return path;
    }
}