
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


contract UController is ControllerInterface {


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

    struct Organization {
        DAOToken                  nativeToken;
        Reputation                nativeReputation;
        mapping(address=>Scheme)  schemes;
        GlobalConstraint[] globalConstraintsPre;
        GlobalConstraint[] globalConstraintsPost;
        mapping(address=>GlobalConstraintRegister) globalConstraintsRegisterPre;
        mapping(address=>GlobalConstraintRegister) globalConstraintsRegisterPost;
        bool exist;
    }

    mapping(address=>Organization) public organizations;
    mapping(address=>address) public newControllers;//mapping between avatar address and newController address

    mapping(address=>bool) public reputations;
    mapping(address=>bool) public tokens;


    event MintReputation (address indexed _sender, address indexed _to, uint256 _amount,address indexed _avatar);
    event BurnReputation (address indexed _sender, address indexed _from, uint256 _amount,address indexed _avatar);
    event MintTokens (address indexed _sender, address indexed _beneficiary, uint256 _amount, address indexed _avatar);
    event RegisterScheme (address indexed _sender, address indexed _scheme,address indexed _avatar);
    event UnregisterScheme (address indexed _sender, address indexed _scheme, address indexed _avatar);
    event GenericAction (address indexed _sender, bytes32[] _params);
    event SendEther (address indexed _sender, uint _amountInWei, address indexed _to);
    event ExternalTokenTransfer (address indexed _sender, address indexed _externalToken, address indexed _to, uint _value);
    event ExternalTokenTransferFrom (address indexed _sender, address indexed _externalToken, address _from, address _to, uint _value);
    event ExternalTokenIncreaseApproval (address indexed _sender, StandardToken indexed _externalToken, address _spender, uint _value);
    event ExternalTokenDecreaseApproval (address indexed _sender, StandardToken indexed _externalToken, address _spender, uint _value);
    event UpgradeController(address indexed _oldController,address _newController,address _avatar);
    event GenericCall(address indexed _contract,bytes _data,address indexed _avatar);

    event AddGlobalConstraint(
        address indexed _globalConstraint,
        bytes32 _params,
        GlobalConstraintInterface.CallPhase _when,
        address indexed _avatar
    );
    event RemoveGlobalConstraint(address indexed _globalConstraint ,uint256 _index,bool _isPre,address indexed _avatar);


    function newOrganization(
        Avatar _avatar
    ) external
    {

        require(!organizations[address(_avatar)].exist);
        require(_avatar.owner() == address(this));
        require(!reputations[_avatar.nativeReputation()]);
        require(!tokens[_avatar.nativeToken()]);
        organizations[address(_avatar)].exist = true;
        organizations[address(_avatar)].nativeToken = _avatar.nativeToken();
        organizations[address(_avatar)].nativeReputation = _avatar.nativeReputation();
        reputations[_avatar.nativeReputation()] = true;
        tokens[_avatar.nativeToken()] = true;
        organizations[address(_avatar)].schemes[msg.sender] = Scheme({paramsHash: bytes32(0),permissions: bytes4(0x1F)});
        emit RegisterScheme(msg.sender, msg.sender,_avatar);
    }

    modifier onlyRegisteredScheme(address avatar) {

        require(organizations[avatar].schemes[msg.sender].permissions&bytes4(1) == bytes4(1));
        _;
    }

    modifier onlyRegisteringSchemes(address avatar) {

        require(organizations[avatar].schemes[msg.sender].permissions&bytes4(2) == bytes4(2));
        _;
    }

    modifier onlyGlobalConstraintsScheme(address avatar) {

        require(organizations[avatar].schemes[msg.sender].permissions&bytes4(4) == bytes4(4));
        _;
    }

    modifier onlyUpgradingScheme(address _avatar) {

        require(organizations[_avatar].schemes[msg.sender].permissions&bytes4(8) == bytes4(8));
        _;
    }

    modifier onlyGenericCallScheme(address _avatar) {

        require(organizations[_avatar].schemes[msg.sender].permissions&bytes4(16) == bytes4(16));
        _;
    }

    modifier onlySubjectToConstraint(bytes32 func,address _avatar) {

        uint idx;
        GlobalConstraint[] memory globalConstraintsPre = organizations[_avatar].globalConstraintsPre;
        GlobalConstraint[] memory globalConstraintsPost = organizations[_avatar].globalConstraintsPost;
        for (idx = 0;idx<globalConstraintsPre.length;idx++) {
            require((GlobalConstraintInterface(globalConstraintsPre[idx].gcAddress)).pre(msg.sender, globalConstraintsPre[idx].params, func));
        }
        _;
        for (idx = 0;idx<globalConstraintsPost.length;idx++) {
            require((GlobalConstraintInterface(globalConstraintsPost[idx].gcAddress)).post(msg.sender, globalConstraintsPost[idx].params, func));
        }
    }

    function mintReputation(uint256 _amount, address _to, address _avatar)
    external
    onlyRegisteredScheme(_avatar)
    onlySubjectToConstraint("mintReputation",_avatar)
    returns(bool)
    {

        emit MintReputation(msg.sender, _to, _amount,_avatar);
        return organizations[_avatar].nativeReputation.mint(_to, _amount);
    }

    function burnReputation(uint256 _amount, address _from,address _avatar)
    external
    onlyRegisteredScheme(_avatar)
    onlySubjectToConstraint("burnReputation",_avatar)
    returns(bool)
    {

        emit BurnReputation(msg.sender, _from, _amount,_avatar);
        return organizations[_avatar].nativeReputation.burn(_from, _amount);
    }

    function mintTokens(uint256 _amount, address _beneficiary,address _avatar)
    external
    onlyRegisteredScheme(_avatar)
    onlySubjectToConstraint("mintTokens",_avatar)
    returns(bool)
    {

        emit MintTokens(msg.sender, _beneficiary, _amount,_avatar);
        return organizations[_avatar].nativeToken.mint(_beneficiary, _amount);
    }

    function registerScheme(address _scheme, bytes32 _paramsHash, bytes4 _permissions,address _avatar)
    external
    onlyRegisteringSchemes(_avatar)
    onlySubjectToConstraint("registerScheme",_avatar)
    returns(bool)
    {

        bytes4 schemePermission = organizations[_avatar].schemes[_scheme].permissions;
        bytes4 senderPermission = organizations[_avatar].schemes[msg.sender].permissions;

        require(bytes4(0x1F)&(_permissions^schemePermission)&(~senderPermission) == bytes4(0));

        require(bytes4(0x1F)&(schemePermission&(~senderPermission)) == bytes4(0));

        organizations[_avatar].schemes[_scheme] = Scheme({paramsHash:_paramsHash,permissions:_permissions|bytes4(1)});
        emit RegisterScheme(msg.sender, _scheme, _avatar);
        return true;
    }

    function unregisterScheme(address _scheme,address _avatar)
    external
    onlyRegisteringSchemes(_avatar)
    onlySubjectToConstraint("unregisterScheme",_avatar)
    returns(bool)
    {

        bytes4 schemePermission = organizations[_avatar].schemes[_scheme].permissions;
        if (schemePermission&bytes4(1) == bytes4(0)) {
            return false;
          }
        require(bytes4(0x1F)&(schemePermission&(~organizations[_avatar].schemes[msg.sender].permissions)) == bytes4(0));

        emit UnregisterScheme(msg.sender, _scheme,_avatar);
        delete organizations[_avatar].schemes[_scheme];
        return true;
    }

    function unregisterSelf(address _avatar) external returns(bool) {

        if (_isSchemeRegistered(msg.sender,_avatar) == false) {
            return false;
        }
        delete organizations[_avatar].schemes[msg.sender];
        emit UnregisterScheme(msg.sender, msg.sender,_avatar);
        return true;
    }

    function isSchemeRegistered( address _scheme,address _avatar) external view returns(bool) {

        return _isSchemeRegistered(_scheme,_avatar);
    }

    function getSchemeParameters(address _scheme,address _avatar) external view returns(bytes32) {

        return organizations[_avatar].schemes[_scheme].paramsHash;
    }

    function getSchemePermissions(address _scheme,address _avatar) external view returns(bytes4) {

        return organizations[_avatar].schemes[_scheme].permissions;
    }

    function getGlobalConstraintParameters(address _globalConstraint, address _avatar) external view returns(bytes32) {


        Organization storage organization = organizations[_avatar];

        GlobalConstraintRegister memory register = organization.globalConstraintsRegisterPre[_globalConstraint];

        if (register.isRegistered) {
            return organization.globalConstraintsPre[register.index].params;
        }

        register = organization.globalConstraintsRegisterPost[_globalConstraint];

        if (register.isRegistered) {
            return organization.globalConstraintsPost[register.index].params;
        }
    }

    function globalConstraintsCount(address _avatar) external view returns(uint,uint) {

        return (organizations[_avatar].globalConstraintsPre.length,organizations[_avatar].globalConstraintsPost.length);
    }

    function isGlobalConstraintRegistered(address _globalConstraint,address _avatar) external view returns(bool) {

        return (organizations[_avatar].globalConstraintsRegisterPre[_globalConstraint].isRegistered ||
        organizations[_avatar].globalConstraintsRegisterPost[_globalConstraint].isRegistered) ;
    }

    function addGlobalConstraint(address _globalConstraint, bytes32 _params, address _avatar)
    external onlyGlobalConstraintsScheme(_avatar) returns(bool)
    {

        Organization storage organization = organizations[_avatar];
        GlobalConstraintInterface.CallPhase when = GlobalConstraintInterface(_globalConstraint).when();
        if ((when == GlobalConstraintInterface.CallPhase.Pre)||(when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            if (!organization.globalConstraintsRegisterPre[_globalConstraint].isRegistered) {
                organization.globalConstraintsPre.push(GlobalConstraint(_globalConstraint,_params));
                organization.globalConstraintsRegisterPre[_globalConstraint] = GlobalConstraintRegister(true,organization.globalConstraintsPre.length-1);
            }else {
                organization.globalConstraintsPre[organization.globalConstraintsRegisterPre[_globalConstraint].index].params = _params;
            }
        }

        if ((when == GlobalConstraintInterface.CallPhase.Post)||(when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            if (!organization.globalConstraintsRegisterPost[_globalConstraint].isRegistered) {
                organization.globalConstraintsPost.push(GlobalConstraint(_globalConstraint,_params));
                organization.globalConstraintsRegisterPost[_globalConstraint] = GlobalConstraintRegister(true,organization.globalConstraintsPost.length-1);
           }else {
                organization.globalConstraintsPost[organization.globalConstraintsRegisterPost[_globalConstraint].index].params = _params;
           }
        }
        emit AddGlobalConstraint(_globalConstraint, _params,when,_avatar);
        return true;
    }

    function removeGlobalConstraint (address _globalConstraint,address _avatar)
    external onlyGlobalConstraintsScheme(_avatar) returns(bool)
    {
        GlobalConstraintInterface.CallPhase when = GlobalConstraintInterface(_globalConstraint).when();
        if ((when == GlobalConstraintInterface.CallPhase.Pre)||(when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            removeGlobalConstraintPre(_globalConstraint,_avatar);
        }
        if ((when == GlobalConstraintInterface.CallPhase.Post)||(when == GlobalConstraintInterface.CallPhase.PreAndPost)) {
            removeGlobalConstraintPost(_globalConstraint,_avatar);
        }
        return false;
    }

    function upgradeController(address _newController,address _avatar)
    external onlyUpgradingScheme(_avatar) returns(bool)
    {

        require(newControllers[_avatar] == address(0));   // so the upgrade could be done once for a contract.
        require(_newController != address(0));
        newControllers[_avatar] = _newController;
        (Avatar(_avatar)).transferOwnership(_newController);
        require(Avatar(_avatar).owner() == _newController);
        if (organizations[_avatar].nativeToken.owner() == address(this)) {
            organizations[_avatar].nativeToken.transferOwnership(_newController);
            require(organizations[_avatar].nativeToken.owner() == _newController);
        }
        if (organizations[_avatar].nativeReputation.owner() == address(this)) {
            organizations[_avatar].nativeReputation.transferOwnership(_newController);
            require(organizations[_avatar].nativeReputation.owner() == _newController);
        }
        emit UpgradeController(this,_newController,_avatar);
        return true;
    }

    function genericCall(address _contract,bytes _data,address _avatar)
    external
    onlyGenericCallScheme(_avatar)
    onlySubjectToConstraint("genericCall",_avatar)
    returns (bytes32)
    {

        emit GenericCall(_contract, _data,_avatar);
        (Avatar(_avatar)).genericCall(_contract, _data);
        assembly {
        returndatacopy(0, 0, returndatasize)
        return(0, returndatasize)
        }
    }

    function sendEther(uint _amountInWei, address _to,address _avatar)
    external
    onlyRegisteredScheme(_avatar)
    onlySubjectToConstraint("sendEther",_avatar)
    returns(bool)
    {

        emit SendEther(msg.sender, _amountInWei, _to);
        return (Avatar(_avatar)).sendEther(_amountInWei, _to);
    }

    function externalTokenTransfer(StandardToken _externalToken, address _to, uint _value,address _avatar)
    external
    onlyRegisteredScheme(_avatar)
    onlySubjectToConstraint("externalTokenTransfer",_avatar)
    returns(bool)
    {

        emit ExternalTokenTransfer(msg.sender, _externalToken, _to, _value);
        return (Avatar(_avatar)).externalTokenTransfer(_externalToken, _to, _value);
    }

    function externalTokenTransferFrom(StandardToken _externalToken, address _from, address _to, uint _value,address _avatar)
    external
    onlyRegisteredScheme(_avatar)
    onlySubjectToConstraint("externalTokenTransferFrom",_avatar)
    returns(bool)
    {

        emit ExternalTokenTransferFrom(msg.sender, _externalToken, _from, _to, _value);
        return (Avatar(_avatar)).externalTokenTransferFrom(_externalToken, _from, _to, _value);
    }

    function externalTokenIncreaseApproval(StandardToken _externalToken, address _spender, uint _addedValue,address _avatar)
    external
    onlyRegisteredScheme(_avatar)
    onlySubjectToConstraint("externalTokenIncreaseApproval",_avatar)
    returns(bool)
    {

        emit ExternalTokenIncreaseApproval(msg.sender,_externalToken,_spender,_addedValue);
        return (Avatar(_avatar)).externalTokenIncreaseApproval(_externalToken, _spender, _addedValue);
    }

    function externalTokenDecreaseApproval(StandardToken _externalToken, address _spender, uint _subtractedValue,address _avatar)
    external
    onlyRegisteredScheme(_avatar)
    onlySubjectToConstraint("externalTokenDecreaseApproval",_avatar)
    returns(bool)
    {

        emit ExternalTokenDecreaseApproval(msg.sender,_externalToken,_spender,_subtractedValue);
        return (Avatar(_avatar)).externalTokenDecreaseApproval(_externalToken, _spender, _subtractedValue);
    }

    function getNativeReputation(address _avatar) external view returns(address) {

        return address(organizations[_avatar].nativeReputation);
    }

    function removeGlobalConstraintPre(address _globalConstraint,address _avatar)
    private returns(bool)
    {

        GlobalConstraintRegister memory globalConstraintRegister = organizations[_avatar].globalConstraintsRegisterPre[_globalConstraint];
        GlobalConstraint[] storage globalConstraints = organizations[_avatar].globalConstraintsPre;

        if (globalConstraintRegister.isRegistered) {
            if (globalConstraintRegister.index < globalConstraints.length-1) {
                GlobalConstraint memory globalConstraint = globalConstraints[globalConstraints.length-1];
                globalConstraints[globalConstraintRegister.index] = globalConstraint;
                organizations[_avatar].globalConstraintsRegisterPre[globalConstraint.gcAddress].index = globalConstraintRegister.index;
              }
            globalConstraints.length--;
            delete organizations[_avatar].globalConstraintsRegisterPre[_globalConstraint];
            emit RemoveGlobalConstraint(_globalConstraint,globalConstraintRegister.index,true,_avatar);
            return true;
        }
        return false;
    }

    function removeGlobalConstraintPost(address _globalConstraint,address _avatar)
    private returns(bool)
    {

        GlobalConstraintRegister memory globalConstraintRegister = organizations[_avatar].globalConstraintsRegisterPost[_globalConstraint];
        GlobalConstraint[] storage globalConstraints = organizations[_avatar].globalConstraintsPost;

        if (globalConstraintRegister.isRegistered) {
            if (globalConstraintRegister.index < globalConstraints.length-1) {
                GlobalConstraint memory globalConstraint = globalConstraints[globalConstraints.length-1];
                globalConstraints[globalConstraintRegister.index] = globalConstraint;
                organizations[_avatar].globalConstraintsRegisterPost[globalConstraint.gcAddress].index = globalConstraintRegister.index;
              }
            globalConstraints.length--;
            delete organizations[_avatar].globalConstraintsRegisterPost[_globalConstraint];
            emit RemoveGlobalConstraint(_globalConstraint,globalConstraintRegister.index,false,_avatar);
            return true;
        }
        return false;
    }

    function _isSchemeRegistered( address _scheme,address _avatar) private view returns(bool) {

        return (organizations[_avatar].schemes[_scheme].permissions&bytes4(1) != bytes4(0));
    }
}