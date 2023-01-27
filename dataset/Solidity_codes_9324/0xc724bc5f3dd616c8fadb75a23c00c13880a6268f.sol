

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

contract IWhitelist {

    function isWhitelisted(address _address) public view returns (bool);

}


pragma solidity 0.4.26;



contract IBancorConverter {

    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256, uint256);

    function convert2(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public returns (uint256);

    function quickConvert2(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _affiliateAccount, uint256 _affiliateFee) public payable returns (uint256);

    function conversionWhitelist() public view returns (IWhitelist) {this;}

    function conversionFee() public view returns (uint32) {this;}

    function reserves(address _address) public view returns (uint256, uint32, bool, bool, bool) {_address; this;}

    function getReserveBalance(IERC20Token _reserveToken) public view returns (uint256);

    function reserveTokens(uint256 _index) public view returns (IERC20Token) {_index; this;}


    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);

    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);

    function quickConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);

    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool);

    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);

    function connectorTokens(uint256 _index) public view returns (IERC20Token);

    function connectorTokenCount() public view returns (uint16);

}


pragma solidity 0.4.26;


contract IBancorConverterUpgrader {

    function upgrade(bytes32 _version) public;

    function upgrade(uint16 _version) public;

}


pragma solidity 0.4.26;

contract IOwned {

    function owner() public view returns (address) {this;}


    function transferOwnership(address _newOwner) public;

    function acceptOwnership() public;

}


pragma solidity 0.4.26;



contract ISmartToken is IOwned, IERC20Token {

    function disableTransfers(bool _disable) public;

    function issue(address _to, uint256 _amount) public;

    function destroy(address _from, uint256 _amount) public;

}


pragma solidity 0.4.26;

contract IContractRegistry {

    function addressOf(bytes32 _contractName) public view returns (address);


    function getAddress(bytes32 _contractName) public view returns (address);

}


pragma solidity 0.4.26;




