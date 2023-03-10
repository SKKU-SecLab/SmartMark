
pragma solidity ^0.4.24;


contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract AbstractDeployer is Ownable {

    function title() public view returns(string);


    function deploy(bytes data)
        external onlyOwner returns(address result)
    {

        require(address(this).call(data), "Arbitrary call failed");
        assembly {
            returndatacopy(0, 0, 32)
            result := mload(0)
        }
    }
}


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


library SafeMath {


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}


library CheckedERC20 {

    using SafeMath for uint;

    function isContract(address addr) internal view returns(bool result) {

        assembly {
            result := gt(extcodesize(addr), 0)
        }
    }

    function handleReturnBool() internal pure returns(bool result) {

        assembly {
            switch returndatasize()
            case 0 { // not a std erc20
                result := 1
            }
            case 32 { // std erc20
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            default { // anything else, should revert for safety
                revert(0, 0)
            }
        }
    }

    function handleReturnBytes32() internal pure returns(bytes32 result) {

        assembly {
            switch eq(returndatasize(), 32) // not a std erc20
            case 1 {
                returndatacopy(0, 0, 32)
                result := mload(0)
            }

            switch gt(returndatasize(), 32) // std erc20
            case 1 {
                returndatacopy(0, 64, 32)
                result := mload(0)
            }

            switch lt(returndatasize(), 32) // anything else, should revert for safety
            case 1 {
                revert(0, 0)
            }
        }
    }

    function asmTransfer(address token, address to, uint256 value) internal returns(bool) {

        require(isContract(token));
        require(token.call(bytes4(keccak256("transfer(address,uint256)")), to, value));
        return handleReturnBool();
    }

    function asmTransferFrom(address token, address from, address to, uint256 value) internal returns(bool) {

        require(isContract(token));
        require(token.call(bytes4(keccak256("transferFrom(address,address,uint256)")), from, to, value));
        return handleReturnBool();
    }

    function asmApprove(address token, address spender, uint256 value) internal returns(bool) {

        require(isContract(token));
        require(token.call(bytes4(keccak256("approve(address,uint256)")), spender, value));
        return handleReturnBool();
    }


    function checkedTransfer(ERC20 token, address to, uint256 value) internal {

        if (value > 0) {
            uint256 balance = token.balanceOf(this);
            asmTransfer(token, to, value);
            require(token.balanceOf(this) == balance.sub(value), "checkedTransfer: Final balance didn't match");
        }
    }

    function checkedTransferFrom(ERC20 token, address from, address to, uint256 value) internal {

        if (value > 0) {
            uint256 toBalance = token.balanceOf(to);
            asmTransferFrom(token, from, to, value);
            require(token.balanceOf(to) == toBalance.add(value), "checkedTransfer: Final balance didn't match");
        }
    }


    function asmName(address token) internal view returns(bytes32) {

        require(isContract(token));
        require(token.call(bytes4(keccak256("name()"))));
        return handleReturnBytes32();
    }

    function asmSymbol(address token) internal view returns(bytes32) {

        require(isContract(token));
        require(token.call(bytes4(keccak256("symbol()"))));
        return handleReturnBytes32();
    }
}


contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}


contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {

    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract DetailedERC20 is ERC20 {

  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}


interface ERC165 {


  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);

}


contract SupportsInterfaceWithLookup is ERC165 {


  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;

  mapping(bytes4 => bool) internal supportedInterfaces;

  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC165);
  }

  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {

    return supportedInterfaces[_interfaceId];
  }

  function _registerInterface(bytes4 _interfaceId)
    internal
  {

    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}


contract ERC1003Caller is Ownable {

    function makeCall(address target, bytes data) external payable onlyOwner returns (bool) {

        return target.call.value(msg.value)(data);
    }
}


