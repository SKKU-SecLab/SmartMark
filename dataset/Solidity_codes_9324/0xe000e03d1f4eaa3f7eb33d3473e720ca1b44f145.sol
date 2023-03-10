
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


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}



contract Reputation is Ownable {

    using SafeMath for uint;

    mapping (address => uint256) public balances;
    uint256 public totalSupply;
    uint public decimals = 18;

    event Mint(address indexed _to, uint256 _amount);
    event Burn(address indexed _from, uint256 _amount);

    function reputationOf(address _owner) public view returns (uint256 balance) {

        return balances[_owner];
    }

    function mint(address _to, uint _amount)
    public
    onlyOwner
    returns (bool)
    {

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        return true;
    }

    function burn(address _from, uint _amount)
    public
    onlyOwner
    returns (bool)
    {

        uint amountMinted = _amount;
        if (balances[_from] < _amount) {
            amountMinted = balances[_from];
        }
        totalSupply = totalSupply.sub(amountMinted);
        balances[_from] = balances[_from].sub(amountMinted);
        emit Burn(_from, amountMinted);
        return true;
    }
}


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}


contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
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

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

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
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {

    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {

    require(msg.sender == owner);
    _;
  }

  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {

    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


contract BurnableToken is BasicToken {


  event Burn(address indexed burner, uint256 value);

  function burn(uint256 _value) public {

    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}


contract ERC827 is ERC20 {


    function approveAndCall(address _spender,uint256 _value,bytes _data) public payable returns(bool);


    function transferAndCall(address _to,uint256 _value,bytes _data) public payable returns(bool);


    function transferFromAndCall(address _from,address _to,uint256 _value,bytes _data) public payable returns(bool);


}



pragma solidity ^0.4.24;




contract ERC827Token is ERC827, StandardToken {


    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes _data
    )
    public
    payable
    returns (bool)
    {

        require(_spender != address(this));

        super.approve(_spender, _value);

        require(_spender.call.value(msg.value)(_data));

        return true;
    }

    function transferAndCall(
        address _to,
        uint256 _value,
        bytes _data
    )
    public
    payable
    returns (bool)
    {

        require(_to != address(this));

        super.transfer(_to, _value);

        require(_to.call.value(msg.value)(_data));
        return true;
    }

    function transferFromAndCall(
        address _from,
        address _to,
        uint256 _value,
        bytes _data
    )
    public payable returns (bool)
    {

        require(_to != address(this));

        super.transferFrom(_from, _to, _value);

        require(_to.call.value(msg.value)(_data));
        return true;
    }

    function increaseApprovalAndCall(
        address _spender,
        uint _addedValue,
        bytes _data
    )
    public
    payable
    returns (bool)
    {

        require(_spender != address(this));

        super.increaseApproval(_spender, _addedValue);

        require(_spender.call.value(msg.value)(_data));

        return true;
    }

    function decreaseApprovalAndCall(
        address _spender,
        uint _subtractedValue,
        bytes _data
    )
    public
    payable
    returns (bool)
    {

        require(_spender != address(this));

        super.decreaseApproval(_spender, _subtractedValue);

        require(_spender.call.value(msg.value)(_data));

        return true;
    }

}



contract DAOToken is ERC827Token,MintableToken,BurnableToken {


    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint public cap;

    constructor(string _name, string _symbol,uint _cap) public {
        name = _name;
        symbol = _symbol;
        cap = _cap;
    }

    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {

        if (cap > 0)
            require(totalSupply_.add(_amount) <= cap);
        return super.mint(_to, _amount);
    }
}


contract Avatar is Ownable {

    bytes32 public orgName;
    DAOToken public nativeToken;
    Reputation public nativeReputation;

    event GenericAction(address indexed _action, bytes32[] _params);
    event SendEther(uint _amountInWei, address indexed _to);
    event ExternalTokenTransfer(address indexed _externalToken, address indexed _to, uint _value);
    event ExternalTokenTransferFrom(address indexed _externalToken, address _from, address _to, uint _value);
    event ExternalTokenIncreaseApproval(StandardToken indexed _externalToken, address _spender, uint _addedValue);
    event ExternalTokenDecreaseApproval(StandardToken indexed _externalToken, address _spender, uint _subtractedValue);
    event ReceiveEther(address indexed _sender, uint _value);

    constructor(bytes32 _orgName, DAOToken _nativeToken, Reputation _nativeReputation) public {
        orgName = _orgName;
        nativeToken = _nativeToken;
        nativeReputation = _nativeReputation;
    }

    function() public payable {
        emit ReceiveEther(msg.sender, msg.value);
    }

    function genericCall(address _contract,bytes _data) public onlyOwner {

        bool result = _contract.call(_data);
        assembly {
        returndatacopy(0, 0, returndatasize)

        switch result
        case 0 { revert(0, returndatasize) }
        default { return(0, returndatasize) }
        }
    }

    function sendEther(uint _amountInWei, address _to) public onlyOwner returns(bool) {

        _to.transfer(_amountInWei);
        emit SendEther(_amountInWei, _to);
        return true;
    }

    function externalTokenTransfer(StandardToken _externalToken, address _to, uint _value)
    public onlyOwner returns(bool)
    {

        _externalToken.transfer(_to, _value);
        emit ExternalTokenTransfer(_externalToken, _to, _value);
        return true;
    }

    function externalTokenTransferFrom(
        StandardToken _externalToken,
        address _from,
        address _to,
        uint _value
    )
    public onlyOwner returns(bool)
    {

        _externalToken.transferFrom(_from, _to, _value);
        emit ExternalTokenTransferFrom(_externalToken, _from, _to, _value);
        return true;
    }

    function externalTokenIncreaseApproval(StandardToken _externalToken, address _spender, uint _addedValue)
    public onlyOwner returns(bool)
    {

        _externalToken.increaseApproval(_spender, _addedValue);
        emit ExternalTokenIncreaseApproval(_externalToken, _spender, _addedValue);
        return true;
    }

    function externalTokenDecreaseApproval(StandardToken _externalToken, address _spender, uint _subtractedValue )
    public onlyOwner returns(bool)
    {

        _externalToken.decreaseApproval(_spender, _subtractedValue);
        emit ExternalTokenDecreaseApproval(_externalToken,_spender, _subtractedValue);
        return true;
    }

}


contract GlobalConstraintInterface {


    enum CallPhase { Pre, Post,PreAndPost }

    function pre( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);

    function post( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);

    function when() public returns(CallPhase);

}


interface ControllerInterface {


    function mintReputation(uint256 _amount, address _to,address _avatar)
    external
    returns(bool);


    function burnReputation(uint256 _amount, address _from,address _avatar)
    external
    returns(bool);


    function mintTokens(uint256 _amount, address _beneficiary,address _avatar)
    external
    returns(bool);


    function registerScheme(address _scheme, bytes32 _paramsHash, bytes4 _permissions,address _avatar)
    external
    returns(bool);


    function unregisterScheme(address _scheme,address _avatar)
    external
    returns(bool);

    function unregisterSelf(address _avatar) external returns(bool);


    function isSchemeRegistered( address _scheme,address _avatar) external view returns(bool);


    function getSchemeParameters(address _scheme,address _avatar) external view returns(bytes32);


    function getGlobalConstraintParameters(address _globalConstraint,address _avatar) external view returns(bytes32);


    function getSchemePermissions(address _scheme,address _avatar) external view returns(bytes4);


    function globalConstraintsCount(address _avatar) external view returns(uint,uint);


    function isGlobalConstraintRegistered(address _globalConstraint,address _avatar) external view returns(bool);


    function addGlobalConstraint(address _globalConstraint, bytes32 _params,address _avatar)
    external returns(bool);


    function removeGlobalConstraint (address _globalConstraint,address _avatar)
    external  returns(bool);

    function upgradeController(address _newController,address _avatar)
    external returns(bool);


    function genericCall(address _contract,bytes _data,address _avatar)
    external
    returns(bytes32);


    function sendEther(uint _amountInWei, address _to,address _avatar)
    external returns(bool);


    function externalTokenTransfer(StandardToken _externalToken, address _to, uint _value,address _avatar)
    external
    returns(bool);


    function externalTokenTransferFrom(StandardToken _externalToken, address _from, address _to, uint _value,address _avatar)
    external
    returns(bool);


    function externalTokenIncreaseApproval(StandardToken _externalToken, address _spender, uint _addedValue,address _avatar)
    external
    returns(bool);


    function externalTokenDecreaseApproval(StandardToken _externalToken, address _spender, uint _subtractedValue,address _avatar)
    external
    returns(bool);


    function getNativeReputation(address _avatar)
    external
    view
    returns(address);

}


contract Controller is ControllerInterface {


    struct Scheme {
        bytes32 paramsHash;  // a hash "configuration" of the scheme
        bytes4  permissions; // A bitwise flags of permissions,
    }

    struct GlobalConstraint {
        address gcAddress;
        bytes32 params;
    }

    struct GlobalConstraintRegister {
        bool isRegistered; //is registered
        uint index;    //index at globalConstraints
    }

    mapping(address=>Scheme) public schemes;

    Avatar public avatar;
    DAOToken public nativeToken;
    Reputation public nativeReputation;
    address public newController;

    GlobalConstraint[] public globalConstraintsPre;
    GlobalConstraint[] public globalConstraintsPost;
    mapping(address=>GlobalConstraintRegister) public globalConstraintsRegisterPre;
    mapping(address=>GlobalConstraintRegister) public globalConstraintsRegisterPost;

    event MintReputation (address indexed _sender, address indexed _to, uint256 _amount);
    event BurnReputation (address indexed _sender, address indexed _from, uint256 _amount);
    event MintTokens (address indexed _sender, address indexed _beneficiary, uint256 _amount);
    event RegisterScheme (address indexed _sender, address indexed _scheme);
    event UnregisterScheme (address indexed _sender, address indexed _scheme);
    event GenericAction (address indexed _sender, bytes32[] _params);
    event SendEther (address indexed _sender, uint _amountInWei, address indexed _to);
    event ExternalTokenTransfer (address indexed _sender, address indexed _externalToken, address indexed _to, uint _value);
    event ExternalTokenTransferFrom (address indexed _sender, address indexed _externalToken, address _from, address _to, uint _value);
    event ExternalTokenIncreaseApproval (address indexed _sender, StandardToken indexed _externalToken, address _spender, uint _value);
    event ExternalTokenDecreaseApproval (address indexed _sender, StandardToken indexed _externalToken, address _spender, uint _value);
    event UpgradeController(address indexed _oldController,address _newController);
    event AddGlobalConstraint(address indexed _globalConstraint, bytes32 _params,GlobalConstraintInterface.CallPhase _when);
    event RemoveGlobalConstraint(address indexed _globalConstraint ,uint256 _index,bool _isPre);
    event GenericCall(address indexed _contract,bytes _data);

    constructor( Avatar _avatar) public
    {
        avatar = _avatar;
        nativeToken = avatar.nativeToken();
        nativeReputation = avatar.nativeReputation();
        schemes[msg.sender] = Scheme({paramsHash: bytes32(0),permissions: bytes4(0x1F)});
    }

    function() external {
        revert();
    }

    modifier onlyRegisteredScheme() {

        require(schemes[msg.sender].permissions&bytes4(1) == bytes4(1));
        _;
    }

    modifier onlyRegisteringSchemes() {

        require(schemes[msg.sender].permissions&bytes4(2) == bytes4(2));
        _;
    }

    modifier onlyGlobalConstraintsScheme() {

        require(schemes[msg.sender].permissions&bytes4(4) == bytes4(4));
        _;
    }

    modifier onlyUpgradingScheme() {

        require(schemes[msg.sender].permissions&bytes4(8) == bytes4(8));
        _;
    }

    modifier onlyGenericCallScheme() {

        require(schemes[msg.sender].permissions&bytes4(16) == bytes4(16));
        _;
    }

    modifier onlySubjectToConstraint(bytes32 func) {

        uint idx;
        for (idx = 0;idx<globalConstraintsPre.length;idx++) {
            require((GlobalConstraintInterface(globalConstraintsPre[idx].gcAddress)).pre(msg.sender,globalConstraintsPre[idx].params,func));
        }
        _;
        for (idx = 0;idx<globalConstraintsPost.length;idx++) {
            require((GlobalConstraintInterface(globalConstraintsPost[idx].gcAddress)).post(msg.sender,globalConstraintsPost[idx].params,func));
        }
    }

    modifier isAvatarValid(address _avatar) {

        require(_avatar == address(avatar));
        _;
    }

    function mintReputation(uint256 _amount, address _to,address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("mintReputation")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit MintReputation(msg.sender, _to, _amount);
        return nativeReputation.mint(_to, _amount);
    }

    function burnReputation(uint256 _amount, address _from,address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("burnReputation")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit BurnReputation(msg.sender, _from, _amount);
        return nativeReputation.burn(_from, _amount);
    }

    function mintTokens(uint256 _amount, address _beneficiary,address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("mintTokens")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit MintTokens(msg.sender, _beneficiary, _amount);
        return nativeToken.mint(_beneficiary, _amount);
    }

    function registerScheme(address _scheme, bytes32 _paramsHash, bytes4 _permissions,address _avatar)
    external
    onlyRegisteringSchemes
    onlySubjectToConstraint("registerScheme")
    isAvatarValid(_avatar)
    returns(bool)
    {


        Scheme memory scheme = schemes[_scheme];


        require(bytes4(0x1F)&(_permissions^scheme.permissions)&(~schemes[msg.sender].permissions) == bytes4(0));

        require(bytes4(0x1F)&(scheme.permissions&(~schemes[msg.sender].permissions)) == bytes4(0));

        schemes[_scheme].paramsHash = _paramsHash;
        schemes[_scheme].permissions = _permissions|bytes4(1);
        emit RegisterScheme(msg.sender, _scheme);
        return true;
    }

    function unregisterScheme( address _scheme,address _avatar)
    external
    onlyRegisteringSchemes
    onlySubjectToConstraint("unregisterScheme")
    isAvatarValid(_avatar)
    returns(bool)
    {

        if (schemes[_scheme].permissions&bytes4(1) == bytes4(0)) {
            return false;
          }
        require(bytes4(0x1F)&(schemes[_scheme].permissions&(~schemes[msg.sender].permissions)) == bytes4(0));

        emit UnregisterScheme(msg.sender, _scheme);
        delete schemes[_scheme];
        return true;
    }

    function unregisterSelf(address _avatar) external isAvatarValid(_avatar) returns(bool) {

        if (_isSchemeRegistered(msg.sender,_avatar) == false) {
            return false;
        }
        delete schemes[msg.sender];
        emit UnregisterScheme(msg.sender, msg.sender);
        return true;
    }

    function isSchemeRegistered(address _scheme,address _avatar) external isAvatarValid(_avatar) view returns(bool) {

        return _isSchemeRegistered(_scheme,_avatar);
    }

    function getSchemeParameters(address _scheme,address _avatar) external isAvatarValid(_avatar) view returns(bytes32) {

        return schemes[_scheme].paramsHash;
    }

    function getSchemePermissions(address _scheme,address _avatar) external isAvatarValid(_avatar) view returns(bytes4) {

        return schemes[_scheme].permissions;
    }

    function getGlobalConstraintParameters(address _globalConstraint,address) external view returns(bytes32) {


        GlobalConstraintRegister memory register = globalConstraintsRegisterPre[_globalConstraint];

        if (register.isRegistered) {
            return globalConstraintsPre[register.index].params;
        }

        register = globalConstraintsRegisterPost[_globalConstraint];

        if (register.isRegistered) {
            return globalConstraintsPost[register.index].params;
        }
    }

    function globalConstraintsCount(address _avatar)
        external
        isAvatarValid(_avatar)
        view
        returns(uint,uint)
        {

        return (globalConstraintsPre.length,globalConstraintsPost.length);
    }

    function isGlobalConstraintRegistered(address _globalConstraint,address _avatar)
        external
        isAvatarValid(_avatar)
        view
        returns(bool)
        {

        return (globalConstraintsRegisterPre[_globalConstraint].isRegistered || globalConstraintsRegisterPost[_globalConstraint].isRegistered);
    }

    function addGlobalConstraint(address _globalConstraint, bytes32 _params,address _avatar)
    external
    onlyGlobalConstraintsScheme
    isAvatarValid(_avatar)
    returns(bool)
    {

        GlobalConstraintInterface.CallPhase when = GlobalConstraintInterface(_globalConstraint).when();
        if ((when == GlobalConstraintInterface.CallPhase.Pre)||(when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            if (!globalConstraintsRegisterPre[_globalConstraint].isRegistered) {
                globalConstraintsPre.push(GlobalConstraint(_globalConstraint,_params));
                globalConstraintsRegisterPre[_globalConstraint] = GlobalConstraintRegister(true,globalConstraintsPre.length-1);
            }else {
                globalConstraintsPre[globalConstraintsRegisterPre[_globalConstraint].index].params = _params;
            }
        }
        if ((when == GlobalConstraintInterface.CallPhase.Post)||(when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            if (!globalConstraintsRegisterPost[_globalConstraint].isRegistered) {
                globalConstraintsPost.push(GlobalConstraint(_globalConstraint,_params));
                globalConstraintsRegisterPost[_globalConstraint] = GlobalConstraintRegister(true,globalConstraintsPost.length-1);
            }else {
                globalConstraintsPost[globalConstraintsRegisterPost[_globalConstraint].index].params = _params;
            }
        }
        emit AddGlobalConstraint(_globalConstraint, _params,when);
        return true;
    }

    function removeGlobalConstraint (address _globalConstraint,address _avatar)
    external
    onlyGlobalConstraintsScheme
    isAvatarValid(_avatar)
    returns(bool)
    {
        GlobalConstraintRegister memory globalConstraintRegister;
        GlobalConstraint memory globalConstraint;
        GlobalConstraintInterface.CallPhase when = GlobalConstraintInterface(_globalConstraint).when();
        bool retVal = false;

        if ((when == GlobalConstraintInterface.CallPhase.Pre)||(when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            globalConstraintRegister = globalConstraintsRegisterPre[_globalConstraint];
            if (globalConstraintRegister.isRegistered) {
                if (globalConstraintRegister.index < globalConstraintsPre.length-1) {
                    globalConstraint = globalConstraintsPre[globalConstraintsPre.length-1];
                    globalConstraintsPre[globalConstraintRegister.index] = globalConstraint;
                    globalConstraintsRegisterPre[globalConstraint.gcAddress].index = globalConstraintRegister.index;
                }
                globalConstraintsPre.length--;
                delete globalConstraintsRegisterPre[_globalConstraint];
                retVal = true;
            }
        }
        if ((when == GlobalConstraintInterface.CallPhase.Post)||(when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            globalConstraintRegister = globalConstraintsRegisterPost[_globalConstraint];
            if (globalConstraintRegister.isRegistered) {
                if (globalConstraintRegister.index < globalConstraintsPost.length-1) {
                    globalConstraint = globalConstraintsPost[globalConstraintsPost.length-1];
                    globalConstraintsPost[globalConstraintRegister.index] = globalConstraint;
                    globalConstraintsRegisterPost[globalConstraint.gcAddress].index = globalConstraintRegister.index;
                }
                globalConstraintsPost.length--;
                delete globalConstraintsRegisterPost[_globalConstraint];
                retVal = true;
            }
        }
        if (retVal) {
            emit RemoveGlobalConstraint(_globalConstraint,globalConstraintRegister.index,when == GlobalConstraintInterface.CallPhase.Pre);
        }
        return retVal;
    }

    function upgradeController(address _newController,address _avatar)
    external
    onlyUpgradingScheme
    isAvatarValid(_avatar)
    returns(bool)
    {

        require(newController == address(0));   // so the upgrade could be done once for a contract.
        require(_newController != address(0));
        newController = _newController;
        avatar.transferOwnership(_newController);
        require(avatar.owner()==_newController);
        if (nativeToken.owner() == address(this)) {
            nativeToken.transferOwnership(_newController);
            require(nativeToken.owner()==_newController);
        }
        if (nativeReputation.owner() == address(this)) {
            nativeReputation.transferOwnership(_newController);
            require(nativeReputation.owner()==_newController);
        }
        emit UpgradeController(this,newController);
        return true;
    }

    function genericCall(address _contract,bytes _data,address _avatar)
    external
    onlyGenericCallScheme
    onlySubjectToConstraint("genericCall")
    isAvatarValid(_avatar)
    returns (bytes32)
    {

        emit GenericCall(_contract, _data);
        avatar.genericCall(_contract, _data);
        assembly {
        returndatacopy(0, 0, returndatasize)
        return(0, returndatasize)
        }
    }

    function sendEther(uint _amountInWei, address _to,address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("sendEther")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit SendEther(msg.sender, _amountInWei, _to);
        return avatar.sendEther(_amountInWei, _to);
    }

    function externalTokenTransfer(StandardToken _externalToken, address _to, uint _value,address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("externalTokenTransfer")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit ExternalTokenTransfer(msg.sender, _externalToken, _to, _value);
        return avatar.externalTokenTransfer(_externalToken, _to, _value);
    }

    function externalTokenTransferFrom(StandardToken _externalToken, address _from, address _to, uint _value,address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("externalTokenTransferFrom")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit ExternalTokenTransferFrom(msg.sender, _externalToken, _from, _to, _value);
        return avatar.externalTokenTransferFrom(_externalToken, _from, _to, _value);
    }

    function externalTokenIncreaseApproval(StandardToken _externalToken, address _spender, uint _addedValue,address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("externalTokenIncreaseApproval")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit ExternalTokenIncreaseApproval(msg.sender,_externalToken,_spender,_addedValue);
        return avatar.externalTokenIncreaseApproval(_externalToken, _spender, _addedValue);
    }

    function externalTokenDecreaseApproval(StandardToken _externalToken, address _spender, uint _subtractedValue,address _avatar)
    external
    onlyRegisteredScheme
    onlySubjectToConstraint("externalTokenDecreaseApproval")
    isAvatarValid(_avatar)
    returns(bool)
    {

        emit ExternalTokenDecreaseApproval(msg.sender,_externalToken,_spender,_subtractedValue);
        return avatar.externalTokenDecreaseApproval(_externalToken, _spender, _subtractedValue);
    }

    function getNativeReputation(address _avatar) external isAvatarValid(_avatar) view returns(address) {

        return address(nativeReputation);
    }

    function _isSchemeRegistered(address _scheme,address _avatar) private isAvatarValid(_avatar) view returns(bool) {

        return (schemes[_scheme].permissions&bytes4(1) != bytes4(0));
    }
}


contract UniversalSchemeInterface {


    function updateParameters(bytes32 _hashedParameters) public;


    function getParametersFromController(Avatar _avatar) internal view returns(bytes32);

}


contract UniversalScheme is Ownable, UniversalSchemeInterface {

    bytes32 public hashedParameters; // For other parameters.

    function updateParameters(
        bytes32 _hashedParameters
    )
        public
        onlyOwner
    {

        hashedParameters = _hashedParameters;
    }

    function getParametersFromController(Avatar _avatar) internal view returns(bytes32) {

        return ControllerInterface(_avatar.owner()).getSchemeParameters(this,address(_avatar));
    }
}


contract ExecutableInterface {

    function execute(bytes32 _proposalId, address _avatar, int _param) public returns(bool);

}


interface IntVoteInterface {

    modifier onlyProposalOwner(bytes32 _proposalId) {revert(); _;}

    modifier votable(bytes32 _proposalId) {revert(); _;}


    event NewProposal(bytes32 indexed _proposalId, address indexed _avatar, uint _numOfChoices, address _proposer, bytes32 _paramsHash);
    event ExecuteProposal(bytes32 indexed _proposalId, address indexed _avatar, uint _decision, uint _totalReputation);
    event VoteProposal(bytes32 indexed _proposalId, address indexed _avatar, address indexed _voter, uint _vote, uint _reputation);
    event CancelProposal(bytes32 indexed _proposalId, address indexed _avatar );
    event CancelVoting(bytes32 indexed _proposalId, address indexed _avatar, address indexed _voter);

    function propose(
        uint _numOfChoices,
        bytes32 _proposalParameters,
        address _avatar,
        ExecutableInterface _executable,
        address _proposer
        ) external returns(bytes32);


    function cancelProposal(bytes32 _proposalId) external returns(bool);


    function ownerVote(bytes32 _proposalId, uint _vote, address _voter) external returns(bool);


    function vote(bytes32 _proposalId, uint _vote) external returns(bool);


    function voteWithSpecifiedAmounts(
        bytes32 _proposalId,
        uint _vote,
        uint _rep,
        uint _token) external returns(bool);


    function cancelVote(bytes32 _proposalId) external;


    function execute(bytes32 _proposalId) external returns(bool);


    function getNumberOfChoices(bytes32 _proposalId) external view returns(uint);


    function isVotable(bytes32 _proposalId) external view returns(bool);


    function voteStatus(bytes32 _proposalId,uint _choice) external view returns(uint);


    function isAbstainAllow() external pure returns(bool);


    function getAllowedRangeOfChoices() external pure returns(uint min,uint max);

}


contract GlobalConstraintRegistrar is UniversalScheme {

    event NewGlobalConstraintsProposal(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _intVoteInterface,
        address _gc,
        bytes32 _params,
        bytes32 _voteToRemoveParams
    );
    event RemoveGlobalConstraintsProposal(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _intVoteInterface,
        address _gc
    );
    event ProposalExecuted(address indexed _avatar, bytes32 indexed _proposalId,int _param);
    event ProposalDeleted(address indexed _avatar, bytes32 indexed _proposalId);

    struct GCProposal {
        address gc; // The address of the global constraint contract.
        bytes32 params; // Parameters for global constraint.
        uint proposalType; // 1: add a GC, 2: remove a GC.
        bytes32 voteToRemoveParams; // Voting parameters for removing this GC.
    }

    mapping(address=>mapping(bytes32=>GCProposal)) public organizationsProposals;

    mapping(address=>mapping(address=>bytes32)) public voteToRemoveParams;

    struct Parameters {
        bytes32 voteRegisterParams;
        IntVoteInterface intVote;
    }

    mapping(bytes32=>Parameters) public parameters;

    function execute(bytes32 _proposalId, address _avatar, int _param) external returns(bool) {


        require(parameters[getParametersFromController(Avatar(_avatar))].intVote == msg.sender);
        bool retVal = true;
        GCProposal memory proposal = organizationsProposals[_avatar][_proposalId];
        require(proposal.gc != address(0));
        delete organizationsProposals[_avatar][_proposalId];
        emit ProposalDeleted(_avatar,_proposalId);

        if (_param == 1 ) {

            ControllerInterface controller = ControllerInterface(Avatar(_avatar).owner());

            if (proposal.proposalType == 1) {
                retVal = controller.addGlobalConstraint(proposal.gc, proposal.params,_avatar);
                voteToRemoveParams[_avatar][proposal.gc] = proposal.voteToRemoveParams;
              }
            if (proposal.proposalType == 2) {
                retVal = controller.removeGlobalConstraint(proposal.gc,_avatar);
              }
        }
        emit ProposalExecuted(_avatar, _proposalId,_param);
        return retVal;
    }

    function setParameters(
        bytes32 _voteRegisterParams,
        IntVoteInterface _intVote
    ) public returns(bytes32)
    {

        bytes32 paramsHash = getParametersHash(_voteRegisterParams, _intVote);
        parameters[paramsHash].voteRegisterParams = _voteRegisterParams;
        parameters[paramsHash].intVote = _intVote;
        return paramsHash;
    }

    function getParametersHash(
        bytes32 _voteRegisterParams,
        IntVoteInterface _intVote
    ) public pure returns(bytes32)
    {

        return (keccak256(abi.encodePacked(_voteRegisterParams, _intVote)));
    }

    function proposeGlobalConstraint(Avatar _avatar, address _gc, bytes32 _params, bytes32 _voteToRemoveParams)
    public
    returns(bytes32)
    {

        Parameters memory votingParams = parameters[getParametersFromController(_avatar)];

        IntVoteInterface intVote = votingParams.intVote;
        bytes32 proposalId = intVote.propose(2, votingParams.voteRegisterParams, _avatar, ExecutableInterface(this),msg.sender);

        GCProposal memory proposal = GCProposal({
            gc: _gc,
            params: _params,
            proposalType: 1,
            voteToRemoveParams: _voteToRemoveParams
        });

        organizationsProposals[_avatar][proposalId] = proposal;
        emit NewGlobalConstraintsProposal(
            _avatar,
            proposalId,
            intVote,
            _gc,
            _params,
            _voteToRemoveParams
        );
        intVote.ownerVote(proposalId, 1, msg.sender); // Automatically votes `yes` in the name of the opener.
        return proposalId;
    }

    function proposeToRemoveGC(Avatar _avatar, address _gc) public returns(bytes32) {

        Controller controller = Controller(Avatar(_avatar).owner());
        require(controller.isGlobalConstraintRegistered(_gc,address(_avatar)));
        Parameters memory params = parameters[getParametersFromController(_avatar)];
        IntVoteInterface intVote = params.intVote;
        bytes32 proposalId = intVote.propose(2, voteToRemoveParams[_avatar][_gc], _avatar, ExecutableInterface(this),msg.sender);

        GCProposal memory proposal = GCProposal({
            gc: _gc,
            params: 0,
            proposalType: 2,
            voteToRemoveParams: 0
        });

        organizationsProposals[_avatar][proposalId] = proposal;
        emit RemoveGlobalConstraintsProposal(_avatar, proposalId, intVote, _gc);
        intVote.ownerVote(proposalId, 1, msg.sender); // Automatically votes `yes` in the name of the opener.
        return proposalId;
    }
}