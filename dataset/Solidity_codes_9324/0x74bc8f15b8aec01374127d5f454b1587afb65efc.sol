

pragma solidity 0.4.26;

contract IOwned {

    function owner() public view returns (address) {this;}


    function transferOwnership(address _newOwner) public;

    function acceptOwnership() public;

}


pragma solidity 0.4.26;

contract IERC20Token {

    function name() public view returns (string) {this;}

    function symbol() public view returns (string) {this;}

    function decimals() public view returns (uint8) {this;}

    function totalSupply() public view returns (uint256) {this;}

    function balanceOf(address _owner) public view returns (uint256) {_owner; this;}

    function allowance(address _owner, address _spender) public view returns (uint256) {_owner; _spender; this;}


    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

}


pragma solidity 0.4.26;



contract ITokenHolder is IOwned {

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;

}


pragma solidity 0.4.26;



contract IConverterAnchor is IOwned, ITokenHolder {

}


pragma solidity 0.4.26;

contract IWhitelist {

    function isWhitelisted(address _address) public view returns (bool);

}


pragma solidity 0.4.26;





contract IConverter is IOwned {

    function converterType() public pure returns (uint16);

    function anchor() public view returns (IConverterAnchor) {this;}

    function isActive() public view returns (bool);


    function targetAmountAndFee(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount) public view returns (uint256, uint256);

    function convert(IERC20Token _sourceToken,
                     IERC20Token _targetToken,
                     uint256 _amount,
                     address _trader,
                     address _beneficiary) public payable returns (uint256);


    function conversionWhitelist() public view returns (IWhitelist) {this;}

    function conversionFee() public view returns (uint32) {this;}

    function maxConversionFee() public view returns (uint32) {this;}

    function reserveBalance(IERC20Token _reserveToken) public view returns (uint256);

    function() external payable;

    function transferAnchorOwnership(address _newOwner) public;

    function acceptAnchorOwnership() public;

    function setConversionFee(uint32 _conversionFee) public;

    function setConversionWhitelist(IWhitelist _whitelist) public;

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;

    function withdrawETH(address _to) public;

    function addReserve(IERC20Token _token, uint32 _ratio) public;


    function token() public view returns (IConverterAnchor);

    function transferTokenOwnership(address _newOwner) public;

    function acceptTokenOwnership() public;

    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool);

    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);

    function connectorTokens(uint256 _index) public view returns (IERC20Token);

    function connectorTokenCount() public view returns (uint16);

}


pragma solidity 0.4.26;

contract IConverterUpgrader {

    function upgrade(bytes32 _version) public;

    function upgrade(uint16 _version) public;

}


pragma solidity 0.4.26;

contract IBancorFormula {

    function purchaseTargetAmount(uint256 _supply,
                                  uint256 _reserveBalance,
                                  uint32 _reserveWeight,
                                  uint256 _amount)
                                  public view returns (uint256);


    function saleTargetAmount(uint256 _supply,
                              uint256 _reserveBalance,
                              uint32 _reserveWeight,
                              uint256 _amount)
                              public view returns (uint256);


    function crossReserveTargetAmount(uint256 _sourceReserveBalance,
                                      uint32 _sourceReserveWeight,
                                      uint256 _targetReserveBalance,
                                      uint32 _targetReserveWeight,
                                      uint256 _amount)
                                      public view returns (uint256);


    function fundCost(uint256 _supply,
                      uint256 _reserveBalance,
                      uint32 _reserveRatio,
                      uint256 _amount)
                      public view returns (uint256);


    function fundSupplyAmount(uint256 _supply,
                              uint256 _reserveBalance,
                              uint32 _reserveRatio,
                              uint256 _amount)
                              public view returns (uint256);


    function liquidateReserveAmount(uint256 _supply,
                                    uint256 _reserveBalance,
                                    uint32 _reserveRatio,
                                    uint256 _amount)
                                    public view returns (uint256);


    function balancedWeights(uint256 _primaryReserveStakedBalance,
                             uint256 _primaryReserveBalance,
                             uint256 _secondaryReserveBalance,
                             uint256 _reserveRateNumerator,
                             uint256 _reserveRateDenominator)
                             public view returns (uint32, uint32);

}