contract ERC1003Token is ERC20 {

    ERC1003Caller private _caller = new ERC1003Caller();
    address[] internal _sendersStack;

    function caller() public view returns(ERC1003Caller) {

        return _caller;
    }

    function approveAndCall(address to, uint256 value, bytes data) public payable returns (bool) {

        _sendersStack.push(msg.sender);
        approve(to, value);
        require(_caller.makeCall.value(msg.value)(to, data));
        _sendersStack.length -= 1;
        return true;
    }

    function transferAndCall(address to, uint256 value, bytes data) public payable returns (bool) {

        transfer(to, value);
        require(_caller.makeCall.value(msg.value)(to, data));
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        address spender = (from != address(_caller)) ? from : _sendersStack[_sendersStack.length - 1];
        return super.transferFrom(spender, to, value);
    }
}


contract IBasicMultiToken is ERC20 {

    event Bundle(address indexed who, address indexed beneficiary, uint256 value);
    event Unbundle(address indexed who, address indexed beneficiary, uint256 value);

    function tokensCount() public view returns(uint256);

    function tokens(uint i) public view returns(ERC20);

    function bundlingEnabled() public view returns(bool);

    
    function bundleFirstTokens(address _beneficiary, uint256 _amount, uint256[] _tokenAmounts) public;

    function bundle(address _beneficiary, uint256 _amount) public;


    function unbundle(address _beneficiary, uint256 _value) public;

    function unbundleSome(address _beneficiary, uint256 _value, ERC20[] _tokens) public;


    function disableBundling() public;

    function enableBundling() public;


    bytes4 public constant InterfaceId_IBasicMultiToken = 0xd5c368b6;
}


contract BasicMultiToken is Ownable, StandardToken, DetailedERC20, ERC1003Token, IBasicMultiToken, SupportsInterfaceWithLookup {

    using CheckedERC20 for ERC20;
    using CheckedERC20 for DetailedERC20;

    ERC20[] private _tokens;
    uint private _inLendingMode;
    bool private _bundlingEnabled = true;

    event Bundle(address indexed who, address indexed beneficiary, uint256 value);
    event Unbundle(address indexed who, address indexed beneficiary, uint256 value);
    event BundlingStatus(bool enabled);

    modifier notInLendingMode {

        require(_inLendingMode == 0, "Operation can't be performed while lending");
        _;
    }

    modifier whenBundlingEnabled {

        require(_bundlingEnabled, "Bundling is disabled");
        _;
    }

    constructor(ERC20[] tokens, string name, string symbol, uint8 decimals)
        public DetailedERC20(name, symbol, decimals)
    {
        require(decimals > 0, "constructor: _decimals should not be zero");
        require(bytes(name).length > 0, "constructor: name should not be empty");
        require(bytes(symbol).length > 0, "constructor: symbol should not be empty");
        require(tokens.length >= 2, "Contract does not support less than 2 inner tokens");

        _tokens = tokens;

        _registerInterface(InterfaceId_IBasicMultiToken);
    }

    function tokensCount() public view returns(uint) {

        return _tokens.length;
    }

    function tokens(uint i) public view returns(ERC20) {

        return _tokens[i];
    }

    function inLendingMode() public view returns(uint) {

        return _inLendingMode;
    }

    function bundlingEnabled() public view returns(bool) {

        return _bundlingEnabled;
    }

    function bundleFirstTokens(address beneficiary, uint256 amount, uint256[] tokenAmounts) public whenBundlingEnabled notInLendingMode {

        require(totalSupply_ == 0, "bundleFirstTokens: This method can be used with zero total supply only");
        _bundle(beneficiary, amount, tokenAmounts);
    }

    function bundle(address beneficiary, uint256 amount) public whenBundlingEnabled notInLendingMode {

        require(totalSupply_ != 0, "This method can be used with non zero total supply only");
        uint256[] memory tokenAmounts = new uint256[](_tokens.length);
        for (uint i = 0; i < _tokens.length; i++) {
            tokenAmounts[i] = _tokens[i].balanceOf(this).mul(amount).div(totalSupply_);
        }
        _bundle(beneficiary, amount, tokenAmounts);
    }

    function unbundle(address beneficiary, uint256 value) public notInLendingMode {

        unbundleSome(beneficiary, value, _tokens);
    }

    function unbundleSome(address beneficiary, uint256 value, ERC20[] someTokens) public notInLendingMode {

        _unbundle(beneficiary, value, someTokens);
    }


    function disableBundling() public onlyOwner {

        require(_bundlingEnabled, "Bundling is already disabled");
        _bundlingEnabled = false;
        emit BundlingStatus(false);
    }

    function enableBundling() public onlyOwner {

        require(!_bundlingEnabled, "Bundling is already enabled");
        _bundlingEnabled = true;
        emit BundlingStatus(true);
    }


    function _bundle(address beneficiary, uint256 amount, uint256[] tokenAmounts) internal {

        require(amount != 0, "Bundling amount should be non-zero");
        require(_tokens.length == tokenAmounts.length, "Lenghts of _tokens and tokenAmounts array should be equal");

        for (uint i = 0; i < _tokens.length; i++) {
            require(tokenAmounts[i] != 0, "Token amount should be non-zero");
            _tokens[i].checkedTransferFrom(msg.sender, this, tokenAmounts[i]);
        }

        totalSupply_ = totalSupply_.add(amount);
        balances[beneficiary] = balances[beneficiary].add(amount);
        emit Bundle(msg.sender, beneficiary, amount);
        emit Transfer(0, beneficiary, amount);
    }

    function _unbundle(address beneficiary, uint256 value, ERC20[] someTokens) internal {

        require(someTokens.length > 0, "Array of someTokens can't be empty");

        uint256 totalSupply = totalSupply_;
        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply_ = totalSupply.sub(value);
        emit Unbundle(msg.sender, beneficiary, value);
        emit Transfer(msg.sender, 0, value);

        for (uint i = 0; i < someTokens.length; i++) {
            for (uint j = 0; j < i; j++) {
                require(someTokens[i] != someTokens[j], "unbundleSome: should not unbundle same token multiple times");
            }
            uint256 tokenAmount = someTokens[i].balanceOf(this).mul(value).div(totalSupply);
            someTokens[i].checkedTransfer(beneficiary, tokenAmount);
        }
    }


    function lend(address to, ERC20 token, uint256 amount, address target, bytes data) public payable {

        uint256 prevBalance = token.balanceOf(this);
        token.asmTransfer(to, amount);
        _inLendingMode += 1;
        require(caller().makeCall.value(msg.value)(target, data), "lend: arbitrary call failed");
        _inLendingMode -= 1;
        require(token.balanceOf(this) >= prevBalance, "lend: lended token must be refilled");
    }
}