contract IBancorConverterFactory {

    function createConverter(
        ISmartToken _token,
        IContractRegistry _registry,
        uint32 _maxConversionFee,
        IERC20Token _reserveToken,
        uint32 _reserveRatio
    )
    public returns (address);

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


pragma solidity 0.4.26;

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


pragma solidity 0.4.26;




contract ContractRegistryClient is Owned, Utils {

    bytes32 internal constant CONTRACT_FEATURES = "ContractFeatures";
    bytes32 internal constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 internal constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 internal constant BANCOR_FORMULA = "BancorFormula";
    bytes32 internal constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";
    bytes32 internal constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 internal constant BANCOR_CONVERTER_REGISTRY = "BancorConverterRegistry";
    bytes32 internal constant BANCOR_CONVERTER_REGISTRY_DATA = "BancorConverterRegistryData";
    bytes32 internal constant BNT_TOKEN = "BNTToken";
    bytes32 internal constant BANCOR_X = "BancorX";
    bytes32 internal constant BANCOR_X_UPGRADER = "BancorXUpgrader";

    IContractRegistry public registry;      // address of the current contract-registry
    IContractRegistry public prevRegistry;  // address of the previous contract-registry
    bool public onlyOwnerCanUpdateRegistry; // only an owner can update the contract-registry

    modifier only(bytes32 _contractName) {

        require(msg.sender == addressOf(_contractName));
        _;
    }

    constructor(IContractRegistry _registry) internal validAddress(_registry) {
        registry = IContractRegistry(_registry);
        prevRegistry = IContractRegistry(_registry);
    }

    function updateRegistry() public {

        require(msg.sender == owner || !onlyOwnerCanUpdateRegistry);

        address newRegistry = addressOf(CONTRACT_REGISTRY);

        require(newRegistry != address(registry) && newRegistry != address(0));

        require(IContractRegistry(newRegistry).addressOf(CONTRACT_REGISTRY) != address(0));

        prevRegistry = registry;

        registry = IContractRegistry(newRegistry);
    }

    function restoreRegistry() public ownerOnly {

        registry = prevRegistry;
    }

    function restrictRegistryUpdate(bool _onlyOwnerCanUpdateRegistry) ownerOnly public {

        onlyOwnerCanUpdateRegistry = _onlyOwnerCanUpdateRegistry;
    }

    function addressOf(bytes32 _contractName) internal view returns (address) {

        return registry.addressOf(_contractName);
    }
}


pragma solidity 0.4.26;

contract IContractFeatures {

    function isSupported(address _contract, uint256 _features) public view returns (bool);

    function enableFeatures(uint256 _features, bool _enable) public;

}


pragma solidity 0.4.26;

contract FeatureIds {

    uint256 public constant CONVERTER_CONVERSION_WHITELIST = 1 << 0;
}


pragma solidity 0.4.26;








contract IBancorConverterExtended is IBancorConverter, IOwned {

    function token() public view returns (ISmartToken) {this;}

    function maxConversionFee() public view returns (uint32) {this;}

    function conversionFee() public view returns (uint32) {this;}

    function connectorTokenCount() public view returns (uint16);

    function reserveTokenCount() public view returns (uint16);

    function connectorTokens(uint256 _index) public view returns (IERC20Token) {_index; this;}

    function reserveTokens(uint256 _index) public view returns (IERC20Token) {_index; this;}

    function setConversionWhitelist(IWhitelist _whitelist) public;

    function transferTokenOwnership(address _newOwner) public;

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;

    function acceptTokenOwnership() public;

    function setConversionFee(uint32 _conversionFee) public;

    function addConnector(IERC20Token _token, uint32 _weight, bool _enableVirtualBalance) public;

    function updateConnector(IERC20Token _connectorToken, uint32 _weight, bool _enableVirtualBalance, uint256 _virtualBalance) public;

}

contract BancorConverterUpgrader is IBancorConverterUpgrader, ContractRegistryClient, FeatureIds {

    string public version = '0.3';

    event ConverterOwned(address indexed _converter, address indexed _owner);

    event ConverterUpgrade(address indexed _oldConverter, address indexed _newConverter);

    constructor(IContractRegistry _registry) ContractRegistryClient(_registry) public {
    }

    function upgrade(bytes32 _version) public {

        upgradeOld(IBancorConverter(msg.sender), _version);
    }

    function upgrade(uint16 _version) public {

        upgradeOld(IBancorConverter(msg.sender), bytes32(_version));
    }

    function upgradeOld(IBancorConverter _converter, bytes32 _version) public {

        _version;
        IBancorConverterExtended converter = IBancorConverterExtended(_converter);
        address prevOwner = converter.owner();
        acceptConverterOwnership(converter);
        IBancorConverterExtended newConverter = createConverter(converter);
        copyConnectors(converter, newConverter);
        copyConversionFee(converter, newConverter);
        transferConnectorsBalances(converter, newConverter);                
        ISmartToken token = converter.token();

        if (token.owner() == address(converter)) {
            converter.transferTokenOwnership(newConverter);
            newConverter.acceptTokenOwnership();
        }

        converter.transferOwnership(prevOwner);
        newConverter.transferOwnership(prevOwner);

        emit ConverterUpgrade(address(converter), address(newConverter));
    }

    function acceptConverterOwnership(IBancorConverterExtended _oldConverter) private {

        _oldConverter.acceptOwnership();
        emit ConverterOwned(_oldConverter, this);
    }

    function createConverter(IBancorConverterExtended _oldConverter) private returns(IBancorConverterExtended) {

        IWhitelist whitelist;
        ISmartToken token = _oldConverter.token();
        uint32 maxConversionFee = _oldConverter.maxConversionFee();

        IBancorConverterFactory converterFactory = IBancorConverterFactory(addressOf(BANCOR_CONVERTER_FACTORY));
        address converterAddress = converterFactory.createConverter(
            token,
            registry,
            maxConversionFee,
            IERC20Token(address(0)),
            0
        );

        IBancorConverterExtended converter = IBancorConverterExtended(converterAddress);
        converter.acceptOwnership();

        IContractFeatures features = IContractFeatures(addressOf(CONTRACT_FEATURES));

        if (features.isSupported(_oldConverter, FeatureIds.CONVERTER_CONVERSION_WHITELIST)) {
            whitelist = _oldConverter.conversionWhitelist();
            if (whitelist != address(0))
                converter.setConversionWhitelist(whitelist);
        }

        return converter;
    }

    function copyConnectors(IBancorConverterExtended _oldConverter, IBancorConverterExtended _newConverter)
        private
    {

        uint256 virtualBalance;
        uint32 weight;
        bool isVirtualBalanceEnabled;
        uint16 connectorTokenCount = _oldConverter.connectorTokenCount();

        for (uint16 i = 0; i < connectorTokenCount; i++) {
            address connectorAddress = _oldConverter.connectorTokens(i);
            (virtualBalance, weight, isVirtualBalanceEnabled, , ) = _oldConverter.connectors(connectorAddress);

            IERC20Token connectorToken = IERC20Token(connectorAddress);
            _newConverter.addConnector(connectorToken, weight, isVirtualBalanceEnabled);

            if (isVirtualBalanceEnabled)
                _newConverter.updateConnector(connectorToken, weight, isVirtualBalanceEnabled, virtualBalance);
        }
    }

    function copyConversionFee(IBancorConverterExtended _oldConverter, IBancorConverterExtended _newConverter) private {

        uint32 conversionFee = _oldConverter.conversionFee();
        _newConverter.setConversionFee(conversionFee);
    }

    function transferConnectorsBalances(IBancorConverterExtended _oldConverter, IBancorConverterExtended _newConverter)
        private
    {

        uint256 connectorBalance;
        uint16 connectorTokenCount = _oldConverter.connectorTokenCount();

        for (uint16 i = 0; i < connectorTokenCount; i++) {
            address connectorAddress = _oldConverter.connectorTokens(i);
            IERC20Token connector = IERC20Token(connectorAddress);
            connectorBalance = connector.balanceOf(_oldConverter);
            _oldConverter.withdrawTokens(connector, address(_newConverter), connectorBalance);
        }
    }
}