
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
contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
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
contract ERC827 is ERC20 {


    function approveAndCall(address _spender,uint256 _value,bytes _data) public payable returns(bool);


    function transferAndCall(address _to,uint256 _value,bytes _data) public payable returns(bool);


    function transferFromAndCall(address _from,address _to,uint256 _value,bytes _data) public payable returns(bool);


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


contract UniversalSchemeInterface {


    function updateParameters(bytes32 _hashedParameters) public;


    function getParametersFromController(Avatar _avatar) internal view returns(bytes32);

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




contract SchemeRegistrar is UniversalScheme {

    event NewSchemeProposal(
        address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _intVoteInterface,
        address _scheme,
        bytes32 _parametersHash,
        bytes4 _permissions
    );
    event RemoveSchemeProposal(address indexed _avatar,
        bytes32 indexed _proposalId,
        address indexed _intVoteInterface,
        address _scheme
    );
    event ProposalExecuted(address indexed _avatar, bytes32 indexed _proposalId,int _param);
    event ProposalDeleted(address indexed _avatar, bytes32 indexed _proposalId);

    struct SchemeProposal {
        address scheme; //
        bytes32 parametersHash;
        uint proposalType; // 1: add a scheme, 2: remove a scheme.
        bytes4 permissions;
    }

    mapping(address=>mapping(bytes32=>SchemeProposal)) public organizationsProposals;

    struct Parameters {
        bytes32 voteRegisterParams;
        bytes32 voteRemoveParams;
        IntVoteInterface intVote;
    }
    mapping(bytes32=>Parameters) public parameters;


    function execute(bytes32 _proposalId, address _avatar, int _param) external returns(bool) {

        require(parameters[getParametersFromController(Avatar(_avatar))].intVote == msg.sender);
        SchemeProposal memory proposal = organizationsProposals[_avatar][_proposalId];
        require(proposal.scheme != address(0));
        delete organizationsProposals[_avatar][_proposalId];
        emit ProposalDeleted(_avatar,_proposalId);
        if (_param == 1) {

            ControllerInterface controller = ControllerInterface(Avatar(_avatar).owner());

            if (proposal.proposalType == 1) {
                require(controller.registerScheme(proposal.scheme, proposal.parametersHash, proposal.permissions,_avatar));
            }
            if ( proposal.proposalType == 2 ) {
                require(controller.unregisterScheme(proposal.scheme,_avatar));
            }
          }
        emit ProposalExecuted(_avatar, _proposalId,_param);
        return true;
    }

    function setParameters(
        bytes32 _voteRegisterParams,
        bytes32 _voteRemoveParams,
        IntVoteInterface _intVote
    ) public returns(bytes32)
    {

        bytes32 paramsHash = getParametersHash(_voteRegisterParams, _voteRemoveParams, _intVote);
        parameters[paramsHash].voteRegisterParams = _voteRegisterParams;
        parameters[paramsHash].voteRemoveParams = _voteRemoveParams;
        parameters[paramsHash].intVote = _intVote;
        return paramsHash;
    }

    function getParametersHash(
        bytes32 _voteRegisterParams,
        bytes32 _voteRemoveParams,
        IntVoteInterface _intVote
    ) public pure returns(bytes32)
    {

        return keccak256(abi.encodePacked(_voteRegisterParams, _voteRemoveParams, _intVote));
    }

    function proposeScheme(
        Avatar _avatar,
        address _scheme,
        bytes32 _parametersHash,
        bytes4 _permissions
    )
    public
    returns(bytes32)
    {

        require(_scheme != address(0));
        Parameters memory controllerParams = parameters[getParametersFromController(_avatar)];

        bytes32 proposalId = controllerParams.intVote.propose(
            2,
            controllerParams.voteRegisterParams,
            _avatar,
            ExecutableInterface(this),
            msg.sender
        );

        SchemeProposal memory proposal = SchemeProposal({
            scheme: _scheme,
            parametersHash: _parametersHash,
            proposalType: 1,
            permissions: _permissions
        });
        emit NewSchemeProposal(
            _avatar,
            proposalId,
            controllerParams.intVote,
            _scheme, _parametersHash,
            _permissions
        );
        organizationsProposals[_avatar][proposalId] = proposal;

        controllerParams.intVote.ownerVote(proposalId, 1, msg.sender); // Automatically votes `yes` in the name of the opener.
        return proposalId;
    }

    function proposeToRemoveScheme(Avatar _avatar, address _scheme)
    public
    returns(bytes32)
    {

        bytes32 paramsHash = getParametersFromController(_avatar);
        Parameters memory params = parameters[paramsHash];

        IntVoteInterface intVote = params.intVote;
        bytes32 proposalId = intVote.propose(2, params.voteRemoveParams, _avatar, ExecutableInterface(this),msg.sender);

        organizationsProposals[_avatar][proposalId].proposalType = 2;
        organizationsProposals[_avatar][proposalId].scheme = _scheme;
        emit RemoveSchemeProposal(_avatar, proposalId, intVote, _scheme);
        intVote.ownerVote(proposalId, 1, msg.sender); // Automatically votes `yes` in the name of the opener.
        return proposalId;
    }
}