pragma solidity 0.4.26;


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

}


pragma solidity 0.4.26;


contract Owned is IOwned {

    address public owner;
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

    function transferOwnership(address _newOwner) public ownerOnly {

        require(_newOwner != owner, "ERR_SAME_OWNER");
        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        require(msg.sender == newOwner, "ERR_ACCESS_DENIED");
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


pragma solidity 0.4.26;

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


pragma solidity 0.4.26;

contract IContractRegistry {

    function addressOf(bytes32 _contractName) public view returns (address);


    function getAddress(bytes32 _contractName) public view returns (address);

}


pragma solidity 0.4.26;




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

    constructor(IContractRegistry _registry) internal validAddress(_registry) {
        registry = IContractRegistry(_registry);
        prevRegistry = IContractRegistry(_registry);
    }

    function updateRegistry() public {

        require(msg.sender == owner || !onlyOwnerCanUpdateRegistry, "ERR_ACCESS_DENIED");

        IContractRegistry newRegistry = IContractRegistry(addressOf(CONTRACT_REGISTRY));

        require(newRegistry != address(registry) && newRegistry != address(0), "ERR_INVALID_REGISTRY");

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


pragma solidity 0.4.26;

contract ReentrancyGuard {

    bool private locked = false;

    constructor() internal {}

    modifier protected() {

        _protected();
        locked = true;
        _;
        locked = false;
    }

    function _protected() internal view {

        require(!locked, "ERR_REENTRANCY");
    }
}


pragma solidity 0.4.26;

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


pragma solidity 0.4.26;


contract TokenHandler {

    bytes4 private constant APPROVE_FUNC_SELECTOR = bytes4(keccak256("approve(address,uint256)"));
    bytes4 private constant TRANSFER_FUNC_SELECTOR = bytes4(keccak256("transfer(address,uint256)"));
    bytes4 private constant TRANSFER_FROM_FUNC_SELECTOR = bytes4(keccak256("transferFrom(address,address,uint256)"));

    function safeApprove(IERC20Token _token, address _spender, uint256 _value) internal {

       execute(_token, abi.encodeWithSelector(APPROVE_FUNC_SELECTOR, _spender, _value));
    }

    function safeTransfer(IERC20Token _token, address _to, uint256 _value) internal {

       execute(_token, abi.encodeWithSelector(TRANSFER_FUNC_SELECTOR, _to, _value));
    }

    function safeTransferFrom(IERC20Token _token, address _from, address _to, uint256 _value) internal {

       execute(_token, abi.encodeWithSelector(TRANSFER_FROM_FUNC_SELECTOR, _from, _to, _value));
    }

    function execute(IERC20Token _token, bytes memory _data) private {

        uint256[1] memory ret = [uint256(1)];

        assembly {
            let success := call(
                gas,            // gas remaining
                _token,         // destination address
                0,              // no ether
                add(_data, 32), // input buffer (starts after the first 32 bytes in the `data` array)
                mload(_data),   // input length (loaded from the first 32 bytes in the `data` array)
                ret,            // output buffer
                32              // output length
            )
            if iszero(success) {
                revert(0, 0)
            }
        }

        require(ret[0] != 0, "ERR_TRANSFER_FAILED");
    }
}


pragma solidity 0.4.26;






contract TokenHolder is ITokenHolder, TokenHandler, Owned, Utils {

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {

        safeTransfer(_token, _to, _amount);
    }
}


pragma solidity 0.4.26;


contract IEtherToken is IERC20Token {

    function deposit() public payable;

    function withdraw(uint256 _amount) public;

    function depositTo(address _to) public payable;

    function withdrawTo(address _to, uint256 _amount) public;

}


pragma solidity 0.4.26;


contract IBancorX {

    function token() public view returns (IERC20Token) {this;}

    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount, uint256 _id) public;

    function getXTransferAmount(uint256 _xTransferId, address _for) public view returns (uint256);

}


pragma solidity 0.4.26;













contract ConverterBase is IConverter, TokenHandler, TokenHolder, ContractRegistryClient, ReentrancyGuard {

    using SafeMath for uint256;

    uint32 internal constant WEIGHT_RESOLUTION = 1000000;
    uint64 internal constant CONVERSION_FEE_RESOLUTION = 1000000;
    address internal constant ETH_RESERVE_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    struct Reserve {
        uint256 balance;    // reserve balance
        uint32 weight;      // reserve weight, represented in ppm, 1-1000000
        bool deprecated1;   // deprecated
        bool deprecated2;   // deprecated
        bool isSet;         // true if the reserve is valid, false otherwise
    }

    uint16 public constant version = 31;

    IConverterAnchor public anchor;                 // converter anchor contract
    IWhitelist public conversionWhitelist;          // whitelist contract with list of addresses that are allowed to use the converter
    IERC20Token[] public reserveTokens;             // ERC20 standard token addresses (prior version 17, use 'connectorTokens' instead)
    mapping (address => Reserve) public reserves;   // reserve token addresses -> reserve data (prior version 17, use 'connectors' instead)
    uint32 public reserveRatio = 0;                 // ratio between the reserves and the market cap, equal to the total reserve weights
    uint32 public maxConversionFee = 0;             // maximum conversion fee for the lifetime of the contract,
    uint32 public conversionFee = 0;                // current conversion fee, represented in ppm, 0...maxConversionFee
    bool public constant conversionsEnabled = true; // deprecated, backward compatibility

    event Activation(uint16 indexed _type, IConverterAnchor indexed _anchor, bool indexed _activated);

    event Conversion(
        address indexed _fromToken,
        address indexed _toToken,
        address indexed _trader,
        uint256 _amount,
        uint256 _return,
        int256 _conversionFee
    );

    event TokenRateUpdate(
        address indexed _token1,
        address indexed _token2,
        uint256 _rateN,
        uint256 _rateD
    );

    event ConversionFeeUpdate(uint32 _prevFee, uint32 _newFee);

    constructor(
        IConverterAnchor _anchor,
        IContractRegistry _registry,
        uint32 _maxConversionFee
    )
        validAddress(_anchor)
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

        require(_conversionFee <= CONVERSION_FEE_RESOLUTION, "ERR_INVALID_CONVERSION_FEE");
    }

    modifier validReserveWeight(uint32 _weight) {

        _validReserveWeight(_weight);
        _;
    }

    function _validReserveWeight(uint32 _weight) internal pure {

        require(_weight > 0 && _weight <= WEIGHT_RESOLUTION, "ERR_INVALID_RESERVE_WEIGHT");
    }

    function() external payable {
        require(reserves[ETH_RESERVE_ADDRESS].isSet, "ERR_INVALID_RESERVE"); // require(hasETHReserve(), "ERR_INVALID_RESERVE");
    }

    function withdrawETH(address _to)
        public
        protected
        ownerOnly
        validReserve(IERC20Token(ETH_RESERVE_ADDRESS))
    {

        address converterUpgrader = addressOf(CONVERTER_UPGRADER);

        require(!isActive() || owner == converterUpgrader, "ERR_ACCESS_DENIED");
        _to.transfer(address(this).balance);

        syncReserveBalance(IERC20Token(ETH_RESERVE_ADDRESS));
    }

    function isV28OrHigher() public pure returns (bool) {

        return true;
    }

    function setConversionWhitelist(IWhitelist _whitelist)
        public
        ownerOnly
        notThis(_whitelist)
    {

        conversionWhitelist = _whitelist;
    }

    function isActive() public view returns (bool) {

        return anchor.owner() == address(this);
    }

    function transferAnchorOwnership(address _newOwner)
        public
        ownerOnly
        only(CONVERTER_UPGRADER)
    {

        anchor.transferOwnership(_newOwner);
    }

    function acceptAnchorOwnership() public ownerOnly {

        require(reserveTokenCount() > 0, "ERR_INVALID_RESERVE_COUNT");
        anchor.acceptOwnership();
        syncReserveBalances();
    }

    function withdrawFromAnchor(IERC20Token _token, address _to, uint256 _amount) public ownerOnly {

        anchor.withdrawTokens(_token, _to, _amount);
    }

    function setConversionFee(uint32 _conversionFee) public ownerOnly {

        require(_conversionFee <= maxConversionFee, "ERR_INVALID_CONVERSION_FEE");
        emit ConversionFeeUpdate(conversionFee, _conversionFee);
        conversionFee = _conversionFee;
    }

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public protected ownerOnly {

        address converterUpgrader = addressOf(CONVERTER_UPGRADER);

        require(!reserves[_token].isSet || !isActive() || owner == converterUpgrader, "ERR_ACCESS_DENIED");
        super.withdrawTokens(_token, _to, _amount);

        if (reserves[_token].isSet)
            syncReserveBalance(_token);
    }

    function upgrade() public ownerOnly {

        IConverterUpgrader converterUpgrader = IConverterUpgrader(addressOf(CONVERTER_UPGRADER));

        emit Activation(converterType(), anchor, false);

        transferOwnership(converterUpgrader);
        converterUpgrader.upgrade(version);
        acceptOwnership();
    }

    function reserveTokenCount() public view returns (uint16) {

        return uint16(reserveTokens.length);
    }

    function addReserve(IERC20Token _token, uint32 _weight)
        public
        ownerOnly
        inactive
        validAddress(_token)
        notThis(_token)
        validReserveWeight(_weight)
    {

        require(_token != address(anchor) && !reserves[_token].isSet, "ERR_INVALID_RESERVE");
        require(_weight <= WEIGHT_RESOLUTION - reserveRatio, "ERR_INVALID_RESERVE_WEIGHT");
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
        view
        validReserve(_reserveToken)
        returns (uint256)
    {

        return reserves[_reserveToken].balance;
    }

    function hasETHReserve() public view returns (bool) {

        return reserves[ETH_RESERVE_ADDRESS].isSet;
    }

    function convert(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount, address _trader, address _beneficiary)
        public
        payable
        protected
        only(BANCOR_NETWORK)
        returns (uint256)
    {

        require(_sourceToken != _targetToken, "ERR_SAME_SOURCE_TARGET");

        require(conversionWhitelist == address(0) ||
                (conversionWhitelist.isWhitelisted(_trader) && conversionWhitelist.isWhitelisted(_beneficiary)),
                "ERR_NOT_WHITELISTED");

        return doConvert(_sourceToken, _targetToken, _amount, _trader, _beneficiary);
    }

    function doConvert(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount, address _trader, address _beneficiary) internal returns (uint256);


    function calculateFee(uint256 _targetAmount) internal view returns (uint256) {

        return _targetAmount.mul(conversionFee).div(CONVERSION_FEE_RESOLUTION);
    }

    function syncReserveBalance(IERC20Token _reserveToken) internal validReserve(_reserveToken) {

        if (_reserveToken == ETH_RESERVE_ADDRESS)
            reserves[_reserveToken].balance = address(this).balance;
        else
            reserves[_reserveToken].balance = _reserveToken.balanceOf(this);
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

    function token() public view returns (IConverterAnchor) {

        return anchor;
    }

    function transferTokenOwnership(address _newOwner) public ownerOnly {

        transferAnchorOwnership(_newOwner);
    }

    function acceptTokenOwnership() public ownerOnly {

        acceptAnchorOwnership();
    }

    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool) {

        Reserve memory reserve = reserves[_address];
        return(reserve.balance, reserve.weight, false, false, reserve.isSet);
    }

    function connectorTokens(uint256 _index) public view returns (IERC20Token) {

        return ConverterBase.reserveTokens[_index];
    }

    function connectorTokenCount() public view returns (uint16) {

        return reserveTokenCount();
    }

    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256) {

        return reserveBalance(_connectorToken);
    }

    function getReturn(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount) public view returns (uint256, uint256) {

        return targetAmountAndFee(_sourceToken, _targetToken, _amount);
    }
}


pragma solidity 0.4.26;


contract LiquidityPoolConverter is ConverterBase {

    event LiquidityAdded(
        address indexed _provider,
        address indexed _reserveToken,
        uint256 _amount,
        uint256 _newBalance,
        uint256 _newSupply
    );

    event LiquidityRemoved(
        address indexed _provider,
        address indexed _reserveToken,
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

    function acceptAnchorOwnership() public {

        require(reserveTokenCount() > 1, "ERR_INVALID_RESERVE_COUNT");
        super.acceptAnchorOwnership();
    }
}


pragma solidity 0.4.26;




contract ISmartToken is IConverterAnchor, IERC20Token {

    function disableTransfers(bool _disable) public;

    function issue(address _to, uint256 _amount) public;

    function destroy(address _from, uint256 _amount) public;

}


pragma solidity 0.4.26;



contract LiquidityPoolV1Converter is LiquidityPoolConverter {

    IEtherToken internal etherToken = IEtherToken(0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315);

    event PriceDataUpdate(
        address indexed _connectorToken,
        uint256 _tokenSupply,
        uint256 _connectorBalance,
        uint32 _connectorWeight
    );

    constructor(
        ISmartToken _token,
        IContractRegistry _registry,
        uint32 _maxConversionFee
    )
        LiquidityPoolConverter(_token, _registry, _maxConversionFee)
        public
    {
    }

    function converterType() public pure returns (uint16) {

        return 1;
    }

    function acceptAnchorOwnership() public ownerOnly {

        super.acceptAnchorOwnership();

        emit Activation(converterType(), anchor, true);
    }

    function targetAmountAndFee(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount)
        public
        view
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

    function doConvert(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount, address _trader, address _beneficiary)
        internal
        returns (uint256)
    {

        (uint256 amount, uint256 fee) = targetAmountAndFee(_sourceToken, _targetToken, _amount);

        require(amount != 0, "ERR_ZERO_TARGET_AMOUNT");

        uint256 targetReserveBalance = reserveBalance(_targetToken);
        assert(amount < targetReserveBalance);

        if (_sourceToken == ETH_RESERVE_ADDRESS)
            require(msg.value == _amount, "ERR_ETH_AMOUNT_MISMATCH");
        else
            require(msg.value == 0 && _sourceToken.balanceOf(this).sub(reserveBalance(_sourceToken)) >= _amount, "ERR_INVALID_AMOUNT");

        syncReserveBalance(_sourceToken);
        reserves[_targetToken].balance = reserves[_targetToken].balance.sub(amount);

        if (_targetToken == ETH_RESERVE_ADDRESS)
            _beneficiary.transfer(amount);
        else
            safeTransfer(_targetToken, _beneficiary, amount);

        dispatchConversionEvent(_sourceToken, _targetToken, _trader, _amount, amount, fee);

        dispatchRateEvents(_sourceToken, _targetToken);

        return amount;
    }

    function addLiquidity(IERC20Token[] memory _reserveTokens, uint256[] memory _reserveAmounts, uint256 _minReturn)
        public
        payable
        protected
        active
    {

        verifyLiquidityInput(_reserveTokens, _reserveAmounts, _minReturn);

        for (uint256 i = 0; i < _reserveTokens.length; i++)
            if (_reserveTokens[i] == ETH_RESERVE_ADDRESS)
                require(_reserveAmounts[i] == msg.value, "ERR_ETH_AMOUNT_MISMATCH");

        if (msg.value > 0)
            require(reserves[ETH_RESERVE_ADDRESS].isSet, "ERR_NO_ETH_RESERVE");

        uint256 totalSupply = ISmartToken(anchor).totalSupply();

        uint256 amount = addLiquidityToPool(_reserveTokens, _reserveAmounts, totalSupply);

        require(amount >= _minReturn, "ERR_RETURN_TOO_LOW");

        ISmartToken(anchor).issue(msg.sender, amount);
    }

    function removeLiquidity(uint256 _amount, IERC20Token[] memory _reserveTokens, uint256[] memory _reserveMinReturnAmounts)
        public
        protected
        active
    {

        verifyLiquidityInput(_reserveTokens, _reserveMinReturnAmounts, _amount);

        uint256 totalSupply = ISmartToken(anchor).totalSupply();

        ISmartToken(anchor).destroy(msg.sender, _amount);

        removeLiquidityFromPool(_reserveTokens, _reserveMinReturnAmounts, totalSupply, _amount);
    }

    function fund(uint256 _amount) public payable protected {

        syncReserveBalances();
        reserves[ETH_RESERVE_ADDRESS].balance = reserves[ETH_RESERVE_ADDRESS].balance.sub(msg.value);

        uint256 supply = ISmartToken(anchor).totalSupply();
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
                    safeTransferFrom(etherToken, msg.sender, this, reserveAmount);
                    etherToken.withdraw(reserveAmount);
                }
            }
            else {
                safeTransferFrom(reserveToken, msg.sender, this, reserveAmount);
            }

            uint256 newReserveBalance = rsvBalance.add(reserveAmount);
            reserves[reserveToken].balance = newReserveBalance;

            uint256 newPoolTokenSupply = supply.add(_amount);

            emit LiquidityAdded(msg.sender, reserveToken, reserveAmount, newReserveBalance, newPoolTokenSupply);

            uint32 reserveWeight = reserves[reserveToken].weight;
            dispatchPoolTokenRateEvent(newPoolTokenSupply, reserveToken, newReserveBalance, reserveWeight);
        }

        ISmartToken(anchor).issue(msg.sender, _amount);
    }

    function liquidate(uint256 _amount) public protected {

        require(_amount > 0, "ERR_ZERO_AMOUNT");

        uint256 totalSupply = ISmartToken(anchor).totalSupply();
        ISmartToken(anchor).destroy(msg.sender, _amount);

        uint256[] memory reserveMinReturnAmounts = new uint256[](reserveTokens.length);
        for (uint256 i = 0; i < reserveMinReturnAmounts.length; i++)
            reserveMinReturnAmounts[i] = 1;

        removeLiquidityFromPool(reserveTokens, reserveMinReturnAmounts, totalSupply, _amount);
    }

    function verifyLiquidityInput(IERC20Token[] memory _reserveTokens, uint256[] memory _reserveAmounts, uint256 _amount) private view {

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

        uint256 amount = geometricMean(_reserveAmounts);

        for (uint256 i = 0; i < _reserveTokens.length; i++) {
            if (_reserveTokens[i] != ETH_RESERVE_ADDRESS) // ETH has already been transferred as part of the transaction
                safeTransferFrom(_reserveTokens[i], msg.sender, this, _reserveAmounts[i]);

            reserves[_reserveTokens[i]].balance = _reserveAmounts[i];

            emit LiquidityAdded(msg.sender, _reserveTokens[i], _reserveAmounts[i], _reserveAmounts[i], amount);

            uint32 reserveWeight = reserves[_reserveTokens[i]].weight;
            dispatchPoolTokenRateEvent(amount, _reserveTokens[i], _reserveAmounts[i], reserveWeight);
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
                safeTransferFrom(reserveToken, msg.sender, this, reserveAmount);
            else if (_reserveAmounts[i] > reserveAmount) // transfer the extra amount of ETH back to the user
                msg.sender.transfer(_reserveAmounts[i] - reserveAmount);

            uint256 newReserveBalance = rsvBalance.add(reserveAmount);
            reserves[reserveToken].balance = newReserveBalance;

            emit LiquidityAdded(msg.sender, reserveToken, reserveAmount, newReserveBalance, newPoolTokenSupply);

            uint32 reserveWeight = reserves[_reserveTokens[i]].weight;
            dispatchPoolTokenRateEvent(newPoolTokenSupply, _reserveTokens[i], newReserveBalance, reserveWeight);
        }

        return amount;
    }

    function removeLiquidityFromPool(IERC20Token[] memory _reserveTokens, uint256[] memory _reserveMinReturnAmounts, uint256 _totalSupply, uint256 _amount)
        private
    {

        syncReserveBalances();

        IBancorFormula formula = IBancorFormula(addressOf(BANCOR_FORMULA));
        uint256 newPoolTokenSupply = _totalSupply.sub(_amount);

        for (uint256 i = 0; i < _reserveTokens.length; i++) {
            IERC20Token reserveToken = _reserveTokens[i];
            uint256 rsvBalance = reserves[reserveToken].balance;
            uint256 reserveAmount = formula.liquidateReserveAmount(_totalSupply, rsvBalance, reserveRatio, _amount);
            require(reserveAmount >= _reserveMinReturnAmounts[i], "ERR_ZERO_TARGET_AMOUNT");

            uint256 newReserveBalance = rsvBalance.sub(reserveAmount);
            reserves[reserveToken].balance = newReserveBalance;

            if (reserveToken == ETH_RESERVE_ADDRESS)
                msg.sender.transfer(reserveAmount);
            else
                safeTransfer(reserveToken, msg.sender, reserveAmount);

            emit LiquidityRemoved(msg.sender, reserveToken, reserveAmount, newReserveBalance, newPoolTokenSupply);

            uint32 reserveWeight = reserves[reserveToken].weight;
            dispatchPoolTokenRateEvent(newPoolTokenSupply, reserveToken, newReserveBalance, reserveWeight);
        }
    }

    function getMinShare(IBancorFormula formula, uint256 _totalSupply, IERC20Token[] memory _reserveTokens, uint256[] memory _reserveAmounts) private view returns (uint256) {

        uint256 minIndex = 0;
        for (uint256 i = 1; i < _reserveTokens.length; i++) {
            if (_reserveAmounts[i].mul(reserves[_reserveTokens[minIndex]].balance) < _reserveAmounts[minIndex].mul(reserves[_reserveTokens[i]].balance))
                minIndex = i;
        }
        return formula.fundSupplyAmount(_totalSupply, reserves[_reserveTokens[minIndex]].balance, reserveRatio, _reserveAmounts[minIndex]);
    }

    function decimalLength(uint256 _x) public pure returns (uint256) {

        uint256 y = 0;
        for (uint256 x = _x; x > 0; x /= 10)
            y++;
        return y;
    }

    function roundDiv(uint256 _n, uint256 _d) public pure returns (uint256) {

        return (_n + _d / 2) / _d;
    }

    function geometricMean(uint256[] memory _values) public pure returns (uint256) {

        uint256 numOfDigits = 0;
        uint256 length = _values.length;
        for (uint256 i = 0; i < length; i++)
            numOfDigits += decimalLength(_values[i]);
        return uint256(10) ** (roundDiv(numOfDigits, length) - 1);
    }

    function dispatchRateEvents(IERC20Token _sourceToken, IERC20Token _targetToken) private {

        uint256 poolTokenSupply = ISmartToken(anchor).totalSupply();
        uint256 sourceReserveBalance = reserveBalance(_sourceToken);
        uint256 targetReserveBalance = reserveBalance(_targetToken);
        uint32 sourceReserveWeight = reserves[_sourceToken].weight;
        uint32 targetReserveWeight = reserves[_targetToken].weight;

        uint256 rateN = targetReserveBalance.mul(sourceReserveWeight);
        uint256 rateD = sourceReserveBalance.mul(targetReserveWeight);
        emit TokenRateUpdate(_sourceToken, _targetToken, rateN, rateD);

        dispatchPoolTokenRateEvent(poolTokenSupply, _sourceToken, sourceReserveBalance, sourceReserveWeight);
        dispatchPoolTokenRateEvent(poolTokenSupply, _targetToken, targetReserveBalance, targetReserveWeight);

        emit PriceDataUpdate(_sourceToken, poolTokenSupply, sourceReserveBalance, sourceReserveWeight);
        emit PriceDataUpdate(_targetToken, poolTokenSupply, targetReserveBalance, targetReserveWeight);
    }

    function dispatchPoolTokenRateEvent(uint256 _poolTokenSupply, IERC20Token _reserveToken, uint256 _reserveBalance, uint32 _reserveWeight) private {

        emit TokenRateUpdate(anchor, _reserveToken, _reserveBalance.mul(WEIGHT_RESOLUTION), _poolTokenSupply.mul(_reserveWeight));
    }
}