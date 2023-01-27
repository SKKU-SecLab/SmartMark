

pragma solidity 0.6.12;

interface IOwned {

    function owner() external view returns (address);


    function transferOwnership(address _newOwner) external;

    function acceptOwnership() external;

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



interface ITokenHolder is IOwned {

    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) external;

}



pragma solidity 0.6.12;



interface IConverterAnchor is IOwned, ITokenHolder {

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

interface ITypedConverterCustomFactory {

    function converterType() external pure returns (uint16);

}



pragma solidity 0.6.12;

interface IContractRegistry {

    function addressOf(bytes32 _contractName) external view returns (address);

}



pragma solidity 0.6.12;





interface IConverterFactory {

    function createAnchor(uint16 _type, string memory _name, string memory _symbol, uint8 _decimals) external returns (IConverterAnchor);

    function createConverter(uint16 _type, IConverterAnchor _anchor, IContractRegistry _registry, uint32 _maxConversionFee) external returns (IConverter);


    function customFactories(uint16 _type) external view returns (ITypedConverterCustomFactory);

}



pragma solidity 0.6.12;




interface ITypedConverterFactory {

    function converterType() external pure returns (uint16);

    function createConverter(IConverterAnchor _anchor, IContractRegistry _registry, uint32 _maxConversionFee) external returns (IConverter);

}



pragma solidity 0.6.12;


interface ITypedConverterAnchorFactory {

    function converterType() external pure returns (uint16);

    function createAnchor(string memory _name, string memory _symbol, uint8 _decimals) external returns (IConverterAnchor);

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




contract ERC20Token is IERC20Token, Utils {

    using SafeMath for uint256;


    string public override name;
    string public override symbol;
    uint8 public override decimals;
    uint256 public override totalSupply;
    mapping (address => uint256) public override balanceOf;
    mapping (address => mapping (address => uint256)) public override allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) public {
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
        virtual
        override
        validAddress(_to)
        returns (bool)
    {

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        virtual
        override
        validAddress(_from)
        validAddress(_to)
        returns (bool)
    {

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        virtual
        override
        validAddress(_spender)
        returns (bool)
    {

        require(_value == 0 || allowance[msg.sender][_spender] == 0, "ERR_INVALID_AMOUNT");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}



pragma solidity 0.6.12;




interface ISmartToken is IConverterAnchor, IERC20Token {

    function disableTransfers(bool _disable) external;

    function issue(address _to, uint256 _amount) external;

    function destroy(address _from, uint256 _amount) external;

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





contract SmartToken is ISmartToken, Owned, ERC20Token, TokenHolder {

    using SafeMath for uint256;

    uint16 public constant version = 4;

    bool public transfersEnabled = true;    // true if transfer/transferFrom are enabled, false otherwise

    event Issuance(uint256 _amount);

    event Destruction(uint256 _amount);

    constructor(string memory _name, string memory _symbol, uint8 _decimals)
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

    function disableTransfers(bool _disable) public override ownerOnly {

        transfersEnabled = !_disable;
    }

    function issue(address _to, uint256 _amount)
        public
        override
        ownerOnly
        validAddress(_to)
        notThis(_to)
    {

        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);

        emit Issuance(_amount);
        emit Transfer(address(0), _to, _amount);
    }

    function destroy(address _from, uint256 _amount) public override ownerOnly {

        balanceOf[_from] = balanceOf[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);

        emit Transfer(_from, address(0), _amount);
        emit Destruction(_amount);
    }


    function transfer(address _to, uint256 _value)
        public
        override(IERC20Token, ERC20Token)
        transfersAllowed
        returns (bool)
    {

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        override(IERC20Token, ERC20Token)
        transfersAllowed
        returns (bool) 
    {

        return super.transferFrom(_from, _to, _value);
    }
}



pragma solidity 0.6.12;









contract ConverterFactory is IConverterFactory, Owned {

    event NewConverter(uint16 indexed _type, IConverter indexed _converter, address indexed _owner);

    mapping (uint16 => ITypedConverterFactory) public converterFactories;
    mapping (uint16 => ITypedConverterAnchorFactory) public anchorFactories;
    mapping (uint16 => ITypedConverterCustomFactory) public override customFactories;

    function registerTypedConverterFactory(ITypedConverterFactory _factory) public ownerOnly {

        converterFactories[_factory.converterType()] = _factory;
    }

    function registerTypedConverterAnchorFactory(ITypedConverterAnchorFactory _factory) public ownerOnly {

        anchorFactories[_factory.converterType()] = _factory;
    }

    function registerTypedConverterCustomFactory(ITypedConverterCustomFactory _factory) public ownerOnly {

        customFactories[_factory.converterType()] = _factory;
    }

    function createAnchor(uint16 _converterType, string memory _name, string memory _symbol, uint8 _decimals)
        public
        virtual
        override
        returns (IConverterAnchor)
    {

        IConverterAnchor anchor;
        ITypedConverterAnchorFactory factory = anchorFactories[_converterType];

        if (address(factory) == address(0)) {
            anchor = new SmartToken(_name, _symbol, _decimals);
        }
        else {
            anchor = factory.createAnchor(_name, _symbol, _decimals);
            anchor.acceptOwnership();
        }

        anchor.transferOwnership(msg.sender);
        return anchor;
    }

    function createConverter(uint16 _type, IConverterAnchor _anchor, IContractRegistry _registry, uint32 _maxConversionFee)
        public
        virtual
        override
        returns (IConverter)
    {

        IConverter converter = converterFactories[_type].createConverter(_anchor, _registry, _maxConversionFee);
        converter.acceptOwnership();
        converter.transferOwnership(msg.sender);

        emit NewConverter(_type, converter, msg.sender);
        return converter;
    }
}