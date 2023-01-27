

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

contract ITypedConverterCustomFactory {

    function converterType() public pure returns (uint16);

}


pragma solidity 0.4.26;

contract IContractRegistry {

    function addressOf(bytes32 _contractName) public view returns (address);


    function getAddress(bytes32 _contractName) public view returns (address);

}


pragma solidity 0.4.26;





contract IConverterFactory {

    function createAnchor(uint16 _type, string _name, string _symbol, uint8 _decimals) public returns (IConverterAnchor);

    function createConverter(uint16 _type, IConverterAnchor _anchor, IContractRegistry _registry, uint32 _maxConversionFee) public returns (IConverter);


    function customFactories(uint16 _type) public view returns (ITypedConverterCustomFactory) { _type; this; }

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


contract IEtherToken is IERC20Token {

    function deposit() public payable;

    function withdraw(uint256 _amount) public;

    function depositTo(address _to) public payable;

    function withdrawTo(address _to, uint256 _amount) public;

}


pragma solidity 0.4.26;

interface IChainlinkPriceOracle {

    function latestAnswer() external view returns (int256);

    function latestTimestamp() external view returns (uint256);

}


pragma solidity 0.4.26;



contract IPriceOracle {

    function latestRate(IERC20Token _tokenA, IERC20Token _tokenB) public view returns (uint256, uint256);

    function lastUpdateTime() public view returns (uint256);

    function latestRateAndUpdateTime(IERC20Token _tokenA, IERC20Token _tokenB) public view returns (uint256, uint256, uint256);


    function tokenAOracle() public view returns (IChainlinkPriceOracle) {this;}

    function tokenBOracle() public view returns (IChainlinkPriceOracle) {this;}

}


pragma solidity 0.4.26;



contract ILiquidityPoolV2Converter {

    function reserveStakedBalance(IERC20Token _reserveToken) public view returns (uint256);

    function setReserveStakedBalance(IERC20Token _reserveToken, uint256 _balance) public;


    function primaryReserveToken() public view returns (IERC20Token);


    function priceOracle() public view returns (IPriceOracle);


    function activate(IERC20Token _primaryReserveToken, IChainlinkPriceOracle _primaryReserveOracle, IChainlinkPriceOracle _secondaryReserveOracle) public;

}


pragma solidity 0.4.26;








contract ConverterUpgrader is IConverterUpgrader, ContractRegistryClient {

    address private constant ETH_RESERVE_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    IEtherToken public etherToken;

    event ConverterOwned(address indexed _converter, address indexed _owner);

    event ConverterUpgrade(address indexed _oldConverter, address indexed _newConverter);

    constructor(IContractRegistry _registry, IEtherToken _etherToken) ContractRegistryClient(_registry) public {
        etherToken = _etherToken;
    }

    function upgrade(bytes32 _version) public {

        upgradeOld(IConverter(msg.sender), _version);
    }

    function upgrade(uint16 _version) public {

        upgradeOld(IConverter(msg.sender), bytes32(_version));
    }

    function upgradeOld(IConverter _converter, bytes32 _version) public {

        _version;
        IConverter converter = IConverter(_converter);
        address prevOwner = converter.owner();
        acceptConverterOwnership(converter);
        IConverter newConverter = createConverter(converter);
        copyReserves(converter, newConverter);
        copyConversionFee(converter, newConverter);
        transferReserveBalances(converter, newConverter);
        IConverterAnchor anchor = converter.token();

        bool activate = isV28OrHigherConverter(converter) && converter.isActive();

        if (anchor.owner() == address(converter)) {
            converter.transferTokenOwnership(newConverter);
            newConverter.acceptAnchorOwnership();
        }

        handleTypeSpecificData(converter, newConverter, activate);

        converter.transferOwnership(prevOwner);
        newConverter.transferOwnership(prevOwner);

        emit ConverterUpgrade(address(converter), address(newConverter));
    }

    function acceptConverterOwnership(IConverter _oldConverter) private {

        _oldConverter.acceptOwnership();
        emit ConverterOwned(_oldConverter, this);
    }

    function createConverter(IConverter _oldConverter) private returns (IConverter) {

        IConverterAnchor anchor = _oldConverter.token();
        uint32 maxConversionFee = _oldConverter.maxConversionFee();
        uint16 reserveTokenCount = _oldConverter.connectorTokenCount();

        uint16 newType = 0;
        if (isV28OrHigherConverter(_oldConverter))
            newType = _oldConverter.converterType();
        else if (reserveTokenCount > 1)
            newType = 1;

        IConverterFactory converterFactory = IConverterFactory(addressOf(CONVERTER_FACTORY));
        IConverter converter = converterFactory.createConverter(newType, anchor, registry, maxConversionFee);

        converter.acceptOwnership();
        return converter;
    }

    function copyReserves(IConverter _oldConverter, IConverter _newConverter) private {

        uint16 reserveTokenCount = _oldConverter.connectorTokenCount();

        for (uint16 i = 0; i < reserveTokenCount; i++) {
            address reserveAddress = _oldConverter.connectorTokens(i);
            (, uint32 weight, , , ) = _oldConverter.connectors(reserveAddress);

            if (reserveAddress == ETH_RESERVE_ADDRESS) {
                _newConverter.addReserve(IERC20Token(ETH_RESERVE_ADDRESS), weight);
            }
            else if (reserveAddress == address(etherToken)) {
                _newConverter.addReserve(IERC20Token(ETH_RESERVE_ADDRESS), weight);
            }
            else {
                _newConverter.addReserve(IERC20Token(reserveAddress), weight);
            }
        }
    }

    function copyConversionFee(IConverter _oldConverter, IConverter _newConverter) private {

        uint32 conversionFee = _oldConverter.conversionFee();
        _newConverter.setConversionFee(conversionFee);
    }

    function transferReserveBalances(IConverter _oldConverter, IConverter _newConverter) private {

        uint256 reserveBalance;
        uint16 reserveTokenCount = _oldConverter.connectorTokenCount();

        for (uint16 i = 0; i < reserveTokenCount; i++) {
            address reserveAddress = _oldConverter.connectorTokens(i);
            if (reserveAddress == ETH_RESERVE_ADDRESS) {
                _oldConverter.withdrawETH(address(_newConverter));
            }
            else if (reserveAddress == address(etherToken)) {
                reserveBalance = etherToken.balanceOf(_oldConverter);
                _oldConverter.withdrawTokens(etherToken, address(this), reserveBalance);
                etherToken.withdrawTo(address(_newConverter), reserveBalance);
            }
            else {
                IERC20Token connector = IERC20Token(reserveAddress);
                reserveBalance = connector.balanceOf(_oldConverter);
                _oldConverter.withdrawTokens(connector, address(_newConverter), reserveBalance);
            }
        }
    }

    function handleTypeSpecificData(IConverter _oldConverter, IConverter _newConverter, bool _activate) private {

        if (!isV28OrHigherConverter(_oldConverter))
            return;

        uint16 converterType = _oldConverter.converterType();
        if (converterType == 2) {
            uint16 reserveTokenCount = _oldConverter.connectorTokenCount();
            for (uint16 i = 0; i < reserveTokenCount; i++) {
                IERC20Token reserveTokenAddress = _oldConverter.connectorTokens(i);
                uint256 balance = ILiquidityPoolV2Converter(_oldConverter).reserveStakedBalance(reserveTokenAddress);
                ILiquidityPoolV2Converter(_newConverter).setReserveStakedBalance(reserveTokenAddress, balance);
            }

            if (!_activate) {
                return;
            }

            IERC20Token primaryReserveToken = ILiquidityPoolV2Converter(_oldConverter).primaryReserveToken();

            IPriceOracle priceOracle = ILiquidityPoolV2Converter(_oldConverter).priceOracle();
            IChainlinkPriceOracle oracleA = priceOracle.tokenAOracle();
            IChainlinkPriceOracle oracleB = priceOracle.tokenBOracle();

            ILiquidityPoolV2Converter(_newConverter).activate(primaryReserveToken, oracleA, oracleB);
        }
    }

    bytes4 private constant IS_V28_OR_HIGHER_FUNC_SELECTOR = bytes4(keccak256("isV28OrHigher()"));

    function isV28OrHigherConverter(IConverter _converter) internal view returns (bool) {

        bool success;
        uint256[1] memory ret;
        bytes memory data = abi.encodeWithSelector(IS_V28_OR_HIGHER_FUNC_SELECTOR);

        assembly {
            success := staticcall(
                5000,          // isV28OrHigher consumes 190 gas, but just for extra safety
                _converter,    // destination address
                add(data, 32), // input buffer (starts after the first 32 bytes in the `data` array)
                mload(data),   // input length (loaded from the first 32 bytes in the `data` array)
                ret,           // output buffer
                32             // output length
            )
        }

        return success && ret[0] != 0;
    }
}