contract FeeBasicMultiToken is Ownable, BasicMultiToken {

    using CheckedERC20 for ERC20;

    uint256 constant public TOTAL_PERCRENTS = 1000000;
    uint256 internal _lendFee;

    function lendFee() public view returns(uint256) {

        return _lendFee;
    }

    function setLendFee(uint256 theLendFee) public onlyOwner {

        require(theLendFee <= 30000, "setLendFee: fee should be not greater than 3%");
        _lendFee = theLendFee;
    }

    function lend(address to, ERC20 token, uint256 amount, address target, bytes data) public payable {

        uint256 expectedBalance = token.balanceOf(this).mul(TOTAL_PERCRENTS.add(_lendFee)).div(TOTAL_PERCRENTS);
        super.lend(to, token, amount, target, data);
        require(token.balanceOf(this) >= expectedBalance, "lend: tokens must be returned with lend fee");
    }
}


contract AstraBasicMultiToken is FeeBasicMultiToken {

    constructor(ERC20[] tokens, string name, string symbol, uint8 decimals)
        public BasicMultiToken(tokens, name, symbol, decimals)
    {
    }
}


contract AstraBasicMultiTokenDeployer is AbstractDeployer {

    function title() public view returns(string) {

        return "AstraBasicMultiTokenDeployer";
    }

    function create(ERC20[] tokens, string name, string symbol)
        external returns(address)
    {

        require(msg.sender == address(this), "Should be called only from deployer itself");
        AstraBasicMultiToken mtkn = new AstraBasicMultiToken(tokens, name, symbol, 18);
        mtkn.transferOwnership(msg.sender);
        return mtkn;
    }
}