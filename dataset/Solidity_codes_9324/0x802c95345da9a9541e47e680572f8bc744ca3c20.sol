

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




contract ISmartToken is IConverterAnchor, IERC20Token {

    function disableTransfers(bool _disable) public;

    function issue(address _to, uint256 _amount) public;

    function destroy(address _from, uint256 _amount) public;

}


pragma solidity 0.4.26;



contract IPoolTokensContainer is IConverterAnchor {

    function poolTokens() public view returns (ISmartToken[]);

    function createToken() public returns (ISmartToken);

    function mint(ISmartToken _token, address _to, uint256 _amount) public;

    function burn(ISmartToken _token, address _from, uint256 _amount) public;

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




contract ERC20Token is IERC20Token, Utils {

    using SafeMath for uint256;


    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
        require(bytes(_name).length > 0, "ERR_INVALID_NAME");
        require(bytes(_symbol).length > 0, "ERR_INVALID_SYMBOL");

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
    }

    function transfer(address _to, uint256 _value)
        public
        validAddress(_to)
        returns (bool success)
    {

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        validAddress(_from)
        validAddress(_to)
        returns (bool success)
    {

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        validAddress(_spender)
        returns (bool success)
    {

        require(_value == 0 || allowance[msg.sender][_spender] == 0, "ERR_INVALID_AMOUNT");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}


pragma solidity 0.4.26;





contract SmartToken is ISmartToken, Owned, ERC20Token, TokenHolder {

    using SafeMath for uint256;

    uint16 public constant version = 4;

    bool public transfersEnabled = true;    // true if transfer/transferFrom are enabled, false otherwise

    event Issuance(uint256 _amount);

    event Destruction(uint256 _amount);

    constructor(string _name, string _symbol, uint8 _decimals)
        public
        ERC20Token(_name, _symbol, _decimals, 0)
    {
    }

    modifier transfersAllowed {

        _transfersAllowed();
        _;
    }

    function _transfersAllowed() internal view {

        require(transfersEnabled, "ERR_TRANSFERS_DISABLED");
    }

    function disableTransfers(bool _disable) public ownerOnly {

        transfersEnabled = !_disable;
    }

    function issue(address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_to)
        notThis(_to)
    {

        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);

        emit Issuance(_amount);
        emit Transfer(address(0), _to, _amount);
    }

    function destroy(address _from, uint256 _amount) public ownerOnly {

        balanceOf[_from] = balanceOf[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);

        emit Transfer(_from, address(0), _amount);
        emit Destruction(_amount);
    }


    function transfer(address _to, uint256 _value) public transfersAllowed returns (bool success) {

        assert(super.transfer(_to, _value));
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed returns (bool success) {

        assert(super.transferFrom(_from, _to, _value));
        return true;
    }
}


pragma solidity 0.4.26;





contract PoolTokensContainer is IPoolTokensContainer, Owned, TokenHolder {

    uint8 internal constant MAX_POOL_TOKENS = 5;    // maximum pool tokens in the container

    string public name;                 // pool name
    string public symbol;               // pool symbol
    uint8 public decimals;              // underlying pool tokens decimals
    ISmartToken[] private _poolTokens;  // underlying pool tokens

    constructor(string _name, string _symbol, uint8 _decimals) public {
        require(bytes(_name).length > 0, "ERR_INVALID_NAME");
        require(bytes(_symbol).length > 0, "ERR_INVALID_SYMBOL");

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function poolTokens() public view returns (ISmartToken[] memory) {

        return _poolTokens;
    }

    function createToken() public ownerOnly returns (ISmartToken) {

        require(_poolTokens.length < MAX_POOL_TOKENS, "ERR_MAX_LIMIT_REACHED");

        string memory poolName = concatStrDigit(name, uint8(_poolTokens.length + 1));
        string memory poolSymbol = concatStrDigit(symbol, uint8(_poolTokens.length + 1));

        SmartToken token = new SmartToken(poolName, poolSymbol, decimals);
        _poolTokens.push(token);
        return token;
    }

    function mint(ISmartToken _token, address _to, uint256 _amount) public ownerOnly {

        _token.issue(_to, _amount);
    }

    function burn(ISmartToken _token, address _from, uint256 _amount) public ownerOnly {

        _token.destroy(_from, _amount);
    }

    function concatStrDigit(string _str, uint8 _digit) private pure returns (string) {

        return string(abi.encodePacked(_str, uint8(bytes1('0')) + _digit));
    }
}


pragma solidity 0.4.26;

contract ITypedConverterCustomFactory {

    function converterType() public pure returns (uint16);

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





contract PriceOracle is IPriceOracle, Utils {

    using SafeMath for uint256;

    address private constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    uint8 private constant ETH_DECIMALS = 18;

    IERC20Token public tokenA;                  // token A the oracle supports
    IERC20Token public tokenB;                  // token B the oracle supports
    mapping (address => uint8) public tokenDecimals; // token -> token decimals

    IChainlinkPriceOracle public tokenAOracle;  // token A chainlink price oracle
    IChainlinkPriceOracle public tokenBOracle;  // token B chainlink price oracle
    mapping (address => IChainlinkPriceOracle) public tokensToOracles;  // token -> price oracle for easier access

    constructor(IERC20Token _tokenA, IERC20Token _tokenB, IChainlinkPriceOracle _tokenAOracle, IChainlinkPriceOracle _tokenBOracle)
        public
        validUniqueAddresses(_tokenA, _tokenB)
        validUniqueAddresses(_tokenAOracle, _tokenBOracle)
    {
        tokenA = _tokenA;
        tokenB = _tokenB;
        tokenDecimals[_tokenA] = decimals(_tokenA);
        tokenDecimals[_tokenB] = decimals(_tokenB);

        tokenAOracle = _tokenAOracle;
        tokenBOracle = _tokenBOracle;
        tokensToOracles[_tokenA] = _tokenAOracle;
        tokensToOracles[_tokenB] = _tokenBOracle;
    }

    modifier validUniqueAddresses(address _address1, address _address2) {

        _validUniqueAddresses(_address1, _address2);
        _;
    }

    function _validUniqueAddresses(address _address1, address _address2) internal pure {

        _validAddress(_address1);
        _validAddress(_address2);
        require(_address1 != _address2, "ERR_SAME_ADDRESS");
    }

    modifier supportedTokens(IERC20Token _tokenA, IERC20Token _tokenB) {

        _supportedTokens(_tokenA, _tokenB);
        _;
    }

    function _supportedTokens(IERC20Token _tokenA, IERC20Token _tokenB) internal view {

        _validUniqueAddresses(_tokenA, _tokenB);
        require(tokensToOracles[_tokenA] != address(0) && tokensToOracles[_tokenB] != address(0), "ERR_UNSUPPORTED_TOKEN");
    }

    function latestRate(IERC20Token _tokenA, IERC20Token _tokenB)
        public
        view
        supportedTokens(_tokenA, _tokenB)
        returns (uint256, uint256)
    {

        uint256 rateTokenA = uint256(tokensToOracles[_tokenA].latestAnswer());
        uint256 rateTokenB = uint256(tokensToOracles[_tokenB].latestAnswer());
        uint8 decimalsTokenA = tokenDecimals[_tokenA];
        uint8 decimalsTokenB = tokenDecimals[_tokenB];


        if (decimalsTokenA > decimalsTokenB) {
            rateTokenB = rateTokenB.mul(uint256(10) ** (decimalsTokenA - decimalsTokenB));
        }
        else if (decimalsTokenA < decimalsTokenB) {
            rateTokenA = rateTokenA.mul(uint256(10) ** (decimalsTokenB - decimalsTokenA));
        }

        return (rateTokenA, rateTokenB);
    }

    function lastUpdateTime()
        public
        view
        returns (uint256) {

        uint256 timestampA = tokenAOracle.latestTimestamp();
        uint256 timestampB = tokenBOracle.latestTimestamp();

        return  timestampA < timestampB ? timestampA : timestampB;
    }

    function latestRateAndUpdateTime(IERC20Token _tokenA, IERC20Token _tokenB)
        public
        view
        returns (uint256, uint256, uint256)
    {

        (uint256 numerator, uint256 denominator) = latestRate(_tokenA, _tokenB);

        return (numerator, denominator, lastUpdateTime());
    }

    function decimals(IERC20Token _token) private view returns (uint8) {

        if (_token == ETH_ADDRESS) {
            return ETH_DECIMALS;
        }

        return _token.decimals();
    }
}


pragma solidity 0.4.26;



contract LiquidityPoolV2ConverterCustomFactory is ITypedConverterCustomFactory {

    function converterType() public pure returns (uint16) {

        return 2;
    }

    function createPriceOracle(
        IERC20Token _primaryReserveToken,
        IERC20Token _secondaryReserveToken,
        IChainlinkPriceOracle _primaryReserveOracle,
        IChainlinkPriceOracle _secondaryReserveOracle)
        public
        returns (IPriceOracle)
    {

        return new PriceOracle(_primaryReserveToken, _secondaryReserveToken, _primaryReserveOracle, _secondaryReserveOracle);
    }
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
    uint32 internal constant CONVERSION_FEE_RESOLUTION = 1000000;
    address internal constant ETH_RESERVE_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    struct Reserve {
        uint256 balance;    // reserve balance
        uint32 weight;      // reserve weight, represented in ppm, 1-1000000
        bool deprecated1;   // deprecated
        bool deprecated2;   // deprecated
        bool isSet;         // true if the reserve is valid, false otherwise
    }

    uint16 public constant version = 37;

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





contract IConverterFactory {

    function createAnchor(uint16 _type, string _name, string _symbol, uint8 _decimals) public returns (IConverterAnchor);

    function createConverter(uint16 _type, IConverterAnchor _anchor, IContractRegistry _registry, uint32 _maxConversionFee) public returns (IConverter);


    function customFactories(uint16 _type) public view returns (ITypedConverterCustomFactory) { _type; this; }

}


pragma solidity 0.4.26;






contract LiquidityPoolV2Converter is LiquidityPoolConverter {

    uint8 internal constant AMPLIFICATION_FACTOR = 20;  // factor to use for conversion calculations (reduces slippage)

    struct Fraction {
        uint256 n;  // numerator
        uint256 d;  // denominator
    }

    IPriceOracle public priceOracle;                                // external price oracle
    IERC20Token public primaryReserveToken;                         // primary reserve in the pool
    IERC20Token public secondaryReserveToken;                       // secondary reserve in the pool (cache)
    mapping (address => uint256) private stakedBalances;            // tracks the staked liquidity in the pool plus the fees
    mapping (address => ISmartToken) private reservesToPoolTokens;  // maps each reserve to its pool token
    mapping (address => IERC20Token) private poolTokensToReserves;  // maps each pool token to its reserve

    bool public referenceRateEnabled = true;    // reference rate enable / disable flag
    Fraction public referenceRate;              // reference rate from the previous block(s) of 1 primary token in secondary tokens
    uint256 public referenceRateUpdateTime;     // last time when the reference rate was updated (in seconds)

    Fraction public lastConversionRate;         // last conversion rate of 1 primary token in secondary tokens

    mapping (address => uint256) public maxStakedBalances;
    bool public maxStakedBalanceEnabled = true;

    uint256 public dynamicFeeFactor = 0; // initial dynamic fee factor is 0%, represented in ppm
    uint256 public weightSpreadFactor = 20000; // initial weight spread factor is 2%, represented in ppm
    uint256 public ratePropagationPeriod = 600 seconds; // initial time until the last rate takes full effect, represented in seconds

    event ReferenceRateEnabled(bool _newState);

    event DynamicFeeFactorUpdate(uint256 _prevFactor, uint256 _newFactor);

    event WeightSpreadFactorUpdate(uint256 _prevFactor, uint256 _newFactor);

    event RatePropagationPeriodUpdate(uint256 _prevPeriod, uint256 _newPeriod);

    constructor(IPoolTokensContainer _poolTokensContainer, IContractRegistry _registry, uint32 _maxConversionFee)
        public LiquidityPoolConverter(_poolTokensContainer, _registry, _maxConversionFee)
    {
    }

    modifier validPoolToken(ISmartToken _address) {

        _validPoolToken(_address);
        _;
    }

    function _validPoolToken(ISmartToken _address) internal view {

        require(poolTokensToReserves[_address] != address(0), "ERR_INVALID_POOL_TOKEN");
    }

    function converterType() public pure returns (uint16) {

        return 2;
    }

    function isActive() public view returns (bool) {

        return super.isActive() && priceOracle != address(0);
    }

    function amplificationFactor() public pure returns (uint8) {

        return AMPLIFICATION_FACTOR;
    }

    function activate(IERC20Token _primaryReserveToken, IChainlinkPriceOracle _primaryReserveOracle, IChainlinkPriceOracle _secondaryReserveOracle)
        public
        inactive
        ownerOnly
        validReserve(_primaryReserveToken)
        notThis(_primaryReserveOracle)
        notThis(_secondaryReserveOracle)
        validAddress(_primaryReserveOracle)
        validAddress(_secondaryReserveOracle)
    {

        require(anchor.owner() == address(this), "ERR_ANCHOR_NOT_OWNED");

        IWhitelist oracleWhitelist = IWhitelist(addressOf(CHAINLINK_ORACLE_WHITELIST));
        require(oracleWhitelist.isWhitelisted(_primaryReserveOracle), "ERR_INVALID_ORACLE");
        require(oracleWhitelist.isWhitelisted(_secondaryReserveOracle), "ERR_INVALID_ORACLE");

        createPoolTokens();

        primaryReserveToken = _primaryReserveToken;
        if (_primaryReserveToken == reserveTokens[0])
            secondaryReserveToken = reserveTokens[1];
        else
            secondaryReserveToken = reserveTokens[0];

        LiquidityPoolV2ConverterCustomFactory customFactory =
            LiquidityPoolV2ConverterCustomFactory(IConverterFactory(addressOf(CONVERTER_FACTORY)).customFactories(converterType()));
        priceOracle = customFactory.createPriceOracle(_primaryReserveToken, secondaryReserveToken, _primaryReserveOracle, _secondaryReserveOracle);

        (referenceRate.n, referenceRate.d) = priceOracle.latestRate(primaryReserveToken, secondaryReserveToken);
        lastConversionRate = referenceRate;

        referenceRateUpdateTime = time();

        uint256 primaryReserveStakedBalance = reserveStakedBalance(primaryReserveToken);
        uint256 primaryReserveBalance = reserveBalance(primaryReserveToken);
        uint256 secondaryReserveBalance = reserveBalance(secondaryReserveToken);

        if (primaryReserveStakedBalance == primaryReserveBalance) {
            if (primaryReserveStakedBalance > 0 || secondaryReserveBalance > 0) {
                rebalance();
            }
        }
        else if (primaryReserveStakedBalance > 0 && primaryReserveBalance > 0 && secondaryReserveBalance > 0) {
            rebalance();
        }

        emit Activation(converterType(), anchor, true);
    }

    function setReferenceRateEnabled(bool _referenceRateEnabled) public ownerOnly {

        emit ReferenceRateEnabled(_referenceRateEnabled);
        referenceRateEnabled = _referenceRateEnabled;
    }

    function setDynamicFeeFactor(uint256 _dynamicFeeFactor) public ownerOnly {

        require(_dynamicFeeFactor <= CONVERSION_FEE_RESOLUTION, "ERR_INVALID_DYNAMIC_FEE_FACTOR");
        emit DynamicFeeFactorUpdate(dynamicFeeFactor, _dynamicFeeFactor);
        dynamicFeeFactor = _dynamicFeeFactor;
    }

    function setWeightSpreadFactor(uint256 _weightSpreadFactor) public ownerOnly {

        require(_weightSpreadFactor <= CONVERSION_FEE_RESOLUTION, "ERR_INVALID_WEIGHT_SPREAD_FACTOR");
        emit WeightSpreadFactorUpdate(weightSpreadFactor, _weightSpreadFactor);
        weightSpreadFactor = _weightSpreadFactor;
    }

    function setRatePropagationPeriod(uint256 _ratePropagationPeriod) public ownerOnly {

        emit RatePropagationPeriodUpdate(ratePropagationPeriod, _ratePropagationPeriod);
        ratePropagationPeriod = _ratePropagationPeriod;
    }

    function customizeAll(uint256 _dynamicFeeFactor, uint256 _weightSpreadFactor, uint256 _ratePropagationPeriod) public ownerOnly {

        if (_dynamicFeeFactor != dynamicFeeFactor)
            setDynamicFeeFactor(_dynamicFeeFactor);
        if (_weightSpreadFactor != weightSpreadFactor)
            setWeightSpreadFactor(_weightSpreadFactor);
        if (_ratePropagationPeriod != ratePropagationPeriod)
            setRatePropagationPeriod(_ratePropagationPeriod);
    }

    function reserveStakedBalance(IERC20Token _reserveToken)
        public
        view
        validReserve(_reserveToken)
        returns (uint256)
    {

        return stakedBalances[_reserveToken];
    }

    function reserveAmplifiedBalance(IERC20Token _reserveToken)
        public
        view
        validReserve(_reserveToken)
        returns (uint256)
    {

        return stakedBalances[_reserveToken].mul(AMPLIFICATION_FACTOR - 1).add(reserveBalance(_reserveToken));
    }

    function setReserveStakedBalance(IERC20Token _reserveToken, uint256 _balance)
        public
        ownerOnly
        only(CONVERTER_UPGRADER)
        validReserve(_reserveToken)
    {

        stakedBalances[_reserveToken] = _balance;
    }

    function setMaxStakedBalances(uint256 _reserve1MaxStakedBalance, uint256 _reserve2MaxStakedBalance) public ownerOnly {

        maxStakedBalances[reserveTokens[0]] = _reserve1MaxStakedBalance;
        maxStakedBalances[reserveTokens[1]] = _reserve2MaxStakedBalance;
    }

    function disableMaxStakedBalances() public ownerOnly {

        maxStakedBalanceEnabled = false;
    }

    function poolToken(IERC20Token _reserveToken) public view returns (ISmartToken) {

        return reservesToPoolTokens[_reserveToken];
    }

    function liquidationLimit(ISmartToken _poolToken) public view returns (uint256) {

        uint256 poolTokenSupply = _poolToken.totalSupply();

        IERC20Token reserveToken = poolTokensToReserves[_poolToken];
        uint256 balance = reserveBalance(reserveToken);
        uint256 stakedBalance = stakedBalances[reserveToken];

        return balance.mul(poolTokenSupply).div(stakedBalance);
    }

    function addReserve(IERC20Token _token, uint32 _weight) public {

        require(reserveTokenCount() < 2, "ERR_INVALID_RESERVE_COUNT");
        super.addReserve(_token, _weight);
    }

    function effectiveTokensRate() public view returns (uint256, uint256) {

        Fraction memory rate = _effectiveTokensRate();
        return (rate.n, rate.d);
    }

    function effectiveReserveWeights() public view returns (uint256, uint256) {

        Fraction memory rate = _effectiveTokensRate();
        (uint32 primaryReserveWeight, uint32 secondaryReserveWeight) = effectiveReserveWeights(rate);

        if (primaryReserveToken == reserveTokens[0]) {
            return (primaryReserveWeight, secondaryReserveWeight);
        }

        return (secondaryReserveWeight, primaryReserveWeight);
    }

    function targetAmountAndFee(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount)
        public
        view
        active
        returns (uint256, uint256)
    {

        _validReserve(_sourceToken);
        _validReserve(_targetToken);
        require(_sourceToken != _targetToken, "ERR_SAME_SOURCE_TARGET");

        uint32 sourceTokenWeight;
        uint32 targetTokenWeight;

        Fraction memory rate;
        if (referenceRateUpdateTime == time()) {
            rate = referenceRate;
            sourceTokenWeight = reserves[_sourceToken].weight;
            targetTokenWeight = reserves[_targetToken].weight;
        }
        else {
            rate = _effectiveTokensRate();
            (uint32 primaryReserveWeight, uint32 secondaryReserveWeight) = effectiveReserveWeights(rate);

            if (_sourceToken == primaryReserveToken) {
                sourceTokenWeight = primaryReserveWeight;
                targetTokenWeight = secondaryReserveWeight;
            }
            else {
                sourceTokenWeight = secondaryReserveWeight;
                targetTokenWeight = primaryReserveWeight;
            }
        }

        (uint256 targetAmount, , uint256 fee) = targetAmountAndFees(_sourceToken, _targetToken, sourceTokenWeight, targetTokenWeight, rate, _amount);
        return (targetAmount, fee);
    }

    function doConvert(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount, address _trader, address _beneficiary)
        internal
        active
        validReserve(_sourceToken)
        validReserve(_targetToken)
        returns (uint256)
    {

        (uint256 amount, uint256 fee) = doConvert(_sourceToken, _targetToken, _amount);

        if (_targetToken == ETH_RESERVE_ADDRESS) {
            _beneficiary.transfer(amount);
        }
        else {
            safeTransfer(_targetToken, _beneficiary, amount);
        }

        dispatchConversionEvent(_sourceToken, _targetToken, _trader, _amount, amount, fee);

        dispatchRateEvents(_sourceToken, _targetToken, reserves[_sourceToken].weight, reserves[_targetToken].weight);

        return amount;
    }

    function doConvert(IERC20Token _sourceToken, IERC20Token _targetToken, uint256 _amount) private returns (uint256, uint256) {

        (bool rateUpdated, Fraction memory rate) = handleRateChange();

        (uint256 amount, uint256 standardFee, uint256 dynamicFee) = targetAmountAndFees(_sourceToken, _targetToken, 0, 0, rate, _amount);

        require(amount != 0, "ERR_ZERO_TARGET_AMOUNT");

        uint256 targetReserveBalance = reserveBalance(_targetToken);
        require(amount < targetReserveBalance, "ERR_TARGET_AMOUNT_TOO_HIGH");

        if (_sourceToken == ETH_RESERVE_ADDRESS)
            require(msg.value == _amount, "ERR_ETH_AMOUNT_MISMATCH");
        else
            require(msg.value == 0 && _sourceToken.balanceOf(this).sub(reserveBalance(_sourceToken)) >= _amount, "ERR_INVALID_AMOUNT");

        syncReserveBalance(_sourceToken);
        reserves[_targetToken].balance = targetReserveBalance.sub(amount);

        stakedBalances[_targetToken] = stakedBalances[_targetToken].add(standardFee);

        if (rateUpdated) {
            lastConversionRate = tokensRate(primaryReserveToken, secondaryReserveToken, 0, 0);
        }

        return (amount, dynamicFee);
    }

    function addLiquidity(IERC20Token _reserveToken, uint256 _amount, uint256 _minReturn)
        public
        payable
        protected
        active
        validReserve(_reserveToken)
        greaterThanZero(_amount)
        greaterThanZero(_minReturn)
        returns (uint256)
    {

        require(_reserveToken == ETH_RESERVE_ADDRESS ? msg.value == _amount : msg.value == 0, "ERR_ETH_AMOUNT_MISMATCH");

        syncReserveBalances();

        if (_reserveToken == ETH_RESERVE_ADDRESS)
            reserves[ETH_RESERVE_ADDRESS].balance = reserves[ETH_RESERVE_ADDRESS].balance.sub(msg.value);

        uint256 initialStakedBalance = stakedBalances[_reserveToken];

        if (maxStakedBalanceEnabled) {
            require(maxStakedBalances[_reserveToken] == 0 || initialStakedBalance.add(_amount) <= maxStakedBalances[_reserveToken], "ERR_MAX_STAKED_BALANCE_REACHED");
        }

        ISmartToken reservePoolToken = reservesToPoolTokens[_reserveToken];
        uint256 poolTokenSupply = reservePoolToken.totalSupply();

        if (_reserveToken != ETH_RESERVE_ADDRESS)
            safeTransferFrom(_reserveToken, msg.sender, this, _amount);

        reserves[_reserveToken].balance = reserves[_reserveToken].balance.add(_amount);
        stakedBalances[_reserveToken] = initialStakedBalance.add(_amount);

        uint256 poolTokenAmount = 0;
        if (initialStakedBalance == 0 || poolTokenSupply == 0)
            poolTokenAmount = _amount;
        else
            poolTokenAmount = _amount.mul(poolTokenSupply).div(initialStakedBalance);
        require(poolTokenAmount >= _minReturn, "ERR_RETURN_TOO_LOW");

        IPoolTokensContainer(anchor).mint(reservePoolToken, msg.sender, poolTokenAmount);

        rebalance();

        emit LiquidityAdded(msg.sender, _reserveToken, _amount, initialStakedBalance.add(_amount), poolTokenSupply.add(poolTokenAmount));

        dispatchPoolTokenRateUpdateEvent(reservePoolToken, poolTokenSupply.add(poolTokenAmount), _reserveToken);

        dispatchTokenRateUpdateEvent(reserveTokens[0], reserveTokens[1], 0, 0);

        return poolTokenAmount;
    }

    function removeLiquidity(ISmartToken _poolToken, uint256 _amount, uint256 _minReturn)
        public
        protected
        active
        validPoolToken(_poolToken)
        greaterThanZero(_amount)
        greaterThanZero(_minReturn)
        returns (uint256)
    {

        syncReserveBalances();

        uint256 initialPoolSupply = _poolToken.totalSupply();

        (uint256 reserveAmount, ) = removeLiquidityReturnAndFee(_poolToken, _amount);
        require(reserveAmount >= _minReturn, "ERR_RETURN_TOO_LOW");

        IERC20Token reserveToken = poolTokensToReserves[_poolToken];

        IPoolTokensContainer(anchor).burn(_poolToken, msg.sender, _amount);

        reserves[reserveToken].balance = reserves[reserveToken].balance.sub(reserveAmount);
        uint256 newStakedBalance = stakedBalances[reserveToken].sub(reserveAmount);
        stakedBalances[reserveToken] = newStakedBalance;

        if (reserveToken == ETH_RESERVE_ADDRESS)
            msg.sender.transfer(reserveAmount);
        else
            safeTransfer(reserveToken, msg.sender, reserveAmount);

        rebalance();

        uint256 newPoolTokenSupply = initialPoolSupply.sub(_amount);

        emit LiquidityRemoved(msg.sender, reserveToken, reserveAmount, newStakedBalance, newPoolTokenSupply);

        dispatchPoolTokenRateUpdateEvent(_poolToken, newPoolTokenSupply, reserveToken);

        dispatchTokenRateUpdateEvent(reserveTokens[0], reserveTokens[1], 0, 0);

        return reserveAmount;
    }

    function removeLiquidityReturnAndFee(ISmartToken _poolToken, uint256 _amount)
        public
        view
        returns (uint256, uint256)
    {

        uint256 totalSupply = _poolToken.totalSupply();
        uint256 stakedBalance = stakedBalances[poolTokensToReserves[_poolToken]];

        if (_amount < totalSupply) {
            uint256 x = stakedBalances[primaryReserveToken].mul(AMPLIFICATION_FACTOR);
            uint256 y = reserveAmplifiedBalance(primaryReserveToken);
            (uint256 min, uint256 max) = x < y ? (x, y) : (y, x);
            uint256 amountBeforeFee = _amount.mul(stakedBalance).div(totalSupply);
            uint256 amountAfterFee = amountBeforeFee.mul(min).div(max);
            return (amountAfterFee, amountBeforeFee - amountAfterFee);
        }
        return (stakedBalance, 0);
    }

    function targetAmountAndFees(
        IERC20Token _sourceToken,
        IERC20Token _targetToken,
        uint32 _sourceWeight,
        uint32 _targetWeight,
        Fraction memory _rate,
        uint256 _amount)
        private
        view
        returns (uint256 targetAmount, uint256 standardFee, uint256 dynamicFee)
    {

        if (_sourceWeight == 0)
            _sourceWeight = reserves[_sourceToken].weight;
        if (_targetWeight == 0)
            _targetWeight = reserves[_targetToken].weight;

        uint256 sourceBalance = reserveAmplifiedBalance(_sourceToken);
        uint256 targetBalance = reserveAmplifiedBalance(_targetToken);

        uint32 weightSpread = uint32(uint256(_sourceWeight) * weightSpreadFactor / CONVERSION_FEE_RESOLUTION);

        targetAmount = IBancorFormula(addressOf(BANCOR_FORMULA)).crossReserveTargetAmount(
            sourceBalance,
            _sourceWeight - weightSpread,
            targetBalance,
            _targetWeight + weightSpread,
            _amount
        );

        standardFee = calculateFee(targetAmount);
        dynamicFee = calculateDynamicFee(_targetToken, _sourceWeight, _targetWeight, _rate, targetAmount).add(standardFee);
        targetAmount = targetAmount.sub(dynamicFee);
    }

    function calculateDynamicFee(
        IERC20Token _targetToken,
        uint32 _sourceWeight,
        uint32 _targetWeight,
        Fraction memory _rate,
        uint256 _targetAmount)
        internal view returns (uint256)
    {

        uint256 fee;

        if (_targetToken == secondaryReserveToken) {
            fee = calculateFeeToEquilibrium(
                stakedBalances[primaryReserveToken],
                stakedBalances[secondaryReserveToken],
                _sourceWeight,
                _targetWeight,
                _rate.n,
                _rate.d,
                dynamicFeeFactor);
        }
        else {
            fee = calculateFeeToEquilibrium(
                stakedBalances[primaryReserveToken],
                stakedBalances[secondaryReserveToken],
                _targetWeight,
                _sourceWeight,
                _rate.n,
                _rate.d,
                dynamicFeeFactor);
        }

        return _targetAmount.mul(fee).div(CONVERSION_FEE_RESOLUTION);
    }

    function calculateFeeToEquilibrium(
        uint256 _primaryReserveStaked,
        uint256 _secondaryReserveStaked,
        uint256 _primaryReserveWeight,
        uint256 _secondaryReserveWeight,
        uint256 _primaryReserveRate,
        uint256 _secondaryReserveRate,
        uint256 _dynamicFeeFactor)
        internal
        pure
        returns (uint256)
    {

        uint256 x = _primaryReserveStaked.mul(_primaryReserveRate).mul(_secondaryReserveWeight);
        uint256 y = _secondaryReserveStaked.mul(_secondaryReserveRate).mul(_primaryReserveWeight);
        if (y > x)
            return (y - x).mul(_dynamicFeeFactor).mul(AMPLIFICATION_FACTOR).div(y);
        return 0;
    }

    function createPoolTokens() internal {

        IPoolTokensContainer container = IPoolTokensContainer(anchor);
        ISmartToken[] memory poolTokens = container.poolTokens();
        bool initialSetup = poolTokens.length == 0;

        uint256 reserveCount = reserveTokens.length;
        for (uint256 i = 0; i < reserveCount; i++) {
            ISmartToken reservePoolToken;
            if (initialSetup) {
                reservePoolToken = container.createToken();
            }
            else {
                reservePoolToken = poolTokens[i];
            }

            reservesToPoolTokens[reserveTokens[i]] = reservePoolToken;
            poolTokensToReserves[reservePoolToken] = reserveTokens[i];
        }
    }

    function _effectiveTokensRate() private view returns (Fraction memory) {

        (uint256 externalRateN, uint256 externalRateD, uint256 updateTime) = priceOracle.latestRateAndUpdateTime(primaryReserveToken, secondaryReserveToken);

        if (!referenceRateEnabled || updateTime > referenceRateUpdateTime) {
            return Fraction({ n: externalRateN, d: externalRateD });
        }

        uint256 timeElapsed = time() - referenceRateUpdateTime;

        if (timeElapsed == 0) {
            return referenceRate;
        }


        if (timeElapsed >= ratePropagationPeriod) {
            return lastConversionRate;
        }

        Fraction memory ref = referenceRate;
        Fraction memory last = lastConversionRate;

        uint256 x = ref.d.mul(last.n);
        uint256 y = ref.n.mul(last.d);

        uint256 newRateN = y.mul(ratePropagationPeriod - timeElapsed).add(x.mul(timeElapsed));
        uint256 newRateD = ref.d.mul(last.d).mul(ratePropagationPeriod);

        return reduceRate(newRateN, newRateD);
    }

    function handleRateChange() private returns (bool, Fraction memory) {

        uint256 currentTime = time();

        if (referenceRateUpdateTime == currentTime) {
            return (false, referenceRate);
        }

        Fraction memory newRate = _effectiveTokensRate();

        Fraction memory ref = referenceRate;
        if (newRate.n == ref.n && newRate.d == ref.d) {
            return (false, newRate);
        }

        referenceRate = newRate;
        referenceRateUpdateTime = currentTime;

        rebalance();

        return (true, newRate);
    }

    function rebalance() private {

        (uint32 primaryReserveWeight, uint32 secondaryReserveWeight) = effectiveReserveWeights(referenceRate);

        reserves[primaryReserveToken].weight = primaryReserveWeight;
        reserves[secondaryReserveToken].weight = secondaryReserveWeight;
    }

    function effectiveReserveWeights(Fraction memory _rate) private view returns (uint32, uint32) {

        uint256 primaryStakedBalance = stakedBalances[primaryReserveToken];

        uint256 primaryBalance = reserveAmplifiedBalance(primaryReserveToken);
        uint256 secondaryBalance = reserveAmplifiedBalance(secondaryReserveToken);

        return IBancorFormula(addressOf(BANCOR_FORMULA)).balancedWeights(
            primaryStakedBalance.mul(AMPLIFICATION_FACTOR),
            primaryBalance,
            secondaryBalance,
            _rate.n,
            _rate.d);
    }

    function tokensRate(IERC20Token _token1, IERC20Token _token2, uint32 _token1Weight, uint32 _token2Weight) private view returns (Fraction memory) {

        uint256 token1Balance = reserveAmplifiedBalance(_token1);
        uint256 token2Balance = reserveAmplifiedBalance(_token2);

        if (_token1Weight == 0) {
            _token1Weight = reserves[_token1].weight;
        }

        if (_token2Weight == 0) {
            _token2Weight = reserves[_token2].weight;
        }

        return Fraction({ n: token2Balance.mul(_token1Weight), d: token1Balance.mul(_token2Weight) });
    }

    function dispatchRateEvents(IERC20Token _sourceToken, IERC20Token _targetToken, uint32 _sourceWeight, uint32 _targetWeight) private {

        dispatchTokenRateUpdateEvent(_sourceToken, _targetToken, _sourceWeight, _targetWeight);

        ISmartToken targetPoolToken = poolToken(_targetToken);
        uint256 targetPoolTokenSupply = targetPoolToken.totalSupply();
        dispatchPoolTokenRateUpdateEvent(targetPoolToken, targetPoolTokenSupply, _targetToken);
    }

    function dispatchTokenRateUpdateEvent(IERC20Token _token1, IERC20Token _token2, uint32 _token1Weight, uint32 _token2Weight) private {

        Fraction memory rate = tokensRate(_token1, _token2, _token1Weight, _token2Weight);

        emit TokenRateUpdate(_token1, _token2, rate.n, rate.d);
    }

    function dispatchPoolTokenRateUpdateEvent(ISmartToken _poolToken, uint256 _poolTokenSupply, IERC20Token _reserveToken) private {

        emit TokenRateUpdate(_poolToken, _reserveToken, stakedBalances[_reserveToken], _poolTokenSupply);
    }

    function time() internal view returns (uint256) {

        return now;
    }

    uint256 private constant MAX_RATE_FACTOR_LOWER_BOUND = 1e30;
    uint256 private constant MAX_RATE_FACTOR_UPPER_BOUND = uint256(-1) / MAX_RATE_FACTOR_LOWER_BOUND;

    function reduceRate(uint256 _n, uint256 _d) internal pure returns (Fraction memory) {

        if (_n >= _d) {
            return reduceFactors(_n, _d);
        }

        Fraction memory rate = reduceFactors(_d, _n);
        return Fraction({ n: rate.d, d: rate.n });
    }

    function reduceFactors(uint256 _max, uint256 _min) internal pure returns (Fraction memory) {

        if (_min > MAX_RATE_FACTOR_UPPER_BOUND) {
            return Fraction({
                n: MAX_RATE_FACTOR_LOWER_BOUND,
                d: _min / (_max / MAX_RATE_FACTOR_LOWER_BOUND)
            });
        }

        if (_max > MAX_RATE_FACTOR_LOWER_BOUND) {
            return Fraction({
                n: MAX_RATE_FACTOR_LOWER_BOUND,
                d: _min * MAX_RATE_FACTOR_LOWER_BOUND / _max
            });
        }

        return Fraction({ n: _max, d: _min });
    }
}